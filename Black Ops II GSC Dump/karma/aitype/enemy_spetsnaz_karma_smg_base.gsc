
main()
{
	self.accuracy = 1;
	self.animstatedef = "";
	self.animtree = "";
	self.csvinclude = "char_spetsnaz.csv";
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
	self.grenadeweapon = "concussion_grenade_future_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "beretta93r_silencer_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "qcw05_silencer_sp";
	self setengagementmindist( 250, 0 );
	self setengagementmaxdist( 700, 1000 );
	character/c_mul_pmc_undercover_ol::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "axis" );
}

precache( ai_index )
{
	character/c_mul_pmc_undercover_ol::precache();
	precacheitem( "qcw05_silencer_sp" );
	precacheitem( "beretta93r_silencer_sp" );
	precacheitem( "concussion_grenade_future_sp" );
}
