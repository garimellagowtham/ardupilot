// Dynamixel SDK platform independent header
#ifndef _DYNAMIXEL_HEADER
#define _DYNAMIXEL_HEADER

#define ID					(2)
#define LENGTH				(3)
#define INSTRUCTION			(4)
#define ERRBIT				(4)
#define PARAMETER			(5)
#define DEFAULT_BAUDNUMBER	(1)


#define BROADCAST_ID		(254)

#define INST_PING			(1)
#define INST_READ			(2)
#define INST_WRITE			(3)
#define INST_REG_WRITE		(4)
#define INST_ACTION			(5)
#define INST_RESET			(6)
#define INST_SYNC_WRITE		(131)

#define MAXNUM_TXPARAM		(150)

#define ERRBIT_VOLTAGE		(1)
#define ERRBIT_ANGLE		(2)
#define ERRBIT_OVERHEAT		(4)
#define ERRBIT_RANGE		(8)
#define ERRBIT_CHECKSUM		(16)
#define ERRBIT_OVERLOAD		(32)
#define ERRBIT_INSTRUCTION	(64)

#define MAXNUM_RXPARAM		(60)

#define	COMM_TXSUCCESS		(0)
#define COMM_RXSUCCESS		(1)
#define COMM_TXFAIL			(2)
#define COMM_RXFAIL			(3)
#define COMM_TXERROR		(4)
#define COMM_RXWAITING		(5)
#define COMM_RXTIMEOUT		(6)
#define COMM_RXCORRUPT		(7)

#include <AP_HAL.h>
#include <stdint.h>


class dynamixel
{
//	public: 
	public:
		//Hal methods:
		void dxl_initialize( uint8_t devIndex, uint16_t baudnum );
		uint8_t dxl_hal_open( uint8_t devIndex, float baudrate );
 		void dxl_hal_close(void);
		void dxl_hal_clear(void);
		uint8_t dxl_hal_tx( unsigned char *pPacket, uint8_t numPacket );
		uint8_t dxl_hal_rx( unsigned char *pPacket, uint8_t numPacket );
		void dxl_hal_set_timeout( uint8_t NumRcvByte );
		uint8_t dxl_hal_timeout(void);

		///////////// device control methods ////////////////////////
		dynamixel(void);//Constructor
		~dynamixel(void);//Destructor


		///////////// set/get packet methods //////////////////////////
		void dxl_set_txpacket_id( uint8_t id );

		void dxl_set_txpacket_instruction( uint8_t instruction );
		void dxl_set_txpacket_parameter( uint8_t index, uint8_t value );
		void dxl_set_txpacket_length( uint8_t length );

		uint8_t dxl_get_rxpacket_error( uint8_t errbit );
		uint8_t dxl_get_rxpacket_parameter( uint8_t index );
		uint8_t dxl_get_rxpacket_length(void);

		// utility for value
		uint16_t dxl_makeword( uint8_t lowbyte, uint8_t highbyte );
		uint8_t dxl_get_lowbyte( uint16_t word );
		uint8_t dxl_get_highbyte( uint16_t word );


		////////// packet communication methods ///////////////////////
		void dxl_tx_packet(void);
		void dxl_rx_packet(void);
		void dxl_txrx_packet(void);

		uint8_t dxl_get_result(void);

		//////////// high communication methods ///////////////////////
		void dxl_ping( uint8_t id );
		uint8_t dxl_read_byte( uint8_t id, uint8_t address );
		void dxl_write_byte( uint8_t id, uint8_t address, uint8_t value );
		uint16_t dxl_read_word( uint8_t id, uint8_t address );
		void dxl_write_word( uint8_t id, uint8_t address, uint16_t value );
};



#endif
