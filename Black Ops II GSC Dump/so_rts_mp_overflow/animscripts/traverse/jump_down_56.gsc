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
			assertmsg( "Traversal: 'jump_down_56' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata = [];
	traversedata[ "traverseAnim" ] = animarray( "jump_down_56", "move" );
	traversedata[ "traverseHeight" ] = 56;
	traversedata[ "traverseStance" ] = "crouch";
	traversedata[ "traverseAlertness" ] = "alert";
	traversedata[ "traverseMovement" ] = "walk";
	dotraverse( traversedata );
}

dog()
{
	dog_jump_down( 56, 5 );
}
