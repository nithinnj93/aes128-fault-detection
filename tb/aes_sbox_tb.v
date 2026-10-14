`timescale 1ns/1ps

module aes_sbox_tb;
    reg  [7:0] data_in;
    wire [7:0] data_out;
    integer passed;
    integer failed;

    aes_sbox dut (
        .data_in(data_in),
        .data_out(data_out)
    );

    task check;
        input [7:0] test_in;
        input [7:0] expected;
        begin
            data_in = test_in;
            #1;
            if (data_out === expected) begin
                $display("PASS: SBOX[%02h] = %02h", test_in, data_out);
                passed = passed + 1;
            end else begin
                $display("FAIL: SBOX[%02h] expected %02h, got %02h",
                         test_in, expected, data_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        passed = 0;
        failed = 0;
        data_in = 8'h00;
        $dumpfile("sim/aes_sbox_tb.vcd");
        $dumpvars(0, aes_sbox_tb);

        check(8'h00, 8'h63);
        check(8'h01, 8'h7c);
        check(8'h53, 8'hed);
        check(8'h7c, 8'h10);
        check(8'hff, 8'h16);

        $display("--------------------------------");
        $display("S-box tests: PASS=%0d FAIL=%0d", passed, failed);
        if (failed == 0)
            $display("RESULT: ALL S-BOX TESTS PASSED");
        else
            $display("RESULT: S-BOX TESTS FAILED");
        $finish;
    end
endmodule
