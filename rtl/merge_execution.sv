/*
Write a markdown documentation for this systemverilog module: execution unit merge
Base Author : Ramisa Tahsin (ramisashreya@gmail.com)
Author      : Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

`include "simple_processor_pkg.sv"

module merge_execution
import simple_processor_pkg::*;
#(
    parameter int MEM_ADDR_WIDTH = simple_processor_pkg::ADDR_WIDTH,  // With of memory address bus
    parameter int MEM_DATA_WIDTH = simple_processor_pkg::DATA_WIDTH   // With of memory data bus
) (
      //-PORTS
  input  logic  [DATA_WIDTH-1:0]     rs1_data_i,     //source register 1 data input from RF
  input  func_t                      func_i,         //input func_i from op code
  input  logic  [5:0]                imm_i,          //immiediate input
  input  logic  [DATA_WIDTH-1:0]     rs2_data_i,     //second register value input

  input  logic  [MEM_DATA_WIDTH-1:0] dmem_rdata_i,   // DMEM data of the requested address
  input  logic                       dmem_ack_i,     // Acknowledge if data request is completed

  output logic                       dmem_req_o,     // DMEM is active, always HIGH
  output logic  [MEM_ADDR_WIDTH-1:0] dmem_addr_o,    // Data to be read/written to this address
  output logic                       dmem_we_o,      // Active for STORE operation
  output logic  [MEM_DATA_WIDTH-1:0] dmem_wdata_o,   // DATA to be stored in DMEM
  output logic  [DATA_WIDTH-1:0]     rd_data_o       // Final Output from mux
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // logic       [DATA_WIDTH-1:0]     res_math;           //result for add,addi,sub
  // logic       [DATA_WIDTH-1:0]     res_gate;           //result for gate operation
  // logic       [DATA_WIDTH-1:0]     res_shift;          //result for shift operation
  // logic       [DATA_WIDTH-1:0]     res_mem;            //result for memory operation

  logic       [DATA_WIDTH-1:0]     rs2_data_i_2c;      //intermediate value for 2's complement
  logic       [DATA_WIDTH-1:0]     imm_i_extended;     //Sign extension for imm_i


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //2's complement for the sub operation
  assign rs2_data_i_2c = ~rs2_data_i + 1;

  //Sign extention for the imm_iediate
  assign imm_i_extended = {{26{imm_i[5]}}, imm_i};

  //Memory address and data assignments
  assign dmem_addr_o  = rs1_data_i;                     // RS1 has address which is load

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //mimicking the input mux operation for ALU Math
  always_comb begin
    case(func_i)
      ADDI    : rd_data_o = rs1_data_i + imm_i_extended;
      ADD     : rd_data_o = rs1_data_i + rs2_data_i;
      SUB     : rd_data_o = rs1_data_i + rs2_data_i_2c;
      AND     : rd_data_o = rs1_data_i & rs2_data_i;  // AND operation
      OR      : rd_data_o = rs1_data_i | rs2_data_i;  // OR operation
      XOR     : rd_data_o = rs1_data_i ^ rs2_data_i;  // XOR operation
      NOT     : rd_data_o = ~rs1_data_i;              // NOT operation
      SLL     : rd_data_o = rs1_data_i << rs2_data_i;
      SLLI    : rd_data_o = rs1_data_i << imm_i_extended;
      SLR     : rd_data_o = rs1_data_i >> rs2_data_i;
      SLRI    : rd_data_o = rs1_data_i >> imm_i_extended;
      LOAD    : begin
                dmem_we_o = '0;                            // Write is active
                rd_data_o = dmem_rdata_i;                    // Data read from memory
                end
      STORE   : begin
                dmem_we_o    =  '1;                        // Write is active
                dmem_wdata_o = rs2_data_i;
                rd_data_o ='x;             // RS2 data to be stored to memory
      end
      default:  rd_data_o = 32'b0;               // Default rd_data_o if no valid operation
    endcase
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  `ifdef SIMULATION
    initial begin
      if (DATA_WIDTH > 2) begin
        $display("\033[1;33m%m DATA_WIDTH\033[0m");
      end
    end
  `endif  // SIMULATION

endmodule
