/*
Description
Author : nusratanila (nusratanila94@gmail.com)
Editor : Ramisa Tahsin (ramisashreya@gmail.com)
*/

`include "simple_processor_pkg.sv"

module merge_execution_tb #(
  parameter int MEM_ADDR_WIDTH = simple_processor_pkg::ADDR_WIDTH,
  parameter int MEM_DATA_WIDTH = simple_processor_pkg::DATA_WIDTH
);

  //`define ENABLE_DUMPFILE

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-IMPORTS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   //bring in test bench essentials from package

   `include "vip/tb_ess.sv"

   import simple_processor_pkg::*;

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-SIGNALS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   `CREATE_CLK(clk_i, 4ns, 6ns)

   logic arst_ni = 1;

   logic  [DATA_WIDTH-1:0]        rs1_data_i;     //source register 1 data input from RF
   logic  [DATA_WIDTH-1:0]        rs2_data_i;     //source register 2 data
   logic  [5:0]                   imm_i;          //immediate value
   func_t                         func_i;         //opcode

   logic  [MEM_DATA_WIDTH-1:0]    dmem_rdata_i;   // DMEM data of the requested address
   logic                          dmem_ack_i;     // Acknowledge if data request is completed
   logic                          dmem_req_o;     // DMEM is active, always HIGH
   logic  [MEM_ADDR_WIDTH-1:0]    dmem_addr_o;    // Data to be read/written to this address
   logic                          dmem_we_o;      // Active for STORE operation
   logic  [MEM_DATA_WIDTH-1:0]    dmem_wdata_o;   // DATA to be stored in DMEM

   logic  [DATA_WIDTH-1:0]        rd_data_o;      // output of the execution unit


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                              pass;
  int                              fail;

  logic       [DATA_WIDTH-1:0]     rs2_data_i_2c;      //intermediate value for 2's complement
  logic       [DATA_WIDTH-1:0]     imm_i_extended;     //Sign extension for imm_i

  logic       [DATA_WIDTH-1:0]     rd_data_o_temp;
  logic                            dmem_we_o_temp;
  logic       [MEM_ADDR_WIDTH-1:0] dmem_addr_o_temp;
  logic       [MEM_DATA_WIDTH-1:0] dmem_wdata_o_temp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  merge_execution #(
     .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
     .MEM_DATA_WIDTH(MEM_DATA_WIDTH)
  ) dut (
    .rs1_data_i,
    .func_i,
    .imm_i,
    .rs2_data_i,
    .dmem_rdata_i,
    .dmem_ack_i,
    .dmem_req_o,
    .dmem_addr_o,
    .dmem_we_o,
    .dmem_wdata_o,
    .rd_data_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //2's complement for the sub operation
  assign rs2_data_i_2c = ~rs2_data_i + 1;

  //Sign extention for the imm_iediate
  assign imm_i_extended = {{26{imm_i[5]}}, imm_i};

  //Memory address and data assignments
  //assign dmem_addr_o  = rs1_data_i;            // RS1 has address which is load

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

  //Randomly drive the address and data
  task static start_rand_dvr();
    fork
      forever begin
        rs1_data_i <= $urandom;
        rs2_data_i <= $urandom;
        imm_i      <= $urandom;  // 6-bit random imm_iediate value
        randcase
          1: func_i <= AND;
          1: func_i <= OR;
          1: func_i <= XOR;
          1: func_i <= NOT;
          1: func_i <= ADDI;
          1: func_i <= ADD;
          1: func_i <= SUB;
          1: func_i <= SLL;
          1: func_i <= SLLI;
          1: func_i <= SLR;
          1: func_i <= SLRI;
          1: func_i <= LOAD;
          1: func_i <= STORE;
          //default: func_i <= INVALID;
        endcase

        @(posedge clk_i);
     end
    join_none
  endtask

//   monitor and check
  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        case(func_i)
          ADDI    : rd_data_o_temp = rs1_data_i + imm_i_extended;
          ADD     : rd_data_o_temp = rs1_data_i + rs2_data_i;
          SUB     : rd_data_o_temp = rs1_data_i + rs2_data_i_2c;
          AND     : rd_data_o_temp = rs1_data_i & rs2_data_i;
          OR      : rd_data_o_temp = rs1_data_i | rs2_data_i;
          XOR     : rd_data_o_temp = rs1_data_i ^ rs2_data_i;
          NOT     : rd_data_o_temp = ~rs1_data_i;
          SLL     : rd_data_o_temp = rs1_data_i << rs2_data_i;
          SLLI    : rd_data_o_temp = rs1_data_i << imm_i_extended;
          SLR     : rd_data_o_temp = rs1_data_i >> rs2_data_i;
          SLRI    : rd_data_o_temp = rs1_data_i >> imm_i_extended;
          LOAD    : begin
                      dmem_we_o_temp = '0;
                      rd_data_o_temp = dmem_rdata_i; ///confusion about rdata_i and storing in dmem
                    end
          STORE   : begin
                      dmem_we_o_temp = '1;
                      dmem_wdata_o_temp = rs2_data_i;
                      rd_data_o_temp = 'x;  // Not really used, but kept for consistency
                    end
          default:  rd_data_o_temp = 32'b0; //every other input selection for different block will be done here
         endcase

        if(rd_data_o === rd_data_o_temp) pass++;
        else begin
               fail++;
               $display("FUNC:%0d RS1:0x%h IMM:0x%h RS2:0x%h GOT:0x%h EXPECTED:0x%h [%0t]",
               func_i, rs1_data_i, imm_i, rs2_data_i, rd_data_o, rd_data_o_temp, $realtime);
            end
        if(dmem_we_o === dmem_we_o_temp) pass++;
        else begin
               fail++;
               $display("FUNC:%0d DMEM_WE GOT:0x%h DMEM_WE EXPECTED:0x%h [%0t]",
               func_i, dmem_we_o, dmem_we_o_temp, $realtime);
             end
        if(dmem_wdata_o === dmem_wdata_o_temp) pass++;
        else begin
               fail++;
               $display("FUNC:%0d DMEM_WE GOT:0x%h DMEM_WE EXPECTED:0x%h [%0t]",
               func_i, dmem_wdata_o, dmem_wdata_o_temp, $realtime);
             end
      end
    join_none
  endtask

 //////////////////////////////////////////////////////////////////////////////////////////////////
 //-SEQUENTIALS
 //////////////////////////////////////////////////////////////////////////////////////////////////


   initial begin  // main initial

    apply_reset();
    start_clk_i();
    @(posedge clk_i);
    start_rand_dvr();
    start_checking();

    //@(posedge clk_i);
    //rd_data_o_print(1, "This is a PASS");
    repeat(6000)@(posedge clk_i);
    result_print(!fail, $sformatf("Data flow %0d/%0d", pass, pass + fail));
  $finish;
  end
endmodule
