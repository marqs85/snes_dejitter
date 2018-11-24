SNSP-CPU-02 installation guide
==============

Features

* dual MCLK for 50/60Hz modded console provided by snes_dejitter/S-CLK depending on mode
* de-jittered CSYNC on multi-AV pin 7 (compatible with RGB cables wired to use luma as sync)

Steps

1. Desolder R73 and R25 on SNES mainboard
2. Leave JP3 open on snes_dejitter board (rev v1.0/v1.1: leave C8 unpopulated)
3. Short JP2 on snes_dejitter board (v1.2 and higher revisions only)
4. Cover copper areas on the bottom of snes_dejitter with electrical tape
5. Attach snes_dejitter on the bottom of SNES mainboard via double-sided adhesive tape
6. Connect 5V and GND to C92
7. Connect CSYNC_i to S-ENC pin 8 (or S-PPU2 pin 100)
8. Connect CSYNC_o to multiAV pin 7
9. Connect MCLK_o to CPU side of removed R73
10. Connect MCLK_EXT_i to S-CLK side of R73
11. Connect CLK_SEL_i to 50/60Hz select line (same that goes to S-PPU1 pin 24)
