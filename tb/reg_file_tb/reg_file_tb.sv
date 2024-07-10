/*
Base File Author : Foez Ahmed (foez.official@gmail.com)
Added by: Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

module reg_file_tb;

  `define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int NumRs = 2;
  localparam bit ZeroReg = 1;
  localparam int NumReg = 8;
  localparam int RegWidth = 32;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 5ns, 5ns)

  logic                       arst_ni = '1;
  logic [$clog2(NumReg)-1:0]  rd_addr_i = '0;
  logic [      RegWidth-1:0]  rd_data_i = '0;
  logic                       we_i = '0;
  logic [$clog2(NumReg)-1:0]  rs1_addr_i = '0;
  logic [$clog2(NumReg)-1:0]  rs2_addr_i = '0;
  logic [      RegWidth-1:0]  rs1_data_o;
  logic [      RegWidth-1:0]  rs2_data_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                                            pass;
  int                                            fail;

  logic [      RegWidth-1:0]                     ref_mem        [NumReg];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  reg_file #(
      //.NUM_RS   (NumRs   ),
      .ZERO_REG (ZeroReg ),
      .NUM_REG  (NumReg  ),
      .REG_WIDTH(RegWidth)
  ) u_reg_file (
      .clk_i,
      .arst_ni,
      .rd_addr_i,
      .rd_data_i,
      .we_i,
      .rs1_addr_i,
      .rs1_data_o,
      .rs2_addr_i,
      .rs2_data_o
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

  // generate random transactions
  task static start_rand_dvr();
    fork
      forever begin
        we_i   <= $urandom;
        rd_data_i <= $urandom;
        rd_addr_i <= $urandom & 'b111;
        rd_addr_i  <= $urandom & 'b111;
        rs1_addr_i <= $urandom & 'b111;
        rs2_addr_i <= $urandom & 'b111;
        @(posedge clk_i);
      end
    join_none
  endtask

  // monitor and check
  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        if (rs1_data_o == ref_mem[rs1_addr_i]) begin
          pass++;
          //$write("\033[1;32m");
        end else begin
          fail++;
          //$write("\033[1;31m");
        end
      //  $display("PORT1 REG%0d GOT_DATA:0x%h EXP_DATA:0x%h [%0t]\033[0m", rs1_addr_i,
                 //rs1_data_o, ref_mem[rs1_addr_i], $realtime);
        if (rs2_data_o == ref_mem[rs2_addr_i]) begin
          pass++;
         // $write("\033[1;32m");
        end else begin
          fail++;
         // $write("\033[1;31m");
        end
       // $display("PORT2 REG%0d GOT_DATA:0x%h EXP_DATA:0x%h [%0t]\033[0m", rs2_addr_i,
                 //rs2_data_o, ref_mem[rs2_addr_i], $realtime);
        if (we_i && (rd_addr_i != '0)) begin
          ref_mem[rd_addr_i] = rd_data_i;
          //$display("\033[1;36mWRITE REG%0d DATA:0x%h [%0t]\033[0m", rd_addr_i, rd_data_i,
                  // $realtime);
        end
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

    // Data flow checking
    start_rand_dvr();
    start_checking();
    repeat (1000) @(posedge clk_i);
    result_print(!fail, $sformatf("frontdoor data flow %0d/%0d", pass, pass + fail));

    $finish;

  end

endmodule
