`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:56:00
// Design Name: 
// Module Name: pwm_gen
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

module pwm_gen (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        led_on,       // from FSM: NIGHT state
    input  wire        led_blink,    // from FSM: FAULT state
    output reg         pwm_out       // to LED
);

    // PWM counter: 8-bit = 256 steps
    // At 100MHz: PWM frequency = 100MHz/256 = ~390kHz
    localparam DUTY_NIGHT = 8'd230;  // ~90% duty cycle for NIGHT
    localparam DUTY_BLINK = 8'd128;  // 50% duty cycle when blinking

    // Blink divider: toggles every 2^23 clocks = ~12Hz at 100MHz
    localparam BLINK_DIV  = 4;

    reg [7:0]          pwm_counter;
    reg [BLINK_DIV:0]  blink_counter;
    reg                blink_gate;   // 1 = blink ON half, 0 = blink OFF half

    // PWM counter
    always @(posedge clk) begin
        if (!rst_n)
            pwm_counter <= 8'd0;
        else
            pwm_counter <= pwm_counter + 1;
    end

    // Blink divider
    always @(posedge clk) begin
        if (!rst_n) begin
            blink_counter <= 0;
            blink_gate    <= 1'b0;
        end else begin
            blink_counter <= blink_counter + 1;
            blink_gate    <= blink_counter[BLINK_DIV];
        end
    end

    // PWM output logic
    always @(*) begin
        if (!led_on && !led_blink)
            pwm_out = 1'b0;                               // DAY: LED OFF
        else if (led_on)
            pwm_out = (pwm_counter < DUTY_NIGHT);         // NIGHT: 90% PWM
        else
            pwm_out = blink_gate && (pwm_counter < DUTY_BLINK); // FAULT: blink 50%
    end

endmodule
