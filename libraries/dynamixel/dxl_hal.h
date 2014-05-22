// Dynamixel SDK platform dependent header
#ifndef _DYNAMIXEL_HAL_HEADER
#define _DYNAMIXEL_HAL_HEADER

//#include <DataFlash.h>

extern const AP_HAL::HAL& hal;


uint8_t dynamixel::dxl_hal_open( uint8_t devIndex, float baudrate )
{
	// Opening device
	// devIndex: Device index
	// baudrate: Real baudrate (ex> 115200, 57600, 38400...)
	// Return: 0(Failed), 1(Succeed)
	timeoutcount = 0;
	if(hal.uartD != NULL)
	{
		hal.uartD->begin( uint32_t(baudrate), 256, 256);
		return 1;
	}
	else
	{
		return 0;
	}
}
void dynamixel::dxl_hal_close(void)
{
	// Closing device
	hal.uartD->end();//Close the serial device
}
void dynamixel::dxl_hal_clear(void)
{
	// Clear communication buffer
	timeoutcount = 0;
	//Not implemented
}

uint8_t dynamixel::dxl_hal_tx( unsigned char *pPacket, uint8_t numPacket )
{
	// Transmiting date
	// *pPacket: data array pointer
	// numPacket: number of data array
	// Return: number of data transmitted. -1 is error.
	return hal.uartD->write(pPacket,numPacket);
}
uint8_t dynamixel::dxl_hal_rx( unsigned char *pPacket, uint8_t numPacket )
{
	// Recieving date
	// *pPacket: data array pointer
	// numPacket: number of data array
	// Return: number of data recieved. -1 is error.
	//return hal.uartD->_read_fd(pPacket, numPacket);
	uint8_t availablebytes = hal.uartD->available();
	if(availablebytes > numPacket)
		availablebytes = numPacket;
	else if(availablebytes < 0)
		availablebytes = -1;//Error
	if(availablebytes > 0)
	{
		for(int count1 =0;count1< availablebytes;count1++)
			pPacket[count1] = (unsigned char)hal.uartD->read();
	}
	return availablebytes;
}
void dynamixel::dxl_hal_set_timeout( uint8_t NumRcvByte )
{
	// Start stop watch
	// NumRcvByte: number of recieving data(to calculate maximum waiting time)
	timeoutcount = NumRcvByte;
}
uint8_t dynamixel::dxl_hal_timeout(void)
{
	// Check timeout
	// Return: 0 is false, 1 is true(timeout occurred)
	 hal.scheduler->delay(1);//constant delay whenever delay just to give others time for doing their tasks
	 if((timeoutcount--) > 0)
		 return 0;
	 else
		 return 1;
}
#endif
