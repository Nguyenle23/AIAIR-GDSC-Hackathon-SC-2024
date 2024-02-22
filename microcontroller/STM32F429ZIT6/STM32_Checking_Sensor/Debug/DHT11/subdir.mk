################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../DHT11/DHT11.c 

OBJS += \
./DHT11/DHT11.o 

C_DEPS += \
./DHT11/DHT11.d 


# Each subdirectory must supply rules for building sources it contributes
DHT11/%.o DHT11/%.su DHT11/%.cyclo: ../DHT11/%.c DHT11/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F429xx -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-DHT11

clean-DHT11:
	-$(RM) ./DHT11/DHT11.cyclo ./DHT11/DHT11.d ./DHT11/DHT11.o ./DHT11/DHT11.su

.PHONY: clean-DHT11

