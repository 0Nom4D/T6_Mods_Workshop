#include maps/createart/afghanistan_art;
#include maps/afghanistan_firehorse;
#include maps/_audio;
#include maps/afghanistan_anim;
#include maps/_music;
#include maps/_horse;
#include maps/_dialog;
#include maps/_objectives;
#include maps/_vehicle;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "player" );

init_flags()
{
	flag_init( "first_rebel_base_visit" );
	flag_init( "lockbreaker_opened" );
	flag_init( "map_tutorial_active" );
	flag_init( "tutorial_vo_tank_sniper" );
	flag_init( "tutorial_vo_tank_rpg" );
	flag_init( "tutorial_vo_tank_stinger" );
	flag_init( "tutorial_vo_west_sniper" );
	flag_init( "tutorial_vo_west_rpg" );
	flag_init( "tutorial_vo_west_stinger" );
	flag_init( "tutorial_vo_north_sniper" );
	flag_init( "tutorial_vo_north_rpg" );
	flag_init( "tutorial_vo_north_stinger" );
	flag_init( "tutorial_vo_east_sniper" );
	flag_init( "tutorial_vo_east_rpg" );
	flag_init( "tutorial_vo_east_stinger" );
}

init_spawn_funcs()
{
}

skipto_intro()
{
	skipto_setup();
	level.woods = init_hero( "woods" );
	remove_woods_facemask_util();
	iprintlnbold( "SKIP TO RUNNING" );
	level.zhao = init_hero( "zhao" );
	skipto_teleport( "skipto_rebel_base_intro", level.heroes );
	flag_wait( "afghanistan_gump_intro" );
	exploder( 300 );
}

main()
{
/#
	iprintln( "Intro Rebel Base" );
#/
	level thread cleanup();
	set_up_map_room();
	maps/afghanistan_anim::init_afghan_anims_part1b();
	run_map_room_anims();
	flag_set( "first_rebel_base_visit" );
}

set_up_map_room()
{
	autosave_by_name( "e3_base_start" );
	level thread spawn_map_room_personnel();
	level.rebel_leader = init_hero( "rebel_leader" );
	level.rebel_leader.animname = "rebel_leader";
	level.hudson = init_hero( "hudson" );
	level.hudson.animname = "hudson";
	level.zhao thread say_dialog( "zhao_this_way_0" );
	level thread first_frame_player_cave_enter();
	run_scene( "walkto_cave_entrance" );
	level thread run_scene( "cave_entrance_wait" );
	flag_wait( "enter_cave" );
	level notify( "entering_the_cave" );
	end_scene( "cave_entrance_wait" );
	delete_scene( "walkto_cave_entrance", 1 );
	delete_scene( "cave_entrance_wait", 1 );
}

first_frame_player_cave_enter()
{
	level endon( "entering_the_cave" );
	flag_wait( "enter_cave" );
	level.player startcameratween( 1 );
	run_scene_first_frame( "cave_enter_player_only" );
}

run_map_room_anims()
{
	t_map_table = getent( "trigger_map_room_table", "targetname" );
	set_objective( level.obj_afghan_bc3, undefined, "done" );
	level notify( "reset_walk_speed" );
	level.player startcameratween( 0,5 );
	run_scene( "cave_enter" );
	level thread run_scene( "map_room" );
	ak47 = get_model_or_models_from_scene( "map_room", "woods_ak47" );
	ak47 hide();
	flag_wait( "map_room_started" );
	level thread trigger_attack_before_animation_end();
	wait 0,35;
	delete_intro_scenes();
	rebel_base_clean_up();
	load_gump( "afghanistan_gump_arena" );
	scene_wait( "map_room" );
	level thread maps/_audio::switch_music_wait( "AFGHAN_BATTLE_START", 4 );
	clientnotify( "abs_1" );
	delete_scene( "cave_enter", 1 );
	delete_scene( "map_room", 1 );
}

trigger_attack_before_animation_end()
{
	num_length = getanimlength( %p_af_02_01_map_room_conversation_player );
	wait ( num_length - 2 );
	level thread maps/afghanistan_firehorse::explosion_base();
}

delete_intro_scenes()
{
	level thread cleanup_intro();
	end_scene( "e2_cooking_muj" );
	end_scene( "e2_drum_burner" );
	end_scene( "e2_gunsmith" );
	end_scene( "e2_smokers" );
	end_scene( "e2_generator" );
	end_scene( "e2_tower_lookout_endidl" );
	end_scene( "e2_stinger_endidl" );
	end_scene( "e2_stacker_endidl" );
	end_scene( "e2_stacker_3" );
	delete_section_2_scenes();
}

spawn_map_room_personnel()
{
	flag_wait( "map_room_started" );
	a_ai_muj = [];
	a_s_positions = [];
	i = 0;
	while ( i < 4 )
	{
		a_s_positions[ i ] = getstruct( "map_room_muj_pos" + i, "targetname" );
		i++;
	}
	i = 0;
	while ( i < a_s_positions.size )
	{
		a_ai_muj[ i ] = get_muj_ai();
		a_ai_muj[ i ] forceteleport( a_s_positions[ i ].origin, a_s_positions[ i ].angles );
		a_ai_muj[ i ].goalradius = 64;
		a_ai_muj[ i ] setgoalpos( a_ai_muj[ i ].origin );
		a_ai_muj[ i ].arena_guy = 1;
		i++;
	}
	flag_wait( "e3_exit_map_room_started" );
	wait 3,5;
	v_wait_pos = getent( "trigger_tower_collapse", "targetname" ).origin;
	i = 0;
	while ( i < a_s_positions.size )
	{
		if ( isalive( a_ai_muj[ i ] ) )
		{
			a_ai_muj[ i ] setgoalpos( v_wait_pos + ( randomintrange( -32, 32 ), randomintrange( -64, 64 ), 0 ) );
			wait randomfloatrange( 0,5, 1 );
		}
		i++;
	}
	trigger_wait( "trigger_maproom_exit" );
	v_goal_pos = getstruct( "base_weapons_cache", "targetname" ).origin;
	i = 0;
	while ( i < a_s_positions.size )
	{
		if ( isalive( a_ai_muj[ i ] ) )
		{
			a_ai_muj[ i ] setgoalpos( v_goal_pos + ( randomintrange( -32, 32 ), randomintrange( -64, 64 ), 0 ) );
			wait 0,1;
		}
		i++;
	}
	wait 3,5;
	i = 0;
	while ( i < a_s_positions.size )
	{
		if ( isalive( a_ai_muj[ i ] ) )
		{
			magicbullet( "btr60_heavy_machinegun", a_ai_muj[ i ].origin + vectorScale( ( -1, 0, 1 ), 200 ), a_ai_muj[ i ].origin + vectorScale( ( -1, 0, 1 ), 40 ) );
			wait 0,05;
		}
		i++;
	}
	i = 0;
	while ( i < 4 )
	{
		a_s_positions[ i ] structdelete();
		i++;
	}
	goal_pos = getstruct( "base_weapons_cache", "targetname" );
	goal_pos structdelete();
	goal_pos = undefined;
}

start_loop_for_maps_room()
{
	level thread run_scene( "e2_s1_map_loop" );
}

cleanup()
{
	while ( isDefined( level.muj_horses ) )
	{
		i = 0;
		while ( i < level.muj_horses.size )
		{
			level.muj_horses[ i ].delete_on_death = 1;
			level.muj_horses[ i ] notify( "death" );
			if ( !isalive( level.muj_horses[ i ] ) )
			{
				level.muj_horses[ i ] delete();
			}
			i++;
		}
	}
}

rebel_base_clean_up()
{
	ent_useless = getentarray( "e2_muj_clean_up", "script_noteworthy" );
	i = 0;
	while ( i < ent_useless.size )
	{
		ent_useless[ i ] delete();
		i++;
	}
	if ( isDefined( level.zhao.vh_my_horse ) )
	{
		level.zhao.vh_my_horse.delete_on_death = 1;
		level.zhao.vh_my_horse notify( "death" );
		if ( !isalive( level.zhao.vh_my_horse ) )
		{
			level.zhao.vh_my_horse delete();
		}
	}
	if ( isDefined( level.woods.vh_my_horse ) )
	{
		level.woods.vh_my_horse.delete_on_death = 1;
		level.woods.vh_my_horse notify( "death" );
		if ( !isalive( level.woods.vh_my_horse ) )
		{
			level.woods.vh_my_horse delete();
		}
	}
	if ( isDefined( level.mason_horse ) && !level.press_demo )
	{
		level.mason_horse.delete_on_death = 1;
		level.mason_horse notify( "death" );
		if ( !isalive( level.mason_horse ) )
		{
			level.mason_horse delete();
		}
	}
	if ( isDefined( level.muj_tank ) )
	{
		level.muj_tank.delete_on_death = 1;
		level.muj_tank notify( "death" );
		if ( !isalive( level.muj_tank ) )
		{
			level.muj_tank delete();
		}
	}
	allow_horse_sprint( 1 );
	override_player_horse_speed( undefined );
	level maps/createart/afghanistan_art::turn_down_fog();
}

cleanup_intro()
{
	delete_ride_vignette_array = getentarray( "e1_ride_vig_cleanup", "script_noteworthy" );
	_a326 = delete_ride_vignette_array;
	_k326 = getFirstArrayKey( _a326 );
	while ( isDefined( _k326 ) )
	{
		cleanup_ent = _a326[ _k326 ];
		cleanup_ent delete();
		_k326 = getNextArrayKey( _a326, _k326 );
	}
	intro_fail_triggers = getentarray( "e1_intro_ride_fail_trigger", "script_noteworthy" );
	_a335 = intro_fail_triggers;
	_k335 = getFirstArrayKey( _a335 );
	while ( isDefined( _k335 ) )
	{
		fail_trigger = _a335[ _k335 ];
		fail_trigger delete();
		_k335 = getNextArrayKey( _a335, _k335 );
	}
}
