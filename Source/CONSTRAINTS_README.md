# Constraint Files for SHA-256 RISC-V Co-processor

## Overview

This directory contains constraint files (XDC) for synthesizing and implementing the SHA-256 RISC-V co-processor design on Xilinx FPGAs.

## Files

### 1. `RISC_Top.xdc` (Default Constraint File)
- **Purpose**: Basic constraint file for the current design
- **I/O Count**: 404 pins (147 inputs + 257 outputs)
- **Status**: ⚠️ Will NOT fit on FPGAs with < 404 I/O pins
- **Use Case**: Reference only - requires large FPGA or design modification

### 2. `RISC_Top_BRAM.xdc` (Recommended)
- **Purpose**: Constraint file assuming Block RAM usage for memories
- **I/O Count**: 260 pins (4 control + 256 SHA output)
- **Status**: ✅ Fits on medium-sized FPGAs (e.g., XC7A100T with 300+ I/O)
- **Use Case**: Recommended approach using internal BRAM

## Current Issue

Your implementation error occurs because:
```
Number of unplaced terminals: 349
Number of available sites: 328
Result: CANNOT FIT ❌
```

## Solutions

### Solution 1: Use Block RAM (RECOMMENDED) ⭐

**Modify the design to use internal Block RAM instead of external memory interfaces:**

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

3. **Instantiate Block RAM** in `Top.v` instead of external ports

4. **Result**: I/O count reduces to ~260 pins (fits most FPGAs)

### Solution 2: Use Larger FPGA

**Select an FPGA with more I/O pins:**

| FPGA Part Number | Available I/O | Will Fit? |
|------------------|---------------|-----------|
| XC7A35T          | 250           | ❌ No     |
| XC7A50T          | 250           | ❌ No     |
| XC7A100T         | 300           | ❌ No     |
| XC7A200T         | 500           | ✅ Yes    |
| XC7K325T         | 500           | ✅ Yes    |

**To change FPGA in Vivado:**
1. Tools → Settings → Project Settings → General
2. Change "Part" to a larger FPGA (e.g., XC7A200T)
3. Re-run synthesis and implementation

### Solution 3: Reduce SHA Output Width

**If you don't need all 256 bits of SHA output externally:**

1. **Option A**: Output only 32 bits (hash verification)
   ```verilog
   output [31:0] res_sha256_o  // Instead of [255:0]
   ```
   Saves: 224 I/O pins

2. **Option B**: Use serial output (32-bit bus, 8 clock cycles)
   ```verilog
   output [31:0] res_sha256_o
   output [2:0] word_select
   ```
   Saves: 221 I/O pins

### Solution 4: Minimal I/O Design (4 pins only)

**For the absolute minimal design:**
- Use Block RAM for memories (Solution 1)
- Use serial/minimal output (Solution 3)
- Final I/O count: 4 pins (clk, reset, start_in, state_done)

## How to Use Constraint Files

### In Vivado GUI:
1. Open your Vivado project
2. Click "Add Sources" → "Add or Create Constraints"
3. Add the appropriate `.xdc` file (`RISC_Top.xdc` or `RISC_Top_BRAM.xdc`)
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
