module EX_MEM (
  input wire Clk, 
  input wire Rst, 
  input wire flush,
  input [31:0] EX_MEM_PC_in,
  input [4:0] EX_MEM_rd_in,
  input [31:0] EX_MEM_signals_in,
  input [31:0] EX_MEM_RD1_in,
  input [31:0] EX_MEM_rRD2_in,
  input [31:0] EX_MEM_ALUout_in,
  input EX_MEM_zero,
  input [31:0] EX_MEM_immout_in,

  output reg [31:0] MEM_PC_out,
  output reg [4:0] MEM_rd,
  output reg [31:0] MEM_signals,
  output reg [31:0] MEM_RD1,
  output reg [31:0] MEM_RD2,
  output reg [31:0] MEM_ALUout,
  output reg MEM_zero,
  output reg [31:0] MEM_immout
);

  always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      MEM_PC_out <= 32'h0000_0000;
      MEM_rd <= 5'b00000;
      MEM_signals <= 32'h0000_0000;
      MEM_RD1 <= 32'h0000_0000;
      MEM_RD2 <= 32'h0000_0000;
      MEM_ALUout <= 32'h0000_0000;
      MEM_zero <= 0;
      MEM_immout <= 32'h0000_0000;
    end else if (flush) begin
      MEM_PC_out <= 32'h0000_0000;
      MEM_rd <= 5'b00000;
      MEM_signals <= 32'h0000_0000;
      MEM_RD1 <= 32'h0000_0000;
      MEM_RD2 <= 32'h0000_0000;
      MEM_ALUout <= 32'h0000_0000;
      MEM_zero <= 0;
      MEM_immout <= 32'h0000_0000;
    end else begin
      MEM_PC_out <= EX_MEM_PC_in;
      MEM_rd <= EX_MEM_rd_in;
      MEM_signals <= EX_MEM_signals_in;
      MEM_RD1 <= EX_MEM_RD1_in;
      MEM_RD2 <= EX_MEM_rRD2_in;
      MEM_ALUout <= EX_MEM_ALUout_in;
      MEM_zero <= EX_MEM_zero;
      MEM_immout <= EX_MEM_immout_in;
    end
  end

endmodule
