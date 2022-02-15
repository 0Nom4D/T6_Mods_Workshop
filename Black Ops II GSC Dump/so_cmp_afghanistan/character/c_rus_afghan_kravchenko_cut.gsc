
main()
{
	self setmodel( "c_rus_afghan_kravchenko_body" );
	self.headmodel = "c_rus_afghan_kravchenko_head_cut";
	self attach( self.headmodel, "", 1 );
	self.hatmodel = "c_rus_afghan_kravchenko_rarm";
	self attach( self.hatmodel );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_rus_afghan_kravchenko_body" );
	precachemodel( "c_rus_afghan_kravchenko_head_cut" );
	precachemodel( "c_rus_afghan_kravchenko_rarm" );
}
