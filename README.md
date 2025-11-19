# Proxmox 9 Template builder

## Usage
- Copy variables.auto.pkrvars.hcl.template to variables.auto.pkrvars.hcl
- Complete the informations
- run `./run.sh`

## Template to build for GOAD
- Windows Server 2016 - x64 - eval no update : 201600
- Windows Server 2019 - x64 - eval updated   : 201901
- Windows Server 2019 - x64 - eval no update : 201900
- Windows 10 22h2 - x64 - eval updated       : 102221
- Ubuntu server 24.04                        : 924040

## Templates ID:

| vm_id  | template name                                     |
| ------ | ------------------------------------------------- |
| 102220 │ windows-10-22h2-x64-enterprise-eval-noup-template │
| 102221 │ windows-10-22h2-x64-enterprise-template           │
| 102221 │ windows-10-22h2-x64-enterprise-eval-template      │
| 112420 │ windows-11-24h2-x64-enterprise-eval-noup-template │
| 112421 │ windows-11-24h2-x64-enterprise-eval-template      │
| 112422 │ windows-11-24h2-x64-enterprise-template           │
| 112520 │ windows-11-25h2-x64-enterprise-eval-noup-template │
| 112521 │ windows-11-25h2-x64-enterprise-eval-template      │
| 112522 │ windows-11-25h2-x64-enterprise-template           │
| 201600 │ windows-server-2016-x64-eval-noup-template        │
| 201601 │ windows-server-2016-x64-eval-template             │
| 201602 │ windows-server-2016-x64-template                  │
| 201900 │ windows-server-2019-x64-eval-noup-template        │
| 201901 │ windows-server-2019-x64-eval-template             │
| 201902 │ windows-server-2019-x64-template                  │
| 813000 │ debian-13-x64-template                            │
| 922040 │ ubuntu-22.04-x64-server-template                  │
| 924040 │ ubuntu-24.04-x64-server-template                  │

## Windows templates

- The windows template are created using evaluation version : 180 days for server / 90 days for workstation
- The Windows templates are cloudInit Ready and sysprepared
- Default language is EN-US
- Default keyboards are US + FR
- Default timezone is Europe/Paris
