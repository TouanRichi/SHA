module wr_b2data(
    input clk,
    input reset,
    input wire [255:0] result_SHA_in,
    input wire enable_wb,
    output reg en_w_datamem,
    output reg [31:0] data_sha256,
    output reg [31:0] addr_sha256
);
reg done_flag;
reg [31:0] temp_data_out [0:7];
reg [31:0] addr_sha256_temp;
integer i;
reg [1:0] state; 
reg [2:0] round;
localparam IDLE = 2'd0, N1 = 2'd1, DONE = 2'd2;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        data_sha256 <= 32'b0;
        addr_sha256 <= 32'b0;
        en_w_datamem <= 1'b0;
        state <= IDLE;
    end
    else if (enable_wb) begin
        case (state)
            IDLE: begin 
                for (i = 0; i<8; i = i +1) begin
                    temp_data_out[i] = result_SHA_in[255 - (i * 32) -: 32];
                end
                state <= N1;
                round <= 0;
            end  

            N1: begin
                if (round < 8) begin 
                    data_sha256 <= temp_data_out[round];
                    addr_sha256 <= 32'd0 + round*4;
                    en_w_datamem <= 1'b1;
                    round <= round + 1;
                end else begin 
                    state <= DONE;
                    en_w_datamem <= 1'b0;
                end 
                end

            DONE: begin
                done_flag <= 1;
                state <= IDLE;
            end 
            default: begin
                data_sha256 <= data_sha256;
            addr_sha256 <= addr_sha256;
            en_w_datamem <= en_w_datamem;
            state <= state;
            end

        endcase
    end else begin
        data_sha256 <= 0;
        addr_sha256 <= 0;
        en_w_datamem <= 0;
        state <= 0;
    end
end
endmodule