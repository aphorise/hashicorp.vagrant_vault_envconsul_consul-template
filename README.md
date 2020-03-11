# HashiCorp `vagrant` demo of **`vault`** with **`consul-template`** & **`envconsul`** tools.
This repo contains a `Vagrantfile` mock of a [Vault](https://www.vaultproject.io/) server demonstrating the use of [consul-template](https://github.com/hashicorp/consul-template) & [envconsul](https://github.com/hashicorp/envconsul/) used to set environmental variables and populate placeholders within configuration files using values retrieved from vault.


## Makeup & Concept

The concepts herein are drawn from the [Vault Direct Application Integration guide](https://learn.hashicorp.com/vault/developer/sm-app-integration). 

`consul-template` is tool that populates input files with values retried from either Vault or Consul; `envconsul` similarly sets environment variables using values retried from either Vault or Consul.

A vault server (hostname: vault-dev - in dev mode) instance is minimally configured with key-value (kv) secrets engine (kv2) enabled at the path of 'kv/'.

Example values are written to a few below and then retrieved after for passing to `vault_example_app.sh` via **`envconsul`** and populating `vault_example_file.sh` via **`consul-template`**.


### Prerequisites
Ensure that you have a setup with [**Virtualbox**](https://www.virtualbox.org/), [**Virtualbox Guest Additions**](https://download.virtualbox.org/virtualbox/) & [**Vagrant**](https://www.vagrantup.com/) already working and with sufficient hardware resources (RAM, CPU, Network)


## Usage & Workflow
Refer to the contents of **`Vagrantfile`** for provisioning steps.

```bash
# // Your localhost:
vagrant up ;
# // ... output of provisioning steps.
vagrant global-status ; # should show running nodes
# id       name      provider   state   directory
# -------------------------------------------------------------------------------
# 2147692  vault-dev virtualbox running /home/auser/hashicorp.vagrant_vault_envconsul_consul-template

# // SSH to vault1:
vagrant ssh vault-dev ;
# // ...
vagrant@vault-dev:~$ \
./vault_run_examples.sh ;
# ...
# // envconsul invoking vault_example.sh inline after retrieved values & then
# // consul-template is invoked to generate vault_example_file.sh thats then executed.

# when done remove eg: vagrant destroy -f vault-dev && vagrant box remove -f debian/buster64 ;
```


## Notes
This is intended as a mere practise / training.

See also:
 - [kikitux/vaultlab1](https://github.com/kikitux/vaultlab1)
 - [Vault Direct Appplication Intergartion guide](https://learn.hashicorp.com/vault/developer/sm-app-integration)
 -----
