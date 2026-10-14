`timescale 1ns/1ps

module aes128_top_tb;
    reg  [127:0] plaintext;
    reg  [127:0] key;
    reg  [127:0] sbox_fault_mask;
    wire [127:0] ciphertext;
    wire fault_flag;
    wire [39:0] parity_fault_flags;
    integer passed, failed;

    aes128_top dut (
        .plaintext(plaintext),
        .key(key),
        .sbox_fault_mask(sbox_fault_mask),
        .ciphertext(ciphertext),
        .fault_flag(fault_flag),
        .parity_fault_flags(parity_fault_flags)
    );

    initial begin
        passed = 0;
        failed = 0;
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 128'h000102030405060708090a0b0c0d0e0f;
        sbox_fault_mask = 128'h0;
        #10;

        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a && fault_flag === 1'b0 && parity_fault_flags === 40'b0) begin
            $display("PASS: ciphertext=%032h fault_flag=%b parity_flags=%010h", ciphertext, fault_flag, parity_fault_flags);
            passed = passed + 1;
        end else begin
            $display("FAIL: no-fault test: ciphertext=%032h fault_flag=%b", ciphertext, fault_flag);
            failed = failed + 1;
        end

        // Inject a single-bit error into one byte of every round's S-box output.
        // This is a testbench hook, not a physical hardware fault injection circuit.
        sbox_fault_mask = 128'h80000000000000000000000000000000;
        #10;
        if (fault_flag === 1'b1) begin
            $display("PASS: injected-fault test detected; fault_flag=%b", fault_flag);
            passed = passed + 1;
        end else begin
            $display("FAIL: injected-fault test missed; fault_flag=%b", fault_flag);
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("AES-128 top tests: PASS=%0d FAIL=%0d", passed, failed);
        if (failed == 0)
            $display("RESULT: AES-128 NORMAL AND FAULT-DETECTION TESTS PASSED");
        else
            $display("RESULT: AES-128 TOP-LEVEL TESTS FAILED");
        $finish;
    end
endmodule
