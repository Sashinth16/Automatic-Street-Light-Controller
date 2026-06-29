`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2026 16:46:18
// Design Name: 
// Module Name: fsm_controller
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

module fsm_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ldr_dark,
    input  wire        sensor_fault,
    output reg  [1:0]  state,
    output reg         led_on,
    output reg         led_blink
);

    localparam DAY   = 2'b00;
    localparam NIGHT = 2'b01;
    localparam FAULT = 2'b10;

    reg [1:0] next_state;

    // State register
    always @(posedge clk) begin
        if (!rst_n)
            state <= DAY;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            DAY: begin
                if (sensor_fault)       next_state = FAULT;
                else if (ldr_dark)      next_state = NIGHT;
            end
            NIGHT: begin
                if (sensor_fault)       next_state = FAULT;
                else if (!ldr_dark)     next_state = DAY;
            end
            FAULT: begin
                if (!sensor_fault)
                    next_state = ldr_dark ? NIGHT : DAY;
            end
            default: next_state = DAY;
        endcase
    end

    // Output logic (Moore)
    always @(*) begin
        led_on    = 1'b0;
        led_blink = 1'b0;
        case (state)
            DAY:   begin led_on = 1'b0; led_blink = 1'b0; end
            NIGHT: begin led_on = 1'b1; led_blink = 1'b0; end
            FAULT: begin led_on = 1'b0; led_blink = 1'b1; end
            default: begin led_on = 1'b0; led_blink = 1'b0; end
        endcase
    end

endmodule
