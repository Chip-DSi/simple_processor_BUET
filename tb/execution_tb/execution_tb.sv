/*
Description
Author : nusratanila (nusratanila94@gmail.com)
*/

`include "simple_processor_pkg.sv"

module execution_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  `include "vip/tb_ess.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam DATA_WIDTH = 32;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0] rs1_data_i;
  logic [DATA_WIDTH-1:0] rs2_data_i;
  logic [5:0] imm;
  func_t func_i;
  logic [DATA_WIDTH-1:0] res_math;
  logic [DATA_WIDTH-1:0] rd_data_o;
  logic [DATA_WIDTH-1:0] res_shift;
  logic [DATA_WIDTH-1:0] result;
  logic clk_i;
  logic arst_ni = 1;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task static result_print(int result, string msg);
    if (result == 1)
      $display("PASS: %s", msg);
    else
      $display("FAIL: %s", msg);
  endtask

  task static apply_reset();
    #100ns;
    arst_ni <= 0;
    #100ns;
    arst_ni <= 1;
    #100ns;
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    apply_reset();
    start_clk_i();

    // Test AND operation
    #10 rs1_data_i = 32'hA5A5A5A5;
        rs2_data_i = 32'h5A5A5A5A;
        func_i = AND;
    @(posedge clk_i);
    if (rd_data_o === (32'hA5A5A5A5 & 32'h5A5A5A5A))
      result_print(1, "AND test passed!");
    else
      result_print(0, "AND test failed!");

    // Test OR operation
    #10 func_i = OR;
    @(posedge clk_i);
    if (rd_data_o === (32'hA5A5A5A5 | 32'h5A5A5A5A))
      result_print(1, "OR test passed!");
    else
      result_print(0, "OR test failed!");

    // Test XOR operation
    #10 func_i = XOR;
    @(posedge clk_i);
    if (rd_data_o === (32'hA5A5A5A5 ^ 32'h5A5A5A5A))
      result_print(1, "XOR test passed!");
    else
      result_print(0, "XOR test failed!");

    // Test NOT operation
    #10 func_i = NOT;
    @(posedge clk_i);
    if (rd_data_o === ~32'hA5A5A5A5)
      result_print(1, "NOT test passed!");
    else
      result_print(0, "NOT test failed!");

    // Test ADDI operation
    #10 rs1_data_i = 32'h00000001;
        imm = 6'b000011;
        func_i = ADDI;
    @(posedge clk_i);
    if (res_math === (32'h00000001 + {{26{imm[5]}}, imm}))
      result_print(1, "ADDI test passed!");
    else
      result_print(0, "ADDI test failed!");

    // Test ADD operation
    #10 rs2_data_i = 32'h00000001;
        func_i = ADD;
    @(posedge clk_i);
    if (res_math === (32'h00000001 + 32'h00000001))
      result_print(1, "ADD test passed!");
    else
      result_print(0, "ADD test failed!");

    // Test SUB operation
    #10 func_i = SUB;
    @(posedge clk_i);
    if (res_math === (32'h00000001 - 32'h00000001))
      result_print(1, "SUB test passed!");
    else
      result_print(0, "SUB test failed!");

    // Test SLL operation
    #10 rs1_data_i = 32'h00000001;
        rs2_data_i = 32'h00000002;
        func_i = SLL;
    @(posedge clk_i);
    if (res_shift === (32'h00000001 << 32'h00000002))
      result_print(1, "SLL test passed!");
    else
      result_print(0, "SLL test failed!");

    // Test SLLI operation
    #10 imm = 6'b000010;
        func_i = SLLI;
    @(posedge clk_i);
    if (res_shift === (32'h00000001 << {{26{imm[5]}}, imm}))
      result_print(1, "SLLI test passed!");
    else
      result_print(0, "SLLI test failed!");

    // Test SLR operation
    #10 rs1_data_i = 32'h00000004;
        rs2_data_i = 32'h00000002;
        func_i = SLR;
    @(posedge clk_i);
    if (res_shift === (32'h00000004 >> 32'h00000002))
      result_print(1, "SLR test passed!");
    else
      result_print(0, "SLR test failed!");

    // Test SLRI operation
    #10 imm = 6'b000010;
        func_i = SLRI;
    @(posedge clk_i);
    if (res_shift === (32'h00000004 >> {{26{imm[5]}}, imm}))
      result_print(1, "SLRI test passed!");
    else
      result_print(0, "SLRI test failed!");

    // Finish simulation
    #10 $display("All tests completed.");
    $finish;
  end

endmodule

