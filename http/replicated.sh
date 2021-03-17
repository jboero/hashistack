#!/bin/bash

#
# This script is meant for quick & easy install via:
#   'curl -sSL https://get.replicated.com/docker | sudo bash'
# or:
#   'wget -qO- https://get.replicated.com/docker | sudo bash'
#
# This script can also be used for upgrades by re-running on same host.
#

set -e

REPLICATED_VERSION="2.51.0"
PINNED_DOCKER_VERSION="19.03.8"
MIN_DOCKER_VERSION="1.7.1"
SKIP_DOCKER_INSTALL=0
SKIP_DOCKER_PULL=0
NO_PUBLIC_ADDRESS=0
SKIP_OPERATOR_INSTALL=0
IS_MIGRATION=0
NO_PROXY=0
AIRGAP=0
ONLY_INSTALL_DOCKER=0
OPERATOR_TAGS="workers"
REPLICATED_USERNAME="replicated"
UI_BIND_PORT="8800"
CONFIGURE_IPV6=0

NO_CE_ON_EE=""
HARD_FAIL_ON_LOOPBACK="True"
HARD_FAIL_ON_FIREWALLD=""
ADDITIONAL_NO_PROXY=
FORCE_REPLICATED_DOWNGRADE=0
SKIP_PREFLIGHTS=""
IGNORE_PREFLIGHTS="1"
REGISTRY_ADDRESS_OVERRIDE=
REGISTRY_PATH_PREFIX=
DISABLE_REPLICATED_UI=""
DISABLE_REPLICATED_HOST_NETWORKING=""
RELEASE_SEQUENCE=""
RELEASE_PATCH_SEQUENCE=""

CHANNEL_CSS=
set +e
read -r -d '' CHANNEL_CSS << CHANNEL_CSS_EOM
Ym9keSB7CiAgICBjb2xvcjogIzAwMDsKICAgIGJhY2tncm91bmQtY29sb3I6ICNmZmY7CiAgICBm
b250LWZhbWlseTogLWFwcGxlLXN5c3RlbSxCbGlua01hY1N5c3RlbUZvbnQsIlNlZ29lIFVJIixS
b2JvdG8sT3h5Z2VuLVNhbnMsVWJ1bnR1LENhbnRhcmVsbCwiSGVsdmV0aWNhIE5ldWUiLHNhbnMt
c2VyaWY7Cn0KCmgxLnBhZ2UtdGl0bGUgewogICAgY29sb3I6ICMwMDA7Cn0KCmEsIGE6Zm9jdXMg
ewogIGNvbG9yOiAjMzI3M2RjOwp9CgphOmhvdmVyIHsKICBjb2xvcjogIzM2MzYzNjsKfQoKLnRl
eHQtbXV0ZWQsIC50ZXh0LW11dGVkOmhvdmVyIHsKICAgIGNvbG9yOiAjNTU1Owp9CgoubGVhZCB7
CiAgICBjb2xvcjogI2E3YTdhNzsKfQoKLnBhbmVsLWRlZmF1bHQgewogICAgYm9yZGVyLWNvbG9y
OiAjZGVkZWRlOwp9CgoucGFuZWwgewogICAgYmFja2dyb3VuZC1jb2xvcjogI2YxZjFmMTsKfQoK
I3JldHJhY2VkTG9nc1ZpZXdlckFwcCB7CiAgICBiYWNrZ3JvdW5kLWNvbG9yOiAjNDQ0Owp9Cgou
d2VsbCAubmF2PmxpPmEgewogICAgY29sb3I6ICMwMDA7Cn0KCi53ZWxsIHsKICAgIGJhY2tncm91
bmQtY29sb3I6ICNkZGQ7Cn0KCi5idG4tY2hlY2tib3ggewogICAgYmFja2dyb3VuZC1jb2xvcjog
I2RkZDsKfQoKLmJ0bi1jaGVja2JveDpmb2N1cywgLmJ0bi1jaGVja2JveDpob3ZlciB7CiAgICBi
YWNrZ3JvdW5kLWNvbG9yOiAjY2NjOwp9CgouZGFzaGJvYXJkIC5idG4td2FybmluZyB7CiAgYm9y
ZGVyLWNvbG9yOiAjYTAzMzI5OwogIGJhY2tncm91bmQtY29sb3I6ICNjODQwMzQ7CiAgY29sb3I6
ICNmZmY7Cn0KLmRhc2hib2FyZCAuYnRuLXdhcm5pbmc6aG92ZXIgewogIGNvbG9yOiNmZmY7CiAg
YmFja2dyb3VuZC1jb2xvcjogI2NmNTI0NjsKICBib3JkZXItY29sb3I6ICNhMDMzMjk7Cn0KCi5y
ZWFjdC1ncmlkLWl0ZW0gewogIGJvcmRlcjogMDsKfQoKLyogY3B1IGdyYXBocyAqLwoud2lkZ2V0
LW1ldHJpY3MtY3B1YWNjdCB7CiAgYmFja2dyb3VuZC1jb2xvcjogI2RkZDsKfQoud2lkZ2V0LW1l
dHJpY3MtY3B1YWNjdCAud2lkZ2V0LW1ldHJpY3MtY2hhcnQgewogIGJhY2tncm91bmQtY29sb3I6
ICM2OTZkNzM7Cn0KLndpZGdldC1jcHUtbWV0cmljcyA+IC50ZXh0LW11dGVkIHsKICBjb2xvcjog
IzAwMDsKfQoKLyogbWVtb3J5IGdyYXBocyAqLwoud2lkZ2V0LW1ldHJpY3MtbWVtb3J5IHsKICBi
YWNrZ3JvdW5kLWNvbG9yOiAjZGRkOwp9Ci53aWRnZXQtbWV0cmljcy1tZW1vcnkgLndpZGdldC1t
ZXRyaWNzLWNoYXJ0IHsKICBiYWNrZ3JvdW5kLWNvbG9yOiAjNjk2ZDczOwp9Ci53aWRnZXQtbWVt
b3J5LW1ldHJpY3MgPiAudGV4dC1tdXRlZCB7CiAgY29sb3I6ICMwMDA7Cn0KCi8qIEFwcCBzdGF0
dXMgdGlsZSAqLwoud2lkZ2V0LWFwcHN0YXR1cyB7CiAgY29sb3I6ICNmZmY7CiAgYmFja2dyb3Vu
ZC1jb2xvcjogIzNFNDBCQTsKfQoKLyogQXBwIHVkcGF0ZSB0aWxlICovCi53aWRnZXQtYXBwdXBk
YXRlIHsKICBjb2xvcjogI2ZmZjsKICBiYWNrZ3JvdW5kLWNvbG9yOiAjM0U0MEJBOwp9CgovKiBB
cHAgYmFja3VwIHRpbGUgKi8KLndpZGdldC1hcHBiYWNrdXAgewogIGNvbG9yOiAjZmZmOwogIGJh
Y2tncm91bmQtY29sb3I6ICMzRTQwQkE7Cn0=
CHANNEL_CSS_EOM
set -e

TERMS=


#######################################
#
# common.sh
#
#######################################

GREEN='\033[0;32m'
BLUE='\033[0;94m'
LIGHT_BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#######################################
# Check if command exists.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if command exists
#######################################
commandExists() {
    command -v "$@" > /dev/null 2>&1
}

#######################################
# Check if replicated 1.2 is installed
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if replicated 1.2 is installed
#######################################
replicated12Installed() {
    commandExists replicated && replicated --version | grep -q "Replicated version 1\.2"
}

#######################################
# Check if replicated 2.0 is installed
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if replicated 2.0 is installed
#######################################
replicated2Installed() {
    commandExists /usr/local/bin/replicatedctl && /usr/local/bin/replicatedctl version >/dev/null 2>&1
}

#######################################
# Returns replicated 2.0 version
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   INSTALLED_REPLICATED_VERSION
#######################################
replicated2Version() {
    if replicated2Installed; then
        INSTALLED_REPLICATED_VERSION="$(/usr/local/bin/replicatedctl version --quiet)"
    else
        INSTALLED_REPLICATED_VERSION=""
    fi
}

#######################################
# Returns 0 if replicated will downgrade
# Globals:
#   None
# Arguments:
#   Next replicated version
# Returns:
#   0 if replicated version is less than current
#   1 if replicated version is greater than or equal to current
#######################################
isReplicatedDowngrade() {
    if ! replicated2Installed; then
        return 1
    fi

    replicated2Version
    semverCompare "$1" "$INSTALLED_REPLICATED_VERSION"
    if [ "$SEMVER_COMPARE_RESULT" -lt "0" ]; then
        return 0
    fi
    return 1
}

#######################################
# Gets curl or wget depending if cmd exits.
# Globals:
#   PROXY_ADDRESS
# Arguments:
#   None
# Returns:
#   URLGET_CMD
#######################################
URLGET_CMD=
getUrlCmd() {
    if commandExists "curl"; then
        URLGET_CMD="curl -sSL"
        if [ -n "$PROXY_ADDRESS" ]; then
            URLGET_CMD=$URLGET_CMD" -x $PROXY_ADDRESS"
        fi
    else
        URLGET_CMD="wget -qO-"
    fi
}

#######################################
# Generates a 32 char unique id.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   GUID_RESULT
#######################################
getGuid() {
    GUID_RESULT="$(head -c 128 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
}

#######################################
# performs in-place sed substitution with escapting of inputs (http://stackoverflow.com/a/10467453/5344799)
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
safesed() {
    sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

#######################################
# Parses a semantic version string
# Globals:
#   None
# Arguments:
#   Version
# Returns:
#   major, minor, patch
#######################################
semverParse() {
    major="${1%%.*}"
    minor="${1#$major.}"
    minor="${minor%%.*}"
    patch="${1#$major.$minor.}"
    patch="${patch%%[-.]*}"
}

#######################################
# Compare two semvers.
# Returns -1 if A lt B, 0 if eq, 1 A gt B.
# Globals:
#   None
# Arguments:
#   Sem Version A
#   Sem Version B
# Returns:
#   SEMVER_COMPARE_RESULT
#######################################
SEMVER_COMPARE_RESULT=
semverCompare() {
    semverParse "$1"
    _a_major="${major:-0}"
    _a_minor="${minor:-0}"
    _a_patch="${patch:-0}"
    semverParse "$2"
    _b_major="${major:-0}"
    _b_minor="${minor:-0}"
    _b_patch="${patch:-0}"
    if [ "$_a_major" -lt "$_b_major" ]; then
        SEMVER_COMPARE_RESULT=-1
        return
    fi
    if [ "$_a_major" -gt "$_b_major" ]; then
        SEMVER_COMPARE_RESULT=1
        return
    fi
    if [ "$_a_minor" -lt "$_b_minor" ]; then
        SEMVER_COMPARE_RESULT=-1
        return
    fi
    if [ "$_a_minor" -gt "$_b_minor" ]; then
        SEMVER_COMPARE_RESULT=1
        return
    fi
    if [ "$_a_patch" -lt "$_b_patch" ]; then
        SEMVER_COMPARE_RESULT=-1
        return
    fi
    if [ "$_a_patch" -gt "$_b_patch" ]; then
        SEMVER_COMPARE_RESULT=1
        return
    fi
    SEMVER_COMPARE_RESULT=0
}

#######################################
# Inserts a parameter into a json file. If the file does not exist, creates it. If the parameter is already set, replaces it.
# Globals:
#   None
# Arguments:
#   path, parameter name, value
# Returns:
#   None
#######################################
insertOrReplaceJsonParam() {
    if ! [ -f "$1" ]; then
        # If settings file does not exist
        mkdir -p "$(dirname "$1")"
        echo "{\"$2\": \"$3\"}" > "$1"
    else
        # Settings file exists
        if grep -q -E "\"$2\" *: *\"[^\"]*\"" "$1"; then
            # If settings file contains named setting, replace it
            sed -i -e "s/\"$2\" *: *\"[^\"]*\"/\"$2\": \"$3\"/g" "$1"
        else
            # Insert into settings file (with proper commas)
            if [ $(wc -c <"$1") -ge 5 ]; then
                # File long enough to actually have an entry, insert "name": "value",\n after first {
                _commonJsonReplaceTmp="$(awk "NR==1,/^{/{sub(/^{/, \"{\\\"$2\\\": \\\"$3\\\", \")} 1" "$1")"
                echo "$_commonJsonReplaceTmp" > "$1"
            else
                # file not long enough to actually have contents, replace wholesale
                echo "{\"$2\": \"$3\"}" > "$1"
            fi
        fi
    fi
}

######################################
# Inserts a string array of length 1 into a json file. Fails if key is found in file.
# Globals:
#   None
# Arguments:
#   path, key, value[0]
# Returns:
#   1 if there are errors
######################################
insertJSONArray() {
	if ! [ -f "$1" ] || [ $(wc -c <"$1") -lt 5 ]; then
        mkdir -p "$(dirname "$1")"
		cat > $1 <<EOF
{
  "$2": ["$3"]
}
EOF
		return 0
	fi

	if grep -q "$2" "$1"; then
		return 1
	fi

	_commonJsonReplaceTmp="$(awk "NR==1,/^{/{sub(/^{/, \"{\\\"$2\\\": [\\\"$3\\\"], \")} 1" "$1")"
	echo "$_commonJsonReplaceTmp" > "$1"
	return 0
}

#######################################
# Splits an address in the format "host:port".
# Globals:
#   None
# Arguments:
#   address
# Returns:
#   HOST
#   PORT
#######################################
splitHostPort() {
    oIFS="$IFS"; IFS=":" read -r HOST PORT <<< "$1"; IFS="$oIFS"
}

#######################################
# Checks if Docker is installed
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if Docker is installed
#######################################
isDockerInstalled() {
    commandExists "docker" && ps aux | grep -q '[d]ockerd'
}
#######################################
# Prints the first arg in green with a checkmark
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
logSuccess() {
    printf "${GREEN}✔ $1${NC}\n" 1>&2
}

#######################################
# Prints the first arg in blue
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
logStep() {
    printf "${BLUE}⚙  $1${NC}\n" 1>&2
}

#######################################
# Prints the first arg indented in light blue
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
logSubstep() {
    printf "\t${LIGHT_BLUE}- $1${NC}\n" 1>&2
}

#######################################
# Prints the first arg in Yellow
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
logWarn() {
    printf "${YELLOW}$1${NC}\n" 1>&2
}


#######################################
# Prints the first arg in Red
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
logFail() {
    printf "${RED}$1${NC}\n" 1>&2
}

#######################################
# Prints the args in Red and exits 1
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
bail() {
    logFail "$@"
    exit 1
}


#######################################
#
# prompt.sh
#
#######################################

PROMPT_RESULT=

if [ -z "$READ_TIMEOUT" ]; then
    READ_TIMEOUT="-t 20"
fi


#######################################
# Prompts the user for input.
# Globals:
#   READ_TIMEOUT, FAST_TIMEOUTS
# Arguments:
#   Read timeout, formatted "-t int"
# Returns:
#   PROMPT_RESULT
#######################################
promptTimeout() {
    set +e
    if [ -z "$FAST_TIMEOUTS" ]; then
        read ${1:-$READ_TIMEOUT} PROMPT_RESULT < /dev/tty
    else
        read ${READ_TIMEOUT} PROMPT_RESULT < /dev/tty
    fi
    set -e
}

#######################################
# Confirmation prompt default yes.
# Globals:
#   READ_TIMEOUT, FAST_TIMEOUTS
# Arguments:
#   Read timeout, formatted "-t int"
# Returns:
#   None
#######################################
confirmY() {
    printf "(Y/n) "
    promptTimeout "$@"
    if [ "$PROMPT_RESULT" = "n" ] || [ "$PROMPT_RESULT" = "N" ]; then
        return 1
    fi
    return 0
}

#######################################
# Confirmation prompt default no.
# Globals:
#   READ_TIMEOUT, FAST_TIMEOUTS
# Arguments:
#   Read timeout, formatted "-t int"
# Returns:
#   None
#######################################
confirmN() {
    printf "(y/N) "
    promptTimeout "$@"
    if [ "$PROMPT_RESULT" = "y" ] || [ "$PROMPT_RESULT" = "Y" ]; then
        return 0
    fi
    return 1
}


#######################################
# Prompts the user for input.
# Globals:
#   READ_TIMEOUT
# Arguments:
#   None
# Returns:
#   PROMPT_RESULT
#######################################
prompt() {
    set +e
    read PROMPT_RESULT < /dev/tty
    set -e
}

#######################################
#
# system.sh
#
#######################################

#######################################
# Requires a 64 bit platform or exits with an error.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
require64Bit() {
    case "$(uname -m)" in
        *64)
            ;;
        *)
            echo >&2 'Error: you are not using a 64bit platform.'
            echo >&2 'This installer currently only supports 64bit platforms.'
            exit 1
            ;;
    esac
}

#######################################
# Detects the Linux kernel version.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   KERNEL_MAJOR
#   KERNEL_MINOR
#   KERNEL_PATCH
#######################################
KERNEL_MAJOR=
KERNEL_MINOR=
KERNEL_PATCH=
getKernelVersion() {
    semverParse "$(uname -r)"
    KERNEL_MAJOR=$major
    KERNEL_MINOR=$minor
    KERNEL_PATCH=$patch
}

#######################################
# Requires that the script be run with the root user.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   USER
#######################################
USER=
requireRootUser() {
    USER="$(id -un 2>/dev/null || true)"
    if [ "$USER" != "root" ]; then
        echo >&2 "Error: This script requires admin privileges. Please re-run it as root."
        exit 1
    fi
}

#######################################
# Detects the linux distribution.
# Upon failure exits with an error.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   LSB_DIST
#   DIST_VERSION - should be MAJOR.MINOR e.g. 16.04 or 7.4
#   DIST_VERSION_MAJOR
#######################################
LSB_DIST=
DIST_VERSION=
DIST_VERSION_MAJOR=
detectLsbDist() {
    _dist=
    _error_msg="We have checked /etc/os-release and /etc/centos-release files."
    if [ -f /etc/centos-release ] && [ -r /etc/centos-release ]; then
        # CentOS 6 example: CentOS release 6.9 (Final)
        # CentOS 7 example: CentOS Linux release 7.5.1804 (Core)
        _dist="$(cat /etc/centos-release | cut -d" " -f1)"
        _version="$(cat /etc/centos-release | sed -r 's/(Linux|Stream) //' | cut -d" " -f3 | cut -d "." -f1-2)"
    elif [ -f /etc/os-release ] && [ -r /etc/os-release ]; then
        _dist="$(. /etc/os-release && echo "$ID")"
        _version="$(. /etc/os-release && echo "$VERSION_ID")"
    elif [ -f /etc/redhat-release ] && [ -r /etc/redhat-release ]; then
        # this is for RHEL6
        _dist="rhel"
        _major_version=$(cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f1)
        _minor_version=$(cat /etc/redhat-release | cut -d" " -f7 | cut -d "." -f2)
        _version=$_major_version
    elif [ -f /etc/system-release ] && [ -r /etc/system-release ]; then
        if grep --quiet "Amazon Linux" /etc/system-release; then
            # Special case for Amazon 2014.03
            _dist="amzn"
            _version=`awk '/Amazon Linux/{print $NF}' /etc/system-release`
        fi
    else
        _error_msg="$_error_msg\nDistribution cannot be determined because neither of these files exist."
    fi

    if [ -n "$_dist" ]; then
        _error_msg="$_error_msg\nDetected distribution is ${_dist}."
        _dist="$(echo "$_dist" | tr '[:upper:]' '[:lower:]')"
        case "$_dist" in
            ubuntu)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 12."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 12 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            debian)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 7."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 7 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            fedora)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 21."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 21 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            rhel)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 6."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            centos)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 6."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            amzn)
                _error_msg="$_error_msg\nHowever detected version $_version is not one of\n    2, 2.0, 2018.03, 2017.09, 2017.03, 2016.09, 2016.03, 2015.09, 2015.03, 2014.09, 2014.03."
                [ "$_version" = "2" ] || [ "$_version" = "2.0" ] || \
                [ "$_version" = "2018.03" ] || \
                [ "$_version" = "2017.03" ] || [ "$_version" = "2017.09" ] || \
                [ "$_version" = "2016.03" ] || [ "$_version" = "2016.09" ] || \
                [ "$_version" = "2015.03" ] || [ "$_version" = "2015.09" ] || \
                [ "$_version" = "2014.03" ] || [ "$_version" = "2014.09" ] && \
                LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$_version
                ;;
            sles)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 12."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 12 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            ol)
                _error_msg="$_error_msg\nHowever detected version $_version is less than 6."
                oIFS="$IFS"; IFS=.; set -- $_version; IFS="$oIFS";
                [ $1 -ge 6 ] && LSB_DIST=$_dist && DIST_VERSION=$_version && DIST_VERSION_MAJOR=$1
                ;;
            *)
                _error_msg="$_error_msg\nThat is an unsupported distribution."
                ;;
        esac
    fi

    if [ -z "$LSB_DIST" ]; then
        echo >&2 "$(echo | sed "i$_error_msg")"
        echo >&2 ""
        echo >&2 "Please visit the following URL for more detailed installation instructions:"
        echo >&2 ""
        echo >&2 "  https://help.replicated.com/docs/distributing-an-application/installing/"

        echo "Continuing anyway"
        #exit 1
    fi
}

#######################################
# Detects the init system.
# Upon failure exits with an error.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   INIT_SYSTEM
#######################################
INIT_SYSTEM=
detectInitSystem() {
    if [[ "$(/sbin/init --version 2>/dev/null)" =~ upstart ]]; then
        INIT_SYSTEM=upstart
    elif [[ "$(systemctl 2>/dev/null)" =~ -\.mount ]]; then
        INIT_SYSTEM=systemd
    elif [ -f /etc/init.d/cron ] && [ ! -h /etc/init.d/cron ]; then
        INIT_SYSTEM=sysvinit
    else
        echo >&2 "Error: failed to detect init system or unsupported."
        exit 1
    fi
}

#######################################
# Finds the init system conf dir. One of /etc/default, /etc/sysconfig
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   CONFDIR
#######################################
CONFDIR=
detectInitSystemConfDir() {
    # NOTE: there was a bug in support bundle that creates a dir in place of non-existant conf files
    if [ -d /etc/default/replicated ] || [ -d /etc/default/replicated-operator ]; then
        if [ -d /etc/default/replicated ]; then
            rm -rf /etc/default/replicated
        fi
        if [ -d /etc/default/replicated-operator ]; then
            rm -rf /etc/default/replicated-operator
        fi
        if [ ! "$(ls -A /etc/default 2>/dev/null)" ]; then
            # directory is empty, probably exists because of support bundle
            rm -rf /etc/default
        fi
    fi
    if [ -d /etc/sysconfig/replicated ] || [ -d /etc/sysconfig/replicated-operator ]; then
        if [ -d /etc/sysconfig/replicated ]; then
            rm -rf /etc/sysconfig/replicated
        fi
        if [ -d /etc/sysconfig/replicated-operator ]; then
            rm -rf /etc/sysconfig/replicated-operator
        fi
        if [ ! "$(ls -A /etc/sysconfig 2>/dev/null)" ]; then
            # directory is empty, probably exists because of support bundle
            rm -rf /etc/sysconfig
        fi
    fi

    # prefer dir if config is already found
    if [ -f /etc/default/replicated ] || [ -f /etc/default/replicated-operator ]; then
        CONFDIR="/etc/default"
    elif [ -f /etc/sysconfig/replicated ] || [ -f /etc/sysconfig/replicated-operator ]; then
        CONFDIR="/etc/sysconfig"
    elif [ "$INIT_SYSTEM" = "systemd" ] && [ -d /etc/sysconfig ]; then
        CONFDIR="/etc/sysconfig"
    else
        CONFDIR="/etc/default"
    fi
    mkdir -p "$CONFDIR"
}

#######################################
# prevent a package from being automatically updated
# Globals:
#   LSB_DIST
# Arguments:
#   None
# Returns:
#   None
#######################################
lockPackageVersion() {
    case $LSB_DIST in
        rhel|centos)
            yum install -y yum-plugin-versionlock
            yum versionlock ${1}-*
            ;;
        ubuntu)
            apt-mark hold $1
            ;;
    esac
}

#######################################
#
# docker.sh
#
# require common.sh, system.sh
#
#######################################

RESTART_DOCKER=0

#######################################
# Prints a message and exits if docker is not installed.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
requireDocker() {
    if isDockerInstalled ; then
        return
    fi

    printf "${RED}Docker is not installed. Please install Docker before proceeding.\n" 1>&2
    printf "Instructions for installing Docker can be found at the link below:\n" 1>&2
    printf "\n" 1>&2
    printf "    https://help.replicated.com/community/t/installing-docker-in-airgapped-environments/81${NC}\n" 1>&2
    exit 127
}

#######################################
# Starts docker.
# Globals:
#   LSB_DIST
#   INIT_SYSTEM
# Arguments:
#   None
# Returns:
#   None
#######################################
startDocker() {
    if [ "$LSB_DIST" = "amzn" ]; then
        service docker start
        return
    fi
    case "$INIT_SYSTEM" in
        systemd)
            systemctl enable docker
            systemctl start docker
            ;;
        upstart|sysvinit)
            service docker start
            ;;
    esac
}

#######################################
# Restarts docker.
# Globals:
#   LSB_DIST
#   INIT_SYSTEM
# Arguments:
#   None
# Returns:
#   None
#######################################
restartDocker() {
    case "$INIT_SYSTEM" in
        systemd)
            systemctl daemon-reload
            systemctl restart docker
            ;;
        upstart|sysvinit)
            service docker restart
            ;;
    esac
}

#######################################
# Checks support for docker driver.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
checkDockerDriver() {
    if ! isDockerInstalled ; then
        echo >&2 "Error: docker is not installed."
        exit 1
    fi

    if [ "$(ps -ef | grep "docker" | grep -v "grep" | wc -l)" = "0" ]; then
        startDocker
    fi

    _driver=$(docker info 2>/dev/null | grep 'Execution Driver' | awk '{print $3}' | awk -F- '{print $1}')
    if [ "$_driver" = "lxc" ]; then
        echo >&2 "Error: the running Docker daemon is configured to use the '${_driver}' execution driver."
        echo >&2 "This installer only supports the 'native' driver (AKA 'libcontainer')."
        echo >&2 "Check your Docker daemon options."
        exit 1
    fi
}

#######################################
# Checks support for docker storage driver.
# Globals:
#   BYPASS_STORAGEDRIVER_WARNINGS
# Arguments:
#   HARD_FAIL_ON_LOOPBACK
# Returns:
#   None
#######################################
BYPASS_STORAGEDRIVER_WARNINGS=
checkDockerStorageDriver() {
    if [ "$BYPASS_STORAGEDRIVER_WARNINGS" = "1" ]; then
        return
    fi

    if ! isDockerInstalled ; then
        echo >&2 "Error: docker is not installed."
        exit 1
    fi

    if [ "$(ps -ef | grep "docker" | grep -v "grep" | wc -l)" = "0" ]; then
        startDocker
    fi

    _driver=$(docker info 2>/dev/null | grep 'Storage Driver' | awk '{print $3}' | awk -F- '{print $1}')
    if [ "$_driver" = "devicemapper" ] && docker info 2>/dev/null | grep -Fqs 'Data loop file:' ; then
        printf "${RED}The running Docker daemon is configured to use the 'devicemapper' storage driver \
in loopback mode.\nThis is not recommended for production use. Please see to the following URL for more \
information.\n\nhttps://help.replicated.com/docs/kb/developer-resources/devicemapper-warning/.${NC}\n\n\
"
        # HARD_FAIL_ON_LOOPBACK
        if [ -n "$1" ]; then
            printf "${RED}Please configure a recommended storage driver and try again.${NC}\n\n"
            exit 1
        fi

        printf "Do you want to proceed anyway? "
        if ! confirmN; then
            exit 0
        fi
    fi
}

#######################################
# Get the docker group ID.
# Default to 0 for root group.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DOCKER_GROUP_ID
#   None
#######################################
DOCKER_GROUP_ID=0
detectDockerGroupId() {
    # Parse the docker group from the docker.sock file
    # On most systems this will be a group called `docker`
    if [ -e /var/run/docker.sock ]; then
        DOCKER_GROUP_ID="$(stat -c '%g' /var/run/docker.sock)"
    # If the docker.sock file doesn't fall back to the docker group.
    elif [ "$(getent group docker)" ]; then
        DOCKER_GROUP_ID="$(getent group docker | cut -d: -f3)"
    fi
}


#######################################
# Check if docker image exists.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if image exists
#######################################
dockerImageExists() {
    [[ "$(docker images -q "$@" 2> /dev/null)" != "" ]];
}

#######################################
# Gets the image repo tag from the tar file.
# Globals:
#   None
# Arguments:
#   - Path to the tar file
# Returns:
#   REPO_TAG
#######################################
REPO_TAG=
dockerGetRepoTagFromTar() {
    REPO_TAG="$(tar -xOf "$1" manifest.json | sed 's/.*RepoTags":\["\([^"]*\).*/\1/')"
}

#######################################
# Replaces the registry address from a docker repo tag.
# Globals:
#   None
# Arguments:
#   - Repo tag
#   - New registry address
# Returns:
#   REPO_TAG
#######################################
REPO_TAG=
dockerReplaceRegistryAddress() {
    local first
    local rest
    oIFS="$IFS"; IFS="/" read -r first rest <<< "$1"; IFS="$oIFS"
    if [ -z "$rest" ]; then
        # There are no slashes so this is an official image in the official registry.
        REPO_TAG="$2/library/$1"
    elif echo "$rest" | grep -q '/'; then
        REPO_TAG="$2/$rest"
    else
        # NOTE: This makes some assumptions about the domain component vs the org component that
        # are probably not true but it seems good enough for our use case.
        if echo "$first" | grep -q '\.' || echo "$first" | grep -q ':'; then
            # There is probably just no org component here.
            REPO_TAG="$2/$rest"
        else
            # This is the official registry since there is no domain component.
            REPO_TAG="$2/$1"
        fi
    fi
}

#######################################
# Re-tags and pushes image to specified registry.
# Globals:
#   None
# Arguments:
#   - Repo tag
#   - New registry address
# Returns:
#   None
#######################################
REPO_TAG=
dockerRetagAndPushImageToRegistry() {
    dockerReplaceRegistryAddress "$1" "$2"
    local _localTag="$REPO_TAG"
    (set -x; docker tag "$1" "$_localTag")
    (set -x; docker push "$_localTag")
}

#######################################
# Gets the Docker logging driver.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DOCKER_LOGGING_DRIVER
#######################################
DOCKER_LOGGING_DRIVER=
dockerGetLoggingDriver() {
    DOCKER_LOGGING_DRIVER="$(docker info 2>/dev/null | grep -i "Logging Driver:" | sed 's/[Ll]ogging [Dd]river: *//')"
}

#######################################
# Gets the docker0 bridge network gateway ip.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DOCKER0_GATEWAY_IP
#######################################
get_docker0_gateway_ip() {
    DOCKER0_GATEWAY_IP=$(ip -o -4 address | grep docker0 | awk '{ print $4 }' | cut -d'/' -f1)
    if [ -z "$DOCKER0_GATEWAY_IP" ]; then
        DOCKER0_GATEWAY_IP=172.17.0.1
    fi
}

#######################################
#
# docker-version.sh
#
# require common.sh, system.sh
#
#######################################

#######################################
# Gets docker server version.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DOCKER_VERSION
#######################################
DOCKER_VERSION=
getDockerVersion() {
    if ! isDockerInstalled ; then
        return
    fi

    DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null || docker -v | awk '{gsub(/,/, "", $3); print $3}')
}

#######################################
# Parses docker version.
# Globals:
#   None
# Arguments:
#   Docker Version
# Returns:
#   DOCKER_VERSION_MAJOR
#   DOCKER_VERSION_MINOR
#   DOCKER_VERSION_PATCH
#   DOCKER_VERSION_RELEASE
#######################################
DOCKER_VERSION_MAJOR=
DOCKER_VERSION_MINOR=
DOCKER_VERSION_PATCH=
DOCKER_VERSION_RELEASE=
parseDockerVersion() {
    # reset
    DOCKER_VERSION_MAJOR=
    DOCKER_VERSION_MINOR=
    DOCKER_VERSION_PATCH=
    DOCKER_VERSION_RELEASE=
    if [ -z "$1" ]; then
        return
    fi

    OLD_IFS="$IFS" && IFS=. && set -- $1 && IFS="$OLD_IFS"
    DOCKER_VERSION_MAJOR=$1
    DOCKER_VERSION_MINOR=$2
    OLD_IFS="$IFS" && IFS=- && set -- $3 && IFS="$OLD_IFS"
    DOCKER_VERSION_PATCH=$1
    DOCKER_VERSION_RELEASE=$2
}

#######################################
# Compare two docker versions ignoring the patch version.
# Returns -1 if A lt B, 0 if eq, 1 A gt B.
# Globals:
#   None
# Arguments:
#   Docker Version A
#   Docker Version B
# Returns:
#   COMPARE_DOCKER_VERSIONS_RESULT
#######################################
COMPARE_DOCKER_VERSIONS_RESULT=
compareDockerVersionsIgnorePatch() {
    # reset
    COMPARE_DOCKER_VERSIONS_RESULT=
    parseDockerVersion "$1"
    _a_major="$DOCKER_VERSION_MAJOR"
    _a_minor="$DOCKER_VERSION_MINOR"
    parseDockerVersion "$2"
    _b_major="$DOCKER_VERSION_MAJOR"
    _b_minor="$DOCKER_VERSION_MINOR"
    if [ "$_a_major" -lt "$_b_major" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=-1
        return
    fi
    if [ "$_a_major" -gt "$_b_major" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=1
        return
    fi
    if [ "$_a_minor" -lt "$_b_minor" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=-1
        return
    fi
    if [ "$_a_minor" -gt "$_b_minor" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=1
        return
    fi
    COMPARE_DOCKER_VERSIONS_RESULT=0
}

#######################################
# Compare two docker versions.
# Returns -1 if A lt B, 0 if eq, 1 A gt B.
# Globals:
#   None
# Arguments:
#   Docker Version A
#   Docker Version B
# Returns:
#   COMPARE_DOCKER_VERSIONS_RESULT
#######################################
COMPARE_DOCKER_VERSIONS_RESULT=
compareDockerVersions() {
    # reset
    COMPARE_DOCKER_VERSIONS_RESULT=
    compareDockerVersionsIgnorePatch "$1" "$2"
    if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -ne "0" ]; then
        return
    fi
    parseDockerVersion "$1"
    _a_patch="$DOCKER_VERSION_PATCH"
    parseDockerVersion "$2"
    _b_patch="$DOCKER_VERSION_PATCH"
    if [ "$_a_patch" -lt "$_b_patch" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=-1
        return
    fi
    if [ "$_a_patch" -gt "$_b_patch" ]; then
        COMPARE_DOCKER_VERSIONS_RESULT=1
        return
    fi
    COMPARE_DOCKER_VERSIONS_RESULT=0
}

#######################################
# Get max docker version for lsb dist/version.
# Globals:
#   LSB_DIST
# Arguments:
#   None
# Returns:
#   MAX_DOCKER_VERSION_RESULT
#######################################
MAX_DOCKER_VERSION_RESULT=
getMaxDockerVersion() {
    MAX_DOCKER_VERSION_RESULT=

    # Max Docker version on CentOS 6 is 1.7.1.
    if [ "$LSB_DIST" = "centos" ]; then
        if [ "$DIST_VERSION_MAJOR" = "6" ]; then
            MAX_DOCKER_VERSION_RESULT="1.7.1"
        fi
    fi
    # Max Docker version on RHEL 6 is 1.7.1.
    if [ "$LSB_DIST" = "rhel" ]; then
        if [ "$DIST_VERSION_MAJOR" = "6" ]; then
            MAX_DOCKER_VERSION_RESULT="1.7.1"
        fi
    fi
    if [ "$LSB_DIST" = "ubuntu" ]; then
        # Max Docker version on Ubuntu 14.04 is 18.06.1.
        # see https://github.com/docker/for-linux/issues/591
        if [ "$DIST_VERSION" = "14.04" ]; then
            MAX_DOCKER_VERSION_RESULT="18.06.1"
        fi
    fi
    if [ "$LSB_DIST" = "debian" ]; then
        # Max Docker version on Debian 7 is 18.03.1
        if [ "$DIST_VERSION" = "7" ]; then
            MAX_DOCKER_VERSION_RESULT="18.03.1"
        fi
        # Max Docker version on Debian 8 is 18.06.2.
        if [ "$DIST_VERSION" = "8" ]; then
            MAX_DOCKER_VERSION_RESULT="18.06.2"
        fi
    fi
    # 2019-01-07
    # Max Docker version on Amazon Linux 2 is 18.09.9.
    if [ "$LSB_DIST" = "amzn" ]; then
        MAX_DOCKER_VERSION_RESULT="18.09.9"
    fi
    # 2020-05-11
    # Max Docker version on SUSE Linux Enterprise Server 12 and 15 is 19.03.5.
    if [ "$LSB_DIST" = "sles" ]; then
        MAX_DOCKER_VERSION_RESULT="19.03.5"
    fi
    # Max Docker version on Oracle Linux 6.x seems to be 17.05.0.
    if [ "$LSB_DIST" = "ol" ]; then
        if [ "$DIST_VERSION_MAJOR" = "6" ]; then
            MAX_DOCKER_VERSION_RESULT="17.05.0"
        fi
    fi
}

#######################################
# Get min docker version for lsb dist/version.
# Globals:
#   LSB_DIST
# Arguments:
#   None
# Returns:
#   MIN_DOCKER_VERSION_RESULT
#######################################
MIN_DOCKER_VERSION_RESULT=
getMinDockerVersion() {
    MIN_DOCKER_VERSION_RESULT=

    if [ "$LSB_DIST" = "ubuntu" ]; then
        # Min Docker version on Ubuntu 20.04 is 19.03.9.
        if [ "$DIST_VERSION" = "20.04" ]; then
            MIN_DOCKER_VERSION_RESULT="19.03.11"
        fi
    fi
}

#######################################
#
# docker-install.sh
#
# require common.sh, prompt.sh, system.sh, docker-version.sh
#
#######################################

#######################################
# Installs requested docker version.
# Requires at least min docker version to proceed.
# Globals:
#   LSB_DIST
#   INIT_SYSTEM
#   AIRGAP
# Arguments:
#   Requested Docker Version
#   Minimum Docker Version
# Returns:
#   DID_INSTALL_DOCKER
#######################################
DID_INSTALL_DOCKER=0
installDocker() {
    _dockerGetBestVersion "$1"

    if ! isDockerInstalled ; then
        _dockerRequireMinInstallableVersion "$2"
        _installDocker "$BEST_DOCKER_VERSION_RESULT" 1
        return
    fi

    getDockerVersion

    compareDockerVersions "$DOCKER_VERSION" "$2"
    if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
        _dockerRequireMinInstallableVersion "$2"
        _dockerForceUpgrade "$BEST_DOCKER_VERSION_RESULT"
    else
        compareDockerVersions "$DOCKER_VERSION" "$BEST_DOCKER_VERSION_RESULT"
        if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
            _dockerUpgrade "$BEST_DOCKER_VERSION_RESULT"
            if [ "$DID_INSTALL_DOCKER" -ne "1" ]; then
                _dockerProceedAnyway "$BEST_DOCKER_VERSION_RESULT"
            fi
        elif [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "1" ]; then
            # allow patch versions greater than the current version
            compareDockerVersionsIgnorePatch "$DOCKER_VERSION" "$BEST_DOCKER_VERSION_RESULT"
            if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "1" ]; then
                _dockerProceedAnyway "$BEST_DOCKER_VERSION_RESULT"
            fi
        fi
        # The system has the exact pinned version installed.
        # No need to run the Docker install script.
    fi
}

#######################################
# Install docker from a prepared image
# Globals:
#   LSB_DIST
#   INIT_SYSTEM
# Returns:
#   DID_INSTALL_DOCKER
#######################################
DID_INSTALL_DOCKER=0
installDockerOffline() {
    if isDockerInstalled ; then
        return
    fi

    case "$LSB_DIST$DIST_VERSION" in
        ubuntu16.04)
            mkdir -p image/
            layer_id=$(tar xvf packages-docker-ubuntu1604.tar -C image/ | grep layer.tar | cut -d'/' -f1)
            tar xvf image/${layer_id}/layer.tar
            pushd archives/
               dpkg -i --force-depends-version *.deb
            popd
            DID_INSTALL_DOCKER=1
            return
            ;;
        ubuntu18.04)
            mkdir -p image/
            layer_id=$(tar xvf packages-docker-ubuntu1804.tar -C image/ | grep layer.tar | cut -d'/' -f1)
            tar xvf image/${layer_id}/layer.tar
            pushd archives/
               dpkg -i --force-depends-version *.deb
            popd
            DID_INSTALL_DOCKER=1
            return
            ;;
        centos7.4|centos7.5|centos7.6|centos7.7|centos7.8|centos7.9|rhel7.4|rhel7.5|rhel7.6|rhel7.7|rhel7.8|rhel7.9)
            mkdir -p image/
            layer_id=$(tar xvf packages-docker-rhel7.tar -C image/ | grep layer.tar | cut -d'/' -f1)
            tar xvf image/${layer_id}/layer.tar
            pushd archives/
                rpm --upgrade --force --nodeps *.rpm
            popd
            systemctl enable docker
            systemctl start docker
            DID_INSTALL_DOCKER=1
            return
            ;;
        *)
   esac

   printf "Offline Docker install is not supported on ${LSB_DIST} ${DIST_MAJOR}"
   exit 1
}

_installDocker() {
    _should_skip_docker_ee_install
    if [ "$SHOULD_SKIP_DOCKER_EE_INSTALL" -eq "1" ]; then
        printf "${RED}Enterprise Linux distributions require Docker Enterprise Edition. Please install Docker before running this installation script.${NC}\n" 1>&2
        exit 1
    fi

    if [ "$LSB_DIST" = "amzn" ]; then
        # Docker install script no longer supports Amazon Linux
        printf "${YELLOW}Pinning Docker version not supported on Amazon Linux${NC}\n"
        printf "${GREEN}Installing Docker from Yum repository${NC}\n"

        # 2020-05-11
        # Amazon Linux has Docker 17.12.1ce, 18.06.1ce and Docker 18.09.9ce available.
        compareDockerVersions "18.0.0" "${1}"
        if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
            compareDockerVersions "18.09.0" "${1}"
            if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -le "0" ]; then
                if commandExists "amazon-linux-extras"; then
                    ( set -x; amazon-linux-extras install -y -q docker=18.09.9 || amazon-linux-extras install docker=18.09.9 || \
                        amazon-linux-extras install -y -q docker || amazon-linux-extras install docker )
                else
                    ( set -x; yum install -y -q docker-18.09.9ce || yum install -y -q docker )
                fi
            else
                if commandExists "amazon-linux-extras"; then
                    ( set -x; amazon-linux-extras install -y -q docker=18.06.1 || amazon-linux-extras install docker=18.06.1 || \
                        amazon-linux-extras install -y -q docker || amazon-linux-extras install docker )
                else
                    ( set -x; yum install -y -q docker-18.06.1ce || yum install -y -q docker )
                fi
            fi
        else
            if commandExists "amazon-linux-extras"; then
                ( set -x; amazon-linux-extras install -y -q docker=17.12.1 || amazon-linux-extras install docker=17.12.1 \
                    || amazon-linux-extras install -y -q docker || amazon-linux-extras install docker )
            else
                ( set -x; yum install -y -q docker-17.12.1ce || yum install -y -q docker )
            fi
        fi

        service docker start || true
        DID_INSTALL_DOCKER=1
        return
    elif [ "$LSB_DIST" = "sles" ]; then
        printf "${YELLOW}Pinning Docker version not supported on SUSE Linux${NC}\n"
        printf "${GREEN}Installing Docker from Zypper repository${NC}\n"

        # 2020-05-11
        # SUSE has Docker 17.09.1_ce, 18.09.7_ce and 19.03.5 available.
        compareDockerVersions "19.0.0" "${1}"
        if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
            ( set -x; zypper -n install "docker=19.03.5_ce" || zypper -n install docker )
        else
            compareDockerVersions "18.0.0" "${1}"
            if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
                ( set -x; zypper -n install "docker=18.09.7_ce" || zypper -n install docker )
            else
                ( set -x; zypper -n install "docker=17.09.1_ce" || zypper -n install docker )
            fi
        fi

        service docker start || true
        DID_INSTALL_DOCKER=1
        return
    fi

    compareDockerVersions "17.06.0" "${1}"
    if { [ "$LSB_DIST" = "rhel" ] || [ "$LSB_DIST" = "ol" ] ; } && [ "$COMPARE_DOCKER_VERSIONS_RESULT" -le "0" ]; then
        if yum list installed "container-selinux" >/dev/null 2>&1; then
            # container-selinux installed
            printf "Skipping install of container-selinux as a version of it was already present\n"
        else
            # Install container-selinux from official source, ignoring errors
            yum install -y -q container-selinux 2> /dev/null || true
            # verify installation success
            if yum list installed "container-selinux" >/dev/null 2>&1; then
                printf "${GREEN}Installed container-selinux from existing sources${NC}\n"
            else
                if [ "$DIST_VERSION" = "7.6" ]; then
                    # Install container-selinux from mirror.centos.org
                    yum install -y -q "http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-1.el7_6.noarch.rpm"
                    if yum list installed "container-selinux" >/dev/null 2>&1; then
                        printf "${YELLOW}Installed package required by docker container-selinux from fallback source of mirror.centos.org${NC}\n"
                    else
                        printf "${RED}Failed to install container-selinux package, required by Docker CE. Please install the container-selinux package or Docker before running this installation script.${NC}\n"
                        exit 1
                    fi
                else
                    # Install container-selinux from mirror.centos.org
                    yum install -y -q "http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-3.el7.noarch.rpm"
                    if yum list installed "container-selinux" >/dev/null 2>&1; then
                        printf "${YELLOW}Installed package required by docker container-selinux from fallback source of mirror.centos.org${NC}\n"
                    else
                        printf "${RED}Failed to install container-selinux package, required by Docker CE. Please install the container-selinux package or Docker before running this installation script.${NC}\n"
                        exit 1
                    fi
                fi
            fi
        fi
    fi

    _docker_install_url="https://get.replicated.com/docker-install.sh"
    printf "${GREEN}Installing docker version ${1} from ${_docker_install_url}${NC}\n"
    getUrlCmd
    $URLGET_CMD "$_docker_install_url?docker_version=${1}&lsb_dist=${LSB_DIST}&dist_version=${DIST_VERSION_MAJOR}" > /tmp/docker_install.sh
    # When this script is piped into bash as stdin, apt-get will eat the remaining parts of this script,
    # preventing it from being executed.  So using /dev/null here to change stdin for the docker script.
    VERSION="${1}" sh /tmp/docker_install.sh < /dev/null

    printf "${GREEN}External script is finished${NC}\n"

    # Need to manually start Docker in these cases
    if [ "$INIT_SYSTEM" = "systemd" ]; then
        systemctl enable docker
        systemctl start docker
    elif [ "$LSB_DIST" = "centos" ] && [ "$DIST_VERSION_MAJOR" = "6" ]; then
        service docker start
    elif [ "$LSB_DIST" = "rhel" ] && [ "$DIST_VERSION_MAJOR" = "6" ]; then
        service docker start
    fi

    # i guess the second arg means to skip this?
    if [ "$2" -eq "1" ]; then
        # set +e because df --output='fstype' doesn't exist on older versions of rhel and centos
        set +e
        _maybeRequireRhelDevicemapper
        set -e
    fi

    DID_INSTALL_DOCKER=1
}

_maybeRequireRhelDevicemapper() {
    # If the distribution is CentOS or RHEL and the filesystem is XFS, it is possible that docker has installed with overlay as the device driver
    # In that case we should change the storage driver to devicemapper, because while loopback-lvm is slow it is also more likely to work
    if { [ "$LSB_DIST" = "centos" ] || [ "$LSB_DIST" = "rhel" ] ; } && { df --output='fstype' 2>/dev/null | grep -q -e '^xfs$' || grep -q -e ' xfs ' /etc/fstab ; } ; then
        # If distribution is centos or rhel and filesystem is XFS

        # xfs (RHEL 7.2 and higher), but only with d_type=true enabled. Use xfs_info to verify that the ftype option is set to 1.
        # https://docs.docker.com/storage/storagedriver/overlayfs-driver/#prerequisites
        oIFS="$IFS"; IFS=.; set -- $DIST_VERSION; IFS="$oIFS";
        _dist_version_minor=$2
        if [ "$DIST_VERSION_MAJOR" -eq "7" ] && [ "$_dist_version_minor" -ge "2" ] && xfs_info / | grep -q -e 'ftype=1'; then
            return
        fi

        # Get kernel version (and extract major+minor version)
        kernelVersion="$(uname -r)"
        semverParse $kernelVersion

        if docker info | grep -q -e 'Storage Driver: overlay2\?' && { ! xfs_info / | grep -q -e 'ftype=1' || [ $major -lt 3 ] || { [ $major -eq 3 ] && [ $minor -lt 18 ]; }; }; then
            # If storage driver is overlay and (ftype!=1 OR kernel version less than 3.18)
            printf "${YELLOW}Changing docker storage driver to devicemapper."
            printf "Using overlay/overlay2 requires CentOS/RHEL 7.2 or higher and ftype=1 on xfs filesystems.\n"
            printf "It is recommended to configure devicemapper to use direct-lvm mode for production.${NC}\n"
            systemctl stop docker

            insertOrReplaceJsonParam /etc/docker/daemon.json storage-driver devicemapper

            systemctl start docker
        fi
    fi
}

_dockerUpgrade() {
    _should_skip_docker_ee_install
    if [ "$SHOULD_SKIP_DOCKER_EE_INSTALL" -eq "1" ]; then
        return
    fi

    if [ "$AIRGAP" != "1" ]; then
        printf "This installer will upgrade your current version of Docker (%s) to the recommended version: %s\n" "$DOCKER_VERSION" "$1"
        printf "Do you want to allow this? "
        if confirmY; then
            _installDocker "$1" 0
            return
        fi
    fi
}

_dockerForceUpgrade() {
    if [ "$AIRGAP" -eq "1" ]; then
        echo >&2 "Error: The installed version of Docker ($DOCKER_VERSION) may not be compatible with this installer."
        echo >&2 "Please manually upgrade your current version of Docker to the recommended version: $1"
        exit 1
    fi

    _dockerUpgrade "$1"
    if [ "$DID_INSTALL_DOCKER" -ne "1" ]; then
        printf "Please manually upgrade your current version of Docker to the recommended version: %s\n" "$1"
        exit 0
    fi
}

_dockerProceedAnyway() {
    printf "The installed version of Docker (%s) may not be compatible with this installer.\nThe recommended version is %s\n" "$DOCKER_VERSION" "$1"
    printf "Do you want to proceed anyway? "
    if ! confirmN; then
        exit 0
    fi
}

_dockerGetBestVersion() {
    BEST_DOCKER_VERSION_RESULT="$1"
    getMinDockerVersion
    if [ -n "$MIN_DOCKER_VERSION_RESULT" ]; then
        compareDockerVersions "$MIN_DOCKER_VERSION_RESULT" "$BEST_DOCKER_VERSION_RESULT"
        if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "1" ]; then
            BEST_DOCKER_VERSION_RESULT="$MIN_DOCKER_VERSION_RESULT"
            return
        fi
    fi
    getMaxDockerVersion
    if [ -n "$MAX_DOCKER_VERSION_RESULT" ]; then
        compareDockerVersions "$BEST_DOCKER_VERSION_RESULT" "$MAX_DOCKER_VERSION_RESULT"
        if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "1" ]; then
            BEST_DOCKER_VERSION_RESULT="$MAX_DOCKER_VERSION_RESULT"
            return
        fi
    fi
}

_dockerRequireMinInstallableVersion() {
    getMaxDockerVersion
    if [ -z "$MAX_DOCKER_VERSION_RESULT" ]; then
        return
    fi

    compareDockerVersions "$1" "$MAX_DOCKER_VERSION_RESULT"
    if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "1" ]; then
        echo >&2 "Error: This install script may not be compatible with this linux distribution."
        echo >&2 "We have detected a maximum docker version of $MAX_DOCKER_VERSION_RESULT while the required minimum version for this script is $1."
        exit 1
    fi
}

#######################################
# Checks if Docker EE should be installed or upgraded.
# Globals:
#   LSB_DIST
#   NO_CE_ON_EE
# Returns:
#   SHOULD_SKIP_DOCKER_EE_INSTALL
#######################################
SHOULD_SKIP_DOCKER_EE_INSTALL=
_should_skip_docker_ee_install() {
  SHOULD_SKIP_DOCKER_EE_INSTALL=
  if [ "$LSB_DIST" = "rhel" ] || [ "$LSB_DIST" = "ol" ] || [ "$LSB_DIST" = "sles" ]; then
      if [ -n "$NO_CE_ON_EE" ]; then
          SHOULD_SKIP_DOCKER_EE_INSTALL=1
          return
      fi
  fi
  SHOULD_SKIP_DOCKER_EE_INSTALL=0
}


#######################################
# Docker uses cgroupfs by default to manage cgroup. On distributions using systemd,
# i.e. RHEL and Ubuntu, this causes issues because there are now 2 seperate ways
# to manage resources. For more info see the link below.
# https://github.com/kubernetes/kubeadm/issues/1394#issuecomment-462878219
# Globals:
#   None
# Returns:
#   None
#######################################
changeCgroupDriverToSystemd() {
    insertJSONArray "/etc/docker/daemon.json" "exec-opts" "native.cgroupdriver=systemd"
}

#######################################
#
# replicated.sh
#
# require prompt.sh
#
#######################################

#######################################
# Reads a value from the /etc/replicated.conf file
# Globals:
#   None
# Arguments:
#   Variable to read
# Returns:
#   REPLICATED_CONF_VALUE
#######################################
readReplicatedConf() {
    unset REPLICATED_CONF_VALUE
    if [ -f /etc/replicated.conf ]; then
        REPLICATED_CONF_VALUE=$(cat /etc/replicated.conf | grep -o "\"$1\":\s*\"[^\"]*" | sed "s/\"$1\":\s*\"//") || true
    fi
}

#######################################
# Reads a value from REPLICATED_OPTS variable in the /etc/default/replicated file
# Globals:
#   REPLICATED_OPTS
# Arguments:
#   Variable to read
# Returns:
#   REPLICATED_OPTS_VALUE
#######################################
readReplicatedOpts() {
    unset REPLICATED_OPTS_VALUE
    REPLICATED_OPTS_VALUE="$(echo "$REPLICATED_OPTS" | grep -o "$1=[^ ]*" | cut -d'=' -f2)"
}

#######################################
# Reads a value from REPLICATED_OPERATOR_OPTS variable in the /etc/default/replicated-operator file
# Globals:
#   REPLICATED_OPTS
# Arguments:
#   Variable to read
# Returns:
#   REPLICATED_OPTS_VALUE
#######################################
readReplicatedOperatorOpts() {
    unset REPLICATED_OPTS_VALUE
    REPLICATED_OPTS_VALUE="$(echo "$REPLICATED_OPERATOR_OPTS" | grep -o "$1=[^ ]*" | cut -d'=' -f2)"
}

#######################################
# Prompts for daemon endpoint if not already set.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DAEMON_ENDPOINT
#######################################
DAEMON_ENDPOINT=
promptForDaemonEndpoint() {
    if [ -n "$DAEMON_ENDPOINT" ]; then
        return
    fi

    printf "Please enter the 'Daemon Address' displayed on the 'Cluster' page of your On-Prem Console.\n"
    while true; do
        printf "Daemon Address: "
        prompt
        if [ -n "$PROMPT_RESULT" ]; then
            DAEMON_ENDPOINT="$PROMPT_RESULT"
            return
        fi
    done
}

#######################################
# Prompts for daemon token if not already set.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   DAEMON_TOKEN
#######################################
DAEMON_TOKEN=
promptForDaemonToken() {
    if [ -n "$DAEMON_TOKEN" ]; then
        return
    fi

    printf "Please enter the 'Secret Token' displayed on the 'Cluster' page of your On-Prem Console.\n"
    while true; do
        printf "Secret Token: "
        prompt
        if [ -n "$PROMPT_RESULT" ]; then
            DAEMON_TOKEN="$PROMPT_RESULT"
            return
        fi
    done
}

#######################################
# Creates user and adds to Docker group
# Globals:
#   REPLICATED_USERNAME
# Arguments:
#   None
# Returns:
#   REPLICATED_USER_ID
#######################################
REPLICATED_USER_ID=0
maybeCreateReplicatedUser() {
    # require REPLICATED_USERNAME
    if [ -z "$REPLICATED_USERNAME" ]; then
        return
    fi

    # Create the users
    REPLICATED_USER_ID=$(id -u "$REPLICATED_USERNAME" 2>/dev/null || true)
    if [ -z "$REPLICATED_USER_ID" ]; then
        useradd -g "${DOCKER_GROUP_ID:-0}" "$REPLICATED_USERNAME"
        REPLICATED_USER_ID=$(id -u "$REPLICATED_USERNAME")
    fi

    # Add the users to the docker group if needed
    # Versions older than 2.5.0 run as root
    if [ "$REPLICATED_USER_ID" != "0" ]; then
        usermod -a -G "${DOCKER_GROUP_ID:-0}" "$REPLICATED_USERNAME"
    fi
}

#######################################
# Gets the replicated image registry prefix
# Globals:
#   None
# Arguments:
#   Replicated version
# Returns:
#   REPLICATED_REGISTRY_PREFIX
#######################################
REPLICATED_REGISTRY_PREFIX=
getReplicatedRegistryPrefix() {
    REPLICATED_REGISTRY_PREFIX=replicated
    local replicated_version="$1"
    semverCompare "$replicated_version" "2.45.0"
    if [ "$SEMVER_COMPARE_RESULT" -lt "0" ]; then
        REPLICATED_REGISTRY_PREFIX=quay.io/replicated
    fi
}

#######################################
# Pull replicated and replicated-ui container images.
# Globals:
#   REGISTRY_ADDRESS_OVERRIDE
#   REGISTRY_PATH_PREFIX
#   REPLICATED_REGISTRY_PREFIX
# Arguments:
#   None
# Returns:
#   None
#######################################
pullReplicatedImages() {
    if [ -n "$REGISTRY_ADDRESS_OVERRIDE" ]; then
        docker pull "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated:stable-2.51.0"
        docker pull "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated-ui:stable-2.51.0"
        (set -x; docker tag "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated:stable-2.51.0" "${REPLICATED_REGISTRY_PREFIX}/replicated:stable-2.51.0")
        (set -x; docker tag "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated-ui:stable-2.51.0" "${REPLICATED_REGISTRY_PREFIX}/replicated-ui:stable-2.51.0")
    else
        docker pull "${REPLICATED_REGISTRY_PREFIX}/replicated:stable-2.51.0"
        docker pull "${REPLICATED_REGISTRY_PREFIX}/replicated-ui:stable-2.51.0"
    fi
}

#######################################
# Pull replicated-operator container image.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
pullOperatorImage() {
    if [ -n "$REGISTRY_ADDRESS_OVERRIDE" ]; then
        docker pull "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated-operator:2.51.0"
        (set -x; docker tag "${REGISTRY_ADDRESS_OVERRIDE}/${REGISTRY_PATH_PREFIX}replicated/replicated-operator:2.51.0" "${REPLICATED_REGISTRY_PREFIX}/replicated-operator:stable-2.51.0")
    else
        docker pull "${REPLICATED_REGISTRY_PREFIX}/replicated-operator:2.51.0"
    fi
}

#######################################
# Tag and push replicated-operator container image to the on-prem registry.
# Globals:
#   None
# Arguments:
#   On-prem registry address
# Returns:
#   None
#######################################
tagAndPushOperatorImage()  {
    docker tag \
        "${REPLICATED_REGISTRY_PREFIX}/replicated-operator:2.51.0" \
        "${1}/replicated/replicated-operator:2.51.0"
    docker push "${1}/replicated/replicated-operator:2.51.0"
}

#######################################
#
# cli-script.sh
#
#######################################

#######################################
# Writes the replicated CLI to /usr/local/bin/replicated
# Wtires the replicated CLI V2 to /usr/local/bin/replicatedctl
# Globals:
#   None
# Arguments:
#   Container name/ID or script that identifies the container to run the commands in
# Returns:
#   None
#######################################
installCliFile() {
    _installCliFile "/usr/local/bin" "$1" "$2"
}

_installCliFile() {
    set +e
    read -r -d '' _flags <<EOF
interactive=
tty=
push=
no_tty=
is_admin=

while [ "\$1" != "" ]; do
  case "\$1" in
    # replicated admin shell alias support
    admin )
      is_admin=1
      ;;
    --no-tty )
      no_tty=1
      ;;
    --help | -h )
      push=\$push" \$1"
      ;;
    -i | --interactive | --interactive=1 )
      interactive=1
      ;;
    --interactive=0 )
      interactive=0
      ;;
    -t | --tty | --tty=1 )
      tty=1
      ;;
    --tty=0 )
      tty=0
      ;;
    -it | -ti )
      interactive=1
      tty=1
      ;;
    * )
      break
      ;;
  esac
  shift
done

# test if stdin is a terminal
if [ -z "\$interactive" ] && [ -z "\$tty" ]; then
  if [ -t 0 ]; then
    interactive=1
    tty=1
  elif [ -t 1 ]; then
    interactive=1
  fi
elif [ -z "\$tty" ] || [ "\$tty" = "0" ]; then
  # if flags explicitly set then use new behavior for no-tty
  no_tty=1
fi

if [ "\$is_admin" = 1 ]; then
  if [ "\$no_tty" = 1 ]; then
    push=" --no-tty"\$push
  fi
  push=" admin"\$push
fi

flags=
if [ "\$interactive" = "1" ] && [ "\$tty" = "1" ]; then
  flags=" -it"
elif [ "\$interactive" = "1" ]; then
  flags=" -i"
elif [ "\$tty" = "1" ]; then
  flags=" -t"
fi

# do not lose the quotes in arguments
opts=''
for i in "\$@"; do
  case "\$i" in
    *\\'*)
      i=\`printf "%s" "\$i" | sed "s/'/'\\"'\\"'/g"\`
      ;;
    *) : ;;
  esac
  opts="\$opts '\$i'"
done

EOF
    set -e

    cat > "${1}/replicated" <<-EOF
#!/bin/bash

set -eo pipefail

${_flags}

sh -c "${2} \$flags \\
  ${3} \\
  replicated\$push \$(printf "%s" "\$opts")"
EOF
    chmod a+x "${1}/replicated"
    cat > "${1}/replicatedctl" <<-EOF
#!/bin/bash

set -eo pipefail

${_flags}

sh -c "${2} \$flags \\
  ${3} \\
  replicatedctl\$push \$(printf "%s" "\$opts")"
EOF
    chmod a+x "${1}/replicatedctl"
}

#######################################
#
# alias.sh
#
# require common.sh
#
#######################################

#######################################
# Writes the alias command to the /etc/replicated.alias file
# Globals:
#   None
# Arguments:
#   Alias to write
# Returns:
#   REPLICATED_CONF_VALUE
#######################################
installAliasFile() {
    # "replicated" is no longer an alias, and we need to remove it from the file.
    # And we still need to create this file so replicated can write app aliases here.
    requireAliasFile

    _match="alias replicated=\".*\""
    if grep -q -s "$_match" /etc/replicated.alias; then
        # Replace in case we switched tags
        sed -i "s#$_match##" /etc/replicated.alias
    fi

    installAliasBashrc
}

#######################################
# Creates the /etc/replicated.alias file if it does not exist
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
requireAliasFile() {
    # Old script might have mounted this file when it didn't exist, and now it's a folder.
    if [ -d /etc/replicated.alias ]; then
        rm -rf /etc/replicated.alias
    fi
    if [ ! -e /etc/replicated.alias ]; then
        echo "# THIS FILE IS GENERATED BY REPLICATED. DO NOT EDIT!" > /etc/replicated.alias
        chmod a+r /etc/replicated.alias
    fi
}

#######################################
# Sources the /etc/replicated.alias file in the .bashrc
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
installAliasBashrc() {
    bashrc_file=
    if [ -f /etc/bashrc ]; then
        bashrc_file="/etc/bashrc"
    elif [ -f /etc/bash.bashrc ]; then
        bashrc_file="/etc/bash.bashrc"
    else
        echo "${RED}No global bashrc file found. Replicated command aliasing will be disabled.${NC}"
    fi

    if [ -n "$bashrc_file" ]; then
        if ! grep -q "/etc/replicated.alias" "$bashrc_file"; then
            cat >> "$bashrc_file" <<-EOF

if [ -f /etc/replicated.alias ]; then
    . /etc/replicated.alias
fi
EOF
        fi
    fi
}

#######################################
#
# ip-address.sh
#
# require common.sh, prompt.sh
#
#######################################

PRIVATE_ADDRESS=
PUBLIC_ADDRESS=

#######################################
# Prompts the user for a private address.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PRIVATE_ADDRESS
#######################################
promptForPrivateIp() {
    _count=0
    _regex="^[[:digit:]]+: ([^[:space:]]+)[[:space:]]+[[:alnum:]]+ ([[:digit:].]+)"
    while read -r _line; do
        [[ $_line =~ $_regex ]]
        if [ "${BASH_REMATCH[1]}" != "lo" ]; then
            _iface_names[$((_count))]=${BASH_REMATCH[1]}
            _iface_addrs[$((_count))]=${BASH_REMATCH[2]}
            let "_count += 1"
        fi
    done <<< "$(ip -4 -o addr)"
    if [ "$_count" -eq "0" ]; then
        echo >&2 "Error: The installer couldn't discover any valid network interfaces on this machine."
        echo >&2 "Check your network configuration and re-run this script again."
        echo >&2 "If you want to skip this discovery process, pass the 'local-address' arg to this script, e.g. 'sudo ./install.sh local-address=1.2.3.4'"
        exit 1
    elif [ "$_count" -eq "1" ]; then
        PRIVATE_ADDRESS=${_iface_addrs[0]}
        printf "The installer will use network interface '%s' (with IP address '%s')\n" "${_iface_names[0]}" "${_iface_addrs[0]}"
        return
    fi
    printf "The installer was unable to automatically detect the private IP address of this machine.\n"
    printf "Please choose one of the following network interfaces:\n"
    for i in $(seq 0 $((_count-1))); do
        printf "[%d] %-5s\t%s\n" "$i" "${_iface_names[$i]}" "${_iface_addrs[$i]}"
    done
    while true; do
        printf "Enter desired number (0-%d): " "$((_count-1))"
        prompt
        if [ -z "$PROMPT_RESULT" ]; then
            continue
        fi
        if [ "$PROMPT_RESULT" -ge "0" ] && [ "$PROMPT_RESULT" -lt "$_count" ]; then
            PRIVATE_ADDRESS=${_iface_addrs[$PROMPT_RESULT]}
            printf "The installer will use network interface '%s' (with IP address '%s').\n" "${_iface_names[$PROMPT_RESULT]}" "$PRIVATE_ADDRESS"
            return
        fi
    done
}

#######################################
# Discovers public IP address from cloud provider metadata services.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PUBLIC_ADDRESS
#######################################
discoverPublicIp() {
    if [ -n "$PUBLIC_ADDRESS" ]; then
        printf "The installer will use service address '%s' (from parameter)\n" "$PUBLIC_ADDRESS"
        return
    fi

    # gce
    if commandExists "curl"; then
        set +e
        _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip 2>/dev/null)
        _status=$?
        set -e
    else
        set +e
        _out=$(wget --no-proxy -t 1 --timeout=5 --connect-timeout=2 -qO- --header='Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip 2>/dev/null)
        _status=$?
        set -e
    fi
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        PUBLIC_ADDRESS=$_out
        printf "The installer will use service address '%s' (discovered from GCE metadata service)\n" "$PUBLIC_ADDRESS"
        return
    fi

    # ec2
    if commandExists "curl"; then
        set +e
        _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
        _status=$?
        set -e
    else
        set +e
        _out=$(wget --no-proxy -t 1 --timeout=5 --connect-timeout=2 -qO- http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
        _status=$?
        set -e
    fi
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        PUBLIC_ADDRESS=$_out
        printf "The installer will use service address '%s' (discovered from EC2 metadata service)\n" "$PUBLIC_ADDRESS"
        return
    fi

    # azure
    if commandExists "curl"; then
        set +e
        _out=$(curl --noproxy "*" --max-time 5 --connect-timeout 2 -qSfs -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text" 2>/dev/null)
        _status=$?
        set -e
    else
        set +e
        _out=$(wget --no-proxy -t 1 --timeout=5 --connect-timeout=2 -qO- --header='Metadata:true' "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text" 2>/dev/null)
        _status=$?
        set -e
    fi
    if [ "$_status" -eq "0" ] && [ -n "$_out" ]; then
        PUBLIC_ADDRESS=$_out
        printf "The installer will use service address '%s' (discovered from Azure metadata service)\n" "$PUBLIC_ADDRESS"
        return
    fi
}

#######################################
# Prompts the user for a public address.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PUBLIC_ADDRESS
#######################################
shouldUsePublicIp() {
    if [ -z "$PUBLIC_ADDRESS" ]; then
        return
    fi

    printf "The installer has automatically detected the service IP address of this machine as %s.\n" "$PUBLIC_ADDRESS"
    printf "Do you want to:\n"
    printf "[0] default: use %s\n" "$PUBLIC_ADDRESS"
    printf "[1] enter new address\n"
    printf "Enter desired number (0-1): "
    promptTimeout
    if [ "$PROMPT_RESULT" = "1" ]; then
        promptForPublicIp
    fi
}

#######################################
# Prompts the user for a public address.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PUBLIC_ADDRESS
#######################################
promptForPublicIp() {
    while true; do
        printf "Service IP address: "
        promptTimeout "-t 120"
        if [ -n "$PROMPT_RESULT" ]; then
            if isValidIpv4 "$PROMPT_RESULT"; then
                PUBLIC_ADDRESS=$PROMPT_RESULT
                break
            else
                printf "%s is not a valid ip address.\n" "$PROMPT_RESULT"
            fi
        else
            break
        fi
    done
}

#######################################
# Determines if the ip is a valid ipv4 address.
# Globals:
#   None
# Arguments:
#   IP
# Returns:
#   None
#######################################
isValidIpv4() {
    if echo "$1" | grep -qs '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'; then
        return 0
    else
        return 1
    fi
}

#######################################
# Determines if the ip is a valid ipv6 address. This will match long and short IPv6 addresses as
# well as the loopback address.
# Globals:
#   None
# Arguments:
#   IP
# Returns:
#   None
#######################################
isValidIpv6() {
    if echo "$1" | grep -qs "^\([0-9a-fA-F]\{0,4\}:\)\{1,7\}[0-9a-fA-F]\{0,4\}$"; then
        return 0
    else
        return 1
    fi
}

#######################################
# Returns the ip portion of an address.
# Globals:
#   None
# Arguments:
#   ADDRESS
# Returns:
#   PARSED_IPV4
#######################################
PARSED_IPV4=
parseIpv4FromAddress() {
    PARSED_IPV4=$(echo "$1" | grep --only-matching '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*')
}

#######################################
# Validates a private address against the ip routes.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if valid
#######################################
isValidPrivateIp() {
    local privateIp="$1"
    local _regex="^[[:digit:]]+: ([^[:space:]]+)[[:space:]]+[[:alnum:]]+ ([[:digit:].]+)"
    while read -r _line; do
        [[ $_line =~ $_regex ]]
        if [ "${BASH_REMATCH[1]}" != "lo" ] && [ "${BASH_REMATCH[2]}" = "$privateIp" ]; then
            return 0
        fi
    done <<< "$(ip -4 -o addr)"
    return 1
}

#######################################
#
# proxy.sh
#
# require prompt.sh, system.sh, docker.sh, replicated.sh
#
#######################################

PROXY_ADDRESS=
DID_CONFIGURE_DOCKER_PROXY=0

#######################################
# Prompts for proxy address.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PROXY_ADDRESS
#######################################
promptForProxy() {
    printf "Does this machine require a proxy to access the Internet? "
    if ! confirmN; then
        return
    fi

    printf "Enter desired HTTP proxy address: "
    prompt
    if [ -n "$PROMPT_RESULT" ]; then
        if [ "${PROMPT_RESULT:0:7}" != "http://" ] && [ "${PROMPT_RESULT:0:8}" != "https://" ]; then
            echo >&2 "Proxy address must have prefix \"http(s)://\""
            exit 1
        fi
        PROXY_ADDRESS="$PROMPT_RESULT"
        printf "The installer will use the proxy at '%s'\n" "$PROXY_ADDRESS"
    fi
}

#######################################
# Discovers proxy address from environment.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PROXY_ADDRESS
#######################################
discoverProxy() {
    readReplicatedConf "HttpProxy"
    if [ -n "$REPLICATED_CONF_VALUE" ]; then
        PROXY_ADDRESS="$REPLICATED_CONF_VALUE"
        printf "The installer will use the proxy at '%s' (imported from /etc/replicated.conf 'HttpProxy')\n" "$PROXY_ADDRESS"
        return
    fi

    if [ -n "$HTTP_PROXY" ]; then
        PROXY_ADDRESS="$HTTP_PROXY"
        printf "The installer will use the proxy at '%s' (imported from env var 'HTTP_PROXY')\n" "$PROXY_ADDRESS"
        return
    elif [ -n "$http_proxy" ]; then
        PROXY_ADDRESS="$http_proxy"
        printf "The installer will use the proxy at '%s' (imported from env var 'http_proxy')\n" "$PROXY_ADDRESS"
        return
    elif [ -n "$HTTPS_PROXY" ]; then
        PROXY_ADDRESS="$HTTPS_PROXY"
        printf "The installer will use the proxy at '%s' (imported from env var 'HTTPS_PROXY')\n" "$PROXY_ADDRESS"
        return
    elif [ -n "$https_proxy" ]; then
        PROXY_ADDRESS="$https_proxy"
        printf "The installer will use the proxy at '%s' (imported from env var 'https_proxy')\n" "$PROXY_ADDRESS"
        return
    fi
}

#######################################
# Requires that docker is set up with an http proxy.
# Globals:
#   PROXY_ADDRESS
#   NO_PROXY_ADDRESSES
#   DID_INSTALL_DOCKER
# Arguments:
#   None
# Returns:
#   None
#######################################
requireDockerProxy() {
    _previous_proxy="$(docker info 2>/dev/null | grep -i 'Http Proxy:' | sed 's/ *Http Proxy: //I')"
    _previous_no_proxy="$(docker info 2>/dev/null | grep -i 'No Proxy:' | sed 's/ *No Proxy: //I')"
    if [ "$PROXY_ADDRESS" = "$_previous_proxy" ] && [ "$NO_PROXY_ADDRESSES" = "$_previous_no_proxy" ]; then
        return
    fi

    _allow=n
    if [ "$DID_INSTALL_DOCKER" = "1" ]; then
        _allow=y
    else
        if [ -n "$_previous_proxy" ]; then
            printf "${YELLOW}It looks like Docker is set up with http proxy address $_previous_proxy.${NC}\n"
            if [ -n "$_previous_no_proxy" ]; then
                printf "${YELLOW}and no proxy addresses $_previous_no_proxy.${NC}\n"
            fi
            printf "${YELLOW}This script will automatically reconfigure it now.${NC}\n"
        else
            printf "${YELLOW}It does not look like Docker is set up with http proxy enabled.${NC}\n"
            printf "${YELLOW}This script will automatically configure it now.${NC}\n"
        fi
        printf "${YELLOW}Do you want to allow this?${NC} "
        if confirmY; then
            _allow=y
        fi
    fi
    if [ "$_allow" = "y" ]; then
        configureDockerProxy
    else
        printf "${YELLOW}Do you want to proceed anyway?${NC} "
        if ! confirmN; then
            printf "${RED}Please manually configure your Docker daemon with environment HTTP_PROXY.${NC}\n" 1>&2
            exit 1
        fi
    fi
}

#######################################
# Configures docker to run with an http proxy.
# Globals:
#   INIT_SYSTEM
#   PROXY_ADDRESS
#   NO_PROXY_ADDRESSES
# Arguments:
#   None
# Returns:
#   RESTART_DOCKER
#######################################
configureDockerProxy() {
    case "$INIT_SYSTEM" in
        systemd)
            _docker_conf_file=/etc/systemd/system/docker.service.d/http-proxy.conf
            mkdir -p /etc/systemd/system/docker.service.d

            _configureDockerProxySystemd "$_docker_conf_file" "$PROXY_ADDRESS" "$NO_PROXY_ADDRESSES"
            RESTART_DOCKER=1
            ;;
        upstart|sysvinit)
            _docker_conf_file=
            if [ -e /etc/sysconfig/docker ]; then
                _docker_conf_file=/etc/sysconfig/docker
            else
                _docker_conf_file=/etc/default/docker
                mkdir -p /etc/default
            fi

            _configureDockerProxyUpstart "$_docker_conf_file" "$PROXY_ADDRESS" "$NO_PROXY_ADDRESSES"
            RESTART_DOCKER=1
            ;;
        *)
            return 0
            ;;
    esac
    DID_CONFIGURE_DOCKER_PROXY=1
}

#######################################
# Configures systemd docker to run with an http proxy.
# Globals:
#   None
# Arguments:
#   $1 - config file
#   $2 - proxy address
#   $3 - no proxy address
# Returns:
#   None
#######################################
_configureDockerProxySystemd() {
    if [ ! -e "$1" ]; then
        touch "$1" # create the file if it doesn't exist
    fi

    if [ ! -s "$1" ]; then # if empty
        echo "# Generated by replicated install script" >> "$1"
        echo "[Service]" >> "$1"
    fi
    if ! grep -q "^\[Service\] *$" "$1"; then
        # don't mess with this file in this case
        return
    fi
    if ! grep -q "^Environment=" "$1"; then
        echo "Environment=" >> "$1"
    fi

    sed -i'' -e "s/\"*HTTP_PROXY=[^[:blank:]]*//" "$1" # remove new no proxy address
    sed -i'' -e "s/\"*NO_PROXY=[^[:blank:]]*//" "$1" # remove old no proxy address
    sed -i'' -e "s/^\(Environment=\) */\1/" "$1" # remove space after equals sign
    sed -i'' -e "s/ $//" "$1" # remove trailing space
    sed -i'' -e "s#^\(Environment=.*$\)#\1 \"HTTP_PROXY=${2}\" \"NO_PROXY=${3}\"#" "$1"
}

#######################################
# Configures upstart docker to run with an http proxy.
# Globals:
#   None
# Arguments:
#   $1 - config file
#   $2 - proxy address
#   $3 - no proxy address
# Returns:
#   None
#######################################
_configureDockerProxyUpstart() {
    if [ ! -e "$1" ]; then
        touch "$1" # create the file if it doesn't exist
    fi

    _export_proxy="export http_proxy=\"$2\""
    _export_noproxy="export NO_PROXY=\"$3\""
    if grep -q "^export http_proxy" "$1"; then
        sed -i'' -e "s#^export *http_proxy=.*#$_export_proxy#" "$1"
        _export_proxy=
    fi
    if grep -q "^export NO_PROXY" "$1"; then
        sed -i'' -e "s#^export *NO_PROXY=.*#$_export_noproxy#" "$1"
        _export_noproxy=
    fi

    if [ -n "$_export_proxy" ] || [ -n "$_export_noproxy" ]; then
        echo "" >> "$1"
        echo "# Generated by replicated install script" >> "$1"
    fi
    if [ -n "$_export_proxy" ]; then
        echo "$_export_proxy" >> "$1"
    fi
    if [ -n "$_export_noproxy" ]; then
        echo "$_export_noproxy" >> "$1"
    fi
}

#######################################
# Check that the docker proxy configuration was successful.
# Globals:
#   DID_CONFIGURE_DOCKER_PROXY
# Arguments:
#   None
# Returns:
#   None
#######################################
checkDockerProxyConfig() {
    if [ "$DID_CONFIGURE_DOCKER_PROXY" != "1" ]; then
        return
    fi
    if docker info 2>/dev/null | grep -q -i "Http Proxy:"; then
        return
    fi

    echo -e "${RED}Docker proxy configuration failed.${NC}"
    printf "Do you want to proceed anyway? "
    if ! confirmN; then
        echo >&2 "Please manually configure your Docker daemon with environment HTTP_PROXY."
        exit 1
    fi
}

#######################################
# Exports proxy configuration.
# Globals:
#   PROXY_ADDRESS
# Arguments:
#   None
# Returns:
#   None
#######################################
exportProxy() {
    if [ -z "$PROXY_ADDRESS" ]; then
        return
    fi
    if [ -z "$http_proxy" ]; then
       export http_proxy=$PROXY_ADDRESS
    fi
    if [ -z "$https_proxy" ]; then
       export https_proxy=$PROXY_ADDRESS
    fi
    if [ -z "$HTTP_PROXY" ]; then
       export HTTP_PROXY=$PROXY_ADDRESS
    fi
    if [ -z "$HTTPS_PROXY" ]; then
       export HTTPS_PROXY=$PROXY_ADDRESS
    fi
}

#######################################
# Assembles a sane list of no_proxy addresses
# Globals:
#   ADDITIONAL_NO_PROXY (optional)
# Arguments:
#   None
# Returns:
#   NO_PROXY_ADDRESSES
#######################################
NO_PROXY_ADDRESSES=
getNoProxyAddresses() {
    get_docker0_gateway_ip

    NO_PROXY_ADDRESSES="localhost,127.0.0.1,$DOCKER0_GATEWAY_IP"

    if [ -n "$ADDITIONAL_NO_PROXY" ]; then
        NO_PROXY_ADDRESSES="$NO_PROXY_ADDRESSES,$ADDITIONAL_NO_PROXY"
    fi

    while [ "$#" -gt 0 ]
    do
        # [10.138.0.2]:9878 -> 10.138.0.2
        hostname=`echo $1 | sed -e 's/:[0-9]*$//' | sed -e 's/[][]//g'`
        if [ -n "$hostname" ]; then
            NO_PROXY_ADDRESSES="$NO_PROXY_ADDRESSES,$hostname"
        fi
        shift
    done

    # filter duplicates
    NO_PROXY_ADDRESSES=`echo "$NO_PROXY_ADDRESSES" | sed 's/,/\n/g' | sort | uniq | paste -s --delimiters=","`
}

#######################################
#
# airgap.sh
#
# require prompt.sh
#
#######################################

#######################################
# Loads replicated main images into docker
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
airgapLoadReplicatedImages() {
    docker load < replicated.tar
    docker load < replicated-ui.tar
}

#######################################
# Loads replicated operator image into docker
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
airgapLoadOperatorImage() {
    docker load < replicated-operator.tar
}

#######################################
# Loads replicated support images into docker
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
airgapLoadSupportImages() {
    docker load < cmd.tar
    docker load < statsd-graphite.tar
    docker load < premkit.tar
    if [ -f debian.tar ]; then
        docker load < debian.tar
    fi
}

#######################################
# Loads Retraced images into docker, these images power the replicated audit logs
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
airgapMaybeLoadSupportBundle() {
    if [ -f support-bundle.tar ]; then
      printf "Loading support bundle image\n"
      docker load < support-bundle.tar
    fi

}

#######################################
# Loads Retraced images into docker, these images power the replicated audit logs
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
airgapMaybeLoadRetraced() {
    printf "Loading audit log images from package\n"

    # these have been monocontainer'd since 2.24.0
    if [ -f retraced.tar ]; then
        docker load < retraced.tar
        docker load < retraced-postgres.tar
        docker load < retraced-nsqd.tar
    fi

    # these have been included together prior to 2.21.0
    if [ -f retraced-processor.tar ]; then
        docker load < retraced-processor.tar
        docker load < retraced-db.tar
        docker load < retraced-api.tar
        docker load < retraced-cron.tar
    fi
    # single retraced bundle no longer included since 2.21.0
    if [ -f retraced-bundle.tar.gz ]; then
        tar xzvf retraced-bundle.tar.gz
        docker load < retraced-processor.tar
        docker load < retraced-postgres.tar
        docker load < retraced-nsqd.tar
        docker load < retraced-db.tar
        docker load < retraced-api.tar
        docker load < retraced-cron.tar
    fi
    # redis is included in Retraced <= 1.1.10
    if [ -f retraced-redis.tar ]; then
        docker load < retraced-redis.tar
    fi
}

#######################################
# Prompts for daemon registry address if not defined
# Globals:
#   DAEMON_REGISTRY_ADDRESS
# Arguments:
#   None
# Returns:
#   None
#######################################
promptForDaemonRegistryAddress() {
    if [ -n "$DAEMON_REGISTRY_ADDRESS" ]; then
        return
    fi

    printf "Please enter the Replicated on-prem registry address.\n"
    while true; do
        printf "On-prem registry address: "
        prompt
        if [ -n "$PROMPT_RESULT" ]; then
            DAEMON_REGISTRY_ADDRESS="$PROMPT_RESULT"
            return
        fi
    done
}

#######################################
# Prompts for daemon registry CA if not defined
# Globals:
#   CA
# Arguments:
#   None
# Returns:
#   None
#######################################
promptForCA() {
    if [ -n "$CA" ]; then
        return
    fi

    printf "Please enter the Replicated on-prem registry base64 encoded ca certificate pem.\n"
    while true; do
        printf "CA: "
        prompt
        if [ -n "$PROMPT_RESULT" ]; then
            CA="$PROMPT_RESULT"
            return
        fi
    done
}

#######################################
#
# selinux.sh
#
# require common.sh docker-version.sh prompt.sh
#
#######################################

#######################################
# Check if SELinux is enabled
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Non-zero exit status unless SELinux is enabled
#######################################
selinux_enabled() {
    if commandExists "selinuxenabled"; then
        selinuxenabled
        return
    elif commandExists "sestatus"; then
        ENABLED=$(sestatus | grep 'SELinux status' | awk '{ print $3 }')
        echo "$ENABLED" | grep --quiet --ignore-case enabled
        return
    fi

    return 1
}

#######################################
# Check if SELinux is enforced
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Non-zero exit status unelss SELinux is enforced
#######################################
selinux_enforced() {
    if commandExists "getenforce"; then
        ENFORCED=$(getenforce)
        echo $(getenforce) | grep --quiet --ignore-case enforcing
        return
    elif commandExists "sestatus"; then
        ENFORCED=$(sestatus | grep 'SELinux mode' | awk '{ print $3 }')
        echo "$ENFORCED" | grep --quiet --ignore-case enforcing
        return
    fi

    return 1
}

SELINUX_REPLICATED_DOMAIN_LABEL=
get_selinux_replicated_domain_label() {
    getDockerVersion

    compareDockerVersions "$DOCKER_VERSION" "1.11.0"
    if [ "$COMPARE_DOCKER_VERSIONS_RESULT" -eq "-1" ]; then
        SELINUX_REPLICATED_DOMAIN_LABEL="label:type:$SELINUX_REPLICATED_DOMAIN"
    else
        SELINUX_REPLICATED_DOMAIN_LABEL="label=type:$SELINUX_REPLICATED_DOMAIN"
    fi
}

#######################################
# Prints a warning if selinux is enabled and enforcing
# Globals:
#   None
# Arguments:
#   Mode - either permissive or enforcing
# Returns:
#   None
#######################################
warn_if_selinux() {
    if selinux_enabled ; then
        if selinux_enforced ; then
            printf "${YELLOW}SELinux is enforcing. Running docker with the \"--selinux-enabled\" flag may cause some features to become unavailable.${NC}\n\n"
        else
            printf "${YELLOW}SELinux is enabled. Switching to enforcing mode and running docker with the \"--selinux-enabled\" flag may cause some features to become unavailable.${NC}\n\n"
        fi
    fi
}

#######################################
# Prompts to confirm disabling of SELinux for K8s installs, bails on decline.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
must_disable_selinux() {
    # From kubernets kubeadm docs for RHEL:
    #
    #    Disabling SELinux by running setenforce 0 is required to allow containers to
    #    access the host filesystem, which is required by pod networks for example.
    #    You have to do this until SELinux support is improved in the kubelet.
    if selinux_enabled && selinux_enforced ; then
        printf "\n${YELLOW}Kubernetes is incompatible with SELinux. Disable SELinux to continue?${NC} "
        if confirmY ; then
            setenforce 0
            sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config
        else
            bail "\nDisable SELinux with 'setenforce 0' before re-running install script"
        fi
    fi
}

#######################################
#
# firewall.sh
#
# require prompt.sh
#
#######################################

#######################################
# Warns or terminates if firewalld is active
# Globals:
#   BYPASS_FIREWALLD_WARNING, HARD_FAIL_ON_FIREWALLD, INIT_SYSTEM
# Arguments:
#   None
# Returns:
#   None
#######################################
checkFirewalld() {
    if [ "$BYPASS_FIREWALLD_WARNING" = "1" ]; then
        return
    fi
    # firewalld is only available on RHEL 7+ so other init systems can be ignored
    if [ "$INIT_SYSTEM" != "systemd" ]; then
        return
    fi
    if ! systemctl -q is-active firewalld ; then
        return
    fi

    if [ "$HARD_FAIL_ON_FIREWALLD" = "1" ]; then
        printf "${RED}Firewalld is active${NC}\n" 1>&2
        exit 1
    fi

    printf "${YELLOW}Continue with firewalld active? ${NC}"
    if confirmY ; then
        BYPASS_FIREWALLD_WARNING=1
        return
    fi
    exit 1
}

#######################################
#
# registryproxy.sh
#
# require common.sh
# require log.sh
# require prompt.sh
#
#######################################

ARTIFACTORY_ADDRESS=
ARTIFACTORY_ACCESS_METHOD=
ARTIFACTORY_DOCKER_REPO_KEY=
ARTIFACTORY_QUAY_REPO_KEY=
ARTIFACTORY_AUTH=

#######################################
# Configures the registry address override
# and path prefix when a registry proxy is set.
# Globals:
#   ARTIFACTORY_ADDRESS
#   ARTIFACTORY_ACCESS_METHOD
#   ARTIFACTORY_DOCKER_REPO_KEY
#   ARTIFACTORY_QUAY_REPO_KEY
#   REPLICATED_REGISTRY_PREFIX
# Arguments:
#   None
# Returns:
#   REGISTRY_ADDRESS_OVERRIDE
#   REGISTRY_PATH_PREFIX
#######################################
configureRegistryProxyAddressOverride()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    if [ "$AIRGAP" = "1" ]; then
        bail "Artifactory registry proxy cannot be used with airgap."
    fi

    if [ "$REPLICATED_REGISTRY_PREFIX" = "quay.io/replicated" ]; then
        case "$ARTIFACTORY_ACCESS_METHOD" in
            url-prefix)
                _configureRegistryProxyAddressOverride_UrlPrefixQuay
                ;;
            subdomain)
                _configureRegistryProxyAddressOverride_SubdomainQuay
                ;;
            port)
                _configureRegistryProxyAddressOverride_PortQuay
                ;;
            *)
                # default url-prefix
                _configureRegistryProxyAddressOverride_UrlPrefixQuay
                ;;
        esac
    else
        case "$ARTIFACTORY_ACCESS_METHOD" in
            url-prefix)
                _configureRegistryProxyAddressOverride_UrlPrefix
                ;;
            subdomain)
                _configureRegistryProxyAddressOverride_Subdomain
                ;;
            port)
                _configureRegistryProxyAddressOverride_Port
                ;;
            *)
                # default url-prefix
                _configureRegistryProxyAddressOverride_UrlPrefix
                ;;
        esac
    fi
}

_configureRegistryProxyAddressOverride_UrlPrefix()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    local repoKey="$ARTIFACTORY_DOCKER_REPO_KEY"
    if [ -z "$repoKey" ]; then
        logWarn "Flag \"artifactory-docker-repo-key\" not set, defaulting to \"docker-remote\"."
        repoKey="docker-remote"
    fi
    REGISTRY_ADDRESS_OVERRIDE="$ARTIFACTORY_ADDRESS"
    REGISTRY_PATH_PREFIX="${repoKey}/"
}

_configureRegistryProxyAddressOverride_UrlPrefixQuay()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    local repoKey="$ARTIFACTORY_QUAY_REPO_KEY"
    if [ -z "$repoKey" ]; then
        logWarn "Flag \"artifactory-quay-repo-key\" not set, defaulting to \"quay-remote\"."
        repoKey="quay-remote"
    fi
    REGISTRY_ADDRESS_OVERRIDE="$ARTIFACTORY_ADDRESS"
    REGISTRY_PATH_PREFIX="${repoKey}/"
}

_configureRegistryProxyAddressOverride_Subdomain()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    local repoKey="$ARTIFACTORY_DOCKER_REPO_KEY"
    if [ -z "$repoKey" ]; then
        logWarn "Flag \"artifactory-docker-repo-key\" not set, defaulting to \"docker-remote\"."
        repoKey="docker-remote"
    fi
    REGISTRY_ADDRESS_OVERRIDE="${repoKey}.${ARTIFACTORY_ADDRESS}"
}

_configureRegistryProxyAddressOverride_SubdomainQuay()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    local repoKey="$ARTIFACTORY_QUAY_REPO_KEY"
    if [ -z "$repoKey" ]; then
        logWarn "Flag \"artifactory-quay-repo-key\" not set, defaulting to \"quay-remote\"."
        repoKey="quay-remote"
    fi
    REGISTRY_ADDRESS_OVERRIDE="${repoKey}.${ARTIFACTORY_ADDRESS}"
}

_configureRegistryProxyAddressOverride_Port()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    if [ -z "$ARTIFACTORY_DOCKER_REPO_KEY" ]; then
        bail "Flag \"artifactory-docker-repo-key\" required for Artifactory access method \"port\"."
    fi
    splitHostPort "$ARTIFACTORY_ADDRESS"
    REGISTRY_ADDRESS_OVERRIDE="${HOST}:${ARTIFACTORY_DOCKER_REPO_KEY}"
}

_configureRegistryProxyAddressOverride_PortQuay()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    if [ -z "$ARTIFACTORY_QUAY_REPO_KEY" ]; then
        bail "Flag \"artifactory-quay-repo-key\" required for Artifactory access method \"port\"."
    fi
    splitHostPort "$ARTIFACTORY_ADDRESS"
    REGISTRY_ADDRESS_OVERRIDE="${HOST}:${ARTIFACTORY_QUAY_REPO_KEY}"
}

#######################################
# Writes registry proxy config if it does not exist.
# Globals:
#   ARTIFACTORY_ADDRESS
#   ARTIFACTORY_ACCESS_METHOD
#   ARTIFACTORY_DOCKER_REPO_KEY
#   ARTIFACTORY_QUAY_REPO_KEY
#   ARTIFACTORY_AUTH
# Arguments:
#   None
# Returns:
#   None
#######################################
maybeWriteRegistryProxyConfig()
{
    if [ -z "$ARTIFACTORY_ADDRESS" ]; then
        return
    fi

    if [ -f /etc/replicated/registry_proxy.json ]; then
        return
    fi

    printf "\n${YELLOW}Registry proxy configuration file /etc/replicated/registry_proxy.json not found.${NC}\n\n"
    printf "${YELLOW}Do you want to proceed anyway? ${NC}"
    if ! confirmN; then
        exit 0
    fi

    mkdir -p /etc/replicated
    _writeRegistryProxyConfig "/etc/replicated/registry_proxy.json"
}

_writeRegistryProxyConfig()
{
    cat > "$1" <<-EOF
{
  "artifactory": {
    "address": "$ARTIFACTORY_ADDRESS",
    "auth": "$ARTIFACTORY_AUTH",
EOF
    if [ -z "$ARTIFACTORY_DOCKER_REPO_KEY" ] && [ -z "$ARTIFACTORY_QUAY_REPO_KEY" ]; then
        cat >> "$1" <<-EOF
    "access_method": "$ARTIFACTORY_ACCESS_METHOD"
  }
}
EOF
        return
    fi

    cat >> "$1" <<-EOF
    "access_method": "$ARTIFACTORY_ACCESS_METHOD",
    "repository_key_map": {
EOF
    if [ -n "$ARTIFACTORY_DOCKER_REPO_KEY" ] && [ -n "$ARTIFACTORY_QUAY_REPO_KEY" ]; then
        echo "      \"docker.io\": \"$ARTIFACTORY_DOCKER_REPO_KEY\"," >> "$1"
    elif [ -n "$ARTIFACTORY_DOCKER_REPO_KEY" ]; then
        echo "      \"docker.io\": \"$ARTIFACTORY_DOCKER_REPO_KEY\"" >> "$1"
    fi
    if [ -n "$ARTIFACTORY_QUAY_REPO_KEY" ]; then
        echo "      \"quay.io\": \"$ARTIFACTORY_QUAY_REPO_KEY\"" >> "$1"
    fi
    cat >> "$1" <<-EOF
    }
  }
}
EOF
}

#######################################
# Prompts for Artifactory auth creds if ARTIFACTORY_AUTH
# is set to string literal "<ARTIFACTORY_SECRET>".
# Globals:
#   ARTIFACTORY_AUTH
# Arguments:
#   $1 - username (for testing)
#   $2 - password (for testing)
# Returns:
#   ARTIFACTORY_AUTH
#######################################
maybePromptForArtifactoryAuth()
{
    if [ "$ARTIFACTORY_AUTH" != "<ARTIFACTORY_SECRET>" ]; then
        return
    fi

    artifactoryUsername="$1"
    artifactoryPassword="$2"

    printf "\nPlease enter your artifactory registry credentials (leave blank to skip)\n"
    if [ -z "$artifactoryUsername" ]; then
        printf "Username: "
        prompt
        local artifactoryUsername="$PROMPT_RESULT"
    fi
    if [ -z "$artifactoryPassword" ]; then
        printf "Password: "
        prompt
        local artifactoryPassword="$PROMPT_RESULT"
    fi
    if [ -z "$artifactoryUsername" ] || [ -z "$artifactoryPassword" ]; then
        logWarn "Artifactory credentials are empty"
        unset ARTIFACTORY_AUTH
        return
    fi
    ARTIFACTORY_AUTH="$(echo -n $artifactoryUsername:$artifactoryPassword | base64)"
}

#######################################
# Parses a basic auth string (base64 user:pass)
# Globals:
#   None
# Arguments:
#   $1 - Auth string
# Returns:
#   BASICAUTH_USERNAME
#   BASICAUTH_PASSWORD
#######################################
parseBasicAuth()
{
    BASICAUTH_USERNAME=
    BASICAUTH_PASSWORD=
    local auth="$(echo "$1" | base64 --decode)"
    oIFS="$IFS"; IFS=":" read -r BASICAUTH_USERNAME BASICAUTH_PASSWORD <<< "$auth"; IFS="$oIFS"
}
###############################################################################
## index.sh
###############################################################################

###############################################################################
## print.sh
###############################################################################

info()
{
    printf "[INFO] ${1}\n"
}

warn()
{
    printf "${YELLOW}[WARN] ${1}${NC}\n"
}

error()
{
    printf "${RED}[ERROR] ${1}${NC}\n"
}

###############################################################################
## disk.sh
###############################################################################

###############################################################################
# Determine if root disk usage is over 83% threshold
###############################################################################
preflightDiskUsageRootDir()
{
    preflightDiskUsage / 83
}

###############################################################################
# Determine if /var/lib/docker disk usage is over 83% threshold
###############################################################################
preflightDiskUsageDockerDataDir()
{
    if ! isDockerInstalled ; then
        return 0
    fi
    preflightDiskUsage /var/lib/docker 83
}

###############################################################################
# Determine if /var/lib/replicated disk usage is over 83% threshold
###############################################################################
preflightDiskUsageReplicatedDataDir()
{
    if ! commandExists "replicatedctl"; then
        return 0
    fi
    preflightDiskUsage /var/lib/replicated 83
}

preflightDiskUsage()
{
    local dir="$1"
    local threshold="$2"
    if [ ! -d "$dir" ]; then
        return 0
    fi

    getDiskUsagePcent "$dir"
    if [ "$DISK_USAGE_PCENT" -ge "$threshold" ]; then
        warn "$dir disk usage is at ${DISK_USAGE_PCENT}%%"
        return 1
    fi
    info "$dir disk usage is at ${DISK_USAGE_PCENT}%%"
    return 0
}

getDiskUsagePcent()
{
    DISK_USAGE_PCENT="$(df "$1" | awk 'NR==2 {print $5}' | sed 's/%//')"
}
###############################################################################
## docker.sh
###############################################################################

###############################################################################
# Check if Docker device driver is Devicemapper in loopback mode
###############################################################################
preflightDockerDevicemapperLoopback()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    local driver="$(docker info 2>/dev/null | grep 'Storage Driver' | awk '{print $3}' | awk -F- '{print $1}')"
    if [ "$driver" != "devicemapper" ]; then
        return 0
    fi
    if docker info 2>/dev/null | grep -Fqs 'Data loop file:'; then
        warn "Docker device driver devicemapper is in loopback mode"
        return 1
    fi
    info "Docker device driver devicemapper not in loopback mode"
    return 0
}

###############################################################################
# Check if Docker is running with an http proxy
###############################################################################
preflightDockerHttpProxy()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    local proxy="$(docker info 2>/dev/null | grep -i 'Http Proxy:' | sed 's/ *Http Proxy: //I')"
    local no_proxy="$(docker info 2>/dev/null | grep -i 'No Proxy:' | sed 's/ *No Proxy: //I')"

    if [ -n "$proxy" ]; then
        info "Docker is set with http proxy \"$proxy\" and no proxy \"$no_proxy\""
    fi
    info "Docker http proxy not set"
    return 0
}

###############################################################################
# Check if Docker is running with a non-default seccomp profile
###############################################################################
preflightDockerSeccompNonDefault()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    if ! docker info 2>&1 | grep -q seccomp; then
        # no seccomp profile
        return 0
    fi

    if docker info 2>&1 | grep -qE "WARNING:.*seccomp profile"; then
        warn "Docker using a non-default seccomp profile"
        return 1
    fi
    info "Docker using default seccomp profile"
    return 0
}

###############################################################################
# Check if Docker is running with a non-standard root directory
###############################################################################
preflightDockerNonStandardRoot()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    local dir="$(docker info 2>/dev/null | grep -i 'Docker Root Dir:' | sed 's/ *Docker Root Dir: //I')"
    if [ -z "$dir" ]; then
        # failed to detect root dir
        return 0
    fi
    if [ "$dir" != "/var/lib/docker" ]; then
        warn "Docker using a non-standard root directory of $dir"
        return 0
    fi
    info "Docker using standard root directory"
    return 0
}

###############################################################################
# Check if Docker icc is disabled
###############################################################################
preflightDockerIccDisabled()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    if ! docker network >/dev/null 2>&1; then
        # docker network command does not exist
        return 0
    fi

    if docker network inspect bridge | grep -q '"com.docker.network.bridge.enable_icc": "false"'; then
        warn "Docker icc (inter-container communication) disabled"
        return 1
    fi
    info "Docker icc (inter-container communication) enabled"
    return 0
}

###############################################################################
# Check if any Docker container registries are blocked
###############################################################################
preflightDockerContainerRegistriesBlocked()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    if [ ! -e /etc/containers/registries.conf ]; then
        return 0
    fi
    local registries="$(cat /etc/containers/registries.conf | awk '/\[registries\.block\]/,0' | grep "registries = " | head -1 | sed 's/registries *= \[ *\([^]]*\) *]/\1/')"
    if [ -n "$registries" ]; then
        warn "Docker /etc/containers/registries.conf blocking registries $registries"
        return 1
    fi
    info "Docker /etc/containers/registries.conf not blocking"
    return 0
}

###############################################################################
# Check if any Docker nofile ulimit is set
###############################################################################
preflightDockerUlimitNofileSet()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    maybeBuildPreflightImage
    maybeRemoveDockerContainer preflightDockerUlimitNofileSet
    docker run -d -p 38888:80 --name preflightDockerUlimitNofileSet "$PREFLIGHT_IMAGE" 10 >/dev/null 2>&1
    local nofile="$(docker inspect preflightDockerUlimitNofileSet | awk '/"nofile",/,0')"
    maybeRemoveDockerContainer preflightDockerUlimitNofileSet

    if [ -n "$nofile" ]; then
        local soft="$(echo "$nofile" | grep '"Soft":' | head -1 | sed 's/.*"Soft": *\([0-9]*\).*/\1/')"
        local hard="$(echo "$nofile" | grep '"Hard":' | head -1 | sed 's/.*"Hard": *\([0-9]*\).*/\1/')"
        if [ -n "$soft" ] || [ -n "$hard" ]; then
            warn "Docker open files (nofile) ulimit set to ${soft}:${hard}"
            return 1
        fi
    fi
    info "Docker open files (nofile) ulimit not set"
    return 0
}

###############################################################################
# Check if Docker userland-proxy is disabled
###############################################################################
preflightDockerUserlandProxyDisabled()
{
    if ! isDockerInstalled ; then
        return 0
    fi

    maybeBuildPreflightImage
    maybeRemoveDockerContainer preflightDockerUserlandProxyDisabled
    docker run -d -p 38888:80 --name preflightDockerUserlandProxyDisabled "$PREFLIGHT_IMAGE" 10 >/dev/null 2>&1
    if ! ps auxw | grep -q "[d]ocker-proxy"; then
        maybeRemoveDockerContainer preflightDockerUserlandProxyDisabled
        warn "Docker userland proxy disabled"
        return 1
    fi
    maybeRemoveDockerContainer preflightDockerUserlandProxyDisabled
    info "Docker userland proxy enabled"
    return 0
}

PREFLIGHT_IMAGE="replicated/sleep:1.0"
maybeBuildPreflightImage()
{
    if docker inspect "$PREFLIGHT_IMAGE" >/dev/null 2>&1; then
        return
    fi

    local sleep="$(which sleep)"

    local linked="$(ldd -v "$sleep" | grep " => /" | sed -n 's/.*=> \(\/[^ ]*\).*/\1/p' | sort | uniq)"

    local dir="$(mktemp -d)"

    cp "$sleep" "$dir"

    while read -r so; do
        cp "$so" "$dir"
    done <<< "$linked"

    cat >"$dir/Dockerfile" <<EOF
FROM scratch

ADD sleep /bin/sleep
EOF

    while read -r so; do
        echo "ADD $(basename $so) $so" >> "$dir/Dockerfile"
    done <<< "$linked"

    cat >>"$dir/Dockerfile" <<EOF

ENTRYPOINT ["/bin/sleep"]
EOF

    docker build -t "$PREFLIGHT_IMAGE" "$dir" >/dev/null
    rm -rf "$dir"
}

maybeRemoveDockerContainer()
{
    docker rm -f "$1" >/dev/null 2>&1 || true
}
###############################################################################
## firewalld.sh
###############################################################################

###############################################################################
# Determine if firewalld is active
###############################################################################
preflightFirewalld()
{
    if ! commandExists "systemctl"; then
        return 0
    fi
    if ! systemctl -q is-active firewalld; then
        info "Firewalld is not active"
        return 0
    fi

    info "Firewalld is active"
    return 1
}
###############################################################################
## iptables.sh
###############################################################################

###############################################################################
# Check if iptables default policy for the input chain is drop
###############################################################################
preflightIptablesInputDrop()
{
    if iptables -L | grep 'Chain INPUT (policy DROP)'; then
        warn "Iptables chain INPUT default policy DROP"
        return 1
    fi

    info "Iptables chain INPUT default policy ACCEPT"
    return 0
}
###############################################################################
## selinux.sh
###############################################################################

###############################################################################
# Check if SELinux is in enforcing mode
###############################################################################
preflightSelinuxEnforcing()
{
    local enforcing=
    if commandExists "getenforce"; then
        enforcing="$(getenforce)"
    elif commandExists "sestatus"; then
        enforcing="$(sestatus | grep 'SELinux mode' | awk '{ print $3 }')"
    else
        return 0
    fi

    if echo "$enforcing" | grep -qi enforcing; then
        warn "SELinux is in enforcing mode"
        return 1
    fi
    info "SELinux is not in enforcing mode"
    return 0
}

HAS_PREFLIGHT_WARNINGS=
HAS_PREFLIGHT_ERRORS=

###############################################################################
# Runs preflight checks
# Sets HAS_PREFLIGHT_WARNINGS=1 if there are any warnings
# Sets HAS_PREFLIGHT_ERRORS=1 if there are any errors
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   1 if there are errors
###############################################################################
runPreflights()
{
    HAS_PREFLIGHT_WARNINGS=0
    HAS_PREFLIGHT_ERRORS=0

    set +e
    if ! preflightDiskUsageRootDir; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDiskUsageDockerDataDir; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDiskUsageReplicatedDataDir; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerDevicemapperLoopback; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerHttpProxy; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerSeccompNonDefault; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerNonStandardRoot; then
        HAS_PREFLIGHT_ERRORS=1
    fi

    if ! preflightDockerIccDisabled; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerContainerRegistriesBlocked; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerUlimitNofileSet; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightDockerUserlandProxyDisabled; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightFirewalld; then
        HAS_PREFLIGHT_WARNINGS=1
    fi

    if ! preflightIptablesInputDrop; then
        HAS_PREFLIGHT_ERRORS=1
    fi

    if ! preflightSelinuxEnforcing; then
        HAS_PREFLIGHT_WARNINGS=1
    fi
    set -e

    if [ "$HAS_PREFLIGHT_ERRORS" = "1" ]; then
        return 1
    fi
    return 0
}

ask_for_registry_name_ipv6() {
  line=
  while [[ "$line" == "" ]]; do
    printf "Enter a hostname that resolves to $PRIVATE_ADDRESS: "
    prompt
    line=$PROMPT_RESULT
  done

  # check if it's resolvable.  it might not be ping-able.
  if ping6 -c 1 $line 2>&1 | grep -q "unknown host"; then
      echo -e >&2 "${RED}${line} cannot be resolved${NC}"
      exit 1
  fi
  REGISTRY_ADVERTISE_ADDRESS="$line"
  printf "Replicated will use \"%s\" to communicate with this server.\n" "${REGISTRY_ADVERTISE_ADDRESS}"
}

discoverPrivateIp() {
    if [ -n "$PRIVATE_ADDRESS" ]; then
        if [ "$NO_PRIVATE_ADDRESS_PROMPT" != "1" ]; then
            printf "Validating local address supplied in parameter: '%s'\n" $PRIVATE_ADDRESS
            if ! isValidPrivateIp "$PRIVATE_ADDRESS" ; then
                promptForPrivateIp
                return
            fi
        fi
        printf "The installer will use local address '%s' (from parameter)\n" $PRIVATE_ADDRESS
        return
    fi

    readReplicatedConf "LocalAddress"
    if [ -n "$REPLICATED_CONF_VALUE" ]; then
        PRIVATE_ADDRESS="$REPLICATED_CONF_VALUE"
        if [ "$NO_PRIVATE_ADDRESS_PROMPT" != "1" ]; then
            printf "Validating local address found in /etc/replicated.conf: '%s'\n" $PRIVATE_ADDRESS
            if ! isValidPrivateIp "$PRIVATE_ADDRESS" ; then
                promptForPrivateIp
                return
            fi
        fi
        printf "The installer will use local address '%s' (imported from /etc/replicated.conf 'LocalAddress')\n" $PRIVATE_ADDRESS
        return
    fi

    promptForPrivateIp
}

configure_docker_ipv6() {
  case "$INIT_SYSTEM" in
      systemd)
        if ! grep -q "^ExecStart.*--ipv6" /lib/systemd/system/docker.service; then
            sed -i 's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd --ipv6/' /lib/systemd/system/docker.service
            RESTART_DOCKER=1
        fi
        ;;
      upstart|sysvinit)
        if [ -e /etc/sysconfig/docker ]; then # CentOS 6
          if ! grep -q "^other_args=.*--ipv6" /etc/sysconfig/docker; then
              sed -i 's/other_args=\"/other_args=\"--ipv6/' /etc/sysconfig/docker
              RESTART_DOCKER=1
          fi
        fi

        if [ -e /etc/default/docker ]; then # Everything NOT CentOS 6
          if ! grep -q "^DOCKER_OPTS=" /etc/default/docker; then
              echo 'DOCKER_OPTS="--ipv6"' >> /etc/default/docker
              RESTART_DOCKER=1
          fi
        fi
        ;;
      *)
        return 0
        ;;
  esac
}

DAEMON_TOKEN=
get_daemon_token() {
    if [ -n "$DAEMON_TOKEN" ]; then
        return
    fi

    readReplicatedOpts "DAEMON_TOKEN"
    if [ -n "$REPLICATED_OPTS_VALUE" ]; then
        DAEMON_TOKEN="$REPLICATED_OPTS_VALUE"
        return
    fi

    readReplicatedConf "DaemonToken"
    if [ -n "$REPLICATED_CONF_VALUE" ]; then
        DAEMON_TOKEN="$REPLICATED_CONF_VALUE"
        return
    fi

    getGuid
    DAEMON_TOKEN="$GUID_RESULT"
}

SELINUX_REPLICATED_DOMAIN=
CUSTOM_SELINUX_REPLICATED_DOMAIN=0
get_selinux_replicated_domain() {
    # may have been set by command line argument
    if [ -n "$SELINUX_REPLICATED_DOMAIN" ]; then
        CUSTOM_SELINUX_REPLICATED_DOMAIN=1
        return
    fi

    # if previously set to a custom domain it will be in REPLICATED_OPTS
    readReplicatedOpts "SELINUX_REPLICATED_DOMAIN"
    if [ -n "$REPLICATED_OPTS_VALUE" ]; then
        SELINUX_REPLICATED_DOMAIN="$REPLICATED_OPTS_VALUE"
        CUSTOM_SELINUX_REPLICATED_DOMAIN=1
        return
    fi

    # default if unset
    SELINUX_REPLICATED_DOMAIN=spc_t
}

remove_docker_containers() {
    # try twice because of aufs error "Unable to remove filesystem"
    if docker inspect replicated &>/dev/null; then
        set +e
        docker rm -f replicated
        _status=$?
        set -e
        if [ "$_status" -ne "0" ]; then
            if docker inspect replicated &>/dev/null; then
                printf "Failed to remove replicated container, retrying\n"
                sleep 1
                docker rm -f replicated
            fi
        fi
    fi
    if docker inspect replicated-ui &>/dev/null; then
        set +e
        docker rm -f replicated-ui
        _status=$?
        set -e
        if [ "$_status" -ne "0" ]; then
            if docker inspect replicated-ui &>/dev/null; then
                printf "Failed to remove replicated-ui container, retrying\n"
                sleep 1
                docker rm -f replicated-ui
            fi
        fi
    fi
}

tag_docker_images() {
    printf "Tagging replicated and replicated-ui images\n"
    # older docker versions require -f flag to move a tag from one image to another
    docker tag "$REPLICATED_REGISTRY_PREFIX/replicated:stable-2.51.0" "$REPLICATED_REGISTRY_PREFIX/replicated:current" 2>/dev/null \
        || docker tag -f "$REPLICATED_REGISTRY_PREFIX/replicated:stable-2.51.0" "$REPLICATED_REGISTRY_PREFIX/replicated:current"
    docker tag "$REPLICATED_REGISTRY_PREFIX/replicated-ui:stable-2.51.0" "$REPLICATED_REGISTRY_PREFIX/replicated-ui:current" 2>/dev/null \
        || docker tag -f "$REPLICATED_REGISTRY_PREFIX/replicated-ui:stable-2.51.0" "$REPLICATED_REGISTRY_PREFIX/replicated-ui:current"
}

find_hostname() {
    set +e
    SYS_HOSTNAME=`hostname -f`
    if [ "$?" -ne "0" ]; then
        SYS_HOSTNAME=`hostname`
        if [ "$?" -ne "0" ]; then
            SYS_HOSTNAME=""
        fi
    fi
    set -e
}

REPLICATED_OPTS=
build_replicated_opts() {
    # See https://github.com/golang/go/blob/23173fc025f769aaa9e19f10aa0f69c851ca2f3b/src/crypto/x509/root_linux.go
    # CentOS 6/7, RHEL 7
    # Fedora/RHEL 6 (this is a link on Centos 6/7)
    # OpenSUSE
    # OpenELEC
    # Debian/Ubuntu/Gentoo etc. This is where OpenSSL will look. It's moved to the bottom because this exists as a link on some other platforms
    set \
        "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem" \
        "/etc/pki/tls/certs/ca-bundle.crt" \
        "/etc/ssl/ca-bundle.pem" \
        "/etc/pki/tls/cacert.pem" \
        "/etc/ssl/certs/ca-certificates.crt"

    for cert_file do
        if [ -f "$cert_file" ]; then
            REPLICATED_TRUSTED_CERT_MOUNT="-v ${cert_file}:/etc/ssl/certs/ca-certificates.crt"
            break
        fi
    done

    if [ -n "$REPLICATED_OPTS" ]; then
        REPLICATED_OPTS=$(echo "$REPLICATED_OPTS" | sed -e 's/-e[[:blank:]]*HTTP_PROXY=[^[:blank:]]*//g')
        if [ -n "$PROXY_ADDRESS" ]; then
            REPLICATED_OPTS="$REPLICATED_OPTS -e HTTP_PROXY=$PROXY_ADDRESS"
        fi
        REPLICATED_OPTS=$(echo "$REPLICATED_OPTS" | sed -e 's/-e[[:blank:]]*NO_PROXY=[^[:blank:]]*//g')
        if [ -n "$NO_PROXY_ADDRESSES" ]; then
           REPLICATED_OPTS="$REPLICATED_OPTS -e NO_PROXY=$NO_PROXY_ADDRESSES"
        fi
        REPLICATED_OPTS=$(echo "$REPLICATED_OPTS" | sed -e 's/-e[[:blank:]]*REGISTRY_ADVERTISE_ADDRESS=[^[:blank:]]*//g')
        if [ -n "$REGISTRY_ADVERTISE_ADDRESS" ]; then
            REPLICATED_OPTS="$REPLICATED_OPTS -e REGISTRY_ADVERTISE_ADDRESS=$REGISTRY_ADVERTISE_ADDRESS"
        fi
        REPLICATED_OPTS=$(echo "$REPLICATED_OPTS" | sed -e 's/-e[[:blank:]]*DISABLE_HOST_NETWORKING=[^[:blank:]]*//g')
        if [ "$DISABLE_REPLICATED_HOST_NETWORKING" = "1" ]; then
            REPLICATED_OPTS="$REPLICATED_OPTS -e DISABLE_HOST_NETWORKING=true"
        fi
        return
    fi

    REPLICATED_OPTS=""





    if [ -n "$PROXY_ADDRESS" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e HTTP_PROXY=$PROXY_ADDRESS -e NO_PROXY=$NO_PROXY_ADDRESSES"
    fi
    if [ -n "$REGISTRY_ADVERTISE_ADDRESS" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e REGISTRY_ADVERTISE_ADDRESS=$REGISTRY_ADVERTISE_ADDRESS"
    fi
    if [ "$SKIP_OPERATOR_INSTALL" != "1" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e DAEMON_TOKEN=$DAEMON_TOKEN"
    fi
    if [ -n "$LOG_LEVEL" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e LOG_LEVEL=$LOG_LEVEL"
    else
        REPLICATED_OPTS="$REPLICATED_OPTS -e LOG_LEVEL=info"
    fi
    if [ "$AIRGAP" = "1" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e AIRGAP=true"
    fi
    if [ -n "$RELEASE_SEQUENCE" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e RELEASE_SEQUENCE=$RELEASE_SEQUENCE"
    fi
    if [ -n "$RELEASE_PATCH_SEQUENCE" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e RELEASE_PATCH_SEQUENCE=$RELEASE_PATCH_SEQUENCE"
    fi
    if [ "$CUSTOM_SELINUX_REPLICATED_DOMAIN" = "1" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e SELINUX_REPLICATED_DOMAIN=$SELINUX_REPLICATED_DOMAIN"
    fi

    find_hostname
    REPLICATED_OPTS="$REPLICATED_OPTS -e NODENAME=$SYS_HOSTNAME"

    REPLICATED_UI_OPTS=""
    if [ -n "$LOG_LEVEL" ]; then
        REPLICATED_UI_OPTS="$REPLICATED_UI_OPTS -e LOG_LEVEL=$LOG_LEVEL"
    fi

    dockerGetLoggingDriver
    if [ "$DOCKER_LOGGING_DRIVER" = "json-file" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS --log-opt max-size=50m --log-opt max-file=3"
        REPLICATED_UI_OPTS="$REPLICATED_UI_OPTS --log-opt max-size=50m --log-opt max-file=3"
    fi

    if [ "$DISABLE_REPLICATED_HOST_NETWORKING" = "1" ]; then
        REPLICATED_OPTS="$REPLICATED_OPTS -e DISABLE_HOST_NETWORKING=true"
    fi
}

write_replicated_configuration() {
    cat > $CONFDIR/replicated <<-EOF
RELEASE_CHANNEL=stable
PRIVATE_ADDRESS=$PRIVATE_ADDRESS
SKIP_OPERATOR_INSTALL=$SKIP_OPERATOR_INSTALL
REPLICATED_OPTS="$REPLICATED_OPTS"
REPLICATED_UI_OPTS="$REPLICATED_UI_OPTS"
EOF
}

write_systemd_services() {
    cat > /etc/systemd/system/replicated.service <<-EOF
[Unit]
Description=Replicated Service
After=docker.service
Requires=docker.service

[Service]
PermissionsStartOnly=true
TimeoutStartSec=0
KillMode=none
EnvironmentFile=${CONFDIR}/replicated
User=${REPLICATED_USER_ID}
Group=${DOCKER_GROUP_ID}
ExecStartPre=-/usr/bin/docker rm -f replicated
ExecStartPre=/bin/mkdir -p /var/run/replicated /var/lib/replicated /var/lib/replicated/statsd 
ExecStartPre=/bin/chown -R ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} /var/run/replicated /var/lib/replicated 
ExecStartPre=-/bin/chmod -R 755 /var/lib/replicated/tmp
ExecStart=/usr/bin/docker run --name=replicated \\
    ${REPLICATED_PORT_RANGE} \\
    -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
    -v /var/lib/replicated:/var/lib/replicated \\
    -v /var/run/docker.sock:/host/var/run/docker.sock \\
    -v /proc:/host/proc:ro \\
    -v /etc:/host/etc:ro \\
    -v /etc/os-release:/host/etc/os-release:ro \\
    ${REPLICATED_TRUSTED_CERT_MOUNT} \\
    -v /var/run/replicated:/var/run/replicated \\
    --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
    -e LOCAL_ADDRESS=\${PRIVATE_ADDRESS} \\
    -e RELEASE_CHANNEL=\${RELEASE_CHANNEL} \\
    \$REPLICATED_OPTS \\
    ${REPLICATED_REGISTRY_PREFIX}/replicated:current
ExecStop=/usr/bin/docker stop replicated
Restart=on-failure
RestartSec=7

[Install]
WantedBy=docker.service
EOF

    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        cat > /etc/systemd/system/replicated-ui.service <<-EOF
[Unit]
Description=Replicated Service
After=docker.service
Requires=docker.service

[Service]
PermissionsStartOnly=true
TimeoutStartSec=0
KillMode=none
EnvironmentFile=${CONFDIR}/replicated
User=${REPLICATED_USER_ID}
Group=${DOCKER_GROUP_ID}
ExecStartPre=-/usr/bin/docker rm -f replicated-ui
ExecStartPre=/bin/mkdir -p /var/run/replicated
ExecStartPre=/bin/chown -R ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} /var/run/replicated
ExecStart=/usr/bin/docker run --name=replicated-ui \\
    -p ${UI_BIND_PORT}:8800/tcp \\
    -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
    -v /var/run/replicated:/var/run/replicated \\
    --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
    \$REPLICATED_UI_OPTS \\
    ${REPLICATED_REGISTRY_PREFIX}/replicated-ui:current
ExecStop=/usr/bin/docker stop replicated-ui
Restart=on-failure
RestartSec=7

[Install]
WantedBy=docker.service
EOF
    fi

    systemctl daemon-reload
}

write_upstart_services() {
    REPLICATED_RESTART_POLICY=
    # NOTE: SysVinit does not support dependencies therefore we must add a
    # restart policy to the replicated service. The tradeoff here is that
    # SysVinit will lose track of the replicated process when docker restarts
    # the replicated service.
    if ! ls /etc/init/docker* 1> /dev/null 2>&1; then
        REPLICATED_RESTART_POLICY="--restart always"
    fi

    cat > /etc/init/replicated.conf <<-EOF
description "Replicated Service"
author "Replicated.com"
start on replicated-docker or started docker
stop on runlevel [!2345] or stopping docker
respawn
respawn limit 5 30
normal exit 0
pre-start script
    /bin/mkdir -p /var/run/replicated /var/lib/replicated /var/lib/replicated/statsd 
    /bin/chown -R ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} /var/run/replicated /var/lib/replicated 
    /bin/chmod -R 755 /var/lib/replicated/tmp 2>/dev/null || true
    /usr/bin/docker rm -f replicated 2>/dev/null || true
    COUNTER=0
    while \$(/usr/bin/docker ps -a | grep --quiet "replicated:current") && [ \$COUNTER -lt 3 ]; do
        #Try removing the container again, but don't suppress output this time
        /usr/bin/docker rm -f replicated || true
        sleep 1
        COUNTER=\$((\$COUNTER+1))
    done
end script
script
    . ${CONFDIR}/replicated
    exec su -s /bin/sh -c 'exec "\$0" "\$@"' ${REPLICATED_USERNAME} -- /usr/bin/docker run --name=replicated \\
        ${REPLICATED_RESTART_POLICY} \\
        ${REPLICATED_PORT_RANGE} \\
        -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
        -v /var/lib/replicated:/var/lib/replicated \\
        -v /var/run/docker.sock:/host/var/run/docker.sock \\
        -v /proc:/host/proc:ro \\
        -v /etc:/host/etc:ro \\
        -v /etc/os-release:/host/etc/os-release:ro \\
        ${REPLICATED_TRUSTED_CERT_MOUNT} \\
        -v /var/run/replicated:/var/run/replicated \\
        --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
        -e LOCAL_ADDRESS=\${PRIVATE_ADDRESS} \\
        -e RELEASE_CHANNEL=\${RELEASE_CHANNEL} \\
        \$REPLICATED_OPTS \\
        ${REPLICATED_REGISTRY_PREFIX}/replicated:current
end script
EOF
    cat > /etc/init/replicated-stop.conf <<-EOF
description "Replicated shutdown script"
author "Replicated.com"
start on stopping replicated
kill timeout 30
script
    exec /usr/bin/docker stop replicated
end script
EOF

    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        cat > /etc/init/replicated-ui.conf <<-EOF
description "Replicated UI Service"
author "Replicated.com"
start on replicated-docker or started docker
stop on runlevel [!2345] or stopping docker
respawn
respawn limit 5 30
normal exit 0
pre-start script
    /bin/mkdir -p /var/run/replicated
    /bin/chown -R ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} /var/run/replicated
    /usr/bin/docker rm -f replicated-ui 2>/dev/null || true
    COUNTER=0
    while \$(/usr/bin/docker ps -a | grep --quiet "replicated-ui:current") && [ \$COUNTER -lt 3 ]; do
        #Try removing the container again, but don't suppress output this time
        /usr/bin/docker rm -f replicated-ui || true
        sleep 1
        COUNTER=\$((\$COUNTER+1))
    done
end script
script
    . ${CONFDIR}/replicated
    exec su -s /bin/sh -c 'exec "\$0" "\$@"' ${REPLICATED_USERNAME} -- /usr/bin/docker run --name=replicated-ui \\
        ${REPLICATED_RESTART_POLICY} \\
        -p ${UI_BIND_PORT}:8800/tcp \\
        -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
        -v /var/run/replicated:/var/run/replicated \\
        --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
        \$REPLICATED_UI_OPTS \\
        ${REPLICATED_REGISTRY_PREFIX}/replicated-ui:current
end script
EOF
        cat > /etc/init/replicated-ui-stop.conf <<-EOF
description "Replicated UI shutdown script"
author "Replicated.com"
start on stopping replicated-ui
kill timeout 30
script
    exec /usr/bin/docker stop replicated-ui
end script
EOF
    fi
}

write_sysvinit_services() {
    cat > /etc/init.d/replicated <<-EOF
#!/bin/bash
set -e

### BEGIN INIT INFO
# Provides:          replicated
# Required-Start:    docker
# Required-Stop:     docker
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Replicated
# Description:       Replicated Service
### END INIT INFO

REPLICATED=replicated
DOCKER=/usr/bin/docker
DEFAULTS=${CONFDIR}/replicated

[ -r "\${DEFAULTS}" ] && . "\${DEFAULTS}"
[ -r "/lib/lsb/init-functions" ] && . "/lib/lsb/init-functions"
[ -r "/etc/rc.d/init.d/functions" ] && . "/etc/rc.d/init.d/functions"

if [ ! -x \${DOCKER} ]; then
    echo -n >&2 "\${DOCKER} not present or not executable"
    exit 1
fi

run_container() {
    /bin/mkdir -p /var/run/replicated /var/lib/replicated /var/lib/replicated/statsd 
    /bin/chown -R ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} /var/run/replicated /var/lib/replicated 
    /bin/chmod -R 755 /var/lib/replicated/tmp 2>/dev/null || true
    /usr/bin/docker rm -f replicated 2>/dev/null || true
    exec su -s /bin/sh -c 'exec "\$0" "\$@"' ${REPLICATED_USERNAME} -- \${DOCKER} run -d --name=\${REPLICATED} \\
        ${REPLICATED_PORT_RANGE} \\
        -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
        -v /var/lib/replicated:/var/lib/replicated \\
        -v /var/run/docker.sock:/host/var/run/docker.sock \\
        -v /proc:/host/proc:ro \\
        -v /etc:/host/etc:ro \\
        -v /etc/os-release:/host/etc/os-release:ro \\
        ${REPLICATED_TRUSTED_CERT_MOUNT} \\
        -v /var/run/replicated:/var/run/replicated \\
        --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
        -e LOCAL_ADDRESS=\${PRIVATE_ADDRESS} \\
        -e RELEASE_CHANNEL=\${RELEASE_CHANNEL} \\
        \$REPLICATED_OPTS \\
        ${REPLICATED_REGISTRY_PREFIX}/replicated:current
}

stop_container() {
    \${DOCKER} stop \${REPLICATED}
}

remove_container() {
    \${DOCKER} rm -f \${REPLICATED}
}

_status() {
	if type status_of_proc | grep -i function > /dev/null; then
	    status_of_proc "\${REPLICATED}" && exit 0 || exit \$?
	elif type status | grep -i function > /dev/null; then
		status "\${REPLICATED}" && exit 0 || exit \$?
	else
		exit 1
	fi
}

case "\$1" in
    start)
        echo -n "Starting \${REPLICATED} service: "
        remove_container 2>/dev/null || true
        run_container
        ;;
    stop)
        echo -n "Shutting down \${REPLICATED} service: "
        stop_container
        ;;
    status)
        _status
        ;;
    restart|reload)
        pid=`pidofproc "\${REPLICATED}" 2>/dev/null`
        [ -n "\$pid" ] && ps -p \$pid > /dev/null 2>&1 \\
            && \$0 stop
        \$0 start
        ;;
    *)
        echo "Usage: \${REPLICATED} {start|stop|status|reload|restart"
        exit 1
        ;;
esac
EOF
    chmod +x /etc/init.d/replicated

    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        cat > /etc/init.d/replicated-ui <<-EOF
#!/bin/bash
set -e

### BEGIN INIT INFO
# Provides:          replicated-ui
# Required-Start:    docker
# Required-Stop:     docker
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Replicated UI
# Description:       Replicated UI Service
### END INIT INFO

REPLICATED_UI=replicated-ui
DOCKER=/usr/bin/docker
DEFAULTS=${CONFDIR}/replicated

[ -r "\${DEFAULTS}" ] && . "\${DEFAULTS}"
[ -r "/lib/lsb/init-functions" ] && . "/lib/lsb/init-functions"
[ -r "/etc/rc.d/init.d/functions" ] && . "/etc/rc.d/init.d/functions"

if [ ! -x \${DOCKER} ]; then
    echo -n >&2 "\${DOCKER} not present or not executable"
    exit 1
fi

run_container() {
    exec su -s /bin/sh -c 'exec "\$0" "\$@"' ${REPLICATED_USERNAME} -- \${DOCKER} run -d --name=\${REPLICATED_UI} \\
        -p ${UI_BIND_PORT}:8800/tcp \\
        -u ${REPLICATED_USER_ID}:${DOCKER_GROUP_ID} \\
        -v /var/run/replicated:/var/run/replicated \\
        --security-opt ${SELINUX_REPLICATED_DOMAIN_LABEL} \\
        \$REPLICATED_UI_OPTS \\
        ${REPLICATED_REGISTRY_PREFIX}/replicated-ui:current
}

stop_container() {
    \${DOCKER} stop \${REPLICATED_UI}
}

remove_container() {
    \${DOCKER} rm -f \${REPLICATED_UI}
}

_status() {
	if type status_of_proc | grep -i function > /dev/null; then
	    status_of_proc "\${REPLICATED_UI}" && exit 0 || exit \$?
	elif type status | grep -i function > /dev/null; then
		status "\${REPLICATED_UI}" && exit 0 || exit \$?
	else
		exit 1
	fi
}

case "\$1" in
    start)
        echo -n "Starting \${REPLICATED_UI} service: "
        remove_container 2>/dev/null || true
        run_container
        ;;
    stop)
        echo -n "Shutting down \${REPLICATED_UI} service: "
        stop_container
        ;;
    status)
        _status
        ;;
    restart|reload)
        pid=`pidofproc "\${REPLICATED_UI}" 2>/dev/null`
        [ -n "\$pid" ] && ps -p \$pid > /dev/null 2>&1 \\
            && \$0 stop
        \$0 start
        ;;
    *)
        echo "Usage: \${REPLICATED_UI} {start|stop|status|reload|restart"
        exit 1
        ;;
esac
EOF
        chmod +x /etc/init.d/replicated-ui
    fi
}

stop_systemd_services() {
    if systemctl status replicated &>/dev/null; then
        systemctl stop replicated
    fi
    if systemctl status replicated-ui &>/dev/null; then
        systemctl stop replicated-ui
    fi
}

start_systemd_services() {
    systemctl enable replicated
    systemctl start replicated

    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        systemctl enable replicated-ui
        systemctl start replicated-ui
    fi
}

stop_upstart_services() {
    if status replicated &>/dev/null && ! status replicated 2>/dev/null | grep -q "stop"; then
        stop replicated
    fi
    if status replicated-ui &>/dev/null && ! status replicated-ui 2>/dev/null | grep -q "stop"; then
        stop replicated-ui
    fi
}

start_upstart_services() {
    start replicated
    start replicated-ui
}

stop_sysvinit_services() {
    if service replicated status &>/dev/null; then
        service replicated stop
    fi
    if service replicated-ui status &>/dev/null; then
        service replicated-ui stop
    fi
}

start_sysvinit_services() {
    # TODO: what about chkconfig
    update-rc.d replicated stop 20 0 1 6 . start 20 2 3 4 5 .
    update-rc.d replicated enable
    service replicated start

    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        update-rc.d replicated-ui stop 20 0 1 6 . start 20 2 3 4 5 .
        update-rc.d replicated-ui enable
        service replicated-ui start
    fi
}

install_operator() {
    prefix=""
    if [ "$AIRGAP" != "1" ]; then
        getUrlCmd
        echo -e "${GREEN}Installing local operator with command:"
        echo -e "${URLGET_CMD} https://get.replicated.com${prefix}/operator?replicated_operator_tag=2.51.0${NC}"
        ${URLGET_CMD} "https://get.replicated.com${prefix}/operator?replicated_operator_tag=2.51.0" > /tmp/operator_install.sh
    fi
    _private_address_with_brackets="$PRIVATE_ADDRESS"
    if [ "$DISABLE_REPLICATED_HOST_NETWORKING" = "1" ]; then
        _private_address_with_brackets="$DOCKER0_GATEWAY_IP"
    fi
    if isValidIpv6 "$_private_address_with_brackets"; then
        _private_address_with_brackets="[$_private_address_with_brackets]"
    fi
    opts="no-docker skip-preflights daemon-endpoint=$_private_address_with_brackets:9879 daemon-token=$DAEMON_TOKEN private-address=$PRIVATE_ADDRESS tags=$OPERATOR_TAGS"
    if [ -n "$PUBLIC_ADDRESS" ]; then
        opts=$opts" public-address=$PUBLIC_ADDRESS"
    elif [ "$NO_PUBLIC_ADDRESS" = "1" ]; then
        opts=$opts" no-public-address"
    fi
    if [ -n "$PROXY_ADDRESS" ]; then
        opts=$opts" http-proxy=$PROXY_ADDRESS additional-no-proxy=$NO_PROXY_ADDRESSES"
    else
        opts=$opts" no-proxy"
    fi
    if [ -z "$READ_TIMEOUT" ]; then
        opts=$opts" no-auto"
    fi
    if [ "$AIRGAP" = "1" ]; then
        opts=$opts" airgap"
    fi
    if [ "$SKIP_DOCKER_PULL" = "1" ]; then
        opts=$opts" skip-pull"
    fi
    if [ -n "$LOG_LEVEL" ]; then
        opts=$opts" log-level=$LOG_LEVEL"
    fi
    if [ "$CUSTOM_SELINUX_REPLICATED_DOMAIN" = "1" ]; then
        opts=$opts" selinux-replicated-domain=$SELINUX_REPLICATED_DOMAIN"
    fi
    if [ -n "$FAST_TIMEOUTS" ]; then
        opts=$opts" fast-timeouts"
    fi
    if [ -n "$NO_CE_ON_EE" ]; then
        opts=$opts" no-ce-on-ee"
    fi
    if [ "$BYPASS_FIREWALLD_WARNING" = "1" ]; then
        opts=$opts" bypass-firewalld-warning"
    fi
    if [ -n "$REGISTRY_ADDRESS_OVERRIDE" ]; then
        opts=$opts" registry-address-override=$REGISTRY_ADDRESS_OVERRIDE"
    fi
    if [ -n "$REGISTRY_PATH_PREFIX" ]; then
        opts=$opts" registry-path-prefix=$REGISTRY_PATH_PREFIX"
    fi
    if [ "$DISABLE_REPLICATED_HOST_NETWORKING" = "1" ]; then
        # we still bind the registry to the host network
        opts=$opts" daemon-registry-address=$DOCKER0_GATEWAY_IP:9874"
    fi

    # When this script is piped into bash as stdin, apt-get will eat the remaining parts of this script,
    # preventing it from being executed.  So using /dev/null here to change stdin for the docker script.
    if [ "$AIRGAP" = "1" ]; then
        bash ./operator_install.sh $opts < /dev/null
    else
        bash -x /tmp/operator_install.sh $opts < /dev/null
    fi
}

outro() {
    warn_if_selinux
    if [ "$DISABLE_REPLICATED_UI" != "1" ]; then
        if [ -z "$PUBLIC_ADDRESS" ]; then
            PUBLIC_ADDRESS="<this_server_address>"
        fi
        printf "To continue the installation, visit the following URL in your browser:\n\n  http://%s:$UI_BIND_PORT\n" "$PUBLIC_ADDRESS"
    fi
    if ! commandExists "replicated"; then
        printf "\nTo create an alias for the replicated cli command run the following in your current shell or log out and log back in:\n\n  source /etc/replicated.alias\n"
    fi
    printf "\n"
}


################################################################################
# Execution starts here
################################################################################

if replicated12Installed; then
    echo -e >&2 "${RED}Existing 1.2 install detected; please back up and run migration script before installing.${NC}"
    echo -e >&2 "${RED}Instructions at https://help.replicated.com/docs/native/customer-installations/upgrading/${NC}"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

require64Bit
requireRootUser
detectLsbDist
detectInitSystem
detectInitSystemConfDir
getReplicatedRegistryPrefix "$REPLICATED_VERSION"

mkdir -p /var/lib/replicated/branding
if [ -n "$CHANNEL_CSS" ]; then
    echo "$CHANNEL_CSS" | base64 --decode > /var/lib/replicated/branding/channel.css
fi
if [ -n "$TERMS" ]; then
    echo "$TERMS" | base64 --decode > /var/lib/replicated/branding/terms.json
fi

# read existing replicated opts values
if [ -f $CONFDIR/replicated ]; then
    # shellcheck source=replicated-default
    . $CONFDIR/replicated
fi
if [ -f $CONFDIR/replicated-operator ]; then
    # support for the old installation script that used REPLICATED_OPTS for
    # operator
    tmp_replicated_opts="$REPLICATED_OPTS"
    # shellcheck source=replicated-operator-default
    . $CONFDIR/replicated-operator
    REPLICATED_OPTS="$tmp_replicated_opts"
fi

# override these values with command line flags
while [ "$1" != "" ]; do
    _param="$(echo "$1" | cut -d= -f1)"
    _value="$(echo "$1" | grep '=' | cut -d= -f2-)"
    case $_param in
        http-proxy|http_proxy)
            PROXY_ADDRESS="$_value"
            ;;
        local-address|local_address|private-address|private_address)
            PRIVATE_ADDRESS="$_value"
            NO_PRIVATE_ADDRESS_PROMPT="1"
            ;;
        public-address|public_address)
            PUBLIC_ADDRESS="$_value"
            ;;
        no-public-address|no_public_address)
            NO_PUBLIC_ADDRESS=1
            ;;
        no-operator|no_operator)
            SKIP_OPERATOR_INSTALL=1
            ;;
        is-migration|is_migration)
            IS_MIGRATION=1
            ;;
        no-docker|no_docker)
            SKIP_DOCKER_INSTALL=1
            ;;
        install-docker-only|install_docker_only)
            ONLY_INSTALL_DOCKER=1
            ;;
        no-proxy|no_proxy)
            NO_PROXY=1
            ;;
        airgap)
            # airgap implies "skip docker"
            AIRGAP=1
            SKIP_DOCKER_INSTALL=1
            ;;
        no-auto|no_auto)
            READ_TIMEOUT=
            ;;
        daemon-token|daemon_token)
            DAEMON_TOKEN="$_value"
            ;;
        tags)
            OPERATOR_TAGS="$_value"
            ;;
        docker-version|docker_version)
            PINNED_DOCKER_VERSION="$_value"
            ;;
        ui-bind-port|ui_bind_port)
            UI_BIND_PORT="$_value"
            ;;
        registry-advertise-address|registry_advertise_address)
            REGISTRY_ADVERTISE_ADDRESS="$_value"
            ;;
        release-sequence|release_sequence)
            RELEASE_SEQUENCE="$_value"
            ;;
        release-patch-sequence|release_patch_sequence)
            RELEASE_PATCH_SEQUENCE="$_value"
            ;;
        skip-pull|skip_pull)
            SKIP_DOCKER_PULL=1
            ;;
        bypass-storagedriver-warnings|bypass_storagedriver_warnings)
            BYPASS_STORAGEDRIVER_WARNINGS=1
            ;;
        log-level|log_level)
            LOG_LEVEL="$_value"
            ;;
        selinux-replicated-domain|selinux_replicated_domain)
            SELINUX_REPLICATED_DOMAIN="$_value"
            ;;
        fast-timeouts|fast_timeouts)
            READ_TIMEOUT="-t 1"
            FAST_TIMEOUTS=1
            ;;
        force-replicated-downgrade|force_replicated_downgrade)
            FORCE_REPLICATED_DOWNGRADE=1
            ;;
        skip-preflights|skip_preflights)
            SKIP_PREFLIGHTS=1
            ;;
        prompt-on-preflight-warnings|prompt_on_preflight_warnings)
            IGNORE_PREFLIGHTS=0
            ;;
        ignore-preflights|ignore_preflights)
            # do nothing
            ;;
        no-ce-on-ee|no_ce_on_ee)
            NO_CE_ON_EE=1
            ;;
        hard-fail-on-loopback|hard_fail_on_loopback)
            HARD_FAIL_ON_LOOPBACK=1
            ;;
        bypass-firewalld-warning|bypass_firewalld_warning)
            BYPASS_FIREWALLD_WARNING=1
            ;;
        hard-fail-on-firewalld|hard_fail_on_firewalld)
            HARD_FAIL_ON_FIREWALLD=1
            ;;
        additional-no-proxy|additional_no_proxy)
            if [ -z "$ADDITIONAL_NO_PROXY" ]; then
                ADDITIONAL_NO_PROXY="$_value"
            else
                ADDITIONAL_NO_PROXY="$ADDITIONAL_NO_PROXY,$_value"
            fi
            ;;
        artifactory-address|artifactory_address)
            ARTIFACTORY_ADDRESS="$_value"
            ;;
        artifactory-access-method|artifactory_access_method)
            ARTIFACTORY_ACCESS_METHOD="$_value"
            ;;
        artifactory-docker-repo-key|artifactory_docker_repo_key)
            ARTIFACTORY_DOCKER_REPO_KEY="$_value"
            ;;
        artifactory-quay-repo-key|artifactory_quay_repo_key)
            ARTIFACTORY_QUAY_REPO_KEY="$_value"
            ;;
        artifactory-auth)
            ARTIFACTORY_AUTH="$_value"
            ;;
        registry-address-override|registry_address_override)
            REGISTRY_ADDRESS_OVERRIDE="$_value"
            ;;
        registry-path-prefix|registry_path_prefix)
            REGISTRY_PATH_PREFIX="$_value"
            ;;
        disable-replicated-ui|disable_replicated_ui)
            DISABLE_REPLICATED_UI=1
            ;;
        disable-replicated-host-networking|disable_replicated_host_networking)
            # DISABLE_REPLICATED_HOST_NETWORKING supported in replicated 2.49.0+
            DISABLE_REPLICATED_HOST_NETWORKING=1
            ;;
        *)
            echo >&2 "Error: unknown parameter \"$_param\""
            exit 1
            ;;
    esac
    shift
done

if [ "$FORCE_REPLICATED_DOWNGRADE" != "1" ] && isReplicatedDowngrade "$REPLICATED_VERSION"; then
    replicated2Version
    echo -e >&2 "${RED}Current Replicated version $INSTALLED_REPLICATED_VERSION is greater than the proposed version $REPLICATED_VERSION.${NC}"
    echo -e >&2 "${RED}To downgrade Replicated re-run the script with the force-replicated-downgrade flag.${NC}"
    exit 1
fi

checkFirewalld

if [ "$ONLY_INSTALL_DOCKER" = "1" ]; then
    # no min if only installing docker
    installDocker "$PINNED_DOCKER_VERSION" "0.0.0"

    checkDockerDriver
    checkDockerStorageDriver "$HARD_FAIL_ON_LOOPBACK"
    exit 0
fi

printf "Determining local address\n"
discoverPrivateIp

if [ -z "$PUBLIC_ADDRESS" ] && [ "$AIRGAP" != "1" ] && [ "$NO_PUBLIC_ADDRESS" != "1" ]; then
    printf "Determining service address\n"
    discoverPublicIp

    # check that we will eventually run the operator install script
    if [ "$SKIP_OPERATOR_INSTALL" != "1" ] && [ "$IS_MIGRATION" != "1" ]; then
        # Even though this script does not use PUBLIC_ADDRESS, we must prompt prior to replicated
        # operator installation to minimize the delay between starting replicated and the operator for
        # automated installs. If the operator takes too long to start then the app start will fail.
        readReplicatedOperatorOpts "PUBLIC_ADDRESS"
        if [ -z "$PUBLIC_ADDRESS" ]; then
            PUBLIC_ADDRESS="$REPLICATED_OPTS_VALUE"
        fi
        # Check that the public address from discoverPublicIp matches the one from Replicated Operator opts
        if [ -n "$REPLICATED_OPTS_VALUE" ] && [ "$REPLICATED_OPTS_VALUE" = "$PUBLIC_ADDRESS" ]; then
            printf "The installer will use service address '%s' (imported from $CONFDIR/replicated-operator 'PUBLIC_ADDRESS')\n" $PUBLIC_ADDRESS
        else
            if [ -n "$PUBLIC_ADDRESS" ]; then
                # If public addresses do not match then prompt with confirmation
                shouldUsePublicIp
            else
                printf "The installer was unable to automatically detect the service IP address of this machine.\n"
                printf "Please enter the address or leave blank for unspecified.\n"
                promptForPublicIp
                if [ -z "$PUBLIC_ADDRESS" ]; then
                    NO_PUBLIC_ADDRESS=1
                fi
            fi
        fi
    fi
fi

maybePromptForArtifactoryAuth
configureRegistryProxyAddressOverride
maybeWriteRegistryProxyConfig

if [ "$NO_PROXY" != "1" ]; then
    if [ -z "$PROXY_ADDRESS" ]; then
        discoverProxy
    fi

    if [ -z "$PROXY_ADDRESS" ] && [ "$AIRGAP" != "1" ]; then
        promptForProxy
    fi

    if [ -n "$PROXY_ADDRESS" ]; then
        getNoProxyAddresses "$PRIVATE_ADDRESS"
    fi
fi

exportProxy

if [ "$SKIP_DOCKER_INSTALL" != "1" ]; then
    installDocker "$PINNED_DOCKER_VERSION" "$MIN_DOCKER_VERSION"

    checkDockerDriver
    checkDockerStorageDriver "$HARD_FAIL_ON_LOOPBACK"
else
    requireDocker
fi

get_docker0_gateway_ip

if [ -n "$PROXY_ADDRESS" ]; then
    requireDockerProxy
fi

if [ "$CONFIGURE_IPV6" = "1" ] && [ "$DID_INSTALL_DOCKER" = "1" ]; then
    configure_docker_ipv6
fi

if [ "$RESTART_DOCKER" = "1" ]; then
    restartDocker
fi

if [ -n "$PROXY_ADDRESS" ]; then
    checkDockerProxyConfig
fi

if [ "$SKIP_PREFLIGHTS" != "1" ]; then
    echo ""
    echo "Running preflight checks..."
    runPreflights || true
    if [ "$IGNORE_PREFLIGHTS" != "1" ]; then
        if [ "$HAS_PREFLIGHT_ERRORS" = "1" ]; then
            bail "\nPreflights have encountered some errors. Please correct them before proceeding."
        elif [ "$HAS_PREFLIGHT_WARNINGS" = "1" ]; then
            logWarn "\nPreflights have encountered some warnings. Please review them before proceeding."
            logWarn "Would you like to proceed anyway?"
            if ! confirmN " "; then
                exit 1
                return
            fi
        fi
    fi
fi

if [ -n "$ARTIFACTORY_ADDRESS" ] && [ -n "$ARTIFACTORY_AUTH" ]; then
    parseBasicAuth "$ARTIFACTORY_AUTH"
    echo "+ docker login $ARTIFACTORY_ADDRESS --username $BASICAUTH_USERNAME"
    echo "$BASICAUTH_PASSWORD" | docker login "$ARTIFACTORY_ADDRESS" --username "$BASICAUTH_USERNAME" --password-stdin
fi

detectDockerGroupId
maybeCreateReplicatedUser

get_daemon_token

if [ "$SKIP_DOCKER_PULL" = "1" ]; then
    printf "Skip docker pull flag detected, will not pull replicated and replicated-ui images\n"
elif [ "$AIRGAP" != "1" ]; then
    printf "Pulling replicated and replicated-ui images\n"
    pullReplicatedImages
else
    printf "Loading replicated and replicated-ui images from package\n"
    airgapLoadReplicatedImages
    printf "Loading replicated debian, command, statsd-graphite, and premkit images from package\n"
    airgapLoadSupportImages

    airgapMaybeLoadSupportBundle
    airgapMaybeLoadRetraced
fi

tag_docker_images

printf "Stopping replicated and replicated-ui service\n"
case "$INIT_SYSTEM" in
    systemd)
        stop_systemd_services
        ;;
    upstart)
        stop_upstart_services
        ;;
    sysvinit)
        stop_sysvinit_services
        ;;
esac
remove_docker_containers

printf "Installing replicated and replicated-ui service\n"

REPLICATED_PORT_RANGE="-p 9874-9879:9874-9879/tcp"
if [ "$DISABLE_REPLICATED_HOST_NETWORKING" = "1" ]; then
    if [ -z "$REGISTRY_ADVERTISE_ADDRESS" ]; then
        REGISTRY_ADVERTISE_ADDRESS="$DOCKER0_GATEWAY_IP:9874"
    fi
    REPLICATED_PORT_RANGE="-p $DOCKER0_GATEWAY_IP:9874-9879:9874-9879/tcp"
fi

get_selinux_replicated_domain
get_selinux_replicated_domain_label
build_replicated_opts
write_replicated_configuration

case "$INIT_SYSTEM" in
    systemd)
        write_systemd_services
        ;;
    upstart)
        write_upstart_services
        ;;
    sysvinit)
        write_sysvinit_services
        ;;
esac

printf "Starting replicated and replicated-ui service\n"
case "$INIT_SYSTEM" in
    systemd)
        start_systemd_services
        ;;
    upstart)
        start_upstart_services
        ;;
    sysvinit)
        start_sysvinit_services
        ;;
esac

printf "Installing replicated command alias\n"
installCliFile "sudo docker exec" "replicated"
installAliasFile

if [ "$SKIP_OPERATOR_INSTALL" != "1" ] && [ "$IS_MIGRATION" != "1" ]; then
    # we write this value to the opts file so if you didn't install it the first
    # time it will not install when updating
    printf "Installing local operator\n"
    install_operator
fi

outro
exit 0