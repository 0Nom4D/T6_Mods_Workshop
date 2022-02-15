#include animscripts/anims;
#include animscripts/traverse/shared;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	switch( self.type )
	{
		case "human":
			human();
			break;
		default:
/#
			assertmsg( "Traversal: 'mantle_on_36' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata = [];
	traversedata[ "traverseAnim" ] = array( animarray( "mantle_on_36", "move" ) );
	traversedata[ "traverseHeight" ] = 36;
	traversedata[ "traverseStance" ] = "stand";
	traversedata[ "traverseAlertness" ] = "casual";
	traversedata[ "traverseMovement" ] = "run";
	traversedata[ "interruptDeathAnim" ][ 0 ] = animarray( "traverse_40_death_start", "move" );
	traversedata[ "interruptDeathAnim" ][ 1 ] = animarray( "traverse_40_death_end", "move" );
	dotraverse( traversedata );
}
