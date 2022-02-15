#include common_scripts/utility;

#using_animtree( "generic_human" );

setup_traversal_anim_array( animtype, array )
{
/#
	if ( isDefined( array ) )
	{
		assert( isarray( array ) );
	}
#/
	array = setup_stairs_anim_array( animtype, array );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "dive_over_40" ] = %ai_dive_over_40;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_across_72" ] = %ai_jump_across_72;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_across_120" ] = %ai_jump_across_120;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_36" ] = %ai_jump_down_36;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_40" ] = %ai_jump_down_40;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_56" ] = %ai_jump_down_56;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_96" ] = %ai_jump_down_96;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_96_pak" ] = %ai_jump_down_96_pak;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_down_128" ] = %ai_jump_down_128;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "jump_over_high_wall" ] = %jump_over_high_wall;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "ladder_climbon" ] = %ladder_climbon;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "ladder_climbdown" ] = %ladder_climbdown;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "ladder_start" ] = %ladder_climbon_bottom_walk;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "ladder_climb" ] = %ladder_climbup;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "ladder_end" ] = %ladder_climboff;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "traverse_40_death_start" ] = array( %traverse40_death_start, %traverse40_death_start_2 );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "traverse_40_death_end" ] = array( %traverse40_death_end, %traverse40_death_end_2 );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "traverse_90_death_start" ] = array( %traverse90_start_death );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "traverse_90_death_end" ] = array( %traverse90_end_death );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_on_36" ] = %ai_mantle_on_36;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_on_40" ] = %ai_mantle_on_40;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_on_48" ] = %ai_mantle_on_48;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_on_52" ] = %ai_mantle_on_52;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_on_56" ] = %ai_mantle_on_56;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_over_36" ] = %ai_mantle_over_36;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_over_40" ] = %ai_mantle_over_40;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_over_40_to_cover" ] = %traverse40_2_cover;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_over_40_down_80" ] = array( %ai_mantle_over_40_down_80, %ai_mantle_over_40_down_80_v2 );
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_over_96" ] = %ai_mantle_over_96;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_window_36_run" ] = %ai_mantle_window_36_run;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_window_36_stop" ] = %ai_mantle_window_36_stop;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "mantle_window_dive_36" ] = %ai_mantle_window_dive_36;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "slide_across_car" ] = %ai_slide_across_car;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "slide_across_car_to_cover" ] = %slide_across_car_2_cover;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "slide_across_car_death" ] = %slide_across_car_death;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "step_up" ] = %step_up_low_wall;
	return array;
}

setup_stairs_anim_array( animtype, array )
{
/#
	if ( isDefined( array ) )
	{
		assert( isarray( array ) );
	}
#/
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_in" ] = %ai_staircase_run_up_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_in_even" ] = %ai_staircase_run_up_8x8_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_out" ] = %ai_staircase_run_up_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_2" ] = %ai_staircase_run_up_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_4" ] = %ai_staircase_run_up_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_6" ] = %ai_staircase_run_up_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_7" ] = %ai_staircase_run_up_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_10" ] = %ai_staircase_run_up_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_aim_up" ] = %ai_staircase_run_up_8x8_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_aim_down" ] = %ai_staircase_run_up_8x8_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_aim_left" ] = %ai_staircase_run_up_8x8_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x8_aim_right" ] = %ai_staircase_run_up_8x8_aim_6;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_in" ] = %ai_staircase_run_down_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_out" ] = %ai_staircase_run_down_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_out_even" ] = %ai_staircase_run_down_8x8_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_2" ] = %ai_staircase_run_down_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_4" ] = %ai_staircase_run_down_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_6" ] = %ai_staircase_run_down_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_8" ] = %ai_staircase_run_down_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_10" ] = %ai_staircase_run_down_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_aim_up" ] = %ai_staircase_run_down_8x8_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_aim_down" ] = %ai_staircase_run_down_8x8_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_aim_left" ] = %ai_staircase_run_down_8x8_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x8_aim_right" ] = %ai_staircase_run_down_8x8_aim_6;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_in" ] = %ai_staircase_run_up_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_in_even" ] = %ai_staircase_run_up_8x12_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_out" ] = %ai_staircase_run_up_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_2" ] = %ai_staircase_run_up_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_4" ] = %ai_staircase_run_up_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_6" ] = %ai_staircase_run_up_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_8" ] = %ai_staircase_run_up_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_10" ] = %ai_staircase_run_up_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_aim_up" ] = %ai_staircase_run_up_8x12_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_aim_down" ] = %ai_staircase_run_up_8x12_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_aim_left" ] = %ai_staircase_run_up_8x12_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x12_aim_right" ] = %ai_staircase_run_up_8x12_aim_6;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_in" ] = %ai_staircase_run_down_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_out" ] = %ai_staircase_run_down_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_out_even" ] = %ai_staircase_run_down_8x12_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_2" ] = %ai_staircase_run_down_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_4" ] = %ai_staircase_run_down_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_6" ] = %ai_staircase_run_down_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_8" ] = %ai_staircase_run_down_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_10" ] = %ai_staircase_run_down_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_aim_up" ] = %ai_staircase_run_down_8x12_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_aim_down" ] = %ai_staircase_run_down_8x12_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_aim_left" ] = %ai_staircase_run_down_8x12_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x12_aim_right" ] = %ai_staircase_run_down_8x12_aim_6;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_in" ] = %ai_staircase_run_up_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_in_even" ] = %ai_staircase_run_up_8x16_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_out" ] = %ai_staircase_run_up_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_2" ] = %ai_staircase_run_up_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_4" ] = %ai_staircase_run_up_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_6" ] = %ai_staircase_run_up_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_8" ] = %ai_staircase_run_up_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_10" ] = %ai_staircase_run_up_8x16_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_aim_up" ] = %ai_staircase_run_up_8x16_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_aim_down" ] = %ai_staircase_run_up_8x16_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_aim_left" ] = %ai_staircase_run_up_8x16_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_up_8x16_aim_right" ] = %ai_staircase_run_up_8x16_aim_6;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_in" ] = %ai_staircase_run_down_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_out" ] = %ai_staircase_run_down_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_out_even" ] = %ai_staircase_run_down_8x16_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_2" ] = %ai_staircase_run_down_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_4" ] = %ai_staircase_run_down_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_6" ] = %ai_staircase_run_down_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_8" ] = %ai_staircase_run_down_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_10" ] = %ai_staircase_run_down_8x16_5;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_aim_up" ] = %ai_staircase_run_down_8x16_aim_8;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_aim_down" ] = %ai_staircase_run_down_8x16_aim_2;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_aim_left" ] = %ai_staircase_run_down_8x16_aim_4;
	array[ animtype ][ "move" ][ "stand" ][ "rifle" ][ "staircase_down_8x16_aim_right" ] = %ai_staircase_run_down_8x16_aim_6;
	if ( is_true( level.supportspistolanimations ) )
	{
		array = setup_pistol_stairs_anim_array( animtype, array );
	}
	array = setup_civilian_stairs_anim_array( animtype, array );
	return array;
}

setup_pistol_stairs_anim_array( animtype, array )
{
/#
	if ( isDefined( array ) )
	{
		assert( isarray( array ) );
	}
#/
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_in" ] = %ai_pistol_staircase_run_up_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_in_even" ] = %ai_pistol_staircase_run_up_8x8_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_out" ] = %ai_pistol_staircase_run_up_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_2" ] = %ai_pistol_staircase_run_up_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_4" ] = %ai_pistol_staircase_run_up_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_6" ] = %ai_pistol_staircase_run_up_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_7" ] = %ai_pistol_staircase_run_up_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x8_10" ] = %ai_pistol_staircase_run_up_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_in" ] = %ai_pistol_staircase_run_down_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_out" ] = %ai_pistol_staircase_run_down_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_out_even" ] = %ai_pistol_staircase_run_down_8x8_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_2" ] = %ai_pistol_staircase_run_down_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_4" ] = %ai_pistol_staircase_run_down_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_6" ] = %ai_pistol_staircase_run_down_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_8" ] = %ai_pistol_staircase_run_down_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x8_10" ] = %ai_pistol_staircase_run_down_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_in" ] = %ai_pistol_staircase_run_up_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_in_even" ] = %ai_pistol_staircase_run_up_8x12_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_out" ] = %ai_pistol_staircase_run_up_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_2" ] = %ai_pistol_staircase_run_up_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_4" ] = %ai_pistol_staircase_run_up_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_6" ] = %ai_pistol_staircase_run_up_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_8" ] = %ai_pistol_staircase_run_up_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x12_10" ] = %ai_pistol_staircase_run_up_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_in" ] = %ai_pistol_staircase_run_down_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_out" ] = %ai_pistol_staircase_run_down_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_out_even" ] = %ai_pistol_staircase_run_down_8x12_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_2" ] = %ai_pistol_staircase_run_down_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_4" ] = %ai_pistol_staircase_run_down_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_6" ] = %ai_pistol_staircase_run_down_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_8" ] = %ai_pistol_staircase_run_down_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x12_10" ] = %ai_pistol_staircase_run_down_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_in" ] = %ai_pistol_staircase_run_up_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_in_even" ] = %ai_pistol_staircase_run_up_8x16_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_out" ] = %ai_pistol_staircase_run_up_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_2" ] = %ai_pistol_staircase_run_up_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_4" ] = %ai_pistol_staircase_run_up_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_6" ] = %ai_pistol_staircase_run_up_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_8" ] = %ai_pistol_staircase_run_up_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_up_8x16_10" ] = %ai_pistol_staircase_run_up_8x16_5;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_in" ] = %ai_pistol_staircase_run_down_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_out" ] = %ai_pistol_staircase_run_down_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_out_even" ] = %ai_pistol_staircase_run_down_8x16_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_2" ] = %ai_pistol_staircase_run_down_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_4" ] = %ai_pistol_staircase_run_down_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_6" ] = %ai_pistol_staircase_run_down_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_8" ] = %ai_pistol_staircase_run_down_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "pistol" ][ "staircase_down_8x16_10" ] = %ai_pistol_staircase_run_down_8x16_5;
	return array;
}

setup_civilian_stairs_anim_array( animtype, array )
{
/#
	if ( isDefined( array ) )
	{
		assert( isarray( array ) );
	}
#/
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_in" ] = %ai_pistol_staircase_run_up_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_in_even" ] = %ai_pistol_staircase_run_up_8x8_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_out" ] = %ai_pistol_staircase_run_up_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_2" ] = %ai_pistol_staircase_run_up_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_4" ] = %ai_pistol_staircase_run_up_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_6" ] = %ai_pistol_staircase_run_up_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_7" ] = %ai_pistol_staircase_run_up_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x8_10" ] = %ai_pistol_staircase_run_up_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_in" ] = %ai_pistol_staircase_run_down_8x8_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_out" ] = %ai_pistol_staircase_run_down_8x8_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_out_even" ] = %ai_pistol_staircase_run_down_8x8_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_2" ] = %ai_pistol_staircase_run_down_8x8_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_4" ] = %ai_pistol_staircase_run_down_8x8_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_6" ] = %ai_pistol_staircase_run_down_8x8_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_8" ] = %ai_pistol_staircase_run_down_8x8_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x8_10" ] = %ai_pistol_staircase_run_down_8x8_5;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_in" ] = %ai_pistol_staircase_run_up_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_in_even" ] = %ai_pistol_staircase_run_up_8x12_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_out" ] = %ai_pistol_staircase_run_up_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_2" ] = %ai_pistol_staircase_run_up_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_4" ] = %ai_pistol_staircase_run_up_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_6" ] = %ai_pistol_staircase_run_up_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_8" ] = %ai_pistol_staircase_run_up_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x12_10" ] = %ai_pistol_staircase_run_up_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_in" ] = %ai_pistol_staircase_run_down_8x12_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_out" ] = %ai_pistol_staircase_run_down_8x12_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_out_even" ] = %ai_pistol_staircase_run_down_8x12_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_2" ] = %ai_pistol_staircase_run_down_8x12_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_4" ] = %ai_pistol_staircase_run_down_8x12_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_6" ] = %ai_pistol_staircase_run_down_8x12_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_8" ] = %ai_pistol_staircase_run_down_8x12_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x12_10" ] = %ai_pistol_staircase_run_down_8x12_5;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_in" ] = %ai_pistol_staircase_run_up_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_in_even" ] = %ai_pistol_staircase_run_up_8x16_in_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_out" ] = %ai_pistol_staircase_run_up_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_2" ] = %ai_pistol_staircase_run_up_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_4" ] = %ai_pistol_staircase_run_up_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_6" ] = %ai_pistol_staircase_run_up_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_8" ] = %ai_pistol_staircase_run_up_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_up_8x16_10" ] = %ai_pistol_staircase_run_up_8x16_5;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_in" ] = %ai_pistol_staircase_run_down_8x16_in;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_out" ] = %ai_pistol_staircase_run_down_8x16_out;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_out_even" ] = %ai_pistol_staircase_run_down_8x16_out_even;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_2" ] = %ai_pistol_staircase_run_down_8x16_1;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_4" ] = %ai_pistol_staircase_run_down_8x16_2;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_6" ] = %ai_pistol_staircase_run_down_8x16_3;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_8" ] = %ai_pistol_staircase_run_down_8x16_4;
	array[ animtype ][ "move" ][ "stand" ][ "none" ][ "staircase_down_8x16_10" ] = %ai_pistol_staircase_run_down_8x16_5;
	return array;
}
