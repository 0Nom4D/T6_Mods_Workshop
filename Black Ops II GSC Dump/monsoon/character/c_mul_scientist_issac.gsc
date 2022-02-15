
main()
{
	self setmodel( "c_mul_scientists_jacket1" );
	self.headmodel = "c_mul_scientists_issac_head_cin";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_scientists_jacket1" );
	precachemodel( "c_mul_scientists_issac_head_cin" );
}
