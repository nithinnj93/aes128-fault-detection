`timescale 1ns/1ps

module aes_round_parity_checker_tb;

    reg  [127:0] expected_round_out;
    reg  [127:0] actual_round_out;
    wire         fault_flag;

    integer i;
    integer pass_count;
    integer fail_count;

    aes_round_parity_checker dut (
        .expected_round_out(expected_round_out),
        .actual_round_out(actual_round_out),
        .fault_flag(fault_flag)
    );

    initial begin
        $dumpfile("sim/aes_round_parity_checker_tb.vcd");
        $dumpvars(0, aes_round_parity_checker_tb);

        pass_count = 0;
        fail_count = 0;

        expected_round_out =
            128'h00112233445566778899aabbccddeeff;
        actual_round_out = expected_round_out;
        #1;

        if (fault_flag == 0) begin
            $display("PASS: normal operation");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: normal operation");
            fail_count = fail_count + 1;
        end

        for (i = 0; i < 128; i = i + 1) begin
            actual_round_out =
                expected_round_out ^ (128'b1 << i);
            #1;

            if (fault_flag == 1'b1) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: single-bit error at bit %0d", i);
                fail_count = fail_count + 1;
            end
        end

        $display("Single-bit fault tests: 128 positions checked");

        actual_round_out =
            expected_round_out ^ 128'h00000000000000000000000000000003;
        #1;

        if (fault_flag == 0) begin
            $display("PASS: two-bit error preserves global parity");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: expected two-bit parity limitation");
            fail_count = fail_count + 1;
        end

        $display("--------------------------------");
        $display("Parity checker tests: PASS=%0d FAIL=%0d",
                 pass_count, fail_count);

        if (fail_count == 0)
            $display("RESULT: ALL 130 CHECKS PASSED");
        else
            $display("RESULT: TESTS FAILED");

        $finish;
    end

endmodule
