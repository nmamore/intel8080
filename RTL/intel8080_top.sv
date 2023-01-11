/*
* @file intel8080_top.sv
* @brief top-level file for the Intel 8080
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/2/2023
*/

`timescale 1ns / 100ps

//Selection for 8 bit access
localparam B_REG_8 =  4'b0000;
localparam C_REG_8 =  4'b0001;
localparam D_REG_8 =  4'b0010;
localparam E_REG_8 =  4'b0011;
localparam H_REG_8 =  4'b0100;
localparam L_REG_8 =  4'b0101;
localparam A_REG_8 =  4'b0111;
localparam SP_REG_8 = 4'b1000;
localparam PC_REG_8 = 4'b1001;

//Selection for 16 bit access
localparam BC_REG_16 = 3'b000;
localparam DE_REG_16 = 3'b001;
localparam HL_REG_16 = 3'b010;
localparam SP_REG_16 = 3'b011;
localparam PC_REG_16 = 3'b100;

module intel8080_top
(
    input logic clk50M_i,
    input logic rst_ni
    
);

//Top-level bus signals
logic [7:0]  data_bus;
logic [15:0] address_bus;

logic [15:0] addr_latch;

//PC Signals
logic pc_load;
logic pc_inc;
logic pc_rd;

logic [15:0] pc_out;

//SP Signals
logic sp_load;
logic sp_inc;
logic sp_dec;
logic sp_rd;

logic [15:0] sp_out;

//ALU Signals
logic [7:0] alu_a;
logic [7:0] alu_temp;

//Register Signals
logic reg_write;
logic reg_read;
logic alu_wr;
logic alu_flag_wr;
logic [3:0] alu_sel;

logic [3:0] reg8_sel;
logic [2:0] reg16_sel;

logic [8:0] mux_write;
logic [8:0] mux_read;

//Instruction Register
logic ir_rd;
logic ir_wr;
logic [7:0] ir_dat;

//A Register
logic a_reg_wr;
logic a_reg_rd;
logic [7:0] a_out;

//A Latch
logic a_latch_rd;
logic a_latch_wr;

//Temp Reg
logic temp_reg_rd;
logic temp_reg_wr;
logic [7:0] temp_out;

//B Register
logic b_reg_wr;
logic b_reg_rd;
logic [7:0] b_out;

//C Register
logic c_reg_wr;
logic c_reg_rd;
logic [7:0] c_out;

//BC Register
logic [15:0] bc_out;

//D Register
logic d_reg_wr;
logic d_reg_rd;
logic [7:0] d_out;

//E Register
logic e_reg_wr;
logic e_reg_rd;
logic [7:0] e_out;

//DE Register
logic [15:0] de_out;

//H Register
logic h_reg_wr;
logic h_reg_rd;
logic [7:0] h_out;

//L Register
logic l_reg_wr;
logic l_reg_rd;
logic [7:0] l_out;

//HL Register
logic [15:0] hl_out;

assign a_reg_wr = mux_write[8];
assign b_reg_wr = mux_write[7];
assign c_reg_wr = mux_write[6];
assign d_reg_wr = mux_write[5];
assign e_reg_wr = mux_write[4];
assign h_reg_wr = mux_write[3];
assign l_reg_wr = mux_write[2];
assign sp_load  = mux_write[1];
assign pc_load  = mux_write[0];

assign a_reg_rd = mux_read[8];
assign b_reg_rd = mux_read[7];
assign c_reg_rd = mux_read[6];
assign d_reg_rd = mux_read[5];
assign e_reg_rd = mux_read[4];
assign h_reg_rd = mux_read[3];
assign l_reg_rd = mux_read[2];
assign sp_rd    = mux_read[1];
assign pc_rd    = mux_read[0];

always_comb begin
    case (reg8_sel)
        A_REG_8: begin
            mux_write = {reg_write, 8'b000000};
            mux_read  = {reg_read,  8'b000000};
        end
        B_REG_8: begin
            mux_write = {1'b0, reg_write, 7'b0000000};
            mux_read  = {1'b0, reg_read,  7'b0000000};
        end
        C_REG_8: begin
            mux_write = {2'b00, reg_write, 6'b000000};
            mux_read  = {2'b00, reg_read,  6'b000000};
        end
        D_REG_8: begin
            mux_write = {3'b000, reg_write, 5'b00000};
            mux_read  = {3'b000, reg_read,  5'b00000};
        end
        E_REG_8: begin
            mux_write = {4'b0000, reg_write, 4'b0000};
            mux_read  = {4'b0000, reg_read,  4'b0000};
        end
        H_REG_8: begin
            mux_write = {5'b00000, reg_write, 3'b000};
            mux_read  = {5'b00000, reg_read,  3'b000};
        end
        L_REG_8: begin
            mux_write = {6'b000000, reg_write, 2'b00};
            mux_read  = {6'b000000, reg_read,  2'b00};
        end
        SP_REG_8: begin
            mux_write = {7'b0000000, reg_write, 1'b0};
            mux_read  = {7'b0000000, reg_read,  1'b0};
        end
        PC_REG_8: begin
            mux_write = {8'b00000000, reg_write};
            mux_read  = {8'b00000000, reg_read};
        end
        default: begin
            mux_write = {9'b000000000};
            mux_read  = {9'b000000000};
        end
    endcase
end

//Address Latch select
always_comb begin
    case (reg16_sel)
        BC_REG_16: begin
            addr_latch = bc_out;
        end
        DE_REG_16: begin
            addr_latch = de_out;
        end
        HL_REG_16: begin
            addr_latch = hl_out;
        end
        SP_REG_16: begin
            addr_latch = sp_out;
        end
        PC_REG_16: begin
            addr_latch = pc_out;
        end
        default: begin
            addr_latch = 16'hzzzz;
        end
    endcase
end

alu i_alu (
    .a_dat_i   (alu_a),
    .b_dat_i   (temp_out),
    .flag_out_i(alu_flag_wr),
    .alu_out_i (alu_wr),
    .alu_sel_i (alu_sel),
    .flag_reg  (data_bus),
    .alu_dat_o (data_bus)
);

latch_16bit address_latch (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .latch_rd(latch_rd),
    .latch_wr(latch_wr),
    .data_d  (addr_latch),
    .data_q  (address_bus)
);

reg_8bit instruction_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (ir_rd),
    .ff_wr   (ir_wr),
    .bus_o   (ir_dat),
    .bus_io  (data_bus)
);

program_counter i_program_counter (
    .clk50M_i (clk50M_i),
    .rst_ni   (rst_ni),
    .load_i   (pc_load),
    .inc_i    (pc_inc),
    .out_i    (pc_rd),
    .pc_dat_io(data_bus),
    .pc_addr_o(pc_out)
);

stack_pointer i_stack_pointer (
    .clk50M_i (clk50M_i),
    .rst_ni   (rst_ni),
    .inc_i    (sp_inc),
    .dec_i    (sp_dec),
    .load_i   (sp_load),
    .out_i    (sp_rd),
    .sp_dat_io(data_bus),
    .sp_addr_o(sp_out)
);

reg_8bit a_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (a_reg_rd),
    .ff_wr   (a_reg_wr),
    .bus_o   (a_out),
    .bus_io  (data_bus)
);

latch_8bit a_latch (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .latch_rd(a_latch_rd),
    .latch_wr(a_latch_wr),
    .data_d  (a_out),
    .data_q  (alu_a)
);

reg_8bit temp_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (temp_reg_rd),
    .ff_wr   (temp_reg_wr),
    .bus_o   (temp_out),
    .bus_io  (data_bus)
);

reg_8bit b_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (b_reg_rd),
    .ff_wr   (b_reg_wr),
    .bus_o   (b_out),
    .bus_io  (data_bus)
);

reg_8bit c_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (c_reg_rd),
    .ff_wr   (c_reg_wr),
    .bus_o   (c_out),
    .bus_io  (data_bus)
);

reg_8bit d_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (d_reg_rd),
    .ff_wr   (d_reg_wr),
    .bus_o   (d_out),
    .bus_io  (data_bus)
);

reg_8bit e_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (e_reg_rd),
    .ff_wr   (e_reg_wr),
    .bus_o   (e_out),
    .bus_io  (data_bus)
);

reg_8bit h_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (h_reg_rd),
    .ff_wr   (h_reg_wr),
    .bus_o   (h_out),
    .bus_io  (data_bus)
);

reg_8bit l_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (l_reg_rd),
    .ff_wr   (l_reg_wr),
    .bus_o   (l_out),
    .bus_io  (data_bus)
);

endmodule