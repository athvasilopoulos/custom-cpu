# Custom CPU
This project was a first try to build a custom CPU from scratch. The RTL code is written in Verilog and I use Xilinx IPs for the external memory.

## Architecture
The system follows the Harvard architecture with separate instruction and data memories. The instruction memory is a single port ROM IP, whereas the data memory is a single port RAM IP. The CPU contains 32 16-bit general purpose registers.

## ISA
The instructions follow the three address format,which means both the operands and the destination register need to be specified in the instruction. The instructions are 32-bit and follow the following modes:

1. Register addressing mode

>>| Bit field | Content |
>>|:---------:|:-------:|
>>| 31...27   | Opcode  |
>>| 26...22   | Destination register |
>>| 21...17   | Source register 1 |
>>| 16   | Addressing mode (0) |
>>| 15...11   | Source register 2 |
>>| 10...0   | Unused |
<br>

2. Immediate addressing mode

>>| Bit field | Content |
>>|:---------:|:-------:|
>>| 31...27   | Opcode  |
>>| 26...22   | Destination register |
>>| 21...17   | Source register 1 |
>>| 16   | Addressing mode (1) |
>>| 15...0   | Immediate data |
<br>

3. Jump and branch instructions

>>| Bit field | Content |
>>|:---------:|:-------:|
>>| 31...27   | Opcode  |
>>| 26...17   | Unused  |
>>| 16   | Addressing mode (1) |
>>| 15...0   | Instruction address |
<br>

4. Store and load instructions
>>| Bit field | Content |
>>|:---------:|:-------:|
>>| 31...27   | Opcode  |
>>| 26...16   | RAM address  |
>>| 15...11   | Store/Load register (for LD and STR)|
>>| 10...0   | Unused (for LD and STR)|
>>| 15...0 | Immediate data (for STI) |
