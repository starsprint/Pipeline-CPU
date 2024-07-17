module Hazard(
  input ID_EX_MR,  //ctrl中生成的WDSel低位，判断是否为load指令
  input [4:0] ID_EX_rd,
  input [4:0] IF_ID_rs1,
  input [4:0] IF_ID_rs2,
  
  output reg stall
);

//判断是否为加载指令产生的数据冒险
always @(*) begin
  if (ID_EX_MR && (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2) && (ID_EX_rd != 0)) begin
    stall = 1;

  end else begin
    stall = 0;
  end

end

endmodule