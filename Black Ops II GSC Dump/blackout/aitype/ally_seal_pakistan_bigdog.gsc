
main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "\\bigdog.atr";
	self.csvinclude = "char_bigdog.csv";
	self.demolockonhighlightdistance = 100;
	self.demolockonviewheightoffset1 = 8;
	self.demolockonviewheightoffset2 = 8;
	self.demolockonviewpitchmax1 = 60;
	self.demolockonviewpitchmax2 = 60;
	self.demolockonviewpitchmin1 = 0;
	self.demolockonviewpitchmin2 = 0;
	self.footstepfxtable = "";
	self.footstepprepend = "";
	self.footstepscriptcallback = 1;
	self.grenadeammo = 0;
	self.grenadeweapon = "claw_grenade_impact_explode_sp";
	self.health = 2000;
	self.precachescript = "aitype_bigdog.gsc";
	self.secondaryweapon = "";
	self.sidearm = "";
	self.subclass = "regular";
	self.team = "allies";
	self.type = "bigdog";
	self.weapon = "";
	self setengagementmindist( 500, 300 );
	self setengagementmaxdist( 800, 1200 );
	character/c_t6_claw_mk2::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "allies" );
}

precache( ai_index )
{
	character/c_t6_claw_mk2::precache();
	precacheitem( "claw_grenade_impact_explode_sp" );
	animscripts/aitype/aitype_bigdog::precache();
}
