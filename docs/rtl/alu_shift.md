# alu_shift (module)

### Author : Bokhtiar Foysol Himon (bokhtiarfoysol@gmail.com)

## TOP IO
<img src="./alu_shift_top.svg">

## Description

Write a markdown documentation for this systemverilog module:
This module takes in Rs1, Rs2 and an immediate. Shifts the value of Rs1 by Rs2 or immediate

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|rs1_data_i|input|logic [DATA_WIDTH - 1:0]||input data from Rs1|
|rs2_data_i|input|logic [DATA_WIDTH - 1:0]||input data from Rs2|
|func_i|input|func_t||input func_t from Instruction Decoder|
|imm|input|logic [5:0]||extracted imm from func_t|
|result|output|logic [DATA_WIDTH - 1:0]||output result|
