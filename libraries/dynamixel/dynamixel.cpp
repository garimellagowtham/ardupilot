#include "dynamixel.h"
#include <AP_HAL.h>

extern const AP_HAL::HAL& hal;

unsigned char gbInstructionPacket[MAXNUM_TXPARAM+10] = {0};
unsigned char gbStatusPacket[MAXNUM_RXPARAM+10] = {0};
unsigned char gbRxPacketLength = 0;
unsigned char gbRxGetLength = 0;
uint8_t gbCommStatus = COMM_RXSUCCESS;
uint8_t giBusUsing = 0;
uint8_t timeoutcount;


/* Dynamixel HAL Methods*/
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

/* Dynamixel Higher level methods */
dynamixel::dynamixel()
{
	dynamixel::dxl_initialize(0,1);
}

dynamixel::~dynamixel()
{
	dynamixel::dxl_hal_close();
}


void dynamixel::dxl_initialize( uint8_t devIndex, uint16_t baudnum )
{
	float baudrate;	
	baudrate = 2000000.0f / (float)(baudnum + 1);

	if( dynamixel::dxl_hal_open(devIndex, baudrate) == 0 )
		return;

	gbCommStatus = COMM_RXSUCCESS;
	giBusUsing = 0;
	return;
}

void dynamixel::dxl_tx_packet()
{
	unsigned char i;
	unsigned char TxNumByte, RealTxNumByte;
	unsigned char checksum = 0;

	if( giBusUsing == 1 )
		return;

	giBusUsing = 1;

	if( gbInstructionPacket[LENGTH] > (MAXNUM_TXPARAM+2) )
	{
		gbCommStatus = COMM_TXERROR;
		giBusUsing = 0;
		return;
	}

	if( gbInstructionPacket[INSTRUCTION] != INST_PING
			&& gbInstructionPacket[INSTRUCTION] != INST_READ
			&& gbInstructionPacket[INSTRUCTION] != INST_WRITE
			&& gbInstructionPacket[INSTRUCTION] != INST_REG_WRITE
			&& gbInstructionPacket[INSTRUCTION] != INST_ACTION
			&& gbInstructionPacket[INSTRUCTION] != INST_RESET
			&& gbInstructionPacket[INSTRUCTION] != INST_SYNC_WRITE )
	{
		gbCommStatus = COMM_TXERROR;
		giBusUsing = 0;
		return;
	}

	gbInstructionPacket[0] = 0xff;
	gbInstructionPacket[1] = 0xff;
	for( i=0; i<(gbInstructionPacket[LENGTH]+1); i++ )
		checksum += gbInstructionPacket[i+2];
	gbInstructionPacket[gbInstructionPacket[LENGTH]+3] = ~checksum;

	if( gbCommStatus == COMM_RXTIMEOUT || gbCommStatus == COMM_RXCORRUPT )
		dynamixel::dxl_hal_clear();

	TxNumByte = gbInstructionPacket[LENGTH] + 4;
	RealTxNumByte = dynamixel::dxl_hal_tx( (unsigned char*)gbInstructionPacket, TxNumByte );

	if( TxNumByte != RealTxNumByte )
	{
		gbCommStatus = COMM_TXFAIL;
		giBusUsing = 0;
		return;
	}

	if( gbInstructionPacket[INSTRUCTION] == INST_READ )
		dynamixel::dxl_hal_set_timeout( gbInstructionPacket[PARAMETER+1] + 6 );
	else
		dynamixel::dxl_hal_set_timeout( 6 );

	gbCommStatus = COMM_TXSUCCESS;
}

void dynamixel::dxl_rx_packet()
{
	unsigned char i, j, nRead;
	unsigned char checksum = 0;

	if( giBusUsing == 0 )
		return;

	if( gbInstructionPacket[ID] == BROADCAST_ID )
	{
		gbCommStatus = COMM_RXSUCCESS;
		giBusUsing = 0;
		return;
	}

	if( gbCommStatus == COMM_TXSUCCESS )
	{
		gbRxGetLength = 0;
		gbRxPacketLength = 6;
	}

	nRead = dynamixel::dxl_hal_rx( (unsigned char*)&gbStatusPacket[gbRxGetLength], gbRxPacketLength - gbRxGetLength );
	gbRxGetLength += nRead;
	if( gbRxGetLength < gbRxPacketLength )
	{
		if( dynamixel::dxl_hal_timeout() == 1 )
		{
			if(gbRxGetLength == 0)
				gbCommStatus = COMM_RXTIMEOUT;
			else
				gbCommStatus = COMM_RXCORRUPT;
			giBusUsing = 0;
			return;
		}
	}

	// Find packet header
	for( i=0; i<(gbRxGetLength-1); i++ )
	{
		if( gbStatusPacket[i] == 0xff && gbStatusPacket[i+1] == 0xff )
		{
			break;
		}
		else if( i == gbRxGetLength-2 && gbStatusPacket[gbRxGetLength-1] == 0xff )
		{
			break;
		}
	}	
	if( i > 0 )
	{
		for( j=0; j<(gbRxGetLength-i); j++ )
			gbStatusPacket[j] = gbStatusPacket[j + i];

		gbRxGetLength -= i;		
	}

	if( gbRxGetLength < gbRxPacketLength )
	{
		gbCommStatus = COMM_RXWAITING;
		return;
	}

	// Check id pairing
	if( gbInstructionPacket[ID] != gbStatusPacket[ID])
	{
		gbCommStatus = COMM_RXCORRUPT;
		giBusUsing = 0;
		return;
	}

	gbRxPacketLength = gbStatusPacket[LENGTH] + 4;
	if( gbRxGetLength < gbRxPacketLength )
	{
		nRead = dynamixel::dxl_hal_rx( (unsigned char*)&gbStatusPacket[gbRxGetLength], gbRxPacketLength - gbRxGetLength );
		gbRxGetLength += nRead;
		if( gbRxGetLength < gbRxPacketLength )
		{
			gbCommStatus = COMM_RXWAITING;
			return;
		}
	}

	// Check checksum
	for( i=0; i<(gbStatusPacket[LENGTH]+1); i++ )
		checksum += gbStatusPacket[i+2];
	checksum = ~checksum;

	if( gbStatusPacket[gbStatusPacket[LENGTH]+3] != checksum )
	{
		gbCommStatus = COMM_RXCORRUPT;
		giBusUsing = 0;
		return;
	}

	gbCommStatus = COMM_RXSUCCESS;
	giBusUsing = 0;
}

void dynamixel::dxl_txrx_packet()
{
	dxl_tx_packet();

	if( gbCommStatus != COMM_TXSUCCESS )
		return;	

	do{
		dxl_rx_packet();		
	}while( gbCommStatus == COMM_RXWAITING );	
}

uint8_t dynamixel::dxl_get_result()
{
	return gbCommStatus;
}

void dynamixel::dxl_set_txpacket_id( uint8_t id )
{
	gbInstructionPacket[ID] = (unsigned char)id;
}

void dynamixel::dxl_set_txpacket_instruction( uint8_t instruction )
{
	gbInstructionPacket[INSTRUCTION] = (unsigned char)instruction;
}

void dynamixel::dxl_set_txpacket_parameter( uint8_t index, uint8_t value )
{
	gbInstructionPacket[PARAMETER+index] = (unsigned char)value;
}

void dynamixel::dxl_set_txpacket_length( uint8_t length )
{
	gbInstructionPacket[LENGTH] = (unsigned char)length;
}

uint8_t dynamixel::dxl_get_rxpacket_error( uint8_t errbit )
{
	if( gbStatusPacket[ERRBIT] & (unsigned char)errbit )
		return 1;

	return 0;
}

uint8_t dynamixel::dxl_get_rxpacket_length()
{
	return (uint8_t)gbStatusPacket[LENGTH];
}

uint8_t dynamixel::dxl_get_rxpacket_parameter( uint8_t index )
{
	return (uint8_t)gbStatusPacket[PARAMETER+index];
}

uint16_t dynamixel::dxl_makeword( uint8_t lowbyte, uint8_t highbyte )
{
	uint16_t word;

	word = highbyte;
	word = ((word << 8)&0xff00);//Depends on Little and Big Endian
	word = word + lowbyte;
	return word;
}

uint8_t dynamixel::dxl_get_lowbyte( uint16_t word )
{
	uint8_t  temp;
	temp = uint8_t(word & 0x00ff);
	return temp;
}

uint8_t dynamixel::dxl_get_highbyte( uint16_t word )
{
	uint8_t  temp;
	temp = uint8_t((word & 0xff00)>>8);//This depends on little/BigEndian see if it does not work have to change
	return temp;
}

void dynamixel::dxl_ping( uint8_t id )
{
	while(giBusUsing);

	gbInstructionPacket[ID] = (unsigned char)id;
	gbInstructionPacket[INSTRUCTION] = INST_PING;
	gbInstructionPacket[LENGTH] = 2;

	dxl_txrx_packet();
}

uint8_t dynamixel::dxl_read_byte( uint8_t id, uint8_t address )
{
	while(giBusUsing);

	gbInstructionPacket[ID] = (unsigned char)id;
	gbInstructionPacket[INSTRUCTION] = INST_READ;
	gbInstructionPacket[PARAMETER] = (unsigned char)address;
	gbInstructionPacket[PARAMETER+1] = 1;
	gbInstructionPacket[LENGTH] = 4;

	dxl_txrx_packet();

	return (uint8_t)gbStatusPacket[PARAMETER];
}

void dynamixel::dxl_write_byte( uint8_t id, uint8_t address, uint8_t value )
{
	while(giBusUsing);

	gbInstructionPacket[ID] = (unsigned char)id;
	gbInstructionPacket[INSTRUCTION] = INST_WRITE;
	gbInstructionPacket[PARAMETER] = (unsigned char)address;
	gbInstructionPacket[PARAMETER+1] = (unsigned char)value;
	gbInstructionPacket[LENGTH] = 4;

	dxl_txrx_packet();
}

uint16_t dynamixel::dxl_read_word( uint8_t id, uint8_t address )
{
	while(giBusUsing);

	gbInstructionPacket[ID] = (unsigned char)id;
	gbInstructionPacket[INSTRUCTION] = INST_READ;
	gbInstructionPacket[PARAMETER] = (unsigned char)address;
	gbInstructionPacket[PARAMETER+1] = 2;
	gbInstructionPacket[LENGTH] = 4;

	dxl_txrx_packet();

	return dxl_makeword((uint8_t)gbStatusPacket[PARAMETER], (uint8_t)gbStatusPacket[PARAMETER+1]);
}

void dynamixel::dxl_write_word( uint8_t id, uint8_t address, uint16_t value )
{
	while(giBusUsing);

	gbInstructionPacket[ID] = (unsigned char)id;
	gbInstructionPacket[INSTRUCTION] = INST_WRITE;
	gbInstructionPacket[PARAMETER] = (unsigned char)address;
	gbInstructionPacket[PARAMETER+1] = (unsigned char)dxl_get_lowbyte(value);
	gbInstructionPacket[PARAMETER+2] = (unsigned char)dxl_get_highbyte(value);
	gbInstructionPacket[LENGTH] = 5;

	dxl_txrx_packet();
}
