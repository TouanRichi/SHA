// module PC(
//     input clk,
//     input reset,
//     input [31:0] pc_in,
//     input [31:0] pc_ecall,
//     input ecall_detected,     // T�n hi?u cho bi?t c� l?nh ecall

//     output reg [31:0] pc_out
//     // output reg ena_ins,       // ena signal 
//     // output reg wea
// );

// always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             pc_out <= 32'b0;    // Khi reset, pc_out ???c ??t v?? 0
//             // ena_ins <= 0;       // Disable instruction fetch when reset
//             // wea <= 0;
//         end
//         else if (ecall_detected) begin
//             pc_out <= pc_ecall; // Khi g?p ecall, gi? nguy�n gi� tr? c?a pc_out
//             // ena_ins <= 0;       // Disable instruction fetch on ecall
//             // wea <= 0;
//         end
//         else begin
//             pc_out <= pc_in;    // C?p nh?t pc_out b�nh th???ng n?u kh�ng c� ecall
//             // ena_ins <= 1;       // Enable instruction fetch
//             // wea <= 0;    
//         end
//     end

// endmodule


module PC(
    input clk,
    input reset,
    input start,               // C?? start ?? ki?m so�t ho?t ??ng
    input [31:0] pc_in,
//    input [31:0] pc_ecall,
//    input ecall_detected,     // T�n hi?u cho bi?t c� l?nh ecall

    output reg [31:0] pc_out
    // output reg ena_ins,       // ena signal 
    // output reg wea
);

// always @(posedge clk or negedge reset) begin
//         if (!reset) begin
//             pc_out <= 32'b0;    // Khi reset, pc_out ???c ??t v?? 0
//             // ena_ins <= 0;       // Disable instruction fetch when reset
//             // wea <= 0;
//         end
//         else if (start) begin
//             if (ecall_detected) begin
//                 pc_out <= pc_ecall; // Khi g?p ecall, g�n gi� tr? pc_ecall v�o pc_out
//             end else begin
//                 pc_out <= pc_in;    // N?u kh�ng, g�n gi� tr? pc_in v�o pc_out
//             end
//         end else begin
//             pc_out <= pc_out;    // Khi start kh�ng ???c k�ch ho?t, pc_out ???c ??t v?? 0
//         end
//     end
// endmodule

always @(posedge clk or negedge reset) begin
       if (!reset) begin
           pc_out <= 32'd0; 
       end else begin
           if (start) begin
           pc_out <= pc_in;
           end else begin
            pc_out <= pc_out;
             end
       end
end
endmodule


