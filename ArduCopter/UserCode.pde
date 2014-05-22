/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifdef USERHOOK_INIT
void userhook_init()
{
	// put your initialisation code here
	// this will be called once at start-up
	//armpwm1 =3977;//Corresponds to 350 degrees
	armpwm1 = 480;//Corresponds to 350 degrees
	armpwm2 = 480;//value between 0 to 4095
	armpwm3 = 1023;//Right now not used
	armspeed = 52;//Roughly 6rpm 
  hal.rcout->set_freq(0x0700, 50);//Setting the channels 8,9,10 for regular servos
	dynamixelinstance.dxl_write_word( id1, P_MOVING_SPEED_L, armspeed);
	dynamixelinstance.dxl_write_word( id2, P_MOVING_SPEED_L, armspeed);
}
#endif

#ifdef USERHOOK_FASTLOOP
void userhook_FastLoop()
{
    // put your 100Hz code here
}
#endif

#ifdef USERHOOK_50HZLOOP
void userhook_50Hz()
{
	// put your 50Hz code here
	//Add code here to differentiate armed and disarmed states TODO
	dynamixelinstance.dxl_write_word( id1, P_GOAL_POSITION_L, armpwm1);
	dynamixelinstance.dxl_write_word( id2, P_GOAL_POSITION_L, armpwm2);
	//Have to add gripper clinching code
	hal.rcout->enable_ch(10);
	hal.rcout->write(10, armpwm3);
}
#endif

#ifdef USERHOOK_MEDIUMLOOP
void userhook_MediumLoop()
{
    // put your 10Hz code here
}
#endif

#ifdef USERHOOK_SLOWLOOP
void userhook_SlowLoop()
{
    // put your 3.3Hz code here
}
#endif

#ifdef USERHOOK_SUPERSLOWLOOP
void userhook_SuperSlowLoop()
{
    // put your 1Hz code here
}
#endif
