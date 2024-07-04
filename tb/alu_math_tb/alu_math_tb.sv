/*
This is the testbench of the alu_math block
Author                 : MD. Toky Tazwar (toky.tech01t@gmail.com) and Mehedi Hasan
Editor and Executioner : Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

`include "simple_processor_pkg.sv"

module alu_math_tb;

  //`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"

  import simple_processor_pkg::*;

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)

  logic arst_ni = 1;

  logic  [DATA_WIDTH-1:0] rs1_data_i;
  func_t                  func_i; //added func_t here by akc
  logic  [5:0]            imm;
  logic  [DATA_WIDTH-1:0] rs2_data_i;
  logic  [DATA_WIDTH-1:0] result;
  logic  [DATA_WIDTH-1:0] temp;
  logic  [DATA_WIDTH-1:0] imm_ext;


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int                    pass;
  int                    fail;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  alu_math dut (
    .rs1_data_i,
    .func_i,
    .imm,
    .rs2_data_i,
    .result
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task static start_rand_dvr();
  fork
    forever begin
      rs1_data_i   <= $urandom;
      rs2_data_i  <= $urandom;
      imm  <= $urandom;
      randcase
        5: func_i <= ADDI;
        5: func_i <= ADD;
        5: func_i <= SUB;
       // 1: func_i <= INVALID;
    endcase

      @(posedge clk_i);
    end
  join_none
endtask
assign imm_ext = {{26{imm[5]}}, imm};
// monitor and check
task static start_checking();
  fork
    forever begin
      @(posedge clk_i);
      case(func_i)
      ADDI    : temp = imm_ext;
      ADD     : temp = rs2_data_i;
      SUB     : temp = ~rs2_data_i + 1;
      default : temp = 32'b0;
      //every other input selection for different block will be done here
       endcase
      if (result === (rs1_data_i + temp)) pass++;
      else begin
        fail++;
      end
    end
  join_none
endtask

//////////////////////////////////////////////////////////////////////////////////////////////////
//-PROCEDURALS
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
