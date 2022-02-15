#include maps/_challenges_sp;
#include maps/afghanistan_base_threats;
#include maps/_rusher;
#include maps/voice/voice_afghanistan;
#include maps/_patrol;
#include maps/_afghanstinger;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	maps/afghanistan_fx::main();
	level_precache();
	level_init_flags();
	level_init_spawn_funcs();
	blocking_point_chooser();
	maps/so_cmp_afghanistan::setup_skiptos();
	setup_level();
	maps/_patrol::patrol_init();
	maps/voice/voice_afghanistan::init_voice();
	level.ammo_cache_waittill_notify = "start_afghan_ammo_caches";
	level._ammo_refill_think_alt = ::maps/afghanistan_utility::_ammo_refill_horse_think;
	maps/_load::main();
	maps/afghanistan_amb::main();
	maps/afghanistan_anim::main();
	maps/afghanistan_anim::init_afghan_anims_part1();
	maps/_heatseekingmissile::init();
	maps/_drones_aipath::init();
	maps/_rusher::init_rusher();
	setup_objectives();
	level thread maps/_objectives::objectives();
	level thread maps/createart/afghanistan_art::main();
	level thread lockbreaker_door();
	level thread intruder_door();
	level thread pull_out_sword();
	base_wall_hide_destroyed_state();
	mountain_tops_no_cull();
	open_base_gate();
	setsaveddvar( "vehicle_sounds_cutoff", 30000 );
	setdvar( "footstep_sounds_cutoff", 3000 );
	setsaveddvar( "vehicle_riding", 0 );
	onplayerconnect_callback( ::on_player_connect );
	onsaverestored_callback( ::on_save_restored );
	level.callbackactorkilled = ::callback_actorkilled_check;
	level thread maps/_horse_player::init();
	level.overrideactordamage = ::maps/_horse::horse_actor_damage;
	level.prevent_player_damage = ::maps/afghanistan_utility::player_shrug_off_horse;
	level.horse_sprint_unlimited = 1;
	level.hudson_vo = getent( "hudson_vo", "targetname" );
}

debug_items()
{
/#
	while ( 1 )
	{
		a_grenades = getentarray( "grenade", "classname" );
		_a106 = a_grenades;
		_k106 = getFirstArrayKey( _a106 );
		while ( isDefined( _k106 ) )
		{
			e_grenade = _a106[ _k106 ];
			if ( isDefined( e_grenade.name ) && e_grenade.name == "tc6_mine_sp" )
			{
				e_grenade delete();
				iprintln( "deleteing tank mine" );
			}
			_k106 = getNextArrayKey( _a106, _k106 );
		}
		wait 1;
#/
	}
}

debug_woods_horse()
{
/#
	while ( 1 )
	{
		woods_horse = getentarray( "woods_horse", "targetname" );
		if ( woods_horse.size == 2 )
		{
			iprintln( "why do we have 2 horses" );
		}
		wait 0,05;
#/
	}
}

explode_stuff()
{
/#
	while ( 1 )
	{
		level notify( "base_attacked" );
		wait 1;
#/
	}
}

on_player_connect()
{
	level.player = get_players()[ 0 ];
	setup_challenges();
	init_weapon_cache();
	level.player thread waittill_player_mounts_horse();
	setnorthyaw( 90 );
	level.player setclientdvar( "cg_aggressiveCullRadius", "500" );
	level.player.friendlyfire_attacker_not_vehicle_owner = 1;
}

on_save_restored()
{
	if ( level.player getcurrentweapon() == "afghanstinger_ff_sp" )
	{
		level.player switchtoweapon( "afghanstinger_sp" );
	}
	if ( !flag( "in_horse_charge" ) && isDefined( level.base_total_health ) && level.base_total_health < 200 )
	{
		if ( ( level.base_total_health / 200 ) < 0,5 )
		{
			level.base_total_health = 100;
		}
		else
		{
			if ( ( level.base_total_health / 200 ) < 0,8 )
			{
				level.base_total_health = 160;
			}
		}
		maps/afghanistan_base_threats::base_update_icon();
	}
	level.player.friendlyfire_attacker_not_vehicle_owner = 1;
}

level_precache()
{
	precachemodel( "c_usa_mason_afgan_wrap_viewbody" );
	precachemodel( "c_usa_mason_afghan_viewbody" );
	precachemodel( "t5_weapon_1911_sp_world" );
	precachemodel( "viewmodel_t6_wpn_pistol_m1911_animated" );
	precachemodel( "t6_wpn_mortar_shell_prop_view" );
	precachemodel( "viewmodel_binoculars" );
	precachemodel( "t5_weapon_static_binoculars" );
	precachemodel( "p6_afghanistan_herding_staff" );
	precachemodel( "t6_wpn_pistol_m1911_prop_view" );
	precachemodel( "p6_anim_afghan_rope" );
	precachemodel( "p6_anim_afghan_interrogation_rope" );
	precachemodel( "c_rus_afghan_kravchenko_head_cut" );
	precachemodel( "c_rus_afghan_kravchenko_rarm_cut" );
	precachemodel( "com_hand_radio" );
	precachemodel( "p_glo_tools_hammer" );
	precachemodel( "p6_anim_smoking_pipe" );
	precachemodel( "com_hookah_pipe_anim" );
	precachemodel( "jun_ammo_crate_anim" );
	precachemodel( "p6_bullet_shell_pile_large_anim" );
	precachemodel( "p6_bullet_shell_pile_small_anim" );
	precachemodel( "t6_wpn_ar_ak47_prop" );
	precachemodel( "mil_ammo_case_anim_1" );
	precachemodel( "c_usa_jungmar_assault_fb" );
	precachemodel( "p6_knife_karambit" );
	precachemodel( "p6_wooden_chair_anim" );
	precachemodel( "p_jun_gear_canteen" );
	precachemodel( "weapon_c4_detonator" );
	precachemodel( "rope_test_ri" );
	precachemodel( "t6_wpn_ar_ak47_world" );
	precachemodel( "fxanim_chopper_crash_blades" );
	precachemodel( "t6_wpn_cratercharge_prop" );
	precachemodel( "anim_horse1_black_fb_nolod" );
	precacheitem( "satchel_charge_sp" );
	precacheitem( "satchel_charge_80s_sp" );
	precacheitem( "afghanstinger_sp" );
	precacheitem( "afghanstinger_ff_sp" );
	precacheitem( "rpg_magic_bullet_sp" );
	precacheitem( "ak47_sp" );
	precacheitem( "btr60_heavy_machinegun" );
	precacheitem( "hind_rockets" );
	precacheitem( "stinger_sp" );
	precacheitem( "rpg_player_sp" );
	precacheitem( "pulwar_sword_sp" );
	precacheitem( "tc6_mine_sp" );
	precacheitem( "mortar_shell_dpad_sp" );
	precacheshader( "cinematic2d" );
	precacheshader( "fullscreen_dirt_bottom_b" );
	precacheshellshock( "afghan_horsefall" );
	precachestring( &"hud_afghan_update_ammo" );
	precachestring( &"hud_afghan_update_rpg" );
	precachestring( &"hud_afghan_add_vehicle_icon" );
	precachestring( &"hud_afghan_remove_vehicle_icon" );
	maps/_horse::precache_models();
	maps/_horse_player::precache_models();
}

level_init_flags()
{
	flag_init( "bp_underway" );
	flag_init( "in_horse_charge" );
	flag_init( "old_man_woods_talking" );
	flag_init( "woods_getting_off_horse" );
	maps/afghanistan_horse_intro::init_flags();
	maps/afghanistan_intro_rebel_base::init_flags();
	maps/afghanistan_firehorse::init_flags();
	maps/afghanistan_wave_1::init_flags();
	maps/afghanistan_wave_2::init_flags();
	maps/afghanistan_wave_3::init_flags();
	maps/afghanistan_blocking_done::init_flags();
	maps/afghanistan_horse_charge::init_flags();
	maps/afghanistan_krav_captured::init_flags();
	maps/afghanistan_deserted::init_flags();
}

level_init_spawn_funcs()
{
	maps/afghanistan_horse_charge::init_spawn_funcs();
}

setup_skiptos()
{
	add_skipto( "intro", ::maps/afghanistan_intro::skipto_intro, "Intro", ::maps/afghanistan_intro::main );
	add_skipto( "horse_intro", ::maps/afghanistan_horse_intro::skipto_intro, "Horse Intro", ::maps/afghanistan_horse_intro::main );
	add_skipto( "rebel_base_intro", ::maps/afghanistan_intro_rebel_base::skipto_intro, "rebel base intro", ::maps/afghanistan_intro_rebel_base::main );
	add_skipto( "firehorse", ::maps/afghanistan_firehorse::skipto_firehorse, "Fire Horse", ::maps/afghanistan_firehorse::main );
	add_skipto( "wave_1", ::maps/afghanistan_wave_1::skipto_wave1, "Wave 1", ::maps/afghanistan_wave_1::main );
	add_skipto( "arena_sandbox", ::maps/afghanistan_wave_2::skipto_wave2, "Wave 2", ::maps/afghanistan_wave_2::main );
	add_skipto( "horse_charge", ::maps/afghanistan_horse_charge::skipto_horse_charge, "Horse Charge", ::maps/afghanistan_horse_charge::main );
	add_skipto( "krav_tank", ::maps/afghanistan_horse_charge::skipto_krav_tank, "Krav Tank", ::maps/afghanistan_horse_charge::after_button_mash_scene );
	add_skipto( "krav_captured", ::maps/afghanistan_krav_captured::skipto_krav_captured, "Krav Captured", ::maps/afghanistan_krav_captured::main );
	add_skipto( "interrogation", ::maps/afghanistan_krav_captured::skipto_krav_interrogation, "Krav Captured", ::maps/afghanistan_krav_captured::interrogation );
	add_skipto( "beat_down", ::maps/afghanistan_krav_captured::skipto_beat_down, "Beatdown", ::maps/afghanistan_krav_captured::beatdown );
	add_skipto( "deserted", ::maps/afghanistan_deserted::skipto_deserted, "Deserted", ::maps/afghanistan_deserted::main );
	default_skipto( "intro" );
}

setup_objectives()
{
	level.a_objectives = [];
	level.n_obj_index = 0;
	level.obj_brute_perk = register_objective( &"" );
	level.obj_lock_perk = register_objective( &"" );
	level.obj_intru_perk = register_objective( &"" );
	level.obj_initial = register_objective( &"AFGHANISTAN_OBJ_OVERALL" );
	level.obj_afghan_bc3a = register_objective( &"" );
	level.obj_afghan_bc3 = register_objective( &"AFGHANISTAN_BASECAMP_3" );
	level.obj_follow_bp1 = register_objective( &"" );
	level.obj_defend_cache1 = register_objective( &"AFGHANISTAN_OBJ_DEFEND_CACHE1" );
	level.obj_afghan_bp1 = register_objective( &"AFGHANISTAN_OBJ_BP1" );
	level.obj_afghan_bp1_vehicles = register_objective( &"AFGHANISTAN_BP1_VEHICLES" );
	level.obj_destroy_dome = register_objective( &"AFGHANISTAN_OBJ_DESTROY_DOME" );
	level.obj_destroy_btr = register_objective( &"AFGHANISTAN_OBJ_DESTROY_BTR" );
	level.obj_bp1_wave3 = register_objective( &"" );
	level.obj_bp3_secure_cache = register_objective( &"AFGHANISTAN_OBJ_SECURE_CACHE" );
	level.obj_horse = register_objective( &"" );
	level.obj_ammo = register_objective( &"" );
	level.obj_weapon = register_objective( &"" );
	level.obj_defend_bp = register_objective( &"" );
	level.obj_protect = register_objective( &"AFGHANISTAN_OBJ_PROTECT" );
	level.obj_destroy_helo = register_objective( &"" );
	level.obj_destroy_tank = register_objective( &"" );
	level.obj_return_base = register_objective( &"AFGHANISTAN_RETURN_TO_BASE" );
	level.obj_interrogate_krav = register_objective( &"AFGHANISTAN_OBJ_INTERROGATE" );
}

setup_level()
{
	level.press_demo = 0;
	level.n_current_wave = 1;
	level.player_wave3_loc = 0;
	level.caches_lost = 0;
	t_cache_guard = getent( "trigger_firehorse_cache_guard", "targetname" );
	t_cache_guard trigger_off();
	t_exit = getent( "tunnel_exit", "targetname" );
	t_exit trigger_off();
	t_overlook = getent( "player_at_overlook", "targetname" );
	t_overlook trigger_off();
	t_chase = getent( "trigger_uaz_chase", "targetname" );
	t_chase trigger_off();
	m_cratercharge = getent( "crater_charge_explosive", "targetname" );
	m_cratercharge hide();
	trigger_off( "trigger_btr_chase", "script_noteworthy" );
	t_bp3_uaz = getent( "spawn_wave2_bp3", "targetname" );
	t_bp3_uaz trigger_off();
	bm_clips1 = getentarray( "bridge1_clip", "targetname" );
	_a408 = bm_clips1;
	_k408 = getFirstArrayKey( _a408 );
	while ( isDefined( _k408 ) )
	{
		bm_clip = _a408[ _k408 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k408 = getNextArrayKey( _a408, _k408 );
	}
	bm_clips2 = getentarray( "bridge2_clip", "targetname" );
	_a415 = bm_clips2;
	_k415 = getFirstArrayKey( _a415 );
	while ( isDefined( _k415 ) )
	{
		bm_clip = _a415[ _k415 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k415 = getNextArrayKey( _a415, _k415 );
	}
	bm_clips3 = getentarray( "bridge3_clip", "targetname" );
	_a422 = bm_clips3;
	_k422 = getFirstArrayKey( _a422 );
	while ( isDefined( _k422 ) )
	{
		bm_clip = _a422[ _k422 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k422 = getNextArrayKey( _a422, _k422 );
	}
	bm_clips4 = getentarray( "bridge4_clip", "targetname" );
	_a429 = bm_clips4;
	_k429 = getFirstArrayKey( _a429 );
	while ( isDefined( _k429 ) )
	{
		bm_clip = _a429[ _k429 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k429 = getNextArrayKey( _a429, _k429 );
	}
	t_bp3_exit = getentarray( "bp3_exit_flag_trigger", "script_noteworthy" );
	_a436 = t_bp3_exit;
	_k436 = getFirstArrayKey( _a436 );
	while ( isDefined( _k436 ) )
	{
		t_trig = _a436[ _k436 ];
		t_trig trigger_off();
		_k436 = getNextArrayKey( _a436, _k436 );
	}
	t_bp3_cache = getent( "trigger_zhao_cache", "script_noteworthy" );
	t_bp3_cache trigger_off();
	a_m_destroyed_dome = getentarray( "archway_destroyed_static", "targetname" );
	_a450 = a_m_destroyed_dome;
	_k450 = getFirstArrayKey( _a450 );
	while ( isDefined( _k450 ) )
	{
		m_dest = _a450[ _k450 ];
		m_dest hide();
		m_dest notsolid();
		_k450 = getNextArrayKey( _a450, _k450 );
	}
	t_pulwar_victim = getent( "trigger_pulwar_victim", "targetname" );
	t_pulwar_victim trigger_off();
	level.tank_dest = getent( "firehorse_tank_dest", "targetname" );
	level.tank_dest hide();
	level.tank_dest notsolid();
	level.tank_dest connectpaths();
	a_gun_crate = getentarray( "crate_guns", "targetname" );
	_a465 = a_gun_crate;
	_k465 = getFirstArrayKey( _a465 );
	while ( isDefined( _k465 ) )
	{
		gun = _a465[ _k465 ];
		gun hide();
		_k465 = getNextArrayKey( _a465, _k465 );
	}
	setsaveddvar( "vehicle_selfCollision", 0 );
}

blocking_point_chooser()
{
	level.wave2_loc = "blocking point 2";
	if ( cointoss() )
	{
		level.wave2_loc = "blocking point 3";
	}
	if ( level.wave2_loc == "blocking point 2" )
	{
		level.wave3_loc = "blocking point 3";
	}
	else
	{
		level.wave3_loc = "blocking point 2";
	}
}

waittill_player_mounts_horse()
{
	level endon( "blocking_done" );
	while ( 1 )
	{
		self waittill( "enter_vehicle", vehicle );
		level.mason_horse = vehicle;
		if ( vehicle.vehicletype == "horse_player" || vehicle.vehicletype == "horse" )
		{
			setsaveddvar( "player_disableWeaponsOnVehicle", "0" );
		}
		vehicle veh_magic_bullet_shield( 1 );
		self waittill( "exit_vehicle", vehicle );
		setsaveddvar( "player_disableWeaponsOnVehicle", "1" );
	}
}

lockbreaker_door()
{
	trigger_off( "intruder_box", "targetname" );
	trigger_off( "lockbreaker_trigger", "targetname" );
	while ( !isDefined( level.player ) )
	{
		wait 0,5;
	}
	level.player waittill_player_has_lock_breaker_perk();
	flag_wait( "map_room_started" );
	trigger_on( "intruder_box", "targetname" );
	trigger_on( "lockbreaker_trigger", "targetname" );
	m_door = getent( "afghan_lockbreaker_door", "targetname" );
	m_door_clip = getent( "afghan_lockbreaker_door_clip", "targetname" );
	e_align_obj = spawn( "script_origin", m_door.origin );
	e_align_obj.angles = m_door.angles;
	e_align_obj.targetname = "mortar_door_align";
	s_obj = getstruct( "lockbreaker_objective", "targetname" );
	trig_access = getent( "trig_mortar_access", "targetname" );
	set_objective_perk( level.obj_intru_perk, s_obj, undefined, trig_access );
	trigger_wait( "lockbreaker_trigger" );
	trigger_off( "lockbreaker_trigger", "targetname" );
	remove_objective_perk( level.obj_intru_perk );
	run_scene( "lockbreaker" );
	level notify( "player_accessed_perk" );
	m_door_clip delete();
	flag_set( "lockbreaker_opened" );
	level.player giveweapon( "mortar_shell_dpad_sp" );
	level.player setactionslot( 4, "weapon", "mortar_shell_dpad_sp" );
	sticky_grenade_hint();
}

give_grenade( str_grenade_type )
{
	players_grenades = [];
	a_player_weapons = self getweaponslist();
	_a585 = a_player_weapons;
	_k585 = getFirstArrayKey( _a585 );
	while ( isDefined( _k585 ) )
	{
		weapon = _a585[ _k585 ];
		if ( weapontype( weapon ) == "grenade" )
		{
			arrayinsert( players_grenades, weapon, players_grenades.size );
		}
		_k585 = getNextArrayKey( _a585, _k585 );
	}
	if ( players_grenades.size >= 2 )
	{
		self takeweapon( players_grenades[ 1 ] );
	}
	self giveweapon( str_grenade_type );
	self givemaxammo( str_grenade_type );
}

sticky_grenade_hint()
{
	level endon( "sticky_threw" );
	screen_message_create( &"AFGHANISTAN_HINT_STICKY_THROW" );
	level thread hint_timer( "sticky_threw" );
}

temp_shield( time )
{
	self magic_bullet_shield();
	wait time;
	self stop_magic_bullet_shield();
}

intruder_door()
{
	trigger_off( "intruder_box", "targetname" );
	while ( !isDefined( level.player ) )
	{
		wait 0,5;
	}
	level.player waittill_player_has_intruder_perk();
	run_scene_first_frame( "intruder_box_and_mine" );
	trigger_on( "intruder_box", "targetname" );
	s_obj = getstruct( "intruder_objective", "targetname" );
	set_objective_perk( level.obj_lock_perk, s_obj, 400 );
	level thread toggle_off_intruder_when_blowing_dome();
	trigger_wait( "intruder_box" );
	trigger_off( "intruder_box", "targetname" );
	remove_objective_perk( level.obj_lock_perk );
	level notify( "intruder_box_accessed" );
	level thread run_scene( "intruder_box_and_mine" );
	run_scene( "intruder" );
	level notify( "player_accessed_perk" );
	level.player giveweapon( "tc6_mine_sp" );
	level.player setactionslot( 1, "weapon", "tc6_mine_sp" );
	level.player givemaxammo( "tc6_mine_sp" );
	level.player thread temp_shield( 3 );
	level thread mine_hint();
	level.woods thread maps/_dialog::say_dialog( "wood_try_and_lay_them_in_0", 1 );
}

toggle_off_intruder_when_blowing_dome()
{
	level endon( "intruder_box_accessed" );
	flag_wait( "started_crater_charge" );
	trigger_off( "intruder_box", "targetname" );
	remove_objective_perk( level.obj_lock_perk );
	flag_wait( "dome_exploded" );
	trigger_on( "intruder_box", "targetname" );
	s_obj = getstruct( "intruder_objective", "targetname" );
	set_objective_perk( level.obj_lock_perk, s_obj, 1024 );
}

mine_hint()
{
	level endon( "mine_placed" );
	level thread hint_timer( "mine_selected" );
	screen_message_create( &"AFGHANISTAN_HINT_MINE_SELECT" );
	while ( level.player getcurrentweapon() != "tc6_mine_sp" )
	{
		wait 0,05;
	}
	level notify( "mine_selected" );
	level thread hint_timer( "mine_placed" );
	screen_message_delete();
	screen_message_create( &"AFGHANISTAN_HINT_MINE_PLACE" );
	level.player waittill_attack_button_pressed();
	screen_message_delete();
	level notify( "mine_placed" );
}

hint_timer( str_notify )
{
	level endon( str_notify );
	wait 3;
	screen_message_delete();
}

pull_out_sword()
{
	level endon( "player_mounted_horse" );
	trigger_off( "pullout_pulwar", "targetname" );
	level run_scene_first_frame( "e1_s1_pulwar_single" );
	while ( !isDefined( level.player ) )
	{
		wait 0,5;
	}
	level.player waittill_player_has_brute_force_perk();
	if ( level.skipto_point == "intro" )
	{
		scene_wait( "e1_zhao_horse_charge_player" );
	}
	trigger_on( "pullout_pulwar", "targetname" );
	s_pullout_pulwar_obj = getstruct( "pullout_pulwar_obj" );
	trig_access = getent( "trig_pulwar_access", "targetname" );
	set_objective_perk( level.obj_brute_perk, s_pullout_pulwar_obj, undefined, trig_access );
	level thread disable_pull_out_sword();
	trigger_wait( "pullout_pulwar" );
	level.player freezecontrolsallowlook( 1 );
	trigger_off( "pullout_pulwar", "targetname" );
	remove_objective_perk( level.obj_brute_perk );
	level.player startcameratween( 0,2 );
	level thread run_scene_first_frame( "e1_s1_pulwar_player" );
	wait 0,25;
	level thread run_scene( "e1_s1_pulwar" );
	level notify( "player_accessed_perk" );
	level notify( "sword_pulled" );
	level thread vo_pulwar();
	scene_wait( "e1_s1_pulwar" );
	trig_access delete();
	level.player freezecontrolsallowlook( 0 );
	level.player giveweapon( "pulwar_sword_sp" );
}

disable_pull_out_sword()
{
	level endon( "sword_pulled" );
	level waittill( "player_mounted_horse" );
	remove_objective_perk( level.obj_brute_perk );
	trigger_delete( "trig_pulwar_access" );
	obj_struct = getstruct( "pullout_pulwar_obj" );
	obj_struct structdelete();
}

vo_pulwar()
{
	wait 4,5;
	level.woods say_dialog( "wood_what_the_hell_you_go_0" );
	level.player say_dialog( "maso_you_never_know_0", 0,5 );
}

setup_challenges()
{
	self thread maps/_challenges_sp::register_challenge( "nodeath", ::nodeath_challenge );
	self thread maps/_challenges_sp::register_challenge( "tank_mine", ::tank_mine );
	self thread maps/_challenges_sp::register_challenge( "pulwar_sword", ::pulwar_sword_challenge );
	self thread maps/_challenges_sp::register_challenge( "grenade_helo", ::lockbreaker_challenge );
	self thread maps/_challenges_sp::register_challenge( "kill_heli_with_truck_mg", ::kill_helis_with_truck_mg );
	self thread maps/_challenges_sp::register_challenge( "trampled_under_hoof", ::trampled_under_hoof );
	self thread maps/_challenges_sp::register_challenge( "blocking_point_2_kill_helis", ::blocking_point_2_kill_helis );
	self thread maps/_challenges_sp::register_challenge( "helo_rpg", ::helo_rpg );
	self thread maps/_challenges_sp::register_challenge( "rain_fire", ::rain_fire_challenge );
}

pulwar_sword_challenge( str_notify )
{
	while ( 1 )
	{
		level waittill( "killed_by_sword" );
		self notify( str_notify );
	}
}

rain_fire_challenge( str_notify )
{
	while ( 1 )
	{
		level waittill( "killed_by_rainfire" );
		self notify( str_notify );
	}
}

callback_actorkilled_check( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) )
		{
			if ( sweapon == "afghanstinger_sp" )
			{
				level notify( "killed_by_rainfire" );
				return;
			}
			else
			{
				if ( sweapon == "pulwar_sword_sp" )
				{
					level notify( "killed_by_sword" );
				}
			}
		}
	}
}

nodeath_challenge( str_notify )
{
	level.player waittill( "mission_finished" );
	n_deaths = get_player_stat( "deaths" );
	if ( n_deaths == 0 )
	{
		self notify( str_notify );
	}
}

accessallperk( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_accessed_perk" );
		self notify( str_notify );
	}
}

trampled_under_hoof( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_trampled_ai_with_horse" );
		self notify( str_notify );
		if ( randomint( 20 ) == 13 )
		{
			if ( cointoss() )
			{
				level.player thread say_dialog( "maso_shoulda_moved_fucke_0", 0,5 );
				break;
			}
			else
			{
				level.player thread say_dialog( "maso_get_outta_the_way_0", 0,5 );
			}
		}
	}
}

kravchenko_intel( str_notify )
{
	level waittill( "krav_gives_all_intel" );
	self notify( str_notify );
}

kill_helis_with_truck_mg( str_notify )
{
	while ( 1 )
	{
		level waittill( "killed_heli_with_truck_mg" );
		self notify( str_notify );
	}
}

lockbreaker_challenge( str_notify )
{
	level waittill( "helo_destroyed_by_mortar" );
	self notify( str_notify );
}

blocking_point_2_kill_helis( str_notify )
{
	while ( 1 )
	{
		level waittill( "blocking_point_2_heli_shot_down" );
		self notify( str_notify );
	}
}

helo_rpg( str_notify )
{
	level waittill( "helo_shot_down_by_rpg" );
	self notify( str_notify );
}

tank_mine( str_notify )
{
	level waittill( "tank_destroyed_by_mine" );
	self notify( str_notify );
}
