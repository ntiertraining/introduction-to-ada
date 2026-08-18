<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 04: Subprograms</h1>

[Return to list of module lab instructions](/README.md#module-lab-instructions)

## Goals

The lab decomposes the monolithic `flight_deck` procedure from Module 3
into a set of procedures and functions. Actions move into procedures.
Computations move into functions. Mutable telemetry state moves between
subprograms exclusively through parameters, never through direct reference
to an enclosing variable.

## Requirements

- Move the starting values for airspeed, g-force, and angle of attack into
  a subprogram.
- Move the per-event increment of airspeed, g-force, and angle of attack
  into a subprogram.
- Move the finite in-flight event loop into a subprogram.
- Have the main procedure call the initialization subprogram, then the
  loop subprogram, in that order.
- Use `in out` parameters on every subprogram that moves telemetry data
  into and back out of it. No subprogram reaches outside itself to modify
  `Current_Airspeed`, `Current_G_Force`, or `Current_Angle_Of_Attack`
  directly.

## Instructions

1. Open `flight_deck.adb`. Everything below adds
   subprogram declarations to the existing declarative part; no separate
   file and no package enter this lab.
2. Declare a function named `Safety_Ratio`, taking `Airspeed : Airspeed_Type`,
   `G_Force : G_Force_Type`, and `Temp : Float`, returning `Float`. Move the
   Kelvin conversion, air density, and stall speed calculations from Module
   3 into local variables declared inside this function, not at the
   procedure level. The function reads only its parameters and returns a
   single value; it touches no telemetry variable directly, which keeps it
   usable and testable in isolation from the rest of the program.
3. Declare a function named `Is_Stall_Risk`, taking `Ratio : Float` and
   `Angle_Of_Attack : Integer`, returning `Boolean`. Move the `or else`
   condition from Module 3 into this function body unchanged.
4. Declare a procedure named `Report_Attitude`, taking
   `Angle_Of_Attack : in Integer`. Move the range-based `case` statement
   from Module 3 into this procedure body unchanged.
5. Declare a procedure named `Report_Posture`, taking
   `Mode : in Flight_Mode_Type`. Move the `case` statement grouping `Nav`
   and `Landing` with `|` into this procedure body unchanged.
6. Declare two procedures sharing the name `Report_Event`, distinguished
   by parameter list:
   - `Report_Event (Event : in Integer; Risk : in Boolean)` prints a
     one-line NOMINAL or STALL WARNING message with no ratio detail.
   - `Report_Event (Event : in Integer; Risk : in Boolean; Ratio : in Float)`
     prints the same message with the safety ratio appended, and prints
     CAUTION rather than NOMINAL when `Risk` is false but the ratio still
     runs close to the threshold.
   Ada resolves which `Report_Event` applies from the number and type of
   arguments supplied at the call site; no separate name is needed for
   the second form.
7. Declare a procedure named `Apply_Increments`, taking
   `Airspeed : in out Airspeed_Type`, `G_Force : in out G_Force_Type`, and
   `Angle_Of_Attack : in out Integer`. Move the three increment
   assignments from Module 3 into this procedure body. Reference
   `Airspeed_Increment`, `G_Force_Increment`, and `Angle_Increment`
   directly inside the body without passing them as parameters; their
   values never change during a run, so passing them adds nothing.
8. Declare a procedure named `Initialize_Telemetry`, taking
   `Airspeed : out Airspeed_Type`, `G_Force : out G_Force_Type`,
   `Angle_Of_Attack : out Integer`, followed by three additional
   parameters carrying default values: `Starting_Airspeed : Airspeed_Type
   := 900`, `Starting_G_Force : G_Force_Type := 1.0`, and
   `Starting_Angle : Integer := 5`. Assign each `out` parameter from its
   corresponding default parameter in the body. A caller supplying no
   extra arguments gets the values above; a caller wishing to start a
   batch at different conditions may override one or more explicitly.
9. Declare a procedure named `Run_Flight_Events`, taking
   `Airspeed : in out Airspeed_Type`, `G_Force : in out G_Force_Type`, and
   `Angle_Of_Attack : in out Integer`. Move the `In_Flight_Events` `for`
   loop from Module 3 into this procedure body, retaining its label. Keep
   the per-event `declare` block from Module 3 inside the loop, but
   populate it now with two local variables, `Ratio` and `Risk`,
   initialized by calls to `Safety_Ratio` and `Is_Stall_Risk`. Within the
   block, call `Report_Event` with three arguments when `Risk` is true or
   `Ratio` runs below 1.2, and with two arguments otherwise. Follow the
   block, still inside the loop, with calls to `Report_Attitude` and
   `Report_Posture`. Close the loop body with a call to
   `Apply_Increments`, passing the three `in out` parameters through.
10. Declare every subprogram in the order given above. `Run_Flight_Events`
    calls each of the others, so Ada requires those bodies to appear
    first in the declarative part; a subprogram cannot be called before
    its declaration is visible.
11. In the executable part of `flight_deck`, replace the direct
    assignment of starting values with a call to
    `Initialize_Telemetry (Current_Airspeed, Current_G_Force,
    Current_Angle_Of_Attack)`, supplying no override arguments.
12. Replace the `In_Flight_Events` loop, now relocated into
    `Run_Flight_Events`, with a single call: `Run_Flight_Events
    (Current_Airspeed, Current_G_Force, Current_Angle_Of_Attack)`, placed
    inside the existing `Simulation_Batches` `while` loop in the position
    the inline loop previously occupied.
13. Compile and run the program. Confirm the reported sequence of events
    matches Module 3 output exactly; the refactor changes structure, not
    behavior.
14. Set a breakpoint inside `Apply_Increments`. Launch the debugger and
    step through several calls. Confirm the `in out` parameters show the
    caller's current values on entry and the caller's variables reflect
    the modification on return, without any global variable involved in
    the exchange.

<br>

![Stop](../images/stop.png)
<font size="+1">Congratulations! You have completed this lab.</font>

[Return to list of module lab instructions](/README.md#module-lab-instructions)

## Notes

- A separate file for these subprograms is not part of this lab. The
  outline schedules file splitting alongside package specifications and
  bodies in Module 7; introducing it here would front-run that material.
- Recursion does not appear in this decomposition. `Run_Flight_Events`
  processes a known, finite event count, which is exactly the case
  iteration handles correctly and recursion handles only by manufacturing
  a call stack the problem does not need.
- Variable shadowing is avoided by construction rather than demonstrated:
  every subprogram parameter name chosen above (`Airspeed`, `G_Force`,
  `Angle_Of_Attack`, `Ratio`, `Risk`) could collide with an outer-scope
  identifier if reused carelessly. Ada offers no general mechanism to
  reach past a shadowing parameter to the outer object of the same simple
  name, so the safer discipline is choosing names that do not collide in
  the first place, illustrated here rather than stated as a rule.
- `Safety_Ratio` takes `Temp` as a parameter rather than reading
  `Temperature` directly, even though `Temperature` remains visible from
  the nesting. A function that depends only on its arguments produces the
  same result every time it runs with the same inputs, a property worth
  preserving now; Module 10 substitutes exactly this kind of function
  with an injected test double.
- `Report_Event` demonstrates overloading; `Initialize_Telemetry`
  demonstrates default parameters. Both solve a similar-sounding problem,
  a subprogram behaving differently depending on what the caller
  supplies, through two different mechanisms, deliberately kept distinct
  here rather than collapsed into one pattern.

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
   Temperature     : Float := 15.0;     -- degrees Celsius, standard day

   type Flight_Mode_Type is (Nav, Dogfight, Landing);
   Flight_Mode : Flight_Mode_Type := Nav;

   Weapons_Armed : Boolean := False;

   Current_Airspeed : Airspeed_Type;
   Current_Altitude : Altitude_Type := 20_000;
   Current_G_Force  : G_Force_Type;

   Wing_Loading      : Float;
   Airspeed_Fraction : Float;

   Base_Stall_Speed : constant Float := 150.0; -- knots, 1g sea level

   Airspeed_Increment : constant Integer := -50;
   G_Force_Increment  : constant Float   := 0.5;
   Angle_Increment    : constant Integer := 1;
   Event_Count        : constant Integer := 8;

   Current_Angle_Of_Attack : Integer;

   Continue_Simulation : Boolean := True;

   -- Subprogram declarations --------------------------------------------

   function Safety_Ratio
     (Airspeed : Airspeed_Type;
      G_Force  : G_Force_Type;
      Temp     : Float) return Float
   is
      Temperature_Kelvin : Float;
      Air_Density         : Float;
      Stall_Speed          : Float;
   begin
      Temperature_Kelvin := Temp + 273.15;
      Air_Density         := 288.15 / Temperature_Kelvin;
      Stall_Speed          := Base_Stall_Speed *
                                 Sqrt(G_Force / Air_Density);
      return Float(Airspeed) / Stall_Speed;
   end Safety_Ratio;

   function Is_Stall_Risk
     (Ratio           : Float;
      Angle_Of_Attack : Integer) return Boolean is
   begin
      return Ratio < 1.0 or else Angle_Of_Attack > Critical_Angle_Of_Attack;
   end Is_Stall_Risk;

   procedure Report_Attitude (Angle_Of_Attack : in Integer) is
   begin
      case Angle_Of_Attack is
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

   procedure Apply_Increments
     (Airspeed        : in out Airspeed_Type;
      G_Force         : in out G_Force_Type;
      Angle_Of_Attack : in out Integer) is
   begin
      Airspeed        := Airspeed + Airspeed_Increment;
      G_Force         := G_Force + G_Force_Increment;
      Angle_Of_Attack := Angle_Of_Attack + Angle_Increment;
   end Apply_Increments;

   procedure Initialize_Telemetry
     (Airspeed          : out Airspeed_Type;
      G_Force           : out G_Force_Type;
      Angle_Of_Attack   : out Integer;
      Starting_Airspeed : Airspeed_Type := 900;
      Starting_G_Force  : G_Force_Type  := 1.0;
      Starting_Angle    : Integer       := 5) is
   begin
      Airspeed        := Starting_Airspeed;
      G_Force         := Starting_G_Force;
      Angle_Of_Attack := Starting_Angle;
   end Initialize_Telemetry;

   procedure Run_Flight_Events
     (Airspeed        : in out Airspeed_Type;
      G_Force         : in out G_Force_Type;
      Angle_Of_Attack : in out Integer) is
   begin
      In_Flight_Events :
      for Event in 1 .. Event_Count loop

         declare
            Ratio : Float   := Safety_Ratio(Airspeed, G_Force, Temperature);
            Risk  : Boolean := Is_Stall_Risk(Ratio, Angle_Of_Attack);
         begin
            if Risk or else Ratio < 1.2 then
               Report_Event(Event, Risk, Ratio);
            else
               Report_Event(Event, Risk);
            end if;

            Report_Attitude(Angle_Of_Attack);
            Report_Posture(Flight_Mode);
         end;

         Apply_Increments(Airspeed, G_Force, Angle_Of_Attack);

      end loop In_Flight_Events;
   end Run_Flight_Events;

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

   -- Both operands are already Float; no conversion required.
   Wing_Loading := Aircraft_Weight / Wing_Area;
   Put_Line("Wing Loading (lb/sq ft): " & Float'Image(Wing_Loading));

   Initialize_Telemetry(Current_Airspeed, Current_G_Force,
                         Current_Angle_Of_Attack);

   -- Current_Airspeed is Airspeed_Type, an Integer subtype. Max_Airspeed
   -- is a universal integer. Division against a Float denominator
   -- requires an explicit Float conversion on the integer operand; Ada
   -- performs no implicit conversion between numeric types.
   Airspeed_Fraction := Float(Current_Airspeed) / Float(Max_Airspeed);
   Put_Line("Airspeed Fraction Of Max: " & Float'Image(Airspeed_Fraction));

   Put_Line("---------------------------");
   Put_Line("Stall Risk Simulation");

   Simulation_Batches :
   while Continue_Simulation loop

      Run_Flight_Events(Current_Airspeed, Current_G_Force,
                         Current_Angle_Of_Attack);

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
