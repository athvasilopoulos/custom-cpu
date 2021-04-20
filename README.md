# Custom CPU
This project was a first try to build a custom CPU from scratch. The RTL code is written in Verilog and I use Xilinx IPs for the external memory.

## Architecture
The system follows the Harvard architecture with separate instruction and data memories. The instruction memory is a single port ROM IP, whereas the data memory is a single port RAM IP. The CPU contains 32 16-bit general purpose registers, one 16-bit register to hold the MSBs of the multiplication operation and four flags for carry, zero, sign and overflow on arithmetic operations.

## Instruction format
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

## Instructions

| Name | Operation | Opcode | Instruction mode|
|:----:|:-------:|:-------:|:-------:|
| MOV | Rdst <- (Rsrc1 or Imm)| 00000 | 1, 2|
| ADD | Rdst <- Rsrc1 + (Rsrc2 or Imm)| 00001 | 1, 2 |
| SUB | Rdst <- Rsrc1 - (Rsrc2 or Imm)| 00010 | 1, 2 |
| MUL | Rdst <- Rsrc1 * (Rsrc2 or Imm)| 00011 | 1, 2 |
| AND | Rdst <- Rsrc1 & (Rsrc2 or Imm)| 00100 | 1, 2 |
| OR  | Rdst <- Rsrc1 \| (Rsrc2 or Imm)| 00101 | 1, 2 |
| XOR | Rdst <- Rsrc1 ^ (Rsrc2 or Imm)| 00110 | 1, 2 |
| NAND| Rdst <- ~(Rsrc1 & (Rsrc2 or Imm))| 00111 | 1, 2 |
| NOR | Rdst <- ~(Rsrc1 \| (Rsrc2 or Imm))| 01000 | 1, 2 |
| XNOR| Rdst <- Rsrc1 ~^ (Rsrc2 or Imm)| 01001 | 1, 2 |
| NOT | Rdst <- ~(Rsrc1 or Imm)| 01010 | 1, 2 |
| LD  | Rld <- RAM(address) | 01011 | 4 |
| STI | RAM(address) <- Immediate | 01100 | 4 |
| STR | RAM(address) <- Rst | 01101 | 4 |
| JMP | PC <- Instr. address | 01110 | 3 |
| BC  | if(carry) PC <- Instr. address | 01111 | 3 |
| BZ  | if(zero) PC <- Instr. address | 10000 | 3 |
| BN  | if(sign) PC <- Instr. address | 10001 | 3 |
| BV  | if(overflow) PC <- Instr. address | 10010 | 3 |
| BNC | if(!carry) PC <- Instr. address | 10011 | 3 |
| BNZ | if(!zero) PC <- Instr. address | 10100 | 3 |
| BNN | if(!sign) PC <- Instr. address | 10101 | 3 |
| BNV | if(!overflow) PC <- Instr. address | 10110 | 3 |
| HLT | Halt the CPU | 10111 | 3 |


## How to test the CPU
The CPU was designed with the Vivado Design Suite and uses its IP Catalog for the external memories. To test the CPU the following steps are necessary:
1. Generate the Instruction and Data memories from the Block Memory Generator on the IP Catalog. For the parameters check the corresponding file
2. Write the assembly program on its binary format inside a coe file and link it with the ROM inside Vivado
3. Run a simulation from the testbench and check if the content of the registers is the expected