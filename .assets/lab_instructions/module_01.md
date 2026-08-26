<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png" />&nbsp;&nbsp;Module 01 Lab: Initial Flight Check</h1>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Overview

The project encompasses flight-deck operations with a focus on the Air Data Inference Reference Computer and
the Flight Computer. This lab concentrates on configuring the development environment.

## Goals

- Introduce the developer to the use of Visual Studio Code, Alire, and GNAT.
- Compile and execute a baseline Ada program to confirm the toolchain functions correctly.
- Build launch configurations, run, and debug the program inside VS Code

## Prerequisites

This lab assumes the following are already installed in your work environment.
Review the instructions in [README](../../README.md) for environment setup.

- Visual Studio Code
- Alire (`alr`) package manager
- GNAT compiler (via Alire or a standalone GNAT install)

You can sanity-check your installs at any time ($ is the command prompt):

```bash
$ code --version
1.104.1
0f0d87fa9e96c856c5212fc86db137ac0d783365
x64
$ alr --version
alr 2.1.1
$ alr toolchain
CRATE       VERSION STATUS  NOTES
gprbuild    26.0.1  Default
gnat_native 15.2.1  Default
```

## Estimated Time

60 minutes

## Working Branch Initialization

To kick things off right-click the tab in the VS Code *Editor* area for this file (labeled *Preview module_01.md*), and click `Close Others`
to close all the other open editor tabs.
Before you start coding, to keep your work organized the work for every module will be performed on a separate Git branch in the
local repository.
Git is a *Version Control System* package that keeps a history, allows recovering project state to any point, and supports multiple *branches* for
concurrently working on features separated from all the other code in the project.
Use the menu item <code>Terminal &rarr; New Terminal</code> to open a terminal window if one is not already open in the *Panel* at the
bottom of the IDE.
Run the following commands in the terminal window ($ is the command prompt):

```bash
$ git checkout -b module_01
$ git branch
  main
* module_01
  module_start
$
```

The second command is to verify the correct working branch is selected.
The * in front of *module_01* shows that you are currently working on that branch.

---

## Part 1 — Create the Alire Project

### Step 1.1: Initialize a new workspace named `flight_deck`

You should already have an embedded terminal window open from performing the *Working Branch Initialization*.
Use the following command to initialize the Ada project in this project folder.
The first prompt will ask for the project name, enter *Flight_Deck*.
Press return and take the default values for all the remaining prompts until the wizard is finished.

```bash
$ alr -n init --bin --in-place flight_deck
```

- `-n` says to not run interactively and select all the defaults for the configuration.
- `--bin` tells Alire to scaffold an **executable** project (as opposed to a library).
- `--in-place` says to build it in the current directory and ignore the directory exists.
- `flight_deck` will be used as the name of the project.
- This creates the following structure in this folder.
The explorer panel will update immediately with a new structure added to the *Explorer* panel on the left:

```
flight_deck/
├── alire.toml
├── flight_deck.gpr
└── src/
    └── flight_deck.adb
```

In the *Explorer* panel double-click the *src/flight_deck.adb* file to open it.
That will put a new tab in the *Editor* space following these instructions, with the focus on that tab.
You will have to move back to these instructions to continue.

Click and hold on the tab for these instructions and drag it top center of the right half of the editor window.
When the right half of the window is highlighted, drop the tab.
Now both the file and instructions are open side-by-side, the Ada file on the left and the instructions on the right.

In the terminal window run this command to build the application.
Watch for any warnings or errors:

```bash
$ alr build
```

Now use this command to run the program.
There isn't any output, if you look closely at the code the program does nothing.
This is just to check that the program runs:

```bash
$ alr run
```

### Step 1.2: Write the initialization program

In the *Editor*, replace the contents of the file with this code.
If you want to avoid typing, VS Code provides a copy button at the upper right
of the code window when you hover over it with the mouse:

```ada
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

procedure Flight_Deck is

   function OK_Message (Msg : String) return String is
      MSG_LENGTH : constant Integer := 37;
   begin
      return Msg & ((MSG_LENGTH - Msg'Length) * '.') & " OK";
   end OK_Message;

   avionics_suite_init : constant String := "F-16 Avionics Suite Initializing...";
   adirs_init           : constant String := "Air Data Inertial Reference System";
   dp_init              : constant String := "Display Processor";
   fc_init              : constant String := "Flight Computer";
   mc_init              : constant String := "Mission Computer";
   init_complete        : constant String := "Power-On Self-Test Complete. Ready for flight.";

begin
   Put_Line (avionics_suite_init);
   Put_Line (OK_Message (dp_init));
   Put_Line (OK_Message (adirs_init));
   Put_Line (OK_Message (fc_init));
   Put_Line (OK_Message (mc_init));
   Put_Line (init_complete);
end Flight_Deck;
```

VS Code will indicate if the file is modified by showing an asterisk instead of an X in the tab for the file. 
Save the file using the menu item <code>File &rarr; Save</code>
Technically the project settings for VS Code (in .vscode/settings.json) should have Autosave turned on, but you can always do a manual save.

---

## Part 2 — Compile and Run from the Command Line

### Step 2.1: Build

Run the following command (again):

```bash
$ alr build
```

This resolves dependencies (none needed for this simple program), invokes `gprbuild` under the hood, and produces an executable in the `bin/` folder:

- Linux/Mac: `bin/flight_deck`
- Windows: `bin\flight_deck.exe`

### Step 2.2: Run

Run the following command (again):

```bash
$ alr run
F-16 Avionics Suite Initializing...
Display Processor.................... OK
Air Data Inertial Reference System... OK
Flight Computer...................... OK
Mission Computer..................... OK
Power-On Self-Test Complete. Ready for flight.
$ 
```
You can also run the compiled binary directly without going through Alire:

```bash
# For Linux or Mac
$ bin/flight_deck
F-16 Avionics Suite Initializing...
Display Processor.................... OK
Air Data Inertial Reference System... OK
Flight Computer...................... OK
Mission Computer..................... OK
Power-On Self-Test Complete. Ready for flight.
# For Microsoft Windows (PowerShell or cmd)
$ bin/flight_deck.exe
F-16 Avionics Suite Initializing...
Display Processor.................... OK
Air Data Inertial Reference System... OK
Flight Computer...................... OK
Mission Computer..................... OK
Power-On Self-Test Complete. Ready for flight.
$
```

Notice: VS Code in Microsoft Windows allows the forward-slash as a path separator, even if Windows uses the back-slash (\)
If you see the initialization message, your command-line toolchain (GNAT + Alire) is confirmed working. ✅

---

Inside your project, create a folder named `.vscode` at the project root (same level as `flight_deck.gpr`). This is where `settings.json` and `launch.json` will live:

---

## Part 3 — Configure `settings.json`

The *Ada & Spark* extension for VS Code was installed during the environment setup.
This extension provides syntax highlighting, the Ada Language Server (ALS) for navigation/hover/errors, and debugging integration.
The *.vscode* folder is provided for you, this is where the *settings.json* and *launch.json* configuration files will be saved.
A *settings.json* file is already provided:

```
flight_deck/
├── .vscode/
│   ├── settings.json
│   └── launch.json
├── alire.toml
├── flight_deck.gpr
└── src/
    └── flight_deck.adb
```

`settings.json` tells VS Code (and the Ada extension) which GPR project file to use and ensures the integrated terminal has the Alire-managed toolchain on its `PATH`.
The file is a JavaScript Object Notation file with configuration information.
The JSON file is an object definition wrapped in braces {}.
Each attribute in the file is a quoted string; the values may be a quoted string, a number, a Boolean `true` or `false`, an array of values, or a nested object in braces.
Double-click the *settings.json* file to open it in the *Editor*, and then pick the appropriate example below and add the attributes *inside the braces* alongside the
existing attributes in the file:

### Windows — `.vscode/settings.json`

```json
"ada.projectFile": "flight_deck.gpr",
"ada.scenarioVariables": {},
"terminal.integrated.defaultProfile.windows": "PowerShell",
"terminal.integrated.env.windows": {
    "PATH": "${env:USERPROFILE}\\.alire\\bin;${env:PATH}"
},
"files.associations": {
    "*.adb": "ada",
    "*.ads": "ada",
    "*.gpr": "ada"
}
```

### macOS — `.vscode/settings.json`

```json
"ada.projectFile": "flight_deck.gpr",
"ada.scenarioVariables": {},
"terminal.integrated.defaultProfile.osx": "zsh",
"terminal.integrated.env.osx": {
    "PATH": "${env:HOME}/.alire/bin:${env:PATH}",
    "SDKROOT": "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
    "LIBRARY_PATH": "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
},
"files.associations": {
    "*.adb": "ada",
    "*.ads": "ada",
    "*.gpr": "ada"
}
```

### Linux — `.vscode/settings.json`

```json
"ada.projectFile": "flight_deck.gpr",
"ada.scenarioVariables": {},
"terminal.integrated.defaultProfile.linux": "bash",
"terminal.integrated.env.linux": {
    "PATH": "${env:HOME}/.alire/bin:${env:PATH}"
},
"files.associations": {
    "*.adb": "ada",
    "*.ads": "ada",
    "*.gpr": "ada"
}
```

After saving *settings.json*, reload the VS Code window to pick up the configuration changes.
Use `Ctrl+Shift+P` / `Cmd+Shift+P` to open the *Command Palette*, then in the dialog that opens
at the top center of the IDE search for and pick `Developer: Reload Window`.

---

## Part 4 — Configure *launch.json* and *tasks.json*

The *launch.json* file defines how VS Code builds and launches the debugger. 
all three OS versions below use `cppdbg` with GDB (the debugger that ships with GNAT/Alire toolchains)
and reference a `preLaunchTask` that builds the project via Alire.

### Step 4.1 - Create launch.json

Right-click the *.vscode* folder in the *Explorer* panel and select `New File...`.
In the dialog that opens at the top-center of the IDE name the file *launch.json*.
Pick the appropriate environment and copy the contents below into the file and save it:

### Windows — `.vscode/launch.json`

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug flight_deck",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/flight_deck.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": true,
            "MIMode": "C:\\This PC\\Users\\[your_user_name]\\AppData\\...",
            "miDebuggerPath": "gdb.exe",
            "preLaunchTask": "alr-build"
        }
    ]
}
```

The Gnu Debugger (*gdb*) in the windows environment is installed as part of the Alire package.
You must verify the location to set the path in the JSON configuration.
Open the *File Explorer* and from the toolbar select <code>View &rarr; Show &rarr; Hidden items</code>
to be able to see all files on the computer.
Navigate to <code>C:\\This PC\\Users\\[your_user_name]\\AppData\\Local\\alire\\cache\\toolchains\\gnat_native_[pick the latest version]\\bin</code>.
Verify that *gdb.exe* is in the folder.
Click *after* the word *bin* in the address bar of the File Explorer.
Copy the full path to a Notepad.
Add \\gdb.exe to the end of the path.
Double-up every \ in the path for JSON, and set the *miDebuggerPath* attribute in the *launch.json* with this new value.

### macOS — `.vscode/launch.json`

> macOS no longer supports the Gnu Debugger, instead it uses with the LLVM open source LLDB debugger.
The environment setup instructions for macOS included the VS Code extension *CodeLLDB* to interface to this debugger.
More information is available on this page: <a href="./macos-debugging.md" target="_blank">Debugging Ada on Apple macOS</a>.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug flight_deck",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/flight_deck",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "alr-build"
        }
    ]
}
```

### Linux — `.vscode/launch.json`

> Linux natively supports the Gnu Debugger, so no changes are required to the JSON.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug flight_deck",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/flight_deck",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "gdb",
            "preLaunchTask": "alr-build"
        }
    ]
}
```

### Step 4.2 Create the build task — `.vscode/tasks.json`

All the launch configurations above reference the *alr-build* task, so that must be defined.
Right-click the *.vscode* folder again, create a new file, and name it *tasks.json*.
Notice the following JSON uses a different schema version than the *launch.json* configurations,
2.0.0 vs 0.2.0.
That is the correct schemna version.
Copy the following JSON to the new file and save it:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "alr-build",
            "type": "shell",
            "command": "alr",
            "args": ["build"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["$gcc"]
        }
    ]
}
```

Click the *Run/Debug* icon in the *Activity Bar* or use `Ctrl+Shift+D` / `Cmd+Shift+D` to open Run/Debug in the sidebar.
Check the dropdown box at the top for **"Debug flight_deck"** to verify the launch.json file is being read.

---

## Part 5 — Run the Program Inside VS Code

### Step 5.1: Run *without* debugging

1. Make sure that *src/flight_deck.adb* is still open, or double-click it to open it in the *Editor*.
2. Make sure the *Run/Debug* panel is open in the sidebar, or open it with `Ctrl+Shift+D` / `Cmd+Shift+D`.
3. Select **"Debug flight_deck"** from the dropdown at the top.
4. Select the menu item <code>Run &rarr; Run Without Debugging</code> or press `Ctrl+F5` / `Cmd+F5` to launch the program.

This builds the project (via the `alr-build` task) and runs the executable straight through, printing the full initialization sequence in the terminal/console with no pauses.

### Step 5.2: Run *with* debugging (no breakpoint yet)

1. Press `F5`, or select the menu item <code>Run &rarr; Start Debugging</code>.
2. *Alr* builds the project in a new terminal window, which ends with a message to press return to close the window.
    Press return as it directs.
3. The program was launched immediately, but the output lands on the *Debug Console* instead of the *Terminal* window.
4. The program ran to completion because no breakpoints are set.

---

## Part 6 — Set a Breakpoint and Debug

### Step 6.1: Place the breakpoint

1. In the *Editor* window for `src/flight_deck.adb` click in the gutter (left margin) next to the line:

   ```ada
   Put_Line (avionics_suite_init);
   ```

   A red dot appears, marking an active breakpoint.

### Step 6.2: Launch with debugging

> <a href="./macos-debugging.md" target="_blank">Debugging Ada on Apple macOS</a> is iffy at best, follow the link for more information.

1. If the *Run/Debug* panel is not displayed in the sidebar open it with `Ctrl+Shift+D` / `Cmd+Shift+D`.
1. Ensure **"Debug flight_deck"** is selected in the Run and Debug dropdown.
1. Press `F5` to launch debugging.
1. VS Code builds the project in a new terminal window, sends the output to the *Debug Console*, and launches it under the debugger.
1. Execution is paused at the line with the breakpoint, before any messages are printed.

### Step 6.3: Inspect and step through

While the program is paused, you can:

- Hover over variables defined above the Put_Line print statements to see their values.
- Use the debug toolbar: a small floating toolbar that appears while debugging, usually near the top-center of the IDE:
  - **Continue** (`F5`) — resumes execution; the message prints and the program runs to completion.
  - **Step Over** (`F10`) — executes the current line and stops at the next one.
  - **Step Into** (`F11`) — steps into called subprograms (not applicable directly on this line, but useful once you factor code into procedures).
  - **Step Out Of** (`Shift+F11`) - completes a subprogram and returns to the client code.
  - **Restart** (`Shift+Ctrl/Cmd+F11`) - Restart the debugging session.
  - **Stop** (`Shift+F5`) - exit the debugger.
- Use the **Debug Console** to evaluate Ada expressions (this step will not work when using <i>lldb</i> on macOS):
  - Locate and open the *Debug Console* in the lower *Panel*.
  - At the bottom of the panel locate the > prompt to enter commands.
  - Try evaluating `1 + 1`
  - Try evaluating `fc_init'length`
  - Try evaluating `mc_init & "... OK"`
- In the debug toolbar click Confirm in the integrated **Debug Console/Terminal** that once you click **Continue**, the full sequence prints:

  ```
  F-16 Avionics Suite Initializing...
  Radar................ OK
  Navigation Systems... OK
  Weapons Systems....... OK
  Power-On Self-Test Complete. Ready for flight.
  ```

### Step 6.4: Remove or disable the breakpoint

In *flight_deck.adb* in the *Editor* click the red dot again to remove it, or right-click it and choose **Disable Breakpoint** if you want to keep it for later without it triggering.

---

## Lab Checklist

- [&nbsp;&nbsp;] `alr init --bin flight_deck` created the project successfully.
- [&nbsp;&nbsp;] `src/flight_deck.adb` compiles and prints the F-16 initialization message.
- [&nbsp;&nbsp;] `alr build` and `alr run` succeed from the command line.
- [&nbsp;&nbsp;] Project opens correctly in VS Code with the Ada extension active.
- [&nbsp;&nbsp;] *.vscode/settings.json* created and configured for your OS.
- [&nbsp;&nbsp;] *.vscode/tasks.json* and *.vscode/launch.json* created and configured for your OS.
- [&nbsp;&nbsp;] Program runs successfully via *Run Without Debugging* (`Ctrl+F5`/`Cmd+F5`).
- [&nbsp;&nbsp;] Program runs successfully via *Start Debugging* (`F5`) with no breakpoints.
- [&nbsp;&nbsp;] Breakpoint set on the `Put_Line ("F-16 Avionics Suite Initializing...")` line successfully pauses execution.
- [&nbsp;&nbsp;] Execution resumes and completes after clicking **Continue**.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>
