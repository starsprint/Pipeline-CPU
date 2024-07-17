module ID_EX (
  input wire Clk, 
  input wire Rst, 
  input wire flush,
  input [31:0] ID_EX_PC_in,
  input [4:0] ID_EX_rs1_in,
  input [4:0] ID_EX_rs2_in,
  input [4:0] ID_EX_rd_in,
  input [31:0] ID_EX_ctrlsignals_in,
  input [31:0] ID_EX_RD1_in,
  input [31:0] ID_EX_RD2_in,
  input [31:0] ID_EX_immout_in,

  output reg [31:0] EX_PC_out,
  output reg [4:0] EX_rs1,
  output reg [4:0] EX_rs2,
  output reg [4:0] EX_rd,
  output reg [31:0] EX_signals,
  output reg [31:0] EX_RD1,
  output reg [31:0] EX_RD2,
  output reg [31:0] EX_immout
);

  always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      EX_PC_out <= 32'h0000_0000;
      EX_rs1 <= 5'b00000;
      EX_rs2 <= 5'b00000;
      EX_rd <= 5'b00000;
      EX_signals <= 32'h0000_0000;
      EX_RD1 <= 32'h0000_0000;
      EX_RD2 <= 32'h0000_0000;
      EX_immout <= 32'h0000_0000;
    end else if (flush) begin
      EX_PC_out <= 32'h0000_0000;
      EX_rs1 <= 5'b00000;
      EX_rs2 <= 5'b00000;
      EX_rd <= 5'b00000;
      EX_signals <= 32'h0000_0000;
      EX_RD1 <= 32'h0000_0000;
      EX_RD2 <= 32'h0000_0000;
      EX_immout <= 32'h0000_0000;
    end else begin
      EX_PC_out <= ID_EX_PC_in;
      EX_rs1 <= ID_EX_rs1_in;
      EX_rs2 <= ID_EX_rs2_in;
      EX_rd <= ID_EX_rd_in;
      EX_signals <= ID_EX_ctrlsignals_in;
      EX_RD1 <= ID_EX_RD1_in;
      EX_RD2 <= ID_EX_RD2_in;
      EX_immout <= ID_EX_immout_in;
    end
  end

endmodule
