#!/usr/bin/env python3
"""Generate all OTA simulation plots at once."""

import subprocess
import sys
import os

script_dir = os.path.dirname(os.path.abspath(__file__))

scripts = [
    ('DC Transfer Curve', 'plot_dc.py'),
    ('AC Bode Plot', 'plot_ac.py'),
]

failed = False
for name, script in scripts:
    path = os.path.join(script_dir, script)
    print(f"\n--- Plotting {name} ---")
    result = subprocess.run([sys.executable, path], cwd=script_dir)
    if result.returncode != 0:
        print(f"  FAILED: {name}")
        failed = True

print("\n" + "=" * 50)
if not failed:
    print("  All plots generated in outputs/")
    print("    outputs/dc_transfer.png")
    print("    outputs/ac_bode.png")
else:
    print("  Some plots failed. Run 'make sim' first.")
print("=" * 50)
