<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png" />&nbsp;&nbsp;Module 01 Lab: Initial Flight Check</h1>

[Return to list of module lab instructions](/README.md#module-lab-instructions)

## Topic

Configuring and checking the development environment.
The project will encompass flight-deck operations.

## Goals

- Ensure the developer can successfully use Visual Studio Code, Alire, and GNAT.
- Compile and execute a baseline Ada program to confirm the toolchain functions correctly.

## Prerequisites

This lab assumes the following are **already installed** on your workstation:

- GNAT compiler (via Alire or a standalone GNAT install)
- Alire (`alr`) package manager
- Visual Studio Code

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

---

## Part 1 — Create the Alire Project

### Step 1.1: Initialize a new workspace named `flight_deck`

Here in VS Code with the *Flight_Deck* project open a terminal
window in the lower panel.
Use the following
command to initialize the Ada project in this project folder.
The first prompt will ask for the project name, enter *Flight_Deck*.
Take the default values for all the remaining prompts.

```bash
$ alr init --bin --in-place
```

- `--bin` tells Alire to scaffold an **executable** project (as opposed to a library).
- This creates the following structure in this folder.
The explorer panel will update immediately with the new structure:

```
flight_deck/
├── alire.toml
├── flight_deck.gpr
└── src/
    └── flight_deck.adb
```

Double-click on the *src/flight_deck.adb* file to open it.

Click and hold on the tab for these instructions and drag it top center of the right half of the editor window.
The right half will highlight, drop the tab.
Now both the file and instructions are open side-by-side.

Build the application:

```bash
$ alr build
```

Run the program.
There isn't any output, the program does nothing.
The check here is to make sure it runs without errors:

```bash
$ alr run
```

### Step 1.2: Write the initialization program

Double click the `src/flight_deck.adb` file to open in the editor.
Replace the contents of the file with this:

```ada
with Ada.Text_IO; use Ada.Text_IO;

procedure Flight_Deck is
begin
   Put_Line ("F-16 Avionics Suite Initializing...");
   Put_Line ("Display Processor.................... OK");
   Put_Line ("Air Data Inertial Reference System... OK");
   Put_Line ("Flight Computer...................... OK");
   Put_Line ("Mission Computer..................... OK");
   Put_Line ("Power-On Self-Test Complete. Ready for flight.");
end Flight_Deck;
```

Save the file.
Autosave should be turned on, but it's always a good idea to save.$ 

---

## Part 2 — Compile and Run from the Command Line

From inside the `flight_deck/` directory:

### Step 2.1: Build

```bash
$ alr build
```

This resolves dependencies (none needed for this simple program), invokes `gprbuild` under the hood, and produces an executable in the `bin/` folder:

- Linux/Mac: `bin/flight_deck`
- Windows: `bin\flight_deck.exe`

### Step 2.2: Run

```bash
$ alr run
```

The expected output is:

```txt
F-16 Avionics Suite Initializing...
Radar................ OK
Navigation Systems... OK
Weapons Systems....... OK
Power-On Self-Test Complete. Ready for flight.
```

You can also run the compiled binary directly without going through Alire:

```bash
# Linux or Mac
./bin/flight_deck

# Windows (PowerShell or cmd)
.\bin\flight_deck.exe
```

If you see the initialization message, your command-line toolchain (GNAT + Alire) is confirmed working. ✅

---

## Part 3 — Use Run/Debug in VS Code

### Step 3.2: Install the Ada extension (if not already installed)

In VS Code, open the Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`) and install:

- **Ada** by AdaCore (extension id: `AdaCore.ada`)

This provides syntax highlighting, the Ada Language Server (ALS) for navigation/hover/errors, and debugging integration.

### Step 3.3: Create the `.vscode` folder

Inside your project, create a folder named `.vscode` at the project root (same level as `flight_deck.gpr`). This is where `settings.json` and `launch.json` will live:

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

---

## Part 4 — Configure `settings.json`

`settings.json` tells VS Code (and the Ada extension) which GPR project file to use and ensures the integrated terminal has the Alire-managed toolchain on its `PATH`.
Add the following attributes (inside the braces) to the `.vscode/settings.json`.
Pick the example below that matches your operating system:

### Windows — `.vscode/settings.json`

```json
{
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
}
```

### macOS — `.vscode/settings.json`

```json
{
    "ada.projectFile": "flight_deck.gpr",
    "ada.scenarioVariables": {},
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.env.osx": {
        "PATH": "${env:HOME}/.alire/bin:${env:PATH}",
        "SDKROOT": "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
        "LIBRARY_PATH": "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"
    }
    },
    "files.associations": {
        "*.adb": "ada",
        "*.ads": "ada",
        "*.gpr": "ada"
    }
}
```

### Linux — `.vscode/settings.json`

```json
{
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
}
```

> **Note:** If `alr` reports a different installation path on your machine (run `alr version` —
it will show where the toolchain is rooted), adjust the `PATH` entries above to match.
The goal is simply that `gnat`, `gprbuild`, and `gdb` resolve correctly inside the VS Code integrated terminal.

After saving `settings.json`, reload VS Code (`Ctrl+Shift+P` / `Cmd+Shift+P` →
"Developer: Reload Window") so the Ada extension picks up `flight_deck.gpr`.

---

## Part 5 — Configure `launch.json`

`launch.json` defines how VS Code builds and launches the debugger. All three OS versions below use `cppdbg` with GDB (the debugger that ships with GNAT/Alire toolchains) and reference a `preLaunchTask` that builds the project via Alire.

### Step 5.1: Create the build task first — `.vscode/tasks.json`

Since `launch.json` will call `alr build` before debugging, add a `tasks.json` alongside it:

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
            "MIMode": "gdb",
            "miDebuggerPath": "gdb.exe",
            "preLaunchTask": "alr-build"
        }
    ]
}
```

### macOS — `.vscode/launch.json`

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

> macOS ships with LLDB by default. If your Alire toolchain includes GDB and you prefer it, set `"MIMode": "gdb"` and add `"miDebuggerPath": "gdb"` instead.

### Linux — `.vscode/launch.json`

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

Save the file. VS Code will now show **"Debug flight_deck"** in the Run and Debug dropdown (`Ctrl+Shift+D` / `Cmd+Shift+D`).

---

## Part 6 — Run the Program Inside VS Code

### Step 6.1: Run *without* debugging

1. Open `src/flight_deck.adb`.
2. Open the Run and Debug panel (`Ctrl+Shift+D` / `Cmd+Shift+D`).
3. Select **"Debug flight_deck"** from the dropdown at the top.
4. Use **Run → Run Without Debugging** (`Ctrl+F5` / `Cmd+F5`).

This builds the project (via the `alr-build` task) and runs the executable straight through, printing the full initialization sequence in the terminal/console with no pauses.

### Step 6.2: Run *with* debugging (no breakpoint yet)

1. Press `F5`, or use **Run → Start Debugging**.
2. The program builds and launches under GDB/LLDB, then runs to completion the same as before, since no breakpoints are set — you'll simply see the debugger attach and detach around the normal output.

---

## Part 7 — Set a Breakpoint and Debug

### Step 7.1: Place the breakpoint

1. Open `src/flight_deck.adb`.
2. Click in the gutter (left margin) next to the line:

   ```ada
   Put_Line ("F-16 Avionics Suite Initializing...");
   ```

   A red dot appears, marking an active breakpoint.

### Step 7.2: Launch with debugging

1. Ensure **"Debug flight_deck"** is selected in the Run and Debug dropdown.
2. Press `F5`.
3. VS Code builds the project and launches it under the debugger. Execution will **pause** at the breakpointed line, before the message is printed.

### Step 7.3: Inspect and step through

While paused, you can:

- Hover over variables (none in this simple program yet, but this is where you'd inspect state in later labs) to see their values.
- Use the **Debug Console** to evaluate expressions.
- Use the debug toolbar controls:
  - **Continue** (`F5`) — resumes execution; the message prints and the program runs to completion.
  - **Step Over** (`F10`) — executes the current line and stops at the next one.
  - **Step Into** (`F11`) — steps into called subprograms (not applicable directly on this line, but useful once you factor code into procedures).
- Confirm in the integrated **Debug Console/Terminal** that once you click **Continue**, the full sequence prints:

  ```
  F-16 Avionics Suite Initializing...
  Radar................ OK
  Navigation Systems... OK
  Weapons Systems....... OK
  Power-On Self-Test Complete. Ready for flight.
  ```

### Step 7.4: Remove or disable the breakpoint

Click the red dot again to remove it, or right-click it and choose **Disable Breakpoint** if you want to keep it for later without it triggering.

---

## Lab Checklist

- [ ] `alr init --bin flight_deck` created the project successfully.
- [ ] `src/flight_deck.adb` compiles and prints the F-16 initialization message.
- [ ] `alr build` and `alr run` succeed from the command line.
- [ ] Project opens correctly in VS Code with the Ada extension active.
- [ ] `.vscode/settings.json` created and configured for your OS.
- [ ] `.vscode/tasks.json` and `.vscode/launch.json` created and configured for your OS.
- [ ] Program runs successfully via **Run Without Debugging** (`Ctrl+F5`/`Cmd+F5`).
- [ ] Program runs successfully via **Start Debugging** (`F5`) with no breakpoints.
- [ ] Breakpoint set on the `Put_Line ("F-16 Avionics Suite Initializing...")` line successfully pauses execution.
- [ ] Execution resumes and completes after clicking **Continue**.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

[Return to list of module lab instructions](/README.md#module-lab-instructions)