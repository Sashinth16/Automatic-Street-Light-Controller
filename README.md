
# Automatic Street Light Controller — FSM-Based Verilog Design

**Platform:** Xilinx Vivado | **Language:** Verilog HDL | **Clock:** 100 MHz  
**Author:** Sashinth M K | B.Tech Electrical Engineering, 2nd Year | IIT Kharagpur

---

## Overview

A fully synthesizable, simulation-verified automatic street light controller designed using a **3-state Moore Finite State Machine** in Verilog. The system reads ambient light via an LDR sensor interface, drives an LED through a PWM generator, and handles sensor fault conditions — all verified through behavioral simulation on Xilinx Vivado.

Built as a structured HDL design exercise covering sensor interfacing, FSM design, PWM generation, and hierarchical module integration.

---

## System Architecture

```
                    ┌─────────────────────────────────────────────┐
                    │                  top.v                      │
                    │                                             │
  ldr_raw[7:0] ───► │  ┌─────────────┐    ┌─────────────────┐   │
                    │  │  ldr_sensor │    │  fsm_controller │   │
                    │  │             │    │                 │   │
                    │  │  DARK_THRESH│───►│  DAY  → NIGHT  │   │
                    │  │   = 80      │    │  NIGHT → FAULT  │   │
                    │  │  FAULT_LOW  │    │  FAULT → DAY   │   │
                    │  │   = 10      │    │                 │   │
                    │  │  FAULT_HIGH │    └────────┬────────┘   │
                    │  │   = 245     │             │led_on       │
                    │  └─────────────┘             │led_blink    │
                    │         │ldr_dark             ▼            │
                    │         │sensor_fault  ┌─────────────┐    │──► pwm_out
                    │         └─────────────►│   pwm_gen   │    │
                    │                        │             │    │──► state[1:0]
                    │                        │ NIGHT: 90%  │    │
                    │                        │ FAULT: blink│    │
                    │                        └─────────────┘    │
                    └─────────────────────────────────────────────┘
```

---

## FSM State Diagram

```
                         sensor_fault
              ┌──────────────────────────────┐
              │                              │
              ▼          ldr_dark            │
         ┌─────────┐ ──────────────────► ┌──────────┐
         │   DAY   │                     │  NIGHT   │
         │ LED OFF │ ◄────────────────── │  LED ON  │
         └─────────┘    !ldr_dark        │  90% PWM │
              │                          └──────────┘
              │ sensor_fault                  │
              │                               │ sensor_fault
              ▼                               ▼
         ┌─────────────────────────────────────────┐
         │                 FAULT                   │
         │           LED BLINK (50% PWM)           │
         └─────────────────────────────────────────┘
                    │                    │
          !fault + bright      !fault + dark
                    │                    │
                    ▼                    ▼
                  DAY                 NIGHT
```

| State | Encoding | `led_on` | `led_blink` | Condition |
|-------|----------|----------|-------------|-----------|
| DAY   | `2'b00`  | 0        | 0           | `ldr_raw ≥ 80`, no fault |
| NIGHT | `2'b01`  | 1        | 0           | `ldr_raw < 80`, no fault |
| FAULT | `2'b10`  | 0        | 1           | `ldr_raw < 10` or `> 245` |

---

## Module Breakdown

### `ldr_sensor.v` — LDR Sensor Interface
Converts 8-bit raw ADC reading to digital control signals.

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `DARK_THRESH` | 80 | Below this → Night mode |
| `FAULT_LOW` | 10 | Sensor disconnected / dead |
| `FAULT_HIGH` | 245 | Sensor shorted |

```
ldr_raw[7:0] ──► [ Threshold Comparator ] ──► ldr_dark
                 [ Fault Detector       ] ──► sensor_fault
```

- Registered outputs — glitch-free, synchronous to clock
- Fault detection takes priority over dark detection
- `ldr_raw < 10` AND `ldr_raw > 245` both assert `sensor_fault`

---

### `fsm_controller.v` — 3-State Moore FSM
Core control logic. Outputs depend only on current state (Moore machine).

```verilog
// State Encoding
localparam DAY   = 2'b00;
localparam NIGHT = 2'b01;
localparam FAULT = 2'b10;
```

- Two always blocks: state register (sequential) + next-state logic (combinational)
- FAULT has highest priority in state transitions
- Safe recovery: FAULT exits to correct state based on `ldr_dark` value
- Synchronous active-low reset → defaults to DAY

---

### `pwm_gen.v` — PWM Generator
Generates PWM signal for LED brightness control and fault blinking.

| Mode | Duty Cycle | Mechanism |
|------|-----------|-----------|
| DAY | 0% | Output forced low |
| NIGHT | ~90% | 8-bit counter vs `DUTY_NIGHT = 230` |
| FAULT | 50% gated | 8-bit counter vs `DUTY_BLINK = 128`, gated by blink divider |

```
pwm_counter[7:0]: 0 ──────────────── 230 ──── 255
                  │████████████████████│       │
                  │     HIGH (90%)     │  LOW  │
                                       ▲
                               DUTY_NIGHT threshold
```

- PWM frequency = 100MHz / 256 = **~390 kHz**
- Blink gate toggled by `blink_counter[4]` — visible blink rate in simulation

---

### `top.v` — System Integration
Wires all three modules together. Clean hierarchical instantiation.

```
Inputs  : clk, rst_n, ldr_raw[7:0]
Outputs : pwm_out, state[1:0]
```

Internal wires: `ldr_dark`, `sensor_fault`, `led_on`, `led_blink`

---

## File Structure

```
auto-street-light-controller/
│
├── src/
│   ├── ldr_sensor.v          # LDR sensor interface with fault detection
│   ├── fsm_controller.v      # 3-state Moore FSM — core control logic
│   ├── pwm_gen.v             # PWM generator for LED brightness + blink
│   └── top.v                 # Top-level integration module
│
├── sim/
│   ├── tb_ldr_sensor.v       # LDR sensor testbench — threshold + fault tests
│   ├── tb_fsm_controller.v   # FSM testbench — all 6 transition tests
│   ├── tb_pwm_gen.v          # PWM testbench — DAY/NIGHT/FAULT waveforms
│   └── tb_street_light.v     # Integrated top-level testbench
│
├── screenshots/
│   ├── fsm_state_transitions.png
│   ├── ldr_sensor_verified.png
│   ├── pwm_verified.png
│   └── full_system_simulation.png
│
└── README.md
```

---

## Simulation Results

### FSM State Transitions — `tb_fsm_controller`

All 6 state transitions verified at 100 MHz:

```
t=0ns    : RESET  → DAY   (state=00, led_on=0, led_blink=0) ✓
t=40ns   : DAY    → NIGHT (ldr_dark=1)                      ✓
t=130ns  : NIGHT  → FAULT (sensor_fault=1)                  ✓
t=210ns  : FAULT  → NIGHT (fault clears, still dark)        ✓
t=255ns  : NIGHT  → DAY   (ldr_dark=0)                      ✓
t=290ns  : DAY    → FAULT (sensor_fault=1)                  ✓
t=370ns  : FAULT  → DAY   (fault clears, still bright)      ✓
```

### LDR Sensor — `tb_ldr_sensor`

| Input | ldr_dark | sensor_fault | Result |
|-------|----------|--------------|--------|
| 200   | 0        | 0            | ✅ DAY — normal bright |
| 50    | 1        | 0            | ✅ NIGHT — dark |
| 80    | 0        | 0            | ✅ Boundary — threshold not crossed |
| 79    | 1        | 0            | ✅ One below — NIGHT triggers |
| 5     | 1        | 1            | ✅ FAULT LOW — sensor dead |
| 250   | 0        | 1            | ✅ FAULT HIGH — sensor shorted |
| 180   | 0        | 0            | ✅ Recovery — back to DAY |

### PWM Generator — `tb_pwm_gen`

| Phase | `pwm_out` behaviour | Verified |
|-------|---------------------|----------|
| DAY | Flat 0 — no pulses | ✅ |
| NIGHT | Dense pulses — 90% duty cycle | ✅ |
| FAULT | Gated pulse bursts — blink visible | ✅ |

### Integrated System — `tb_street_light`

Full end-to-end sequence verified: `ldr_raw` drives FSM through all states, `pwm_out` responds correctly across the complete test sequence.

---

## How to Run in Xilinx Vivado

**1. Create Project**
```
File → New Project → RTL Project → Verilog
Board: Any (simulation only — no constraints needed)
```

**2. Add Sources**
```
Add Sources → Add or create design sources
→ ldr_sensor.v, fsm_controller.v, pwm_gen.v, top.v

Add Sources → Add or create simulation sources
→ tb_street_light.v (set as top for simulation)
```

**3. Set Simulation Runtime**
```
Simulation Settings → Simulation tab
→ xsim.simulate.runtime = 30000ns
```

**4. Run Simulation**
```
Flow Navigator → Run Simulation → Run Behavioral Simulation
```

**5. Add Waveform Signals**
```
In waveform window, add:
- clk, rst_n
- ldr_raw       [Radix: Unsigned Decimal]
- state[1:0]    [Radix: Unsigned Decimal]
- pwm_out
```

**6. Zoom and Verify**
```
Zoom Fit → verify state transitions 0→1→2→1→0→2→0
Zoom into NIGHT region → verify 90% PWM duty cycle
Zoom into FAULT region → verify blink gating pattern
```

---

## Design Decisions

**Why Moore FSM over Mealy?**  
Outputs depend only on current state — no combinational path from input to output. Cleaner timing, no glitches on output transitions, easier to verify.

**Why synchronous reset?**  
Xilinx FPGAs infer flip-flops more efficiently with synchronous reset. Avoids asynchronous glitches during power-up.

**Why registered LDR outputs?**  
Raw comparator outputs are combinational and can glitch with noisy ADC values. Registering `ldr_dark` and `sensor_fault` gives the FSM clean, stable inputs on every clock edge.

**Why 8-bit PWM counter?**  
256 steps gives fine enough brightness resolution for LED dimming. At 100 MHz: PWM frequency = ~390 kHz, well above human flicker perception (~60 Hz) and most LED driver requirements.

---

## Technical Specifications

| Parameter | Value |
|-----------|-------|
| Clock Frequency | 100 MHz |
| Reset | Active-low, synchronous |
| LDR ADC Width | 8-bit (0–255) |
| Night Threshold | < 80 |
| Fault Range | < 10 or > 245 |
| PWM Resolution | 8-bit (256 steps) |
| PWM Frequency | ~390 kHz |
| NIGHT Duty Cycle | ~90% (230/256) |
| FAULT Duty Cycle | 50% gated |
| FSM Type | Moore |
| FSM States | 3 (DAY, NIGHT, FAULT) |

---

## Skills Demonstrated

- Finite State Machine design (Moore) in synthesizable Verilog
- Hierarchical module design and integration
- PWM generation with variable duty cycle
- Sensor interface design with fault detection
- Testbench writing — stimulus generation and output verification
- Xilinx Vivado simulation and waveform analysis
- Clean HDL coding practices — parameterized thresholds, default state handling, combinational sensitivity lists

---

*Simulated and verified on Xilinx Vivado 2023. All modules written in synthesizable Verilog-2001.*
