
main()
{
	self setmodel( "c_mul_menendez_young_body" );
	self.headmodel = "c_mul_menendez_young_head";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_menendez_young_body" );
	precachemodel( "c_mul_menendez_young_head" );
}
