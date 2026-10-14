`timescale 1ns/1ps

module aes_round_tb;
    reg  [127:0] state_in;
    reg  [127:0] round_key;
    reg          final_round;
    reg  [127:0] sbox_fault_mask;
    wire [127:0] state_out;
    integer passed, failed;

    aes_round dut (
        .state_in(state_in),
        .round_key(round_key),
        .final_round(final_round),
        .sbox_fault_mask(sbox_fault_mask),
        .state_out(state_out),
        .fault_flag()
    );

    initial begin
        passed = 0;
        failed = 0;
        // NIST AES-128 example: state after initial AddRoundKey.
        state_in = 128'h00102030405060708090a0b0c0d0e0f0;
        round_key = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
        final_round = 1'b0;
        sbox_fault_mask = 128'b0;
        #2;

        if (state_out === 128'h89d810e8855ace682d1843d8cb128fe4) begin
            $display("PASS: Round 1 output = %032h", state_out);
            passed = passed + 1;
        end else begin
            $display("FAIL: Round 1 expected 89d810e8855ace682d1843d8cb128fe4");
            $display("      Actual:   %032h", state_out);
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("AES round tests: PASS=%0d FAIL=%0d", passed, failed);
        if (failed == 0)
            $display("RESULT: AES ROUND TEST PASSED");
        else
            $display("RESULT: AES ROUND TEST FAILED");
        $finish;
    end
endmodule
