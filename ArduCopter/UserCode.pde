/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#ifdef USERHOOK_INIT
void userhook_init()
{
	// put your initialisation code here
	// this will be called once at start-up
	gripperpwm = 500;
  hal.rcout->set_freq(0x0700, 50);//Setting the channels 8,9,10 for regular servos
	//Assuming BRD_PWM_COUNT = 4 i.e last two pins are gpio
	pinMode(54,GPIO_OUTPUT);
	pinMode(55,GPIO_OUTPUT);
	digitalWrite(54,LOW);
	digitalWrite(55,LOW);
	hal.rcout->enable_ch(11); 
	hal.rcout->write(11, 0);//This powers off the motors initially

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
