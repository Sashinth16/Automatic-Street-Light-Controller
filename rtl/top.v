`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 17:08:03
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  ldr_raw,
    output wire        pwm_out,
    output wire [1:0]  state
);

    wire ldr_dark;
    wire sensor_fault;
    wire led_on;
    wire led_blink;

    ldr_sensor u_ldr (
        .clk          (clk),
        .rst_n        (rst_n),
        .ldr_raw      (ldr_raw),
        .ldr_dark     (ldr_dark),
        .sensor_fault (sensor_fault)
    );

    fsm_controller u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .ldr_dark     (ldr_dark),
        .sensor_fault (sensor_fault),
        .state        (state),
        .led_on       (led_on),
        .led_blink    (led_blink)
    );

    pwm_gen u_pwm (
        .clk          (clk),
        .rst_n        (rst_n),
        .led_on       (led_on),
        .led_blink    (led_blink),
        .pwm_out      (pwm_out)
    );

endmodule