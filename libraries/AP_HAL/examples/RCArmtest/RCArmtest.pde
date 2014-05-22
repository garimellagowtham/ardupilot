
#include <AP_Common.h>
#include <AP_Math.h>
#include <AP_Param.h>
#include <AP_Progmem.h>

#include <AP_HAL.h>
#include <AP_HAL_AVR.h>
#include <AP_HAL_AVR_SITL.h>
#include <AP_HAL_PX4.h>
#include <AP_HAL_Empty.h>
#include <GCS_MAVLink.h>
#include <DataFlash.h>
#include <AP_GPS.h>
#include <AP_InertialSensor.h>
#include <AP_ADC.h>
#include <AP_Baro.h>
#include <Filter.h>
#include <AP_AHRS.h>
#include <AP_Compass.h>
#include <AP_Declination.h>
#include <AP_Airspeed.h>
#include <AP_Vehicle.h>
#include <AP_ADC_AnalogSource.h>
#include <AP_Notify.h>
#include <AP_Mission.h>
const AP_HAL::HAL& hal = AP_HAL_BOARD_DRIVER;
uint8_t jcounter;
void setup (void) 
{
    hal.console->printf_P(PSTR("Starting AP_HAL::RCOutput test\r\n"));
    uint8_t i;

    for (i=0; i<3; i++) {
        hal.rcout->enable_ch(i+8);
        hal.rcout->write(i+8, 1050 + i*50);
    }
    hal.rcout->set_freq(0x0700, 50);//Setting the channels 8,9,10 for regular servos
}

void loop (void) 
{
    uint8_t i;
    for (i=0; i<3; i++) {
        hal.rcout->enable_ch(i+8);
        hal.rcout->write(i+8, 1050 + i*200+jcounter*2);
    }
		if((jcounter++) > 255)
			jcounter = 0;
    hal.scheduler->delay(10);
}

AP_HAL_MAIN();
