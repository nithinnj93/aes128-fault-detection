module aes_round_parity_checker (
    input  wire [127:0] expected_round_out,
    input  wire [127:0] actual_round_out,
    output wire         fault_flag
);

    assign fault_flag =
        (^expected_round_out) ^ (^actual_round_out);

endmodule
