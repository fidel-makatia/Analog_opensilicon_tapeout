# Student Guide: Analog OTA Tapeout Workshop

## Prerequisites

- ngspice (circuit simulation)
- xschem (schematic capture, optional for simulation-only)
- Magic VLSI (layout, DRC, extraction)
- netgen (LVS verification)
- SKY130 PDK installed at `$PDK_ROOT`
- Python 3 with matplotlib (for plotting, optional)

### Install Tools

**macOS (Homebrew):**
```bash
brew install ngspice magic netgen
pip3 install matplotlib numpy
```

**Ubuntu/Debian:**
```bash
sudo apt install ngspice magic netgen-lvs
pip3 install matplotlib numpy
```

**Install SKY130 PDK (using volare):**
```bash
pip3 install volare
mkdir -p ~/pdk
volare enable --pdk-root ~/pdk 0fe599b2afb6708d281543108caf8310912f54af
export PDK_ROOT=~/pdk
```

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
echo 'export PDK_ROOT=~/pdk' >> ~/.zshrc
```

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

### 1.2 Run All Simulations at Once
```bash
export PDK_ROOT=~/pdk    # set your PDK path
make sim                 # runs OP, DC, and AC simulations
```

Or run them individually (see below).

### 1.3 Operating Point Simulation

Verifies all transistors are biased correctly at balanced input (VIN+ = VIN- = 0.9V).

```bash
make sim_op
```

**What happens:** ngspice runs a `.op` analysis with both inputs at 0.9V and IREF = 10uA.

**Check `outputs/sim_op.log` for:**

| Node | Expected | What It Means |
|------|----------|---------------|
| VOUT | ~0.6-0.9V | Output near mid-rail (balanced input) |
| VBIAS | ~0.5-0.7V | M6 diode voltage (NMOS threshold region) |
| VTAIL | ~0.2V | Source of diff pair (M5 in saturation) |
| D_M3 | ~VOUT | Mirror side should match output at balance |
| IREF | 10uA | External reference current |
| VDD current | ~19-20uA | Total supply current (IREF + tail) |

**If VOUT is stuck at VDD or 0V:** The IREF current source polarity may be wrong, or the PDK path is not set.

**Interactive mode (for debugging):**
```bash
cd spice
ngspice ota_tb_op.spice
```
In the ngspice shell:
```
op
print all
print v(VOUT) v(XOTA.VBIAS) v(XOTA.VTAIL)
quit
```

### 1.4 DC Transfer Curve

Sweeps VIN+ from 0.3V to 1.5V while holding VIN- at 0.9V to characterize the input-output relationship.

```bash
make sim_dc
```

**What happens:** ngspice sweeps `VINP` in 1mV steps and records `VOUT`.

**Check `outputs/sim_dc.log` for:**
- `vout_max` — maximum output voltage (should approach VDD)
- `vout_min` — minimum output voltage (should approach VSS)

**Output data:** `outputs/dc_transfer.csv` (columns: VIN+, VOUT)

**What to look for:**
- S-shaped transfer curve centered around VIN+ = 0.9V
- Steep slope in the linear region = high gain
- Output swing from near 0V to near 1.8V

#### Plot DC Transfer Curve

**Option A — ngspice interactive plot:**
```bash
cd spice
ngspice ota_tb_dc.spice
```
In the ngspice shell:
```
run
plot v(VOUT) vs v(VINP) title 'OTA DC Transfer Curve'
```

**Option B — Python/matplotlib:**
```bash
python3 scripts/plot_dc.py
```
This reads `outputs/dc_transfer.csv` and generates `outputs/dc_transfer.png`.

**Option C — gnuplot:**
```bash
gnuplot -e "
  set terminal png size 800,500;
  set output 'outputs/dc_transfer.png';
  set title 'OTA DC Transfer Curve';
  set xlabel 'VIN+ (V)';
  set ylabel 'VOUT (V)';
  set grid;
  plot 'outputs/dc_transfer.csv' using 1:2 with lines lw 2 title 'VOUT'
"
```

### 1.5 AC Gain/Phase Analysis (Bode Plot)

Measures open-loop gain, unity-gain bandwidth (UGB), and phase margin.

```bash
make sim_ac
```

**What happens:** ngspice applies a small-signal AC stimulus at VIN+ and sweeps frequency from 1Hz to 1GHz (100 points/decade) with a 1pF load capacitor.

**Check `outputs/sim_ac.log` for:**

| Parameter | Target | What It Means |
|-----------|--------|---------------|
| dc_gain | 20-35 dB | Low-frequency voltage gain |
| ugb | 1-3 MHz | Frequency where gain drops to 0 dB |
| phase_at_ugb | > -135° | Phase margin = 180° + phase (want > 45°) |

**Output data:** `outputs/ac_bode.csv` (columns: frequency, gain_dB, phase_deg)

#### Plot Bode Plot (Gain + Phase)

**Option A — ngspice interactive plot:**
```bash
cd spice
ngspice ota_tb_ac.spice
```
In the ngspice shell:
```
run
* Gain plot
plot vdb(VOUT) title 'OTA Gain (dB)' xlabel 'Frequency' ylabel 'Gain (dB)'
* Phase plot
plot vp(VOUT)*180/3.14159 title 'OTA Phase (degrees)' xlabel 'Frequency' ylabel 'Phase (deg)'
```

**Option B — Python/matplotlib:**
```bash
python3 scripts/plot_ac.py
```
This reads `outputs/ac_bode.csv` and generates `outputs/ac_bode.png`.

**Option C — gnuplot:**
```bash
gnuplot -e "
  set terminal png size 1000,600;
  set output 'outputs/ac_bode.png';
  set multiplot layout 2,1 title 'OTA Bode Plot';
  set logscale x;
  set grid;
  set xlabel 'Frequency (Hz)';
  set ylabel 'Gain (dB)';
  plot 'outputs/ac_bode.csv' using 1:2 with lines lw 2 title 'Gain';
  set ylabel 'Phase (deg)';
  plot 'outputs/ac_bode.csv' using 1:3 with lines lw 2 lc rgb 'red' title 'Phase';
  unset multiplot
"
```

### 1.6 Understanding the Results

**Gain is too low (< 20 dB):**
- Check that M5/M6 mirror ratio is 1:1 (same W/L)
- Check that PMOS loads (M3/M4) have matching dimensions
- Verify IREF = 10uA (not 100uA — higher current reduces gain)

**UGB is too low (< 1 MHz):**
- Reduce load capacitance or increase bias current
- Check diff pair gm (transconductance)

**Phase margin is low (< 45°):**
- Increase load capacitance to move the dominant pole
- Reduce parasitic capacitance at the output node

**Output not centered at mid-rail:**
- Slight asymmetry is normal for a single-stage OTA
- The exact value depends on device matching in the PDK models

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
