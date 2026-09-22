# UART Protocol – Verilog Implementation

## What is a Protocol?
A protocol is a specific set of rules used to establish communication 
between two systems. Protocols fall into two categories:
- **On-Chip**: Communication on chips (e.g., AMBA, AHB, APB, AXI, Wishbone)
- **Peripheral**: Peripheral communication (e.g., SPI, UART, I2C)

## UART Protocol
UART (Universal Asynchronous Receiver Transmitter) is a hardware 
protocol/device used for serial communication, commonly found in 
microcontrollers, computers, and other electronic devices.

### Why Asynchronous?
In UART, there is no shared clock between the master and slave devices. 
The master sends data at a particular baud rate in serial format, and 
the receiver receives data at its own baud rate in serial format — 
synchronization is achieved through matching baud rates, not a shared clock.

### What UART does
A UART converts parallel data into serial data for transmission, and 
converts received serial data back into parallel form — enabling 
communication over interfaces such as RS-232, RS-485, or TTL.

### Uses of UART
- Fundamental component in digital communication systems for serial 
  communication between electronic devices
- Interfacing with peripheral devices
- Wireless communication
- Control and monitoring systems
- Industrial automation

## How UART Works

### Parallel to Serial Conversion
Data is transmitted serially over a communication wire even though it 
originates in parallel form on the controlling data bus. The transmitting 
UART converts parallel data into a serial stream, sending it bit by bit 
to the receiving UART.

### TX/RX Pins
UART devices have dedicated **TX** (transmit) and **RX** (receive) pins, 
enabling bi-directional communication between two devices (TX of one 
connects to RX of the other, and vice versa).

### Baud Rate
Baud rate (bits per second) determines the rate of data transfer between 
transmitter and receiver:
- Higher baud rate → faster data transfer
- Lower baud rate → slower data transfer
- Baud rate refers to the *rate* bits are transmitted, not the number of bits
- Since UART has no shared clock, both devices must operate at the **same 
  baud rate** for correct synchronization — the transmitter generates the 
  bitstream on its own clock, and the receiver samples incoming bits at 
  the same rate using its own internal clock.

---

## Project Implementation

Verilog implementation of a UART transmitter and receiver, simulated in 
ModelSim and synthesized in Quartus Prime Lite.

### Modules
| File | Description |
|------|-------------|
| `baud_gen.v` | Generates 16x-oversampled baud rate tick from system clock |
| `uart_tx.v` | UART transmitter (shifts out start + 8 data + stop bits) |
| `uart_rx.v` | UART receiver (samples and reconstructs received byte) |
| `uart_top.v` | Top-level module integrating TX/RX with board I/O |
| `uart_tb.v` | Testbench simulating TX→RX loopback |

### Simulation Results
Verified in ModelSim: bytes `0x41` ('A') and `0x5A` ('Z') were transmitted 
and correctly received via internal loopback, confirmed via waveform and 
console output.

See `waveform_result.png` for the waveform capture.

To reproduce:

vlib work
vmap work work
vlog baud_gen.v uart_tx.v uart_rx.v uart_top.v uart_tb.v
vsim uart_tb
do wave.do
run -all




### Status
- [x] Core TX/RX logic simulated and verified
- [ ] Top-level integration simulated
- [ ] Synthesized in Quartus Prime Lite
- [ ] Tested on physical hardware