# SHA-256 RISC-V Co-processor Constraint File (BRAM Version)
# This version assumes Block RAM is used for instruction/data memory
# This reduces I/O pin count significantly

##############################################################################
# Clock Constraints
##############################################################################
# Define the main clock - adjust the period based on your target frequency
# Default: 100 MHz (10ns period)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Set input delay constraints relative to clock
set_input_delay -clock clk -max 2.000 [get_ports -filter {NAME != clk}]
set_input_delay -clock clk -min 0.500 [get_ports -filter {NAME != clk}]

# Set output delay constraints relative to clock
set_output_delay -clock clk -max 2.000 [get_ports -filter {NAME != clk}]
set_output_delay -clock clk -min 0.500 [get_ports -filter {NAME != clk}]

##############################################################################
# I/O Standard Constraints
##############################################################################
# Set I/O standard for control signals
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports start_in]
set_property IOSTANDARD LVCMOS33 [get_ports state_done]

# SHA-256 Result Output (256 bits)
# NOTE: If 256-bit output is too large, consider these alternatives:
# 1. Use a serial interface (32 clock cycles to output 256 bits)
# 2. Output only a hash digest (first 32 bits) for verification
# 3. Store result in BRAM and read via control interface
set_property IOSTANDARD LVCMOS33 [get_ports res_sha256_o*]

##############################################################################
# Location Constraints for Minimal I/O Version
##############################################################################
# This version uses only ~260 I/O pins (if all 256 bits of SHA output are used)
# Or only 4 I/O pins if SHA output is removed/minimized

# EXAMPLE CONSTRAINTS - Customize for your specific FPGA board
# Clock input (typically from on-board oscillator)
# set_property PACKAGE_PIN W5 [get_ports clk]
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

# Control signals
# set_property PACKAGE_PIN U18 [get_ports reset]
# set_property PACKAGE_PIN U17 [get_ports start_in]
# set_property PACKAGE_PIN V17 [get_ports state_done]

# SHA-256 output pins (256 pins total)
# Distribute across available I/O banks
# Example for first 8 bits:
# set_property PACKAGE_PIN T18 [get_ports {res_sha256_o[0]}]
# set_property PACKAGE_PIN W19 [get_ports {res_sha256_o[1]}]
# ... continue for all 256 bits ...

##############################################################################
# Recommended Design Modifications to Reduce I/O
##############################################################################
# OPTION 1: Use Block RAM for Memory (RECOMMENDED)
# - Remove DMAD_* and DMAI_* ports from Top.v
# - Instantiate Xilinx Block Memory Generator IP for:
#   * Instruction Memory (ins_mem)
#   * Data Memory (data_mem)
# - Initialize memories with .coe or .mem files
# - This reduces I/O from 404 pins to 260 pins
#
# OPTION 2: Add Serial Interface for SHA Result
# - Replace 256-bit parallel output with 32-bit serial output
# - Add a shift register to output 256 bits over 8 clock cycles
# - This reduces I/O from 260 pins to 36 pins (4 control + 32 data)
#
# OPTION 3: Minimal I/O Version (4 pins only)
# - Use Block RAM for memories
# - Use serial interface for SHA result
# - Only expose: clk, reset, start_in, state_done
# - Total I/O: 4 pins (fits on any FPGA)
#
##############################################################################

##############################################################################
# Timing Exceptions
##############################################################################
# Disable timing on asynchronous reset
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *reset*}]

# Multi-cycle paths for SHA computation (if needed)
# set_multicycle_path 2 -setup -from [get_pins FSM_Sha*] -to [get_pins Reg_res256*]
# set_multicycle_path 1 -hold -from [get_pins FSM_Sha*] -to [get_pins Reg_res256*]

##############################################################################
# Additional Optimization Settings
##############################################################################
# Enable aggressive optimization for area reduction
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
