# Simple Processor Design and Verification

## Repository Structure
The repository is structured into several directories, each with a distinct role:

- **docs**: Contains all the documentation files.

- **inc**: Houses include files, which are incorporated into other SystemVerilog files using the ``` `include``` directive. These files, which may or may not be part of the RTL, are further categorized into folders based on their protocol or use case. **Note that this does not include certain include files located in the Testbench directory.**

- **intf**: Stores SystemVerilog interfaces, which are recommended solely for verification purposes and not for RTL design. We favor structured IOs for requests and responses to facilitate connections, as opposed to using interfaces.

- **rtl**: This is where all the design source files are located.

- **sub**: Contains all git repository submodules. **Please note that submodule files are not compiled automatically. They must be manually added in the compile order within the **`config/*/xvlog`** for each Testbench (TB). This file is auto-generated next to the TB top file.**

- **tb**: All the Testbenches (TBs) are stored here. Each TB should be in a separate directory that corresponds to the name of the Device Under Test (DUT) module, suffixed with `_tb`. The Testbenches are utilized to verify the design functionality under various scenarios.

## How-to
To know how to use different commands on this repo, type `make help` or just `make` at the repo root and further details with be printed on the terminal.

## RTL
[alu_gate ](./docs/rtl/alu_gate.md)<br>
[alu_math ](./docs/rtl/alu_math.md)<br>
[alu_mem ](./docs/rtl/alu_mem.md)<br>
[alu_shift ](./docs/rtl/alu_shift.md)<br>
[demux ](./docs/rtl/demux.md)<br>
[ins_dec ](./docs/rtl/ins_dec.md)<br>
[merge_execution ](./docs/rtl/merge_execution.md)<br>
[mux ](./docs/rtl/mux.md)<br>
[r2_w1_32b_memory_model ](./docs/rtl/r2_w1_32b_memory_model.md)<br>
[reg_file ](./docs/rtl/reg_file.md)<br>
[simple_processor ](./docs/rtl/simple_processor.md)<br>

