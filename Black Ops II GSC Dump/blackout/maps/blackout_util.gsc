#include maps/_rusher;
#include maps/_dialog;
#include maps/_jetpack_ai;
#include animscripts/shared;
#include maps/_friendlyfire;
#include maps/_cic_turret;
#include maps/_glasses;
#include maps/_dynamic_nodes;
#include maps/blackout_hangar;
#include maps/_dds;
#include maps/blackout_security;
#include maps/blackout_bridge;
#include maps/blackout_interrogation;
#include maps/blackout_amb;
#include maps/_fxanim;
#include maps/createart/blackout_art;
#include maps/_anim;
#include maps/_drones;
#include maps/_loadout;
#include maps/_skipto;
#include maps/_scene;
#include maps/_objectives;
#include common_scripts/utility;
#include animscripts/utility;

#using_animtree( "generic_human" );
#using_animtree( "animated_props" );
#using_animtree( "player" );

load_gumps_blackout()
{
	if ( issubstr( level.skipto_point, "dev" ) )
	{
		load_gump( "blackout_gump_messiah" );
	}
	else if ( is_after_skipto( "mason_salazar_caught" ) )
	{
		load_gump( "blackout_gump_deck" );
	}
	else if ( is_after_skipto( "mason_vent" ) )
	{
		load_gump( "blackout_gump_mason_after" );
	}
	else if ( is_after_skipto( "mason_cctv" ) )
	{
		load_gump( "blackout_gump_messiah" );
	}
	else if ( is_after_skipto( "mason_interrogation_room" ) )
	{
		load_gump( "blackout_gump_mason_before" );
	}
	else
	{
		load_gump( "blackout_gump_intro" );
	}
}

skipto_setup()
{
	load_gumps_blackout();
	skipto = level.skipto_point;
	setsaveddvar( "r_skyTransition", 1 );
	set_aggressive_cull_radius( 100 );
	trigger_off( "computer_server_use", "targetname" );
	set_player_mason( 1 );
	exploder( 1000 );
	exploder( 125 );
	elevator_models_link();
	mason_elevator_move_down();
	sensitive_room_pipes_hide();
	elevator_models_hide();
	deck_vtols_hide();
	drone_cover_hide();
	add_spawn_function_group( "actor_Enemy_Manticore_Blackout_Launcher_Base", "classname", ::remove_launchers_on_easy_difficulty );
	add_spawn_function_veh_by_type( "turret_cic", ::turret_lighting_origin_set );
	maps/_fxanim::fxanim_deconstruct( "fxanim_f38_launch_fail" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_f38_failed_landing_gear" );
	if ( skipto == "mason_start" )
	{
		return;
	}
	if ( skipto == "mason_interrogation_room" )
	{
		return;
	}
	vision_set_interrogation();
	level thread maps/blackout_amb::force_start_alarm_sounds();
	level thread emergency_light_init();
	if ( skipto == "mason_wakeup" )
	{
		return;
	}
	maps/blackout_interrogation::clean_up_mason_start();
	maps/blackout_interrogation::clean_up_mason_interrogation_room();
	maps/blackout_interrogation::clean_up_mason_wakeup();
	stop_exploder( 1000 );
	if ( level.player hasperk( "specialty_intruder" ) )
	{
		level.player giveweapon( "tazer_knuckles_sp" );
	}
	cleanup_ents( "armory_weapon", "targetname" );
	if ( skipto == "mason_hallway" )
	{
		return;
	}
	maps/blackout_interrogation::clean_up_mason_hallway();
	vision_set_hallway();
	if ( skipto == "mason_salazar_exit" )
	{
		return;
	}
	maps/blackout_bridge::clean_up_mason_salazar_exit();
	deck_vtols_show();
	vision_set_exterior_01();
	sea_cowbell();
	flag_set( "at_bridge_entry" );
	exploder( 1111 );
	maps/_fxanim::fxanim_delete( "intro_hallway_pipes" );
	if ( skipto == "mason_bridge" )
	{
		return;
	}
	maps/blackout_bridge::clean_up_mason_bridge();
	vision_set_bridge();
	flag_set( "at_catwalk" );
	if ( skipto == "mason_catwalk" )
	{
		return;
	}
	end_sea_cowbell();
	if ( skipto == "mason_lower_level" )
	{
		return;
	}
	maps/blackout_bridge::clean_up_mason_catwalk();
	vision_set_lowerlevel();
	flag_set( "at_defend_objective" );
	if ( skipto == "mason_defend" )
	{
		return;
	}
	maps/blackout_security::clean_up_mason_lower_level();
	vision_set_sensitive_room();
	flag_set( "player_at_cctv_room" );
	stop_exploder( 1111 );
	if ( skipto == "mason_cctv" )
	{
		return;
	}
	maps/blackout_security::clean_up_mason_cctv();
	maps/_fxanim::fxanim_delete( "bridge_fxanims" );
	set_player_menendez();
	maps/_dds::dds_disable();
	if ( skipto == "menendez_start" )
	{
		return;
	}
	if ( skipto == "menendez_meat_shield" )
	{
		return;
	}
	if ( skipto != "menendez_betrayal" || issubstr( skipto, "dev_alive" ) && issubstr( skipto, "dev_dead" ) )
	{
		return;
	}
	if ( skipto == "menendez_combat" )
	{
		return;
	}
	flag_set( "start_messiah" );
	flag_set( "distant_explosions_on" );
	if ( skipto == "menendez_hangar" )
	{
		return;
	}
	sea_cowbell();
	elevators_set_no_cull( 1 );
	setsaveddvar( "r_skyTransition", 0 );
	if ( skipto == "menendez_plane" )
	{
		return;
	}
	if ( skipto == "menendez_deck" )
	{
		return;
	}
	set_player_mason();
	flag_clear( "start_messiah" );
	maps/_dds::dds_enable();
	if ( skipto == "mason_vent" )
	{
		return;
	}
	vision_set_vent();
	trigger_on( "computer_server_use", "targetname" );
	maps/_fxanim::fxanim_delete( "sensitive_room_pipes" );
	if ( skipto == "mason_server_room" )
	{
		return;
	}
	vision_set_mason_serverroom();
	if ( skipto == "mason_hangar" )
	{
		return;
	}
	deck_turn_off_cells();
	elevator_models_show();
	elevator_models_link();
	vision_set_hanger();
	exploder( 1111 );
	maps/blackout_hangar::cleanup_server_room();
	if ( skipto == "mason_salazar_caught" )
	{
		return;
	}
	if ( skipto == "mason_elevator" )
	{
		return;
	}
	delete_exploder( 125 );
	flag_set( "reached_top_elevator" );
	flag_set( "start_deck_spawners" );
	vision_set_hanger_elevator();
	stop_exploder( 125 );
	maps/_fxanim::fxanim_delete( "control_room_fxanims" );
	maps/blackout_hangar::cleanup_for_deck();
	if ( skipto == "mason_deck" )
	{
		return;
	}
	vision_set_deck();
	if ( skipto == "mason_deck_final" )
	{
		return;
	}
}

turret_lighting_origin_set()
{
	str_turret_name = self.targetname;
	v_spawn = vectorScale( ( 0, 0, 0 ), 64 ) + bullettrace( self.origin - vectorScale( ( 0, 0, 0 ), 64 ), ( self.origin - vectorScale( ( 0, 0, 0 ), 64 ) ) + vectorScale( ( 0, 0, 0 ), 100000 ), 0, self )[ "position" ];
	e_temp = spawn( "script_model", v_spawn );
	e_temp setmodel( "tag_origin" );
	e_temp.targetname = str_turret_name + "_lighting_origin";
	set_lighting_pair( str_turret_name, e_temp.targetname );
	self waittill( "death" );
	e_temp delete();
}

deck_vtols_hide()
{
	maps/_fxanim::fxanim_deconstruct( "fxanim_deck_vtol_1" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_deck_vtol_2" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_deck_vtol_3" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_deck_vtol_4" );
}

deck_vtols_show()
{
	maps/_fxanim::fxanim_reconstruct( "fxanim_deck_vtol_1" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_deck_vtol_2" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_deck_vtol_3" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_deck_vtol_4" );
}

sensitive_room_pipes_hide()
{
	maps/_fxanim::fxanim_deconstruct( "fxanim_pipes_block" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_pipes_break_01" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_pipes_break_02" );
}

sensitive_room_pipes_show()
{
	maps/_fxanim::fxanim_reconstruct( "fxanim_pipes_block" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_pipes_break_01" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_pipes_break_02" );
}

drone_cover_hide()
{
	maps/_fxanim::fxanim_deconstruct( "fxanim_drone_cover_01" );
	maps/_fxanim::fxanim_deconstruct( "fxanim_drone_cover_02" );
}

drone_cover_show()
{
	maps/_fxanim::fxanim_reconstruct( "fxanim_drone_cover_01" );
	maps/_fxanim::fxanim_reconstruct( "fxanim_drone_cover_02" );
}

elevator_models_hide()
{
	if ( !isDefined( level.elevator_models_hidden ) )
	{
		level.elevator_models_hidden = 0;
	}
	if ( !level.elevator_models_hidden )
	{
		a_elevator_mason = get_ent_array( "mason_elevator_detail", "targetname", 1 );
		a_elevator_vtol = get_ent_array( "vtol_elevator_detail", "targetname", 1 );
		a_models = arraycombine( a_elevator_mason, a_elevator_vtol, 1, 0 );
		level.a_elevator_models = [];
		_a323 = a_models;
		_k323 = getFirstArrayKey( _a323 );
		while ( isDefined( _k323 ) )
		{
			model = _a323[ _k323 ];
			model unlink();
			level.a_elevator_models[ level.a_elevator_models.size ] = model model_to_struct();
			model delete();
			_k323 = getNextArrayKey( _a323, _k323 );
		}
		level.elevator_models_hidden = 1;
	}
}

elevator_models_show()
{
	if ( !isDefined( level.elevator_models_hidden ) )
	{
		level.elevator_models_hidden = 0;
	}
	if ( level.elevator_models_hidden )
	{
/#
		assert( isDefined( level.a_elevator_models ), "elevator models for deck aren't set up!" );
#/
		_a342 = level.a_elevator_models;
		_k342 = getFirstArrayKey( _a342 );
		while ( isDefined( _k342 ) )
		{
			struct = _a342[ _k342 ];
			struct struct_to_model();
			struct structdelete();
			_k342 = getNextArrayKey( _a342, _k342 );
		}
		level.elevator_models_hidden = 0;
	}
}

elevator_models_link()
{
	if ( !isDefined( level.elevator_models_hidden ) )
	{
		level.elevator_models_hidden = 0;
	}
	if ( level.elevator_models_hidden )
	{
		elevator_models_show();
	}
	a_models_mason = get_ent_array( "mason_elevator_detail", "targetname", 1 );
	e_elevator_mason = get_ent( "mason_elevator", "targetname", 1 );
	_a364 = a_models_mason;
	_k364 = getFirstArrayKey( _a364 );
	while ( isDefined( _k364 ) )
	{
		model = _a364[ _k364 ];
		model linkto( e_elevator_mason );
		_k364 = getNextArrayKey( _a364, _k364 );
	}
	a_models_vtol = get_ent_array( "vtol_elevator_detail", "targetname", 1 );
	e_elevator_vtol = get_ent( "vtol_elevator", "targetname", 1 );
	_a372 = a_models_vtol;
	_k372 = getFirstArrayKey( _a372 );
	while ( isDefined( _k372 ) )
	{
		model = _a372[ _k372 ];
		model linkto( e_elevator_vtol );
		_k372 = getNextArrayKey( _a372, _k372 );
	}
}

model_to_struct()
{
	s_temp = spawnstruct();
	self _copy_kvps_to_target( s_temp );
	return s_temp;
}

struct_to_model()
{
	e_temp = spawn( "script_model", self.origin );
	self _copy_kvps_to_target( e_temp );
	return e_temp;
}

_copy_kvps_to_target( target )
{
	target.origin = self.origin;
	if ( isDefined( self.angles ) )
	{
		target.angles = self.angles;
	}
	else
	{
		target.angles = ( 0, 0, 0 );
	}
	if ( isDefined( self.model_name ) )
	{
		target setmodel( self.model_name );
	}
	if ( isDefined( self.model ) && self.classname == "script_model" )
	{
		target.model_name = self.model;
	}
	if ( isDefined( self.targetname ) )
	{
		target.targetname = self.targetname;
	}
	if ( isDefined( self.script_noteworthy ) )
	{
		target.script_noteworthy = self.script_noteworthy;
	}
}

elevator_disconnect_paths()
{
	a_nodes = getnodearray( "elevator_pathnode", "targetname" );
	_a432 = a_nodes;
	_k432 = getFirstArrayKey( _a432 );
	while ( isDefined( _k432 ) )
	{
		node = _a432[ _k432 ];
		node maps/_dynamic_nodes::node_disconnect_from_path();
		_k432 = getNextArrayKey( _a432, _k432 );
	}
}

elevator_connect_paths()
{
	elevator_disconnect_paths();
	a_nodes = getnodearray( "elevator_pathnode", "targetname" );
	_a444 = a_nodes;
	_k444 = getFirstArrayKey( _a444 );
	while ( isDefined( _k444 ) )
	{
		node = _a444[ _k444 ];
		node maps/_dynamic_nodes::node_connect_to_path();
		_k444 = getNextArrayKey( _a444, _k444 );
	}
	m_mason_elevator = get_ent( "mason_elevator", "targetname", 1 );
	m_mason_elevator setmovingplatformenabled( 1 );
	m_mason_elevator connectpaths();
}

mason_elevator_move_down()
{
	m_mason_elevator = get_ent( "mason_elevator", "targetname", 1 );
	if ( !isDefined( m_mason_elevator.at_ground_floor ) )
	{
		m_mason_elevator.at_ground_floor = 0;
	}
	if ( !m_mason_elevator.at_ground_floor )
	{
		m_mason_elevator.at_ground_floor = 1;
		m_mason_elevator setmovingplatformenabled( 1 );
		m_mason_elevator movez( -576, 1 );
		m_mason_elevator waittill( "movedone" );
	}
}

skipto_check_conditional_dvars()
{
	if ( issubstr( level.skipto_point, "dev" ) )
	{
		flag_wait( "dev_skipto_ready" );
	}
	str_karma_alive = getDvar( "karma_alive" );
	if ( str_karma_alive == "1" )
	{
		level.is_karma_alive = 1;
	}
	else
	{
		if ( str_karma_alive == "0" )
		{
			level.is_karma_alive = 0;
		}
	}
	str_defalco_alive = getDvar( "defalco_alive" );
	if ( str_defalco_alive == "1" )
	{
		level.is_defalco_alive = 1;
	}
	else
	{
		if ( str_defalco_alive == "0" )
		{
			level.is_defalco_alive = 0;
		}
	}
	str_farid_alive = getDvar( "farid_alive" );
	if ( str_farid_alive == "1" )
	{
		level.is_farid_alive = 1;
		level.is_harper_alive = 0;
	}
	else
	{
		if ( str_farid_alive == "0" )
		{
			level.is_farid_alive = 0;
			level.is_harper_alive = 1;
		}
	}
	str_briggs_alive = getDvar( #"87148D93" );
	if ( str_briggs_alive == "1" )
	{
		level.is_briggs_alive = 1;
	}
	else
	{
		if ( str_briggs_alive == "0" )
		{
			level.is_briggs_alive = 0;
		}
	}
}

delete_gumped_deadpose_characters( b_delete_models )
{
	if ( !isDefined( b_delete_models ) )
	{
		b_delete_models = 1;
	}
	a_to_delete = [];
	a_to_delete = arraycombine( a_to_delete, get_ent_array( "farid_ai", "targetname" ), 1, 0 );
	a_to_delete = arraycombine( a_to_delete, get_ent_array( "defalco_ai", "targetname" ), 1, 0 );
	a_to_delete = arraycombine( a_to_delete, get_ent_array( "karma_ai", "targetname" ), 1, 0 );
	if ( b_delete_models )
	{
		a_to_delete = arraycombine( a_to_delete, get_ent_array( "farid", "targetname" ), 1, 0 );
		a_to_delete = arraycombine( a_to_delete, get_ent_array( "defalco", "targetname" ), 1, 0 );
		a_to_delete = arraycombine( a_to_delete, get_ent_array( "karma", "targetname" ), 1, 0 );
	}
	i = 0;
	while ( i < a_to_delete.size )
	{
		if ( !is_spawner( a_to_delete[ i ] ) )
		{
			a_to_delete[ i ] delete();
		}
		i++;
	}
}

elevators_set_no_cull( b_force_no_cull )
{
	if ( !isDefined( b_force_no_cull ) )
	{
		b_force_no_cull = 1;
	}
	m_menendez_elevator = get_ent( "menendez_elevator", "targetname", 1 );
	m_mason_elevator = get_ent( "mason_elevator", "targetname", 1 );
	if ( b_force_no_cull )
	{
		m_menendez_elevator setforcenocull();
		m_mason_elevator setforcenocull();
	}
	else
	{
		m_menendez_elevator removeforcenocull();
		m_mason_elevator removeforcenocull();
	}
}

disable_melee_until_flag( str_flag )
{
	self endon( "death" );
	self.dontmelee = 1;
	flag_wait( str_flag );
	self.dontmelee = 0;
}

clean_up_all_ai()
{
	axis_array = getaiarray( "allies" );
	array_delete( axis_array );
	axis_array = getaiarray( "axis" );
	array_delete( axis_array );
}

skipto_randomize_stats()
{
	level.is_defalco_alive = cointoss();
	level.is_karma_alive = cointoss();
	level.is_farid_alive = cointoss();
}

rand_chance( pct_chance )
{
	roll = randomfloatrange( 0, 1 );
	return roll < pct_chance;
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

run_distant_explosions()
{
	a_str_rumbles = array( "grenade_rumble", "flyby", "artillery_rumble" );
	while ( 1 )
	{
		str_rumble = random( a_str_rumbles );
		flag_wait( "distant_explosions_on" );
		wait randomfloatrange( 3, 7 );
		size = randomfloatrange( 0,2, 0,4 );
		duration = randomfloatrange( 1,5, 3 );
		level thread light_flicker_fx( duration );
		level thread light_flicker( duration );
		level.player playsound( "exp_carrier_impact" );
		playrumbleonposition( str_rumble, level.player.origin + vectorScale( ( 0, 0, 0 ), 256 ) );
		earthquake( size, duration, level.player.origin, 100 );
		wait randomfloatrange( 10, 20 );
	}
}

remove_dead_turret_trigger( trigger )
{
	self waittill_any( "death", self.targetname + "_perk_done" );
	if ( trigger.script_noteworthy == "bridge_turret_box" )
	{
		set_objective( level.obj_hack_perk1, self, "remove", undefined, 0 );
	}
	else
	{
		set_objective( level.obj_hack_perk2, self, "remove", undefined, 0 );
	}
	trigger delete();
}

hackable_turret_enable( str_turret_name )
{
	run_scene_first_frame( str_turret_name + "_box" );
	wait_network_frame();
}

hackable_turret_disable( str_turret_name )
{
	level notify( str_turret_name + "_perk_done" );
	wait_network_frame();
}

set_turret_callback( callback_func )
{
	self.m_turret_callback = callback_func;
}

run_turret_damage()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "turret_entered" );
		while ( flag( "player_using_turret" ) )
		{
			self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
			if ( flag( "player_using_turret" ) )
			{
				if ( isDefined( attacker ) )
				{
					level.player dodamage( 10, attacker.origin );
				}
			}
		}
	}
}

pull_player_off_turret_when_destroyed( turret, original_origin, original_angles )
{
	turret endon( "turret_exited" );
	turret waittill_any( "death" );
	level.player playsound( "veh_cic_turret_plr_death" );
	flag_clear( "player_using_turret" );
	if ( isDefined( turret.m_turret_callback ) )
	{
		turret [[ turret.m_turret_callback ]]( 0 );
	}
	level.player setclientdvar( "cg_objectiveIndicatorPerkFarFadeDist", 1024 );
	level.player.health = level.player.maxhealth;
	level.player setorigin( original_origin );
	level.player setplayerangles( original_angles );
	level.player allowcrouch( 1 );
	level.player stop_magic_bullet_shield();
	maps/_glasses::add_visor_text( "BLACKOUT_VISOR_TURRET_DESTROYED", 3, "orange", "bright", 1 );
}

turret_set_team( team )
{
	self.vteam = team;
}

run_hackable_turret( trig )
{
	self endon( "death" );
	self.hacked = 0;
	level flag_wait( "level.player" );
	trig sethintstring( &"SCRIPT_HINT_INTRUDER" );
	trig setcursorhint( "HINT_NOICON" );
	trig trigger_off();
	level.player waittill_player_has_lock_breaker_perk();
	trig trigger_on();
	if ( trig.script_noteworthy == "bridge_turret_box" )
	{
		set_objective( level.obj_hack_perk1, trig, "interact", undefined, 0 );
	}
	else
	{
		set_objective( level.obj_hack_perk2, trig, "interact", undefined, 0 );
	}
	self thread run_turret_damage();
	while ( 1 )
	{
		trig waittill( "trigger" );
		trig trigger_off();
		if ( trig.script_noteworthy == "bridge_turret_box" )
		{
			set_objective( level.obj_hack_perk1, undefined, "delete" );
		}
		else
		{
			set_objective( level.obj_hack_perk2, undefined, "delete" );
		}
		wait 0,05;
		self notify( "turret_hacked" );
		if ( isDefined( self.m_turret_callback ) )
		{
			self [[ self.m_turret_callback ]]( 1 );
		}
		level.player setclientdvar( "cg_objectiveIndicatorPerkFarFadeDist", 64 );
		player_pos = level.player.origin;
		player_angles = level.player.angles;
		if ( is_false( self.hacked ) )
		{
			level.player thread turret_hack_rumble();
			level thread run_scene_and_delete( self.targetname + "_box_player" );
			level thread run_scene_and_delete( self.targetname + "_box" );
			level thread enemies_ignore_player_hacking_turret( self.targetname + "_box_player" );
			wait_network_frame();
			scene_wait( self.targetname + "_box_player" );
			trig sethintstring( &"SCRIPT_HOLD_TO_USE" );
			level.player freezecontrols( 1 );
			wait 0,2;
			level.player freezecontrols( 0 );
			self.hacked = 1;
			level.player set_ignoreme( 1 );
			level.player delay_thread( 5, ::set_ignoreme, 0 );
			self turret_set_team( "neutral" );
			self delay_thread( 5, ::turret_set_team, "allies" );
		}
		flag_set( "player_using_turret" );
		self notify( "turret_entered" );
		self makevehicleusable();
		self usevehicle( level.player, 0 );
		level.player allowcrouch( 0 );
		level.player magic_bullet_shield();
		flag_set( "intruder_perk_used" );
		level thread pull_player_off_turret_when_destroyed( self, player_pos, player_angles );
		while ( level.player.usingvehicle || level.player.usingturret )
		{
			wait_network_frame();
		}
		flag_clear( "player_using_turret" );
		if ( isDefined( self.m_turret_callback ) )
		{
			self [[ self.m_turret_callback ]]( 0 );
		}
		level.player setclientdvar( "cg_objectiveIndicatorPerkFarFadeDist", 1024 );
		level.player.health = level.player.maxhealth;
		level.player allowcrouch( 1 );
		level.player stop_magic_bullet_shield();
		self makevehicleunusable();
		level.player setorigin( player_pos );
		level.player setplayerangles( player_angles );
		self notify( "turret_exited" );
		self maps/_cic_turret::cic_turret_start_ai();
		wait 0,5;
		trig trigger_on();
		luinotifyevent( &"hud_expand_ammo" );
	}
}

enemies_ignore_player_hacking_turret( str_scene )
{
	level.player set_ignoreme( 1 );
	scene_wait( str_scene );
	level.player set_ignoreme( 0 );
}

turret_hack_rumble()
{
	wait 0,5;
	i = 0;
	while ( i < 10 )
	{
		self playrumbleonentity( "tank_rumble" );
		earthquake( 0,1, 0,1, self.origin, 1000, self );
		wait 0,1;
		i++;
	}
	wait 0,5;
	self playrumbleonentity( "damage_heavy" );
	earthquake( 0,1, 1, self.origin, 1000, self );
}

become_vulnerable_callback( ai )
{
}

become_invulnerable_callback( ai )
{
}

init_hackable_turrets()
{
	trigs = getentarray( "turret_trigger", "targetname" );
	i = 0;
	while ( i < trigs.size )
	{
		turret = getent( trigs[ i ].target, "targetname" );
		add_spawn_function_veh( trigs[ i ].target, ::hackable_turret_think );
		if ( isDefined( trigs[ i ].script_noteworthy ) )
		{
			hack_box = getent( trigs[ i ].script_noteworthy, "targetname" );
			add_scene( hack_box.targetname, hack_box.targetname );
			add_prop_anim( hack_box.targetname + "_panel", %o_specialty_blackout_intruder_panel, "p6_intruder_perk_box_panel" );
			add_scene( hack_box.targetname + "_player", hack_box.targetname );
			add_player_anim( "player_body", %int_specialty_blackout_intruder, 1 );
			add_prop_anim( hack_box.targetname + "_torch", %o_specialty_blackout_intruder_cutter, "t6_wpn_laser_cutter_prop", 1 );
			add_notetrack_custom_function( "player_body", "start", ::data_glove_on );
			add_notetrack_fx_on_tag( hack_box.targetname + "_torch", "zap_start", "laser_cutter_sparking", "tag_fx" );
			add_notetrack_fx_on_tag( hack_box.targetname + "_torch", "zap_end", "fx_laser_cutter_on", "tag_fx" );
		}
		i++;
	}
}

hackable_turret_think()
{
	t_hack = getent( self.targetname + "_box", "script_noteworthy" );
	self thread run_hackable_turret( t_hack );
	self thread remove_dead_turret_trigger( t_hack );
}

player_has_sniper_weapon()
{
	a_current_weapons = level.player getweaponslist();
	_a962 = a_current_weapons;
	_k962 = getFirstArrayKey( _a962 );
	while ( isDefined( _k962 ) )
	{
		weapon = _a962[ _k962 ];
		if ( !weaponissniperweapon( weapon ) && issubstr( weapon, "metalstorm" ) && level.player getammocount( weapon ) > 0 )
		{
			return 1;
		}
		_k962 = getNextArrayKey( _a962, _k962 );
	}
	return 0;
}

breadcrumb_and_flag( breadcrumb, objective, flag_name, show_message )
{
	if ( !isDefined( show_message ) )
	{
		show_message = 1;
	}
	level endon( "clear_old_breadcrumb" );
	first_trig = getent( breadcrumb, "targetname" );
	set_objective( objective, first_trig, "breadcrumb", undefined, show_message );
	if ( isDefined( first_trig.target ) )
	{
		objective_breadcrumb( objective, breadcrumb );
	}
	else
	{
		first_trig waittill( "trigger" );
	}
	flag_set( flag_name );
}

init_hero_startstruct( str_hero_name, str_struct_targetname )
{
	ai_hero = init_hero( str_hero_name );
	s_start_pos = getstruct( str_struct_targetname, "targetname" );
/#
	assert( isDefined( s_start_pos ), "Bad Hero setup struct: " + str_struct_targetname );
#/
	if ( isDefined( s_start_pos.angles ) )
	{
		v_angles = s_start_pos.angles;
	}
	else
	{
		v_angles = ( 0, 0, 0 );
	}
	ai_hero forceteleport( s_start_pos.origin, v_angles );
	return ai_hero;
}

precache_player_models()
{
	precachemodel( "c_mul_menendez_captured_viewhands" );
	precachemodel( "c_mul_menendez_captured_viewbody" );
	precachemodel( "c_usa_cia_masonjr_armlaunch_viewhands" );
	precachemodel( "c_usa_cia_masonjr_armlaunch_viewbody" );
}

get_furthest_offscreen( array )
{
	best_choice_dot = 2;
	best_choice = undefined;
	fvec = anglesToForward( level.player.angles );
	_a1034 = array;
	_k1034 = getFirstArrayKey( _a1034 );
	while ( isDefined( _k1034 ) )
	{
		obj = _a1034[ _k1034 ];
		to_obj = vectornormalize( obj.origin - level.player.origin );
		dot = vectordot( to_obj, fvec );
		if ( dot < best_choice_dot )
		{
			best_choice = obj;
			best_choice_dot = dot;
		}
		_k1034 = getNextArrayKey( _a1034, _k1034 );
	}
	return best_choice;
}

enable_node( do_enable )
{
	setenablenode( self, do_enable );
}

set_player_menendez()
{
	level.player allowsprint( 0 );
	level.player allowjump( 0 );
	setsaveddvar( "g_speed", 90 );
	level.player_is_menendez = 1;
	level.player enableinvulnerability();
	setdvar( "scr_damagefeedback", 0 );
	setsaveddvar( "vc_LUT", 6 );
	mason_trigs = getentarray( "mason_only_trigger", "script_noteworthy" );
	menendez_trigs = getentarray( "menendez_only_trigger", "script_noteworthy" );
	array_func( mason_trigs, ::trigger_off );
	array_func( menendez_trigs, ::trigger_on );
	mason_nodes = getnodearray( "mason_only_node", "script_noteworthy" );
	menendez_nodes = getnodearray( "menendez_only_node", "script_noteworthy" );
	array_func( mason_nodes, ::enable_node, 0 );
	array_func( menendez_nodes, ::enable_node, 1 );
	level.player_interactive_hands = "c_mul_menendez_captured_viewhands";
	level.player_interactive_model = "c_mul_menendez_captured_viewbody";
	level.player_viewmodel = "c_mul_menendez_captured_viewbody";
	level.player setviewmodel( "c_mul_menendez_captured_viewhands" );
	luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"menendez_no_hud" );
	maps/_friendlyfire::turnoff();
}

set_player_mason( initial_setup )
{
	if ( !isDefined( initial_setup ) )
	{
		initial_setup = 0;
	}
	level.player allowsprint( 1 );
	level.player allowjump( 1 );
	level.player_is_menendez = 0;
	level.player disableinvulnerability();
	setsaveddvar( "g_speed", 190 );
	setdvar( "scr_damagefeedback", 1 );
	setsaveddvar( "vc_LUT", 0 );
	mason_trigs = getentarray( "mason_only_trigger", "script_noteworthy" );
	menendez_trigs = getentarray( "menendez_only_trigger", "script_noteworthy" );
	array_func( mason_trigs, ::trigger_on );
	array_func( menendez_trigs, ::trigger_off );
	mason_nodes = getnodearray( "mason_only_node", "script_noteworthy" );
	menendez_nodes = getnodearray( "menendez_only_node", "script_noteworthy" );
	array_func( mason_nodes, ::enable_node, 1 );
	array_func( menendez_nodes, ::enable_node, 0 );
	set_character_rig_mason();
	luinotifyevent( &"hud_update_vehicle_custom", 1, 0 );
	maps/_friendlyfire::turnbackon();
	settimescale( 1 );
}

set_character_rig_mason()
{
	level.player_interactive_hands = "c_usa_cia_masonjr_armlaunch_viewhands";
	level.player_interactive_model = "c_usa_cia_masonjr_armlaunch_viewbody";
	level.player_viewmodel = "c_usa_cia_masonjr_armlaunch_viewhands";
	level.player setviewmodel( "c_usa_cia_masonjr_armlaunch_viewhands" );
}

set_character_rig_mason_shadow()
{
	level.player_interactive_hands = "c_usa_cia_masonjr_armlaunch_viewhands";
	level.player_interactive_model = "c_usa_cia_masonjr_armlaunch_viewbody_s";
	level.player_viewmodel = "c_usa_cia_masonjr_armlaunch_viewhands";
	level.player setviewmodel( "c_usa_cia_masonjr_armlaunch_viewhands" );
}

play_pip( str_bik_name, b_is_in_level_memory )
{
	if ( !isDefined( b_is_in_level_memory ) )
	{
		b_is_in_level_memory = 1;
	}
	maps/_glasses::play_bink_on_hud( str_bik_name, 0, b_is_in_level_memory );
}

friendly_fire_instant_fail_add()
{
	if ( isDefined( self.magic_bullet_shield ) )
	{
		self.restore_magic_bullet_shield = self.magic_bullet_shield;
	}
	self thread magic_bullet_shield();
	self.overrideactordamage = ::friendly_fire_fail_if_shot_by_player;
}

friendly_fire_instant_fail_remove()
{
	if ( !self.restore_magic_bullet_shield )
	{
		self thread stop_magic_bullet_shield();
	}
	self.restore_magic_bullet_shield = undefined;
	self.overrideactordamage = undefined;
}

friendly_fire_fail_if_shot_by_player( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename )
{
	if ( isplayer( eattacker ) )
	{
		level.player thread maps/_friendlyfire::missionfail();
	}
	return 0;
}

handle_m32_gas_death()
{
	if ( is_true( self.magic_bullet_shield ) )
	{
		return;
	}
	if ( self.damageweapon == "m32_gas_sp" && self.damagemod != "MOD_PROJECTILE_SPLASH" )
	{
		initial_force = self.damagedir + vectorScale( ( 0, 0, 0 ), 0,2 );
		initial_force *= 100;
		self startragdoll( self.damagemod == "MOD_CRUSH" );
		self launchragdoll( initial_force, self.damagelocation );
		return 1;
	}
	else
	{
		if ( self.damageweapon == "m32_gas_sp" )
		{
			self.a.forcegasdeath = 1;
		}
	}
	return 0;
}

handle_m32_allies()
{
	if ( self.damageweapon == "m32_gas_sp" )
	{
		return 1;
	}
	return 0;
}

waittill_player_away( distance, distance_2d )
{
	if ( !isDefined( distance_2d ) )
	{
		distance_2d = 1;
	}
	dist_sq = distance * distance;
	my_dist_sq = dist_sq - 10;
	if ( distance_2d )
	{
		my_dist_sq = distance2dsquared( self.origin, level.player.origin );
	}
	else
	{
		my_dist_sq = distancesquared( self.origin, level.player.origin );
	}
	wait_network_frame();
}

waittill_player_nearby( distance, override_notify, distance_2d, do_trace )
{
	if ( !isDefined( distance_2d ) )
	{
		distance_2d = 1;
	}
	if ( !isDefined( do_trace ) )
	{
		do_trace = 0;
	}
	if ( isDefined( override_notify ) )
	{
		self endon( override_notify );
	}
	dist_sq = distance * distance;
	my_dist_sq = dist_sq + 10;
	if ( distance_2d )
	{
		my_dist_sq = distance2dsquared( self.origin, level.player.origin );
	}
	else
	{
		my_dist_sq = distancesquared( self.origin, level.player.origin );
	}
	can_see = 1;
	if ( do_trace )
	{
		can_see = level.player is_player_looking_at( self.origin, 0,5, 1, 1 );
	}
	wait_network_frame();
	if ( dist_sq <= my_dist_sqreturn sqrt( my_dist_sq );
}

kill_behind_player( forward_struct )
{
	self endon( "death" );
	room_dir_struct = getstruct( forward_struct, "targetname" );
	forward = anglesToForward( room_dir_struct.angles );
	wait_network_frame();
	me_to_player = level.player.origin - self.origin;
	magicbullet( "xm8_sp", level.salazar.origin + vectorScale( ( 0, 0, 0 ), 60 ), self gettagorigin( "J_head" ) );
	self bloody_death();
}

give_redshirt_gas_mask()
{
	b_has_gas_mask = isDefined( self.gas_mask_model );
	if ( !b_has_gas_mask )
	{
		if ( self.model == "c_mul_neomax_la_medium" )
		{
			str_gas_mask_model = "c_mul_neomarx_la_medium_gasmask";
		}
		else
		{
			str_gas_mask_model = "c_mul_neomarx_la_light_gasmask";
		}
		self attach( str_gas_mask_model, "J_Head" );
		self.gas_mask_model = str_gas_mask_model;
	}
}

run_menendez_enemy()
{
	self endon( "death" );
	self.deathfunction = ::handle_m32_gas_death;
	self.script_accuracy = 0;
	if ( issubstr( self.targetname, "control_room" ) )
	{
		trigger_wait( "sacrifice_start_trigger" );
		self thread kill_behind_player( "messiah_dir_struct" );
	}
	else
	{
		return;
	}
	dist = self waittill_player_nearby( 300, "kill_this_chump", 1, 1 );
	while ( isDefined( self.melee ) )
	{
		wait_network_frame();
	}
	aim_time = randomfloatrange( 0,5, 1 );
	self thread aim_at_target( level.player, 1 );
	wait aim_time;
	if ( level.player is_player_looking_at( self.origin, 0,5, 1, 1 ) )
	{
		attacker = level.salazar;
		if ( rand_chance( 0,5 ) )
		{
			attacker = level.defalco;
		}
		magicbullet( "xm8_sp", attacker.origin + vectorScale( ( 0, 0, 0 ), 60 ), self gettagorigin( "J_head" ), attacker );
	}
	self bloody_death();
}

assign_scripted_team( scripted_team )
{
/#
	assert( isDefined( scripted_team ) );
#/
/#
	if ( scripted_team != "axis" && scripted_team != "allies" )
	{
		assert( scripted_team == "team3" );
	}
#/
	self.team = scripted_team;
	if ( level.player_is_menendez )
	{
		if ( scripted_team == "axis" )
		{
			if ( !isDefined( self.script_animname ) )
			{
				self thread run_menendez_enemy();
			}
			return;
		}
		else
		{
			self.deathfunction = ::handle_m32_allies;
		}
	}
}

extra_cam_init( position_struct_name, link_to_obj_name, aspect_ratio )
{
	cam = get_extracam();
	cam_pos = getstruct( position_struct_name, "targetname" );
	cam.origin = cam_pos.origin;
	cam.angles = cam_pos.angles;
	if ( isDefined( link_to_obj_name ) )
	{
		link_obj = getent( link_to_obj_name, "targetname" );
		cam linkto( link_obj );
	}
	turn_on_extra_cam();
	if ( !isDefined( aspect_ratio ) )
	{
		aspect_ratio = 1,777778;
	}
	setsaveddvar( "r_extracam_custom_aspectratio", aspect_ratio );
	return cam;
}

extra_cam_move( position_struct_name )
{
	cam = get_extracam();
	cam_pos = getstruct( position_struct_name, "targetname" );
	cam.origin = cam_pos.origin;
	cam.angles = cam_pos.angles;
}

spawn_defalco_or_standin( str_start_node )
{
	if ( !isDefined( str_start_node ) )
	{
		str_start_node = "skipto_menendez_start_defalco";
	}
	if ( level.is_defalco_alive )
	{
		level.defalco = init_hero_startstruct( "defalco", str_start_node );
		level.defalco.name = "Defalco";
	}
	else
	{
		level.defalco = simple_spawn_single( "defalco_standin", ::pmc_give_headmodel_without_mask );
		s_spawn = getstruct( str_start_node, "targetname" );
		level.defalco forceteleport( s_spawn.origin, s_spawn.angles );
	}
	level.defalco.animname = "defalco";
	level.defalco set_force_color( "o" );
	level.defalco set_ignoreall( 1 );
	level.defalco setgoalpos( level.defalco.origin );
	level.defalco stop_magic_bullet_shield();
	return level.defalco;
}

init_spawner_teams()
{
	team_names = [];
	team_names[ 0 ] = "allies";
	team_names[ 1 ] = "axis";
	team_names[ 2 ] = "team3";
	j = 0;
	while ( j < team_names.size )
	{
		spawners = getentarray( team_names[ j ], "script_noteworthy" );
		i = 0;
		while ( i < spawners.size )
		{
			spawners[ i ] add_spawn_function( ::assign_scripted_team, team_names[ j ] );
			i++;
		}
		j++;
	}
}

trigger_wait_facing( str_trigger_name, max_facing_angle_degrees )
{
	max_dot = cos( max_facing_angle_degrees );
	t_trigger = getent( str_trigger_name, "targetname" );
	t_trigger waittill( "trigger" );
	player_fvec = anglesToForward( level.player.angles );
	trigger_fvec = anglesToForward( t_trigger.angles );
}

weapon_kill_reporter()
{
	self waittill( "death", attacker, type, sweapon );
	if ( isDefined( attacker ) && isDefined( sweapon ) )
	{
		if ( isplayer( attacker ) )
		{
			level notify( "player_performed_kill" );
		}
	}
	if ( isDefined( self._fire_direction_targeted ) && self._fire_direction_targeted && isDefined( sweapon ) )
	{
		if ( sweapon == "claw_grenade_impact_explode_sp" || sweapon == "bigdog_dual_turret" )
		{
			level notify( "brute_kill" );
		}
	}
}

init_kill_functions()
{
	all_spawners = getspawnerarray();
	_a1510 = all_spawners;
	_k1510 = getFirstArrayKey( _a1510 );
	while ( isDefined( _k1510 ) )
	{
		spawner = _a1510[ _k1510 ];
		spawner add_spawn_function( ::weapon_kill_reporter );
		_k1510 = getNextArrayKey( _a1510, _k1510 );
	}
}

min_val( a, b )
{
	if ( a < b )
	{
		return a;
	}
	else
	{
		return b;
	}
}

welding_fx( str_wait_scene )
{
	fxorg = spawn( "script_model", ( 0, 0, 0 ) );
	fxorg setmodel( "tag_origin" );
	wait 0,1;
	fxorg.origin = self gettagorigin( "tag_fx" );
	fxorg.angles = self gettagangles( "tag_fx" );
	fxorg linkto( self, "tag_fx" );
	self play_fx( "laser_cutter_sparking", undefined, undefined, "stop_fx", 1, "tag_fx" );
	self play_fx( "fx_laser_cutter_on", undefined, undefined, "stop_fx", 1, "tag_fx" );
	fxorg playsound( "evt_vent_cutter_start" );
	fxorg playloopsound( "evt_vent_cutter_loop", 1 );
	if ( isDefined( str_wait_scene ) )
	{
		scene_wait( str_wait_scene );
	}
	wait 3;
	fxorg stoploopsound( 1 );
	fxorg playsound( "evt_vent_cutter_end" );
	wait 1;
	self notify( "stop_fx" );
}

set_karma_killed()
{
	level.is_karma_alive = 0;
	level.player set_story_stat( "KARMA_DEAD_IN_COMMAND_CENTER", 1 );
}

set_farid_killed()
{
	level.is_farid_alive = 0;
	level.player set_story_stat( "FARID_DEAD_IN_COMMAND_CENTER", 1 );
}

set_briggs_killed()
{
	level.is_briggs_alive = 0;
	level.player set_story_stat( "BRIGGS_DEAD", 1 );
}

set_defalco_killed()
{
	level.is_defalco_alive = 0;
	level.player set_story_stat( "DEFALCO_DEAD_IN_COMMAND_CENTER", 1 );
}

set_post_branching_scene_stats()
{
	if ( level.is_karma_alive && !level.is_farid_alive )
	{
		set_karma_killed();
	}
	if ( !level.is_farid_alive )
	{
		set_farid_killed();
	}
	else
	{
		if ( level.is_defalco_alive )
		{
			set_defalco_killed();
		}
	}
}

get_branching_scene_label()
{
	flag_wait( "story_stats_loaded" );
	scene_name = "";
	if ( level.is_defalco_alive )
	{
		scene_name += "alive_";
	}
	else
	{
		scene_name += "dead_";
	}
	if ( level.is_farid_alive )
	{
		if ( level.is_karma_alive )
		{
			scene_name += "a";
		}
		else
		{
			scene_name += "b";
		}
	}
	else if ( level.is_karma_alive )
	{
		scene_name += "c";
	}
	else
	{
		scene_name = undefined;
	}
	return scene_name;
}

branching_scene_debug()
{
	if ( !level.branching_scene_debug )
	{
		return;
	}
	variant_string = "Living Actors:";
	if ( level.is_defalco_alive )
	{
		variant_string += " Defalco";
	}
	if ( level.is_karma_alive )
	{
		variant_string += " Karma";
	}
	if ( level.is_farid_alive )
	{
		variant_string += " Farid";
	}
	iprintlnbold( variant_string );
}

run_debug_timer()
{
	time_s = 0;
	while ( 1 )
	{
		if ( !flag( "debug_timer_active" ) )
		{
			time_s = 0;
		}
		flag_wait( "debug_timer_active" );
		iprintln( "" + time_s );
		wait 0,2;
		time_s += 0,2;
	}
}

retrieve_story_stats()
{
	flag_wait( "all_players_connected" );
	level.is_defalco_alive = !level.player get_story_stat( "DEFALCO_DEAD_IN_KARMA" );
	if ( !level.player get_story_stat( "KARMA_DEAD_IN_KARMA" ) )
	{
		b_karma_alive_and_not_captured_in_karma = !level.player get_story_stat( "KARMA_CAPTURED" );
	}
	if ( !level.player get_story_stat( "KARMA_DEAD_IN_KARMA" ) )
	{
		if ( level.player get_story_stat( "KARMA_CAPTURED" ) )
		{
			b_karma_captured_but_retrieved_in_socotra = level.player get_story_stat( "SO_WAR_SOCOTRA_SUCCESS" );
		}
	}
	if ( !b_karma_alive_and_not_captured_in_karma )
	{
		level.is_karma_alive = b_karma_captured_but_retrieved_in_socotra;
	}
	level.is_farid_alive = !level.player get_story_stat( "FARID_DEAD_IN_YEMEN" );
	level.is_harper_alive = !level.player get_story_stat( "HARPER_DEAD_IN_YEMEN" );
/#
	if ( level.is_farid_alive == level.is_harper_alive )
	{
#/
	}
	if ( level.is_harper_alive && level.player get_story_stat( "HARPER_SCARRED" ) )
	{
		sp_harper = get_ent( "harper", "targetname", 1 );
		sp_harper add_spawn_function( ::harper_give_scarred_face );
	}
	skipto_check_conditional_dvars();
	flag_set( "story_stats_loaded" );
}

harper_give_scarred_face()
{
	self detach( self.headmodel );
	self.headmodel = "c_usa_cia_combat_harper_head_scar";
	self attach( "c_usa_cia_combat_harper_head_scar" );
}

karma_cut_throat()
{
	if ( is_mature() )
	{
		self detach( self.headmodel );
		self.headmodel = "c_usa_chloe_cc_head_cut_cin";
		self attach( "c_usa_chloe_cc_head_cut_cin" );
	}
}

karma_head_bruised()
{
	self detach( self.headmodel );
	self.headmodel = "c_usa_chloe_cc_head_bruised_cin";
	self attach( "c_usa_chloe_cc_head_bruised_cin" );
}

karma_head_shot()
{
	if ( is_mature() )
	{
		self detach( self.headmodel );
		self.headmodel = "c_usa_chloe_cc_head_bleed_cin";
		self attach( "c_usa_chloe_cc_head_bleed_cin" );
		self setclientflag( 0 );
	}
}

defalco_shot_head()
{
	if ( is_mature() )
	{
		self detach( self.headmodel );
		self.headmodel = "c_mul_yemen_defalco_head_shot";
		self attach( "c_mul_yemen_defalco_head_shot" );
	}
}

defalco_knife_bloody()
{
	if ( is_mature() )
	{
		self detach( "viewmodel_knife", "tag_weapon_left" );
		self attach( "viewmodel_knife_blood", "tag_weapon_left" );
		self.super_kill_knife = "viewmodel_knife_blood";
	}
}

defalco_body_bloody()
{
	if ( is_mature() )
	{
		self setmodel( "c_mul_yemen_defalco_bloody_body" );
	}
}

farid_body_shot()
{
	if ( is_mature() )
	{
		self detach( self.headmodel );
		self.headmodel = "c_mul_farid_cc_shirt_shot";
		self attach( "c_mul_farid_cc_shirt_shot" );
	}
}

menendez_bloody_version()
{
	if ( is_mature() )
	{
		if ( isassetloaded( "xmodel", "c_mul_menendez_old_captured_head_bleed" ) )
		{
			self detach( self.headmodel );
			self.headmodel = "c_mul_menendez_old_captured_head_bleed";
			self attach( "c_mul_menendez_old_captured_head_bleed" );
		}
		if ( isassetloaded( "xmodel", "c_mul_menendez_old_captured_body_bld" ) )
		{
			self setmodel( "c_mul_menendez_old_captured_body_bld" );
		}
	}
}

crosby_setup()
{
	str_crosby_head = "c_usa_seal6_assault_head";
	if ( isassetloaded( "xmodel", str_crosby_head ) )
	{
		self detach( self.headmodel );
		self attach( str_crosby_head );
		self.headmodel = str_crosby_head;
	}
}

pmc_give_headmodel_without_mask()
{
	str_headmodel = "c_mul_pmc_head_1_1";
	if ( isassetloaded( "xmodel", str_headmodel ) )
	{
		self detach( self.headmodel );
		self attach( str_headmodel );
		self.headmodel = str_headmodel;
	}
}

super_kill_exploder_add( num )
{
	if ( !isDefined( level.super_kill_exploders ) )
	{
		level.super_kill_exploders = [];
	}
	level.super_kill_exploders[ level.super_kill_exploders.size ] = num;
	exploder( num );
}

super_kill_exploder_stop_all()
{
	while ( isDefined( level.super_kill_exploders ) )
	{
		i = 0;
		while ( i < level.super_kill_exploders.size )
		{
			stop_exploder( level.super_kill_exploders[ i ] );
			i++;
		}
	}
}

super_kill_exploder_restore_all()
{
	while ( isDefined( level.super_kill_exploders ) )
	{
		i = 0;
		while ( i < level.super_kill_exploders.size )
		{
			exploder( level.super_kill_exploders[ i ] );
			i++;
		}
	}
}

clean_up_super_kill_blood()
{
	stop_exploder( 771 );
	stop_exploder( 772 );
	stop_exploder( 773 );
	stop_exploder( 774 );
	stop_exploder( 775 );
	stop_exploder( 774 );
	stop_exploder( 776 );
	stop_exploder( 777 );
	stop_exploder( 778 );
	stop_exploder( 779 );
	stop_exploder( 770 );
	if ( isDefined( level.super_kill_exploders ) )
	{
		level.super_kill_exploders = undefined;
	}
}

headtracking_on()
{
	self animscripts/shared::notetrackheadlookatplayer( undefined, undefined );
}

headtracking_off()
{
	self animscripts/shared::notetrackclearlookat( undefined, undefined );
}

notetrack_switch_to_sidearm( ai_guy )
{
	ai_guy gun_switchto( ai_guy.sidearm, "right" );
}

trigger_wait_timeout( failsafe_time_s, str_trigger_name, str_key )
{
	t_trig = undefined;
	if ( isDefined( str_trigger_name ) )
	{
		if ( !isDefined( str_key ) )
		{
			str_key = "targetname";
		}
		t_trig = getent( str_trigger_name, str_key );
	}
	else
	{
		t_trig = self;
	}
	t_trig endon( "trigger" );
	wait failsafe_time_s;
}

waittill_trigger_or_notify( str_trigger, str_notify )
{
	self endon( str_notify );
	trigger_wait( str_trigger );
}

waittill_trigger_timeout_or_notify( trigger_name, timeout_time, notify_name )
{
	self endon( notify_name );
	trigger = getent( trigger_name, "targetname" );
	if ( isDefined( trigger ) )
	{
		trigger endon( "trigger" );
	}
	if ( isDefined( timeout_time ) )
	{
		wait timeout_time;
	}
	else if ( isDefined( trigger ) )
	{
		trigger waittill( "trigger" );
	}
	else
	{
		self waittill( notify_name );
	}
}

sea_cowbell()
{
	level.fire_at_drones = 0;
	if ( flag( "sea_cowbell_running" ) )
	{
		return;
	}
	launcher_list = getentarray( "launcher", "targetname" );
	level.boats_already_spawned = 1;
	array_thread( launcher_list, ::_aircraft_launcher_logic );
}

end_sea_cowbell()
{
	flag_clear( "sea_cowbell_running" );
	level notify( "stop_sea_cowbell" );
	level notify( "stop_ambient_shooting_at_boats" );
}

_populate_boat_models( n_x_min, n_x_max, n_y_min, n_y_max )
{
	total_spawned_boats_this_function_call = 0;
	a_boat_models = array( "veh_iw_sea_slava_cruiser_des", "veh_iw_arleigh_burke_des", "veh_iw_sea_rus_burya_corvette" );
	x = n_x_min;
	while ( x <= n_x_max )
	{
		y = n_y_min;
		while ( y <= n_y_max )
		{
			if ( total_spawned_boats_this_function_call >= 14 )
			{
				break;
			}
			else
			{
				n_placement_chance = randomint( 5 );
				if ( n_placement_chance == 0 )
				{
					m_boat_model = random( a_boat_models );
					v_position = ( x, y, -1024 );
					if ( m_boat_model == "veh_iw_sea_slava_cruiser_des" )
					{
						v_position += vectorScale( ( 0, 0, 0 ), 250 );
					}
					else
					{
						if ( m_boat_model == "veh_iw_arleigh_burke_des" )
						{
							v_position += vectorScale( ( 0, 0, 0 ), 1000 );
						}
					}
					m_boat = spawn_model( m_boat_model, v_position, ( 0, randomint( 360 ), 0 ) );
					m_boat.targetname = "boat_model";
					m_boat.script_noteworthy = "sky_cowbell_targets";
					total_spawned_boats_this_function_call++;
				}
				y += 4096;
			}
		}
		x += 4096;
	}
}

_vehicle_on_spline()
{
	level endon( "stop_sea_cowbell" );
	a_boat_vehicles = array( "ambient_barge", "ambient_gunboat_medium", "ambient_gunboat_medium", "ambient_gunboat_small", "ambient_gunboat_small", "ambient_gunboat_small" );
	while ( 1 )
	{
		str_boat_vehicle = random( a_boat_vehicles );
		vh_spawner = get_vehicle_spawner( str_boat_vehicle );
		while ( isDefined( vh_spawner.vehicle_spawned_thisframe ) )
		{
			wait 0,05;
		}
		vh_spawner.vehicle_spawned_thisframe = 1;
		vh_boat = spawn_vehicle_from_targetname( str_boat_vehicle );
		vh_boat thread _boat_death();
		vh_boat thread _notify_death_when_sea_cowbell_stops();
		if ( str_boat_vehicle == "ambient_barge" )
		{
			vh_boat setspeed( 16 );
		}
		else if ( str_boat_vehicle == "ambient_gunboat_medium" )
		{
			vh_boat setspeed( 31 );
		}
		else
		{
			if ( str_boat_vehicle == "ambient_gunboat_small" )
			{
				vh_boat setspeed( 61 );
			}
		}
		wait 0,05;
		vh_spawner.vehicle_spawned_thisframe = undefined;
		vh_boat thread go_path( self );
		vh_boat waittill( "death" );
	}
}

_notify_death_when_sea_cowbell_stops()
{
	self endon( "death" );
	level waittill( "stop_sea_cowbell" );
	self notify( "death" );
}

_boat_death()
{
	self waittill( "death" );
	if ( isDefined( self ) )
	{
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
	}
}

_aircraft_launcher_logic()
{
	level endon( "stop_ambient_shooting_at_boats" );
	self veh_magic_bullet_shield();
	v_launcher_forward = anglesToForward( self.angles );
	while ( 1 )
	{
		while ( level.fire_at_drones )
		{
			a_drone_vehicles = getentarray( "drone_turret_targets", "script_noteworthy" );
			while ( a_drone_vehicles.size > 0 )
			{
				n_dot_to_drones = 0;
				while ( n_dot_to_drones <= 0,4 )
				{
					e_drone = random( a_drone_vehicles );
					if ( isDefined( e_drone ) && isalive( e_drone ) )
					{
						while ( e_drone.origin[ 2 ] < -1028 )
						{
							continue;
						}
						n_dot_to_drones = vectordot( v_launcher_forward, vectornormalize( e_drone.origin - self.origin ) );
						if ( n_dot_to_drones > 0,4 )
						{
							self set_turret_target( e_drone, vectorScale( ( 0, 0, 0 ), 64 ), 0 );
							self fire_turret( 0 );
							if ( distance( level.player.origin, self.origin ) < 768 )
							{
								level.player playrumbleonentity( "damage_heavy" );
							}
							earthquake( 0,3, 1, self.origin, 768 );
							wait 0,1;
							break;
						}
					}
					else
					{
						wait 0,05;
					}
				}
				wait 3;
			}
		}
		a_boat_vehicles = getstructarray( "sea_cowbell_target", "targetname" );
		while ( a_boat_vehicles.size > 0 )
		{
			e_boat = random( a_boat_vehicles );
			n_dot_to_boat = vectordot( v_launcher_forward, vectornormalize( e_boat.origin - self.origin ) );
			while ( n_dot_to_boat > 0,4 )
			{
				target_origin = spawn( "script_origin", e_boat.origin );
				self set_turret_target( target_origin, vectorScale( ( 0, 0, 0 ), 64 ), 0 );
				self fire_turret( 0 );
				if ( distance( level.player.origin, self.origin ) < 768 )
				{
					level.player playrumbleonentity( "damage_heavy" );
				}
				earthquake( 0,3, 1, self.origin, 768 );
				wait 3;
				target_origin delete();
			}
		}
		wait 0,05;
	}
}

weaken_ai_group( str_aigroup )
{
	ai_guys = get_ai_group_ai( str_aigroup );
	i = 0;
	while ( i < ai_guys.size )
	{
		ai_guys[ i ] weaken_ai();
		i++;
	}
	return ai_guys;
}

_phalanx_cannon_think_hacked()
{
	a_initial_targets = get_ai_group_ai( "deck_wave_1" );
	while ( isDefined( a_initial_targets ) && a_initial_targets.size > 0 )
	{
		ai_target = random( a_initial_targets );
		self set_turret_target( ai_target, undefined, 0 );
		wait randomfloatrange( 1,5, 2,5 );
		a_initial_targets = get_ai_group_ai( "deck_wave_1" );
		while ( a_initial_targets.size > 0 )
		{
			ai_target = random( a_initial_targets );
			while ( isDefined( ai_target ) && isalive( ai_target ) )
			{
				self set_turret_target( ai_target, undefined, 0 );
				wait randomfloatrange( 0,6, 1,2 );
				self fire_turret_for_time( randomfloatrange( 2, 4 ), 0 );
			}
			a_initial_targets = get_ai_group_ai( "deck_wave_1" );
		}
	}
	self thread _phalanx_cannon_think( "deck_drone" );
}

_phalanx_cannon_think( str_target )
{
	level endon( "kill_phalanx_cannons" );
	self endon( "stop_targeting" );
	while ( 1 )
	{
		if ( isDefined( str_target ) )
		{
			a_e_targets = getentarray( str_target, "script_noteworthy" );
			v_offset = ( randomintrange( -16, 16 ), randomintrange( -16, 16 ), randomintrange( -64, 128 ) );
		}
		else
		{
			a_e_targets = level.a_e_phalanx_cannon_targets;
			v_offset = ( randomintrange( -64, 64 ), randomintrange( -64, 64 ), randomintrange( 640, 2048 ) );
		}
		if ( a_e_targets.size > 0 )
		{
			e_target = random( a_e_targets );
			if ( isDefined( e_target ) )
			{
				if ( vectordot( anglesToForward( self.angles ), vectornormalize( e_target.origin - self.origin ) ) > 0,4 )
				{
					self set_turret_target( e_target, v_offset, 0 );
					wait randomfloatrange( 2, 5 );
					self fire_turret_for_time( randomfloatrange( 0,1, 1 ), 0 );
				}
			}
		}
		wait 0,2;
	}
}

phalanx_cannon_target_update()
{
	level endon( "kill_phalanx_cannons" );
	while ( 1 )
	{
		a_e_targets = getentarray( "allied_vehicle", "script_noteworthy" );
		a_m_ambient = getentarray( "ambient_ship_spot", "script_noteworthy" );
		level.a_e_phalanx_cannon_targets = arraycombine( a_e_targets, a_m_ambient, 1, 0 );
		wait 0,1;
	}
}

end_bridge_launchers()
{
	flag_clear( "bridge_launchers_running" );
	level notify( "stop_bridge_launchers" );
}

_bridge_launcher_logic( n_index )
{
	level endon( "stop_bridge_launchers" );
	v_launcher_forward = anglesToForward( self.angles );
	a_battleship_structs = getstructarray( "battleship_end", "targetname" );
	if ( a_battleship_structs.size == 0 )
	{
/#
		iprintln( "THERE ARE NO BATTLESHIP_END STRUCTS" );
#/
		return;
	}
	n_start_wait_time = n_index % 3;
	wait n_start_wait_time;
	burst_time_min = 0,2;
	burst_time_max = 0,4;
	time_between_bursts_min = 2;
	time_between_bursts_max = 4;
	while ( 1 )
	{
		self set_turret_burst_parameters( burst_time_min, burst_time_max, time_between_bursts_min, time_between_bursts_max, 0 );
		s_battleship_end = random( a_battleship_structs );
		n_dot_to_struct = vectordot( v_launcher_forward, vectornormalize( s_battleship_end.origin - self.origin ) );
		if ( n_dot_to_struct > 0,4 )
		{
			v_battleship_forward = anglesToForward( s_battleship_end.angles );
			v_rand_target_pos = s_battleship_end.origin + ( v_battleship_forward * randomint( 11264 ) );
			self settargetorigin( v_rand_target_pos );
			self waittill( "turret_on_target" );
			fire_time = randomfloatrange( 6, 8 );
			self fire_turret_for_time( fire_time, 0 );
		}
		wait_network_frame();
	}
}

fa38_init_fx( is_hovering )
{
	if ( !isDefined( is_hovering ) )
	{
		is_hovering = 1;
	}
	self thread fa38_hover();
	self thread fa38_fly();
	if ( is_true( is_hovering ) )
	{
		self notify( "hover" );
	}
	else
	{
		self notify( "fly" );
	}
}

f38_init_fake_vehicle( m_f38 )
{
	m_f38 notetrack_f38_add_exhaust_fx();
}

notetrack_f38_add_exhaust_fx()
{
	self play_fx( "f35_exhaust_hover_rear", undefined, undefined, "fly", 1, "tag_fx_nozzle_left_rear" );
	self play_fx( "f35_exhaust_hover_rear", undefined, undefined, "fly", 1, "tag_fx_nozzle_right_rear" );
	self play_fx( "f35_exhaust_hover_front", undefined, undefined, "fly", 1, "tag_fx_nozzle_left" );
	self play_fx( "f35_exhaust_hover_front", undefined, undefined, "fly", 1, "tag_fx_nozzle_right" );
}

fa38_hover()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "hover" );
		if ( isDefined( self.hovering ) && !self.hovering )
		{
			play_fx( "f35_exhaust_hover_rear", undefined, undefined, "fly", 1, "tag_fx_nozzle_left_rear" );
			play_fx( "f35_exhaust_hover_rear", undefined, undefined, "fly", 1, "tag_fx_nozzle_right_rear" );
			play_fx( "f35_exhaust_hover_front", undefined, undefined, "fly", 1, "tag_fx_nozzle_left" );
			play_fx( "f35_exhaust_hover_front", undefined, undefined, "fly", 1, "tag_fx_nozzle_right" );
			self.hovering = 1;
		}
	}
}

fa38_fly()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "fly" );
		if ( isDefined( self.hovering ) && self.hovering )
		{
			play_fx( "f35_exhaust_fly", undefined, undefined, "hover", 1, "origin_animate_jnt" );
			self.hovering = 0;
		}
	}
}

notetrack_fxanim_f38_stops_firing( m_f38 )
{
	self notify( "f38_stops_firing_guns" );
}

notetrack_fxanim_f38_fires_guns( m_f38 )
{
	self endon( "f38_stops_firing_guns" );
	str_tag_turret_left = "tag_flash_gunner1";
	str_tag_turret_right = "tag_flash_gunner2";
	str_weapon = "f35_side_minigun";
	while ( isDefined( m_f38 ) )
	{
		v_angles_forward = anglesToForward( m_f38.angles ) * 200;
		v_left_start = m_f38 gettagorigin( str_tag_turret_left );
		v_left_end = v_left_start + v_angles_forward;
		playfxontag( level._effect[ "fx_f38_turret_flash" ], m_f38, str_tag_turret_left );
		magicbullet( str_weapon, v_left_start, v_left_end );
		v_right_start = m_f38 gettagorigin( str_tag_turret_right );
		v_right_end = v_right_start + v_angles_forward;
		playfxontag( level._effect[ "fx_f38_turret_flash" ], m_f38, str_tag_turret_right );
		magicbullet( str_weapon, v_right_start, v_right_end );
		wait 0,1;
	}
}

mason_objectives_hide()
{
	set_objective( level.obj_interrogate, undefined, "delete" );
	set_objective( level.obj_restore_control, undefined, "delete" );
	set_objective( level.obj_help_seals, undefined, "delete" );
}

mason_objectives_show()
{
	set_objective( level.obj_fake_interrogate, undefined, undefined, undefined, 0 );
	set_objective( level.obj_fake_interrogate, undefined, "done", undefined, 0 );
	set_objective( level.obj_fake_restore_control, undefined, undefined, undefined, 0 );
	set_objective( level.obj_fake_restore_control, undefined, "done", undefined, 0 );
	flag_set( "mason_objectives_restored" );
}

hide_surface()
{
	self hide();
}

get_furthest( origin, array )
{
	return get_array_of_farthest( origin, array, undefined, 1 )[ 0 ];
}

scene_exists( scene_name )
{
	return flag_exists( scene_name + "_started" );
}

scene_is_playing( scene_name )
{
	if ( flag( scene_name + "_started" ) )
	{
		return !flag( scene_name + "_done" );
	}
}

setup_extra_cams()
{
	level.extra_cam_surfaces = [];
	level.extra_cam_surfaces[ "cctv_left" ] = getent( "khan_screen", "targetname" );
	level.extra_cam_surfaces[ "cctv_right" ] = getent( "khan_screen_2", "targetname" );
	level.extra_cam_surfaces[ "server" ] = getent( "server_screen", "targetname" );
	level.extra_cam_surfaces[ "observation" ] = getent( "intro_screen", "targetname" );
	level.extra_cam_surfaces[ "cctv_salazar" ] = getent( "salazar_shoots_screen", "targetname" );
	array_func( level.extra_cam_surfaces, ::hide_surface );
	cams = [];
	cams[ 0 ] = "pip_glasses_pos";
	cams[ 1 ] = "menendez_start_extracam";
	_a2519 = cams;
	_k2519 = getFirstArrayKey( _a2519 );
	while ( isDefined( _k2519 ) )
	{
		cam_name = _a2519[ _k2519 ];
		cam_pos = getstruct( cam_name, "targetname" );
		cam_pos_target = getstruct( cam_pos.target, "targetname" );
		to_target = cam_pos_target.origin - cam_pos.origin;
		cam_pos.angles = vectorToAngle( to_target );
		_k2519 = getNextArrayKey( _a2519, _k2519 );
	}
}

fxanim_play_fx_think( str_joint, str_notify, str_fx )
{
	while ( 1 )
	{
		self waittill( str_notify );
		playfxontag( level._effect[ str_fx ], self, str_joint );
	}
}

fxanim_play_fx( str_model_targetname, str_joint, str_notify, str_fx )
{
	e_models = getentarray( str_model_targetname, "targetname" );
	_a2540 = e_models;
	_k2540 = getFirstArrayKey( _a2540 );
	while ( isDefined( _k2540 ) )
	{
		e_model = _a2540[ _k2540 ];
		e_model thread fxanim_play_fx_think( str_joint, str_notify, str_fx );
		_k2540 = getNextArrayKey( _a2540, _k2540 );
	}
}

play_spark_fx( e_wire )
{
	if ( e_wire.model == "fxanim_gp_wirespark_med_mod" )
	{
		str_tag = "med_spark_06_jnt";
	}
	else if ( e_wire.model == "fxanim_gp_wirespark_long_mod" )
	{
		str_tag = "long_spark_06_jnt";
	}
	else
	{
/#
		assertmsg( e_wire.model + " is not supported by play_spark_fx() yet" );
#/
	}
	playfxontag( level._effect[ "fx_wire_spark" ], e_wire, str_tag );
}

init_fxanims()
{
	add_notetrack_custom_function( "fxanim_props", "spark_wire", ::play_spark_fx, 1 );
}

init_drones()
{
	maps/_drones::drones_add_custom_func( "jetpack_arrival", ::maps/_jetpack_ai::create_jetpack_drone );
}

init_flags()
{
	flag_init( "player_using_turret" );
	flag_init( "distant_explosions_on" );
	flag_init( "debug_timer_active" );
	flag_init( "start_messiah" );
	flag_init( "story_stats_loaded" );
	flag_init( "mason_objectives_restored" );
	flag_init( "dev_skipto_ready" );
	flag_init( "emergency_lights_initialized" );
}

hide_fa38_elevator_fxanim_model()
{
	models = getentarray( "black_elevator_debris", "script_string" );
	i = 0;
	while ( i < models.size )
	{
		models[ i ] hide();
		i++;
	}
}

show_fa38_elevator_fxanim_model()
{
	models = getentarray( "black_elevator_debris", "script_string" );
	i = 0;
	while ( i < models.size )
	{
		models[ i ] show();
		i++;
	}
}

menendez_weapons( give_gun_notify )
{
	if ( !isDefined( give_gun_notify ) )
	{
		give_gun_notify = undefined;
	}
	self thread take_and_giveback_weapons( "give_mason_weapons" );
	self.has_menendez_weapons = 1;
	if ( isDefined( give_gun_notify ) )
	{
		level.player waittill( give_gun_notify );
	}
	self giveweapon( "judge_sp" );
	self switchtoweapon( "judge_sp" );
	self allowpickupweapons( 0 );
	self setlowready( 1 );
}

menendez_cleanup()
{
	server_room_exit_door_close();
	_a2635 = level.salutes;
	_k2635 = getFirstArrayKey( _a2635 );
	while ( isDefined( _k2635 ) )
	{
		salute = _a2635[ _k2635 ];
		end_scene( salute.loop );
		_k2635 = getNextArrayKey( _a2635, _k2635 );
	}
	level.salutes = undefined;
}

server_room_exit_door_open()
{
	server_room_exit = get_ent( "server_room_exit", "targetname", 1 );
	if ( !isDefined( server_room_exit.is_open ) )
	{
		server_room_exit.is_open = 0;
	}
	if ( !isDefined( server_room_exit.m_clip ) )
	{
		server_room_exit.m_clip = get_ent( "server_room_exit_clip", "targetname" );
		server_room_exit.m_clip linkto( server_room_exit );
	}
	if ( !server_room_exit.is_open )
	{
		server_room_exit connectpaths();
		server_room_exit movez( -1000, 0,1 );
		server_room_exit.is_open = 1;
		if ( isDefined( server_room_exit.m_clip ) )
		{
			server_room_exit.m_clip connectpaths();
		}
	}
}

server_room_exit_door_close()
{
	server_room_exit = getent( "server_room_exit", "targetname", 1 );
	if ( !isDefined( server_room_exit.is_open ) )
	{
		server_room_exit.is_open = 0;
	}
	if ( !isDefined( server_room_exit.m_clip ) )
	{
		server_room_exit.m_clip = get_ent( "server_room_exit_clip", "targetname" );
		server_room_exit.m_clip linkto( server_room_exit );
	}
	if ( server_room_exit.is_open )
	{
		server_room_exit disconnectpaths();
		server_room_exit movez( 1000, 0,1 );
		server_room_exit.is_open = 0;
		if ( isDefined( server_room_exit.m_clip ) )
		{
			server_room_exit.m_clip disconnectpaths();
		}
	}
}

refill_weapon_clip( weapon_name )
{
	clip_size = weaponclipsize( weapon_name );
	self setweaponammoclip( weapon_name, clip_size );
}

toggle_messiah_mode( mode_on )
{
	if ( mode_on )
	{
		vision_set_menendez();
	}
	else
	{
		vision_set_default();
	}
}

use_trigger_on_group_clear( str_group_name, str_trigger_name )
{
	t_color = getent( str_trigger_name, "targetname" );
	if ( isDefined( t_color ) )
	{
		t_color thread _use_trigger_on_group_clear_think( str_group_name );
	}
}

_use_trigger_on_group_clear_think( str_group_name )
{
	self endon( "trigger" );
	self endon( "death" );
	waittill_ai_group_cleared( str_group_name );
	self notify( "trigger" );
}

use_trigger_on_group_count( str_group_name, str_trigger_name, n_count, b_weaken )
{
	if ( !isDefined( b_weaken ) )
	{
		b_weaken = 0;
	}
	t_color = getent( str_trigger_name, "targetname" );
	if ( isDefined( t_color ) )
	{
		t_color thread _use_trigger_on_group_count_think( str_group_name, n_count, b_weaken );
	}
}

_use_trigger_on_group_count_think( str_group_name, n_count, b_weaken )
{
	self endon( "trigger" );
	self endon( "death" );
	waittill_ai_group_count( str_group_name, n_count );
	if ( b_weaken )
	{
		array_func( get_ai_group_ai( str_group_name ), ::weaken_ai );
	}
	self notify( "trigger" );
}

weaken_ai()
{
	self.health = 1;
	self.attackeraccuracy = 10;
}

player_boat_sim()
{
	wait 1;
	e_ref = spawn_model( "tag_origin", self.origin );
	self playersetgroundreferenceent( e_ref );
	while ( 1 )
	{
		n_time = 8;
		n_angle = randomfloatrange( 1, 1,5 );
		e_ref rotateto( ( n_angle, 0, 0 ), n_time, n_time / 2, n_time / 2 );
		e_ref waittill( "rotatedone" );
		e_ref rotateto( ( n_angle * -1, 0, 0 ), n_time, n_time / 2, n_time / 2 );
		e_ref waittill( "rotatedone" );
	}
}

kill_guys( a_ai, str_targetname )
{
	if ( isDefined( str_targetname ) )
	{
		a_ai = get_ai_array( str_targetname, "targetname" );
	}
	_a2812 = a_ai;
	_k2812 = getFirstArrayKey( _a2812 );
	while ( isDefined( _k2812 ) )
	{
		ai = _a2812[ _k2812 ];
		ai stop_magic_bullet_shield();
		ai die();
		_k2812 = getNextArrayKey( _a2812, _k2812 );
	}
}

cleanup_ents( str_value, str_key )
{
	a_e_ents = getentarray( str_value, str_key );
	array_delete( a_e_ents );
}

delete_if_defined( str_value, str_key )
{
	if ( !isDefined( str_key ) )
	{
		str_key = "targetname";
	}
	e_temp = getent( str_value, str_key );
	if ( isDefined( e_temp ) )
	{
		e_temp delete();
	}
}

clean_up_ent_array( a_to_delete )
{
	i = 0;
	while ( i < a_to_delete.size )
	{
		delete_if_defined( a_to_delete[ i ] );
		wait_network_frame();
		i++;
	}
}

cleanup_structs( str_value, str_key )
{
	a_s_structs = getstructarray( str_value, str_key );
	_a2849 = a_s_structs;
	_k2849 = getFirstArrayKey( _a2849 );
	while ( isDefined( _k2849 ) )
	{
		s_struct = _a2849[ _k2849 ];
		s_struct structdelete();
		_k2849 = getNextArrayKey( _a2849, _k2849 );
	}
}

give_scene_models_guns( str_scene_name )
{
	a_m_guys = get_model_or_models_from_scene( str_scene_name );
	_a2860 = a_m_guys;
	_k2860 = getFirstArrayKey( _a2860 );
	while ( isDefined( _k2860 ) )
	{
		m_guy = _a2860[ _k2860 ];
		m_guy attach( "t6_wpn_ar_xm8_world", "tag_weapon_right" );
		_k2860 = getNextArrayKey( _a2860, _k2860 );
	}
}

run_scene_then_loop( str_scene, str_scene_loop, str_ender )
{
	if ( isDefined( str_ender ) )
	{
		level endon( str_ender );
	}
	run_scene_and_delete( str_scene );
	if ( !isDefined( str_scene_loop ) )
	{
		str_scene_loop = str_scene + "_loop";
	}
	run_scene_and_delete( str_scene_loop );
}

shoot_rpg_from_struct( str_struct )
{
	s_rpg = getstruct( str_struct, "targetname" );
	s_rpg_target = getstruct( s_rpg.target, "targetname" );
	magicbullet( "usrpg_magic_bullet_nodrop_sp", s_rpg.origin, s_rpg_target.origin );
}

data_glove_on_with_light( m_player_body )
{
	m_player_body attach( "c_usa_cia_frnd_viewbody_vson", "J_WristTwist_LE" );
	m_player_body play_fx( "data_glove_glow", undefined, undefined, "data_glove_glow_off", 1, "J_WristTwist_LE" );
}

data_glove_on( m_player_body )
{
	m_player_body attach( "c_usa_cia_frnd_viewbody_vson", "J_WristTwist_LE" );
}

data_glove_off( m_player_body )
{
	m_player_body detach( "c_usa_cia_frnd_viewbody_vson", "J_WristTwist_LE" );
	m_player_body notify( "data_glove_glow_off" );
}

data_glove_bink_on( m_player_body )
{
	m_player_body attach( "c_usa_cia_bink_viewbody_vson", "J_WristTwist_LE" );
	m_player_body.n_bink_id = play_movie_on_surface_async( "blackout_intro_jetwing", 1, 1 );
	m_player_body play_fx( "data_glove_glow", undefined, undefined, "data_glove_glow_off", 1, "J_WristTwist_LE" );
}

data_glove_bink_off( m_player_body )
{
	m_player_body detach( "c_usa_cia_bink_viewbody_vson", "J_WristTwist_LE" );
	stop3dcinematic( m_player_body.n_bink_id );
	m_player_body notify( "data_glove_glow_off" );
}

start_cowbell()
{
	sea_cowbell();
	init_phalanx_cannons( "phalanx_cannon_spot" );
	init_ambient_models();
	init_ambient_vehicles();
	init_ambient_fake_vehicle();
}

stop_cowbell()
{
	kill_ambient_models();
	kill_ambient_vehicles();
	kill_phalanx_cannons( "phalanx_cannon" );
	end_sea_cowbell();
}

init_persist_ambience( n_state, str_start_struct )
{
	m_tanker = spawn_script_model_at_struct( str_start_struct );
	switch( n_state )
	{
		case 1:
			m_tanker thread set_persist_damaged_tanker_state_1();
			level thread set_persist_deck_destruction_state_1();
			break;
		case 2:
			m_tanker thread set_persist_damaged_tanker_state_2();
			level thread set_persist_deck_destruction_state_3();
			break;
		case 3:
			m_tanker thread set_presist_damaged_tanker_state_3();
			break;
		case 4:
			m_tanker set_presist_damaged_tanker_state_4();
			break;
	}
}

set_persist_damaged_tanker_state_1()
{
	self play_fx( "fx_com_distant_ship_exp", self.origin + ( -505,5, -320,5, 852 ), self.angles, "stop_damaged_tanker", 1 );
	flag_wait( "tanker_hit_start" );
	exploder( 10100 );
	exploder( 11001 );
	self rotate_script_model_to_angles( "tanker_hit_react_spot", 1,2, 0, 0,25 );
	self thread set_tanker_idle_yaw( "tanker_hit_react_opposite_spot", "tanker_hit_spot", 4, 5, 1, 1 );
	flag_set( "tanker_hit_done" );
	level waittill( "stop_damaged_tanker" );
	cleanup_structs( "tanker_hit_react_spot", "targetname" );
	cleanup_structs( "tanker_hit_spot", "targetname" );
}

set_persist_damaged_tanker_state_2()
{
	stop_exploder( 10100 );
	self play_fx( "fx_com_distant_ship_exp", self.origin + ( -505,5, -320,5, 852 ), self.angles, "stop_damaged_tanker", 1 );
	flag_wait( "reached_bridge_windows" );
	exploder( 10100 );
	self thread set_tanker_idle_yaw( "tanker_second_state_low_spot", "tanker_hit_react_opposite_spot", 3, 5, 1, 1 );
	flag_wait( "reached_lower_decks" );
	cleanup_structs( "tanker_hit_react_opposite_spot", "targetname" );
	stop_exploder( 10100 );
}

set_presist_damaged_tanker_state_3()
{
	self play_fx( "fx_com_distant_ship_exp", self.origin + ( -505,5, -320,5, 852 ), self.angles, "stop_damaged_tanker", 1 );
	self thread move_script_model_to_position( "tanker_third_state_low_spot", 2, 0, 1 );
	self rotate_script_model_to_angles( "tanker_third_state_low_spot", 2, 0, 1 );
	self thread set_tanker_idle_yaw( "tanker_second_state_low_spot", "tanker_third_state_low_spot", 2, 4, 1, 1 );
	stop_exploder( 1001 );
	exploder( 10101 );
	level waittill( "stop_damaged_tanker" );
	cleanup_structs( "tanker_third_state_low_spot", "targetname" );
}

set_presist_damaged_tanker_state_4()
{
	level endon( "reached_top_elevator" );
	self play_fx( "fx_com_distant_ship_exp", self.origin + ( -505,5, -320,5, 852 ), self.angles, "stop_damaged_tanker", 1 );
	self thread move_script_model_to_position( "tanker_fourth_state_start_spot", 1, 0, 1 );
	self rotate_script_model_to_angles( "tanker_fourth_state_start_spot", 1, 0, 1 );
	stop_exploder( 1001 );
	exploder( 10101 );
	s_tanker_spot = getstruct( "tanker_second_state_low_spot", "targetname" );
	level.player waittill_player_looking_at( s_tanker_spot.origin, 120, 1 );
	self thread move_script_model_to_position( "tanker_fourth_state_last_spot", 15, 15 / 2, 15 / 2 );
	self rotate_script_model_to_angles( "tanker_fourth_state_last_spot", 15, 15 / 2, 15 / 2 );
	self thread set_tanker_idle_yaw( "tanker_fourth_state_yawto_spot", "tanker_fourth_state_last_spot", 3, 4, 1, 1 );
	level waittill( "stop_damaged_tanker" );
	s_tanker_spot delete();
	cleanup_structs( "tanker_fourth_state_start_spot", "targetname" );
	cleanup_structs( "tanker_fourth_state_last_spot", "targetname" );
	cleanup_structs( "tanker_fourth_state_yawto_spot", "targetname" );
}

set_persist_deck_destruction_state_1()
{
	level endon( "bridge_entered" );
	flag_wait( "tanker_hit_done" );
	s_vtol = getstruct( "pyro_vtol_03", "targetname" );
	level.player waittill_player_looking_at( s_vtol.origin );
	level notify( "fxanim_deck_vtol_3_start" );
	s_vtol structdelete();
}

set_persist_deck_destruction_state_2()
{
	level endon( "entered_lower_decks" );
	s_vtol = getstruct( "pyro_vtol_02", "targetname" );
	level.player waittill_player_looking_at( s_vtol.origin );
	level notify( "fxanim_deck_vtol_2_start" );
	s_vtol structdelete();
	flag_set( "saw_left_most_vtol_explode" );
	wait 2;
	level thread set_persist_deck_destruction_state_4();
}

set_persist_deck_destruction_state_3()
{
	s_vtol = getstruct( "pyro_vtol_01", "targetname" );
	level.player waittill_player_looking_at( s_vtol.origin );
	level notify( "fxanim_deck_vtol_1_start" );
	s_vtol structdelete();
	wait 2;
	level thread set_persist_deck_destruction_state_2();
}

set_persist_deck_destruction_state_4()
{
	if ( isDefined( getstruct( "pyro_vtol_04", "targetname" ) ) )
	{
		s_vtol = getstruct( "pyro_vtol_04", "targetname" );
		level.player waittill_player_looking_at( s_vtol.origin );
		level notify( "fxanim_deck_vtol_4_start" );
		s_vtol structdelete();
	}
}

kill_persist_damaged_tanker( str_model )
{
	level notify( "stop_damaged_tanker" );
	m_ship = getent( str_model, "targetname" );
	m_ship delete();
}

init_ambient_models()
{
	a_s_spots = getstructarray( "ambient_ship_spot", "script_noteworthy" );
	_a3144 = a_s_spots;
	_k3144 = getFirstArrayKey( _a3144 );
	while ( isDefined( _k3144 ) )
	{
		s_spot = _a3144[ _k3144 ];
		s_spot thread ambient_model_move_loop( int( s_spot.script_string ) );
		_k3144 = getNextArrayKey( _a3144, _k3144 );
	}
}

init_ambient_oneoff_models( str_start_struct )
{
	a_s_spots = getstructarray( str_start_struct, "script_noteworthy" );
	a_str_fx = array( "fx_com_distant_exp_1", "fx_com_distant_exp_2" );
	_a3165 = a_s_spots;
	_k3165 = getFirstArrayKey( _a3165 );
	while ( isDefined( _k3165 ) )
	{
		s_spot = _a3165[ _k3165 ];
		m_model = spawn_script_model_at_struct( undefined, s_spot );
		if ( m_model.script_noteworthy == "drifting_ambient_ship_spot" )
		{
			v_offset = ( randomintrange( -128, 128 ), randomintrange( -16, 16 ), -4 );
			str_fx = random( a_str_fx );
			m_model play_fx( str_fx, m_model.origin + v_offset, m_model.angles, "kill_ambient_ships", 1 );
		}
		m_model thread ambient_model_move( s_spot, int( s_spot.script_string ) );
		_k3165 = getNextArrayKey( _a3165, _k3165 );
	}
}

kill_ambient_models()
{
	a_m_ships = getentarray( "ambient_ship_spot", "script_noteworthy" );
	a_m_oneoffs = getentarray( "oneoff_ambient_ship_spot", "script_noteworthy" );
	a_m_right_oneoffs = getentarray( "oneoff_starboard_ambient_ship_spot", "script_noteworthy" );
	a_m_models = arraycombine( a_m_ships, a_m_oneoffs, 1, 0 );
	a_m_models = arraycombine( a_m_models, a_m_right_oneoffs, 1, 0 );
	level notify( "kill_ambient_models" );
	array_delete( a_m_models );
}

init_ambient_fake_vehicle()
{
	level notify( "stop_fake_ambient_vehicles" );
	a_structs = get_struct_array( "fake_ambient_vehicle_spline", "script_noteworthy" );
	_a3200 = a_structs;
	_k3200 = getFirstArrayKey( _a3200 );
	while ( isDefined( _k3200 ) )
	{
		struct = _a3200[ _k3200 ];
		struct thread create_fake_vehicle_and_go_path();
		_k3200 = getNextArrayKey( _a3200, _k3200 );
	}
}

create_fake_vehicle_and_go_path()
{
	level endon( "stop_fake_ambient_vehicles" );
	while ( 1 )
	{
		self thread _create_fake_vehicle_and_go_path();
		self waittill( "fake_vehicle_deleted" );
		wait randomfloatrange( 0,5, 1,5 );
	}
}

_create_fake_vehicle_and_go_path()
{
/#
	assert( isDefined( self.speed ), "speed value is missing on fake_ambient_vehicle_spline at " + self.origin );
#/
/#
	assert( isDefined( self.target ), "target value is missing on fake_ambient_vehicle_spline at " + self.origin );
#/
	if ( !isDefined( self.target_struct ) )
	{
		self.target_struct = get_struct( self.target, "targetname" );
	}
	m_temp = self _setup_fake_vehicle_model();
	m_temp.angles = vectorToAngle( self.target_struct.origin - self.origin );
	if ( !isDefined( self.time_to_move ) )
	{
		self.time_to_move = distance( self.target_struct.origin, self.origin ) / ( self.speed * 17,6 );
	}
	m_temp rotateroll( randomfloatrange( -20, 20 ), 1 );
	m_temp moveto( self.target_struct.origin, self.time_to_move );
	m_temp waittill( "movedone" );
	m_temp delete();
	self notify( "fake_vehicle_deleted" );
}

_setup_fake_vehicle_model()
{
/#
	assert( isDefined( self.script_string ), "script_string value is missing on fake_ambient_vehicle_spline at " + self.origin + ". This is used to determine the model of a fake vehicle spawner." );
#/
	m_temp = spawn( "script_model", self.origin );
	m_temp setmodel( self.script_string );
	m_temp setforcenocull();
	switch( self.script_string )
	{
		case "veh_t6_air_fa38":
		case "veh_t6_air_fa38_low":
			playfxontag( level._effect[ "f35_exhaust_fly" ], m_temp, "origin_animate_jnt" );
			m_temp playsoundontag( "evt_fake_flyby", "origin_animate_jnt" );
			break;
		default:
/#
			assertmsg( self.script_string + " is not yet supported by _setup_fake_vehicle_model" );
#/
			break;
	}
	return m_temp;
}

init_ambient_vehicles()
{
	a_vnd_splines = [];
	a_vnd_splines = getvehiclenodearray( "ambient_vehicle_spawner", "script_noteworthy" );
	_a3309 = a_vnd_splines;
	_k3309 = getFirstArrayKey( _a3309 );
	while ( isDefined( _k3309 ) )
	{
		vnd_spline = _a3309[ _k3309 ];
		vnd_spline thread ambient_vehicle_loop();
		wait randomfloatrange( 0,75, 1,23 );
		_k3309 = getNextArrayKey( _a3309, _k3309 );
	}
}

kill_ambient_vehicles()
{
	a_vh_vehicles = get_vehicle_array( "allied_vehicle", "script_noteworthy" );
	level notify( "kill_ambient_vehicles" );
	_a3323 = a_vh_vehicles;
	_k3323 = getFirstArrayKey( _a3323 );
	while ( isDefined( _k3323 ) )
	{
		vh_vehicle = _a3323[ _k3323 ];
		vh_vehicle.delete_on_death = 1;
		vh_vehicle notify( "death" );
		if ( !isalive( vh_vehicle ) )
		{
			vh_vehicle delete();
		}
		_k3323 = getNextArrayKey( _a3323, _k3323 );
	}
}

init_phalanx_cannons( str_cannon_spot )
{
	a_s_cannon = getstructarray( str_cannon_spot, "targetname" );
	level thread phalanx_cannon_target_update();
	_a3336 = a_s_cannon;
	_k3336 = getFirstArrayKey( _a3336 );
	while ( isDefined( _k3336 ) )
	{
		s_cannon = _a3336[ _k3336 ];
		vh_cannon = maps/_vehicle::spawn_vehicle_from_targetname( s_cannon.script_noteworthy );
		vh_cannon.origin = s_cannon.origin;
		vh_cannon.angles = s_cannon.angles;
		vh_cannon.script_string = s_cannon.targetname;
		vh_cannon veh_magic_bullet_shield();
		vh_cannon thread _phalanx_cannon_think( undefined );
		_k3336 = getNextArrayKey( _a3336, _k3336 );
	}
}

disable_phalanx_cannons( str_cannon_name )
{
	a_vh_vehicles = get_vehicle_array( "blackout_minigun_aircraft_spawner", "targetname" );
	_a3353 = a_vh_vehicles;
	_k3353 = getFirstArrayKey( _a3353 );
	while ( isDefined( _k3353 ) )
	{
		vh_vehicle = _a3353[ _k3353 ];
		if ( vh_vehicle.script_string == str_cannon_name )
		{
			vh_vehicle notify( "stop_targeting" );
			vh_vehicle clearturrettarget();
			vh_vehicle setturrettargetvec( vh_vehicle.origin + ( -256, 0, -8 ) );
		}
		_k3353 = getNextArrayKey( _a3353, _k3353 );
	}
}

enable_phalanx_cannons( str_cannon_name, b_hacked )
{
	if ( !isDefined( b_hacked ) )
	{
		b_hacked = 0;
	}
	a_vh_vehicles = get_vehicle_array( "blackout_minigun_aircraft_spawner", "targetname" );
	_a3372 = a_vh_vehicles;
	_k3372 = getFirstArrayKey( _a3372 );
	while ( isDefined( _k3372 ) )
	{
		vh_vehicle = _a3372[ _k3372 ];
		if ( vh_vehicle.script_string == str_cannon_name )
		{
			if ( b_hacked )
			{
				vh_vehicle thread _phalanx_cannon_think_hacked();
				break;
			}
			else
			{
				vh_vehicle thread _phalanx_cannon_think();
			}
		}
		_k3372 = getNextArrayKey( _a3372, _k3372 );
	}
	wait 1;
}

set_phalanx_cannon_default_target_vec()
{
	self clearturrettarget();
	self setturrettargetvec( self.origin + ( -256, 0, 16 ) );
}

phalanx_cannons_override_target( str_cannon_name, str_target, b_notarget )
{
	a_vh_vehicles = get_vehicle_array( "blackout_minigun_aircraft_spawner", "targetname" );
	_a3403 = a_vh_vehicles;
	_k3403 = getFirstArrayKey( _a3403 );
	while ( isDefined( _k3403 ) )
	{
		vh_vehicle = _a3403[ _k3403 ];
		if ( vh_vehicle.script_string == str_cannon_name )
		{
			vh_vehicle notify( "stop_targeting" );
			if ( !isDefined( b_notarget ) || b_notarget == 0 )
			{
				vh_vehicle thread _phalanx_cannon_think( str_target );
			}
		}
		_k3403 = getNextArrayKey( _a3403, _k3403 );
	}
}

kill_phalanx_cannons( str_cannon_spot )
{
	a_vh_vehicles = get_vehicle_array( str_cannon_spot, "script_noteworthy" );
	level notify( "kill_phalanx_cannons" );
	_a3421 = a_vh_vehicles;
	_k3421 = getFirstArrayKey( _a3421 );
	while ( isDefined( _k3421 ) )
	{
		vh_vehicle = _a3421[ _k3421 ];
		vh_vehicle notify( "stop_targeting" );
		vh_vehicle.delete_on_death = 1;
		vh_vehicle notify( "death" );
		if ( !isalive( vh_vehicle ) )
		{
			vh_vehicle delete();
		}
		_k3421 = getNextArrayKey( _a3421, _k3421 );
	}
}

init_ambient_oneoff_vehicles( str_spline_start, b_selfremove )
{
	a_vnd_splines = getvehiclenodearray( str_spline_start, "targetname" );
	_a3432 = a_vnd_splines;
	_k3432 = getFirstArrayKey( _a3432 );
	while ( isDefined( _k3432 ) )
	{
		vnd_spline = _a3432[ _k3432 ];
		vnd_spline thread spawn_ambient_vehicle_and_drive( b_selfremove, 0, vnd_spline.script_noteworthy );
		wait_network_frame();
		_k3432 = getNextArrayKey( _a3432, _k3432 );
	}
}

spawn_ambient_vehicle_and_drive( b_selfremove, b_use_drivepath, str_spawner_name )
{
	level endon( "kill_ambient_vehicles" );
	vh_vehicle = maps/_vehicle::spawn_vehicle_from_targetname( str_spawner_name );
	vh_vehicle setforcenocull();
	if ( isDefined( b_use_drivepath ) && b_use_drivepath )
	{
		vh_vehicle.drivepath = 1;
	}
	vh_vehicle.origin = self.origin;
	vh_vehicle veh_magic_bullet_shield( 1 );
	vh_vehicle maps/_utility::go_path( self );
	if ( !isDefined( b_selfremove ) || b_selfremove == 1 )
	{
		vh_vehicle.delete_on_death = 1;
		vh_vehicle notify( "death" );
		if ( !isalive( vh_vehicle ) )
		{
			vh_vehicle delete();
		}
	}
}

ambient_vehicle_loop()
{
	level endon( "kill_ambient_vehicles" );
	while ( 1 )
	{
		self spawn_ambient_vehicle_and_drive( undefined, 0, self.script_string );
		wait randomfloatrange( 1,2, 4,1 );
	}
}

ambient_model_move_loop( n_movetime )
{
	level endon( "kill_ambient_models" );
	while ( 1 )
	{
		wait randomfloatrange( 0,57, 1,5 );
		m_model = spawn_script_model_at_struct( undefined, self );
		m_model ambient_model_move( self, n_movetime );
		wait randomfloatrange( 0,5, 1,5 );
		m_model delete();
	}
}

ambient_model_move( s_spot, n_movetime )
{
	self rotateto( vectorScale( ( 0, 0, 0 ), 270 ), n_movetime, 0, 0 );
	self move_script_model_to_position( s_spot.target, n_movetime, 0, 1 );
}

set_tanker_idle_yaw( str_port_yaw_spot, str_star_yaw_spot, n_min_intrvl, n_max_intrvl, n_acceltime, n_deceltime )
{
	level endon( "stop_damaged_tanker" );
	while ( 1 )
	{
		self rotate_script_model_to_angles( str_port_yaw_spot, randomfloatrange( n_min_intrvl, n_max_intrvl ), n_acceltime, n_deceltime );
		self rotate_script_model_to_angles( str_star_yaw_spot, randomfloatrange( n_min_intrvl, n_max_intrvl ), n_acceltime, n_deceltime );
	}
}

set_ambient_idle_yaw()
{
	level endon( "kill_ambient_models" );
	while ( 1 )
	{
		self rotate_script_model_to_angles( undefined, randomfloatrange( 2, 4 ), 0,5, 0,5, self.angles + ( randomfloatrange( 32, 54 ), randomfloatrange( 32, 54 ), 0 ) );
		self rotate_script_model_to_angles( undefined, randomfloatrange( 2, 4 ), 0,5, 0,5, self.angles + ( randomfloatrange( -32, 0 ), randomfloatrange( -32, 0 ), 0 ) );
	}
}

spawn_script_model_at_struct( str_start_struct, s_start_spot )
{
	if ( isDefined( str_start_struct ) )
	{
		s_start_spot = getstruct( str_start_struct, "targetname" );
	}
	m_script_model = spawn( "script_model", s_start_spot.origin );
	m_script_model setmodel( s_start_spot.model );
	m_script_model.angles = s_start_spot.angles;
	m_script_model.targetname = s_start_spot.targetname + "_model";
	m_script_model.script_noteworthy = s_start_spot.script_noteworthy;
	m_script_model.target = s_start_spot.target;
	return m_script_model;
}

move_script_model_to_position( str_target_spot, n_movetime, n_acceltime, n_deceltime, v_offset )
{
	s_target_spot = getstruct( str_target_spot, "targetname" );
	v_position = s_target_spot.origin;
	if ( isDefined( v_offset ) )
	{
		v_position += v_offset;
	}
	self moveto( s_target_spot.origin, n_movetime, n_acceltime, n_deceltime );
	self waittill( "movedone" );
}

rotate_script_model_to_angles( str_target_spot, n_movetime, n_acceltime, n_deceltime, v_angles )
{
	if ( isDefined( str_target_spot ) )
	{
		s_target_spot = getstruct( str_target_spot, "targetname" );
		v_angles = s_target_spot.angles;
	}
	self rotateto( v_angles, n_movetime, n_acceltime, n_deceltime );
	self waittill( "rotatedone" );
}

spawn_ambient_drones( trig_name, kill_trig_name, str_targetname, str_targetname_allies, path_start, n_count_axis, n_count_allies, min_interval, max_interval, speed, delay )
{
	if ( !isDefined( speed ) )
	{
		speed = 400;
	}
	if ( !isDefined( delay ) )
	{
		delay = 0;
	}
	level endon( "end_ambient_drones" );
	level endon( "end_ambient_drones_" + path_start );
	if ( isDefined( kill_trig_name ) )
	{
		level thread ambient_drones_kill_trig_watcher( kill_trig_name, path_start );
	}
	trigger_wait( trig_name, "targetname" );
	drones = [];
	vehicles = getvehiclearray();
	total = n_count_axis + n_count_allies;
	while ( ( vehicles.size + total ) > 60 )
	{
		wait 0,05;
		vehicles = getvehiclearray();
	}
	if ( delay > 0 )
	{
		wait delay;
	}
	while ( 1 )
	{
		i = 0;
		while ( i < n_count_axis )
		{
			vh_plane = maps/_vehicle::spawn_vehicle_from_targetname( str_targetname );
			vh_plane setspeedimmediate( speed, 300 );
			vh_plane thread delete_me();
			vh_plane setforcenocull();
			vh_plane thread ambient_drone_die();
			vh_plane pathfixedoffset( ( randomintrange( -1000, 1000 ), randomintrange( -1000, 1000 ), randomintrange( -500, 500 ) ) );
			vh_plane pathvariableoffset( vectorScale( ( 0, 0, 0 ), 500 ), randomfloatrange( 1, 2 ) );
			vh_plane thread go_path( getvehiclenode( path_start, "targetname" ) );
			vh_plane thread play_fake_flyby();
			vh_plane.b_is_ambient = 1;
			drones[ drones.size ] = vh_plane;
			wait 0,25;
			i++;
		}
		i = 0;
		while ( i < n_count_allies )
		{
			vh_plane = maps/_vehicle::spawn_vehicle_from_targetname( str_targetname_allies );
			vh_plane setspeedimmediate( speed, 300 );
			vh_plane.drone_targets = drones;
			vh_plane thread ambient_allies_weapons_think( 101 );
			vh_plane thread delete_me();
			vh_plane setforcenocull();
			vh_plane pathfixedoffset( ( randomintrange( -2000, 0 ), randomintrange( -1000, 1000 ), randomintrange( -500, 500 ) ) );
			vh_plane pathvariableoffset( vectorScale( ( 0, 0, 0 ), 500 ), randomfloatrange( 1, 2 ) );
			vh_plane thread go_path( getvehiclenode( path_start, "targetname" ) );
			vh_plane.b_is_ambient = 1;
			wait 0,1;
			i++;
		}
		wait randomfloatrange( min_interval, max_interval );
	}
}

play_fake_flyby()
{
	wait 0,1;
	sound_ent = spawn( "script_origin", self.origin );
	sound_ent linkto( self, "tag_body" );
	wait randomfloatrange( 1, 3 );
	sound_ent playsound( "evt_fake_flyby" );
	self waittill( "reached_end_node" );
	sound_ent delete();
}

ambient_drones_kill_trig_watcher( trig_name, kill_name )
{
	trigger_wait( trig_name, "targetname" );
	level notify( "end_ambient_drones_" + kill_name );
}

delete_me()
{
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

ambient_drone_die()
{
	self waittill( "death" );
	wait 0,05;
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.delete_on_death ) && isDefined( level._effect[ "fireball_trail_lg" ] ) )
	{
		playfxontag( level._effect[ "fireball_trail_lg" ], self, "tag_origin" );
		playsoundatposition( "evt_pegasus_explo", self.origin );
		wait 5;
		if ( isDefined( self ) )
		{
			self delete();
		}
	}
	else
	{
		wait 30;
		if ( isDefined( self ) )
		{
			self delete();
		}
	}
}

ambient_allies_weapons_think( n_missile_pct )
{
	self endon( "death" );
	while ( 1 )
	{
		target = undefined;
		if ( isDefined( self.drone_targets ) && self.drone_targets.size > 0 )
		{
			target = random( self.drone_targets );
			if ( isDefined( target ) )
			{
				self maps/_turret::set_turret_target( target, ( 0, 0, 0 ), 1 );
				self maps/_turret::set_turret_target( target, ( 0, 0, 0 ), 2 );
				self thread maps/_turret::fire_turret_for_time( randomfloatrange( 3, 5 ), 1 );
				self thread maps/_turret::fire_turret_for_time( randomfloatrange( 3, 5 ), 2 );
				if ( randomint( 100 ) < n_missile_pct )
				{
					self maps/_turret::set_turret_target( target, ( 0, 0, 0 ), 0 );
					self fireweapon( target );
				}
			}
		}
		if ( !isDefined( target ) )
		{
			wait 0,05;
			continue;
		}
		else
		{
			wait randomfloatrange( 4, 6 );
		}
	}
}

magic_bullet_shield_for_time( n_time )
{
	self thread magic_bullet_shield();
	wait n_time;
	self stop_magic_bullet_shield();
}

start_hacking( s_align, str_dir, b_react )
{
	if ( !isDefined( b_react ) )
	{
		b_react = 1;
	}
	self endon( "death" );
	s_align thread anim_generic_loop_aligned( self, "hack_loop_" + str_dir );
	self gun_switchto( self.primaryweapon, "right" );
	self set_allowdeath( 1 );
	if ( b_react )
	{
		wait 0,05;
		level.player waittill_player_looking_at( self.origin + vectorScale( ( 0, 0, 0 ), 72 ) );
		wait randomfloatrange( 0,5, 1,5 );
		s_align thread anim_generic_aligned( self, "hack_react_" + str_dir );
	}
}

emergency_light_init()
{
	a_light_triggers = get_ent_array( "emergency_light_trigger", "targetname", 1 );
	a_light_models = get_ent_array( "fxanim_emergency_light", "targetname", 1 );
/#
	while ( a_light_triggers.size != a_light_models.size )
	{
		if ( a_light_triggers.size < a_light_models.size )
		{
			i = 0;
			while ( i < a_light_models.size )
			{
				b_found_match = 0;
				j = 0;
				while ( j < a_light_triggers.size )
				{
					if ( a_light_models[ i ] istouching( a_light_triggers[ j ] ) )
					{
						b_found_match = 1;
					}
					j++;
				}
				if ( !b_found_match )
				{
					println( "emergency light at " + a_light_models[ i ].origin + " is missing trigger!" );
				}
				i++;
			}
		}
		else i = 0;
		while ( i < a_light_triggers.size )
		{
			b_found_match = 0;
			j = 0;
			while ( j < a_light_models.size )
			{
				if ( a_light_triggers[ i ] istouching( a_light_models[ j ] ) )
				{
					b_found_match = 1;
				}
				j++;
			}
			if ( !b_found_match )
			{
				println( "emergency light trigger at " + a_light_triggers[ i ].origin + " is not using a light!" );
			}
			i++;
#/
		}
	}
	spread_array_thread( a_light_triggers, ::emergency_light_trigger_think, a_light_models );
	flag_set( "emergency_lights_initialized" );
}

emergency_light_trigger_think( a_light_models )
{
	self endon( "death" );
	m_light = undefined;
	n_lights_found = 0;
/#
	assert( isDefined( self.script_string ), "emergency light trigger at " + self.origin + " is missing a script_string identifier" );
#/
	i = 0;
	while ( i < a_light_models.size )
	{
		if ( isDefined( a_light_models[ i ].script_string ) && self.script_string == a_light_models[ i ].script_string )
		{
			m_light = a_light_models[ i ];
			n_lights_found++;
		}
		i++;
	}
/#
	assert( isDefined( m_light ), "emergency_light_trigger_think found no light for trigger at " + self.origin );
#/
/#
	assert( n_lights_found == 1, "emergency_light_trigger_think found " + n_lights_found + " for trigger at " + self.origin + "! There should only be one light per trigger volume" );
#/
	n_lights_found = undefined;
	a_light_models = undefined;
	m_light.trigger = self;
	if ( isDefined( m_light.script_string ) )
	{
		m_light.b_play_cheap_light = m_light.script_string == "intro_hallway_light";
	}
	while ( isDefined( self ) )
	{
		self waittill( "trigger" );
		if ( !isDefined( level.emergency_light_active ) )
		{
			level.emergency_light_active = level.player;
		}
		if ( level.emergency_light_active != m_light )
		{
			level notify( "new_emergency_light_playing" );
			if ( isDefined( level.emergency_light_active.trigger ) )
			{
				level.emergency_light_active notify( "stop_emergency_light" );
				if ( isDefined( level.emergency_light_active.trigger.script_delete ) && level.emergency_light_active.trigger.script_delete )
				{
					level.emergency_light_active.trigger delete();
					maps/_fxanim::fxanim_delete( level.emergency_light_active.script_string );
				}
			}
			level.emergency_light_active = m_light;
			wait_network_frame();
			m_light play_fx( "fx_com_emergency_lights", undefined, undefined, "stop_emergency_light", 1, "tag_light_fx", 1 );
		}
		self thread emergency_light_play_cheap_fx_out_of_range_of_trigger( m_light );
		level waittill( "new_emergency_light_playing" );
	}
}

emergency_light_play_cheap_fx_out_of_range_of_trigger( m_light )
{
	level endon( "new_emergency_light_playing" );
	self endon( "death" );
	b_playing_expensive_light = 1;
	if ( m_light.b_play_cheap_light )
	{
		m_light play_fx( "emergency_light_small", undefined, undefined, "stop_emergency_light", 1, "tag_light_fx", 1 );
		b_playing_expensive_light = 0;
	}
	while ( level.emergency_light_active == m_light )
	{
		b_inside_trigger = level.player istouching( self );
		if ( b_inside_trigger && !b_playing_expensive_light )
		{
			m_light notify( "stop_emergency_light" );
			wait_network_frame();
			m_light play_fx( "fx_com_emergency_lights", undefined, undefined, "stop_emergency_light", 1, "tag_light_fx", 1 );
			b_playing_expensive_light = 1;
		}
		else
		{
			if ( !b_inside_trigger && b_playing_expensive_light )
			{
				m_light notify( "stop_emergency_light" );
				wait_network_frame();
				if ( m_light.b_play_cheap_light )
				{
					m_light play_fx( "emergency_light_small", undefined, undefined, "stop_emergency_light", 1, "tag_light_fx", 1 );
				}
				b_playing_expensive_light = 0;
			}
		}
		if ( b_inside_trigger )
		{
			wait 1;
			continue;
		}
		else
		{
			self waittill( "trigger" );
		}
	}
}

emergency_light_activate( str_script_string )
{
	a_light_triggers = get_ent_array( "emergency_light_trigger", "targetname", 1 );
	_a3983 = a_light_triggers;
	_k3983 = getFirstArrayKey( _a3983 );
	while ( isDefined( _k3983 ) )
	{
		trigger = _a3983[ _k3983 ];
		if ( isDefined( trigger.script_string ) && trigger.script_string == str_script_string )
		{
			trigger notify( "trigger" );
		}
		_k3983 = getNextArrayKey( _a3983, _k3983 );
	}
}

delete_emergency_light( str_script_string )
{
	flag_wait( "emergency_lights_initialized" );
	a_lights = get_ent_array( "fxanim_emergency_light", "targetname" );
	_a3998 = a_lights;
	_k3998 = getFirstArrayKey( _a3998 );
	while ( isDefined( _k3998 ) )
	{
		light = _a3998[ _k3998 ];
		if ( isDefined( light.script_string ) && light.script_string == str_script_string )
		{
			if ( isDefined( light.trigger ) )
			{
				light.trigger delete();
			}
			maps/_fxanim::fxanim_delete( str_script_string );
		}
		_k3998 = getNextArrayKey( _a3998, _k3998 );
	}
}

light_flicker( n_duration )
{
	clientnotify( "hallway_01_flicker" );
	level thread exposure_flicker();
	wait n_duration;
	level notify( "stop_exposure_flicker" );
	blend_exposure_over_time( 2,24, randomfloatrange( 0,05, 0,15 ) );
	clientnotify( "hallway_01_flicker" );
}

light_flicker_fx( n_duration )
{
	level endon( "light_flicker_change" );
	if ( isDefined( level.light_flicker_fx_exploder ) )
	{
		stop_exploder( level.light_flicker_fx_exploder );
		wait 0,1;
		exploder( level.light_flicker_fx_exploder );
		wait 0,1;
		stop_exploder( level.light_flicker_fx_exploder );
		wait 0,1;
		exploder( level.light_flicker_fx_exploder );
	}
}

set_light_flicker_fx_area( exploder )
{
	level notify( "light_flicker_change" );
	if ( isDefined( level.light_flicker_fx_exploder ) )
	{
		stop_exploder( level.light_flicker_fx_exploder );
	}
	level.light_flicker_fx_exploder = exploder;
	if ( isDefined( level.light_flicker_fx_exploder ) )
	{
		exploder( level.light_flicker_fx_exploder );
	}
}

exposure_flicker()
{
	level endon( "stop_exposure_flicker" );
	while ( 1 )
	{
		blend_exposure_over_time( randomfloatrange( 3, 5 ), randomfloatrange( 0,25, 0,5 ) );
		blend_exposure_over_time( 2,24, randomfloatrange( 0,25, 0,5 ) );
	}
}

spawn_drone_v_formation( n_count, str_spline, n_speed )
{
	a_str_vh_names = array( "blackout_avenger_spawner", "blackout_pegasus_spawner" );
	nd_path_start = getvehiclenode( str_spline, "targetname" );
	v_offset = vectorScale( ( 0, 0, 0 ), 1896 );
	i = 0;
	while ( i < n_count )
	{
		a_vh_vehicles = getvehiclearray( "axis", "allies", "neutral" );
		if ( a_vh_vehicles.size < 65 )
		{
			vh_drone = maps/_vehicle::spawn_vehicle_from_targetname( random( a_str_vh_names ) );
			if ( isDefined( n_speed ) )
			{
				vh_drone setspeed( n_speed, n_speed / 2, n_speed / 2 );
			}
			vh_drone maps/_vehicle::getonpath( nd_path_start );
			vh_drone.drivepath = 1;
			v_offset_scale = get_offset_scale( i );
			vh_drone pathfixedoffset( v_offset * v_offset_scale );
			vh_drone thread maps/_vehicle::gopath();
			vh_drone thread drone_cleanup();
		}
		i++;
	}
}

spawn_drone_stack_formation( n_count, str_spline, n_speed )
{
	a_str_vh_names = array( "blackout_avenger_spawner", "blackout_pegasus_spawner" );
	path_start = getvehiclenode( str_spline, "targetname" );
	offset = ( 0, 0, 0 );
	quads = [];
	i = 0;
	while ( i < n_count )
	{
		a_vh_vehicles = getvehiclearray( "axis", "allies", "neutral" );
		if ( a_vh_vehicles.size < 65 )
		{
			quad = maps/_vehicle::spawn_vehicle_from_targetname( random( a_str_vh_names ) );
			quad thread drone_cleanup();
			quads[ quads.size ] = quad;
		}
		i++;
	}
	wait 0,1;
	i = 0;
	_a4135 = quads;
	_k4135 = getFirstArrayKey( _a4135 );
	while ( isDefined( _k4135 ) )
	{
		quad = _a4135[ _k4135 ];
		quad.origin = path_start.origin + offset;
		quad pathmove( path_start, path_start.origin + offset, path_start.angles );
		quad maps/_vehicle::getonpath( path_start );
		quad.drivepath = 1;
		v_offset_scale = get_offset_scale( i );
		quad pathfixedoffset( offset );
		quad thread maps/_vehicle::gopath();
		offset += ( 128, 1024, 1024 );
		i++;
		if ( ( i % 3 ) == 0 )
		{
			offset = ( 0, 0, 0 );
			wait 0,5;
		}
		_k4135 = getNextArrayKey( _a4135, _k4135 );
	}
}

get_offset_scale( i )
{
	if ( ( i % 2 ) == 0 )
	{
		return ( i / 2 ) * -1;
	}
	else
	{
		return ( i - ( i / 2 ) ) + 0,5;
	}
}

drone_cleanup()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

add_posed_corpses( str_script_noteworthy, str_delete_flag )
{
	a_corpses = get_struct_array( str_script_noteworthy, "script_noteworthy" );
	i = 0;
	while ( i < a_corpses.size )
	{
		a_corpses[ i ] thread _setup_corpse_pose_from_struct( str_delete_flag );
		i++;
	}
}

_setup_corpse_pose_from_struct( str_flag )
{
/#
	assert( isDefined( self.script_string ), "corpse pose struct at " + self.origin + " is missing script_string!" );
#/
/#
	assert( isDefined( level.scr_anim[ self.script_string ][ "corpse_pose" ] ), "corpse pose struct with script_string " + self.targetname + " is missing level.scr_anim entry!" );
#/
	m_corpse = spawn( "script_model", self.origin );
	if ( !isDefined( self.angles ) )
	{
		self.angles = ( 0, 0, 0 );
	}
	m_corpse.angles = self.angles;
	m_corpse _make_random_character();
	m_corpse useanimtree( -1 );
	if ( isDefined( self.script_parameters ) && self.script_parameters == "aligned" )
	{
		m_corpse.animname = self.script_string;
		m_corpse animscripted( "corpse_pose", self.origin, self.angles, level.scr_anim[ self.script_string ][ "corpse_pose" ] );
	}
	else
	{
		m_corpse setanim( level.scr_anim[ self.script_string ][ "corpse_pose" ] );
	}
	self structdelete();
	flag_wait( str_flag );
	m_corpse delete();
}

precache_corpse_pose_characters()
{
	character/c_usa_navy_wounded_1::precache();
	character/c_usa_navy_wounded_2::precache();
	character/c_usa_navy_wounded_3::precache();
	character/c_usa_navy_wounded_4::precache();
}

_make_random_character()
{
	if ( !isDefined( level.corpse_character_funcs ) )
	{
		level.corpse_character_funcs = [];
		level.corpse_character_funcs[ level.corpse_character_funcs.size ] = ::character/c_usa_navy_wounded_1::main;
		level.corpse_character_funcs[ level.corpse_character_funcs.size ] = ::character/c_usa_navy_wounded_2::main;
		level.corpse_character_funcs[ level.corpse_character_funcs.size ] = ::character/c_usa_navy_wounded_3::main;
		level.corpse_character_funcs[ level.corpse_character_funcs.size ] = ::character/c_usa_navy_wounded_4::main;
	}
	self [[ level.corpse_character_funcs[ randomint( level.corpse_character_funcs.size ) ] ]]();
}

notetrack_set_blend_times( ent )
{
	ent maps/_anim::anim_set_blend_in_time( 0,2 );
	ent maps/_anim::anim_set_blend_out_time( 0,2 );
}

notetrack_set_blend_times_long( ent )
{
	ent maps/_anim::anim_set_blend_in_time( 0,5 );
	ent maps/_anim::anim_set_blend_out_time( 0,5 );
}

notetrack_set_blend_time_zero( ent )
{
	ent maps/_anim::anim_set_blend_in_time( 0 );
	ent maps/_anim::anim_set_blend_out_time( 0 );
}

notetrack_remove_blend_time( ent )
{
	if ( isDefined( ent ) )
	{
		ent maps/_anim::anim_set_blend_in_time( undefined );
		ent maps/_anim::anim_set_blend_out_time( undefined );
	}
}

disable_grenades()
{
	self.grenadeammo = 0;
}

set_aggressive_cull_radius( n_radius )
{
	level.player setclientdvar( "cg_aggressiveCullRadius", n_radius );
}

set_flag_when_ai_touches_trigger( str_trigger_name, str_flag )
{
	trigger = get_ent( str_trigger_name, "targetname" );
	trigger endon( "delete" );
	while ( 1 )
	{
		trigger waittill( "trigger", ai_guy );
		while ( is_alive( ai_guy ) && ai_guy istouching( trigger ) )
		{
			flag_set( str_flag );
			wait 0,5;
		}
		flag_clear( str_flag );
	}
}

func_on_ai_group_cleared( str_ai_group_name, func_after_cleared )
{
	waittill_ai_group_cleared( str_ai_group_name );
	self [[ func_after_cleared ]]();
}

set_flag_on_ai_group_count( str_ai_group_name, n_count, str_flag )
{
	waittill_ai_group_ai_count( str_ai_group_name, n_count );
	flag_set( str_flag );
}

set_flag_on_ai_group_clear( str_flag, str_ai_group_name, str_ai_group_name_2 )
{
	waittill_ai_group_cleared( str_ai_group_name );
	if ( isDefined( str_ai_group_name_2 ) )
	{
		waittill_ai_group_cleared( str_ai_group_name_2 );
	}
	flag_set( str_flag );
}

deck_turn_off_cells()
{
	a_structs = getstructarray( "deck_cell_struct", "targetname" );
	i = 0;
	while ( i < a_structs.size )
	{
		setcellinvisibleatpos( a_structs[ i ].origin );
		i++;
	}
}

start_combat_vo_group_friendly( a_chatter_generic, str_endon_flag, a_chatter_conditional, str_conditional_flag )
{
/#
	assert( isDefined( str_endon_flag ), "str_endon_flag is a required parameter for start_combat_vo_group_friendly!" );
#/
/#
	if ( isDefined( a_chatter_generic ) )
	{
		assert( a_chatter_generic.size > 0, "a_chatter_generic is missing lines!" );
	}
#/
	if ( !isDefined( a_chatter_conditional ) )
	{
		a_chatter_conditional = [];
	}
	a_chatter_generic_temp = array_copy( a_chatter_generic );
	a_chatter_conditional_temp = array_copy( a_chatter_conditional );
	while ( a_chatter_generic_temp.size > 0 && !flag( str_endon_flag ) )
	{
		if ( isDefined( str_conditional_flag ) && !flag( str_conditional_flag ) && a_chatter_conditional_temp.size > 0 )
		{
			str_line = random( a_chatter_conditional_temp );
			arrayremovevalue( a_chatter_conditional_temp, str_line );
		}
		else
		{
			str_line = random( a_chatter_generic_temp );
			arrayremovevalue( a_chatter_generic_temp, str_line );
		}
		maps/_dialog::queue_dialog_ally( str_line, 0, undefined, undefined, 0 );
		wait randomfloatrange( 5, 12 );
	}
	if ( !flag( str_endon_flag ) )
	{
		level thread start_combat_vo_group_friendly( a_chatter_generic, str_endon_flag, a_chatter_conditional, str_conditional_flag );
	}
	else
	{
		_kill_all_queued_dialog( "allies" );
	}
}

start_combat_vo_group_enemy( a_chatter_generic, str_endon_flag, a_chatter_conditional, str_conditional_flag )
{
/#
	assert( isDefined( str_endon_flag ), "str_endon_flag is a required parameter for start_combat_vo_group_enemy!" );
#/
/#
	if ( isDefined( a_chatter_generic ) )
	{
		assert( a_chatter_generic.size > 0, "a_chatter_generic is missing lines!" );
	}
#/
	if ( !isDefined( a_chatter_conditional ) )
	{
		a_chatter_conditional = [];
	}
	a_chatter_generic_temp = array_copy( a_chatter_generic );
	a_chatter_conditional_temp = array_copy( a_chatter_conditional );
	while ( a_chatter_generic_temp.size > 0 && !flag( str_endon_flag ) )
	{
		if ( isDefined( str_conditional_flag ) && !flag( str_conditional_flag ) && a_chatter_conditional_temp.size > 0 )
		{
			str_line = random( a_chatter_conditional_temp );
			arrayremovevalue( a_chatter_conditional_temp, str_line );
		}
		else
		{
			str_line = random( a_chatter_generic_temp );
			arrayremovevalue( a_chatter_generic_temp, str_line );
		}
		maps/_dialog::queue_dialog_enemy( str_line, 0, undefined, undefined, 0 );
		wait randomfloatrange( 5, 12 );
	}
	if ( !flag( str_endon_flag ) )
	{
		level thread start_combat_vo_group_enemy( a_chatter_generic, str_endon_flag, a_chatter_conditional, str_conditional_flag );
	}
	else
	{
		_kill_all_queued_dialog( "axis" );
	}
}

_kill_all_queued_dialog( str_faction )
{
	a_guys = getaiarray( str_faction );
	i = 0;
	while ( i < a_guys.size )
	{
		if ( !a_guys[ i ] is_hero() )
		{
			kill_all_pending_dialog( a_guys[ i ] );
		}
		i++;
	}
}

rush_when_grouped( n_group_radius )
{
	if ( !isDefined( n_group_radius ) )
	{
		n_group_radius = 128;
	}
	self endon( "death" );
	self waittill( "goal" );
	while ( 1 )
	{
		wait randomfloatrange( 4, 6 );
		a_guys_close = get_within_range( self.origin, getaiarray( "axis" ), n_group_radius );
		arrayremovevalue( a_guys_close, self );
		a_valid_guys = undefined;
		a_valid_guys = [];
		while ( a_guys_close.size > 0 )
		{
			i = 0;
			while ( i < a_guys_close.size )
			{
				if ( isDefined( a_guys_close[ i ].rusher ) && !a_guys_close[ i ].rusher && isDefined( a_guys_close[ i ].holding_position ) && !a_guys_close[ i ].holding_position )
				{
					a_valid_guys[ a_valid_guys.size ] = a_guys_close[ i ];
				}
				i++;
			}
		}
		if ( a_valid_guys.size > 0 )
		{
			ai_closest = arraysort( a_valid_guys, self.origin, 1 )[ 0 ];
			ai_closest thread maps/_rusher::rush( undefined, 5 );
			self.holding_position = 1;
		}
	}
}

use_trigger_on_flag( str_trigger, str_flag )
{
	flag_wait( str_flag );
	t_use = get_ent( str_trigger, "targetname" );
	if ( isDefined( t_use ) )
	{
		t_use notify( "trigger" );
	}
}

player_invulnerable_for_time( n_time, str_ender )
{
	level.player enableinvulnerability();
	wait n_time;
	level.player disableinvulnerability();
}

set_force_no_cull_on_actors_during_scene( str_scene, str_flag_override )
{
	flag_wait( str_scene + "_started" );
	a_ents = arraycombine( get_ais_from_scene( str_scene ), get_model_or_models_from_scene( str_scene ), 1, 0 );
	_a4522 = a_ents;
	_k4522 = getFirstArrayKey( _a4522 );
	while ( isDefined( _k4522 ) )
	{
		ent = _a4522[ _k4522 ];
		ent setforcenocull();
		_k4522 = getNextArrayKey( _a4522, _k4522 );
	}
	if ( !isDefined( str_flag_override ) )
	{
		scene_wait( str_scene );
	}
	else
	{
		flag_wait( str_flag_override );
	}
	_a4537 = a_ents;
	_k4537 = getFirstArrayKey( _a4537 );
	while ( isDefined( _k4537 ) )
	{
		ent = _a4537[ _k4537 ];
		if ( isDefined( ent ) )
		{
			ent removeforcenocull();
		}
		_k4537 = getNextArrayKey( _a4537, _k4537 );
	}
}

remove_blend_times_for_scene( str_scene, str_flag_override )
{
	flag_wait( str_scene + "_started" );
	a_ents = arraycombine( get_ais_from_scene( str_scene ), get_model_or_models_from_scene( str_scene ), 1, 0 );
	_a4553 = a_ents;
	_k4553 = getFirstArrayKey( _a4553 );
	while ( isDefined( _k4553 ) )
	{
		ent = _a4553[ _k4553 ];
		notetrack_set_blend_time_zero( ent );
		_k4553 = getNextArrayKey( _a4553, _k4553 );
	}
	if ( !isDefined( str_flag_override ) )
	{
		scene_wait( str_scene );
	}
	else
	{
		flag_wait( str_flag_override );
	}
	_a4567 = a_ents;
	_k4567 = getFirstArrayKey( _a4567 );
	while ( isDefined( _k4567 ) )
	{
		ent = _a4567[ _k4567 ];
		if ( isDefined( ent ) )
		{
			ent notetrack_remove_blend_time();
		}
		_k4567 = getNextArrayKey( _a4567, _k4567 );
	}
}

set_blend_times_for_scene( str_scene, str_flag_override )
{
	flag_wait( str_scene + "_started" );
	a_ents = arraycombine( get_ais_from_scene( str_scene ), get_model_or_models_from_scene( str_scene ), 1, 0 );
	_a4582 = a_ents;
	_k4582 = getFirstArrayKey( _a4582 );
	while ( isDefined( _k4582 ) )
	{
		ent = _a4582[ _k4582 ];
		notetrack_set_blend_times( ent );
		_k4582 = getNextArrayKey( _a4582, _k4582 );
	}
	if ( !isDefined( str_flag_override ) )
	{
		scene_wait( str_scene );
	}
	else
	{
		flag_wait( str_flag_override );
	}
	_a4596 = a_ents;
	_k4596 = getFirstArrayKey( _a4596 );
	while ( isDefined( _k4596 ) )
	{
		ent = _a4596[ _k4596 ];
		if ( isDefined( ent ) )
		{
			ent notetrack_remove_blend_time();
		}
		_k4596 = getNextArrayKey( _a4596, _k4596 );
	}
}

set_force_no_cull( ent )
{
	ent setforcenocull();
}

callback_player_damage_only( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename )
{
	if ( !isDefined( eattacker ) || !isplayer( eattacker ) )
	{
		idamage = 0;
	}
	return idamage;
}

remove_launchers_on_easy_difficulty()
{
	self endon( "death" );
	while ( self.targetname != "pmc_launcher_guy" )
	{
		str_launcher = self.primaryweapon;
		str_secondary = self.secondaryweapon;
		while ( 1 )
		{
			if ( getdifficulty() == "easy" )
			{
				self custom_ai_weapon_loadout( str_secondary, undefined, self.sidearm );
			}
			else
			{
				self custom_ai_weapon_loadout( str_launcher, str_secondary, self.sidearm );
			}
			level waittill( "difficulty_change" );
		}
	}
}

level_has_callback( str_event, func )
{
	b_has_callback_already = 0;
	i = 0;
	while ( i < level._callbacks[ str_event ].size )
	{
		if ( level._callbacks[ str_event ][ i ] == func )
		{
			b_has_callback_already = 1;
		}
		i++;
	}
	return b_has_callback_already;
}

save_restored_callback()
{
	if ( checkpoint_respawn_safe_spot_exists() )
	{
		move_player_to_safe_checkpoint_spot();
	}
	if ( isDefined( level.player_is_menendez ) && level.player_is_menendez )
	{
		wait 1;
		luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"menendez_no_hud" );
	}
}

checkpoint_respawn_safe_spot_exists()
{
	return isDefined( level.checkpoint_restart_safe_spot );
}

checkpoint_respawn_safe_spot_set( str_struct_targetname )
{
	level.checkpoint_restart_safe_spot = get_struct( str_struct_targetname, "targetname" );
}

checkpoint_respawn_safe_spot_clear()
{
	level.checkpoint_restart_safe_spot = undefined;
}

move_player_to_safe_checkpoint_spot()
{
	s_temp = level.checkpoint_restart_safe_spot;
	if ( isDefined( s_temp ) )
	{
		level.player setorigin( s_temp.origin );
		level.player setplayerangles( s_temp.angles );
	}
}

kill_all_living_enemies()
{
	a_axis = getaiarray( "axis" );
	_a4707 = a_axis;
	_k4707 = getFirstArrayKey( _a4707 );
	while ( isDefined( _k4707 ) )
	{
		guy = _a4707[ _k4707 ];
		guy delay_thread( randomfloatrange( 0,5, 3 ), ::bloody_death );
		_k4707 = getNextArrayKey( _a4707, _k4707 );
	}
}
