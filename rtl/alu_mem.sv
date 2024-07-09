/*
Write a markdown documentation for this systemverilog module:
Author : Md. Nayem Hasan (nayem90375@gmail.com)
*/

`include "simple_processor_pkg.sv"

module alu_mem
    import simple_processor_pkg::*;
#(
    // Parameter definitions if needed
    // parameter int MEM_ADDR_WIDTH = 32,
    // parameter int MEM_DATA_WIDTH = 32
    // Local parameters
)
(
    //////////// Inputs ////////////
    input logic [DATA_WIDTH-1:0] rs1_data_i,   // Memory address
    input func_t func_i,                        // Function code to select LOAD or STORE
    input logic [DATA_WIDTH-1:0] rs2_data_i,   // Data to be stored for STORE operation
    input logic we_i,                          // Write enable input signal
    input logic [DATA_WIDTH-1:0] rd_data_i,   // Data read from memory for LOAD operation
    //////////// Outputs ////////////
    //output logic [DATA_WIDTH-1:0] result,      // Result (data read from memory for LOAD)
    output logic [DATA_WIDTH-1:0] mem_addr_o,  // Memory address output (for LOAD/STORE)
    output logic [DATA_WIDTH-1:0] mem_data_o   // Data to be written to memory (for STORE)
    // output logic mem_write_o                   // Memory write signal (for STORE)
);

  // Memory address and data assignments
  assign mem_addr_o = rs1_data_i;

  // Control logic for LOAD and STORE operations
  always_comb begin
      case(func_i)
        LOAD:     if(!we_i) mem_data_o = rd_data_i; // Data read from memory
        STORE:    if (we_i) mem_data_o = rs2_data_i;  // Data to be stored to memory
        default:  mem_data_o = 32'b0; // Default result if no valid operation
      endcase
  end

endmodule
