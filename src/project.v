/*
 * Single-Stage OTA - TinyTapeout Analog Wrapper
 * Copyright (c) 2025 Fidel Makatia
 * SPDX-License-Identifier: Apache-2.0
 *
 * This is a pure analog design. The actual OTA circuit is implemented
 * in the analog layout domain. This Verilog wrapper satisfies the
 * TinyTapeout digital interface requirement by tying all unused
 * digital outputs to ground.
 *
 * Analog pin mapping:
 *   ua[0] = VIN+  (positive differential input)
 *   ua[1] = VIN-  (negative differential input)
 *   ua[2] = VOUT  (single-ended output)
 *   ua[3] = IREF  (external 10uA reference current)
 */

`default_nettype none

module tt_um_fidel_makatia_analog_ota (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
`ifdef GL_TEST
    input  wire       VPWR,
    input  wire       VGND,
`endif
    inout  wire [5:0] ua
);

    // Tie all unused digital outputs to ground
    assign uo_out  = 8'b0;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Suppress unused input warnings
    wire _unused = &{clk, rst_n, ena, ui_in, uio_in, 1'b0};

endmodule
