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
			assertmsg( "Traversal: 'mantle_over_40' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata = [];
	traversedata[ "traverseHeight" ] = 40;
	traversedata[ "traverseAnim" ] = array( animarray( "mantle_over_40", "move" ) );
	traversedata[ "traverseStance" ] = "stand";
	traversedata[ "traverseToCoverAnim" ] = animarray( "mantle_over_40_to_cover", "move" );
	traversedata[ "coverType" ] = "Cover Crouch";
	dotraverse( traversedata );
}

dog()
{
	dog_wall_and_window_hop( "window_40", 40 );
}
