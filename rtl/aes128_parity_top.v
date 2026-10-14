// Ten-round AES-128 with S-box fault checks and round-output parity checks.
// Both fault masks are simulation-only. Masks are applied at every round.
module aes128_parity_top (
    input wire [127:0] plaintext,
    input wire [127:0] key,
    input wire [127:0] sbox_fault_mask,
    input wire [127:0] round_fault_mask,
    output wire [127:0] ciphertext,
    output wire sbox_fault_flag,
    output wire parity_fault_flag,
    output wire fault_flag
);
    wire [1407:0] round_keys;
    wire [127:0] states [0:10];
    wire [127:0] raw_states [1:10];
    wire [10:1] sbox_flags, parity_flags;
    aes_key_expansion ks (.key(key), .round_keys(round_keys));
    assign states[0] = plaintext ^ round_keys[127:0];
    genvar r;
    generate for (r=1; r<=10; r=r+1) begin: ROUNDS
        aes_round enc (
            .state_in(states[r-1]), .round_key(round_keys[r*128 +: 128]),
            .final_round(r==10), .sbox_fault_mask(sbox_fault_mask),
            .state_out(raw_states[r]), .fault_flag(sbox_flags[r])
        );
        aes_round_parity parity (
            .round_result(raw_states[r]), .round_fault_mask(round_fault_mask),
            .checked_state(states[r]), .parity_fault_flag(parity_flags[r])
        );
    end endgenerate
    assign ciphertext = states[10];
    assign sbox_fault_flag = |sbox_flags;
    assign parity_fault_flag = |parity_flags;
    assign fault_flag = sbox_fault_flag | parity_fault_flag;
endmodule
