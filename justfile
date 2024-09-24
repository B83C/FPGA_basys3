
sim:
    mkdir -p sim
    @echo "Compiling Verilog file..."
    cd sim; verilator --binary -j 16  --build tb.sv --trace -I../src/ --timing
    @echo "Running simulation..."
    cd sim; ./obj_dir/Vtb
    @echo "Simulation complete. Run 'just wave' to view the waveform."

wave: sim
    @echo "Opening GTKWave..."
    cd sim; gtkwave waveform.vcd

build:
    /home/b83c/tools/Xilinx/Vivado/2024.1/bin/vivado -nolog -nojournal -mode batch -notrace -quiet -source  build.tcl 

upload: 
    openFPGALoader -b basys3 ./target/BASYS3.bit
    
