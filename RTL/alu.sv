/*
* @file alu.sv
* @brief AlU for the Intel 8080
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/8/2023
*/

`timescale 1ns / 100ps

localparam INC                = 4'h0;
localparam DEC                = 4'h1;
localparam ADD                = 4'h2;
localparam ADD_CARRY          = 4'h3;
localparam SUB                = 4'h4;
localparam SUB_BORROW         = 4'h5;
localparam AND                = 4'h6;
localparam XOR                = 4'h7;
localparam OR                 = 4'h8;
localparam ROTATE_LEFT        = 4'h9;
localparam ROTATE_LEFT_CARRY  = 4'hA;
localparam ROTATE_RIGHT       = 4'hB;
localparam ROTATE_RIGHT_CARRY = 4'hC;
localparam COMPLEMENT         = 4'hD;
localparam CMC                = 4'hE;
localparam STC                = 4'hF;

module alu
(
    input logic  [7:0] a_dat_i,
    input logic  [7:0] b_dat_i,
    
    input logic        flag_out_i,
    input logic        alu_out_i,
    input logic  [3:0] alu_sel_i,
    
    output logic [3:0] flag_reg,
    
    output logic [7:0] alu_dat_o
);

logic [7:0] alu_dat;
logic [3:0] flag_dat;

logic zero;
logic sign;
logic parity;
logic cout;

assign flag_dat = {zero, sign, parity, cout};
 
assign alu_dat_o = (alu_out_i) ? alu_dat:
                                 8'hzz;
                                 
assign flag_reg = (flag_out_i) ? flag_dat:
                                 4'hz;
                                 
assign zero = |alu_dat;
assign sign = alu_dat[7];
assign parity = ^alu_dat;

always_comb begin
    case (alu_sel_i)
        INC: begin
            alu_dat = b_dat_i + 1'b1;
        end
        DEC: begin
            alu_dat = b_dat_i - 1'b1;
        end
        ADD: begin
            {cout, alu_dat} = a_dat_i + b_dat_i;
        end
        ADD_CARRY: begin
            {cout, alu_dat} = a_dat_i + b_dat_i + cout;
        end
        SUB: begin
            {cout, alu_dat} = a_dat_i - b_dat_i;
        end
        SUB_BORROW: begin
            {cout, alu_dat} = a_dat_i - b_dat_i - cout;
        end
        AND: begin
            alu_dat = a_dat_i & b_dat_i;
        end
        XOR: begin
            alu_dat = a_dat_i ^ b_dat_i;
        end
        OR: begin
            alu_dat = a_dat_i | b_dat_i;
        end
        ROTATE_LEFT: begin
            for (int i = 0; i < 8; i++) begin
                if (i == 0) begin
                    alu_dat[i] = a_dat_i[7];
                    cout = a_dat_i[7];
                end
                else if (i < 8) begin
                    alu_dat[i] = a_dat_i[i-1];
                end
            end 
        end
        ROTATE_LEFT_CARRY: begin
            for (int i = 0; i < 8; i++) begin
                if (i == 0) begin
                    alu_dat[i] = cout;
                end
                else if (i < 7) begin
                    alu_dat[i] = a_dat_i[i-1];
                end
                else if (i == 7) begin
                    alu_dat[i] = a_dat_i[i-1];
                    cout = a_dat_i[i];
                end
            end 
        end
        ROTATE_RIGHT: begin
            for (int i = 0; i < 8; i++) begin
                if (i < 7) begin
                    alu_dat[i] = a_dat_i[i+1];
                end
                else if (i == 7) begin
                    alu_dat[i] = a_dat_i[0];
                    cout = a_dat_i[0];
                end
            end
        end
        ROTATE_RIGHT_CARRY: begin
            for (int i = 0; i < 8; i++) begin
                if (i == 0) begin
                    cout = a_dat_i[i];
                    alu_dat[i] = a_dat_i[i+1];
                end
                else if (i < 7) begin
                    alu_dat[i] = a_dat_i[i+1];
                end
                if (i == 7) begin
                    alu_dat[i] = cout;
                end
            end
        end
        COMPLEMENT: begin
            alu_dat = !a_dat_i;
        end
        CMC: begin
            cout = !cout;
        end
        STC: begin
            cout = 1'b1;
        end
    endcase
end

endmodule