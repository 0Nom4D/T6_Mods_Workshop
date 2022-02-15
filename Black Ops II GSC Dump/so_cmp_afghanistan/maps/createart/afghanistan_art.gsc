#include maps/_utility;
#include common_scripts/utility;

main()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 8 );
	level.tweakfile = 1;
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 8 );
	vs_trigs = getentarray( "visionset", "targetname" );
	array_thread( vs_trigs, ::vision_set );
}

canyon()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

open_area()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

rebel_entrance()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 6 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

rebel_camp()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

fire_horse()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

interrogation()
{
	visionsetnaked( "afghanistan_interrogation", 3 );
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	level.player depth_of_field_off( 0,1 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

deserted()
{
	visionsetnaked( "afghanistan_open_area", 1 );
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

dof_time_lapse( m_player_body )
{
	setsunlight( 0,77, 0,63, 0,49 );
	setsaveddvar( "r_lightTweakSunLight", 5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

turn_down_fog()
{
}

dof_lookout( m_player_body )
{
	level.player depth_of_field_tween( 0, 1, 1,2, 20000, 6, 1,8, 0,3 );
}

dof_rappell( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1,8, 0,3 );
}

dof_landed( m_player_body )
{
	level.player depth_of_field_tween( 1, 7,7, 20,6, 1415, 6, 2, 0,5 );
}

dof_run2wall( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1,8, 0,3 );
}

dof_hit_wall( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1, 0,3 );
}

dof_woods( m_player_body )
{
	level.player depth_of_field_tween( 1, 20,59, 20,6, 1122, 6, 1,2, 0,5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

dof_horses( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1,8, 0,3 );
}

dof_jumped( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1,8, 0,3 );
}

dof_woods_up( m_player_body )
{
	level.player depth_of_field_tween( 1, 20,59, 20,6, 1122, 6, 0,3, 0,5 );
}

dof_zhao( m_player_body )
{
	level.player depth_of_field_tween( 1, 20,59, 20,6, 1122, 6, 0,3, 0,5 );
}

dof_woods_end( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 0,3, 0,3 );
	wait 1;
	level.player depth_of_field_off( 0,3 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
}

dof_krav_focus()
{
	level.player thread depth_of_field_tween( 2,75, 26,22, 66, 66,5, 4,05, 3,8, 2,5 );
}

dof_krav_unfocus()
{
	level.player thread depth_of_field_tween( 1, 20,59, 20,6, 715, 6, 2, 2,5 );
}

dof_omar( m_player_body )
{
	level.player depth_of_field_tween( 1, 20,59, 20,6, 715, 6, 2, 0,1 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

dof_beatdown( m_player_body )
{
	n_near_start = 1;
	n_near_end = 7,7;
	n_far_start = 20,96;
	n_far_end = 335,17;
	n_near_blur = 6;
	n_far_blur = 1,83;
	n_time = 0,2;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
	wait 1;
	n_near_start = 1;
	n_near_end = 1,1;
	n_far_start = 1,2;
	n_far_end = 20000;
	n_near_blur = 0,1;
	n_far_blur = 0,1;
	n_time = 0,3;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	level.player depth_of_field_off( 3 );
}

dof_tank_on( m_player_body )
{
	level.player depth_of_field_tween( 1, 7,7, 20,6, 1415, 6, 2, 0,5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

dof_tank_off( m_player_body )
{
	level.player depth_of_field_tween( 1, 1,1, 1,2, 20000, 6, 1,8, 0,3 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
}

dof_strangle( m_player_body )
{
	level.player depth_of_field_tween( 1, 7,7, 20,6, 2000, 6, 1, 0,5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
	visionsetnaked( "afghanistan_krav_ground", 2 );
	wait 1;
	level.player depth_of_field_off( 3 );
}

dof_number_attack_hold_head()
{
	n_near_start = 1;
	n_near_end = 60;
	n_far_start = 60,1;
	n_far_end = 1310;
	n_near_blur = 4;
	n_far_blur = 0,76;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

dof_03( m_player_body )
{
	level.player depth_of_field_tween( 1, 7,7, 20,6, 1415, 6, 1, 0,5 );
	setsunlight( 0,92, 0,84, 0,75 );
	setsaveddvar( "r_lightTweakSunLight", 0,4 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,35 );
	visionsetnaked( "afghanistan_deserted_sunset", 6 );
}

vision_set()
{
	time = 2;
	if ( isDefined( self.script_float ) )
	{
		time = self.script_float;
	}
	while ( 1 )
	{
		self waittill( "trigger" );
		player = get_players()[ 0 ];
		if ( player getvisionsetnaked() != self.script_noteworthy )
		{
			visionsetnaked( self.script_noteworthy, time );
		}
	}
}
