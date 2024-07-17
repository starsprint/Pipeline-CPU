 //`include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3,
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,dm_ctrl
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   // input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [2:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for A
   output [2:0] dm_ctrl;
   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection

  // r format
    wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011 �???1时指令为R型，�???0时则不是R�???

    wire r_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add Funct7: 0000000 Funct3: 000
    wire r_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub Funct7: 0100000 Funct3: 000
    wire r_sll  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]& Funct3[0]; // sll Funct7: 0000000 Funct3: 001
    wire r_slt  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]&~Funct3[0]; // slt Funct7: 0000000 Funct3: 010
    wire r_sltu  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]& Funct3[0]; // sltu Funct7: 0000000 Funct3: 011
    wire r_xor  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]&~Funct3[0]; // xor Funct7: 0000000 Funct3: 100
    wire r_srl  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srl Funct7: 0000000 Funct3: 101
    wire r_sra  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // sra Funct7: 0100000 Funct3: 101
    wire r_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or Functt7: 0000000 Funct3: 110
    wire r_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and Funct7: 0000000 Funct3: 111
    

 // i format
   wire itype_1  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011

   wire i1_lb  = itype_1& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // lb Funct3: 000
   wire i1_lh  = itype_1& ~Funct3[2]&~Funct3[1]& Funct3[0]; // lh Funct3: 001
   wire i1_lw  = itype_1& ~Funct3[2]& Funct3[1]&~Funct3[0]; // lw Funct3: 010
   wire i1_lbu  = itype_1&  Funct3[2]&~Funct3[1]&~Funct3[0]; // lbu Funct3: 100
   wire i1_lhu  = itype_1&  Funct3[2]&~Funct3[1]& Funct3[0]; // lhu Funct3: 101

   wire itype_2  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011

   wire i2_addi  =  itype_2& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi Funct3: 000
   wire i2_slli  =  itype_2&  ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& ~Funct3[2]& ~Funct3[1]&  Funct3[0]; // slli Funct7: 0000000 Funct3: 001
   wire i2_slti  =  itype_2& ~Funct3[2]&  Funct3[1]& ~Funct3[0]; // slti Funct3: 010
   wire i2_sltiu  =  itype_2& ~Funct3[2]&  Funct3[1]&  Funct3[0]; // sltiu Funct3: 011
   wire i2_xori  =  itype_2&  Funct3[2]& ~Funct3[1]& ~Funct3[0]; // xori Funct3: 100
   wire i2_srli  =  itype_2&  ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]&  Funct3[0]; // srli Funct7: 0000000 Funct3: 101
   wire i2_srai  =  itype_2&  ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& ~Funct3[1]&  Funct3[0]; // srai Funct7: 0100000 Funct3: 101
   wire i2_ori  =  itype_2& Funct3[2]& Funct3[1]&~Funct3[0]; // ori Funct3: 110
	 wire i2_andi  =  itype_2&  Funct3[2]&  Funct3[1]&  Funct3[0]; // andi Funct3: 111

	 wire i_jalr = Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; //jalr OPCODE: 1100111

  // u format
  wire u_auipc  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; // auipc OPCODE: 0010111
  wire u_lui  = ~Op[6]&Op[5]&Op[4]&~Op[3]&Op[2]&Op[1]&Op[0]; // lui OPCODE: 0110111

  // s format
   wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011

   wire s_sb   =  stype& ~Funct3[2]&~Funct3[1]&~Funct3[0]; // sb Funct3: 000
   wire s_sh   =  stype& ~Funct3[2]&~Funct3[1]& Funct3[0]; // sh Funct3: 001
   wire s_sw   =  stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw Funct3: 010

  // sb format
   wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011

   wire sb_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq Funct3: 000
   wire sb_bne  = sbtype& ~Funct3[2]& ~Funct3[1]& Funct3[0]; // bne Funct3: 001
   wire sb_blt  = sbtype&  Funct3[2]& ~Funct3[1]&~Funct3[0]; // blt Funct3: 100
   wire sb_bge  = sbtype&  Funct3[2]& ~Funct3[1]& Funct3[0]; // bge Funct3: 101
   wire sb_bltu  = sbtype&  Funct3[2]&  Funct3[1]&~Funct3[0]; // bltu Funct3: 110
   wire sb_bgeu  = sbtype&  Funct3[2]&  Funct3[1]& Funct3[0]; // bgeu Funct3: 111
	
 // uj format
   wire uj_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111

  // generate control signals
  assign RegWrite   = rtype | itype_1 | itype_2 | i_jalr | uj_jal | u_auipc | u_lui; // register write
  assign MemWrite   = stype;                           // memory write
  assign ALUSrc     = itype_1 | itype_2 | stype | uj_jal | i_jalr | u_lui | u_auipc;   // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = i2_slli | i2_srai | i2_srli;
  assign EXTOp[4] = (itype_1 | itype_2 | i_jalr) & ~ (i2_slli | i2_srai | i2_srli);  
  assign EXTOp[3] = stype; 
  assign EXTOp[2] = sbtype; 
  assign EXTOp[1] = u_auipc | u_lui;   
  assign EXTOp[0] = uj_jal;         


  
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_1;
  assign WDSel[1] = uj_jal | i_jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	   3'b100

  // assign NPCOp[0] = sbtype & Zero;
  assign NPCOp[0] = sbtype;
  assign NPCOp[1] = uj_jal;
  assign NPCOp[2] = i_jalr;
  

  //ALUOp分类

  assign ALUOp[0] = u_lui | (r_add | itype_1 | stype | i2_addi) | sb_bne | sb_bge | sb_bgeu | (r_sltu | i2_sltiu) | (r_or | i2_ori) | (r_sll | i2_slli) | (r_sra | i2_srai);
  assign ALUOp[1] = u_auipc | (r_add | itype_1 | stype | i2_addi) | sb_blt | sb_bge | (r_slt | i2_slti) |  (r_sltu | i2_sltiu) | (r_and | i2_andi) | (r_sll | i2_slli);
  assign ALUOp[2] = (r_sub | sb_beq) | sb_bne | sb_blt | sb_bge | (r_xor | i2_xori) | (r_or | i2_ori) | (r_and | i2_andi) | (r_sll | i2_slli);
  assign ALUOp[3] = sb_bltu | sb_bgeu | (r_slt | i2_slti) | (r_sltu | i2_sltiu) | (r_xor | i2_xori) | (r_or | i2_ori) | (r_and | i2_andi) | (r_sll | i2_slli);
  assign ALUOp[4] = (r_srl | i2_srli) | (r_sra | i2_srai);

  //dm_ctrl
  assign dm_ctrl[0] = i1_lb | s_sb | i1_lh | s_sh;
  assign dm_ctrl[1] = i1_lhu | i1_lb | s_sb;
  assign dm_ctrl[2] = i1_lbu;
  
endmodule
