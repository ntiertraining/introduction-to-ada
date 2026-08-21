[//]: # (README.md)
[//]: # (Copyright © 2026 nTier Training. All rights reserved.)
[//]: #

<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png" />&nbsp;&nbsp;Setup for a Local Development Computer</h1>

## Install the development environment

Install these packages as necessary.
Some may already be installed and configured.

1. Install Visual Studio Code. If you prefer use a package manager, or download directly from [https://code.visualstudio.com](https://code.visualstudio.com)

1. Open Visual Studio Code:
    <ol type="a">
        <li>In the activity bar on the left find and click the *Extensions* icon (hover and it will display the name).</li>
        <li>In *Extensions* panel, in the search bar, enter <i>"Ada & Spark"</i>.</li>
        <li>Click the package in the results list, and in the main window describing the extension click the button to install it.
    </ol>

1. For Microsoft Windows only: use winget to install *Git* and the Ada package manager *Alire* ($ is the command prompt):
    ```bash
    $ winget install --id Git.Git -e --source winget
    $ winget install Alire.Alire   # alternative: use winget install AdaLang.Alire.Portable
    ```

1. For Apple macOS and Linux install the Ada package manager *Alire*.
    Alire does not have a release for the *Homebrew* or *apt* package managers.
    Download the appropriate zip file from *[https://github.com/alire-project/alire/releases/latest](https://github.com/alire-project/alire/releases/latest)*.
    Choose the *Universal* zip file for Apple macOS, it will handle x86_64 or aarch64 architectures.
    ```bash
    $ # Replace the path with the current release and the correct file to download
    $ curl https://github.com/alire-project/alire/releases/tag/v2.1.1/alr-2.1.1-bin-universal-macos.zip alr.zip
    # unzip alr.zip
    $ mv bin/alr /usr/local/bin
    $ alr --version # To check alr is installed and reachable
    ```

1. Add the compile and build toolchain:

    a. Run the command *alr toolchain --select* to run the toolchain wizard (your version number may differ):
    ```bash
    $ alr toolchain --select
    ◴ Updating index... remote: Enumerating objects: 986, done.
    remote: Counting objects: 100% (354/354), done.
    remote: Compressing objects: 100% (66/66), done.
    remote: Total 986 (delta 314), reused 288 (delta 288), pack-reused 632 (from 3)
    ...
    ```
    b. Wait for *alr* to update the compiler and build packages.
    Pick the toolchain no. 1: *gnat_native**:
    ```bash
    Please select the gnat version for use with this configuration
    1. gnat_native=16.1.0
    2. None
    3. gnat_aarch64_elf=16.1.0
    4. gnat_arm_elf=16.1.0
    5. gnat_avr_elf=16.1.0
    6. gnat_riscv64_elf=16.1.0
    7. gnat_x86_64_elf=16.1.0
    8. gnat_xtensa_esp32_elf=16.1.0
    9. gnat_aarch64_elf=15.3.1
    0. gnat_arm_elf=15.3.1
    a. (See more choices...)
    Enter your choice index (first is default): 
    > 1
    ⓘ Selected tool version gnat_native=16.1.0
    ```

    c. On the second chooser pick the first option, *gprbuild*:
    ```bash
    ⓘ Choices for the following tool are narrowed down to releases compatible with just selected gnat_native=16.1.0

    Please select the gprbuild version for use with this configuration
    1. gprbuild=26.0.1
    2. None
    3. gprbuild=25.0.1
    4. gprbuild=24.0.1
    Enter your choice index (first is default): 
    > 1
    ⓘ Selected tool version gprbuild=26.0.1       
    ```

    d. Wait for *alr* to install the compiler and builder.
    ```bash
    ⓘ Deploying gprbuild=26.0.1...
    ################################################################################################################################ 100.0%
    ⓘ gprbuild=26.0.1 installed successfully.
    ⓘ Deploying gnat_native=16.1.0...
    ################################################################################################################################ 100.0%
    ⓘ gnat_native=16.1.0 installed successfully.
    $ 
    ```

1. That is it, all done!

## Copy the labs to the local computer

1. Use the following *git* command on your local computer to clone this repository into a new project and call it *flight_deck*.
    The first parameter is the URL to the repository, the second is the name to give the clone.
    $ is the command prompt.
    ```bash
    $ cd [your projects folder]
    $ git clone https://github.com/ntiertraining/introduction-to-ada flight_deck
    ```

1. Change directory into the new project:
    ```bash
    $ cd flight_deck
    ```

3. Launch Visual Studio Code in the current (flight_deck) directory.
    The README file with the lab instruction links will display.
    Click on the link for the Module 01 lab instructions and continue.
    ```bash
    $ code .
    ```
    Note: VS Code may be launched from the GUI as well, just open find and open the flight_deck folder.