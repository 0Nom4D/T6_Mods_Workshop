#include codescripts/character;

main()
{
	self.accuracy = 0,5;
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
	self.sidearm = "fnp45_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "usrpg_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	randchar = codescripts/character::get_random_character( 3 );
	switch( randchar )
	{
		case 0:
			character/c_pak_isi_1_char_wet::main();
			break;
		case 1:
			character/c_pak_isi_2_char_wet::main();
			break;
		case 2:
			character/c_pak_isi_3_char_wet::main();
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
	character/c_pak_isi_1_char_wet::precache();
	character/c_pak_isi_2_char_wet::precache();
	character/c_pak_isi_3_char_wet::precache();
	precacheitem( "usrpg_sp" );
	precacheitem( "fnp45_sp" );
	precacheitem( "frag_grenade_sp" );
}
