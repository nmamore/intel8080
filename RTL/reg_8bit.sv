/*
* @file reg_8bit.sv
* @brief 8-Bit Register
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/3/2023
*/

`timescale 1ns / 100ps

module reg_8bit (
    input  logic       clk50M_i,
    input  logic       rst_ni,
                        
    input  logic       ff_rd,
    input  logic       ff_wr,
    
    output logic [7:0] bus_o,
    inout  logic [7:0] bus_io
);

logic [7:0] ff_dat;

//Sets the output to the stored internal data if FF is selected
//Otherwise go high-impedance
assign bus_io = (ff_rd) ? ff_dat:
                          8'hzz;

assign bus_o = ff_dat;

//FF for storing data on the input
always_ff @ (posedge clk50M_i or negedge rst_ni) begin
    if (!rst_ni) begin
        ff_dat <= 8'h00;
    end
    else if (ff_wr) begin
        ff_dat <= bus_io;
    end
end

endmodule