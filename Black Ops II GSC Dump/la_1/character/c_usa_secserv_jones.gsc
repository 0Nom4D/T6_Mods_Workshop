
main()
{
	self setmodel( "c_usa_secserv_body" );
	self.headmodel = "c_usa_secserv_head_jones";
	self attach( self.headmodel, "", 1 );
	self.gearmodel = "c_usa_secserv_gear_light";
	self attach( self.gearmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_secserv_body" );
	precachemodel( "c_usa_secserv_head_jones" );
	precachemodel( "c_usa_secserv_gear_light" );
}
