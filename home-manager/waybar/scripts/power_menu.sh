#!/usr/bin/env bash

CHOICE=$(echo -e " Shutdown\n Reboot\n Lock\n Suspend\n Logout" | rofi -dmenu -p "Power Menu")

case $CHOICE in
    " Shutdown")
        systemctl poweroff
        ;;
    " Reboot")
        systemctl reboot
        ;;
    " Lock")
        swaylock
        ;;
    " Suspend")
        systemctl suspend
        ;;
    " Logout")
        hyprctl dispatch exit 1 
        ;;
    *)
        exit 0
        ;;
esac
