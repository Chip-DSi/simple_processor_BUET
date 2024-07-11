/*
Description
Author : nusratanila (nusratanila94@gmail.com)
Editor : Ramisa Tahsin (ramisashreya@gmail.com)
*/


module merge_execution_tb;

`include "simple_processor_pkg.sv"


   //`define ENABLE_DUMPFILE

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-IMPORTS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   `include "vip/tb_ess.sv"

   import simple_processor_pkg::*;

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-SIGNALS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   `CREATE_CLK(clk_i, 4ns, 6ns)

   logic arst_ni = 1;

   logic [DATAWIDTH-1:0] rs1_data_i;
   logic [DATAWIDTH-1:0] rs2_data_i;
   logic [5:0]           imm_i;
   func_t                func_i;
   logic [DATAWIDTH-1:0] result;


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                     pass;
  int                     fail;

  logic  [DATAWIDTH-1:0]  res_math;
  logic  [DATAWIDTH-1:0]  res_gate;
  logic  [DATAWIDTH-1:0]  res_shift;
  //logic [DATAWIDTH-1:0] res_mem;

  logic  [DATA_WIDTH-1:0] res_math_exp;
  logic  [DATA_WIDTH-1:0] res_gate_exp;
  logic  [DATA_WIDTH-1:0] res_shift_exp;
  //logic [DATAWIDTH-1:0] res_mem_exp;

  logic  [DATAWIDTH-1:0]  result_exp;

  logic  [DATA_WIDTH-1:0] temp_math;
  logic  [DATA_WIDTH-1:0] temp_shift;

  logic                   s_r;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  eu_merge dut (
    .rs1_data_i,
    .func_i,
    .imm_i,
    .rs2_data_i,
    .result
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign imm_i_ext = {{26{imm_i[5]}}, imm_i};

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //Randomly drive the address and data 
  task static start_rand_dvr();
    fork
      forever begin
        rs1_data_i <= $urandom;
        rs2_data_i <= $urandom;
        imm_i <= $urandom;  // 6-bit random imm_iediate value
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
          ADDI    : begin
                     temp_math = imm_i_ext;
                     res_math_exp = rs1_data_i + res_math_exp;
                       if(res_math === res_math_exp) pass++;
                       else begin
                            fail++;
                            $display("ADDI RS1:0x%h IMM:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                                      res_math_exp, res_math, res_math_exp, $realtime);
                       end
                    end
          ADD     : begin
                     temp_math = rs2_data_i;
                     res_math_exp = rs1_data_i + temp_math;
                       if(res_math === res_math_exp) pass++;
                       else begin
                          fail++;
                          $display("ADD RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                                      rs2_data_i, res_math, res_math_exp, $realtime);
                       end
                    end
          SUB     : begin
                     temp_math = ~rs2_data_i + 1;
                     res_math_exp = rs1_data_i + temp_math;
                     if(res_math === res_math_exp) pass++;
                     else begin
                          fail++;
                          $display("SUB RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                                      rs2_data_i, res_math, res_math_exp, $realtime);
                     end
                    end
          AND     : begin
                     res_gate_exp = rs1_data_i & rs2_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                          $display("AND RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                                      rs2_data_i, res_gate, res_gate_exp, $realtime);
                     end
                    end
          OR      : begin
                     res_gate_exp = rs1_data_i | rs2_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                          $display("OR RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                          rs2_data_i, res_gate, res_gate_exp, $realtime);
                     end
                    end
          XOR     : begin
                     res_gate_exp = rs1_data_i ^ rs2_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                          $display("XOR RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                          rs2_data_i, res_gate, res_gate_exp, $realtime);
                     end
                    end
          NOT     : begin
                     res_gate_exp = ~rs1_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                          $display("NOT RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                          rs2_data_i, res_gate, res_gate_exp, $realtime);
                     end
                    end
          SLLI    : begin
                      temp_shift = imm_i_ext;
                      res_shift_exp = rs1_data_i << temp_shift;
                      s_r = '0;
                      if (res_shift === res_shift_exp) pass++;
                       else begin
                            fail++;
                            $display("SLLI RS1:0x%h IMM:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                            imm_i, res_shift, res_shift_exp, $realtime);
                      end
                    end
          SLRI    : begin
                      temp_shift = imm_i_ext;
                      res_shift_exp = rs1_data_i >> res_gate_exp;
                      s_r = '1;
                      if (res_shift === res_shift_exp) pass++;
                       else begin
                            fail++;
                            $display("SLRI RS1:0x%h IMM:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                            imm_i, res_shift, res_shift_exp, $realtime);
                      end
                    end
          SLL     : begin
                      temp_shift = rs2_data_i;
                      res_shift_exp = rs1_data_i << res_gate_exp;
                      s_r = '0 ;
                      if (res_shift === res_shift_exp) pass++;
                       else begin
                            fail++;
                            $display("SLL RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                            rs2_data_i, res_shift, res_shift_exp, $realtime);
                      end
                    end
          SLR     : begin
                      res_shift_exp = rs2_data_i;
                      s_r = '1;
                      if (res_shift === (rs1_data_i >> res_gate_exp)) pass++;
                       else begin
                            fail++;
                            $display("SLR RS1:0x%h RS2:0x%h GOT_DATA:0x%h EXP_DATA:0x%h [%0t]", rs1_data_i, 
                            rs2_data_i, res_shift, res_shift_exp, $realtime);
                      end
                    end
          default  :  res_math_exp=32'b0 & res_gate_exp = 32'b0 & res_shift_exp = 32'b0;
//default for math,gate, shift different???
//every other input selection for different block will be done here
         endcase

      end
    join_none
  endtask

 //////////////////////////////////////////////////////////////////////////////////////////////////
 //-SEQUENTIALS
 //////////////////////////////////////////////////////////////////////////////////////////////////


   initial begin  // main initial

    //apply_reset();
    start_clk_i();
    @(posedge clk_i);
    start_rand_dvr();
    start_checking();

    //@(posedge clk_i);
    //result_print(1, "This is a PASS");
    repeat(5000)@(posedge clk_i);
    result_print(!fail, $sformatf("Data flow %0d/%0d", pass, pass + fail));
  $finish;
  end
endmodule
