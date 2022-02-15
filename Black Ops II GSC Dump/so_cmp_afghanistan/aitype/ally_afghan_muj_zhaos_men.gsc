#include codescripts/character;

main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "";
	self.csvinclude = "subclass_militia";
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
	self.grenadeammo = 0;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "m1911_sp";
	self.subclass = "militia";
	self.team = "allies";
	self.type = "human";
	self.weapon = "ak47_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	randchar = codescripts/character::get_random_character( 3 );
	switch( randchar )
	{
		case 0:
			character/c_chn_afghan_zhaosmen_1::main();
			break;
		case 1:
			character/c_chn_afghan_zhaosmen_2::main();
			break;
		case 2:
			character/c_chn_afghan_zhaosmen_3::main();
			break;
	}
	self setcharacterindex( randchar );
}

spawner()
{
	self setspawnerteam( "allies" );
}

precache( ai_index )
{
	character/c_chn_afghan_zhaosmen_1::precache();
	character/c_chn_afghan_zhaosmen_2::precache();
	character/c_chn_afghan_zhaosmen_3::precache();
	precacheitem( "ak47_sp" );
	precacheitem( "m1911_sp" );
	precacheitem( "frag_grenade_sp" );
}
