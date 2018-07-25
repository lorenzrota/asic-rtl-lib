### Example full-chip co-simulation

The SACI master is written in SystemVerilog. It is used to configure the ASIC and stimulate it.
This co-simulation is considered a SPICE-top approach where "saci_tb.sp" will be the wrapper for the fullchip simulation.
The file "saci.stim" is the raw stimulus file that is used to configure the ASIC.

The co-simulation will use a digital simulator and an analog simulator, vcs and finesim respectively.
Currently, the simulation performs the following:
* SACI master (SystemVerilog) sends transactions to ASIC SACI slave.
* SACI slave (SPICE) accepts the transactions and read/writes them to a RAM (vhd). The RAM here represents the ControlUnit.
* The transactions are ploted in fsdb (analog) and vpd (digital) formats.

Execute ```./run.sh```
