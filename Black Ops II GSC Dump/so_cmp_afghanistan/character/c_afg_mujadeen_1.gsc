#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_afg_muhaj_body1_als::main() );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body1_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body1_gear_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "mujahideen";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body1_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body1_head_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body1_gear_als::main() );
}
