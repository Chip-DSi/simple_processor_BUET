/*
Write a markdown documentation for this systemverilog module:
Author : Bokhtiar Foysol Himon (bokhtiarfoysol@gmail.com)
*/

<<<<<<< HEAD
module alu_shift 
import simple_processor_pkg::DATA_WIDTH;
#(
    //-PARAMETERS
    //-LOCALPARAMS
    parameter int SHIFT_WIDTH = 5
) (
    //-PORTS
    input logic   [DATA_WIDTH - 1:0] rs1_data_i,
    input logic   [DATA_WIDTH - 1:0] rs2_data_i,
    input instr_t func_i,

    output logic [DATA_WIDTH - 1:0] result
=======
module shift_left (
    input  logic        clk,
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amount,  // assuming 5-bit shift amount to cover shift ranges from 0 to 31
    output logic [31:0] data_out
);

    always_ff @(posedge clk) begin
        data_out <= data_in << shift_amount;
    end

endmodule

module alu_shift #(
    //-PARAMETERS
    //-LOCALPARAMS
    parameter int DATA_WIDTH = 32
) (
    //-PORTS
    input logic clk,
    input logic [DATA_WIDTH - 1:0] rs1_i,
    input logic [DATA_WIDTH - 1:0] rs2_i,
    input logic [DATA_WIDTH - 1:0] imm,
    input logic use_imm,
    input logic shift_l

    output logic [DATA_WIDTH - 1:0] rd_o
>>>>>>> 33525d2 (added SLL, SLLI, SLR, SLRI to alu_shift)
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

<<<<<<< HEAD
  logic                     shift_r;
  logic                     use_imm;
  logic [DATA_WIDTH - 1:0]  imm;
  logic [SHIFT_WIDTH- 1:0] 
  logic [SHIFT_WIDTH - 1:0]  shift_amount;
  logic [DATA_WIDTH-1:0]    stage[SHIFT_WIDTH];
  logic [DATA_WIDTH-1:0]    lr_init;
  logic [DATA_WIDTH-1:0]    lr_final;

=======
logic [DATA_WIDTH - 1:0] shift_amount;
>>>>>>> 33525d2 (added SLL, SLLI, SLR, SLRI to alu_shift)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
always_comb begin
    if(use_imm)
        shift_amount = imm;
    else
        shift_amount = rs2_i;
end

<<<<<<< HEAD


  for (genvar i = 0; i < DATA_WIDTH; i++) begin : g_right_shift_invertions
    assign lr_init[i] = shift_r ? rs1_data_i[DATA_WIDTH-1-i] : rs1_data_i[i];
    assign lr_final[i] = shift_r ? stage[SHIFT_WIDTH-1][DATA_WIDTH-1-i]
                                       : stage[SHIFT_WIDTH-1][i];
  end

  assign stage[0] = shift_amount[0] ? {lr_init, 1'b0}: lr_init;
  for (genvar i = 1; i < SHIFT_WIDTH; i++) begin : g_shift_mux
    assign stage[i] = shift_amount[i] ? {stage[i-1], {(2**i){1'b0}}} : stage[i-1];
  end

  assign data_o = lr_final;
=======
>>>>>>> 33525d2 (added SLL, SLLI, SLR, SLRI to alu_shift)
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk) begin
    if(shift_l)
        rd_o <= rs1_i << shift_amount;
    else
        rd_o <= rs1_i >> shift_amount;
end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule