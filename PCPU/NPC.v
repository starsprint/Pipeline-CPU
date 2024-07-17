`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, NPC,aluout, MEM_pcout);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input  [31:0] aluout;
   input [31:0] MEM_pcout;

   output reg [31:0] NPC;   // next pc

   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4

   
   always @(*) begin
      case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = MEM_pcout+IMM;
          `NPC_JUMP:   NPC = MEM_pcout+IMM;
		    `NPC_JALR:	  NPC = aluout+IMM;
          default:     NPC = PCPLUS4;
      endcase
   end // end always
   
endmodule
