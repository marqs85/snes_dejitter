NES/SNES 240p de-jitter mod
==============

snes_dejitter is a mod board which eliminates sync jitter of NES/SNES 240p modes. Technical description and discussion is found on [this](https://shmups.system11.org/viewtopic.php?f=6&t=61285) thread.

Requirements for building the board and CPLD firmware
--------------------------------------------------------
* Hardware
  * [PCB](https://oshpark.com/shared_projects/NkuS1ju6) + [parts](pcb/bom/snes_dejitter.ods)

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

**NOTE:** Only needed when building a custom firmware. Pre-built images can be found under output_files/ on master and nes-fix (recommended for NES/FC) branches.

1. Open the project file in Quartus, and run compilation

2. Convert MAX7000 targeted POF object file into JEDEC file suitable for 1502AS via winpof2jed.exe:
~~~~
1. Select .pof file from previous step as input file
2. Select 1502AS as device
3. Change the following options:
  * Reduce MC power -> On
  * Open Collector -> Off
  * JTAG mode -> On
  * Slew rate -> Slow
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

Board flashing
--------------------------------------------------------
The board can be flashed using any OpenOCD supported JTAG programmer that supports 3.3V-5V IO signal level (TCK, TMS and TDI are TTL inputs with 10k pull-downs). If 3.3V IO is used, JP4 (on v1.3 PCB) should be closed which clamps TDO output to 3.3V. A standalone snes_jitter board is flashed by hooking all of its 6 JTAG header pins to respective pins of the programmer/cable, and by running flash procedure specified below. After the board has been installed to NES/SNES, firmware can be subsequently updated, but in this method 5V pin of the JTAG connector MUST be left disconnected, and programming needs to be done while NES/SNES is powered on (without a game is ok). The update procedure is similar in both cases:

1. Create openocd.conf that matches your JTAG programmer. A configuration file for FT2232-based programmers is found in installation/openocd-ft2232.conf, and it uses following standard pinout for data signals:

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
3. OpenOCD auto-probing should report a TAP controller with id 0x0150203f - if not, check connections and configuration. When successful, open another terminal to interact with openocd and program the chip:
~~~~
telnet localhost 4444
> svf <full_path_to_svf_file>
~~~~
4. The programming procedure should finish with no error, after which you can finish installation by powering off hardware and disconnecting the programmer.

Installation
--------------------------------------------------------
General descriptions on board pins are in table below. Model-specific installation instructions are added to separate <a href="installation/">subdirectories</a>.

Board pin  | Description
---------- | -------------
CSYNC_i    | TTL C-sync signal from the console
MCLK_EXT_i | External clock input. Used only in PAL mode, not needed in pure NTSC installations.
CLK_SEL_i  | Master clock source selection (0=internal/NTSC, 1=external/PAL). In PAL mode, MCLK and CSYNC are bypassed to output. Pin is pulled low internally, so it can be left disconnected in pure NTSC installations. Connected to PALMODE in multiregion installations. Can be forced high by bridging JP1 (pre-1.2 boards only), but must never be done if the pin is wired to console.
MCLK_o     | Clock output. An optional voltage divider (R13,R14 / JP2) can be used to reduce output level from ~4Vpp to ~3Vpp, see model-specific instructions for more details.
CSYNC_o    | C-sync output (~2.5Vpp unterminated, ~1.1Vpp into 75ohm termination) to an isolated multi-AV pin. Driver circuit is identical to SHVC-CPU-01. JP3 connects optional 330pF output capacitor that may not be present on console mainboard (not strictly needed, reduces potential noise at the price of less sharp transition time), see model-specific instructions for more details.

Jumper  | Description
------- | -------------
JP1     | Forces CLK_SEL_i high. Removed on v1.2 since it was mostly for debugging purposes.
JP2     | Enables MCLK_o voltage divider. Recommended for NES installations to ensure signal level is safe for NESRGB.
JP3     | Connects optional 330pF output capacitor on CSYNC_o.
JP4     | Enable TDO voltage clamp. Recommended if board is flashed with a 3.3V programmer.

PCB revision history
--------------------------------------------------------
### v1.3
* change (R9,R10) voltage divider values
* replace TDO voltage divider with an optional zener clamp (selectable via JP4)
* add R15 pulldown to prevent floating input pin

### v1.2
* remove JP1
* add JP2 and JP3 to easily support different setups

### v1.1
* change R14 value
* change JTAG connector

### v1.0
* first revision

FAQ
--------------------------------------------------------
### Can I buy the board pre-assembled / pre-installed
* VGP [store](https://www.videogameperfection.com/products/snes-jitter-kit/) offers pre-assembled boards with optional installation service.

### Can I flash the board with USB Blaster?
* USB Blaster is compatible with OpenOCD, but you have to check your programmer details (official/clone, 5V compatibility) and hook up and configure it accordingly. Official USB Blaster has fixed 6MHz TCK frequency which is probably too high for the board, so USB Blaster II and clones are more likely to work. None of the USB Blasters supply voltage on the board, but instead require connection from the board's supply to Vcc(TRGT) pin of the debug connector. You must thus power the board externally and connect 5V to Vcc(TRGT) (make sure your programmer supports 5V operation!). Some clones also require hacks on OpenOCD to operate correctly, see the [thread](https://shmups.system11.org/viewtopic.php?f=6&t=61285) for more details.

### Which other programmers can I use?
* OpenOCD supports a wide range of [debug adapters](http://openocd.org/doc/html/Debug-Adapter-Hardware.html). Several people also have programmed their boards using a Raspberry Pi. Instructions and tools for RPI can be found on the [thread](https://shmups.system11.org/viewtopic.php?f=6&t=61285).

### Does the mod change game speed in any way?
* Yes, but in very minimal way - in 1 hour of gameplay a de-jittered system falls less than 2 frames behind a vanilla system.

### Is it possible to disable de-jitter functionality after installation?
* When the board is installed so that MCLK_EXT_i and CLK_SEL_i are not used, a simple bypass can be added without firmware modifications. To do that, connect MCLK_EXT_i to CPLD pin 34 (MCLK_XTAL_o) and add a ON-OFF switch that connects MCLK_SEL_i to 5V.
