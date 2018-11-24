SNS-CPU-1CHIP-01 installation guide
==============

Features

* single MCLK provided by snes_dejitter
* de-jittered CSYNC on multi-AV pin 3 (compatible with RGB cables wired to use CSYNC)

Steps

1. Remove X1, C3 and R12 from SNES mainboard
2. Leave JP2 and JP3 open on snes_dejitter board (rev v1.0/v1.1: leave C8 and R14 unpopulated)
3. Cover copper areas on the bottom of snes_dejitter with electrical tape
4. Attach snes_dejitter on the bottom of SNES mainboard via double-sided adhesive tape
5. Connect 5V, GND, CSYNC_i, CSYNC_o and MCLK_o as shown in image below

![](1chip-install.jpg)
