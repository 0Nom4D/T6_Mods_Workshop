
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
	self.sidearm = "beretta93r_sf_sp";
	self.subclass = "regular";
	self.team = "neutral";
	self.type = "human";
	self.weapon = "tar21_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	character/c_mul_jinan_guard_bscatter_off::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "neutral" );
}

precache( ai_index )
{
	character/c_mul_jinan_guard_bscatter_off::precache();
	precacheitem( "tar21_sp" );
	precacheitem( "beretta93r_sf_sp" );
	precacheitem( "frag_grenade_sp" );
}
