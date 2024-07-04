/*
Description: ALU Gate TestBench
Author : Ramisa Tahsin Shreya (ramisashreya@gmail.com)
*/
`include "simple_processor_pkg.sv"

module Alu_Gate_tb;

  `define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"
  import simple_processor_pkg::*;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int DATA_WIDTH    = 32;
  localparam int INT_REG_WIDTH = 32;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 5ns, 5ns)

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

  logic  [INT_REG_WIDTH-1:0] ref_mem   [DATA_WIDTH];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  AluGate #(
  ) u_AluGate(
    .rs1_data_i,
    .rs2_data_i,
    .func_i,
    .rd_data_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task static apply_reset();
    #100ns;
    arst_ni <= 0;
    foreach (ref_mem[i]) ref_mem[i] <= '0;
    #100ns;
    arst_ni <= 1;
    #100ns;
  endtask

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
      @(posedge clk_i);
     end
   join_none
  endtask

  // monitor and check
  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        // Reference model logic to generate expected results
        case (func_i)
          AND: ref_mem[rd_addr_i] = rs1_data_i & rs2_data_i;
          OR:  ref_mem[rd_addr_i] = rs1_data_i | rs2_data_i;
          XOR: ref_mem[rd_addr_i] = rs1_data_i ^ rs2_data_i;
          NOT: ref_mem[rd_addr_i] = ~rs1_data_i;
        endcase
        if (rd_data_o == ref_mem[rd_addr_i]) begin
          pass++;
          $write("\033[1;32m");
        end else begin
          fail++;
          $write("\033[1;31m");
        end
        $display("rs1_data_i: %h, rs2_data_i: %h, func_i: %b, rd_data_o: %h, ref_mem: %h [%0t]", 
        rs1_data_i, rs2_data_i, func_i, rd_data_o, ref_mem, $realtime);
      end
    join_none
  endtask
    
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    apply_reset();
    start_clk_i();

    @(posedge clk_i);
    // Data Flow Checking
    start_rand_dvr();
    start_checking();
    repeat (1000) @(posedge clk_i);  // Let the test run for a certain number of cycles
    result_print(1, $sformatf("This is a PASS. pass=%0d, fail=%0d", pass, fail));
    result_print(0, $sformatf("This is a FAIL. pass=%0d, fail=%0d", pass, fail));

    $finish;

  end

endmodule