
ifeq ($(CC2640_SDK),)
  $(error CC2640_SDK is not defined)
endif

include $(CC2640_SDK)/imports.mak

PREFIX=arm-none-eabi
export PATH := $(PATH):$(GCC_ARMCOMPILER)/bin

ifeq ($(GCC_ARMCOMPILER),)
  $(error GCC_ARMCOMPILER is not defined)
endif

# Compile commands are echoed if V=1
ifneq ($(V),)
  SS=
else
  SS=@
endif

CC=$(PREFIX)-gcc
LD=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
OBJDUMP=$(PREFIX)-objdump
OBJCOPY=$(PREFIX)-objcopy

BUILD_DIR = ./_build

vpath %.c $(CC2640_SDK)/source

C_SOURCES := \
	src/main.c \
	ti/devices/cc26x0/startup_files/startup_gcc.c

DRIVERLIB_DIR := ti/devices/cc26x0r2/driverlib
DRIVERLIB_SRC := \
	$(DRIVERLIB_DIR)/adi.c \
	$(DRIVERLIB_DIR)/aon_batmon.c \
	$(DRIVERLIB_DIR)/aon_event.c \
	$(DRIVERLIB_DIR)/aon_ioc.c \
	$(DRIVERLIB_DIR)/aon_rtc.c \
	$(DRIVERLIB_DIR)/aon_wuc.c \
	$(DRIVERLIB_DIR)/aux_adc.c \
	$(DRIVERLIB_DIR)/aux_smph.c \
	$(DRIVERLIB_DIR)/aux_tdc.c \
	$(DRIVERLIB_DIR)/aux_timer.c \
	$(DRIVERLIB_DIR)/aux_wuc.c \
	$(DRIVERLIB_DIR)/ccfgread.c \
	$(DRIVERLIB_DIR)/chipinfo.c \
	$(DRIVERLIB_DIR)/cpu.c \
	$(DRIVERLIB_DIR)/crypto.c \
	$(DRIVERLIB_DIR)/ddi.c \
	$(DRIVERLIB_DIR)/debug.c \
	$(DRIVERLIB_DIR)/driverlib_release.c \
	$(DRIVERLIB_DIR)/event.c \
	$(DRIVERLIB_DIR)/flash.c \
	$(DRIVERLIB_DIR)/gpio.c \
	$(DRIVERLIB_DIR)/i2c.c \
	$(DRIVERLIB_DIR)/i2s.c \
	$(DRIVERLIB_DIR)/interrupt.c \
	$(DRIVERLIB_DIR)/ioc.c \
	$(DRIVERLIB_DIR)/osc.c \
	$(DRIVERLIB_DIR)/prcm.c \
	$(DRIVERLIB_DIR)/pwr_ctrl.c \
	$(DRIVERLIB_DIR)/rfc.c \
	$(DRIVERLIB_DIR)/setup.c \
	$(DRIVERLIB_DIR)/setup_rom.c \
	$(DRIVERLIB_DIR)/smph.c \
	$(DRIVERLIB_DIR)/ssi.c \
	$(DRIVERLIB_DIR)/sw_chacha.c \
	$(DRIVERLIB_DIR)/sw_poly1305-donna.c \
	$(DRIVERLIB_DIR)/sys_ctrl.c \
	$(DRIVERLIB_DIR)/systick.c \
	$(DRIVERLIB_DIR)/timer.c \
	$(DRIVERLIB_DIR)/trng.c \
	$(DRIVERLIB_DIR)/uart.c \
	$(DRIVERLIB_DIR)/udma.c \
	$(DRIVERLIB_DIR)/vims.c \
	$(DRIVERLIB_DIR)/watchdog.c

# Add the driverlib 
C_SOURCES += $(DRIVERLIB_SRC)

C_OBJECTS := $(addprefix $(BUILD_DIR)/, $(C_SOURCES:.c=.o))

DEFINES += -DDeviceFamily_CC26X0R2
#DEFINES += -DDRIVERLIB_NOROM

INCLUDES += -I$(CC2640_SDK)/source
INCLUDES += -I$(CC2640_SDK)/source/ti/devices/cc26x0r2

# CFLAGS for all sources.
CFLAGS += -mthumb -mcpu=cortex-m3
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Os -g

# Error on implicit function declaration.
CFLAGS += -Werror=implicit-function-declaration

# CFLAGS for anything in driverlib
CFLAGS_DRIVERLIB += -Os

# Append extra CFLAGS depending on directory.
$(BUILD_DIR)/$(DRIVERLIB_DIR)/%.o: CFLAGS+=$(CFLAGS_DRIVERLIB)

LDFLAGS += -Wl,-T"$(CC2640_SDK)/source/ti/devices/cc26x0r2/linker_files/cc26x0r2f.lds"
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -mthumb -mcpu=cortex-m3
LDFLAGS += -nostartfiles

.PHONY: clean all flash disasm

TARGET=blinky

all: $(TARGET).elf $(TARGET).hex

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TARGET).elf $(TARGET).hex
	rm -f $(TARGET).disasm

flash: $(TARGET).hex
	openocd -f ocd_flash.cfg

disasm: $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).disasm

$(TARGET).elf: $(C_OBJECTS)
	@echo LD $@
	$(SS) $(LD) -o $@ $(LDFLAGS) $^

%.hex: %.elf
	@echo HEX $@
	$(SS) $(OBJCOPY) -O ihex $< $@

# Include generated dependency files (alongside .o files)
-include $(C_OBJECTS:.o=.d)

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo CC $(notdir $<)
	$(SS) $(CC) $(INCLUDES) $(DEFINES) $(CFLAGS) -c -o $@ $<
	$(SS) $(CC) $(INCLUDES) $(DEFINES) $(CFLAGS) -MM -MT $@ $< > $(BUILD_DIR)/$*.d
