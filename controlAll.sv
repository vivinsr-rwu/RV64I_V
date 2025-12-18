`timescale 1ns / 1ps

module controlAll (
    input  logic [31:0] instruction,
    // ALU flags
    input  logic        zero,   // rs1 == rs2
    input  logic        lt,     // rs1 < rs2  (signed)
    input  logic        ltu,    // rs1 < rs2  (unsigned)
    // Control signals outputs
    output logic [4:0]  aluSel,
    output logic        aluSrcA,
    output logic        aluSrcB,
    output logic        dMemWr,
    output logic        dMemRd,
    output logic        PCSrc,
    output logic [1:0]  resultSrc,
    output logic [2:0]  immSrc,
    output logic        regWr,
    output logic        jump,
    // Pipeline 
    output logic        branch_s_o,
    output logic        jump_s_o
);

    // Instruction fields
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    assign opcode = instruction[6:0];
    assign func3  = instruction[14:12];
    assign func7  = instruction[31:25];

    // Control bus
    // { regWr, immSrc[2:0], aluSrcB, aluSrcA, dMemWr, dMemRd, resultSrc[1:0], branch_s, jump_s }
    logic [11:0] controls;
    logic        branch_s;
    logic        jump_s;

    // Main Decoder
    always_comb begin
        // Defaults
        controls = 12'b0;
        aluSel   = 5'b00000;

        case (opcode)

            // I-Type LOAD: LB, LH, LW, LBU, LHU
            //3
            7'b0000011: begin
                controls = 12'b1_000_1_0_0_1_01_0_0;
                aluSel   = 5'b00000; // ADD for address calculation
            end

            // I-type ALU: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            //19
            7'b0010011: begin
                controls = 12'b1_000_1_0_0_0_00_0_0;
                case ({func7, func3})
                    10'b0000000_000: aluSel = 5'b00000; // ADDI
                    10'b0000000_010: aluSel = 5'b01000; // SLTI
                    10'b0000000_011: aluSel = 5'b01001; // SLTIU
                    10'b0000000_100: aluSel = 5'b00100; // XORI
                    10'b0000000_110: aluSel = 5'b00011; // ORI
                    10'b0000000_111: aluSel = 5'b00010; // ANDI
                    10'b0000000_001: aluSel = 5'b00101; // SLLI
                    10'b0000000_101: aluSel = 5'b00110; // SRLI
                    10'b0100000_101: aluSel = 5'b00111; // SRAI
                endcase
            end
            
            // I-type ALU word instructions (RV64)
            //27
            7'b0011011: begin
                controls = 12'b1_000_1_0_0_0_00_0_0; // regWr=1, immSrc=000, aluSrcB=1 ...
                case ({func7[5], func3})
                    10'b0_000: aluSel = 5'b01100; // ADDIW
                    10'b1_000: aluSel = 5'b01011; // SUBIW
                    10'b0_001: aluSel = 5'b01010; // SLLIW
                    10'b0_101: aluSel = 5'b01001; // SRLIW
                    10'b1_101: aluSel = 5'b01000; // SRAIW
                    default:   aluSel = 5'b00000;
                endcase
            end


            // R-type ALU: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            //51
            7'b0110011: begin
                controls = 12'b1_000_0_0_0_0_00_0_0;
                case ({func7, func3})
                    10'b0000000_000: aluSel = 5'b00000; // ADD
                    10'b0100000_000: aluSel = 5'b00001; // SUB
                    10'b0000000_111: aluSel = 5'b00010; // AND
                    10'b0000000_110: aluSel = 5'b00011; // OR
                    10'b0000000_100: aluSel = 5'b00100; // XOR
                    10'b0000000_001: aluSel = 5'b00101; // SLL
                    10'b0000000_101: aluSel = 5'b00110; // SRL
                    10'b0100000_101: aluSel = 5'b00111; // SRA
                    10'b0000000_010: aluSel = 5'b01000; // SLT
                    10'b0000000_011: aluSel = 5'b01001; // SLTU
                endcase
            end

            // STORE: SB, SH, SW
            //35
            7'b0100011: begin
                controls = 12'b0_001_1_0_1_0_00_0_0;
                aluSel   = 5'b00000; // ADD for address
            end

            // B-type BRANCH: BEQ, BNE, BLT, BGE, BLTU, BGEU
            //99
            7'b1100011: begin
                controls = 12'b0_010_0_0_0_0_00_1_0;
                case (func3)
                    3'b000: aluSel = 5'b10000; // BEQ
                    3'b001: aluSel = 5'b10001; // BNE
                    3'b100: aluSel = 5'b10010; // BLT
                    3'b101: aluSel = 5'b10011; // BGE
                    3'b110: aluSel = 5'b10100; // BLTU
                    3'b111: aluSel = 5'b10101; // BGEU
                endcase
            end

            // J-type JAL
            //111
            7'b1101111: begin
                controls = 12'b1_011_1_0_0_0_10_0_1;
            end

            //T-Type JALR
            //103
            7'b1100111: begin
                controls = 12'b1_000_1_0_0_0_10_0_1;
            end

            // U-type: LUI
            //55
            7'b0110111: begin
                controls = 12'b1_100_0_0_0_0_00_0_0; // immSrc = U-type
                aluSel   = 5'b00000; // Pass-through immediate
            end

            // U-type: AUIPC
            //23
            7'b0010111: begin
                controls = 12'b1_101_0_0_0_0_00_0_0; // immSrc = U-type for PC+imm
                aluSel   = 5'b00000; // ALU adds PC + imm
            end

            // R-type WORD (RV64W): ADDW, SUBW, SLLW, SRLW, SRAW
            //59
            7'b0111011: begin
                controls = 12'b1_000_0_0_0_0_00_0_0;
                case (func3)
                    3'b000: aluSel = func7[5] ? 5'b01011 : 5'b01100; // SUBW / ADDW
                    3'b001: aluSel = 5'b01010; // SLLW
                    3'b101: aluSel = func7[5] ? 5'b01000 : 5'b01001; // SRAW / SRLW
                    default: aluSel = 5'b00000;
                endcase
            end

        endcase
    end

    // Control decode
    assign { regWr, immSrc, aluSrcB, aluSrcA, dMemWr, dMemRd, resultSrc, branch_s, jump_s } = controls;

    // Branch decision logic
    logic branch_taken;
    always_comb begin
        branch_taken = 1'b0;
        if (branch_s) begin
            case (func3)
                3'b000: branch_taken =  zero;   // BEQ
                3'b001: branch_taken = ~zero;   // BNE
                3'b100: branch_taken =  lt;     // BLT
                3'b101: branch_taken = ~lt;     // BGE
                3'b110: branch_taken =  ltu;    // BLTU
                3'b111: branch_taken = ~ltu;    // BGEU
            endcase
        end
    end

    // PC control
    assign PCSrc      = branch_taken | jump_s;
    assign branch_s_o = branch_s;
    assign jump_s_o   = jump_s;

    // JALR only
    assign jump = jump_s & (immSrc == 3'b000);

endmodule