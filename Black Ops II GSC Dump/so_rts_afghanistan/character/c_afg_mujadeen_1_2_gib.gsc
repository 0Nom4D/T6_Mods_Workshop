#include codescripts/character;

main()
{
	self setmodel( "c_afg_muhajadeen_body_1_2" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body1_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_afg_muhaj_body1_gear_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "mujahideen";
	self.skeleton = "base";
	self.torsodmg1 = "c_afg_muhaj_body_1_2_g_upclean";
	self.torsodmg2 = "c_afg_muhaj_body_1_2_g_rarmoff";
	self.torsodmg3 = "c_afg_muhaj_body_1_2_g_larmoff";
	self.legdmg1 = "c_afg_muhaj_body_1_2_g_lowclean";
	self.legdmg2 = "c_afg_muhaj_body_1_2_g_rlegoff";
	self.legdmg3 = "c_afg_muhaj_body_1_2_g_llegoff";
	self.legdmg4 = "c_afg_muhaj_body_1_2_g_legsoff";
	self.gibspawn1 = "c_afg_muhaj_body_g_rarm_spawn";
	self.gibspawntag1 = "J_Elbow_RI";
	self.gibspawn2 = "c_afg_muhaj_body_g_larm_spawn";
	self.gibspawntag2 = "J_Elbow_LE";
	self.gibspawn3 = "c_afg_muhaj_body_g_rleg_spawn";
	self.gibspawntag3 = "J_Knee_RI";
	self.gibspawn4 = "c_afg_muhaj_body_g_lleg_spawn";
	self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
	precachemodel( "c_afg_muhajadeen_body_1_2" );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body1_head_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afg_muhaj_body1_gear_als::main() );
	precachemodel( "c_afg_muhaj_body_1_2_g_upclean" );
	precachemodel( "c_afg_muhaj_body_1_2_g_rarmoff" );
	precachemodel( "c_afg_muhaj_body_1_2_g_larmoff" );
	precachemodel( "c_afg_muhaj_body_1_2_g_lowclean" );
	precachemodel( "c_afg_muhaj_body_1_2_g_rlegoff" );
	precachemodel( "c_afg_muhaj_body_1_2_g_llegoff" );
	precachemodel( "c_afg_muhaj_body_1_2_g_legsoff" );
	precachemodel( "c_afg_muhaj_body_g_rarm_spawn" );
	precachemodel( "c_afg_muhaj_body_g_larm_spawn" );
	precachemodel( "c_afg_muhaj_body_g_rleg_spawn" );
	precachemodel( "c_afg_muhaj_body_g_lleg_spawn" );
}
