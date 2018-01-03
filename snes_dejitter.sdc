### CPU clock constraints ###

create_clock -period 21.477272MHz -name mclk [get_ports MCLK_XTAL_i]
create_clock -period 21.28137MHz -name mclk_alt [get_ports MCLK_EXT_i]

set_clock_groups -exclusive -group {mclk} -group {mclk_alt}
