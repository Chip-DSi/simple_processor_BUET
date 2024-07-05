# merge_execution (module)

### Author : Mymuna Khatun Sadia (maimuna14400@gmail.com)

## TOP IO
<img src="./merge_execution_top.svg">

## Description

Write a markdown documentation for this systemverilog module:
This is merged file for execution of 4 blocks

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|rs1_data_i|input|logic [DATA_WIDTH-1:0]||source register 1 data input from RF|
|func_i|input|func_t||confused about instr_t|
|imm|input|logic [5:0]||immediate input|
|rs2_data_i|input|logic [DATA_WIDTH-1:0]||second register value input|
|res_math|output|logic [DATA_WIDTH-1:0]||final result input|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||destination reg data|
|res_shift|output|logic [DATA_WIDTH-1:0]|| final result input destination reg data|
|result|output|logic [DATA_WIDTH-1:0]|||
