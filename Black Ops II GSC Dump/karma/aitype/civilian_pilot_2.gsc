
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
	self.footstepprepend = "";
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
	self.weapon = "fiveseven_sp";
	self setengagementmindist( 256, 0 );
	self setengagementmaxdist( 768, 1024 );
	character/c_mul_vtol_pilot2::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "neutral" );
}

precache( ai_index )
{
	character/c_mul_vtol_pilot2::precache();
	precacheitem( "fiveseven_sp" );
	precacheitem( "frag_grenade_sp" );
}
