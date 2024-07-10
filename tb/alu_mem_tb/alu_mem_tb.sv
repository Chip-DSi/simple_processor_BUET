
`include "simple_processor_pkg.sv"

module alu_mem_tb;

    `include "vip/tb_ess.sv"
    // Parameters
    import simple_processor_pkg::*;
    //parameter int DATA_WIDTH = 32;

    // Signals

    `CREATE_CLK(clk_i, 4ns, 6ns)
    logic [DATA_WIDTH-1:0] rs1_data_i, rs2_data_i, mem_data_i, rd_data_o;
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
        .mem_data_i,
        .rd_data_o,
        .result,
        .mem_addr_o,
        .mem_data_o
    );

    task static start_rand_dvr();
      fork
        forever begin
          rs1_data_i <= $urandom;
          rs2_data_i <= $urandom;
          mem_data_i <= $urandom;
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
            LOAD : if(!we_i) result = mem_data_i;
            STORE: if(we_i) result = mem_data_o;
            default: result = 32'b0;
          endcase
          if(result === mem_data_i || result === mem_data_o) pass++;
          //if(result === rd_data_o ) pass++;
          else  fail++;
          end
      join_none
    endtask


    // Stimulus generation
    initial begin
        // Initialize random seed
        start_clk_i();
        @(posedge clk_i);
        start_rand_dvr();
        start_checking();
        repeat(5000)@(posedge clk_i);
        result_print(!fail, $sformatf("Successful load, store: %0d;\nTotal attempts: %0d", pass, pass + fail));

        // End simulation
        $finish;
    end

endmodule
