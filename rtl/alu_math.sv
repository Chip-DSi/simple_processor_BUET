/*
This block is within the execution block which is going to perform only ADDI, ADD, SUB.
Author : Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

`include "simple_processor_pkg.sv"

module alu_math
import simple_processor_pkg::*;
#(
) (
    input  logic  [DATA_WIDTH-1:0] rs1_data_i,     //source register 1 data input from RF
    input  func_t                   func_i,        //confused about instr_t
    input  logic  [5:0]            imm,            //immediate input
    input  logic  [DATA_WIDTH-1:0] rs2_data_i,     //second register value input

    output logic  [DATA_WIDTH-1:0] result          //final result input

);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] rs2_data_i_2c;
  logic [DATA_WIDTH-1:0] imm_extended;
  logic [DATA_WIDTH-1:0] selected_input;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //2's complement for the sub operation
  assign rs2_data_i_2c = ~rs2_data_i + 1;

  //Sign extention for the immediate
  assign imm_extended = {{26{imm[5]}}, imm};

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //mimicking the input mux operation

  always_comb begin
    case(func_i)
      ADDI: selected_input = imm_extended;
      ADD : selected_input = rs2_data_i;
      SUB : selected_input = rs2_data_i_2c;
      //every other input selection for different block will be done here
      default : selected_input = 32'b0;
    endcase
  end

  assign result = rs1_data_i + selected_input;

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
