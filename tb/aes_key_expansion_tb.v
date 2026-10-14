`timescale 1ns/1ps

module aes_key_expansion_tb;
    reg  [127:0] key;
    wire [1407:0] round_keys;
    integer passed, failed;

    aes_key_expansion dut (
        .key(key),
        .round_keys(round_keys)
    );

    initial begin
        passed = 0;
        failed = 0;
        key = 128'h000102030405060708090a0b0c0d0e0f;
        #5;

        if (round_keys[127:0] === 128'h000102030405060708090a0b0c0d0e0f) begin
            $display("PASS: K0 = %032h", round_keys[127:0]);
            passed = passed + 1;
        end else begin
            $display("FAIL: K0 = %032h", round_keys[127:0]);
            failed = failed + 1;
        end

        if (round_keys[255:128] === 128'hd6aa74fdd2af72fadaa678f1d6ab76fe) begin
            $display("PASS: K1 = %032h", round_keys[255:128]);
            passed = passed + 1;
        end else begin
            $display("FAIL: K1 expected d6aa74fdd2af72fadaa678f1d6ab76fe, got %032h",
                     round_keys[255:128]);
            failed = failed + 1;
        end

        if (round_keys[1407:1280] === 128'h13111d7fe3944a17f307a78b4d2b30c5) begin
            $display("PASS: K10 = %032h", round_keys[1407:1280]);
            passed = passed + 1;
        end else begin
            $display("FAIL: K10 expected 13111d7fe3944a17f307a78b4d2b30c5, got %032h",
                     round_keys[1407:1280]);
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("Key expansion tests: PASS=%0d FAIL=%0d", passed, failed);
        if (failed == 0)
            $display("RESULT: ALL KEY EXPANSION TESTS PASSED");
        else
            $display("RESULT: KEY EXPANSION TESTS FAILED");
        $finish;
    end
endmodule
