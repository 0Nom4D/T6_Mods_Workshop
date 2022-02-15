#include maps/_utility;
#include common_scripts/utility;

intro_igc()
{
	n_near_start = 0;
	n_near_end = 5;
	n_far_start = 270;
	n_far_end = 900;
	n_near_blur = 6;
	n_far_blur = 2;
	n_time = 0,2;
	level.rts.player visionsetnaked( "sp_singapore_intro", 0 );
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

success_igc()
{
	n_near_start = 0;
	n_near_end = 1000;
	n_far_start = 8200;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,2;
	level.rts.player visionsetnaked( "sp_singapore_end", 0 );
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

fail_igc()
{
	n_near_start = 0;
	n_near_end = 1000;
	n_far_start = 8200;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,2;
	level.rts.player visionsetnaked( "sp_singapore_end", 0 );
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}
