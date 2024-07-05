/*
Description
Author : MD. Toky Tazwar (toky.tech01t@gmail.com)
*/
`include "simple_processor_pkg.sv"

module ins_dec_tb;

  //`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
 
`include "vip/tb_ess.sv"

  import simple_processor_pkg::ADDR_WIDTH;
  import simple_processor_pkg::DATA_WIDTH;

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)

  logic arst_ni = 1;

  logic [INSTR_WIDTH-1:0] imem_rdata_i; //instruction data coming from IMEM
  logic                   imem_ack_i;   //IMEM ack to select between imem_rdata_i or 0
  logic [INSTR_WIDTH-1:0] imem_addr_i;
  func_t                  func_o;       //op codes are stored in this typedef
  logic                   we_o;         //write enable pin for RF
  logic [2:0]             rd_addr_o;    //destination register address
  logic [2:0]             rs1_addr_o;   //RS1 register address
  logic [2:0]             rs2_addr_o;   //RS2 register address
  logic [5:0]             imm_o;        //unextended immediate
  logic                   valid_pc;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  int [INSTR_WIDTH-1:0]  instruction;
  int                    is_valid;
  int                    pass;
  int                    fail;
  logic                  valid_pc_middle;
  logic                  w_middle;
  func_t                 func_middle;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  ins_dec_tb dut(
    .clk_i,
    .imem_rdata_i, //instruction data coming from IMEM
    .imem_ack_i,   //IMEM ack to select between imem_rdata_i or 0
    .imem_addr_i,
    .func_o,       //op codes are stored in this typedef
    .we_o,         //write enable pin for RF
    .rd_addr_o,    //destination register address
    .rs1_addr_o,   //RS1 register address
    .rs2_addr_o,   //RS2 register address
    .imm_o,        //unextended immediate
    .valid_pc
  )
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

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

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task static start_rand_dvr();
  fork
    forever begin
      imem_addr_i   <= $urandom;
      imem_addr_i   <= $urandom;
      @(posedge clk_i);
    end
  join_none
  endtask
  assign instruction       = imem_addr_i[1] ? imem_rdata_i[31:16] : imem_rdata_i[15:0];
  assign imem_ack_i        = 1'b1;
  assign func_middle       = func_t'(instruction[3:0]); 
  assign rs1_addr_o1       = instruction[12:10];
  assign imm_o1            = instruction[9:4];
  assign rs2_addr_o1       = instruction[9:7];
  assign rd_addr_o1        = instruction[15:13];
       
  case(func_o)
        ADDI, ADD, SUB        : valid_pc_middle = 1'b1; 
        AND, OR, XOR, NOT     : valid_pc_middle = 1'b1;
        LOAD, STORE           : valid_pc_middle = 1'b1;
        SLL, SLR, SLLI, SLRI  : valid_pc_middle = 1'b1;
        default               : valid_pc_middle = 1'b0;
  endcase

  case(func_o)
        ADDI, ADD, SUB        : w_middle = 1'b1; 
        AND, OR, XOR, NOT     : w_middle = 1'b1;
        LOAD                  : w_middle = 1'b1;
        SLL, SLR, SLLI, SLRI  : w_middle = 1'b1;
        default               : w_middle = 1'b0;
  endcase

task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        if (func_o === func_middle) pass++;
        else begin
          fail++;
        end
        if (valid_pc === valid_pc_middle) pass++;
        else begin
          fail++;
        end
        if (we_o === w_middle) ref_mem[w_addr_i[ADDR_WIDTH-1:2]] = w_data_i;
      end
    join_none
  endtask


  initial begin  // main initial

    apply_reset();
    start_clk_i();
    start_rand_dvr();
    start_checking();


    /*@(posedge clk_i);
    result_print(1, "This is a PASS");
    @(posedge clk_i);
    result_print(0, "And this is a FAIL");*/

    $finish;

  end

endmodule
