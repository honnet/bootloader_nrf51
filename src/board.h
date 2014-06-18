#ifndef BOARD_H
#define BOARD_H

// IHM:
#define LED_R           12       /* red */
#define LED_G           13       /* green */
#define LED             LED_G    /* default LED */
#define BUTTON          29       /* connect to VCC when pressed */
#define BUTTON_PULL     NRF_GPIO_PIN_PULLDOWN

// UART:
#define TX_PIN_NUMBER   0        /* 1.8V ! */
#define RX_PIN_NUMBER   1        /* 1.8V ! */
#define CTS_PIN_NUMBER  2        /* not connected, for retro-compatibility only */
#define RTS_PIN_NUMBER  3        /* not connected, for retro-compatibility only */
#define HWFC            false    /* no hardware flow control */
/*
// IMU:
#define I2C_SDA         4
#define I2C_SCL         5
#define I2C_INT         6
*/
// Analog Inputs: (Note: the analog reference is on pin 0)
#define AIN0            26
#define AIN1            27

#endif

