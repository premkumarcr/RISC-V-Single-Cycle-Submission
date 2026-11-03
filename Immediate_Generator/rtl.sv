module imm_generator(
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);
    always_comb begin
        case (opcode)
            7'b1100011: // B-type: sign-extend the encoded 12 bits, then shift left once.
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};
            7'b1101111: // J-type: sign-extend the encoded 20 bits, then shift left once.
                imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};
            7'b0110111, 7'b0010111: // U-type
                imm_output = {imm_input_uj, 12'b0};
            7'b0010011: begin // I-type ALU
                if ((fn3 == 3'b001) || (fn3 == 3'b101))
                    imm_output = {27'b0, imm_input[4:0]};
                else
                    imm_output = {{20{imm_input[11]}}, imm_input};
            end
            default: // Loads, stores, JALR and other immediate consumers.
                imm_output = {{20{imm_input[11]}}, imm_input};
        endcase
    end
endmodule
