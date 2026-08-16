[//]: # (README.md)
[//]: # (Copyright © 2026 nTier Training. All rights reserved.)
[//]: #

![Banner Light](./.assets/images/banner-introduction-to-ada-light.png#gh-light-mode-only)
![banner Dark](./.assets/images/banner-introduction-to-ada-dark.png#gh-dark-mode-only)

# Introduction

Welcome to the lab project repository for the nTier Traininbg Introduction to Ada course.

## Local Computer

### Install the development environment on the local computer

Install these packages as necessary.
Some may already be installed and configured.

1. Install Visual Studio Code. If you prefer use a package manager, or download directly from [https://code.visualstudio.com](https://code.visualstudio.com)

1. Open Visual Studio Code:
    <ol type="a">
        <li>In the activity bar on the left find and click the *Extensions* icon (hover and it will display the name).</li>
        <li>In the search bar enter *Ada & Spark*.</li>
        <li>Click the package in the results, and in the window describing the extension install it.
    </ol>

1. Install *Alire*, the Ada package and toolchain manager. Download the file from *[https://alire.ada.dev](https://alire.ada.dev)*.
    * For Apple macOS and Linux the zip file only contains the *alr* program; extract this and move it to /usr/local/bin.
    * For Microsoft Windows:
        <ol type="a">
            <li>Run the *.exe* installer downloaded in this step.</li>
            <li>Click the *Windows* icon on the task bar and search for *Alire*. Run the program.</li>
            <li>Use the command <i>alr --version</i> to make sure that *alr* runs.
            <li>Use the <i>Control Panel</i> to add <i>C:\Program Files\Alire\bin</i> to the PATH so <i>alr</i> is visible from any command prompt.
        </ol>

1. Add the compile and build toolchain:
    <ol type="a">
        <li>Run the command <i>alr toolchain --select</i> to run the toolchain wizard.</li>
        <li>Wait for <i>alr</i> to update the compile and build packages.</li>
        <li>Pick the toolchain no. 1: <i>gnat_native</i>.</li>
        <li>On the second chooser pick the first option: <i>gprbuild</i>.</li>
        <li>Wait for <i>alr</i> to install the compiler and builder.</li>
    </ol>

1. That is it, all done!

### Install the lab environment on the local computer

Use the following *git* command on your local computer to clone this repository into a new project and call it *flight_deck*.
The first parameter is the URL to the repository, the second is the name to give the clone.
$ is the command prompt.

```bash
$ cd [your projects folder]
$ git clone https://github.com/ntiertraining/introduction-to-ada flight_deck
```

Change directory into the new project:

```bash
$ cd flight_deck
```

<!-- $ alr init --bin --in-place -->

Launch Visual Studio Code in the current (flight_deck) directory.
This README.md file will display.
Click on the link for the Module 01 lab instructions and continue.

```bash
$ code .
```

# Module Lab Instructions

[Module 01: Introduction to Ada](./.assets/lab_instructions/module_01.md)<br>
[Module 02: Basic Syntax and Data Types](./.assets/lab_instructions/module_02.md)<br>
[Module 03: Control Structures and Operators](./.assets/lab_instructions/module_03.md)<br>
[Module 04: Subprograms](./.assets/lab_instructions/module_04.md)<br>
[Module 05: Modular Programming](./.assets/lab_instructions/module_05.md)<br>
[Module 06: Composite Types (Recoreds and Arrays)](./.assets/lab_instructions/module_06.md)<br>
[Module 07: Exceptions and Error Handling](./.assets/lab_instructions/module_07.md)<br>
[Module 08: Generics](./.assets/lab_instructions/module_08.md)<br>
[Module 09: Task and Concurrency](./.assets/lab_instructions/module_09.md)<br>
[Module 10: Putting it Together](./.assets/lab_instructions/module_10.md)<br>