#include maps/_utility;
#include common_scripts/utility;

intro_igc()
{
	n_near_start = 2;
	n_near_end = 149;
	n_far_start = 489;
	n_far_end = 8902;
	n_near_blur = 4;
	n_far_blur = 0,3;
	n_time = 20;
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	level.player depth_of_field_off( 0,05 );
}

success_igc()
{
}

fail_igc()
{
}
