`timescale 1ns/1ps

module aes_round_parity_check_tb;

    reg [127:0] state_in;
    reg [127:0] round_key;
    reg [127:0] sbox_fault_mask;
    reg [127:0] output_fault_mask;

    wire [127:0] state_out;
    wire [127:0] observed_round_out;
    wire sbox_fault_flag;
    wire [3:0] parity_fault_flags;

    integer passed;
    integer failed;

    assign observed_round_out = state_out ^ output_fault_mask;

    aes_round dut (
        .state_in(state_in),
        .round_key(round_key),
        .final_round(1'b0),
        .sbox_fault_mask(sbox_fault_mask),
        .state_out(state_out),
        .fault_flag(sbox_fault_flag)
    );

    aes_round_parity_predictor parity_checker (
        .state_after_shiftrows(dut.shift_state),
        .round_key(round_key),
        .actual_round_out(observed_round_out),
        .fault_flag(parity_fault_flags)
    );

    initial begin
        passed = 0;
        failed = 0;

        state_in = 128'h00112233445566778899aabbccddeeff;
        round_key = 128'h000102030405060708090a0b0c0d0e0f;
        sbox_fault_mask = 128'b0;
        output_fault_mask = 128'b0;

        #10;
        if (parity_fault_flags === 4'b0000) begin
            $display("PASS: normal AES round has no parity flags");
            passed = passed + 1;
        end else begin
            $display("FAIL: normal parity flags=%b", parity_fault_flags);
            failed = failed + 1;
        end

        output_fault_mask = 128'h80000000000000000000000000000000;
        #1;
        if (parity_fault_flags === 4'b0001) begin
            $display("PASS: injected output-bit error detected");
            passed = passed + 1;
        end else begin
            $display("FAIL: injected output fault flags=%b",
                     parity_fault_flags);
            failed = failed + 1;
        end

        output_fault_mask = 128'b0;
        #1;
        if (parity_fault_flags === 4'b0000) begin
            $display("PASS: parity flags clear after fault removal");
            passed = passed + 1;
        end else begin
            $display("FAIL: flags did not clear=%b", parity_fault_flags);
            failed = failed + 1;
        end

        $display("Round output = %032h", state_out);
        $display("--------------------------------");
        $display("Round parity tests: PASS=%0d FAIL=%0d", passed, failed);

        if (failed == 0)
            $display("RESULT: ALL ROUND PARITY TESTS PASSED");
        else
            $display("RESULT: ROUND PARITY TESTS FAILED");

        $finish;
    end
endmodule
