<h1><img alt="nTier Logo" style="margin-bottom: -10px;" src="../images/ntier-logo.png">&nbsp;&nbsp; Module 3: Control Structures and Operators</h1>


## Goals

The lab extends the `flight_deck` procedure from Module 2 with a stall risk
calculation driven by airspeed, g-force, and angle of attack. A finite
sequence of simulated in-flight events feeds the calculation, with each
event evaluated and reported through conditional and looping constructs.
The formula used is a simplified, generalized approximation. It does not
produce accurate results for any specific airframe, such as an F-16, and
serves the exercise only.

## Requirements

- Calculate temperature in Kelvin from the existing `Temperature` variable:
  `Tk = Temperature + 273.15`.
- Calculate air density as `288.15 / Tk`.
- Calculate stall speed as a base stall speed multiplied by the square root
  of current g-force divided by air density.
- Calculate a safety ratio as current airspeed divided by stall speed.
- Determine stall risk as true when the safety ratio falls below 1.0, or
  when the current angle of attack exceeds the critical angle of attack
  constant from Module 2.
- Drive the calculation through a finite, fixed-count sequence of in-flight
  events. Each event adjusts current airspeed downward, current g-force
  upward, and current angle of attack upward by a fixed increment, then
  recalculates and reports the result.
- After the fixed sequence completes, prompt for terminal input to decide
  whether to run another sequence. Continue running sequences while the
  response indicates yes.
- Provide a means, once the sequence and prompt behavior are confirmed, to
  change the increment values and their direction, and observe the effect
  on the reported results.

## Instructions

1. Open `flight_deck.adb` from the Module 2 project. Add a `with` clause
   and a `use` clause for `Ada.Numerics.Elementary_Functions` above the
   procedure declaration. Explain in a comment why the predefined `**`
   operator does not serve here: the predefined exponentiation operator
   accepts only an `Integer` right operand, and a square root demands a
   fractional exponent, which forces reliance on the `Sqrt` function
   supplied by the library package instead.
2. Declare `Base_Stall_Speed : constant Float := 150.0` to represent a
   reference one-g, sea-level stall speed, in knots.
3. Declare four increment constants, using these exact names, referenced
   again if the increment values change later in the lab:
   - `Airspeed_Increment : constant Integer := -50`
   - `G_Force_Increment : constant Float := 0.5`
   - `Angle_Increment : constant Integer := 1`
   - `Event_Count : constant Integer := 8`
4. Declare `Current_Angle_Of_Attack : Integer := 5`. Reuse
   `Current_Airspeed`, `Current_G_Force`, `Angle_Of_Attack`, and
   `Critical_Angle_Of_Attack` from Module 2 without redeclaring them.
   Reset `Current_Airspeed` to a value comfortably above stall risk, such
   as 900, and `Current_G_Force` to 1.0, before the loop structure below.
5. Declare `Continue_Simulation : Boolean := True` above the executable
   part of the procedure.
6. Build an outer `while` loop, labeled `Simulation_Batches`, controlled
   by `Continue_Simulation`. A `while` loop fits this control: the number
   of batches depends on terminal input entered during execution, not on
   a count known in advance.
7. Inside `Simulation_Batches`, build an inner `for` loop, labeled
   `In_Flight_Events`, iterating a loop variable named `Event` across
   `1 .. Event_Count`.
8. Inside `In_Flight_Events`, open a declare block scoped to the single
   event. Declare, local to the block, `Temperature_Kelvin`,
   `Air_Density`, `Stall_Speed`, `Safety_Ratio`, all `Float`, and
   `Stall_Risk`, `Boolean`. Values calculated for one event have no
   bearing on the next; block scope enforces that boundary.
9. Within the block, calculate `Temperature_Kelvin`, `Air_Density`, and
   `Stall_Speed` per the Requirements. Convert `Current_G_Force` and
   `Air_Density` as needed for the `Sqrt` argument; both already share
   `Float`, so no conversion applies at this step.
10. Calculate `Safety_Ratio` as `Current_Airspeed` divided by
    `Stall_Speed`. `Current_Airspeed` is `Airspeed_Type`, an `Integer`
    subtype; apply an explicit `Float` conversion before dividing.
11. Assign `Stall_Risk` using the relational and logical operators
    directly: safety ratio below 1.0, `or else` current angle of attack
    greater than `Critical_Angle_Of_Attack`. Favor `or else` over `or`,
    since the second condition needs no evaluation once the first proves
    true.
12. Report the event outcome with an `if` statement carrying three
    branches: `Stall_Risk` true reports a stall warning; `Safety_Ratio`
    below 1.2 (and `Stall_Risk` false) reports a caution; the remaining
    case reports nominal margin. Build each message with the `&`
    concatenation operator rather than multiple `Put_Line` calls.
13. Below the `if` statement, still inside the block, add a `case`
    statement on `Current_Angle_Of_Attack` that reports an attitude
    category: `0 .. 10` reports normal, `11 .. 14` reports approaching
    critical, `15 .. 90` reports critical or beyond, and `when others`
    reports an invalid reading. The range syntax matches values falling
    between bounds without an entry for every discrete value.
14. Still inside the block, add a second `case` statement on
    `Flight_Mode`, established in Module 2. Group `Nav` and `Landing`
    together with the `|` operator to report a single relaxed-posture
    message; report `Dogfight` separately with its own message.
15. After the block closes, still inside `In_Flight_Events`, adjust
    `Current_Airspeed`, `Current_G_Force`, and `Current_Angle_Of_Attack`
    by their respective increment constants.
16. Close `In_Flight_Events`. Immediately after, prompt for terminal
    input asking whether to run another batch. Open a declare block
    scoped to the prompt. Declare a one-character `String` and a
    `Natural` for the count of characters read. Read the response with
    `Get_Line`. Assign `Continue_Simulation` true only when a character
    was read and that character equals `Y` or `y`; use `and then` so the
    character comparison never runs against an empty response.
17. Close `Simulation_Batches`. Compile and run the program. Answer the
    prompt with `Y` to confirm a second batch runs with airspeed, g-force,
    and angle of attack continuing from where the first batch left off.
    Answer with any other input to confirm the program ends cleanly.
18. Change `G_Force_Increment` to a negative value and rerun the program.
    Observe that a negative current g-force divided by air density
    produces a negative argument to `Sqrt`, which the elementary
    functions library rejects at runtime. Do not add handling for this
    condition; an unhandled runtime error at this point is expected, and
    it previews exception handling introduced in a later module. Restore
    `G_Force_Increment` to its original positive value afterward.
19. Change `Airspeed_Increment`, `Angle_Increment`, and `Event_Count` to
    several different values in turn. For each change, rerun the program
    and record how quickly the safety ratio crosses below 1.0 or the
    angle of attack crosses the critical threshold.

## Notes

- `Base_Stall_Speed` carries no value in the requirements. 150.0 knots
  serves as a plausible one-g, sea-level reference figure, chosen only to
  make the formula executable.
- The stall condition combines two signals of different units: safety
  ratio, a dimensionless number, and angle of attack, in degrees. The lab
  treats these as two independent risk indicators joined with `or else`,
  rather than a single comparable quantity.
- Square root uses `Ada.Numerics.Elementary_Functions.Sqrt`, not the
  predefined `**` operator. The predefined exponentiation operator accepts
  only an `Integer` right operand; a fractional exponent requires the
  library function instead.
- Reversing `G_Force_Increment` can drive a negative value into `Sqrt`,
  which raises an unhandled runtime error. Exception handling arrives in
  a later module, so the lab directs the developer to observe the failure rather
  than handle it, foreshadowing that later material without teaching it
  early.
- Two separate `case` statements cover angle-of-attack range buckets and
  flight-mode grouping. Angle of attack and flight mode do not share a
  type, so one `case` expression cannot serve both.

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

   Current_Airspeed : Airspeed_Type := 900;
   Current_Altitude : Altitude_Type := 20_000;
   Current_G_Force  : G_Force_Type  := 1.0;

   Wing_Loading      : Float;
   Airspeed_Fraction : Float;

   -- Module 3 additions -----------------------------------------------

   Base_Stall_Speed : constant Float := 150.0; -- knots, 1g sea level

   Airspeed_Increment : constant Integer := -50;
   G_Force_Increment  : constant Float   := 0.5;
   Angle_Increment    : constant Integer := 1;
   Event_Count        : constant Integer := 8;

   Current_Angle_Of_Attack : Integer := 5;

   Continue_Simulation : Boolean := True;

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

      In_Flight_Events :
      for Event in 1 .. Event_Count loop

         declare
            Temperature_Kelvin : Float;
            Air_Density        : Float;
            Stall_Speed         : Float;
            Safety_Ratio        : Float;
            Stall_Risk          : Boolean;
         begin
            Temperature_Kelvin := Temperature + 273.15;
            Air_Density        := 288.15 / Temperature_Kelvin;
            Stall_Speed        := Base_Stall_Speed *
                                     Sqrt(Current_G_Force / Air_Density);
            Safety_Ratio       := Float(Current_Airspeed) / Stall_Speed;

            Stall_Risk := Safety_Ratio < 1.0
              or else Current_Angle_Of_Attack > Critical_Angle_Of_Attack;

            Put("Event " & Integer'Image(Event) & ": ");
            if Stall_Risk then
               Put_Line("STALL WARNING - safety ratio " &
                        Float'Image(Safety_Ratio));
            elsif Safety_Ratio < 1.2 then
               Put_Line("CAUTION - safety ratio " &
                        Float'Image(Safety_Ratio));
            else
               Put_Line("NOMINAL - safety ratio " &
                        Float'Image(Safety_Ratio));
            end if;

            case Current_Angle_Of_Attack is
               when 0 .. 10 =>
                  Put_Line("  Attitude: normal");
               when 11 .. 14 =>
                  Put_Line("  Attitude: approaching critical");
               when 15 .. 90 =>
                  Put_Line("  Attitude: critical or beyond");
               when others =>
                  Put_Line("  Attitude: invalid reading");
            end case;

            case Flight_Mode is
               when Nav | Landing =>
                  Put_Line("  Posture: relaxed");
               when Dogfight =>
                  Put_Line("  Posture: combat");
            end case;
         end;

         Current_Airspeed := Current_Airspeed + Airspeed_Increment;
         Current_G_Force  := Current_G_Force + G_Force_Increment;
         Current_Angle_Of_Attack := Current_Angle_Of_Attack + Angle_Increment;

      end loop In_Flight_Events;

      declare
         Response       : String (1 .. 1);
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
