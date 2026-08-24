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

There are three ways to initialize and use the development environment.
Pick the one which best serves your needs:

<blockquote><b>Run on a local computer:</b><br>
    Setup for a Local Development Computer:
    <a href="./.assets/lab_instructions/local-install.md">follow the instructions on this page</a></blockquote><br>

<blockquote><b>Run in a local Docker container:</b><br>
    Clone this project onto a local computer with Docker, open the folder in VS Code,
    and use the <i>Dev Containers: Reopen in Container</i> command to launch the project in a local Docker container.</blockquote><br>

<blockquote><b>Run in a GitHub Codespace (a Docker container on GitHub's servers):</b><br>
    When signed onto GitHub with a personal account, and with this repository open in GitHub,
    follow <a href="https://codespaces.new/ntiertraining/introduction-to-ada">this link</a>
    or click the green *Code* button on the GitHub page, select the Codespaces tab,
    and click the green button to <i>Create codespace on main</i>.
    Running this from a personal GitHub account is required to launch the Codespace.
    Warning: any work you do will be lost if the Codespace is deleted.</blockquote><br>

<blockquote><b>Run in a Google Cloud Shell: (a virtual container on Google's servers)</b><br>
    When signed onto Google with a personal account, and with this repository open in GitHub,
    click <a target="_blank" href="https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/ntiertraining/introduction-to-ada.git&cloudshell_workspace=.&ephemeral=true">this link</a>.
    Running this from a personal Google account is required to launch the virtual computer.
    Google Cloud Shell works a little differently from other environments.
    It ignores the Docker configuration and does not have the ability to automatically run a setup script.
    After launching the virtual computer, run the command <code>sudo scripts/setup.sh</code> in the shell window at the bottom
    of the browser window to load the required packages.
    When the script is sucessfully finished run the command <code>exit</code>.
    Right click the *README.md* file in the *Explorer* panel to the left and select *Open Preview*.
    Close the *Gemini Code Assist* panel at the right; Google deprecated Gemini Assist even though the panel pops up.
    Click on the instructions for Module 01 in the README file.
    Warning: this is an ephermal virtual computer and any work you do will be erased when the Google Cloud Shell ends.
    Google sets the maximum idle time to 40 minutes, and the maximum elapsed time to twelve hours.
    </blockquote><br>

When the development environment is ready, VS Code will always display this README file for the
newly opened workspace, so you are placed right back here to start.
In the newly opened workspace use the following links for the lab instructions:

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