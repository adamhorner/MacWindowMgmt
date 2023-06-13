# Mac Window Management for Alfred

This project helps with window management on a mac, leveraging the power of the
[Alfred Power Pack][app] and [Alfred Remote][remote].

The intention is to help you move a window to the edge of the current display
without resizing the window. It also helps with moving the window to the next
display as well as centring[^1] windows in the display.

[^1]: Note that the documentation is written in British English (e.g.
centre), whereas the code is written in American English (e.g. center).

[app]: http://www.alfredapp.com/powerpack/
[remote]: http://www.alfredapp.com/remote/

# Setup

- Download `Window Snap.alfredworkflow` from the [Downloads][dl] page
- double click it to install the workflow in Alfred
- setup the hotkeys (Alfred removes these on installation of a workflow for your
  safety).

For reference, you can see an image below of how these hotkeys are set up in the
Author's workflow. Those keys work as follows:

- ⌘↖︎ (CMD-HOME) - "left"
    - CMD-FN-LEFT on a compact keyboard
    - moves the current window to the left edge of the current monitor
- ⌘⇞ (CMD-PAGEUP) - "top"
    - CMD-FN-UP on a compact keyboard
    - moves the current window to the top edge of the current monitor
- ⌘↘︎ (CMD-END) - "right"
    - CMD-FN-RIGHT on a compact keyboard
    - moves the current window to the right edge of the current monitor
- ⌘⇟ (CMD-PAGEDOWN) - "bottom"
    - CMD-FN-DOWN on a compact keyboard
    - moves the current window to the bottom edge of the current monitor
- ^⎇⌘. (CTRL-ALT-CMD-PERIOD) - "center"
    - moves the current window to the centre of the current monitor
- ^⎇⌘, (CTRL-ALT-CMD-COMMA) - "next"
    - moves the current window to the next monitor

On an Apple laptop or bluetooth keyboard without the extended keys, you'll need
to use the alternative key combination shown beneath each one.

![Hot Keys configured in Alfred][hk]

[dl]: https://bitbucket.org/adamhorner/macwindowmgmt/downloads
[hk]: https://bitbucket.org/repo/zAg8Eq/images/1802463211-hotkeys.png

# Usage

Once the keyboard shortcuts are set up then moving windows around the monitor(s)
(without resizing them) is simply a matter of using the hotkeys as configured.

It is also easy to set up a remote page as part of the workflow, simply add the
suggested page from the Window Snap workflow in the remotes tab, here is what it
looks like on the author's iPhone:

![Alfred Remote][ri]

[ri]: https://bitbucket.org/repo/zAg8Eq/images/2277048358-IMG_2340.PNG

# Advanced usage

There is a keyword for each of the four main operations, simply activate Alfred
using your keyboard shortcut and type "top", "left", "right", "bottom" to move
your current window to that edge of its current monitor. The underlying script
allows more complication motions, for example it is possible to move the current
window to the centre-right edge of the next monitor by activating Alfred and
type `move next center right`.

Specify any of the following valid keywords (case doesn't matter), in any order
after the 'move' keyword.

- TOP
- BOTTOM
- RIGHT
- LEFT
- CENTER
- NEXT
