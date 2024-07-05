`include "simple_processor_pkg.sv"

`ifndef MODEL_PKG__
`define MODEL_PKG__

package model_pkg;

  import simple_processor_pkg::ADDR_WIDTH;

  import "DPI-C" function void model_write(int addr, byte data);

  import "DPI-C" function byte model_read(int addr);

  function automatic void model_load(input string file);
    logic [7:0] mem[logic [ADDR_WIDTH-1:0]];
    $readmemh(file, mem);
    foreach (mem[i]) model_write(i,mem[i]);
  endfunction

  import "DPI-C" function void model_set_PC(int addr);

  import "DPI-C" function int model_get_PC();

  import "DPI-C" function void model_set_GPR(byte addr, int data);

  import "DPI-C" function int model_get_GPR(byte addr);

  import "DPI-C" function void model_dis_asm(int instr);

  import "DPI-C" function bit model_is_dmem_op();

  import "DPI-C" function bit model_is_dmem_we();

  import "DPI-C" function int model_dmem_addr();

  import "DPI-C" function int model_dmem_data();

  import "DPI-C" function void model_step();

endpackage

`endif
