# ============================================================================
# Analog OTA Tapeout Workshop - Makefile
# ============================================================================
# Single-Stage OTA on SKY130 for TinyTapeout Analog
#
# Quick Start (simulation only, requires ngspice + SKY130 PDK):
#   make sim_op       # Operating point analysis
#   make sim_dc       # DC transfer curve
#   make sim_ac       # AC gain/phase Bode plot
#   make sim          # Run all simulations
#
# Full Flow (requires Magic + netgen):
#   make layout       # Generate layout skeleton
#   make gds          # Export GDS
#   make drc          # Design rule check
#   make extract      # Extract SPICE from layout
#   make lvs          # Layout vs schematic
#   make all          # Complete flow
#
# Utilities:
#   make check_tools  # Verify tool installation
#   make clean        # Remove generated files
#   make help         # Show this help
# ============================================================================

PDK_ROOT ?= /usr/local/share/pdk
export PDK_ROOT

NGSPICE  ?= ngspice
MAGIC    ?= magic
NETGEN   ?= netgen

MAGIC_RC = $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc

.PHONY: all sim sim_op sim_dc sim_ac layout gds drc extract lvs clean help check_tools

all: sim
	@echo ""
	@echo "============================================================"
	@echo "  Simulation complete!"
	@echo "  For layout/GDS/DRC/LVS, complete the layout in Magic first,"
	@echo "  then run: make gds drc lvs"
	@echo "============================================================"

help:
	@echo "============================================================"
	@echo "  Analog OTA Workshop - Available Targets"
	@echo "============================================================"
	@echo ""
	@echo "  Simulation (requires ngspice + SKY130 models):"
	@echo "    make sim_op      - Operating point analysis"
	@echo "    make sim_dc      - DC transfer curve"
	@echo "    make sim_ac      - AC gain/phase (Bode plot)"
	@echo "    make sim         - Run all simulations"
	@echo ""
	@echo "  Layout & Verification (requires Magic + netgen):"
	@echo "    make layout      - Generate layout skeleton"
	@echo "    make gds         - Export GDS for fabrication"
	@echo "    make drc         - Design rule check"
	@echo "    make extract     - Extract SPICE from layout"
	@echo "    make lvs         - Layout vs schematic"
	@echo ""
	@echo "  Utilities:"
	@echo "    make check_tools - Verify tool installation"
	@echo "    make clean       - Remove generated files"
	@echo "============================================================"

# ---- Tool Check ----
check_tools:
	@echo "Checking tool installation..."
	@which $(NGSPICE) > /dev/null 2>&1 && echo "  [OK] ngspice" || echo "  [MISSING] ngspice"
	@which $(MAGIC) > /dev/null 2>&1 && echo "  [OK] magic" || echo "  [MISSING] magic"
	@which $(NETGEN) > /dev/null 2>&1 && echo "  [OK] netgen" || echo "  [MISSING] netgen"
	@if [ -d "$(PDK_ROOT)/sky130A" ]; then \
		echo "  [OK] SKY130 PDK at $(PDK_ROOT)"; \
	else \
		echo "  [MISSING] SKY130 PDK (set PDK_ROOT)"; \
	fi

# ---- Simulation ----
sim: sim_op sim_dc sim_ac
	@echo ""
	@echo "All simulations complete. Check outputs/ for results."

sim_op:
	@echo "========== Operating Point Analysis =========="
	@mkdir -p outputs
	cd spice && $(NGSPICE) -b ota_tb_op.spice 2>&1 | tee ../outputs/sim_op.log
	@echo ""

sim_dc:
	@echo "========== DC Transfer Curve =========="
	@mkdir -p outputs
	cd spice && $(NGSPICE) -b ota_tb_dc.spice 2>&1 | tee ../outputs/sim_dc.log
	@echo ""

sim_ac:
	@echo "========== AC Gain/Phase Analysis =========="
	@mkdir -p outputs
	cd spice && $(NGSPICE) -b ota_tb_ac.spice 2>&1 | tee ../outputs/sim_ac.log
	@echo ""

# ---- Layout ----
layout:
	@echo "========== Generating Layout Skeleton =========="
	@mkdir -p mag
	cd mag && $(MAGIC) -dnull -noconsole -rcfile $(MAGIC_RC) < ../flow/generate_layout.tcl 2>&1 | tee ../outputs/layout.log

# ---- GDS Export ----
gds:
	@echo "========== GDS Export =========="
	@mkdir -p gds outputs
	$(MAGIC) -dnull -noconsole -rcfile $(MAGIC_RC) < flow/gds_export.tcl 2>&1 | tee outputs/gds.log

# ---- Extraction ----
extract:
	@echo "========== SPICE Extraction =========="
	@mkdir -p outputs
	$(MAGIC) -dnull -noconsole -rcfile $(MAGIC_RC) < flow/extract.tcl 2>&1 | tee outputs/extract.log

# ---- DRC ----
drc:
	@echo "========== DRC (Magic) =========="
	@mkdir -p outputs
	$(MAGIC) -dnull -noconsole -rcfile $(MAGIC_RC) < flow/drc.tcl 2>&1 | tee outputs/drc.log

# ---- LVS ----
lvs: extract
	@echo "========== LVS (netgen) =========="
	@mkdir -p outputs
	$(NETGEN) -batch lvs flow/lvs.tcl 2>&1 | tee outputs/lvs.log

# ---- Clean ----
clean:
	rm -f outputs/*.log outputs/*.csv outputs/*.txt outputs/*.spice
	rm -f mag/*.ext mag/*.sim mag/*.nodes
	rm -f gds/*.gds
	@echo "Cleaned all generated files."
