#include codescripts/character;

main()
{
	codescripts/character::setmodelfromarray( xmodelalias/c_mul_scientists_shirt_asn_als::main() );
	self.headmodel = "c_mul_scientists_head4";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	codescripts/character::precachemodelarray( xmodelalias/c_mul_scientists_shirt_asn_als::main() );
	precachemodel( "c_mul_scientists_head4" );
}
