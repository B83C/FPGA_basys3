set_param general.maxThreads 16

set partNum xc7a35tcpg236-1
set outputDir ./target
set automatic_compile_point 1
# file mkdir $outputDir
# set files [glob -nocomplain "$outputDir/*"]
# if {[llength $files] != 0} {
# 	puts "Deleting contents of $outputDir "
# 	file delete -force {*}[glob -directory $outputDir *];
# } else {
# 	puts "$outputDir is empty"
# }


read_verilog -sv -quiet [glob src/*.sv]
read_xdc -quiet [glob src/xdc/*.xdc]
set outputDir ./target
# read_checkpoint -auto_incremental -incremental $outputDir/post_route.dcp

# read_checkpoint -incremental $outputDir/post_synth.dcp
synth_design -top main -part $partNum -incremental_mode quick
# write_checkpoint -force $outputDir/post_synth.dcp
# report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
# report_utilization -file $outputDir/post_synth_util.rpt

# read_checkpoint -auto_incremental -incremental $outputDir/post_opt.dcp
opt_design
# write_checkpoint -force $outputDir/post_opt.dcp

read_checkpoint -incremental -auto_incremental $outputDir/post_route.dcp
place_design
# report_clock_utilization -file $outputDir/clock_util.rpt

if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
	puts "Found setup timing violations => running physical optimisation"
	phys_opt_design
}
# write_checkpoint -force $outputDir/post_place.dcp
# report_timing_summary -file $outputDir/post_place_timing_summary.rpt
# report_utilization -file $outputDir/post_place_util.rpt

# read_checkpoint -auto_incremental -incremental $outputDir/post_route.dcp
route_design -directive Explore -ultrathreads
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt

write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true
write_bitstream -force $outputDir/BASYS3.bit
