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
		case "dog":
			dog();
			break;
		default:
/#
			assertmsg( "Traversal: 'mantle_window_36' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata = [];
	traversedata[ "traverseHeight" ] = 36;
	traversedata[ "traverseAnim" ] = animarray( "mantle_window_36_run", "move" );
	traversedata[ "traverseToCoverAnim" ] = animarray( "mantle_window_36_stop", "move" );
	traversedata[ "coverType" ] = "Cover Crouch";
	traversedata[ "interruptDeathAnim" ][ 0 ] = animarray( "traverse_40_death_start", "move" );
	traversedata[ "interruptDeathAnim" ][ 1 ] = animarray( "traverse_40_death_end", "move" );
	dotraverse( traversedata );
}

dog()
{
	dog_wall_and_window_hop( "window_40", 40 );
}
