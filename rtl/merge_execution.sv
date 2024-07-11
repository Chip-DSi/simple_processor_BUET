/*
Write a markdown documentation for this systemverilog module: execution unit merge01
Author : Ramisa Tahsin (ramisashreya@gmail.com)
*/

`include "simple_processor_pkg.sv"

module merge_execution
import simple_processor_pkg::*;
#(
) (
    //-PORTS
input  logic  [DATA_WIDTH-1:0]    rs1_data_i,     //source register 1 data input from RF
input  func_t                     func_i,         //funct_i
input  logic  [5:0]               imm_i,          //imm_iediate input
input  logic  [DATA_WIDTH-1:0]    rs2_data_i,     //second register value input
input  logic  [DATA_WIDTH-1:0]    dmem_rd_i,      // DMEM data of the requested address
input  logic  [DATA_WIDTH-1:0]    dmem_ack_i,     // Acknowledge if data request is completed
output logic  [DATA_WIDTH-1:0]    dmem_req_o,     // DMEM is active, always HIGH
output logic  [DATA_WIDTH-1:0]    dmem_addr_o,    // Data to be read/written to this address
output logic  [DATA_WIDTH-1:0]    dmem_we_o,      // Active for STORE operation
output logic  [DATA_WIDTH-1:0]    dmem_wdata_o,   // DATA to be stored in DMEM
output logic  [DATA_WIDTH-1:0]    rd_data_o       // Data to be written to RF
output logic  [DATA_WIDTH-1:0]    result,         //final output from mux
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [DATA_WIDTH-1:0]   res_math;          //final result input for add,addi,sub
  logic [DATA_WIDTH-1:0]   res_gate;        //result for gate operation
  logic [DATA_WIDTH-1:0]   res_shift;         //result for shift operation
  logic [DATA_WIDTH-1:0]   res_mem;         //result for memory operation

  logic                        shift_r;          //shift right if HIGH, shift left if LOW
  logic   [DATA_WIDTH - 1:0 ]  imm_i_extended_1;   //extended 32 bit imm_i
  logic   [DATA_WIDTH - 1:0 ]  shift_amount;     //number of bits we want to shift 
                                                          //extracted from imm_i or Rs2
  
  logic   [DATA_WIDTH-1:0]     rs2_data_i_2c;    //intermediate value for 2's complement
  logic   [DATA_WIDTH-1:0]     imm_i_extended;     //Sign extension for imm_i
  logic   [DATA_WIDTH-1:0]     selected_input;   //to select between Rs2 or imm_i

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //ALU Math

  //2's complement for the sub operation
  assign rs2_data_i_2c = ~rs2_data_i + 1;

  //Sign extention for the imm_iediate
  assign imm_i_extended = {{26{imm_i[5]}}, imm_i};

  //Shifting
  assign imm_i_extended_1 = {{26{imm_i[5]}}, imm_i};          //sign-extending imm_iediate

  //Memory address and data assignments
  assign dmem_addr_o  = rs1_data_i;              // RS1 has address which is load 

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

//mimicking the input mux operation for ALU Math
always_comb begin
  case(func_i)
    ADDI: selected_input = imm_i_extended;
    ADD : selected_input = rs2_data_i;
    SUB : selected_input = rs2_data_i_2c;
    //every other input selection for different block will be done here
    default : selected_input = 32'b0;
  endcase
end

assign res_math = rs1_data_i + selected_input;

//ALU Gate
always_comb begin
  case (func_i)
    ADD:      res_gate = rs1_data_i & rs2_data_i;  // AND operation
    OR:       res_gate = rs1_data_i | rs2_data_i;  // OR operation
    XOR:      res_gate = rs1_data_i ^ rs2_data_i;  // XOR operation
    NOT:      res_gate = ~rs1_data_i;              // NOT operation (only uses rs1_data_i)
    default:  res_gate = {DATA_WIDTH{1'b0}};       // Default case to handle invalid opcodes
  endcase
end

//Shifting
always_comb begin
  case(func_i)
    SLL     : begin
              shift_r = '0;
              shift_amount = rs2_data_i;
    end
    SLLI    : begin
              shift_r = '0;
              shift_amount = imm_i_extended_1;
    end
    SLR     : begin
              shift_r = '1;
              shift_amount = rs2_data_i;
    end
    SLRI    : begin
              shift_r = '1;
              shift_amount = imm_i_extended_1;
    end
    default : begin
              shift_r = '1;
              shift_amount = rs2_data_i;
    end
  endcase
end

assign res_shift = shift_r? rs1_data_i >> shift_amount : rs1_data_i << shift_amount;

//control logic for load and store
always_comb begin
  case(func_i)
    LOAD:     begin
      res_mem = dmem_rd_i;                 // Data read from memory
      dmem_we_o = '0;
    end
    STORE:    begin
      dmem_wdata_o = rs2_data_i;             // RS2 data to be stored to memory
      dmem_we_o    =  '1;                    // Write is active
    end
    default:  rd_data_o = 32'b0;             // Default result if no valid operation
  endcase
end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

always_comb begin
  case (func_i)
    AND,ADDI,SUB            :      result = res_math;  // math operation
    AND,OR,XOR,NOT          :      result = res_gate;  // gate operation
    SLL,SLR,SLLI,SLRI       :      result = res_shift;  // shift operation
    LOAD                    :      result = res_mem;   // load operation 
    default                 :      result = {DATA_WIDTH{1'b0}};       // Default case to handle invalid opcodes
  endcase
end

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule
