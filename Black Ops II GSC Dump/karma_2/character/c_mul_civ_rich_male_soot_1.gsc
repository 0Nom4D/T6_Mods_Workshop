#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_mul_civ_rich_male_soot_up_als::main() );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_mul_civ_rich_male_shot_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = codescripts/character::randomelement( xmodelalias/c_mul_civ_rich_male_soot_lower_als::main() );
	self attach( self.hatmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_mul_civ_rich_male_soot_up_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_civ_rich_male_shot_head_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_civ_rich_male_soot_lower_als::main() );
}
