`timescale 1ns / 1ps
/*******************************************************************
*
* Module: Four_One_mux_new.v
* Project: femtoRV32
* Authors: Fekry Mohamed & Mario Ghaly & Freddy Amgad
* Description: The module is a 4-to-1 multiplexer that selects one of the four input signals (A, B, C, or D)
* based on the 2-bit selection signal (sel). The selected input is then assigned to the output signal Y. 
* This multiplexer is parameterized, allowing the user to specify the bit width (N) for the inputs and output.
*
**********************************************************************/

module Four_One_mux_new #(parameter N= 32)(input [N-1:0] A, B, C, D, input [1:0] sel, output reg [N-1:0]  Y);

always @(*)begin 
case(sel)
2'b00: Y=A;
2'b01: Y=B;
2'b10: Y=C;
2'b11: Y=D;
endcase
end

endmodule
