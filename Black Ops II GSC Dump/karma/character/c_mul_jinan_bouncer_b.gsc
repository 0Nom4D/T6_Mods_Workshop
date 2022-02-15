
main()
{
	self setmodel( "c_mul_jinan_bouncer_body" );
	self.headmodel = "c_mul_jinan_bouncer_head2";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_jinan_bouncer_body" );
	precachemodel( "c_mul_jinan_bouncer_head2" );
}
