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
			assertmsg( "Traversal: 'jump_across_120' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	preparefortraverse();
	traversedata[ "traverseAnim" ] = animarray( "jump_across_120", "move" );
	traversedata[ "traverseStance" ] = "stand";
	dotraverse( traversedata );
}
