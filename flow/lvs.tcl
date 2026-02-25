# ============================================================================
# LVS Script using netgen
# ============================================================================
# Compares extracted layout netlist against reference schematic netlist.
#
# Usage: netgen -batch lvs flow/lvs.tcl
# ============================================================================

puts "Running LVS comparison..."
puts "  Layout netlist:    outputs/ota_extracted.spice"
puts "  Schematic netlist: spice/ota.spice"

lvs "outputs/ota_extracted.spice ota" \
    "spice/ota.spice ota" \
    $::env(PDK_ROOT)/sky130A/libs.tech/netgen/sky130A_setup.tcl \
    outputs/lvs_report.txt

puts ""
puts "============================================================"
puts "  LVS comparison complete."
puts "  Report: outputs/lvs_report.txt"
puts "============================================================"
