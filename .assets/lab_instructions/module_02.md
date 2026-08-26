<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 2: Basic Syntax and Data Types</h1>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Overview

`Important`: before commencing this lab, right-lick the tab in the VS Code *Editor* area for this file, and click `Close Others`
to close all the other open editor tabs.

This is the second lab in the Introduction to Ada series.
There are two ways to approach this lab.

1. If you are confident with the work that you accomplished in Module 01, continue with that work. This lab builds on that environment.

1. In the VS Code terminal window execute the following commands to switch to the solution for Module 01 and 

## Goals

The lab builds a cockpit telemetry data set inside the existing `flight_deck`
procedure. Emphasis falls on scalar declarations, constrained subtypes,
enumeration types, and strong typing enforcement. The exercise extends the
initialization messages produced in Module 1 with a structured set of
constants and variables representing live aircraft telemetry. Identifier
names are specified below and carry forward into later modules.

## Requirements

- Declare minimum and maximum constants for the following, using appropriate
  scalar types for each pairing:
  - Airspeed: 120 knots minimum, 1175 knots maximum
  - Altitude: 300 feet minimum, 50000 feet maximum
  - G-force: -3 minimum, +7.3 maximum
  - Critical angle of attack: 15 degrees
- Define constrained subtypes for airspeed, altitude, and g-force. Base
  airspeed and altitude on `Integer`. Base g-force on `Float`, since the
  stated limits carry a fractional maximum; a constrained `Integer` subtype
  cannot represent 7.3 without truncation, and truncation defeats the
  purpose of the constraint.
- Declare a constant for wing area (300 square feet) and a constant for
  angle of attack (15 degrees).
- Declare variables for aircraft weight (26,500 pounds) and outside air
  temperature. Weight remains fixed for this lab; temperature varies and
  requires an initial value chosen by the developer.
- Implement an enumeration type for flight mode with three values: `Nav`,
  `Dogfight`, `Landing`. Assign an initial mode.
- Add a boolean variable representing weapon systems safety status. `True`
  indicates armed, `False` indicates safe. Initialize to safe.
- Perform at least one calculation requiring an explicit type conversion
  between a `Integer`-based subtype and a `Float` value. Wing loading
  (weight divided by wing area) satisfies this requirement, as does any
  ratio built from the airspeed subtype and a `Float` denominator.
- Output every constant and variable to the terminal with a labeled
  `Put_Line` statement. Format numeric output using the appropriate
  `'Image` attribute rather than string concatenation of raw literals.

## Instructions

1. Open the `src/flight_deck.adb` file.
2. Add a `with` clause for `Ada.Text_IO` above the procedure declaration.
   Add a corresponding `use` clause. State in a comment why the `use`
   clause removes the need for a fully qualified prefix on every
   `Put_Line` call.
3. Inside the declarative part of `flight_deck`, declare the following
   paired constants for airspeed, altitude, and g-force. Use these exact
   names, referenced again in later modules:
   - `Min_Airspeed : constant := 120` and `Max_Airspeed : constant := 1175`
   - `Min_Altitude : constant := 300` and `Max_Altitude : constant := 50_000`
   - `Min_G_Force : constant := -3.0` and `Max_G_Force : constant := 7.3`
   Declare the critical angle of attack separately as
   `Critical_Angle_Of_Attack : constant := 15`, since no paired minimum
   applies to it.
4. Declare three constrained subtypes, using these exact names, referencing
   the paired constants from step 3 rather than repeating literal values:
   - `subtype Airspeed_Type is Integer range Min_Airspeed .. Max_Airspeed`
   - `subtype Altitude_Type is Integer range Min_Altitude .. Max_Altitude`
   - `subtype G_Force_Type is Float range Min_G_Force .. Max_G_Force`
   Add a short comment above `G_Force_Type` explaining the choice of
   `Float` over `Integer`.
5. Assign `Wing_Area : constant Float := 300.0` and
   `Angle_Of_Attack : constant Integer := 15`.
6. Declare `Aircraft_Weight : Float := 26_500.0` and
   `Temperature : Float`. Choose and assign a reasonable starting value
   for temperature.
7. Declare `type Flight_Mode_Type is (Nav, Dogfight, Landing)` and a
   variable named `Flight_Mode` of that type. Initialize `Flight_Mode`
   to `Nav`.
8. Declare `Weapons_Armed : Boolean := False`.
9. Declare working variables of the subtypes from step 4, using these
   exact names: `Current_Airspeed : Airspeed_Type`,
   `Current_Altitude : Altitude_Type`, `Current_G_Force : G_Force_Type`.
   Assign initial values that fall within each constrained range. Attempt,
   temporarily, to assign a value outside one range and observe the
   compiler or runtime response; remove the out-of-range assignment before
   proceeding.
10. Declare `Wing_Loading : Float` and `Airspeed_Fraction : Float` to hold
    the results calculated in steps 11 and 12.
11. In the executable part of the procedure, calculate `Wing_Loading` by
    dividing `Aircraft_Weight` by `Wing_Area`. Both operands are already
    `Float`, so no conversion applies here; note this in a comment as a
    contrast to the next step.
12. Calculate `Airspeed_Fraction` by dividing `Current_Airspeed` by
    `Max_Airspeed`. Apply an explicit `Float` conversion to the integer
    operand before dividing. Explain in a comment why Ada rejects the
    unconverted expression at compile time.
13. Output every constant, variable, and calculated result with a labeled
    `Put_Line` statement. Use `'Image` for numeric conversion to string.
14. Compile and run the program from the integrated terminal. Confirm all
    output values match the assigned initial values and calculations.
15. Set a breakpoint on the line calculating `Wing_Loading`. Launch the
    debugger using the `launch.json` configuration created in Module 1.
    When execution halts, inspect the current values of `Aircraft_Weight`,
    `Wing_Area`, and the constrained telemetry variables in the debugger
    variable pane. Step over the calculation and confirm the resulting
    value.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>


## Solution

```ada
with Ada.Text_IO; use Ada.Text_IO;

procedure Flight_Deck is

   -- Airspeed limits, in knots.
   Min_Airspeed : constant := 120;
   Max_Airspeed : constant := 1175;

   -- Altitude limits, in feet.
   Min_Altitude : constant := 300;
   Max_Altitude : constant := 50_000;

   -- G-force limits. A Float maximum of 7.3 rules out an Integer subtype.
   Min_G_Force : constant := -3.0;
   Max_G_Force : constant := 7.3;

   -- Critical angle of attack, in degrees. No paired minimum applies.
   Critical_Angle_Of_Attack : constant := 15;

   subtype Airspeed_Type is Integer range Min_Airspeed .. Max_Airspeed;
   subtype Altitude_Type  is Integer range Min_Altitude .. Max_Altitude;

   -- Float subtype: fractional maximum (7.3) cannot be represented by a
   -- constrained Integer subtype without truncation.
   subtype G_Force_Type is Float range Min_G_Force .. Max_G_Force;

   Wing_Area       : constant Float   := 300.0; -- square feet
   Angle_Of_Attack : constant Integer := 15;     -- degrees

   Aircraft_Weight : Float := 26_500.0; -- pounds
   Temperature     : Float := 15.0;     -- degrees Celsius, standard day

   type Flight_Mode_Type is (Nav, Dogfight, Landing);
   Flight_Mode : Flight_Mode_Type := Nav;

   Weapons_Armed : Boolean := False;

   Current_Airspeed : Airspeed_Type := 450;
   Current_Altitude : Altitude_Type := 20_000;
   Current_G_Force  : G_Force_Type  := 1.0;

   Wing_Loading      : Float;
   Airspeed_Fraction : Float;

begin
   Put_Line("Cockpit Telemetry Data Set");
   Put_Line("---------------------------");

   Put_Line("Min Airspeed (kt): " & Integer'Image(Min_Airspeed));
   Put_Line("Max Airspeed (kt): " & Integer'Image(Max_Airspeed));
   Put_Line("Min Altitude (ft): " & Integer'Image(Min_Altitude));
   Put_Line("Max Altitude (ft): " & Integer'Image(Max_Altitude));
   Put_Line("Min G-Force: " & Float'Image(Min_G_Force));
   Put_Line("Max G-Force: " & Float'Image(Max_G_Force));
   Put_Line("Critical Angle Of Attack (deg): " &
            Integer'Image(Critical_Angle_Of_Attack));

   Put_Line("Wing Area (sq ft): " & Float'Image(Wing_Area));
   Put_Line("Angle Of Attack (deg): " & Integer'Image(Angle_Of_Attack));
   Put_Line("Aircraft Weight (lb): " & Float'Image(Aircraft_Weight));
   Put_Line("Temperature (C): " & Float'Image(Temperature));

   Put_Line("Flight Mode: " & Flight_Mode_Type'Image(Flight_Mode));
   Put_Line("Weapons Armed: " & Boolean'Image(Weapons_Armed));

   Put_Line("Current Airspeed (kt): " & Integer'Image(Current_Airspeed));
   Put_Line("Current Altitude (ft): " & Integer'Image(Current_Altitude));
   Put_Line("Current G-Force: " & Float'Image(Current_G_Force));

   -- Both operands are already Float; no conversion required.
   Wing_Loading := Aircraft_Weight / Wing_Area;
   Put_Line("Wing Loading (lb/sq ft): " & Float'Image(Wing_Loading));

   -- Current_Airspeed is Airspeed_Type, an Integer subtype. Max_Airspeed
   -- is a universal integer. Division against a Float denominator
   -- requires an explicit Float conversion on the integer operand; Ada
   -- performs no implicit conversion between numeric types.
   Airspeed_Fraction := Float(Current_Airspeed) / Float(Max_Airspeed);
   Put_Line("Airspeed Fraction Of Max: " & Float'Image(Airspeed_Fraction));

end Flight_Deck;
```
