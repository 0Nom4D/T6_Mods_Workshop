#include maps/afghanistan_arena_manager;
#include maps/afghanistan_base_threats;
#include maps/afghanistan_wave_2;
#include maps/_drones_aipath;
#include maps/_music;
#include maps/_dialog;
#include maps/_horse;
#include maps/_vehicle_aianim;
#include maps/_turret;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

start_bp2()
{
	level thread start_hip_dropoff();
	level thread triggercolor_bp2();
	level thread maps/afghanistan_wave_2::init_spawn_funcs_wave2_bp2();
	level thread fxanim_bridges();
	level thread enemy_blowup_bridge();
	level thread fxanim_statue();
	level thread fxanim_statue_entrance();
	level thread fxanim_statue_end();
	level thread bp2_enemies_logic();
	level thread bp2_defenders_logic();
	flag_set( "wave2_started" );
}

bp2_enemies_logic()
{
	level endon( "stop_sandbox" );
	level thread spawn_bp2_sniper();
	while ( 1 )
	{
		level waittill( "player_moved" );
		if ( level.player_location == "bp2" )
		{
			spawn_manager_enable( "manager_bp2_rpg" );
			spawn_manager_enable( "manager_bp2_soviet" );
			continue;
		}
		else if ( level.player_location == "bp3" )
		{
			a_ai_leftover = get_ai_from_spawn_manager( "manager_bp2_rpg" );
			_a142 = a_ai_leftover;
			_k142 = getFirstArrayKey( _a142 );
			while ( isDefined( _k142 ) )
			{
				e_ai = _a142[ _k142 ];
				e_ai die();
				_k142 = getNextArrayKey( _a142, _k142 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_bp2_soviet" );
			_a148 = a_ai_leftover;
			_k148 = getFirstArrayKey( _a148 );
			while ( isDefined( _k148 ) )
			{
				e_ai = _a148[ _k148 ];
				e_ai die();
				_k148 = getNextArrayKey( _a148, _k148 );
			}
		}
		else spawn_manager_disable( "manager_bp2_rpg" );
		spawn_manager_disable( "manager_bp2_soviet" );
	}
}

bp2_defenders_logic()
{
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		level waittill( "player_moved" );
		if ( level.player_location == "bp2" )
		{
			spawn_manager_enable( "manager_reinforce_bp2" );
			spawn_manager_enable( "manager_reinforce_bp2_no_horse" );
			continue;
		}
		else if ( level.player_location == "bp3" )
		{
			a_ai_leftover = get_ai_from_spawn_manager( "manager_reinforce_bp2" );
			_a177 = a_ai_leftover;
			_k177 = getFirstArrayKey( _a177 );
			while ( isDefined( _k177 ) )
			{
				e_ai = _a177[ _k177 ];
				e_ai die();
				_k177 = getNextArrayKey( _a177, _k177 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_reinforce_bp2_no_horse" );
			_a183 = a_ai_leftover;
			_k183 = getFirstArrayKey( _a183 );
			while ( isDefined( _k183 ) )
			{
				e_ai = _a183[ _k183 ];
				e_ai die();
				_k183 = getNextArrayKey( _a183, _k183 );
			}
		}
		else spawn_manager_disable( "manager_reinforce_bp2" );
		spawn_manager_disable( "manager_reinforce_bp2_no_horse" );
	}
}

start_bp3()
{
	level.n_bp3_veh_destroyed = 0;
	level.n_bp3_bridges = 0;
	level.n_bp3_soviet_killed = 0;
	level.n_bp3_muj_killed = 0;
	t_bp3_uaz = getent( "spawn_wave2_bp3", "targetname" );
	t_bp3_uaz trigger_on();
	level thread bp3_enemies_logic();
	level thread monitor_muj_group();
	level thread defenders_bp3();
	t_pulwar_victim = getent( "trigger_pulwar_victim", "targetname" );
	t_pulwar_victim trigger_on();
	sp_sniper = getent( "sniper_bp3", "targetname" );
	bp3_sniper = sp_sniper spawn_ai( 1 );
}

bp3_enemies_logic()
{
	init_spawn_funcs_wave2_bp3();
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		level waittill( "player_moved" );
		if ( level.player_location == "bp3" )
		{
			spawn_manager_enable( "manager_bp3wave2_soviet" );
			spawn_manager_enable( "manager_assault_soviet" );
			spawn_manager_enable( "manager_bp3_foot" );
			trigger_use( "triggercolor_bp3_soviet" );
			trigger_use( "triggercolor_bp3_assault" );
			if ( !flag( "bridge3_destroyed" ) )
			{
				spawn_manager_enable( "manager_upper_bridge", 1 );
			}
			if ( !flag( "bridge4_destroyed" ) )
			{
				spawn_manager_enable( "manager_assaultcrew_bp3", 1 );
			}
			continue;
		}
		else if ( level.player_location == "bp2" )
		{
			a_ai_leftover = get_ai_from_spawn_manager( "manager_bp3wave2_soviet" );
			_a284 = a_ai_leftover;
			_k284 = getFirstArrayKey( _a284 );
			while ( isDefined( _k284 ) )
			{
				e_ai = _a284[ _k284 ];
				e_ai die();
				_k284 = getNextArrayKey( _a284, _k284 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_assault_soviet" );
			_a290 = a_ai_leftover;
			_k290 = getFirstArrayKey( _a290 );
			while ( isDefined( _k290 ) )
			{
				e_ai = _a290[ _k290 ];
				e_ai die();
				_k290 = getNextArrayKey( _a290, _k290 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_bp3_foot" );
			_a296 = a_ai_leftover;
			_k296 = getFirstArrayKey( _a296 );
			while ( isDefined( _k296 ) )
			{
				e_ai = _a296[ _k296 ];
				e_ai die();
				_k296 = getNextArrayKey( _a296, _k296 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_upper_bridge" );
			_a302 = a_ai_leftover;
			_k302 = getFirstArrayKey( _a302 );
			while ( isDefined( _k302 ) )
			{
				e_ai = _a302[ _k302 ];
				e_ai die();
				_k302 = getNextArrayKey( _a302, _k302 );
			}
			a_ai_leftover = get_ai_from_spawn_manager( "manager_assaultcrew_bp3" );
			_a308 = a_ai_leftover;
			_k308 = getFirstArrayKey( _a308 );
			while ( isDefined( _k308 ) )
			{
				e_ai = _a308[ _k308 ];
				e_ai die();
				_k308 = getNextArrayKey( _a308, _k308 );
			}
		}
		else spawn_manager_disable( "manager_bp3wave2_soviet" );
		spawn_manager_disable( "manager_assault_soviet" );
		spawn_manager_disable( "manager_bp3_foot" );
		if ( !flag( "bridge3_destroyed" ) )
		{
			spawn_manager_disable( "manager_upper_bridge", 1 );
		}
		if ( !flag( "bridge4_destroyed" ) )
		{
			spawn_manager_disable( "manager_assaultcrew_bp3", 1 );
		}
	}
}

bp3_infantry_event()
{
	flag_init( "bp3_dialog_happening" );
	flag_init( "bp3_event_continue" );
	set_objective( level.obj_protect, undefined, "deactivate" );
	level thread cleanup_hip_dropoff();
	level thread event_setup_wave2_bp3();
	level thread spawn_uaz_bp3();
	level thread bp3_approach_explosions();
	vo_announce_bp3_event();
	spawn_manager_set_global_active_count( 24 );
	s_obj = getstruct( "struct_bp3_cache_objective", "targetname" );
	set_objective( level.obj_bp3_secure_cache, s_obj );
	level thread maps/afghanistan_base_threats::vo_bp3_story();
	watch_for_infantry_event_start();
	level thread maps/afghanistan_arena_manager::cleanup_trucks_on_bp3();
	vo_zhao_tell_you_where_the_event_is();
	level thread maps/afghanistan_arena_manager::cleanup_ambient_hips();
	level thread maps/afghanistan_arena_manager::cleanup_arena_horse();
	spawn_manager_enable( "manager_bp3_cache_enemies" );
	autosave_by_name( "wave2bp3_start" );
	level thread spawn_heli_attack();
	level thread bridge_over_uaz();
	level thread bp3_vehicle_chooser();
	level thread end_bp3_spawn_manager_cleared();
	level thread end_bp3_fail_safe();
	wait 10;
	flag_set( "shoot_rider" );
	level thread bp3wave2_boss_chooser();
	level thread throttle_bp3_spawn_managers();
	wait_network_frame();
	flag_wait( "bp3_event_continue" );
	set_objective( level.obj_bp3_secure_cache, s_obj, "delete" );
	level.player say_dialog( "maso_hudson_the_ammo_ca_0" );
	level.zhao say_dialog( "zhao_you_fight_bravely_a_0", 0,25 );
	level maps/afghanistan_base_threats::vo_after_bp3_story();
	wait_network_frame();
	set_objective( level.obj_protect, undefined, "reactivate" );
	flag_clear( "bp3_infantry_event" );
}

end_bp3_spawn_manager_cleared()
{
	level endon( "bp3_event_continue" );
	waittill_spawn_manager_cleared( "manager_bp3_cache_enemies" );
	flag_set( "bp3_event_continue" );
}

end_bp3_fail_safe()
{
	level endon( "bp3_event_continue" );
	goal_volume = undefined;
	a_goal_volumes = getentarray( "info_volume", "classname" );
	_a432 = a_goal_volumes;
	_k432 = getFirstArrayKey( _a432 );
	while ( isDefined( _k432 ) )
	{
		e_volume = _a432[ _k432 ];
		if ( isDefined( e_volume.script_goalvolume ) && e_volume.script_goalvolume == "bp3_cache_enemy_volume" )
		{
			goal_volume = e_volume;
			break;
		}
		else
		{
			_k432 = getNextArrayKey( _a432, _k432 );
		}
	}
	while ( 1 )
	{
		if ( level.player istouching( goal_volume ) )
		{
			e_axis_in_cache = get_ai_touching_volume( "axis", undefined, goal_volume );
			if ( e_axis_in_cache.size <= 0 )
			{
				break;
			}
		}
		else
		{
			wait 0,1;
		}
	}
	wait 1;
	spawn_manager_kill( "manager_bp3_cache_enemies", 1 );
	flag_set( "bp3_event_continue" );
}

bp3_handle_player_horse()
{
	flag_wait( "bp3_player_horse_dismount" );
	while ( level.player is_on_horseback() )
	{
		screen_message_create( &"AFGHANISTAN_HORSE_DISMOUNT" );
		level.player thread bp3_watch_for_dismount();
		delay_thread( 5, ::screen_message_delete );
		while ( level.player is_on_horseback() )
		{
			wait 1;
		}
	}
	wait 3;
	s_runoff = getstruct( "player_bp3_exit", "targetname" );
	level.mason_horse setvehgoalpos( ( 4708, -4564, 37,4213 ), 1, 2 );
	level.mason_horse waittill_any_or_timeout( 20, "goal", "near_goal" );
	level.mason_horse horse_stop();
}

bp3_watch_for_dismount()
{
	self endon( "message_deleted" );
	while ( self is_on_horseback() )
	{
		wait 0,05;
	}
	screen_message_delete();
}

watch_for_infantry_event_start()
{
	e_trig = getent( "t_in_bp3", "targetname" );
	level thread maps/afghanistan_arena_manager::send_zhao_to_bp( 3 );
	e_trig waittill( "trigger" );
}

vo_announce_bp3_event()
{
	level.woods say_dialog( "huds_russians_have_launch_0" );
	level.woods say_dialog( "huds_do_whatever_is_neces_0", 0,15 );
}

vo_zhao_tell_you_where_the_event_is()
{
	flag_waitopen( "bp3_dialog_happening" );
	flag_set( "bp3_dialog_happening" );
	level.zhao say_dialog( "zhao_the_ammo_cache_is_le_0" );
	level thread bp3_handle_player_horse();
	level.zhao say_dialog( "zhao_the_path_is_impassib_0", 0,15 );
	level.zhao say_dialog( "zhao_dismount_we_will_p_0", 0,1 );
	flag_clear( "bp3_dialog_happening" );
}

throttle_bp3_spawn_managers()
{
	while ( flag( "bp3_infantry_event" ) )
	{
		if ( get_ai_count( "all" ) >= 20 )
		{
			spawn_manager_disable( "manager_bp3wave2_soviet" );
			spawn_manager_disable( "manager_assault_soviet" );
			spawn_manager_disable( "manager_bp3_foot" );
			if ( !flag( "bridge3_destroyed" ) )
			{
				spawn_manager_disable( "manager_upper_bridge", 1 );
			}
			if ( !flag( "bridge4_destroyed" ) )
			{
				spawn_manager_disable( "manager_assaultcrew_bp3", 1 );
			}
		}
		else
		{
			spawn_manager_enable( "manager_bp3wave2_soviet" );
			spawn_manager_enable( "manager_assault_soviet" );
			spawn_manager_enable( "manager_bp3_foot" );
			trigger_use( "triggercolor_bp3_soviet" );
			trigger_use( "triggercolor_bp3_assault" );
			if ( !flag( "bridge3_destroyed" ) )
			{
				spawn_manager_enable( "manager_upper_bridge", 1 );
			}
			if ( !flag( "bridge4_destroyed" ) )
			{
				spawn_manager_enable( "manager_assaultcrew_bp3", 1 );
			}
		}
		wait 0,05;
	}
	spawn_manager_enable( "manager_bp3wave2_soviet" );
	spawn_manager_enable( "manager_assault_soviet" );
	spawn_manager_enable( "manager_bp3_foot" );
	trigger_use( "triggercolor_bp3_soviet" );
	trigger_use( "triggercolor_bp3_assault" );
	if ( !flag( "bridge3_destroyed" ) )
	{
		spawn_manager_enable( "manager_upper_bridge", 1 );
	}
	if ( !flag( "bridge4_destroyed" ) )
	{
		spawn_manager_enable( "manager_assaultcrew_bp3", 1 );
	}
}
