`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:56:37
// Design Name: 
// Module Name: tb_pwm_gen
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

module tb_pwm_gen;

    reg  clk;
    reg  rst_n;
    reg  led_on;
    reg  led_blink;
    wire pwm_out;

    pwm_gen dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .led_on    (led_on),
        .led_blink (led_blink),
        .pwm_out   (pwm_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0; led_on = 0; led_blink = 0;
        repeat(4) @(posedge clk);
        rst_n = 1;

        // DAY: LED fully OFF
        led_on = 0; led_blink = 0;
        repeat(512) @(posedge clk);   // 2 full PWM periods

        // NIGHT: 90% PWM
        led_on = 1; led_blink = 0;
        repeat(512) @(posedge clk);

        // FAULT: blink with 50% PWM
        led_on = 0; led_blink = 1;
        repeat(512) @(posedge clk);

        // Back to DAY
        led_on = 0; led_blink = 0;
        repeat(256) @(posedge clk);

        $finish;
    end

endmodule