
main()
{
	self setmodel( "c_afg_muhajadeen_body_1_1" );
	self.headmodel = "c_afg_muhajadeen_head_1_1";
	self attach( self.headmodel, "", 1 );
	self.gearmodel = "c_afg_muhajadeen_gear_1_1";
	self attach( self.gearmodel, "", 1 );
	self.voice = "mujahideen";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_afg_muhajadeen_body_1_1" );
	precachemodel( "c_afg_muhajadeen_head_1_1" );
	precachemodel( "c_afg_muhajadeen_gear_1_1" );
}
