#include maps/_turret;
#include maps/_fxanim;
#include maps/_anim;
#include maps/nicaragua_util;
#include maps/_objectives;
#include maps/_scene;
#include maps/_dialog;
#include maps/_utility;
#include common_scripts/utility;

skipto_mason_donkeykong()
{
	level.hudson = init_hero( "hudson" );
	level.woods = init_hero( "woods" );
	skipto_teleport( "player_skipto_mason_donkeykong", get_heroes() );
	set_objective( level.obj_mason_up_hill );
	a_nd_nodes = getnodearray( "mason_truck_exposed_nodes", "script_noteworthy" );
	_a30 = a_nd_nodes;
	_k30 = getFirstArrayKey( _a30 );
	while ( isDefined( _k30 ) )
	{
		node = _a30[ _k30 ];
		setenablenode( node, 0 );
		_k30 = getNextArrayKey( _a30, _k30 );
	}
	exploder( 10 );
	setsaveddvar( "cg_aggressiveCullRadius", "500" );
	level thread run_scene( "mason_truck_pdf_corpse" );
	model_restore_area( "mason_hill_1" );
	model_restore_area( "mason_hill_2" );
	model_restore_area( "mason_mission" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_watertower_river" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_hut_river" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_porch_explode" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_hut_explode" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_hut_explode_watertower" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_trough_break_1" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_trough_break_2" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_truck_fence" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_archway" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_fountain" );
	battlechatter_on( "axis" );
}

init_flags()
{
	flag_init( "nicaragua_mason_donkeykong_complete" );
	flag_init( "nicaragua_donkeykong_house_open" );
	flag_init( "donkeykong_truck_gunner_killed" );
	flag_init( "donkeykong_truck_stopped" );
}

main()
{
	init_flags();
	level thread nicaragua_mason_donkeykong_objectives();
	level thread donkeykong_autosaves();
	donkeykong_setup();
	level thread donkeykong_vo();
	begin_donkeykong();
	level thread donkeykong_truck();
	level thread donkeykong_stair_runner();
	level thread donkeykong_kill_off_balcony_cartel();
	flag_wait( "nicaragua_mason_donkeykong_complete" );
	level notify( "nicaragua_mason_donkeykong_complete" );
	donkeykong_cleanup();
}

nicaragua_mason_donkeykong_objectives()
{
	flag_wait( "mason_truck_breadcrumbs_complete" );
	set_objective( level.obj_mason_up_hill, getstruct( "donkeykong_objective_1" ), "" );
	flag_wait_any( "donkeykong_truck_stopped", "donkeykong_top_of_hill" );
	set_objective( level.obj_mason_up_hill, getstruct( "donkeykong_objective_2" ), "" );
	trigger_wait( "player_near_donkeykong_house" );
	set_objective( level.obj_mason_up_hill, getstruct( "donkeykong_objective_3" ), "" );
	trigger_wait( "donkeykong_house_upstairs_trigger" );
	set_objective( level.obj_mason_up_hill, getstruct( "donkeykong_objective_3" ), "remove" );
}

donkeykong_autosaves()
{
	trigger_wait( "donkeykong_player_near_hill" );
	autosave_by_name( "mason_donkeykong_start" );
}

donkeykong_setup()
{
	exploder( 101 );
	exploder( 330 );
	a_nd_nodes = getnodearray( "mason_donkeykong_exposed_nodes", "script_noteworthy" );
	_a136 = a_nd_nodes;
	_k136 = getFirstArrayKey( _a136 );
	while ( isDefined( _k136 ) )
	{
		node = _a136[ _k136 ];
		setenablenode( node, 0 );
		_k136 = getNextArrayKey( _a136, _k136 );
	}
	level thread run_scene( "woods_freakout_doors" );
}

begin_donkeykong()
{
	trigger_wait( "begin_donkeykong" );
	e_wagon_clip = getent( "wagon_clip", "targetname" );
	e_wagon_clip trigger_on();
	level thread donkeykong_colortriggers();
	spawn_manager_enable( "donkeykong_cartel_wave1_cart_sm" );
	waittill_spawn_manager_complete( "donkeykong_cartel_wave1_cart_sm" );
	spawn_manager_enable( "donkeykong_cartel_wave1_sm" );
	waittill_spawn_manager_complete( "donkeykong_cartel_wave1_sm" );
	spawn_manager_enable( "mason_donkeykong_leftside_sm" );
	waittill_spawn_manager_complete( "mason_donkeykong_leftside_sm" );
	level thread wagon_traversal();
	level thread open_donkeykong_balcony_doors();
	spawn_manager_enable( "donkeykong_cartel_sniper_sm" );
	spawn_manager_enable( "donkeykong_cartel_balcony1_sm" );
	level thread donkeykong_spawn_house_enemies();
	a_ai_cart = get_ai_array( "donkeykong_cartel_wave1_cart_ai", "targetname" );
	e_goalvolume = getent( "donkeykong_offpath_goalvolume", "targetname" );
	if ( a_ai_cart.size > 2 )
	{
		waittill_dead_or_dying( a_ai_cart, 2 );
		a_ai_cart = array_removedead( a_ai_cart );
	}
	_a184 = a_ai_cart;
	_k184 = getFirstArrayKey( _a184 );
	while ( isDefined( _k184 ) )
	{
		guy = _a184[ _k184 ];
		if ( isalive( guy ) )
		{
			guy thread sprint_to_retreat( e_goalvolume );
			wait randomfloatrange( 0,5, 1,5 );
		}
		_k184 = getNextArrayKey( _a184, _k184 );
	}
}

wagon_traversal()
{
	trigger_wait( "wagon_traversal_trigger" );
	level thread run_scene( "wagon_traversal" );
}

open_donkeykong_balcony_doors()
{
	e_door_left = getent( "balcony_door_left", "targetname" );
	e_door_right = getent( "balcony_door_right", "targetname" );
	v_new_angles_left = e_door_left.angles + vectorScale( ( 0, 1, 0 ), 90 );
	v_new_angles_right = e_door_right.angles - vectorScale( ( 0, 1, 0 ), 90 );
	e_door_left rotateto( v_new_angles_left, 0,5 );
	e_door_right rotateto( v_new_angles_right, 0,5 );
}

donkeykong_truck()
{
	trigger_wait( "mason_donkeykong_truck_start" );
	wait 0,1;
	vh_truck = getent( "mason_donkeykong_truck", "targetname" );
	vh_truck thread donkeykong_truck_spawn_occupants();
	vh_truck thread donkeykong_truck_shoot();
	vh_truck thread donkeykong_truck_disable_turret_on_gunner_death();
	vh_truck waittill( "brake" );
	flag_set( "donkeykong_truck_stopped" );
	flag_set( "spawn_donkeykong_house_enemies" );
}

donkeykong_truck_spawn_occupants()
{
	str_driver_tag = "tag_driver";
	str_passenger_tag = "tag_passener";
	str_gunner_tag = "tag_gunner1";
	ai_driver = simple_spawn_single( "mason_donkeykong_truck_occupants" );
	wait_network_frame();
	ai_gunner = simple_spawn_single( "mason_donkeykong_truck_occupants" );
	wait_network_frame();
	ai_gunner.deathfunction = ::donkeykong_truck_gunner_death;
	ai_gunner.script_noteworthy = "ai_gunner";
	if ( isalive( ai_gunner ) )
	{
		ai_gunner set_ignoreme( 1 );
	}
	ai_driver enter_vehicle( self, str_driver_tag );
	ai_gunner enter_vehicle( self, str_gunner_tag );
}

donkeykong_truck_gunner_death()
{
	flag_set( "donkeykong_truck_gunner_killed" );
	return 0;
}

donkeykong_truck_disable_turret_on_gunner_death()
{
	flag_wait( "donkeykong_truck_gunner_killed" );
	n_index = 1;
	if ( isDefined( self ) )
	{
		self maps/_turret::stop_turret( n_index, 1 );
		self notify( "gunner_dead" );
		self makevehicleusable();
	}
}

donkeykong_truck_shoot()
{
	self endon( "death" );
	self endon( "gunner_dead" );
	n_turret_index = 1;
	v_offset = self set_mason_truck_burst_parameters( n_turret_index );
	self set_turret_ignore_line_of_sight( 1, n_turret_index );
	self enable_turret( n_turret_index );
	self maps/_turret::shoot_turret_at_target( level.player, -1, v_offset, n_turret_index );
}

mason_donkeykong_player_uses_turret( vh_truck )
{
	level endon( "nicaragua_mason_donkeykong_complete" );
	self waittill( "enter_vehicle", e_vehicle );
	if ( e_vehicle != vh_truck )
	{
		return;
	}
	a_nd_nodes = getnodearray( "mason_donkeykong_exposed_nodes", "script_noteworthy" );
	_a314 = a_nd_nodes;
	_k314 = getFirstArrayKey( _a314 );
	while ( isDefined( _k314 ) )
	{
		node = _a314[ _k314 ];
		setenablenode( node, 1 );
		_k314 = getNextArrayKey( _a314, _k314 );
	}
	spawn_manager_enable( "donkeykong_turret_targets_sm" );
	self waittill( "exit_vehicle" );
	spawn_manager_disable( "donkeykong_turret_targets_sm" );
	a_s_spawner = getentarray( "donkeykong_turret_targets", "targetname" );
	_a327 = a_s_spawner;
	_k327 = getFirstArrayKey( _a327 );
	while ( isDefined( _k327 ) )
	{
		spawner = _a327[ _k327 ];
		if ( isDefined( spawner ) )
		{
			spawner.count = 0;
		}
		_k327 = getNextArrayKey( _a327, _k327 );
	}
}

sprint_to_retreat( e_goalvolume )
{
	self endon( "death" );
	self change_movemode( "sprint" );
	self set_ignoreme( 0 );
	self setgoalvolumeauto( e_goalvolume );
	self waittill( "goal" );
	self reset_movemode();
}

donkeykong_stair_runner()
{
	trigger_wait( "player_near_donkeykong_house" );
	ai_runner = simple_spawn_single( "donkeykong_house_runner" );
	ai_runner thread dude_runs_up_stairs();
}

dude_runs_up_stairs()
{
	self endon( "death" );
	if ( !isalive( self ) )
	{
		return;
	}
	nd_goal = getnode( "donkeykong_top_of_stairs_node", "targetname" );
	self set_ignoreall( 0 );
	self set_ignoreme( 0 );
	self change_movemode( "sprint" );
	self setgoalnode( nd_goal );
	self waittill( "goal" );
	self reset_movemode();
}

donkeykong_kill_off_balcony_cartel()
{
	flag_wait( "donkeykong_top_of_hill" );
	spawn_manager_disable( "donkeykong_cartel_balcony2_sm" );
	a_ai_cartel = get_ai_group_ai( "donkeykong_balcony_cartel" );
	_a389 = a_ai_cartel;
	_k389 = getFirstArrayKey( _a389 );
	while ( isDefined( _k389 ) )
	{
		guy = _a389[ _k389 ];
		guy thread timebomb( 0,25, 5 );
		_k389 = getNextArrayKey( _a389, _k389 );
	}
}

donkeykong_colortriggers()
{
	trigger_wait( "donkeykong_player_near_hill" );
	trigger_use( "donkeykong_initial_colortrigger" );
	trigger_wait( "donkeykong_house_entry" );
	trigger_use( "donkeykong_into_house_colortrigger" );
}

donkeykong_spawn_left_ridge_enemies()
{
	trigger_wait( "spawn_donkeykong_left_ridge_enemies" );
	spawn_manager_enable( "mason_donkeykong_leftside_sm" );
}

donkeykong_spawn_house_enemies()
{
	flag_wait( "spawn_donkeykong_house_enemies" );
	spawn_manager_enable( "donkeykong_building_cartel_sm" );
	waittill_spawn_manager_complete( "donkeykong_building_cartel_sm" );
	level thread check_for_donkeykong_house_cleared();
	donkeykong_open_door();
	make_shotgunners_agressive();
	spawn_manager_enable( "donkeykong_PDF_sm" );
	a_ai_balcony_cartel = get_ai_array( "donkeykong_cartel_balcony1_ai", "targetname" );
	if ( a_ai_balcony_cartel.size < 3 )
	{
		spawn_manager_enable( "donkeykong_cartel_balcony2_sm" );
	}
}

donkeykong_open_door()
{
	m_door_left = getent( "house_front_door_left", "targetname" );
	m_door_right = getent( "house_front_door_right", "targetname" );
	v_new_angles_left = m_door_left.angles + vectorScale( ( 0, 1, 0 ), 90 );
	v_new_angles_right = m_door_right.angles - vectorScale( ( 0, 1, 0 ), 90 );
	m_door_left rotateto( v_new_angles_left, 0,2 );
	m_door_right rotateto( v_new_angles_right, 0,2 );
}

make_shotgunners_agressive()
{
	a_ai_enemies = getaiarray( "axis" );
	_a454 = a_ai_enemies;
	_k454 = getFirstArrayKey( _a454 );
	while ( isDefined( _k454 ) )
	{
		guy = _a454[ _k454 ];
		if ( issubstr( guy.classname, "Shotgun" ) )
		{
			self make_ai_aggressive();
		}
		_k454 = getNextArrayKey( _a454, _k454 );
	}
}

check_for_donkeykong_house_cleared()
{
	a_ai_enemies = get_ai_group_ai( "donkeykong_cartel" );
	waittill_dead( a_ai_enemies );
	autosave_by_name( "mason_donkeykong_complete" );
	flag_set( "nicaragua_mason_donkeykong_complete" );
}

donkeykong_vo()
{
	trigger_wait( "donkeykong_player_near_hill" );
	level.hudson queue_dialog( "huds_through_the_fire_k_0" );
	if ( is_mature() )
	{
		level.woods queue_dialog( "wood_shit_they_re_gonna_0" );
	}
	else
	{
		level.woods queue_dialog( "wood_they_re_gonna_light_0" );
	}
	n_count = get_ai_group_sentient_count( "donkeykong_balcony_cartel" );
	if ( n_count > 0 )
	{
		level.woods queue_dialog( "wood_move_get_off_the_p_0", 2 );
		n_count = get_ai_group_sentient_count( "donkeykong_balcony_cartel" );
		if ( n_count > 0 )
		{
			level.hudson queue_dialog( "huds_taking_fire_from_the_0", 2 );
		}
	}
	trigger_wait( "donkeykong_house_entry" );
	level.hudson queue_dialog( "huds_into_the_building_0" );
}

donkeykong_cleanup()
{
	spawn_manager_disable( "donkeykong_PDF_sm" );
	spawn_manager_disable( "donkeykong_cartel_balcony1_sm" );
	spawn_manager_disable( "donkeykong_cartel_balcony2_sm" );
	spawn_manager_disable( "donkeykong_cartel_sniper_sm" );
	spawn_manager_disable( "donkeykong_building_cartel_sm" );
	spawn_manager_disable( "donkeykong_cartel_wave1_cart_sm" );
	spawn_manager_disable( "mason_donkeykong_leftside_sm" );
	spawn_manager_disable( "donkeykong_cartel_wave1_sm" );
	a_ai_pdf = get_ai_group_ai( "donkeykong_pdf" );
	_a525 = a_ai_pdf;
	_k525 = getFirstArrayKey( _a525 );
	while ( isDefined( _k525 ) )
	{
		guy = _a525[ _k525 ];
		if ( isalive( guy ) )
		{
			guy thread timebomb( 0,1, 2 );
		}
		_k525 = getNextArrayKey( _a525, _k525 );
	}
	a_ai_cartel = get_ai_group_ai( "donkeykong_cartel_wave1" );
	_a534 = a_ai_pdf;
	_k534 = getFirstArrayKey( _a534 );
	while ( isDefined( _k534 ) )
	{
		guy = _a534[ _k534 ];
		if ( isalive( guy ) )
		{
			guy thread timebomb( 0,1, 2 );
		}
		_k534 = getNextArrayKey( _a534, _k534 );
	}
	a_ai_cartel = get_ai_group_ai( "donkeykong_cartel_wave1_left" );
	_a543 = a_ai_pdf;
	_k543 = getFirstArrayKey( _a543 );
	while ( isDefined( _k543 ) )
	{
		guy = _a543[ _k543 ];
		if ( isalive( guy ) )
		{
			guy thread timebomb( 0,1, 2 );
		}
		_k543 = getNextArrayKey( _a543, _k543 );
	}
	a_ai_cartel = get_ai_group_ai( "donkeykong_balcony_cartel" );
	_a552 = a_ai_pdf;
	_k552 = getFirstArrayKey( _a552 );
	while ( isDefined( _k552 ) )
	{
		guy = _a552[ _k552 ];
		if ( isalive( guy ) )
		{
			guy thread timebomb( 0,1, 2 );
		}
		_k552 = getNextArrayKey( _a552, _k552 );
	}
	a_ai_cartel = get_ai_group_ai( "donkeykong_cartel" );
	_a561 = a_ai_pdf;
	_k561 = getFirstArrayKey( _a561 );
	while ( isDefined( _k561 ) )
	{
		guy = _a561[ _k561 ];
		if ( isalive( guy ) )
		{
			guy thread timebomb( 0,1, 2 );
		}
		_k561 = getNextArrayKey( _a561, _k561 );
	}
	kill_spawnernum( 13 );
	delete_scene_all( "wagon_traversal", 1 );
}
