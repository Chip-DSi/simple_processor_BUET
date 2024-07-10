/*
The `reg_file` module is a register file with a configurable number of source registers, register
width, and an option to hardcode zero to the first register.
Base File Author: Md. Mohiuddin Reyad (mreyad30207@gmail.com)
Author: Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

module reg_file #(
    parameter int NUM_RS = 2,     // number of source register
    parameter bit ZERO_REG = 1,   // hardcoded zero(0) to first register
    parameter int NUM_REG = 8,   // number of registers
    parameter int REG_WIDTH = 32  // width of each register
) (
    input logic clk_i,   // Global clock
    input logic arst_ni, // asynchronous active low reset

    input logic [$clog2(NUM_REG)-1:0] rd_addr_i,  // destination register address
    input logic [      REG_WIDTH-1:0] rd_data_i,  // read data
    //input logic                       rd_en_i,  // read enable not necessary
    input logic                       we_i,       // write enable

    input logic [$clog2(NUM_REG)-1:0] rs1_addr_i,  // source register 1 address
    input logic [$clog2(NUM_REG)-1:0] rs2_addr_i,  // source register 2 address

    output logic [REG_WIDTH-1:0] rs1_data_o,  // source register 1 data
    output logic [REG_WIDTH-1:0] rs2_data_o   // source register 2 data
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [NUM_REG-1:0]                demux_en;  // connected with the register enable
  logic [NUM_REG-1:0][REG_WIDTH-1:0] mux_in;  // input for mux

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  if (ZERO_REG) begin : g_zero
    assign mux_in[0] = '0;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  demux #(
      .NUM_ELEM  (NUM_REG),
      .ELEM_WIDTH(1)
  ) u_demux_reg (
      .s_i(rd_addr_i),
      .i_i(we_i),
      .o_o(demux_en)
  );

  for (genvar i = ZERO_REG; i < NUM_REG; i++) begin : g_reg_array
    register #(
        .ELEM_WIDTH (REG_WIDTH),
        .RESET_VALUE('0)
    ) register_dut (
        .clk_i  (clk_i),
        .arst_ni(arst_ni),
        .en_i   (demux_en[i]),
        .d_i    (rd_data_i),
        .q_o    (mux_in[i])
    );
  end

    mux #(
      .ELEM_WIDTH(REG_WIDTH),
      .NUM_ELEM  (NUM_REG)
  ) u_mux_rs1 (
      .s_i(rs1_addr_i),
      .i_i(mux_in),
      .o_o(rs1_data_o)
  );

  mux #(
      .ELEM_WIDTH(REG_WIDTH),
      .NUM_ELEM  (NUM_REG)
  ) u_mux_rs2 (
      .s_i(rs2_addr_i),
      .i_i(mux_in),
      .o_o(rs2_data_o)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (NUM_REG > 64) begin
      $display("\033[7;31m%m TOO MANY REGISTERS!!\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
