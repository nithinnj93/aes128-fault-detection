// AES-128 encryption top: combinational 10-round implementation.
// Packed byte order matches the test vector convention used in this project.
module aes128_top (
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    input  wire [127:0] sbox_fault_mask, // simulation-only fault injection, applied in each round
    output wire [127:0] ciphertext,
    output wire         fault_flag,
    output wire [39:0]  parity_fault_flags
);
    wire [1407:0] round_keys;
    wire [127:0] states [0:10];
    wire [10:1] round_fault_flags;
    wire [3:0] round_parity_flags [1:10];

    aes_key_expansion key_schedule (
        .key(key),
        .round_keys(round_keys)
    );

    assign states[0] = plaintext ^ round_keys[127:0];

    genvar r;
    generate
        for (r = 1; r <= 10; r = r + 1) begin : AES_ROUNDS
            aes_round round_unit (
                .state_in(states[r-1]),
                .round_key(round_keys[r*128 +: 128]),
                .final_round(r == 10),
                .sbox_fault_mask(sbox_fault_mask),
                .state_out(states[r]),
                .fault_flag(round_fault_flags[r]),
                .parity_fault_flags(round_parity_flags[r])
            );
        end
    endgenerate

    assign ciphertext = states[10];

    // Four parity flags per round, across all ten rounds.
    genvar c;
    generate
        for (c = 1; c <= 10; c = c + 1) begin : PARITY_FLAGS
            assign parity_fault_flags[(c-1)*4 +: 4] =
                round_parity_flags[c];
        end
    endgenerate

    // Overall fault flag includes S-box and parity detections.
    assign fault_flag = (|round_fault_flags) |
                        (|parity_fault_flags);
endmodule
