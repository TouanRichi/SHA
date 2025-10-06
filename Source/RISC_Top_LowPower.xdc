# SHA-256 RISC-V Co-processor Constraint File - LOW POWER VERSION
# This file provides power-optimized timing and I/O constraints
# Reduces clock frequency to 50 MHz for ~50% power savings

##############################################################################
# Clock Constraints - LOW POWER (50 MHz)
##############################################################################
# Clock period: 20ns (50 MHz) - half the speed of default 100 MHz
# This reduces dynamic power consumption by approximately 50%
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

# Set input delay constraints relative to clock
set_input_delay -clock clk -max 4.000 [get_ports -filter {NAME != clk}]
set_input_delay -clock clk -min 1.000 [get_ports -filter {NAME != clk}]

# Set output delay constraints relative to clock
set_output_delay -clock clk -max 4.000 [get_ports -filter {NAME != clk}]
set_output_delay -clock clk -min 1.000 [get_ports -filter {NAME != clk}]

##############################################################################
# I/O Standard Constraints - LOW POWER
##############################################################################
# Using LVCMOS18 (1.8V) instead of LVCMOS33 (3.3V) for ~70% I/O power savings
# NOTE: Your FPGA board must support 1.8V I/O banks for this to work
# If your board only supports 3.3V, change LVCMOS18 to LVCMOS33

# Control signals
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports start_in]
set_property IOSTANDARD LVCMOS18 [get_ports state_done]

# AXI Data Memory Interface
set_property IOSTANDARD LVCMOS18 [get_ports DMAD_addr_in*]
set_property IOSTANDARD LVCMOS18 [get_ports DMAD_data_in*]
set_property IOSTANDARD LVCMOS18 [get_ports DMAD_wea_in*]

# AXI Instruction Memory Interface
set_property IOSTANDARD LVCMOS18 [get_ports DMAI_addr_in*]
set_property IOSTANDARD LVCMOS18 [get_ports DMAI_data_in*]
set_property IOSTANDARD LVCMOS18 [get_ports DMAI_wea_in*]

# NOTE: res_sha256_o output has been removed to reduce I/O pin count
# SHA-256 result is now written to data memory (addresses 0x00-0x1C)
# This reduces total I/O from 404 pins to 148 pins

##############################################################################
# Location Constraints (EXAMPLE - MUST BE CUSTOMIZED FOR YOUR FPGA BOARD)
##############################################################################
# Uncomment and modify these based on your specific FPGA board
# You MUST match these to your actual board connections

# Example clock pin location (adjust for your board)
# set_property PACKAGE_PIN W5 [get_ports clk]

# Example reset pin location
# set_property PACKAGE_PIN U18 [get_ports reset]

# Example start_in pin location
# set_property PACKAGE_PIN U17 [get_ports start_in]

# Example state_done pin location
# set_property PACKAGE_PIN V17 [get_ports state_done]

##############################################################################
# Power Optimization Constraints
##############################################################################
# Enable power optimization in implementation
set_property POWER_OPT_DESIGN true [current_design]

# Set default switching activity for power analysis
# Lower values = more conservative power estimates
set_switching_activity -default_static_probability 0.5
set_switching_activity -default_toggle_rate 12.5

##############################################################################
# NOTE: I/O PIN COUNT - REDUCED VERSION
##############################################################################
# This design now requires 148 I/O pins total:
#   - 147 input pins (clk, reset, start_in, DMAD_*, DMAI_*)
#   - 1 output pin (state_done)
#
# SHA-256 result (256 bits) is written to data memory instead of output port
# This reduces I/O count from 404 pins to 148 pins - fits most FPGAs!
#
# FURTHER REDUCTIONS (if still needed):
# 1. Use Block RAM (BRAM) for memories instead of external connections:
#    - Remove DMAD_* and DMAI_* external connections (144 pins)
#    - Instantiate Block RAM IP cores for instruction and data memory
#    - Final I/O count: 4 pins (clk, reset, start_in, state_done)
# 2. Use serial interfaces (SPI, UART) for memory programming
#
##############################################################################

##############################################################################
# Timing Exceptions
##############################################################################
# Add false paths for reset to reduce unnecessary timing constraints
set_false_path -from [get_ports reset] -to [all_registers]

# Multi-cycle paths for slow paths (if needed)
# Uncomment if timing fails and path can tolerate multiple cycles
# set_multicycle_path -setup 2 -from [get_pins ...] -to [get_pins ...]

##############################################################################
# Additional Power Optimization Constraints
##############################################################################
# Disable timing analysis on asynchronous reset
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *reset*}]

# Set maximum delay for critical paths if needed
# set_max_delay 10 -from [get_pins ...] -to [get_pins ...]

# Enable automatic clock gating insertion during synthesis
# This can be done via synthesis options:
# set_property STEPS.SYNTH_DESIGN.ARGS.GATED_CLOCK_CONVERSION auto [get_runs synth_1]

##############################################################################
# Power Budget Constraints (Optional)
##############################################################################
# Set power budget for design (in Watts)
# Uncomment and adjust based on your power requirements
# set_property POWER_BUDGET 1.0 [current_design]

##############################################################################
# Usage Notes
##############################################################################
# POWER SAVINGS with this file compared to default 100 MHz design:
# - Clock frequency reduction (50 MHz): ~50% dynamic power savings
# - LVCMOS18 I/O (if supported): ~70% I/O power savings (~3-5% total)
# - Total expected savings: ~50-55% overall power reduction
#
# PERFORMANCE TRADE-OFF:
# - Computation time increases by 2x (due to 50 MHz vs 100 MHz)
# - If 50 MHz is still too fast, consider 25 MHz (period 40.000) for 75% power savings
#
# FOR MAXIMUM POWER SAVINGS:
# 1. Use this file for 50-55% savings (no HDL changes)
# 2. Implement clock gating in HDL (see POWER_OPTIMIZATION.md) for additional 30-40%
# 3. Total potential savings: 70-80% with moderate effort
##############################################################################
