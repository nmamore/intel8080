/*
* @file stack_pointer.sv
* @brief Stack Pointer for the Intel 8080
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/6/2023
*/

`timescale 1ns / 100ps

module stack_pointer
(
    input logic         clk50M_i,
    input logic         rst_ni,
    
    input logic         inc_i,
    input logic         dec_i,
    
    input logic         load_i,
    input logic         out_i,
    
    inout logic  [7:0]  sp_dat_io,
    output logic [15:0] sp_addr_o
    
);

logic [15:0] sp_addr;
logic [7:0]  sp_out;

//Define the states
typedef enum{
    StIdle, StInc, StDec, StLoad1, StLoad2, StOut1, StOut2
} sp_state_e;

sp_state_e sp_state_d, sp_state_q;

assign sp_dat_io = (out_i) ? sp_out:
                             8'hzz;
                             
assign sp_addr_o = sp_addr;

//Combinational decode of the states
always_comb begin
    sp_state_d = sp_state_q;
    case(sp_state_q)
        //StIdle: Waits for control signal to increment or load address
        StIdle: begin
            //Checks if control has indicated an SP load
            if (!rst_ni) begin
                sp_addr = 16'h0000;
                sp_out = 8'h00;
            end
            else if(load_i) begin
                sp_state_d = StLoad1;
            end
            //Checks if control has indicated to output the SP
            else if (out_i) begin
                sp_state_d = StOut1;
            end
            //Checks if control has indicated to increment the stack address
            else if (inc_i) begin
                sp_state_d = StInc;
            end
            //Checks if control has indicated to decrement the stack address
            else if (dec_i) begin
                sp_state_d = StDec;
            end
        end
        //StInc: Increments the PC
        StInc: begin
            sp_addr = sp_addr + 1'b1;
            sp_state_d = StIdle;
        end
        StDec: begin
            sp_addr = sp_addr - 1'b1;
            sp_state_d = StIdle;
        end
        //StLoad1: Loads in the LSB of the stack address from the databus
        StLoad1: begin
            sp_addr[7:0] = sp_dat_io;
            sp_state_d = StLoad2;
        end
        //StLoad2: Loads in the MSB of the stack address from the databus
        StLoad2: begin
            sp_addr[15:8] = sp_dat_io;
            sp_state_d = StIdle;
        end
        //StOut1: Outputs the LSB of the SP
        StOut1: begin
            sp_out = sp_addr[7:0];
            sp_state_d = StOut2;
        end
        //StOut2: Outputs the MSB of the SP
        StOut2: begin
            sp_out = sp_addr[15:8];
            sp_state_d = StIdle;
        end
        default: begin
            sp_state_d = StIdle;
        end
    endcase
end

//Register the state
always_ff @(posedge clk50M_i or negedge rst_ni) begin
    if (!rst_ni) begin
        sp_state_q <= StIdle;
    end
    else begin
        sp_state_q <= sp_state_d;
    end
end

endmodule