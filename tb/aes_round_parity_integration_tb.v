`timescale 1ns/1ps

module aes_round_parity_integration_tb;

    reg [127:0] state_in;
    reg [127:0] round_key;
    reg [127:0] sbox_fault_mask;

    wire [127:0] state_out;
    wire fault_flag;

    aes_round dut (
        .state_in(state_in),
        .round_key(round_key),
        .final_round(1'b0),
        .sbox_fault_mask(sbox_fault_mask),
        .state_out(state_out),
        .fault_flag(fault_flag)
    );

    initial begin
        state_in = 128'h00112233445566778899aabbccddeeff;
        round_key = 128'h000102030405060708090a0b0c0d0e0f;
        sbox_fault_mask = 128'b0;

        #10;
        $display("AES round output = %032h", state_out);
        $display("S-box fault flag = %b", fault_flag);
        $display("This test confirms round execution only.");
        $display("Parity must be checked against the actual round output separately.");
        $finish;
    end

endmodule
