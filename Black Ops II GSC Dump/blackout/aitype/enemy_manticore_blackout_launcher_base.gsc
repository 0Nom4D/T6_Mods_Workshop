
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
	self.grenadeammo = 1;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "vector_sp";
	self.sidearm = "fiveseven_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "usrpg_nodrop_sp";
	self setengagementmindist( 700, 500 );
	self setengagementmaxdist( 1000, 1500 );
	character/c_mul_pmc_1::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "axis" );
}

precache( ai_index )
{
	character/c_mul_pmc_1::precache();
	precacheitem( "usrpg_nodrop_sp" );
	precacheitem( "vector_sp" );
	precacheitem( "fiveseven_sp" );
	precacheitem( "frag_grenade_sp" );
}
