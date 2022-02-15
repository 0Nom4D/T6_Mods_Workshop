#include codescripts/character;

main()
{
	self setmodel( "c_usa_seal6_body" );
	self.headmodel = "c_usa_seal6_head_flight";
	self attach( self.headmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_usa_seal6_gear_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_usa_seal6_body" );
	precachemodel( "c_usa_seal6_head_flight" );
	codescripts/character::precachemodelarray( xmodelalias/c_usa_seal6_gear_als::main() );
}
