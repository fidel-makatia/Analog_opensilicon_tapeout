#!/usr/bin/env python3
"""Plot OTA AC Bode plot (gain + phase) from ngspice wrdata output."""

import sys
import os
import numpy as np

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("Error: matplotlib not installed. Install with: pip3 install matplotlib")
    sys.exit(1)

# Find the CSV file
csv_path = os.path.join(os.path.dirname(__file__), '..', 'outputs', 'ac_bode.csv')
if not os.path.exists(csv_path):
    print(f"Error: {csv_path} not found. Run 'make sim_ac' first.")
    sys.exit(1)

# Load data (ngspice wrdata format: col0=freq, col1=gain_dB, col2=freq, col3=phase_deg)
data = np.loadtxt(csv_path)
freq = data[:, 0]
gain_db = data[:, 1]
phase_deg = data[:, 3]  # column 3 is phase (column 2 is freq repeated)

# Find key metrics
dc_gain = gain_db[0]

# Find UGB (where gain crosses 0 dB)
ugb_idx = None
for i in range(1, len(gain_db)):
    if gain_db[i-1] > 0 and gain_db[i] <= 0:
        # Linear interpolation
        f1, f2 = freq[i-1], freq[i]
        g1, g2 = gain_db[i-1], gain_db[i]
        ugb = f1 + (f2 - f1) * (0 - g1) / (g2 - g1)
        ugb_idx = i
        break

if ugb_idx is None:
    ugb = freq[-1]
    phase_margin = None
else:
    pm_phase = phase_deg[ugb_idx-1] + (phase_deg[ugb_idx] - phase_deg[ugb_idx-1]) * \
               (0 - gain_db[ugb_idx-1]) / (gain_db[ugb_idx] - gain_db[ugb_idx-1])
    phase_margin = 180 + pm_phase

# Create Bode plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 7), sharex=True)
fig.suptitle('OTA Bode Plot (SKY130)', fontsize=14, fontweight='bold')

# Gain plot
ax1.semilogx(freq, gain_db, 'b-', linewidth=2, label='Gain')
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='0 dB')
if ugb_idx:
    ax1.axvline(x=ugb, color='green', linestyle=':', alpha=0.7)
    ax1.annotate(f'UGB = {ugb/1e6:.1f} MHz',
                 xy=(ugb, 0), xytext=(ugb*3, 10),
                 arrowprops=dict(arrowstyle='->', color='green'),
                 fontsize=10, color='green')
ax1.annotate(f'DC Gain = {dc_gain:.1f} dB',
             xy=(freq[5], dc_gain), xytext=(freq[20], dc_gain - 5),
             fontsize=10, color='blue')
ax1.set_ylabel('Gain (dB)', fontsize=12)
ax1.legend(loc='upper right')
ax1.grid(True, which='both', alpha=0.3)
ax1.set_title('Magnitude Response')

# Phase plot
ax2.semilogx(freq, phase_deg, 'r-', linewidth=2, label='Phase')
ax2.axhline(y=-180, color='gray', linestyle='--', alpha=0.5, label='-180°')
if phase_margin is not None:
    ax2.axvline(x=ugb, color='green', linestyle=':', alpha=0.7)
    ax2.annotate(f'PM = {phase_margin:.1f}°',
                 xy=(ugb, -180 + phase_margin), xytext=(ugb*5, -180 + phase_margin + 15),
                 arrowprops=dict(arrowstyle='->', color='green'),
                 fontsize=10, color='green')
ax2.set_xlabel('Frequency (Hz)', fontsize=12)
ax2.set_ylabel('Phase (degrees)', fontsize=12)
ax2.legend(loc='upper right')
ax2.grid(True, which='both', alpha=0.3)
ax2.set_title('Phase Response')

# Print summary
print("=" * 50)
print("  OTA AC Performance Summary")
print("=" * 50)
print(f"  DC Gain:       {dc_gain:.1f} dB")
print(f"  UGB:           {ugb/1e6:.2f} MHz")
if phase_margin is not None:
    print(f"  Phase Margin:  {phase_margin:.1f}°")
print("=" * 50)

plt.tight_layout()

out_path = os.path.join(os.path.dirname(__file__), '..', 'outputs', 'ac_bode.png')
plt.savefig(out_path, dpi=150, bbox_inches='tight')
print(f"Bode plot saved to {out_path}")

try:
    plt.show()
except Exception:
    pass
