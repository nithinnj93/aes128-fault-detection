module aes_round_parity_predictor (
    input  wire [127:0] state_after_shiftrows,
    input  wire [127:0] round_key,
    input  wire [127:0] actual_round_out,
    output wire [3:0]   fault_flag
);

    wire [31:0] p_sh;
    wire [31:0] p_rk;
    wire [31:0] p_out;
    wire [31:0] p_expected;

    // Column 0: bytes 0, 1, 2, 3
    assign p_sh[7:0] =
        state_after_shiftrows[127:120] ^
        state_after_shiftrows[119:112] ^
        state_after_shiftrows[111:104] ^
        state_after_shiftrows[103:96];

    // Column 1: bytes 4, 5, 6, 7
    assign p_sh[15:8] =
        state_after_shiftrows[95:88] ^
        state_after_shiftrows[87:80] ^
        state_after_shiftrows[79:72] ^
        state_after_shiftrows[71:64];

    // Column 2: bytes 8, 9, 10, 11
    assign p_sh[23:16] =
        state_after_shiftrows[63:56] ^
        state_after_shiftrows[55:48] ^
        state_after_shiftrows[47:40] ^
        state_after_shiftrows[39:32];

    // Column 3: bytes 12, 13, 14, 15
    assign p_sh[31:24] =
        state_after_shiftrows[31:24] ^
        state_after_shiftrows[23:16] ^
        state_after_shiftrows[15:8] ^
        state_after_shiftrows[7:0];

    assign p_rk[7:0] =
        round_key[127:120] ^ round_key[119:112] ^
        round_key[111:104] ^ round_key[103:96];

    assign p_rk[15:8] =
        round_key[95:88] ^ round_key[87:80] ^
        round_key[79:72] ^ round_key[71:64];

    assign p_rk[23:16] =
        round_key[63:56] ^ round_key[55:48] ^
        round_key[47:40] ^ round_key[39:32];

    assign p_rk[31:24] =
        round_key[31:24] ^ round_key[23:16] ^
        round_key[15:8] ^ round_key[7:0];

    assign p_out[7:0] =
        actual_round_out[127:120] ^
        actual_round_out[119:112] ^
        actual_round_out[111:104] ^
        actual_round_out[103:96];

    assign p_out[15:8] =
        actual_round_out[95:88] ^
        actual_round_out[87:80] ^
        actual_round_out[79:72] ^
        actual_round_out[71:64];

    assign p_out[23:16] =
        actual_round_out[63:56] ^
        actual_round_out[55:48] ^
        actual_round_out[47:40] ^
        actual_round_out[39:32];

    assign p_out[31:24] =
        actual_round_out[31:24] ^
        actual_round_out[23:16] ^
        actual_round_out[15:8] ^
        actual_round_out[7:0];

    assign p_expected = p_sh ^ p_rk;

    assign fault_flag[0] = (p_out[7:0]   != p_expected[7:0]);
    assign fault_flag[1] = (p_out[15:8]  != p_expected[15:8]);
    assign fault_flag[2] = (p_out[23:16] != p_expected[23:16]);
    assign fault_flag[3] = (p_out[31:24] != p_expected[31:24]);

endmodule
