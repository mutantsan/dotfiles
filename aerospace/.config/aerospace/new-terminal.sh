#!/bin/bash

# Open a new iTerm window on the current workspace.
# on-window-detected sends every iTerm window to T, so move the new one back here.
app=com.googlecode.iterm2
ws=$(aerospace list-workspaces --focused)
before=$(aerospace list-windows --monitor all --app-bundle-id $app --format '%{window-id}')

if pgrep -xq iTerm2; then
    osascript -e 'tell application "iTerm2" to create window with default profile'
else
    open -a iTerm
fi

for _ in $(seq 50); do
    for id in $(aerospace list-windows --monitor all --app-bundle-id $app --format '%{window-id}'); do
        if ! grep -qx "$id" <<<"$before"; then
            aerospace move-node-to-workspace --window-id "$id" --focus-follows-window "$ws"
            exit
        fi
    done
    sleep 0.1
done
