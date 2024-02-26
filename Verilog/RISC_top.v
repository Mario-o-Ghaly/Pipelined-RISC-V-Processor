/*******************************************************************
*
* Module: RISC_top.v
* Project: femtoRV32
* Authors: Fekry Mohamed & Mario Ghaly & Freddy Amgad
* Description: a top module for the FPGA implementation
**********************************************************************/


module RISC_top(input clk, rst, input[1:0] ledSel, input[3:0]ssdSel, input SSD_Clock, output [15:0] LED_out, output[3:0] Anode, output [6:0] LED);
     
    wire [12:0] ssd_out; 
    RISC_FPGA risc(clk, rst,ledSel, ssdSel, SSD_Clock, LED_out, ssd_out);
    Four_Digit_Seven_Segment_Driver SSD(SSD_Clock, ssd_out, Anode, LED);

endmodule
