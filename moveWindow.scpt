#!/usr/bin/osascript
-- vim: filetype=applescript

-- Takes two arguments, x and y, then moves the frontmost window to that
--   screen location

on run(argv)
    set {_newx, _newy} to {item 1, item 2} of argv
    tell application "System Events"
        set _frontMostApp to first item of (processes whose frontmost is true)
        set _frontWindow to first window of _frontMostApp
        set position of _frontWindow to {_newx, _newy}
    end tell
end run
