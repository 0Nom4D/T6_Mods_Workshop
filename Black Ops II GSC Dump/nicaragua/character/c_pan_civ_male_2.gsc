#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_pan_civ_male_body2_als::main() );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_pan_civ_male_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_pan_civ_male_body2_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_pan_civ_male_head_als::main() );
}
