#!/usr/bin/env bash
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

if [[ ${1-} ]] && [[ (($# == 1)) && $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
printf """Usage: VARIABLE='...' ${0##*/} [OPTIONS]
Installs latest HashiCorp tools: envconsul & consul-template.

See:
    https://releases.hashicorp.com/envconsul/
    https://releases.hashicorp.com/consul-template/

${0##*/} 0.0.1				March 2020
""" ;
exit 0 ;
fi ;

if ! which curl 2>&1>/dev/null ; then printf 'ERROR: curl utility missing & required. Install & retry again.\n' ; exit 1 ; fi ;
if ! which unzip 2>&1>/dev/null ; then printf 'ERROR: unzip utility missing & required. Install & retry again.\n' ; exit 1 ; fi ;

LOGNAME=$(logname) ;
PATH_BIN_TARGETS='/usr/local/bin/.' ;  # // where downloaded bins are intended to be placed.

if [[ ! ${VERSION_ENVCONSUL+x} ]]; then VERSION_ENVCONSUL='' ; fi ;
if [[ ! ${VERSION_CONSULTEMPLATE+x} ]]; then VERSION_CONSULTEMPLATE='' ; fi ;
if [[ ! ${URL_ENVCONSUL_BASE+x} ]]; then URL_ENVCONSUL_BASE='https://releases.hashicorp.com/envconsul/' ; fi ;
if [[ ! ${URL_CONSULTEMPLATE_BASE+x} ]]; then URL_CONSULTEMPLATE_BASE='https://releases.hashicorp.com/consul-template/' ; fi ;
# // DETERMINE LATEST VERSIONS - where none are provided.
if [[ ${VERSION_ENVCONSUL} == '' ]] ; then
	VERSION_ENVCONSUL=$(curl -s ${URL_ENVCONSUL_BASE} | grep '<a href="/envconsul/' | grep -v -E 'rc|ent|beta|hsm' | head -n 1 | grep -E -o '([0-9]{1,3}[\.]){2}[0-9]{1,3}' | head -n 1) ;
	if [[ ${VERSION_ENVCONSUL} == '' ]] ; then
		printf '\nERROR: Could not determine valid / current EnvConsul version to download.\n' ;
		exit 1 ;
	fi ;
fi ;
if [[ ${VERSION_CONSULTEMPLATE} == '' ]] ; then
	VERSION_CONSULTEMPLATE=$(curl -s ${URL_CONSULTEMPLATE_BASE} | grep '<a href="/consul-template/' | grep -v -E 'rc|ent|beta|hsm' | head -n 1 | grep -E -o '([0-9]{1,3}[\.]){2}[0-9]{1,3}' | head -n 1) ;
	if [[ ${VERSION_CONSULTEMPLATE} == '' ]] ; then
		printf '\nERROR: Could not determine valid / current Consul-Template version to download.\n' ;
		exit 1 ;
	fi ;
fi ;

set +e ; CHECK_ENVCONSUL=$(envconsul --version 2>&1) ; CHECK_CONSULTEMPLATE=$(consul-template --version 2>&1); set -e ; # // maybe required vault version is already installed.
if [[ ${CHECK_ENVCONSUL} == *"v${VERSION_ENVCONSUL}"* ]] && [[ (($# == 0)) || $1 != "-f" ]] ; then printf "envconsul v${VERSION_ENVCONSUL} already installed; Use '-f' to force this script to run anyway.\nNo action taken.\n" && exit 0 ; fi ;
if [[ ${CHECK_CONSULTEMPLATE} == *"v${VERSION_CONSULTEMPLATE}"* ]] && [[ (($# == 0)) || $1 != "-f" ]] ; then printf "consul-template v${VERSION_CONSULTEMPLATE} already installed; Use '-f' to force this script to run anyway.\nNo action taken.\n" && exit 0 ; fi ;


if [[ ! ${FILE_ENVCONSUL+x} ]] ; then FILE_ENVCONSUL="envconsul_${VERSION_ENVCONSUL}_" ; fi ; # // to be appended later.
if [[ ! ${URL_ENVCONSUL+x} ]] ; then URL_ENVCONSUL="${URL_ENVCONSUL_BASE}${VERSION_ENVCONSUL}/" ; fi ; # // to be appended later.
if [[ ! ${URL_ENVCONSUL2+x} ]] ; then URL_ENVCONSUL2="${URL_ENVCONSUL_BASE}${VERSION_ENVCONSUL}/envconsul_${VERSION_ENVCONSUL}_SHA256SUMS" ; fi ;
if [[ ! ${FILE_CONSULTEMPLATE+x} ]] ; then FILE_CONSULTEMPLATE="consul-template_${VERSION_CONSULTEMPLATE}_" ; fi ; # // to be appended later.
if [[ ! ${URL_CONSULTEMPLATE+x} ]] ; then URL_CONSULTEMPLATE="${URL_CONSULTEMPLATE_BASE}${VERSION_CONSULTEMPLATE}/" ; fi ; # // to be appended later.
if [[ ! ${URL_CONSULTEMPLATE2+x} ]] ; then URL_CONSULTEMPLATE2="${URL_CONSULTEMPLATE_BASE}${VERSION_CONSULTEMPLATE}/consul-template_${VERSION_CONSULTEMPLATE}_SHA256SUMS" ; fi ;

if [[ ! ${OS_CPU+x} ]]; then OS_CPU='' ; fi ; # // ARCH CPU's: 'amd64', '386', 'arm64' or 'arm'.
if [[ ! ${OS_VERSION+x} ]]; then OS_VERSION=$(uname -ar) ; fi ; # // OS's: 'Darwin', 'Linux', 'Solaris', 'FreeBSD', 'NetBSD', 'OpenBSD'.

if [[ ${OS_CPU} == '' ]] ; then
	if [[ ${OS_VERSION} == *'x86_64'* ]] ; then
		OS_CPU='amd64' ;
	else
		if [[ ${OS_VERSION} == *' i386'* || ${OS_VERSION} == *' i686'* ]] ; then OS_CPU='386' ; fi ;
		if [[ ${OS_VERSION} == *' armv6'* || ${OS_VERSION} == *' armv7'* ]] ; then OS_CPU='arm' ; fi ;
		if [[ ${OS_VERSION} == *' armv8'* || ${OS_VERSION} == *' aarch64'* ]] ; then OS_CPU='arm64' ; fi ;
		if [[ ${OS_VERSION} == *'solaris'* ]] ; then OS_CPU='amd64' ; fi ;
	fi ;
	if [[ ${OS_CPU} == '' ]] ; then printf "${sERR}" ; exit 1 ; fi ;
fi ;

case "$(uname -ar)" in
	Darwin*)
		printf 'macOS (aka OSX)\n' ;
		# if which brew > /dev/null ; then printf 'Consider: "brew install vault" since you have HomeBrew availble.\n' ; else :; fi ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}darwin_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}darwin_${OS_CPU}.zip" ;
	;;
	Linux*)
		printf 'Linux\n' ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}linux_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}linux_${OS_CPU}.zip" ;
	;;
	*Solaris)
		printf 'SunOS / Solaris\n' ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}solaris_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}solaris_${OS_CPU}.zip" ;
	;;
	*FreeBSD*)
		printf 'FreeBSD\n' ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}freebsd_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}freebsd_${OS_CPU}.zip" ;
	;;
	*NetBSD*)
		printf 'NetBSD\n' ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}netbsd_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}netbsd_${OS_CPU}.zip" ;
	;;
	*OpenBSD*)
		printf 'OpenBSD\n' ;
		FILE_ENVCONSUL="${FILE_ENVCONSUL}netbsd_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}netbsd_${OS_CPU}.zip" ;
	;;
	*Cygwin)
		printf 'Cygwin - POSIX on MS Windows\n'
		FILE_ENVCONSUL="${FILE_ENVCONSUL}windows_${OS_CPU}.zip" ;
		FILE_CONSULTEMPLATE="${FILE_CONSULTEMPLATE}windows_${OS_CPU}.zip" ;
		URL_ENVCONSUL="${URL_ENVCONSUL}${FILE_ENVCONSUL}" ;
		URL_CONSULTEMPLATE="${URL_CONSULTEMPLATE}${FILE_CONSULTEMPLATE}" ;
		printf "Conisder downloading (exe's) from: ${URL_ENVCONSUL} & ${URL_CONSULTEMPLATE}.\nUse executables from CMD / Windows Prompt(s).\n" ;
		exit 0 ;
	;;
	*)
		printf "\nREFER TO: ${URL_VAULT}\n\nERROR: Operating System Not Supported.\n" ;
		exit 1 ;
	;;
esac ;

function donwloadUnpack()
{
	printf "Downloading from: ${URL_ENVCONSUL}\n\t& ${URL_CONSULTEMPLATE}\n" ;
	if wget -qc ${URL_ENVCONSUL} && wget -qc ${URL_ENVCONSUL2} && wget -qc ${URL_CONSULTEMPLATE} && wget -qc ${URL_CONSULTEMPLATE2} ; then
		if shasum -a 256 -c envconsul_${VERSION_ENVCONSUL}_SHA256SUMS 2>/dev/null | grep 'OK' && \
			shasum -a 256 -c consul-template_${VERSION_CONSULTEMPLATE}_SHA256SUMS 2>/dev/null | grep 'OK' ; then
			if unzip -qo ${FILE_ENVCONSUL} && unzip -qo ${FILE_CONSULTEMPLATE} ; then
				mv consul-template ${PATH_BIN_TARGETS} && mv envconsul ${PATH_BIN_TARGETS} ; # // move to bin path
				# // remove .zip & SHA256SUM files downloaded
				rm -r ${FILE_ENVCONSUL} ${FILE_CONSULTEMPLATE} envconsul_${VERSION_ENVCONSUL}_SHA256SUMS consul-template_${VERSION_CONSULTEMPLATE}_SHA256SUMS ;
				printf "Try: 'envconsul --version' && consul-template --version ; # to test.\nSuccessfully installed envconsul ${VERSION_ENVCONSUL} && consul-template ${VERSION_CONSULTEMPLATE}\n" ;
			else
				printf "\nERROR: Could not unzip.\n" ; exit 1 ;
			fi ;

			chown -R ${LOGNAME} . ;
		else
			printf '\nERROR: During shasum - Downloaded .zip corrupted?\n' ;
			exit 1 ;
		fi ;
	else
		printf "\nERROR: Unable to download from all URL ${URL_ENVCONSUL}, ${URL_ENVCONSUL2}, ${URL_CONSULTEMPLATE} & ${URL_CONSULTEMPLATE2}" ;
	fi ;
}

URL_ENVCONSUL="${URL_ENVCONSUL}${FILE_ENVCONSUL}" ;
URL_CONSULTEMPLATE="${URL_CONSULTEMPLATE}${FILE_CONSULTEMPLATE}" ;
donwloadUnpack ;
