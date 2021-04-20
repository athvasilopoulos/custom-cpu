// Areas of the instruction register
`define opcode IR[31:27]
`define r_dst IR[26:22]
`define r_src1 IR[21:17]
`define r_src2 IR[15:11]
`define imm_mode IR[16]
`define immediate IR[15:0]
`define ram_address IR[26:16]
`define ram_rd_reg IR[15:11]
`define ram_wr_reg IR[15:11]
`define ram_imm_data IR[15:0]
`define jmp_imm_addr IR[15:0]
`define branch_imm_addr IR[15:0]

// Opcode to operation table
`define mov 5'b00000
// Arithmetic Operations
`define add 5'b00001
`define sub 5'b00010
`define mul 5'b00011
// Logic Operations
`define and 5'b00100
`define or 5'b00101
`define xor 5'b00110
`define nand 5'b00111
`define nor 5'b01000
`define xnor 5'b01001
`define not 5'b01010
// Ram operations
`define ld 5'b01011
`define sti 5'b01100
`define str 5'b01101
// Jump operation
`define jmp 5'b01110
// Branch on flags operations
`define bc 5'b01111
`define bz 5'b10000
`define bn 5'b10001
`define bv 5'b10010
`define bnc 5'b10011
`define bnz 5'b10100
`define bnn 5'b10101
`define bnv 5'b10110
// Halt
`define hlt 5'b10111