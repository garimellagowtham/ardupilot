/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifdef USERHOOK_INIT
void userhook_init()
{
	// put your initialisation code here
	// this will be called once at start-up
	//armpwm1 =3977;//Corresponds to 350 degrees
	/*armpwm1 = 480;//Corresponds to 40 degrees approx
	armpwm2 = 480;//value between 0 to 4095
	armpwm3 = 500;//means gripper is neutral CHANGE
	*/
	M1_MIN = 937;
	M2_MIN = 0;
	M1_MAX = 2337;
	M2_MAX = 3070;
	armpwm1 = 2167;
	armpwm2 = M2_MIN;
	armpwm3 = 500;
	//armspeed = 52;//Roughly 6rpm 
	armspeed = 78;//Roughly 9rpm 
  //hal.rcout->set_freq(0x0700, 50);//Setting the channels 8,9,10 for regular servos
  hal.rcout->set_freq(0x0700, 50);//Setting the channels 8,9,10 for regular servos
	dynamixelinstance.dxl_write_word( id1, P_MOVING_SPEED_L, armspeed);
	dynamixelinstance.dxl_write_word( id2, P_MOVING_SPEED_L, armspeed);
	//Assuming BRD_PWM_COUNT = 4 i.e last two pins are gpio
	pinMode(54,GPIO_OUTPUT);
	pinMode(55,GPIO_OUTPUT);
	digitalWrite(54,LOW);
	digitalWrite(55,LOW);
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
	armpwm1 = armpwm1 > M1_MAX?M1_MAX:(armpwm1<M1_MIN?M1_MIN:armpwm1);//Bind value betn max and min of workspace
	armpwm2 = armpwm2 > M2_MAX?M2_MAX:(armpwm2<M2_MIN?M2_MIN:armpwm2);//Bind value betn max and min of workspace
	dynamixelinstance.dxl_write_word( id1, P_GOAL_POSITION_L, armpwm1);
	dynamixelinstance.dxl_write_word( id2, P_GOAL_POSITION_L, armpwm2);
	//Have to add gripper clinching code
	if(armpwm3 > 700)//TRISTATE gripper 
	{
		digitalWrite(54,LOW);
		hal.rcout->enable_ch(11);
		hal.rcout->write(11, 10000);//This is not for servo
	}
	else if(armpwm3 < 300)
	{
		digitalWrite(54,HIGH);
		hal.rcout->enable_ch(11);
		hal.rcout->write(11, 10000);
	}
	else
	{
		digitalWrite(54,LOW);
		hal.rcout->enable_ch(11);
		hal.rcout->write(11, 0);//Not moving
	}
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
