/*
This module represents a simple 32-bit memory model with read and write ports. It is designed to be
used with a processor or other digital system. The module contains an internal memory array `mem`,
which is an 8-bit wide array indexed by the address. The memory array stores 4Byte data written to
it and provides 4 Byte data for read operations.
Author : Foez Ahmed (foez.official@gmail.com)
*/

`include "simple_processor_pkg.sv"

module r2_w1_32b_memory_model
  import simple_processor_pkg::ADDR_WIDTH;
  import simple_processor_pkg::DATA_WIDTH;
#(
) (
    input logic                  clk_i,     // Clock input
    input logic                  we_i,      // Write enable input
    input logic [ADDR_WIDTH-1:0] w_addr_i,  // Write address input
    input logic [DATA_WIDTH-1:0] w_data_i,  // Write data input

    input  logic [ADDR_WIDTH-1:0] r0_addr_i,  // Read port 0 address input
    output logic [DATA_WIDTH-1:0] r0_data_o,  // Read port 0 data output

    input  logic [ADDR_WIDTH-1:0] r1_addr_i,  // Read port 1 address input
    output logic [DATA_WIDTH-1:0] r1_data_o   // Read port 1 data output
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Using associative array to save space. Vivado on a 32GB machine can handle around 8MB RTL
  // memory before stalling. Associative array is like python dictionary
  logic [7:0] mem[logic [ADDR_WIDTH-1:0]];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Clear out the entire memory. This is not synthesizable
  function automatic void clear();
    mem.delete();
  endfunction

  // Load a hex file into the memory. This is not synthesizable
  function automatic void load(input string file);
    $readmemh(file, mem);
  endfunction

  // Write a byte to the memory. This is not synthesizable
  function automatic void write(input logic [ADDR_WIDTH-1:0] addr, input logic [7:0] data);
    mem[addr] = data;
  endfunction

  // Read a byte from the memory. This is not synthesizable
  function automatic logic [7:0] read(input logic [ADDR_WIDTH-1:0] addr);
    return mem[addr];
  endfunction

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Address sensitive as combinational
  // Clock sensitive to maintain correct output if data itself gets update
  for (genvar i = 0; i < 4; i++) begin : g_read0s
    always @(r0_addr_i, clk_i) begin
      r0_data_o[i*8+7:i*8] <= mem[{r0_addr_i[ADDR_WIDTH-1:2], 2'b0}+i];
    end
  end

  // Address sensitive as combinational
  // Clock sensitive to maintain correct output if data itself gets update
  for (genvar i = 0; i < 4; i++) begin : g_read1s
    always @(r1_addr_i, clk_i) begin
      r1_data_o[i*8+7:i*8] <= mem[{r1_addr_i[ADDR_WIDTH-1:2], 2'b0}+i];
    end
  end

  // Associative array can not be driven by a non-blocking assignment
  // Anyway, we're not synthesizing this memory
  for (genvar i = 0; i < 4; i++) begin : g_writes
    always @(posedge clk_i) begin
      if (we_i) begin
        mem[{w_addr_i[ADDR_WIDTH-1:2], 2'b0}+i] = w_data_i[i*8+7:i*8];
      end
    end
  end

endmodule
