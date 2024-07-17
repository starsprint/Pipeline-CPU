`include "ctrl_encode_def.v"
module EXT( 
	input   [4:0]           iimm_shamt,
    input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[11:0]			sbimm, //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	input	[19:0]			uimm,
	input	[19:0]			ujimm,
	input	[5:0]			EXTOp, //立即数扩展控制信号，用于选择不同的立即数扩展方式。

	output	reg [31:0] 	    immout);
   
always  @(*)
	 case (EXTOp)
		`EXT_CTRL_ITYPE_SHAMT:   immout<={27'b0,iimm_shamt[4:0]};
		`EXT_CTRL_ITYPE:	immout <= {{{32-12}{iimm[11]}}, iimm[11:0]};
		`EXT_CTRL_STYPE:	immout <= {{{32-12}{simm[11]}}, simm[11:0]};
		`EXT_CTRL_BTYPE:    immout <= {{{32-13}{sbimm[11]}}, sbimm[11:0], 1'b0};
		`EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0}; 
		`EXT_CTRL_JTYPE:	immout <= {{{32-21}{ujimm[19]}}, ujimm[19:0], 1'b0};
		default:	        immout <= 32'b0;
	 endcase

       
endmodule
