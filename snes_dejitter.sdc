create_clock -period 21.477272MHz -name mclk_ntsc [get_ports MCLK_XTAL_i]
create_generated_clock -source [get_ports MCLK_XTAL_i] -name gclk_ntsc [get_ports GCLK_o]

create_clock -period 21.28137MHz -name mclk_pal [get_ports MCLK_EXT_i]
create_generated_clock -source [get_ports MCLK_EXT_i] -name gclk_pal [get_ports GCLK_o] -add

set_clock_groups -exclusive -group {mclk_ntsc gclk_ntsc} -group {mclk_pal gclk_pal}

# CSYNC_i is launched on falling edge of GCLK_o
set_input_delay 3 -clock gclk_ntsc -clock_fall [get_ports CSYNC_i]
set_false_path -from [get_ports CSYNC_i] -to [get_clocks {mclk_pal gclk_pal}]

# Constrain feedthrough path timing to 10ns
set_max_delay 10 -to [get_ports MCLK_XTAL_o]
set_max_delay 10 -from [get_ports {MCLK_XTAL_i MCLK_EXT_i}] -to [get_ports GCLK_o]

# Ignore timing of the following signals
set_false_path -from [get_ports {MCLK_SEL_i}]
set_false_path -to [get_ports {CSYNC_o SC_o}]
