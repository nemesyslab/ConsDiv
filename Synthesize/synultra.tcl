proc getSlack {} {
    set matchSlack 0
    set number 0

    set infile [open "lastTiming.log" r]
    while { [gets $infile line] >= 0 } {
	# regexp {slack.+(?[-+](\d+(\.\d*)?|\.\d+))} $line match number
	# regexp {([-+]?(\d+|\.\d+|\d+\.\d*))($|[^+-.])} $line match number
	set pattern "slack.* +(\\-?(\\d+(\\.\\d*)?|\\.\\d+))"
	regexp $pattern $line match number
    }
    close $infile

    # puts "slack match = $match"
    # puts "slack number = $number"

    return $number
}

proc getArea {} {
    set matchSlack 0
    set number 0

    set infile [open "lastArea.log" r]
    while { [gets $infile line] >= 0 } {
	set pattern "Total cell area.* +((\\d+(\\.\\d*)?|\\.\\d+))"
	regexp $pattern $line match number
    }
    close $infile

    # puts "area match = $match"
    # puts "area number = $number"

    return $number
}

proc writeNewRun {fileName} {
    set fileId [open $fileName a+]
    puts $fileId "--- new run ---\n"
    close $fileId
}

set clkPer 0.1
set lowerBound 0
set try 4

file delete "compile.log"
file delete "timing.log"
file delete "area.log"
file delete "check.log"

# source period.tcl
# puts $period

# set search_path [list . /synopsys/libraries/syn/]
# set search_path [list . /ECE/Synopsys/libraries/syn]
set search_path [list . ../files ./../common]

suppress_message LBDB-272
read_lib 28nm.lib

set target_library [list ./../common/sc12mcpp140_cln28hpc_base_svt_c30_ssg_cworst_max_0p90v_125c.db]
set_dont_use slow/SEDFF*
# set link_library [list * slow.db dw_foundation.sldb]
set link_library [list * sc12mcpp140_cln28hpc_base_svt_c30_ssg_cworst_max_0p90v_125c.db]

define_design_lib USER -path ./work/
set moduleList [list wrapper divByN]
foreach module $moduleList {
    analyze -format verilog -lib USER $module.v
}

elaborate wrapper -lib USER >> compile.log
current_design wrapper
# set_wire_load_model -name Mine
# set_wire_load_mode top

link >> compile.log

current_design divByN
uniquify >> compile.log
# set_wire_load_model -name Mine

write -f ddc -hier -output wrapper.ddc wrapper

set bestClkPer 1000
set bestArea 10000000
while {$try > 0} {
    remove_design wrapper -hier
    # remove_design 

    puts "trying = $clkPer"
    set startDate [date]

    writeNewRun "compile.log"
    writeNewRun "timing.log"
    writeNewRun "area.log"
    writeNewRun "check.log"

    # file delete "wrapper.db"
    read_ddc wrapper.ddc
    link >> compile.log

    current_design wrapper 
    set_max_area 0
    set_wire_load_model -name "W40000"
    set_wire_load_mode top
    create_clock -name clk -period $clkPer clk
    compile_ultra -no_autoungroup -timing_high_effort_script >> compile.log

    current_design divByN
    ungroup -all -flatten

    current_design wrapper
    compile_ultra -incremental -timing_high_effort_script >> compile.log

    report_timing >> timing.log
    report_timing > lastTiming.log
    check_design >> check.log

    current_design divByN
    report_area >> area.log
    report_area > lastArea.log

    set slack [getSlack]
    set newArea [getArea]
    set newClkPer [expr {$clkPer -$slack}]
    puts "obtained = $newClkPer and $newArea\n"

    set finishDate [date]

    if {$newClkPer < $bestClkPer ||
	$newClkPer == $bestClkPer && $newArea < $bestArea} {

	write -f verilog -hier -output bestsdivByN.vg divByN

	set bestClkPer $newClkPer
	set bestArea $newArea

	file rename -force -- lastTiming.log bestsTiming.log
	file rename -force -- lastArea.log bestsArea.log
	echo "startDate = $startDate" > bestsSummary.log
	echo "finishDate = $finishDate" >> bestsSummary.log
	echo "bestClkPer = $newClkPer  bestArea = $newArea" >> bestsSummary.log
    }

    set try [expr {$try -1}]

    if {$slack < 0} {
	set lowerBound $clkPer
    }

    if {$try == 1} {
	set clkPer [expr {$bestClkPer * 0.8}]
    } else {
	set clkPer [expr {($bestClkPer +$lowerBound)/2.}]
    }
}

quit

