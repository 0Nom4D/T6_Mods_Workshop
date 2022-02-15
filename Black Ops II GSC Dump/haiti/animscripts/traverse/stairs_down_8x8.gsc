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
			assertmsg( "Traversal: 'stairs_down' doesn't support entity type '" + self.type + "'." );
#/
	}
}

human()
{
	movement = preparefortraverse();
	traversedata = [];
	transition_stair_count_in = 1;
	traversedata[ "traverseAnimTransIn" ] = animarray( "staircase_down_8x8_in", movement );
	if ( self animscripts/traverse/stairs_util::get_stair_count() % 2 )
	{
		transition_stair_count_out = 0;
		traversedata[ "traverseAnimTransOut" ] = animarray( "staircase_down_8x8_out", movement );
	}
	else
	{
		transition_stair_count_out = 1;
		traversedata[ "traverseAnimTransOut" ] = animarray( "staircase_down_8x8_out_even", movement );
	}
	stair_anims[ 2 ] = animarray( "staircase_down_8x8_2", movement, 0 );
	stair_anims[ 4 ] = animarray( "staircase_down_8x8_4", movement, 0 );
	stair_anims[ 6 ] = animarray( "staircase_down_8x8_6", movement, 0 );
	stair_anims[ 8 ] = animarray( "staircase_down_8x8_8", movement, 0 );
	stair_anims[ 10 ] = animarray( "staircase_down_8x8_10", movement, 0 );
	stair_aim = "staircase_down_8x8";
	traversedata = animscripts/traverse/stairs_util::build_traverse_data( traversedata, stair_anims, transition_stair_count_in, transition_stair_count_out, stair_aim );
	dotraverse( traversedata );
}
