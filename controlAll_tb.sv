`timescale 1ns / 1ps

module tb_controlAll;

    // Inputs
    logic [31:0] instruction;
    logic        zero;
    logic        lt;
    logic        ltu;

    // Outputs
    logic [4:0]  aluSel;
    logic        aluSrcA;
    logic        aluSrcB;
    logic        dMemWr;
    logic        dMemRd;
    logic        PCSrc;
    logic [1:0]  resultSrc;
    logic [2:0]  immSrc;
    logic        regWr;
    logic        jump;
    logic        branch_s_o;
    logic        jump_s_o;

    // DUT
    controlAll dut (
        .instruction (instruction),
        .zero        (zero),
        .lt          (lt),
        .ltu         (ltu),
        .aluSel      (aluSel),
        .aluSrcA     (aluSrcA),
        .aluSrcB     (aluSrcB),
        .dMemWr      (dMemWr),
        .dMemRd      (dMemRd),
        .PCSrc       (PCSrc),
        .resultSrc   (resultSrc),
        .immSrc      (immSrc),
        .regWr       (regWr),
        .jump        (jump),
        .branch_s_o  (branch_s_o),
        .jump_s_o    (jump_s_o)
    );

    // Expected signals structure
    typedef struct {
        logic [4:0]  aluSel;
        logic        aluSrcA;
        logic        aluSrcB;
        logic        dMemWr;
        logic        dMemRd;
        logic        PCSrc;
        logic [1:0]  resultSrc;
        logic [2:0]  immSrc;
        logic        regWr;
        logic        jump;
        logic        branch_s_o;
        logic        jump_s_o;
    } control_signals_t;

    // Task to check outputs
    task check(input int id, input string name, input control_signals_t expected);
        begin
            $display("\n=================================================");
            $display("[TEST %0d] %s", id, name);
            $display("Instruction = %032b", instruction);

            $display("ACTUAL  : aluSel=%05b aluSrcA=%0d aluSrcB=%0d dMemWr=%0d dMemRd=%0d PCSrc=%0d resultSrc=%02b immSrc=%03b regWr=%0d jump=%0d branch_s=%0d jump_s=%0d",
                     aluSel, aluSrcA, aluSrcB, dMemWr, dMemRd, PCSrc, resultSrc, immSrc, regWr, jump, branch_s_o, jump_s_o);

            $display("EXPECTED: aluSel=%05b aluSrcA=%0d aluSrcB=%0d dMemWr=%0d dMemRd=%0d PCSrc=%0d resultSrc=%02b immSrc=%03b regWr=%0d jump=%0d branch_s=%0d jump_s=%0d",
                     expected.aluSel, expected.aluSrcA, expected.aluSrcB, expected.dMemWr, expected.dMemRd, expected.PCSrc, expected.resultSrc, expected.immSrc, expected.regWr, expected.jump, expected.branch_s_o, expected.jump_s_o);

            if (aluSel     !== expected.aluSel ||
                aluSrcA    !== expected.aluSrcA ||
                aluSrcB    !== expected.aluSrcB ||
                dMemWr     !== expected.dMemWr ||
                dMemRd     !== expected.dMemRd ||
                PCSrc      !== expected.PCSrc ||
                resultSrc  !== expected.resultSrc ||
                immSrc     !== expected.immSrc ||
                regWr      !== expected.regWr ||
                jump       !== expected.jump ||
                branch_s_o !== expected.branch_s_o ||
                jump_s_o   !== expected.jump_s_o) begin
                $display(">>>> FAILED <<<<");
            end else begin
                $display(">>>> PASSED <<<<");
            end

            $display("=================================================");
        end
    endtask


    // Task to apply instruction and expected signals
    task apply(input int id, input string name, input [31:0] instr, input control_signals_t expected);
        begin
            instruction = instr;
            #10;
            check(id, name, expected);
        end
    endtask

    // Test sequence
    initial begin
        zero = 0; lt = 0; ltu = 0;

        // -----------------------------
        // I-Type LOAD
        apply(1, "LB",  32'b000000000000_00001_000_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(2, "LH",  32'b000000000000_00001_001_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(3, "LW",  32'b000000000000_00001_010_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(4, "LD",  32'b000000000000_00001_011_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(5, "LBU", 32'b000000000000_00001_100_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(6, "LHU", 32'b000000000000_00001_101_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});
        apply(7, "LWU", 32'b000000000000_00001_110_00010_0000011, '{5'b00000,0,1,0,1,0,2'b01,3'b000,1,0,0,0});

        // -----------------------------
        // I-Type ALU
        apply(8,  "ADDI", 32'b000000000001_00001_000_00010_0010011, '{5'b00000,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(9,  "SLTI", 32'b000000000001_00001_010_00010_0010011, '{5'b01000,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(10, "SLTIU",32'b000000000001_00001_011_00010_0010011, '{5'b01001,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(11, "XORI", 32'b000000000001_00001_100_00010_0010011, '{5'b00100,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(12, "ORI",  32'b000000000001_00001_110_00010_0010011, '{5'b00011,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(13, "ANDI", 32'b000000000001_00001_111_00010_0010011, '{5'b00010,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(14, "SLLI", 32'b0000000_00001_00001_001_00010_0010011, '{5'b00101,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(15, "SRLI", 32'b0000000_00001_00001_101_00010_0010011, '{5'b00110,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(16, "SRAI", 32'b0100000_00001_00001_101_00010_0010011, '{5'b00111,0,1,0,0,0,2'b00,3'b000,1,0,0,0});

        // -----------------------------
        // I-Type W
        apply(17, "ADDIW",32'b000000000001_00001_000_00010_0011011, '{5'b01100,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(18, "SLLIW",32'b0000000_00001_00001_001_00010_0011011, '{5'b01010,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(19, "SRLIW",32'b0000000_00001_00001_101_00010_0011011, '{5'b01001,0,1,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(20, "SRAIW",32'b0100000_00001_00001_101_00010_0011011, '{5'b01000,0,1,0,0,0,2'b00,3'b000,1,0,0,0});

        // -----------------------------
        // R-Type ALU
        apply(21, "ADD",  32'b0000000_00010_00001_000_00011_0110011, '{5'b00000,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(22, "SUB",  32'b0100000_00010_00001_000_00011_0110011, '{5'b00001,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(23, "SLL",  32'b0000000_00010_00001_001_00011_0110011, '{5'b00101,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(24, "SLT",  32'b0000000_00010_00001_010_00011_0110011, '{5'b01000,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(25, "SLTU", 32'b0000000_00010_00001_011_00011_0110011, '{5'b01001,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(26, "XOR",  32'b0000000_00010_00001_100_00011_0110011, '{5'b00100,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(27, "SRL",  32'b0000000_00010_00001_101_00011_0110011, '{5'b00110,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(28, "SRA",  32'b0100000_00010_00001_101_00011_0110011, '{5'b00111,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(29, "OR",   32'b0000000_00010_00001_110_00011_0110011, '{5'b00011,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(30, "AND",  32'b0000000_00010_00001_111_00011_0110011, '{5'b00010,0,0,0,0,0,2'b00,3'b000,1,0,0,0});

        // -----------------------------
        // S-Type STORE
        apply(31, "SB", 32'b0000000_00010_00001_000_00000_0100011, '{5'b00000,0,1,1,0,0,2'b00,3'b001,0,0,0,0});
        apply(32, "SH", 32'b0000000_00010_00001_001_00000_0100011, '{5'b00000,0,1,1,0,0,2'b00,3'b001,0,0,0,0});
        apply(33, "SW", 32'b0000000_00010_00001_010_00000_0100011, '{5'b00000,0,1,1,0,0,2'b00,3'b001,0,0,0,0});
        apply(34, "SD", 32'b0000000_00010_00001_011_00000_0100011, '{5'b00000,0,1,1,0,0,2'b00,3'b001,0,0,0,0});
        
        // -----------------------------
        // B-Type BRANCH
        zero = 1; apply(35,"BEQ",  32'b0000000_00010_00001_000_00000_1100011, '{5'b10000,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        zero = 0; apply(36,"BNE",  32'b0000000_00010_00001_001_00000_1100011, '{5'b10001,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        lt   = 1; apply(37,"BLT",  32'b0000000_00010_00001_100_00000_1100011, '{5'b10010,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        lt   = 0; apply(38,"BGE",  32'b0000000_00010_00001_101_00000_1100011, '{5'b10011,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        ltu  = 1; apply(39,"BLTU", 32'b0000000_00010_00001_110_00000_1100011, '{5'b10100,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        ltu  = 0; apply(40,"BGEU", 32'b0000000_00010_00001_111_00000_1100011, '{5'b10101,1,0,0,0,1,2'b00,3'b010,0,0,1,0});
        
        // -----------------------------
        // J-Type / JALR
        apply(41, "JAL", 32'b00000000000000000000_00001_1101111, '{5'b00000,1,1,0,0,1,2'b10,3'b011,1,0,0,1});
        apply(42, "JALR",32'b000000000001_00001_000_00010_1100111, '{5'b00000,0,1,0,0,1,2'b10,3'b000,1,1,0,1});
        
        // -----------------------------
        // R-Type W
        apply(43, "ADDW",32'b0000000_00010_00001_000_00011_0111011, '{5'b01100,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(44, "SUBW",32'b0100000_00010_00001_000_00011_0111011, '{5'b01011,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(45, "SLLW",32'b0000000_00010_00001_001_00011_0111011, '{5'b01010,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(46, "SRLW",32'b0000000_00010_00001_101_00011_0111011, '{5'b01001,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        apply(47, "SRAW",32'b0100000_00010_00001_101_00011_0111011, '{5'b01000,0,0,0,0,0,2'b00,3'b000,1,0,0,0});
        
        // -----------------------------
        // U-Type
        apply(48, "LUI",  32'b00000000000100000000_00010_0110111, '{5'b00000,0,0,0,0,0,2'b00,3'b100,1,0,0,0});
        apply(49, "AUIPC",32'b00000000000100000000_00010_0010111, '{5'b00000,1,0,0,0,0,2'b00,3'b101,1,0,0,0});


        $display("\n--------- ALL 49 TESTCASES EVALUATED --------");
        $finish;

    end

endmodule
