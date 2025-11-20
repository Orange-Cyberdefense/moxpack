#!/usr/bin/env python3
import os
import sys
import hcl2
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple
from urllib.parse import urlparse
from rich import print as rprint
from rich.table import Table
from proxmoxer import ProxmoxAPI
from proxmoxer.core import ResourceException
import subprocess
import argparse

@dataclass
class Template:
    vm_id: str = ""
    vm_name: str = ""
    template_path: str = ""
    description: str = ""
    iso_file: str = ""
    vm_disk_size: str = ""

class Proxmox:
    DEFAULT_CONFIG_PATH = os.path.abspath("variables.auto.pkrvars.hcl")

    def __init__(self):
        self.config = self.load_config()
        self.proxmox_client = self.connect_proxmox(self.config)

    def get_config(self):
        return self.config

    def load_config(self, path: str = DEFAULT_CONFIG_PATH) -> dict:
        if not os.path.exists(path):
            rprint(f"[red]Configuration file not found: {path}[/red]")
            rprint("[red]Copy the variables.auto.pkrvars.hcl.template file to variables.auto.pkrvars.hcl and complete it[/red]")
            sys.exit(2)
        with open(path, "r", encoding="utf-8") as f:
            config = hcl2.load(f)
        return config

    def connect_proxmox(self, config: dict) -> ProxmoxAPI:
        parsed = urlparse(config.get("proxmox_api_url"))
        host = parsed.hostname
        [user, token_name] = config.get("proxmox_api_token_id").split('!')
        skip_verify = config.get("proxmox_skip_tls_verify", False)
        verify_ssl = not skip_verify

        token_value = config.get("proxmox_api_token_secret", "")
        if token_value == "":
            token_value = os.getenv("PROXMOX_API_TOKEN", "")
            if token_value == "":
                 rprint(f"[red]Missing env value PROXMOX_API_TOKEN[/red]")
                 sys.exit(3)
        try:
            rprint(f"[blue]Connecting to Proxmox host {host} as {user}[/blue]")
            proxmox_client = ProxmoxAPI(
                host,
                user=user,
                token_name=token_name,
                token_value=token_value,
                verify_ssl=verify_ssl
            )
            rprint("[green]Proxmox connection OK[/green]")
        except Exception as e:
            rprint(f"[red]Failed to connect to Proxmox: {e}[/red]")
            sys.exit(1)
        return proxmox_client

    def load_proxmox_templates(self) -> dict[str, dict]:
        proxmox_vms = {}
        for node in self.proxmox_client.nodes.get():
            nodename = node["node"]
            try:
                vms = self.proxmox_client.nodes(nodename).qemu.get()
                for vm in vms:
                    vmid = str(vm["vmid"])
                    proxmox_vms[vmid] = {
                        "node": nodename,
                        "type": "qemu",
                        "name": vm.get("name"),
                        "is_template": vm.get("template", 0)
                    }
            except ResourceException:
                pass
        return proxmox_vms

    def load_iso_cache(self):
        """Load all iso."""
        self.iso_cache = []

        nodes = self.proxmox_client.nodes.get()

        for node in nodes:
            node_name = node["node"]
            storages = self.proxmox_client.nodes(node_name).storage.get()

            for storage in storages:
                storage_name = storage["storage"]

                try:
                    content = self.proxmox_client.nodes(node_name).storage(storage_name).content.get()
                except Exception:
                    continue  # stockage inaccessible

                for item in content:
                    if item.get("content") == "iso":
                        self.iso_cache.append(item["volid"])
        return self.iso_cache


class Moxpack:
    def __init__(self, templates_dir: str = "./templates"):
        self.templates_dir = Path(templates_dir)
        self.templates: List[Template] = []
        self.proxmox = Proxmox()
        self.refresh_proxmox_vms()
        self.refresh_proxmox_isos()
        default_disk_size = self.proxmox.get_config().get('vm_disk_size','-')
        self.load_templates(self.templates_dir, default_disk_size)

    def refresh_proxmox_vms(self):
        rprint("[green]Refreshing Proxmox VMs[/green]")
        self.proxmox_vms = self.proxmox.load_proxmox_templates()

    def refresh_proxmox_isos(self):
        rprint("[green]Refreshing Proxmox ISOs[/green]")
        self.proxmox_isos = self.proxmox.load_iso_cache()

    def load_templates(self, path: Path, default_disk_size: str) -> List[Template]:
        rprint(f"[green]Loading Packer template config files from {path}[/green]")
        self.templates = []

        if not path.exists():
            rprint(f"[red]Directory {path} does not exist[/red]")
            return self.templates

        for file_path in path.rglob("*.pkrvars.hcl"):
            if file_path.name.endswith("variables.auto.pkrvars.hcl"):
                continue
            try:
                with file_path.open("r", encoding="utf-8") as f:
                    vm_config = hcl2.load(f)
            except Exception as e:
                rprint(f"[red]Failed to parse {file_path}: {e}[/red]")
                continue

            tpl = Template(
                template_path=str(file_path),
                vm_id=str(vm_config.get('vm_id', '-1')),
                vm_name=vm_config.get('vm_name', '-'),
                description=vm_config.get('description', ''),
                iso_file=vm_config.get('iso_file', ''),
                vm_disk_size=vm_config.get('vm_disk_size', default_disk_size)
            )
            tpl.uptodate = str(vm_config.get('uptodate', False))
            self.templates.append(tpl)

        def sort_key(t: Template) -> Tuple[int, object]:
            if t.vm_id:
                try:
                    return (0, int(t.vm_id))
                except ValueError:
                    return (1, t.vm_id.lower())
            return (2, t.template_path)

        self.templates.sort(key=sort_key)
        return self.templates

    def show_status(self):
        table = Table(show_header=True, header_style="bold")
        #table.add_column("Status", style="bold", justify="center")
        table.add_column("Id", style="bold cyan", no_wrap=True)
        table.add_column("Name")
        table.add_column("Description")
        table.add_column("Status Infos")
        table.add_column("Sec. Updates", justify="center")
        table.add_column("Disk")
        table.add_column("Need Iso")
        #table.add_column("Path", style="dim")

        prev_prefix = None
        num_columns = len(table.columns)

        for template in self.templates:
            # if 4 first digits change add an empty line
            vm_id_str = str(template.vm_id or "")
            digits = "".join(ch for ch in vm_id_str if ch.isdigit())
            if len(digits) >= 4:
                prefix = digits[:4]
            else:
                prefix = digits or vm_id_str[:4]

            if prev_prefix is not None and prefix != prev_prefix:
                table.add_section()

            prev_prefix = prefix

            # status evaluation
            status = '[bright_black]ABSENT[/bright_black]'
            status_color = 'bright_black'
            status_infos = '[cyan]Ready for creation[/cyan]'
            for vm_id, vm in self.proxmox_vms.items():
                if vm_id == template.vm_id:
                    if vm.get('is_template') == 0:
                        status = '[yellow]WARNING[/yellow]'
                        status_color = 'yellow'
                        status_infos = '[yellow]Id already taken by a VM[/yellow]'
                        break
                    if template.vm_name == vm.get('name'):
                        status = '[green]OK[/green]'
                        status_color = 'green'
                        status_infos = '[green]OK[/green]'
                    else:
                        status = '[yellow]WARNING[/yellow]'
                        status_color = 'yellow'
                        status_infos = '[yellow]Template name mismatch[/yellow]'
                    break
                if template.vm_name == vm.get('name'):
                    status = '[yellow]WARNING[/yellow]'
                    status_color = 'yellow'
                    status_infos = '[yellow]Name already exists[/yellow]'
            security_update = "[green]Y[/green]" if template.uptodate == "True" else "N"

            iso_file = ""
            if template.iso_file in self.proxmox_isos:
                iso_file = f"[green]{template.iso_file}[/green]"
            elif template.iso_file != "":
                iso_file = f"[bright_black]{template.iso_file}[/bright_black]"
                status_infos = '[yellow]Missing iso[/yellow]'
            
            table.add_row(
                #status,
                template.vm_id or "-",
                f"[{status_color}]{template.vm_name}[/{status_color}]" or "-",
                template.description or "-",
                status_infos,
                security_update,
                template.vm_disk_size,
                iso_file,
                #template.template_path or "-",
            )
        rprint(table)

    def build_templates(self, vm_ids: list[str]):
        for vm_id in vm_ids:
            rprint(f"[blue]=== Build for vm_id={vm_id} ===[/blue]")
            tpl = next((t for t in self.templates if t.vm_id == vm_id), None)
            if not tpl:
                rprint(f"[red]Template with vm_id={vm_id} not found.[/red]")
                continue

            # Check status
            status = "OK"
            for p_vm_id, vm in self.proxmox_vms.items():
                if p_vm_id == tpl.vm_id or tpl.vm_name == vm.get("name"):
                    status = "WARNING"
                    break

            if status == "WARNING":
                rprint(f"[yellow]Template {tpl.vm_name} conflicts with existing VM/template. Build denied[/yellow]")
                continue

            var_file = tpl.template_path
            template_dir = Path(var_file).parent

            # Validate
            rprint(f"[blue]Validating template with {var_file}[/blue]")
            validate_cmd = ["packer", "validate", "-var-file", str(var_file), str(template_dir)]
            result = subprocess.run(validate_cmd, capture_output=True, text=True)
            print(result.stdout)
            if result.returncode != 0:
                rprint(f"[red]Validation failed for {tpl.vm_name}[/red]")
                continue

            # Build
            rprint(f"[blue]Starting Packer build for {tpl.vm_name}[/blue]")
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
                rprint(f"[green]Build finished successfully for {tpl.vm_name}[/green]")
            else:
                rprint(f"[red]Build failed for {tpl.vm_name} (code {process.returncode})[/red]")
            self.refresh_proxmox_vms()
            self.show_status()

def main():
    parser = argparse.ArgumentParser(description="Moxpack: Proxmox template manager with Packer")
    subparsers = parser.add_subparsers(dest="command")

    parser_status = subparsers.add_parser("status", help="Show templates status")
    parser_build = subparsers.add_parser("build", help="Build templates by vm_id")
    parser_build.add_argument("vm_ids", nargs="+", help="VM IDs to build")

    args = parser.parse_args()

    rprint('[dark_orange]Mox[/dark_orange]Pack - A proxmox template builder')
    cli = Moxpack()

    if args.command == "status":
        cli.show_status()
    elif args.command == "build":
        cli.build_templates(args.vm_ids)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
