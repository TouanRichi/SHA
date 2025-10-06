# SHA-256 RISC-V Co-processor Constraint File (Reduced I/O Version)
# This file provides timing and I/O constraints for the design
# SHA-256 output removed - result is written to data memory instead

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
# Set default I/O standard for all ports
# LVCMOS33 is commonly used - adjust based on your FPGA board specifications
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports start_in]
set_property IOSTANDARD LVCMOS33 [get_ports state_done]

# AXI Data Memory Interface
set_property IOSTANDARD LVCMOS33 [get_ports DMAD_addr_in*]
set_property IOSTANDARD LVCMOS33 [get_ports DMAD_data_in*]
set_property IOSTANDARD LVCMOS33 [get_ports DMAD_wea_in*]

# AXI Instruction Memory Interface
set_property IOSTANDARD LVCMOS33 [get_ports DMAI_addr_in*]
set_property IOSTANDARD LVCMOS33 [get_ports DMAI_data_in*]
set_property IOSTANDARD LVCMOS33 [get_ports DMAI_wea_in*]

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
# Add false paths or multi-cycle paths if needed
# Example: set_false_path -from [get_ports reset] -to [all_registers]

##############################################################################
# Additional Constraints
##############################################################################
# Disable timing analysis on asynchronous reset
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *reset*}]

# Set maximum delay for critical paths if needed
# set_max_delay 10 -from [get_pins ...] -to [get_pins ...]
