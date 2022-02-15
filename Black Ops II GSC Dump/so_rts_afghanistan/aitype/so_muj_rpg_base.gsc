#include codescripts/character;

main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "";
	self.csvinclude = "";
	self.demolockonhighlightdistance = 100;
	self.demolockonviewheightoffset1 = 8;
	self.demolockonviewheightoffset2 = 8;
	self.demolockonviewpitchmax1 = 60;
	self.demolockonviewpitchmax2 = 60;
	self.demolockonviewpitchmin1 = 0;
	self.demolockonviewpitchmin2 = 0;
	self.footstepfxtable = "";
	self.footstepprepend = "";
	self.footstepscriptcallback = 0;
	self.grenadeammo = 2;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "m1911_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "rpg_sp_rts";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	randchar = codescripts/character::get_random_character( 6 );
	switch( randchar )
	{
		case 0:
			character/c_afg_mujadeen_1_1_gib::main();
			break;
		case 1:
			character/c_afg_mujadeen_1_2_gib::main();
			break;
		case 2:
			character/c_afg_mujadeen_1_3_gib::main();
			break;
		case 3:
			character/c_afg_mujadeen_2_1_gib::main();
			break;
		case 4:
			character/c_afg_mujadeen_2_2_gib::main();
			break;
		case 5:
			character/c_afg_mujadeen_2_3_gib::main();
			break;
	}
	self setcharacterindex( randchar );
}

spawner()
{
	self setspawnerteam( "axis" );
}

precache( ai_index )
{
	character/c_afg_mujadeen_1_1_gib::precache();
	character/c_afg_mujadeen_1_2_gib::precache();
	character/c_afg_mujadeen_1_3_gib::precache();
	character/c_afg_mujadeen_2_1_gib::precache();
	character/c_afg_mujadeen_2_2_gib::precache();
	character/c_afg_mujadeen_2_3_gib::precache();
	precacheitem( "rpg_sp_rts" );
	precacheitem( "m1911_sp" );
	precacheitem( "frag_grenade_sp" );
}
