
main()
{
	self setmodel( "c_usa_captured_mason_body" );
	self.headmodel = "c_usa_captured_mason_head_shot";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_captured_mason_body" );
	precachemodel( "c_usa_captured_mason_head_shot" );
}
