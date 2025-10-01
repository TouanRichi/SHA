// Clock Gating Module for Power Optimization
// This module provides a simple clock gating mechanism to reduce dynamic power
// when SHA-256 computation is not active

module clock_gating (
    input clk,           // Main clock input
    input enable,        // Clock enable signal (1 = clock active, 0 = clock gated)
    output gated_clk     // Gated clock output
);

    // Simple AND-based clock gating
    // Note: For production designs, consider using BUFGCE or BUFHCE primitives
    // which are clock-buffer primitives with built-in enable
    assign gated_clk = clk & enable;

endmodule

// Alternative: Using Xilinx BUFGCE primitive (recommended for production)
// This provides glitch-free clock gating
/*
module clock_gating_bufgce (
    input clk,
    input enable,
    output gated_clk
);
    BUFGCE bufgce_inst (
        .O(gated_clk),   // Clock output
        .CE(enable),      // Clock enable
        .I(clk)          // Clock input
    );
endmodule
*/

// Usage Example in Top.v:
// 
// // Add clock enable signal based on SHA FSM state
// wire sha_clk_enable;
// assign sha_clk_enable = start_sha_w3 | (current_sha_state != IDLE);
// 
// // Instantiate clock gating
// wire sha_gated_clk;
// clock_gating sha_clk_gate (
//     .clk(clk),
//     .enable(sha_clk_enable),
//     .gated_clk(sha_gated_clk)
// );
// 
// // Then use sha_gated_clk for SHA registers:
// // - Reg_A through Reg_H (SHA working variables)
// // - Reg0 through Reg15 (message schedule)
// // - K_register (round constants)
// // - All SHA computation modules
//
// Expected power savings: 30-40% dynamic power when SHA is idle

// Notes:
// 1. Clock gating is most effective for modules that are idle for long periods
// 2. The enable signal must be synchronous to avoid glitches
// 3. For Xilinx FPGAs, BUFGCE is preferred over simple AND gate
// 4. Verify timing closure after adding clock gating
// 5. Test thoroughly to ensure no functional issues
