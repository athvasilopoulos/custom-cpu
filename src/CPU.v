`timescale 1ns / 1ps
`include "macros.v"

module CPU(
  input clk, rst
);
  /* 
    Register declarations
  */

  // 32 16-bit general purpose registers are user accessible, R[32] -- mul MSB register
  reg [15:0] GPR [32:0];
  // Instruction register
  reg [31:0] IR;
  // Temporary register for multiplication
  reg [31:0] mul_temp;
  // Program counter
  reg [15:0] PC;
  // Link Register
  reg [15:0] LR;
  // Branch temporary register
  reg [15:0] blr;

  /* 
    Signal declarations
  */

  // Ram signals
  reg ram_en, ram_we;
  reg [10:0] ram_addr;
  reg [15:0] ram_din;
  wire [15:0] ram_dout;
  // Rom signals
  wire [31:0] rom_dout;
  reg rom_en;
  // Flag logic
  reg zero, sign, carry, overflow;
  reg [15:0] s1, s2;
  reg [32:0] o;
  // Halt variable
  reg stop;
  // Controller variables
  integer delay_count;
  reg [2:0] state;
  integer i;
  
  /* 
    Memories are generated by the Vivado IP Catalog (Block Memory Generator)
  */

  // Program memory (Single port ROM)
  blk_mem_gen_0 prog_memory (.clka(clk), .ena(rom_en), .addra(PC), .douta(rom_dout));
  
  // Data memory (Single port RAM)
  blk_mem_gen_1 data_memory (
    .clka(clk), .ena(ram_en), 
    .wea(ram_we), .addra(ram_addr),
    .dina(ram_din), .douta(ram_dout)
  );
  
  /* 
    Task declarations for the different operations
  */

  // Instruction decoding and operation execution
  task execute();
    case(`opcode)

      // Update register data
      `mov: begin
        if(`imm_mode == 1'b1)
          GPR[`r_dst] = `immediate;
        else
          GPR[`r_dst] = GPR[`r_src1];
      end

      // Arithmetic operations
      `add: begin
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] + `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] + GPR[`r_src2];
        end
        conditionflags();
      end
      `sub: begin
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] - `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] - GPR[`r_src2];
        end
        conditionflags();
      end
      `mul: begin
        if(`imm_mode == 1'b1) begin
          mul_temp = GPR[`r_src1] * `immediate;
          GPR[`r_dst] = mul_temp[15:0];
          GPR[32] = mul_temp[31:16];
        end
        else begin
          mul_temp = GPR[`r_src1] * GPR[`r_src2];
          GPR[`r_dst] = mul_temp[15:0];
          GPR[32] = mul_temp[31:16];
        end
        conditionflags();
      end

      // Logic operations
      `and: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] & `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] & GPR[`r_src2];
        end
      end
      `or: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] | `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] | GPR[`r_src2];
        end
      end
      `xor: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] ^ `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] ^ GPR[`r_src2];
        end
      end
      `nand: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = ~(GPR[`r_src1] & `immediate);
        end
        else begin
          GPR[`r_dst] = ~(GPR[`r_src1] & GPR[`r_src2]);
        end
      end
      `nor: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = ~(GPR[`r_src1] | `immediate);
        end
        else begin
          GPR[`r_dst] = ~(GPR[`r_src1] | GPR[`r_src2]);
        end
      end
      `xnor: begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = GPR[`r_src1] ~^ `immediate;
        end
        else begin
          GPR[`r_dst] = GPR[`r_src1] ~^ GPR[`r_src2];
        end
      end
      `not:begin 
        if(`imm_mode == 1'b1) begin
          GPR[`r_dst] = ~`immediate;
        end
        else begin
          GPR[`r_dst] = ~GPR[`r_src1];
        end
      end
      
      // RAM instructions
      `sti: begin 
        write_ram_imm();
      end
      `str: begin
        write_ram_reg();
      end
      `ld: begin
        read_ram();
      end
      
      // Jump instruction
      `jmp: begin
        LR = PC;
        if(`imm_mode == 1'b1)
          PC = `jmp_imm_addr;
      end

      // Branch instructions
      `bc: begin 
        if(carry)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bz: begin 
        if(zero)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bn: begin 
        if(sign)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bv: begin 
        if(overflow)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bnc: begin
        if (carry == 1'b0)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bnz: begin
        if (zero == 1'b0)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bnn: begin
        if (sign == 1'b0)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end
      `bnv: begin
        if (overflow == 1'b0)
          blr = `branch_imm_addr;
        else
          blr = PC + 1;
      end

      // Halt instruction
      `hlt:
        stop = 1'b1;

    endcase
  endtask

  // Flag logic
  task conditionflags();
    begin
      begin
        if(`imm_mode == 1'b1) begin
          s1 = GPR[`r_src1];
          s2 = `immediate;
        end
        else begin
          s1 = GPR[`r_src1];
          s2 = GPR[`r_src2];
        end
      end
      case(`opcode)
        `add: o = s1 + s2;
        `sub: o = s1 - s2;
        `mul: o = s1 * s2;
        default: o = 0;
      endcase
  
      zero = ~(|o[32:0]);
      sign = (o[15] & ~IR[28] & IR[27]) | (o[15] & IR[28] & ~IR[27]) | (o[31] & IR[28] & IR[27]);
      carry = (o[16] & ~IR[28] & IR[27]);
      overflow = (~s1[15] & ~s2[15] & o[15] & ~IR[28] & IR[27]) | 
                 (s1[15] & s2[15] & ~o[15] & ~IR[28] & IR[27]) |
                 (s1[15] & ~s2[15] & ~o[15] & IR[28] & ~IR[27]) |
                 (~s1[15] & s2[15] & o[15] & IR[28] & ~IR[27]);
    end
  endtask
  
  // Ram tasks
  task read_ram();
    begin 
      ram_en = 1'b1;
      ram_we = 1'b0;
      ram_addr = `ram_address;
      // Data is stored in the 4th state of the controller
      // due to the two cycles delay of the memories.
    end
  endtask

  task write_ram_imm();
    begin 
      ram_en = 1'b1;
      ram_we = 1'b1;
      ram_addr = `ram_address;
      ram_din = `ram_imm_data;
    end
  endtask

  task write_ram_reg();
    begin 
      ram_en = 1'b1;
      ram_we = 1'b1;
      ram_addr = `ram_address;
      ram_din = GPR[`ram_wr_reg];
    end
  endtask
  
  // Reset Task
  task reset();
    begin
      for(i = 0; i < 33; i = i + 1)
        GPR[i] = 0;
      PC = 0;
      zero = 0;
      carry = 0;
      overflow = 0;
      sign = 0;
      stop = 0;
      state = 3'b0;
      delay_count = 0;
      ram_en = 0;
      ram_we = 0;
      rom_en = 0;
    end
  endtask

  /*
    State controller
  */

  always @(posedge clk or posedge rst) begin
    if(rst)
      reset();
    else if(clk) begin
      case (state)
      
        // Check for halt signal
        3'b0: begin
          if(stop)
            state <= 3'b0;
          else
            state <= 3'b001;
        end
        
        // Put the next instruction inside
        // the IR. A delay of 3 cycles is
        // added due to the memory delay
        3'b001: begin 
          IR <= rom_dout;
          rom_en <= 1'b1;
          if (delay_count < 3) begin 
            delay_count <= delay_count + 1;
            state <= 3'b001;
          end
          else begin 
            delay_count <= 0;
            state <= 3'b010;
          end
        end
        
        // Decode and execute the operation
        3'b010: begin 
          rom_en <= 1'b0;
          execute();
          state <= 3'b011;
        end
        
        // Delay to ensure all operations
        // are finished (especially memory operations)
        3'b011: begin 
          if(delay_count < 3)
            delay_count <= delay_count + 1;
          else begin 
            delay_count <= 0;
            state <= 3'b100;
          end
        end
        
        // Finish the ld operation (if executed) and
        // then update the PC with the next instruction
        3'b100: begin
          ram_en <= 1'b0;
          state <= 3'b101;
          if(`opcode == `ld)
            GPR[`ram_rd_reg] <= ram_dout;
          if(`opcode == `jmp)
            PC <= PC;
          else if(`bc <= `opcode && `opcode <= `bnv)
            PC <= blr;
          else
            PC <= PC + 1;
        end
        
        // Extra delay for robustness
        3'b101: begin 
          if(delay_count < 3)
            delay_count <= delay_count + 1;
          else begin 
            delay_count <= 0;
            state <= 3'b0;
          end
        end
      endcase
    end
  end
endmodule
