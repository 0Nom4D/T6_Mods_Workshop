#include codescripts/character;

main()
{
	self setmodel( "c_afr_unitas_body2" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_afr_unitas_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.hatmodel = codescripts/character::randomelement( xmodelalias/c_afr_unitas_hat_als::main() );
	self attach( self.hatmodel, "", 1 );
	self.gearmodel = codescripts/character::randomelement( xmodelalias/c_afr_unitas_gear_als::main() );
	self attach( self.gearmodel, "", 1 );
	self.voice = "unita";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_afr_unitas_body2" );
	codescripts/character::precachemodelarray( xmodelalias/c_afr_unitas_head_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afr_unitas_hat_als::main() );
	codescripts/character::precachemodelarray( xmodelalias/c_afr_unitas_gear_als::main() );
}
