#!/usr/bin/env python3
import cmd
import os
import sys
import hcl2
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Tuple
from urllib.parse import urlparse
from rich import print as rprint
from rich.table import Table
from proxmoxer import ProxmoxAPI
from proxmoxer.core import ResourceException
import subprocess

@dataclass
class Template:
    vm_id: str = ""
    vm_name: str = ""
    template_path: str = ""
    description: str = ""

class Proxmox:
    DEFAULT_CONFIG_PATH = os.path.abspath("variables.auto.pkrvars.hcl")

    def __init__(self):
        config = self.load_config()
        self.proxmox_client = self.connect_proxmox(config)


    def load_config(self, path: str = DEFAULT_CONFIG_PATH) -> dict:
        if not os.path.exists(path):
            rprint(f"[red]Configuration file not found: {path}[/red]")
            rprint("[red]Copy the variables.auto.pkrvars.hcl.template file to variables.auto.pkrvars.hcl and complete it[/red]")
            sys.exit(2)
        with open(path, "r", encoding="utf-8") as f:
            config = hcl2.load(f)
        return config
    
    def connect_proxmox(self, config: dict) -> ProxmoxAPI:
        proxmox_client = None
        parsed = urlparse(config.get("proxmox_api_url"))
        host = parsed.hostname
        [user, token_name] = config.get("proxmox_api_token_id").split('!')
        skip_verify = config.get("proxmox_skip_tls_verify", False)
        verify_ssl = not skip_verify
        token_value = config.get("proxmox_api_token_secret")
        try:
            rprint('[blue]Try proxmox connection with [/blue]')
            rprint(f' - host       : {host}')
            rprint(f' - user       : {user}')
            rprint(f' - token_name : {token_name}')
            rprint(f' - verify_ssl : {verify_ssl}')
            proxmox_client = ProxmoxAPI(host,
                                user=user,
                                token_name=token_name,
                                token_value=token_value,
                                verify_ssl=verify_ssl)
            rprint(f"[green]Proxmox connection ok ![/green]")
        except Exception as e:
            rprint(f"[red]Failed to connect to Proxmox: {e}[/red]")
            sys.exit(1)
        return proxmox_client

    def load_proxmox_templates(self) -> dict[str, dict]:
        """
        Returns mapping str(vmid) -> {node, type, name, vmid}
        """
        proxmox_vms = {}
        for node in self.proxmox_client.nodes.get():
            nodename = node["node"]
            # QEMU
            try:
                vms = self.proxmox_client.nodes(nodename).qemu.get()
                for vm in vms:
                    vmid = str(vm["vmid"])
                    proxmox_vms[vmid] = {"node": nodename, "type": "qemu", "name": vm.get("name"), "is_template": vm.get("template", 0)}
            except ResourceException:
                pass
        return proxmox_vms


class Packmox(cmd.Cmd):
    intro = "Packmox type 'help' or '?' for the command list."
    prompt = "(packmox) > "

    def __init__(self, templates_dir: str = "./templates"):
        super().__init__()
        # load proxmox
        self.proxmox = Proxmox()
        self.refresh_proxmox_vms()        
        # load templates
        self.templates_dir = Path(templates_dir)
        self.templates: List[Template] = []
        self.load_templates(self.templates_dir)
        # show summary at start
        self.do_status('')

    def refresh_proxmox_vms(self):
        rprint(f"[green]Refresh proxmox vms[/green]")
        self.proxmox_vms = self.proxmox.load_proxmox_templates()

    def load_templates(self, path: Path) -> List[Template]:
        rprint(f"[blue]Load packer templates config files[/blue]")
        self.templates = []

        if not path.exists():
            rprint(f"[red]Le dossier {path} n'existe pas.[/red]")
            return self.templates

        for file_path in path.rglob("*.pkrvars.hcl"):
            if file_path.name.endswith("variables.auto.pkrvars.hcl"):
                continue

            try:
                with file_path.open("r", encoding="utf-8") as f:
                    vm_config = hcl2.load(f)
            except Exception as e:
                rprint(f"[red]Erreur de lecture/parse du fichier {file_path}: {e}[/red]")
                continue

            tpl = Template(template_path=str(file_path))
            tpl.vm_id = str(vm_config.get('vm_id','-1'))
            tpl.vm_name = vm_config.get('vm_name','-')
            tpl.description = vm_config.get('description','')
            tpl.uptodate = str(vm_config.get('uptodate',False))

            self.templates.append(tpl)

        # tri des templates par vm_id (numérique si possible, sinon lexicographique)
        def sort_key(t: Template) -> Tuple[int, object]:
            if t.vm_id:
                try:
                    return (0, int(t.vm_id))
                except ValueError:
                    return (1, t.vm_id.lower())
            # mettre les éléments sans id en dernier
            return (2, t.template_path)

        self.templates.sort(key=sort_key)
        return self.templates

    def default(self, line: str):
        # override: affiche rien pour les commandes inconnues (peut être modifié)
        print()

    def do_status(self, arg: str):
        """status — affiche la liste des templates chargés"""
        table = Table(show_header=True, header_style="bold")
        table.add_column("Status", style="bold")
        table.add_column("Id", style="dim", no_wrap=True)
        table.add_column("Name")
        table.add_column("Description")
        table.add_column("Security Updates")
        table.add_column("Status Infos")
        table.add_column("Path", style="dim")

        for template in self.templates:
            status = '[red]ABSENT[/red]'
            status_infos = '[green]ready for creation[/green]'
            for vm_id, vm in self.proxmox_vms.items():
                if vm_id == template.vm_id:
                    # id already exist
                    if vm.get('is_template') == 0:
                        status = '[yellow]WARNING[/yellow]'
                        status_infos = '[yellow]Id already taken by a vm[/yellow]'
                        break
                    if template.vm_name == vm.get('name'):
                        status = '[green]OK[/green]'
                        status_infos = '[green]Ok and present[/green]'
                    else:
                        status = '[yellow]WARNING[/yellow]'
                        status_infos = '[yellow]Template name not match[/yellow]'
                    break
                if template.vm_name == vm.get('name'):
                    if vm.get('is_template') == 1:
                        status = '[yellow]WARNING[/yellow]'
                        status_infos = '[yellow]A template already exist with the same name[/yellow]'
                    else:
                        status = '[yellow]WARNING[/yellow]'
                        status_infos = '[yellow]A vm exist with the same name[/yellow]'
            table.add_row(
                status,
                template.vm_id or "-",
                template.vm_name or "-",
                template.description or "-",
                template.uptodate or "-",
                status_infos,
                template.template_path or "-"
            )
        rprint(table)

    def do_reload(self, arg: str):
        """reload — recharge les templates du dossier"""
        self.load_templates(self.templates_dir)
        rprint(f"[green]Reload {len(self.templates)} template(s).[/green]")

    def do_exit(self, arg: str):
        """exit — quitte"""
        print("bye")
        return True

    def do_quit(self, arg: str):
        """quit — alias de exit"""
        return self.do_exit(arg)

    def do_help(self, arg: str):
        # réutilise le help standard de cmd.Cmd (affiche docstrings)
        return super().do_help(arg)

    def do_build(self, arg: str):
        """
        build <vm_id1> [<vm_id2> ...] — launches Packer build for selected templates
        """
        # Split argument into a list of vm_ids
        vm_ids = arg.strip().split()
        if not vm_ids:
            rprint("[red]Usage: build <vm_id1> [<vm_id2> ...][/red]")
            return

        # Loop through each vm_id sequentially
        for vm_id in vm_ids:
            rprint(f"[blue]=== Build for vm_id={vm_id} ===[/blue]")

            # recherche du template
            tpl = next((t for t in self.templates if t.vm_id == vm_id), None)
            if not tpl:
                rprint(f"[red]Template with vm_id={vm_id} not found.[/red]")
                return

            # Vérifie le status dans proxmox_vms
            status = "ABSENT"
            status_msg = ""
            for p_vm_id, vm in self.proxmox_vms.items():
                if p_vm_id == tpl.vm_id or tpl.vm_name == vm.get("name"):
                    if vm.get("is_template") == 1:
                        status = "WARNING"
                        status_msg = "Template already exist with same ID or name"
                    else:
                        status = "WARNING"
                        status_msg = "VM already exist with same ID or name"
                    break
            else:
                status = "OK"

            if status == "WARNING":
                rprint(f"[yellow]{status_msg} — build denied[/yellow]")
                return
            elif status == "OK":
                rprint(f"[green]Template {tpl.vm_name} ready for build.[/green]")

            # Détermine le fichier var-file
            var_file = tpl.template_path
            template_dir = Path(tpl.template_path).parent

            if not template_dir:
                rprint(f"[red]template dir not found {tpl.template_dir}[/red]")
                return

            # Lance d'abord validate
            rprint(f"[blue]Validate template with {var_file}[/blue]")
            validate_cmd = ["packer", "validate", "-var-file", str(var_file), str(template_dir)]
            result = subprocess.run(validate_cmd, capture_output=True, text=True)
            print(result.stdout)
            if result.returncode != 0:
                rprint(f"[red]Validation failed for {tpl.vm_name}[/red]")
                return

            # Lance le build
            rprint(f"[blue]Start Packer build for {tpl.vm_name}[/blue]")
            build_cmd = ["packer", "build", "-var-file", str(var_file), str(template_dir)]
            process = subprocess.Popen(
                build_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )

            for line in process.stdout:
                print(line.rstrip())

            process.wait()
            if process.returncode == 0:
                rprint(f"[green]Build finished successful for {tpl.vm_name}[/green]")
            else:
                rprint(f"[red]Build failed for {tpl.vm_name} (code {process.returncode})[/red]")
        self.refresh_proxmox_vms()
        self.do_status('')


if __name__ == "__main__":
    Packmox().cmdloop()
