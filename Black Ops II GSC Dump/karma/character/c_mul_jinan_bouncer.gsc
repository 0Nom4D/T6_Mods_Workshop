#include codescripts/character;

main()
{
	self setmodel( "c_mul_jinan_bouncer_body" );
	self.headmodel = codescripts/character::randomelement( xmodelalias/c_mul_jinan_bouncer_head_als::main() );
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_jinan_bouncer_body" );
	codescripts/character::precachemodelarray( xmodelalias/c_mul_jinan_bouncer_head_als::main() );
}
