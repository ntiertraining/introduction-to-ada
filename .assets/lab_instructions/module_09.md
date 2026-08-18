<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; MModule 09: Exception Handling</h1>

[Return to list of module lab instructions](/README.md#module-lab-instructions)

## Goals

The lab introduces a simulated failure in the air data inertial reference
system: a random chance, checked every time the program advances the
telemetry for a new event, that the update does not arrive. A user-defined
exception represents that dropout. Handling happens close to where the
dropout occurs for an isolated case, and escalates to a controlled exit
when dropouts recur too often within one batch. The file-writing
subprograms from Module 8, a known source of I/O exceptions, gain
handling appropriate to what each failure means for the rest of the
program.

## Requirements

- Generate a random value inside the subprogram that advances telemetry
  by its fixed increments.
- When that value falls within a five-percent range, raise a
  user-defined exception representing an ADIRS (Air Data Inertial Reference System) timeout.
- Handle the exception close to where it is raised for an isolated
  occurrence: skip logging that event, and report an error message in
  its place.
- Track repeated occurrences within a batch. Once too many have happened,
  re-raise the exception to a higher level, which logs the situation and
  brings the program to a controlled stop rather than an unhandled crash.
- Add exception handling around the file-writing operations introduced in
  Module 8, since I/O operations are a well-known source of runtime
  exceptions.

## Instructions

1. In `telemetry_generation.ads`, declare `ADIRS_Timeout_Error :
   exception;` above the two existing subprogram declarations. A
   user-defined exception in Ada is its own distinct type, not derived
   from `Ada.Exceptions.Exception_Occurrence` or any other exception;
   declaring one costs nothing beyond the single line.
3. In `telemetry_generation.adb`, add a `with` clause for
   `Ada.Numerics.Float_Random`. Declare `Dropout_Probability : constant
   Float := 0.05;` and `Gen : Ada.Numerics.Float_Random.Generator;` at
   the package body level, above the subprogram bodies.
4. At the very end of the package body, after the last `end
   Apply_Increments;`, add a `begin ... end Telemetry_Generation;`
   elaboration part containing one statement: `Ada.Numerics.Float_Random.
   Reset (Gen);`. A package body's own elaboration code runs once, the
   first time the package comes into scope, which is exactly the point a
   generator needs seeding; seeding inside `Apply_Increments` itself
   would reseed on every call and defeat the randomness it is meant to
   provide.
5. Rewrite `Apply_Increments`. Before the three increment assignments,
   declare `Roll : constant Float := Ada.Numerics.Float_Random.Random
   (Gen);` and test it: `if Roll < Dropout_Probability then raise
   ADIRS_Timeout_Error with "ADIRS dropout triggered (roll " &
   Float'Image(Roll) & ")"; end if;`. The message text is the only
   content a raised exception carries in Ada; embedding the roll value
   in a fixed, readable format is what the Requirements call defining a
   format to carry data in the message.
6. Open `src/flight_deck.adb`. Add a `with` clause and a `use` clause for
   `Ada.Exceptions`. Add a `with` clause for `Ada.IO_Exceptions`, without
   a paired `use` clause; its two exceptions, `Name_Error` and
   `Use_Error`, appear in handlers below written out with the package
   name, in the same spirit `Flight_Physics` calls stayed qualified
   in Module 7.
7. Add `Timeout_Threshold : constant Natural := 3;` near the existing
   `Event_Count` declaration.
8. Restructure `Run_Flight_Events`'s loop body. Move the call to
   `Apply_Increments (Data)` to the first statement inside the `for
   Event in 1 .. Event_Count loop`, ahead of the existing `declare` block
   that computes `Ratio` and `Risk`. This reorders the cycle to match
   what it represents: ADIRS supplies a fresh reading first, and only
   once that reading is in hand does the rest of the cycle, calculation,
   reporting, and logging, have anything to work with. The Module 8
   ordering, where the increment ran last, has no natural place for a
   failed reading to skip the event it belongs to; this ordering does.
9. Wrap the `Apply_Increments` call and the `declare` block that follows
   it in an inner `begin ... exception ... end;`, nested inside the `for
   Event` loop, distinct from the loop itself. Declare `Timeout_Count :
   Natural := 0;` once, before the loop, so it accumulates across the
   whole batch rather than resetting every event.
10. Add one handler: `when Error : ADIRS_Timeout_Error =>`. Increment
    `Timeout_Count`. Report the event number and `Exception_Message
    (Error)` to the terminal as the error message the Requirements call
    for. No call to `Write_Event_Line`, `Free_Log_Entry`, or
    `Build_Event_Log` executes for this event; the exception transferred
    control out of the `declare` block before reaching any of them, which
    is what skips the log entry. Once the handler finishes, the `for`
    loop moves on to the next `Event` value on its own; no `exit` or
    other explicit step is needed. This is the concrete mechanism behind
    a comment made back in Module 3: Ada has no `continue` statement, but
    an exception handler that finishes without re-raising produces the
    same effect for the iteration it was raised in.
11. Inside that same handler, after reporting the message, test
    `Timeout_Count >= Timeout_Threshold`. When true, report that the
    threshold was reached, then execute a bare `raise;` with no
    exception name. A bare `raise` inside a handler re-raises the
    exception currently being handled, `ADIRS_Timeout_Error` in this
    case, preserving its original message, and sends it looking for a
    handler further out, past `Run_Flight_Events` entirely.
12. In the executable part of `flight_deck`, wrap the existing call to
    `Open_Log_File` in its own `begin ... exception ... end;`. Add one
    handler covering both exceptions at once: `when Error :
    Ada.IO_Exceptions.Name_Error | Ada.IO_Exceptions.Use_Error =>`,
    grouped with `|` since both indicate the file could not be created
    and both call for the same response here. Declare a small procedure,
    `Log_Fatal_Error (Context : in String; Error : in
    Exception_Occurrence)`, ahead of the executable part, printing
    `Context`, `Exception_Name (Error)`, and `Exception_Message (Error)`
    together; `Exception_Name` is what lets a single handler covering two
    exceptions report which one actually fired. Call `Log_Fatal_Error`
    from the `Open_Log_File` handler, then execute a bare `return;`,
    ending the procedure immediately; without a log file, none of what
    follows can do what this program exists to do.
13. Wrap `Simulation_Batches` and the two calls immediately after it,
    `Close_Log_File` and `Echo_Log_File`, in one more `begin ...
    exception ... end;`. Add a handler, `when Error : ADIRS_Timeout_Error
    =>`, calling `Log_Fatal_Error ("Repeated ADIRS timeouts forced an
    early stop", Error)` followed by `Close_Log_File`. This is the higher
    level the Requirements describe: the exception that escalated out of
    `Run_Flight_Events` lands here, gets logged, and the program reaches
    `Put_Line ("Simulation complete.")` afterward and ends normally,
    rather than terminating on an unhandled exception with no message a
    person watching the terminal could act on.
14. Open `event_file_logging.adb`. Add a `with` clause for
    `Ada.IO_Exceptions`, unqualified use omitted for the same reason as
    step 6. Leave `Open_Log_File` exactly as Module 8 left it, with no
    exception handling of its own. A reusable I/O package generally
    should not decide, on the caller's behalf, what a failure to create a
    file means for the rest of the program; that decision belongs to
    whatever called `Open_Log_File`, which is exactly what step 12
    handles.
15. In `Echo_Log_File`, add `exception when Ada.IO_Exceptions.Name_Error
    => Put_Line ("Log file '" & File_Name & "' could not be reopened for
    review; skipping echo.");` after the existing body. Unlike
    `Open_Log_File`, this failure has one sensible response regardless of
    what called it: skip the echo, say so, and let the program continue;
    that single, context-independent response is exactly the case where
    handling inside the package, rather than at the call site, makes
    sense.
16. Compile and run the program several times. Most runs complete with
    zero or one ADIRS timeout message and finish normally. To exercise
    the escalation path deliberately, temporarily change
    `Dropout_Probability` to `0.5`, rerun, and confirm the program logs
    three timeout messages, reports the threshold reached, and ends
    through the `Simulation_Batches` handler rather than reaching
    `Echo_Log_File`. Restore `Dropout_Probability` to `0.05` afterward.
17. Set a breakpoint on the `raise;` statement inside
    `Run_Flight_Events`'s handler. With `Dropout_Probability` still
    raised for testing, launch the debugger and confirm `Timeout_Count`
    reads at least `Timeout_Threshold` when the breakpoint is reached.
    Step forward and watch execution leave `Run_Flight_Events` entirely,
    landing in the handler added in step 13.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

[Return to list of module lab instructions](/README.md#module-lab-instructions)

## Notes

- Apply_Increments could have signaled a dropout by returning a status
  value instead of raising an exception, but a procedure with `in out`
  telemetry data and no return type has no natural channel for that
  signal beyond adding a parameter purely to carry error status, one more
  piece of state every caller would need to check on every call whether
  or not a dropout occurred. Raising an exception is what the outline
  calls an out-of-band mechanism: the failure travels a path separate
  from the normal flow of parameters and return values, checked only
  where a handler exists to check it.
- `ADIRS_Timeout_Error` carries no data beyond its message text; Ada
  gives a user-defined exception nothing else to set. Any additional
  detail belongs in that message, formatted consistently, exactly as
  step 5 does with the roll value.
- Write_Event_Line and Close_Log_File receive no exception handling of
  their own in this lab. Both can raise, most plausibly
  `Ada.IO_Exceptions.Device_Error` from a full or failing disk, but that
  class of failure is rare enough mid-run, and severe enough when it
  happens, that a handler at every individual I/O call would add
  clutter without adding much real protection; a broader `when others`
  handler around the whole simulation would be the natural next step if
  this program needed to survive that case gracefully, left for whenever
  the course revisits robustness in more depth.
- The reordering in step 8 changes what Event 1 reports compared to
  Module 8: it now reflects one increment applied before its first
  report, rather than the unmodified starting values. This is a
  deliberate consequence of making the exception's placement meaningful,
  not an oversight; a run of this lab's solution will not match a Module
  8 run event-for-event even with dropouts disabled entirely.

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

   ADIRS_Timeout_Error : exception;

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
with Ada.Numerics.Float_Random;

package body Telemetry_Generation is

   Airspeed_Increment : constant Integer := -50;
   G_Force_Increment  : constant Float   := 0.5;
   Angle_Increment    : constant Integer := 1;

   -- Simulated ADIRS dropout probability, checked once per increment
   -- cycle.
   Dropout_Probability : constant Float := 0.05;

   Gen : Ada.Numerics.Float_Random.Generator;

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
      Roll : constant Float := Ada.Numerics.Float_Random.Random(Gen);
   begin
      if Roll < Dropout_Probability then
         raise ADIRS_Timeout_Error with
           "ADIRS dropout triggered (roll " & Float'Image(Roll) & ")";
      end if;

      Data.Airspeed        := Data.Airspeed + Airspeed_Increment;
      Data.G_Force         := Data.G_Force + G_Force_Increment;
      Data.Angle_Of_Attack := Data.Angle_Of_Attack + Angle_Increment;
   end Apply_Increments;

begin
   Ada.Numerics.Float_Random.Reset(Gen);
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
with Ada.IO_Exceptions;

package body Event_File_Logging is

   Log_File : File_Type;

   -- No exception handling here: a caller that cannot create the log
   -- file needs to decide what that means for the rest of the program,
   -- a policy decision this package leaves to whoever calls it.
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

   exception
      when Ada.IO_Exceptions.Name_Error =>
         Put_Line("Log file '" & File_Name &
                  "' could not be reopened for review; skipping echo.");
   end Echo_Log_File;

end Event_File_Logging;
```

### src/flight_deck.adb

```ada
with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Exceptions;   use Ada.Exceptions;
with Ada.IO_Exceptions;

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

   Event_Count       : constant Integer := 8;
   Timeout_Threshold : constant Natural := 3;

   Continue_Simulation : Boolean := True;

   type Event_Log_Array is array (1 .. Event_Count) of Event_Log_Access;

   Event_Log : Event_Log_Array := (others => null);

   procedure Log_Fatal_Error
     (Context : in String;
      Error   : in Exception_Occurrence) is
   begin
      Put_Line("FATAL: " & Context & " - " &
               Exception_Name(Error) & ": " & Exception_Message(Error));
   end Log_Fatal_Error;

   procedure Run_Flight_Events
     (Data : in out Air_Data_Type;
      Log  : in out Event_Log_Array)
   is
      Timeout_Count : Natural := 0;
   begin
      In_Flight_Events :
      for Event in 1 .. Event_Count loop

         begin
            Apply_Increments(Data);

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

         exception
            when Error : ADIRS_Timeout_Error =>
               Timeout_Count := Timeout_Count + 1;
               Put_Line("Event " & Integer'Image(Event) &
                        ": ADIRS TIMEOUT - " & Exception_Message(Error));

               if Timeout_Count >= Timeout_Threshold then
                  Put_Line("ADIRS timeout threshold reached (" &
                           Natural'Image(Timeout_Count) &
                           " in this batch); escalating.");
                  raise;
               end if;
         end;

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

   begin
      Open_Log_File;
   exception
      when Error : Ada.IO_Exceptions.Name_Error | Ada.IO_Exceptions.Use_Error =>
         Log_Fatal_Error("Unable to open flight event log file", Error);
         return;
   end;

   Put_Line("---------------------------");
   Put_Line("Stall Risk Simulation");

   begin
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

   exception
      when Error : ADIRS_Timeout_Error =>
         Log_Fatal_Error("Repeated ADIRS timeouts forced an early stop",
                          Error);
         Close_Log_File;
   end;

   Put_Line("Simulation complete.");

end Flight_Deck;
```
