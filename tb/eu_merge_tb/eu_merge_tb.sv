/*
Description
Author : nusratanila (nusratanila94@gmail.com)
*/

`include "simple_processor_pkg.sv"

module eu_merge_tb;

   //`define ENABLE_DUMPFILE

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-IMPORTS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   `include "vip/tb_ess.sv"
   import simple_processor_pkg::*;

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-LOCALPARAMS
   //////////////////////////////////////////////////////////////////////////////////////////////////



   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-SIGNALS
   //////////////////////////////////////////////////////////////////////////////////////////////////
   `CREATE_CLK(clk_i, 4ns, 6ns)

   logic arst_ni = 1;

   logic [DATAWIDTH-1:0] rs1_data_i;
   logic [DATAWIDTH-1:0] rs2_data_i;
   logic [5:0]           imm;
   func_t                func_i;
   logic [DATAWIDTH-1:0] res_math;
   logic [DATAWIDTH-1:0] res_gate;
   logic [DATAWIDTH-1:0] res_shift;
   //logic [DATAWIDTH-1:0] result;


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                     pass;
  int                     fail;
  logic  [DATA_WIDTH-1:0] res_math_exp;
  logic  [DATA_WIDTH-1:0] res_gate_exp;
  logic  [DATA_WIDTH-1:0] res_shift_exp;
  logic                   s_r;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  eu_merge dut (
    .rs1_data_i,
    .func_i,
    .imm,
    .rs2_data_i,
    .res_math,
    .res_gate,
    .res_shift
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task static start_rand_dvr();
    fork
      forever begin
        rs1_data_i <= $urandom;
        rs2_data_i <= $urandom;
        imm <= $urandom;  // 6-bit random immediate value
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

  assign imm_ext = {{26{imm[5]}}, imm};
//   monitor and check
  task static start_checking();
    fork
      forever begin
        @(posedge clk_i);
        case(func_i)
          ADDI    : begin
                     res_math_exp = imm_ext;
                       if(res_math === rs1_data_i + res_math_exp) pass++;
                       else begin
                            fail++;
                       end
                    end
          ADD     : begin
                     res_math_exp = rs2_data_i;
                       if(res_math === rs1_data_i + res_math_exp) pass++;
                       else begin
                          fail++;
                       end
                    end
          SUB     : begin
                     res_math_exp = ~rs2_data_i + 1;
                     if(res_math === rs1_data_i + res_math_exp) pass++;
                     else begin
                          fail++;
                     end
                    end
          AND     : begin
                     res_gate_exp = rs1_data_i & rs2_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                     end
                    end
          OR      : begin
                     res_gate_exp = rs1_data_i | rs2_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                     end
                    end
          XOR     : begin
                     res_gate_exp = rs1_data_i ^ rs2_data_i;
                     if (res_gate == res_gate_exp) pass++;
                     else begin
                          fail++;
                     end
                    end
          NOT     : begin
                     res_gate_exp = ~rs1_data_i;
                     if (res_gate === res_gate_exp) pass++;
                     else begin
                          fail++;
                     end
                    end
          SLLI:     begin
                      res_shift_exp = imm_ext;
                      s_r = '0;
                      if (res_shift === (rs1_data_i << res_gate_exp)) pass++;
                       else begin
                            fail++;
                      end
                    end
          SLRI:     begin
                    res_shift_exp = imm_ext;
                    s_r = '1;
                    if (res_shift === (rs1_data_i >> res_gate_exp)) pass++;
                       else begin
                            fail++;
                      end
                    end
          SLL :     begin
                    res_shift_exp = rs2_data_i;
                    s_r = '0 ;
                    if (res_shift === (rs1_data_i << res_gate_exp)) pass++;
                       else begin
                            fail++;
                      end
                    end
          SLR :     begin
                    res_shift_exp = rs2_data_i;
                    s_r = '1;
                    if (res_shift === (rs1_data_i >> res_gate_exp)) pass++;
                       else begin
                            fail++;
                      end
                    end
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
