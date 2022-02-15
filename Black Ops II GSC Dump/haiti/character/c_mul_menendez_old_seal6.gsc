
main()
{
	self setmodel( "c_mul_menendez_old_seal6_body" );
	self.headmodel = "c_mul_menendez_old_seal6_head";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_menendez_old_seal6_body" );
	precachemodel( "c_mul_menendez_old_seal6_head" );
}
