
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
	self.grenadeammo = 0;
	self.grenadeweapon = "frag_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "kard_semiauto_sp";
	self.subclass = "regular";
	self.team = "allies";
	self.type = "human";
	self.weapon = "xm8_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	character/c_usa_secserv_swat_tactical::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "allies" );
}

precache( ai_index )
{
	character/c_usa_secserv_swat_tactical::precache();
	precacheitem( "xm8_sp" );
	precacheitem( "kard_semiauto_sp" );
	precacheitem( "frag_grenade_sp" );
}
