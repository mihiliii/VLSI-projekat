# VLSI Systems - Custom CPU Implementation

A custom 16-bit CPU implementation designed for FPGA synthesis and simulation, featuring a complete instruction set architecture with ALU operations, memory management, and peripheral I/O.

## Overview

This project implements a simple yet functional CPU core written in Verilog/SystemVerilog. The design targets Intel/Altera FPGA development boards (DE0 and DE0-CV) and includes comprehensive simulation and verification capabilities.

## Features

- **16-bit Data Width** with 6-bit addressing
- **Custom Instruction Set** including:
  - Data movement (MOV)
  - Arithmetic operations (ADD, SUB, MUL, DIV)
  - Input/Output operations (IN, OUT)
  - Control flow (STOP)
- **ALU Module** supporting 8 operations:
  - Arithmetic: ADD, SUB, MUL, DIV
  - Logical: AND, OR, XOR, NOT
- **Memory System** with read/write capability
- **Register File** for data storage
- **Stack Pointer** support
- **BCD Display** support for seven-segment displays

## Project Structure

```
├── src/
│   ├── simulation/          # Simulation-specific source files
│   │   ├── top.sv          # Top-level testbench
│   │   ├── top.v
│   │   └── modules/        # Simulation modules
│   │       ├── alu.v
│   │       └── register.v
│   ├── synthesis/          # Synthesis source files for FPGA
│   │   ├── DE0_CV_TOP.v   # Top module for Cyclone V (DE0-CV)
│   │   ├── DE0_TOP.v      # Top module for Cyclone III (DE0)
│   │   └── modules/       # Core CPU modules
│   │       ├── alu.v      # Arithmetic Logic Unit
│   │       ├── cpu.v      # Main CPU implementation
│   │       ├── memory.v   # Memory module
│   │       ├── register.v # Register file
│   │       ├── bcd.v      # BCD converter
│   │       ├── clk_div.v  # Clock divider
│   │       ├── ssd.v      # Seven-segment display
│   │       └── top.v      # CPU top-level wrapper
│   └── verifikacija/       # Verification files
│       ├── register.v
│       ├── top.sv
│       ├── register_cov.ucdb
│       └── covhtmlreport/ # Coverage reports
├── tooling/
│   ├── makefile           # Main build automation
│   ├── mem_init.mif       # Memory initialization file
│   ├── config/            # Configuration files
│   │   ├── list-icarus-verilog.lst
│   │   ├── list-src-files-simul.lst
│   │   ├── list-src-files-synth.lst
│   │   ├── run.tcl
│   │   ├── waveform-define.do
│   │   └── boards/        # Board-specific configurations
│   │       ├── cyclone3/  # Cyclone III (DE0)
│   │       └── cyclone5/  # Cyclone V (DE0-CV)
│   └── xpack/             # GNU Make binaries
└── README.md
```

## Supported Hardware

### Target Boards
- **DE0 Board** - Altera Cyclone III (EP3C16F484C6)
- **DE0-CV Board** - Altera Cyclone V (5CEBA4F23C7)

## Prerequisites

### Simulation
- **ModelSim-Altera Edition** or **Questa Sim**
- Path configured in makefile: `/mnt/c/altera/13.1/modelsim_ase/win32aloem/`

### Synthesis
- **Quartus II** (version 13.1 or compatible)
- Path configured in makefile: `/mnt/c/altera/13.1/quartus/bin/`

### Build System
- **GNU Make** (included in `tooling/xpack/bin/`)

## Getting Started

### Setup

1. Navigate to the tooling directory:
```bash
cd tooling
```

2. Configure paths in the makefile if your Quartus/ModelSim installation differs from the defaults.

### Building and Simulating

The project uses a comprehensive makefile for all operations:

```bash
# Show all available commands
make help

# Simulation targets
make simul_all       # Compile and simulate (complete flow)
make simul_lib       # Create work library
make simul_cmp       # Compile design
make simul_run       # Run simulation (shell mode)
make simul_run_gui   # Run simulation with GUI
make simul_wave_new  # Run simulation and view waveforms

# Synthesis targets
make synth_all       # Complete synthesis flow
make synth_map       # Analyze & Synthesize
make synth_fit       # Place & Route
make synth_asm       # Generate programming file
make synth_sta       # Static timing analysis
make synth_pgm       # Program the FPGA

# Cleanup
make simul_clean     # Clean simulation files
make synth_clean     # Clean synthesis files
make clean           # Clean everything
```

### Simulation Workflow

2. **Run simulation:**
```bash
make simul_run       # Shell-based
```

3. **View waveforms:**
```bash
make simul_wave_new
```

### Synthesis Workflow

1. **Select target board** in makefile:
```makefile
# For DE0 (Cyclone III):
SYNTH_TOP_LEVEL_MODULE = DE0_TOP
SYNTH_DEVICE_FAMILY = CycloneIII
SYNTH_DEVICE_PART = EP3C16F484C6

# For DE0-CV (Cyclone V):
SYNTH_TOP_LEVEL_MODULE = DE0_CV_TOP
SYNTH_DEVICE_FAMILY = CycloneV
SYNTH_DEVICE_PART = 5CEBA4F23C7
```

2. **Run synthesis:**
```bash
make synth_all
```

3. **Program the device:**
```bash
make synth_pgm
```

## CPU Architecture

### Instruction Format
- **Opcode:** 4 bits
- **Operands:** 12 bits (varies by instruction)
- **Addressing modes:** Direct and indirect

### Instruction Set

| Mnemonic | Opcode | Description |
|----------|--------|-------------|
| MOV      | 0000   | Move data between registers/memory |
| ADD      | 0001   | Addition |
| SUB      | 0010   | Subtraction |
| MUL      | 0011   | Multiplication |
| DIV      | 0100   | Division |
| IN       | 0111   | Input from peripheral |
| OUT      | 1000   | Output to peripheral |
| STOP     | 1111   | Halt execution |

### Memory Map
- **Program memory:** Starts at address 8
- **Stack:** Grows down from address 63
- **Total addressable space:** 64 words (6-bit addressing)

## Verification

The project includes functional verification with code coverage analysis:

- Test files located in `src/verifikacija/`
- Coverage reports generated in HTML format
- ModelSim `.ucdb` database for coverage tracking

View coverage reports by opening:
```
src/verifikacija/covhtmlreport/index.html
```

## Configuration Files

- **list-src-files-simul.lst** - List of files for simulation
- **list-src-files-synth.lst** - List of files for synthesis
- **run.tcl** - TCL script for simulation control
- **waveform-define.do** - Waveform configuration for ModelSim
- **mem_init.mif** - Memory initialization file

## Development Notes

### Modifying the Design

1. **Source files:** Edit files in `src/synthesis/modules/`
2. **Simulation:** Test changes using simulation flow
3. **Synthesis:** Recompile for target board

### Adding New Instructions

1. Define instruction opcode in [cpu.v](src/synthesis/modules/cpu.v)
2. Implement instruction logic in the CPU state machine
3. Update ALU if new operations are required
4. Add test cases in simulation testbench

## Troubleshooting

### Simulation Issues
- Verify ModelSim path in makefile
- Check that source file lists are up to date
- Ensure work library exists: `make simul_lib`

### Synthesis Issues
- Verify Quartus installation path
- Check device family and part number match your board
- Review timing analysis reports
- Ensure pin assignments are correct for your target board
