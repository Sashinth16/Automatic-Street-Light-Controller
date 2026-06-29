`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:52:26
// Design Name: 
// Module Name: ldr_sensor
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

module ldr_sensor (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] ldr_raw,      // 0=pitch dark, 255=bright sunlight
    output reg        ldr_dark,     // 1 = night, feed to FSM
    output reg        sensor_fault  // 1 = broken sensor, feed to FSM
);

    // Thresholds
    localparam DARK_THRESH  = 8'd80;   // below this = night
    localparam FAULT_LOW    = 8'd10;   // below this = sensor stuck/dead
    localparam FAULT_HIGH   = 8'd245;  // above this = sensor shorted

    always @(posedge clk) begin
        if (!rst_n) begin
            ldr_dark     <= 1'b0;
            sensor_fault <= 1'b0;
        end else begin
            // Fault detection
            if (ldr_raw < FAULT_LOW || ldr_raw > FAULT_HIGH)
                sensor_fault <= 1'b1;
            else
                sensor_fault <= 1'b0;

            // Dark detection
            if (ldr_raw < DARK_THRESH)
                ldr_dark <= 1'b1;
            else
                ldr_dark <= 1'b0;
        end
    end

endmodule
