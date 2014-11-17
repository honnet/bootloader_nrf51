#ifndef BOARDS_H
#define BOARDS_H

#include "nrf_gpio.h"

// IHM:
#define LED_R           12       /* red   ! INVERTED LOGIC ! */
#define LED_G           14       /* green ! INVERTED LOGIC ! */
#define LED_B           13       /* blue  ! INVERTED LOGIC ! */
#define BUTTON          29       /* connect to VCC when pressed */
#define LED             LED_G    /* default green */
// other aliases:
#define LED_0           LED_R
#define LED_1           LED_G
#define LED_2           LED_B
const int leds[] = {LED_R, LED_G, LED_B};

// UART:
#define UART_TX_PIN     15       /* 3V */
#define UART_RX_PIN     16       /* 3V */
#define UART_CTS_PIN    2        /* not connected, for retro-compatibility only */
#define UART_RTS_PIN    3        /* not connected, for retro-compatibility only */
#define HWFC            false    /* no hardware flow control */

// IMU:
#define I2C_SDA         (4u)
#define I2C_SCL         (5u)
#define I2C_INT         (6u)
// Aliases:
#define TWI_MASTER_CONFIG_DATA_PIN_NUMBER   I2C_SDA
#define TWI_MASTER_CONFIG_CLOCK_PIN_NUMBER  I2C_SCL
#define MPU9150_INT_PIN                     I2C_INT

// Analog Inputs: (Note: the analog reference is on pin 0)
#define AREF            0
#define AIN0            26
#define AIN1            27
#define AIN2            1

// Extra GPIOs
#define GPIO8           8
#define GPIO9           9
#define GPIO10          10
#define GPIO11          11

#endif

