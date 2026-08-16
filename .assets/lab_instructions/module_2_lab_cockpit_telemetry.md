# Module 2 Lab: Cockpit Telemetry Data Declaration

**Builds on:** Module 1 — Avionics Environment Setup and Initial Flight Check
**Project:** `flight_deck` (continued)

This lab reinforces the topics covered in Module 2 — Basic Syntax and Data Types:

- Basic program structure, comments, `with`/`use`
- `procedure`, `function`, `package` (minimal)
- Identifier naming conventions
- Variable declarations
- Scalar types: Integer, Float, Boolean, Character
- Strings
- Derived types
- Subtypes, constraints, and compile-time / run-time checking
- Enumeration types
- Constants
- Strong typing
- Type conversion / casting and implicit conversions
- Scalar attributes

---

## Lab Topic

**Cockpit Telemetry Data Declaration** — Implementing strongly typed variables, scalar types, subtypes, and constants to represent aircraft sensor data.

## Goals

- Practice declaring variables using basic scalar types such as integers, floats, booleans, and characters.
- Utilize Ada's strong typing, custom subtypes, and constrained ranges to represent physical limits safely.

## Requirements

- The program must declare constants for maximum structural limits, such as maximum gravitational force (`9.0`) and maximum airspeed (`Mach 2.0`).
- The developer must define constrained integer subtypes for altitude and speed to leverage compile-time and run-time constraint checking.
- The developer must implement enumeration types for flight modes (e.g., `Nav`, `Dogfight`, `Landing`) and boolean flags for weapon systems safety status (armed versus safe).
- Explicit type conversions must be performed when combining different numeric scalar types.

---

## Setup: Add a New Program to the `flight_deck` Project

You'll keep `flight_deck.adb` from Module 1 as-is and add a second, independent program in the same project.

1. Inside `flight_deck/src/`, create a new file named `cockpit_telemetry.adb`.
2. Start it with the minimal shell below — you'll fill in the rest as you work through the tasks:

   ```ada
   with Ada.Text_IO; use Ada.Text_IO;

   procedure Cockpit_Telemetry is

      --  TODO: your declarations go here (Tasks 1-4)

   begin

      --  TODO: your statements go here (Tasks 5-8)

   end Cockpit_Telemetry;
   ```

3. Open `flight_deck.gpr` at the project root and find:

   ```ada
   for Main use ("flight_deck.adb");
   ```

   Change it to register the new program as a second executable entry point:

   ```ada
   for Main use ("flight_deck.adb", "cockpit_telemetry.adb");
   ```

   Save the file.

---

## Tasks

Work through these in order — each one builds on the last. Write your code directly into `cockpit_telemetry.adb`.

### Task 1 — Declare Constants

In the declarative part, declare two constants:

- `Max_G_Force`, a `Float`, set to `9.0`
- `Max_Airspeed_Mach`, a `Float`, set to `2.0`

### Task 2 — Derived Type and Constrained Subtypes

- Declare a derived type named `Feet` based on `Integer`.
- Declare a subtype named `Altitude_Type` based on `Feet`, constrained to the range `0 .. 60_000`.
- Declare a subtype named `Airspeed_Knots` based on `Integer`, constrained to the range `0 .. 1_200`.

### Task 3 — Enumeration Type

Declare an enumeration type named `Flight_Mode` with the values `Nav`, `Dogfight`, and `Landing`.

### Task 4 — Variable Declarations

Declare the following variables, giving each a sensible initial value:

- `Current_Altitude` of type `Altitude_Type`
- `Current_Speed` of type `Airspeed_Knots`
- `Current_Mode` of type `Flight_Mode`
- `Weapons_Armed`, a `Boolean` (`True` = armed, `False` = safe)
- `Pilot_Initials`, a single `Character`
- `Current_G`, a `Float`

### Task 5 — Print a Telemetry Snapshot

In the statement part, use `Put_Line` to print each of the Task 4 values. You'll need the `'Image` attribute to convert non-string values into `String` for concatenation with `&`. Also print `"Weapons Status: ARMED"` or `"Weapons Status: SAFE"` based on `Weapons_Armed`.

### Task 6 — Explicit Type Conversion

`Current_Speed` is an `Integer`-based subtype, but you need a `Float` to compare against `Max_Airspeed_Mach`. Using a `declare` block:

1. Convert `Current_Speed` to `Float` explicitly.
2. Compute an approximate Mach number by dividing that float by `660.0`.
3. Print the approximate Mach value.
4. If it exceeds `Max_Airspeed_Mach`, print a warning.

Then, separately, compare `Current_G` against `Max_G_Force` and print whether the aircraft is within its structural limit.

### Task 7 — Trigger a Compile-Time Constraint Check

Temporarily add the following line to your declarative part:

```ada
Bad_Altitude : Altitude_Type := 70_000;
```

Run `alr build` and observe what happens. Once you've confirmed the compiler catches it, comment the line back out (or delete it) so the project builds cleanly again.

### Task 8 — Trigger a Run-Time Constraint Check

In the statement part, add a `declare` block that:

1. Declares a local variable `Boosted_Speed` of type `Airspeed_Knots` (no initial value).
2. Assigns `Current_Speed + 900` to it.
3. Prints `Boosted_Speed` if the assignment succeeds.
4. Includes an `exception` handler for `Constraint_Error` that prints a message indicating the value exceeded the safe envelope.

Think about why this particular check can only be caught at run time, and not at compile time like Task 7.

### Task 9 (Stretch) — Scalar Attributes

Using `'First` and `'Last`, print the lower and upper bounds of `Altitude_Type` and `Airspeed_Knots`.

---

## Compile and Test from the Command Line

From the `flight_deck/` project root:

```bash
alr build
```

Run your program:

```bash
# Linux / Mac
./bin/cockpit_telemetry

# Windows (PowerShell or cmd)
.\bin\cockpit_telemetry.exe
```

Confirm:

- The telemetry snapshot prints correctly.
- Task 7's out-of-range constant fails the **build** when uncommented, and the build succeeds again once removed/commented.
- Task 8's `Boosted_Speed` assignment raises `Constraint_Error` at **run time**, caught by your exception handler.

---

## Run and Debug from VS Code

1. Add a second configuration to `.vscode/launch.json`, alongside `"Debug flight_deck"` from Module 1:

   ```json
   {
       "name": "Debug cockpit_telemetry",
       "type": "cppdbg",
       "request": "launch",
       "program": "${workspaceFolder}/bin/cockpit_telemetry",
       "args": [],
       "stopAtEntry": false,
       "cwd": "${workspaceFolder}",
       "environment": [],
       "externalConsole": false,
       "MIMode": "gdb",
       "miDebuggerPath": "gdb",
       "preLaunchTask": "alr-build"
   }
   ```

   > On Windows, set `"program"` to `${workspaceFolder}/bin/cockpit_telemetry.exe` and `"miDebuggerPath"` to `gdb.exe`.

2. Set a breakpoint on your Task 8 assignment line (`Boosted_Speed := Current_Speed + 900;`).
3. Select **"Debug cockpit_telemetry"** in the Run and Debug dropdown and press `F5`.
4. Step **Over** (`F10`) the breakpointed line and watch execution jump into your `exception` handler as `Constraint_Error` is raised.

---

## Lab Checklist

- [ ] `cockpit_telemetry.adb` created and registered as a second main in `flight_deck.gpr`.
- [ ] Constants `Max_G_Force` and `Max_Airspeed_Mach` declared (Task 1).
- [ ] `Feet` derived type and `Altitude_Type` / `Airspeed_Knots` subtypes declared (Task 2).
- [ ] `Flight_Mode` enumeration declared (Task 3).
- [ ] All required variables declared with sensible initial values (Task 4).
- [ ] Telemetry snapshot prints correctly, including weapons status (Task 5).
- [ ] Explicit `Float` conversion used to compute and check approximate Mach and G-force (Task 6).
- [ ] Compile-time constraint violation demonstrated and then removed (Task 7).
- [ ] Run-time constraint violation demonstrated and caught with an exception handler (Task 8).
- [ ] (Stretch) Scalar attributes printed for both subtypes (Task 9).
- [ ] Program builds and runs cleanly from the command line.
- [ ] `launch.json` extended and breakpoint debugging confirmed in VS Code.

---

## Solution

```ada
with Ada.Text_IO; use Ada.Text_IO;

procedure Cockpit_Telemetry is

   --------------------------------------------------------------------------
   --  Task 1: Constants — structural / performance limits
   --------------------------------------------------------------------------
   Max_G_Force       : constant Float := 9.0;
   Max_Airspeed_Mach : constant Float := 2.0;

   --------------------------------------------------------------------------
   --  Task 2: Derived type and constrained subtypes
   --------------------------------------------------------------------------
   type Feet is new Integer;

   subtype Altitude_Type  is Feet    range 0 .. 60_000;
   subtype Airspeed_Knots is Integer range 0 .. 1_200;

   -- Task 7 demonstration (leave commented for a clean build):
   -- Bad_Altitude : Altitude_Type := 70_000;  -- COMPILE-TIME constraint violation

   --------------------------------------------------------------------------
   --  Task 3: Enumeration type
   --------------------------------------------------------------------------
   type Flight_Mode is (Nav, Dogfight, Landing);

   --------------------------------------------------------------------------
   --  Task 4: Variable declarations
   --------------------------------------------------------------------------
   Current_Altitude : Altitude_Type  := 35_000;
   Current_Speed    : Airspeed_Knots := 450;
   Current_Mode     : Flight_Mode    := Nav;
   Weapons_Armed    : Boolean        := False;
   Pilot_Initials   : Character      := 'M';
   Current_G        : Float          := 1.2;

begin
   --  Task 5: Telemetry snapshot
   Put_Line ("=== Cockpit Telemetry Snapshot ===");
   Put_Line ("Pilot: " & Pilot_Initials);
   Put_Line ("Mode: " & Flight_Mode'Image (Current_Mode));
   Put_Line ("Altitude (ft): " & Feet'Image (Current_Altitude));
   Put_Line ("Airspeed (kt): " & Integer'Image (Current_Speed));

   if Weapons_Armed then
      Put_Line ("Weapons Status: ARMED");
   else
      Put_Line ("Weapons Status: SAFE");
   end if;

   --  Task 6: Explicit type conversion
   declare
      Speed_As_Float : constant Float := Float (Current_Speed);
      Approx_Mach    : constant Float := Speed_As_Float / 660.0;
   begin
      Put_Line ("Approx Mach: " & Float'Image (Approx_Mach));

      if Approx_Mach > Max_Airspeed_Mach then
         Put_Line ("WARNING: Airspeed exceeds Mach limit!");
      end if;
   end;

   if Current_G > Max_G_Force then
      Put_Line ("WARNING: G-force exceeds structural limit!");
   else
      Put_Line ("G-force within structural limit (" & Float'Image (Current_G) &
                 " / " & Float'Image (Max_G_Force) & ")");
   end if;

   --  Task 8: Run-time constraint check
   declare
      Boosted_Speed : Airspeed_Knots;
   begin
      Boosted_Speed := Current_Speed + 900;  -- 450 + 900 = 1350 > 1_200
      Put_Line ("Boosted speed: " & Integer'Image (Boosted_Speed));
   exception
      when Constraint_Error =>
         Put_Line ("Runtime check failed: boosted speed exceeds safe envelope (Constraint_Error).");
   end;

   --  Task 9 (Stretch): Scalar attributes
   Put_Line ("Altitude_Type range: " & Feet'Image (Altitude_Type'First) &
              " .. " & Feet'Image (Altitude_Type'Last));
   Put_Line ("Airspeed_Knots range: " & Integer'Image (Airspeed_Knots'First) &
              " .. " & Integer'Image (Airspeed_Knots'Last));

end Cockpit_Telemetry;
```

### Expected Output

```
=== Cockpit Telemetry Snapshot ===
Pilot: M
Mode: NAV
Altitude (ft):  35000
Airspeed (kt):  450
Weapons Status: SAFE
Approx Mach:  6.81818E-01
G-force within structural limit ( 1.20000E+00 /  9.00000E+00)
Runtime check failed: boosted speed exceeds safe envelope (Constraint_Error).
Altitude_Type range:  0 ..  60000
Airspeed_Knots range:  0 ..  1200
```

> Exact `Float'Image` formatting may vary slightly by compiler version — the values and the `Constraint_Error` message are what matter.
