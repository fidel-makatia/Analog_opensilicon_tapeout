## How it works

This is a single-stage Operational Transconductance Amplifier (OTA) implemented in SKY130 130nm CMOS. The circuit consists of 6 transistors:

- **NMOS differential input pair** (M1, M2): W/L = 10um/1um, 2 fingers each
- **PMOS current mirror active load** (M3 diode-connected, M4 mirror): W/L = 20um/1um, 4 fingers each
- **NMOS tail current source** (M5): W/L = 8um/2um, biased by mirror
- **NMOS bias reference** (M6, diode-connected): W/L = 8um/2um, sets bias from external IREF

An external 10uA reference current applied to ua[3] flows through the diode-connected M6, establishing a gate bias voltage (VBIAS). M5 mirrors this current as the ~10uA tail current for the differential pair, split equally (~5uA per branch).

The differential input voltage (ua[0] minus ua[1]) is amplified and converted to a single-ended output at ua[2].

**Specifications:** VDD=1.8V, DC gain 20-35dB, UGB 1-3MHz, power ~18uW, output swing ~0.3-1.4V.

## How to test

1. Connect VDD (1.8V) and VSS (GND) from the TinyTapeout power rails
2. Apply a 10uA current sink to ua[3] (IREF) -- use a precision current source or a 180kohm resistor from VDD to ua[3]
3. Apply ~0.9V DC bias to both ua[0] (VIN+) and ua[1] (VIN-) as common-mode voltage
4. Apply a small differential signal between ua[0] and ua[1] (e.g., 10mV AC)
5. Observe the amplified output on ua[2] (VOUT)
6. For AC characterization, sweep frequency and measure gain/phase on ua[2]

## External hardware

- Precision current source (10uA) or 180kohm resistor from VDD to ua[3] for IREF biasing
- Signal generator for differential input stimulus
- Oscilloscope or spectrum analyzer to measure output on ua[2]
- Optional: bias tee for AC measurements at ua[2]
