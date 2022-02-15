
main()
{
	self setmodel( "c_usa_afghan_hudson_fb" );
	self.hatmodel = "c_usa_afghan_hudson_shades";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_afghan_hudson_fb" );
	precachemodel( "c_usa_afghan_hudson_shades" );
}
