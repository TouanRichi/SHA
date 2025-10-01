module MUX_AES1(
    input [31:0] a, // a is the normal RISC-V address signal
    input [31:0] b, // b is the SHA-256 write-back address signal
    input sel,
    output [31:0] c
);
    assign c = (sel) ? b : a;
endmodule
