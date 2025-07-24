# SDC file for RISCV_processador

# Define the main clock (CLOCK_50) with a period of 20ns (50MHz)
create_clock -name {CLOCK_50} -period 20.000 [get_ports {CLOCK_50}]

# Optionally, you can define generated clocks if your clock_divider creates a new clock domain
# However, for a simple tick, it's usually not necessary to define it as a clock, but rather as a data path.
# If you were to treat tick_1hz as a clock for other parts of your design, you would do something like:
# create_generated_clock -name {tick_1hz} -source [get_ports {CLOCK_50}] -divide_by 50000000 [get_registers {clock_divider:clk_div_1hz|tick}]

# Set input and output delays (optional, but good practice for real-world designs)
# set_input_delay -clock {CLOCK_50} -max 5.0 [all_inputs]
# set_output_delay -clock {CLOCK_50} -max 5.0 [all_outputs]

# False path for asynchronous resets (if applicable and if reset is truly asynchronous)
# set_false_path -from [get_ports {reset}] -to [all_registers]