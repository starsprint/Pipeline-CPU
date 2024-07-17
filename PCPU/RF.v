module RF(
  input clk,               //时钟
  input rst,               //复位信号
  input RegWrite,          //写使能信号，为1时，在时钟上升沿写入
  input [4:0] rs1,         //源寄存器1地址输入端口
  input [4:0] rs2,         //源寄存器2地址输入端口
  input [4:0] WriteReg,    //目的寄存器地址输入端口
  input [31:0] WriteData,  //写入目的寄存器的数据输入端口
  
  output [31:0] ReadData1,
  output [31:0] ReadData2
);

reg [31:0] rf[31:0]; //新建32个寄存器
integer i;

//写寄存器
always @(negedge clk, posedge rst)
if(rst) begin
  for(i = 0 ; i< 32 ; i= i + 1) rf[i] <= 0;
end

else if(RegWrite && WriteReg != 0) begin //不能修改0号寄存器的值
  rf[WriteReg] = WriteData;
  
end

//读寄存器
assign ReadData1 = (rs1 != 0) ? rf[rs1] : 0;
assign ReadData2 = (rs2 != 0) ? rf[rs2] : 0;

endmodule