/*
Write a markdown documentation for this systemverilog module:
Author : Mymuna Khatun Sadia (maimuna14400@gmail.com)
*/
`include "simple_processor_pkg.sv"
module simple_processor 
import simple_processor_pkg::*;
#(
    parameter int MEM_ADDR_WIDTH = simple_processor_pkg::ADDR_WIDTH,  // Width of memory address bus
    parameter int MEM_DATA_WIDTH = simple_processor_pkg::DATA_WIDTH   // Width of memory data bus
) (
    // Global Synchronous Clock
    input logic                       clk_i,
    // Active low asynchronous reset
    input logic                       arst_ni,

    // Boot address of the processor
    input logic [MEM_ADDR_WIDTH-1:0]  boot_addr_i,

    // Signifies there is active request for memory at address imem_addr_o
    output logic                      imem_req_o,
    // Instruction address bus
    output logic [MEM_ADDR_WIDTH-1:0] imem_addr_o,
    // Instruction data bus
    input  logic [MEM_DATA_WIDTH-1:0] imem_rdata_i,
    // Signifies instruction request is completed
    //input  logic                      imem_ack_i,

    // Signifies there is active request for memory at address dmem_addr_o
    output logic                      dmem_req_o,
    // Signifies it is a write operation
    output logic                      dmem_we_o,
    // Data address bus
    output logic [MEM_ADDR_WIDTH-1:0] dmem_addr_o,
    // Write data bus
    output logic [MEM_DATA_WIDTH-1:0] dmem_wdata_o,
    // Read data bus
    input  logic [MEM_DATA_WIDTH-1:0] dmem_rdata_i,
    // Signifies data request is completed
    input  logic                      dmem_ack_i
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [MEM_ADDR_WIDTH-1:0]    pc_o_temp;   // intermediate pc value
  logic                         valid_pc_i;  // from ID to PC
  logic                         we_i_temp;
  func_t                        func_i_temp;
  logic [5:0]                   imm_i_temp;
  logic [2:0]                   rd_addr_i_temp;
  logic [2:0]                   rs1_addr_i_temp;
  logic [2:0]                   rs2_addr_i_temp;
  logic [MEM_DATA_WIDTH-1:0]    rd_data_i_temp;
  logic [MEM_DATA_WIDTH-1:0]    rs1_data_i_temp;
  logic [MEM_DATA_WIDTH-1:0]    rs2_data_i_temp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Instruction Decoder
  ins_dec #() u_ins_dec (
    .imem_addr_i(imem_addr_o),         // from PC to ID
    .imem_rdata_i(imem_rdata_i),       // from IMEM
    .func_o(func_i_temp),              // to Execution block
    .we_o(we_i_temp),                  // to reg file
    .rd_addr_o(rd_addr_i_temp),        // to reg file
    .rs1_addr_o(rs1_addr_i_temp),      // to reg file
    .rs2_addr_o(rs2_addr_i_temp),      // to reg file
    .imm_o(imm_i_temp),                // to execution block
    .valid_pc_o(valid_pc_i)            // to PC
  );

  // Register File
  reg_file #() u_reg_file (
    .rs1_addr_i(rs1_addr_i_temp),      // from ID
    .rs2_addr_i(rs2_addr_i_temp),      // from ID
    .rd_addr_i(rd_addr_i_temp),        // from ID
    .rd_data_i(rd_data_i_temp),        // from Execution block
    .we_i(we_i_temp),                  // from ID
    .rs1_data_o(rs1_data_i_temp),      // to Execution block
    .rs2_data_o(rs2_data_i_temp)       // to Execution block
  )

  // Execution Block
  merge_execution #() u_merge_execution (
    .rs1_data_i(rs1_data_i_temp),      // from reg file
    .rs2_data_i(rs2_data_i_temp),      // from reg file
    .func_i(func_i_temp),              // from reg file
    .imm_i(imm_i_temp),                // from instruction decoder
    .rd_data_o(rd_data_i_temp)         // to reg file
  )

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    case(valid_pc_i)
      1'b1       :  pc_o_temp   = imem_addr_o + 2; // next pc
      1'b0       :  pc_o_temp   = boot_addr_i;     // boot address
      default    :  pc_o_temp   = boot_addr_i;     // for default boot address
    endcase
  end

  // hardcode imem_req_o = 1 always
  assign imem_req_o = 1'b1;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      imem_addr_o <= '0;
    end else begin
      imem_addr_o <= pc_o_temp;
    end
  end

endmodule
