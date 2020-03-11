#!/usr/bin/env bash
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

# // envconsul example
envconsul -vault-renew-token=false -upcase -secret kv/key -secret kv/user -secret kv/secret ./vault_example_app.sh ;

# // consul-template example
consul-template -vault-renew-token=false -template "vault_example_file.template:vault_example_file.sh" -once ;
./vault_example_file.sh ;

