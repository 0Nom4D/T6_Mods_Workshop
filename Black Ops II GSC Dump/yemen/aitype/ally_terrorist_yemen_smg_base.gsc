#include codescripts/character;

main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "";
	self.csvinclude = "subclass_militia.csv";
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
	self.sidearm = "fiveseven_sp";
	self.subclass = "militia";
	self.team = "allies";
	self.type = "human";
	self.weapon = "evoskorpion_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	randchar = codescripts/character::get_random_character( 8 );
	switch( randchar )
	{
		case 0:
			character/c_mul_cordis3_1::main();
			break;
		case 1:
			character/c_mul_cordis1_2::main();
			break;
		case 2:
			character/c_mul_cordis1_3::main();
			break;
		case 3:
			character/c_mul_cordis1_4::main();
			break;
		case 4:
			character/c_mul_cordis2_1::main();
			break;
		case 5:
			character/c_mul_cordis2_2::main();
			break;
		case 6:
			character/c_mul_cordis2_3::main();
			break;
		case 7:
			character/c_mul_cordis2_4::main();
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
	character/c_mul_cordis3_1::precache();
	character/c_mul_cordis1_2::precache();
	character/c_mul_cordis1_3::precache();
	character/c_mul_cordis1_4::precache();
	character/c_mul_cordis2_1::precache();
	character/c_mul_cordis2_2::precache();
	character/c_mul_cordis2_3::precache();
	character/c_mul_cordis2_4::precache();
	precacheitem( "evoskorpion_sp" );
	precacheitem( "fiveseven_sp" );
	precacheitem( "frag_grenade_sp" );
}
