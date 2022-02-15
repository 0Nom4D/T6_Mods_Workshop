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
	self.sidearm = "makarov_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "ak74u_sp";
	self setengagementmindist( 700, 500 );
	self setengagementmaxdist( 1000, 1500 );
	randchar = codescripts/character::get_random_character( 2 );
	switch( randchar )
	{
		case 0:
			character/c_rus_afghan_spetsnaz::main();
			break;
		case 1:
			character/c_rus_afghan_spetsnaz_2::main();
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
	character/c_rus_afghan_spetsnaz::precache();
	character/c_rus_afghan_spetsnaz_2::precache();
	precacheitem( "ak74u_sp" );
	precacheitem( "makarov_sp" );
	precacheitem( "frag_grenade_sp" );
}
