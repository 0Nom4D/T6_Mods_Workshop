#include maps/afghanistan_wave_3;
#include maps/afghanistan_bp2;
#include maps/afghanistan_amb;
#include maps/afghanistan_base_threats;
#include maps/afghanistan_anim;
#include maps/createart/afghanistan_art;
#include maps/_horse_rider;
#include maps/afghanistan_arena_manager;
#include maps/_rusher;
#include maps/_music;
#include maps/_dialog;
#include maps/_vehicle_aianim;
#include maps/_turret;
#include maps/_horse;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "vehicles" );

init_flags()
{
	flag_init( "zhao_at_bp2" );
	flag_init( "woods_at_bp2" );
	flag_init( "dropoff1_complete" );
	flag_init( "dropoff2_complete" );
	flag_init( "dropoff3_complete" );
	flag_init( "dropoff4_complete" );
	flag_init( "spawn_vehicles" );
	flag_init( "spawn_boss_bp2" );
	flag_init( "wave2bp2_hind" );
	flag_init( "wave2bp2_tank" );
	flag_init( "attack_cache_bp2" );
	flag_init( "cache_destroyed_bp2" );
	flag_init( "muj_charge" );
	flag_init( "horse_at_bp2hitch" );
	flag_init( "bp2_exit" );
	flag_init( "left_bp2" );
	flag_init( "mig_bombrun" );
	flag_init( "bp2_horseriders_done" );
	flag_init( "mortars_start" );
	flag_init( "mortar_first" );
	flag_init( "mortar1_destroyed" );
	flag_init( "mortar2_destroyed" );
	flag_init( "mortars_done" );
	flag_init( "bp2_vehicles_done" );
	flag_init( "mortar_victims" );
	flag_init( "arch_destroyed" );
	flag_init( "player_onhorse_bp2exit" );
	flag_init( "btr_chase_spawned" );
	flag_init( "zhao_at_bp3" );
	flag_init( "woods_at_bp3" );
	flag_init( "shoot_rider" );
	flag_init( "rpg_fired" );
	flag_init( "uaz_guys_dead" );
	flag_init( "bridges_obj" );
	flag_init( "bridge3_obj" );
	flag_init( "bridge4_obj" );
	flag_init( "attack_cache_bp3" );
	flag_init( "bp3_spawn_vehicles" );
	flag_init( "spawn_boss_bp3" );
	flag_init( "spawn_hip1_bp3" );
	flag_init( "spawn_hip2_bp3" );
	flag_init( "spawn_btr1_bp3" );
	flag_init( "spawn_btr2_bp3" );
	flag_init( "cache_destroyed_bp3" );
	flag_init( "bp3_exit" );
	flag_init( "wave2bp3_tank" );
	flag_init( "wave2bp3_hind" );
	flag_init( "bridge3_destroyed" );
	flag_init( "bridge4_destroyed" );
	flag_init( "muj_retreat" );
	flag_init( "bp3_hip_arrival" );
	flag_init( "hind1_pass" );
	flag_init( "btr1_entry" );
	flag_init( "btr2_entry" );
	flag_init( "btr1_stop_sprint" );
	flag_init( "btr2_stop_sprint" );
	flag_init( "player_onhorse_bp3exit" );
	flag_init( "wave2_started" );
	flag_init( "wave2_done" );
	flag_init( "goto_bp3" );
	flag_init( "switched_to_afghanstinger_ff_sp" );
	flag_init( "player_killed_btr" );
	flag_init( "heli_spawned" );
	flag_init( "base_successfully_defended" );
	flag_init( "bp2_exit_done" );
	flag_init( "truck_dead" );
}

skipto_wave2()
{
	skipto_setup();
	init_hero( "zhao" );
	init_hero( "woods" );
	level.player giveweapon( "pulwar_sword_sp" );
	level thread maps/_horse::set_horse_in_combat( 1 );
	level.zhao = getent( "zhao_ai", "targetname" );
	level.woods = getent( "woods_ai", "targetname" );
	remove_woods_facemask_util();
	level.zhao setcandamage( 0 );
	level.woods setcandamage( 0 );
	a_weapons = level.player getweaponslist();
	i = 0;
	while ( i < a_weapons.size )
	{
		str_class = weaponclass( a_weapons[ i ] );
		if ( str_class == "pistol" )
		{
			level.player takeweapon( a_weapons[ i ] );
		}
		i++;
	}
	level.player giveweapon( "rpg_player_sp" );
	level.player givemaxammo( "rpg_player_sp" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		skipto_teleport( "skipto_wave2bp2", level.heroes );
		wait 0,1;
		s_player_horse_spawnpt = getstruct( "wave2bp2_player_horse_spawnpt", "targetname" );
		s_zhao_horse_spawnpt = getstruct( "wave2bp2_zhao_horse_spawnpt", "targetname" );
		s_woods_horse_spawnpt = getstruct( "wave2bp2_woods_horse_spawnpt", "targetname" );
	}
	else
	{
		skipto_teleport( "skipto_wave2", level.heroes );
		wait 0,1;
		s_player_horse_spawnpt = getstruct( "wave2bp3_player_horse_spawnpt", "targetname" );
		s_zhao_horse_spawnpt = getstruct( "wave2bp3_zhao_horse_spawnpt", "targetname" );
		s_woods_horse_spawnpt = getstruct( "wave2bp3_woods_horse_spawnpt", "targetname" );
	}
	level clientnotify( "dbw2" );
	level.zhao_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.zhao_horse.origin = s_zhao_horse_spawnpt.origin;
	level.zhao_horse.angles = s_zhao_horse_spawnpt.angles;
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.woods_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods_horse.origin = s_woods_horse_spawnpt.origin;
	level.woods_horse.angles = s_woods_horse_spawnpt.angles;
	level.woods_horse veh_magic_bullet_shield( 1 );
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_player_horse_spawnpt.origin;
	level.mason_horse.angles = s_player_horse_spawnpt.angles;
	level.mason_horse veh_magic_bullet_shield( 1 );
	level.mason_horse makevehicleusable();
	level.zhao_horse makevehicleunusable();
	level.woods_horse makevehicleunusable();
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.woods_horse veh_magic_bullet_shield( 1 );
	level.zhao enter_vehicle( level.zhao_horse );
	level.woods enter_vehicle( level.woods_horse );
	wait 0,1;
	level.zhao_horse thread zhao_bp2_skipto();
	level.woods_horse thread woods_bp2_skipto();
	flag_wait( "afghanistan_gump_arena" );
	struct_cleanup_wave1();
	delete_section1_scenes();
	delete_section1_ride_scenes();
	delete_section_2_scenes();
	level thread maps/afghanistan_arena_manager::arena_drones();
	exploder( 300 );
}

bp3_approach_explosions()
{
	level endon( "shoot_rider" );
	a_structs = getstructarray( "bp3_approach_explosion", "targetname" );
	a_s_explosions = array_randomize( a_structs );
	while ( 1 )
	{
		_a233 = a_s_explosions;
		_k233 = getFirstArrayKey( _a233 );
		while ( isDefined( _k233 ) )
		{
			s_exp = _a233[ _k233 ];
			playfx( level._effect[ "explode_mortar_sand" ], s_exp.origin );
			playsoundatposition( "exp_mortar", s_exp.origin );
			if ( distance2dsquared( level.player.origin, s_exp.origin ) > 9000000 )
			{
				n_scale = 0,1;
			}
			else if ( distance2dsquared( level.player.origin, s_exp.origin ) > 4000000 )
			{
				n_scale = 0,2;
			}
			else if ( distance2dsquared( level.player.origin, s_exp.origin ) > 1000000 )
			{
				n_scale = 0,4;
			}
			else
			{
				n_scale = 0,5;
			}
			earthquake( n_scale, 2,5, level.player.origin, 4000 );
			wait randomfloatrange( 1,5, 2 );
			_k233 = getNextArrayKey( _a233, _k233 );
		}
		wait 0,1;
	}
}

zhao_bp2_skipto()
{
	level.zhao.vh_horse = level.zhao_horse;
	self setvehicleavoidance( 1 );
	self setcandamage( 0 );
	self notify( "groupedanimevent" );
	level.zhao maps/_horse_rider::ride_and_shoot( self );
	level.mason_horse waittill( "enter_vehicle", player );
	s_zhao_wave2 = getstruct( "zhao_bp3", "targetname" );
	s_zhao_wave2_approach = getstruct( "bp3_entrance", "targetname" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		s_zhao_wave2 = getstruct( "zhao_bp2", "targetname" );
	}
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_zhao_wave2.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_set( "zhao_at_bp2" );
	}
	else
	{
		flag_set( "zhao_at_bp3" );
	}
}

woods_bp2_skipto()
{
	level.woods.vh_horse = level.woods_horse;
	self setvehicleavoidance( 1 );
	self setcandamage( 0 );
	self notify( "groupedanimevent" );
	level.woods maps/_horse_rider::ride_and_shoot( self );
	level.mason_horse waittill( "enter_vehicle", player );
}

main()
{
/#
	iprintln( "Wave 2" );
#/
	maps/createart/afghanistan_art::open_area();
	struct_cleanup_wave1();
	if ( level.skipto_point == "wave_2" )
	{
		maps/afghanistan_anim::init_afghan_anims_part1b();
		delete_section1_scenes();
		delete_section3_scenes();
	}
	level clientnotify( "dbw2" );
	level notify( level.ammo_cache_waittill_notify );
	level.player setclientdvar( "cg_objectiveIndicatorFarFadeDist", 80000 );
	level thread enable_base_spawn_managers();
	level.player thread maps/afghanistan_arena_manager::woods_toggle_follow_behavior();
	level.mason_horse thread maps/afghanistan_arena_manager::horse_toggle_follow_behavior();
	level.player thread vehicle_whizby_or_close_impact();
	level.player thread maps/afghanistan_base_threats::ammo_show_caches_when_ooa();
	level.player thread maps/afghanistan_base_threats::weapon_show_caches_when_need_launcher();
	level.player thread cheat_reload_stinger_when_not_primary_and_on_horse();
	level thread maps/afghanistan_arena_manager::respawn_arena();
	level thread stock_weapon_caches();
	level thread maps/afghanistan_base_threats::base_attack_manager();
	level thread maps/afghanistan_amb::start_music_manager();
	level thread maps/afghanistan_bp2::start_bp2();
	level thread maps/afghanistan_bp2::start_bp3();
	level thread close_base_gate();
	flag_wait( "base_successfully_defended" );
	spawn_manager_kill( "sm_muj_wall_1" );
	spawn_manager_kill( "sm_muj_wall_2" );
	spawn_manager_kill( "sm_muj_wall_3" );
	spawn_manager_kill( "sm_muj_wall_4" );
	get_player_back_to_base();
}

get_player_back_to_base()
{
	level thread vo_hudson_call_back_to_base();
	level thread open_base_gate( 1 );
	level thread back_to_base_objective();
	level.woods_horse thread send_hero_back_to_base( level.woods, "struct_woods_final_pos" );
	level.zhao_horse thread send_hero_back_to_base( level.zhao, "struct_zhao_final_pos" );
	level thread spawn_guys_at_base_entrance();
	trigger_wait( "trig_base_fade" );
	set_objective( level.obj_return_base, undefined, "done" );
	set_objective( level.obj_return_base, undefined, "delete" );
}

spawn_guys_at_base_entrance()
{
	a_s_horse_spawnpts = [];
	i = 0;
	while ( i < 6 )
	{
		a_s_horse_spawnpts[ i ] = getstruct( "muj_horse_charge_spawnpt" + i, "targetname" );
		i++;
	}
	level.a_vh_horses = [];
	i = 0;
	while ( i < a_s_horse_spawnpts.size )
	{
		wait 0,05;
		level.a_vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_horses[ i ].origin = a_s_horse_spawnpts[ i ].origin;
		level.a_vh_horses[ i ].angles = a_s_horse_spawnpts[ i ].angles;
		level.a_vh_horses[ i ] makevehicleunusable();
		level.a_vh_horses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_horses[ i ].ai_rider ) )
		{
			level.a_vh_horses[ i ].ai_rider ai_horse_ride( level.a_vh_horses[ i ] );
		}
		level.a_vh_horses[ i ] thread go_path( getvehiclenode( "horse_path_" + i, "targetname" ) );
		level.a_vh_horses[ i ] setspeedimmediate( 0 );
		i++;
	}
}

send_hero_back_to_base( e_hero, str_struct_goal_name )
{
	self setvehicleavoidance( 0 );
	e_hero disable_ai_color( 1 );
	s_goal = get_struct( str_struct_goal_name, "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		e_hero ai_mount_horse( self );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_goal.origin, 0, 2 );
	self waittill_any( "goal", "near_goal" );
	self setvehicleavoidance( 1, 2 );
	self horse_stop();
}

back_to_base_objective()
{
	if ( !level.player is_on_horseback() && level.player_location == "bp3" )
	{
		set_objective( level.obj_return_base, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
		level.mason_horse waittill( "enter_vehicle", player );
	}
	s_defend = getstruct( "base_defend_pos", "targetname" );
	set_objective( level.obj_return_base, s_defend );
	objective_setflag( level.obj_return_base, "fadeoutonscreen", 0 );
}

vo_hudson_call_back_to_base()
{
	level.woods say_dialog( "huds_mason_return_to_th_0" );
	level.player say_dialog( "maso_what_kind_of_problem_0", 1 );
	level.woods say_dialog( "huds_you_d_better_see_it_0", 2,5 );
}

stinger_hint()
{
	while ( 1 )
	{
		if ( level.player getcurrentweapon() == "afghanstinger_sp" )
		{
			flag_wait( "heli_spawned" );
			screen_message_create( &"AFGHANISTAN_STINGER_HINT" );
			while ( 1 )
			{
				if ( level.player getcurrentweapon() == "afghanstinger_ff_sp" )
				{
					flag_set( "switched_to_afghanstinger_ff_sp" );
					break;
				}
				else if ( level.player getcurrentweapon() != "afghanstinger_sp" )
				{
					break;
				}
				else
				{
					wait 1;
				}
			}
			screen_message_delete();
			if ( flag( "switched_to_afghanstinger_ff_sp" ) )
			{
				break;
			}
		}
		else
		{
			wait 0,1;
		}
	}
	screen_message_delete();
}

stinger_ff_hint()
{
	n_msg_time = 0;
	while ( 1 )
	{
		if ( level.player getcurrentweapon() == "afghanstinger_ff_sp" )
		{
			screen_message_create( &"AFGHANISTAN_STINGER_FF_HINT" );
			while ( 1 )
			{
				wait 1;
				n_msg_time++;
				if ( n_msg_time == 6 )
				{
					break;
				}
				else
				{
				}
			}
		}
		else wait 0,1;
	}
	screen_message_delete();
}

wave2_bp2_main()
{
	init_spawn_funcs_wave2_bp2();
	wave2_bp2();
}

init_spawn_funcs_wave2_bp2()
{
	add_spawn_function_group( "bp2_soviet", "targetname", ::bp2_soviet_logic );
	add_spawn_function_group( "bp2_soviet_rpg", "targetname", ::bp2_soviet_logic );
	add_spawn_function_group( "muj_reinforce_bp2", "targetname", ::reinforce_bp2_logic );
	add_spawn_function_group( "bp2_exit_muj", "targetname", ::bp2_exit_muj_logic );
	add_spawn_function_group( "bp2_exit_soviet", "targetname", ::delete_bp2_exit_battle );
}

wave2_bp2()
{
	level.n_bp2_veh_destroyed = 0;
	level.n_bp2_mortar_destroyed = 0;
	level.b_mortar_vo = 0;
	if ( level.wave2_loc == "blocking point 2" )
	{
		level.zhao_horse thread zhao_bp2();
		level.woods_horse thread woods_bp2();
		level.mason_horse thread mason_bp2();
		level thread vo_intro_bp2();
	}
	level thread mortar_victim_left();
	level thread mortar_victim_right();
	level thread mortar_victim_bp3_bp2();
	trigger_wait( "spawn_wave2_bp2" );
	flag_set( "bp_underway" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_set( "wave2_started" );
	}
	else
	{
		flag_set( "player_at_bp2wave3" );
		wait 0,1;
		flag_set( "wave3_started" );
		wait 0,5;
		level.zhao_horse thread zhao_bp2();
		level.woods_horse thread woods_bp2();
		level.mason_horse thread mason_bp2();
		set_objective( level.obj_follow_bp3, level.zhao, "remove" );
	}
	flag_set( "stop_arena_explosions" );
	autosave_by_name( "wave2bp2_start" );
	level thread objectives_bp2();
	level thread monitor_bp2_enemies();
	level thread muj_horse_lineup();
	level thread bp2_replenish_arena();
	level thread vo_bp2();
	level thread bp2_mig_bombers();
	level thread bp2_backup_horse();
	level thread triggercolor_bp2();
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_wait( "wave2_done" );
	}
	else
	{
		flag_wait( "bp2wave3_done" );
	}
	flag_clear( "bp_underway" );
}

objectives_bp2_cache()
{
	s_stinger = getstruct( "stinger_bp2_pos1", "targetname" );
	wait 0,1;
	if ( !player_has_stinger() )
	{
		set_objective( level.obj_afghan_bp2, s_stinger, "use" );
		while ( !player_has_stinger() )
		{
			wait 0,1;
		}
		set_objective( level.obj_afghan_bp2, s_stinger, "remove" );
	}
	else
	{
		set_objective( level.obj_afghan_bp2, s_stinger, "breadcrumb" );
		flag_wait( "mortars_start" );
		set_objective( level.obj_afghan_bp2, s_stinger, "remove" );
	}
}

objectives_bp2()
{
	trigger_wait( "spawn_wave2_bp2" );
	level thread objectives_bp2_cache();
	flag_wait( "mortars_start" );
	set_objective( level.obj_bp2_mortar, undefined, undefined, level.n_bp2_mortar_destroyed );
	m_mortar1 = getent( "bp2_mortar1_emplacement", "targetname" );
	m_mortar2 = getent( "bp2_mortar2_emplacement", "targetname" );
	s_mortar1_obj = getstruct( "bp2_mortar1_obj", "targetname" );
	s_mortar2_obj = getstruct( "bp2_mortar2_obj", "targetname" );
	m_mortar1 setcandamage( 1 );
	m_mortar2 setcandamage( 1 );
	m_mortar1 thread mortar_destroyed( s_mortar1_obj );
	m_mortar2 thread mortar_destroyed( s_mortar2_obj );
	level thread vo_mortars();
	flag_wait( "spawn_vehicles" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		set_objective( level.obj_afghan_bp2wave2_vehicles, undefined, undefined, level.n_bp2_veh_destroyed );
		level thread bp2_vehicle_chooser();
	}
	else
	{
		set_objective( level.obj_afghan_bp2wave3_vehicles, undefined, undefined, level.n_bp2_veh_destroyed );
		wait 1;
		level thread bp2wave2_spawn_boss();
	}
	flag_wait_all( "mortars_done", "bp2_vehicles_done" );
	autosave_by_name( "bp2_vehicles_done" );
	level thread delete_bp2_vehicles_objectives();
	set_objective( level.obj_afghan_bp2, undefined, "done" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_set( "wave2_done" );
		level thread spawn_backup_cache_horse( getstruct( "cache1_horse_spawnpt", "targetname" ), "wave3_started" );
		level thread bp2_exit_battle();
		set_objective( level.obj_afghan_bp2wave2_vehicles, undefined, "delete" );
	}
	else
	{
		flag_set( "bp2wave3_done" );
		set_objective( level.obj_afghan_bp2wave3_vehicles, undefined, "delete" );
	}
	level.mason_horse thread waittill_player_onhorse_bp2exit();
	level.player thread player_leaving_bp2_onfoot();
	if ( !level.player is_on_horseback() )
	{
		set_objective( level.obj_follow_bp3, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
		flag_wait( "player_onhorse_bp2exit" );
		set_objective( level.obj_follow_bp3, level.mason_horse, "remove" );
	}
	if ( level.wave2_loc == "blocking point 2" )
	{
		set_objective( level.obj_follow_bp3, level.zhao, "follow" );
	}
}

objective_bp2_exit()
{
	set_objective( level.obj_follow_bp3, level.zhao, "remove" );
	set_objective( level.obj_defend_cache2, getstruct( "bp2_cache_obj", "targetname" ).origin, "protect" );
	flag_wait( "bp2_exit_done" );
	set_objective( level.obj_defend_cache2, undefined, "done" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_wait( "zhao_at_bp3" );
		set_objective( level.obj_afghan_bp3, level.zhao, "follow" );
	}
}

delete_bp2_vehicles_objectives()
{
	wait 1;
	if ( level.wave2_loc == "blocking point 2" )
	{
		set_objective( level.obj_afghan_bp2wave2_vehicles, undefined, "delete" );
	}
	else
	{
		set_objective( level.obj_afghan_bp2wave3_vehicles, undefined, "delete" );
	}
}

waittill_player_onhorse_bp2exit()
{
	level endon( "player_onhorse_bp2exit" );
	while ( !level.player is_on_horseback() )
	{
		wait 0,1;
	}
	flag_set( "player_onhorse_bp2exit" );
}

player_leaving_bp2_onfoot()
{
	level endon( "player_onhorse_bp2exit" );
	trigger_wait( "replenish_bp2" );
	if ( !level.player is_on_horseback() )
	{
		flag_set( "player_onhorse_bp2exit" );
	}
}

triggercolor_bp2()
{
	trigger_use( "triggercolor_evacuate_cache" );
}

arch_target()
{
	level endon( "arch_destroyed" );
	m_arch = getent( "BP2_arch_hitbox", "targetname" );
	m_arch setcandamage( 1 );
	while ( 1 )
	{
		m_arch waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type != "MOD_PROJECTILE" && type != "MOD_EXPLOSIVE" || type == "MOD_EXPLOSIVE_SPLASH" && type == "MOD_PROJECTILE_SPLASH" )
		{
			if ( attacker == level.player )
			{
				level notify( "fxanim_rock_arch_collapse_start" );
				level.player thread say_dialog( "maso_it_s_coming_down_0", 0,5 );
				level.woods thread say_dialog( "wood_fucking_a_0", 2 );
				level thread clip_under_arch();
				set_objective( level.obj_bp2_arch, getstruct( "arch_target", "targetname" ), "remove" );
				flag_set( "arch_destroyed" );
			}
		}
	}
}

clip_under_arch()
{
	trigger_use( "triggercolor_flee_arch" );
	a_triggers = getentarray( "trigger_arch_dmg", "targetname" );
	s_zhao_tele = getstruct( "zhao_teleport_pos", "targetname" );
	s_woods_tele = getstruct( "woods_teleport_pos", "targetname" );
	m_clip_arch = getent( "BP2_tankdebris", "targetname" );
	m_clip_arch trigger_on();
	m_clip_arch disconnectpaths();
	wait 1,9;
	_a993 = a_triggers;
	_k993 = getFirstArrayKey( _a993 );
	while ( isDefined( _k993 ) )
	{
		t_trig = _a993[ _k993 ];
		if ( level.zhao istouching( t_trig ) )
		{
			level.zhao teleport( s_zhao_tele.origin, s_zhao_tele.angles );
		}
		if ( level.woods istouching( t_trig ) )
		{
			level.woods teleport( s_woods_tele.origin, s_woods_tele.angles );
		}
		if ( level.player istouching( t_trig ) )
		{
			missionfailedwrapper( &"AFGHANISTAN_ROCK_ARCH_FAIL" );
		}
		_k993 = getNextArrayKey( _a993, _k993 );
	}
	wait 0,1;
	a_ai_guys = getaiarray( "all" );
	a_vh_vehicles = getentarray( "script_vehicle", "classname" );
	a_entities = arraycombine( a_ai_guys, a_vh_vehicles, 1, 0 );
	_a1017 = a_triggers;
	_k1017 = getFirstArrayKey( _a1017 );
	while ( isDefined( _k1017 ) )
	{
		t_trig = _a1017[ _k1017 ];
		_a1019 = a_ai_guys;
		_k1019 = getFirstArrayKey( _a1019 );
		while ( isDefined( _k1019 ) )
		{
			e_entity = _a1019[ _k1019 ];
			if ( e_entity istouching( t_trig ) )
			{
				radiusdamage( e_entity.origin, 100, 5000, 4000, undefined, "MOD_PROJECTILE" );
			}
			_k1019 = getNextArrayKey( _a1019, _k1019 );
		}
		_a1027 = a_vh_vehicles;
		_k1027 = getFirstArrayKey( _a1027 );
		while ( isDefined( _k1027 ) )
		{
			vh_entity = _a1027[ _k1027 ];
			if ( vh_entity istouching( t_trig ) )
			{
				radiusdamage( vh_entity.origin, 100, 5000, 4000, undefined, "MOD_PROJECTILE" );
			}
			_k1027 = getNextArrayKey( _a1027, _k1027 );
		}
		_k1017 = getNextArrayKey( _a1017, _k1017 );
	}
}

vo_mortars()
{
	level endon( "mortars_done" );
	flag_wait( "mortar_first" );
	level.zhao say_dialog( "zhao_incoming_0", 0,5 );
	level.woods say_dialog( "wood_up_high_on_the_cli_0", 1 );
	level.woods say_dialog( "wood_that_s_where_the_bas_0", 0,5 );
	level.player say_dialog( "maso_i_don_t_have_a_visua_0", 0,5 );
	level.woods say_dialog( "wood_they_re_dug_in_maso_0", 1 );
	level.zhao say_dialog( "zhao_we_must_hurry_the_0", 1 );
	level thread vo_mortar_nag();
}

vo_mortar_check()
{
	level endon( "mortars_done" );
	switch( randomint( 4 ) )
	{
		case 0:
			level.woods say_dialog( "wood_that_s_a_miss_0", 1 );
			break;
		case 1:
			level.woods say_dialog( "wood_dammit_not_quite_0", 1 );
			break;
		case 2:
			level.zhao say_dialog( "zhao_close_try_again_0", 1 );
			break;
		case 3:
			level.zhao say_dialog( "zhao_not_even_close_adj_0", 1 );
			break;
	}
}

vo_mortar_nag()
{
	wait 7;
	while ( 1 )
	{
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else level.zhao thread say_dialog( "zhao_hurry_mason_silen_0", 0 );
		wait 1;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else wait 7;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else screen_message_delete();
		wait 2;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else level.woods thread say_dialog( "wood_they_re_dug_in_maso_0", 0 );
		wait 1;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else wait 7;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else screen_message_delete();
		wait 2;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else level.woods say_dialog( "wood_come_on_mason_0", 0 );
		wait 1;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else wait 7;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else screen_message_delete();
		wait 1;
		if ( flag( "mortars_done" ) )
		{
			break;
		}
		else
		{
		}
	}
	screen_message_delete();
}

mortar_destroyed( s_obj_pos )
{
	set_objective( level.obj_bp2_mortar, s_obj_pos, "destroy", -1 );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type != "MOD_EXPLOSIVE" && type != "MOD_EXPLOSIVE_SPLASH" || type == "MOD_PROJECTILE" && type == "MOD_PROJECTILE_SPLASH" )
		{
			level.n_bp2_mortar_destroyed++;
			set_objective( level.obj_bp2_mortar, s_obj_pos, "remove" );
			wait 0,5;
			set_objective( level.obj_bp2_mortar, undefined, undefined, level.n_bp2_mortar_destroyed );
			wait 0,5;
			if ( self.targetname == "bp2_mortar2_emplacement" )
			{
				flag_set( "mortar2_destroyed" );
				level thread mortar2_destroyed_fx();
				autosave_by_name( "mortar2" );
			}
			else
			{
				flag_set( "mortar1_destroyed" );
				level thread mortar1_destroyed_fx();
				spawn_manager_kill( "manager_bp2_rpg" );
				autosave_by_name( "mortar1" );
			}
			if ( level.n_bp2_mortar_destroyed > 1 )
			{
				set_objective( level.obj_bp2_mortar, undefined, "done" );
				wait 0,1;
				set_objective( level.obj_bp2_mortar, undefined, "delete" );
				flag_set( "mortars_done" );
				level.woods say_dialog( "wood_there_you_go_0", 1 );
				level.woods say_dialog( "wood_nice_shootin_broth_0", 0,5 );
				level.woods say_dialog( "wood_that_should_do_it_0", 1 );
				flag_set( "spawn_vehicles" );
			}
			else
			{
				level.woods say_dialog( "wood_that_s_a_hit_0", 1 );
				if ( !flag( "mortars_done" ) )
				{
					level.woods say_dialog( "wood_shit_there_s_a_se_0", 1 );
				}
				if ( !flag( "mortars_done" ) )
				{
					level.woods say_dialog( "wood_hit_em_now_0", 0,5 );
				}
			}
			self delete();
		}
	}
}

mortar1_destroyed_fx()
{
	exploder( 651 );
	level notify( "fxanim_rock_peak_explosion_start" );
	s_mortar = getstruct( "bp2_mortar1_pos", "targetname" );
	radiusdamage( s_mortar.origin, 800, 2000, 1500, level.player, "MOD_PROJECTILE" );
	s_mortar = undefined;
}

mortar2_destroyed_fx()
{
	exploder( 466 );
	level notify( "fxanim_cliff_collapse_start" );
}

mortar_check( v_explode_point )
{
	level endon( "mortars_done" );
	s_mortar1_obj = getstruct( "bp2_mortar1_pos", "targetname" );
	s_mortar2_obj = getstruct( "bp2_mortar2_pos", "targetname" );
	wait 2;
	if ( !flag( "mortar1_destroyed" ) )
	{
		if ( distance2dsquared( v_explode_point, s_mortar1_obj.origin ) < 640000 && v_explode_point[ 2 ] > 625 )
		{
			level thread vo_mortar_check();
		}
	}
	else
	{
		if ( !flag( "mortar2_destroyed" ) )
		{
			if ( distance2dsquared( v_explode_point, s_mortar2_obj.origin ) < 640000 && v_explode_point[ 2 ] > 425 )
			{
				level thread vo_mortar_check();
			}
		}
	}
}

mortar_victim_left()
{
	level endon( "mortar_victims" );
	trigger_wait( "trigger_mortar_truck_victim_left" );
	s_spawnpt = getstruct( "mortar_victim_right_spawnpt", "targetname" );
	spawn_mortar_victims( s_spawnpt );
	trigger_delete( "trigger_mortar_truck_victim_left" );
	trigger_delete( "trigger_mortar_truck_victim_right" );
	trigger_delete( "trigger_bp3_bp2_mortars" );
	flag_set( "mortar_victims" );
}

mortar_victim_right()
{
	level endon( "mortar_victims" );
	trigger_wait( "trigger_mortar_truck_victim_right" );
	s_spawnpt = getstruct( "mortar_victim_left_spawnpt", "targetname" );
	spawn_mortar_victims( s_spawnpt );
	trigger_delete( "trigger_mortar_truck_victim_left" );
	trigger_delete( "trigger_mortar_truck_victim_right" );
	trigger_delete( "trigger_bp3_bp2_mortars" );
	flag_set( "mortar_victims" );
}

mortar_victim_bp3_bp2()
{
	level endon( "mortar_victims" );
	trigger_wait( "trigger_bp3_bp2_mortars" );
	s_spawnpt = getstruct( "bp3_bp2_mortar_truck_spawnpt", "targetname" );
	spawn_mortar_victims( s_spawnpt, 1 );
	trigger_delete( "trigger_mortar_truck_victim_left" );
	trigger_delete( "trigger_mortar_truck_victim_right" );
	trigger_delete( "trigger_bp3_bp2_mortars" );
	flag_set( "mortar_victims" );
}

spawn_mortar_victims( s_spawnpt, b_is_bp3 )
{
	a_vh_trucks = [];
	i = 0;
	while ( i < 3 )
	{
		a_vh_trucks[ i ] = spawn_vehicle_from_targetname( "truck_afghan" );
		a_vh_trucks[ i ].origin = s_spawnpt.origin + ( 0, i * 200, 0 );
		a_vh_trucks[ i ].angles = s_spawnpt.angles + ( 0, i * 200, 0 );
		ai_rider2 = get_muj_ai();
		if ( isDefined( ai_rider2 ) )
		{
			ai_rider2.script_startingposition = 2;
			ai_rider2 enter_vehicle( a_vh_trucks[ i ] );
		}
		if ( isDefined( b_is_bp3 ) )
		{
			s_goal = getstruct( "bp3_bp2_mortar_truck_goal", "targetname" );
		}
		else
		{
			s_goal = getstruct( "mortar_victim_truck_goal", "targetname" );
		}
		v_goal = s_goal.origin + ( 0, i * 50, 0 );
		a_vh_trucks[ i ] thread mortar_victim_logic( v_goal );
		if ( i == 0 )
		{
			a_vh_trucks[ i ] thread start_bp2_mortars();
		}
		i++;
	}
}

mortar_victim_logic( v_goal )
{
	self endon( "death" );
	self setneargoalnotifydist( 300 );
	self setspeed( 30, 25, 10 );
	self setvehgoalpos( v_goal, 0 );
	self waittill_any( "near_goal", "goal" );
	self setbrake( 1 );
	playsoundatposition( "exp_mortar", self.origin );
	playfx( level._effect[ "explode_mortar_sand" ], self.origin );
	earthquake( 0,2, 1, level.player.origin, 100 );
	self launchvehicle( vectorScale( ( 0, 0, 0 ), 200 ), anglesToForward( self.angles ) * 180, 1, 1 );
	wait 2;
	radiusdamage( self.origin, 100, self.health, self.health );
}

start_bp2_mortars()
{
	self endon( "death" );
	i = 0;
	while ( i < 3 )
	{
		s_mortar = getstruct( "bp2_mortar1_obj", "targetname" );
		if ( cointoss() )
		{
			s_mortar = getstruct( "bp2_mortar2_obj", "targetname" );
		}
		playsoundatposition( "prj_mortar_launch", s_mortar.origin );
		wait 1;
		v_explosion = self.origin + ( randomintrange( -300, 0 ), randomintrange( -300, 300 ), 0 );
		playsoundatposition( "prj_mortar_incoming", v_explosion );
		wait 0,45;
		playsoundatposition( "exp_mortar", v_explosion );
		playfx( level._effect[ "explode_mortar_sand" ], v_explosion );
		earthquake( 0,2, 1, level.player.origin, 100 );
		wait randomfloatrange( 0,1, 0,3 );
		i++;
	}
}

bp2_mig_bombers()
{
	s_spawnpt1 = getstruct( "bp2_mig1_spawnpt", "targetname" );
	s_spawnpt2 = getstruct( "bp2_mig2_spawnpt", "targetname" );
	s_spawnpt3 = getstruct( "bp2_mig3_spawnpt", "targetname" );
	vh_mig1 = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig1.origin = s_spawnpt1.origin;
	vh_mig1.angles = s_spawnpt1.angles;
	vh_mig1 setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	vh_mig1 thread bp2_mig_bombrun( s_spawnpt1 );
	vh_mig1.overridevehicledamage = ::sticky_grenade_damage;
	wait 1;
	vh_mig2 = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig2.origin = s_spawnpt2.origin;
	vh_mig2.angles = s_spawnpt2.angles;
	vh_mig2 setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	vh_mig2 thread bp2_mig_bombrun( s_spawnpt2 );
	vh_mig2.overridevehicledamage = ::sticky_grenade_damage;
	wait 1;
	vh_mig3 = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig3.origin = s_spawnpt3.origin;
	vh_mig3.angles = s_spawnpt3.angles;
	vh_mig3 setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	vh_mig3 thread bp2_mig_bombrun( s_spawnpt3 );
	vh_mig3.overridevehicledamage = ::sticky_grenade_damage;
	level.n_missiles_fired = 0;
	flag_wait( "mig_bombrun" );
	level notify( "fxanim_rock_arch_start" );
	level.player say_dialog( "maso_that_arch_almost_cam_0", 1 );
}

bp2_mig_bombrun( s_spawnpt )
{
	self endon( "death" );
	target_set( self, ( -230, 0, -12 ) );
	self setneargoalnotifydist( 1000 );
	self setspeed( 400, 350, 100 );
	self thread vehicle_route( s_spawnpt );
	self thread launch_missiles();
}

launch_missiles()
{
	self endon( "death" );
	t_missiles = getent( "bp2_mig_missiles", "targetname" );
	while ( !self istouching( t_missiles ) )
	{
		wait 0,1;
	}
	e_stinger1 = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_right" ) + vectorScale( ( 0, 0, 0 ), 6000 ), self.origin + ( -9500, 0, -1600 ) );
	e_stinger1 thread stinger_explode();
	wait 0,2;
	e_stinger2 = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_left" ) + vectorScale( ( 0, 0, 0 ), 6000 ), self.origin + ( -9500, 0, -1600 ) );
	e_stinger2 thread stinger_explode();
}

stinger_explode()
{
	self waittill( "death" );
	playfx( level._effect[ "explode_mortar_sand" ], self.origin );
	earthquake( 0,2, 1, level.player.origin, 100 );
	playsoundatposition( "exp_mortar", self.origin );
	level.n_missiles_fired++;
	if ( level.n_missiles_fired > 2 && !flag( "mig_bombrun" ) )
	{
		flag_set( "mig_bombrun" );
	}
}

mig_victim_logic()
{
	self endon( "death" );
	self set_ignoreall( 1 );
}

vo_intro_bp2()
{
	level.woods say_dialog( "huds_mason_the_russians_0", 0 );
	level.woods say_dialog( "huds_the_muj_are_taking_h_0", 0,5 );
	level.player say_dialog( "maso_copy_that_hudson_w_0", 0,5 );
	level.woods say_dialog( "wood_gotta_go_mason_0", 1 );
	level.woods say_dialog( "wood_lead_the_way_zhao_0", 0,5 );
	flag_wait( "mortar_victims" );
	level.zhao say_dialog( "zhao_incoming_0", 0,5 );
	level.woods say_dialog( "wood_we_gotta_stop_those_0", 1 );
}

vo_bp2()
{
	trigger_wait( "bp2_commit" );
	level.zhao say_dialog( "zhao_target_the_helicopte_0", 0 );
	if ( level.n_current_wave == 3 )
	{
		level.woods say_dialog( "wood_mason_same_drill_0", 0 );
	}
	flag_wait( "spawn_vehicles" );
	trigger_use( "triggercolor_assault_arch" );
	level.woods say_dialog( "wood_russian_infantry_inb_0", 1 );
	level.player say_dialog( "maso_they_re_heading_for_0", 2 );
	level.woods say_dialog( "wood_get_outta_there_0", 1 );
	flag_wait_all( "mortars_done", "bp2_vehicles_done" );
	level.woods say_dialog( "huds_woods_mason_sitr_0", 2,5 );
	level.woods say_dialog( "wood_area_s_secure_0", 0,5 );
	level.woods say_dialog( "huds_any_problems_0", 0,5 );
	level.woods say_dialog( "wood_nothing_we_couldn_t_0", 0,5 );
	flag_wait( "bp2_exit_done" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		level.woods say_dialog( "huds_mason_the_russians_1", 1 );
	}
}

bp2_exit_battle()
{
	trigger_wait( "trigger_bp2_exit_battle" );
	level thread objective_bp2_exit();
	level thread bp2_exit_battle_horses();
	level thread spawn_bp2_exit_truck1();
	wait 0,1;
	level thread spawn_bp2_exit_truck2();
	wait 0,1;
	level thread spawn_bp2_exit_btr();
}

bp2_exit_battle_horses()
{
	s_spawnpt = getstruct( "bp2_exit_horse_spawnpt", "targetname" );
	vh_horses = [];
	i = 0;
	while ( i < 4 )
	{
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		vh_horses[ i ] setvehicleavoidance( 1, undefined, 3 );
		s_goal = getstruct( "bp2_exit_horse_goal" + i, "targetname" );
		ai_rider = get_muj_ai();
		vh_horses[ i ] thread bp2_exit_battle_horse_behavior( ai_rider, s_goal );
		wait 0,3;
		i++;
	}
	flag_wait( "bp2_exit_done" );
	i = 0;
	while ( i < 4 )
	{
		if ( isDefined( vh_horses[ i ] ) )
		{
			vh_horses[ i ].delete_on_death = 1;
			vh_horses[ i ] notify( "death" );
			if ( !isalive( vh_horses[ i ] ) )
			{
				vh_horses[ i ] delete();
			}
		}
		i++;
	}
}

bp2_exit_battle_horse_behavior( ai_rider, s_goal )
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 100 );
	self makevehicleunusable();
	if ( isalive( ai_rider ) )
	{
		ai_rider enter_vehicle( self );
	}
	wait 0,1;
	self notify( "groupedanimevent" );
	if ( isalive( ai_rider ) )
	{
		ai_rider maps/_horse_rider::ride_and_shoot( self );
	}
	self setspeed( 35, 30, 10 );
	self setvehgoalpos( s_goal.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	wait 1;
	if ( isalive( ai_rider ) )
	{
		ai_rider ai_dismount_horse( self );
	}
	s_horse_goal1 = getstruct( "exit_battle_horse_goal4", "targetname" );
	self setvehgoalpos( s_horse_goal1.origin + ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), 0 ), 1, 1 );
	if ( isalive( ai_rider ) )
	{
		ai_rider set_spawner_targets( "bp2_cache_perimeter" );
	}
}

spawn_bp2_exit_uaz()
{
	level thread spawn_bp2_exit_uaz1();
	wait 1;
	level thread spawn_bp2_exit_uaz2();
	wait 1;
	while ( 1 )
	{
		a_ai_guys = getentarray( "bp2exit_soviet", "targetname" );
		if ( !a_ai_guys.size )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	flag_set( "bp2_exit_done" );
}

spawn_bp2_exit_uaz1()
{
	nd_start1 = getvehiclenode( "bp2_exit_uaz1_startnode1", "targetname" );
	nd_start2 = getvehiclenode( "bp2_exit_uaz1_startnode2", "targetname" );
	s_truck_spawnpt1 = getstruct( "bp2_exit_uaz1_spawnpt1", "targetname" );
	s_truck_spawnpt2 = getstruct( "bp2_exit_uaz1_spawnpt2", "targetname" );
	vh_uaz1 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz1.origin = s_truck_spawnpt1.origin;
	vh_uaz1.angles = s_truck_spawnpt1.angles;
	wait 0,1;
	vh_uaz1 thread go_path( nd_start1 );
	vh_uaz1 thread bp2_exit_uaz_logic();
	wait 0,1;
	vh_uaz2 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz2.origin = s_truck_spawnpt2.origin;
	vh_uaz2.angles = s_truck_spawnpt2.angles;
	wait 0,1;
	vh_uaz2 thread go_path( nd_start2 );
	vh_uaz2 thread bp2_exit_uaz_logic();
}

spawn_bp2_exit_uaz2()
{
	nd_start1 = getvehiclenode( "bp2_exit_uaz2_startnode1", "targetname" );
	nd_start2 = getvehiclenode( "bp2_exit_uaz2_startnode2", "targetname" );
	s_truck_spawnpt1 = getstruct( "bp2_exit_uaz2_spawnpt1", "targetname" );
	s_truck_spawnpt2 = getstruct( "bp2_exit_uaz2_spawnpt2", "targetname" );
	vh_uaz1 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz1.origin = s_truck_spawnpt1.origin;
	vh_uaz1.angles = s_truck_spawnpt1.angles;
	wait 0,1;
	vh_uaz1 thread go_path( nd_start1 );
	vh_uaz1 thread bp2_exit_uaz_logic();
	wait 0,1;
	vh_uaz2 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz2.origin = s_truck_spawnpt2.origin;
	vh_uaz2.angles = s_truck_spawnpt2.angles;
	wait 0,1;
	vh_uaz2 thread go_path( nd_start2 );
	vh_uaz2 thread bp2_exit_uaz_logic();
}

bp2_exit_uaz_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	sp_rider = getent( "soviet_assault", "targetname" );
	i = 0;
	while ( i < 2 )
	{
		ai_rider = sp_rider spawn_ai( 1 );
		if ( isDefined( ai_rider ) )
		{
			ai_rider.targetname = "bp2exit_soviet";
			ai_rider.arena_guy = 1;
			ai_rider thread bp2_exit_troop_logic();
			wait 0,05;
			ai_rider enter_vehicle( self );
		}
		i++;
	}
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

bp2_exit_troop_logic()
{
	self endon( "death" );
	self.goalradius = 64;
	vol_cache = getent( "vol_cache1", "targetname" );
	self setgoalvolumeauto( vol_cache );
	self waittill( "goal" );
	self set_fixednode( 0 );
}

spawn_bp2_exit_truck1()
{
	nd_start = getvehiclenode( "bp2_exit_truck1_startnode", "targetname" );
	s_truck_spawnpt = getstruct( "bp2_exit_truck1_spawnpt", "targetname" );
	vh_truck = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck.origin = s_truck_spawnpt.origin;
	vh_truck.angles = s_truck_spawnpt.angles;
	vh_truck.targetname = "bp2_exit_truck1";
	vh_truck thread go_path( nd_start );
	vh_truck thread bp2_exit_truck1_logic();
}

bp2_exit_truck1_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self setcandamage( 0 );
	sp_rider = getent( "muj_assault", "targetname" );
	n_pos = 0;
	i = 0;
	while ( i < 2 )
	{
		ai_rider = sp_rider spawn_ai( 1 );
		if ( isDefined( ai_rider ) )
		{
			ai_rider.arena_guy = 1;
			ai_rider.script_startingposition = n_pos;
			n_pos += 2;
			wait 0,05;
			ai_rider enter_vehicle( self );
		}
		i++;
	}
	wait 1;
	vh_btr = getent( "bp2_exit_btr", "targetname" );
	if ( isalive( vh_btr ) )
	{
		self set_turret_target( vh_btr, ( 0, -100, -32 ), 1 );
		self shoot_turret_at_target( vh_btr, 7, ( 0, 0, 0 ), 1 );
	}
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self setbrake( 1 );
	wait 1;
	if ( isDefined( self.riders[ 0 ] ) )
	{
		self.riders[ 0 ] die();
	}
	wait 2;
	while ( isDefined( self.riders ) )
	{
		_a1943 = self.riders;
		_k1943 = getFirstArrayKey( _a1943 );
		while ( isDefined( _k1943 ) )
		{
			ai_rider = _a1943[ _k1943 ];
			ai_rider die();
			_k1943 = getNextArrayKey( _a1943, _k1943 );
		}
	}
	self makevehicleusable();
}

spawn_bp2_exit_truck2()
{
	nd_start = getvehiclenode( "bp2_exit_truck2_startnode", "targetname" );
	s_truck_spawnpt = getstruct( "bp2_exit_truck2_spawnpt", "targetname" );
	vh_truck = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck.origin = s_truck_spawnpt.origin;
	vh_truck.angles = s_truck_spawnpt.angles;
	vh_truck.targetname = "bp2_exit_truck2";
	vh_truck thread go_path( nd_start );
	vh_truck thread bp2_exit_truck2_logic();
}

bp2_exit_truck2_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	sp_rider = getent( "muj_assault", "targetname" );
	n_pos = 0;
	i = 0;
	while ( i < 2 )
	{
		ai_rider = sp_rider spawn_ai( 1 );
		if ( isDefined( ai_rider ) )
		{
			ai_rider.arena_guy = 1;
			ai_rider.script_startingposition = n_pos;
			n_pos += 2;
			wait 0,05;
			ai_rider enter_vehicle( self );
		}
		i++;
	}
	wait 1;
	vh_btr = getent( "bp2_exit_btr", "targetname" );
	if ( isalive( vh_btr ) )
	{
		self set_turret_target( vh_btr, ( 0, -100, -32 ), 1 );
		self shoot_turret_at_target( vh_btr, 7, ( 0, 0, 0 ), 1 );
	}
}

bp2_exit_muj_logic()
{
	self endon( "death" );
	self thread delete_bp2_exit_battle();
	wait 1;
	vh_btr = getent( "bp2_exit_btr", "targetname" );
	while ( isalive( vh_btr ) )
	{
		self shoot_at_target( vh_btr, undefined, 0, randomfloatrange( 2,5, 4,5 ) );
		wait randomfloatrange( 0,5, 1,5 );
	}
}

spawn_bp2_exit_btr()
{
	nd_start = getvehiclenode( "bp2_exit_btr_startnode", "targetname" );
	s_btr_spawnpt = getstruct( "bp2_exit_btr_spawnpt", "targetname" );
	vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_btr_spawnpt.origin;
	vh_btr.angles = s_btr_spawnpt.angles;
	vh_btr.targetname = "bp2_exit_btr";
	vh_btr thread go_path( nd_start );
	vh_btr thread bp2_exit_btr_logic();
	level thread spawn_bp2_exit_uaz();
	level.zhao say_dialog( "zhao_another_btr_is_heade_0", 1 );
}

bp2_exit_btr_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	wait 1;
	vh_truck = getent( "bp2_exit_truck2", "targetname" );
	if ( isalive( vh_truck ) )
	{
		self set_turret_target( vh_truck, ( 0, 0, 0 ), 1 );
		self shoot_turret_at_target( vh_truck, 7, ( 0, 0, 0 ), 1 );
	}
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

delete_bp2_exit_battle()
{
	self endon( "death" );
	flag_wait( "wave3_started" );
	self delete();
}

bp2_vehicle_destroyed()
{
	self waittill( "death", attacker );
	level.n_bp2_veh_destroyed++;
	if ( level.n_bp2_veh_destroyed > 1 && !flag( "spawn_boss_bp2" ) )
	{
		flag_set( "spawn_boss_bp2" );
	}
	if ( level.n_current_wave == 2 )
	{
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "remove" );
		wait 0,5;
		set_objective( level.obj_afghan_bp2wave2_vehicles, undefined, undefined, level.n_bp2_veh_destroyed );
		if ( level.n_bp2_veh_destroyed > 2 && !flag( "bp2_vehicles_done" ) )
		{
			set_objective( level.obj_afghan_bp2wave2_vehicles, undefined, "done" );
			flag_set( "bp2_vehicles_done" );
		}
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			set_objective( level.obj_afghan_bp2wave3_vehicles, self, "remove" );
			wait 0,5;
			set_objective( level.obj_afghan_bp2wave3_vehicles, undefined, undefined, level.n_bp2_veh_destroyed );
			if ( level.n_bp2_veh_destroyed > 1 && !flag( "bp2_vehicles_done" ) )
			{
				set_objective( level.obj_afghan_bp2wave3_vehicles, undefined, "done" );
				flag_set( "bp2_vehicles_done" );
			}
			if ( level.n_bp2_veh_destroyed > 0 && !flag( "bp2wave3_hind" ) && !flag( "bp2wave3_tank" ) )
			{
				level thread bp2wave3_spawn_boss();
			}
		}
	}
}

bp2_replenish_arena()
{
	trigger_wait( "bp2_commit" );
	trigger_wait( "bp2_replenish_arena" );
	if ( !flag( "wave2_done" ) )
	{
		level thread replenish_bp2();
		level thread vo_nag_get_back( "bp2_exit" );
	}
	else
	{
		level thread vo_get_horse();
	}
	flag_set( "bp2_exit" );
	flag_set( "left_bp2" );
	spawn_manager_disable( "manager_bp2_soviet" );
	spawn_manager_disable( "manager_bp2_rpg" );
	spawn_manager_disable( "manager_reinforce_bp2" );
	wait 0,1;
	cleanup_bp_ai();
	maps/afghanistan_arena_manager::respawn_arena();
}

replenish_bp2()
{
	trigger_wait( "replenish_bp2" );
	flag_clear( "left_bp2" );
	wait 0,1;
	spawn_manager_enable( "manager_bp2_soviet" );
	spawn_manager_enable( "manager_bp2_rpg" );
	spawn_manager_enable( "manager_reinforce_bp2" );
	level thread bp2_replenish_arena();
}

zhao_bp2()
{
	if ( level.n_current_wave == 2 )
	{
		flag_wait( "wave2_started" );
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			flag_wait( "wave3_started" );
		}
	}
	wait 5;
	self thread zhao_circle_bp2();
}

woods_bp2()
{
	if ( level.n_current_wave == 2 )
	{
		flag_wait( "wave2_started" );
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			flag_wait( "wave3_started" );
		}
	}
	wait 5;
	self thread woods_circle_bp2();
}

mason_bp2()
{
	level endon( "wave2_done" );
	level endon( "bp2wave3_done" );
	trigger_wait( "bp2_commit" );
	while ( 1 )
	{
		self waittill( "exit_vehicle", player );
		if ( !flag( "left_bp2" ) )
		{
			if ( level.n_current_wave == 2 && !flag( "wave2_done" ) )
			{
				self makevehicleunusable();
				wait 2;
				self thread horse_runaway_bp2();
				self thread mason_horse_return_bp2();
				break;
			}
			else
			{
				if ( level.n_current_wave == 3 && !flag( "bp2wave3_done" ) )
				{
					self makevehicleunusable();
					wait 2;
					self thread horse_runaway_bp2();
					self thread mason_horse_return_bp2();
				}
			}
		}
		self waittill( "enter_vehicle", player );
	}
}

mason_horse_return_bp2()
{
	if ( level.n_current_wave == 2 )
	{
		flag_wait( "wave2_done" );
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			flag_wait_any( "bp2wave3_hind", "bp2wave3_tank" );
		}
	}
	s_return = getstruct( "bp2_horse_return", "targetname" );
	self setvehgoalpos( s_return.origin + ( 0, 0, 0 ), 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	self makevehicleusable();
	s_return = undefined;
}

bp2_backup_horse()
{
	s_spawnpt = getstruct( "bp2_hitch", "targetname" );
	horse = spawn_vehicle_from_targetname( "mason_horse" );
	horse.origin = s_spawnpt.origin;
	horse.angles = s_spawnpt.angles;
	horse makevehicleusable();
	horse veh_magic_bullet_shield( 1 );
	horse thread horse_panic();
}

zhao_circle_bp2()
{
	self setbrake( 0 );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 300 );
	self setvehgoalpos( getstruct( "zhao_cache", "targetname" ).origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	wait 1;
	level.zhao ai_dismount_horse( self );
	wait 2;
	self thread horse_runaway_bp2();
	level.zhao set_force_color( "o" );
}

woods_circle_bp2()
{
	level endon( "woods_ride_with_player" );
	s_end = getstruct( "woods_bp2", "targetname" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_end.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	flag_set( "woods_getting_off_horse" );
	level.woods ai_dismount_horse( self );
	wait 2;
	self horse_runaway_bp2();
	level.woods set_force_color( "o" );
	flag_clear( "woods_getting_off_horse" );
}

defend_against_wave3_vehicle( ai_rider )
{
	level endon( "bp2wave3_done" );
	level endon( "bp3wave3_done" );
	if ( ai_rider.targetname == "woods_ai" )
	{
		s_goal = getstruct( "woods_btr_chase_goal1", "targetname" );
	}
	else
	{
		s_goal = getstruct( "zhao_btr_chase_goal1", "targetname" );
	}
	if ( flag( "bp2wave3_tank" ) )
	{
		if ( isDefined( getent( "bp2wave3_tank", "targetname" ) ) )
		{
			ai_rider thread shoot_at_wave3_vehicle( "bp2wave3_tank" );
		}
	}
	else if ( flag( "bp2wave3_hind" ) )
	{
		if ( isDefined( getent( "bp2wave3_hind", "targetname" ) ) )
		{
			ai_rider thread shoot_at_wave3_vehicle( "bp2wave3_hind" );
		}
	}
	else if ( flag( "bp3wave3_hind" ) )
	{
		if ( isDefined( getent( "bp3wave3_hind", "targetname" ) ) )
		{
			ai_rider thread shoot_at_wave3_vehicle( "bp3wave3_hind" );
		}
	}
	else
	{
		if ( flag( "bp3wave3_tank" ) )
		{
			if ( isDefined( getent( "bp3wave3_tank", "targetname" ) ) )
			{
				ai_rider thread shoot_at_wave3_vehicle( "bp3wave3_tank" );
			}
		}
	}
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	wait 0,5;
	ai_rider ai_dismount_horse( self );
	ai_rider set_fixednode( 0 );
	if ( ai_rider.targetname == "woods_ai" )
	{
		ai_rider thread force_goal( getnode( "node_woods_base_entrance", "targetname" ), 32 );
	}
	else
	{
		ai_rider thread force_goal( getnode( "node_zhao_base_entrance", "targetname" ), 32 );
	}
}

stop_wave3_vehicle_dead( ai_rider )
{
	flag_wait_any( "bp2wave3_done", "bp3wave3_done" );
	wait 1;
	self horse_stop();
	wait 1;
	if ( !isDefined( self get_driver() ) )
	{
		ai_rider ai_mount_horse( self );
	}
}

shoot_at_wave3_vehicle( str_vh_targetname )
{
	vh_target = getent( str_vh_targetname, "targetname" );
	while ( isalive( vh_target ) )
	{
		self shoot_at_target( vh_target, undefined, 1, randomfloatrange( 2, 3,5 ) );
		wait randomfloatrange( 1, 2 );
	}
	self stop_shoot_at_target();
}

horse_runaway_bp2()
{
	s_goal = getstruct( "bp2_horse_runspot", "targetname" );
	self setvehgoalpos( s_goal.origin + ( randomintrange( -200, 0 ), randomintrange( -100, 100 ), 0 ), 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	s_goal = undefined;
}

muj_horse_lineup()
{
	trigger_wait( "bp2_commit" );
	flag_wait_or_timeout( "trigger_bp2_horses", 5 );
	level thread spawn_horse_lineup();
	trigger_wait( "lookat_horse_lineup" );
	flag_set( "muj_charge" );
}

spawn_horse_lineup()
{
	a_s_spawnpts = [];
	a_nd_starts = [];
	a_nd_ready = [];
	i = 0;
	while ( i < 8 )
	{
		a_s_spawnpts[ i ] = getstruct( "horse_lineup_spawnpt" + i, "targetname" );
		a_nd_starts[ i ] = getvehiclenode( "horse_lineup_startnode" + i, "targetname" );
		a_nd_ready[ i ] = getvehiclenode( "horse_lineup_ready" + i, "targetname" );
		spawn_horse_and_rider( a_s_spawnpts[ i ], a_nd_starts[ i ], a_nd_ready[ i ], i );
		wait 0,1;
		i++;
	}
}

spawn_horse_and_rider( s_spawnpt, nd_start, nd_ready, n_index )
{
	vh_horse = spawn_vehicle_from_targetname( "horse_afghan" );
	vh_horse.origin = s_spawnpt.origin;
	vh_horse.angles = s_spawnpt.angles;
	vh_horse.overridevehicledamage = ::horse_damage;
	vh_horse setvehicleavoidance( 1, undefined, 3 );
	if ( n_index < 4 )
	{
		vh_horse.bp_side = "ramp_side";
	}
	else
	{
		vh_horse.bp_side = "cache_side";
	}
	ai_rider = get_muj_ai();
	wait 0,1;
	if ( isDefined( ai_rider ) )
	{
		ai_rider.targetname = "bp2_horserider";
		ai_rider set_force_color( "y" );
		ai_rider enter_vehicle( vh_horse );
	}
	wait 0,1;
	vh_horse notify( "groupedanimevent" );
	if ( isDefined( ai_rider ) )
	{
		ai_rider maps/_horse_rider::ride_and_shoot( vh_horse );
	}
	vh_horse thread go_path( nd_start );
	vh_horse thread bp2_horse_lineup_behavior( nd_ready );
}

bp2_horse_lineup_behavior( nd_ready )
{
	self endon( "death" );
	self horse_panic();
	nd_ready.gateopen = 0;
	flag_wait( "muj_charge" );
	nd_ready.gateopen = 1;
	wait randomfloatrange( 0,5, 1,5 );
	self resumespeed( 15 );
	self waittill( "reached_end_node" );
	ai_rider = self get_driver();
	if ( isalive( ai_rider ) )
	{
		ai_rider notify( "stop_riding" );
		wait 0,05;
		self notify( "unload" );
		self waittill( "unloaded" );
		wait 1;
	}
	if ( self.bp_side == "ramp_side" )
	{
		s_clear = getstruct( "ramp_horse_clear", "targetname" );
	}
	else
	{
		s_clear = getstruct( "cache_horse_clear", "targetname" );
	}
	s_end = getstruct( "bp2_horse_delete", "targetname" );
	self vehicle_detachfrompath();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self makevehicleunusable();
	self clearvehgoalpos();
	self setbrake( 0 );
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_clear.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_end.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

monitor_bp2_enemies()
{
	flag_wait_all( "dropoff1_complete", "dropoff2_complete", "dropoff3_complete", "dropoff4_complete" );
	autosave_by_name( "bp2_start" );
	level thread spawn_bp2_sniper();
	level thread monitor_bp2_defenders();
	flag_set( "mortars_start" );
	spawn_manager_enable( "manager_bp2_rpg" );
	flag_wait( "mortars_done" );
	spawn_manager_enable( "manager_bp2_soviet" );
	if ( level.n_current_wave == 2 )
	{
		flag_wait( "wave2_done" );
	}
	else
	{
		flag_wait( "bp2wave3_done" );
	}
	spawn_manager_kill( "manager_bp2_soviet" );
}

spawn_bp2_sniper()
{
	s_spawnpt = getstruct( "bp2_mortar1_pos", "targetname" );
	sp_sniper = getent( "soviet_sniper", "targetname" );
	ai_sniper = sp_sniper spawn_ai( 1 );
	if ( isDefined( ai_sniper ) )
	{
		ai_sniper forceteleport( s_spawnpt.origin, s_spawnpt.angles );
		ai_sniper force_goal( getnode( "node_bp2_sniper", "targetname" ), 32 );
	}
}

monitor_bp2_defenders()
{
	if ( !flag( "muj_charge" ) )
	{
		flag_set( "muj_charge" );
	}
	spawn_manager_enable( "manager_reinforce_bp2" );
}

monitor_bp2_horseriders()
{
	while ( 1 )
	{
		a_ai_guys = getentarray( "bp2_horserider", "targetname" );
		if ( !a_ai_guys.size )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	flag_set( "bp2_horseriders_done" );
}

bp2_vehicle_chooser()
{
	level.n_veh_wave2bp2 = randomint( 3 );
	if ( level.n_veh_wave2bp2 == 0 )
	{
		s_spawnpt = getstruct( "wave2bp2_hip2_spawnpt", "targetname" );
		vh_hip2 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip2.origin = s_spawnpt.origin;
		vh_hip2.angles = s_spawnpt.angles;
		vh_hip2.targetname = "wave2bp2_hip2";
		vh_hip2 thread bp2wave2_hip2_logic();
		wait 3;
		flag_set( "heli_spawned" );
		s_spawnpt = getstruct( "wave2bp2_hip1_spawnpt", "targetname" );
		vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip1.origin = s_spawnpt.origin;
		vh_hip1.angles = s_spawnpt.angles;
		vh_hip1.targetname = "wave2bp2_hip1";
		vh_hip1 thread bp2wave2_hip1_logic();
	}
	else if ( level.n_veh_wave2bp2 == 1 )
	{
		s_btr1_spawnpt = getstruct( "wave2bp2_btr1_spawnpt", "targetname" );
		vh_btr1 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr1.origin = s_btr1_spawnpt.origin;
		vh_btr1.angles = s_btr1_spawnpt.angles;
		vh_btr1.targetname = "wave2bp2_btr1";
		vh_btr1 thread wave2bp2_btr1_behavior();
		wait 3;
		s_btr2_spawnpt = getstruct( "wave2bp2_btr2_spawnpt", "targetname" );
		vh_btr2 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr2.origin = s_btr2_spawnpt.origin;
		vh_btr2.angles = s_btr2_spawnpt.angles;
		vh_btr2.targetname = "wave2bp2_btr2";
		vh_btr2 thread wave2bp2_btr2_behavior();
	}
	else
	{
		s_spawnpt = getstruct( "wave2bp2_hip1_spawnpt", "targetname" );
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_spawnpt.origin;
		vh_hip.angles = s_spawnpt.angles;
		vh_hip.targetname = "wave2bp2_hip1";
		vh_hip thread bp2wave2_hip1_logic();
		wait 3;
		flag_set( "heli_spawned" );
		s_btr1_spawnpt = getstruct( "wave2bp2_btr1_spawnpt", "targetname" );
		vh_btr1 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr1.origin = s_btr1_spawnpt.origin;
		vh_btr1.angles = s_btr1_spawnpt.angles;
		vh_btr1.targetname = "wave2bp2_btr1";
		vh_btr1 thread wave2bp2_btr1_behavior();
	}
	flag_wait( "spawn_boss_bp2" );
	autosave_by_name( "bp2_boss" );
	wait 1,5;
	level thread bp2wave2_spawn_boss();
}

bp2wave2_spawn_boss()
{
	s_spawnpt = getstruct( "wave2bp2_tank_spawnpt", "targetname" );
	vh_tank = spawn_vehicle_from_targetname( "tank_soviet" );
	vh_tank.origin = s_spawnpt.origin;
	vh_tank.angles = s_spawnpt.angles;
	vh_tank.targetname = "wave2bp2_tank";
	vh_tank thread wave2bp2_tank_logic();
	flag_set( "wave2bp2_tank" );
}

bp2wave3_spawn_boss()
{
	wait 2;
	if ( cointoss() )
	{
		s_spawnpt = getstruct( "bp2wave3_hind_spawnpt", "targetname" );
		vh_hind = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind.origin = s_spawnpt.origin;
		vh_hind.angles = s_spawnpt.angles;
		vh_hind.targetname = "bp2wave3_hind";
		vh_hind thread maps/afghanistan_wave_3::bp2wave3_hind_behavior();
		flag_set( "bp2wave3_hind" );
	}
	else
	{
		s_spawnpt = getstruct( "wave2bp2_tank_spawnpt", "targetname" );
		vh_tank = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank.origin = s_spawnpt.origin;
		vh_tank.angles = s_spawnpt.angles;
		vh_tank.targetname = "bp2wave3_tank";
		vh_tank thread maps/afghanistan_wave_3::bp2wave3_tank_behavior();
		flag_set( "bp2wave3_tank" );
	}
}

reinforce_bp2_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "y" );
	trigger_use( "triggercolor_evacuate_cache" );
}

reinforce_horse_logic( ai_rider )
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self makevehicleunusable();
	self.overridevehicledamage = ::horse_damage;
	if ( cointoss() )
	{
		s_goal = getstruct( "muj_reinforce_right", "targetname" );
		s_goal1 = getstruct( "muj_right_goal1", "targetname" );
		s_goal2 = getstruct( "muj_right_goal2", "targetname" );
		s_goal3 = getstruct( "muj_right_goal3", "targetname" );
		s_goal4 = getstruct( "muj_right_goal4", "targetname" );
	}
	else
	{
		s_goal = getstruct( "muj_reinforce_left", "targetname" );
		s_goal1 = getstruct( "muj_left_goal1", "targetname" );
		s_goal2 = getstruct( "muj_left_goal2", "targetname" );
		s_goal3 = getstruct( "muj_left_goal3", "targetname" );
		s_goal4 = getstruct( "muj_left_goal4", "targetname" );
	}
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal1.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin + ( randomintrange( -200, 200 ), randomintrange( -200, 200 ), 0 ), 1, 1 );
	self waittill_any( "goal", "near_goal" );
	if ( isalive( ai_rider ) )
	{
		self horse_stop();
		wait 1;
		if ( isalive( ai_rider ) )
		{
			ai_rider ai_dismount_horse( self );
		}
		wait 1;
	}
	s_end = getstruct( "bp2_horse_delete", "targetname" );
	self setvehgoalpos( s_end.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

start_hip_dropoff()
{
	level endon( "end_hip_drop_off" );
	s_spawnpt = getstruct( "hipdropoff1_spawnpt", "targetname" );
	vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet_land" );
	vh_hip1.origin = s_spawnpt.origin;
	vh_hip1.angles = s_spawnpt.angles;
	vh_hip1.script_noteworthy = "hip1_dropoff";
	s_spawnpt = getstruct( "hipdropoff2_spawnpt", "targetname" );
	vh_hip2 = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip2.origin = s_spawnpt.origin;
	vh_hip2.angles = s_spawnpt.angles;
	vh_hip2.script_noteworthy = "hip2_dropoff";
	s_spawnpt = getstruct( "hipdropoff3_spawnpt", "targetname" );
	vh_hip3 = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip3.origin = s_spawnpt.origin;
	vh_hip3.angles = s_spawnpt.angles;
	vh_hip3.script_noteworthy = "hip3_dropoff";
	s_spawnpt = getstruct( "hipdropoff4_spawnpt", "targetname" );
	vh_hip4 = spawn_vehicle_from_targetname( "hip_soviet_land" );
	vh_hip4.origin = s_spawnpt.origin;
	vh_hip4.angles = s_spawnpt.angles;
	vh_hip4.script_noteworthy = "hip4_dropoff";
	level.a_bp2_helis = [];
	level.a_bp2_helis[ level.a_bp2_helis.size ] = vh_hip1;
	level.a_bp2_helis[ level.a_bp2_helis.size ] = vh_hip2;
	level.a_bp2_helis[ level.a_bp2_helis.size ] = vh_hip3;
	level.a_bp2_helis[ level.a_bp2_helis.size ] = vh_hip4;
	_a3117 = level.a_bp2_helis;
	_k3117 = getFirstArrayKey( _a3117 );
	while ( isDefined( _k3117 ) )
	{
		heli = _a3117[ _k3117 ];
		heli.is_bp2_heli = 1;
		heli thread heli_select_death();
		_k3117 = getNextArrayKey( _a3117, _k3117 );
	}
	while ( level.player_location != "bp2" )
	{
		wait 0,05;
	}
	vh_hip1 thread hip1_dropoff_logic();
	vh_hip2 thread hip2_dropoff_logic();
	vh_hip3 thread hip3_dropoff_logic();
	vh_hip4 thread hip4_dropoff_logic();
}

cleanup_hip_dropoff()
{
	level notify( "end_hip_drop_off" );
	i = level.a_bp2_helis.size - 1;
	while ( i >= 0 )
	{
		if ( isDefined( level.a_bp2_helis[ i ] ) )
		{
			level.a_bp2_helis[ i ].delete_on_death = 1;
			level.a_bp2_helis[ i ] notify( "death" );
			if ( !isalive( level.a_bp2_helis[ i ] ) )
			{
				level.a_bp2_helis[ i ] delete();
			}
		}
		i--;

	}
}

hip1_dropoff_logic()
{
	self endon( "death" );
	self.dropoff_heli = 1;
	self.overridevehicledamage = ::heli_vehicle_damage;
	self thread set_dropoff_flag_ondeath( "dropoff1_complete" );
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip_dropoff_goal1", "targetname" );
	s_goal2 = getstruct( "hip_dropoff_goal2", "targetname" );
	s_goal3 = getstruct( "hip_dropoff_goal3", "targetname" );
	s_goal4 = getstruct( "hip_dropoff_goal4", "targetname" );
	s_goal_dropoff = getstruct( "hip1_dropoff", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 35, 20, 10 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread load_landing_troops( 3, "bp2_dropoff_ai" );
	self hip_land_unload( "hip1_dropoff" );
	flag_set( "dropoff1_complete" );
	self setspeed( 80, 15, 10 );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip2_dropoff_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::heli_vehicle_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip_dropoff_goal1", "targetname" );
	s_goal2 = getstruct( "hip_dropoff_goal2", "targetname" );
	s_goal3 = getstruct( "hip_dropoff_goal3", "targetname" );
	s_goal4 = getstruct( "hip_dropoff_goal4", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 35, 20, 10 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread set_dropoff_flag_ondeath( "dropoff2_complete" );
	s_goal0 = getstruct( "hip2_dropoff_goal0", "targetname" );
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_goal0.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread load_landing_troops( 3, "bp2_dropoff_ai" );
	self hip_rappel_unload( "hip2_dropoff_goal1" );
	flag_set( "dropoff2_complete" );
	self setspeed( 80, 15, 10 );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip3_dropoff_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::heli_vehicle_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip_dropoff_goal1", "targetname" );
	s_goal2 = getstruct( "hip_dropoff_goal2", "targetname" );
	s_goal3 = getstruct( "hip_dropoff_goal3", "targetname" );
	s_goal4 = getstruct( "hip_dropoff_goal4", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 35, 20, 10 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread set_dropoff_flag_ondeath( "dropoff3_complete" );
	self thread load_landing_troops( 3, "bp2_dropoff_ai" );
	self hip_rappel_unload( "hip3_dropoff_goal1" );
	flag_set( "dropoff3_complete" );
	self setspeed( 80, 15, 10 );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip4_dropoff_logic()
{
	self endon( "death" );
	self.dropoff_heli = 1;
	self.overridevehicledamage = ::heli_vehicle_damage;
	self thread set_dropoff_flag_ondeath( "dropoff4_complete" );
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip_dropoff_goal1", "targetname" );
	s_goal2 = getstruct( "hip_dropoff_goal2", "targetname" );
	s_goal3 = getstruct( "hip_dropoff_goal3", "targetname" );
	s_goal4 = getstruct( "hip_dropoff_goal4", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 35, 20, 10 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal0 = getstruct( "hip4_dropoff_goal0", "targetname" );
	s_goal1 = getstruct( "hip4_dropoff_goal1", "targetname" );
	s_goal2 = getstruct( "hip4_dropoff_goal2", "targetname" );
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_goal0.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread load_landing_troops( 3, "bp2_dropoff_ai" );
	self hip_land_unload( "hip4_dropoff_goal1" );
	flag_set( "dropoff4_complete" );
	self setspeed( 80, 15, 10 );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp2wave2_hip1_logic()
{
	self endon( "death" );
	self thread bp2_vehicle_destroyed();
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip1_wave2bp2_goal1", "targetname" );
	s_goal2 = getstruct( "hip1_wave2bp2_goal2", "targetname" );
	s_goal3 = getstruct( "hip1_wave2bp2_goal3", "targetname" );
	s_goal4 = getstruct( "hip1_wave2bp2_goal4", "targetname" );
	s_goal5 = getstruct( "hip1_wave2bp2_goal5", "targetname" );
	s_goal6 = getstruct( "hip1_wave2bp2_goal6", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 45, 25, 15 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal5.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal6.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread load_landing_troops( 3, "bp2_hip1_troops" );
	self hip_rappel_unload( "hip1_wave2bp2_goal7" );
	a_ai_troops = getentarray( "bp2_hip1_troops", "targetname" );
	_a3443 = a_ai_troops;
	_k3443 = getFirstArrayKey( _a3443 );
	while ( isDefined( _k3443 ) )
	{
		ai_troop = _a3443[ _k3443 ];
		ai_troop thread bp2_hip1_troops_logic();
		_k3443 = getNextArrayKey( _a3443, _k3443 );
	}
	s_start = getstruct( "bp2_circle_goal01", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
	flag_wait( "attack_cache_bp2" );
	self notify( "stop_attack" );
	m_damage = getent( "bp2_cache_origin", "targetname" );
	self thread hip_attack_cache( m_damage );
	flag_wait( "cache_destroyed_bp2" );
	self notify( "stop_attack" );
	self notify( "stop_circle" );
	self thread hip_attack();
}

bp2wave2_hip2_logic()
{
	self endon( "death" );
	self thread bp2_vehicle_destroyed();
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	s_goal1 = getstruct( "hip2_wave2bp2_goal1", "targetname" );
	s_goal2 = getstruct( "hip2_wave2bp2_goal2", "targetname" );
	s_goal3 = getstruct( "hip2_wave2bp2_goal3", "targetname" );
	s_goal4 = getstruct( "hip2_wave2bp2_goal4", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 35, 25, 15 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 20, 15, 10 );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread load_landing_troops( 3, "bp2_hip2_troops" );
	self hip_rappel_unload( "hip2_wave2bp2_goal4" );
	a_ai_troops = getentarray( "bp2_hip2_troops", "targetname" );
	_a3521 = a_ai_troops;
	_k3521 = getFirstArrayKey( _a3521 );
	while ( isDefined( _k3521 ) )
	{
		ai_troop = _a3521[ _k3521 ];
		ai_troop thread bp2_hip2_troops_logic();
		_k3521 = getNextArrayKey( _a3521, _k3521 );
	}
	s_start = getstruct( "bp2_circle_goal01", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
	flag_wait( "attack_cache_bp2" );
	self notify( "stop_attack" );
	m_damage = getent( "bp2_cache_origin", "targetname" );
	self thread hip_attack_cache( m_damage );
	flag_wait( "cache_destroyed_bp2" );
	self notify( "stop_attack" );
	self notify( "stop_circle" );
	self thread hip_attack();
}

bp2_soviet_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "g" );
}

bp2_hip1_troops_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "g" );
}

bp2_hip2_troops_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "g" );
}

wave2bp2_btr1_behavior()
{
	self endon( "death" );
	nd_start = getvehiclenode( "wave2bp2_btr1_startnode", "targetname" );
	wait 0,1;
	self thread go_path( nd_start );
	self thread bp2_vehicle_destroyed();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread nag_destroy_vehicle();
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	nd_arch = getvehiclenode( "node_btr1_arch", "targetname" );
	nd_arch waittill( "trigger" );
	self setspeedimmediate( 0 );
}

wave2bp2_btr2_behavior()
{
	self endon( "death" );
	nd_start = getvehiclenode( "wave2bp2_btr2_startnode", "targetname" );
	wait 0,1;
	self thread go_path( nd_start );
	self thread bp2_vehicle_destroyed();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread nag_destroy_vehicle();
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	nd_wait = getvehiclenode( "wave2bp2_btr2_wait", "targetname" );
	nd_wait waittill( "trigger" );
	self setspeedimmediate( 0 );
	wait randomintrange( 3, 7 );
	self resumespeed( 5 );
	nd_cache = getvehiclenode( "wave2bp2_btr2_cache", "targetname" );
	nd_cache waittill( "trigger" );
	self setspeedimmediate( 0 );
	wait randomintrange( 5, 7 );
	self resumespeed( 5 );
	nd_stop = getvehiclenode( "wave2bp2_btr2_stop", "targetname" );
	nd_stop waittill( "trigger" );
	self setspeedimmediate( 0 );
}

wave2bp2_tank_logic()
{
	self endon( "death" );
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
		level.zhao thread say_dialog( "zhao_russian_tank_0", 1 );
		wait 3;
		level.woods thread say_dialog( "wood_take_down_that_damn_0", 0 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	nd_start = getvehiclenode( "wave2bp2_tank_startnode", "targetname" );
	wait 0,1;
	self thread go_path( nd_start );
	self.overridevehicledamage = ::tank_damage;
	self thread bp2_vehicle_destroyed();
	self thread nag_destroy_vehicle();
	self thread tank_targetting();
	self thread projectile_fired_at_tank();
	nd_cache = getvehiclenode( "node_bp2_under_arch", "targetname" );
	nd_cache waittill( "trigger" );
	self setspeedimmediate( 0 );
	if ( !flag( "arch_destroyed" ) )
	{
		self thread destroy_arch_upon_death();
		level.woods thread say_dialog( "wood_use_this_bring_dow_0", 0 );
		set_objective( level.obj_bp2_arch, getstruct( "arch_target", "targetname" ), "target" );
		level thread arch_target();
	}
}

destroy_arch_upon_death()
{
	level endon( "arch_destroyed" );
	self waittill( "death" );
	level thread clip_under_arch();
	level.player thread say_dialog( "maso_it_s_coming_down_0", 0,5 );
	level.woods thread say_dialog( "wood_fucking_a_0", 2 );
	set_objective( level.obj_bp2_arch, getstruct( "arch_target", "targetname" ), "remove" );
	flag_set( "arch_destroyed" );
}

bp2wave2_hind_logic()
{
	self endon( "death" );
	target_set( self, ( -50, 0, -32 ) );
	self thread bp2_vehicle_destroyed();
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp2wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp2wave3_vehicles, self, "destroy", -1 );
	}
	s_goal01 = getstruct( "bp2_hind_goal01", "targetname" );
	s_goal02 = getstruct( "bp2_hind_goal02", "targetname" );
	s_goal03 = getstruct( "bp2_hind_goal03", "targetname" );
	s_goal04 = getstruct( "bp2_hind_goal04", "targetname" );
	s_goal05 = getstruct( "bp2_hind_goal05", "targetname" );
	s_goal06 = getstruct( "bp2_hind_goal06", "targetname" );
	s_goal07 = getstruct( "bp2_hind_goal07", "targetname" );
	s_goal08 = getstruct( "bp2_hind_goal08", "targetname" );
	s_goal09 = getstruct( "bp2_hind_goal09", "targetname" );
	s_goal10 = getstruct( "bp2_hind_goal10", "targetname" );
	weapons_cache = getent( "ammo_cache_BP2_destroyed", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 15 );
	self setvehgoalpos( s_goal01.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread hind_strafe();
	self setvehgoalpos( s_goal02.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal03.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self notify( "stop_strafe" );
	self setvehgoalpos( s_goal05.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal06.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal07.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal08.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal09.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal10.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self thread bp2_hind_attackpoint();
	flag_wait( "attack_cache_bp2" );
	self notify( "stop_hind_attack" );
	self thread bp2_hind_attack_cache();
	flag_wait( "cache_destroyed_bp2" );
	self notify( "cache_destroyed" );
	s_base = getstruct( "hind_bp3_goal12", "targetname" );
	self clearlookatent();
	self setspeed( 50, 50, 15 );
	self setvehgoalpos( s_base.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self thread hind_baseattack();
}

bp2_hind_attackpoint()
{
	self endon( "death" );
	self endon( "stop_hind_attack" );
	a_s_right = [];
	a_s_right[ 0 ] = getstruct( "bp2_hind_right01", "targetname" );
	a_s_right[ 1 ] = getstruct( "bp2_hind_right02", "targetname" );
	a_s_right[ 2 ] = getstruct( "bp2_hind_right03", "targetname" );
	a_s_right[ 3 ] = getstruct( "bp2_hind_right04", "targetname" );
	a_s_left = [];
	a_s_left[ 0 ] = getstruct( "bp2_hind_left01", "targetname" );
	a_s_left[ 1 ] = getstruct( "bp2_hind_left02", "targetname" );
	a_s_left[ 2 ] = getstruct( "bp2_hind_left03", "targetname" );
	a_s_left[ 3 ] = getstruct( "bp2_hind_left04", "targetname" );
	s_attackpt = a_s_right[ randomint( a_s_right.size ) ];
	self.loc = "right";
	if ( cointoss() )
	{
		s_attackpt = a_s_left[ randomint( a_s_left.size ) ];
		self.loc = "left";
	}
	e_goal = spawn( "script_origin", s_attackpt.origin );
	self setlookatent( e_goal );
	self setspeed( 100, 50, 15 );
	self setvehgoalpos( s_attackpt.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self clearlookatent();
	e_goal delete();
	while ( 1 )
	{
		if ( self.loc == "right" )
		{
			s_attackpt = a_s_left[ randomint( a_s_left.size ) ];
			self.loc = "left";
		}
		else
		{
			s_attackpt = a_s_right[ randomint( a_s_right.size ) ];
			self.loc = "right";
		}
		e_goal = spawn( "script_origin", s_attackpt.origin );
		self setlookatent( e_goal );
		self setvehgoalpos( s_attackpt.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		self clearlookatent();
		e_goal delete();
		self bp2_hind_attack();
	}
}

bp2_hind_attack()
{
	self endon( "death" );
	a_enemies = getaiarray( "allies" );
	a_targets = sort_by_distance( a_enemies, self.origin );
	e_target = level.player;
	if ( cointoss() )
	{
		ai_muj = a_targets[ randomint( a_targets.size ) ];
		if ( isDefined( ai_muj ) )
		{
			e_target = ai_muj;
		}
		else
		{
			e_target = level.player;
		}
	}
	self setlookatent( e_target );
	wait 2;
	self hind_fireat_target( e_target );
	wait randomfloatrange( 2, 3 );
	self clearlookatent();
}

bp2_hind_attack_cache()
{
	self endon( "death" );
	self endon( "cache_destroyed" );
	s_cache1 = getstruct( "bp2_hind_cache1", "targetname" );
	s_cache2 = getstruct( "bp2_hind_cache2", "targetname" );
	s_cache3 = getstruct( "bp2_hind_cache3", "targetname" );
	s_cache4 = getstruct( "bp2_hind_cache4", "targetname" );
	m_weapons_cache = getent( "bp2_cache_origin", "targetname" );
	self setspeed( 100, 50, 15 );
	self setvehgoalpos( s_cache1.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self setlookatent( m_weapons_cache );
	while ( 1 )
	{
		self setvehgoalpos( s_cache2.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
		self setvehgoalpos( s_cache3.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
		self setvehgoalpos( s_cache4.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
		self setvehgoalpos( s_cache3.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
		self setvehgoalpos( s_cache2.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
		self setvehgoalpos( s_cache1.origin, 1 );
		self waittill_any( "goal", "near_goal" );
		wait 1;
		hind_fireat_target( m_weapons_cache );
	}
}

wave2_bp3_main()
{
	event_setup_wave2_bp3();
	init_spawn_funcs_wave2_bp3();
	wave2_bp3();
}

event_setup_wave2_bp3()
{
	level.n_bp3_soviet_killed = 0;
	level.n_bp3_muj_killed = 0;
	t_bp3_uaz = getent( "spawn_wave2_bp3", "targetname" );
	t_bp3_uaz trigger_on();
}

init_spawn_funcs_wave2_bp3()
{
	add_spawn_function_group( "bp3_rider_victim", "script_noteworthy", ::rider_victim_logic );
	add_spawn_function_group( "bp3_muj_bridge1", "targetname", ::muj_bridge1_logic );
	add_spawn_function_group( "bp3_muj_bridge2", "targetname", ::muj_bridge2_logic );
	add_spawn_function_group( "bp3_muj_initial", "targetname", ::muj_initial_logic );
	add_spawn_function_group( "bp3_muj_bridge", "targetname", ::muj_bridge_crosser_logic );
	add_spawn_function_group( "bp3_foot_soldier", "targetname", ::foot_soldier_logic );
	add_spawn_function_group( "bp3_exit_muj", "targetname", ::bp3_exit_muj_logic );
	add_spawn_function_group( "sniper_bp3", "targetname", ::sniper_logic );
	add_spawn_function_group( "bp3_crew_assault", "targetname", ::bp3_soviet_bridge_logic );
	add_spawn_function_group( "bridge_sniper", "script_noteworthy", ::bridge_sniper_logic );
	add_spawn_function_group( "bp3_upper_bridge", "targetname", ::bp3_soviet_firstbridge_logic );
	add_spawn_function_group( "upper_bridge_crosser", "script_noteworthy", ::upper_bridge_logic );
	add_spawn_function_group( "bp3_hip_rappel", "script_noteworthy", ::bp3_hip_rappel_logic );
	add_spawn_function_group( "bp3_exit_soviet", "targetname", ::bp3_exit_soviet_logic );
	add_spawn_function_group( "bp3_wave2_spawner", "targetname", ::bp3_soviet_logic );
	add_spawn_function_group( "assault_soviet", "targetname", ::assault_soviet_logic );
	add_spawn_function_group( "pulwar_victim", "targetname", ::pulwar_victim_logic );
	add_spawn_function_group( "btr1_support", "targetname", ::assault_soviet_logic );
	add_spawn_function_group( "btr2_support", "targetname", ::bp3_soviet_logic );
}

wave2_bp3()
{
	level.n_bp3_veh_destroyed = 0;
	level.n_bp3_bridges = 0;
	if ( level.wave2_loc == "blocking point 3" )
	{
		level.zhao_horse thread zhao_bp3();
		level.woods_horse thread woods_bp3();
	}
	level thread objectives_bp3();
	level thread bp3_approach_explosions();
	level thread monitor_muj_group();
	level thread defenders_bp3();
	level thread bp3_replenish_arena();
	level thread fxanim_bridges();
	level thread enemy_blowup_bridge();
	level thread fxanim_statue();
	level thread fxanim_statue_entrance();
	level thread fxanim_statue_end();
	m_damage = getent( "ammo_cache_BP3_destroyed", "targetname" );
	level thread monitor_weapons_cache( m_damage, "cache_destroyed_bp3" );
	t_pulwar_victim = getent( "trigger_pulwar_victim", "targetname" );
	t_pulwar_victim trigger_on();
	sp_sniper = getent( "sniper_bp3", "targetname" );
	bp3_sniper = sp_sniper spawn_ai( 1 );
	level thread bp3_backup_horse();
	trigger_wait( "spawn_wave2_bp3" );
	flag_set( "bp_underway" );
	level.mason_horse thread mason_horse_return_bp3();
	level thread spawn_heli_attack();
	level thread bridge_over_uaz();
	autosave_by_name( "wave2bp3_start" );
	if ( level.wave2_loc == "blocking point 3" )
	{
		flag_set( "wave2_started" );
	}
	else
	{
		flag_set( "wave3_started" );
		flag_set( "player_at_bp3wave3" );
		wait 1;
		level.zhao_horse thread zhao_bp3();
		level.woods_horse thread woods_bp3();
		set_objective( level.obj_follow_bp3, level.zhao, "remove" );
	}
	level thread vo_bp3();
	level thread spawn_uaz_bp3();
	if ( level.wave2_loc == "blocking point 3" )
	{
		flag_wait( "wave2_done" );
		setmusicstate( "AFGHAN_WAVE3_PART1" );
		level.woods say_dialog( "wood_hell_yeah_0", 0 );
		if ( level.press_demo )
		{
			wait 1;
			screen_fade_out( 2 );
			nextmission();
		}
		else
		{
			level.woods say_dialog( "huds_mason_the_russians_0", 1 );
			level.zhao say_dialog( "zhao_we_must_move_to_defe_0", 1 );
			setmusicstate( "AFGHAN_WAVE3_PART1" );
		}
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			flag_wait( "bp3wave3_done" );
		}
	}
	flag_clear( "bp_underway" );
}

objectives_bp3()
{
	flag_wait( "bridges_obj" );
	autosave_by_name( "bp3_bridges" );
	set_objective( level.obj_afghan_bp3, level.zhao, "remove" );
	flag_wait( "bp3_spawn_vehicles" );
	if ( level.wave2_loc == "blocking point 3" )
	{
		set_objective( level.obj_afghan_bp3wave2_vehicles, undefined, undefined, level.n_bp3_veh_destroyed );
		flag_wait( "wave2_done" );
	}
	else
	{
		flag_wait( "bp3wave3_done" );
	}
	level thread delete_bp3_vehicles_objectives();
	set_objective( level.obj_afghan_bp3, undefined, "done" );
	level.player thread waittill_player_onhorse_bp3exit();
	level.player thread player_leaving_bp3_onfoot();
	if ( !level.player is_on_horseback() )
	{
		set_objective( level.obj_follow_bp3, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
		flag_wait( "player_onhorse_bp3exit" );
		set_objective( level.obj_follow_bp3, level.mason_horse, "remove" );
	}
	if ( level.wave2_loc == "blocking point 3" )
	{
		if ( !flag( "bp3_exit" ) )
		{
			set_objective( level.obj_follow_bp3, level.zhao, "follow" );
		}
	}
}

delete_bp3_vehicles_objectives()
{
	wait 1;
	if ( level.wave2_loc == "blocking point 3" )
	{
		set_objective( level.obj_afghan_bp3wave2_vehicles, undefined, "delete" );
	}
	else
	{
		set_objective( level.obj_afghan_bp3wave3_vehicles, undefined, "delete" );
	}
}

waittill_player_onhorse_bp3exit()
{
	level endon( "player_onhorse_bp3exit" );
	while ( !level.player is_on_horseback() )
	{
		wait 0,1;
	}
	flag_set( "player_onhorse_bp3exit" );
}

player_leaving_bp3_onfoot()
{
	level endon( "player_onhorse_bp3exit" );
	trigger_wait( "replenish_bp3" );
	if ( !level.player is_on_horseback() )
	{
		flag_set( "player_onhorse_bp3exit" );
	}
}

bridge3_objective()
{
	m_bridge3 = getent( "pristine_bridge01_long_break", "targetname" );
	if ( !flag( "bridges_obj" ) )
	{
		set_objective( level.obj_afghan_bridges, undefined, undefined, level.n_bp3_bridges );
		flag_set( "bridges_obj" );
	}
	flag_set( "bridge3_obj" );
	set_objective( level.obj_afghan_bridges, m_bridge3, "destroy", -1 );
}

bridge4_objective()
{
	m_bridge4 = getent( "pristine_bridge02_long_break", "targetname" );
	if ( !flag( "bridges_obj" ) )
	{
		set_objective( level.obj_afghan_bridges, undefined, undefined, level.n_bp3_bridges );
		flag_set( "bridges_obj" );
	}
	flag_set( "bridge4_obj" );
	set_objective( level.obj_afghan_bridges, m_bridge4, "destroy", -1 );
}

spawn_uaz_bp3()
{
	s_spawnpt = getstruct( "bp3_uaz1_spawnpt", "targetname" );
	vh_uaz1 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz1.origin = s_spawnpt.origin;
	vh_uaz1.angles = s_spawnpt.angles;
	vh_uaz1.targetname = "bp3_uaz1";
	vh_uaz1 thread uaz_bp3_logic( getvehiclenode( "bp3_uaz1_startnode", "targetname" ) );
	s_spawnpt = getstruct( "bp3_uaz2_spawnpt", "targetname" );
	vh_uaz2 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz2.origin = s_spawnpt.origin;
	vh_uaz2.angles = s_spawnpt.angles;
	vh_uaz2.targetname = "bp3_uaz2";
	vh_uaz2 thread uaz_bp3_logic( getvehiclenode( "bp3_uaz2_startnode", "targetname" ) );
	wait 1;
	level thread monitor_bp3uaz_soviet();
}

uaz_bp3_logic( nd_start )
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	i = 0;
	while ( i < 2 )
	{
		n_aitype = randomint( 10 );
		if ( n_aitype < 5 )
		{
			sp_rider = getent( "soviet_assault", "targetname" );
		}
		else if ( n_aitype < 8 )
		{
			sp_rider = getent( "soviet_smg", "targetname" );
		}
		else
		{
			sp_rider = getent( "soviet_lmg", "targetname" );
		}
		ai_rider = sp_rider spawn_ai( 1 );
		if ( isDefined( ai_rider ) )
		{
			ai_rider.script_combat_getout = 1;
			ai_rider.targetname = "bp3_uaz_soviet";
			ai_rider thread bp3_uaz_logic();
			wait 0,05;
			ai_rider enter_vehicle( self );
		}
		i++;
	}
	self thread go_path( nd_start );
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

monitor_bp3uaz_soviet()
{
	while ( 1 )
	{
		a_ai_guys = getentarray( "bp3_uaz_soviet", "targetname" );
		if ( a_ai_guys.size < 3 )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	flag_set( "uaz_guys_dead" );
}

btr_chase()
{
	s_spawnpt = getstruct( "btr_chase_spawnpt1", "targetname" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		s_spawnpt = getstruct( "btr_chase_spawnpt2", "targetname" );
	}
	vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_spawnpt.origin;
	vh_btr.angles = s_spawnpt.angles;
	vh_btr.targetname = "btr_chase";
	vh_btr thread btr_chase_logic();
	vh_btr thread monitor_btr_chase_death();
	flag_wait( "spawn_btr_chase" );
	wait 2;
	level.woods say_dialog( "wood_dammit_we_got_a_btr_0", 1 );
	level.woods say_dialog( "wood_i_m_going_after_the_0", 0,5 );
}

btr_chase_logic()
{
	self endon( "death" );
	flag_set( "btr_chase_spawned" );
	flag_wait( "spawn_btr_chase" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		self thread go_path( getvehiclenode( "startnode_btr_chase2", "targetname" ) );
	}
	else
	{
		self thread go_path( getvehiclenode( "startnode_btr_chase1", "targetname" ) );
	}
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self waittill( "reached_end_node" );
	self thread btr_chase_attack_cache();
}

btr_chase_attack_cache()
{
	self endon( "death" );
	self notify( "stop_attack" );
	cache7_pris = getent( "ammo_cache_arena_7_pristine", "targetname" );
	cache7_dest = getent( "ammo_cache_arena_7_destroyed", "targetname" );
	cache7_clip = getent( "ammo_cache_arena_7_clip", "targetname" );
	self set_turret_target( cache7_dest, vectorScale( ( 0, 0, 0 ), 42 ), 1 );
	self thread fire_turret_for_time( 8, 1 );
	wait 5;
	wait 2;
	playfx( level._effect[ "cache_dest" ], cache7_dest.origin );
	cache7_pris delete();
	cache7_clip delete();
	cache7_dest show();
	self thread muj_kill_btr_chase();
}

muj_kill_btr_chase()
{
	level endon( "btr_chase_dead" );
	magicbullet( "afghanstinger_sp", ( 11932, -6530, 1077,7 ), self.origin, undefined, self, vectorScale( ( 0, 0, 0 ), 30 ) );
	wait 2;
	if ( isalive( self ) )
	{
		radiusdamage( self.origin, 100, 5000, 4000 );
	}
}

monitor_btr_chase_death()
{
	self waittill( "death", attacker );
	flag_set( "btr_chase_dead" );
	if ( attacker == level.player )
	{
		flag_set( "player_killed_btr" );
		level.player say_dialog( "maso_i_ve_got_him_0", 0,5 );
		level.woods say_dialog( "wood_fuck_yeah_mason_y_0", 0,5 );
		level.woods say_dialog( "wood_zhao_needs_our_help_0", 0,5 );
		return;
	}
}

bp3_exit_battle_spawn()
{
	spawn_manager_enable( "manager_bp3_exit_muj" );
	s_spawnpt = getstruct( "bp3_exit_chopper_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawnpt.origin;
	vh_hip.angles = s_spawnpt.angles;
	vh_hip thread bp3_exit_chopper_behavior();
	spawn_manager_enable( "manager_bp3_exit_soviet" );
	level thread spawn_bp3_exit_battle_horses();
}

spawn_bp3_exit_battle_horses()
{
	s_horse_spawnpt = getstruct( "bp3_exit_horse_spawnpt", "targetname" );
	vh_horses = [];
	i = 0;
	while ( i < 4 )
	{
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horses[ i ].origin = s_horse_spawnpt.origin;
		vh_horses[ i ].angles = s_horse_spawnpt.angles;
		vh_horses[ i ] thread bp3_exit_battle_horse_behavior();
		vh_horses[ i ] setvehicleavoidance( 1, undefined, 3 );
		wait 0,3;
		i++;
	}
}

bp3_exit_battle_horse_behavior()
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self makevehicleunusable();
	s_goal = getstruct( "exit_battle_horse_goal4", "targetname" );
	self setspeed( 45, 40, 10 );
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp3_exit_chopper_behavior()
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setforcenocull();
	self setneargoalnotifydist( 500 );
	self.overridevehicledamage = ::heli_vehicle_damage;
	target_set( self, ( -50, 0, -32 ) );
	self thread heli_select_death();
	waittill_spawn_manager_complete( "manager_bp3_exit_soviet" );
	s_spawnpt = getstruct( "bp3_exit_chopper_spawnpt", "targetname" );
	s_goal0 = getstruct( "bp3_exit_chopper_goal0", "targetname" );
	s_goal1 = getstruct( "bp3_exit_chopper_goal1", "targetname" );
	s_goal2 = getstruct( "bp3_exit_chopper_goal2", "targetname" );
	s_goal3 = getstruct( "bp3_exit_chopper_goal3", "targetname" );
	self setspeed( 50, 20, 10 );
	self setvehgoalpos( s_goal0.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 80, 40, 10 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 120, 50, 10 );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 150, 50, 10 );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp3_vehicle_chooser()
{
	level endon( "stop_sandbox" );
	level thread spawn_hip1_bp3();
	flag_set( "spawn_hip1_bp3" );
	wait 5;
	flag_set( "heli_spawned" );
	level thread spawn_hip2_bp3();
	flag_set( "spawn_hip2_bp3" );
	wait 20;
	s_spawnpt = getstruct( "btr1_bp3_spawnpt", "targetname" );
	vh_btr1 = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr1.origin = s_spawnpt.origin;
	vh_btr1.angles = s_spawnpt.angles;
	vh_btr1 thread bp3_btr1_logic();
	flag_set( "spawn_btr1_bp3" );
	while ( isalive( vh_btr1 ) )
	{
		wait 0,05;
	}
	flag_set( "spawn_btr1_bp3" );
	wait 5;
	level thread spawn_hip1_bp3();
	flag_set( "spawn_hip1_bp3" );
	wait 5;
	flag_set( "heli_spawned" );
}

bp3wave3_boss_chooser()
{
	wait 2;
	if ( cointoss() )
	{
		s_spawnpt = getstruct( "bp3wave3_hind_spawnpt", "targetname" );
		vh_hind = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind.origin = s_spawnpt.origin;
		vh_hind.angles = s_spawnpt.angles;
		vh_hind.targetname = "bp3wave3_hind";
		vh_hind thread maps/afghanistan_wave_3::bp3wave3_hind_behavior();
		flag_set( "bp3wave3_hind" );
	}
	else
	{
		s_spawnpt = getstruct( "wave3bp3_tank_spawnpt", "targetname" );
		vh_tank2 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank2.origin = s_spawnpt.origin;
		vh_tank2.angles = s_spawnpt.angles;
		vh_tank2.targetname = "bp3wave3_tank";
		vh_tank2 thread maps/afghanistan_wave_3::bp3wave3_tank_behavior();
		flag_set( "bp3wave3_tank" );
	}
}

vo_bp3()
{
	if ( level.n_current_wave == 3 )
	{
		level.woods say_dialog( "wood_mason_same_drill_0", 0 );
	}
	level.zhao say_dialog( "zhao_the_mujahideen_are_p_0", 0 );
	level.woods say_dialog( "wood_mason_take_the_high_0", 1,5 );
	level.woods say_dialog( "wood_get_on_the_ledges_0", 0,5 );
	level thread vo_bridge_destroyed();
	flag_wait_any( "bridge4_obj", "bridge4_destroyed" );
	level.woods say_dialog( "wood_mason_rpg_bring_d_0", 0,5 );
	level.player say_dialog( "maso_cover_me_i_ll_hit_0", 0,5 );
	if ( flag( "bridge4_obj" ) )
	{
		level.woods say_dialog( "wood_fucking_bridges_are_0", 1 );
		level.woods say_dialog( "wood_the_bridge_mason_0", 1 );
	}
	setmusicstate( "AFGHAN_WAVE2_PART2" );
	flag_wait_any( "bridge3_obj", "bridge3_destroyed" );
	if ( flag( "bridge3_obj" ) )
	{
		wait 3;
		if ( !flag( "bridge3_destroyed" ) )
		{
			level.woods say_dialog( "wood_put_an_rpg_into_the_0", 0 );
		}
	}
	if ( level.n_current_wave == 2 )
	{
		flag_wait( "hind1_pass" );
		level.woods say_dialog( "wood_i_ve_had_enough_of_t_0", 0 );
	}
}

vo_bridge_destroyed()
{
	flag_wait_any( "bridge3_destroyed", "bridge4_destroyed" );
	if ( !flag( "bridge3_destroyed" ) || !flag( "bridge3_destroyed" ) )
	{
		level.player say_dialog( "maso_got_one_0", 1 );
		level.player say_dialog( "maso_one_more_to_go_0", 0,5 );
	}
}

fxanim_bridges()
{
	m_bridge3_clip = getent( "BP3_bridge_3", "targetname" );
	m_bridge4_clip = getent( "BP3_bridge_4", "targetname" );
	m_bridge3 = getent( "pristine_bridge01_long_break", "targetname" );
	m_bridge4 = getent( "pristine_bridge02_long_break", "targetname" );
	str_bridge3 = "fxanim_bridge01_long_break_start";
	str_bridge4 = "fxanim_bridge02_long_break_start";
	m_bridge3 thread trigger_fxanim_objbridge( m_bridge3_clip, str_bridge3 );
	m_bridge4 thread trigger_fxanim_objbridge( m_bridge4_clip, str_bridge4 );
	m_bridge3_clip thread trigger_fxanim_objbridge_clip( m_bridge3 );
	m_bridge4_clip thread trigger_fxanim_objbridge_clip( m_bridge4 );
}

trigger_fxanim_objbridge_clip( e_bridge )
{
	self setcandamage( 1 );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( isDefined( self ) && type != "MOD_PROJECTILE" && type != "MOD_PROJECTILE_SPLASH" || type == "MOD_EXPLOSIVE" && type == "MOD_EXPLOSIVE_SPLASH" )
		{
			self notify( "damage" );
		}
	}
}

trigger_fxanim_objbridge( m_bridge_clip, str_notify )
{
	self setcandamage( 1 );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type != "MOD_PROJECTILE" && type != "MOD_PROJECTILE_SPLASH" || type == "MOD_EXPLOSIVE" && type == "MOD_EXPLOSIVE_SPLASH" )
		{
			if ( str_notify == "fxanim_bridge01_long_break_start" && attacker == level.player )
			{
				flag_set( "bridge3_destroyed" );
				spawn_manager_disable( "manager_upper_bridge" );
				level thread kill_upper_bridge();
			}
			else
			{
				if ( str_notify == "fxanim_bridge02_long_break_start" && attacker == level.player )
				{
					flag_set( "bridge4_destroyed" );
					spawn_manager_kill( "manager_assaultcrew_bp3" );
					level.n_bp3_bridges++;
				}
			}
			if ( attacker == level.player )
			{
				level.n_bp3_bridges++;
				self thread disable_bridge_nodes();
				m_bridge_clip delete();
				level notify( str_notify );
				self delete();
			}
		}
	}
}

spawn_bp3_vehicles()
{
	if ( level.n_current_wave == 3 )
	{
		set_objective( level.obj_afghan_bp3wave3_vehicles, undefined, undefined, level.n_bp3_veh_destroyed );
		wait 0,1;
		level thread bp3wave2_boss_chooser();
	}
	else
	{
		level thread bp3_vehicle_chooser();
	}
	flag_set( "bp3_spawn_vehicles" );
	level.zhao say_dialog( "zhao_focus_on_the_vehicle_0", 1 );
	level.woods say_dialog( "wood_don_t_let_the_bastar_0", 1 );
}

trigger_fxanim_bridge( m_bridge_clip, str_notify )
{
	self setcandamage( 1 );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type != "MOD_PROJECTILE" && type != "MOD_PROJECTILE_SPLASH" || type == "MOD_EXPLOSIVE" && type == "MOD_EXPLOSIVE_SPLASH" )
		{
			self thread disable_bridge_nodes();
			self delete();
			m_bridge_clip delete();
			level notify( str_notify );
			return;
		}
		else
		{
		}
	}
}

disable_bridge_nodes()
{
	if ( self.targetname == "pristine_bridge01_break" )
	{
		t_bridge = getent( "bridge1_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge1_clip", "targetname" );
		_a5010 = bm_clips;
		_k5010 = getFirstArrayKey( _a5010 );
		while ( isDefined( _k5010 ) )
		{
			bm_clip = _a5010[ _k5010 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5010 = getNextArrayKey( _a5010, _k5010 );
		}
	}
	else if ( self.targetname == "pristine_bridge02_break" )
	{
		t_bridge = getent( "bridge2_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge2_clip", "targetname" );
		_a5025 = bm_clips;
		_k5025 = getFirstArrayKey( _a5025 );
		while ( isDefined( _k5025 ) )
		{
			bm_clip = _a5025[ _k5025 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5025 = getNextArrayKey( _a5025, _k5025 );
		}
	}
	else if ( self.targetname == "pristine_bridge01_long_break" )
	{
		t_bridge = getent( "bridge3_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge3_clip", "targetname" );
		_a5040 = bm_clips;
		_k5040 = getFirstArrayKey( _a5040 );
		while ( isDefined( _k5040 ) )
		{
			bm_clip = _a5040[ _k5040 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5040 = getNextArrayKey( _a5040, _k5040 );
		}
	}
	else t_bridge = getent( "bridge4_physics_trigger", "targetname" );
	t_bridge thread bridge_destruction_physics();
	t_bridge thread bridge_destruction_kill();
	bm_clips = getentarray( "bridge4_clip", "targetname" );
	_a5055 = bm_clips;
	_k5055 = getFirstArrayKey( _a5055 );
	while ( isDefined( _k5055 ) )
	{
		bm_clip = _a5055[ _k5055 ];
		bm_clip trigger_on();
		bm_clip disconnectpaths();
		_k5055 = getNextArrayKey( _a5055, _k5055 );
	}
	spawn_manager_kill( "manager_assaultcrew_bp3" );
}

bridge_destruction_kill()
{
	a_ai_guys = getaiarray( "all" );
	_a5070 = a_ai_guys;
	_k5070 = getFirstArrayKey( _a5070 );
	while ( isDefined( _k5070 ) )
	{
		ai_guy = _a5070[ _k5070 ];
		if ( ai_guy istouching( self ) && isDefined( ai_guy ) )
		{
			radiusdamage( ai_guy.origin, 100, ai_guy.health, ai_guy.health, undefined, "MOD_PROJECTILE" );
		}
		_k5070 = getNextArrayKey( _a5070, _k5070 );
	}
}

bridge_destruction_physics()
{
	wait 1;
	a_ai_corpses = entsearch( level.contents_corpse, self.origin, 1200 );
	_a5086 = a_ai_corpses;
	_k5086 = getFirstArrayKey( _a5086 );
	while ( isDefined( _k5086 ) )
	{
		ai_corpse = _a5086[ _k5086 ];
		if ( ai_corpse istouching( self ) )
		{
			if ( ai_corpse isragdoll() )
			{
				physicsexplosionsphere( ai_corpse.origin, 10, 5, 0,01 );
			}
		}
		_k5086 = getNextArrayKey( _a5086, _k5086 );
	}
	wait 1;
	delete_ents( level.contents_corpse, self.origin, 1200 );
	self delete();
}

bp3_replenish_arena()
{
	trigger_wait( "spawn_wave2_bp3" );
	trigger_wait( "bp3_replenish_arena" );
	if ( !flag( "wave2_done" ) )
	{
		level thread replenish_bp3();
		level thread vo_nag_get_back( "bp3_exit" );
	}
	else
	{
		level thread vo_get_horse();
	}
	if ( level.n_current_wave == 3 && !flag( "bp3wave3_done" ) )
	{
		level thread replenish_bp3();
	}
	flag_set( "bp3_exit" );
	spawn_manager_disable( "manager_bp3_foot" );
	spawn_manager_disable( "manager_bp3wave2_soviet" );
	spawn_manager_disable( "manager_assaultcrew_bp3" );
	wait 0,1;
	cleanup_bp_ai();
	maps/afghanistan_arena_manager::respawn_arena();
}

replenish_bp3()
{
	trigger_wait( "replenish_bp3" );
	flag_clear( "bp3_exit" );
	spawn_manager_enable( "manager_bp3wave2_soviet" );
	spawn_manager_enable( "manager_bp3_foot" );
	wait 0,1;
	level thread bp3_replenish_arena();
}

defenders_bp3()
{
	trigger_wait( "bp3_defense" );
	if ( flag( "bp3_infantry_event" ) )
	{
		return;
	}
	a_s_spawnpts = [];
	a_vh_horses = [];
	a_nd_startnodes = [];
	i = 0;
	while ( i < 5 )
	{
		a_s_spawnpts[ i ] = getstruct( "bp3_horse_spawnpt" + i, "targetname" );
		a_vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		a_vh_horses[ i ].origin = a_s_spawnpts[ i ].origin;
		a_vh_horses[ i ].angles = a_s_spawnpts[ i ].angles;
		a_vh_horses[ i ] setvehicleavoidance( 1, undefined, 3 );
		a_vh_horses[ i ] thread get_horse_rider();
		a_vh_horses[ i ] thread bp3_horse_logic( getvehiclenode( "bp3_horse_startnode" + i, "targetname" ) );
		wait 0,05;
		i++;
	}
	wait 0,5;
	flag_set( "shoot_rider" );
	s_rpg_target = getstruct( "rpg_sniper_target", "targetname" );
	e_target = spawn( "script_origin", s_rpg_target.origin );
	e_rpg = magicbullet( "rpg_magic_bullet_sp", ( 2200, -3374, 644 ), e_target.origin );
	e_rpg thread rpg_horse_explosion();
	level thread rpg_destroy_statue_entrance();
	a_s_spawnpts = undefined;
	a_vh_horses = undefined;
}

get_horse_rider()
{
	self endon( "death" );
	ai_rider = get_muj_ai();
	wait 0,05;
	if ( isDefined( ai_rider ) )
	{
		ai_rider thread bp3_horserider_logic();
		ai_rider.targetname = "bp3_horserider";
		ai_rider enter_vehicle( self );
	}
	wait 0,05;
	self notify( "groupedanimevent" );
	if ( isDefined( ai_rider ) )
	{
		ai_rider maps/_horse_rider::ride_and_shoot( self );
	}
}

zhao_bp3()
{
	level.zhao ai_dismount_horse( self );
	level.zhao set_force_color( "r" );
	flag_set( "zhao_at_bp3" );
	level.zhao thread zhao_set_ignore();
	level.zhao thread zhao_shootat_chopper();
	self horse_panic();
	self clearvehgoalpos();
	wait 1;
	s_runoff = getstruct( "zhao_bp3_exit", "targetname" );
	self setvehgoalpos( s_runoff.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
}

zhao_set_ignore()
{
	trigger_wait( "trigger_pulwar_victim" );
	self set_ignoreme( 1 );
	wait 6;
	self set_ignoreme( 0 );
}

zhao_shootat_chopper()
{
	flag_wait( "bp3_hip_arrival" );
	vh_hip = getent( "bp3_heli_hip", "targetname" );
	if ( isDefined( vh_hip ) )
	{
		self shoot_at_target_untill_dead( vh_hip );
	}
}

enable_bridge2_destruction()
{
	t_bridge = getent( "trigger_zhao_across", "targetname" );
	while ( !self istouching( t_bridge ) )
	{
		wait 1;
	}
	m_bridge2_clip = getent( "BP3_bridge_2", "targetname" );
	m_bridge2 = getent( "pristine_bridge02_break", "targetname" );
	str_bridge2 = "fxanim_bridge02_break_start";
	m_bridge2 thread trigger_fxanim_bridge( m_bridge2_clip, str_bridge2 );
	t_bridge delete();
	if ( distance2dsquared( self.origin, level.player.origin ) > 1440000 )
	{
		self say_dialog( "zhao_stay_with_me_mason_1", 0 );
	}
}

woods_bp3()
{
	level endon( "woods_ride_with_player" );
	s_woods = getstruct( "woods_bp3", "targetname" );
	self setvehgoalpos( s_woods.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	flag_set( "woods_getting_off_horse" );
	level.woods ai_dismount_horse( self );
	level.woods set_force_color( "b" );
	flag_set( "zhao_at_bp3" );
	self horse_panic();
	self horse_rearback();
	self clearvehgoalpos();
	wait 1;
	s_runoff = getstruct( "woods_bp3_exit", "targetname" );
	self setvehgoalpos( s_runoff.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	flag_clear( "woods_getting_off_horse" );
}

mason_horse_return_bp3()
{
	while ( level.player is_on_horseback() )
	{
		wait 1;
	}
	self makevehicleunusable();
	wait 1;
	self horse_rearback();
	wait 2;
	s_runoff = getstruct( "woods_bp3_exit", "targetname" );
	self setvehgoalpos( s_runoff.origin + vectorScale( ( 0, 0, 0 ), 300 ), 1, 1 );
	flag_wait( "wave2_done" );
	s_return = getstruct( "zhao_bp3", "targetname" );
	self setvehgoalpos( s_return.origin + vectorScale( ( 0, 0, 0 ), 300 ), 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self makevehicleusable();
}

bp3_backup_horse()
{
	s_spawnpt = getstruct( "bp3_hitch", "targetname" );
	horse = spawn_vehicle_from_targetname( "mason_horse" );
	horse.origin = s_spawnpt.origin;
	horse.angles = s_spawnpt.angles;
	horse makevehicleusable();
	horse veh_magic_bullet_shield( 1 );
	horse thread horse_panic();
}

zhao_bp2_exit_battle()
{
	s_bp2_exit_divert = getstruct( "bp2_exit_divert", "targetname" );
	s_bp2_exit_battle = getstruct( "bp2_exit_battle_zhao", "targetname" );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_bp2_exit_divert.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_bp2_exit_battle.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	level.zhao ai_dismount_horse( self );
	level.zhao set_spawner_targets( "bp2_cache_perimeter" );
	flag_wait( "bp2_exit_done" );
	level.zhao ai_mount_horse( self );
	if ( level.wave2_loc == "blocking point 2" )
	{
		self thread maps/afghanistan_wave_3::follow_player();
	}
}

woods_bp2_exit_battle()
{
	s_bp2_exit_divert = getstruct( "bp2_exit_divert", "targetname" );
	s_bp2_exit_battle = getstruct( "bp2_exit_battle_woods", "targetname" );
	wait 1;
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_bp2_exit_divert.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_bp2_exit_battle.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	level.woods ai_dismount_horse( self );
	level.woods set_spawner_targets( "bp2_cache_perimeter" );
	flag_wait( "bp2_exit_done" );
	level.woods ai_mount_horse( self );
	if ( level.wave2_loc == "blocking point 2" )
	{
		self thread maps/afghanistan_wave_3::follow_player();
	}
}

zhao_bp3exit()
{
	s_bp3_exit = getstruct( "zhao_bp3_exit", "targetname" );
	level.zhao thread teleport_ai( self.origin + vectorScale( ( 0, 0, 0 ), 150 ), self.angles );
	level.zhao ai_mount_horse( self );
	wait 1;
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_bp3_exit.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	if ( level.wave2_loc == "blocking point 3" )
	{
		self horse_stop();
		self thread maps/afghanistan_wave_3::follow_player();
	}
	else
	{
		level.zhao_horse thread maps/afghanistan_wave_3::zhao_goto_bp1wave3();
	}
}

woods_bp3exit()
{
	s_bp3_exit = getstruct( "woods_bp3_exit", "targetname" );
	level.woods thread teleport_ai( self.origin + vectorScale( ( 0, 0, 0 ), 150 ), self.angles );
	level.woods ai_mount_horse( self );
	wait 1;
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_bp3_exit.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	if ( level.wave2_loc == "blocking point 3" )
	{
		self horse_stop();
		self thread maps/afghanistan_wave_3::follow_player();
	}
	else
	{
		if ( flag( "bp3wave3_tank" ) )
		{
			flag_wait_any( "bp3wave3_tank_chase", "bp3wave3_tank_chase_dead" );
		}
		else
		{
			if ( flag( "bp3wave3_hind" ) )
			{
				flag_wait_any( "bp3wave3_hind_chase", "bp3wave3_hind_chase_dead" );
			}
		}
		wait 0,5;
		if ( flag( "bp3wave3_tank_chase" ) || flag( "bp3wave3_hind_chase" ) )
		{
			self thread defend_against_wave3_vehicle( level.woods );
			self stop_wave3_vehicle_dead( level.woods );
		}
		level.woods_horse thread maps/afghanistan_wave_3::woods_goto_bp1wave3();
	}
}

bp3wave2_boss_chooser()
{
	s_spawnpt = getstruct( "bp3_hind1_spawnpt", "targetname" );
	vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
	vh_hind1.origin = s_spawnpt.origin;
	vh_hind1.angles = s_spawnpt.angles;
	vh_hind1 thread bp3_hind1_logic();
	flag_set( "wave2bp3_hind" );
}

bp3_horserider_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self set_force_color( "g" );
	self waittill( "enter_vehicle", vehicle );
	vehicle notify( "groupedanimevent" );
	self maps/_horse_rider::ride_and_shoot( vehicle );
}

bp3_horse_logic( nd_start )
{
	self endon( "death" );
	self thread go_path( nd_start );
	self waittill( "reached_end_node" );
	if ( isalive( self.riders[ 0 ] ) )
	{
		self.riders[ 0 ] notify( "stop_riding" );
		wait 0,05;
		self waittill( "unloaded" );
	}
	wait 1;
	self vehicle_detachfrompath();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 300 );
	self setvehgoalpos( self.origin, 1, 1 );
	if ( randomint( 3 ) == 1 )
	{
		self horse_rearback();
	}
	self thread kill_disobedient_horse();
	s_rideoff = getstruct( "bp3_horse_rideoff", "targetname" );
	self setspeed( 20, 10, 5 );
	self setvehgoalpos( s_rideoff.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

kill_disobedient_horse()
{
	self endon( "death" );
	wait randomintrange( 5, 10 );
	if ( distance2dsquared( self.origin, level.player.origin ) < 4000000 )
	{
		radiusdamage( self.origin, 100, 5000, 5000 );
	}
}

rider_victim_logic()
{
	self endon( "death" );
	level.rider_victim = self;
	self.script_longdeath = 0;
	wait 0,5;
	flag_wait( "rider_shot" );
	self dodamage( self.health, self.origin );
}

spawn_hip1_bp3()
{
	s_spawnpt = getstruct( "bp3_hip1_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawnpt.origin;
	vh_hip.angles = s_spawnpt.angles;
	vh_hip thread bp3wave2_hip1_logic();
}

spawn_hip2_bp3()
{
	s_spawnpt = getstruct( "bp3_hip2_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawnpt.origin;
	vh_hip.angles = s_spawnpt.angles;
	vh_hip thread bp3wave2_hip2_logic();
}

bp3wave2_hip1_logic()
{
	self endon( "death" );
	self hidepart( "tag_back_door" );
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	self thread damage_on_impact();
	self thread vo_heli_dead();
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self.vehicletype = "heli_hip";
	self thread bp3_vehicle_destroyed();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	s_liftoff = getstruct( "hip1_bp3_liftoff", "targetname" );
	s_ascent = getstruct( "hip1_bp3_ascent", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 50, 20, 10 );
	self setvehgoalpos( s_liftoff.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	sp_rappel = getent( "bp3_hip1_rappel", "targetname" );
	s_dropoff = "hip1_bp3_dropoff";
	self thread vo_hip_rappel();
	n_pos = 2;
	i = 0;
	while ( i < 4 )
	{
		ai_rappeller = sp_rappel spawn_ai( 1 );
		ai_rappeller.script_startingposition = n_pos;
		ai_rappeller enter_vehicle( self );
		n_pos++;
		wait 0,1;
		i++;
	}
	self heli_rappel( s_dropoff );
	trigger_use( "triggercolor_bp3_cache" );
	self setspeed( 100, 20, 10 );
	self setvehgoalpos( s_ascent.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_start = getstruct( "hip_bp3_circle01", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
	flag_wait( "attack_cache_bp3" );
	self notify( "stop_attack" );
	m_damage = getent( "bp3_cache_origin", "targetname" );
	self thread hip_attack_cache( m_damage );
	flag_wait( "cache_destroyed_bp3" );
	self notify( "stop_cache_attack" );
	self notify( "stop_circle" );
	self thread hip_attack();
}

vo_hip_rappel()
{
	self endon( "death" );
	self waittill( "unload" );
	level.player say_dialog( "maso_infantry_fast_roping_0", 0 );
	level.woods say_dialog( "wood_don_t_let_their_feet_0", 0,5 );
}

vo_heli_dead()
{
}

damage_on_impact()
{
	self waittill( "crash_move_done" );
	radiusdamage( self.origin, 800, 2000, 1600, level.player, "MOD_PROJECTILE" );
}

hip_deploy_flares( missile, e_statue )
{
	self endon( "death" );
	self notify( "evade" );
	if ( !isDefined( missile ) )
	{
		return;
	}
	vec_toforward = anglesToForward( self.angles );
	vec_toright = anglesToRight( self.angles );
	self.chaff_fx = spawn( "script_model", self.origin );
	self.chaff_fx.angles = vectorScale( ( 0, 0, 0 ), 180 );
	self.chaff_fx setmodel( "tag_origin" );
	self.chaff_fx linkto( self, "tag_origin", vectorScale( ( 0, 0, 0 ), 120 ), ( 0, 0, 0 ) );
	delta = self.origin - missile.origin;
	dot = vectordot( delta, vec_toright );
	sign = 1;
	if ( dot > 0 )
	{
		sign = -1;
	}
	chaff_dir = vectornormalize( vectorScale( vec_toforward, -0,2 ) + vectorScale( vec_toright, sign ) );
	velocity = vectorScale( chaff_dir, randomintrange( 400, 600 ) );
	velocity = ( velocity[ 0 ], velocity[ 1 ], velocity[ 2 ] - randomintrange( 10, 100 ) );
	self.chaff_fx thread delete_after_time( 5 );
	wait 0,1;
	self.chaff_fx thread play_flares_fx();
	missile missile_settarget( e_statue );
	wait 5;
	if ( isDefined( e_statue ) )
	{
		e_statue delete();
	}
	self.statue_target = 0;
}

bp3wave2_hip2_logic()
{
	self endon( "death" );
	self hidepart( "tag_back_door" );
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	self thread damage_on_impact();
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self.vehicletype = "heli_hip";
	self thread bp3_vehicle_destroyed();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	s_liftoff = getstruct( "hip2_bp3_liftoff", "targetname" );
	s_over = getstruct( "hip2_bp3_over", "targetname" );
	s_approach = getstruct( "hip2_bp3_approach", "targetname" );
	s_dropoff = getstruct( "hip2_bp3_dropoff", "targetname" );
	s_away = getstruct( "hip2_bp3_away", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 50, 20, 10 );
	self setvehgoalpos( s_liftoff.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_over.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_approach.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_dropoff.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 100, 20, 10 );
	self setvehgoalpos( s_away.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_start = getstruct( "hip_bp3_circle01", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
	flag_wait( "attack_cache_bp3" );
	self notify( "stop_attack" );
	m_damage = getent( "bp3_cache_origin", "targetname" );
	self thread hip_attack_cache( m_damage );
	flag_wait( "cache_destroyed_bp3" );
	self notify( "stop_cache_attack" );
	self notify( "stop_circle" );
	self thread hip_attack();
}

heli_rappel( s_drop_pt )
{
	self endon( "death" );
	self sethoverparams( 0, 0, 10 );
	drop_struct = getstruct( s_drop_pt, "targetname" );
	drop_origin = drop_struct.origin;
	drop_offset_tag = "tag_fastrope_ri";
	drop_offset = self gettagorigin( "tag_origin" ) - self gettagorigin( drop_offset_tag );
	drop_offset = ( drop_offset[ 0 ], drop_offset[ 1 ], self.fastropeoffset );
	drop_origin += drop_offset;
	self setvehgoalpos( drop_origin, 1 );
	self waittill( "goal" );
	self notify( "unload" );
	self waittill( "unloaded" );
}

bp3_hip_rappel_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.demo_guy = 1;
	self change_movemode( "cqb_sprint" );
	self set_force_color( "c" );
	self thread force_goal();
}

bp3_infantry_attack_cache()
{
	t_cache = getent( "trigger_bp3_cache_demo", "targetname" );
	m_damage = getent( "ammo_cache_BP3_destroyed", "targetname" );
	n_counter = 0;
	t_cache waittill( "trigger" );
	while ( 1 )
	{
		wait 1;
		n_counter++;
		if ( n_counter > 5 )
		{
			break;
		}
		else
		{
		}
	}
	a_ai_guys = getentarray( "bp3_hip1_rappel_ai", "targetname" );
	if ( !flag( "cache_destroyed_bp3" ) && a_ai_guys.size )
	{
		radiusdamage( m_damage.origin, 300, 100, 100, a_ai_guys[ 0 ], "MOD_PROJECTILE" );
	}
}

bp3_heli_hip_logic()
{
	self endon( "death" );
	self thread go_path( getvehiclenode( "bp3_heli_hip_startnode", "targetname" ) );
	self thread hip_crash();
	target_set( self, ( -50, 0, -32 ) );
	nd_crew = getvehiclenode( "crew_fire", "targetname" );
	nd_fire = getvehiclenode( "fire_turret", "targetname" );
	nd_shoot = getvehiclenode( "shoot_down", "targetname" );
	s_fire = getstruct( "crew_stinger_fire", "targetname" );
	nd_crew waittill( "trigger" );
	self playsound( "veh_heli_flyby_sweet" );
	flag_set( "bp3_hip_arrival" );
	self thread crew_fireat_hip( s_fire );
	nd_fire waittill( "trigger" );
	a_ai_bridge = getaiarray( "allies" );
	self set_turret_target_ent_array( a_ai_bridge, 2 );
	self thread fire_turret_for_time( 6, 2 );
	nd_shoot waittill( "trigger" );
	magicbullet( "stinger_sp", s_fire.origin, self.origin, undefined, self, vectorScale( ( 0, 0, 0 ), 32 ) );
}

hip_crash()
{
	self waittill( "death" );
	wait 1,2;
	self setvehvelocity( self.velocity * 2 );
}

crew_fireat_hip( s_fire )
{
	self endon( "death" );
	magicbullet( "stinger_sp", s_fire.origin, self.origin, undefined, self, vectorScale( ( 0, 0, 0 ), 120 ) );
	wait 1,5;
	magicbullet( "stinger_sp", s_fire.origin, self.origin, undefined, self, vectorScale( ( 0, 0, 0 ), 200 ) );
}

bp3_hind1_logic()
{
	self endon( "death" );
	self setforcenocull();
	self setvehicleavoidance( 1 );
	self thread bp3_vehicle_destroyed();
	self thread go_path( getvehiclenode( "bp3_hind1_startnode", "targetname" ) );
	self.overridevehicledamage = ::hind_vehicle_damage;
	target_set( self, ( -50, 0, -32 ) );
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	nd_shoot = getvehiclenode( "hind_start_shoot", "targetname" );
	nd_shoot waittill( "trigger" );
	self thread hind_rocket_strafe();
	nd_stop = getvehiclenode( "hind_stop_shoot", "targetname" );
	nd_stop waittill( "trigger" );
	self notify( "stop_strafe" );
	self waittill( "reached_end_node" );
	if ( !flag( "hind1_pass" ) )
	{
		flag_set( "hind1_pass" );
	}
	self vehicle_detachfrompath();
	self thread bp3_hind1_attack_pattern();
}

bp3_hind1_attack_pattern()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "hind_bridge_target", "targetname" );
	i = 1;
	while ( i < 19 )
	{
		a_s_goal[ i ] = getstruct( "hind_bp3_goal" + i, "targetname" );
		i++;
	}
	self setspeed( 60, 50, 35 );
	i = 1;
	while ( 1 )
	{
		if ( i == 3 || i == 15 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
			self waittill_any( "goal", "near_goal" );
			if ( cointoss() )
			{
				self thread hind_attack_indefinitely();
				wait randomfloatrange( 6, 8 );
				self notify( "stop_attack" );
				self clearlookatent();
			}
			self thread hind_rocket_strafe();
			i++;
			continue;
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
			self waittill_any( "goal", "near_goal" );
			self notify( "stop_strafe" );
		}
		i++;
		if ( i > 18 )
		{
			i = 1;
		}
	}
}

bp3wave2_hind_logic()
{
	self endon( "death" );
	self setforcenocull();
	self.statue_target = 1;
	self thread bp3_vehicle_destroyed();
	self thread heli_select_death();
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp3wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp3wave3_vehicles, self, "destroy", -1 );
	}
	s_bridge_target = getstruct( "hind_bridge_target", "targetname" );
	e_target = spawn( "script_origin", s_bridge_target.origin );
	s_goal01 = getstruct( "hind_bp3_goal1", "targetname" );
	s_goal02 = getstruct( "hind_bp3_goal2", "targetname" );
	s_goal03 = getstruct( "hind_bp3_goal3", "targetname" );
	s_goal04 = getstruct( "hind_bp3_goal4", "targetname" );
	s_goal05 = getstruct( "hind_bp3_goal5", "targetname" );
	s_goal06 = getstruct( "hind_bp3_goal6", "targetname" );
	s_goal07 = getstruct( "hind_bp3_goal7", "targetname" );
	s_goal08 = getstruct( "hind_bp3_goal8", "targetname" );
	self setneargoalnotifydist( 200 );
	self setspeed( 100, 50, 10 );
	self setvehgoalpos( s_goal01.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal02.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal03.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal04.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self thread hind_evade();
	self thread hind_attack_indefinitely();
	self waittill( "evade" );
	self notify( "stop_attack" );
	self clearlookatent();
	self setspeed( 75, 45, 30 );
	self setvehgoalpos( s_goal05.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal06.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal07.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal08.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread bp3wave2_hind_attack_pattern();
}

bp3wave2_hind_attack_pattern()
{
	self endon( "death" );
	self endon( "stop_attack_pattern" );
	s_goal09 = getstruct( "hind_bp3_goal9", "targetname" );
	s_goal10 = getstruct( "hind_bp3_goal10", "targetname" );
	s_goal11 = getstruct( "hind_bp3_goal11", "targetname" );
	s_goal12 = getstruct( "hind_bp3_goal12", "targetname" );
	s_goal13 = getstruct( "hind_bp3_goal13", "targetname" );
	s_goal14 = getstruct( "hind_bp3_goal14", "targetname" );
	s_goal15 = getstruct( "hind_bp3_goal15", "targetname" );
	while ( 1 )
	{
		n_index = 8;
		b_divert = 0;
		if ( cointoss() )
		{
			n_index = 15;
			b_divert = 1;
		}
		while ( 1 )
		{
			if ( !b_divert )
			{
				if ( n_index < 15 )
				{
					n_index++;
				}
				else
				{
					self bp3wave2_hind_circle();
					break;
				}
			}
			else if ( n_index > 8 )
			{
				n_index--;

			}
			else
			{
				self bp3wave2_hind_circle();
				break;
			}
			self setvehgoalpos( getstruct( "hind_bp3_goal" + n_index, "targetname" ).origin, 0 );
			self waittill_any( "goal", "near_goal" );
			if ( flag( "cache_destroyed_bp3" ) )
			{
				if ( n_index > 7 )
				{
					self thread bp3wave2_hind_flyto_base();
					wait 0,5;
					self notify( "stop_attack_pattern" );
				}
			}
			if ( b_divert && n_index != 9 || n_index == 12 && n_index == 15 )
			{
				self hind_target_and_fire();
			}
			if ( n_index == 13 )
			{
				self hind_target_and_fire();
			}
			if ( !b_divert && n_index == 14 )
			{
				self hind_target_and_fire();
			}
		}
	}
}

hind_target_and_fire()
{
	self endon( "death" );
	a_targets = getaiarray( "allies" );
	e_target = level.player;
	if ( cointoss() )
	{
		if ( isDefined( a_targets[ randomintrange( 0, a_targets.size ) ] ) )
		{
			e_target = a_targets[ randomintrange( 0, a_targets.size ) ];
		}
		else
		{
			e_target = level.player;
		}
	}
	if ( flag( "attack_cache_bp3" ) )
	{
		if ( cointoss() )
		{
			m_weapons_cache = getent( "ammo_cache_BP3_destroyed", "targetname" );
			e_target = m_weapons_cache;
		}
		else
		{
			e_target = level.player;
		}
	}
	self setlookatent( e_target );
	wait 3;
	self hind_fireat_target( e_target );
	self clearlookatent();
}

bp3wave2_hind_circle()
{
	self endon( "death" );
	self endon( "stop_attack_pattern" );
	s_goal03 = getstruct( "hind_bp3_goal3", "targetname" );
	s_goal04 = getstruct( "hind_bp3_goal4", "targetname" );
	s_goal05 = getstruct( "hind_bp3_goal5", "targetname" );
	s_goal06 = getstruct( "hind_bp3_goal6", "targetname" );
	s_goal07 = getstruct( "hind_bp3_goal7", "targetname" );
	s_goal08 = getstruct( "hind_bp3_goal8", "targetname" );
	self setvehgoalpos( s_goal08.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal07.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal06.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal05.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal03.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal05.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal06.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self hind_target_and_fire();
	self setvehgoalpos( s_goal07.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self hind_target_and_fire();
	self setvehgoalpos( s_goal08.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	if ( flag( "cache_destroyed_bp3" ) )
	{
		self thread bp3wave2_hind_flyto_base();
		wait 0,5;
		self notify( "stop_attack_pattern" );
	}
}

bp3wave2_hind_flyto_base()
{
	self endon( "death" );
	s_goal01 = getstruct( "hind_bp3_base01", "targetname" );
	s_goal02 = getstruct( "hind_bp3_base02", "targetname" );
	s_goal03 = getstruct( "hind_bp3_base03", "targetname" );
	s_goal04 = getstruct( "hind_bp3_base04", "targetname" );
	s_goal05 = getstruct( "hind_bp3_base05", "targetname" );
	self setvehgoalpos( s_goal01.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal02.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal03.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal05.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self hind_baseattack();
}

tank_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::tank_damage;
	self thread go_path( getvehiclenode( "tank_bp3_startnode", "targetname" ) );
	self thread bp3_vehicle_destroyed();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
		set_objective( level.obj_afghan_bp3wave2_vehicles, self, "destroy", -1 );
	}
	else
	{
		self thread delete_corpse_wave3();
		set_objective( level.obj_afghan_bp3wave3_vehicles, self, "destroy", -1 );
	}
	self thread tank_targetting();
	self thread projectile_fired_at_tank();
	nd_ready = getvehiclenode( "bp3_tank1_ready", "targetname" );
	nd_ready waittill( "trigger" );
	self setspeedimmediate( 0 );
	flag_wait( "attack_cache_bp3" );
	self resumespeed( 5 );
	nd_attack = getvehiclenode( "bp3_tank1_attack", "targetname" );
	nd_attack waittill( "trigger" );
	self setspeedimmediate( 0 );
	self notify( "stop_attack" );
	self notify( "stop_projectile_check" );
	cache_dest = getent( "bp3_cache_origin", "targetname" );
	self thread attack_cache_tank( cache_dest );
	self thread projectile_fired_at_tank( cache_dest );
	flag_wait( "cache_destroyed_bp3" );
	self notify( "stop_attack" );
	self notify( "stop_projectile_check" );
	self cleartargetentity();
	wait 2;
	self resumespeed( 5 );
	self thread tank_targetting();
	self thread projectile_fired_at_tank();
	self waittill( "reached_end_node" );
	self notify( "stop_attack" );
	self notify( "stop_projectile_check" );
	self thread tank_baseattack();
}

tank_shoot_bridge()
{
	self endon( "death" );
	s_bridge = getstruct( "hind_bridge_target", "targetname" );
	e_bridge_target = spawn_model( "tag_origin", s_bridge.origin, ( 0, 0, 0 ) );
	m_bridge = getent( "pristine_bridge01_long_break", "targetname" );
	if ( isDefined( m_bridge ) )
	{
		self settargetentity( e_bridge_target );
		self waittill( "turret_on_target" );
		self fireweapon();
		wait 0,1;
		radiusdamage( e_bridge_target.origin, 100, 500, 400, undefined, "MOD_PROJECTILE" );
	}
}

spawn_heli_attack()
{
	trigger_wait( "trigger_heli_attack" );
	autosave_by_name( "bp3_heli_attack" );
	s_spawnpt = getstruct( "bp3_heli_hip_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawnpt.origin;
	vh_hip.angles = s_spawnpt.angles;
	vh_hip thread bp3_heli_hip_logic();
	vh_hip.targetname = "bp3_heli_hip";
	s_spawnpt = undefined;
}

bridge_over_uaz()
{
	trigger_wait( "trigger_bridge_over_uaz" );
	vh_uaz1 = getent( "bp3_uaz1", "targetname" );
	if ( isalive( vh_uaz1 ) )
	{
		radiusdamage( vh_uaz1.origin, 50, 5000, 4500 );
	}
	wait 0,3;
	vh_uaz2 = getent( "bp3_uaz2", "targetname" );
	if ( isalive( vh_uaz2 ) )
	{
		radiusdamage( vh_uaz2.origin, 50, 5000, 4500 );
	}
}

bridge_warning()
{
	wait 5;
	if ( !flag( "bridge4_destroyed" ) )
	{
		level thread bridge4_objective();
	}
	wait 1;
	if ( !flag( "bridge3_destroyed" ) )
	{
		level thread bridge3_objective();
	}
}

kill_upper_bridge()
{
	wait 1;
	a_ai_guys = getentarray( "bp3_upper_bridge_ai", "targetname" );
	_a6894 = a_ai_guys;
	_k6894 = getFirstArrayKey( _a6894 );
	while ( isDefined( _k6894 ) )
	{
		ai_guy = _a6894[ _k6894 ];
		if ( isalive( ai_guy ) )
		{
			ai_guy die();
		}
		_k6894 = getNextArrayKey( _a6894, _k6894 );
	}
}

kill_far_bridge()
{
	wait 1;
	a_ai_guys = getentarray( "bp3_crew_assault_ai", "targetname" );
	_a6910 = a_ai_guys;
	_k6910 = getFirstArrayKey( _a6910 );
	while ( isDefined( _k6910 ) )
	{
		ai_guy = _a6910[ _k6910 ];
		if ( isalive( ai_guy ) )
		{
			ai_guy die();
		}
		_k6910 = getNextArrayKey( _a6910, _k6910 );
	}
}

monitor_bp3_soviets()
{
	level.n_bp3_soviet_killed++;
	if ( level.n_bp3_soviet_killed > 11 && !flag( "attack_cache_bp3" ) )
	{
		flag_set( "attack_cache_bp3" );
	}
	return 0;
}

monitor_muj_group()
{
	sp_muj1 = getent( "bp3_muj_bridge1", "targetname" );
	sp_muj2 = getent( "bp3_muj_bridge2", "targetname" );
	sp_muj1 spawn_ai( 1 );
	wait 0,1;
	sp_muj2 spawn_ai( 1 );
	flag_wait( "rpg_fired" );
	sp_muj_initial = getent( "bp3_muj_initial", "targetname" );
	i = 0;
	while ( i < 4 )
	{
		wait 0,1;
		sp_muj_initial spawn_ai( 1 );
		i++;
	}
	wait 0,5;
	level.zhao thread say_dialog( "muj1_our_lines_are_breaki_0", 2 );
	waittill_ai_group_count( "muj_init_group", 3 );
	spawn_manager_enable( "manager_bp3_foot" );
	level.zhao say_dialog( "muj1_do_not_fear_death_e_0", 1 );
}

bp3_btr1_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	nd_start = getvehiclenode( "btr1_bp3_startnode", "targetname" );
	nd_entry = getvehiclenode( "node_spawn_troops1", "targetname" );
	nd_pause = getvehiclenode( "bp3_btr1_pause", "targetname" );
	nd_attack = getvehiclenode( "bp3_btr1_attack", "targetname" );
	nd_stop = getvehiclenode( "bp3_btr1_stop", "targetname" );
	self thread go_path( nd_start );
	self thread bp3_vehicle_destroyed();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	nd_entry waittill( "trigger" );
	level.woods thread say_dialog( "wood_shit_more_btrs_0", 8 );
	flag_set( "btr1_entry" );
	nd_pause waittill( "trigger" );
	flag_set( "btr1_stop_sprint" );
	nd_attack waittill( "trigger" );
	flag_set( "muj_retreat" );
	nd_stop waittill( "trigger" );
	self setspeed( 0, 15, 5 );
}

bp3_btr2_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	nd_start = getvehiclenode( "btr2_bp3_startnode", "targetname" );
	nd_entry = getvehiclenode( "node_spawn_troops2", "targetname" );
	nd_pause = getvehiclenode( "bp3_btr2_pause", "targetname" );
	nd_attack = getvehiclenode( "bp3_btr2_attack", "targetname" );
	nd_stop = getvehiclenode( "bp3_btr2_stop", "targetname" );
	self thread go_path( nd_start );
	self thread bp3_vehicle_destroyed();
	self thread nag_destroy_vehicle();
	if ( level.n_current_wave == 2 )
	{
		self thread delete_corpse_wave2();
	}
	else
	{
		self thread delete_corpse_wave3();
	}
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	nd_entry waittill( "trigger" );
	flag_set( "btr2_entry" );
	nd_pause waittill( "trigger" );
	flag_set( "btr2_stop_sprint" );
	nd_attack waittill( "trigger" );
	flag_set( "muj_retreat" );
}

bp3_vehicle_destroyed()
{
	self waittill( "death", attacker );
	level.n_bp3_veh_destroyed++;
	autosave_by_name( "bp3_vehicle_killed" );
	wait 0,3;
	if ( level.n_current_wave == 2 )
	{
		set_objective( level.obj_afghan_bp3wave2_vehicles, self, "remove" );
		wait 0,1;
		set_objective( level.obj_afghan_bp3wave2_vehicles, undefined, undefined, level.n_bp3_veh_destroyed );
		if ( level.n_bp3_veh_destroyed > 2 && !flag( "wave2_done" ) )
		{
			set_objective( level.obj_afghan_bp3wave2_vehicles, undefined, "done" );
			if ( level.n_bp3_bridges > 1 )
			{
				flag_set( "wave2_done" );
			}
		}
		if ( level.n_bp3_veh_destroyed == 1 )
		{
			level.woods say_dialog( "wood_one_down_0", 2 );
		}
		if ( level.n_bp3_veh_destroyed > 1 && !flag( "spawn_boss_bp3" ) )
		{
			level thread bp3wave2_boss_chooser();
			flag_set( "spawn_boss_bp3" );
			level.woods thread say_dialog( "muj1_rejoicing_0", 1 );
		}
	}
	else
	{
		if ( level.n_current_wave == 3 )
		{
			set_objective( level.obj_afghan_bp3wave3_vehicles, self, "remove" );
			wait 0,1;
			set_objective( level.obj_afghan_bp3wave3_vehicles, undefined, undefined, level.n_bp3_veh_destroyed );
			if ( level.n_bp3_veh_destroyed > 1 && !flag( "bp3wave3_done" ) )
			{
				set_objective( level.obj_afghan_bp3wave3_vehicles, undefined, "done" );
				flag_set( "bp3wave3_done" );
				autosave_by_name( "bp3_wave3_done" );
			}
			if ( level.n_bp3_veh_destroyed > 0 && !flag( "bp3wave3_hind" ) && !flag( "bp3wave3_tank" ) )
			{
				level thread bp3wave3_boss_chooser();
			}
		}
	}
}

sniper_logic()
{
	self endon( "death" );
	self setcandamage( 0 );
	self.goalradius = 32;
	self.no_cleanup = 1;
	self set_fixednode( 1 );
	self allowedstances( "stand" );
	s_rpg_target = getstruct( "rpg_sniper_target", "targetname" );
	e_target = spawn( "script_origin", s_rpg_target.origin );
	self thread force_goal( ( 2191, -3354, 609 ), 32 );
	self waittill( "goal" );
	self aim_at_target( e_target );
	self setcandamage( 1 );
	wait 1;
	self stop_aim_at_target();
	e_target delete();
}

rpg_destroy_statue_entrance()
{
	s_fire = getstruct( "statue_entrance_rpg", "targetname" );
	s_target = getstruct( "statue_entrance_target", "targetname" );
	wait 1,5;
	magicbullet( "rpg_magic_bullet_sp", s_fire.origin, s_target.origin );
	s_fire = undefined;
	s_target = undefined;
}

enemy_blowup_bridge()
{
	trigger_wait( "trigger_rpg_bridge" );
	s_fire = getstruct( "rpg_bridge_fire", "targetname" );
	s_target = getstruct( "rpg_bridge_target", "targetname" );
	magicbullet( "rpg_magic_bullet_sp", s_fire.origin, s_target.origin );
	m_bridge1_clip = getent( "BP3_bridge_1", "targetname" );
	m_bridge1 = getent( "pristine_bridge01_break", "targetname" );
	str_bridge1 = "fxanim_bridge01_break_start";
	m_bridge1 thread trigger_fxanim_bridge( m_bridge1_clip, str_bridge1 );
	s_fire = undefined;
	s_target = undefined;
}

rpg_horse_explosion()
{
	self waittill( "death" );
	playfx( level._effect[ "explode_mortar_sand" ], self.origin );
	earthquake( 0,3, 1, level.player.origin, 3000 );
	playsoundatposition( "exp_mortar", self.origin );
	playsoundatposition( "evt_horse_death_3", self.origin );
	radiusdamage( self.origin, 400, 2000, 2000, undefined, "MOD_PROJECTILE" );
	flag_set( "rpg_fired" );
}

bp3_soviet_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "b" );
	self.deathfunction = ::monitor_bp3_soviets;
	if ( flag( "spawn_btr2_bp3" ) )
	{
		self change_movemode( "sprint" );
		flag_wait( "btr1_stop_sprint" );
		self reset_movemode();
	}
}

assault_soviet_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "y" );
	self.deathfunction = ::monitor_bp3_soviets;
	if ( flag( "spawn_btr1_bp3" ) )
	{
		self change_movemode( "sprint" );
		flag_wait( "btr2_stop_sprint" );
		self reset_movemode();
	}
}

pulwar_victim_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_ignoreall( 1 );
	self set_ignoreme( 1 );
	self thread vo_killedby_player();
	self rush();
	wait 1;
	self set_ignoreall( 0 );
	wait 5;
	self set_ignoreme( 0 );
}

vo_killedby_player()
{
	self waittill( "death", attacker );
	if ( isDefined( attacker ) && attacker == level.player )
	{
		level.player say_dialog( "maso_fuck_you_0", 0,5 );
	}
}

bp3_uaz_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.deathfunction = ::monitor_bp3_soviets;
}

muj_bridge1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self.goalradius = 32;
	self set_fixednode( 1 );
	trigger_wait( "trigger_bridge_crosser" );
	self set_fixednode( 0 );
	self setgoalnode( getnode( "bridge_node", "targetname" ) );
	self waittill( "goal" );
	self set_fixednode( 1 );
}

muj_bridge2_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self set_fixednode( 1 );
}

muj_initial_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self set_fixednode( 0 );
}

muj_bridge_crosser_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self set_force_color( "p" );
}

foot_soldier_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self set_force_color( "g" );
}

bp3_exit_muj_logic()
{
	self endon( "death" );
	flag_wait( "arena_return" );
	self delete();
}

bp3_exit_soviet_logic()
{
	self endon( "death" );
	flag_wait( "arena_return" );
	self delete();
}

bp3_soviet_bridge_logic()
{
	self endon( "death" );
	self.deathfunction = ::monitor_bp3_soviets;
	self.nododgemove = 1;
	self.bp_ai = 1;
	self.script_longdeath = 0;
	if ( randomint( 4 ) == 0 )
	{
		self thread force_goal( ( 303, -2789, 540 ), 64 );
	}
	else if ( randomint( 4 ) == 1 )
	{
		self thread force_goal( ( 670, -2850, 527 ), 64 );
	}
	else if ( randomint( 4 ) == 2 )
	{
		self thread force_goal( ( 1106, -2927, 527 ), 64 );
	}
	else
	{
		self thread force_goal( ( 1446, -2991, 542 ), 64 );
	}
}

bp3_soviet_firstbridge_logic()
{
	self endon( "death" );
	self.deathfunction = ::monitor_bp3_soviets;
	self.nododgemove = 1;
	self.bp_ai = 1;
	self.script_longdeath = 0;
	self thread force_goal( ( 2515, -5886, 749,03 ), 64 );
	self waittill( "goal" );
	self delete();
}

upper_bridge_logic()
{
	self endon( "death" );
	vol_bridge = getent( "vol_upper_bridge", "targetname" );
	self thread force_goal( undefined, 64 );
	self setgoalvolumeauto( vol_bridge );
	self waittill( "goal" );
	self setgoalpos( self.origin );
	self set_fixednode( 1 );
	self set_ignoreall( 1 );
	wait 10;
	self die();
}

bridge_sniper_logic()
{
	self endon( "death" );
	self set_ignoreall( 1 );
	self thread force_goal( undefined, 64 );
	self waittill( "goal" );
	self set_fixednode( 1 );
	a_tags = [];
	a_tags[ 0 ] = "J_SpineLower";
	a_tags[ 1 ] = "J_Knee_LE";
	a_tags[ 2 ] = "J_SpineUpper";
	a_tags[ 3 ] = "J_Neck";
	a_tags[ 4 ] = "J_Head";
	while ( 1 )
	{
		a_ai_targets = getaiarray( "allies" );
		if ( a_ai_targets.size )
		{
			i = 0;
			while ( i < a_ai_targets.size )
			{
				ai_target = a_ai_targets[ randomint( a_ai_targets.size ) ];
				if ( isalive( ai_target ) && self cansee( ai_target ) )
				{
					break;
				}
				else
				{
					i++;
				}
			}
			if ( randomint( 5 ) == 0 )
			{
				ai_target = level.player;
			}
			if ( isalive( ai_target ) )
			{
				if ( distance2dsquared( self.origin, ai_target.origin ) <= ( 5000 * 5000 ) )
				{
					self thread aim_at_target( ai_target );
					wait 1;
					if ( isalive( ai_target ) )
					{
						if ( ai_target != level.player )
						{
							v_target = ai_target gettagorigin( a_tags[ randomint( 5 ) ] );
						}
						else
						{
							v_target = level.player.origin + ( randomintrange( -200, 200 ), randomintrange( -200, 200 ), randomintrange( -100, 100 ) );
						}
						vec_tag_flash = self gettagorigin( "tag_flash" );
						b_canshoot = bullettracepassed( vec_tag_flash, v_target, 1, ai_target );
						if ( b_canshoot )
						{
							magicbullet( "dragunov_sp", vec_tag_flash, v_target );
							e_trail = spawn( "script_model", vec_tag_flash );
							e_trail setmodel( "tag_origin" );
							playfxontag( level._effect[ "sniper_trail" ], e_trail, "tag_origin" );
							e_trail moveto( v_target, 0,1 );
							playfx( level._effect[ "sniper_impact" ], v_target );
							wait 0,2;
							e_trail delete();
						}
					}
					self thread stop_aim_at_target();
				}
			}
		}
		wait randomfloatrange( 2, 3 );
	}
}

monitor_weapons_cache( m_damage, str_endon )
{
	level endon( str_endon );
	m_damage setcandamage( 1 );
	n_cache_health = 100;
	b_under_attack = 0;
	b_down_50 = 0;
	b_down_25 = 0;
	b_destroyed = 0;
	cache = m_damage;
	if ( m_damage.targetname == "ammo_cache_BP2_destroyed" )
	{
		cache_pris = getent( "ammo_cache_BP2_pristine", "targetname" );
		cache_dmg = getent( "ammo_cache_BP2_damaged", "targetname" );
		cache_dest = getent( "ammo_cache_BP2_destroyed", "targetname" );
		cache_clip = getent( "ammo_cache_BP2_clip", "targetname" );
	}
	else
	{
		cache_pris = getent( "ammo_cache_BP3_pristine", "targetname" );
		cache_dmg = getent( "ammo_cache_BP3_damaged", "targetname" );
		cache_dest = getent( "ammo_cache_BP3_destroyed", "targetname" );
		cache_clip = getent( "ammo_cache_BP3_clip", "targetname" );
	}
	while ( 1 )
	{
		cache waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( isDefined( attacker.demo_guy ) )
		{
			n_cache_health = 0;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "apc_btr60" )
		{
			n_cache_health -= 0,2;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "heli_hip" )
		{
			n_cache_health -= 0,8;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "tank_t62" )
		{
			n_cache_health -= 10;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "heli_hind_afghan" )
		{
			n_cache_health -= 5;
		}
		if ( type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" )
		{
			n_cache_health -= 10;
		}
		if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			n_cache_health -= 4;
		}
		wait 0,1;
		if ( n_cache_health < 1 )
		{
			if ( !b_destroyed )
			{
				b_destroyed = 1;
				playfx( level._effect[ "cache_dest" ], cache_dest.origin );
				wait 0,1;
				if ( isDefined( cache_pris ) )
				{
					cache_pris delete();
				}
				cache_dest show();
				cache_dmg delete();
				cache_clip delete();
				level.caches_lost++;
				if ( level.caches_lost > 1 )
				{
				}
				if ( m_damage.targetname == "ammo_cache_BP2_destroyed" )
				{
					flag_set( "cache_destroyed_bp2" );
					break;
				}
				else
				{
					flag_set( "cache_destroyed_bp3" );
				}
			}
		}
		if ( n_cache_health < 100 )
		{
			if ( !b_under_attack )
			{
				b_under_attack = 1;
			}
		}
		if ( n_cache_health < 50 )
		{
			if ( !b_down_50 )
			{
				b_down_50 = 1;
				cache_dmg setcandamage( 1 );
				cache = cache_dmg;
				cache_pris delete();
				cache_dmg show();
				playfx( level._effect[ "cache_dmg" ], cache_dmg.origin );
			}
		}
		if ( n_cache_health < 25 )
		{
			if ( !b_down_25 )
			{
				b_down_25 = 1;
			}
		}
	}
}

cleanup_ai_bp2wave2()
{
	spawn_manager_disable( "manager_troops_exit" );
	spawn_manager_disable( "manager_hip3_troops" );
	a_ai_guys = getaiarray( "allies", "axis" );
	a_ai_guys = array_exclude( a_ai_guys, level.zhao );
	_a7862 = a_ai_guys;
	_k7862 = getFirstArrayKey( _a7862 );
	while ( isDefined( _k7862 ) )
	{
		ai_guy = _a7862[ _k7862 ];
		if ( isDefined( ai_guy.bp_ai ) )
		{
			ai_guy delete();
		}
		_k7862 = getNextArrayKey( _a7862, _k7862 );
	}
}
