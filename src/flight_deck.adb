with Ada.Text_IO; use Ada.Text_IO;
--  use replaces the need for Ada.Text_IO.Put_Line

procedure Flight_Deck is

   --  declare min and max airspeed (120, 1175)
   Min_Airspeed : constant Integer := 120;
   Max_Airspeed : constant Integer := 1175;

   --  declare min and max altitude (300, 50000)
   Min_Altitude : constant Integer := 300;
   Max_Altitude : constant Integer := 50000;

   --  declare min and max g-force (-3, 7.3)
   Min_G_Force : constant Float := -3.0;
   Max_G_Force : constant Float := 7.3;

   --  declare critical angle of attack (15 degrees)
   Critical_Angle_Of_Attack : constant Float := 15.0;

   --  declare substypes for airspeed, altitude, and g-force
   subtype Airspeed_Type is Integer range Min_Airspeed .. Max_Airspeed;
   subtype Altitude_Type is Integer range Min_Altitude .. Max_Altitude;
   --  g-force is a float, so we need to declare a subtype for it as well
   subtype G_Force_Type is Float range Min_G_Force .. Max_G_Force;

   --  declare wing area of 300 square feet
   Wing_Area : constant Float := 300.0;

   --  declare angle of attack 15 degrees
   Angle_Of_Attack : constant Float := 15.0;

   --  declare weight of 26,500 pounds
   Aircraft_Weight : constant Float := 26500.0;

   --  declare a reasonable starting temperature in celsius (20 degrees)
   Starting_Temperature : constant Float := 20.0;

   --  declare type Flight_Mode_Type is (Nav, Dogfight, Landing)
   --  declare variable flight mode of type Flight_Mode_Type
   --  initialize flight mode to Nav
   type Flight_Mode_Type is (Nav, Dogfight, Landing);
   Flight_Mode : Flight_Mode_Type := Nav;

   --  declare weapons armed as boolean set initially to false
   Weapons_Armed : Boolean := False;

   --  declare working variables for subtypes
   Current_Airspeed : Airspeed_Type := Min_Airspeed;
   Current_Altitude : Altitude_Type := Min_Altitude;
   Current_G_Force : G_Force_Type := 0.0;

   --  declare wing loading variable as float
   Wing_Loading : Float;

   --  declare airspeed fraction variable as float
   Airspeed_Fraction : Float;
begin
   --  initialize avionics suite and display status messages
   Put_Line ("F-16 Avionics Suite Initializing...");
   Put_Line ("Radar................ OK");
   Put_Line ("Navigation Systems... OK");
   Put_Line ("Weapons Systems....... OK");
   Put_Line ("Power-On Self-Test Complete. Ready for flight.");
   Put_Line ("---------------------------------------------");

   --  report every constant and variable before calculations
   Put_Line ("Flight Deck Status Report:");
   Put_Line ("Min Airspeed: " & Integer'Image (Min_Airspeed) & " knots");
   Put_Line ("Max Airspeed: " & Integer'Image (Max_Airspeed) & " knots");
   Put_Line ("Min Altitude: " & Integer'Image (Min_Altitude) & " feet");
   Put_Line ("Max Altitude: " & Integer'Image (Max_Altitude) & " feet");
   Put_Line ("Min G-Force: " & Float'Image (Min_G_Force) & " g's");
   Put_Line ("Max G-Force: " & Float'Image (Max_G_Force) & " g's");
   Put_Line ("Critical Angle of Attack: " &
              Float'Image (Critical_Angle_Of_Attack) & " degrees");
   Put_Line ("Wing Area: " & Float'Image (Wing_Area) & " square feet");
   Put_Line ("Angle of Attack: " &
              Float'Image (Angle_Of_Attack) & " degrees");
   Put_Line ("Aircraft Weight: " &
              Float'Image (Aircraft_Weight) & " pounds");
   Put_Line ("Starting Temperature: " &
              Float'Image (Starting_Temperature) & " degrees Celsius");
   Put_Line ("Flight Mode: " & Flight_Mode_Type'Image (Flight_Mode));
   Put_Line ("Weapons Armed: " & Boolean'Image (Weapons_Armed));
   Put_Line ("Current Airspeed: " &
              Integer'Image (Current_Airspeed) & " knots");
   Put_Line ("Current Altitude: " &
              Integer'Image (Current_Altitude) & " feet");
   Put_Line ("Current G-Force: " & Float'Image (Current_G_Force) & " g's");
   Put_Line ("---------------------------------------------");

   --  calculate wing loading
   Wing_Loading := Aircraft_Weight / Wing_Area;

   --  calculate airspeed fraction
   Airspeed_Fraction := Float (Current_Airspeed) / Float (Max_Airspeed);

   --  report wing loading and airspeed fraction
   Put_Line ("Calculating Wing Loading and Airspeed Fraction...");
   Put_Line ("Wing Loading: " &
              Float'Image (Wing_Loading) & " pounds per square foot");
   Put_Line ("Airspeed Fraction: " & Float'Image (Airspeed_Fraction));
   Put_Line ("---------------------------------------------");

end Flight_Deck;