`include "ctrl_encode_def.v"
module PCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
   
    output    mem_w,           // output: memory write signal
    output [31:0] PC_out,      // PC address
    output [31:0] Addr_out,    // ALU output
    output [31:0] Data_out,    // data to data memory
    output [2:0] dm_ctrl
);

    //IF stage
    wire [31:0] NPC;
    wire flush;
    wire stall;

    wire [31:0] MEM_ALUout;
    wire [31:0] MEM_immout;
    wire [31:0] MEM_PC_out;
    wire MEM_zero;

    wire [31:0] selected_pc;

    wire [31:0] EX_immout;
    wire [31:0] EX_PC_out;
    wire [31:0] EX_NPCOp;
    wire [31:0] ALUout;

    mux2 pc_select(
        .select(stall),
        .in_0(NPC),
        .in_1(PC_out),
        .out(selected_pc)
    );

    // instantiation of PC unit
    PC U_PC(
        .clk(clk),
        .rst(reset),
        .NPC(selected_pc),
        .PC(PC_out)
    );


    // instantiation of NPC unit
    NPC U_NPC(
        .PC(PC_out), 
        .NPCOp(EX_NPCOp), 
        .IMM(EX_immout), 
        .NPC(NPC), 
        .aluout(ALUout),
        .MEM_pcout(EX_PC_out)
    );

    wire [31:0] IF_inst;

    wire [31:0] ID_inst;

    mux2 inst_select(
        .select(stall),
        .in_0(inst_in),
        .in_1(ID_inst),
        .out(IF_inst)
    );

    // IF_ID register
    wire [31:0] ID_PC_out;

    IF_ID U_IF_ID(
        .Clk(clk),
        .Rst(reset),
        .flush(flush), 
        .IF_ID_PC_in(PC_out), .ID_PC_out(ID_PC_out),
        .IF_ID_inst_in(IF_inst), .ID_inst(ID_inst)
    );

    //ID stage

    // generate control signals
    wire [6:0] opcode; 
    assign opcode = ID_inst[6:0];

    wire [6:0] funct7; 
    assign funct7 = ID_inst[31:25];

    wire [2:0] funct3; 
    assign funct3 = ID_inst[14:12];

    wire [31:0] ctrl_signals;

    // instantiation of ctrl unit
    ctrl U_ctrl(
        .Op(opcode),
        .Funct7(funct7),
        .Funct3(funct3),
        .RegWrite(ctrl_signals[0]),
        .MemWrite(ctrl_signals[1]),
        .EXTOp(ctrl_signals[7:2]),
        .ALUOp(ctrl_signals[12:8]),
        .NPCOp(ctrl_signals[15:13]),
        .ALUSrc(ctrl_signals[16]),
        .dm_ctrl(ctrl_signals[19:17]),
        .GPRSel(ctrl_signals[21:20]),
        .WDSel(ctrl_signals[23:22])
    );
    
    
    wire [31:0] RD1;
    wire [31:0] RD2;

    wire [4:0] rs1; 
    assign rs1 = ID_inst[19:15];

    wire [4:0] rs2; 
    assign rs2 = ID_inst[24:20];

    wire [4:0] rd; 
    assign rd = ID_inst[11:7];

    wire [4:0] wrdtadr; // from WB stage
    wire [31:0] wrdt;
    wire regwrite;

    // instantiation of RF unit
    RF U_RF(
        .clk(clk),
        .rst(reset),
        .RegWrite(regwrite),
        .rs1(rs1),
        .rs2(rs2),
        .WriteReg(wrdtadr),
        .WriteData(wrdt),
        .ReadData1(RD1),
        .ReadData2(RD2)
    );

    // immediate generation
    wire [4:0] iimm_shamt; 
    assign iimm_shamt = ID_inst[24:20];

    wire [11:0] iimm; 
    assign iimm = ID_inst[31:20];

    wire [11:0] simm; 
    assign simm = {ID_inst[31:25], ID_inst[11:7]};

    wire [11:0] sbimm; 
    assign sbimm = {ID_inst[31], ID_inst[7], ID_inst[30:25], ID_inst[11:8]};

    wire [19:0] uimm; 
    assign uimm = ID_inst[31:12];

    wire [19:0] ujimm; 
    assign ujimm = {ID_inst[31], ID_inst[19:12], ID_inst[20], ID_inst[30:21]};

    wire [31:0] immout;

    wire [5:0] EXTOp; 
    assign EXTOp = ctrl_signals[7:2];

    // instantiation of EXT unit
    EXT U_EXT(
        .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        .sbimm(sbimm),
        .uimm(uimm),
        .ujimm(ujimm),
        .EXTOp(EXTOp),
        .immout(immout)
    );

    wire [4:0] EX_rd; 

    // instantiation of Hazard detection unit
    Hazard U_Hazard(
        .ID_EX_MR(EX_signals[22]),
        .ID_EX_rd(EX_rd),
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .stall(stall)
    );

    wire [31:0] signals_out;

    // nop
    mux2 signals_nop_select(
        .select(stall),
        .in_0(ctrl_signals),
        .in_1(32'b0),
        .out(signals_out)
    );

    // ID/EX register
    wire [31:0] EX_RD1;
    wire [31:0] EX_RD2;
    wire [31:0] EX_signals;
    wire [4:0] EX_rs1;
    wire [4:0] EX_rs2;

    ID_EX U_ID_EX(
        .Clk(clk),
        .Rst(reset),
        .flush(flush),
        .ID_EX_PC_in(ID_PC_out), .EX_PC_out(EX_PC_out),
        .ID_EX_rs1_in(rs1), .EX_rs1(EX_rs1),
        .ID_EX_rs2_in(rs2), .EX_rs2(EX_rs2),
        .ID_EX_rd_in(rd), .EX_rd(EX_rd),
        .ID_EX_ctrlsignals_in(signals_out), .EX_signals(EX_signals),
        .ID_EX_RD1_in(RD1), .EX_RD1(EX_RD1),
        .ID_EX_RD2_in(RD2), .EX_RD2(EX_RD2),
        .ID_EX_immout_in(immout), .EX_immout(EX_immout)
    );


    //EX stage
    wire [31:0] WB_signals; 
    wire [31:0] MEM_signals;
    wire [4:0] MEM_rd;
    wire [4:0] WB_rd;

    // ALU

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    wire [31:0] A;
    wire [31:0] B; 

    mux3 A_select(
        .select(ForwardA),
        .in_0(EX_RD1),
        .in_1(wrdt),
        .in_2(MEM_ALUout),
        .out(A)
    );


    wire [31:0] Real_RD2;

    mux3 B_select1(
        .select(ForwardB),
        .in_0(EX_RD2),
        .in_1(wrdt),
        .in_2(MEM_ALUout),
        .out(Real_RD2)
    );

    mux2 B_select2(
        .select(EX_signals[16]),
        .in_0(Real_RD2),
        .in_1(EX_immout),
        .out(B)
    );

    wire EX_zero;

    // instantiation of alu unit
    alu U_alu(
        .A(A),
        .B(B),
        .ALUOp(EX_signals[12:8]),
        .C(ALUout),
        .PC(EX_PC_out),
        .Zero(EX_zero)
    );

    // instantiation of Forwarding unit
    Forward U_Forward(
        .ID_EX_rs1(EX_rs1),
        .ID_EX_rs2(EX_rs2),
        .EX_MEM_rd(MEM_rd),
        .MEM_WB_rd(WB_rd),
        .EX_MEM_WB(MEM_signals[0]),
        .MEM_WB_WB(WB_signals[0]),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );


    // EX/MEM register
    wire [31:0] MEM_RD1;
    wire [31:0] MEM_RD2;
    
    EX_MEM U_EX_MEM(
        .Clk(clk),
        .Rst(reset),
        .flush(0),
        .EX_MEM_PC_in(EX_PC_out), .MEM_PC_out(MEM_PC_out),
        .EX_MEM_rd_in(EX_rd), .MEM_rd(MEM_rd),
        .EX_MEM_signals_in(EX_signals), .MEM_signals(MEM_signals),
        .EX_MEM_RD1_in(EX_RD1), .MEM_RD1(MEM_RD1),
        .EX_MEM_rRD2_in(Real_RD2), .MEM_RD2(MEM_RD2),
        .EX_MEM_ALUout_in(ALUout), .MEM_ALUout(MEM_ALUout),
        .EX_MEM_zero(EX_zero), .MEM_zero(MEM_zero),
        .EX_MEM_immout_in(EX_immout), .MEM_immout(MEM_immout)
    );

    assign branch = EX_zero & EX_signals[13]; //SBTYPE

    assign EX_NPCOp = {EX_signals[15:14], branch};

    assign flush = (EX_NPCOp == 0) ? 0 : 1;
 
    //MEM stage

    // data memory
    assign Addr_out = MEM_ALUout;
    assign Data_out = MEM_RD2;
    assign dm_ctrl = MEM_signals[19:17];

    wire [31:0] rd_data; 
    assign rd_data = Data_in;

    assign mem_w = MEM_signals[1];

    wire [31:0] WB_PC_out;
    wire [31:0] WB_RD1;
    wire [31:0] WB_B;
    wire [31:0] WB_rd_data;
    wire [31:0] WB_ALUout;


    //MEM_WB register
    MEM_WB U_MEM_WB(
        .Clk(clk),
        .Rst(reset),
        .flush(0),
        .MEM_WB_PC_in(MEM_PC_out), .WB_PC_out(WB_PC_out),
        .MEM_WB_ALUout_in(MEM_ALUout), .WB_ALUout(WB_ALUout),
        .MEM_WB_signals_in(MEM_signals), .WB_signals(WB_signals),
        .MEM_WB_RD1_in(MEM_RD1), .WB_RD1(WB_RD1),
        .MEM_WB_RD2_in(MEM_RD2), .WB_RD2(WB_RD2),
        .MEM_WB_rddata_in(rd_data), .WB_rd_data(WB_rd_data),
        .MEM_WB_rd_in(MEM_rd), .WB_rd(WB_rd)
    );

    //WB stage
    wire [1:0] WB_WDSel; 
    assign regwrite = WB_signals[0];
    assign wrdtadr = WB_rd;
    assign WB_WDSel = WB_signals[23:22];

    mux3 wrdt_select(
        .select(WB_WDSel),
        .in_0(WB_ALUout),
        .in_1(WB_rd_data),
        .in_2(WB_PC_out + 4),
        .out(wrdt)
    );


endmodule