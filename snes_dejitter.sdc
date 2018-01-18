create_clock -period 21.477272MHz -name mclk_n [get_ports MCLK_XTAL_i]
create_generated_clock -source [get_ports MCLK_XTAL_i] -invert -name gclk [get_ports GCLK_o]

create_clock -period 21.28137MHz -name mclk_alt [get_ports MCLK_EXT_i]
create_generated_clock -source [get_ports MCLK_EXT_i] -name gclk_alt [get_ports GCLK_o] -add

set_clock_groups -exclusive -group {mclk_n gclk} -group {mclk_alt gclk_alt}

# CSYNC_i is launched on falling edge of GCLK_o
set_input_delay 3 -clock gclk -clock_fall [get_ports CSYNC_i]
set_input_delay 3 -clock gclk_alt -clock_fall [get_ports CSYNC_i] -add_delay

# Ignore feedthrough path timing
set_false_path -to [get_ports MCLK_XTAL_o]

# Ignore following clock transfers
set_false_path -from [get_clocks {mclk_n mclk_alt}] -to [get_ports GCLK_o]

# Ignore timing of the following signals
set_false_path -from [get_ports MCLK_SEL_i]
set_false_path -to [get_ports CSYNC_o]
