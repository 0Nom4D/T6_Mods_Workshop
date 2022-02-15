#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_afg_muhaj_body2_als::main() );
	self.headmodel = "c_afg_muhajadeen_head_6_1";
	self attach( self.headmodel, "", 1 );
	self.voice = "mujahideen";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body2_als::main() );
	precachemodel( "c_afg_muhajadeen_head_6_1" );
}
