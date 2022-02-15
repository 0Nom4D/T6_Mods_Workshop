#include codescripts/character;

main()
{
	self setmodel( "c_mul_pmc_body_1_1_wt" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_mul_pmc_body1_head_wt_als::main() );
	self attach( self.headmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_mul_pmc_body1_gear_wt_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "pmc";
	self.skeleton = "base";
	self.torsodmg1 = "c_mul_pmc_body_1_1_wt_g_upclean";
	self.torsodmg2 = "c_mul_pmc_body_1_1_wt_g_rarmoff";
	self.torsodmg3 = "c_mul_pmc_body_1_1_wt_g_larmoff";
	self.legdmg1 = "c_mul_pmc_body_1_1_wt_g_lowclean";
	self.legdmg2 = "c_mul_pmc_body_1_1_wt_g_rlegoff";
	self.legdmg3 = "c_mul_pmc_body_1_1_wt_g_llegoff";
	self.legdmg4 = "c_mul_pmc_body_1_1_wt_g_legsoff";
	self.gibspawn1 = "c_mul_pmc_body_1_1_g_spawn_rarm";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_mul_pmc_body_1_1_g_spawn_larm";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_mul_pmc_body_1_1_g_spawn_rleg";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_mul_pmc_body_1_1_g_spawn_lleg";
	self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
	precachemodel( "c_mul_pmc_body_1_1_wt" );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_pmc_body1_head_wt_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_pmc_body1_gear_wt_als::main() );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_upclean" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_rarmoff" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_larmoff" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_lowclean" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_rlegoff" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_llegoff" );
	precachemodel( "c_mul_pmc_body_1_1_wt_g_legsoff" );
	precachemodel( "c_mul_pmc_body_1_1_g_spawn_rarm" );
	precachemodel( "c_mul_pmc_body_1_1_g_spawn_larm" );
	precachemodel( "c_mul_pmc_body_1_1_g_spawn_rleg" );
	precachemodel( "c_mul_pmc_body_1_1_g_spawn_lleg" );
}
