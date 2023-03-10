/*
* @file tb_intel8080_top.sv
* @brief top-level file for the PIC24 testbench
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/2/2023
*/

`timescale 1ns/1ps

module tb_intel8080_top();
	
localparam PLD_CLK_SPEED = 10;

logic pld_mclk;
logic pld_rstn;

//Instantiates FPGA top level file for test bench
intel8080_top uut (
	.clk50M_i(pld_mclk),
	.rst_ni  (pld_rstn)
);

//reference clock input to system for FPGA
initial begin
	$display("PLD clk started");
	pld_mclk = 1'b0;
	#15;
	forever
	begin
		#PLD_CLK_SPEED pld_mclk = 1'b1; //wait half period then toggle clock
		#PLD_CLK_SPEED pld_mclk = 1'b0;
	end
end

//System Reset
initial begin
	pld_rstn = 1'b0;
	#15;
	pld_rstn = 1'b1;
end

initial begin
	RunSystem();
	$stop;
end

task RunSystem();

endtask 

endmodule