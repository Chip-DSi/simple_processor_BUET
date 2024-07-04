
/*
Write a markdown documentation for this systemverilog module:
Author : Bokhtiar Foysol Himon (bokhtiarfoysol@gmail.com)
*/

module alu_shift 
import simple_processor_pkg::DATA_WIDTH;
#(
    //-PARAMETERS
    //-LOCALPARAMS
    parameter int SHIFT_WIDTH = 5
) (
    //-PORTS
    input logic   [DATA_WIDTH - 1:0 ]   rs1_data_i, //input data from Rs1
    input logic   [DATA_WIDTH - 1:0 ]   rs2_data_i, //input data from Rs2
    input logic   [15:0 ]               func_t,     //input func_t from Instruction Decoder

    output logic  [DATA_WIDTH - 1:0 ]   result      //output result
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                                shift_r;           //shift right if HIGH, shift left if LOW
  logic           [DATA_WIDTH - 1:0 ]  imm;               //extracted imm from func_t
  logic           [DATA_WIDTH - 1:0 ]  imm_extended;      //extended 32 bit imm
  logic           [SHIFT_WIDTH - 1:0]  shift_amount;      //number of bits we want to shift
                                                          //extracted from imm or Rs2
  logic           [DATA_WIDTH - 1:0 ]  stage[SHIFT_WIDTH];//array of registers representing 
                                                          //intermediate stages
  logic           [DATA_WIDTH - 1:0 ]  lr_init;
  logic           [DATA_WIDTH - 1:0 ]  lr_final;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
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
    assign lr_init[i] = shift_r ? rs1_data_i[DATA_WIDTH-1-i] : rs1_data_i[i];
    assign lr_final[i] = shift_r ? stage[SHIFT_WIDTH-1][DATA_WIDTH-1-i]
                                       : stage[SHIFT_WIDTH-1][i];
  end

  assign stage[0] = shift_amount[0] ? {lr_init, 1'b0}: lr_init;
  for (genvar i = 1; i < SHIFT_WIDTH; i++) begin
    assign stage[i] = shift_amount[i] ? {stage[i-1], {(2**i){1'b0}}} : stage[i-1];
  end

  assign result = lr_final;

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