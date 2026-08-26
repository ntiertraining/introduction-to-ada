[//]: # (README.md)
[//]: # (Copyright © 2026 nTier Training. All rights reserved.)
[//]: #

# Introduction

This lab repository for *Introduction To Ada* has been loaded here into Google Cloud Shell, a Debian-based virtual container.
Warning: this is an ephemeral virtual computer and any work you do will be erased when the Google Cloud Shell ends.
Google sets the maximum idle time to 40 minutes, and the maximum elapsed time to twelve hours.

Google CS does not offer a reliable mechanism to automate the remaining installation.
Follow these steps to take care of it:

1. Close the big *Cloud Shell* terminal window at the bottom of the browser window, below the IDE area.
1. Wait for all the steps in the spin-up dialog to finish, and wait for the IDE UI to appear.
1. Gemini Code Assist has been deprecated and no longer available from Google,
    but the <i>Secondary Sidebar Panel</i> still opens at the right of the IDE to try and provide AI chat.
    It will never connect for your personal account.
    If it did open with a "spinning wheel of death", close that panel to the right of the IDE \(left of these instructions).
1. From the Visual Studio Code menu at the top left of the IDE window (not the browser menu), click on <i>Terminal &rarr; New Terminal</i>.
    This opens the <i>Panel</i> at the bottom of the screen and leaves the <i>Terminal</i> tab with the focus.
1. In the new terminal window run the command <code>scripts/gcs_setup.sh</code> and wait for it to complete.
    If the script fails to complete, look at the file ~/setup.log for the details on what happened.
1. Even if the script completes successfully, run the command <code>alr --version</code> to make sure Alire was installed properly.
1. Run the command <code>gdb --version</code> to make sure the Gnu debugger installed successfully.
1. Verify the toolchain with the command <code>alr toolchain</code>, the <code>default</code> for <i>gprbuild</i> and <i>gnat</i> should be the latest versions.
1. The vertical bar at the left of the IDE is the <i>Activity Bar</i>.
    Clicking on the icons reveals (or hides) a <i>Sidebar Panel</i> to the right of the <i>Activity Bar</i> (left side of the IDE).
    Find and click on the <i>Extensions</i> icon (four squares, the top right square is twisted) and open the panel.
1. In the search field at the top of the  <id>Sidebar Panel</i>, enter <code>Ada</code>.
1. Look for <code>Ada & Spark</code> in the results list and click on it.
    This opens a tab with a details for the extension in the <i>Editor</i>, the big area of the IDE.
    In the details verify the extension is already installed: no <i>install</i> button and there is a <i>uninstall button</i>.
    If not installed, the simple solution is to install using the button in this window.
1. Close the <code>Ada & Spark</code> extension details.
    At this point all panels in the <i>Editor</i> (the big area in the IDE) should be closed.
1. Make sure the Explorer panel is visible:
    in the vertical IDE <i>Activity Bar</i> at the left click on the <i>pages</i> icon at the top to
    open the panel.
1. In the <i>Explorer</i> panel right-click the <i>README.md</i> file and select <code>Open Preview</code>.
1. Close this window when these tasks are complete.
