# Proxmox-Kube
With this repo deploy Kubernetes to a fresh install of Proxmox.
## Ansible Setup
### SSH configuration
Ansible leans on pre-defined SSH hosts for access to Proxmox, the template VM, and all the kube VMs. This is so ansible has nothing to do with the authentication portion for accessing the various nodes. Here is an example for how you could set it up:
- `~/.ssh/config` add an include line at the top of the file:
```bash
include config.d/*/*.conf
```
- `~/.ssh/config.d/proxmox-kube/pve.conf` define pve hosts:
```bash
Host pve0_root
    Hostname <IP-or-FQDN-PVEHost>
    User root
    Identityfile ~/.ssh/.id/<some-private-key>

Host pve0
    Hostname <IP-or-FQDN-PVEHost>
    User ansible
    Identityfile ~/.ssh/.id_ansible/<ansible-specific-private-key>
# Add additional PVE hosts as required by the setup - tho multiple PVE hosts are not supported and you'd have to create additional playbooks targeting these additional PVE hosts
```
- `~/.ssh/config.d/proxmox-kube/kube.conf` define the kube hosts:
```bash
Host kube*
    User ansible
    Identityfile ~/.ssh/.id_ansible/ansible_ed25519

Host kube_template
    Hostname <IP-or-FQDN-for-template-VM>

Host kube_cntrl0
    Hostname <IP-or-FQDN-for-kube-controller-0>

Host kube_worker0
    Hostname <IP-or-FQDN-for-kube-worker-0>
# Add additional cntrl/worker nodes as required by setup
```
### Setup Environment file for the container
Copy the provided `default.env` file to `prod.env`, `dev.env`, `staging.env`, etc... and fill out the fields as required. This will configure environment variables related to Ansible and Ansible's SSH access to the proxmox instance. Note that you can add any Ansible compatible environment variables if you need further configurations to be applied.
### Build and run the deployment container
Execute the `run.sh` script and if the system is missing the `proxmox-kube-deployer` image it will request to build it. Alternatively you can cd to the Docker directory and execute:
```bash
docker build -t proxmox-kube-deployer:v$(date -I) .
```
User the `run.sh` script for starting a container where you will execute the ansible/terraform. Use the `-e <file>` or `--env <file>`  to specify an environment file to use when starting the container. Note the default searches for `dev.env`.
### Create secret files
Create `./ansible/.key/vault_key` with a randomly generated password for encrypting secrets.

Create `./ansible/.secret/become_passwd` with the proxmox server's ansible user's password (for when become: true aka `sudo su`)

Create `./ansible/.secret/pve0-proxmox-secret.yml` to store the proxmox secret details
- You'll need the following `key: value` pairs:
    - `api_token_secret: <api-key>`
    - `cloudinit_password: <cloud-init-user-passwd>`
- Note: For secrets stored in yml format use the vault key to encrypt them:
    - `ansible-vault encrypt_string --vault-password-file ./ansible/.key/vault_key 'test'` where `'test'` is the string to encrypt
    - output: 
        ```
        !vault |
        $ANSIBLE_VAULT;1.1;AES256
        61616437336431316434386337303639316339666532333634623666333137663134316435353638
        3830646266336638393037303836643761626337333036660a626535656532653535626538643834
        31656530306236313366333261346637646536663934653034383834633863393166313133663032
        3831333663316332640a313663366130363435613961303037316235353133343133343439303561
        3230
        ```
    - Now you can add the encrypted string to the value of a key in the yaml file:
        - ```
            api_token_secret: !vault |
            $ANSIBLE_VAULT;1.1;AES256
            61616437336431316434386337303639316339666532333634623666333137663134316435353638
            3830646266336638393037303836643761626337333036660a626535656532653535626538643834
            31656530306236313366333261346637646536663934653034383834633863393166313133663032
            3831333663316332640a313663366130363435613961303037316235353133343133343439303561
            3230
            ```
            You will likely have to fix the spacing of the vault output.
- Note create additional pve1, pve2, etc... for each PVE instance.
### Update inventory files as needed
- `./ansible/inventory/group_vars/all/ansible-user.yml` At the very least update the public key.
- `./ansible/inventory/group_vars/all/user.yml` Modify user name and public key.
- `./ansible/inventory/group_vars/all/network.yml` Modify gateway and kube subnet info as needed.
- `./ansible/inventory/proxmox.yml` Update the api info as needed.
- `./ansible/inventory/kube.yml` Update IP/IDs as needed.
## Ansible Execution
Execute the following playbook to start the process
- `ansible-playbook ./ansible/playbook/setup_proxmox.yml`

This will accomplish the following:
- Install Proxmox dependencies (with root)
- Setup Proxmox PAM users (with root)
- Configure proxmox
    - fix repos (note this removes subscription based repo)
    - install basic packages
    - setup ubuntu cloud img (used for template vm)
    - create template vm (and start)
- setup template vm
- convert template vm into a template

## Terraform Setup
Work in progress
## Terraform Execution
Work in progress