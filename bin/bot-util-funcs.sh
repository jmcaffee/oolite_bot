#!/usr/bin/env bash

source bot-funcs.sh

# Oolite utility functions
#

#
# Write a screen capture image to a file.
# The file extension determines the file format.
# Some supported extensions:
#   png
#   jpg
#   txt
#
# Args:
#   width
#   height
#   origin x
#   origin y
#   filename
#
write_snapshot() {
    # Store the args in named vars
    local width=$1
    local height=$2
    local originX=$3
    local originY=$4
    local fname=$5

    local cropStr="${width}x${height}+${originX}+${originY}"

    # Capture a snapshot of the window
    xwd -name "$WIN_NAME" -silent | convert xwd:- -depth 8 -crop $cropStr $fname
}

#
# Dump all market images to a directory
#
# Args:
#   dir to save to (or nothing)
#       If dir is provided, it must end with slash: some/dir/
#
dump_market_images() {
    local saveTo=$1
    # Delay to give the image write time to complete
    local delay=1.0

    goto_status
    goto_market
    send_key Down
    cap_to_img $ITEM_X $FOOD_Y ${saveTo}food.png
    wait_for $delay
    send_key Up
    cap_to_img $ITEM_X $TEXTILES_Y ${saveTo}textiles.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $RADIOACTIVES_Y ${saveTo}radioactives.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $SLAVES_Y ${saveTo}slaves.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $LIQUOR_Y ${saveTo}liquor.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $LUXURIES_Y ${saveTo}luxuries.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $NARCOTICS_Y ${saveTo}narcotics.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $COMPUTERS_Y ${saveTo}computers.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $MACHINERY_Y ${saveTo}machinery.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $ALLOYS_Y ${saveTo}alloys.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $FIREARMS_Y ${saveTo}firearms.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $FURS_Y ${saveTo}furs.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $MINERALS_Y ${saveTo}minerals.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $GOLD_Y ${saveTo}gold.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $PLATINUM_Y ${saveTo}platinum.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $GEMSTONES_Y ${saveTo}gemstones.png
    wait_for $delay
    send_key Down
    cap_to_img $ITEM_X $ALIENITEMS_Y ${saveTo}alienitems.png
}

#
# Display the current mouse coordinates
#
# Displayed as:
#   absoluteX absoluteY (relativeX relativeY)
#
display_mouse_coords() {
    if [ -z $startX ] || [ -z $startY ]; then
        move_mouse_to_relative 0 0
        store_mouse_location
        startX=$X
        startY=$Y
        oldX=$startX
        oldY=$startY
    fi

    store_mouse_location
    let relx=X-startX
    let rely=Y-startY

    if [[ $oldX != $X ]] || [[ $oldY != $Y ]]; then
        echo "$X $Y ($relx $rely)"
        oldX=$X
        oldY=$Y
    fi
}

