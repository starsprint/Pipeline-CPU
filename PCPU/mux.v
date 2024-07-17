module mux2(
  input  select,
  input [31:0] in_0,
  input [31:0] in_1,

  output reg [31:0] out
);

  always @(*) begin
    case (select)
      1'b0: out = in_0;
      1'b1: out = in_1;
      default: out = 0;
    endcase
  end
endmodule


module mux3(
  input [1:0] select,
  input [31:0] in_0,
  input [31:0] in_1,
  input [31:0] in_2,

  output reg [31:0] out
);

  always @(*) begin
    case (select)
      2'b00: out = in_0;
      2'b01: out = in_1;
      2'b10: out = in_2;
      default: out = 0;
    endcase
  end
endmodule