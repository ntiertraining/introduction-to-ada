<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 2: Basic Syntax and Data Types</h1>

## Topic

**Builds on:** Module 1 — Avionics Environment Setup and Initial Flight Check
**Project:** `flight_deck` (continued)

This module walks through Ada's fundamental syntax and type system, then applies it in a hands-on lab that adds a new program — `cockpit_telemetry.adb` — to the existing `flight_deck` Alire project.

---

## Concepts

### 1. Basic Program Structure

Every Ada program has a consistent shape: optional context clauses (`with`/`use`), a subprogram (or package) declaration, a `begin`, a body, and an `end` that repeats the name:

```ada
with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
   -- declarations go here
begin
   -- statements go here
end Example;
```

- Everything between `is` and `begin` is the **declarative part** (variables, constants, types).
- Everything between `begin` and `end` is the **statement part** (what actually executes).
- The name after the final `end` must match the subprogram name — the compiler checks this for you.

### 2. Comments

Ada comments start with `--` and run to the end of the line. There are no block comments in Ada.

```ada
-- This is a comment.
Put_Line ("Hello");  -- comments can trail a statement too
```

### 3. The `with` Clause

`with` makes a library unit (a package, typically) **visible** to your program so you can reference it:

```ada
with Ada.Text_IO;
```

This is roughly analogous to an `#include` or `import` — it tells the compiler "I intend to use this unit."

### 4. The `use` Clause

`use` brings a package's contents into direct visibility, so you don't have to fully qualify every reference:

```ada
with Ada.Text_IO; use Ada.Text_IO;
...
Put_Line ("Hi");        -- with 'use'
Ada.Text_IO.Put_Line ("Hi");  -- without 'use', still legal, just verbose
```

`use` is a convenience, not a requirement — `with` is what grants access; `use` just saves typing.

### 5. `procedure`, `function`, and `package` (minimal overview)

| Construct   | Purpose                                            |
|-------------|-----------------------------------------------------|
| `procedure` | A subprogram that performs an action, returns nothing |
| `function`  | A subprogram that computes and **returns** a value |
| `package`   | A named grouping of related declarations (types, variables, subprograms) for organization and encapsulation |

```ada
procedure Do_Something is begin null; end Do_Something;

function Square (X : Integer) return Integer is
begin
   return X * X;
end Square;
```

We'll go deeper on functions and packages in later modules — for now, just recognize the shapes.

### 6. Identifier Naming Conventions

- Ada is **case-insensitive** (`Altitude`, `ALTITUDE`, and `altitude` are the same identifier), but the community convention is `Mixed_Case_With_Underscores`.
- Identifiers must start with a letter.
- Identifiers may contain letters, digits, and single underscores — no consecutive (`__`) or trailing (`_`) underscores.
- Reserved words (`begin`, `type`, `is`, etc.) cannot be used as identifiers.

```ada
Max_Altitude   : Integer;   -- good style
maxAltitude    : Integer;   -- legal, but not idiomatic Ada
Max__Altitude  : Integer;   -- illegal: double underscore
```

### 7. Variable Declarations

The general form is:

```ada
Name : Type [:= Initial_Value];
```

```ada
Altitude : Integer := 10_000;   -- underscores are allowed as digit separators
Call_Sign : Character;          -- no initial value — must be assigned before use
```

### 8. Scalar Types: Integer, Float, Boolean, Character

Ada provides built-in scalar types:

```ada
Speed        : Integer := 450;
Fuel_Percent : Float   := 87.5;
Is_Airborne  : Boolean := True;
Grade        : Character := 'A';
```

- `Integer` — whole numbers (implementation-defined range, typically at least -2**31 .. 2**31-1).
- `Float`   — approximate real numbers (IEEE-ish, implementation-defined precision).
- `Boolean` — `True` or `False`.
- `Character` — a single character, in single quotes.

### 9. Strings

Ada's `String` type is a fixed-length array of `Character`, written with double quotes:

```ada
Callsign : String (1 .. 6) := "VIPER1";
Message  : constant String := "Ready for launch";  -- length inferred from the literal
```

Unlike `Character` (single quotes), `String` literals always use double quotes.

### 10. Derived Types

A **derived type** creates a brand-new, distinct type based on an existing one. Even though it shares the same underlying representation, Ada treats it as incompatible with its parent for direct assignment or arithmetic — this is the foundation of Ada's strong typing:

```ada
type Feet is new Integer;
type Meters is new Integer;

Altitude_Ft : Feet := 35_000;
Altitude_M  : Meters := 10_000;

-- Altitude_Ft := Altitude_M;  -- ILLEGAL: different types, even though both are "Integer-like"
```

This prevents accidentally mixing units (feet vs. meters, knots vs. mph) at compile time.

### 11. Subtypes and Constraints

A **subtype** does *not* create a new type — it names a constrained view of an existing type. Values remain freely interoperable with the base type, but out-of-range values are rejected:

```ada
subtype Percentage is Integer range 0 .. 100;

Fuel_Level : Percentage := 75;   -- OK
-- Fuel_Level := 150;            -- rejected: outside 0 .. 100
```

Subtypes are how Ada expresses "this integer, but only within a meaningful range" without inventing an incompatible new type.

### 12. Compile-Time vs. Run-Time Constraint Checking

- **Compile-time checking**: if the compiler can prove a literal or static expression violates a constraint, it rejects the program before it ever runs.

  ```ada
  Fuel_Level : Percentage := 150;  -- compile error: value out of range
  ```

- **Run-time checking**: when a value isn't known until execution (user input, a computed result), Ada inserts a range check that executes when the assignment happens. If the check fails, Ada raises the exception `Constraint_Error`.

  ```ada
  Fuel_Level := Fuel_Level + Boost;  -- checked when this line executes
  ```

This dual-layer checking is central to Ada's safety story: catch what you can before the aircraft ever leaves the ground, and defend everything else at runtime.

### 13. Enumeration Types

An enumeration type lists all its legal values by name:

```ada
type Flight_Mode is (Nav, Dogfight, Landing);

Mode : Flight_Mode := Nav;
```

Enumeration values are ordered (`Nav < Dogfight < Landing` in declaration order) and support attributes like `'Image`, `'Succ`, and `'Pred` (see §18).

### 14. Constants

A constant is declared like a variable but with the `constant` keyword, and it must be initialized — its value can never change:

```ada
Max_G_Force : constant Float := 9.0;
```

Attempting to assign to a constant after declaration is a compile-time error.

### 15. Strong Typing

Ada's type system is **strong** and **nominal**: two types are only compatible if they are declared as the same type (or one is a subtype of the other). Having the same underlying representation is not enough:

```ada
type Feet  is new Integer;
type Knots is new Integer;

Alt   : Feet  := 35_000;
Speed : Knots := 450;

-- Alt := Speed;  -- ILLEGAL, even though both are "just integers" underneath
```

This is a deliberate design choice — it prevents entire classes of unit-confusion bugs at compile time, which matters a great deal in avionics-style software.

### 16. Type Conversion and Casting

Because strong typing blocks implicit mixing, Ada requires an **explicit conversion** when you need to combine values of different types:

```ada
Speed_Knots : Integer := 450;
Speed_Float : Float := Float (Speed_Knots);   -- explicit conversion
```

The syntax is `Target_Type (Expression)`. This is a conversion, not a reinterpretation of bits — Ada performs the appropriate numeric conversion.

### 17. Implicit Conversions

Ada does allow a narrow form of implicit conversion: **universal literals** (integer or real literals with no fixed type yet) adapt automatically to whatever numeric type the context expects:

```ada
G_Force : Float := 9;      -- 9 is a universal integer literal, implicitly usable as Float
Count   : Integer := 3.0;  -- ILLEGAL: 3.0 is a universal real literal, not usable as Integer
```

Once a value is held in a *named* variable of a specific type, though, implicit conversion no longer applies — you're back to needing an explicit conversion as in §16.

### 18. Scalar Attributes (Overview)

Every scalar type comes with built-in attributes you can query:

| Attribute        | Meaning                                      |
|------------------|-----------------------------------------------|
| `T'First`        | Lowest value of type/subtype `T`             |
| `T'Last`         | Highest value of type/subtype `T`            |
| `T'Range`        | Shorthand for `T'First .. T'Last`            |
| `T'Image (X)`    | String representation of value `X`           |
| `T'Value (S)`    | Converts string `S` back into a value of `T` |
| `T'Succ (X)`     | The next value after `X`                     |
| `T'Pred (X)`     | The value before `X`                         |
| `T'Size`         | Number of bits used to represent `T`         |

```ada
Put_Line (Integer'Image (Percentage'Last));  -- prints " 100"
```

---

## Lab: Cockpit Telemetry Data Declaration

**Lab Topic:** Implementing strongly typed variables, scalar types, subtypes, and constants to represent aircraft sensor data.

### Goals

- Practice declaring variables using basic scalar types: integers, floats, booleans, and characters.
- Utilize Ada's strong typing, custom subtypes, and constrained ranges to represent physical limits safely.

### Requirements

- Declare constants for maximum structural limits: maximum G-force (`9.0`) and maximum airspeed (`Mach 2.0`).
- Define constrained integer subtypes for altitude and speed to leverage compile-time and run-time constraint checking.
- Implement an enumeration type for flight modes (`Nav`, `Dogfight`, `Landing`) and a boolean flag for weapons safety status (armed vs. safe).
- Perform explicit type conversions when combining different numeric scalar types.

---

### Step 1: Add a New Source File to the Existing `flight_deck` Project

We'll keep `flight_deck.adb` from Module 1 untouched and add a second, independent program in the same project.

Inside `flight_deck/src/`, create a new file named `cockpit_telemetry.adb`:

```ada
with Ada.Text_IO; use Ada.Text_IO;

procedure Cockpit_Telemetry is

   --------------------------------------------------------------------------
   --  Constants: structural / performance limits
   --------------------------------------------------------------------------
   Max_G_Force       : constant Float := 9.0;   -- Maximum structural G-load
   Max_Airspeed_Mach : constant Float := 2.0;   -- Maximum airspeed (Mach)

   --------------------------------------------------------------------------
   --  Derived type: a unit-safe integer type for altitude, in feet
   --------------------------------------------------------------------------
   type Feet is new Integer;

   --------------------------------------------------------------------------
   --  Subtypes: constrained ranges for compile-time / run-time checking
   --------------------------------------------------------------------------
   subtype Altitude_Type  is Feet    range 0 .. 60_000;   -- service ceiling
   subtype Airspeed_Knots is Integer range 0 .. 1_200;    -- max indicated airspeed

   -- Uncomment the line below to see a COMPILE-TIME constraint violation:
   -- Bad_Altitude : Altitude_Type := 70_000;  -- static value out of range

   --------------------------------------------------------------------------
   --  Enumeration type: flight modes
   --------------------------------------------------------------------------
   type Flight_Mode is (Nav, Dogfight, Landing);

   --------------------------------------------------------------------------
   --  Variable declarations
   --------------------------------------------------------------------------
   Current_Altitude : Altitude_Type  := 35_000;
   Current_Speed    : Airspeed_Knots := 450;
   Current_Mode     : Flight_Mode    := Nav;
   Weapons_Armed    : Boolean        := False;  -- Armed (True) vs. Safe (False)
   Pilot_Initials   : Character      := 'M';
   Current_G        : Float          := 1.2;

begin
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

   --  Explicit type conversion: combining an Integer speed with a
   --  Float-based Mach limit requires converting Integer -> Float.
   declare
      Speed_As_Float : constant Float := Float (Current_Speed);
      Approx_Mach    : constant Float := Speed_As_Float / 660.0; -- rough kt -> Mach, sea level
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

   --  Run-time constraint checking demonstration: this value is only
   --  known at run time, so the compiler cannot reject it in advance.
   --  450 + 900 = 1350, which exceeds Airspeed_Knots'Last (1_200), so
   --  this will raise Constraint_Error when the assignment executes.
   declare
      Boosted_Speed : Airspeed_Knots;
   begin
      Boosted_Speed := Current_Speed + 900;
      Put_Line ("Boosted speed: " & Integer'Image (Boosted_Speed));
   exception
      when Constraint_Error =>
         Put_Line ("Runtime check failed: boosted speed exceeds safe envelope (Constraint_Error).");
   end;

   --  Scalar attribute overview
   Put_Line ("Altitude_Type range: " & Feet'Image (Altitude_Type'First) &
              " .. " & Feet'Image (Altitude_Type'Last));
   Put_Line ("Airspeed_Knots range: " & Integer'Image (Airspeed_Knots'First) &
              " .. " & Integer'Image (Airspeed_Knots'Last));

end Cockpit_Telemetry;
```

### Step 2: Register the New Main in `flight_deck.gpr`

Alire projects declare their executable entry points in the `.gpr` file's `Main` attribute. Open `flight_deck.gpr` at the project root and find the line:

```ada
for Main use ("flight_deck.adb");
```

Change it to include the new program:

```ada
for Main use ("flight_deck.adb", "cockpit_telemetry.adb");
```

Save the file.

### Step 3: Build from the Command Line

From the `flight_deck/` project root:

```bash
alr build
```

This now compiles **both** mains. You should see two executables appear in `bin/`:

- Linux/Mac: `bin/flight_deck`, `bin/cockpit_telemetry`
- Windows: `bin\flight_deck.exe`, `bin\cockpit_telemetry.exe`

### Step 4: Run from the Command Line

```bash
# Linux / Mac
./bin/cockpit_telemetry

# Windows (PowerShell or cmd)
.\bin\cockpit_telemetry.exe
```

Expected output:

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

> Exact `Float'Image` formatting may vary slightly by compiler version — the important thing is the values and the `Constraint_Error` message.

### Step 5: Try the Compile-Time Check

Temporarily uncomment this line near the top of `cockpit_telemetry.adb`:

```ada
-- Bad_Altitude : Altitude_Type := 70_000;  -- static value out of range
```

Run `alr build` again. The compiler should reject the build with a constraint error message pointing at that line — because `70_000` is a **static** literal outside `0 .. 60_000`, GNAT catches it before the program ever runs. Re-comment the line afterward so the build succeeds again.

### Step 6: Run and Debug from VS Code

Reuse the `.vscode` setup from Module 1:

1. Add a second configuration to `.vscode/launch.json`, alongside `"Debug flight_deck"`:

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

   > On Windows, set `"program"` to `${workspaceFolder}/bin/cockpit_telemetry.exe` and `"miDebuggerPath"` to `gdb.exe`, matching the pattern from Module 1.

2. Open `src/cockpit_telemetry.adb` and set a breakpoint on the line:

   ```ada
   Boosted_Speed := Current_Speed + 900;
   ```

3. Select **"Debug cockpit_telemetry"** in the Run and Debug dropdown and press `F5`.
4. Execution pauses at the breakpoint, before the out-of-range assignment happens. Step **Over** (`F10`) that line and watch the debugger jump into the `exception` handler as `Constraint_Error` is raised — a direct, visual confirmation of Ada's run-time constraint checking in action.

---

## Lab Checklist

- [ ] `cockpit_telemetry.adb` added to `flight_deck/src/`.
- [ ] `flight_deck.gpr` updated to list both mains.
- [ ] `alr build` compiles both `flight_deck` and `cockpit_telemetry` successfully.
- [ ] Running `cockpit_telemetry` prints the full telemetry snapshot, including the caught `Constraint_Error`.
- [ ] Uncommenting `Bad_Altitude` demonstrates a **compile-time** constraint failure; re-commenting restores a clean build.
- [ ] The `Boosted_Speed` assignment demonstrates a **run-time** constraint failure, caught by an exception handler.
- [ ] `launch.json` extended with a `"Debug cockpit_telemetry"` configuration.
- [ ] Breakpoint set on the `Boosted_Speed` assignment; debugging confirms the `Constraint_Error` is raised at that line.

**End of Lab.**
