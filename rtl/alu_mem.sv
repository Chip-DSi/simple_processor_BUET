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
    input func_t                  func_i,        // Function code to select LOAD or STORE
    input logic [DATA_WIDTH-1:0]  rs1_data_i,    // Memory address for LOAD/ STORE operation
    input logic [DATA_WIDTH-1:0]  rs2_data_i,    // Data to be stored for STORE operation
    input logic [DATA_WIDTH-1:0]  dmem_rd_i,     // DMEM data of the requested address
    input logic [DATA_WIDTH-1:0]  dmem_ack_i,    // Acknowledge if data request is completed
    //////////// Outputs ////////////
    output logic [DATA_WIDTH-1:0] dmem_req_o,    // DMEM is active, always HIGH
    output logic [DATA_WIDTH-1:0] dmem_addr_o,   // Data to be read/written to this address
    output logic [DATA_WIDTH-1:0] dmem_we_o,     // Active for STORE operation
    output logic [DATA_WIDTH-1:0] dmem_wdata_o,  // DATA to be stored in DMEM
    output logic [DATA_WIDTH-1:0] rd_data_o      // Data to be written to RF
);

  // Memory address and data assignments
  assign dmem_req_o   = '1;
  assign dmem_addr_o  = rs1_data_i;              // RS1 has address which is load to DMEM

  // Control logic for LOAD and STORE operations
  always_comb begin
      case(func_i)
        LOAD:     begin
          rd_data_o = dmem_rd_i;                 // Data read from memory
          dmem_we_o = '0;
        end
        STORE:    begin
          dmem_wdata_o = rs2_data_i;             // RS2 data to be stored to memory
          dmem_we_o    =  '1;                    // Write is active
        end
        default:  rd_data_o = 32'b0;             // Default result if no valid operation
      endcase
  end

endmodule
