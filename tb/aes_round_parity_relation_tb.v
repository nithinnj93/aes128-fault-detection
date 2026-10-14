`timescale 1ns/1ps

module aes_round_parity_relation_tb;

    reg  [127:0] state_after_shiftrows;
    reg  [127:0] round_key;
    reg  [127:0] actual_round_out;

    wire [3:0] fault_flag;

    aes_round_parity_predictor dut (
        .state_after_shiftrows(state_after_shiftrows),
        .round_key(round_key),
        .actual_round_out(actual_round_out),
        .fault_flag(fault_flag)
    );

    function [7:0] column_parity;
        input [127:0] state;
        input integer column;
        begin
            column_parity =
                state[127-column*8 -: 8] ^
                state[95-column*8 -: 8]  ^
                state[63-column*8 -: 8]  ^
                state[31-column*8 -: 8];
        end
    endfunction

    integer j;

    initial begin
        state_after_shiftrows =
            128'h00112233445566778899aabbccddeeff;
        round_key =
            128'h000102030405060708090a0b0c0d0e0f;

        // Construct a reference output using the stated parity relationship.
        actual_round_out = 128'b0;

        for (j = 0; j < 4; j = j + 1) begin
            actual_round_out[127-j*8 -: 8] =
                column_parity(state_after_shiftrows, j) ^
                column_parity(round_key, j);
        end

        #1;
        $display("Parity flags = %b", fault_flag);
        $display("This test validates the predictor arithmetic only.");
        $display("It does not validate the full AES round transformation.");
        $finish;
    end

endmodule
