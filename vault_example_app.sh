#!/usr/bin/env bash
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.
printf "______________ STARTED: ${0##*/}\n" ;
printf "ENVIRONMENT Varibles pre-set & feed inline to this script - GOT:
KEY === ${KV_KEY_VALUE}
USER === ${KV_USER_VALUE}
SECRET === ${KV_SECRET_VALUE}
" ;
printf "--------------- END OF: ${0##*/}\n\n" ;
