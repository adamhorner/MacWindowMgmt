#!/usr/bin/osascript
-- vim: filetype=applescript

-- This script prints the X, Y, Width, Height of the frontmost window

tell application "System Events"
    set _frontMostApp to first item of (processes whose frontmost is true)
    -- special case for Google Chrome where we need the second window
    if (name of _frontMostApp) = "Google Chrome" then
        set _frontWindow to second window of _frontMostApp
    else
        set _frontWindow to first window of _frontMostApp
    end if
    set _position to position of _frontWindow
    set {_x, _y} to {item 1, item 2} of _position
    set _size to size of _frontWindow
    set {_width, _height} to {item 1, item 2} of _size
end tell

set AppleScript's text item delimiters to " "
return {_x, _y, _width, _height} as string
