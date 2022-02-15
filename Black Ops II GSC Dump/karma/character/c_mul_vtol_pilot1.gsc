
main()
{
	self setmodel( "c_mul_vtol_pilot_body" );
	self.headmodel = "c_mul_vtol_pilot_head1";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_vtol_pilot_body" );
	precachemodel( "c_mul_vtol_pilot_head1" );
}
