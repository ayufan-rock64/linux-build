setenv blink_power 'led power off; sleep 0.1; led power on'

# first read existing loader
run blink_power
sf probe
${devtype} read ${kernel_addr_r} 40 1f40;

# erase flash
run blink_power blink_power
sf erase 8000 3e8000

# write flash
run blink_power blink_power blink_power
sf write ${kernel_addr_r} 8000 3e8000

# blink forever
while true; do run blink_power; sleep 1; done
