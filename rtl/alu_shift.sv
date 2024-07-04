/*
Write a markdown documentation for this systemverilog module:
Author : Bokhtiar Foysol Himon (bokhtiarfoysol@gmail.com)
*/

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 08e129931861f2d50972c98ad04a93f388f2c99e
module alu_shift 
import simple_processor_pkg::DATA_WIDTH;
#(
    //-PARAMETERS
    //-LOCALPARAMS
<<<<<<< HEAD
    parameter int DATA_WIDTH = 32
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
=======
    parameter int SHIFT_WIDTH = 5
) (
    //-PORTS
    input logic   [DATA_WIDTH - 1:0 ]   rs1_data_i, //input data from Rs1
    input logic   [DATA_WIDTH - 1:0 ]   rs2_data_i, //input data from Rs2
    input logic   [15:0 ]               func_t,     //input func_t from Instruction Decoder

    output logic  [DATA_WIDTH - 1:0 ]   result      //output result
>>>>>>> 08e129931861f2d50972c98ad04a93f388f2c99e
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

<<<<<<< HEAD
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
=======
  logic                                shift_r;           //shift right if HIGH, shift left if LOW
  logic           [DATA_WIDTH - 1:0 ]  imm;               //extracted imm from func_t
  logic           [DATA_WIDTH - 1:0 ]  imm_extended;      //extended 32 bit imm
  logic           [SHIFT_WIDTH - 1:0]  shift_amount;      //number of bits we want to shift
                                                          //extracted from imm or Rs2
  logic           [DATA_WIDTH - 1:0 ]  stage[SHIFT_WIDTH];//array of registers representing 
                                                          //intermediate stages
  logic           [DATA_WIDTH - 1:0 ]  lr_init;
  logic           [DATA_WIDTH - 1:0 ]  lr_final;
>>>>>>> 08e129931861f2d50972c98ad04a93f388f2c99e

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
<<<<<<< HEAD
always_comb begin
    if(use_imm)
        shift_amount = imm;
    else
        shift_amount = rs2_i;
end

<<<<<<< HEAD


  for (genvar i = 0; i < DATA_WIDTH; i++) begin : g_right_shift_invertions
=======
  
  assign imm = func_t[9:4];  //extracting immediate from func_t
  assign imm_extended = {{26{imm[5]}}, imm};//extending immediate

  always_comb begin
    case(func_t)
      SLL     : shift_r = '0,
                shift_amount = rs2_data_i;
      SLLI    : shift_r = '0,
                shift_amount = imm_extended;
      SLR     : shift_r = '1,
                shift_amount = rs2_data_i;
      SLRI    : shift_r = '1,
                shift_amount = imm_extended;
      default : shift_r = '0,
                shift_amount = rs2_data_i;
    endcase
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  for (genvar i = 0; i < DATA_WIDTH; i++) begin
>>>>>>> 08e129931861f2d50972c98ad04a93f388f2c99e
    assign lr_init[i] = shift_r ? rs1_data_i[DATA_WIDTH-1-i] : rs1_data_i[i];
    assign lr_final[i] = shift_r ? stage[SHIFT_WIDTH-1][DATA_WIDTH-1-i]
                                       : stage[SHIFT_WIDTH-1][i];
  end

  assign stage[0] = shift_amount[0] ? {lr_init, 1'b0}: lr_init;
<<<<<<< HEAD
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
=======
  for (genvar i = 1; i < SHIFT_WIDTH; i++) begin
    assign stage[i] = shift_amount[i] ? {stage[i-1], {(2**i){1'b0}}} : stage[i-1];
  end

  assign result = lr_final;
>>>>>>> 08e129931861f2d50972c98ad04a93f388f2c99e

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