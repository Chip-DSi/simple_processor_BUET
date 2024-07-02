`ifndif
`define SIMPLE_PROCESSOR_PKG__

package simple_processor_pkg;
  localparam int ADDR_WIDTH = 32;
  localparam int DATA_WIDTH = 32;
  localparam int INSTR_WIDTH = 16;
  localparam int XLEN = 32;

  typedef enum logic [3:0]{
    ADDI  = 'b0001, 
    ADD   = 'b0011,
    SUB   = 'b1011,
    AND   = 'b0101,
    OR    = 'b1101,
    XOR   = 'b1111,
    NOT   = 'b0111,
    LOAD  = 'b0010,
    STORE = 'b1010,
    SLL   = 'b0110,
    SLR   = 'b0100,
    SLLI  = 'b1110,
    SLRI  = 'b1100
  } func_t;

endpackage

`endif
