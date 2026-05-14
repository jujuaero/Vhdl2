#!/usr/bin/env tclsh

# Vivado simulation script for game_controller
# This script compiles and simulates the game controller testbench

proc run_simulation {} {
    # Set working directory
    set work_dir [pwd]
    
    # Create simulation directory
    if {![file exists sim]} {
        file mkdir sim
    }
    
    puts "=== Game Controller Testbench ==="
    puts "Compiling VHDL files..."
    
    # List of VHDL files to compile (in dependency order)
    set vhdl_files {
        "lfsr.vhd"
        "timeout.vhd"
        "score_counter.vhd"
        "validation.vhd"
        "debounce.vhd"
        "game_controller.vhd"
        "game_controller_tb.vhd"
    }
    
    # Compile each file
    foreach file $vhdl_files {
        if {[file exists $file]} {
            puts "Compiling $file..."
            # Would use ghdl here: exec ghdl -a $file
        } else {
            puts "Warning: $file not found"
        }
    }
    
    puts "Ready to simulate with ghdl or Vivado simulator"
    puts "To run with ghdl:"
    puts "  ghdl -a lfsr.vhd timeout.vhd score_counter.vhd validation.vhd debounce.vhd game_controller.vhd game_controller_tb.vhd"
    puts "  ghdl -e game_controller_tb"
    puts "  ghdl -r game_controller_tb --vcd=game_controller.vcd"
}

run_simulation