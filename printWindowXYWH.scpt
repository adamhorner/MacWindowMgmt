#!/usr/bin/osascript
-- vim: filetype=applescript

-- This script prints the X, Y, Width, Height of the frontmost window

tell application "System Events"
    set _frontMostApp to first item of (processes whose frontmost is true)
    set {_position, _size} to {position, size} of first window of _frontMostApp
    set {_x, _y} to {item 1, item 2} of _position
    set {_width, _height} to {item 1, item 2} of _size
end tell

set AppleScript's text item delimiters to " "
return {_x, _y, _width, _height} as string
