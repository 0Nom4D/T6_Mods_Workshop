
main()
{
	self setmodel( "c_usa_cia_combat_harper_body_assault" );
	self.headmodel = "c_usa_cia_combat_harper_head_scar";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_cia_combat_harper_body_assault" );
	precachemodel( "c_usa_cia_combat_harper_head_scar" );
}
