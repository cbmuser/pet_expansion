# PET_EXPANSION
Memory, Flash and SID-Device

The trinity-device for the CBM PET2001. You can use up to 512kBx8 Atmel-Flash and SRAM for storing and buffering of data. The SID gives the CBM the ability to play nice chiptunes. 
It's also possible to use it as 1 Megabyte SRAM oder Flash-Device. If you want to capture old disks, the RAM-only variante may be useful. For a virtual, non-volatile Memory-Drive, 
two bigger Atmel-Flashs will be the right choice. 


The device uses address-lines above the screen-ram:

RAM0 : $8c00

RAM1 : $8d00

SID  : $8f00  

The first, early alpha-software and low-level routines will be released for BASIC4-ROMs.

![PCB](https://github.com/cbmuser/PET_EXPANSION/blob/main/images/pet_expansion_top.jpg)

