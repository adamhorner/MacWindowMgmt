#!/bin/bash
# vim: foldmethod=marker foldcolumn=5
#
# A script to work out where to move a window to snap it to a screen edge.
# Should work on OS X Mavericks, even with multiple screens. Uses hmscreens
# (specifically this version: https://bitbucket.org/adamhorner/hmscreens)
# NOTE THAT THIS RELIES ON FEATURES IN BASH v3.2+
#
# Definition of an owning screen is based on where the centre of the window is.
# If no screen seems to own the window, then move it to the appropriate edge
# on the main screen (screen 0).

# TODO: change the parameter parsing so that it can multiple parameters instead
# of one single concatenated parameter, this would allow arbitrary ordering

#DEBUG_MODE=1

if [[ "${DEBUG_MODE}" ]]; then
    set -xv
    # list of debug levels for which output is created
    declare -r DEBUG="ERROR WARNING INFO DEBUG"
else
    declare -r DEBUG="ERROR WARNING"
fi

# Constants #{{{
declare -r ME=$(basename "$0")
declare -r SCREENS="./hmscreens -info"
declare -r IDENTITY_STRING='Screen ID: '
declare -r POSITION_STRING='Global Position: '
declare -r SIZE_STRING='Display Size: '
# list of valid possible window locations
declare -r LOCATIONS="TOP BOTTOM RIGHT LEFT CENTER NEXT"
# the height of the Apple Menu Bar
declare -r MENU_BAR_HEIGHT=22
# How close to the edge of the monitor do we consider being at the edge?
declare -r EDGE_BUFFER=15
# These get set read-only later on
declare WINDOW_X
declare WINDOW_Y
declare WINDOW_WIDTH
declare WINDOW_HEIGHT
# }}}

# Variables #{{{
declare SCREENSRESULT
declare WINDOW_LOC
declare -i SCREEN_COUNT=-1
declare -i -a SCREEN_ID
declare -i -a SCREEN_LEFT
declare -i -a SCREEN_TOP
declare -i -a SCREEN_WIDTH
declare -i -a SCREEN_HEIGHT
declare -i -a SCREEN_RIGHT
declare -i -a SCREEN_BOTTOM
declare -i -a SCREEN_CENTER_X
declare -i -a SCREEN_CENTER_Y
declare -i WINDOW_CENTRE_X
declare -i WINDOW_CENTRE_Y
declare -i NEW_X
declare -i NEW_Y
# deliberately not an integer so it can be null (unset)
declare ACTIVE_SCREEN
# }}}

shopt -s nocasematch

# Functions #{{{

# function to echo to stderr
echoerr() {
    echo "$@" >&2;
}

# function to print usage instructions
usage() {
    echoerr "USAGE: ${ME} <LOC> [<LOC> ...]"
    echoerr " ${ME} provides co-ordinates to move a window to the desired edge"
    echoerr "    of the current monitor, tested on Mavericks (OS X 10.9) only"
    echoerr " <LOC>: one or more of the desired location of the window, from:"
    echoerr "    ${LOCATIONS}"
    echoerr " OUTPUT: NEWX NEWY"
}

debug() {
    local LEVEL="${1}"
    shift
    if [[ "${LEVEL}" == "ERROR" ]]; then
        echo "$@"
    elif [[ "${DEBUG}" =~ "${LEVEL}" ]]; then
        echoerr -e "${LEVEL}:\t${ME}#${FUNCNAME[1]}:\t$@"
    fi
}

# function to check integer value, prints usage and exits on failure
assertInt() {
    # $1: name of value
    # $2: value to check
    # $3: YES for positive integers only
    local ERRMSG
    if [[ "$2" =~ ^[-+]?[0-9]+$ ]]; then
        # value is an integer
        if [[ "$3" == "YES" ]]; then
            if [[ "$2" -ge 0 ]]; then
                # value is a positive integer
                debug DEBUG "$1 (value $2) is a positive integer"
                return 0
            else
                ERRMSG="$ME: $1 must be a positive integer "
                ERRMSG+="(unable to parse \"$2\")"
            fi
        else
            # valid integer
            debug DEBUG "$1 (value $2) is a valid integer"
            return 0
        fi
    else
        ERRMSG="$ME: $1 must be a valid integer (unable to parse \"$2\")"
    fi
    # valid results have already returned by now, we have an error
    debug ERROR "${ERRMSG}"
    usage
    exit 2
}

# function to add a parameter to the desired window location
addWindowLocation() {
    # $1: parameter to add to the window locations variable
    if [[ "${LOCATIONS}" =~ $1 ]]; then
        WINDOW_LOC="${WINDOW_LOC}$1"
        debug DEBUG "Added $1 to WINDOW_LOC"
    else
        debug ERROR "Invalid location ($1)"
        usage
        exit 2
    fi
}

# End of functions #}}}

# Main execution #{{{

debug DEBUG "Parameters($#): $@"

# get the location of the front-most window
read WINDOW_X WINDOW_Y WINDOW_WIDTH WINDOW_HEIGHT <<< $(./printWindowXYWH.scpt)
# set the window variables to constants
declare -r WINDOW_X WINDOW_Y WINDOW_WIDTH WINDOW_HEIGHT

# parameter validation #{{{

# Check number of parameters
if [[ $# -lt 1 ]]; then
    debug ERROR "parameter(s) required"
    usage
    exit 2
fi

# Check Variable values
assertInt "X" "${WINDOW_X}"
assertInt "Y" "${WINDOW_Y}"
assertInt "W" "${WINDOW_WIDTH}" "YES"
assertInt "H" "${WINDOW_HEIGHT}" "YES"
while [[ $# -gt 0 ]]; do
    if [[ "$1" =~ " " ]]; then
        for word in $1; do
            addWindowLocation ${word}
        done
    else
        addWindowLocation $1
    fi
    shift
done
debug INFO "Location to be set to ${WINDOW_LOC}"

# parameters are all good #}}}

WINDOW_CENTRE_X=$((${WINDOW_X} + ${WINDOW_WIDTH}/2))
WINDOW_CENTRE_Y=$((${WINDOW_Y} + ${WINDOW_HEIGHT}/2))

debug INFO "Window centre is at ${WINDOW_CENTRE_X}, ${WINDOW_CENTRE_Y}"

# loop to find the screen dimensions #{{{
# Note that this uses a variety of bash's text wrangling, see 'man bash'
while read SCREENLINE; do
    if [ "${SCREENLINE:0:${#IDENTITY_STRING}}" = "${IDENTITY_STRING}" ]; then
        # Found a new screen, increase count, store ID
        SCREEN_COUNT+=1
        SCREEN_ID[${SCREEN_COUNT}]=${SCREENLINE#${IDENTITY_STRING}}
    fi
    if [ "${SCREENLINE:0:${#POSITION_STRING}}" = "${POSITION_STRING}" ]; then
        # Store the position of this screen
        POS=${SCREENLINE#${POSITION_STRING}}
        SCREEN_LEFT[${SCREEN_COUNT}]=${POS/,*/}
        SCREEN_TOP[${SCREEN_COUNT}]=${POS/*, /}
    fi
    if [ "${SCREENLINE:0:${#SIZE_STRING}}" = "${SIZE_STRING}" ]; then
        # Store the size of this screen
        SIZE=${SCREENLINE#${SIZE_STRING}}
        SCREEN_WIDTH[${SCREEN_COUNT}]=${SIZE/,*/}
        SCREEN_HEIGHT[${SCREEN_COUNT}]=${SIZE/*, /}
    fi
done < <(${SCREENS})
# end get screen dimensions #}}}

# loop to print screen stats and window location #{{{
for ((i=0;i<=${SCREEN_COUNT};i++)); do
    # SCREENINFO is of form ID:X:Y:WIDTH:HEIGHT
    SCREENINFO="Screen $i - ${SCREEN_ID[$i]}:${SCREEN_LEFT[$i]}"
    SCREENINFO+=":${SCREEN_TOP[$i]}:${SCREEN_WIDTH[$i]}:${SCREEN_HEIGHT[$i]}"
    debug INFO "${SCREENINFO}"
    SCREEN_RIGHT[$i]=$((${SCREEN_LEFT[$i]}+${SCREEN_WIDTH[$i]}))
    SCREEN_BOTTOM[$i]=$((${SCREEN_TOP[$i]}+${SCREEN_HEIGHT[$i]}))
    SCREEN_CENTER_X[$i]=$((${SCREEN_LEFT[$i]}+${SCREEN_WIDTH[$i]}/2))
    SCREEN_CENTER_Y[$i]=$((${SCREEN_TOP[$i]}+${SCREEN_HEIGHT[$i]}/2))
    # Test if this screen is the active screen for the window
    if [ $(( \
        ${WINDOW_CENTRE_X} >= ${SCREEN_LEFT[$i]} && \
        ${WINDOW_CENTRE_X} <= $((${SCREEN_LEFT[$i]}+${SCREEN_WIDTH[$i]})) && \
        ${WINDOW_CENTRE_Y} >= ${SCREEN_TOP[$i]} && \
        ${WINDOW_CENTRE_Y} <= $((${SCREEN_TOP[$i]}+${SCREEN_HEIGHT[$i]})) \
        )) == 1 ]; then
        debug DEBUG "Window is on screen $i"
        ACTIVE_SCREEN=$i
    fi
done # find active screen loop #}}}

if [[ -z "${ACTIVE_SCREEN}" ]]; then
    debug WARNING "Window is not on a screen, putting it on main display"
    echo "SETTING TO ZERO ZERO"
    ACTIVE_SCREEN=0
    NEW_X=0
    NEW_Y=0
else
    NEW_X="${WINDOW_X}"
    NEW_Y="${WINDOW_Y}"
fi

# work out where to move the window to #{{{
NEW_LOC="${WINDOW_LOC}"
if [[ "${NEW_LOC}" =~ "NEXT" ]]; then
    if [[ "${NEW_LOC}" == "NEXT" ]]; then
        # if no other position is specified, try and be clever about location
        TOPOFFSET=$((${WINDOW_Y}-${SCREEN_TOP[${ACTIVE_SCREEN}]}-${MENU_BAR_HEIGHT}))
        BOTTOMOFFSET=$((${WINDOW_Y}+${WINDOW_HEIGHT}-${SCREEN_BOTTOM[${ACTIVE_SCREEN}]}))
        LEFTOFFSET=$((${WINDOW_X}-${SCREEN_LEFT[${ACTIVE_SCREEN}]}))
        RIGHTOFFSET=$((${WINDOW_X}+${WINDOW_WIDTH}-${SCREEN_RIGHT[${ACTIVE_SCREEN}]}))
        debug DEBUG "Window offsets calculated as (${TOPOFFSET}, ${BOTTOMOFFSET}, ${LEFTOFFSET}, ${RIGHTOFFSET})"
        if [[ ${TOPOFFSET} -gt -${EDGE_BUFFER} && ${TOPOFFSET} -lt ${EDGE_BUFFER} ]]; then
            NEW_LOC="TOP"
        elif [[ ${BOTTOMOFFSET} -gt -${EDGE_BUFFER} && ${BOTTOMOFFSET} -lt ${EDGE_BUFFER} ]]; then
            NEW_LOC="BOTTOM"
        else
            NEW_LOC="CENTER"
        fi
        if [[ ${LEFTOFFSET} -gt -${EDGE_BUFFER} && ${LEFTOFFSET} -lt ${EDGE_BUFFER} ]]; then
            NEW_LOC+="LEFT"
        elif [[ ${RIGHTOFFSET} -gt -${EDGE_BUFFER} && ${RIGHTOFFSET} -lt ${EDGE_BUFFER} ]]; then
            NEW_LOC+="RIGHT"
        elif [[ "${NEW_LOC}" != "CENTER" ]]; then
            NEW_LOC+="CENTER"
        fi
        debug DEBUG "NEW_LOC set to ${NEW_LOC}"
    fi
    # move window to the next screen
    ACTIVE_SCREEN+=1
    if [[ ${ACTIVE_SCREEN} -gt ${SCREEN_COUNT} ]]; then
        ACTIVE_SCREEN=0
    fi
fi
if [[ "${NEW_LOC}" =~ "CENTER" ]]; then
    NEW_X=$((${SCREEN_CENTER_X[${ACTIVE_SCREEN}]}-${WINDOW_WIDTH}/2))
    NEW_Y=$((${SCREEN_CENTER_Y[${ACTIVE_SCREEN}]}-${WINDOW_HEIGHT}/2))
fi
if [[ "${NEW_LOC}" =~ "LEFT" ]]; then
    NEW_X=${SCREEN_LEFT[${ACTIVE_SCREEN}]}
fi
if [[ "${NEW_LOC}" =~ "TOP" ]]; then
    NEW_Y=$((${SCREEN_TOP[${ACTIVE_SCREEN}]}+${MENU_BAR_HEIGHT}))
fi
if [[ "${NEW_LOC}" =~ "RIGHT" ]]; then
    NEW_X=$((${SCREEN_RIGHT[${ACTIVE_SCREEN}]}-${WINDOW_WIDTH}))
fi
if [[ "${NEW_LOC}" =~ "BOTTOM" ]]; then
    NEW_Y=$((${SCREEN_BOTTOM[${ACTIVE_SCREEN}]}-${WINDOW_HEIGHT}))
fi
# end of calculations #}}}

# move the front-most window
./moveWindow.scpt "${NEW_X}" "${NEW_Y}"

# End #}}}
