# Project Title
**DAC3282-SPI-Communication**

## Getting Started
* Clone the repo
* Create a project on ModelSim
* Add the master, slave and testbench file

## Prerequisites
* Xilinx ISE 14.7+
* ModelSim 10.1c+

## Description
The DAC3282 is a dual-channel 16-bit 625 MSPS, Dual, 16-Bit, 625 MSPS DACs with an 8-bit LVDS input data bus with on-chip termination, optional 2x
Byte-Wide Interleaved Data Load interpolation filter, and internal voltage reference. The serial port of the DAC3282 is a flexible serial interface which communicates with industry standard
microprocessors and microcontrollers. The project was used to create the SPI block to validate serial bus action in DAC3282. The SPI block followed the data communication requriment metiinoned by DAC3282 documentation by *Texas Instrument **([Link here](https://github.com/RishabhSisodia/DAC3282-SPI-Communication/blob/master/TI%20Dac3282.pdf))***. 

## Working 
* Run master.vhdl and slave.vhdl parallely
* For testing run testbench.vhdl

## License
This project is licensed under the Apache-2.0 License License - see the [LICENSE.md](https://github.com/RishabhSisodia/DAC3282-SPI-Communication/blob/master/LICENSE) file for details
