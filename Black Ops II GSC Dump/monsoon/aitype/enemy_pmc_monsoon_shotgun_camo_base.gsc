
main()
{
	self.accuracy = 0,2;
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
	self.grenadeweapon = "emp_grenade_sp";
	self.health = 100;
	self.precachescript = "";
	self.secondaryweapon = "";
	self.sidearm = "beretta93r_sp";
	self.subclass = "regular";
	self.team = "axis";
	self.type = "human";
	self.weapon = "saiga12_sp";
	self setengagementmindist( 256, 0 );
	self setengagementmaxdist( 768, 1024 );
	character/c_mul_pmc_cloak::main();
	self setcharacterindex( 0 );
}

spawner()
{
	self setspawnerteam( "axis" );
}

precache( ai_index )
{
	character/c_mul_pmc_cloak::precache();
	precacheitem( "saiga12_sp" );
	precacheitem( "beretta93r_sp" );
	precacheitem( "emp_grenade_sp" );
}
