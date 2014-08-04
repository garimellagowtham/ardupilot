/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

// user defined variables

#define PX4_GPIO_FMU_SERVO_PIN(n)       (n+50) //Copied from gpio

uint16_t armpwm1;//Here it is position rather than pwm
uint16_t armpwm2;
uint16_t armpwm3;
uint16_t armspeed;//Unit 0.114rpm
uint16_t M1_MIN, M2_MIN, M1_MAX, M2_MAX;

dynamixel dynamixelinstance;
#define P_GOAL_POSITION_L 30
#define P_GOAL_POSITION_H 31
#define P_PRESENT_POSITION_L  36
#define P_PRESENT_POSITION_H  37
#define P_MOVING    46
#define P_ID 3
#define P_MOVING_SPEED_L 32
#define P_MOVING_SPEED_H 33


#define DEFAULT_BAUDNUM 34; // 57600bps baud rate

uint8_t id1 = 1, id2 = 2;//Will combine the id with  pwm to make a struct array


// example variables used in Wii camera testing - replace with your own
// variables
#ifdef USERHOOK_VARIABLES

#if WII_CAMERA == 1
WiiCamera           ircam;
int                 WiiRange=0;
int                 WiiRotation=0;
int                 WiiDisplacementX=0;
int                 WiiDisplacementY=0;
#endif  // WII_CAMERA

#endif  // USERHOOK_VARIABLES


