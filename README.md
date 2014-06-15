# Mac Window Management for Alfred

This project helps with window management on a mac, leveraging the power of the
[Alfred Power Pack][app].

The intention is to help you move a window to the edge of the current display
without resizing the window. It also helps with moving the window to the next
display as well as centring[^1] windows in the display.

[^1]: You will note that the documentation is written in British English (e.g.
centre), whereas the code is written in American English (e.g. center).

[app]: http://www.alfredapp.com/powerpack/

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

# Advanced usage

There is a keyword for each of the four main operations, simply activate Alfred
using your keyboard shortcut and type "top", "left", "right", "bottom" to move
your current window to that edge of its current monitor. The underlying script
allows more complication motions, for example it is possible to move the current
window to the centre-right edge of the next monitor by activating Alfred and
type "move nextcenterright".

The general rule is that you need to specify the keywords in 'priority' order in
a valid combination. These are the valid combinations (case doesn't matter):

- TOP
- BOTTOM
- RIGHT
- LEFT
- TOPRIGHT
- TOPLEFT
- BOTTOMRIGHT
- BOTTOMLEFT
- CENTER
- CENTERTOP
- CENTERLEFT
- CENTERBOTTOM
- CENTERRIGHT
- NEXT
- NEXTTOP
- NEXTBOTTOM
- NEXTRIGHT
- NEXTLEFT
- NEXTTOPRIGHT
- NEXTTOPLEFT
- NEXTBOTTOMRIGHT
- NEXTBOTTOMLEFT
- NEXTCENTER
- NEXTCENTERTOP
- NEXTCENTERLEFT
- NEXTCENTERBOTTOM
- NEXTCENTERRIGHT
