/*******************************************************************
*
* Module: RISC_FPGA.v
* Project: femtoRV32
* Authors: Fekry Mohamed & Mario Ghaly & Freddy Amgad
* Description: a module to be used for the FPGA. This is the same code as the one used in the simulation
**********************************************************************/

`include "defines.v"

module RISC_FPGA(input clk, rst, input[2:0] ledSel, input[3:0]ssdSel, input SSD_Clock, output reg[15:0] LED_out, output reg[12:0] ssd_out);
    
    
    wire [31:0] PC_out, PC_in, read_data1, read_data2, gen_out, ALUOutput, data_out, write_data, ALU_input1, ALU_input2,
                write_data_mem_reg, Second_AluMux_output, instruction_out;
    wire [14:0] hazard_control_out;
    wire [11:0] EX_MEM_Ctrl_in;
    wire [4:0] ALU_sel;
    wire [1:0] ALUOp, PC_mux_sel, WB_mux_sel, pc_sel,forwardA,forwardB;
    
    
    //IF-ID stage 
    wire [31:0] IF_ID_PC, IF_ID_Inst;
    N_bit_register #(64) IF_ID (clk, rst, !(stall || (pc_sel[0] && pc_sel[1])) , {PC_out, instruction_out},{IF_ID_PC,IF_ID_Inst} );
    
    
    //ID-EX stage 
    wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire [14:0] ID_EX_Ctrl;
    wire [3:0] ID_EX_Func;
    wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    wire ID_EX_muldiv, ID_EX_shamt_sel;
    N_bit_register #(164) ID_EX (clk, rst, 1'b1, {hazard_control_out, IF_ID_PC, read_data1, read_data2, gen_out, 
                                IF_ID_Inst[30], IF_ID_Inst[`IR_funct3],IF_ID_Inst[`IR_rs1], IF_ID_Inst[`IR_rs2], IF_ID_Inst[`IR_rd], IF_ID_Inst[25], IF_ID_Inst[5]},
                                {ID_EX_Ctrl, ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, 
                                ID_EX_Func, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_muldiv, ID_EX_shamt_sel});
    
    
    //EX-MEM stage
    wire [31:0] EX_MEM_PC, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Imm;
    wire [11:0] EX_MEM_Ctrl;
    wire [4:0] EX_MEM_Rd;
    wire [2:0] EX_MEM_Func;
    wire EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf;    
    N_bit_register #(152) EX_MEM (clk,rst,1'b1,
                                {EX_MEM_Ctrl_in, ID_EX_PC, {cf, zf, vf, sf}, 
                                ALUOutput, Second_AluMux_output, ID_EX_Imm, ID_EX_Rd, ID_EX_Func[2:0]},
                                {EX_MEM_Ctrl, EX_MEM_PC, EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, 
                                EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Imm, EX_MEM_Rd, EX_MEM_Func});
    
    
    //MEM-WB stage
    wire [31:0] MEM_WB_PC, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Imm;
    wire [3:0] MEM_WB_Ctrl;
    wire [4:0] MEM_WB_Rd;
    N_bit_register #(137) MEM_WB (clk,rst,1'b1,
                                {EX_MEM_Ctrl[3:0], EX_MEM_PC, data_out, EX_MEM_ALU_out, EX_MEM_Imm, EX_MEM_Rd},
                                {MEM_WB_Ctrl, MEM_WB_PC, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Imm, MEM_WB_Rd});
    
    
    N_bit_register PC( clk, rst, !(stall || EX_MEM_Ctrl[10] || EX_MEM_Ctrl[9]), PC_in, PC_out);
    Memory single_memory(clk, EX_MEM_Ctrl[10], EX_MEM_Ctrl[9], EX_MEM_Ctrl[8], EX_MEM_Ctrl[7], EX_MEM_Ctrl[6], 
                        (EX_MEM_Ctrl[10] || EX_MEM_Ctrl[9])?EX_MEM_ALU_out:PC_out[11:0], EX_MEM_RegR2, data_out);                    
    mux instruction_NOP(data_out, `NOP, (pc_sel[0] || pc_sel[1] || EX_MEM_Ctrl[10] || EX_MEM_Ctrl[9] || (pc_sel[0] && pc_sel[1])) , instruction_out); 
    mux #(12)EX_MEM_Control(ID_EX_Ctrl[11:0], 0, branch_out, EX_MEM_Ctrl_in); 
   
    reg_file register_file (~clk, rst, IF_ID_Inst[`IR_rs1], IF_ID_Inst[`IR_rs2], MEM_WB_Rd, write_data, MEM_WB_Ctrl[2], read_data1, read_data2);
    control_unit control(IF_ID_Inst[6:0], IF_ID_Inst[`IR_funct3], ALUOp, Branch, MemRead, MemtoReg, 
                        MemWrite, ALUSrc, RegWrite, Byte, HalfWord, ZeroExtention, PC_mux_sel, WB_mux_sel);
    rv32_ImmGen immediate(IF_ID_Inst, gen_out);
    
    alu_control alu_ctrl(ID_EX_Ctrl[13:12], ID_EX_Func[2:0], ID_EX_Func[3], ID_EX_muldiv, ALU_sel);
    mux ALU_mux(Second_AluMux_output, ID_EX_Imm, ID_EX_Ctrl[14], ALU_input2);
    prv32_ALU alu(ALU_input1 , ALU_input2, (ID_EX_shamt_sel==1)? ID_EX_RegR2[4:0]:ID_EX_Rs2, ALUOutput, cf, zf, vf, sf, ALU_sel);  //schamt is rs2 if shift immediate and read_data2[4:0] if R-type shift

    branch_control BCU(EX_MEM_Ctrl[11], EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, EX_MEM_Func, branch_out);
    mux #(2) mux_selector(PC_mux_sel, 2'b01, branch_out, pc_sel);
    four_by_two_mux pc_mux( (PC_out+4), (branch_out == 1)?(EX_MEM_PC+EX_MEM_Imm):(IF_ID_PC+gen_out), read_data1 + gen_out,
                            IF_ID_PC, pc_sel, PC_in);
    
    //First_alu_mux_forward
    four_by_two_mux #(32) First_Alu (ID_EX_RegR1,write_data_mem_reg,EX_MEM_ALU_out,32'b0,forwardA,ALU_input1);
    //Second_alu_mux_forward
    four_by_two_mux #(32) Second_Alu(ID_EX_RegR2,write_data_mem_reg,EX_MEM_ALU_out,32'b0,forwardB,Second_AluMux_output);
    //FORWARD_UNIT
    Forward_unit fw (ID_EX_Rs1,ID_EX_Rs2,EX_MEM_Rd,MEM_WB_Rd,EX_MEM_Ctrl[2], MEM_WB_Ctrl[2],forwardA, forwardB);
    
    //HAZARD UNIT 
    hazard_detector hazard(IF_ID_Inst[`IR_rs1], IF_ID_Inst[`IR_rs2], ID_EX_Rd, ID_EX_Ctrl[3], stall);
    mux #(15) control_mux({ALUSrc, ALUOp, Branch, MemRead, MemWrite,Byte, HalfWord, ZeroExtention, PC_mux_sel,
    MemtoReg, RegWrite, WB_mux_sel},0, stall || branch_out, hazard_control_out);


    mux memory_mux(MEM_WB_ALU_out, MEM_WB_Mem_out, MEM_WB_Ctrl[3], write_data_mem_reg);
    four_by_two_mux reg_write_mux(write_data_mem_reg, (MEM_WB_PC+4), MEM_WB_Imm, (MEM_WB_PC+MEM_WB_Imm), MEM_WB_Ctrl[1:0], write_data);
 
    always @(*) begin
        case(ledSel) 
        2'b00: LED_out = data_out[15:0];
        2'b01: LED_out = data_out[31:16];
        2'b10: LED_out = {Byte, HalfWord, ZeroExtention, ALUOp, branch_out, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALU_sel};
        default: LED_out = 0;
        
        endcase
    end
    
    always @(*) begin
        case(ssdSel)
            4'b0000: ssd_out = PC_out[12:0];
            4'b0001: ssd_out = PC_out[12:0] + 4;
            4'b0010: ssd_out = (PC_out+ gen_out);
            4'b0011: ssd_out = PC_in[12:0];
            4'b0100: ssd_out = read_data1[12:0];
            4'b0101: ssd_out = read_data2[12:0];
            4'b0110: ssd_out = write_data[12:0];
            4'b0111: ssd_out = gen_out[12:0];
            4'b1000: ssd_out = gen_out[12:0];
            4'b1001: ssd_out = ALU_input1[12:0];
            4'b1010: ssd_out = ALU_input2[12:0];
            4'b1011: ssd_out = ALUOutput[12:0];
            4'b1100: ssd_out = data_out[12:0];
            default: ssd_out = 0;
        endcase
    end
    
endmodule
