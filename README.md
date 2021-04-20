# Custom CPU
This project was a first try to build a custom CPU from scratch. The RTL code is written in Verilog and I use Xilinx IPs for the external memory.

## Architecture
The system follows the Harvard architecture with separate instruction and data memories. The instruction memory is a single port ROM IP, whereas the data memory is a single port RAM IP. The CPU contains 32 16-bit general purpose registers.

## ISA
The instructions follow the three address format,which means both the operands and the destination register need to be specified in the instruction. The instructions are 32-bit and follow the following modes:

### 1. Register addressing mode

|Bit field:|31...27|26...22|21...17|16|15...11|10...0|
|:--------:|:-----:|:-----:|:-----:|:-:|:----:|:----:|
|Content:|Opcode|Dest. reg.|Src. reg. 1|0|Src. reg. 2|Unused


### 2. Immediate addressing mode

|Bit field:|31...27|26...22|21...17|16|15...0|
|:--------:|:-----:|:-----:|:-----:|:-:|:----:|
|Content:|Opcode|Dest. reg.|Src. reg.|1|Imm. data|

### 3. Jump and branch instructions

|Bit field:|31...27|26...17|16|15...0|
|:--------:|:-----:|:-----:|:-:|:----:|
|Content:|Opcode|Unused|1|Instr. address|

### 4. Store and load instructions

| Bit field: | 31...27 | 26...16 | 15...11 | 10...0 |
|:---------:|:-------:|:-------:|:-------:|:-------:|
| Content: | Opcode  | RAM address | Str/Ld reg. |Unused |

| Bit field: | 31...27 | 26...16 | 15...0 |
|:---------:|:-------:|:-------:|:-------:|
| Content: | Opcode  | RAM address | Imm. data|
