# ============================================================================
# Magic DRC Script for OTA
# ============================================================================
# Usage: magic -dnull -noconsole \
#          -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \
#          < flow/drc.tcl
# ============================================================================

puts "Loading OTA layout for DRC..."

load mag/ota

select top cell
drc check
drc catchup

set drc_count [drc count]

puts ""
puts "============================================================"
puts "  DRC Results: $drc_count violation(s)"
puts "============================================================"

if {$drc_count == 0} {
    puts "  >>> DRC CLEAN <<<"
} else {
    puts "  >>> DRC VIOLATIONS FOUND <<<"
    puts ""
    drc why
}

# Save report
set fp [open "outputs/drc_report.txt" w]
puts $fp "DRC Report for OTA Layout"
puts $fp "Total violations: $drc_count"
close $fp

puts "  Report saved to outputs/drc_report.txt"
puts "============================================================"

quit
