#include animscripts/anims;
#include animscripts/traverse/shared;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	preparefortraverse();
	traversedata[ "traverseAnim" ] = animarray( "jump_across_72", "move" );
	traversedata[ "traverseStance" ] = "stand";
	dotraverse( traversedata );
}
