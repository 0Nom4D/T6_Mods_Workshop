#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

main( n_fog_blend_time )
{
	level.tweakfile = 1;
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 8 );
	b_blend_exposure = 0;
	if ( isDefined( n_fog_blend_time ) )
	{
		time = n_fog_blend_time;
		b_blend_exposure = 1;
	}
	n_exposure = 3,32;
	if ( b_blend_exposure )
	{
		level thread blend_exposure_over_time( n_exposure, n_fog_blend_time );
	}
	else
	{
		setdvar( "r_exposureTweak", 1 );
		setdvar( "r_exposureValue", n_exposure );
	}
	setsaveddvar( "sm_sunSampleSizeNear", 0,25 );
}

art_jet_mode_settings( n_transition_time )
{
	if ( isDefined( n_transition_time ) )
	{
		time = n_transition_time;
	}
	setsaveddvar( "sm_sunSampleSizeNear", 0,25 );
	m_god_rays = getentarray( "godrays", "targetname" );
	_a60 = m_god_rays;
	_k60 = getFirstArrayKey( _a60 );
	while ( isDefined( _k60 ) )
	{
		m_godray = _a60[ _k60 ];
		m_godray.is_hidden = 1;
		m_godray hide();
		_k60 = getNextArrayKey( _a60, _k60 );
	}
}

art_vtol_mode_settings( n_transition_time )
{
	if ( isDefined( n_transition_time ) )
	{
		time = n_transition_time;
	}
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
	m_god_rays = getentarray( "godrays", "targetname" );
	_a84 = m_god_rays;
	_k84 = getFirstArrayKey( _a84 );
	while ( isDefined( _k84 ) )
	{
		m_godray = _a84[ _k84 ];
		if ( isDefined( m_godray.is_hidden ) && m_godray.is_hidden )
		{
			m_godray.is_hidden = 0;
			m_godray show();
		}
		_k84 = getNextArrayKey( _a84, _k84 );
	}
}

blend_exposure_over_time( n_exposure_final, n_time )
{
	n_frames = int( n_time * 20 );
	n_exposure_current = getDvarFloat( "r_exposureValue" );
	n_exposure_change_total = n_exposure_final - n_exposure_current;
	n_exposure_change_per_frame = n_exposure_change_total / n_frames;
	setdvar( "r_exposureTweak", 1 );
	i = 0;
	while ( i < n_frames )
	{
		setdvar( "r_exposureValue", n_exposure_current + ( n_exposure_change_per_frame * i ) );
		wait 0,05;
		i++;
	}
	setdvar( "r_exposureValue", n_exposure_final );
}

fog_intro()
{
	level.player setclientdvars( "r_exposureTweak", 1, "r_exposureValue", 4,15 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
	level.player visionsetnaked( "sp_la_2_start", 0 );
}

enter_jet_players_hand( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 1;
	n_far_end = 400;
	n_near_blur = 6;
	n_far_blur = 3;
	n_time = 0,2;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

enter_jet_cockpit( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 1;
	n_far_end = 400;
	n_near_blur = 6;
	n_far_blur = 3;
	n_time = 0,2;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

enter_jet_hud( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 1;
	n_far_end = 1500;
	n_near_blur = 6;
	n_far_blur = 2;
	n_time = 0,2;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
	wait 4;
	level.player thread depth_of_field_off( 0,5 );
}

eject()
{
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 8 );
}

outro()
{
	setdvar( "r_rimIntensity", 5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
	level.map_default_sun_direction = getDvar( "r_lightTweakSunDirection" );
	setsaveddvar( "r_lightTweakSunDirection", ( -20, 50, 0 ) );
	level.player visionsetnaked( "sp_la_2_end", 1 );
	setdvar( "r_rimIntensity_debug", 0 );
}

outro_samuels()
{
	setdvar( "r_rimIntensity", 5 );
	setsaveddvar( "sm_sunSampleSizeNear", 0,5 );
	level.map_default_sun_direction = getDvar( "r_lightTweakSunDirection" );
	setsaveddvar( "r_lightTweakSunDirection", ( -45, 53, 0 ) );
	level.player visionsetnaked( "sp_la_2_end", 1 );
	setdvar( "r_rimIntensity_debug", 0 );
}

crash_eject( m_player_body )
{
	n_near_start = 0;
	n_near_end = 60;
	n_far_start = 5000;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

crash_chute( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 1000;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

crash_city( m_player_body )
{
	n_near_start = 0;
	n_near_end = 60;
	n_far_start = 5000;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

crash_hit_building( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 300;
	n_far_end = 3000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,2;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

crash_land( m_player_body )
{
	n_near_start = 0;
	n_near_end = 1;
	n_far_start = 100;
	n_far_end = 800;
	n_near_blur = 6;
	n_far_blur = 1;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

outro_convoy( m_player_body )
{
	n_near_start = 0;
	n_near_end = 10;
	n_far_start = 1000;
	n_far_end = 20000;
	n_near_blur = 6;
	n_far_blur = 1;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

outro_harper( m_player_body )
{
	n_near_start = 0;
	n_near_end = 10;
	n_far_start = 1000;
	n_far_end = 7000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

outro_president( m_player_body )
{
	n_near_start = 0;
	n_near_end = 10;
	n_far_start = 1000;
	n_far_end = 7000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}

outro_door( m_player_body )
{
	n_near_start = 0;
	n_near_end = 10;
	n_far_start = 1000;
	n_far_end = 7000;
	n_near_blur = 6;
	n_far_blur = 1,8;
	n_time = 0,5;
	level.player depth_of_field_tween( n_near_start, n_near_end, n_far_start, n_far_end, n_near_blur, n_far_blur, n_time );
}
