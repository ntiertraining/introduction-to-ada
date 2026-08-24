[//]: # (README.md)
[//]: # (Copyright © 2026 nTier Training. All rights reserved.)
[//]: #

![Banner Light](./.assets/images/banner-introduction-to-ada-light.png#gh-light-mode-only)
![banner Dark](./.assets/images/banner-introduction-to-ada-dark.png#gh-dark-mode-only)

<span>[ <a href="/README.md#module-lab-instructions">Lab table of contents</a> ]</span>

# Introduction

This is the lab project repository for the nTier Training course *"Introduction to Ada"*.
This course uses Visual Studio Code as the integrated development environment (IDE) with Alire for package management and GNAT for the build tools.
The first module focuses are creating an Ada project in the workspace and running the program.
The subsequent modules add to the project in the same workspace moving forward.

There are four ways to initialize and use the development environment.
Pick the one which best serves your needs:

<blockquote><font size="+2">&#9312;</font> <b>Run on a local computer:</b><br>
    Setup for a Local Development Computer:
    <a href="./.assets/lab_instructions/local-install.md">follow the instructions on this page</a>
    </blockquote><br>

<blockquote><font size="+2">&#9313;</font> <b>Run in a local Docker container:</b><br>
    Clone this project onto a local computer with Docker, open the folder in VS Code,
    and use the <i>Dev Containers: Reopen in Container</i> command to launch the project in a local Docker container.
    Or, just wait for VS Code to notice the >o>devcontainer.json</i> configuration file and ask if you want to
    launch it in Docker.
    </blockquote><br>

<blockquote><font size="+2">&#9314;</font> <b>Run in a GitHub Codespace (a Docker container on GitHub's servers):</b><br>
    When signed onto GitHub with a personal account, and with this repository open in GitHub,
    follow <a href="https://codespaces.new/ntiertraining/introduction-to-ada">this link</a>
    or click the green *Code* button on the GitHub page, select the Codespaces tab,
    and click the green button to <i>Create codespace on main</i>.
    Running this from a personal GitHub account is required to launch the Codespace.
    Warning: any work you do will be lost if the Codespace is deleted.
    </blockquote><br>

<blockquote><font size="+2">&#9315;</font> <b>Run in a Google Cloud Shell: (a virtual container on Google's servers)</b><br>
    When signed onto Google with a personal account, and with this repository open in GitHub,
    click <a target="_blank" href="https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/ntiertraining/introduction-to-ada.git&cloudshell_workspace=.&&cloudshell_tutorial=README_CS.md&ephemeral=true">this link</a>.
    Running this from a personal Google account is required to launch the virtual container.<br>
    Warning: this is an ephemeral virtual computer and any work you do will be erased when the Google Cloud Shell ends.
    Google sets the maximum idle time to 40 minutes, and the maximum elapsed time to twelve hours.<br><br>
    As the cloud shell starts follow these instructions:<br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;1. In the <i>Open in Cloud Shell</i> dialog check "Trust repo" and click <i>Continue</i>.<br>
    &nbsp;&nbsp;&nbsp;&nbsp;2. If an <i>Authorize Cloud Shell</i> dialog appears click <i>Authorize</i>.<br>
    &nbsp;&nbsp;&nbsp;&nbsp;3. A <i>Cloud Shell Tutorial</i> will appear on the right side of the brower window.
        Continue with the instructions provided there.<br>
    </blockquote><br>

When the development environment is ready, this README file is displayed in the
newly opened workspace and you are placed right back here to start.
In the workspace use the following links for the lab instructions:

# Module Lab Instructions

[Module 01: Introduction to Ada](./.assets/lab_instructions/module_01.md)<br>
[Module 02: Basic Syntax and Data Types](./.assets/lab_instructions/module_02.md)<br>
[Module 03: Control Structures and Operators](./.assets/lab_instructions/module_03.md)<br>
[Module 04: Subprograms](./.assets/lab_instructions/module_04.md)<br>
[Module 05: Modular Programming](./.assets/lab_instructions/module_05.md)<br>
[Module 06: Composite Types (Records and Arrays)](./.assets/lab_instructions/module_06.md)<br>
[Module 07: Exceptions and Error Handling](./.assets/lab_instructions/module_07.md)<br>
[Module 08: Input/Output Operations](./.assets/lab_instructions/module_08.md)<br>
[Module 09: Exception Handling](./.assets/lab_instructions/module_09.md)<br>
<!-- [Module 10: Putting it Together](./.assets/lab_instructions/module_10.md)<br> -->