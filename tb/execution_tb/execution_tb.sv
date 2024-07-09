/*
Description
Author : nusratanila (nusratanila94@gmail.com)
*/

module execution_tb;
`define ENABLE_DUMPFILE
 // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"
   import simple_processor_pkg::*;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic clk_i;
  logic arst_ni;
  logic [DATA_WIDTH-1:0] rs1_data_i;
  logic [DATA_WIDTH-1:0] rs2_data_i;
  logic [5:0] imm;
  func_t func_i;
  logic [DATA_WIDTH-1:0] res_math;
  logic [DATA_WIDTH-1:0] rd_data_o;
  logic [DATA_WIDTH-1:0] res_shift;
  logic [DATA_WIDTH-1:0] result;
  // Instantiate the DUT (Device Under Test)
  merge_execution dut (
    .rs1_data_i(rs1_data_i),
    .func_i(func_i),
    .imm(imm),
    .rs2_data_i(rs2_data_i),
    .res_math(res_math),
    .rd_data_o(rd_data_o),
    .res_shift(res_shift),
    .result(result)
  );
 // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)
  logic arst_ni = 1;
  task static apply_reset();
    begin
      arst_ni = 1;
      #100ns;
      arst_ni = 0;
      #100ns;
      arst_ni = 1;
      #100ns;
    end
  endtask
  initial begin
    apply_reset();
    start_clk_i();
  // Initialize inputs
    rs1_data_i = 0;
    rs2_data_i = 0;
    imm = 0;
    func_i = AND;
   // Monitor signals
    $monitor("Time=%0t, rs1_data_i=%h, rs2_data_i=%h, imm=%h, func_i=%h, res_math=%h, rd_data_o=%h, res_shift=%h, result=%h",
              $time, rs1_data_i, rs2_data_i, imm, func_i, res_math, rd_data_o, res_shift, result);

    // Apply test vectors
    // Test AND operation
    #10 rs1_data_i = 32'hA5A5A5A5; rs2_data_i = 32'h5A5A5A5A; func_i = AND;
    #10 if (rd_data_o !== 32'h00000000) $display("AND test failed!");
    // Test OR operation
    #10 func_i = OR;
    #10 if (rd_data_o !== 32'hFFFFFFFF) $display("OR test failed!");
    // Test XOR operation
    #10 func_i = XOR;
    #10 if (rd_data_o !== 32'hFFFFFFFF) $display("XOR test failed!");
    // Test NOT operation
    #10 func_i = NOT;
    #10 if (rd_data_o !== 32'h5A5A5A5A) $display("NOT test failed!");
    // Test ADDI operation
    #10 rs1_data_i = 32'h00000001; imm = 6'b000011; func_i = ADDI;
    #10 if (res_math !== 32'h00000004) $display("ADDI test failed!");
    // Test ADD operation
    #10 rs2_data_i = 32'h00000001; func_i = ADD;
    #10 if (res_math !== 32'h00000002) $display("ADD test failed!");
    // Test SUB operation
    #10 func_i = SUB;
    #10 if (res_math !== 32'h00000000) $display("SUB test failed!");
    // Test SLL operation
    #10 rs1_data_i = 32'h00000001; rs2_data_i = 32'h00000002; func_i = SLL;
    #10 if (res_shift !== 32'h00000004) $display("SLL test failed!");
    // Test SLLI operation
    #10 imm = 6'b000010; func_i = SLLI;
    #10 if (res_shift !== 32'h00000004) $display("SLLI test failed!");
    // Test SLR operation
    #10 rs1_data_i = 32'h00000004; rs2_data_i = 32'h00000002; func_i = SLR;
    @(posedge clk_i);
    if (res_shift !== (32'h00000004 >> 32'h00000002)) result_print(0, "SLR test failed!");
    // Test SLRI operation
    #10 imm = 6'b000010; func_i = SLRI;
    @(posedge clk_i);
    if (res_shift !== (32'h00000004 >> {{26{imm[5]}}, imm})) result_print(0, "SLRI test failed!");
   // Finish simulation
    #10 $finish;
  end

endmodule
