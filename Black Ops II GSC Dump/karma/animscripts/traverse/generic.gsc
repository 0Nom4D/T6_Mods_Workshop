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
			assertmsg( "Traversal: 'generic' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	node = self getnegotiationstartnode();
/#
	assert( isDefined( node ) );
#/
/#
	assert( isDefined( node.script_animation ), "Negotion start node must have script_parameters kvp with animname when using generic traversal script" );
#/
	animname = node.script_animation;
/#
	assert( isDefined( level.scr_anim[ "generic" ][ animname ] ), "Anim '" + animname + "' not defined in level.scr_anim["generic"]" );
#/
	traversedata = [];
	traversedata[ "traverseAnim" ] = level.scr_anim[ "generic" ][ animname ];
	traversedata[ "traverseRagdollDeath" ] = 1;
	dotraverse( traversedata );
}
