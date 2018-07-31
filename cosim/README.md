### Example full-chip co-simulation

The SACI master is written in SystemVerilog. It is used to configure the ASIC and stimulate it.
This co-simulation is considered a SPICE-top approach where "saci_tb.sp" will be the wrapper for the fullchip simulation.
The file "saci.stim" is the raw stimulus file that is used to configure the ASIC.

The co-simulation will use a digital simulator and an analog simulator, vcs and finesim respectively.
Currently, the simulation performs the following:
* SACI master (SystemVerilog) sends transactions to ASIC SACI slave.
* SACI slave (SPICE) accepts the transactions and read/writes them to a RAM (vhd). The RAM here represents the ControlUnit.
* The transactions are ploted in fsdb (analog) and vpd (digital) formats.


The format of the saci.stim file is as follows:
* All values are in hex.
* All arguments are seperated by a whitespace.
* There are four arguments:
  * rw  : saci read/write bit. read=0, write=1.
  * cmd : saci 7-bit command.
  * addr: saci 12-bit address.
  * data: saci 32-bit data.
* Example:
  * 0 1 5 0
    * 0x0 = saciREAD, 0x1 = register cmd, 0x5 = register at address 0x5, 0x0 = data ignored here.
  * 1 1 5 abcd
    * 0x1 = saciWRITE, 0x1 = register cmd. 0x5 = at address 0x5, 0xabcd = data.

Execute ```./run.sh```
