# ============================================================================
# OTA Layout Generation Script for Magic VLSI
# ============================================================================
# Creates the physical layout for the single-stage OTA using SKY130 PDK.
#
# Usage:
#   magic -dnull -noconsole \
#     -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \
#     < flow/generate_layout.tcl
#
# NOTE: This script provides a starting framework. Interactive refinement
# in Magic may be required to achieve DRC-clean layout.
#
# TinyTapeout Analog Constraints:
#   - Tile size: 160um x 225um (1x2 tile)
#   - Metal 5 is PROHIBITED (reserved for TT power distribution)
#   - VDD/VSS power stripes: vertical metal4, >= 1.2um wide
#   - Pad resistance < 500 ohm
# ============================================================================

# Create new cell
cellname rename (UNNAMED) ota

# ---- Device Placement ----
# The OTA layout follows this floor plan (bottom to top):
#
#   VSS rail (metal4 stripe, bottom)
#   M5 (NMOS tail 8u/2u)  |  M6 (NMOS bias 8u/2u, diode)
#   M1 (NMOS diff+ 10u/1u) | M2 (NMOS diff- 10u/1u)
#   M3 (PMOS load 20u/1u)  | M4 (PMOS load 20u/1u)
#   VDD rail (metal4 stripe, top)

puts "============================================================"
puts "  OTA Layout Generation"
puts "============================================================"
puts ""
puts "  This script creates a skeleton layout for the OTA."
puts "  Interactive completion in Magic is required for:"
puts "    1. Placing parameterized SKY130 devices"
puts "    2. Drawing guard rings"
puts "    3. Routing interconnects"
puts "    4. Adding port labels"
puts "    5. DRC cleanup"
puts ""
puts "  To complete the layout interactively:"
puts "    1. Open Magic: magic -rcfile \$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"
puts "    2. Load this cell: load ota"
puts "    3. Place devices from sky130_fd_pr library"
puts "    4. Route with metal1-metal4 (NO metal5)"
puts "    5. Add labels: VINP, VINN, VOUT, IREF, VDD, VSS"
puts "    6. Run DRC: drc check"
puts "============================================================"

# ---- Draw boundary (160um x 225um tile) ----
box 0 0 160um 225um
paint comment

# ---- VDD power stripe (metal4, top, vertical) ----
box 78um 10um 82um 215um
paint metal4
label VDD FreeSans 1um 0 0 0 center metal4

# ---- VSS power stripe (metal4, bottom area, vertical) ----
box 5um 10um 9um 215um
paint metal4
label VSS FreeSans 1um 0 0 0 center metal4

# ---- Port labels (metal3, routed to analog pads) ----
# VIN+ pad connection area
box 20um 100um 30um 105um
paint metal3
label VINP FreeSans 1um 0 0 0 center metal3

# VIN- pad connection area
box 130um 100um 140um 105um
paint metal3
label VINN FreeSans 1um 0 0 0 center metal3

# VOUT pad connection area
box 130um 170um 140um 175um
paint metal3
label VOUT FreeSans 1um 0 0 0 center metal3

# IREF pad connection area
box 20um 30um 30um 35um
paint metal3
label IREF FreeSans 1um 0 0 0 center metal3

# ---- Save layout ----
save mag/ota

puts ""
puts "  Skeleton layout saved to mag/ota.mag"
puts "  Complete the layout interactively in Magic."
puts "============================================================"

quit
