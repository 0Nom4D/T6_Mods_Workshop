#include animscripts/traverse/stairs_util;
#include maps/_utility;
#include animscripts/utility;
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
			assertmsg( "Traversal: 'stairs_up' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	movement = preparefortraverse();
	traversedata = [];
	if ( self animscripts/traverse/stairs_util::get_stair_count() % 2 )
	{
		transition_stair_count_in = 0;
		traversedata[ "traverseAnimTransIn" ] = animarray( "staircase_up_8x16_in", movement );
	}
	else
	{
		transition_stair_count_in = 1;
		traversedata[ "traverseAnimTransIn" ] = animarray( "staircase_up_8x16_in_even", movement );
	}
	transition_stair_count_out = 1;
	traversedata[ "traverseAnimTransOut" ] = animarray( "staircase_up_8x16_out", movement );
	stair_anims[ 2 ] = animarray( "staircase_up_8x16_2", movement, 0 );
	stair_anims[ 4 ] = animarray( "staircase_up_8x16_4", movement, 0 );
	stair_anims[ 6 ] = animarray( "staircase_up_8x16_6", movement, 0 );
	stair_anims[ 8 ] = animarray( "staircase_up_8x16_8", movement, 0 );
	stair_anims[ 10 ] = animarray( "staircase_up_8x16_10", movement, 0 );
	stair_aim = "staircase_up_8x16";
	transition_stair_count = 1;
	traversedata = animscripts/traverse/stairs_util::build_traverse_data( traversedata, stair_anims, transition_stair_count_in, transition_stair_count_out, stair_aim );
	dotraverse( traversedata );
}
