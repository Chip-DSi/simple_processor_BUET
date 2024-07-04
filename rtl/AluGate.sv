/*
Write a markdown documentation for this systemverilog module:
Author : Mymuna Khatun Sadia (maimuna14400@gmail.com)
*/

`include "simple_processor_pkg.sv"
module AluGate
  import simple_processor_pkg::*;
#(
) (
  output  logic [DATA_WIDTH-1:0] rd_data_o,   // destination reg data
  input   logic [DATA_WIDTH-1:0] rs1_data_i,  // source reg 01 data
  input   logic [DATA_WIDTH-1:0] rs2_data_i,  // source reg 02 data
  input   logic                  func_o       // function of and, or, xor, not
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] result;// intermediate result

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    case (func_o)
      AND:      result = rs1_data_i & rs2_data_i;  // AND operation
      OR:       result = rs1_data_i | rs2_data_i;  // OR operation
      XOR:      result = rs1_data_i ^ rs2_data_i;  // XOR operation
      NOT:      result = ~rs1_data_i;              // NOT operation (only uses rs1_data_i)
      default:  result = {DATA_WIDTH{1'b0}};       // Default case to handle invalid opcodes
    endcase
  end

  // Assign the result to the output port
  assign rd_data_o = result;

endmodule
