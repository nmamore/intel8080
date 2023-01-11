/*
* @file latch_8bit.sv
* @brief 8-Bit Latch
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/4/2023
*/

`timescale 1ns / 100ps

module latch_8bit (
    input  logic       clk50M_i,
    input  logic       rst_ni,
                        
    input  logic       latch_rd,
    input  logic       latch_wr,
    
    input  logic [7:0] data_d,
    output logic [7:0] data_q
);

logic [7:0] latch_dat;

//Sets the output to the stored internal data if FF is selected
//Otherwise go high-impedance
assign data_q = (latch_rd) ? latch_dat:
                             8'hzz;

//FF for storing data on the input
always_ff @ (posedge clk50M_i or negedge rst_ni) begin
    if (!rst_ni) begin
        latch_dat <= 8'h00;
    end
    else if (latch_wr) begin
        latch_dat <= data_d;
    end
end

endmodule