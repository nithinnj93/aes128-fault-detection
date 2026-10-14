// AES-128 key expansion: generates round keys K0..K10.
// Packing convention: round_keys[127:0] = K0, [255:128] = K1, ... [1407:1280] = K10.
module aes_key_expansion (
    input  wire [127:0] key,
    output wire [1407:0] round_keys
);
    assign round_keys[127:0] = key;

    function [7:0] rcon;
        input integer round;
        begin
            case (round)
                1: rcon = 8'h01; 2: rcon = 8'h02; 3: rcon = 8'h04;
                4: rcon = 8'h08; 5: rcon = 8'h10; 6: rcon = 8'h20;
                7: rcon = 8'h40; 8: rcon = 8'h80; 9: rcon = 8'h1b;
                10: rcon = 8'h36;
                default: rcon = 8'h00;
            endcase
        end
    endfunction

    genvar r;
    generate
        for (r = 1; r <= 10; r = r + 1) begin : ROUND_KEY
            wire [127:0] prev_key;
            wire [31:0]  rotated_word;
            wire [31:0]  sub_word;
            wire [31:0]  first_word;
            wire [31:0]  second_word;
            wire [31:0]  third_word;
            wire [31:0]  fourth_word;
            wire [7:0] s0, s1, s2, s3;

            assign prev_key = round_keys[(r-1)*128 +: 128];
            // RotWord on the last 32-bit word: [b0,b1,b2,b3] -> [b1,b2,b3,b0]
            assign rotated_word = {prev_key[23:0], prev_key[31:24]};

            aes_sbox sb0(.data_in(rotated_word[31:24]), .data_out(s0));
            aes_sbox sb1(.data_in(rotated_word[23:16]), .data_out(s1));
            aes_sbox sb2(.data_in(rotated_word[15:8]),  .data_out(s2));
            aes_sbox sb3(.data_in(rotated_word[7:0]),   .data_out(s3));
            assign sub_word = {s0, s1, s2, s3};

            assign first_word  = prev_key[127:96] ^ sub_word ^ {rcon(r), 24'h000000};
            assign second_word = prev_key[95:64]  ^ first_word;
            assign third_word  = prev_key[63:32]   ^ second_word;
            assign fourth_word = prev_key[31:0]    ^ third_word;

            assign round_keys[r*128 +: 128] =
                {first_word, second_word, third_word, fourth_word};
        end
    endgenerate
endmodule
