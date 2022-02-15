
main()
{
	self setmodel( "c_usa_afghan_woods_cin_fb" );
	self.headmodel = "c_usa_afghan_woods_facewrap";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_afghan_woods_cin_fb" );
	precachemodel( "c_usa_afghan_woods_facewrap" );
}
