/*
Description
Author : Foez Ahmed (foez.official@gmail.com)
Dmem Functions Added by: Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

`include "vip/model_pkg.sv"

module simple_processor_tb;

  `define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"

  // Write a byte in model's internal memory
  // void model_write(int addr, byte data);
  //import model_pkg::model_write;

  // Read a byte from model's internal memory
  // byte model_read(int addr);
  // import model_pkg::model_read;

  // Load a hex file in model's internal memory
  // void model_load(input string file);
  // import model_pkg::model_load;

  // Set model's program counter
  // void model_set_PC(int addr);
  // import model_pkg::model_set_PC;

  // Get model's program counter
  // int model_get_PC();
  // import model_pkg::model_get_PC;

  // Set model's internal register's content
  // void model_set_GPR(byte addr, int data);
  // import model_pkg::model_set_GPR;

  // Get model's internal register content
  // int model_get_GPR(byte addr);
  // import model_pkg::model_get_GPR;

  // Disassemble instruction
  // void model_dis_asm(int instr);
  // import model_pkg::model_dis_asm;

  // check if the last operation was a DMEM operation
  // bit model_is_dmem_op();
  // import model_pkg::model_is_dmem_op;

  // check if the last DMEM operation had write enabled
  // bit model_is_dmem_we();
  // import model_pkg::model_is_dmem_we;

  // get last DMEM operation's address
  // int model_dmem_addr();
  // import model_pkg::model_dmem_addr;

  // get last DMEM operation's data
  // int model_dmem_data();
  // import model_pkg::model_dmem_data;

  // execute one instruction and increase program counter by 2
  // void model_step();
  // import model_pkg::model_step;

  import model_pkg::*;
  import simple_processor_pkg::*;

  //import simple_processor_pkg::ADDR_WIDTH;
  //import simple_processor_pkg::DATA_WIDTH;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 4ns, 6ns)

  logic                  arst_ni = 1;
  logic [ADDR_WIDTH-1:0] boot_addr_i = '0;

  logic                  imem_req_o;
  logic [ADDR_WIDTH-1:0] imem_addr_o;
  logic [DATA_WIDTH-1:0] imem_rdata_i;
  logic                  imem_ack_i;

  logic                  dmem_req_o;
  logic                  dmem_we_o;
  logic [ADDR_WIDTH-1:0] dmem_addr_o;
  logic [DATA_WIDTH-1:0] dmem_wdata_o;
  logic [DATA_WIDTH-1:0] dmem_rdata_i;
  logic                  dmem_ack_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int pass_reg, fail_reg;
  int pass_dmem_store, fail_dmem_store;
  int pass_dmem_load, fail_dmem_load;
  int store_count, load_count;

  int instr_addr_temp, model_dmem_data_temp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-CLASSES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO: Add delay
  assign imem_ack_i = imem_req_o;
  assign dmem_ack_i = dmem_req_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // DUT
  simple_processor core (
      .clk_i,
      .arst_ni,
      .boot_addr_i,
      .imem_req_o,
      .imem_addr_o,
      .imem_rdata_i,
      .imem_ack_i,
      .dmem_req_o,
      .dmem_we_o,
      .dmem_addr_o,
      .dmem_wdata_o,
      .dmem_rdata_i,
      .dmem_ack_i
  );

  // Model to act as main memory
  r2_w1_32b_memory_model mMEM (
      .clk_i,
      .we_i(dmem_we_o),
      .w_addr_i(dmem_addr_o),
      .w_data_i(dmem_wdata_o),
      .r0_addr_i(dmem_addr_o),
      .r0_data_o(dmem_rdata_i),
      .r1_addr_i(imem_addr_o),
      .r1_data_o(imem_rdata_i)
  );

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

  function automatic int read_reg(int reg_num);
    case (reg_num)
      1: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[1].register_dut.q_o);
      2: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[2].register_dut.q_o);
      3: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[3].register_dut.q_o);
      4: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[4].register_dut.q_o);
      5: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[5].register_dut.q_o);
      6: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[6].register_dut.q_o);
      7: return int'(simple_processor_tb.core.u_reg_file_top.g_reg_array[7].register_dut.q_o);
      default: return 0;
    endcase
  endfunction

  function automatic void write_reg(int reg_num, int data);
    case (reg_num)
      1: simple_processor_tb.core.u_reg_file_top.g_reg_array[1].register_dut.q_o = data;
      2: simple_processor_tb.core.u_reg_file_top.g_reg_array[2].register_dut.q_o = data;
      3: simple_processor_tb.core.u_reg_file_top.g_reg_array[3].register_dut.q_o = data;
      4: simple_processor_tb.core.u_reg_file_top.g_reg_array[4].register_dut.q_o = data;
      5: simple_processor_tb.core.u_reg_file_top.g_reg_array[5].register_dut.q_o = data;
      6: simple_processor_tb.core.u_reg_file_top.g_reg_array[6].register_dut.q_o = data;
      7: simple_processor_tb.core.u_reg_file_top.g_reg_array[7].register_dut.q_o = data;
      default: begin

      end
    endcase
  endfunction

  function automatic int read_word_mem(int dmem_addr_temp);

  endfunction

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial

    mMEM.clear();

    model_load("all_test.hex");
    mMEM.load("all_test.hex");

    boot_addr_i <= 'h1000;

    apply_reset();
    start_clk_i();

    model_set_PC(boot_addr_i);

    for (int i = 0; i < 8; i++) begin
      model_set_GPR(i, $urandom);
      write_reg(i, model_get_GPR(i));
    end

    @(posedge clk_i);

    while (1) begin  //does 13 mean anything special here?
      @(posedge clk_i);
      if (core.u_ins_dec_top.is_valid) begin
        model_step();

        //DMEM Check during Store Operations
        if( core.u_ins_dec_top.func_o == 4'b1010) begin
          store_count++;

          //Write Enable Check

          if (model_is_dmem_we() == dmem_we_o) begin
            pass_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WE Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_is_dmem_we(), dmem_we_o);
          end else begin
            fail_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WE Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_is_dmem_we(), dmem_we_o);
          end

          //Write Data Address Check

          if (model_dmem_addr() == dmem_addr_o) begin
            pass_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_ADDR Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_addr(), dmem_addr_o);
          end else begin
            fail_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_ADDR Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_addr(), dmem_addr_o);
          end

          //Write Data Check

          if (model_dmem_data() == dmem_wdata_o) begin
            pass_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WDATA Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_data(), dmem_wdata_o);
          end else begin
            fail_dmem_store++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WDATA Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_data(), dmem_wdata_o);
          end
        end

        //DMEM Check during Load Operations
        if( core.u_ins_dec_top.func_o == 4'b0010) begin
          load_count++;
          instr_addr_temp = model_get_PC() - 2;
          model_dmem_data_temp = model_dmem_data();
          $display("Model Mem[RS]= 0x%08h", model_read(model_dmem_addr()));
          //Write Disable Check for the load operation

          if (model_is_dmem_we() == dmem_we_o) begin
            pass_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WE Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_is_dmem_we(), dmem_we_o);
          end else begin
            fail_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_WE Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_is_dmem_we(), dmem_we_o);
          end

          //Read Data Address Check

          if (model_dmem_addr() == dmem_addr_o) begin
            pass_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_ADDR Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_addr(), dmem_addr_o);
          end else begin
            fail_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_ADDR Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_addr(), dmem_addr_o);
          end

          //Read Data Check using dmem_rdata_i
          //How to get something on the line of dmem_rdata_i? Ask Bhaiya

          // if (model_dmem_data() == dmem_rdata_i) begin
          //   pass_dmem_load++;
          //   $display("\033[1;35mInstr_addr:0x%08h DMEM_RDATA Model:0x%0h RTL:0x%0h\033[0m",
          //            model_get_PC() - 2, model_dmem_data(), dmem_rdata_i);
          // end else begin
          //   fail_dmem_load++;
          //   $display("\033[1;35mInstr_addr:0x%08h DMEM_RDATA Model:0x%0h RTL:0x%0h\033[0m",
          //            model_get_PC() - 2, model_dmem_data(), dmem_rdata_i);
          // end
        end

        @(negedge clk_i);
        for (int i = 0; i < 8; i++) begin
          if (model_get_GPR(i) == read_reg(i)) begin
            pass_reg++;
            $display("\033[1;33mInstr_addr:0x%08h GPR:%0d Model:0x%08h RTL:0x%08h\033[0m",
                     model_get_PC() - 2, i, model_get_GPR(i), read_reg(i));
          end else begin
            fail_reg++;
            $display("\033[1;31mInstr_addr:0x%08h GPR:%0d Model:0x%08h RTL:0x%08h\033[0m",
                     model_get_PC() - 2, i, model_get_GPR(i), read_reg(i));
          end
        end

        //Read Data from Dmem Operation Check using register value, not wire value
        if(instr_addr_temp == model_get_PC() - 2) begin
          if (model_dmem_data_temp == read_reg(core.u_ins_dec_top.rd_addr_o)) begin
            pass_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_RDATA Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_data_temp, read_reg(core.u_ins_dec_top.rd_addr_o));
          end else begin
            fail_dmem_load++;
            $display("\033[1;35mInstr_addr:0x%08h DMEM_RDATA Model:0x%0h RTL:0x%0h\033[0m",
                     model_get_PC() - 2, model_dmem_data_temp, read_reg(core.u_ins_dec_top.rd_addr_o));
          end
        end

      end else begin
        break;
      end


    end

    // C model is an separetely running program causing
    // race condition with printf & $display
    #100ns;

    result_print(!fail_reg, $sformatf(
                 "Top Reg Check %0d/%0d for %0d instruction", pass_reg, pass_reg + fail_reg, (pass_reg + fail_reg) / 8
                 ));
    result_print(!fail_dmem_store, $sformatf(
    "Top DMEM Check %0d/%0d for %0d store instruction", pass_dmem_store, pass_dmem_store + fail_dmem_store,
    store_count ));
    result_print(!fail_dmem_load, $sformatf(
      "Top DMEM Check %0d/%0d for %0d load instruction", pass_dmem_load, pass_dmem_load + fail_dmem_load,
      load_count ));

    $finish;

  end

endmodule
