#include maps/_fire_direction;
#include maps/_rusher;
#include maps/pakistan_anim;
#include maps/pakistan_street;
#include maps/_glasses;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_music;
#include maps/pakistan_util;
#include maps/_dialog;
#include maps/_objectives;
#include maps/_utility;
#include common_scripts/utility;

skipto_intro()
{
	skipto_teleport( "skipto_intro" );
}

skipto_market()
{
	skipto_teleport( "skipto_market" );
	simple_spawn( "market_intro_spawners" );
	flag_set( "intro_anim_claw_done" );
	level.b_vo_played = 1;
	level thread maps/pakistan_util::pakistan_deconstruct_ents();
}

skipto_market_dev_perk()
{
	level.player setperk( "specialty_trespasser" );
	flag_set( "intro_anim_claw_done" );
	skipto_market();
	level thread maps/pakistan_util::pakistan_deconstruct_ents();
}

skipto_market_dev_no_perk()
{
	level.player unsetperk( "specialty_trespasser" );
	flag_set( "intro_anim_claw_done" );
	skipto_market();
	level thread maps/pakistan_util::pakistan_deconstruct_ents();
}

skipto_car_smash()
{
	skipto_teleport( "skipto_car_smash", _get_friendly_array_market() );
	ai_claw_1 = init_hero( "claw_1" );
	if ( !isDefined( ai_claw_1.ent_flag[ "ready_to_leave_market" ] ) )
	{
		ai_claw_1 ent_flag_init( "ready_to_leave_market" );
	}
	ai_claw_1 ent_flag_set( "ready_to_leave_market" );
	ai_claw_1 ent_flag_set( "ready_to_leave_market" );
	flag_set( "intro_anim_claw_done" );
	market_fx_anim_setup();
	level thread maps/pakistan_util::skipto_market_exit_deconstruct_ents();
}

skipto_market_exit()
{
	m_car = get_ent( "car_smash_car", "targetname", 1 );
	m_car delete();
	m_bus = get_ent( "car_smash_bus", "targetname", 1 );
	m_bus delete();
	ai_claw_1 = init_hero( "claw_1" );
	ai_claw_2 = init_hero( "claw_2" );
	if ( !isDefined( ai_claw_1.ent_flag[ "ready_to_leave_market" ] ) )
	{
		ai_claw_1 ent_flag_init( "ready_to_leave_market" );
	}
	ai_claw_1 ent_flag_set( "ready_to_leave_market" );
	maps/pakistan_street::claws_toggle_firing( 0 );
	skipto_teleport( "skipto_market_exit", _get_friendly_array_market() );
	flag_set( "intro_anim_claw_done" );
	level.b_vo_played = 1;
	level thread maps/pakistan_util::skipto_market_exit_deconstruct_ents();
	trigger_use( "triggercolor_approach_exit" );
	wait 0,1;
	trigger_use( "frogger_colors_initial_positions_trigger" );
	nd_claw_1 = getstruct( "market_drone_goal1", "targetname" );
	nd_claw_2 = getstruct( "market_drone_goal2", "targetname" );
	ai_claw_1 forceteleport( nd_claw_1.origin, nd_claw_1.angles );
	ai_claw_2 forceteleport( nd_claw_2.origin, nd_claw_2.angles );
}

skipto_market_exit_perk()
{
	level.player setperk( "specialty_brutestrength" );
	skipto_market_exit();
	trigger_use( "frogger_colors_initial_positions_trigger" );
	level thread brute_force_setup();
	level thread maps/pakistan_util::skipto_market_exit_deconstruct_ents();
}

skipto_market_exit_no_perk()
{
	level.player unsetperk( "specialty_brutestrength" );
	skipto_market_exit();
	level thread maps/pakistan_util::skipto_market_exit_deconstruct_ents();
}

_get_friendly_array_market()
{
	a_friendlies = [];
	a_friendlies[ a_friendlies.size ] = init_hero( "harper" );
	a_friendlies[ a_friendlies.size ] = init_hero( "salazar" );
	a_friendlies[ a_friendlies.size ] = init_hero( "claw_1" );
	a_friendlies[ a_friendlies.size ] = init_hero( "claw_2" );
	return a_friendlies;
}

intro()
{
	screen_fade_out( 0 );
	clientnotify( "cleanup_market_dynents" );
	level thread maps/pakistan_util::pakistan_deconstruct_ents();
	level thread _intro_fake_gunshots();
	level clientnotify( "isnp" );
	level.player visionsetnaked( "claw_base", 0 );
	level clientnotify( "stfutz" );
	spawn_intro_enemy();
	run_scene_first_frame( "intro_anim" );
	run_scene_first_frame( "intro_anim_claw" );
	run_scene_first_frame( "intro_anim_enemy" );
	attach_data_glove_texture( "intro_anim" );
	level thread hide_3rdperson_ropes();
	wait 0,1;
	level thread run_scene( "intro_anim_enemy" );
	level thread run_scene( "intro_anim" );
	level thread run_scene( "intro_anim_claw" );
	level thread intro_wait_notify();
	level thread vo_intro_enemy();
	level thread _full_screen_static();
	level thread visor_message_boot_up();
	luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"drone_claw_wflamethrower" );
	wait 0,5;
	level thread screen_fade_in( 1 );
	level clientnotify( "clawfutz" );
	level clientnotify( "aS_on" );
	scene_wait( "intro_anim" );
	ai_claw_1 = get_ent( "claw_1_ai", "targetname", 1 );
	ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
	ai_claw_1 thread lead_market_ai();
	ai_claw_1 thread claws_move_through_market();
	ai_claw_1 thread ai_claw_walk_rumble();
	ai_claw_2 thread ai_claw_walk_rumble();
	level thread market_claw_targets_update();
	ai_claw_1 thread claw_kill_enemies_behind();
	setmusicstate( "PAK_INTRO_MARKET" );
	level.player setstance( "stand" );
	level.player allow_prone( 0 );
	level thread spawn_market_drone();
	level thread spawn_first_wave();
	level thread enemy_color_chain();
	level thread enemy_spawn_control();
	level thread fxanim_destruction_control();
	level.b_vo_played = 0;
}

claws_move_through_market()
{
	ai_brutus = getent( "claw_2_ai", "targetname" );
	self clear_force_color();
	ai_brutus clear_force_color();
	level.salazar clear_force_color();
	level.harper setgoalpos( level.harper.origin );
	level.salazar setgoalpos( level.salazar.origin );
	t_enter = getent( "triggercolor_claw_enter", "targetname" );
	nd_salazar = getnode( "salazar_start_node", "targetname" );
	nd_harper = getnode( "harper_start_node", "targetname" );
	self setgoalpos( t_enter.origin );
	level.harper setgoalnode( nd_harper );
	level.salazar setgoalnode( getnode( "market_salazar_first_goal1", "targetname" ) );
	flag_wait( "triggercolor_claw_enter" );
	nd_goal = getnode( "claw_1_moveup_begin2", "targetname" );
	self setgoalnode( nd_goal );
	ai_brutus setgoalnode( getnode( "claw_2_path_start", "targetname" ) );
	flag_wait( "claw_1_start_right_path" );
	flag_wait( "claw_market_moveup_2" );
	nd_goal = getnode( "claw_1_moveup_market_mid2", "targetname" );
	self setgoalnode( nd_goal );
	wait 2;
	ai_brutus setgoalnode( getnode( "claw_2_moveup_market_mid2", "targetname" ) );
	flag_wait( "mid_fallback" );
	nd_goal = getnode( "claw_1_moveup_market_far2", "targetname" );
	self setgoalnode( nd_goal );
	ai_brutus setgoalnode( getnode( "claw_2_moveup_market_far2", "targetname" ) );
	level.salazar set_force_color( "b" );
	flag_wait( "registers_fallback" );
	flag_wait( "trigger_registers_market" );
	flag_wait( "bus_smash_go" );
	ai_brutus clear_force_color();
	if ( isDefined( ai_brutus ) )
	{
		ai_brutus waittill_claw_moves_to_a_node( "market_brutus_exit_goal", "bus_smash_trigger" );
	}
	if ( isDefined( ai_brutus ) )
	{
		ai_brutus set_force_color( "p" );
	}
	if ( isDefined( self ) )
	{
		self waittill_claw_moves_to_a_node( "claw_1_moveup_market_exit", "bus_smash_trigger" );
	}
	if ( isDefined( self ) )
	{
		self set_force_color( "y" );
	}
}

waittill_claw_moves_to_a_node( str_node, str_trigger )
{
	level endon( "brute_force_unlock_player_started" );
	level endon( "fxanim_car_corner_crash_start" );
	self endon( "delete" );
	a_nd_goals = getnodearray( str_node, "targetname" );
	t_zone = getent( str_trigger, "targetname" );
	while ( isDefined( self ) && isDefined( t_zone ) && !self istouching( t_zone ) )
	{
		nd_goal = random( a_nd_goals );
		self setgoalnode( nd_goal );
		wait 2;
	}
}

visor_message_boot_up()
{
	level endon( "harper_kick" );
	level thread gcm_active_message();
	while ( 1 )
	{
		add_visor_text( "PAKISTAN_SHARED_GCM_OFFLINE", 0, "orange", undefined, 1, 0,3, 0,5 );
		wait 1;
		remove_visor_text( "PAKISTAN_SHARED_GCM_OFFLINE" );
		wait 0,3;
	}
}

gcm_active_message()
{
	flag_wait( "harper_kick" );
	wait 0,5;
	remove_visor_text( "PAKISTAN_SHARED_GCM_OFFLINE" );
	wait 0,1;
	add_visor_text( "PAKISTAN_SHARED_GCM_ONLINE", 3 );
	wait 4;
	add_visor_text( "PAKISTAN_SHARED_CLAW_ONLINE", 5 );
}

vo_intro_enemy()
{
	queue_dialog_enemy( "isi1_we_have_them_trapped_0", 3 );
	queue_dialog_enemy( "isi2_everyone_get_back_0", 12,5 );
	flag_wait( "door_exploded" );
	queue_dialog_enemy( "isi3_move_in_0", 0,5 );
	queue_dialog_enemy( "isi4_what_the_hell_is_tha_0", 3,5 );
	queue_dialog_enemy( "isi1_infantry_has_drone_a_0", 1 );
	queue_dialog_enemy( "isi2_pull_back_pull_back_0", 0,5 );
	flag_wait( "claw_market_moveup_2" );
	queue_dialog_enemy( "isi4_shoot_and_move_0", 1 );
	flag_wait( "claw_market_moveup_3" );
	queue_dialog_enemy( "isi3_we_re_outgunned_ca_0", 1 );
	flag_wait( "bus_smash_go" );
	queue_dialog_enemy( "isi1_we_have_to_retreat_0", 1 );
	flag_wait( "frogger_combat_started" );
	queue_dialog_enemy( "isi2_set_up_ambush_points_0", 1 );
}

hide_3rdperson_ropes()
{
	flag_wait( "intro_anim_started" );
	ai_body = get_ais_from_scene( "intro_anim", "mason_fullbody" );
	ai_body hidepart( "TAG_STOWED_BACK" );
}

intro_wait_notify()
{
	wait 12;
	level clientnotify( "isnp_f" );
	level clientnotify( "nofutz" );
}

lead_market_ai()
{
	trigger_wait( "triggercolor_claw_right", "targetname", self );
	trigger_use( "triggercolor_claw_enter_follow" );
	trigger_wait( "triggercolor_claw_market", "targetname", self );
	trigger_use( "triggercolor_claw_market_follow" );
	trigger_wait( "triggercolor_claw_registers", "targetname", self );
	trigger_use( "triggercolor_claw_registers_follow" );
	trigger_wait( "triggercolor_claw_readyexit", "targetname", self );
	trigger_use( "triggercolor_claw_readyexit_follow" );
}

spawn_intro_enemy()
{
	sp_enemy = getent( "market_intro_enemy", "targetname" );
	a_ai_enemies = [];
	i = 0;
	while ( i < 9 )
	{
		a_ai_enemies[ i ] = sp_enemy spawn_ai( 1 );
		a_ai_enemies[ i ].animname = "enemy" + i;
		a_ai_enemies[ i ] set_force_color( "r" );
		a_ai_enemies[ i ] thread intro_enemy_logic();
		i++;
	}
}

intro_enemy_logic()
{
	self endon( "death" );
	self setgoalpos( self.origin );
	self magic_bullet_shield();
	level waittill( "claw_firing" );
	self stop_magic_bullet_shield();
}

spawn_first_wave()
{
	wait 2;
	a_sp_enemies = getentarray( "market_intro_spawners", "targetname" );
	_a489 = a_sp_enemies;
	_k489 = getFirstArrayKey( _a489 );
	while ( isDefined( _k489 ) )
	{
		sp_enemy = _a489[ _k489 ];
		sp_enemy spawn_ai( 1 );
		wait 0,1;
		_k489 = getNextArrayKey( _a489, _k489 );
	}
	trigger_use( "triggercolor_axis_intro" );
	waittill_ai_group_ai_count( "aigroup_intro", 4 );
	flag_set( "intro_fallback" );
}

enemy_color_chain()
{
	flag_wait( "intro_fallback" );
	trigger_use( "triggercolor_intro_fallback" );
	trigger_use( "triggercolor_mid_fallback" );
	flag_wait_any( "claw_market_moveup_3", "mid_fallback" );
	market_enemy_force_goal();
	flag_wait_any( "market_drone_spawn_left", "market_drone_spawn_right", "registers_fallback" );
	trigger_use( "triggercolor_registers_fallback" );
	market_enemy_force_goal();
}

market_enemy_force_goal()
{
	a_ai_enemies = getaiarray( "axis" );
	_a529 = a_ai_enemies;
	_k529 = getFirstArrayKey( _a529 );
	while ( isDefined( _k529 ) )
	{
		ai_enemy = _a529[ _k529 ];
		ai_enemy thread force_goal( undefined, 64, 1, undefined, 1 );
		_k529 = getNextArrayKey( _a529, _k529 );
	}
}

enemy_spawn_control()
{
	flag_wait( "claw_1_start_right_path" );
	simple_spawn( "market_produce_initial" );
	waittill_ai_group_ai_count( "group_produce_initial", 6 );
	spawn_manager_enable( "manager_market_produce" );
	flag_wait( "trigger_registers_market" );
	spawn_manager_kill( "manager_market_produce" );
	spawn_manager_enable( "manager_market_registers" );
	flag_wait_any( "market_drone_spawn_left", "market_drone_spawn_right" );
	spawn_manager_kill( "manager_market_registers" );
	spawn_manager_enable( "manager_market_exit" );
	flag_wait( "bus_crash_drone" );
	spawn_manager_kill( "manager_market_exit" );
	flag_wait( "frogger_combat_started" );
	a_ai_market = get_ai_array( "market_guy", "script_noteworthy" );
	_a566 = a_ai_market;
	_k566 = getFirstArrayKey( _a566 );
	while ( isDefined( _k566 ) )
	{
		ai_market = _a566[ _k566 ];
		ai_market die();
		_k566 = getNextArrayKey( _a566, _k566 );
	}
}

set_player_invulerability( b_invulnerable, n_delay )
{
/#
	assert( isplayer( self ), "set_player_invulnerability can only be used on players!" );
#/
	if ( !isDefined( n_delay ) )
	{
		n_delay = 0;
	}
	wait n_delay;
	if ( b_invulnerable )
	{
		self enableinvulnerability();
	}
	else
	{
		self disableinvulnerability();
	}
}

_intro_claw_fire_turret( e_target, n_time_to_fire, b_spinup )
{
	str_turret = self.turret.weaponinfo;
	n_fire_time = weaponfiretime( str_turret );
	self.turret setturretspinning( 1 );
	if ( !isDefined( b_spinup ) || b_spinup == 1 )
	{
		wait 1,5;
	}
	n_shots = int( n_time_to_fire / n_fire_time );
	i = 0;
	while ( i < n_shots )
	{
		if ( isDefined( e_target ) )
		{
			self.turret settargetentity( e_target );
			self.turret shootturret();
/#
			level thread draw_line_for_time( self.turret.origin, e_target.origin, 1, 1, 1, n_fire_time );
#/
		}
		wait n_fire_time;
		i++;
	}
	self.turret setturretspinning( 0 );
	self.turret maps/_turret::enable_turret();
}

_intro_fake_gunshots()
{
	wait 0,5;
	s_gunfire_1 = get_struct( "intro_fake_fire_struct_1", "targetname", 1 );
	s_gunfire_1 thread _loop_fake_fire( "insas_sp", 12, 3, 1 );
	s_gunfire_2 = get_struct( "intro_fake_fire_struct_2", "targetname", 1 );
	s_gunfire_2 thread _loop_fake_fire( "qbb95_sp", 12, 3, 0,5 );
	s_gunfire_3 = get_struct( "intro_fake_fire_struct_3", "targetname", 1 );
	s_gunfire_3 thread _loop_fake_fire( "tar21_sp", 14, 1,5, 0,25 );
	level waittill( "intro_return_from_black" );
	wait 0,5;
	s_gunfire_1 thread _loop_fake_fire( "insas_sp", 15, 3, 1 );
	s_gunfire_2 thread _loop_fake_fire( "qbb95_sp", 12, 3, 0,5 );
	s_gunfire_3 thread _loop_fake_fire( "tar21_sp", 15, 1,5, 2 );
}

_loop_fake_fire( str_weapon, n_bursts_total, n_burst_time, n_burst_wait )
{
	level endon( "intro_fake_gunfire_stop" );
	s_target = get_struct( self.target, "targetname", 1 );
	n_fire_time = weaponfiretime( str_weapon );
	n_shots_in_burst = int( n_burst_time / n_fire_time );
	n_bursts = 0;
	while ( n_bursts < n_bursts_total )
	{
		n_shots = 0;
		while ( n_shots < n_shots_in_burst )
		{
			magicbullet( str_weapon, self.origin, s_target.origin );
			wait n_fire_time;
			n_shots++;
		}
		wait n_burst_wait;
		n_bursts++;
	}
}

_full_screen_static()
{
	clientnotify( "init_claw" );
	level waittill( "persp_switch" );
	clientnotify( "disable_claw_boot" );
}

claw_flamethrower_perk_setup()
{
	level endon( "remove_flamethrower_perk_option" );
	t_use = get_ent( "claw_flamethrower_perk_trigger", "targetname", 1 );
	v_offset = vectorScale( ( 0, 0, 0 ), 64 );
	if ( level.player hasperk( "specialty_trespasser" ) )
	{
		t_use enablelinkto();
		t_use.origin = self gettagorigin( "tag_eye" );
		t_use linkto( self, "tag_eye", v_offset );
		wait 0,1;
		t_use setcursorhint( "HINT_NOICON" );
		t_use sethintstring( &"PAKISTAN_SHARED_PERK_GET_FLAMETHROWER" );
		set_objective( level.obj_interact_lock_breaker, self, "interact" );
		while ( 1 )
		{
			t_use trigger_wait();
			if ( level.player maps/_utility::use_button_held() )
			{
				break;
			}
			else
			{
				wait 0,1;
			}
		}
		set_objective( level.obj_interact_lock_breaker, undefined, "done", undefined, 0 );
		flag_set( "lockbreaker_used" );
		self thread claw_give_flamethrower();
		level.player set_temp_stat( 3, 1 );
	}
	t_use delete();
}

claw_remove_flamethrower_perk_option()
{
	level notify( "remove_flamethrower_perk_option" );
	set_objective( level.obj_interact_lock_breaker, undefined, "remove" );
	t_use = get_ent( "claw_flamethrower_perk_trigger", "targetname" );
	if ( isDefined( t_use ) )
	{
		t_use unlink();
		wait_network_frame();
		t_use delete();
	}
}

claw_give_flamethrower()
{
	level.player set_player_invulerability( 1 );
	level.player thread maps/pakistan_util::data_glove_animation( "data_glove_claw_sp" );
	level.player set_player_invulerability( 0, 1 );
	v_position = self.origin;
	v_angles = self.angles;
	setsaveddvar( "flame_system_enabled", 1 );
	self.turret_flamethrower = maps/_turret::create_turret( v_position, v_angles, self.team, "bigdog_flamethrower", "veh_t6_drone_claw_turret_flamethrower", self gettagorigin( "tag_flame_thrower_fx" ) - self.origin );
	self.turret_flamethrower linkto( self, "tag_flame_thrower_fx", ( -1, 1, -0,75 ) );
	self.turret_flamethrower maps/_turret::set_turret_burst_parameters( 3, 6, 2, 6 );
	self.turret_flamethrower maketurretunusable();
	self.turret_flamethrower.accuracy = 0,4;
	self thread claw_flamethrower_control();
	add_visor_text( "PAKISTAN_SHARED_FLAMETHROWER_ENABLED", 5, "orange" );
}

attach_data_glove_texture( str_scene )
{
	m_player_body = get_model_or_models_from_scene( str_scene, "player_body" );
	m_player_body attach( "c_usa_cia_claw_viewbody_vson", "J_WristTwist_LE" );
}

market()
{
	market_ai_setup();
	level.player thread maps/pakistan_util::market_corpse_control();
	level thread market_fx_anim_setup();
	if ( level.player hasperk( "specialty_trespasser" ) )
	{
		ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
		ai_claw_2 thread claw_flamethrower_perk_setup();
	}
	turn_on_claw_firing();
	delay_thread( 0,25, ::maps/pakistan_anim::vo_market_enter );
	level thread _market_clear_logic();
}

market_vehicle_setup()
{
	a_vehicles = get_ent_array( "market_vehicles", "script_noteworthy", 1 );
	_a864 = a_vehicles;
	_k864 = getFirstArrayKey( _a864 );
	while ( isDefined( _k864 ) )
	{
		vehicle = _a864[ _k864 ];
		vehicle movez( 200, 0,05 );
		vehicle waittill( "movedone" );
		vehicle.market_vehicle_in_place = 1;
		_k864 = getNextArrayKey( _a864, _k864 );
	}
}

market_fx_anim_setup()
{
	level thread bus_smash_wall_collision_think();
	a_m_shelves = getentarray( "fxanim_shelving_unit_dest", "targetname" );
	_a879 = a_m_shelves;
	_k879 = getFirstArrayKey( _a879 );
	while ( isDefined( _k879 ) )
	{
		m_shelf = _a879[ _k879 ];
		m_shelf ignorecheapentityflag( 1 );
		_k879 = getNextArrayKey( _a879, _k879 );
	}
	level thread play_fx_anim_on_trigger( "market_ceiling_1_damage_trigger", "fxanim_market_ceiling_01_start" );
	level thread play_fx_anim_on_trigger( "market_ceiling_2_damage_trigger", "fxanim_market_ceiling_02_start" );
	flag_wait( "bus_smash_go" );
	m_car_corner_vehicle = get_ent( "car_corner_crash_vehicle", "targetname", 1 );
	while ( !isDefined( m_car_corner_vehicle.market_vehicle_in_place ) )
	{
		wait 0,05;
	}
	level thread run_scene( "car_corner_crash_loop" );
}

fxanim_destruction_control()
{
	flag_wait( "claw_market_moveup_2" );
	maps/pakistan_util::spawn_grenades_at_structs( "intro_magic_grenade_spot1" );
	level thread intro_spawn_dynents( 0,1, "fxanim_1_dynent_spawn_spot", ( 1,2, 0,2, 1,9 ) );
	level thread intro_spawn_dynents( 0,1, "fxanim_1_dynent_spawn_spot", ( -0,9, 0,1, 0,5 ) );
	wait 1,5;
	cleanupspawneddynents();
	flag_wait( "trigger_registers_market" );
	maps/pakistan_util::spawn_grenades_at_structs( "intro_magic_grenade_spot2" );
	wait_network_frame();
	a_s_grenade_spots = getstructarray( "intro_grenade_spots", "script_noteworthy" );
	_a922 = a_s_grenade_spots;
	_k922 = getFirstArrayKey( _a922 );
	while ( isDefined( _k922 ) )
	{
		s_grenade_spot = _a922[ _k922 ];
		s_grenade_spot structdelete();
		_k922 = getNextArrayKey( _a922, _k922 );
	}
}

bus_smash_wall_collision_think()
{
	m_wall_pristine = get_ent( "market_wall_pristine", "targetname", 1 );
	m_wall_destroyed = get_ent( "market_wall_destroyed", "targetname", 1 );
	m_wall_phys_clip = get_ent( "market_wall_destroyed", "targetname", 1 );
	m_wall_weapon_clip = get_ent( "market_bus_crash_wall_clip", "targetname", 1 );
	m_wall_destroyed movez( 1000 * -1, 0,05 );
	flag_wait( "bus_smash_started" );
	wait 4;
	m_wall_pristine delete();
	m_wall_phys_clip delete();
	m_wall_weapon_clip delete();
}

market_ai_setup()
{
	init_heroes( array( "harper", "salazar", "crosby" ) );
	add_spawn_function_group( "frogger_start_balcony_guy", "script_noteworthy", ::lower_attacker_accuracy );
	level.harper.grenadeawareness = 0;
	level.salazar.grenadeawareness = 0;
	e_market_volume = get_ent( "market_volume", "targetname", 1 );
	e_fallback_volume = get_ent( "market_fallback_volume", "targetname", 1 );
	a_fallback_nodes = getnodearray( "market_fallback_nodes", "script_noteworthy" );
	level.harper set_goalradius( 64 );
	ai_claw_1 = init_hero( "claw_1", ::claw_1_market_movement );
	ai_claw_2 = init_hero( "claw_2", ::claw_2_market_movement );
	ai_claw_1.shoot_only_on_sight = 1;
	ai_claw_1 thread claw_run_over_enemy_watcher( "bus_crash_drone" );
	ai_claw_2 thread claw_run_over_enemy_watcher( "bus_crash_drone" );
}

lower_attacker_accuracy()
{
	self endon( "death" );
	self.attackeraccuracy = 0,5;
}

market_sm_func( e_market_volume, e_fallback_volume, a_fallback_nodes )
{
	self endon( "death" );
	a_cover_nodes = getcovernodearray( self.origin, 650 );
	if ( !isDefined( level.rusher_time_last ) )
	{
		level.rusher_time_last = 0;
	}
	b_found_node = 0;
	while ( !b_found_node )
	{
		nd_goal = random( a_cover_nodes );
		if ( !isnodeoccupied( nd_goal ) )
		{
			b_found_node = is_point_inside_volume( nd_goal.origin, e_market_volume );
		}
		wait 0,05;
	}
	self set_goalradius( 650 );
	self set_goal_node( nd_goal );
	if ( !flag( "market_fallback_start" ) )
	{
		self waittill( "goal" );
		self _market_sm_func_rusher();
	}
	self _market_sm_func_fallback( e_fallback_volume, a_fallback_nodes );
}

_market_sm_func_rusher()
{
	n_rusher_cooldown_ms = 4000;
	b_rushing = 0;
	while ( isalive( self ) && !b_rushing && !flag( "market_fallback_start" ) )
	{
		a_sm_guys = get_ent_array( "market_sm_spawners", "targetname" );
		a_close = get_within_range( self.origin, a_sm_guys, 150 );
		n_distance_to_player = distance( self.origin, level.player.origin );
		n_time = getTime();
		b_should_rush_from_group = a_close.size > 2;
		if ( n_distance_to_player > 1024 )
		{
			b_should_rush_from_distance = randomint( 100 ) < 20;
		}
		b_rusher_cooldown_up = ( getTime() - level.rusher_time_last ) > n_rusher_cooldown_ms;
		if ( b_rusher_cooldown_up || b_should_rush_from_group && b_should_rush_from_distance )
		{
			debug_print_line( "rusher activated" );
			self maps/_rusher::rush( "too_close_to_claw", 10 );
			b_rushing = 1;
		}
		wait randomfloatrange( 5, 10 );
	}
}

_market_sm_func_fallback( e_fallback_volume, a_fallback_nodes )
{
	n_distance_to_fallback_sq = 600 * 600;
	b_do_trace = 1;
	b_found_fallback_node = 0;
	while ( !b_found_fallback_node )
	{
		wait randomfloatrange( 0,5, 5 );
		while ( distancesquared( self.origin, level.player.origin ) > n_distance_to_fallback_sq )
		{
			wait 1;
		}
		b_is_goal_inside_fallback_volume = is_point_inside_volume( self.goalpos, e_fallback_volume );
		if ( !b_is_goal_inside_fallback_volume )
		{
			b_found_node = 0;
			nd_goal = undefined;
			a_fallback_nodes = array_randomize( a_fallback_nodes );
			i = 0;
			while ( i < a_fallback_nodes.size )
			{
				if ( !isnodeoccupied( a_fallback_nodes[ i ] ) )
				{
					b_found_node = 1;
					nd_goal = a_fallback_nodes[ i ];
				}
				wait 0,05;
				i++;
			}
			if ( isDefined( nd_goal ) )
			{
				debug_print_line( "fallback activated" );
				b_found_fallback_node = 1;
				self set_goal_node( nd_goal );
				self setgoalvolumeauto( e_fallback_volume );
			}
		}
	}
}

claw_1_init()
{
	sp_claw_1 = get_ent( "claw_1", "targetname", 1 );
	ai_claw_1 = get_ent( "claw_1_ai", "targetname" );
	if ( isDefined( ai_claw_1 ) && !isDefined( ai_claw_1.ent_flag[ "ready_to_leave_market" ] ) )
	{
		ai_claw_1 thread ent_flag_init( "ready_to_leave_market" );
	}
	else
	{
		sp_claw_1 add_spawn_function( ::ent_flag_init, "ready_to_leave_market" );
	}
}

claw_1_market_movement()
{
	self set_goalradius( 16 );
	flag_wait( "claw_market_moveup_3" );
	if ( isDefined( self ) )
	{
		self ent_flag_set( "ready_to_leave_market" );
	}
}

claw_2_market_movement()
{
	self.goalradius = 16;
	self.my_color = self get_force_color();
	self set_ignoreme( 1 );
	flag_wait( "market_fallback_start" );
	self set_ignoreme( 0 );
}

turn_on_claw_firing()
{
	flag_wait( "intro_anim_claw_done" );
	wait_network_frame();
	autosave_by_name( "market_start" );
	wait 0,1;
	enable_claw_fire_direction_feature( 0 );
}

enable_claw_fire_direction_feature( b_donag )
{
	if ( !isDefined( b_donag ) )
	{
		b_donag = 1;
	}
	level.player maps/_fire_direction::init_fire_direction();
	level.player maps/_fire_direction::add_fire_direction_func( ::claw_fire_direction_func );
	ai_claw_1 = get_ent( "claw_1_ai", "targetname", 1 );
	maps/_fire_direction::add_fire_direction_shooter( ai_claw_1 );
	ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
	maps/_fire_direction::add_fire_direction_shooter( ai_claw_2 );
	if ( b_donag == 1 )
	{
		maps/pakistan_anim::claw_nag_vo_setup();
	}
}

claw_fire_direction_func()
{
	v_origin = self geteye();
	v_angles = anglesToForward( self getplayerangles() );
	v_aim_pos = v_origin + ( v_angles * 8000 );
	a_trace = bullettrace( v_origin, v_aim_pos, 0, self );
	v_shoot_pos = a_trace[ "position" ];
	a_shooters = maps/_fire_direction::get_fire_direction_shooters();
	a_enemies = getaiarray( "axis" );
	_a1203 = a_enemies;
	_k1203 = getFirstArrayKey( _a1203 );
	while ( isDefined( _k1203 ) )
	{
		ai_guy = _a1203[ _k1203 ];
		ai_guy._fire_direction_targeted = undefined;
		_k1203 = getNextArrayKey( _a1203, _k1203 );
	}
	if ( a_shooters.size > 0 )
	{
		array_thread( a_shooters, ::_claw_fire_direction_grenades, v_shoot_pos );
	}
}

_claw_fire_direction_grenades( v_position )
{
	self endon( "death" );
	e_temp = spawn( "script_origin", v_position );
	self.scripted_target = e_temp;
	self thread _claw_fire_guns_at_targets_in_range( v_position );
	i = 0;
	while ( i < 2 )
	{
		v_start_pos = self gettagorigin( "tag_turret" );
		b_can_fire_safely = self _can_hit_target_safely( v_position, v_start_pos );
		if ( b_can_fire_safely )
		{
			v_grenade_velocity = vectornormalize( v_position - v_start_pos ) * 2000;
			self magicgrenadetype( "claw_grenade_impact_explode_sp", v_start_pos, v_grenade_velocity );
			self playsoundontag( "wpn_claw_gren_fire_npc", "tag_neck" );
		}
		wait 0,5;
		i++;
	}
	self.turret maps/_turret::clear_turret_target();
	self.scripted_target = undefined;
	e_temp delete();
	if ( !level.b_vo_played )
	{
		level thread maps/pakistan_anim::vo_fire_directed();
		level.b_vo_played = 1;
	}
}

_claw_fire_guns_at_targets_in_range( v_position )
{
	if ( isDefined( level.vh_market_drone ) )
	{
		if ( level.player is_player_looking_at( level.vh_market_drone.origin, undefined, 0 ) )
		{
			self set_ignoreall( 1 );
			self thread _intro_claw_fire_turret( level.vh_market_drone, randomfloatrange( 4,5, 6 ) );
			wait 6;
			self set_ignoreall( 0 );
			if ( isDefined( level.vh_market_drone ) )
			{
				radiusdamage( level.vh_market_drone.origin, 500, 15000, 12000 );
			}
		}
	}
	a_enemies = getaiarray( "axis" );
	a_guys_within_range = get_within_range( v_position, a_enemies, 256 );
	_a1284 = a_guys_within_range;
	_k1284 = getFirstArrayKey( _a1284 );
	while ( isDefined( _k1284 ) )
	{
		ai_guy = _a1284[ _k1284 ];
		ai_guy._fire_direction_targeted = 1;
		_k1284 = getNextArrayKey( _a1284, _k1284 );
	}
	n_time = getTime();
	if ( a_guys_within_range.size == 0 )
	{
		e_temp = spawn( "script_origin", v_position );
		self.turret maps/_turret::shoot_turret_at_target( e_temp, 5, ( 0, 0, 0 ) );
		e_temp delete();
	}
	else
	{
		n_enemies_max = 3;
		n_cycles = 0;
		b_should_fire = 1;
		while ( b_should_fire )
		{
			ai_enemy = random( a_enemies );
			self.turret thread maps/_turret::shoot_turret_at_target( ai_enemy, 2, ( 0, 0, 0 ) );
			ai_enemies = array_removedead( a_enemies );
			n_cycles++;
			if ( a_enemies.size > 0 )
			{
				b_should_fire = n_cycles < n_enemies_max;
			}
		}
	}
}

_can_hit_target_safely( v_position, v_start_pos )
{
/#
	assert( isDefined( v_position ), "v_position missing for _get_closest_unit_to_fire" );
#/
	a_shooters = maps/_fire_direction::get_fire_direction_shooters();
/#
	assert( isDefined( a_shooters.size > 0 ), "no valid shooters found to use in _can_hit_target_safely. Add these with add_fire_direction_shooter( <ent_that_can_shoot> ) first." );
#/
	a_trace = bullettrace( v_start_pos, v_position, 0, self );
	b_can_hit_target = 1;
	b_will_hit_player = distance( a_trace[ "position" ], level.player.origin ) < 256;
	b_will_hit_self = distance( a_trace[ "position" ], v_start_pos ) < 256;
	b_will_hit_friendly = 0;
	a_friendlies = getaiarray( "allies" );
	j = 0;
	while ( j < a_friendlies.size )
	{
		b_could_hit_friendly = distance( a_trace[ "position" ], a_friendlies[ j ].origin ) < 256;
		if ( b_could_hit_friendly )
		{
			b_will_hit_friendly = 1;
		}
		j++;
	}
	v_to_player = vectornormalize( level.player.origin - v_start_pos );
	v_to_target = vectornormalize( v_position - v_start_pos );
	n_dot = vectordot( v_to_player, v_to_target );
	b_player_in_grenade_path = n_dot > 0,9;
	if ( b_can_hit_target && !b_will_hit_player && !b_will_hit_self && !b_will_hit_friendly )
	{
		b_should_fire_grenades = !b_player_in_grenade_path;
	}
	return b_should_fire_grenades;
}

_get_closest_unit_to_fire( v_position )
{
/#
	assert( isDefined( v_position ), "v_position missing for _get_closest_unit_to_fire" );
#/
	a_shooters = maps/_fire_direction::get_fire_direction_shooters();
/#
	assert( isDefined( a_shooters.size > 0 ), "no valid shooters found to use in _get_closest_unit_to_fire. Add these with add_fire_direction_shooter( <ent_that_can_shoot> ) first." );
#/
	e_closest_shooter = getclosest( v_position, a_shooters );
	return e_closest_shooter;
}

_claw_grenade_launch_internal()
{
	sp_grenade_guy = get_ent( "claw_grenade_guy", "targetname", 1 );
	sp_grenade_guy add_spawn_function( ::claw_grenade_launch_hack );
	ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
	ai_claw_2 endon( "death" );
	level thread run_scene( "claw_grenade_launch" );
	wait 0,1;
	ai_target = get_ent( "claw_grenade_guy_ai", "targetname", 1 );
	ai_claw_2 setentitytarget( ai_target );
	scene_wait( "claw_grenade_launch" );
	ai_claw_2 clearentitytarget();
}

claw_grenade_launch_hack()
{
	self endon( "death" );
	wait 0,2;
	self set_goalradius( 8 );
}

_claw_launches_grenade_at_guy( ai_claw )
{
	ai_target = get_ent( "claw_grenade_guy_ai", "targetname", 1 );
	v_start_pos = ai_claw gettagorigin( "tag_turret" );
	v_end_pos = ai_target.origin + vectorScale( ( 0, 0, 0 ), 20 );
	v_grenade_velocity = vectornormalize( v_end_pos - v_start_pos ) * 2000;
	ai_claw magicgrenadetype( "claw_grenade_impact_explode_sp", v_start_pos, v_grenade_velocity );
}

market_claw_targets_update()
{
	level waittill( "intro_claw_target_stop" );
	while ( !flag( "frogger_started" ) )
	{
		level.a_ai_enemies = getaiarray( "axis" );
		wait 0,1;
	}
	level.a_ai_enemies = undefined;
}

claw_flamethrower_control()
{
	self.turret_flamethrower clear_turret_target();
	o_fake_target = spawn( "script_origin", self.turret_flamethrower.origin );
	o_fake_target linkto( self, "tag_flame_thrower_fx", ( 64, 1, -0,75 ) );
	self flamethrower_turret_think( o_fake_target );
	if ( isDefined( o_fake_target ) )
	{
		o_fake_target delete();
	}
}

flamethrower_turret_think( o_fake_target )
{
	level endon( "frogger_started" );
	while ( !isDefined( level.a_ai_enemies ) )
	{
		wait 0,2;
	}
	while ( 1 )
	{
		_a1463 = level.a_ai_enemies;
		_k1463 = getFirstArrayKey( _a1463 );
		while ( isDefined( _k1463 ) )
		{
			ai_enemy = _a1463[ _k1463 ];
			if ( isalive( ai_enemy ) && self is_claw_walking() && self get_dot_from_eye( ai_enemy geteye(), 1 ) >= 0,9 && self.turret_flamethrower maps/_turret::turret_trace_test( ai_enemy ) && self.turret_flamethrower _can_hit_target_safely( ai_enemy geteye(), self.turret_flamethrower gettagorigin( "tag_flash" ) ) )
			{
				self.turret_flamethrower set_turret_target( o_fake_target );
				self fire_flamethrower( o_fake_target );
			}
			self.turret_flamethrower clear_turret_target();
			_k1463 = getNextArrayKey( _a1463, _k1463 );
		}
		wait 0,2;
	}
}

fire_flamethrower( o_fake_target )
{
	level endon( "frogger_started" );
	i = 0;
	str_turret = self.turret_flamethrower.weaponinfo;
	n_fire_time = weaponfiretime( str_turret );
	while ( self.hunkereddown == 0 && i <= randomfloatrange( 5, 8 ) )
	{
		self.turret_flamethrower set_turret_target( o_fake_target );
		self.turret_flamethrower fire_turret();
		i++;
		wait n_fire_time;
	}
}

claw_kill_enemies_behind()
{
	level endon( "frogger_started" );
	level waittill( "car_smash_go" );
	while ( !isDefined( level.a_ai_enemies ) )
	{
		wait 0,2;
	}
	while ( 1 )
	{
		_a1511 = level.a_ai_enemies;
		_k1511 = getFirstArrayKey( _a1511 );
		while ( isDefined( _k1511 ) )
		{
			ai_enemy = _a1511[ _k1511 ];
			if ( isalive( ai_enemy ) && self get_dot_from_eye( ai_enemy.origin, 1 ) <= 0,1 )
			{
				ai_enemy bloody_death();
			}
			wait 0,25;
			_k1511 = getNextArrayKey( _a1511, _k1511 );
		}
		wait 4;
	}
}

car_smash()
{
	flag_wait( "car_smash_go" );
	level thread water_surge_street();
	level thread _car_smash_internal();
	level thread bus_smash_timeout();
	trigger_wait( "bus_smash_trigger" );
	level thread _bus_smash_internal();
	if ( !flag( "lockbreaker_used" ) )
	{
		level thread claw_remove_flamethrower_perk_option();
	}
}

bus_smash_timeout()
{
	level endon( "bus_smash_go" );
	flag_wait( "claw_market_moveup_3" );
	wait 36;
	s_exit_spot = getstruct( "market_drone_goal2", "targetname" );
	while ( level.player is_looking_at( s_exit_spot.origin, 0,95 ) )
	{
		wait 0,1;
	}
	trigger_use( "bus_smash_trigger" );
}

_market_clear_logic()
{
	flag_wait( "market_drone_dead" );
	trigger_use( "triggercolor_approach_exit" );
	flag_wait( "bus_crash_drone" );
	wait 1,5;
	debug_print_line( "SM cleared: market_spawn_manager" );
	maps/_fire_direction::_fire_direction_remove_hint();
	maps/pakistan_anim::vo_market_done();
}

water_surge_street()
{
	set_water_dvars_street();
	clientnotify( "frogger_water_surge" );
	delay_thread( 2, ::maps/pakistan_street::raise_water_level );
}

_car_smash_internal()
{
	level endon( "bus_smash_collateral_damage_started" );
	model_restore_area( "zone_market_exit" );
	market_vehicle_setup();
	m_car = get_ent( "car_smash_car", "targetname", 1 );
	t_kill_car = get_ent( "car_kill_trigger", "targetname", 1 );
	t_kill_car thread trigger_kill_ai_on_contact( "car_smash_done", m_car );
	level.player thread car_crash_rumble();
	level thread run_scene( "car_smash_guys" );
	run_scene( "car_smash" );
	if ( !flag( "bus_smash_damage_started" ) )
	{
		level thread run_scene( "car_smash_car_idle" );
		level thread run_scene( "car_smash_ai_idle" );
	}
}

_bus_smash_internal()
{
	m_bus = get_ent( "car_smash_bus", "targetname", 1 );
	t_kill_bus = get_ent( "bus_kill_trigger", "targetname", 1 );
	m_bus playsound( "fxa_bus_approach" );
	clientnotify( "bus_hit" );
	level thread maps/pakistan_anim::vo_bus_smash();
	level thread run_scene( "bus_smash" );
	level thread bus_run_over();
	level.player thread bus_crash_rumble();
	spawn_vehicles_from_targetname_and_drive( "street_debris_follow_market_bus" );
	scene_wait( "bus_smash" );
	wait 1;
	level notify( "claws_stop_firing" );
	trigger_use( "frogger_colors_initial_positions_trigger" );
	autosave_by_name( "pakistan_frogger_start" );
}

bus_run_over()
{
	level endon( "bus_smash_done" );
	flag_wait( "bus_smash_started" );
	bus = get_model_or_models_from_scene( "bus_smash", "car_smash_bus" );
	while ( 1 )
	{
		bus waittill( "touch", e_victim );
		bus setmovingplatformenabled( 1 );
		if ( e_victim == level.player )
		{
			setdvar( "ui_deadquote", &"PAKISTAN_SHARED_BUS_RUNOVER" );
			level.player suicide();
		}
	}
}

trigger_kill_ai_on_contact( str_endon, e_linkto )
{
/#
	assert( isDefined( str_endon ), "str_endon is a required argument for trigger_kill_on_contact" );
#/
	level endon( str_endon );
	b_use_linkto = 0;
	if ( isDefined( e_linkto ) )
	{
		b_use_linkto = 1;
	}
	if ( b_use_linkto )
	{
		self enablelinkto();
		self linkto( e_linkto );
	}
	while ( 1 )
	{
		self waittill( "trigger", e_triggered );
		if ( isDefined( e_triggered.ignoreme ) && e_triggered.ignoreme )
		{
			continue;
		}
		e_triggered dodamage( e_triggered.health + 100, self.origin );
	}
}

market_exit()
{
	level thread vo_market_exit();
	level thread _market_exit_internal();
}

_market_exit_internal()
{
	level thread brute_force_setup();
	if ( isDefined( "frogger_first_wave_spawn_trigger" ) )
	{
		trigger_use( "frogger_first_wave_spawn_trigger", "targetname", undefined, 0 );
	}
	flag_set( "market_done" );
}

claw_toggle_firing( b_should_fire )
{
	if ( !isDefined( b_should_fire ) )
	{
		b_should_fire = 0;
	}
	ai_claw_1 = get_ent( "claw_1_ai", "targetname", 1 );
	ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
	ai_claw_1 set_ignoreall( b_should_fire );
	ai_claw_2 set_ignoreall( b_should_fire );
	ai_claw_1 set_ignoreme( b_should_fire );
	ai_claw_2 set_ignoreme( b_should_fire );
	if ( b_should_fire )
	{
		ai_claw_1.turret turretfireenable();
		ai_claw_2.turret turretfireenable();
		if ( isDefined( ai_claw_2.turret_flamethrower ) )
		{
			ai_claw_2.turret_flamethrower turretfireenable();
			ai_claw_2 thread claw_flamethrower_control();
		}
	}
	else
	{
		ai_claw_1.turret turretfiredisable();
		ai_claw_2.turret turretfiredisable();
		if ( isDefined( ai_claw_2.turret_flamethrower ) )
		{
			ai_claw_2.turret_flamethrower turretfiredisable();
			level notify( "claws_stop_firing" );
		}
	}
}

_change_claw_moveplaybackrate( n_speed_multiplier )
{
	ai_claw_1 = get_ent( "claw_1_ai", "targetname", 1 );
	ai_claw_2 = get_ent( "claw_2_ai", "targetname", 1 );
	ai_claw_1.moveplaybackrate = n_speed_multiplier;
	ai_claw_2.moveplaybackrate = n_speed_multiplier;
}

brute_force_setup()
{
	level endon( "brute_force_bypassed" );
	level thread brute_force_finish();
	level thread salazar_brute_force_anims();
	t_perk = get_ent( "brute_force_perk_trigger", "targetname", 1 );
	t_perk setcursorhint( "HINT_NOICON" );
	t_perk sethintstring( &"SCRIPT_HINT_BRUTE_FORCE" );
	level.player waittill_player_has_brute_force_perk();
	if ( !flag( "brute_force_bypassed" ) )
	{
		set_objective( level.obj_interact_brute_force, t_perk, "interact" );
		t_perk trigger_on();
		t_perk trigger_wait();
		t_bypass = getent( "t_brute_force_bypass", "targetname" );
		if ( isDefined( t_bypass ) )
		{
			t_bypass delete();
		}
		end_scene( "brute_force_idle" );
		end_scene( "brute_force_arrive" );
		level.player startcameratween( 1 );
		level thread run_scene( "brute_force_unlock_player" );
		level.player thread brute_force_rumble();
		run_scene( "brute_force_unlock" );
	}
}

salazar_brute_force_anims()
{
	level endon( "brute_force_bypassed" );
	level endon( "brute_force_unlock_player_started" );
	if ( level.player hasperk( "specialty_brutestrength" ) )
	{
		run_scene( "brute_force_arrive" );
		level thread run_scene( "brute_force_idle" );
	}
}

brute_force_finish()
{
	if ( level.player hasperk( "specialty_brutestrength" ) )
	{
		str_ret = waittill_any_return( "brute_force_bypassed", "brute_force_unlock_started" );
		set_objective( level.obj_interact_brute_force, undefined, "done", undefined, 0 );
		if ( str_ret == "brute_force_bypassed" )
		{
			brute_force_bypass_has_perk();
		}
	}
	else
	{
		brute_force_bypass();
	}
}

brute_force_bypass_has_perk()
{
	getent( "brute_force_perk_trigger", "targetname" ) delete();
	end_scene( "brute_force_idle" );
	brute_force_bypass();
}

brute_force_bypass()
{
	level thread brute_force_bypass_cleanup();
	brute_force_bypass_scenes();
}

brute_force_bypass_scenes()
{
	level.salazar set_goalradius( 4 );
	level thread run_scene( "brute_force_bypass_salazar" );
	flag_wait( "brute_force_bypass_salazar_started" );
	level thread run_scene( "brute_force_bypass_brutus" );
	flag_wait( "brute_force_bypass_brutus_started" );
	level thread run_scene( "brute_force_bypass_maximus" );
	flag_wait( "brute_force_bypass_maximus_started" );
	level thread run_scene( "brute_force_bypass_crosby" );
}

brute_force_bypass_cleanup()
{
	flag_wait( "brute_force_bypass_salazar_done" );
	delete_scene_all( "brute_force_bypass_salazar", 1, 1 );
	flag_wait( "brute_force_bypass_brutus_done" );
	delete_scene_all( "brute_force_bypass_brutus", 1, 1 );
	flag_wait( "brute_force_bypass_crosby_done" );
	delete_scene_all( "brute_force_bypass_crosby", 1, 1, 1 );
	flag_wait( "brute_force_bypass_maximus_done" );
	delete_scene_all( "brute_force_bypass_maximus", 1, 1, 1 );
}

spawn_market_drone()
{
	flag_wait_any( "market_drone_spawn_left", "market_drone_spawn_right" );
	s_spawnpt = getstruct( "market_drone_right_spawnpt" );
	if ( flag( "market_drone_spawn_left" ) )
	{
		s_spawnpt = getstruct( "market_drone_left_spawnpt" );
	}
	level thread radial_damage_from_spot( "market_right_exit_register_pulse_spot", 2 );
	level thread radial_damage_from_spot( "market_exit_register_pulse_spot", 2,1 );
	level.vh_market_drone = spawn_vehicle_from_targetname( "isi_drone" );
	level.vh_market_drone.origin = s_spawnpt.origin;
	level.vh_market_drone.angles = s_spawnpt.angles;
	level.vh_market_drone thread market_drone_logic();
	level.vh_market_drone thread drone_death_func();
	level.vh_market_drone thread drone_killedby_bus();
	wait_network_frame();
	s_spawnpt structdelete();
	level thread maps/pakistan_anim::vo_drone_market();
}

market_drone_logic()
{
	level endon( "bus_crash_drone" );
	self endon( "death" );
	s_goal1 = getstruct( "market_drone_goal1" );
	s_goal2 = getstruct( "market_drone_goal2" );
	s_goal3 = getstruct( "market_drone_goal3" );
	e_target_left = getent( "drone_target_left", "targetname" );
	e_target_right = getent( "drone_target_right", "targetname" );
	self.health = 5000;
	target_set( self );
	self sethoverparams( 10 );
	self setspeed( 35, 20, 8 );
	self setlookatent( level.player );
	self play_fx( "helicopter_drone_spotlight", self gettagorigin( "tag_spotlight" ), self gettagangles( "tag_spotlight" ), "death", 1, "tag_spotlight" );
	if ( flag( "market_drone_spawn_right" ) )
	{
		self setvehgoalpos( s_goal1.origin, 1 );
		self waittill( "goal" );
		self setspeed( 15, 12, 8 );
		self setvehgoalpos( s_goal2.origin, 0 );
		self waittill( "goal" );
		self setvehgoalpos( s_goal3.origin, 1 );
	}
	else
	{
		self setvehgoalpos( s_goal3.origin, 1 );
		self waittill( "goal" );
		self setspeed( 15, 12, 8 );
		self setvehgoalpos( s_goal2.origin, 0 );
		self waittill( "goal" );
		self setvehgoalpos( s_goal1.origin, 1 );
	}
	self waittill( "goal" );
	self setspeed( 20, 15, 10 );
	wait 1;
	self set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 20 ), 0 );
	while ( 1 )
	{
		self setvehgoalpos( s_goal2.origin, 1 );
		self waittill( "goal" );
		wait randomfloatrange( 1, 2 );
		if ( cointoss() )
		{
			self setvehgoalpos( s_goal3.origin, 1 );
			self waittill( "goal" );
			self choose_target_drone( e_target_left );
		}
		else
		{
			self setvehgoalpos( s_goal1.origin, 1 );
			self waittill( "goal" );
			self choose_target_drone( e_target_right );
		}
		wait randomfloatrange( 1, 1,5 );
	}
}

choose_target_drone( e_target )
{
	level endon( "bus_crash_drone" );
	self endon( "death" );
	n_wait = randomfloatrange( 4,5, 5,5 );
	v_offset = ( 0, 0, randomint( 50 ) );
	if ( sighttracepassed( self gettagorigin( "tag_flash" ), level.player get_eye(), 1, level.player ) )
	{
		e_target = level.player;
	}
	self set_turret_target( e_target, v_offset, 0 );
	self fire_turret_for_time( n_wait, 0 );
}

drone_death_func()
{
	self waittill( "death" );
	flag_set( "market_drone_dead" );
}

drone_killedby_bus()
{
	self endon( "death" );
	flag_wait( "bus_crash_drone" );
	radiusdamage( self.origin, 100, 15000, 12000 );
}

vo_market_exit()
{
	level endon( "brute_force_bypassed" );
	level endon( "vo_street_moveup" );
	scene_wait( "brute_force_arrive" );
	level.salazar queue_dialog( "sala_this_door_leads_to_t_0", 6 );
	scene_wait( "brute_force_unlock_player" );
	level.player queue_dialog( "sect_take_brutus_and_maxi_0" );
}

intro_player_rumble()
{
	self rumble_loop( 12, randomfloatrange( 0,9, 1,1 ), "reload_clipout" );
}

brute_force_rumble()
{
	wait 0,5;
	self playrumbleonentity( "damage_light" );
	wait 1;
	self playrumbleonentity( "damage_heavy" );
	earthquake( 0,3, 0,5, self.origin, 1000, self );
	wait 0,5;
	self playrumbleonentity( "damage_light" );
	earthquake( 0,1, 1, self.origin, 1000, self );
	wait 0,25;
	self playrumbleonentity( "damage_heavy" );
	earthquake( 0,3, 0,5, self.origin, 1000, self );
	wait 2;
	self playrumbleonentity( "damage_light" );
	earthquake( 0,1, 1, self.origin, 1000, self );
}

bus_crash_rumble()
{
	self playrumbleonentity( "reload_clipout" );
	earthquake( 0,05, 1, self.origin, 1000, self );
	wait 0,5;
	self playrumbleonentity( "damage_light" );
	earthquake( 0,05, 1, self.origin, 1000, self );
	self playrumbleonentity( "artillery_rumble" );
	earthquake( 0,09, 10 / 2, self.origin, 1000, self );
	self rumble_loop( 10 / 2, 0,5, "damage_light" );
	earthquake( 0,08, 10 / 2, self.origin, 1000, self );
	self rumble_loop( 2, 0,5, "damage_heavy" );
	earthquake( 0,09, 1, self.origin, 1000, self );
	self rumble_loop( 2, 0,5, "artillery_rumble" );
	wait 0,4;
	earthquake( 0,09, 2, self.origin, 1000, self );
	self rumble_loop( 2, 0,5, "artillery_rumble" );
	self rumble_loop( 3, 0,5, "damage_light" );
	self rumble_loop( 8, 0,5, "reload_clipout" );
}

car_crash_rumble()
{
	self playrumbleonentity( "reload_clipout" );
	earthquake( 0,05, 1, self.origin, 1000, self );
	wait 0,5;
	self playrumbleonentity( "damage_light" );
	earthquake( 0,05, 1, self.origin, 1000, self );
	self playrumbleonentity( "artillery_rumble" );
	earthquake( 0,06, 10 / 2, self.origin, 1000, self );
	self rumble_loop( 10 / 2, 0,5, "damage_light" );
}

claws_walk_intro_elevator_room_rumble()
{
	level endon( "brute_force_unlock_done" );
	while ( 1 )
	{
		n_dist = distance2d( level.player.origin, self.origin );
		if ( n_dist <= ( 195 / 2 ) )
		{
			earthquake( randomfloatrange( 0,08, 0,12 ), 1, self.origin, 195, level.player );
			level.player rumble_loop( 2, 1 / 2, "damage_light" );
		}
		if ( n_dist > ( 195 / 2 ) && n_dist <= 195 )
		{
			earthquake( randomfloatrange( 0,03, 0,07 ), 1, self.origin, 195, level.player );
			level.player rumble_loop( 2, 1 / 2, "reload_clipout" );
		}
		wait 0,1;
	}
}

intro_player_scene_logic( m_player_body )
{
	setsaveddvar( "cg_drawFriendlyNames", 0 );
	level.player magic_bullet_shield();
	level.player intro_player_rumble();
	radial_damage_from_spot( "market_intro_shooting_pulse_spot", 1 );
}

_intro_extra_cam()
{
	level notify( "persp_switch" );
	level.player switch_player_scene_to_delta();
	clientnotify( "nofutz" );
	level.player show_hud();
	level.player notify( "end_damage_filter" );
	level.player visionsetnaked( "sp_pakistan_default", 0 );
	setsaveddvar( "r_extracam_custom_aspectratio", 1,777778 );
	ai_claw_2 = simple_spawn_single( "claw_2" );
	ai_claw_2 set_goalradius( 8 );
	ai_claw = get_ent( "claw_1_ai", "targetname", 1 );
	e_extra_cam = maps/_glasses::get_extracam();
	e_extra_cam.origin = ai_claw gettagorigin( "tag_eye" );
	e_extra_cam.angles = ai_claw gettagangles( "tag_eye" );
	e_extra_cam linkto( ai_claw, "tag_eye" );
	maps/_glasses::turn_on_extra_cam( &"extracam_glasses", undefined, 1 );
	wait 0,5;
	maps/_glasses::shrink_pip_fullscreen( 1 );
	luinotifyevent( &"hud_update_vehicle_custom", 1, 0 );
	wait 7,5;
	maps/_glasses::turn_off_extra_cam( undefined );
}

intro_harper_kick_rumble( ai_harper )
{
	level.player playrumbleonentity( "damage_heavy" );
	earthquake( 0,3, 0,5, level.player.origin, 1000, level.player );
	flag_set( "harper_kick" );
}

market_doors_explosion( player )
{
	exploder( 101 );
	earthquake( 1, 2, level.player.origin, 100 );
	level thread intro_spawn_dynents( 0,15, "intro_dynent_spawn_spot", ( -0,1, 1,4, 0,7 ) );
	level thread intro_spawn_dynents( 0, "intro_dynent_spawn_spot_right", ( -0,1, -1,4, 1 ) );
	level thread intro_spawn_dynents( 0, "intro_dynent_spawn_spot_right", ( -0,1, -1,4, 0,5 ) );
	level.player playsound( "evt_door_breach" );
	level.player playrumbleonentity( "artillery_rumble" );
	flag_set( "door_exploded" );
	m_door_clip = getent( "intro_doors_clip", "targetname" );
	m_door_clip delete();
}

_intro_claw_turret_control( ai_maximus )
{
	ai_maximus.turret turretfiredisable();
	level waittill( "intro_fake_gunfire_stop" );
	ai_maximus.turret turretfireenable();
}

_intro_claw_turret_spin( ai_maximus )
{
	debug_print_line( "spin" );
	level notify( "intro_fake_gunfire_stop" );
	ai_maximus.turret setturretspinning( 1 );
	wait 2,9;
	s_claw_target_start = getstruct( "intro_claw_target_start", "targetname" );
	e_door_target_ent = spawn( "script_origin", s_claw_target_start.origin + ( 0, -10, -4 ) );
	ai_maximus.scripted_target = e_door_target_ent;
	ai_maximus thread intro_enemies_kill();
	ai_maximus thread intro_column_damage();
	level thread radial_damage_from_spot( "market_intro_planter_pulse_spot", 2,2 );
	level thread intro_spawn_dynents( 2,5, "market_dynent_spawn_spot", ( -1, 0, 1,6 ) );
	level thread intro_spawn_dynents( 2,8, "market_dynent_spawn_spot", ( -1, 0, 1,6 ) );
	e_door_target_ent thread _claw_door_target_move( 3,6 );
	ai_maximus thread turret_fire();
	ai_maximus thread turret_flash();
	wait 0,5;
	maps/pakistan_util::spawn_grenades_at_structs( "intro_magic_grenade_spot1" );
	level thread intro_spawn_dynents( 0,1, "fxanim_1_dynent_spawn_spot", ( 1,2, 0,2, 1,9 ) );
	level thread intro_spawn_dynents( 0,1, "fxanim_1_dynent_spawn_spot", ( -0,9, 0,1, 0,5 ) );
	level notify( "intro_claw_fire_done" );
	level thread radial_damage_from_spot( "market_intro_extinguisher_pulse_spot", 2,2 );
	wait 7,2;
	ai_maximus.scripted_target = undefined;
	ai_maximus.shoot_only_on_sight = 1;
	ai_maximus.turret clear_turret_target();
	trigger_use( "intro_claw_market_start_movement_trig" );
	setsaveddvar( "cg_drawFriendlyNames", 1 );
	level notify( "intro_claw_target_stop" );
	wait_network_frame();
	level.player stop_magic_bullet_shield();
	s_claw_target_start = getstruct( "intro_claw_target_start", "targetname" );
	s_claw_target_end = getstruct( "intro_claw_target_end", "targetname" );
	e_door_target_ent delete();
	s_claw_target_start structdelete();
	s_claw_target_end structdelete();
}

turret_fire()
{
	str_turret = self.turret.weaponinfo;
	i = 0;
	while ( i <= 121 )
	{
		self.turret fire_turret();
		wait weaponfiretime( str_turret );
		i++;
	}
	self.turret notify( "stop_scripted_flash" );
}

turret_flash()
{
	self.turret endon( "stop_scripted_flash" );
	while ( 1 )
	{
		playfxontag( level._effect[ "intro_claw_muzzle_flash" ], self.turret, "tag_flash" );
		wait 0,35;
	}
}

intro_enemies_kill()
{
	level notify( "claw_firing" );
	a_str_tags = get_bleed_tags();
	ai_guy = get_ais_from_scene( "intro_anim_enemy", "enemy1" );
	if ( isalive( ai_guy ) )
	{
		ai_guy thread excessively_bloody_death( a_str_tags );
	}
	wait 1,7;
	ai_guy = get_ais_from_scene( "intro_anim_enemy", "enemy2" );
	if ( isalive( ai_guy ) )
	{
		ai_guy thread excessively_bloody_death( a_str_tags );
	}
	wait 2,7;
	ai_guy = get_ais_from_scene( "intro_anim_enemy", "enemy3" );
	if ( isalive( ai_guy ) )
	{
		ai_guy thread excessively_bloody_death( a_str_tags );
	}
	wait 1,8;
	ai_guy = get_ais_from_scene( "intro_anim_enemy", "enemy4" );
	if ( isalive( ai_guy ) )
	{
		ai_guy thread excessively_bloody_death( a_str_tags );
	}
	wait 1,2;
	a_ai_intro_guys = get_ai_array( "market_intro_enemy_ai", "targetname" );
	a_ai_intro_guys = arraysort( a_ai_intro_guys, self.origin, 0 );
	_a2465 = a_ai_intro_guys;
	_k2465 = getFirstArrayKey( _a2465 );
	while ( isDefined( _k2465 ) )
	{
		ai_guy = _a2465[ _k2465 ];
		ai_guy bloody_death();
		_k2465 = getNextArrayKey( _a2465, _k2465 );
	}
}

get_bleed_tags()
{
	a_tags = [];
	a_tags[ 0 ] = "j_hip_le";
	a_tags[ 1 ] = "j_hip_ri";
	a_tags[ 2 ] = "j_head";
	a_tags[ 3 ] = "j_spine4";
	a_tags[ 4 ] = "j_elbow_le";
	a_tags[ 5 ] = "j_elbow_ri";
	a_tags[ 6 ] = "j_clavicle_le";
	a_tags[ 7 ] = "j_clavicle_ri";
	return a_tags;
}

excessively_bloody_death( a_str_tags )
{
	i = 0;
	while ( i <= 2 )
	{
		if ( isalive( self ) )
		{
			playfxontag( level._effect[ "intro_blood_single" ], self, a_str_tags[ randomint( a_str_tags.size ) ] );
			wait randomfloatrange( 0,05, 0,1 );
		}
		i++;
	}
	self bloody_death();
}

intro_column_damage()
{
	self endon( "delete" );
	level endon( "intro_anim_claw_done" );
	wait 2,6;
	s_spot = getstruct( "first_right_column_dmg_spot", "targetname" );
	v_z_offset = ( 0, 0, 0 );
	while ( 1 )
	{
		radiusdamage( s_spot.origin + v_z_offset, 64, 100, 150, self, "MOD_EXPLOSIVE" );
		v_z_offset += ( 0, 0, 8 );
		wait 0,1;
	}
}

_intro_claw_turret_fire( ai_claw )
{
	debug_print_line( "fire" );
	level notify( "claw_firing" );
}

_claw_door_target_move( n_time )
{
	level endon( "intro_claw_target_stop" );
	self movey( 90, n_time );
	self waittill( "movedone" );
	self movey( -90, n_time );
	self movex( -90, 2 );
}

_intro_claw_grenades_fire( ai_claw )
{
	debug_print_line( "stop firing" );
	ai_claw.turret setturretspinning( 0 );
	ai_claw.turret maps/_turret::enable_turret();
}

bus_smash_car_hit( e_bus )
{
	e_car = getent( "car_smash_car", "targetname" );
	e_car stopsounds();
	end_scene( "car_smash_car_idle" );
	end_scene( "car_smash_ai_idle" );
	level thread run_scene( "bus_smash_damage_ai" );
	level thread run_scene( "bus_smash_damage" );
}

crosby_enter_elevator_room()
{
	ai_crosby = getent( "crosby_ai", "targetname" );
	nd_door_goal = getnode( "crosby_frogger_start", "targetname" );
	if ( distance2d( ai_crosby.origin, nd_door_goal.origin ) > 8 )
	{
		ai_crosby forceteleport( nd_door_goal.origin, nd_door_goal.angles );
	}
	wait 1,7;
	ai_crosby thread send_ai_to_struct( "frogger_crosby_garage_goal" );
	level notify( "claw_walk_rumble_disable" );
	m_door = get_model_or_models_from_scene( "brute_force_unlock", "brute_force_door" );
	m_door thread claws_walk_intro_elevator_room_rumble();
	level waittill( "brute_force_unlock_done" );
	if ( isDefined( ai_crosby ) )
	{
		ai_crosby delete();
	}
}

force_harper_to_frogger_start()
{
	nd_car_goal = getnode( "harper_frogger_start", "targetname" );
	if ( distance2d( level.harper.origin, nd_car_goal.origin ) > 16 )
	{
		level.harper forceteleport( nd_car_goal.origin, nd_car_goal.angles );
	}
}

send_ai_to_struct( str_struct, b_stay )
{
	if ( !isDefined( b_stay ) )
	{
		b_stay = 1;
	}
	s_goal = getstruct( str_struct, "targetname" );
	self set_ignoreme( 1 );
	self set_ignoreall( 1 );
	self set_goalradius( 8 );
	self setgoalpos( s_goal.origin );
	self waittill( "goal" );
	if ( b_stay == 1 )
	{
		o_link_spot = spawn( "script_origin", s_goal.origin );
		self linkto( o_link_spot );
		self waittill( "delete" );
		o_link_spot delete();
	}
}

intro_spawn_dynents( n_delay, str_struct, v_force )
{
	wait n_delay;
	a_s_spawn_points = getstructarray( str_struct, "targetname" );
	_a2636 = a_s_spawn_points;
	_k2636 = getFirstArrayKey( _a2636 );
	while ( isDefined( _k2636 ) )
	{
		s_point = _a2636[ _k2636 ];
		str_model = random( level.floating_dyn_ents_market );
		s_point maps/pakistan_street::launch_dynent( str_model, v_force );
		_k2636 = getNextArrayKey( _a2636, _k2636 );
	}
}

precache_dyn_ent_market_debris()
{
	level.floating_dyn_ents_market = [];
	level.floating_dyn_ents_market[ level.floating_dyn_ents_market.size ] = "phys_p6_pak_food_rice";
	level.floating_dyn_ents_market[ level.floating_dyn_ents_market.size ] = "p6_pak_food_box06";
	level.floating_dyn_ents_market[ level.floating_dyn_ents_market.size ] = "p6_pak_food_soda_single_01";
	level.floating_dyn_ents_market[ level.floating_dyn_ents_market.size ] = "p6_pak_food_soda_twelvepack_02";
	_a2654 = level.floating_dyn_ents_market;
	_k2654 = getFirstArrayKey( _a2654 );
	while ( isDefined( _k2654 ) )
	{
		str_model = _a2654[ _k2654 ];
		precachemodel( str_model );
		_k2654 = getNextArrayKey( _a2654, _k2654 );
	}
}
