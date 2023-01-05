/*
* @file program_counter.sv
* @brief Program Counter for the Intel 8080
* @author Nicholas Amore namore7@gmail.com
* @date Created 1/2/2023
*/

`timescale 1ns / 100ps

module program_counter
(
    input logic         clk50M_i,
    input logic         rst_ni,
    
    input logic         load_i,
    input logic         inc_i,
    
    input logic  [15:0] addr_i,
    output logic [15:0] addr_o
    
);

logic [15:0] pc_count;

//Define the states
typedef enum{
    StIdle, StReset, StInc, StLoad1, StLoad2
} pc_state_e;

pc_state_e pc_state_d, pc_state_q;

assign addr_o = pc_count;

//Combinational decode of the states
always_comb begin
    pc_state_d = pc_state_q;
    case(pc_state_q)
        //StIdle: Waits for control signal to increment or load address
        StIdle: begin
            //Checks if control has indicated an address load
            if(load_i) begin
                pc_state_d = StLoad1;
            end
            //Checks if control has indicated an address increment
            else if (inc_i) begin
                pc_state_d = StInc;
            end
        end
        //StReset: Reset state of PC. Sets initial address back to 0
        StReset: begin
            pc_count = 16'h0000;
            pc_state_d = StIdle;
        end
        //StInc: Increments the PC
        StInc: begin
            pc_count = pc_count + 1'b1;
            pc_state_d = StIdle;
        end
        //StLoad1: Loads in the LSB of the address from the databus
        StLoad1: begin
            pc_count[7:0] = addr_i;
            pc_state_d = StLoad2;
        end
        //StLoad2: Loads in the MSB of the address from the databus
        StLoad2: begin
            pc_count[15:8] = addr_i;
            pc_state_d = StIdle;
        end
        default: begin
            pc_state_d = StIdle;
        end
    endcase
end

//Register the state
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        pc_state_q <= StReset;
    end
    else begin
        pc_state_q <= pc_state_d;
    end
end

endmodule