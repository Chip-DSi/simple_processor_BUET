/*
Description
File Opened and Placed by : MD. Toky Tazwar (toky.tech01t@gmail.com)
Final Author: Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/
`include "simple_processor_pkg.sv"

module ins_dec_tb;

  //`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros

  `include "vip/tb_ess.sv"

  import simple_processor_pkg::*;

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)

  logic  [ DATA_WIDTH-1:0] imem_rdata_i;  //instruction data coming from IMEM
  logic                    imem_ack_i;  //IMEM ack to select between imem_rdata_i or 0
  logic  [ ADDR_WIDTH-1:0] imem_addr_i;
  func_t                   func_o;  //op codes are stored in this typedef
  logic                    we_o;  //write enable pin for RF
  logic  [            2:0] rd_addr_o;  //destination register address
  logic  [            2:0] rs1_addr_o;  //RS1 register address
  logic  [            2:0] rs2_addr_o;  //RS2 register address
  logic  [            5:0] imm_o;  //unextended immediate
  logic                    valid_pc_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic  [INSTR_WIDTH-1:0] instruction;
  int                      pass;
  int                      fail;
  logic                    valid_pc_o_temp;
  logic                    we_o_temp;
  func_t                   func_o_temp;
  logic  [            2:0] rd_addr_o_temp;  //destination register address
  logic  [            2:0] rs1_addr_o_temp;  //RS1 register address
  logic  [            2:0] rs2_addr_o_temp;  //RS2 register address
  logic  [            5:0] imm_o_temp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  ins_dec dut (
      //.clk_i,
      .imem_rdata_i,  //instruction data coming from IMEM
      .imem_ack_i,  //IMEM ack to select between imem_rdata_i or 0
      .imem_addr_i,
      .func_o,  //op codes are stored in this typedef
      .we_o,  //write enable pin for RF
      .rd_addr_o,  //destination register address
      .rs1_addr_o,  //RS1 register address
      .rs2_addr_o,  //RS2 register address
      .imm_o,  //unextended immediate
      .valid_pc_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign instruction     = imem_addr_i[1] ? imem_rdata_i[31:16] : imem_rdata_i[15:0];
  assign imem_ack_i      = 1'b1;
  assign func_o_temp     = func_t'(instruction[3:0]);
  assign rs1_addr_o_temp = instruction[12:10];
  assign imm_o_temp      = instruction[9:4];
  assign rs2_addr_o_temp = instruction[9:7];
  assign rd_addr_o_temp  = instruction[15:13];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Randomly drive the address and data
  task static start_rand_dvr();
    fork
      forever begin
        imem_addr_i  <= $urandom;
        imem_rdata_i <= $urandom;
        @(posedge clk_i);
      end
    join_none
  endtask

  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        case (func_o_temp)
          ADDI, ADD, SUB:       valid_pc_o_temp = 1'b1;
          AND, OR, XOR, NOT:    valid_pc_o_temp = 1'b1;
          LOAD, STORE:          valid_pc_o_temp = 1'b1;
          SLL, SLR, SLLI, SLRI: valid_pc_o_temp = 1'b1;
          default:              valid_pc_o_temp = 1'b0;
        endcase

        case (func_o_temp)
          ADDI, ADD, SUB:       we_o_temp = 1'b1;
          AND, OR, XOR, NOT:    we_o_temp = 1'b1;
          LOAD:                 we_o_temp = 1'b1;
          STORE:                we_o_temp = 1'b0;
          SLL, SLR, SLLI, SLRI: we_o_temp = 1'b1;
          default:              we_o_temp = 1'b0;
        endcase

        if (func_o === func_o_temp) pass++;
        else begin
          fail++;
          $display("FUNC ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, func_o,
                   func_o_temp, $realtime);
        end
        if (valid_pc_o === valid_pc_o_temp) pass++;
        else begin
          fail++;
          $display("VALID PC ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, valid_pc_o,
                   valid_pc_o_temp, $realtime);
        end
        if (we_o === we_o_temp) pass++;
        else begin
          fail++;
          $display("WE ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, we_o, we_o_temp,
                   $realtime);
        end
        if (rd_addr_o === rd_addr_o_temp) pass++;
        else begin
          fail++;
          $display("RD ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, rd_addr_o,
                   rd_addr_o_temp, $realtime);
        end
        if (rs1_addr_o === rs1_addr_o_temp) pass++;
        else begin
          fail++;
          $display("RS1 ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, rs1_addr_o,
                   rs1_addr_o_temp, $realtime);
        end
        if (rs2_addr_o === rs2_addr_o_temp) pass++;
        else begin
          fail++;
          $display("RS2 ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, rs2_addr_o,
                   rs2_addr_o_temp, $realtime);
        end
        if (imm_o === imm_o_temp) pass++;
        else begin
          fail++;
          $display("IMM ADDR:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", imem_addr_i, imm_o,
                   imm_o_temp, $realtime);
        end
      end
    join_none
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    start_clk_i();

    @(posedge clk_i);
    start_rand_dvr();
    start_checking();

    repeat (1000) @(posedge clk_i);
    result_print(!fail, $sformatf("Data flow %0d/%0d", pass, pass + fail));

    $finish;

  end

endmodule
