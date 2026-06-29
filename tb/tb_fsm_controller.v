`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:49:03
// Design Name: 
// Module Name: tb_fsm_controller
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

module tb_fsm_controller;

    reg        clk;
    reg        rst_n;
    reg        ldr_dark;
    reg        sensor_fault;
    wire [1:0] state;
    wire       led_on;
    wire       led_blink;

    // Instantiate DUT
    fsm_controller dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .ldr_dark     (ldr_dark),
        .sensor_fault (sensor_fault),
        .state        (state),
        .led_on       (led_on),
        .led_blink    (led_blink)
    );


    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
 
        rst_n = 0; ldr_dark = 0; sensor_fault = 0;
        repeat(4) @(posedge clk);
        rst_n = 1;

        repeat(3) @(posedge clk);

        ldr_dark = 1;
        repeat(5) @(posedge clk);

        sensor_fault = 1;
        repeat(8) @(posedge clk);

        sensor_fault = 0;
        repeat(5) @(posedge clk);

        ldr_dark = 0;
        repeat(5) @(posedge clk);

        sensor_fault = 1;
        repeat(8) @(posedge clk);

        sensor_fault = 0;
        repeat(5) @(posedge clk);

        $finish;
    end

endmodule
