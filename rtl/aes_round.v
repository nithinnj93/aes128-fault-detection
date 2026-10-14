// One AES-128 encryption round.
// state_in and state_out use the standard packed AES byte order.
// Set final_round=1 for round 10, which omits MixColumns.
module aes_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         final_round,
    input  wire [127:0] sbox_fault_mask, // simulation-only fault injection
    output wire [127:0] state_out,
    output wire         fault_flag,
    output wire [3:0]   parity_fault_flags
);
    wire [127:0] sub_state;
    wire [15:0] sbox_fault_flags;
    wire [127:0] shift_state;
    wire [127:0] mix_state;
    wire [127:0] selected_state;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SUB_BYTES
            aes_sbox_checked sb (
                .data_in(state_in[127 - 8*i -: 8]),
                .fault_mask(sbox_fault_mask[127 - 8*i -: 8]),
                .data_out(sub_state[127 - 8*i -: 8]),
                .fault_flag(sbox_fault_flags[i])
            );
        end
    endgenerate

    // ShiftRows: rotate AES state rows left by 0, 1, 2 and 3 bytes.
    assign shift_state[127:120] = sub_state[127:120]; // byte 0 <- 0
    assign shift_state[119:112] = sub_state[87:80];   // byte 1 <- 5
    assign shift_state[111:104] = sub_state[47:40];   // byte 2 <- 10
    assign shift_state[103:96]  = sub_state[7:0];     // byte 3 <- 15

    assign shift_state[95:88]   = sub_state[95:88];   // byte 4 <- 4
    assign shift_state[87:80]   = sub_state[55:48];   // byte 5 <- 9
    assign shift_state[79:72]   = sub_state[15:8];    // byte 6 <- 14
    assign shift_state[71:64]   = sub_state[103:96];  // byte 7 <- 3

    assign shift_state[63:56]   = sub_state[63:56];   // byte 8 <- 8
    assign shift_state[55:48]   = sub_state[23:16];  // byte 9 <- 13
    assign shift_state[47:40]   = sub_state[111:104];// byte 10 <- 2
    assign shift_state[39:32]   = sub_state[71:64];  // byte 11 <- 7

    assign shift_state[31:24]   = sub_state[31:24];  // byte 12 <- 12
    assign shift_state[23:16]   = sub_state[119:112];// byte 13 <- 1
    assign shift_state[15:8]    = sub_state[79:72];  // byte 14 <- 6
    assign shift_state[7:0]     = sub_state[39:32];  // byte 15 <- 11

    function [7:0] xtime;
        input [7:0] x;
        begin
            xtime = (x << 1) ^ (x[7] ? 8'h1b : 8'h00);
        end
    endfunction

    function [127:0] mix_columns;
        input [127:0] s;
        reg [7:0] a0, a1, a2, a3;
        reg [7:0] b0, b1, b2, b3;
        reg [7:0] c0, c1, c2, c3;
        reg [7:0] d0, d1, d2, d3;
        begin
            a0=s[127:120]; a1=s[119:112]; a2=s[111:104]; a3=s[103:96];
            b0=s[95:88];   b1=s[87:80];   b2=s[79:72];   b3=s[71:64];
            c0=s[63:56];   c1=s[55:48];   c2=s[47:40];   c3=s[39:32];
            d0=s[31:24];   d1=s[23:16];   d2=s[15:8];    d3=s[7:0];

            mix_columns[127:120] = xtime(a0) ^ (xtime(a1)^a1) ^ a2 ^ a3;
            mix_columns[119:112] = a0 ^ xtime(a1) ^ (xtime(a2)^a2) ^ a3;
            mix_columns[111:104] = a0 ^ a1 ^ xtime(a2) ^ (xtime(a3)^a3);
            mix_columns[103:96]  = (xtime(a0)^a0) ^ a1 ^ a2 ^ xtime(a3);

            mix_columns[95:88] = xtime(b0) ^ (xtime(b1)^b1) ^ b2 ^ b3;
            mix_columns[87:80] = b0 ^ xtime(b1) ^ (xtime(b2)^b2) ^ b3;
            mix_columns[79:72] = b0 ^ b1 ^ xtime(b2) ^ (xtime(b3)^b3);
            mix_columns[71:64] = (xtime(b0)^b0) ^ b1 ^ b2 ^ xtime(b3);

            mix_columns[63:56] = xtime(c0) ^ (xtime(c1)^c1) ^ c2 ^ c3;
            mix_columns[55:48] = c0 ^ xtime(c1) ^ (xtime(c2)^c2) ^ c3;
            mix_columns[47:40] = c0 ^ c1 ^ xtime(c2) ^ (xtime(c3)^c3);
            mix_columns[39:32] = (xtime(c0)^c0) ^ c1 ^ c2 ^ xtime(c3);

            mix_columns[31:24] = xtime(d0) ^ (xtime(d1)^d1) ^ d2 ^ d3;
            mix_columns[23:16] = d0 ^ xtime(d1) ^ (xtime(d2)^d2) ^ d3;
            mix_columns[15:8]  = d0 ^ d1 ^ xtime(d2) ^ (xtime(d3)^d3);
            mix_columns[7:0]   = (xtime(d0)^d0) ^ d1 ^ d2 ^ xtime(d3);
        end
    endfunction

    assign mix_state = mix_columns(shift_state);
    assign selected_state = final_round ? shift_state : mix_state;
    assign state_out = selected_state ^ round_key;
    assign fault_flag = |sbox_fault_flags;

    // Check the four AES column-parity relationships.
    aes_round_parity_predictor parity_checker (
        .state_after_shiftrows(shift_state),
        .round_key(round_key),
        .actual_round_out(state_out),
        .fault_flag(parity_fault_flags)
    );
endmodule
