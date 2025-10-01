# SHA-256 RISC-V Co-processor Constraint File
# This file provides timing and I/O constraints for the design

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

# SHA-256 Result Output (256 bits)
set_property IOSTANDARD LVCMOS33 [get_ports res_sha256_o*]

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
# NOTE: IMPORTANT - I/O PIN COUNT ISSUE
##############################################################################
# This design requires 404 I/O pins total:
#   - 147 input pins (clk, reset, start_in, DMAD_*, DMAI_*)
#   - 257 output pins (state_done, res_sha256_o[255:0])
#
# Your current FPGA has only 328 available I/O sites.
#
# SOLUTIONS:
# 1. Use a larger FPGA with more I/O pins (e.g., XC7A200T instead of XC7A100T)
# 2. Use Block RAM (BRAM) for memories instead of external connections:
#    - Remove DMAD_* and DMAI_* external connections
#    - Instantiate Block RAM IP cores for instruction and data memory
#    - This reduces I/O count by 144 pins (72 inputs)
# 3. Reduce res_sha256_o width if partial results are acceptable
# 4. Use serial interfaces (SPI, UART) instead of parallel I/O for data transfer
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
