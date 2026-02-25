# ============================================================================
# Magic SPICE Extraction Script for OTA
# ============================================================================
# Extracts a SPICE netlist from the layout for LVS comparison.
#
# Usage: magic -dnull -noconsole \
#          -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \
#          < flow/extract.tcl
# ============================================================================

puts "Extracting SPICE netlist from OTA layout..."

load mag/ota

select top cell
extract all
ext2spice lvs
ext2spice -o outputs/ota_extracted.spice

puts ""
puts "============================================================"
puts "  Extraction Complete"
puts "  SPICE netlist: outputs/ota_extracted.spice"
puts "============================================================"

quit
