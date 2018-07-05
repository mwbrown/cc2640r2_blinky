# cc2640r2_blinky
Baremetal blinky example for the TI CC2640R2 Launchpad. Makes uses of GCC, Make, and OpenOCD.

## Summary

This is an example project for the TI CC2640R2 Launchpad, designed to be built using standard tools.
Code Composer Studio (aka CCS) is not required to build, flash, or debug this project, i.e. it can all be done via the command line.

## Dependencies

* `arm-none-eabi-gcc` with Cortex-M3 support. Any recent build, either from ARM or from your distro's official package repositories should work.
* `openocd` from a recent version. The changes to support the CC2640 are very new (as of 2018), so it is **highly** recommended to build from Git.
* The [TI CC2640R2 SDK](http://www.ti.com/tool/download/SIMPLELINK-CC2640R2-SDK) must be installed. Currently this is available only as a Windows
  installer, but the files can be installed via WINE and then copied elsewhere.

## Building

1. Ensure the `CC2640_SDK` env var points to your installation of the SDK, for example:
  * `export CC2640_SDK="/opt/ti/simplelink_cc2640r2_sdk_1_50_00_58"`
2. If using a GCC installation that is not in your `$PATH`, modify `$CC2640_SDK/imports.mak` to point to the correct `GCC_ARMCOMPILER` location.
3. Run `make` in the project root.

## Debugging

1. After building, connect the Launchpad and run `make flash`. This will use OpenOCD to program the board.
2. After a successful flash, the board should be running. To connect GDB:
  * Run `openocd`. This should create a GDB server running on port `:3333`.
  * In another terminal, launch `arm-none-eabi-gdb blinky.elf`. If the `.gdbinit` file is sourced, it will connect to OpenOCD automatically.
    Otherwise, within GDB, issue `target remote :3333`
3. Reset the board by issuing `monitor reset init` followed by `set $pc=$pc` (this is a workaround to resync GDB's program counter).
4. You may now set breakpoints and otherwise control the CPU via GDB.

## Known Issues

* The XDS110 debug adapter chip that comes on the Launchpad will need updated firmware for OpenOCD support. Otherwise, OpenOCD will refuse
  to connect to the adapter. Note that the easiest way to update the firmware is via Code Composer Studio's update tools.
* In order to connect to the XDS110 as a normal user, it is required to install udev rules to give the appropriate permissions. The CCS install 
  comes with a file that can be used to give permissions for TI devices, however its permissions are broader than needed for this project.
* The CC2640 support in OpenOCD is still in beta. A regular `monitor reset` command will cause the JTAG to lose connection, as will low-power modes
  on the CC2640. The `openocd.cfg` file remaps reset so that it does not issue a regular chip reset (see **Debugging**).
* The XDS110 USB support in Linux is not stable under VirtualBox. Often times the connection will be made, but die within ten seconds. The board must
  be power-cycled after this occurs.
* For additional caveats, please check TI's [official OpenOCD download page](http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/simplelink-openocd/latest/index_FDS.html).
* These scripts do not currently check if OpenOCD is running. If it is, you will have to kill it before running `make flash` to update the image.
​