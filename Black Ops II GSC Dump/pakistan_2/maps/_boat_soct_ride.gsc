#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "player" );
#using_animtree( "vehicles" );

init()
{
	vehicle_anims();
	player_anims();
	fx();
}

vehicle_anims()
{
	level.soct_wheels_up = %v_soct_wheels_up;
	level.soct_wheels_down = %v_soct_wheels_down;
}

player_anims()
{
	level.viewarms = precachemodel( "c_usa_cia_masonjr_viewbody" );
	level.viewarms_steer_anim = %int_boat_steering;
	level.viewarms_steer_boost = %int_boat_boost_press;
}

fx()
{
}
