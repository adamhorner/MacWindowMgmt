#!/usr/bin/osascript
-- vim: filetype=applescript

-- Takes two arguments, x and y, then moves the frontmost window to that
--   screen location

on run(argv)
    set {_newx, _newy} to {item 1, item 2} of argv
    tell application "System Events"
        set _frontMostApp to first item of (processes whose frontmost is true)
        -- special case for Google Chrome where we need the second window
        if (name of _frontMostApp) = "Google Chrome" then
            set _frontWindow to second window of _frontMostApp
        else
            set _frontWindow to first window of _frontMostApp
        end if
        set position of _frontWindow to {_newx, _newy}
    end tell
end run
