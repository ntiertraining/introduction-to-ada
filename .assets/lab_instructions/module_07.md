<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 07: Exceptions and Error Handling</h1>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Goals

The lab divides the single-file `flight_deck` program from Module 6 into a
set of packages, organized by responsibility, each with its own
specification and, where the package holds executable code, its own
body. Data generation and data packaging separate into two distinct
subprograms in two distinct packages: one produces raw air data, another
wraps that data and its computed results into a loggable object.

## Requirements

- Divide the program into separate compilation units organized by type of
  responsibility, rather than one monolithic procedure.
- Expose each package's related subprograms and types through its
  specification; keep implementation detail that callers do not need out
  of that specification.
- Keep a subprogram that generates air data distinct from a subprogram
  that packages air data and a computed result into a loggable object.
- Update the GNAT project file, so the build locates source files no
  longer sitting in a single flat directory.

## Instructions

1. Create five subdirectories under `src/`: `src/types/`,
   `src/physics/`, `src/generation/`, `src/reporting/`, and
   `src/logging/`. `flight_deck.adb` itself stays directly under `src/`.
2. Open `flight_deck.gpr`. Locate the `Source_Dirs` attribute. Change its
   value to `("src/**")` if it does not already use that recursive form;
   the double asterisk tells GNAT to search every subdirectory beneath
   `src/`, not just `src/` itself. Without this change, the compiler
   never finds the files created in the next steps.
3. In `src/types/`, create `telemetry_types.ads`. Move `Min_Airspeed`,
   `Max_Airspeed`, `Min_Altitude`, `Max_Altitude`, `Min_G_Force`,
   `Max_G_Force`, `Critical_Angle_Of_Attack`, `Airspeed_Type`,
   `Altitude_Type`, `G_Force_Type`, `Wing_Area`, `Angle_Of_Attack`,
   `Flight_Mode_Type`, and `Air_Data_Type` into this file, inside
   `package Telemetry_Types is ... end Telemetry_Types;`. This package
   holds only type and constant declarations, no subprogram, so it needs
   no matching body file; a package with a specification and no body is
   legal whenever the specification declares nothing that requires
   executable code.
4. In `src/physics/`, create `flight_physics.ads`, withing and using
   `Telemetry_Types`. Declare `function Safety_Ratio (Data :
   Air_Data_Type) return Float;` and `function Is_Stall_Risk (Ratio :
   Float; Data : Air_Data_Type) return Boolean;` as the entire visible
   interface.
5. In the same directory, create `flight_physics.adb`. Move the bodies of
   both functions from Module 6 here unchanged, withing and using
   `Ada.Numerics.Elementary_Functions`. Move `Base_Stall_Speed` here as
   well, declared in the package body rather than the specification;
   nothing outside `Flight_Physics` calls `Safety_Ratio`'s internals
   directly, so nothing outside needs to see the constant it depends on.
6. In `src/generation/`, create `telemetry_generation.ads`, withing and
   using `Telemetry_Types`. Declare `Initialize_Telemetry`, keeping its
   five default parameters from Module 6, and `Apply_Increments (Data :
   in out Air_Data_Type)`. These two subprograms generate and modify raw
   air data; neither one wraps a result into a loggable object, which is
   `Event_Logging`'s job, declared later.
7. In the same directory, create `telemetry_generation.adb`. Move
   `Airspeed_Increment`, `G_Force_Increment`, and `Angle_Increment` here
   as private constants, along with the bodies of `Initialize_Telemetry`
   and `Apply_Increments`. Default parameter expressions belong only in
   the specification; repeat the parameter names and types in the body
   without the `:=` defaults.
8. In `src/reporting/`, create `flight_reporting.ads`, withing and using
   `Telemetry_Types`. Declare `Report_Attitude`, `Report_Posture`, and
   both overloads of `Report_Event`, matching their Module 6 profiles.
9. In the same directory, create `flight_reporting.adb`, withing and
   using `Ada.Text_IO`. Move the four subprogram bodies here unchanged.
10. In `src/logging/`, create `event_logging.ads`, withing and using
    `Telemetry_Types`. Declare `Event_Log_Type` and `Event_Log_Access` as
    in Module 6. Declare `function Build_Event_Log (Data : Air_Data_Type;
    Ratio : Float; Risk : Boolean) return Event_Log_Access;`,
    `procedure Free_Log_Entry (Item : in out Event_Log_Access);`, and
    `procedure Print_Log_Entry (Entry_Ref : access Event_Log_Type);`.
    `Build_Event_Log` is the subprogram that packages air data and a
    computed result into the loggable object the Requirements call for.
11. In the same directory, create `event_logging.adb`, withing
    `Ada.Text_IO` and `Ada.Unchecked_Deallocation`. Move the
    `Ada.Unchecked_Deallocation` instantiation here, and the body of
    `Print_Log_Entry`, unchanged from Module 6. Write `Build_Event_Log`'s
    body as in Module 6. Write `Free_Log_Entry`'s body to check `Item /=
    null` and call the instantiated `Free` procedure only when the check
    passes; Module 6 placed that same null check at every call site
    inside `flight_deck.adb`, and moving it into `Free_Log_Entry` means
    every caller gets the check automatically, with one place to
    maintain it.
12. Rewrite `src/flight_deck.adb`. Replace the type, subtype, and
    constant declarations moved out in steps 3 through 11 with `with`
    clauses for `Telemetry_Types`, `Telemetry_Generation`,
    `Flight_Reporting`, and `Event_Logging`, each paired with a `use`
    clause. Add a `with` clause for `Flight_Physics` without a paired
    `use` clause; every call to `Safety_Ratio` or `Is_Stall_Risk` inside
    `flight_deck.adb` from this point forward reads
    `Flight_Physics.Safety_Ratio` and `Flight_Physics.Is_Stall_Risk`, the
    package name written out at the call site. The four packages given a
    `use` clause supply names not easily confused with anything else in
    this file; the two physics functions sit closer to the center of
    what this file actually computes, and spelling out their package
    keeps that computation visually distinct from reporting and logging
    calls around it.
13. Keep `Event_Count`, `Continue_Simulation`, `Aircraft_Weight`,
    `Flight_Mode`, `Weapons_Armed`, `Wing_Loading`, and
    `Airspeed_Fraction` declared directly in `flight_deck.adb`; none of
    the five packages needs them.
14. Keep the `Event_Log_Array` type declaration and the `Event_Log`
    variable in `flight_deck.adb`, now built from
    `Event_Logging.Event_Log_Access` rather than a locally declared
    access type. `Event_Logging` exposes the access type without fixing
    an array length, so any client program can size its own array to its
    own needs; this program is the client, and `Event_Count` is this
    program's concern, not the package's.
15. Keep `Report_Log` and `Run_Flight_Events` declared directly in
    `flight_deck.adb`, updated to call `Flight_Physics.Safety_Ratio`,
    `Flight_Physics.Is_Stall_Risk`, and `Event_Logging.Free_Log_Entry` in
    place of the null-check-then-free pair from Module 6. Both
    subprograms depend on the concrete `Event_Log_Array` type declared in
    this file, which is exactly why they stay here rather than moving
    into `Event_Logging`: a package built around one array length would
    not serve a second client program with a different one.
16. Compile the project. Confirm the build now compiles six separate
    units, `telemetry_types`, `flight_physics`, `telemetry_generation`,
    `flight_reporting`, `event_logging`, and `flight_deck`, and confirm
    running the program reproduces the output from Module 6 exactly; the
    lab reorganizes where code lives, not what the program does.
17. Edit only `flight_physics.adb`, changing `Base_Stall_Speed` to a
    different value. Recompile. Confirm GNAT recompiles `flight_physics`
    and `flight_deck`, since `flight_deck` calls into `flight_physics`,
    but does not recompile `telemetry_generation`, `flight_reporting`, or
    `event_logging`, none of which depends on `flight_physics` at all.
    This is separate compilation in practice: a change confined to one
    package's body affects only that package and whatever calls it.
    Restore `Base_Stall_Speed` afterward.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Notes

- Generics do not appear in this lab, even though the Module 7 topics
  introduce them. The outline calls for that exclusion explicitly: the
  package interface is this lab's subject, and a generic sorting package
  or similar example would shift focus onto a second, unrelated topic in
  the same lab.
- `Event_Logging` exposes `Event_Log_Type` and `Event_Log_Access` as
  ordinary public types rather than as a private type with hidden
  representation. A fully opaque type would need accessor functions for
  every field `flight_deck.adb` currently reads directly, such as
  `Log(Index).Data.Airspeed`; that encapsulation step is a reasonable
  next move for this package, left for whenever the course takes up
  private types directly, rather than folded in here unannounced.
- `Free_Log_Entry` still relies on the `Ada.Unchecked_Deallocation`
  instantiation introduced in Module 6. That instantiation now lives
  entirely inside `event_logging.adb`; nothing in `flight_deck.adb`
  references `Ada.Unchecked_Deallocation` any longer, which is one
  concrete benefit of the split: a generic instantiation that previewed
  Module 7 material ahead of schedule is now fully contained inside the
  package that owns the type it deallocates.

## Solution

### flight_deck.gpr (relevant excerpt)

```ada
project Flight_Deck is

   for Source_Dirs use ("src/**");
   for Main use ("flight_deck.adb");

   -- remaining project attributes unchanged from the Alire-generated file

end Flight_Deck;
```

### src/types/telemetry_types.ads

```ada
package Telemetry_Types is

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

   type Flight_Mode_Type is (Nav, Dogfight, Landing);

   type Air_Data_Type is record
      Airspeed        : Airspeed_Type;
      Altitude        : Altitude_Type;
      G_Force         : G_Force_Type;
      Temperature     : Float;
      Angle_Of_Attack : Integer;
   end record;

end Telemetry_Types;
```

### src/physics/flight_physics.ads

```ada
with Telemetry_Types; use Telemetry_Types;

package Flight_Physics is

   function Safety_Ratio (Data : Air_Data_Type) return Float;

   function Is_Stall_Risk
     (Ratio : Float;
      Data  : Air_Data_Type) return Boolean;

end Flight_Physics;
```

### src/physics/flight_physics.adb

```ada
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Flight_Physics is

   Base_Stall_Speed : constant Float := 150.0; -- knots, 1g sea level

   function Safety_Ratio (Data : Air_Data_Type) return Float
   is
      Temperature_Kelvin : Float;
      Air_Density         : Float;
      Stall_Speed          : Float;
   begin
      Temperature_Kelvin := Data.Temperature + 273.15;
      Air_Density         := 288.15 / Temperature_Kelvin;
      Stall_Speed          := Base_Stall_Speed *
                                 Sqrt(Data.G_Force / Air_Density);
      return Float(Data.Airspeed) / Stall_Speed;
   end Safety_Ratio;

   function Is_Stall_Risk
     (Ratio : Float;
      Data  : Air_Data_Type) return Boolean is
   begin
      return Ratio < 1.0 or else Data.Angle_Of_Attack > Critical_Angle_Of_Attack;
   end Is_Stall_Risk;

end Flight_Physics;
```

### src/generation/telemetry_generation.ads

```ada
with Telemetry_Types; use Telemetry_Types;

package Telemetry_Generation is

   function Initialize_Telemetry
     (Starting_Airspeed    : Airspeed_Type := 900;
      Starting_Altitude    : Altitude_Type := 20_000;
      Starting_G_Force     : G_Force_Type  := 1.0;
      Starting_Temperature : Float         := 15.0;
      Starting_Angle       : Integer       := 5) return Air_Data_Type;

   procedure Apply_Increments (Data : in out Air_Data_Type);

end Telemetry_Generation;
```

### src/generation/telemetry_generation.adb

```ada
package body Telemetry_Generation is

   Airspeed_Increment : constant Integer := -50;
   G_Force_Increment  : constant Float   := 0.5;
   Angle_Increment    : constant Integer := 1;

   function Initialize_Telemetry
     (Starting_Airspeed    : Airspeed_Type;
      Starting_Altitude    : Altitude_Type;
      Starting_G_Force     : G_Force_Type;
      Starting_Temperature : Float;
      Starting_Angle       : Integer) return Air_Data_Type
   is
   begin
      return (Airspeed        => Starting_Airspeed,
              Altitude        => Starting_Altitude,
              G_Force         => Starting_G_Force,
              Temperature     => Starting_Temperature,
              Angle_Of_Attack => Starting_Angle);
   end Initialize_Telemetry;

   procedure Apply_Increments (Data : in out Air_Data_Type) is
   begin
      Data.Airspeed        := Data.Airspeed + Airspeed_Increment;
      Data.G_Force         := Data.G_Force + G_Force_Increment;
      Data.Angle_Of_Attack := Data.Angle_Of_Attack + Angle_Increment;
   end Apply_Increments;

end Telemetry_Generation;
```

### src/reporting/flight_reporting.ads

```ada
with Telemetry_Types; use Telemetry_Types;

package Flight_Reporting is

   procedure Report_Attitude (Data : in Air_Data_Type);
   procedure Report_Posture (Mode : in Flight_Mode_Type);
   procedure Report_Event (Event : in Integer; Risk : in Boolean);
   procedure Report_Event
     (Event : in Integer;
      Risk  : in Boolean;
      Ratio : in Float);

end Flight_Reporting;
```

### src/reporting/flight_reporting.adb

```ada
with Ada.Text_IO; use Ada.Text_IO;

package body Flight_Reporting is

   procedure Report_Attitude (Data : in Air_Data_Type) is
   begin
      case Data.Angle_Of_Attack is
         when 0 .. 10 =>
            Put_Line("  Attitude: normal");
         when 11 .. 14 =>
            Put_Line("  Attitude: approaching critical");
         when 15 .. 90 =>
            Put_Line("  Attitude: critical or beyond");
         when others =>
            Put_Line("  Attitude: invalid reading");
      end case;
   end Report_Attitude;

   procedure Report_Posture (Mode : in Flight_Mode_Type) is
   begin
      case Mode is
         when Nav | Landing =>
            Put_Line("  Posture: relaxed");
         when Dogfight =>
            Put_Line("  Posture: combat");
      end case;
   end Report_Posture;

   procedure Report_Event (Event : in Integer; Risk : in Boolean) is
   begin
      Put("Event " & Integer'Image(Event) & ": ");
      if Risk then
         Put_Line("STALL WARNING");
      else
         Put_Line("NOMINAL");
      end if;
   end Report_Event;

   procedure Report_Event
     (Event : in Integer;
      Risk  : in Boolean;
      Ratio : in Float) is
   begin
      Put("Event " & Integer'Image(Event) & ": ");
      if Risk then
         Put_Line("STALL WARNING - safety ratio " & Float'Image(Ratio));
      else
         Put_Line("CAUTION - safety ratio " & Float'Image(Ratio));
      end if;
   end Report_Event;

end Flight_Reporting;
```

### src/logging/event_logging.ads

```ada
with Telemetry_Types; use Telemetry_Types;

package Event_Logging is

   type Event_Log_Type is record
      Data         : Air_Data_Type;
      Safety_Ratio : Float;
      Stall_Risk   : Boolean;
   end record;

   -- Pool-specific access type: may reference only Event_Log_Type
   -- objects allocated by "new" from the default storage pool.
   type Event_Log_Access is access Event_Log_Type;

   function Build_Event_Log
     (Data  : Air_Data_Type;
      Ratio : Float;
      Risk  : Boolean) return Event_Log_Access;

   procedure Free_Log_Entry (Item : in out Event_Log_Access);

   procedure Print_Log_Entry (Entry_Ref : access Event_Log_Type);

end Event_Logging;
```

### src/logging/event_logging.adb

```ada
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Event_Logging is

   procedure Free is new Ada.Unchecked_Deallocation
     (Event_Log_Type, Event_Log_Access);

   function Build_Event_Log
     (Data  : Air_Data_Type;
      Ratio : Float;
      Risk  : Boolean) return Event_Log_Access is
   begin
      return new Event_Log_Type'(Data         => Data,
                                  Safety_Ratio => Ratio,
                                  Stall_Risk   => Risk);
   end Build_Event_Log;

   procedure Free_Log_Entry (Item : in out Event_Log_Access) is
   begin
      if Item /= null then
         Free(Item);
      end if;
   end Free_Log_Entry;

   procedure Print_Log_Entry (Entry_Ref : access Event_Log_Type) is
   begin
      if Entry_Ref = null then
         Put_Line("  (empty log slot)");
      else
         Put_Line("  Airspeed " & Integer'Image(Entry_Ref.Data.Airspeed) &
                  " kt, Altitude " & Integer'Image(Entry_Ref.Data.Altitude) &
                  " ft");
      end if;
   end Print_Log_Entry;

end Event_Logging;
```

### src/flight_deck.adb

```ada
with Ada.Text_IO; use Ada.Text_IO;

with Telemetry_Types;      use Telemetry_Types;
with Telemetry_Generation; use Telemetry_Generation;
with Flight_Reporting;     use Flight_Reporting;
with Event_Logging;        use Event_Logging;
with Flight_Physics;       -- no "use": calls stay qualified below

procedure Flight_Deck is

   Aircraft_Weight : Float := 26_500.0; -- pounds

   Flight_Mode : Flight_Mode_Type := Nav;

   Weapons_Armed : Boolean := False;

   Wing_Loading      : Float;
   Airspeed_Fraction : Float;

   Event_Count : constant Integer := 8;

   Continue_Simulation : Boolean := True;

   type Event_Log_Array is array (1 .. Event_Count) of Event_Log_Access;

   Event_Log : Event_Log_Array := (others => null);

   procedure Report_Log (Log : in Event_Log_Array) is
   begin
      Put_Line("Flight Data Recorder Summary");
      for Index in Log'Range loop
         Print_Log_Entry(Log(Index));

         if Log(Index) /= null then
            declare
               Recomputed_Ratio : constant Float :=
                 Flight_Physics.Safety_Ratio(Log(Index).Data);
               Recomputed_Risk : constant Boolean :=
                 Flight_Physics.Is_Stall_Risk(Recomputed_Ratio,
                                               Log(Index).Data);
            begin
               -- Exact Float equality is unreliable in general; it holds
               -- here only because both sides run the identical
               -- deterministic calculation on the identical inputs.
               Put_Line("    Recomputed Ratio: " &
                        Float'Image(Recomputed_Ratio) &
                        ", Stored Ratio: " &
                        Float'Image(Log(Index).Safety_Ratio) &
                        ", Match: " &
                        Boolean'Image(Recomputed_Ratio =
                                      Log(Index).Safety_Ratio));
            end;
         end if;
      end loop;
   end Report_Log;

   procedure Run_Flight_Events
     (Data : in out Air_Data_Type;
      Log  : in out Event_Log_Array) is
   begin
      In_Flight_Events :
      for Event in 1 .. Event_Count loop

         declare
            Ratio : Float   := Flight_Physics.Safety_Ratio(Data);
            Risk  : Boolean := Flight_Physics.Is_Stall_Risk(Ratio, Data);
         begin
            if Risk or else Ratio < 1.2 then
               Report_Event(Event, Risk, Ratio);
            else
               Report_Event(Event, Risk);
            end if;

            Report_Attitude(Data);
            Report_Posture(Flight_Mode);

            Free_Log_Entry(Log(Event));
            Log(Event) := Build_Event_Log(Data, Ratio, Risk);
         end;

         Apply_Increments(Data);

      end loop In_Flight_Events;
   end Run_Flight_Events;

   Current_Air_Data : Air_Data_Type := Initialize_Telemetry;

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
   Put_Line("Temperature (C): " & Float'Image(Current_Air_Data.Temperature));
   Put_Line("Current Altitude (ft): " &
            Integer'Image(Current_Air_Data.Altitude));

   Put_Line("Flight Mode: " & Flight_Mode_Type'Image(Flight_Mode));
   Put_Line("Weapons Armed: " & Boolean'Image(Weapons_Armed));

   -- Both operands are already Float; no conversion required.
   Wing_Loading := Aircraft_Weight / Wing_Area;
   Put_Line("Wing Loading (lb/sq ft): " & Float'Image(Wing_Loading));

   -- Current_Air_Data.Airspeed is Airspeed_Type, an Integer subtype.
   -- Max_Airspeed is a universal integer. Division against a Float
   -- denominator requires an explicit Float conversion on the integer
   -- operand; Ada performs no implicit conversion between numeric types.
   Airspeed_Fraction := Float(Current_Air_Data.Airspeed) / Float(Max_Airspeed);
   Put_Line("Airspeed Fraction Of Max: " & Float'Image(Airspeed_Fraction));

   Put_Line("---------------------------");
   Put_Line("Stall Risk Simulation");

   Simulation_Batches :
   while Continue_Simulation loop

      Run_Flight_Events(Current_Air_Data, Event_Log);
      Report_Log(Event_Log);

      declare
         Response        : String (1 .. 1);
         Characters_Read : Natural;
      begin
         Put("Run another batch of in-flight events? (Y/N): ");
         Get_Line(Response, Characters_Read);
         Continue_Simulation := Characters_Read >= 1
           and then (Response(1) = 'Y' or else Response(1) = 'y');
      end;

   end loop Simulation_Batches;

   Put_Line("Simulation complete.");

end Flight_Deck;
```
