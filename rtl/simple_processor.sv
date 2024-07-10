/*
Write a markdown documentation for this systemverilog module:
Author : name (email)
*/

module simple_processor #(
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
    input  logic                      imem_ack_i,

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

  logic [MEM_ADDR_WIDTH-1:0] temp_pc_o; // intermediate pc value
  logic                      valid_pc_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Instruction Decoder
  ins_dec #() u_ins_dec (
    .imem_addr_i(imem_addr_o),    // from PC to IMEM to ID
    .imem_rdata_i(imem_rdata_i),  // from IMEM
    .imem_ack_i(imem_ack_i),      // from IMEM
    .func_o,                      // to reg file
    .we_o,                        // to reg file
    .rd_addr_o,                   // to reg file
    .rs1_addr_o,                  // to reg file
    .rs2_addr_o,                  // to reg file
    .imm_o(imm),
    .valid_pc_o(valid_pc_i)
  );

  // Register File
  reg_file #() u_reg_file (
    
  )

  // Execution Block
  merge_execution #() u_merge_execution (
    .rs1_data_i,  // from reg file
    .rs2_data_i,  // from reg file
    .func_i,      // from reg file
    .imm(imm),    // from instruction decoder
    .result()     // to reg file
  )

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    case(valid_pc_i)
      1'b1       :  temp_pc_o   = imem_addr_o + 2; // next pc
      1'b0       :  temp_pc_o   = boot_addr_i;     // boot address
      default    :  temp_pc_o   = boot_addr_i;     // for default boot address
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
      imem_addr_o <= temp_pc_o;
    end
  end

endmodule
