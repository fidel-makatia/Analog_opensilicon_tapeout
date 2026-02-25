#!/usr/bin/env python3
"""Plot OTA DC transfer curve from ngspice wrdata output."""

import sys
import os
import numpy as np

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("Error: matplotlib not installed. Install with: pip3 install matplotlib")
    sys.exit(1)

# Find the CSV file
csv_path = os.path.join(os.path.dirname(__file__), '..', 'outputs', 'dc_transfer.csv')
if not os.path.exists(csv_path):
    print(f"Error: {csv_path} not found. Run 'make sim_dc' first.")
    sys.exit(1)

# Load data (ngspice wrdata format: col0=VINP, col1=VOUT)
data = np.loadtxt(csv_path)
vinp = data[:, 0]
vout = data[:, 1]

# Compute numerical derivative (small-signal gain)
dv_out = np.gradient(vout, vinp)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 8), sharex=True,
                                gridspec_kw={'height_ratios': [2, 1]})
fig.suptitle('OTA DC Transfer Curve (SKY130)', fontsize=14, fontweight='bold')

# Transfer curve
ax1.plot(vinp, vout, 'b-', linewidth=2, label='VOUT')
ax1.axhline(y=0.9, color='gray', linestyle='--', alpha=0.5, label='VDD/2 = 0.9V')
ax1.axvline(x=0.9, color='gray', linestyle=':', alpha=0.5, label='VIN+ = 0.9V')
ax1.set_ylabel('VOUT (V)', fontsize=12)
ax1.set_ylim(-0.1, 1.9)
ax1.legend(loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_title('Input-Output Transfer')

# Gain curve (dVout/dVin)
ax2.plot(vinp, np.abs(dv_out), 'r-', linewidth=2, label='|dVOUT/dVIN|')
ax2.set_xlabel('VIN+ (V)', fontsize=12)
ax2.set_ylabel('Voltage Gain (V/V)', fontsize=12)
ax2.set_ylim(bottom=0)
ax2.legend(loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_title('Small-Signal Gain vs. Input')

plt.tight_layout()

out_path = os.path.join(os.path.dirname(__file__), '..', 'outputs', 'dc_transfer.png')
plt.savefig(out_path, dpi=150, bbox_inches='tight')
print(f"DC transfer plot saved to {out_path}")

# Also try to display
try:
    plt.show()
except Exception:
    pass
