# merge_execution (module)

### Author      : Anindya Kishore Choudhury (anindyakchoudhury@gmai.com)
### Base Author : Ramisa Tahsin (ramisashreya@gmail.com)

## TOP IO
<img src="./merge_execution_top.svg">

## Description

Write a markdown documentation for this systemverilog module: execution unit merge

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|MEM_ADDR_WIDTH|int||simple_processor_pkg::ADDR_WIDTH|With of memory address bus|
|MEM_DATA_WIDTH|int||simple_processor_pkg::DATA_WIDTH|With of memory data bus|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|rs1_data_i|input|logic [DATA_WIDTH-1:0]||source register 1 data input from RF|
|func_i|input|func_t||input func_i from op code|
|imm_i|input|logic [5:0]||immiediate input|
|rs2_data_i|input|logic [DATA_WIDTH-1:0]||second register value input|
|dmem_rdata_i|input|logic [MEM_DATA_WIDTH-1:0]||DMEM data of the requested address|
|dmem_ack_i|input|logic||Acknowledge if data request is completed|
|dmem_req_o|output|logic||DMEM is active, always HIGH|
|dmem_addr_o|output|logic [MEM_ADDR_WIDTH-1:0]||Data to be read/written to this address|
|dmem_we_o|output|logic||Active for STORE operation|
|dmem_wdata_o|output|logic [MEM_DATA_WIDTH-1:0]||DATA to be stored in DMEM|
|rd_data_o|output|logic [DATA_WIDTH-1:0]||Final Output from mux|
