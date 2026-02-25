# Student Guide: Analog OTA Tapeout Workshop

## Prerequisites

- ngspice (circuit simulation)
- xschem (schematic capture, optional for simulation-only)
- Magic VLSI (layout, DRC, extraction)
- netgen (LVS verification)
- SKY130 PDK installed at `$PDK_ROOT`

### Quick Install Check
```bash
make check_tools
```

## Session 1: Schematic Design & Simulation

### 1.1 Understand the OTA
Read `workshop_handout.tex` for the circuit architecture:
- M1, M2: NMOS differential pair (W=10u, L=1u)
- M3, M4: PMOS current mirror load (W=20u, L=1u)
- M5: NMOS tail current source (W=8u, L=2u)
- M6: NMOS bias mirror, diode-connected (W=8u, L=2u)

### 1.2 Run Operating Point Simulation
```bash
make sim_op
```
Check `outputs/sim_op.log` for:
- VOUT should be near 0.9V (mid-rail at balanced input)
- VBIAS should be ~0.5-0.7V
- Tail current should be ~10uA

### 1.3 Run DC Transfer Curve
```bash
make sim_dc
```
Observe in `outputs/dc_transfer.csv`:
- Output should swing from ~0.3V to ~1.4V
- Linear region centered around VIN+ = 0.9V

### 1.4 Run AC Analysis
```bash
make sim_ac
```
Check `outputs/sim_ac.log` for:
- DC Gain: 20-35 dB
- Unity-Gain Bandwidth: 1-3 MHz
- Phase margin > 45 degrees

## Session 2: Layout and DRC

### 2.1 Generate Layout Skeleton
```bash
make layout
```

### 2.2 Complete Layout in Magic
```bash
magic -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc mag/ota.mag
```

Layout guidelines:
- Place M1/M2 as common-centroid pair
- Place M3/M4 symmetrically above the diff pair
- Place M5/M6 below the diff pair
- Route with metal1-metal4 only (NO metal5)
- Add guard rings around NMOS and PMOS groups
- Label ports: VINP, VINN, VOUT, IREF, VDD, VSS

### 2.3 Run DRC
```bash
make drc
```
Fix any violations reported in `outputs/drc_report.txt`.

## Session 3: LVS and Tapeout

### 3.1 Extract and Run LVS
```bash
make lvs
```
Check `outputs/lvs_report.txt` - must show "Circuits match uniquely."

### 3.2 Export GDS
```bash
make gds
```
The final GDS file is at `gds/ota.gds`.

### 3.3 Submit to TinyTapeout
1. Push your repo to GitHub
2. Go to https://app.tinytapeout.com/projects/create
3. Sign in with GitHub and submit your repo URL
4. Both `docs` and `gds` CI checks must pass

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ngspice: command not found` | Install ngspice: `brew install ngspice` or `apt install ngspice` |
| `sky130.lib.spice not found` | Set `PDK_ROOT` to your PDK installation path |
| DRC violations | Open layout in Magic, run `drc why` on each error |
| LVS mismatch | Check port labels match the SPICE netlist node names |
| VOUT stuck at VDD or VSS | Check IREF current source polarity and value |
