
main()
{
	self setmodel( "c_usa_cia_combat_harper_body" );
	self.headmodel = "c_usa_cia_combat_harper_head";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_cia_combat_harper_body" );
	precachemodel( "c_usa_cia_combat_harper_head" );
}
