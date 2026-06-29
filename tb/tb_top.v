`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 17:09:04
// Design Name: 
// Module Name: tb_top
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

module tb_street_light;

    reg        clk;
    reg        rst_n;
    reg  [7:0] ldr_raw;
    wire       pwm_out;
    wire [1:0] state;

    top dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .ldr_raw (ldr_raw),
        .pwm_out (pwm_out),
        .state   (state)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Reset
        rst_n = 0; ldr_raw = 8'd150;
        repeat(5) @(posedge clk);
        rst_n = 1;

        // DAY - bright light, LED OFF
        ldr_raw = 8'd200;
        repeat(20) @(posedge clk);

        // DAY -> NIGHT - light drops below threshold
        ldr_raw = 8'd50;
        repeat(600) @(posedge clk);

        // NIGHT -> FAULT - sensor dies (value too low)
        ldr_raw = 8'd5;
        repeat(600) @(posedge clk);

        // FAULT -> NIGHT - sensor recovers, still dark
        ldr_raw = 8'd50;
        repeat(600) @(posedge clk);

        // NIGHT -> DAY - sun rises
        ldr_raw = 8'd200;
        repeat(20) @(posedge clk);

        // DAY -> FAULT - sensor shorts (value too high)
        ldr_raw = 8'd250;
        repeat(600) @(posedge clk);

        // FAULT -> DAY - sensor recovers, bright
        ldr_raw = 8'd200;
        repeat(20) @(posedge clk);

        $finish;
    end

endmodule
