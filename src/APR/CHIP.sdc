###################################################################

# Created by write_sdc on Sat Jun  1 15:56:19 2019

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_fanout 20 [current_design]
set_max_area 0
set_load -pin_load 1 [get_ports o_data_valid]
set_load -pin_load 1 [get_ports o_Pointx]
set_load -pin_load 1 [get_ports o_Pointy]
create_clock [get_ports clk]  -period 20  -waveform {0 10}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 1  [get_ports clk]
set_input_delay -clock clk  -max 1  [get_ports rst]
set_input_delay -clock clk  -max 1  [get_ports i_data_valid]
set_input_delay -clock clk  -max 1  [get_ports i_mode]
set_input_delay -clock clk  -max 1  [get_ports i_a]
set_input_delay -clock clk  -max 1  [get_ports i_prime]
set_input_delay -clock clk  -max 1  [get_ports i_Pointx]
set_input_delay -clock clk  -max 1  [get_ports i_Pointy]
set_input_delay -clock clk  -max 1  [get_ports i_mul]
set_output_delay -clock clk  -min 0.5  [get_ports o_data_valid]
set_output_delay -clock clk  -min 0.5  [get_ports o_Pointx]
set_output_delay -clock clk  -min 0.5  [get_ports o_Pointy]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst]
set_drive 1  [get_ports i_data_valid]
set_drive 1  [get_ports i_mode]
set_drive 1  [get_ports i_a]
set_drive 1  [get_ports i_prime]
set_drive 1  [get_ports i_Pointx]
set_drive 1  [get_ports i_Pointy]
set_drive 1  [get_ports i_mul]
