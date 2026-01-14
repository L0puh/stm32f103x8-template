TARGET = bluepill

CC      = arm-none-eabi-gcc
AS      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size

MCU     = cortex-m3

SRCDIR  = src
INCDIR  = inc
DRVDIR  = drivers

DEFS = -DSTM32F103xB -DUSE_HAL_DRIVER

CFLAGS = -mcpu=$(MCU) -mthumb -Wall -O2 \
         -ffunction-sections -fdata-sections \
         $(DEFS) \
         -I$(INCDIR) \
         -I$(DRVDIR)/CMSIS/Include \
         -I$(DRVDIR)/CMSIS/Device/ST/STM32F1xx/Include \
         -I$(DRVDIR)/STM32F1xx_HAL_Driver/Inc

ASFLAGS = $(CFLAGS)

LDFLAGS = -T linker.ld \
          -mcpu=$(MCU) -mthumb \
          -Wl,--gc-sections

C_SOURCES = \
$(SRCDIR)/main.c \
$(SRCDIR)/stm32f1xx_it.c \
$(SRCDIR)/system_stm32f1xx.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c \
$(DRVDIR)/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c

ASM_SOURCES = startup_stm32f103xb.s

OBJS = $(C_SOURCES:.c=.o) $(ASM_SOURCES:.s=.o)

ELF = $(TARGET).elf
BIN = $(TARGET).bin

all: $(ELF) $(BIN)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) -c $< -o $@

$(ELF): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJS) $(ELF) $(BIN)

flash: $(ELF)
	st-flash --reset write $(BIN) 0x8000000

.PHONY: all clean flash

