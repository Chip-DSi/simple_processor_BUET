/*
Author : Foez Ahmed (foez.official@gmail.com)
*/

`include "simple_processor_pkg.sv"

module r2_w1_32b_memory_model_tb;

  //`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"

  import simple_processor_pkg::ADDR_WIDTH;
  import simple_processor_pkg::DATA_WIDTH;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)

  logic                  we_i = '0;
  logic [ADDR_WIDTH-1:0] w_addr_i = '0;
  logic [DATA_WIDTH-1:0] w_data_i = '0;

  logic [ADDR_WIDTH-1:0] r0_addr_i = '0;
  logic [DATA_WIDTH-1:0] r0_data_o;

  logic [ADDR_WIDTH-1:0] r1_addr_i = '0;
  logic [DATA_WIDTH-1:0] r1_data_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                    pass;
  int                    fail;

  logic [DATA_WIDTH-1:0] ref_mem        [logic [ADDR_WIDTH-1:0]];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  r2_w1_32b_memory_model mem (
      .clk_i,
      .we_i,
      .w_addr_i,
      .w_data_i,
      .r0_addr_i,
      .r0_data_o,
      .r1_addr_i,
      .r1_data_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generate random transactions
  task static start_rand_dvr();
    fork
      forever begin
        we_i      <= $urandom;
        w_data_i  <= $urandom;
        w_addr_i  <= $urandom & 'hf;
        r0_addr_i <= $urandom & 'hf;
        r1_addr_i <= $urandom & 'hf;
        @(posedge clk_i);
      end
    join_none
  endtask

  // monitor and check
  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        if (r0_data_o === ref_mem[r0_addr_i[ADDR_WIDTH-1:2]]) pass++;
        else begin
          fail++;
          $display("ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", r0_addr_i, r0_data_o,
                   ref_mem[r0_addr_i[ADDR_WIDTH-1:2]], $realtime);
        end
        if (r1_data_o === ref_mem[r1_addr_i[ADDR_WIDTH-1:2]]) pass++;
        else begin
          fail++;
          $display("ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", r1_addr_i, r0_data_o,
                   ref_mem[r1_addr_i[ADDR_WIDTH-1:2]], $realtime);
        end
        if (we_i) ref_mem[w_addr_i[ADDR_WIDTH-1:2]] = w_data_i;
      end
    join_none
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    automatic bit OK;

    start_clk_i();

    // WRITE READ CHECK
    OK = 1;
    for (int i = 0; i < 256; i++) begin
      mem.write(i + 'h400, i);
    end
    for (int i = 0; i < 256; i++) begin
      if (mem.read(i + 'h400) != i) OK = 0;
    end
    result_print(OK, "backdoor write");
    result_print(OK, "backdoor read");

    // LOAD CHECK
    OK = 1;
    mem.load("sample.hex");
    for (int i = 0; i < 256; i++) begin
      if (mem.read(i + 'h200) != i) OK = 0;
    end
    result_print(OK, "backdoor load");

    // LOAD CLEAR
    OK = 1;
    mem.clear();
    for (int i = 0; i < 256; i++) begin
      if (mem.read(i + 'h200) !== 'x) OK = 0;
    end
    result_print(OK, "backdoor clear");

    // Data flow checking
    start_rand_dvr();
    start_checking();
    repeat (5000) @(posedge clk_i);
    result_print(!fail, $sformatf("frontdoor data flow %0d/%0d", pass, pass + fail));

    $finish;

  end

endmodule
