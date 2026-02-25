# ============================================================================
# GDS Export Script for OTA using Magic
# ============================================================================
# Usage: magic -dnull -noconsole \
#          -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \
#          < flow/gds_export.tcl
# ============================================================================

puts "Exporting OTA layout to GDS..."

load mag/ota

select top cell
gds write gds/ota.gds

puts ""
puts "============================================================"
puts "  GDS Export Complete"
puts "  GDS file: gds/ota.gds"
puts "============================================================"

# Also extract for LVS
puts "Extracting SPICE netlist..."
extract all
ext2spice lvs
ext2spice -o outputs/ota_extracted.spice
puts "  Extracted netlist: outputs/ota_extracted.spice"

quit
