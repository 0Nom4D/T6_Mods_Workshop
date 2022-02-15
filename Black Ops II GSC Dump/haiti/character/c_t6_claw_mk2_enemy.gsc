
main()
{
	self setmodel( "veh_t6_drone_claw_mk2_alt" );
	self.headmodel = "veh_t6_drone_claw_mk2_turret";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "veh_t6_drone_claw_mk2_alt" );
	precachemodel( "veh_t6_drone_claw_mk2_turret" );
}
