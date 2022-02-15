#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_afg_muhaj_body2_als::main() );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body2_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body2_gear_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "chinese";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body2_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body2_head_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body2_gear_als::main() );
}
