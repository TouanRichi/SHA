module MUX_AES2(
    input [31:0] a, // a is the normal RISC-V data signal
    input [31:0] b, // b is the SHA-256 write-back data signal
    input sel,
    output [31:0] c
);
    assign c = (sel) ? b : a;
endmodule
