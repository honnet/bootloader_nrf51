Wut?
====

This BLE bootloader should allow using the nordic app to load .hex files normally compiled to work with a soft device.

More info here:
https://devzone.nordicsemi.com/documentation/nrf51/5.2.0/html/a00027.html

How?
====

make flash-softdevice

make flash


Bonus:
======

To test the DFU, there is a simple LED blink test on the blink-test branch:

git checkout blink-test


If you have dropbox and a folder called Dropbox in your home directory:

make dropbox

It will can put the .hex file in a folder called 'twi' so you can simply open it from your nordic app.


Once an app is running, you can restart twi with the button pressed to go back in DFU mode.

Enjoy ;)
