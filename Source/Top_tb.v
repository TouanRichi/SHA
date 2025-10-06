`timescale 1ns / 1ps

module RISC_Top_tb();

    // T�n hi?u m� ph??ng
    reg clk;
    reg reset;
    // reg [31:0] ins_mem[0:8191];  
    
    // ???u ra t? CPU Pipeline
    // wire [63:0] pc_out;
    // wire [31:0] inst;
    reg [63:0]  Inst_ROM [0:1024];
    reg [63:0]  Data_RAM [0:1024];

    // res_sha256_o output removed - SHA-256 result is written to data memory

    integer dmem = 0;
    integer dins = 0;

    reg [31:0] CPU_addrin;
    reg [31:0] CPU_datain;
    reg [31:0] CPUi_addrin;
    reg [31:0] CPUi_datain;
    
    reg [7:0]  CPU_we;
    reg start_in;
    wire state_done;
    integer addr_cycle_count = 0;
   
//    integer i;
    // initial begin
    
    //   for (i = 0; i <= 1024; i = i + 1) begin
    //     Inst_ROM[i] = 64'd0;
    // end
    
    // // Khởi tạo Data_RAM v�? 0
    // for (i = 0; i <= 1024; i = i + 1) begin
    //     Data_RAM[i] = 64'd0;
    // end
    // end


    // K?t n?i module CPU Pipeline
    RISC_Top CPU (
        .clk(clk),
        .reset(reset),
        .start_in(start_in),
        .DMAD_addr_in(CPU_addrin),
        .DMAD_data_in(CPU_datain),
        .DMAD_wea_in(CPU_we),

        .DMAI_addr_in(CPUi_addrin),
        .DMAI_data_in(CPUi_datain),
        .DMAI_wea_in(CPU_we),
        .state_done(state_done)
    );


    // T?o xung nh?p (clock signal)
    

    initial begin
     clk = 0;
   // Bước 1: Khởi tạo toàn bộ v�? 0
    // for (i = 0; i <= 1024; i = i + 1) begin
    //     Inst_ROM[i] = 64'd0;
    //     Data_RAM[i] = 64'd0;
    // end

        // Kh?i t?o t�n hi?u
    $dumpfile("RISC_Sha_tb.vcd");  // T�n file VCD
    $dumpvars(0, RISC_Top_tb);        // T�n module 
    // Ghi r� t�n hi?u inst_out v�o file VCD
   //  $readmemh("C:\\Users\\ADMIN\\Desktop\\test_git\\RV_doing\\Verilog_Buffer_RV\\Inst_ROM.txt", Inst_ROM);
     //$readmemh("C:\\Users\\ADMIN\\Desktop\\test_git\\RV_doing\\Verilog_Buffer_RV\\Data_Mem.txt", Data_RAM);
    // $readmemh("C:\\Users\\ADMIN\\Desktop\\NCKH\\RV_32_Cus\\Inst_ROM.txt", ins_mem);
     $readmemh("C:\\Users\\Dat Pham\\Downloads\\RV_Sha245_SendtoDat\\Source\\C_code\\Inst_ROM.txt", Inst_ROM);
     $readmemh("C:\\Users\\Dat Pham\\Downloads\\RV_Sha245_SendtoDat\\Source\\C_code\\Data_Mem.txt", Data_RAM);
    // C:\\Users\\Dat Pham\\Downloads\\RV_Sha245_SendtoDat\\Source\\C_code
    end 
    
    always #5 clk = ~clk;  // ch? t?o clock

// Khi state_done l�n, in k?t qu? v� k?t th�c m� ph?ng
// Note: SHA-256 result is now written to data memory (address 0x00-0x1C)
// Read from Data_RAM to verify the result
always @(posedge state_done) begin
    $display("Time=%0t | SHA256 computation done. Result stored in data memory.", $time);
    $display("SHA256[7:0]   = %08h %08h %08h %08h %08h %08h %08h %08h", 
             Data_RAM[0][31:0], Data_RAM[1][31:0], Data_RAM[2][31:0], Data_RAM[3][31:0],
             Data_RAM[4][31:0], Data_RAM[5][31:0], Data_RAM[6][31:0], Data_RAM[7][31:0]);
    $finish;
end

    initial begin
    start_in = 0;
        CPU_we = 8'b00000000; // t�n hi?u cho ph�p ???c ho?c ghi bram = 0 l� wr = 0
        reset <= 0;
        #10;
        reset <= 1;
        // CPU_en = 1'b1;
        #20;
        //Get Data for Data Memory
        for (dmem = 0; dmem<150; dmem=dmem+1) begin //Amount of Datas
            #10;
            CPU_we = 8'b11111111;
            CPU_addrin <= Data_RAM[dmem][63:32];
            CPU_datain <= Data_RAM[dmem][31:0];

            CPUi_addrin <= Inst_ROM[dmem][63:32];
            CPUi_datain <= Inst_ROM[dmem][31:0];
            #10;
            CPU_we = 8'b00000000;
        end
       
        CPU_we = 8'b0000000;
        start_in = 1'b1;
    end

endmodule
