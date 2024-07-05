/*
Write a markdown documentation for this systemverilog module:
Author : Md. Nayem Hasan (nayem90375@gmail.com)
*/


module alumem
import simple_processor_pkg::DATA_WIDTH;
import simple_processor_pkg::ADDR_WIDTH;
 #(
    //parameter int MEM_ADDR_WIDTH =32,
    //parameter int MEM_DATA_WIDTH =32
    //-LOCALPARAMS
)

(
   ////////////////////////
    input logic [DATA_WIDTH-1:0] rs1_data_i,   // Memory address
    input func_t func_i,                        // Function code to select LOAD or STORE
    input logic [DATA_WIDTH-1:0] rs2_data_i,   // Data to be stored for STORE operation
    input logic we_i,                          // Write enable input signal
    input logic [DATA_WIDTH-1:0] mem_data_i,   // Data read from memory for LOAD operation
    output logic [DATA_WIDTH-1:0] rd_data_o,   // output from the memory operation block to the destination register
    output logic [DATA_WIDTH-1:0] result,      // Result (data read from memory for LOAD)
    output logic [DATA_WIDTH-1:0] mem_addr_o,  // Memory address output (for LOAD/STORE)
    output logic [DATA_WIDTH-1:0] mem_data_o,  // Data to be written to memory (for STORE)
    //output logic mem_write_o                   // Memory write signal (for STORE)


);

  //-ASSIGNMENTS
  // Memory control signals
  // Memory address and data assignments
    assign mem_addr_o = rs1_data_i;
    assign mem_data_o = rs2_data_i;
    assign mem_data_i = rd_data_o;

  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Control logic for LOAD and STORE operations


    always_comb begin
      case(func_i)
        LOAD: begin
          result = mem_data_i; // Data read from memory
        end
        STORE: always @(posedge clk_i) begin
           if(we_i)  begin // Enable memory write based on we_i
          result = mem_data_o;  // Data to be stored to memory
        end
      end
        default: begin
          result = 32'b0; // Default result if no valid operation
        end
      endcase
    end
   endmodule


