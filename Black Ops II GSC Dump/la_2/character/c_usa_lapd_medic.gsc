
main()
{
	self setmodel( "c_usa_lapd_medic_body" );
	self.headmodel = "c_usa_lapd_medic_head_mask";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_lapd_medic_body" );
	precachemodel( "c_usa_lapd_medic_head_mask" );
}
