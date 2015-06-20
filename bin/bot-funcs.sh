#!/usr/bin/env bash

#
## Global Settings ##
#

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

# Ag planet details
AG_PLANET_NAME=Xeoner
AG_PLANET_X=422
AG_PLANET_Y=242

# Industrial planet details
IND_PLANET_NAME=Xexedi
IND_PLANET_X=303
IND_PLANET_Y=325

# Keystroke delay in ms
KEYDELAY=80

# Width and height of 'in hold' market items
IN_HOLD_W=25
IN_HOLD_H=18

# Origin of first item (food) on market screen
ITEM_X=551
ITEM_Y=130

# Origin of items on market screen. Because the height is actually
# somewhere between 18 and 19 pixels, the starting point of some
# items is incremented by 1 occasionally.
FOOD_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
TEXTILES_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
RADIOACTIVES_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
SLAVES_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
LIQUOR_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H + 1))
LUXURIES_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
NARCOTICS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
COMPUTERS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
MACHINERY_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
ALLOYS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
FIREARMS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H + 1))
FURS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
MINERALS_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
GOLD_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
PLATINUM_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H))
GEMSTONES_Y=$ITEM_Y
((ITEM_Y += IN_HOLD_H + 1))
ALIENITEMS_Y=$ITEM_Y

#
## Functions ##
#

# Find and initialize the Oolite window
init_oolite_window() {
    find_oolite_window

    if [ -z $WID ]; then
        echo 'Oolite window not found'
        echo 'Please start Oolite and try again'
        exit 1
    fi

    # Resize the window so we have consistent coords
    xdotool windowsize $WID $WIN_WIDTH $WIN_HEIGHT

    # Store the window name (title) for later use
    WIN_NAME=$(xdotool getwindowname $WID)
}

# Find the Oolite window and store the ID
find_oolite_window() {
    WID=$(xdotool search --name "Oolite v1.80" | head -1)
}

focus_oolite_window() {
    xdotool windowactivate --sync $WID
}

pause_shell() {
    read -p "$*"
    focus_oolite_window
}

wait_for() {
    xdotool sleep $1
}

## Mouse and keyboard I/O

left_click() {
    xdotool mousedown 1
    wait_for 0.5
    xdotool mouseup 1
}

store_mouse_location() {
    eval $(xdotool getmouselocation --shell)
    mouseX=$X
    mouseY=$Y
}

restore_mouse_location() {
    xdotool mousemove $mouseX $mouseY
}

send_key() {
    xdotool key --delay $KEYDELAY "$@"
}

key_press() {
    xdotool keydown --delay $KEYDELAY $1
    wait_for $2
    xdotool keyup --delay $KEYDELAY $1
}

## Screen capture functions

capture_snapshot() {
    # Store the args in named vars
    local width=$1
    local height=$2
    local originX=$3
    local originY=$4

    local cropStr="${width}x${height}+${originX}+${originY}"

    # Capture a snapshot of the window
    xwd -name "$WIN_NAME" -silent | convert xwd:- -depth 8 -crop $cropStr txt:-
}

capture_compass() {
    capture_snapshot $COMPASS_WIDTH $COMPASS_HEIGHT $COMPASS_X $COMPASS_Y
}

find_pixel() {
    capture_compass | grep -m1 $1
}

to_coords() {
    eval $(echo $1 | awk 'BEGIN { FS="[,:]" }; { printf("curX=%d\ncurY=%d\n", $1, $2) }')
}

set_crosshair_coords() {
    local greenEnough='#[0-5][0-5]F[5-9|A-F][0-5][0-5]'
    local line=$(find_pixel $greenEnough)
    to_coords $line
}

capture_station_indicator() {
    capture_snapshot $STATION_IND_WIDTH $STATION_IND_HEIGHT $STATION_IND_X $STATION_IND_Y
}

find_station_pixel() {
    capture_station_indicator | grep -m1 $1
}

set_station_ind_coords() {
    local greenEnough='#[[:digit:]][[:digit:]][6-9|A-F][0-9|A-F][[:digit:]][[:digit:]]'
    local line=$(find_station_pixel $greenEnough)
    to_coords $line
}

is_station_in_range() {
    set_station_ind_coords

    if [ $curX -eq 7 ] && [ $curY -eq 2 ]; then
        return 0
    fi
    return 1
}

## Cargo state functions

#
# Generate and store SHAs of the current 'in hold' cargo state for each item
#
get_current_cargo_state() {
    goto_status
    goto_market

    foodSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $FOOD_Y | sha256sum)
    textilesSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $TEXTILES_Y | sha256sum)
    radioactivesSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $RADIOACTIVES_Y | sha256sum)
    slavesSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $SLAVES_Y | sha256sum)
    liquorSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $LIQUOR_Y | sha256sum)
    luxuriesSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $LUXURIES_Y | sha256sum)
    narcoticsSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $NARCOTICS_Y | sha256sum)
    computersSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $COMPUTERS_Y | sha256sum)
    machinerySHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $MACHINERY_Y | sha256sum)
    alloysSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $ALLOYS_Y | sha256sum)
    firearmsSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $FIREARMS_Y | sha256sum)
    fursSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $FURS_Y | sha256sum)
    mineralsSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $MINERALS_Y | sha256sum)
    goldSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $GOLD_Y | sha256sum)
    platinumSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $PLATINUM_Y | sha256sum)
    gemstonesSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $GEMSTONES_Y | sha256sum)
    alienitemsSHA=$(capture_snapshot $IN_HOLD_W $IN_HOLD_H $ITEM_X $ALIENITEMS_Y | sha256sum)
}

#
# Store SHAs of 'in hold' state images for later comparison
#
store_empty_cargo_state() {
    get_current_cargo_state

    foodSHAEmpty=$foodSHA
    textilesSHAEmpty=$textilesSHA
    radioactivesSHAEmpty=$radioactivesSHA
    slavesSHAEmpty=$slavesSHA
    liquorSHAEmpty=$liquorSHA
    luxuriesSHAEmpty=$luxuriesSHA
    narcoticsSHAEmpty=$narcoticsSHA
    computersSHAEmpty=$computersSHA
    machinerySHAEmpty=$machinerySHA
    alloysSHAEmpty=$alloysSHA
    firearmsSHAEmpty=$firearmsSHA
    fursSHAEmpty=$fursSHA
    mineralsSHAEmpty=$mineralsSHA
    goldSHAEmpty=$goldSHA
    platinumSHAEmpty=$platinumSHA
    gemstonesSHAEmpty=$gemstonesSHA
    alienitemsSHAEmpty=$alienitemsSHA
}

#
# Return 0 if cargo is in hold, 1 otherwise
# Arg: name of item to test for (ie. "food")
# Ex:
#   if cargo_hold_contains "food"; then
#       do true
#   else
#       do false
#   fi
#
cargo_hold_contains() {
    local item=$1
    # Store the NAME of a variable containing the empty item SHA
    local emptyItemVar="${item}SHAEmpty"
    # Store the NAME of a variable containing the current item SHA
    local currItemVar="${item}SHA"
    # Get the SHA from the value of the variable named emptyItemVar
    local emptyItem=${!emptyItemVar}
    # Get the SHA from the value of the variable named currItemVar
    local currItem=${!currItemVar}

    if [[ $emptyItem == $currItem ]]; then
        return 1 # false
    else
        return 0 # true
    fi
}

## Game controls

pitch_up() {
    key_press Down $1
}

pitch_down() {
    key_press Up $1
}

rotate_ccw() {
    key_press Left $1
}

rotate_cw() {
    key_press Right $1
}

yaw_left() {
    key_press comma $1
}

yaw_right() {
    key_press period $1
}

launch() {
    send_key F1
    wait_for 2
}

dock() {
    send_key shift+c
    wait_for 4
}

fire_injectors() {
    key_press i $1
}

jump() {
    send_key j
}

enter_hyper() {
    send_key h

    # Wait for 20 seconds for the ship to hyper and recover
    wait_for 20
}

quick_save() {
    send_key 2
    send_key Return
}

refuel() {
    send_key 3
    send_key Return
}

## Game screens

goto_status() {
    send_key 5
}

goto_system_nav() {
    # Make sure we don't go to the galactic chart by
    # going to the market screen first.
    goto_market
    send_key 6
}

goto_market() {
    send_key 8
}

## Market actions

buy_food() {
    goto_status
    goto_market
    send_key Return
}

sell_food() {
    if cargo_hold_contains "food"; then
        buy_food
    fi
}

buy_textiles() {
    goto_status
    goto_market
    send_key Down
    send_key Return
}

sell_textiles() {
    if cargo_hold_contains "textiles"; then
        buy_textiles
    fi
}

buy_radioactives() {
    goto_status
    goto_market
    send_key Down Down
    send_key Return
}

sell_radioactives() {
    if cargo_hold_contains "radioactives"; then
        buy_radioactives
    fi
}

buy_liquor() {
    goto_status
    goto_market
    send_key Down Down Down Down
    send_key Return
}

sell_liquor() {
    if cargo_hold_contains "liquor"; then
        buy_liquor
    fi
}

buy_luxuries() {
    goto_status
    goto_market
    send_key Down Down Down Down Down
    send_key Return
}

sell_luxuries() {
    if cargo_hold_contains "luxuries"; then
        buy_luxuries
    fi
}

buy_computers() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down
    send_key Return
}

sell_computers() {
    if cargo_hold_contains "computers"; then
        buy_computers
    fi
}

buy_machinery() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down
    send_key Return
}

sell_machinery() {
    if cargo_hold_contains "machinery"; then
        buy_machinery
    fi
}

buy_alloys() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down Down
    send_key Return
}

sell_alloys() {
    if cargo_hold_contains "alloys"; then
        buy_alloys
    fi
}

buy_furs() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down Down Down Down
    send_key Return
}

sell_furs() {
    if cargo_hold_contains "furs"; then
        buy_furs
    fi
}

buy_minerals() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down Down Down Down Down
    send_key Return
}

sell_minerals() {
    if cargo_hold_contains "minerals"; then
        buy_minerals
    fi
}

buy_platinum() {
    goto_status
    goto_market
    send_key Down Down Down Down Down Down Down Down Down Down Down Down Down Down
    send_key Return
}

sell_platinum() {
    if cargo_hold_contains "platinum"; then
        buy_platinum
    fi
}


## Navigation actions

mark_ind() {
    # Save the current mouse location
    store_mouse_location

    goto_system_nav
    xdotool mousemove --window $WID $IND_PLANET_X $IND_PLANET_Y
    left_click

    # Restore the mouse location
    restore_mouse_location
}

mark_ag() {
    # Save the current mouse location
    store_mouse_location

    goto_system_nav
    xdotool mousemove --window $WID $AG_PLANET_X $AG_PLANET_Y
    left_click

    # Restore the mouse location
    restore_mouse_location
}

## Automated flight

vert_align_with_station() {
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

horz_align_with_station() {
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

navigate_to_station() {
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

