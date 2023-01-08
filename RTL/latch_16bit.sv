/*
* @file latch_16bit.sv
* @brief 16-Bit Latch
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/4/2023
*/

`timescale 1ns / 100ps

module latch_16bit (
    input  logic        clk50M_i,
    input  logic        rst_ni,
                        
    input  logic        latch_rd,
    input  logic        latch_wr,
    
    input  logic [15:0] data_d,
    output logic [15:0] data_q
);

logic [15:0] latch_dat;

//Sets the output to the stored internal data if FF is selected
//Otherwise go high-impedance
assign data_q = (latch_rd) ? latch_dat:
                             16'hzzzz;

//FF for storing data on the input
always_ff @ (posedge clk50M_i or negedge rst_ni) begin
    if (!rst_ni) begin
        latch_dat <= 16'h0000;
    end
    else if (latch_wr) begin
        latch_dat <= data_d;
    end
end

endmodule