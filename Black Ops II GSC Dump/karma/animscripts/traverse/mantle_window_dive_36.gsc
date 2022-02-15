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
			assertmsg( "Traversal: 'mantle_window_dive_36' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata = [];
	traversedata[ "traverseHeight" ] = 36;
	traversedata[ "traverseAnim" ] = animarray( "mantle_window_dive_36", "move" );
	dotraverse( traversedata );
}
