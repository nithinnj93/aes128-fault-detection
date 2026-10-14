`timescale 1ns/1ps

module aes_round_parity_predictor_tb;

    reg  [127:0] state_after_shiftrows;
    reg  [127:0] round_key;
    reg  [127:0] actual_round_out;
    wire [3:0] fault_flag;

    integer i;
    integer pass_count;
    integer fail_count;

    aes_round_parity_predictor dut (
        .state_after_shiftrows(state_after_shiftrows),
        .round_key(round_key),
        .actual_round_out(actual_round_out),
        .fault_flag(fault_flag)
    );

    task check;
        input [3:0] expected_flag;
        input [255:0] test_name;
        begin
            #1;
            if (fault_flag === expected_flag) begin
                $display("PASS: %0s flags=%b", test_name, fault_flag);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s expected=%b actual=%b",
                         test_name, expected_flag, fault_flag);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/aes_round_parity_predictor_tb.vcd");
        $dumpvars(0, aes_round_parity_predictor_tb);

        pass_count = 0;
        fail_count = 0;

        // A simple test vector: zero state and zero key.
        state_after_shiftrows = 128'b0;
        round_key = 128'b0;
        actual_round_out = 128'b0;
        check(4'b0000, "normal operation");

        // A single-bit error in each of the four columns.
        for (i = 0; i < 4; i = i + 1) begin
            actual_round_out = 128'b0;
            actual_round_out[127 - (i * 32)] = 1'b1;
            check(4'b0001 << i, "single-bit output error");
        end

        // Two bit errors in the same column can cancel under XOR parity.
        actual_round_out = 128'b0;
        actual_round_out[127] = 1'b1;
        actual_round_out[119] = 1'b1;
        check(4'b0000, "two-bit same-column parity limitation");

        $display("--------------------------------");
        $display("Predictor tests: PASS=%0d FAIL=%0d",
                 pass_count, fail_count);

        if (fail_count == 0)
            $display("RESULT: ALL 6 TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED");

        $finish;
    end

endmodule
