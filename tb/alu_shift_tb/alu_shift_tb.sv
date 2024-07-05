/*
Making the testbench of alushift
Author : Md. Julkar Naim Joy (naimjoy567@gmail.com)
*/
`include "simple_processor_pkg.sv"
module alu_shift_tb;
  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"
  import simple_processor_pkg::ADDR_WIDTH;
  import simple_processor_pkg::DATA_WIDTH;
  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)
  logic  [DATA_WIDTH-1:0] rs1_data_i;
  logic  [3:0]            func_i;
  logic  [5:0]            imm;
  logic  [DATA_WIDTH-1:0] rs2_data_i;
  logic  [DATA_WIDTH-1:0] result;
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  int                     pass;
  int                     fail;
  logic  [DATA_WIDTH-1:0] temp;
  logic                   s_r;

  alu_shift_tb dut (
    .rs1_data_i,
    .func_i,
    .imm,
    .rs2_data_i,
    .result
  );

  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task static start_rand_dvr();
  fork
    forever begin
      rs1_data_i   <= $urandom;
      rs2_data_i  <= $urandom;
      imm  <= $urandom & 'h11f;
      rand case
        4: func_i <= SLL;
        4: func_i <= SLLI;
        4: func_i <= SLR;
        4: func_i <= SLRI;
        //1: func_i<=INVALID;
      endcase

      @(posedge clk_i);
    end
  join_none
endtask
assign imm = {{26{imm[5]}}, imm};
// monitor and check
task static start_checking();
  fork
    forever begin
      @(posedge clk_i);
      case(func_i)
        SLLI: begin
              temp = imm;
              s_r = '0;
              end
        SLRI: begin
              temp = imm;
              s_r = '1;
              end
        SLL : begin
              temp = rs2_data_i;
              s_r = '0 ;
              end
        SLR : begin
              temp = rs2_data_i;
              s_r = '1;
              end
        //every other input selection for different block will be done here
      endcase
      if(s_r=='1)
        if (result === (rs1_data_i >> temp)) pass++;
        else fail++;
      else begin
        if (result === (rs1_data_i << temp)) pass++;
        else fail++;
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
  start_rand_dvr();
  start_checking();
  repeat(1000) @(posedge clk_i);
  result_print(!fail, $sformatf("frontdoor data flow %0d/%0d" , pass, pass + fail));
  $finish;

end

endmodule