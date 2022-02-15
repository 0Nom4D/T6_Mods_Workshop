#include codescripts/character;

main()
{
	self setmodel( "c_mul_civ_rich_female_shot_body1_3" );
	self.headmodel = "c_mul_civ_rich_female_shot_head5";
	self attach( self.headmodel, "", 1 );
	self.hatmodel = codescripts/character::randomelement( xmodelalias/c_mul_civ_rich_female_shot_clothes_als::main() );
	self attach( self.hatmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_civ_rich_female_shot_body1_3" );
	precachemodel( "c_mul_civ_rich_female_shot_head5" );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_civ_rich_female_shot_clothes_als::main() );
}
