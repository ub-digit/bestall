# Bestall playbooks

## Installation
To install ub-ansible-deploy role and other dependencies required by this playbook run `ansible-galaxy install -r requirements.yml`
To update dependencies run the same command with the -f flag to force reinstalltion.

## Configuration

### Add new ansible host

For a new host, create `inventory/<host-alias>.yml` containing:

```yaml
---
all:
  hosts:
    <host-alias>:
      ansible_host: <host-url>
      ansible_user: apps
```

Set host specic variables in `host_vars/<host-alias>/vars.yml`.

Set encrypted host specific variables in `host_vars/<host-alias>/vault.yml`, prefixed with `vault_`.

To create the encrypted vault.yml file run:
`ansible-vault create --vault-password-file .vault_password host_vars/<host-alias>/vault.yml`
Replace `create` with `edit` to edit the file.

Vault variables should then be used in the plain text file like:
`variable_name: "{{ vault_variable_name }}"`

This way they are searchable with tools such as grep etc.

Set variables shared between hosts in `group_vars/all/vars.yml`.
Set encrypted shared variables, such as common api keys etc, in `group_vars/all/vault.yml`, prefixed with `vault_` and refered to in `group_vars/all/vars.yml` as shown above.

### Docker .env and secrets.env configuration
To set variables in `.env` and `secrets.env` there are a number of special files:

#### vars/default_env.yml
Environment variables shared between all hosts. Existing values in .env will be replaced with variables defined here.

#### vars/default_secret_env.yml
Secret environment variables shared between all hosts. secret.env.example will be copied to secret.env and existing values will be replaced with values defined here.

#### vars/\<host-alias\>/env.yml
Host specific environment variables, these will be merged in with the default variables.

#### vars/\<host-alias\>/secret_env.yml
Host specific secret environment variables, these will be merged in with the default secret variables.

### Apache configuration
`<file-name>.conf.j2` files in `templates/sites/` will be deployed to /etc/gub-apache2/sites as `<file-name>-<host-alias.conf`, except for production where the host-alias suffix is not included.

### Cron configuration
`<file-name>,j2` files in `templates/cron.d/ will be deployed to `/etc/cron.d/<file-name>`.

## Deployment
- Save vault password in `.vault_password`
- Run ./run-playbook.sh <host> deploy replacing \<host\> with host alias name, for example `lab`.
- To use ansible-playbook command directly run `ansible-playbook -i inventory/<host>.yml --vault-password-file .vault_password deploy.yml` 

(The -C flag can be used to run the playbook without performing and changes on the target server.)

## ./run-playbook.sh
Helper script for running playbook. To use, run `./run-playbook.sh <playbook> <host> <optiona-extra-arguments>`.
