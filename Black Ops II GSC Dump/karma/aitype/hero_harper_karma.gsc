
main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "generic_human.atr";
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
	self.grenadeammo = 0;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "fiveseven_silencer_sp";
	self.subclass = "regular";
	self.team = "allies";
	self.type = "human";
	self.weapon = "hk416_silencer_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	character/c_usa_unioninsp_harper_cin::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "allies" );
}

precache( ai_index )
{
	character/c_usa_unioninsp_harper_cin::precache();
	precacheitem( "hk416_silencer_sp" );
	precacheitem( "fiveseven_silencer_sp" );
	precacheitem( "frag_grenade_sp" );
}
