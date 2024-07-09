/*
Write a markdown documentation for this systemverilog module:
Author : Ramisa Tahsin (ramisashreya@gmail.com)
*/


module eu_merge
import simple_processor_pkg::*;
#(
) (
    //-PORTS
input  logic  [DATA_WIDTH-1:0]  rs1_data_i,     //source register 1 data input from RF
input  func_t                   func_i,         //funct_i
input  logic  [5:0]             imm,            //immediate input
input  logic  [DATA_WIDTH-1:0]  rs2_data_i,     //second register value input

output logic [DATA_WIDTH-1:0]  res_math,          //final result input for add,addi,sub
output logic [DATA_WIDTH-1:0]  res_gate,         //result for gate operation
output logic [DATA_WIDTH-1:0]  res_shift,         //result for shift operation
//output logic [DATA_WIDTH-1:0]  res_mem          //result for memory operation
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                        shift_r;          //shift right if HIGH, shift left if LOW
  logic   [DATA_WIDTH - 1:0 ]  imm_extended_1;   //extended 32 bit imm
  logic   [DATA_WIDTH - 1:0 ]  shift_amount;     //number of bits we want to shift 
                                                          //extracted from imm or Rs2
  
  logic   [DATA_WIDTH-1:0]     rs2_data_i_2c;    //intermediate value for 2's complement
  logic   [DATA_WIDTH-1:0]     imm_extended;     //Sign extension for imm
  logic   [DATA_WIDTH-1:0]     selected_input;   //to select between Rs2 or imm

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //ALU Math

  //2's complement for the sub operation
assign rs2_data_i_2c = ~rs2_data_i + 1;

 //Sign extention for the immediate
assign imm_extended = {{26{imm[5]}}, imm};

  //ALU Gate

always_comb begin
  case (func_i)
    AND:      res_gate = rs1_data_i & rs2_data_i;  // AND operation
    OR:       res_gate = rs1_data_i | rs2_data_i;  // OR operation
    XOR:      res_gate = rs1_data_i ^ rs2_data_i;  // XOR operation
    NOT:      res_gate = ~rs1_data_i;              // NOT operation (only uses rs1_data_i)
    default:  res_gate = {DATA_WIDTH{1'b0}};       // Default case to handle invalid opcodes
  endcase
end

//Shifting

assign imm_extended_1 = {{26{imm[5]}}, imm};          //sign-extending immediate

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

//mimicking the input mux operation for ALU Math

always_comb begin
  case(func_i)
    ADDI: selected_input = imm_extended;
    ADD : selected_input = rs2_data_i;
    SUB : selected_input = rs2_data_i_2c;
    //every other input selection for different block will be done here
    default : selected_input = 32'b0;
  endcase
end

assign res_math = rs1_data_i + selected_input;

//Shifting

always_comb begin
  case(func_i)
    SLL     : begin
              shift_r = '0;
              shift_amount = rs2_data_i;
    end
    SLLI    : begin
              shift_r = '0;
              shift_amount = imm_extended_1;
    end
    SLR     : begin
              shift_r = '1;
              shift_amount = rs2_data_i;
    end
    SLRI    : begin
              shift_r = '1;
              shift_amount = imm_extended_1;
    end
    default : begin
              shift_r = '1;
              shift_amount = rs2_data_i;
    end
  endcase
end

assign res_shift = shift_r? rs1_data_i >> shift_amount : rs1_data_i << shift_amount;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

always_comb begin
  case (func_i)
    AND,ADDI,SUB            :      result = res_math;  // AND operation
    AND,OR,XOR,NOT          :      result = rd_data_o;  // OR operation
    SLL,SLR,SLLI,SLRI       :      result = res_shift;  // XOR operation
    //LOAD/STORE   :      result = ;              // NOT operation (only uses rs1_data_i)
    default:  result = {DATA_WIDTH{1'b0}};       // Default case to handle invalid opcodes
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