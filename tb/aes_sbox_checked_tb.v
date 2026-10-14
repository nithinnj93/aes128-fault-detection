`timescale 1ns/1ps
module aes_sbox_checked_tb;
    reg [7:0] data_in;
    reg [7:0] fault_mask;
    wire [7:0] data_out;
    wire fault_flag;
    wire [7:0] reference_out;
    integer passed, failed, i, bit_index;

    aes_sbox reference_sbox (.data_in(data_in), .data_out(reference_out));
    aes_sbox_checked dut (.data_in(data_in), .fault_mask(fault_mask),
                          .data_out(data_out), .fault_flag(fault_flag));

    initial begin
        passed = 0; failed = 0; data_in = 0; fault_mask = 0;
        $dumpfile("sim/aes_sbox_checked_tb.vcd");
        $dumpvars(0, aes_sbox_checked_tb);

        // Exhaustively verify all 256 S-box inputs without injected faults.
        for (i = 0; i < 256; i = i + 1) begin
            data_in = i[7:0]; fault_mask = 8'h00; #1;
            if (data_out === reference_out && fault_flag === 1'b0) passed = passed + 1;
            else begin
                $display("FAIL normal: input=%02h out=%02h ref=%02h flag=%b",
                         data_in, data_out, reference_out, fault_flag);
                failed = failed + 1;
            end
        end
        $display("Normal-operation sweep: PASS=%0d / 256", passed);

        // At input 0x53, inject each of the eight possible single-bit output faults.
        data_in = 8'h53;
        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
            fault_mask = (8'h01 << bit_index); #1;
            if (fault_flag === 1'b1 && data_out === (reference_out ^ fault_mask)) begin
                $display("PASS injected bit %0d: observed=%02h fault_flag=1", bit_index, data_out);
                passed = passed + 1;
            end else begin
                $display("FAIL injected bit %0d: observed=%02h flag=%b", bit_index, data_out, fault_flag);
                failed = failed + 1;
            end
        end

        // Also test a multi-bit output corruption.
        fault_mask = 8'hA5; #1;
        if (fault_flag === 1'b1 && data_out === (reference_out ^ 8'hA5)) begin
            $display("PASS multi-bit fault: mask=A5 observed=%02h fault_flag=1", data_out);
            passed = passed + 1;
        end else begin
            $display("FAIL multi-bit fault: mask=A5 observed=%02h flag=%b", data_out, fault_flag);
            failed = failed + 1;
        end

        fault_mask = 8'h00; #1;
        $display("--------------------------------");
        $display("Checked S-box tests: PASS=%0d FAIL=%0d", passed, failed);
        if (failed == 0) $display("RESULT: NORMAL AND INJECTED-FAULT TESTS PASSED");
        else $display("RESULT: CHECKED S-BOX TESTS FAILED");
        $finish;
    end
endmodule
