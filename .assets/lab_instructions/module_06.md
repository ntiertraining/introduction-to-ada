<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 06: Composite Types (Records and Arrays)</h1>

## Goals

The lab replaces the by-value event log built in Module 5 with an array of
access values, each referencing an `Event_Log_Type` object allocated on
the heap. Building an entry becomes an allocation returned by reference
rather than a record copied into place. A second pass over the array
dereferences each entry and recomputes its result from the referenced
data, rather than only re-printing what Module 5 already stored.

## Requirements

- Change `Event_Log_Array` from an array of `Event_Log_Type` records to an
  array of access values designating `Event_Log_Type` objects.
- Allocate each event's `Event_Log_Type` object dynamically inside the
  subprogram that builds it, and pass back an access value referencing
  that object, rather than returning or assigning a record copy.
- Update every reference to a log entry, including the reporting loop, to
  work through the access value rather than through a record field
  directly.
- Add a loop that walks the array, dereferences each non-null entry, and
  performs the safety-ratio and stall-risk calculation again from the
  referenced air data, reporting the recomputed result alongside the
  value stored at allocation time.

## Instructions

1. Open `flight_deck.adb`. Add a `with` clause
   for `Ada.Unchecked_Deallocation` above the procedure declaration; no
   `use` clause applies, since the package supplies a generic procedure
   rather than a set of directly visible names. An access type in Ada
   stays associated with one designated type and one storage pool for its
   entire existence, checked by the compiler at every assignment; this is
   the guarantee a raw pointer in a weakly typed language does not carry,
   and it is why Ada calls the type an access type rather than a pointer.
2. Immediately after `Event_Log_Type`, declare `type Event_Log_Access is
   access Event_Log_Type`. Written plainly, with no `all` or `constant`
   qualifier, this is a pool-specific access type: it may reference only
   objects allocated by `new Event_Log_Type` from the default storage
   pool, never an object declared on the stack or in a data segment. That
   restriction is acceptable here, since every log entry originates from
   an allocator in this same lab.
3. Change `Event_Log_Array` to `array (1 .. Event_Count) of
   Event_Log_Access`, replacing the record element type from Module 5
   with the new access type.
4. Change the `Event_Log` declaration to `Event_Log : Event_Log_Array :=
   (others => null)`. An access value defaults to `null` without an
   explicit initializer; writing it out states plainly that every slot
   starts empty, ahead of the first allocation.
5. Immediately after the `Event_Log` declaration, instantiate the
   deallocation generic: `procedure Free is new Ada.Unchecked_Deallocation
   (Event_Log_Type, Event_Log_Access)`. Freeing an allocated object in Ada
   always goes through an instantiation of this library generic, tied to
   one specific designated type and access type pair; generics receive
   full treatment in Module 7, and this is the one unavoidable early use
   of the pattern, needed here to avoid leaking memory across simulation
   batches.
6. Declare a function named `Build_Event_Log`, taking `Data :
   Air_Data_Type`, `Ratio : Float`, and `Risk : Boolean`, returning
   `Event_Log_Access`. The body allocates and returns in one statement:
   `return new Event_Log_Type'(Data => Data, Safety_Ratio => Ratio,
   Stall_Risk => Risk)`. The object exists on the heap from this point
   forward; the function hands back a reference to it rather than a copy
   of it.
7. Declare a procedure named `Print_Log_Entry`, taking `Entry_Ref :
   access Event_Log_Type`. The parameter uses an anonymous access type,
   not `Event_Log_Access` by name; a value of the named access type
   converts to an anonymous access parameter of the same designated type
   automatically, so no conversion appears at the call site later. Inside
   the body, check `Entry_Ref = null` first and report an empty slot;
   otherwise report airspeed and altitude read from `Entry_Ref.Data`,
   which is accepted shorthand, current since Ada 2005, for
   `Entry_Ref.all.Data`.
8. Update `Report_Log` to call `Print_Log_Entry (Log(Index))` inside the
   existing `for Index in Log'Range loop`. Immediately after that call,
   guard with `if Log(Index) /= null then`, and inside the guard,
   recompute a fresh `Safety_Ratio` and `Is_Stall_Risk` from
   `Log(Index).Data`, the same functions carried over from Module 5
   unchanged. Report the freshly computed ratio next to the ratio stored
   in `Log(Index).Safety_Ratio`, plus whether the two match. Comparing two
   `Float` values for exact equality is normally unreliable; it holds
   here only because both values come from the same deterministic
   calculation run twice on the same inputs, with no rounding introduced
   between the two calls.
9. Update `Run_Flight_Events`. Immediately before the line that builds a
   new log entry, add `if Log(Event) /= null then Free(Log(Event)); end
   if;`. Follow it with `Log(Event) := Build_Event_Log(Data, Ratio,
   Risk);`. Without the guarded `Free` call, each rerun of
   `Simulation_Batches` would overwrite a slot's access value with a
   fresh allocation while the previous object at that slot remained
   allocated and now unreachable: a leak of one `Event_Log_Type` object
   per slot, per batch.
10. Compile and run the program. Confirm the live per-event output and
    the recap match Module 5 in content, now sourced through
    dereferenced access values instead of copied fields. Answer the
    batch prompt with `Y` two or three times and confirm the recap after
    each batch still reports eight entries with no growth in memory
    behavior attributable to abandoned allocations.
11. Set a breakpoint inside `Build_Event_Log`, on the `return` statement.
    Launch the debugger and step through three or four calls across two
    batches. Inspect the access value returned on each call; confirm the
    underlying address differs each time a fresh object is allocated, and
    confirm the address for a given slot changes between batches, since
    `Free` released the prior object before the new allocation replaced
    it.

## Notes


- `Event_Log_Access` stays pool-specific throughout; `access all`, which
  can reference a stack, data-segment, or heap object interchangeably,
  does not appear. Every object this lab references originates from
  `new`, so the broader reach of `access all` would add a capability
  nothing here exercises.

  access parameter deliberately, to show a named access type promoting
  into it without ceremony. Every other access-typed parameter in this
  lab could have used the anonymous form as well; `Event_Log_Access`
  appears by name elsewhere mainly so the array declaration and the
  deallocation instantiation have a type to refer to.

## Solution

```ada
with Ada.Text_IO;                      use Ada.Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Unchecked_Deallocation;

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

   -- Pool-specific access type: may reference only Event_Log_Type
   -- objects allocated by "new" from the default storage pool.
   type Event_Log_Access is access Event_Log_Type;

   type Event_Log_Array is array (1 .. Event_Count) of Event_Log_Access;

   Event_Log : Event_Log_Array := (others => null);

   procedure Free is new Ada.Unchecked_Deallocation
     (Event_Log_Type, Event_Log_Access);

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

   function Build_Event_Log
     (Data  : Air_Data_Type;
      Ratio : Float;
      Risk  : Boolean) return Event_Log_Access is
   begin
      return new Event_Log_Type'(Data         => Data,
                                  Safety_Ratio => Ratio,
                                  Stall_Risk   => Risk);
   end Build_Event_Log;

   -- Anonymous access parameter: a value of the named type
   -- Event_Log_Access promotes into this automatically at the call site.
   procedure Print_Log_Entry (Entry_Ref : access Event_Log_Type) is
   begin
      if Entry_Ref = null then
         Put_Line("  (empty log slot)");
      else
         -- Entry_Ref.Data is shorthand, current since Ada 2005, for
         -- Entry_Ref.all.Data.
         Put_Line("  Airspeed " & Integer'Image(Entry_Ref.Data.Airspeed) &
                  " kt, Altitude " & Integer'Image(Entry_Ref.Data.Altitude) &
                  " ft");
      end if;
   end Print_Log_Entry;

   procedure Report_Log (Log : in Event_Log_Array) is
   begin
      Put_Line("Flight Data Recorder Summary");
      for Index in Log'Range loop
         Print_Log_Entry(Log(Index));

         if Log(Index) /= null then
            declare
               Recomputed_Ratio : constant Float :=
                 Safety_Ratio(Log(Index).Data);
               Recomputed_Risk : constant Boolean :=
                 Is_Stall_Risk(Recomputed_Ratio, Log(Index).Data);
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

            if Log(Event) /= null then
               Free(Log(Event));
            end if;
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
