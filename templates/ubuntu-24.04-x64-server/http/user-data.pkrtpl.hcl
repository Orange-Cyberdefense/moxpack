#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: ${keymap}
    variant: ${keymap_variant}
  ssh:
    install-server: true
    allow-pw: true
    authorized-keys: 
      - "${ssh_public_key}"
    allow_public_ssh_keys: true
  packages:
    - qemu-guest-agent
    - sudo
    - ca-certificates
    - python3
    - acpid
    - dbus
    - ifupdown
  storage:
    layout:
      name: direct
    swap:
      size: 0
  identity:
    hostname: ubuntu2404
    username: ${user}
    password: '$6$JyqesGqWCcmPjsm7$6SZDGITcgCZcE2mMNc1jse0YyYEdDVPdoH.wWIX.3yYe7RNNXA2XvZm.qOwzLYjhRNv45RZ8ySmIqCM0MkQX20' # mkpasswd -m sha-512 vagrant
  user-data:
    package_upgrade: yes
    timezone: ${timezone}
    disable_root: false
    ssh_pwauth: true
    chpasswd:
      expire: false
      users:
      - {name: ${user}, password: ${password}, type: text}
  late-commands:
    - 'echo PubkeyAcceptedKeyTypes=+ssh-rsa >> /target/etc/ssh/sshd_config'  # Required for packer to connect via SSH. See https://github.com/hashicorp/packer/issues/11733
    - 'echo "${user} ALL = (root) NOPASSWD: ALL" > /target/etc/sudoers.d/${user}'
