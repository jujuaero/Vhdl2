commandes :
ghdl -a -g --std=08 ual.vhd ualtb.vhd
ghdl -e -fexplicit --ieee=synopsys --std=08 UAL_tb
ghdl -r -fexplicit --ieee=synopsys --std=08 UAL_tb --stop-time=1ms --wave=MyET2tbwave.ghw
