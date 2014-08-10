// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

//
// Simple Read test for the Dynamixcell driver
//
#include <AP_Common.h>                                                                         
#include <AP_Progmem.h>                                                                        
#include <../../../AP_HAL_PX4/UARTDriver.h>
#include <AP_HAL.h>                                                                            
#include <AP_HAL_AVR.h>                                                                        
#include <AP_HAL_AVR_SITL.h>                                                                   
//#include <AP_Scheduler.h>       // main loop scheduler
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
//#include <AP_Mission.h>                                                                        
#include <AP_Param.h>                                                                          
#include <AP_Baro.h>                                                                           
#include <AP_Compass.h>                                                                        
#include <AP_Declination.h>                                                                    
#include <SITL.h>                                                                              
#include <AP_Notify.h>                                                                         
#include <AP_AHRS.h>                                                                           
#include <AP_Airspeed.h>                                                                       
#include <AP_Vehicle.h>                                                                        
#include <AP_ADC_AnalogSource.h>                                                               
#include "dynamixel.h"

                                


// Control table address
#define P_GOAL_POSITION_L	30
#define P_GOAL_POSITION_H	31
#define P_PRESENT_POSITION_L	36
#define P_PRESENT_POSITION_H	37
#define P_MOVING		46
#define P_ID 3
#define P_BAUDRATE 4

// Default setting
//#define DEFAULT_BAUDNUM		1 // 1Mbps

static uint8_t DEFAULT_BAUDNUM = 34; // 1Mbps not supported directly
static uint8_t DEFAULT_ID = 1;//Have to change this based on input

using namespace PX4;
const AP_HAL::HAL& hal = AP_HAL_BOARD_DRIVER;
//static AP_Scheduler scheduler;

uint16_t goalindex = 2047;
uint8_t deviceIndex = 0;//This is not same as device id this is like number of serial devices 
uint8_t Moving;
uint16_t PresentPos;
uint8_t CommStatus;
dynamixel dynamixelinstance;


#if CONFIG_HAL_BOARD == HAL_BOARD_PX4
void setup()
{

	hal.console->println("DynamixCell Environment startup ..");
	dynamixelinstance.dxl_initialize(deviceIndex,DEFAULT_BAUDNUM);
	hal.console->println( "Opened USB2Dynamixel!");
	uint8_t i = 2;
	hal.console->printf_P("i: %#08x\n",i);//Checking Little/Big Indian
	//scheduler.init();
}
void loop()
{

	// Read present position
	PresentPos = dynamixelinstance.dxl_read_word( DEFAULT_ID, P_PRESENT_POSITION_L );
	CommStatus = dynamixelinstance.dxl_get_result();

	if( CommStatus == COMM_RXSUCCESS )
	{
		hal.console->printf_P(PSTR("%d   %d\n"),goalindex, PresentPos);
		PrintErrorCode();
	}
	else
	{
		PrintCommStatus(CommStatus);
	}

	/*	// Check moving done
			Moving = dynamixelinstance.dxl_read_byte( DEFAULT_ID, P_MOVING );
			CommStatus = dynamixelinstance.dxl_get_result();
			if( CommStatus == COMM_RXSUCCESS )
			{
			if( Moving == 0 )
			{
	// Change goal position
	if( goalindex == 2047 )
	goalindex = 0;
	else
	goalindex = 2047;					
	//Write goal position:
	dynamixelinstance.dxl_write_word( DEFAULT_ID, P_GOAL_POSITION_L, goalindex );
	}
	PrintErrorCode();
	}
	else
	{
	PrintCommStatus(CommStatus);
	break;
	}
	 */
	hal.scheduler->delay(2);
}

// Print communication result
void PrintCommStatus(int CommStatus_)
{
	switch(CommStatus_)
	{
		case COMM_TXFAIL:
			hal.console->println("COMM_TXFAIL: Failed transmit instruction packet!");
			break;

		case COMM_TXERROR:
			hal.console->println("COMM_TXERROR: Incorrect instruction packet!");
			break;

		case COMM_RXFAIL:
			hal.console->println("COMM_RXFAIL: Failed get status packet from device!");
			break;

		case COMM_RXWAITING:
			hal.console->println("COMM_RXWAITING: Now recieving status packet!");
			break;

		case COMM_RXTIMEOUT:
			hal.console->println("COMM_RXTIMEOUT: There is no status packet!");
			break;

		case COMM_RXCORRUPT:
			hal.console->println("COMM_RXCORRUPT: Incorrect status packet!");
			break;

		default:
			hal.console->println("This is unknown error code!");
			break;
	}
}

// Print error bit of status packet
void PrintErrorCode()
{
	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_VOLTAGE) == 1)
		hal.console->println("Input voltage error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_ANGLE) == 1)
		hal.console->println("Angle limit error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_OVERHEAT) == 1)
		hal.console->println("Overheat error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_RANGE) == 1)
		hal.console->println("Out of range error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_CHECKSUM) == 1)
		hal.console->println("Checksum error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_OVERLOAD) == 1)
		hal.console->println("Overload error!");

	if(dynamixelinstance.dxl_get_rxpacket_error(ERRBIT_INSTRUCTION) == 1)
		hal.console->println("Instruction code error!");
}
#endif

AP_HAL_MAIN();
