`timescale 1ns / 1ps
module tb_cpu();
  // Initialize the system
  logic clk, rst;
  CPU my_cpy (clk, rst);
  
  // Start a clock
  always #5 clk = ~clk;
  // Reset the CPU and then start the program
  // that is loaded in the ROM
  initial begin
    clk <= 0;
    rst <= 1;
    #22 rst <= 0;
    #10000 $finish;
  end
  
endmodule
