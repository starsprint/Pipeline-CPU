module IF_ID (
  input wire Clk, 
  input wire Rst, 
  input wire flush,
  input [31:0] IF_ID_PC_in,
  input [31:0] IF_ID_inst_in,

  output reg [31:0] ID_PC_out,
  output reg [31:0] ID_inst
);

  always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      ID_PC_out <= 32'h0000_0000;
      ID_inst <= 32'h0000_0000;
    end else if (flush) begin
      ID_PC_out <= 32'h0000_0000;
      ID_inst <= 32'h0000_0000;
    end else begin
      ID_PC_out <= IF_ID_PC_in;
      ID_inst <= IF_ID_inst_in;
    end
  end

endmodule
