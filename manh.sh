#!/bin/bash
# Name  : manh.sh
# Author: R.J.Toscani
# Date  : 30-8-2023
# Description:
# Open man-page in no-snap Firefox browser (alternative for bash-functies 'hman' or 'man --html=firefox')
# Default source: (internal) man-page from own Ubuntu-installation (= system).
# With options for various (external) alternative man-page sources on the Internet. To be extendible as desired.
# Finds pages if existent at chosen source, even if command in question is not present on own system.
# Outputs via Links or Lynx browser to terminal if opted for.
# Alias 'manh' points to this program.
# Known bug:
# If snap-Firefox is active simultaneously, "pkill firefox" may be necessary if FF hangs after 2nd call.
#
##################################################################################################
#
# Copyright (C) 2024 Rob Toscani <rob_toscani@yahoo.com>
#
# perpetualcalendar3a.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# perpetualcalendar3a.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
######################################################################################
#

helptext(){
    while read "line"; do
        echo "$line" >&2
    done << EOF
Usage:
manh [-cdDhHlLmMu] name

   -h     Help (this output)
   -l     Open output in Links instead of Firefox
   -L     Open output in Lynx instead of Firefox

   -c     Open man page via https://man.cx/
   -d     Open man page via https://linux.die.net
   -D     Open man page via https://manpages.debian.org
   -H     Open man page via man.he.net/
   -m     Open man page via https://man7.org/linux/man-pages/
   -M     Open man page via https://manpages.org
   -u     Open man page via https://manpages.ubuntu.com/

EOF
}


getpage(){
    release=$(lsb_release -a 2>/dev/null | grep Codename | awk '{ print $2 }')
    htmlfile="/tmp/ramdisk/$1$2.html"
    case $mansource in
        man.cx)	              htmlfile="https://man.cx/$1($2)"
                              ;;
        man.he.net)           htmlfile="man.he.net/man$2/$1"
                              ;;
        linux.die.net)        htmlfile="https://linux.die.net/man/$2/$1"
                              ;;
        manpages.debian.org)  htmlfile="https://manpages.debian.org/testing/$1/$1.$2.html"
                              ;;
        man7.org)             htmlfile="https://man7.org/linux/man-pages/man$2/$1.$2.html"
                              ;;
        manpages.org)         htmlfile="https://manpages.org/$1/$2"
                              ;;
        manpages.ubuntu.com)  htmlfile="https://manpages.ubuntu.com/manpages/$release/en/man$2/$1.$2.html"
                              ;;
        system)               man2html $manfile >| $htmlfile 2>/dev/null
                              ;;
    esac
    if lynx -dump $htmlfile | grep -qi description; then
        clear
        if [[ $target == firefox ]]; then
            /usr/bin/firefox $htmlfile &
        elif [[ $target == links ]]; then
            links $htmlfile
        else   # (if the target is: lynx)
            lynx $htmlfile
        fi
        exit 0
    else
        return 1
    fi
}


# No snap Firefox (/usr/bin/firefox), omdat lokale files anders niet worden geopend:
target="firefox"
mansource="system"

while getopts "cdDhHlLmMu" OPTION; do
    case $OPTION in
        c) mansource="man.cx"
           ;;
        d) mansource="linux.die.net"
           ;;
        D) mansource="manpages.debian.org"
           ;;
        h) helptext
           exit 0
           ;;
        H) mansource="man.he.net"
           ;;
        l) target="links"
           ;;
        L) target="lynx"
           ;;
        m) mansource="man7.org"
           ;;
        M) mansource="manpages.org"
           ;;
        u) mansource="manpages.ubuntu.com"
           ;;
        *) helptext
           exit 1
           ;;
    esac
done

firstnonopt=$OPTIND
command=${!firstnonopt}         # Het eerste niet-optie argument

([ "$#" -lt 1 ] || [ $command == "." ]) && helptext && exit 1

# manfiles="$(whereis $command | sed 's/ /\n/g' | grep \/man\/.*\.gz$)"
manfiles="$(whereis -M /usr/share/man/* /usr/local/share/man/* -f $command | sed 's/ /\n/g' | grep \/man\/)"
quantity=$(echo "$manfiles" | wc -l)

if [ -z "$manfiles" ]; then
    quantity=0
    [[ $mansource == system ]] &&
    echo -e "\nCommand '$command' doesn't exist on this system. Use options for other sources.\n" >&2 &&
    exit 1
fi

if (( quantity > 1 )); then
    echo "$manfiles"
    while true; do
        read -p "Enter volume number: " volume
        ([ -z "$volume" ] || [ "$volume" == "." ]) && exit 1
        manfile="$(echo -e "$manfiles" | grep \/man$volume\/)"
        if [[ -z $manfile ]]; then
            echo "Volume "$volume" doesn't exist on this system ..." >&2
            continue
        else
            break
        fi
    done
    getpage $command $volume
    echo -e "\nCouldn't find man page for '$command($volume)' on "$mansource".\n" >&2

elif (( quantity == 0 )); then
    echo "Looking for man page ..." >&2
    for volume in {1..9}; do
        getpage $command $volume
    done
    echo -e "\nCouldn't find man page for '$command' in any volume on "$mansource".\n" >&2

else  # (if the quantity is: 1)
    manfile=$manfiles
    volume=$(awk 'BEGIN { FS = "." } { print $2 }' <<< "$manfiles")
    getpage $command $volume
    echo -e "\nCouldn't find man page for '$command($volume)' on "$mansource".\n" >&2
fi
