module Forward(
  input [4:0] ID_EX_rs1,
  input [4:0] ID_EX_rs2,
  input [4:0] EX_MEM_rd,
  input [4:0] MEM_WB_rd,
  input EX_MEM_WB,
  input MEM_WB_WB,

  output reg [1:0] ForwardA,
  output reg [1:0] ForwardB
);

always @(*) begin
  ForwardA = 2'b00;
  ForwardB = 2'b00;

  if (MEM_WB_WB && (MEM_WB_rd != 0)) begin
    if (MEM_WB_rd == ID_EX_rs1) ForwardA = 2'b01;

    if (MEM_WB_rd == ID_EX_rs2) ForwardB = 2'b01;
  end

  if (EX_MEM_WB && (EX_MEM_rd != 0)) begin
    if (EX_MEM_rd == ID_EX_rs1) ForwardA = 2'b10;

    if (EX_MEM_rd == ID_EX_rs2) ForwardB = 2'b10;
  end
  
end

endmodule