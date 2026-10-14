`timescale 1ns/1ps
module aes128_parity_top_tb;
    reg [127:0] plaintext, key, sbox_fault_mask, round_fault_mask;
    wire [127:0] ciphertext;
    wire sbox_fault_flag, parity_fault_flag, fault_flag;
    integer passed, failed, bitno;
    aes128_parity_top dut (
        .plaintext(plaintext), .key(key),
        .sbox_fault_mask(sbox_fault_mask), .round_fault_mask(round_fault_mask),
        .ciphertext(ciphertext), .sbox_fault_flag(sbox_fault_flag),
        .parity_fault_flag(parity_fault_flag), .fault_flag(fault_flag)
    );
    initial begin
        $dumpfile("sim/aes128_parity_top_tb.vcd");
        $dumpvars(0, aes128_parity_top_tb);
        passed=0; failed=0;
        plaintext=128'h00112233445566778899aabbccddeeff;
        key=128'h000102030405060708090a0b0c0d0e0f;
        sbox_fault_mask=0; round_fault_mask=0;
        #10;
        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a &&
            fault_flag === 1'b0 && sbox_fault_flag === 1'b0 && parity_fault_flag === 1'b0) begin
            $display("PASS: no fault, known-answer ciphertext, all flags=0"); passed=passed+1;
        end else begin $display("FAIL: normal AES ciphertext=%h flags=%b%b%b",ciphertext,sbox_fault_flag,parity_fault_flag,fault_flag); failed=failed+1; end
        // Eight single-bit flips on a round-output byte.
        for (bitno=0; bitno<8; bitno=bitno+1) begin
            round_fault_mask=128'h1 << bitno; #10;
            if (parity_fault_flag === 1'b1 && fault_flag === 1'b1 && sbox_fault_flag === 1'b0) begin
                $display("PASS: round-output single-bit fault bit=%0d",bitno); passed=passed+1;
            end else begin $display("FAIL: round-output single-bit fault bit=%0d",bitno); failed=failed+1; end
        end
        round_fault_mask=128'h3; #10;
        if (parity_fault_flag === 1'b0) begin
            $display("PASS: two-bit even-parity error NOT detected (known limitation)"); passed=passed+1;
        end else begin $display("FAIL: unexpected two-bit parity flag"); failed=failed+1; end
        round_fault_mask=0; sbox_fault_mask=128'h80000000000000000000000000000000; #10;
        if (sbox_fault_flag === 1'b1 && fault_flag === 1'b1 && parity_fault_flag === 1'b0) begin
            $display("PASS: S-box injection detected by S-box checker"); passed=passed+1;
        end else begin $display("FAIL: S-box injection flags=%b%b%b",sbox_fault_flag,parity_fault_flag,fault_flag); failed=failed+1; end
        $display("--------------------------------");
        $display("AES-128 parity integration tests: PASS=%0d FAIL=%0d",passed,failed);
        if (failed==0) $display("RESULT: ALL PARITY INTEGRATION TESTS PASSED");
        else $display("RESULT: PARITY INTEGRATION TESTS FAILED");
        $finish;
    end
endmodule
