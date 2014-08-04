/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

/*
  simple hello world sketch
  Andrew Tridgell September 2011
*/

#include <AP_Common.h>
#include <AP_Progmem.h>
#include <AP_HAL.h>
#include <AP_HAL_AVR.h>
#include <AP_HAL_AVR_SITL.h>
#include <AP_HAL_PX4.h>
#include <AP_HAL_Empty.h>
#include <AP_Math.h>
#include <Filter.h>
#include <AP_InertialSensor.h>
#include <AP_ADC.h>
#include <AP_InertialSensor.h>
#include <AP_GPS.h>
#include <DataFlash.h>
#include <GCS_MAVLink.h>
#include <AP_Param.h>
#include <AP_Baro.h>
#include <AP_Compass.h>
#include <AP_Declination.h>
#include <SITL.h>
#include <AP_Notify.h>

const AP_HAL::HAL& hal = AP_HAL_BOARD_DRIVER;

void setup() {
	hal.console->println_P(PSTR("Testing GPIO"));
	for(int count = 0;count < 6;count++)
	{
		hal.gpio->pinMode(PX4_GPIO_FMU_SERVO_PIN(count),GPIO_SET_OUTPUT);//Setting them as output
	}
}

void loop()
{
	int16_t user_input;
	hal.console->println("Press enter to shift between the channels providing 5 volts");
	hal.scheduler->delay(20);
	int8_t pincount = 0;
	while( hal.console->available() ) {
		user_input = hal.console->read();
		if(user_input == 13)//Enter key
		{
			hal.gpio->write(PX4_GPIO_FMU_SERVO_PIN(pincount),0);//Writing value to pin 1 is High, 0 is low

			pincount = pincount + 1;
			if(pincount > 5)
				pincount = 0;

			hal.gpio->write(PX4_GPIO_FMU_SERVO_PIN(pincount),1);//Writing value to pin 1 is High, 0 is low
		}
	}
}

AP_HAL_MAIN();
