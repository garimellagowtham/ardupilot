// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

//
// Simple test for the Dynamixcell driver
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
	int16_t user_input;
	hal.console->println_P(PSTR(
				"Menu:\r\n"
				"    a) Specify Id\r\n"
				"    c) Set Device Id\r\n"
				"    d) Set Baudrate\r\n"
			  "    g) Set Goal\r\n"));
	uint8_t buffer[3];//3 byte buffer

	
	while( hal.console->available() ) {
		user_input = hal.console->read();
		if( user_input == 'c' || user_input == 'C' ) {
			int count1 = 0;
			for(count1 = 0;count1<3;count1++)
				buffer[count1] = 0;//Assigning to 0
			count1 = 0;
			while(user_input != 27)//Esc
			{
				while( !hal.console->available()) {
					hal.scheduler->delay(20);
				}//Wait till console has some input
				user_input = hal.console->read();
				if(user_input == 13 || count1 > 2)//Enter key  has been pressed or 2 bytes have been filled
				{
					uint8_t newid = 1;//default id
					newid = atoi((char*)buffer);
					hal.console->printf_P("Setting ID: %d\n", newid);
					//Set Device ID and change the id in the code
					dynamixelinstance.dxl_write_byte( DEFAULT_ID, P_ID, newid );
					DEFAULT_ID = newid;
				  for(count1 = 0;count1<3;count1++)
						buffer[count1] = 0;//Assigning to 0
					count1 = 0;
				}
				else{
					buffer[count1++] = user_input;
				}
			}
			hal.console->println("Exitting set ID");
		}
		if( user_input == 'a' || user_input == 'A' ) {
			int count1 = 0;
			for(count1 = 0;count1<3;count1++)
				buffer[count1] = 0;//Assigning to 0
			count1 = 0;
			while(user_input != 13)//Enter
			{
				while( !hal.console->available()) {
					hal.scheduler->delay(20);
				}//Wait till console has some input
				user_input = hal.console->read();
				if(user_input == 13 || count1 > 2)//Enter key  or 2 bytes have been filled
				{
					uint8_t newid = 1;//default id
					newid = atoi((char*)buffer);
					hal.console->printf_P("Setting Default ID: %d\n", newid);
					//Set Device ID and change the id in the code
					DEFAULT_ID = newid;
					for(count1 = 0;count1<3;count1++)
						buffer[count1] = 0;//Assigning to 0
					count1 = 0;
				}
				else{
					buffer[count1++] = user_input;
				}
			}
			hal.console->println("Exitting Specify ID");
		}
		if(user_input == 'd' || user_input == 'D')
		{
			//Set the baud rate
			int count1 = 0;
			for(count1 = 0;count1<3;count1++)
				buffer[count1] = 0;//Assigning to 0
			count1 = 0;
			uint8_t newbaudnum = 1;//default id
			while(user_input != 13)//Enter
			{
				while( !hal.console->available()) {
					hal.scheduler->delay(20);
				}//Wait till console has some input
				user_input = hal.console->read();
				if(user_input == 13 || count1 > 2)//Enter key  or 2 bytes have been filled
				{
					newbaudnum = atoi((char*)buffer);
					//Set Device ID and change the id in the code
					for(count1 = 0;count1<3;count1++)
						buffer[count1] = 0;//Assigning to 0
					count1 = 0;
				}
				else{
					buffer[count1++] = user_input;
				}
			}
			hal.console->printf_P("Setting Baudnum: %d\n", newbaudnum);
			if((newbaudnum > 0) &&(newbaudnum < 250))
			{
				dynamixelinstance.dxl_write_byte( DEFAULT_ID, P_BAUDRATE, newbaudnum);
				DEFAULT_BAUDNUM = newbaudnum;
			}
			hal.console->println("Exitting Specify ID");
		}
		if(user_input == 'g' || user_input == 'G')
		{
			hal.console->println("Menu: + to increase goal, - to decrease goal");
			while(user_input != 27)//Escape
			{
				while( !hal.console->available()) {
					hal.scheduler->delay(20);
				}//Wait till console has some input
				user_input = hal.console->read();

				if(user_input == '+' )
				{
					//Set Goal
					// Write goal position
					goalindex += 10;
					dynamixelinstance.dxl_write_word( DEFAULT_ID, P_GOAL_POSITION_L, goalindex );
			    hal.console->printf_P(PSTR("Setting Goal: %d\n"),goalindex);
				}
				if(user_input == '-')
				{
					goalindex -= 10;
					dynamixelinstance.dxl_write_word( DEFAULT_ID, P_GOAL_POSITION_L, goalindex );
			    hal.console->printf_P(PSTR("Setting Goal: %d\n"),goalindex);
				}
				((PX4UARTDriver*)hal.uartD)->_timer_tick();//Tick the timer for uartD
			}
			goalindex = 0;
			hal.console->println("Exitting Specify goal");
		}
	}
	while( !hal.console->available() ) {
		hal.scheduler->delay(20);
	}
	/*
		 do
		 {
	// Read present position
	PresentPos = dynamixelinstance.dxl_read_word( DEFAULT_ID, P_PRESENT_POSITION_L );
	CommStatus = dynamixelinstance.dxl_get_result();

	if( CommStatus == COMM_RXSUCCESS )
	{
	hal.console->printf_P(PSTR("%d   %d\n"),GoalPos[index], PresentPos);
	PrintErrorCode();
	}
	else
	{
	PrintCommStatus(CommStatus);
	break;
	}

	// Check moving done
	Moving = dynamixelinstance.dxl_read_byte( DEFAULT_ID, P_MOVING );
	CommStatus = dynamixelinstance.dxl_get_result();
	if( CommStatus == COMM_RXSUCCESS )
	{
	if( Moving == 0 )
	{
	// Change goal position
	if( index == 0 )
	index = 1;
	else
	index = 0;					
	}

	PrintErrorCode();
	}
	else
	{
	PrintCommStatus(CommStatus);
	break;
	}
	}while(Moving == 1);
	 */
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
