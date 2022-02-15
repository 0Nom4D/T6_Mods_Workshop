
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
	self.grenadeweapon = "claymore_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "kard_sp";
	self.subclass = "regular";
	self.team = "allies";
	self.type = "human";
	self.weapon = "dsr50_extclip_sp";
	self setengagementmindist( 800, 500 );
	self setengagementmaxdist( 1200, 2000 );
	character/c_usa_seal6::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "allies" );
}

precache( ai_index )
{
	character/c_usa_seal6::precache();
	precacheitem( "dsr50_extclip_sp" );
	precacheitem( "kard_sp" );
	precacheitem( "claymore_sp" );
}
