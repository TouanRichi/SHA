# Power Optimization Guide - SHA-256 RISC-V Co-processor

**Date**: Power optimization recommendations  
**Goal**: Reduce energy consumption for logic in FPGA implementation

## Current Design Characteristics

The current design uses:
- **148 I/O pins** (clk, reset, start_in, state_done, DMAD_*, DMAI_*)
- **Full combinational logic** for SHA-256 computation
- **5-stage RISC-V pipeline** running continuously
- **Multiple adders and multiplexers** operating in parallel
- **Large register banks** (37 SHA-256 registers + RISC-V registers)

## Power Consumption Analysis

Energy consumption in FPGA designs comes from:
1. **Dynamic power** (70-80% of total): Clock tree, logic switching, I/O transitions
2. **Static power** (20-30% of total): Leakage current
3. **I/O power**: Driving external pins

## Optimization Strategies

### 1. Clock Gating ⭐ (HIGH IMPACT)

**Recommendation**: Add clock gating to reduce dynamic power when modules are idle.

#### Implementation for SHA-256 FSM:

```verilog
// Add to FSM_Sha.v or Top.v
wire sha_clk_enable;
assign sha_clk_enable = start_sha_w3 | (state != IDLE); // FSM active

// Gated clock for SHA modules
wire sha_gated_clk;
assign sha_gated_clk = clk & sha_clk_enable;

// Use sha_gated_clk for SHA registers and computation units
```

**Benefits**:
- Reduces clock tree power by 40-60% when SHA is idle
- Simple to implement
- No functional changes needed

#### Files to modify:
1. **Top.v**: Add clock gating logic
2. **FSM_Sha.v**: Use gated clock
3. Connect gated clock to: Reg_A through Reg_H, Reg0-15, K_register, etc.

**Estimated savings**: 30-40% dynamic power reduction

---

### 2. Operand Isolation (MEDIUM IMPACT)

**Problem**: Multiplexers and adders continue switching even when outputs are not used.

**Solution**: Add enable signals to prevent unnecessary transitions.

```verilog
// Example for SHA adders
wire [31:0] adder_result;
wire adder_enable;

assign adder_enable = (state == COMPUTE) ? 1'b1 : 1'b0;
assign adder_result = adder_enable ? (a + b) : 32'b0;
```

**Files to modify**:
- Adder_Sha.v, Adder1.v through Adder4.v
- Ch.v, Maj.v, Sigma0.v, Sigma1.v

**Estimated savings**: 10-15% dynamic power reduction

---

### 3. Pipeline Register Optimization (MEDIUM IMPACT)

**Current issue**: RISC-V pipeline runs continuously even when no instructions execute.

**Solution**: Add pipeline stall/freeze capability when SHA computation is active.

```verilog
// Add to Top.v
wire pipeline_enable;
assign pipeline_enable = !start_sha_w3; // Freeze pipeline during SHA

// Modify Reg1-Reg4 to use enable signal
always @(posedge clk) begin
    if (!reset) begin
        // Reset logic
    end else if (pipeline_enable && state_start) begin
        // Normal operation
    end
    // else: hold current values
end
```

**Files to modify**:
- Reg1.v, Reg2.v, Reg3.v, Reg4.v - add enable input

**Estimated savings**: 15-20% dynamic power reduction when SHA is active

---

### 4. Reduce Clock Frequency (HIGH IMPACT)

**Current**: Design uses 100 MHz clock (from constraint file)

**Recommendation**: Lower clock frequency for power-constrained applications.

```tcl
# In RISC_Top.xdc
# Change from 100 MHz to 50 MHz (or lower if timing allows)
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
```

**Benefits**:
- Power scales approximately linearly with frequency
- 50 MHz → 50% power reduction
- 25 MHz → 75% power reduction

**Trade-off**: Reduced throughput (longer computation time)

**Files to modify**:
- RISC_Top.xdc - change clock period
- RISC_Top_BRAM.xdc - change clock period

**Estimated savings**: 50% at 50 MHz, 75% at 25 MHz

---

### 5. Register Retiming (MEDIUM IMPACT)

**Implementation in Vivado**: Enable register retiming during synthesis.

```tcl
# Add to synthesis options in Vivado
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
```

**Benefits**:
- Reduces combinational path delays
- Allows lower voltage operation
- May enable lower clock frequency

**Estimated savings**: 5-10% power reduction

---

### 6. Memory Power Optimization (LOW-MEDIUM IMPACT)

**Current**: Block RAMs (ins_mem, data_mem) always enabled.

**Solution**: Use selective enable signals.

```verilog
// Modify memory instantiations
ins_mem ins_mem(
    .clka(clk),
    .addra(addr_ins[12:0]),
    .dina(data_ins),
    .douta(inst),
    .ena(pipeline_enable), // Only enable when needed
    .wea(wea_ins)
);
```

**Files to modify**:
- Top.v - update ins_mem and data_mem instantiations

**Estimated savings**: 5-10% memory power reduction

---

### 7. I/O Standard Optimization (LOW IMPACT)

**Current**: All I/O uses LVCMOS33 (3.3V)

**Recommendation**: Use lower voltage I/O standards if board supports.

```tcl
# In RISC_Top.xdc - change LVCMOS33 to LVCMOS25 or LVCMOS18
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports reset]
# ... etc
```

**Benefits**:
- LVCMOS18 uses ~70% less I/O power than LVCMOS33
- LVCMOS25 uses ~45% less I/O power than LVCMOS33

**Trade-off**: Requires board-level voltage support

**Estimated savings**: 3-5% total power reduction (I/O is small portion)

---

### 8. Unused Logic Trimming (LOW IMPACT)

**Already done**: All unused AES and SHA-512 logic has been removed (507 lines).

**Additional**: Use synthesis optimization directives.

```tcl
# In Vivado synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE RuntimeOptimized [get_runs synth_1]
```

---

## Recommended Implementation Priority

### Phase 1: Quick Wins (No code changes)
1. ✅ **Reduce clock frequency** (RISC_Top.xdc) - 50% power @ 50 MHz
2. ✅ **Enable register retiming** (Vivado settings) - 5-10% power
3. ✅ **Change I/O standards** (RISC_Top.xdc, if board supports) - 3-5% power

**Total savings**: **55-65% with no HDL changes**

### Phase 2: Clock Gating (Moderate changes)
4. Add clock gating for SHA modules - 30-40% additional savings
5. Add memory enable optimization - 5-10% additional savings

**Total cumulative savings**: **70-80%**

### Phase 3: Advanced Optimizations (Significant changes)
6. Add operand isolation - 10-15% additional savings
7. Add pipeline freeze capability - 15-20% additional savings

**Total cumulative savings**: **85-90%**

---

## Implementation Guide

### Step 1: Immediate (No HDL changes needed)

```bash
# 1. Update constraint file for 50 MHz
# Edit Source/RISC_Top.xdc line 9:
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

# 2. In Vivado TCL console:
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE RuntimeOptimized [get_runs synth_1]

# 3. Re-run synthesis and implementation
```

### Step 2: Add Clock Gating (Recommended)

Create a new file for clock gating logic:

```verilog
// Source/clock_gating.v
module clock_gating (
    input clk,
    input enable,
    output gated_clk
);
    // Simple AND gate for clock gating
    assign gated_clk = clk & enable;
endmodule
```

Then modify Top.v to instantiate and use gated clocks.

### Step 3: Measure Power

Use Vivado's Power Analysis tools:
1. Run implementation
2. Tools → Report → Report Power
3. Compare before/after optimization

---

## Expected Results

| Optimization | Implementation Effort | Power Savings | Notes |
|--------------|----------------------|---------------|-------|
| 50 MHz clock | Low (XDC file only) | 50% | Immediate |
| Register retiming | Low (Vivado setting) | 5-10% | Automatic |
| I/O standards | Low (XDC file) | 3-5% | Board dependent |
| Clock gating | Medium (HDL changes) | 30-40% | Best ROI |
| Memory enable | Low (HDL changes) | 5-10% | Easy |
| Operand isolation | High (HDL changes) | 10-15% | Time consuming |
| Pipeline freeze | Medium (HDL changes) | 15-20% | Moderate effort |

**Recommended starting point**: Phase 1 (clock frequency + retiming) for 55-65% power reduction with minimal effort.

---

## Design Trade-offs

- **Clock frequency reduction**: Increases computation time proportionally
- **Clock gating**: May increase design complexity and area slightly
- **Pipeline freeze**: Reduces overall system throughput
- **Lower I/O voltages**: Requires compatible FPGA board

---

## Next Steps

1. Start with constraint file modifications (clock frequency)
2. Enable synthesis optimizations in Vivado
3. Measure baseline power consumption
4. Implement clock gating for SHA modules
5. Re-measure and validate power savings
6. Consider additional optimizations based on power budget

For questions or implementation help, refer to Xilinx UG907 (Vivado Power Analysis and Optimization Guide).
