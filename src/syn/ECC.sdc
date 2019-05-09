###################################################################

# Created by write_sdc on Thu May  9 11:02:46 2019

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_area 0
set_load -pin_load 1 [get_ports o_mP_valid]
set_load -pin_load 1 [get_ports o_mnP_valid]
set_load -pin_load 1 [get_ports o_mPx]
set_load -pin_load 1 [get_ports o_mPy]
set_load -pin_load 1 [get_ports o_mnPx]
set_load -pin_load 1 [get_ports o_mnPy]
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 1  [get_ports clk]
set_input_delay -clock clk  -max 1  [get_ports rst]
set_input_delay -clock clk  -max 1  [get_ports i_m_P_valid]
set_input_delay -clock clk  -max 1  [get_ports i_nP_valid]
set_input_delay -clock clk  -max 1  [get_ports i_mode]
set_input_delay -clock clk  -max 1  [get_ports i_a]
set_input_delay -clock clk  -max 1  [get_ports i_b]
set_input_delay -clock clk  -max 1  [get_ports i_prime]
set_input_delay -clock clk  -max 1  [get_ports i_Px]
set_input_delay -clock clk  -max 1  [get_ports i_Py]
set_input_delay -clock clk  -max 1  [get_ports i_m]
set_input_delay -clock clk  -max 1  [get_ports i_nPx]
set_input_delay -clock clk  -max 1  [get_ports i_nPy]
set_output_delay -clock clk  -min 0.5  [get_ports o_mP_valid]
set_output_delay -clock clk  -min 0.5  [get_ports o_mnP_valid]
set_output_delay -clock clk  -min 0.5  [get_ports o_mPx]
set_output_delay -clock clk  -min 0.5  [get_ports o_mPy]
set_output_delay -clock clk  -min 0.5  [get_ports o_mnPx]
set_output_delay -clock clk  -min 0.5  [get_ports o_mnPy]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst]
set_drive 1  [get_ports i_m_P_valid]
set_drive 1  [get_ports i_nP_valid]
set_drive 1  [get_ports i_mode]
set_drive 1  [get_ports i_a]
set_drive 1  [get_ports i_b]
set_drive 1  [get_ports i_prime]
set_drive 1  [get_ports i_Px]
set_drive 1  [get_ports i_Py]
set_drive 1  [get_ports i_m]
set_drive 1  [get_ports i_nPx]
set_drive 1  [get_ports i_nPy]
