module smartAlarmClock(SW, GPIO_1, CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR , VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);

 input [9:0] SW;

 input [3:0] KEY;

 input CLOCK_50;

 inout [35:0] GPIO_1;

  

 output [6:0] HEX0;

 output [6:0] HEX1;

 output [6:0] HEX2;

 output [6:0] HEX3;

 output [6:0] HEX4;

 output [6:0] HEX5;

 output [9:0] LEDR;


// components for the VGA display    

wire [3:0] hour2, hour1;

     output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;

     output [9:0] VGA_R, VGA_G, VGA_B;

   

     wire reset, ld_sDown, ld_sUp, ld_sRight, ld_sLeft, ld_d, ld_drawNew, ld_reset_old, plot, enable, up_flag, right_flag, 

     ld_done, clear1, ld_square_completion, ld_move_status;

 


     wire [2:0] output_colour, in_color;

     wire [7:0] x;

     wire [6:0] y;

     reg [26:0] count1;

     reg [2:0] coloreg;


     assign reset = KEY[0];

     assign in_color = coloreg;

     always @(posedge CLOCK_50) begin


if ((hour2 == 4'd2 && hour1 >= 4'd0) || ((hour2 == 4'd0) && (hour1 <= 4'd7)))

     coloreg <= 3'b111;

else coloreg <= 3'b110;


       if(clear1 == 1'b1)

            count1 <= 26'd0;

       else

            count1 <= count1 + 1'b1;

     end

     

     assign clear1 = enable;

 

     assign enable = (count1 == 26'd12500000) ? 1'b1 : 1'b0;            

     

     vga_adapter VGA(.resetn(reset), .clock(CLOCK_50), .colour(output_colour), .x(x), .y(y), .plot(plot),

          .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N),

          .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));

               

     defparam VGA.RESOLUTION = "160x120";

     defparam VGA.MONOCHROME = "FALSE";

     defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;

     defparam VGA.BACKGROUND_IMAGE = "black.mif";

 

     control c0(.clock(CLOCK_50), .reset(reset), .ld_sDown(ld_sDown), .ld_sUp(ld_sUp), .ld_sRight(ld_sRight), 

          .ld_sLeft(ld_sLeft), .ld_d(ld_d), .ld_drawNew(ld_drawNew), .ld_reset_old(ld_reset_old), .ld_done(ld_done),

          .plot(plot), .enable(enable), .up_flag(up_flag), .right_flag(right_flag), .ld_square_completion(ld_square_completion), .ld_move_status(ld_move_status));

 

     datapath d0(.clock(CLOCK_50), .reset(reset), .ld_sDown(ld_sDown), .ld_sUp(ld_sUp) , .ld_sRight(ld_sRight), .ld_sLeft(ld_sLeft), .ld_d(ld_d),

          .ld_drawNew(ld_drawNew), .ld_reset_old(ld_reset_old), .ld_done(ld_done),.up_flag(up_flag), .right_flag(right_flag), .output_colour(output_colour), 

          .output_x(x), .output_y(y), .colour(in_color), .ld_square_completion(ld_square_completion), .ld_move_status(ld_move_status), .hour2(hour2), .hour1(hour1), .settinguptime(SW[0]), .alarmactive(alarmactive));




//Clock Component
wire alarmactive;
assign alarmactive = LEDR[0];

 clocktime d1 (CLOCK_50, SW[0], SW[9], SW[4:1], ~KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR[0], GPIO_1[35:1], GPIO_1[0], hour2, hour1);

 endmodule


 // Clock Modules

module clocktime (clk, stop, switch9, timechange, Ky, dig0, dig1, dig2, dig3, dig4, dig5, light, GPIO_Wire, motionport, hour2, hour1);

 input clk, stop, switch9, motionport;

 input [3:0] timechange;

 input [3:0] Ky;

 inout [35:1] GPIO_Wire;

 output light;

 output [6:0] dig0, dig1, dig2, dig3, dig4, dig5;

 wire [26:0] countOut;

 wire [5:0] carry;

 wire enable;

 wire [3:0] store1, store2, store3, store4, store5, store6;

output [3:0] hour2, hour1;



 assign hour2 = digit6;

assign hour1 = digit5;

  wire [3:0] digit1, digit2, digit3, digit4, digit5, digit6;

 RateDivider u1 (clk, stop, countOut);

 turnFlipFlop u2 (countOut, enable);

 counterHex u3 (enable, dig0, carry[0], clk, timechange, stop, Ky, digit1, switch9, store1, digit6);

 defparam u3.g = 4'd10;

  defparam u3.k = 4'd1;

  defparam u3.hour = 1'd0;

 counterHex u4 (carry[0], dig1, carry[1], clk, timechange, stop, Ky, digit2, switch9, store2, digit6);

 defparam u4.g = 4'd6;

  defparam u4.k = 4'd2;

  defparam u4.hour = 1'd0;

 counterHex u5 (carry[1], dig2, carry[2], clk, timechange, stop, Ky, digit3, switch9, store3, digit6);

 defparam u5.g = 4'd10;

  defparam u5.k = 4'd3;

  defparam u5.hour = 1'd0;

 counterHex u6 (carry[2], dig3, carry[3], clk, timechange, stop, Ky, digit4, switch9, store4, digit6);

 defparam u6.g = 4'd6;

 defparam u6.k = 4'd4;

 defparam u6.hour = 1'd0;

 counterHex u7 (carry[3], dig4, carry[4], clk, timechange, stop, Ky, digit5, switch9, store5, digit6);

 defparam u7.g = 4'd4;

 defparam u7.k = 4'd5;

 

 defparam u7.hour = 1'd1;

 counterHex u8 (carry[4], dig5, carry[5], clk, timechange, stop, Ky, digit6, switch9, store6, digit6);

 defparam u8.g = 4'd3;

 defparam u8.k = 4'd6;

 defparam u8.hour = 1'd0;

 

 storealarm u9 (clk, digit1, digit2, digit3, digit4, digit5, digit6, timechange, stop, switch9, Ky, light, store1, store2, store3, store4, store5, store6, GPIO_Wire, motionport);

 

endmodule

module storealarm (clk, digit1, digit2, digit3, digit4, digit5, digit6, timechange, switch0, switch9, Ky, light, store1, store2, store3, store4, store5, store6, GPIO_Wire, motionport);

 input switch0, switch9, clk, motionport;

 input [3:0] Ky, digit1, digit2, digit3, digit4, digit5, digit6;

 input [3:0] timechange;

 inout [35:1] GPIO_Wire;

 output reg light;

 output reg [3:0] store1, store2, store3, store4, store5, store6;

 wire activealarm, sensorActive;

 reg sensed;


 always@ (posedge clk)

 

 begin

 

 //if stop enabled, and setAlarm enabled...

 if (switch0 && switch9)

 

 begin

 

 /*this series of if statements choose one amongst 6 counterHex.

   depending on the counterHex chosen, modify its 'stored value'

   based on the 4 bit binary value of timechange (user input)

 */

   if (Ky == 4'd1) store1 <= timechange;

 

   else if (Ky == 4'd2) store2 <= timechange;

 

   else if (Ky == 4'd3) store3 <= timechange;

 

   else if (Ky == 4'd4) store4 <= timechange;

 

   else if (Ky == 4'd5) store5 <= timechange;

 

   else if (Ky == 4'd6) store6 <= timechange;

 

 end

 

 /* User is not allowed to 'store' a preset alarm value greater than some maximum.

    e.g. seconds allowed to go up to 59, i.e. one counterHex up to 9, the other

 

 

 

 */

 else if (store1 > 4'd9) store1 <= 4'd0;

 

 else if (store2 > 4'd5) store2 <= 4'd0;

 

 else if (store3 > 4'd9) store3 <= 4'd0;

 

 else if (store4 > 4'd5) store4 <= 4'd0;

 

 else if (store5 > 4'd3 && digit6 == 4'd2) store5 <= 4'd0;

 else if (store5 > 4'd9 && (digit6 == 4'd1 || digit6 == 4'd0)) store5 <= 4'd0;

 else if (store6 > 4'd2) store6 <= 4'd0;

 

   else if (sensed == 1'b1 && store1 == digit1 && store2 == digit2 && store3 == digit3 && store4 == digit4 && store5 == digit5 && store6 == digit6)

  light <= 1'b1;

  

   else light <=1'b0;

 

 end

 assign activealarm = light;

 

 sound_gpio s (clk, GPIO_Wire, activealarm);

 

 sensor_gpio r (clk, motionport, light, sensorActive);

 

 always @(posedge clk) begin

 

 if (sensorActive) sensed = 1;

 else if (activealarm) sensed = 0;

 

 end

endmodule


module counterHex(carryIn, Hex,  carryOut, clk, timechange, stop, Ky, digit, switch9, store, lastdigit);

 input carryIn, clk, stop, switch9;

 input [3:0] timechange;

 input [3:0] Ky, store, lastdigit;

 output [6:0] Hex;

 output [3:0] digit;

 output carryOut;

 wire [3:0] q;

 reg [3:0] chooser;

 

 parameter hour = 1'd0;

 parameter g = 4'd9;

 parameter k = 4'd1;

 assign digit = q;

    

 /*each t_flip_flop's arguments are different:

 'g' corresponds to the maximum value a t_flip_flop is allowed to count up to

 'k' is an ID: we have k from 0 to 5, so that each counterHex is 'special', differentiated.

 'hour' is defined like below; by default, we set hour to 0 so the most general scenario in t_flip_flop is run.

 */

 t_flip_flop r1 (carryIn, clk, q, carryOut, timechange, stop, Ky, switch9, lastdigit);

  defparam r1.n = g;

  defparam r1.k = k;

  defparam r1.hour = hour;

 

 /* If 1. setAlarm is activated,

 * 2. stop is enabled,

 * Then 7-segment displays the value we're intending to preset for the alarm

 *

 * Otherwise, the 7-segment displays the value that's outputted from the flip flop.

 */

  always@ (posedge clk)

    begin

        if (switch9 && stop)

            chooser <= store;

        else

            chooser <= q;

    end

    

 hexDecoder r2 (chooser, Hex);

    

endmodule

 

module t_flip_flop(t, clk, q, carry, timechange, stop, Ky, switch9, lastdigit);

 parameter n = 4'd9;

 parameter hour = 1'd0;

 parameter k = 4'd1;

 input t, clk, stop, switch9;

 

 input [3:0] timechange, lastdigit;

 

 input [3:0] Ky;

 output reg [3:0] q;

 output reg carry;

 always@(posedge clk)

  begin

    /* Meaning of hour: 5th 7-segment is the one in question... (single digit hour)

     * Meaning of lastdigit: left-most 7-segment's value...

     * If it isn't the 5th 7-segment, and leftmost hour is 2

     */

   if (hour==1'd0 || lastdigit==4'd2)

  

     begin

            

            /*if 1. count > threshold,

             * 2. setAlarm not activated,

             * Then count/output resets.

             */

            if (q > n && ~switch9) q = 0;

            

            /*if 1. the particular hexCounter is chosen (k is an ID for which hex is referred to),

             * 2. stop is enabled

             * 3. setAlarm is not activated,

             * then output gets its time changed: paralleloaded from user-input.

             */

            else if (Ky == k && stop && ~switch9) q<=timechange;

            

            

            /* If 1. the second-ly pulse is detected,

             * 2. q hasn't reached threshold

             * 3. setAlarm(sw9) is not activated,

             * output increments normally (this is the default case)

             */

            else if(t && (q != n) && ~switch9) q <= q+1; // this is equivalent to t ^ q

            /* If 1. max threshold reached

             * 2. output/count is not greater than threshold

             * 3. setAlarm(sw9) is not activated

             * carry +1 to the next counter, reset current count/output to 0.

             */

            else if (q == n && ~(q>n)  && ~switch9)

        

            begin

          carry <= 1;

          q <= 4'b0;

       end

     //if incremented up to n, carry; otherwise, carry = 0.

     else carry <= 0;

 

   end

  

   else if ((hour==1'd1) && ((lastdigit == 4'd1) || (lastdigit == 4'd0)))

  

    begin

 

     /* If counter is greater than threshold, and switch9 (setAlarm) is not activated, default reset.*/

     if (q > 10 && ~switch9) q = 0;

 

    /* Every counterhex has its own ‘k’ (ID).

     * When 1. time stops counting

     * 2. setAlarm (sw9) is not on,

     * 3. value of key  pressed matches one of the counterhex:  

     * Then allow time to be changed (value on 7-segment.)

     */

     else if (Ky == k && stop && ~switch9) q<=timechange;

/*when 1. a pulse is detected (once every second), 2. max threshold hasn’t been reached, 3. setAlarm(sw9) is not activated, value of output increments (hex updates increment).

 */

     else if(t && (q != 10) && ~switch9) q <= q+1; // this is equivalent to t ^ q

    /* If 1. Max threshold is reached

     * 2. greater than threshold

     * 3. sw9 (setAlarm) not active,

     *

     * Then allow carry into next flip-flop, and also reset current output to hex to 0.

   */

     else if (q == 10 && ~(q>10)  && ~switch9)

  

      begin

  

       carry <= 1;

       q <= 4'b0;

  

      end

  

     //if incremented up to n, carry; otherwise, carry = 0.

     else carry <= 0;

 

    end

 

  end

 

endmodule

 

/*generates one pulse every second to q.*/

module turnFlipFlop(in, q);

  input [26:0] in;

  output reg q;

  

  always@(*)begin

       if(in == 27'b0) q <= 1;

       else q <= 0;

  end

 

endmodule

/* counts 48 million pulses a second, resets to 0 after. */

 

module RateDivider(clock, Switch, counterOut);

  input clock;

   input Switch;

  output reg [26:0] counterOut;

  

  always@(posedge clock)

  begin

   if (Switch == 1);

       else if(counterOut >= 27'd48000000) counterOut <= 27'd0;

       else counterOut <= counterOut+1;

  end

endmodule

 

module hexDecoder(hex, outputHEX);

 input [3:0] hex;

 output [6:0] outputHEX;

 

 wire a, b, c, d;

 

 assign a = hex[3];

 assign b = hex[2];

 assign c = hex[1];

 assign d = hex[0];

 

 assign outputHEX[0]  = ~((~b & ~d) | (~a & c) | (b & c) | (a & ~d) | (~a & b & d) | (a & ~b & ~c));

 

 assign outputHEX[1] = ~((~a & ~b) | (~b & ~d) | (~a & ~c & ~d) | (~a & c & d) | (a & ~c & d));

 

 assign outputHEX[2] = ~((~a & ~c) | (~a & d) | (~c & d) | (~a & b) | (a & ~b));

 

 assign outputHEX[3] = ~((~a & ~b & ~d) | (~b & c & d) | (b & ~c & d) | (b & c & ~d) | (a & ~c & ~d));

     

 assign outputHEX[4] = ~((~b & ~d) | (c & ~d) | (a & c) | (a & b));

 

 assign outputHEX[5] = ~((~c & ~d) | (b & ~d) | (a & ~b) |(a & c) | (~a & b & ~c));

 

 assign outputHEX[6] = ~((~b & c) | (c & ~d) | (a & ~b) | (a & d) | (~a & b & ~c));

 

endmodule

//Sound:

module sound_gpio(

 input clock,

 output wire [35:0] GPIO_Wire,

 input alarm

);

 // reg

 reg [32:0] counter;

reg [35:0] timer;

 reg turn;

 

 // assign

 assign GPIO_Wire[10] = turn;

 

 // always

 always @(posedge clock) begin

/* alarm is only active for one second. Within this second, timer increments. As long as timer is less than 5 minutes, an ~700 hertz pulse is generated to gpio. */

//34'b1101111110000100011101011000000000

if (alarm || ((timer<=36'd500000000) && timer))

begin

timer <= timer+1;

        counter <= counter + 1;

         if (counter[16]) //outputs ~700 cycles a second

         turn <= 1'b1;         // send one pulse

          else

         turn <= 1'b0;         // don’t send pulse

end

         else timer<=0; 

 end

endmodule

// motion sensor trigger

module sensor_gpio(

 input clock,

 input GPIO_Wire,

 input light,

 output active

);

 // reg

 reg detected;

 

 assign active = detected;

 // always

 always @(posedge clock)

 begin

 if (light)

  detected <= 1'b0;

 

 else if (detected)

  detected <= 1'b1;

 else

  detected <= GPIO_Wire;

 end

endmodule












//______________________________________________________________________



module control (clock, reset, ld_sDown, ld_sUp, ld_sRight, ld_sLeft, ld_d, ld_drawNew, ld_reset_old, ld_done, plot, enable, up_flag, right_flag, ld_square_completion, ld_move_status);

     input clock, reset, enable, up_flag, right_flag, ld_square_completion, ld_move_status;

     output reg ld_sDown, ld_sUp, ld_sRight, ld_sLeft, ld_d, ld_drawNew, plot, ld_done, ld_reset_old;

     reg [5:0] current_state, next_state; 

    

    localparam   S_Reset = 5'd0, 

                     S_DeleteOld = 5'd1,

                     S_StartAnimation = 5'd2,                

                S_ShiftUp = 5'd3,

                     S_ShiftDown = 5'd4,

                     S_ShiftRight = 5'd5,

                S_ShiftLeft = 5'd6,

                     S_PrintNew = 5'd7,

                     S_Done = 5'd8;

 

always@(*)

 begin: state_table 

     case (current_state)

          S_Reset: next_state = S_DeleteOld;

          S_DeleteOld: next_state =  ld_move_status ? S_StartAnimation : S_DeleteOld;

          S_StartAnimation: next_state = up_flag ? S_ShiftUp : S_ShiftDown;

        S_ShiftUp: next_state = right_flag ? S_ShiftRight : S_ShiftLeft; 

        S_ShiftDown: next_state = right_flag ? S_ShiftRight : S_ShiftLeft; 

          S_ShiftLeft: next_state = S_PrintNew;

          S_ShiftRight: next_state = S_PrintNew;

          S_PrintNew: next_state =  ld_square_completion ? S_Done : S_PrintNew ;

          S_Done: next_state = enable ? S_DeleteOld: S_Done;

          default: next_state = S_StartAnimation;

          endcase

 end

 

always @(*)

  begin: enable_signals

  ld_sDown = 1'b0;       

  ld_sUp = 1'b0;

  ld_sRight = 1'b0;

  ld_sLeft = 1'b0;

  ld_d = 1'b0;

  ld_drawNew = 1'b0;

  ld_reset_old = 1'b0;

  plot = 1'b0;

  ld_done = 1'b0; 

  

 case (current_state)

     S_ShiftDown: begin

          ld_sDown = 1'b1; 

   end

     S_ShiftUp: begin

          ld_sUp = 1'b1; 

   end

     S_ShiftRight: begin

          ld_sRight = 1'b1; 

   end

   S_ShiftLeft: begin

        ld_sLeft = 1'b1; 

   end // S_ShiftLeft:

   S_DeleteOld: begin

        ld_d = 1'b1;

          plot = 1'b1;

   end // S_DeleteOld:

   S_PrintNew: begin

        ld_drawNew = 1'b1;

        plot = 1'b1;

   end // S_PrintNew:

   S_Reset: begin

          ld_reset_old = 1'b1; 

   end // S_Reset:

   S_Done: begin

          ld_done = 1'b1; 

   end // S_Done:

endcase

end

 

always@(posedge clock)

   begin: state_FFs

      if(!reset)       

         current_state <= S_Reset; 

      else            

            current_state <= next_state;

   end // state_FFS

endmodule

 

module datapath(clock, reset, ld_sDown, ld_sUp, ld_sRight, ld_sLeft, ld_d, ld_drawNew, ld_reset_old, ld_done, up_flag, right_flag, output_colour, output_x, output_y, colour, ld_square_completion, ld_move_status, hour1, hour2, settinguptime, alarmactive);
		input alarmactive;

		input settinguptime;

     input [3:0] hour2, hour1;

     input clock, reset, ld_sDown, ld_sUp, ld_sRight, ld_sLeft, ld_d, ld_drawNew, ld_reset_old, ld_done;

     input [2:0] colour;

     output reg up_flag, right_flag, ld_square_completion, ld_move_status;

     output reg [2:0] output_colour;

     output reg [7:0] output_x;

     output reg [6:0] output_y;

 

     reg [4:0] counter_draw;

     reg [7:0] x_reg;

     reg [6:0] y_reg;

     reg [16:0] counter1;

      reg [45:0] countblah;

      reg [5:0] countparabolic;

      reg [40:0] counthorizontal;

      reg slowedhorizontal;

      reg slowedvertical;

     

always@(posedge clock) begin


    if (counthorizontal == 40'd50000000) begin

        slowedhorizontal <= 1;

        slowedvertical <= 1;
		  
		  counthorizontal <= 0;

    end

    

    else begin

        counthorizontal <= counthorizontal +1'd1;

        slowedhorizontal <= 0;

        slowedvertical <= 0;

    end
	 
           counter_draw <= 5'b00000;

          counter1 <= 17'b0;

          ld_move_status <= 1'b0;

        ld_square_completion <= 1'b0;
		  
		  
		  if (up_flag  == 1)
          y_reg <= y_reg-slowedvertical; //+countparabolic;
			 else if (up_flag == 0) 
			 y_reg <= y_reg+slowedvertical;
			 
			 if (x_reg <= 8'd80 && x_reg >= 8'd75)
			 up_flag = 1'b0;  
		  

          counter_draw <= 5'b00000;

          counter1 <= 17'b0;

          ld_move_status <= 1'b0;

          ld_square_completion <= 1'b0;
			 
			 x_reg <= x_reg-slowedhorizontal;

          if(x_reg == 8'b0) right_flag = 1'b1;

       

          if ((hour2 == 4'd0 && hour1 == 4'd8) || (hour2 == 4'd2 && hour1==4'd0))  begin
			 if (settinguptime == 1'b1) begin x_reg <= 8'd156; y_reg <= 7'd116; up_flag = 1; end
    end
	 
else if ((hour2 == 4'd0 && hour1 == 4'd9) || (hour2 == 4'd2 && hour1 == 4'd1)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd143; y_reg <= 7'd103; up_flag = 1; end
    end
else if ((hour2 == 4'd1 && hour1 == 4'd0) || (hour2 == 4'd2 && hour1 == 4'd2)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd130; y_reg <= 7'd90; up_flag = 1; end
    end
	 

    else if ((hour2 == 4'd1 && hour1 == 4'd1) || (hour2 == 4'd2 && hour1 == 4'd3)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd117; y_reg <= 7'd77; up_flag = 1; end
    end
	 
else if ((hour2 == 4'd1 && hour1 == 4'd2) || (hour2 == 4'd0 && hour1 == 4'd0)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd104; y_reg <= 7'd64; up_flag = 1; end
    end
else if ((hour2 == 4'd1 && hour1 == 4'd3) || (hour2 == 4'd0 && hour1 == 4'd1)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd91; y_reg <= 7'd51; up_flag = 1; end
    end

	 
else if ((hour2 == 4'd1 && hour1 == 4'd4) || (hour2 == 4'd0 && hour1 == 4'd2)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd78; y_reg <= 7'd38; up_flag = 0; end
    end
	 
	 
else if ((hour2 == 4'd1 && hour1 == 4'd5) || (hour2 == 4'd0 && hour1 == 4'd3)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd65; y_reg <= 7'd51; up_flag = 0; end
    end
else if ((hour2 == 4'd1 && hour1 == 4'd6) || (hour2 == 4'd0 && hour1 == 4'd4)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd52; y_reg <= 7'd64; up_flag = 0; end
    end
	 

else if ((hour2 == 4'd1 && hour1 == 4'd7) || (hour2 == 4'd0 && hour1 == 4'd5)) begin
	if (settinguptime == 1'b1) begin x_reg <= 8'd39; y_reg <= 7'd77; up_flag = 0; end
    end

else if ((hour2 == 4'd1 && hour1 == 4'd8) || (hour2 == 4'd0 && hour1 == 4'd6)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd26; y_reg <= 7'd90; up_flag = 0; end
    end
else if ((hour2 == 4'd1 && hour1 == 4'd9) || (hour2 == 4'd0 && hour1 == 4'd7)) begin
	 if (settinguptime == 1'b1) begin x_reg <= 8'd13; y_reg <= 7'd103; up_flag = 0; end
    end


     if(ld_d) begin

          if(counter1 <= 17'b01111111111111111)

               begin

                     output_x <= counter1[7:0] ;

                     output_y <= counter1[14:8] ;

                     counter1 <= counter1 + 1'b1;


//if hour2 is 0 AND hour1 is less than 8, OR hour2 is 2 AND hour1 greater than 0, is night.
			if (flashing != 2'b00) begin
				if (flashing == 2'b10) output_colour <= 3'b100;
				else if (flashing == 2'b01) output_colour <= 3'b010;
			end

        else if ((hour2 == 4'd2 && hour1 >= 4'd0) || ((hour2 == 4'd0) && (hour1 <= 4'd7)))

                     output_colour <= 3'b000;  

        else output_colour <=3'b001;

               end

          if(counter1 == 17'b10000000000000000)

          begin

               ld_move_status <= 1'b1;

          end

     end // if(ld_d)

     

     if(ld_drawNew) begin
//where to drawing begins
      	if(counter_draw <= 5'b01111)
      	begin
           	//at top left corner, put pixels up to 2^1 to the right
           	output_x <= x_reg + counter_draw[1:0];
           	//put pixels up to 2^1 downwards
           	output_y <= y_reg + counter_draw[3:2];
           	counter_draw <= counter_draw + 1'b1;
      	end
      	if(counter_draw == 5'b10000)
      	begin
            	ld_square_completion <= 1'b1;
           	//resets to 0 because gotta re-draw next cycle
           	counter_draw <= 5'b00000;
      	end
      	output_colour <= colour;
 	end // if(ld_drawNew)


     

     if(ld_reset_old) begin

          counter_draw <= 5'b0000;

          counter1 <= 5'b00000;  

          x_reg <= 8'd156; 

           y_reg <= 7'd116;

          ld_move_status <= 1'b0;

          right_flag <= 1'b0;

          up_flag <= 1'b1;

          ld_square_completion <= 1'b0;     

     end // if(ld_reset_old)     

end


// red screen counter
// reg

 reg [32:0] counter;

reg [35:0] timer;

 reg[1:0] turn;

 
wire [1:0] flashing;
 // assign

 assign flashing = turn;

 

 // always

 always @(posedge clock) begin

/* alarm is only active for one second. Within this second, timer increments. As long as timer is less than 5 minutes, an ~700 hertz pulse is generated to gpio. */

//34'b1101111110000100011101011000000000

if (alarmactive || ((timer<=36'd500000000) && timer))

begin

timer <= timer+1;

        counter <= counter + 1;

         if (counter[11]) //outputs ~700 cycles a second

         turn <= 2'b10;         // send one pulse

          else

         turn <= 2'b01;         // don’t send pulse

end

else begin timer<=0; turn <= 2'b00; end

 end


endmodule // module




