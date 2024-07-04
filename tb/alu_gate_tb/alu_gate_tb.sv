/*
Description: ALU Gate TestBench
Author : Ramisa Tahsin Shreya (ramisashreya@gmail.com)
*/
`include "simple_processor_pkg.sv"

module alu_gate_tb;

  `define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"
  import simple_processor_pkg::*;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic  [DATA_WIDTH-1:0]    rs1_data_i  = '0;
  logic  [DATA_WIDTH-1:0]    rs2_data_i  = '0;
  logic                      func_i      = '0;
  logic  [DATA_WIDTH-1:0]    rd_addr_i   = '0;
  logic  [DATA_WIDTH-1:0]    rd_data_o   = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                        pass;
  int                        fail;
  logic [DATA_WIDTH-1:0]     expected;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  alu_gate #(
  ) u_alu_gate(
    .rs1_data_i,
    .rs2_data_i,
    .func_i,
    .rd_data_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //generate random transactions
  task static start_rand_dvr();
   fork
     forever begin
      rs1_data_i  <= $urandom;
      rs2_data_i  <= $urandom;
      randcase
       5: func_i <= AND;
       5: func_i <= OR;
       5: func_i <= XOR;
       5: func_i <= NOT;
       1: func_i <= INVALID;
      endcase // Randomly choose between 0 (AND), 1 (OR), 2 (XOR), 3 (NOT)
     end
   join_none
  endtask

  // monitor and check
  task static start_checking();
    fork
      forever begin
        // Reference model logic to generate expected results
        case (func_i)
          AND:      expected = rs1_data_i & rs2_data_i;
          OR:       expected = rs1_data_i | rs2_data_i;
          XOR:      expected = rs1_data_i ^ rs2_data_i;
          NOT:      expected = ~rs1_data_i;
          default:  expected = 32'b0;
        endcase
        if (rd_data_o == expected) begin
          pass++;
          $write("\033[1;32m");
        end else begin
          fail++;
          $write("\033[1;31m");
        end
        $display("rs1_data_i: %h, rs2_data_i: %h, func_i: %b, rd_data_o: %h, expected: %h [%0t]",
        rs1_data_i, rs2_data_i, func_i, rd_data_o, expected, $realtime);
      end
    join_none
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    // Data Flow Checking
    start_rand_dvr();
    start_checking();

  end
  $display("Testbench completed with %0d passes and %0d fails", pass, fail);
  $finish;

endmodule
