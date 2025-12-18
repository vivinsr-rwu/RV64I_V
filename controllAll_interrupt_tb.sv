`timescale 1ns / 1ps

module tb_controlAll;

    // Inputs
    logic [31:0] instruction;
    logic        zero;
    logic        lt;
    logic        ltu;
    logic        irq_in;  // added for interrupt

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
    logic        irq_out; // added for interrupt
    logic        trap;    // added for interrupt

    // DUT
    controlAll_interrupt dut (
        .instruction (instruction),
        .zero        (zero),
        .lt          (lt),
        .ltu         (ltu),
        .irq_in      (irq_in),    
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
        .jump_s_o    (jump_s_o),
        .irq_out     (irq_out),   
        .trap        (trap)      
    );

    // Display task
    task show(input int id, input string name);
        begin
            $display("\n=================================================");
            $display("[TEST %0d] %s", id, name);
            $display("instruction = %032b", instruction);
            $display("opcode      = %07b", instruction[6:0]);
            $display("func3       = %03b", instruction[14:12]);
            $display("func7       = %07b", instruction[31:25]);
            $display("-------------------------------------------------");
            $display("regWr=%0d aluSel=%05b aluSrcA=%0d aluSrcB=%0d",
                     regWr, aluSel, aluSrcA, aluSrcB);
            $display("dMemWr=%0d dMemRd=%0d resultSrc=%02b immSrc=%03b",
                     dMemWr, dMemRd, resultSrc, immSrc);
            $display("branch_s=%0d jump_s=%0d PCSrc=%0d jump=%0d",
                     branch_s_o, jump_s_o, PCSrc, jump);
            $display("=================================================");
        end
    endtask

    // Test sequence
    initial begin
        zero = 0; lt = 0; ltu = 0; irq_in = 0;

        // I-Type LOAD instructions
        instruction = 32'b000000000000_00001_000_00010_0000011; #10; show(1, "LB");
        instruction = 32'b000000000000_00001_001_00010_0000011; #10; show(2, "LH");
        instruction = 32'b000000000000_00001_010_00010_0000011; #10; show(3, "LW");
        instruction = 32'b000000000000_00001_011_00010_0000011; #10; show(4, "LD");
        instruction = 32'b000000000000_00001_100_00010_0000011; #10; show(5, "LBU");
        instruction = 32'b000000000000_00001_101_00010_0000011; #10; show(6, "LHU");
        instruction = 32'b000000000000_00001_110_00010_0000011; #10; show(7, "LWU");

        // I-type ALU instructions
        instruction = 32'b000000000001_00001_000_00010_0010011; #10; show(8, "ADDI");
        instruction = 32'b000000000001_00001_010_00010_0010011; #10; show(9, "SLTI");
        instruction = 32'b000000000001_00001_011_00010_0010011; #10; show(10, "SLTIU");
        instruction = 32'b000000000001_00001_100_00010_0010011; #10; show(11, "XORI");
        instruction = 32'b000000000001_00001_110_00010_0010011; #10; show(12, "ORI");
        instruction = 32'b000000000001_00001_111_00010_0010011; #10; show(13, "ANDI");
        instruction = 32'b0000000_00001_00001_001_00010_0010011; #10; show(14, "SLLI");
        instruction = 32'b0000000_00001_00001_101_00010_0010011; #10; show(15, "SRLI");
        instruction = 32'b0100000_00001_00001_101_00010_0010011; #10; show(16, "SRAI");
        
        //I-type W 64-bit instructions (ADDIW, SLLIW, SRLIW, SRAIW)
        instruction = 32'b000000000001_00001_000_00010_0011011; #10; show(17, "ADDIW");
        instruction = 32'b0000000_00001_00001_001_00010_0011011; #10; show(18, "SLLIW");
        instruction = 32'b0000000_00001_00001_101_00010_0011011; #10; show(19, "SRLIW");
        instruction = 32'b0100000_00001_00001_101_00010_0011011; #10; show(20, "SRAIW");
        
        // R-type ALU instructions
        instruction = 32'b0000000_00010_00001_000_00011_0110011; #10; show(21, "ADD");
        instruction = 32'b0100000_00010_00001_000_00011_0110011; #10; show(22, "SUB");
        instruction = 32'b0000000_00010_00001_001_00011_0110011; #10; show(23, "SLL");
        instruction = 32'b0000000_00010_00001_010_00011_0110011; #10; show(24, "SLT");
        instruction = 32'b0000000_00010_00001_011_00011_0110011; #10; show(25, "SLTU");
        instruction = 32'b0000000_00010_00001_100_00011_0110011; #10; show(26, "XOR");
        instruction = 32'b0000000_00010_00001_101_00011_0110011; #10; show(27, "SRL");
        instruction = 32'b0100000_00010_00001_101_00011_0110011; #10; show(28, "SRA");
        instruction = 32'b0000000_00010_00001_110_00011_0110011; #10; show(29, "OR");
        instruction = 32'b0000000_00010_00001_111_00011_0110011; #10; show(30, "AND");

        // S-Type STORE instructions
        instruction = 32'b0000000_00010_00001_000_00000_0100011; #10; show(31, "SB");
        instruction = 32'b0000000_00010_00001_001_00000_0100011; #10; show(32, "SH");
        instruction = 32'b0000000_00010_00001_010_00000_0100011; #10; show(33, "SW");
        instruction = 32'b0000000_00010_00001_011_00000_0100011; #10; show(34, "SD");
        
        //B-Type BRANCH instructions
        zero = 1; instruction = 32'b0000000_00010_00001_000_00000_1100011; #10; show(35, "BEQ");
        zero = 0; instruction = 32'b0000000_00010_00001_001_00000_1100011; #10; show(36, "BNE");
        lt   = 1; instruction = 32'b0000000_00010_00001_100_00000_1100011; #10; show(37, "BLT");
        lt   = 0; instruction = 32'b0000000_00010_00001_101_00000_1100011; #10; show(38, "BGE");
        ltu  = 1; instruction = 32'b0000000_00010_00001_110_00000_1100011; #10; show(39, "BLTU");
        ltu  = 0; instruction = 32'b0000000_00010_00001_111_00000_1100011; #10; show(40, "BGEU");

        // J-Tyoe and I-Type JUMP instructions
        instruction = 32'b00000000000000000000_00001_1101111; #10; show(41, "JAL");
        instruction = 32'b000000000001_00001_000_00010_1100111; #10; show(42, "JALR");
        
        // R-Type W 64-bit instructions
        instruction = 32'b0000000_00010_00001_000_00011_0111011; #10; show(43, "ADDW");
        instruction = 32'b0100000_00010_00001_000_00011_0111011; #10; show(44, "SUBW");
        instruction = 32'b0000000_00010_00001_001_00011_0111011; #10; show(45, "SLLW");
        instruction = 32'b0000000_00010_00001_101_00011_0111011; #10; show(46, "SRLW");
        instruction = 32'b0100000_00010_00001_101_00011_0111011; #10; show(47, "SRAW");

        // U-type instructions
        instruction = 32'b00000000000100000000_00010_0110111; #10; show(48, "LUI");
        instruction = 32'b00000000000100000000_00010_0010111; #10; show(49, "AUIPC");

        //INTERRUPT TEST
        instruction = 32'b0000000_00010_00001_000_00011_0110011; // a normal instruction
        irq_in = 1; #10;
        $display("\n=================================================");
        $display("[TEST %0d] INTERRUPT TEST", 50);
        $display("instruction = %032b", instruction);
        $display("irq_in      = %0d", irq_in);
        $display("irq_out     = %0d", irq_out);
        $display("trap        = %0d", trap);
        $display("PCSrc       = %0d", PCSrc);
        $display("=================================================");
        irq_in = 0; #10; // clear interrupt

        $display("\n===== ALL DECODER TESTS COMPLETED SUCCESSFULLY =====");
        $finish;
    end

endmodule