/*
Write a markdown documentation for this systemverilog module:
This module takes in Rs1, Rs2 and an immediate. Shifts the value of Rs1 by Rs2 or immediate
Author : Bokhtiar Foysol Himon (bokhtiarfoysol@gmail.com)
*/

`include "simple_processor_pkg.sv"

module alu_shift
import simple_processor_pkg::*;
#(
    //-PARAMETERS
    //-LOCALPARAMS
) (
    //-PORTS
    input logic   [DATA_WIDTH - 1:0]   rs1_data_i, //input data from Rs1
    input logic   [DATA_WIDTH - 1:0]   rs2_data_i, //input data from Rs2
    input func_t                       func_i,     //input func_t from Instruction Decoder
    input logic   [5:0]                imm,        //extracted imm from func_t
    output logic  [DATA_WIDTH - 1:0]   result      //output result
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                                shift_r;           //shift right if HIGH, shift left if LOW
  logic           [DATA_WIDTH - 1:0 ]  imm_extended;      //extended 32 bit imm
  logic           [DATA_WIDTH - 1:0 ]  shift_amount;      //number of bits we want to shift extracted from imm or Rs2

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign imm_extended = {{26{imm[5]}}, imm};//sign-extending immediate

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    case(func_i)
      SLL     : begin
                shift_r = '0;
                shift_amount = rs2_data_i;
      end
      SLLI    : begin
                shift_r = '0;
                shift_amount = imm_extended;
      end
      SLR     : begin
                shift_r = '1;
                shift_amount = rs2_data_i;
      end
      SLRI    : begin
                shift_r = '1;
                shift_amount = imm_extended;
      end
      default : begin
                shift_r = '1;
                shift_amount = rs2_data_i;
      end
    endcase
  end

  assign result = shift_r? rs1_data_i >> shift_amount : rs1_data_i << shift_amount;
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
