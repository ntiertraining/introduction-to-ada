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

## <sup>&#9312;</sup> Run on a local computer:
<blockquote>
    Setup for a Local Development Computer:
    <a href="./.assets/lab_instructions/local-install.md">follow the instructions on this page</a>
    </blockquote><br>

## <sup>&#9313;</sup> Run in a local Docker container:
<blockquote>
    Clone this project onto a local computer with Docker, open the folder in VS Code,
    and use the <i>Dev Containers: Reopen in Container</i> command to launch the project in a local Docker container.
    Or, just wait for VS Code to notice the >o>devcontainer.json</i> configuration file and ask if you want to
    launch it in Docker.
    </blockquote><br>

## <sup>&#9314;</sup> Run in a virtual GitHub Codespace:
<blockquote>
    A Codespace is a Docker cotnainer running in a Debian Linux virtual computer at GitHub.
    You must be signed onto a personal GitHub account to launch the Codespace.
    You have this repository open in GitHub,
    scroll up and click the *Code* button at the top of the repository, select the <i>Codespaces</i> tab,
    and click the button to <i>Create codespace on main</i>.
    Warning: Codespaces are persistent, but any work you do will be lost if the Codespace is deleted.
    </blockquote><br>

## <sup>&#9315;</sup> Run in a virtual Google Cloud Shell:
<blockquote>
    A Cloud Shell is a Debian Linux virtual computer hosted at Google.
    You must be signed onto Google with a personal account to launch the virtual computer.
    Once the cloud shell starts in a new browser tab follow these instructions:<br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;1. In the <i>Open in Cloud Shell</i> dialog check "Trust repo" and click <i>Continue</i>.<br>
    &nbsp;&nbsp;&nbsp;&nbsp;2. If an <i>Authorize Cloud Shell</i> dialog appears click <i>Authorize</i>.<br>
    &nbsp;&nbsp;&nbsp;&nbsp;3. A <i>Cloud Shell Tutorial</i> will appear on the right side of the brower window.
        Continue with the instructions provided there.<br><br>
    <a target="_blank" href="https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/ntiertraining/introduction-to-ada.git&cloudshell_workspace=.&&cloudshell_tutorial=.assets/resources/gcs_tutorial.md&ephemeral=true">Click this link to launch this repository in Google Cloud Shell in a new browser tab</a>.<br><br>
    Warning: this is an ephemeral virtual computer and any work you do will be erased when the Google Cloud Shell ends.
    Google sets the maximum idle time to 40 minutes, and the maximum elapsed time to twelve hours.
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