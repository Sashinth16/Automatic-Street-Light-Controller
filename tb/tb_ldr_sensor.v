`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:53:19
// Design Name: 
// Module Name: tb_ldr_sensor
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

module tb_ldr_sensor;

    reg        clk;
    reg        rst_n;
    reg  [7:0] ldr_raw;
    wire       ldr_dark;
    wire       sensor_fault;

    ldr_sensor dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .ldr_raw      (ldr_raw),
        .ldr_dark     (ldr_dark),
        .sensor_fault (sensor_fault)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0; ldr_raw = 8'd128;
        repeat(4) @(posedge clk);
        rst_n = 1;

        ldr_raw = 8'd200;
        repeat(3) @(posedge clk);

        ldr_raw = 8'd50;
        repeat(5) @(posedge clk);

        ldr_raw = 8'd80;
        repeat(3) @(posedge clk);

        ldr_raw = 8'd79;
        repeat(3) @(posedge clk);

        ldr_raw = 8'd5;
        repeat(5) @(posedge clk);

        ldr_raw = 8'd250;
        repeat(5) @(posedge clk);

        ldr_raw = 8'd180;
        repeat(5) @(posedge clk);

        $finish;
    end

endmodule