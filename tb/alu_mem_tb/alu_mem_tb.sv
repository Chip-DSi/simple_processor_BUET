`include "simple_processor_pkg.sv"

module alu_mem_tb;

    `include "vip/tb_ess.sv"
    // Parameters
    import simple_processor_pkg::*;
    //parameter int DATA_WIDTH = 32;

    // Signals

    `CREATE_CLK(clk_i, 4ns, 6ns)
    logic [DATA_WIDTH-1:0] rs1_data_i, rs2_data_i, rd_data_i;
    logic [DATA_WIDTH-1:0] result, mem_addr_o, mem_data_o;
    logic we_i;
    func_t  func_i;

    int pass;
    int fail;

    // Instantiate the module under test
    alu_mem dut (
        .rs1_data_i,
        .func_i,
        .rs2_data_i,
        .we_i,
        .rd_data_i,
        //.result,
        .mem_addr_o,
        .mem_data_o
    );

    task static start_rand_dvr();
      fork
        forever begin
          rs1_data_i  <= $urandom;
          rs2_data_i  <= $urandom;
          rd_data_i   <= $urandom;
          we_i        <= $urandom % 2;
          randcase
            1:  func_i <= LOAD;
            1:  func_i <= STORE;
          endcase
          @(posedge clk_i);
        end
      join_none
    endtask

    task static start_checking();
      fork
        forever begin
          @(posedge clk_i);
          case(func_i)
            //LOAD : result = mem_data_i;
            LOAD : if(!we_i) result = rd_data_i;
            STORE: if(we_i) result  = rs2_data_i;
            default: result = 32'b0;
          endcase
          if(result === mem_data_o) begin
            pass++;
          end
          //if(result === rd_data_o ) pass++;
          else  begin
            fail++;
          end
        end
      join_none
    endtask

    // Stimulus generation
    initial begin
        // Initialize random seed
        pass = 0;
        fail = 0;
        rs1_data_i = 0;
        rs2_data_i = 0;
        rd_data_i = 0;
        we_i = 0;
        func_i = LOAD;
        result = 0;
        start_clk_i();
        @(posedge clk_i);
        start_rand_dvr();
        start_checking();
        repeat(5000)@(posedge clk_i);
        result_print(!fail, $sformatf("Pass: %0d; Total: %0d", pass, pass + fail));

        // End simulation
        $finish;
    end

endmodule
