#include "MPU9150.h"
#include "twi_master.h"
#include "app_error.h"
#include "nrf_delay.h"
//#include "simple_uart.h"

int mpu9150_init()
{
	bool err_code;

    err_code = twi_master_init();

    APP_ERROR_CHECK_BOOL(err_code);

    uint8_t data[1] = { 0 };
    uint8_t reg[1] = { MPU9150_WHO_AM_I };

    //Lets read the WHO_AM_I_REGISTER
    mpu9150_write( reg, 1, MPU9150_DONT_ISSUE_STOP );
    mpu9150_read( data, 1, MPU9150_ISSUE_STOP );

    //Throw an error if the WHO_AM_I register is not the correct value
    if( data[0] != MPU9150_WAI_DEFAULT) {
        return -1;
    }
    return 0; // no error
}

void mpu9150_write( uint8_t *data, uint8_t data_length, bool issue_stop_condition )
{

	bool err_code;

	uint8_t address = (MPU9150_ADDR << 1) & ~(MPU9150_READ_BIT);

	err_code = twi_master_transfer(address, data, data_length, issue_stop_condition);

	APP_ERROR_CHECK_BOOL(err_code);

}

void mpu9150_read( uint8_t *data, uint8_t data_length, bool issue_stop_condition )
{

	bool err_code;

	uint8_t address = (MPU9150_ADDR << 1) | MPU9150_READ_BIT;

	err_code = twi_master_transfer(address, data, data_length, issue_stop_condition);

	APP_ERROR_CHECK_BOOL(err_code);

}

void mpu9150_sleep( bool sleep_enabled ) {

    uint8_t command[2];

    command[0] = MPU9150_PWR_MGMT_1;

    if( sleep_enabled ) {
        //simple_uart_putstring((uint8_t *)"se");
        command[1] = (1 << MP9150_PWR_MGT_1_SLEEP);
    } else {
        //simple_uart_putstring((uint8_t *)"sd");
        command[1] = 0;
    }

    mpu9150_write( command, 2, MPU9150_ISSUE_STOP );

}

void mpu9150_reset() {

    uint8_t command[2];

    command[0] = MPU9150_PWR_MGMT_1;
    command[1] = (1 << MP9150_PWR_MGT_1_RESET);

    mpu9150_write( command, 2, MPU9150_ISSUE_STOP );

}
