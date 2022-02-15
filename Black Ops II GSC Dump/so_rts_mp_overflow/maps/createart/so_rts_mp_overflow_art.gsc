#include maps/_utility;
#include common_scripts/utility;

intro_igc()
{
	n_near_start = 2;
	n_near_end = 58;
	n_far_start = 2977;
	n_far_end = 4823;
	n_near_blur = 4;
	n_far_blur = 0,4;
	n_time = 15;
	wait 1;
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	level.player depth_of_field_off( 0,05 );
}

success_igc()
{
	n_near_start = 4;
	n_near_end = 64;
	n_far_start = 2977;
	n_far_end = 4823;
	n_near_blur = 4;
	n_far_blur = 2;
	n_time = 20;
	wait 1;
	level.map_default_sun_direction = getDvar( "r_lightTweakSunDirection" );
	setsaveddvar( "r_lightTweakSunDirection", ( -165,8, 143, 0 ) );
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	level.player depth_of_field_off( 0,05 );
}

fail_igc()
{
	n_near_start = 2;
	n_near_end = 9;
	n_far_start = 1000;
	n_far_end = 2828;
	n_near_blur = 4;
	n_far_blur = 0,3;
	n_time = 20;
	level.map_default_sun_direction = getDvar( "r_lightTweakSunDirection" );
	setsaveddvar( "r_lightTweakSunDirection", ( -165,8, 143, 0 ) );
	level.rts.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	level.player depth_of_field_off( 0,05 );
}
