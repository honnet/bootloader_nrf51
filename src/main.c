#include "nrf_delay.h"
#include "nrf_gpio.h"

#define LED_0 13

int main(void)
{
  nrf_gpio_cfg_output(LED_0);

  for(;;)
  {
    nrf_gpio_pin_toggle(LED_0);
    nrf_delay_ms(100);
  }
}
