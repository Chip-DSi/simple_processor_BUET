
`include "simple_processor_pkg.sv"

module alu_mem_tb;

    `include "vip/tb_ess.sv"
    // Parameters
    import simple_processor_pkg::*;
    //parameter int DATA_WIDTH = 32;

    // Signals

    `CREATE_CLK(clk_i, 4ns, 6ns)
    logic [DATA_WIDTH-1:0] rs1_data_i, rs2_data_i, dmem_rd_i, dmem_ack_i;
    logic [DATA_WIDTH-1:0] dmem_req_o, dmem_addr_o, dmem_we_o, dmem_wdata_o;
    logic [DATA_WIDTH-1:0] rd_data_o, result;
    func_t  func_i;

    int pass;
    int fail;

    // Instantiate the module under test
    alu_mem dut (
        .func_i,
        .rs1_data_i,
        .rs2_data_i,
        .dmem_rd_i,
        .dmem_ack_i,
        .dmem_req_o,
        .dmem_addr_o,
        .dmem_we_o,
        .dmem_wdata_o,
        .rd_data_o
    );

    task static start_rand_dvr();
      fork
        forever begin
          rs1_data_i    <= $urandom;
          rs2_data_i    <= $urandom;
          dmem_rd_i     <= $urandom;
          dmem_ack_i    <= $urandom;
          randcase
            1:  func_i  <= LOAD;
            1:  func_i  <= STORE;
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
            LOAD : begin
              result = dmem_rd_i;
              if(result === rd_data_o) begin
                pass++;
              end
              else  begin
                fail++;
              end
            end
            STORE: begin
              result   = rs2_data_i;
              if(result === dmem_wdata_o) begin
                pass++;
              end
              else  begin
                fail++;
              end
            end
            default: result = 32'b0;
          endcase
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
        dmem_rd_i   = 0;
        dmem_ack_i = 0;
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
