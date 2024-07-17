module PC(
  input clk,             //时钟信号
  input rst,             //复位信号
  input [31:0] NPC,      //新指令
  
  output reg [31:0] PC   //当前指令
);

always @(posedge clk, posedge rst)
begin
  if(rst)
    PC <= 32'h00000000;
  else
    PC <= NPC;
end
endmodule
