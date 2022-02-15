#include codescripts/character;

main()
{
	self.accuracy = 0,2;
	self.animstatedef = "";
	self.animtree = "generic_human.atr";
	self.csvinclude = "common_civilians.csv";
	self.demolockonhighlightdistance = 100;
	self.demolockonviewheightoffset1 = 8;
	self.demolockonviewheightoffset2 = 8;
	self.demolockonviewpitchmax1 = 60;
	self.demolockonviewpitchmax2 = 60;
	self.demolockonviewpitchmin1 = 0;
	self.demolockonviewpitchmin2 = 0;
	self.footstepfxtable = "";
	self.footstepprepend = "fly_step_civm";
	self.footstepscriptcallback = 0;
	self.grenadeammo = 0;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "";
	self.subclass = "regular";
	self.team = "neutral";
	self.type = "human";
	self.weapon = "";
	self setengagementmindist( 256, 0 );
	self setengagementmaxdist( 768, 1024 );
	randchar = codescripts/character::get_random_character( 6 );
	switch( randchar )
	{
		case 0:
			character/c_mul_civ_rich_male_soot_1::main();
			break;
		case 1:
			character/c_mul_civ_rich_male_soot_1_2::main();
			break;
		case 2:
			character/c_mul_civ_rich_male_soot_2::main();
			break;
		case 3:
			character/c_mul_civ_rich_male_soot_2_2::main();
			break;
		case 4:
			character/c_mul_civ_rich_male_soot_3::main();
			break;
		case 5:
			character/c_mul_civ_rich_male_soot_3_2::main();
			break;
	}
	self setcharacterindex( randchar );
}

spawner()
{
	self setspawnerteam( "neutral" );
}

precache( ai_index )
{
	character/c_mul_civ_rich_male_soot_1::precache();
	character/c_mul_civ_rich_male_soot_1_2::precache();
	character/c_mul_civ_rich_male_soot_2::precache();
	character/c_mul_civ_rich_male_soot_2_2::precache();
	character/c_mul_civ_rich_male_soot_3::precache();
	character/c_mul_civ_rich_male_soot_3_2::precache();
	precacheitem( "frag_grenade_sp" );
}
