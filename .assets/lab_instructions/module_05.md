<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 05: Modular Programming</h1>

## Goals

The lab packages the five air-data values scattered across separate
variables in Module 4 into a single record type. The subprograms
refactored in Module 4 are updated to accept and return that record
instead of individual scalar parameters. A fixed-size array of records
then accumulates a log of every simulated in-flight event, each entry a
full copy of the air data and its computed results at the moment the
event occurred.

## Requirements

- Define a record type containing airspeed, altitude, g-force,
  temperature, and angle of attack.
- Define a second record type pairing one instance of the air-data record
  with its calculated safety ratio and stall-risk flag, forming a single
  loggable event.
- Define a fixed-size, single-dimensional array type of the event-log
  record, sized to the existing event count, and declare one array
  variable of that type.
- Populate the array during the in-flight event loop, one entry per
  event, with a full copy of the air data and results current at that
  point. No entry references another entry, and no entry changes after
  the loop assigns it.
- After the event loop completes, traverse the array by index and report
  a summary of every logged entry.

## Instructions

1. Open `flight_deck.adb`.
2. Declare `type Air_Data_Type is record ... end record`, with five
   components: `Airspeed : Airspeed_Type`, `Altitude : Altitude_Type`,
   `G_Force : G_Force_Type`, `Temperature : Float`, and
   `Angle_Of_Attack : Integer`. This record replaces the separate
   `Current_Airspeed`, `Current_Altitude`, `Current_G_Force`, and
   `Current_Angle_Of_Attack` variables from Module 4, and absorbs the
   standalone `Temperature` variable as well; remove all five of those
   declarations.
3. Declare `type Event_Log_Type is record ... end record`, with three
   components: `Data : Air_Data_Type`, `Safety_Ratio : Float`, and
   `Stall_Risk : Boolean`. One record now carries an air-data snapshot
   together with what that snapshot produced.
4. Declare `type Event_Log_Array is array (1 .. Event_Count) of
   Event_Log_Type`. The bound relies on the existing `Event_Count`
   constant and on the default array index base of 1; no explicit lower
   bound needs stating beyond what the range already provides.
5. Declare `Event_Log : Event_Log_Array` at the procedure level, replacing
   nothing; this is new state the log did not previously have.
6. Change `Safety_Ratio` to take a single parameter,
   `Data : Air_Data_Type`, in place of the three separate scalar
   parameters from Module 4. Reference `Data.Airspeed`, `Data.G_Force`,
   and `Data.Temperature` inside the body using the component selection
   operator.
7. Change `Is_Stall_Risk` to take `Ratio : Float` and
   `Data : Air_Data_Type`. Reference `Data.Angle_Of_Attack` inside the
   body.
8. Change `Report_Attitude` to take `Data : in Air_Data_Type`. Reference
   `Data.Angle_Of_Attack` inside the `case` statement.
9. Leave `Report_Posture` and both `Report_Event` overloads as declared
   in Module 4; none of the three depends on the air-data fields.
10. Declare a new procedure, `Report_Log`, taking `Log : in
    Event_Log_Array`. Iterate with `for Index in Log'Range loop`, printing
    the airspeed, altitude, and safety ratio stored at `Log(Index).Data`
    and `Log(Index).Safety_Ratio` on each pass. The `'Range` attribute
    tracks the array bounds directly from the array itself, so the loop
    needs no separate reference to `Event_Count`.
11. Change `Apply_Increments` to take a single parameter,
    `Data : in out Air_Data_Type`. Reference `Data.Airspeed`,
    `Data.G_Force`, and `Data.Angle_Of_Attack` on both sides of each
    assignment. `Data.Altitude` and `Data.Temperature` receive no
    increment, matching Module 4.
12. Change `Initialize_Telemetry` from a procedure into a function
    returning `Air_Data_Type`. Retain the same five default parameters
    from Module 4, adding `Starting_Altitude : Altitude_Type := 20_000`
    and renaming `Starting_G_Force`'s companions to match the new field
    set. Build the return value with a named-association record
    aggregate, `(Airspeed => Starting_Airspeed, Altitude =>
    Starting_Altitude, G_Force => Starting_G_Force, Temperature =>
    Starting_Temperature, Angle_Of_Attack => Starting_Angle)`, rather than
    assigning through `out` parameters. The function builds a complete
    record and returns it by value.
13. Change `Run_Flight_Events` to take `Data : in out Air_Data_Type` and
    `Log : in out Event_Log_Array`. Inside the per-event `declare` block,
    after computing `Ratio` and `Risk`, add `Log(Event) := (Data => Data,
    Safety_Ratio => Ratio, Stall_Risk => Risk)` before the call to
    `Apply_Increments`. The assignment copies the current state of `Data`
    into the array; the copy holds steady even after `Apply_Increments`
    changes `Data` on the next line. Replace the call to `Report_Attitude`
    so it passes `Data` rather than a bare angle value.
14. In the executable part of `flight_deck`, declare
    `Current_Air_Data : Air_Data_Type := Initialize_Telemetry;` in place
    of the four removed scalar variables, calling the function with no
    override arguments. Move this declaration, and the call it contains,
    ahead of the constant-and-telemetry dump section, since that section
    now reads several of its values from the record the call produces.
15. In the dump section, replace the line printing the old `Temperature`
    variable with one printing `Current_Air_Data.Temperature`. Add a line
    printing `Current_Air_Data.Altitude`, closing a gap from Module 4,
    where altitude was tracked but never actually reported.
16. Replace every remaining reference to `Current_Airspeed`,
    `Current_G_Force`, and `Current_Angle_Of_Attack` in the executable
    part, including the airspeed-fraction calculation, with
    `Current_Air_Data.Airspeed`, `Current_Air_Data.G_Force`, and
    `Current_Air_Data.Angle_Of_Attack`.
17. Change the call inside `Simulation_Batches` to
    `Run_Flight_Events (Current_Air_Data, Event_Log)`. Immediately after
    that call, add a call to `Report_Log (Event_Log)`, so each batch
    prints its live per-event detail followed by a full recap read back
    from the array.
18. Compile and run the program. Confirm the live per-event output
    matches Module 4, and confirm the new recap printed after each batch
    shows eight entries whose airspeed values descend in the same
    increments applied during the loop.
19. Set a breakpoint on the `Log(Event) := ...` assignment. Launch the
    debugger and inspect `Data` and `Log` side by side across two or
    three iterations. Confirm each array entry keeps the values it was
    assigned, unaffected by the increments applied to `Data` afterward.

## Notes

- The array uses a constrained type, `array (1 .. Event_Count) of
  Event_Log_Type`, rather than an unconstrained declaration. Unconstrained
  arrays earn their keep when different objects of the same array type
  need different lengths; every event log in this lab holds exactly
  `Event_Count` entries, so a fixed bound is the more direct choice.
- Bounded and unbounded string types receive no new treatment here. The
  fixed one-character `Response` string from Module 3 remains the extent
  of string handling until Module 8 revisits text input and output in
  depth.

- Ada, prior to the Ada 2012 revision, permitted only `in` mode
  parameters on functions; `out` and `in out` function parameters became
  legal only with that revision. `Safety_Ratio` and `Is_Stall_Risk` use
  `in` mode regardless, consistent with Module 4's decision to keep
  computation functions free of side effects, independent of which
  Ada revision permits otherwise.
- Every value entering `Event_Log` arrives by direct assignment of a
  complete record.

## Solution

```ada
with Ada.Text_IO;                      use Ada.Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

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

   type Flight_Mode_Type is (Nav, Dogfight, Landing);
   Flight_Mode : Flight_Mode_Type := Nav;

   Weapons_Armed : Boolean := False;

   Wing_Loading      : Float;
   Airspeed_Fraction : Float;

   Base_Stall_Speed : constant Float := 150.0; -- knots, 1g sea level

   Airspeed_Increment : constant Integer := -50;
   G_Force_Increment  : constant Float   := 0.5;
   Angle_Increment    : constant Integer := 1;
   Event_Count        : constant Integer := 8;

   Continue_Simulation : Boolean := True;

   -- Composite types -----------------------------------------------------

   type Air_Data_Type is record
      Airspeed        : Airspeed_Type;
      Altitude        : Altitude_Type;
      G_Force         : G_Force_Type;
      Temperature     : Float;
      Angle_Of_Attack : Integer;
   end record;

   type Event_Log_Type is record
      Data         : Air_Data_Type;
      Safety_Ratio : Float;
      Stall_Risk   : Boolean;
   end record;

   type Event_Log_Array is array (1 .. Event_Count) of Event_Log_Type;

   Event_Log : Event_Log_Array;

   -- Subprogram declarations --------------------------------------------

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

   procedure Report_Log (Log : in Event_Log_Array) is
   begin
      Put_Line("Flight Data Recorder Summary");
      for Index in Log'Range loop
         Put_Line("  Log " & Integer'Image(Index) &
                  ": Airspeed " & Integer'Image(Log(Index).Data.Airspeed) &
                  " kt, Altitude " & Integer'Image(Log(Index).Data.Altitude) &
                  " ft, Ratio " & Float'Image(Log(Index).Safety_Ratio));
      end loop;
   end Report_Log;

   procedure Apply_Increments (Data : in out Air_Data_Type) is
   begin
      Data.Airspeed        := Data.Airspeed + Airspeed_Increment;
      Data.G_Force         := Data.G_Force + G_Force_Increment;
      Data.Angle_Of_Attack := Data.Angle_Of_Attack + Angle_Increment;
   end Apply_Increments;

   function Initialize_Telemetry
     (Starting_Airspeed    : Airspeed_Type := 900;
      Starting_Altitude    : Altitude_Type := 20_000;
      Starting_G_Force     : G_Force_Type  := 1.0;
      Starting_Temperature : Float         := 15.0;
      Starting_Angle       : Integer       := 5) return Air_Data_Type
   is
   begin
      return (Airspeed        => Starting_Airspeed,
              Altitude        => Starting_Altitude,
              G_Force         => Starting_G_Force,
              Temperature     => Starting_Temperature,
              Angle_Of_Attack => Starting_Angle);
   end Initialize_Telemetry;

   procedure Run_Flight_Events
     (Data : in out Air_Data_Type;
      Log  : in out Event_Log_Array) is
   begin
      In_Flight_Events :
      for Event in 1 .. Event_Count loop

         declare
            Ratio : Float   := Safety_Ratio(Data);
            Risk  : Boolean := Is_Stall_Risk(Ratio, Data);
         begin
            if Risk or else Ratio < 1.2 then
               Report_Event(Event, Risk, Ratio);
            else
               Report_Event(Event, Risk);
            end if;

            Report_Attitude(Data);
            Report_Posture(Flight_Mode);

            Log(Event) := (Data         => Data,
                            Safety_Ratio => Ratio,
                            Stall_Risk   => Risk);
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
