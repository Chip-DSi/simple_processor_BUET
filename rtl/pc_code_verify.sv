/*
Write a markdown documentation for this systemverilog module:
Author : Mymuna Khatun Sadia (maimuna14400@gmail.com)
*/

module pc_code_verify #(
    parameter int MEM_ADDR_WIDTH = simple_processor_pkg::ADDR_WIDTH,  // Width of memory address bus
    parameter int MEM_DATA_WIDTH = simple_processor_pkg::DATA_WIDTH   // Width of memory data bus
) (
    // Global Synchronous Clock
    input logic clk_i,
    // Active low asynchronous reset
    input logic arst_ni,

    // Boot address of the processor
    input logic [MEM_ADDR_WIDTH-1:0] boot_addr_i,

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

  logic [MEM_ADDR_WIDTH-1:0] imm_pc_i; // intermediate result
  logic                      valid_pc;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Instantiate for valid_pc
  ins_dec #() u_ins_dec (
    .valid_pc(valid_pc)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    case(valid_pc)
      1'b1       :  imm_pc_i   = imem_addr_o + 2; // next pc
      1'b0       :  imm_pc_i   = boot_addr_i;     // boot address
      default    :  imm_pc_i   = boot_addr_i;     // for default boot address
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
      imem_addr_o <= imm_pc_i;
    end
  end

endmodule
