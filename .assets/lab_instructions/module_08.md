<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 08: Input/Output Operations</h1>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Goals

The lab adds a text file record of every simulated in-flight event,
written as each event happens, alongside the in-memory log the array
already keeps. The per-batch terminal summary that walked the array and
printed it is retired; a file, read back and echoed once the simulation
ends, takes its place as the record of what occurred.

## Requirements

- Write each event to a text file at the moment it happens, using a
  fixed, labeled line format applied consistently to every event.
- Continue saving each event into the array alongside the file write; the
  file supplements the array, it does not replace what the array holds.
- Start every run of the program with a clean log file; a previous run's
  entries never carry into the current one.
- Remove the subprogram that walked the array and printed a summary to
  the terminal; nothing in this lab prints from the array any longer.

## Instructions

1. Create a new subdirectory, `src/io/`.
2. Add `("src/**")` coverage already handles this new subdirectory
   automatically, since `Source_Dirs` already recurses; no `.gpr` change
   is needed this time.
3. In `src/io/`, create `event_file_logging.ads`, withing and using
   `Telemetry_Types`. Declare four subprograms: `procedure Open_Log_File
   (File_Name : in String := "flight_events.log");`, `procedure
   Write_Event_Line (Event : in Integer; Data : in Air_Data_Type; Ratio :
   in Float; Risk : in Boolean);`, `procedure Close_Log_File;`, and
   `procedure Echo_Log_File (File_Name : in String :=
   "flight_events.log");`. The default file name appears in two places
   deliberately, so a caller who supplies no argument to either opens and
   later echoes the same file without repeating the name at every call
   site.
4. In the same directory, create `event_file_logging.adb`, withing and
   using `Ada.Text_IO`. Declare `Log_File : File_Type;` at the top of the
   package body. A single file handle, held privately in the body, serves
   every call made through the package's four subprograms; nothing
   outside this package ever names `Log_File` directly.
5. Write `Open_Log_File`'s body as a single call: `Create (Log_File,
   Out_File, File_Name)`. `Create` always produces a new file, discarding
   any existing content at that path; this, rather than `Open` with
   `Append_File`, is what satisfies the requirement that every run starts
   with a clean log. `Append_File` mode exists for the opposite case,
   continuing a file across runs, which this lab specifically avoids.
6. Declare a function, private to the body and absent from the
   specification, `function Status_Label (Risk : Boolean; Ratio : Float)
   return String`, returning `"STALL WARNING"` when `Risk` is true,
   `"CAUTION"` when `Risk` is false and `Ratio` runs below 1.2, and
   `"NOMINAL"` otherwise. This mirrors the three-way message logic
   `Flight_Reporting.Report_Event` already applies to the terminal,
   applied here to the file instead.
7. Write `Write_Event_Line`'s body as one `Put_Line (Log_File, ...)`
   call, concatenating labeled fields with `&`: `EVENT`, `AIRSPEED`,
   `ALTITUDE`, `GFORCE`, `AOA`, `TEMP`, `RATIO`, and `STATUS`, the last
   supplied by a call to `Status_Label`. `Put_Line` appends the line
   terminator automatically, consistent with treating the file as
   line-oriented data, one event per line. Follow the `Put_Line` call
   with `Flush (Log_File)`, so each event reaches disk immediately rather
   than waiting in a buffer an interrupted run might lose.
8. Write `Close_Log_File`'s body as a single call to `Close (Log_File)`.
9. Write `Echo_Log_File`'s body to open a second, independent `File_Type`
   in `In_File` mode against the same `File_Name`, print a heading, then
   loop `while not End_Of_File (Echo_File) loop`, reading each line with
   the function form of `Get_Line` and printing it indented. Calling
   `Get_Line` again after `End_Of_File` reports true raises
   `Ada.IO_Exceptions.End_Error`; the `while` condition exists precisely
   to keep that call from ever happening. Count the lines read and print
   the total after the loop, then close the second handle.
10. Open `src/flight_deck.adb`. Add a `with` clause and a `use` clause
    for `Event_File_Logging`.
11. Remove the `Report_Log` procedure declaration entirely, along with
    its call inside `Simulation_Batches`. The array it walked,
    `Event_Log`, keeps accumulating entries exactly as in Module 7;
    only the code that printed the array's contents is gone.
12. In `Run_Flight_Events`, immediately after the existing calls to
    `Report_Event`, `Report_Attitude`, and `Report_Posture`, add a call
    to `Write_Event_Line (Event, Data, Ratio, Risk)`. This call sits
    beside, not in place of, the existing `Free_Log_Entry` and
    `Build_Event_Log` calls that populate `Event_Log`; the event now
    reaches the terminal, the file, and the array on every pass through
    the loop.
13. In the executable part of `flight_deck`, call `Open_Log_File` once,
    with no argument, immediately before the `Put_Line ("Stall Risk
    Simulation")` line and before `Simulation_Batches` begins.
14. After `Simulation_Batches` ends, call `Close_Log_File`, then
    `Echo_Log_File`, both with no argument, before the final `Put_Line
    ("Simulation complete.")`.
15. Compile and run the program. Confirm a file named
    `flight_events.log` appears in the working directory after the run,
    containing one line per event across every batch answered `Y`.
    Confirm the terminal, after the last batch, echoes that same file
    back with a matching line count.
16. Run the program a second time without deleting the file from the
    first run. Confirm the second run's file contains only the second
    run's events; `Create` discarded the first run's content before the
    first event of the second run was written.
17. Set a breakpoint on the `Flush (Log_File)` line. Launch the debugger,
    run one event, and open `flight_events.log` in a separate editor tab
    while execution sits at the breakpoint. Confirm the line for that
    event is already visible in the file on disk, before the program
    continues; without the explicit `Flush`, the line might sit in a
    buffer, invisible to a separate reader, until the file closes.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

<span>[ <a href="../../README.md#module-lab-instructions">Lab table of contents</a> ]</span>

## Notes

- Binary file formats receive no implementation here, consistent with
  the outline's own instruction to introduce the concept rather than
  build with it. `Ada.Sequential_IO`, `Ada.Direct_IO`, and
  `Ada.Streams.Stream_IO` each read and write fixed-structure binary
  records instead of text lines, trading the space and speed of a
  compact representation for the requirement that every reader agree in
  advance on field sizes and byte order; a flight system with tight
  storage or timing budgets might reasonably choose one of the three over
  the text format this lab uses.
- `Echo_Log_File` reads every line back as a `String` and prints it
  without parsing it into typed fields again. Reconstructing an
  `Air_Data_Type` value from the text this lab writes would need explicit
  delimiter parsing and calls to `Integer'Value` and `Float'Value`, work
  this lab does not require and does not perform; the file exists here as
  a durable record for a person to read, not as a data source the
  program reads back into its own types.
- The bonus outlined in the course notes, a generic composite event
  parameterized over a fuel type or radar type, does not appear. Module 7
  deferred generics on the same grounds this lab does: the topic has not
  yet had its own dedicated treatment, and folding it into a lab about
  file output would ask two unfamiliar ideas to land at once.
- `Open_Log_File` performs no check for whether `Create` succeeded, and
  `Echo_Log_File` performs no check for whether `Open` found the file it
  expects. Both calls can raise an exception, `Open_Log_File` if the
  working directory is not writable, `Echo_Log_File` if
  `flight_events.log` was somehow removed between the write and the
  read; Module 9 introduces exception handling and explicitly revisits
  file I/O as a source of exceptions worth handling, which is where this
  gap gets closed.

## Solution

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

### src/io/event_file_logging.ads

```ada
with Telemetry_Types; use Telemetry_Types;

package Event_File_Logging is

   procedure Open_Log_File (File_Name : in String := "flight_events.log");

   procedure Write_Event_Line
     (Event : in Integer;
      Data  : in Air_Data_Type;
      Ratio : in Float;
      Risk  : in Boolean);

   procedure Close_Log_File;

   procedure Echo_Log_File (File_Name : in String := "flight_events.log");

end Event_File_Logging;
```

### src/io/event_file_logging.adb

```ada
with Ada.Text_IO; use Ada.Text_IO;

package body Event_File_Logging is

   Log_File : File_Type;

   procedure Open_Log_File (File_Name : in String := "flight_events.log") is
   begin
      Create(Log_File, Out_File, File_Name);
   end Open_Log_File;

   function Status_Label (Risk : Boolean; Ratio : Float) return String is
   begin
      if Risk then
         return "STALL WARNING";
      elsif Ratio < 1.2 then
         return "CAUTION";
      else
         return "NOMINAL";
      end if;
   end Status_Label;

   procedure Write_Event_Line
     (Event : in Integer;
      Data  : in Air_Data_Type;
      Ratio : in Float;
      Risk  : in Boolean) is
   begin
      Put_Line(Log_File,
        "EVENT "     & Integer'Image(Event)              &
        " | AIRSPEED " & Integer'Image(Data.Airspeed)     & "kt" &
        " | ALTITUDE " & Integer'Image(Data.Altitude)     & "ft" &
        " | GFORCE "   & Float'Image(Data.G_Force)               &
        " | AOA "      & Integer'Image(Data.Angle_Of_Attack) & "deg" &
        " | TEMP "     & Float'Image(Data.Temperature)     & "C"  &
        " | RATIO "    & Float'Image(Ratio)                       &
        " | STATUS "   & Status_Label(Risk, Ratio));
      Flush(Log_File);
   end Write_Event_Line;

   procedure Close_Log_File is
   begin
      Close(Log_File);
   end Close_Log_File;

   procedure Echo_Log_File (File_Name : in String := "flight_events.log") is
      Echo_File  : File_Type;
      Line_Count : Natural := 0;
   begin
      Open(Echo_File, In_File, File_Name);
      Put_Line("Flight Event Log Contents (" & File_Name & ")");

      while not End_Of_File(Echo_File) loop
         declare
            Line : constant String := Get_Line(Echo_File);
         begin
            Line_Count := Line_Count + 1;
            Put_Line("  " & Line);
         end;
      end loop;

      Close(Echo_File);
      Put_Line("Total lines: " & Natural'Image(Line_Count));
   end Echo_Log_File;

end Event_File_Logging;
```

### src/flight_deck.adb

```ada
with Ada.Text_IO; use Ada.Text_IO;

with Telemetry_Types;      use Telemetry_Types;
with Telemetry_Generation; use Telemetry_Generation;
with Flight_Reporting;     use Flight_Reporting;
with Event_Logging;        use Event_Logging;
with Event_File_Logging;   use Event_File_Logging;
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

            Write_Event_Line(Event, Data, Ratio, Risk);

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

   Open_Log_File;

   Put_Line("---------------------------");
   Put_Line("Stall Risk Simulation");

   Simulation_Batches :
   while Continue_Simulation loop

      Run_Flight_Events(Current_Air_Data, Event_Log);

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

   Close_Log_File;
   Echo_Log_File;

   Put_Line("Simulation complete.");

end Flight_Deck;
```
