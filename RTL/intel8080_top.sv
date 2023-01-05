/*
* @file intel8080_top.sv
* @brief top-level file for the Intel 8080
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/2/2023
*/

`timescale 1ns / 100ps

`define B_REG = 3'b000;
`define C_REG = 3'b001;
`define D_REG = 3'b010;
`define E_REG = 3'b011;
`define H_REG = 3'b100;
`define L_REG = 3'b101;
`define A_REG = 3'b111;

`define BC_REG = 3'b000;
`define DE_REG = 3'b001;
`define HL_REG = 3'b010;
`define SP_REG = 3'b011;
`define PC_REG = 3'b100;

module intel8080_top
(
    input logic clk50M_i,
    input logic rst_ni
    
);

//Top-level bus signals
logic [7:0]  data_bus;
logic [15:0] address_bus;

logic [15:0] addr_latch;

//Control signals
logic pc_load;
logic pc_inc;

logic reg_write;
logic reg_read;

logic [2:0] reg8_sel;
logic [1:0] reg16_sel;

//Register Signals
logic [6:0] mux_write;
logic [6:0] mux_read;

logic a_reg_wr;
logic a_reg_rd;
logic [7:0] a_out;

logic b_reg_wr;
logic b_reg_rd;
logic [7:0] b_out;

logic c_reg_wr;
logic c_reg_rd;
logic [7:0] c_out;

logic [15:0] bc_out;

logic d_reg_wr;
logic d_reg_rd;
logic [7:0] d_out;

logic e_reg_wr;
logic e_reg_rd;
logic [7:0] e_out;

logic [15:0] de_out;

logic h_reg_wr;
logic h_reg_rd;
logic [7:0] h_out;

logic l_reg_wr;
logic l_reg_rd;
logic [7:0] l_out;

logic [15:0] hl_out;

logic [15:0] sp_out;

logic [15:0] pc_out;

mux_write = {a_reg_wr, b_reg_wr, c_reg_wr, d_reg_wr, e_reg_wr, h_reg_wr, l_reg_wr};
mux_read  = {a_reg_rd, b_reg_rd, c_reg_rd, d_reg_rd, e_reg_rd, h_reg_rd, l_reg_rd};

always_comb begin
    case (reg8_sel) begin
        A_REG: begin
            mux_write = {reg_write, 6'b000000};
            mux_read  = {reg_read,  6'b000000};
        end
        B_REG: begin
            mux_write = {1'b0, reg_write, 5'b00000};
            mux_read  = {1'b0, reg_read,  5'b00000};
        end
        C_REG: begin
            mux_write = {2'b00, reg_write, 4'b0000};
            mux_read  = {2'b00, reg_read,  4'b0000};
        end
        D_REG: begin
            mux_write = {3'b000, reg_write, 3'b000};
            mux_read  = {3'b000, reg_read,  3'b000};
        end
        E_REG: begin
            mux_write = {4'b0000, reg_write, 2'b00};
            mux_read  = {4'b0000, reg_read,  2'b00};
        end
        H_REG: begin
            mux_write = {5'b00000, reg_write, 1'b0};
            mux_read  = {5'b00000, reg_read,  1'b0};
        end
        L_REG: begin
            mux_write = {6'b000000, reg_write};
            mux_read  = {6'b000000, reg_read};
        end
        default: begin
            mux_write = {7'b0000000};
            mux_read  = {7'b0000000};
        end
    endcase
end

//Address Latch select
always_comb begin
    case (reg16_sel) begin
        BC_REG: begin
            addr_latch = bc_out;
        end
        DE_REG: begin
            addr_latch = de_out;
        end
        HL_REG: begin
            addr_latch = hl_out;
        end
        SP_REG: begin
            addr_latch = sp_out;
        end
        PC_REG: begin
            addr_latch = pc_out;
        end
        default: begin
            addr_latch = 16'hzzzz;
        end
    endcase
end

program_counter i_program_counter (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .load_i  (pc_load),
    .inc_i   (pc_inc),
    .addr_i  (data_bus),
    .addr_o  (pc_out)
);

reg_8bit b_reg (
    .clk50M_i(clk50M_i),
    .rst_ni  (rst_ni),
    .ff_rd   (a_reg_rd),
    .ff_wr   (a_reg_wr),
    .bus_o   (a_out),
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