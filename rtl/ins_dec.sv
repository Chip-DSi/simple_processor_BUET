/*
This system verilog module performs the functionality of instruction decoder
Author : Anindya Kishore Choudhury (anindyakchoudhury@gmail.com)
*/

`include "simple_processor_pkg.sv"

module ins_dec
import simple_processor_pkg::*;
#(
) (
    //-PORTS
    input  logic [INSTR_WIDTH-1:0] imem_rdata_i, //instruction data coming from IMEM
    input  logic                   imem_ack_i,   //IMEM ack to select between imem_rdata_i or 0
    input  logic [INSTR_WIDTH-1:0] imem_addr_i,  //Address we are fetching from imem_rdata_i

    output func_t                  func_o,       //op codes are stored in this typedef
    output logic                   we_o,         //write enable pin for RF
    output logic [2:0]             rd_addr_o,    //destination register address
    output logic [2:0]             rs1_addr_o,   //RS1 register address
    output logic [2:0]             rs2_addr_o,   //RS2 register address
    output logic [5:0]             imm_o,        //unextended immediate
    output logic                   valid_pc      //for mux selector input after pc
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [INSTR_WIDTH-1:0] instruction;
  logic                   is_valid;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign instruction = imem_addr_i[1] ? imem_rdata_i[31:16] : imem_rdata_i[15:0]; //muxtochoose ins
  assign func_o      = func_t'(instruction[3:0]); //enum variable assignment technique
  assign rs1_addr_o  = instruction[12:10];
  assign imm_o       = instruction[9:4];
  assign rs2_addr_o  = instruction[9:7];
  assign rd_addr_o   = instruction[15:13];
  assign imem_ack_i  = 1'b1; //hardcoded to one always for our case

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  always_comb begin

    //default values
    valid_pc = 1'b1;
    we_o = 1'b1;

    case(func_o)
      ADDI, ADD, SUB        : is_valid = 1'b1; //is_valid can be replaced by valid_pc
      AND, OR, XOR, NOT     : is_valid = 1'b1;
      LOAD, STORE           : is_valid = 1'b1;
      SLL, SLR, SLLI, SLRI  : is_valid = 1'b1;
      default               : is_valid = 1'b0;
    endcase

    //if first register tries to get written
    //or a wrong opcode is stored in the IMEM
    //boot address will get loaded in PC
    //write enable will be made zero
    //if (rd_addr_o == 'b0 || (!is_valid)) we actually need the rd_addr_ = '0 for NOP
    if(!is_valid)
    begin
      valid_pc = 1'b0;
      we_o     = 1'b0;
    end

    if (func_o == STORE) we_o = 1'b0; //no writeback needed in RF for store operation

  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
