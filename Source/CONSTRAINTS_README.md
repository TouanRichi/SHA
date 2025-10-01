# Constraint Files for SHA-256 RISC-V Co-processor

## Overview

This directory contains constraint files (XDC) for synthesizing and implementing the SHA-256 RISC-V co-processor design on Xilinx FPGAs.

## ✅ RESOLVED: I/O Pin Count Issue

**The `res_sha256_o[255:0]` output has been removed to resolve the I/O placement error!**

The SHA-256 result is now written directly to data memory (addresses 0x00-0x1C) instead of being exposed as an external output port. This reduces the I/O pin count from 404 to 148 pins.

## Files

### 1. `RISC_Top.xdc` (Updated - Recommended)
- **Purpose**: Constraint file for the reduced I/O design
- **I/O Count**: 148 pins (147 inputs + 1 output)
  - Inputs: clk, reset, start_in, DMAD_* (72 pins), DMAI_* (72 pins)
  - Output: state_done
- **Status**: ✅ Fits on most FPGAs (XC7A35T and larger)
- **Use Case**: Default configuration

### 2. `RISC_Top_BRAM.xdc` (Optional - Minimal I/O)
- **Purpose**: Constraint file assuming Block RAM usage for memories
- **I/O Count**: 4 pins (clk, reset, start_in, state_done)
- **Status**: ✅ Fits on any FPGA
- **Use Case**: Minimal I/O configuration using internal BRAM

## Previous Issue (RESOLVED) ✅

The implementation error occurred because:
```
Number of unplaced terminals: 349 (with res_sha256_o output)
Number of available sites: 328
Result: CANNOT FIT ❌
```

**Solution Applied**: Removed `res_sha256_o[255:0]` output port (256 pins)
- Old I/O count: 404 pins
- New I/O count: 148 pins  
- Reduction: 256 pins (63%)

## Design Changes

The following changes were made to reduce I/O pins:

1. **Top.v**: Removed `output [255:0] res_sha256_o` port
2. **Top.v**: Removed `assign res_sha256_o = res_sha256_w;` assignment
3. **Top_tb.v**: Updated testbench to read SHA result from data memory
4. **Internal operation**: SHA-256 result is still computed correctly and written to data memory via `wr_b2data` module

## How to Access SHA-256 Result

Since `res_sha256_o` has been removed, the SHA-256 result is accessed through data memory:

### In Hardware:
- Read data memory addresses 0x00 through 0x1C (8 words × 32 bits = 256 bits)
- Word 0 (addr 0x00): SHA-256[255:224]
- Word 1 (addr 0x04): SHA-256[223:192]
- ...
- Word 7 (addr 0x1C): SHA-256[31:0]

### In Testbench:
```verilog
always @(posedge state_done) begin
    $display("SHA256 result stored in data memory:");
    $display("%08h %08h %08h %08h %08h %08h %08h %08h", 
             Data_RAM[0][31:0], Data_RAM[1][31:0], Data_RAM[2][31:0], Data_RAM[3][31:0],
             Data_RAM[4][31:0], Data_RAM[5][31:0], Data_RAM[6][31:0], Data_RAM[7][31:0]);
end
```

## Further Optimization (Optional)
     - Port A Width: 32 bits
     - Port A Depth: 4096 (or as needed)
     - Initialize with your program binary (.coe file)
   - Create `data_mem` (Data Memory)
     - Memory Type: Single Port RAM
     - Port A Width: 32 bits
     - Port A Depth: 4096 (or as needed)

3. **Instantiate Block RAM** in `Top.v` instead of external ports

4. **Result**: I/O count reduces to ~260 pins (fits most FPGAs)


If you still need to reduce I/O further (e.g., to use Block RAM for memories):

### Use Block RAM for Memories

**Reduce I/O from 148 pins to 4 pins by using internal Block RAM:**

1. **Remove external memory ports** from `Top.v`:
   ```verilog
   // REMOVE these ports:
   // input [31:0] DMAD_addr_in,
   // input [31:0] DMAD_data_in,
   // input [7:0] DMAD_wea_in,
   // input [31:0] DMAI_addr_in,
   // input [31:0] DMAI_data_in,
   // input [7:0] DMAI_wea_in,
   ```

2. **Add Block RAM IP cores** in Vivado:
   - Go to: IP Catalog → Memories & Storage Elements → Block Memory Generator
   - Create `ins_mem` (Instruction Memory)
     - Memory Type: Single Port RAM
     - Port A Width: 32 bits
     - Port A Depth: 4096 (or as needed)
     - Initialize with your program binary (.coe file)
   - Create `data_mem` (Data Memory)
     - Memory Type: Single Port RAM
     - Port A Width: 32 bits
     - Port A Depth: 4096 (or as needed)

3. **Result**: Final I/O count = 4 pins (clk, reset, start_in, state_done)

## How to Use Constraint Files

### In Vivado GUI:
1. Open your Vivado project
2. Click "Add Sources" → "Add or Create Constraints"
3. Add `RISC_Top.xdc` (or `RISC_Top_BRAM.xdc` if using Block RAM)
4. Customize pin locations for your specific FPGA board
5. Run synthesis and implementation

### Pin Location Customization:

The constraint files include example pin locations (commented out). You MUST customize these based on your FPGA board:

```tcl
# Example (uncomment and modify for your board):
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports reset]
# ... etc
```

Refer to your FPGA board's user manual or schematic for actual pin locations.

## Timing Constraints

The default clock frequency is set to 100 MHz (10ns period):
```tcl
create_clock -period 10.000 -name clk [get_ports clk]
```

To change the frequency:
- 50 MHz: `-period 20.000`
- 100 MHz: `-period 10.000`
- 200 MHz: `-period 5.000`

## Next Steps

1. **Choose a solution** from the options above (recommend Solution 1: Block RAM)
2. **Modify the design** if needed (remove external memory ports)
3. **Customize pin locations** in the XDC file for your board
4. **Run synthesis** and verify no I/O placement errors
5. **Run implementation** and generate bitstream

## Support

If you continue to have issues:
1. Verify your FPGA part number has enough I/O pins
2. Check for I/O bank conflicts in the placement report
3. Review timing reports for any violations
4. Consider using I/O buffers or serializers for high pin count interfaces

## Additional Resources

- Xilinx Constraints Guide: UG903
- Block Memory Generator Guide: PG058
- 7 Series FPGAs Packaging Guide: UG475
