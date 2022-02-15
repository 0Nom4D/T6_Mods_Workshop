
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
	self.grenadeammo = 2;
	self.grenadeweapon = "emp_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "beretta93r_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "qbb95_sp";
	self setengagementmindist( 500, 400 );
	self setengagementmaxdist( 1000, 1200 );
	character/c_mul_pmc_1_freeze::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "axis" );
}

precache( ai_index )
{
	character/c_mul_pmc_1_freeze::precache();
	precacheitem( "qbb95_sp" );
	precacheitem( "beretta93r_sp" );
	precacheitem( "emp_grenade_sp" );
}
