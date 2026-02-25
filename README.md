# Analog OpenSilicon Tapeout

3-Session Analog IC Tapeout Workshop: Single-Stage OTA using SKY130 for TinyTapeout.

## Circuit

A 6-transistor single-stage Operational Transconductance Amplifier (OTA):

| Device | Type | W/L | Fingers | Role |
|--------|------|-----|---------|------|
| M1 | nfet_01v8 | 10u/1u | 2x5u | Diff pair (+) |
| M2 | nfet_01v8 | 10u/1u | 2x5u | Diff pair (-) |
| M3 | pfet_01v8 | 20u/1u | 4x5u | Load (diode) |
| M4 | pfet_01v8 | 20u/1u | 4x5u | Load (mirror) |
| M5 | nfet_01v8 | 8u/2u | 1 | Tail current |
| M6 | nfet_01v8 | 8u/2u | 1 | Bias mirror |

**Specs:** VDD=1.8V, IREF=10uA, Gain=20-35dB, UGB=1-3MHz, Power=~18uW

## TinyTapeout Analog Pins

| Pin | Signal | Description |
|-----|--------|-------------|
| ua[0] | VIN+ | Positive differential input |
| ua[1] | VIN- | Negative differential input |
| ua[2] | VOUT | Single-ended output |
| ua[3] | IREF | External 10uA reference current |

## Repository Structure

```
├── spice/              # SPICE netlists and testbenches
│   ├── ota.spice       # Core OTA subcircuit
│   ├── ota_tb_op.spice # Operating point testbench
│   ├── ota_tb_dc.spice # DC transfer curve testbench
│   └── ota_tb_ac.spice # AC Bode plot testbench
├── xschem/             # Xschem schematic files
├── src/                # TinyTapeout Verilog wrapper
│   └── project.v       # Digital stub (outputs tied low)
├── mag/                # Magic layout files
├── flow/               # Backend flow scripts
│   ├── generate_layout.tcl
│   ├── drc.tcl
│   ├── extract.tcl
│   ├── lvs.tcl
│   └── gds_export.tcl
├── gds/                # Generated GDS output
├── docs/               # Documentation
│   ├── info.md         # TinyTapeout project page
│   └── STUDENT_GUIDE.md
├── info.yaml           # TinyTapeout project config
├── Makefile            # Build system
└── workshop_handout.tex # LaTeX workshop document
```

## Quick Start

### Prerequisites
- ngspice, Magic VLSI, netgen
- SKY130 PDK (`export PDK_ROOT=/path/to/pdk`)

### Run Simulations
```bash
export PDK_ROOT=~/pdk              # set your SKY130 PDK path
make sim_op    # Operating point
make sim_dc    # DC transfer curve
make sim_ac    # AC gain/phase Bode plot
make sim       # All simulations
```

### Plot Results
```bash
pip3 install matplotlib numpy      # one-time setup
make plot      # Generate all plots (DC + AC)
make plot_dc   # DC transfer curve only
make plot_ac   # AC Bode plot only
```
Plots are saved to `outputs/dc_transfer.png` and `outputs/ac_bode.png`.

You can also plot interactively in ngspice:
```bash
cd spice
ngspice ota_tb_dc.spice            # then: run; plot v(VOUT) vs v(VINP)
ngspice ota_tb_ac.spice            # then: run; plot vdb(VOUT); plot vp(VOUT)
```

### Full Backend Flow
```bash
make layout    # Generate layout skeleton
# Complete layout interactively in Magic
make gds       # Export GDS
make drc       # Design rule check
make lvs       # Layout vs schematic
```

## Workshop Sessions

1. **Session 1** - Schematic & Simulation (xschem + ngspice)
2. **Session 2** - Layout & DRC (Magic VLSI)
3. **Session 3** - LVS & Tapeout (netgen + GDS export)

## Toolchain

| Tool | Purpose |
|------|---------|
| ngspice | Circuit simulation (OP, DC, AC) |
| xschem | Schematic capture |
| Magic VLSI | Layout, DRC, extraction |
| netgen | LVS verification |
