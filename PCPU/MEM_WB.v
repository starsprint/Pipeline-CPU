module MEM_WB (
  input wire Clk, 
  input wire Rst, 
  input wire flush,
  input [31:0] MEM_WB_PC_in,
  input [31:0] MEM_WB_ALUout_in,
  input [31:0] MEM_WB_signals_in,
  input [31:0] MEM_WB_RD1_in,
  input [31:0] MEM_WB_RD2_in,
  input [31:0] MEM_WB_rddata_in,
  input [4:0] MEM_WB_rd_in,
  
  output reg [31:0] WB_PC_out,
  output reg [31:0] WB_ALUout,
  output reg [31:0] WB_signals,
  output reg [31:0] WB_RD1,
  output reg [31:0] WB_RD2,
  output reg [31:0] WB_rd_data,
  output reg [4:0] WB_rd
);

  always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      WB_PC_out <= 32'h0000_0000;
      WB_ALUout <= 32'h0000_0000;
      WB_signals <= 32'h0000_0000;
      WB_RD1 <= 32'h0000_0000;
      WB_RD2 <= 32'h0000_0000;
      WB_rd_data <= 32'h0000_0000;
      WB_rd <= 5'h00000;
    end else if (flush) begin
      WB_PC_out <= 32'h0000_0000;
      WB_ALUout <= 32'h0000_0000;
      WB_signals <= 32'h0000_0000;
      WB_RD1 <= 32'h0000_0000;
      WB_RD2 <= 32'h0000_0000;
      WB_rd_data <= 32'h0000_0000;
      WB_rd <= 5'h00000;
    end else begin
      WB_PC_out <= MEM_WB_PC_in;
      WB_ALUout <= MEM_WB_ALUout_in;
      WB_signals <= MEM_WB_signals_in;
      WB_RD1 <= MEM_WB_RD1_in;
      WB_RD2 <= MEM_WB_RD2_in;
      WB_rd_data <= MEM_WB_rddata_in;
      WB_rd <= MEM_WB_rd_in;
    end
  end

endmodule
