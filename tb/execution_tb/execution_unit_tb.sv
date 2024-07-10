/*
Description
Author : nusratanila (nusratanila94@gmail.com)
*/

`include "simple_processor_pkg.sv"

module execution_unit_tb;

   //`define ENABLE_DUMPFILE

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-IMPORTS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   `include "vip/tb_ess.sv"
   import simple_processor_pkg::*;

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-LOCALPARAMS
   //////////////////////////////////////////////////////////////////////////////////////////////////

   localparam int DataWidth = 32;  // Changed to CamelCase

   //////////////////////////////////////////////////////////////////////////////////////////////////
   //-SIGNALS
   //////////////////////////////////////////////////////////////////////////////////////////////////
   `CREATE_CLK(clk_i, 4ns, 6ns)

   logic [DataWidth-1:0] rs1_data_i;
   logic [DataWidth-1:0] rs2_data_i;
   logic [5:0] imm;
   func_t func_i;
   logic [DataWidth-1:0] res_math;
   logic [DataWidth-1:0] rd_data_o;
   logic [DataWidth-1:0] res_shift;
   logic [DataWidth-1:0] result;
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

   task static randomize_inputs();
   rs1_data_i = $urandom;
   rs2_data_i = $urandom;
   imm = $urandom % 64;  // 6-bit random immediate value
   randcase
     1: func_i = AND;
     1: func_i = OR;
     1: func_i = XOR;
     1: func_i = NOT;
     1: func_i = ADDI;
     1: func_i = ADD;
     1: func_i = SUB;
     1: func_i = SLL;
     1: func_i = SLLI;
     1: func_i = SLR;
     1: func_i = SLRI;
     default: func_i = ADD;  // Default to ADD operation if no other case matches
   endcase
 endtask

 //////////////////////////////////////////////////////////////////////////////////////////////////
 //-SEQUENTIALS
 //////////////////////////////////////////////////////////////////////////////////////////////////

 initial begin
   apply_reset();
   start_clk_i();

   // Run random tests
   repeat (100) begin
     randomize_inputs();
     @(posedge clk_i);

     // Check results based on randomized func_i
     case (func_i)
       AND: if (rd_data_o === (rs1_data_i & rs2_data_i))
              result_print(1, "AND test passed!");
            else
              result_print(0, "AND test failed!");

       OR:  if (rd_data_o === (rs1_data_i | rs2_data_i))
              result_print(1, "OR test passed!");
            else
              result_print(0, "OR test failed!");

       XOR: if (rd_data_o === (rs1_data_i ^ rs2_data_i))
              result_print(1, "XOR test passed!");
            else
              result_print(0, "XOR test failed!");

       NOT: if (rd_data_o === ~rs1_data_i)
              result_print(1, "NOT test passed!");
            else
              result_print(0, "NOT test failed!");

       ADDI: if (res_math === (rs1_data_i + {{26{imm[5]}}, imm}))
               result_print(1, "ADDI test passed!");
             else
               result_print(0, "ADDI test failed!");

       ADD: if (res_math === (rs1_data_i + rs2_data_i))
              result_print(1, "ADD test passed!");
            else
              result_print(0, "ADD test failed!");

       SUB: if (res_math === (rs1_data_i - rs2_data_i))
              result_print(1, "SUB test passed!");
            else
              result_print(0, "SUB test failed!");

       SLL: if (res_shift === (rs1_data_i << rs2_data_i))
              result_print(1, "SLL test passed!");
            else
              result_print(0, "SLL test failed!");

       SLLI: if (res_shift === (rs1_data_i << {{26{imm[5]}}, imm}))
               result_print(1, "SLLI test passed!");
             else
               result_print(0, "SLLI test failed!");

       SLR: if (res_shift === (rs1_data_i >> rs2_data_i))
              result_print(1, "SLR test passed!");
            else
              result_print(0, "SLR test failed!");

       SLRI: if (res_shift === (rs1_data_i >> {{26{imm[5]}}, imm}))
               result_print(1, "SLRI test passed!");
             else
               result_print(0, "SLRI test failed!");

       default: result_print(0, "Unexpected func_i value!");
     endcase
   end

   // Finishing the simulation
   #10 $display("All tests completed.");
   $finish;
 end

endmodule
