// Simulation-oriented round-output parity checker.
// Assumption: round_result is the trusted pre-injection round output.
// A post-round XOR mask models a fault on the transmitted round state.
// The per-byte parity relation is P(received byte) = P(expected byte).
// This is NOT an independent predictor of the internal MixColumns logic.
module aes_round_parity (
    input wire [127:0] round_result,
    input wire [127:0] round_fault_mask,
    output wire [127:0] checked_state,
    output wire parity_fault_flag
);
    wire [15:0] mismatch;
    assign checked_state = round_result ^ round_fault_mask;
    genvar b;
    generate for (b=0; b<16; b=b+1) begin: PARITY_BYTES
        assign mismatch[b] = (^round_result[b*8 +: 8]) ^ (^checked_state[b*8 +: 8]);
    end endgenerate
    assign parity_fault_flag = |mismatch;
endmodule
