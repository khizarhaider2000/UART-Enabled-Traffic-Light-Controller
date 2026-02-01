
# 🚦 UART-Enabled Traffic Light Controller (VHDL)

**Course:** CEG3155 – Digital Systems II
**Group:** 23
**Authors:** Khizar Haider, Vaibhav Bhadrachalam
**Platform:** Intel DE2 FPGA
**Language:** VHDL (Structural / RTL)
**Toolchain:** Intel Quartus II

---

## 📌 Project Overview

This project implements a **real-time traffic light controller** integrated with a **hardware UART debug interface**.
The system transmits **human-readable ASCII messages** over serial communication whenever the traffic light state changes, enabling remote monitoring and diagnostics without physical inspection of the hardware.

The design combines:

* Finite State Machines (FSMs)
* Clock domain crossing
* Hardware-level UART communication
* Fully structural RTL design (no behavioral top-level)

---

## 🎯 Key Features

### 🚥 Traffic Light Control

* 4-state FSM:

  * Main Green / Side Red
  * Main Yellow / Side Red
  * Main Red / Side Green
  * Main Red / Side Yellow
* Human-readable timing (1 Hz clock)
* Configurable durations via DIP switches
* Side-street car sensor input (SSCS)
* One-hot LED outputs for clarity

### 📡 UART Debug Interface

* 8-N-1 UART protocol
* Default baud rate: **9600**
* Transmits messages on **every state transition**
* Messages include:

  * `"Mg Sr\r"`
  * `"My Sr\r"`
  * `"Mr Sg\r"`
  * `"Mr Sy\r"`
* Implemented fully in hardware (no CPU)

### 🧱 Modular Architecture

* Independent FSMs for traffic control and UART
* Clear separation of concerns
* Safe clock domain division (1 Hz vs 50 MHz)

---

## 🧠 System Architecture

**Clock Domains**

* **50 MHz:** UART core, baud generator, UART FSM
* **1 Hz:** Traffic FSM, timer logic

**Major Components**

* `clock_divider` – Generates 1 Hz clock
* `traffic_fsm` – Controls traffic light sequencing
* `timer` – State-dependent countdown timers
* `uart_fsm` – Detects state changes and sends messages
* `uart_core` – Complete UART implementation (TX, RX, registers)
* Optional `bin_to_bcd` – Displays timer value on 7-segment LEDs

---

## 🗂️ Repository Structure (Suggested)

```
/
├── src/
│   ├── traffic_fsm.vhd
│   ├── timer.vhd
│   ├── clock_divider.vhd
│   ├── uart_fsm.vhd
│   ├── uart_core.vhd
│   ├── uart_tx.vhd
│   ├── uart_rx.vhd
│   └── supporting_modules/
│
├── diagrams/
│   ├── system_diagram.png
│   └── fsm_diagram.png
│
├── simulation/
│   └── waveform_results/
│
├── report/
│   └── CEG3155_Project_Report.pdf
│
└── README.md
```

---

## 🧪 Verification & Results

### ✅ Working (Hardware-Verified)

* Traffic light FSM
* Timer logic
* LED sequencing
* Switch and sensor inputs

### ✅ Working (Simulation-Verified)

* UART transmitter and receiver
* Baud rate generation
* FSM sequencing
* Correct UART waveforms

### ⚠️ Known Hardware Issue

UART messages did **not** appear on the terminal during live hardware testing.

**Root cause (identified):**

* Missing **2-stage synchronizer** for traffic state crossing from the 1 Hz domain into the 50 MHz UART domain
* Resulted in metastability and missed state-change detection

This issue is **architectural**, not syntactic, and is fully documented in the report .

---

## 🛠️ Tools Used

* Intel Quartus II (synthesis, simulation, Pin Planner)
* ModelSim (waveform verification)
* PuTTY (serial terminal)
* DE2 FPGA board
* MAX232 (RS-232 level shifting)

---

## 📚 What This Project Demonstrates

* Strong understanding of **FSM design**
* Hardware-level **UART protocol implementation**
* **Clock domain crossing** challenges and solutions
* Structural RTL discipline
* Real-world debugging and post-mortem analysis

---

## 📄 Documentation

📘 **Full technical report:**
See `report/CEG3155_Project_Report.pdf` for complete design rationale, schematics, FSM diagrams, and simulation results .

---

## 🚀 Future Improvements

* Add proper 2-stage synchronizer for UART trigger
* Add SignalTap II for hardware-level debugging
* Implement UART standalone test mode
* Improve timing constraints for I/O pins

---
