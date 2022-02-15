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
	level.cougar_steer_anim = %v_la_04_01_drive_leftturn_cougar;
}

player_anims()
{
	level.viewarms = precachemodel( level.player_interactive_model );
	level.viewarms_steer_anim = %ch_la_04_01_drive_leftturn_player;
}

fx()
{
}
