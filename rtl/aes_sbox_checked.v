// Simulation-oriented S-box fault checker inspired by the paper's alpha relation.
// alpha is stored in a separate lookup table. fault_mask models corruption of
// the S-box output AFTER the functional S-box; it is a test hook, not a physical pin.
module aes_sbox_checked (
    input wire [7:0] data_in,
    input wire [7:0] fault_mask,
    output wire [7:0] data_out,
    output wire fault_flag
);
    wire [7:0] normal_sbox_out;
    wire [7:0] alpha;
    wire [7:0] predicted_out;
    wire [7:0] observed_out;

    aes_sbox normal_sbox (.data_in(data_in), .data_out(normal_sbox_out));
    aes_sbox_alpha_lut alpha_table (.data_in(data_in), .alpha_out(alpha));

    assign predicted_out = data_in ^ alpha;
    assign observed_out = normal_sbox_out ^ fault_mask;
    assign data_out = observed_out;
    assign fault_flag = (predicted_out != observed_out);
endmodule
