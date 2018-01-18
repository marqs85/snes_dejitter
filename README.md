NES/SNES 240p de-jitter mod
==============

snes_dejitter is a mod board which eliminates sync jitter of NES/SNES 240p modes. Technical description and discussion is found on [this](https://shmups.system11.org/viewtopic.php?f=6&t=61285) thread.

Requirements for building the board and CPLD firmware
--------------------------------------------------------
* Hardware
  * PCB + parts

* Software
  * [Altera Quartus II version 13.0sp1 with MAX7000 support](http://dl.altera.com/13.0sp1/?edition=web)
  * [pof2jed](http://www.microchip.com/design-centers/programmable-logic/spld-cpld/tools/software/pof2jed) conversion tool
  * [ATMISP](http://www.microchip.com/design-centers/programmable-logic/spld-cpld/tools/software/atmisp) software
  * [WINE](https://www.winehq.org/) (if Windows OS is not used)

Requirements for flashing CPLD firmware
--------------------------------------------------------
* Hardware
  * OpenOCD supported JTAG programmer (e.g. FT2232 based)

* Software
  * [OpenOCD](http://openocd.org/)
  * Telnet client

CPLD image build procedure
--------------------------------------------------------
1. Open the project file in Quartus, and run compilation

2. Convert MAX7000 targeted POF object file into JEDEC file suitable for 1502AS via winpof2jed.exe:
~~~~
1. Select .pof file from previous step as input file
2. Select 1502AS as device
3. Set Open Collector to "Off", and JTAG mode to "On"
4. Click "Run"
~~~~
![pof2jed](/pics/pof2jed.png)

3. Convert JED to SVF via ATMISP:
~~~~
1. Create a new device chain via File->New
2. Set number of devices to 1
3. Set device to ATF1502AS
4. Set JTAG instruction to "Program/Verify"
5. Select .jed file from previous step as JEDEC file
6. Click "OK"
7. Tick "Write SVF file" and click "Run"
~~~~
![atmisp1](/pics/atmisp_chain.png)
![atmisp1](/pics/atmisp_setup.png)

Board flashing and installation
--------------------------------------------------------
The board can be flashed using any OpenOCD supported JTAG programmer that provides 3.3V-5V IO signal level. A standalone snes_jitter board is flashed by hooking all of its 6 JTAG header pins to respective pins of the programmer/cable, and by running flash procedure specified below. After the board has been installed to NES/SNES, firmware can be subsequently updated, but in this method 5V pin of the JTAG connector MUST be left disconnected, and programming needs to be done while NES/SNES is powered on (without a game is ok). The update procedure is similar in both cases:

1. Create openocd.conf that matches your JTAG programmer. A configuration file for FT2232-based programmers is found in installation/openocd-ft2232.cfg, and it uses following standard pinout for data signals:

Board pin | Programmer pin
--------- | -------------
TCK       | ADBUS0
TMS       | ADBUS3
TDI       | ADBUS1
TDO       | ADBUS2

2. After hooking up JTAG cable, initiate JTAG connection:
~~~~
openocd -f openocd.conf
~~~~
3. OpenOCD auto-probing should report a TAP controller with id 0x0150203f. You can now open another terminal to interact with openocd and program the chip:
~~~~
telnet localhost 4444
> svf <full_path_to_svf_file>
~~~~
4. The programming procedure should finish with no error, after which you can finish installation by powering off hardware and disconnecting the programmer.
