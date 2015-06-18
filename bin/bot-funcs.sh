#!/usr/bin/env bash

## Global Settings ##

# Oolite window size
WIN_WIDTH=727
WIN_HEIGHT=682

# Ship's compass screen location
COMPASS_WIDTH=34
COMPASS_HEIGHT=34
COMPASS_X=497
COMPASS_Y=629

# Crosshair position to center on station/planet
TARGET_MIN_X=15
TARGET_MIN_Y=13

# Station Indicator screen location
STATION_IND_WIDTH=32
STATION_IND_HEIGHT=32
STATION_IND_X=198
STATION_IND_Y=632

# Ag planet X/Y
AG_PLANET_X=422
AG_PLANET_Y=242

# Industrial planet X/Y
IND_PLANET_X=303
IND_PLANET_Y=325

# Keystroke delay in ms
KEYDELAY=80

# Find and initialize the Oolite window
function init_oolite_window() {
    find_oolite_window

    # Resize the window so we have consistent coords
    xdotool windowsize $WID $WIN_WIDTH $WIN_HEIGHT

    # Store the window name (title) for later use
    WIN_NAME=$(xdotool getwindowname $WID)
}

function pause_shell() {
    read -p "$*"
    xdotool windowactivate --sync $WID
}

function wait_for() {
    xdotool sleep $1
}

function left_click() {
    xdotool mousedown 1
    wait_for 0.5
    xdotool mouseup 1
}

function send_key() {
    xdotool key --delay $KEYDELAY "$@"
}

function key_press() {
    xdotool keydown --delay $KEYDELAY $1
    wait_for $2
    xdotool keyup --delay $KEYDELAY $1
}

function pitch_up() {
    key_press Down $1
}

function pitch_down() {
    key_press Up $1
}

function rotate_ccw() {
    key_press Left $1
}

function rotate_cw() {
    key_press Right $1
}

function yaw_left() {
    key_press comma $1
}

function yaw_right() {
    key_press period $1
}

function launch() {
    send_key F1
    wait_for 2
}

function dock() {
    send_key shift+c
    wait_for 4
}

function fire_injectors() {
    key_press i $1
}

function jump() {
    send_key j
}

function enter_hyper() {
    send_key h

    # Wait for 20 seconds for the ship to hyper and recover
    wait_for 20
}

function goto_status() {
    send_key 5
}

function goto_market() {
    send_key 8
}

function goto_system_nav() {
    # Make sure we don't go to the galactic chart by
    # going to the market screen first.
    goto_market
    send_key 6
}

function quick_save() {
    send_key 2
    send_key Return
}

function refuel() {
    send_key 3
    send_key Return
}

function buy_furs() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down Down Down Down
    send_key Return
}

function sell_furs() {
    buy_furs
}

function buy_computers() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down
    send_key Return
}

function sell_computers() {
    buy_computers
}

function mark_xexedi() {
    goto_system_nav
    xdotool mousemove --window $WID $IND_PLANET_X $IND_PLANET_Y
    left_click
}

function mark_xeoner() {
    goto_system_nav
    xdotool mousemove --window $WID $AG_PLANET_X $AG_PLANET_Y
    left_click
}

# Find the Oolite window and store the ID
function find_oolite_window() {
    WID=$(xdotool search --name "Oolite v1.80" | head -1)
}

#
# Screen capture functions
#

function capture_snapshot() {
    # Store the args in named vars
    local width=$1
    local height=$2
    local originX=$3
    local originY=$4

    local cropStr="${width}x${height}+${originX}+${originY}"

    # Capture a snapshot of the window
    xwd -name "$WIN_NAME" -silent | convert xwd:- -depth 8 -crop $cropStr txt:-
}

function capture_compass() {
    capture_snapshot $COMPASS_WIDTH $COMPASS_HEIGHT $COMPASS_X $COMPASS_Y
}

function find_pixel() {
    capture_compass | grep -m1 $1
}

function to_coords() {
    eval $(echo $1 | awk 'BEGIN { FS="[,:]" }; { printf("curX=%d\ncurY=%d\n", $1, $2) }')
}

function set_crosshair_coords() {
    local greenEnough='#[0-5][0-5]F[5-9|A-F][0-5][0-5]'
    local line=$(find_pixel $greenEnough)
    to_coords $line
}

function vert_align_with_station() {
    local delay=.1

    # Don't bother with alignment if station is in range
    is_station_in_range
    if [ $? -eq 0 ]; then
        return
    fi

    set_crosshair_coords
    until [ $curY -le $TARGET_MIN_Y ]; do
        pitch_down 0.05
        wait_for $delay
        set_crosshair_coords
    done

    if [ $curY -lt $TARGET_MIN_Y ]; then
        until [ $curY -ge $TARGET_MIN_Y ]; do
            pitch_up 0.05
            wait_for $delay
            set_crosshair_coords
        done
    fi
}

function horz_align_with_station() {
    local delay=.1

    # Don't bother with alignment if station is in range
    is_station_in_range
    if [ $? -eq 0 ]; then
        return
    fi

    set_crosshair_coords
    until [ $curX -le $TARGET_MIN_X ]; do
        yaw_right 0.01
        wait_for $delay
        set_crosshair_coords
    done

    if [ $curX -lt $TARGET_MIN_X ]; then
        until [ $curX -ge $TARGET_MIN_X ]; do
            yaw_left 0.01
            wait_for $delay
            set_crosshair_coords
        done
    fi
}

function capture_station_indicator() {
    capture_snapshot $STATION_IND_WIDTH $STATION_IND_HEIGHT $STATION_IND_X $STATION_IND_Y
}

function find_station_pixel() {
    capture_station_indicator | grep -m1 $1
}

function set_station_ind_coords() {
    local greenEnough='#[[:digit:]][[:digit:]][6-9|A-F][0-9|A-F][[:digit:]][[:digit:]]'
    local line=$(find_station_pixel $greenEnough)
    to_coords $line
}

function is_station_in_range() {
    set_station_ind_coords

    if [ $curX -eq 7 ] && [ $curY -eq 2 ]; then
        return 0
    fi
    return 1
}

function navigate_to_station() {
    is_station_in_range

    while [ $? -eq 1 ]; do
        wait_for 1
        vert_align_with_station
        wait_for 1
        horz_align_with_station

        is_station_in_range
    done

    dock
}

