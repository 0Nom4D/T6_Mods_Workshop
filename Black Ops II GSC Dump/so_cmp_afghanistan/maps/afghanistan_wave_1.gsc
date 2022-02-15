#include maps/_fxanim;
#include maps/afghanistan_arena_manager;
#include maps/afghanistan_anim;
#include maps/createart/afghanistan_art;
#include maps/_horse_rider;
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

#using_animtree( "generic_human" );
#using_animtree( "vehicles" );

init_flags()
{
	flag_init( "shoot_hip" );
	flag_init( "kill_uaz" );
	flag_init( "bp1_stop_horse" );
	flag_init( "player_off_horse" );
	flag_init( "goto_town" );
	flag_init( "goto_cache" );
	flag_init( "player_has_rpg" );
	flag_init( "at_plaza" );
	flag_init( "spawn_btr1_bp1" );
	flag_init( "spawn_btr2_bp1" );
	flag_init( "zhao_to_weapons" );
	flag_init( "ready_to_leave_bp1" );
	flag_init( "zhao_ready_bp1exit" );
	flag_init( "player_onhorse_bp1exit" );
	flag_init( "bp1_exit_done" );
	flag_init( "wave1_started" );
	flag_init( "wave1_done" );
	flag_init( "wave1_complete" );
	flag_init( "leaving_bp1" );
	flag_init( "leaving_bp1_exit" );
	flag_init( "safe_to_explode" );
	flag_init( "safe_to_explode_player" );
	flag_init( "dome_exploded" );
	flag_init( "btr_chase_dead" );
	flag_init( "defend_against_btr" );
	flag_init( "started_crater_charge" );
	flag_init( "btr_dialog_done" );
	flag_init( "dialog_crater_charge_done" );
	flag_init( "vo_end_of_bp1_done" );
	flag_init( "bp3_infantry_event" );
}

init_spawn_funcs()
{
	add_spawn_function_group( "bp1_roof_jumper", "targetname", ::roof_jumper_logic );
	add_spawn_function_group( "bp1_initial_guard", "targetname", ::victim_bp1_logic );
	add_spawn_function_group( "bp1_initial_sniper", "targetname", ::fixed_bp1_logic );
	add_spawn_function_group( "bp1_initial_troops", "targetname", ::initial_bp1_logic );
	add_spawn_function_group( "bp1_reinforce", "targetname", ::reinforce_bp1_logic );
	add_spawn_function_group( "bp1_assault_troops", "targetname", ::assault_bp1_logic );
	add_spawn_function_group( "bp1_cache_guard1", "targetname", ::fixed_bp1_logic );
	add_spawn_function_group( "bp1_cache_guard2", "targetname", ::fixed_bp1_logic );
	add_spawn_function_group( "bp1_tower_rooftop", "targetname", ::fixed_bp1_logic );
	add_spawn_function_group( "bp1_hip1_rappel", "targetname", ::bp1_rappel_logic );
	add_spawn_function_group( "bp1_last_troops", "targetname", ::reinforce_bp1_logic );
	add_spawn_function_group( "soviet_cache5", "targetname", ::arena_crosser_logic );
	add_spawn_function_group( "bp1_bottom_force", "targetname", ::reinforce_bp1_green_logic );
	add_spawn_function_group( "muj_initial_bp1", "targetname", ::defend_bp1_logic );
	add_spawn_function_group( "muj_defend_bp1", "targetname", ::defend_bp1_logic );
	add_spawn_function_group( "muj_bp1_advance", "targetname", ::defend_bp1_logic );
	add_spawn_function_group( "bp1_muj_exit", "targetname", ::bp1_muj_exit_logic );
}

init_level_setup()
{
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.zhao magic_bullet_shield();
	level.n_bp1wave1_soviet_killed = 0;
	level.b_plant_stairs = 0;
	m_cratercharge_glow = getent( "crater_charge_explosive_glow", "targetname" );
	m_cratercharge_glow hide();
	level clientnotify( "dbw1" );
}

skipto_wave1()
{
	skipto_setup();
	init_hero( "zhao" );
	init_hero( "woods" );
	skipto_teleport( "skipto_wave1", level.heroes );
	t_chase = getent( "trigger_uaz_chase", "targetname" );
	t_chase trigger_on();
	level thread maps/_horse::set_horse_in_combat( 1 );
	level.zhao = getent( "zhao_ai", "targetname" );
	level.woods = getent( "woods_ai", "targetname" );
	remove_woods_facemask_util();
	s_player_horse_spawnpt = getstruct( "wave1_player_horse_spawnpt", "targetname" );
	s_zhao_horse_spawnpt = getstruct( "wave1_zhao_horse_spawnpt", "targetname" );
	s_woods_horse_spawnpt = getstruct( "wave1_woods_horse_spawnpt", "targetname" );
	level.zhao_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.zhao_horse.origin = s_zhao_horse_spawnpt.origin;
	level.zhao_horse.angles = s_zhao_horse_spawnpt.angles;
	level.woods_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods_horse.origin = s_woods_horse_spawnpt.origin;
	level.woods_horse.angles = s_woods_horse_spawnpt.angles;
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_player_horse_spawnpt.origin;
	level.mason_horse.angles = s_player_horse_spawnpt.angles;
	level.woods_horse makevehicleunusable();
	level.zhao_horse makevehicleunusable();
	level.mason_horse makevehicleusable();
	level.woods_horse veh_magic_bullet_shield( 1 );
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.mason_horse veh_magic_bullet_shield( 1 );
	wait 0,1;
	level.woods enter_vehicle( level.woods_horse );
	level.zhao enter_vehicle( level.zhao_horse );
	level clientnotify( "abs_1" );
	wait 0,05;
	level.woods_horse notify( "groupedanimevent" );
	level.zhao_horse notify( "groupedanimevent" );
	level.woods maps/_horse_rider::ride_and_shoot( level.woods_horse );
	level.zhao maps/_horse_rider::ride_and_shoot( level.zhao_horse );
	level clientnotify( "dbw1" );
	level.woods_horse thread woods_skipto_wave1();
	level.zhao_horse thread zhao_skipto_wave1();
	set_objective( level.obj_afghan_bp1, level.zhao, "follow" );
	flag_wait( "afghanistan_gump_arena" );
	exploder( 300 );
}

uaz3_arena_skipto_logic()
{
	self endon( "death" );
	self thread delete_corpse_arena();
	s_goal = getstruct( "uaz3_goal", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self notify( "unload" );
}

zhao_skipto_wave1()
{
	level.mason_horse waittill( "enter_vehicle", player );
	s_zhao_bp1 = getstruct( "zhao_bp1_goal", "targetname" );
	self setneargoalnotifydist( 300 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_zhao_bp1.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self setspeedimmediate( 0 );
	flag_set( "zhao_at_bp1" );
	s_zhao_bp1 = undefined;
}

woods_skipto_wave1()
{
	level.mason_horse waittill( "enter_vehicle", player );
	wait 1;
	s_woods_bp1 = getstruct( "woods_bp1_goal", "targetname" );
	self setneargoalnotifydist( 300 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_woods_bp1.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self setspeedimmediate( 0 );
	flag_set( "woods_at_bp1" );
	s_woods_bp1 = undefined;
}

main()
{
/#
	iprintln( "Wave 1" );
#/
	maps/createart/afghanistan_art::open_area();
	level notify( level.ammo_cache_waittill_notify );
	init_spawn_funcs();
	init_level_setup();
	bp1_vehicle_chooser();
	wave1();
	flag_wait( "vo_end_of_bp1_done" );
}

wave1()
{
	level.woods_horse ent_flag_init( "btr_chase_over" );
	level thread objectives_zhao_bp1();
	level thread objectives_bp1();
	if ( level.skipto_point == "wave_1" )
	{
		maps/afghanistan_anim::init_afghan_anims_part1b();
		delete_section1_scenes();
		delete_section3_scenes();
	}
	level.n_current_wave = 1;
	level.n_bp1_veh_destroyed = 0;
	level.zhao_horse thread zhao_wave1_bp1();
	level.woods_horse thread woods_wave1_bp1();
	level.mason_horse thread player_horse_behavior();
	level thread spawn_chase_truck();
	level thread spawn_bp1_horses();
	trigger_wait( "spawn_bp1" );
	spawn_manager_kill( "manager_troops_exit" );
	spawn_manager_kill( "manager_hip3_troops" );
	t_chase = getent( "trigger_uaz_chase", "targetname" );
	t_chase delete();
	t_cache_guard = getent( "trigger_firehorse_cache_guard", "targetname" );
	t_cache_guard delete();
	flag_set( "wave1_started" );
	level thread vo_enter_bp1();
	level thread vo_engagement_bp1();
	level thread vo_vehicles_bp1();
	level thread vo_done_bp1();
	level thread vo_explosive_bp1();
	level thread check_player_has_rpg();
	level thread spawn_muj_defenders();
	level thread spawn_mig_intro();
	level thread bp1_entrance_explosions();
	level thread mig_bomb_entrance();
	level thread bp1_replenish_arena();
	level thread spawn_mig_tower();
	autosave_by_name( "blocking_point1" );
	maps/afghanistan_arena_manager::cleanup_arena();
	sp_guard = getent( "bp1_initial_guard", "targetname" );
	ai_guard = sp_guard spawn_ai( 1 );
	wait 0,1;
	level thread monitor_enemy_bp1();
	level thread bp1_crew_spawn();
	flag_wait( "wave1_complete" );
	level thread struct_cleanup_firehorse();
}

check_player_has_rpg()
{
	level endon( "player_has_rpg" );
	while ( 1 )
	{
		a_weapons = level.player getweaponslist();
		i = 0;
		while ( i < a_weapons.size )
		{
			if ( issubstr( a_weapons[ i ], "stinger" ) )
			{
				flag_set( "player_has_rpg" );
			}
			i++;
		}
		wait 1;
	}
}

objectives_zhao_bp1()
{
	flag_wait( "spawn_vehicles_bp1" );
	set_objective( level.obj_afghan_bp1, level.zhao, "remove" );
	wait_network_frame();
	flag_wait( "btr_dialog_done" );
	if ( !flag( "player_has_rpg" ) )
	{
		s_rpg = getstruct( "struct_stringer_use", "targetname" );
		set_objective( level.obj_afghan_bp1, s_rpg, &"AFGHANISTAN_OBJ_WEAPONS" );
		while ( !flag( "player_has_rpg" ) && !flag( "wave1_done" ) )
		{
			wait 0,1;
		}
		set_objective( level.obj_afghan_bp1, s_rpg, "remove" );
		level thread vo_bp1_player_at_ammo_cache();
	}
	flag_wait( "wave1_done" );
	set_objective( level.obj_afghan_bp1, undefined, "remove" );
}

objectives_bp1()
{
	flag_wait( "btr_dialog_done" );
	set_objective( level.obj_afghan_bp1_vehicles, undefined, undefined, level.n_bp1_veh_destroyed );
	flag_wait( "dialog_crater_charge_done" );
	e_cratercharge_obj = getstruct( "crater_charge_obj", "targetname" );
	m_cratercharge_glow = getent( "crater_charge_explosive_glow", "targetname" );
	m_cratercharge_glow show();
	set_objective( level.obj_afghan_bp1, undefined, "done" );
	wait_network_frame();
	set_objective( level.obj_afghan_bp1, undefined, "delete" );
	wait_network_frame();
	set_objective( level.obj_destroy_dome, e_cratercharge_obj, "breadcrumb" );
	level thread plant_explosive_dome();
	level thread monitor_crater_charge();
	flag_wait( "started_crater_charge" );
	if ( level.b_plant_stairs )
	{
		scene_wait( "plant_explosive_dome_stairs" );
	}
	else
	{
		scene_wait( "plant_explosive_dome" );
	}
	set_objective( level.obj_destroy_dome, e_cratercharge_obj, "remove" );
	s_detonate_point = getstruct( "detonate_safe_point", "targetname" );
	set_objective( level.obj_destroy_dome, s_detonate_point, "breadcrumb" );
	e_cratercharge_obj structdelete();
	level thread vo_nag_safe_distance();
	flag_wait( "dome_exploded" );
	level thread arena_drones();
	level clientnotify( "bp1" );
	set_objective( level.obj_destroy_dome, undefined, "done" );
	set_objective( level.obj_destroy_dome, undefined, "delete" );
	flag_wait( "ready_to_leave_bp1" );
	set_objective( level.obj_follow_bp1, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
	flag_wait( "player_onhorse_bp1exit" );
	set_objective( level.obj_follow_bp1, level.mason_horse, "remove" );
}

spawn_chase_truck()
{
	trigger_wait( "trigger_uaz_chase" );
	s_spawnpt = getstruct( "chase_truck_spawnpt", "targetname" );
	nd_start = getvehiclenode( "node_start_chase_truck", "targetname" );
	vh_truck = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck.origin = s_spawnpt.origin;
	vh_truck.angles = s_spawnpt.angles;
	vh_truck thread chase_truck_logic();
	sp_rider = getent( "muj_assault", "targetname" );
	ai_rider1 = sp_rider spawn_ai( 1 );
	ai_rider1.script_startingposition = 0;
	ai_rider1 enter_vehicle( vh_truck );
	ai_rider2 = sp_rider spawn_ai( 1 );
	ai_rider2.script_startingposition = 2;
	ai_rider2 enter_vehicle( vh_truck );
	wait 0,1;
	vh_truck thread go_path( nd_start );
}

chase_truck_logic()
{
	self endon( "death" );
	self thread delete_corpse_bp1();
	self thread destroy_chase_truck_end();
	self thread spawn_chopper_victim();
	level thread uaz_arena_chase_horse();
	flag_wait( "kill_uaz" );
	self thread destroy_chase_truck();
}

spawn_chopper_victim()
{
	self endon( "death" );
	s_spawnpt = getstruct( "chopper_victim_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	wait 0,1;
	vh_hip.origin = s_spawnpt.origin;
	vh_hip.angles = s_spawnpt.angles;
	vh_hip thread chopper_victim_logic();
	flag_wait( "shoot_hip" );
	if ( isalive( vh_hip ) )
	{
		self set_turret_target( vh_hip, ( 0, -100, -32 ), 1 );
		self shoot_turret_at_target( vh_hip, 7, ( 0, 0, -1 ), 1 );
	}
}

chopper_victim_logic()
{
	self endon( "death" );
	self thread speed_up_crash();
	self thread heli_select_death();
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	s_goal0 = getstruct( "chopper_victim_goal0", "targetname" );
	s_goal1 = getstruct( "chopper_victim_goal1", "targetname" );
	s_goal2 = getstruct( "chopper_victim_goal2", "targetname" );
	s_goal3 = getstruct( "chopper_victim_goal3", "targetname" );
	s_goal4 = getstruct( "chopper_victim_goal4", "targetname" );
	s_goal5 = getstruct( "chopper_victim_goal5", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 40 );
	self setvehgoalpos( s_goal0.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	flag_set( "shoot_hip" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal5.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

speed_up_crash()
{
	self waittill( "death" );
	self setspeedimmediate( 150 );
}

destroy_chase_truck()
{
	self vehicle_detachfrompath();
	self launchvehicle( vectorScale( ( 0, 0, -1 ), 300 ), anglesToForward( self.angles ) * 180, 1, 1 );
	play_fx( "truck_dmg", self.origin, self.angles, "stop_truck_fx", 1, "tag_origin" );
	self playsound( "evt_truck_flip" );
	ai_gunner = getent( "uaz_chase_shooter_ai", "targetname" );
	if ( isalive( ai_gunner ) )
	{
		ai_gunner die();
	}
	wait 1;
	radiusdamage( self.origin, 100, 5000, 4000 );
	self stopsound( "evt_truck_flip" );
	self setbrake( 1 );
	self notify( "stop_truck_fx" );
}

destroy_chase_truck_end()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
	self.exp_pos = anglesToForward( self.angles ) * 100;
	playfx( level._effect[ "explode_mortar_sand" ], self.exp_pos );
	playsoundatposition( "exp_mortar", self.exp_pos );
	earthquake( 0,5, 1, self.exp_pos, 2000 );
	level.player playrumbleonentity( "artillery_rumble" );
	level thread check_explosion_radius( self.exp_pos );
	self thread destroy_chase_truck();
}

uaz_arena_chase_horse()
{
	s_spawnpt = getstruct( "uaz_chase_horse_spawnpt", "targetname" );
	vh_horses = [];
	i = 0;
	while ( i < 2 )
	{
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		wait 0,1;
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		s_goal = getstruct( "uaz_chase_horse_goal" + i, "targetname" );
		sp_rider = getent( "muj_assault", "targetname" );
		vh_horses[ i ].rider = sp_rider spawn_ai( 1 );
		vh_horses[ i ] thread uaz_arena_chase_horse_behavior( vh_horses[ i ].rider, s_goal );
		if ( i == 0 )
		{
			vh_horses[ i ] pathfixedoffset( vectorScale( ( 0, 0, -1 ), 100 ) );
		}
		else
		{
			vh_horses[ i ] pathfixedoffset( vectorScale( ( 0, 0, -1 ), 100 ) );
		}
		wait 0,3;
		i++;
	}
	flag_wait( "wave2_started" );
	i = 0;
	while ( i < 2 )
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
	vh_horses = undefined;
}

uaz_arena_chase_horse_behavior( ai_rider, s_goal )
{
	self endon( "death" );
	self setneargoalnotifydist( 300 );
	self makevehicleunusable();
	self setspeedimmediate( 25 );
	if ( isalive( ai_rider ) )
	{
		ai_rider enter_vehicle( self );
		ai_rider.vh_horse = self;
		ai_rider.horse_defender = 1;
	}
	wait 0,1;
	self notify( "groupedanimevent" );
	if ( isalive( ai_rider ) )
	{
		ai_rider maps/_horse_rider::ride_and_shoot( self );
	}
	self setvehgoalpos( s_goal.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	wait 1;
	if ( isalive( ai_rider ) )
	{
		ai_rider notify( "stop_riding" );
	}
	self vehicle_unload( 0,1 );
	self setvehicleavoidance( 1 );
	if ( isalive( ai_rider ) )
	{
		ai_rider thread defend_bp1_logic();
	}
	self makevehicleunusable();
	wait 3;
	self thread bp1_horse_runaway();
}

spawn_bp1_horses()
{
	level endon( "wave1_started" );
	trigger_wait( "trigger_bp1_horses" );
	level thread vo_horse_riders_bp1();
	s_spawnpt = getstruct( "bp1_horse_spawnpt", "targetname" );
	vh_horses = [];
	n_offset = 0;
	i = 0;
	while ( i < 4 )
	{
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		wait 0,1;
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		vh_horses[ i ] pathfixedoffset( ( 0, i + n_offset, 0 ) );
		sp_rider = getent( "muj_assault", "targetname" );
		ai_rider = sp_rider spawn_ai( 1 );
		ai_rider thread defend_bp1_logic();
		vh_horses[ i ] thread bp1_horse_behavior( ai_rider );
		wait 0,4;
		if ( cointoss() )
		{
			n_offset += 100;
			i++;
			continue;
		}
		else
		{
			n_offset -= 100;
		}
		i++;
	}
	vh_horses = undefined;
}

vo_horse_riders_bp1()
{
	wait 3;
	level.zhao say_dialog( "muj0_hiyeeah_0", 0 );
	level.zhao say_dialog( "muj0_battle_cry_0", 2 );
	flag_wait( "bp1_bombs1" );
}

bp1_horse_behavior( ai_rider )
{
	self endon( "death" );
	ai_rider enter_vehicle( self );
	ai_rider.vh_horse = self;
	wait 0,1;
	self notify( "groupedanimevent" );
	ai_rider maps/_horse_rider::ride_and_shoot( self );
	s_start = getstruct( "bp1_horse_goal1", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 22, 15, 10 );
	self setvehgoalpos( s_start.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	s_next = getstruct( s_start.target, "targetname" );
	while ( 1 )
	{
		if ( !isDefined( s_next.target ) )
		{
			v_goal = s_next.origin + ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), 0 );
		}
		else
		{
			v_goal = s_next.origin;
		}
		self setvehgoalpos( v_goal, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		if ( isDefined( s_next.target ) )
		{
			s_next = getstruct( s_next.target, "targetname" );
			continue;
		}
		else
		{
		}
	}
	self setbrake( 1 );
	if ( isalive( ai_rider ) )
	{
		ai_rider notify( "stop_riding" );
		self vehicle_unload( 0,1 );
		self waittill( "unloaded" );
	}
	self makevehicleunusable();
	self setvehicleavoidance( 1 );
	wait 2;
	self thread bp1_horse_runaway();
}

plant_explosive_dome()
{
	while ( !flag( "dome_exploded" ) )
	{
		trigger_wait( "trigger_dome_explosive" );
		t_explosive = getent( "trigger_dome_explosive", "targetname" );
		m_cratercharge = getent( "crater_charge_explosive", "targetname" );
		m_cratercharge_glow = getent( "crater_charge_explosive_glow", "targetname" );
		while ( level.player istouching( t_explosive ) )
		{
			screen_message_create( &"AFGHANISTAN_BP1_PLACE_CRATER_CHARGE" );
			if ( level.player usebuttonpressed() )
			{
				screen_message_delete();
				angles = level.player getplayerangles();
				if ( angles[ 1 ] > -90 && angles[ 1 ] < 90 )
				{
					level thread run_scene( "plant_explosive_dome" );
				}
				else
				{
					level thread run_scene( "plant_explosive_dome_stairs" );
					level.b_plant_stairs = 1;
				}
				wait 0,2;
				flag_set( "started_crater_charge" );
				level.woods thread check_friends_positions( getstruct( "teleport_woods_pos", "targetname" ) );
				level.zhao thread check_friends_positions( getstruct( "teleport_zhao_pos", "targetname" ) );
				m_cratercharge_glow delete();
				m_cratercharge show();
				if ( level.b_plant_stairs )
				{
					scene_wait( "plant_explosive_dome_stairs" );
				}
				else
				{
					scene_wait( "plant_explosive_dome" );
				}
				trigger_use( "triggercolor_leavetown" );
				m_cratercharge thread playfx_blinking_light();
				level.player thread explosion_safe_distance( m_cratercharge );
				level.player disableweaponfire();
				currentweapon = level.player getcurrentweapon();
				satchel = search_player_for_satchel();
				if ( isDefined( satchel ) && satchel == "satchel_charge_sp" )
				{
					level.player switchtoweapon( "satchel_charge_sp" );
				}
				else
				{
					if ( isDefined( satchel ) && satchel == "satchel_charge_80s_sp" )
					{
						level.player switchtoweapon( "satchel_charge_80s_sp" );
						break;
					}
					else
					{
						level.player giveweapon( "satchel_charge_80s_sp" );
						level.player switchtoweapon( "satchel_charge_80s_sp" );
						level.player setweaponammoclip( "satchel_charge_80s_sp", 0 );
						level.player setweaponammostock( "satchel_charge_80s_sp", 0 );
					}
				}
				level.player disableweaponcycling();
				level.player disableusability();
				level.player disableoffhandweapons();
				level.player thread disable_mines_at_dome();
				level thread bp1_hips_flyby();
				flag_wait( "safe_to_explode" );
				while ( 1 )
				{
					if ( level.player getcurrentweapon() != "satchel_charge_sp" && level.player getcurrentweapon() == "satchel_charge_80s_sp" && level.player attackbuttonpressed() )
					{
						flag_set( "dome_exploded" );
						level.player playsound( "wpn_c4_activate_plr" );
						screen_message_delete();
						wait 0,1;
						m_cratercharge delete();
						s_explode = getstruct( "explosion_struct", "targetname" );
						exploder( 600 );
						playsoundatposition( "wpn_c4_explode", s_explode.origin );
						earthquake( 0,5, 2,5, level.player.origin, 4000 );
						radiusdamage( s_explode.origin, 1000, 5000, 5000, undefined, "MOD_PROJECTILE" );
						level.player playrumbleonentity( "artillery_rumble" );
						level notify( "fxanim_archway_collapse_start" );
						level thread check_player_position();
						level thread show_dome_destruction();
						level thread delete_dome();
						setmusicstate( "RIDE_TO_FIGHT_TWO" );
						wait 2;
						if ( !isDefined( satchel ) )
						{
							if ( level.player hasweapon( "satchel_charge_sp" ) )
							{
								level.player takeweapon( "satchel_charge_sp" );
							}
							if ( level.player hasweapon( "satchel_charge_80s_sp" ) )
							{
								level.player takeweapon( "satchel_charge_80s_sp" );
							}
						}
						level.player enableweaponcycling();
						level.player enableusability();
						level.player enableoffhandweapons();
						level.player switchtoweapon( currentweapon );
						flag_set( "wave1_complete" );
						autosave_by_name( "dome_destroyed" );
						cleanup_bp_ai();
						break;
					}
					else
					{
						wait 0,05;
					}
				}
			}
			else wait 0,05;
		}
		screen_message_delete();
	}
}

search_player_for_satchel()
{
	a_weaponlist = level.player getweaponslist();
	i = 0;
	while ( i < a_weaponlist.size )
	{
		if ( a_weaponlist[ i ] == "satchel_charge_sp" )
		{
			return a_weaponlist[ i ];
		}
		else
		{
			if ( a_weaponlist[ i ] == "satchel_charge_80s_sp" )
			{
				return a_weaponlist[ i ];
			}
		}
		i++;
	}
	return undefined;
}

monitor_crater_charge()
{
	level endon( "dome_exploded" );
	trigger_wait( "trigger_check_cratercharge" );
	if ( !flag( "dome_exploded" ) )
	{
		missionfailedwrapper( &"AFGHANISTAN_OBJECTIVE_FAIL" );
	}
}

check_friends_positions( s_pos )
{
	if ( distance2dsquared( level.player.origin, self.origin ) > 160000 )
	{
		self clear_force_color();
		wait 1;
		self teleport( s_pos.origin, s_pos.angles );
		wait 1;
		self set_force_color( "r" );
	}
}

crater_charge_fx1( guy )
{
	playfxontag( level._effect[ "crater_charge_bury" ], getent( "crater_charge_explosive", "targetname" ), "tag_origin" );
}

crater_charge_fx2( guy )
{
	playfxontag( level._effect[ "crater_charge_bury" ], getent( "crater_charge_explosive", "targetname" ), "tag_origin" );
}

crater_charge_fx3( guy )
{
	playfxontag( level._effect[ "crater_charge_bury" ], getent( "crater_charge_explosive", "targetname" ), "tag_origin" );
}

crater_charge_fx4( guy )
{
	playfxontag( level._effect[ "crater_charge_bury" ], getent( "crater_charge_explosive", "targetname" ), "tag_origin" );
}

crater_charge_fx5( guy )
{
	playfxontag( level._effect[ "crater_charge_bury" ], getent( "crater_charge_explosive", "targetname" ), "tag_origin" );
}

playfx_blinking_light()
{
	e_tag = spawn( "script_model", self.origin );
	e_tag setmodel( "tag_origin" );
	while ( !flag( "dome_exploded" ) )
	{
		playfxontag( level._effect[ "cratercharge_light" ], e_tag, "tag_origin" );
		wait 0,25;
	}
	e_tag delete();
}

disable_mines_at_dome()
{
	if ( self hasweapon( "tc6_mine_sp" ) )
	{
		self setactionslot( 1, "" );
		flag_wait( "wave1_complete" );
		self setactionslot( 1, "weapon", "tc6_mine_sp" );
	}
}

check_player_position()
{
	if ( level.player.origin[ 0 ] > 4100 )
	{
		level.woods thread say_dialog( "wood_come_on_0" );
		missionfailedwrapper( &"SCRIPT_COMPROMISE_FAIL" );
	}
	else
	{
		if ( level.woods.origin[ 0 ] > 4100 || level.zhao.origin[ 0 ] > 4100 )
		{
			missionfailedwrapper( &"AFGHANISTAN_C4_FAIL" );
		}
	}
}

show_dome_destruction()
{
	a_m_destroyed_dome = getentarray( "archway_destroyed_static", "targetname" );
	m_destroyed_dome_clip = getent( "archway_destroyed_static_clip", "targetname" );
	_a1148 = a_m_destroyed_dome;
	_k1148 = getFirstArrayKey( _a1148 );
	while ( isDefined( _k1148 ) )
	{
		m_dest = _a1148[ _k1148 ];
		m_dest show();
		m_dest setforcenocull();
		_k1148 = getNextArrayKey( _a1148, _k1148 );
	}
	m_destroyed_dome_clip movez( 2080, 0,1 );
	m_destroyed_dome_clip waittill( "movedone" );
	m_destroyed_dome_clip disconnectpaths();
}

set_dome_no_cull()
{
	a_m_dome = getentarray( "dome_pristine", "targetname" );
	_a1163 = a_m_dome;
	_k1163 = getFirstArrayKey( _a1163 );
	while ( isDefined( _k1163 ) )
	{
		m_dome = _a1163[ _k1163 ];
		m_dome setforcenocull();
		_k1163 = getNextArrayKey( _a1163, _k1163 );
	}
	m_water_tower = getent( "water_tower_model", "targetname" );
	m_water_tower setforcenocull();
	m_rope = getent( "rappel_rope", "targetname" );
	m_rope setforcenocull();
}

delete_dome()
{
	a_m_dome = getentarray( "dome_pristine", "targetname" );
	_a1179 = a_m_dome;
	_k1179 = getFirstArrayKey( _a1179 );
	while ( isDefined( _k1179 ) )
	{
		m_dome = _a1179[ _k1179 ];
		m_dome delete();
		_k1179 = getNextArrayKey( _a1179, _k1179 );
	}
	wait 10;
	maps/_fxanim::fxanim_delete( "fxanim_dome" );
}

explosion_safe_distance( m_cratercharge )
{
	self endon( "death" );
	self thread explosion_safe_distance_player( m_cratercharge );
	while ( distance2dsquared( self.origin, m_cratercharge.origin ) < 1000000 && level.woods.origin[ 0 ] > 4100 || level.zhao.origin[ 0 ] > 4100 && self.origin[ 0 ] > 4100 )
	{
		wait 0,05;
	}
	level.woods thread say_dialog( "wood_blow_it_mason_0", 0 );
	level thread nag_blow_it();
	level.player enableweaponfire();
	screen_message_create( &"AFGHANISTAN_BP1_FIRE_CRATER_CHARGE" );
	flag_set( "safe_to_explode" );
}

explosion_safe_distance_player( m_cratercharge )
{
	self endon( "death" );
	while ( distance2dsquared( self.origin, m_cratercharge.origin ) < 1000000 || self.origin[ 0 ] > 4100 )
	{
		wait 0,05;
	}
	flag_set( "safe_to_explode_player" );
}

nag_blow_it()
{
	level endon( "dome_exploded" );
	wait 8;
	n_nag = 0;
	while ( 1 )
	{
		level.woods say_dialog( "wood_blow_it_mason_0", 0 );
		wait 8;
		n_nag++;
		wait 8;
		level.woods say_dialog( "wood_blow_it_make_sure_0", 0 );
		n_nag++;
		wait 8;
		if ( n_nag > 5 )
		{
		}
	}
}

spawn_muj_defenders()
{
	sp_defender = getent( "muj_initial_bp1", "targetname" );
	i = 0;
	while ( i < 3 )
	{
		sp_defender spawn_ai( 1 );
		wait 0,1;
		i++;
	}
	waittill_ai_group_count( "group_bp1_initial", 3 );
	spawn_manager_enable( "manager_muj_bp1" );
}

spawn_mig_intro()
{
	s_spawnpt = getstruct( "bp1_mig_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	wait 0,1;
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	vh_mig thread bp1_mig_intro();
	s_spawnpt = undefined;
}

bp1_mig_intro()
{
	self endon( "death" );
	self setforcenocull();
	s_goal1 = getstruct( "bp1_mig_goal1", "targetname" );
	s_goal2 = getstruct( "bp1_mig_goal2", "targetname" );
	target_set( self );
	self setneargoalnotifydist( 1000 );
	self setspeed( 800, 700, 600 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal1 = undefined;
	s_goal2 = undefined;
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp1_entrance_explosions()
{
	a_s_explosions = [];
	a_s_explosions[ 0 ] = getstruct( "bp1_mig_spawnpt", "targetname" );
	i = 1;
	while ( i < 7 )
	{
		a_s_explosions[ i ] = getstruct( "bp1_mig_exp" + i, "targetname" );
		i++;
	}
	i = 1;
	while ( i < 7 )
	{
		if ( i == 3 )
		{
			flag_set( "kill_uaz" );
		}
		playfx( level._effect[ "explode_mortar_sand" ], a_s_explosions[ i ].origin );
		playsoundatposition( "exp_mortar", a_s_explosions[ i ].origin );
		earthquake( 0,5, 1, a_s_explosions[ i ].origin, 2000 );
		level.player playrumbleonentity( "artillery_rumble" );
		level thread check_explosion_radius( a_s_explosions[ i ].origin );
		wait 1;
		i++;
	}
	a_s_explosions = undefined;
}

mig_bomb_entrance()
{
	flag_wait( "enter_bp1" );
	s_spawnpt = getstruct( "bp1_mig2_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	wait 0,1;
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	s_spawnpt = undefined;
	vh_mig thread bp1_mig2_bombrun();
}

bp1_mig2_bombrun()
{
	self endon( "death" );
	s_goal1 = getstruct( "bp1_mig2_goal1", "targetname" );
	s_goal2 = getstruct( "bp1_mig2_goal2", "targetname" );
	target_set( self );
	self setforcenocull();
	self setneargoalnotifydist( 1000 );
	self setspeed( 800, 700, 600 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread bp1_mig2_bombs();
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal1 = undefined;
	s_goal2 = undefined;
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp1_mig2_bombs()
{
	s_bomb1 = getstruct( "bp1_mig2_exp1", "targetname" );
	s_bomb2 = getstruct( "bp1_mig2_exp2", "targetname" );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb1.origin );
	playsoundatposition( "exp_mortar", s_bomb1.origin );
	earthquake( 0,5, 1, s_bomb1.origin, 2000 );
	level.player playrumbleonentity( "artillery_rumble" );
	radiusdamage( s_bomb1.origin, 300, 120, 100, undefined, "MOD_PROJECTILE" );
	wait 1;
	flag_set( "bp1_stop_horse" );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb2.origin );
	playsoundatposition( "exp_mortar", s_bomb2.origin );
	earthquake( 0,5, 1, s_bomb2.origin, 2000 );
	level.player playrumbleonentity( "artillery_rumble" );
	radiusdamage( s_bomb2.origin, 300, 120, 100, undefined, "MOD_PROJECTILE" );
	s_bomb1 = undefined;
	s_bomb2 = undefined;
}

spawn_mig_tower()
{
	flag_wait( "tower_fall" );
	s_spawnpt = getstruct( "mig_tower_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	s_spawnpt = undefined;
	vh_mig thread mig_destroy_tower();
}

mig_destroy_tower()
{
	self endon( "death" );
	s_goal1 = getstruct( "mig_tower_goal1", "targetname" );
	s_goal2 = getstruct( "mig_tower_goal2", "targetname" );
	s_goal3 = getstruct( "mig_tower_goal3", "targetname" );
	s_goal4 = getstruct( "mig_tower_goal4", "targetname" );
	self veh_magic_bullet_shield( 1 );
	self setforcenocull();
	self setneargoalnotifydist( 1000 );
	self setspeed( 500, 250, 200 );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self thread tower_explosions();
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal1 = undefined;
	s_goal2 = undefined;
	s_goal3 = undefined;
	s_goal4 = undefined;
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

tower_explosions()
{
	s_bomb1 = getstruct( "mig_tower_bomb1", "targetname" );
	e_bomb2 = getent( "mig_tower_bomb2", "targetname" );
	e_missile1 = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_left" ), s_bomb1.origin );
	e_missile1 thread missile_mig_explosion();
	wait 0,1;
	e_missile2 = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_right" ), e_bomb2.origin, self, e_bomb2 );
	e_missile2 thread missile_mig_explosion( 1 );
	wait 1;
	s_bomb1 = undefined;
	e_bomb2 delete();
}

missile_mig_explosion( b_tower )
{
	self waittill( "death" );
	if ( isDefined( b_tower ) )
	{
		playfx( level._effect[ "missile_impact_hip" ], self.origin );
	}
	else
	{
		playfx( level._effect[ "explode_mortar_sand" ], self.origin );
	}
	earthquake( 0,3, 1, level.player.origin, 3000 );
	level.player playrumbleonentity( "grenade_rumble" );
	playsoundatposition( "exp_mortar", self.origin );
	radiusdamage( self.origin, 300, 2000, 2000, undefined, "MOD_PROJECTILE" );
	if ( isDefined( b_tower ) )
	{
		level notify( "fxanim_village_tower_start" );
	}
}

mig1_strafe_logic()
{
	self endon( "death" );
	self setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	self.overridevehicledamage = ::sticky_grenade_damage;
	target_set( self );
	self setforcenocull();
	self thread go_path( getvehiclenode( "start_node_mig_strafe", "targetname" ) );
	self thread mig_gun_strafe();
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

player_horse_behavior()
{
	flag_wait( "bp1_stop_horse" );
	level thread bp1_spawn_hitch_horse();
	if ( isDefined( level.player.viewlockedentity ) )
	{
		v_explosion = self.origin + ( anglesToForward( self.angles ) * 400 );
		playfx( level._effect[ "explode_mortar_sand" ], v_explosion );
		playsoundatposition( "exp_mortar", v_explosion );
		earthquake( 0,4, 2, level.player.origin, 100 );
		level.player playrumbleonentity( "grenade_rumble" );
		level.player playsound( "evt_mortar_dirt_close" );
		level thread check_explosion_radius( v_explosion );
		if ( isDefined( self.being_dismounted ) && !self.being_dismounted )
		{
			level.player disableusability();
			wait 0,3;
			self setbrake( 1 );
			self setspeedimmediate( 0 );
			if ( level.player is_on_horseback() )
			{
				level.player disableweapons();
				level.player enableinvulnerability();
			}
			self horse_rearback();
			level.player disableinvulnerability();
			level.player enableweapons();
			level clientnotify( "cease_aiming" );
			wait 0,1;
			self thread use_horse( level.player );
			self setbrake( 0 );
			self waittill_either( "cant_dismount_here", "no_driver" );
			while ( level.player is_on_horseback() )
			{
				self thread use_horse( level.player );
				self waittill_either( "cant_dismount_here", "no_driver" );
				wait 0,5;
			}
		}
		else level.player disableusability();
		self waittill( "no_driver" );
	}
	self thread bp1_horse_runaway();
	wait 4;
	self makevehicleunusable();
	level.player enableusability();
	autosave_by_name( "bp1_started" );
}

bp1_horse_runaway()
{
	self endon( "death" );
	goal = getstruct( "wave1_player_horse_spawnpt", "targetname" );
	self setbrake( 0 );
	self setspeed( 20, 10, 5 );
	self setvehgoalpos( goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

bp1_spawn_hitch_horse()
{
	s_hitchpt = getstruct( "bp1_hitch", "targetname" );
	flag_wait( "crew_showoff" );
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_hitchpt.origin;
	level.mason_horse.angles = s_hitchpt.angles;
	level.mason_horse setneargoalnotifydist( 300 );
	level.mason_horse setbrake( 0 );
	level.mason_horse veh_magic_bullet_shield( 1 );
	level.mason_horse makevehicleunusable();
	level.mason_horse thread horse_panic();
	flag_wait( "dome_exploded" );
	wait 0,1;
	level.mason_horse makevehicleusable();
	if ( isDefined( level.player.viewlockedentity ) )
	{
		flag_set( "player_onhorse_bp1exit" );
	}
	level.mason_horse waittill( "enter_vehicle", player );
	flag_set( "player_onhorse_bp1exit" );
}

bp1_replenish_arena()
{
	level endon( "wave1_done" );
	trigger_wait( "bp1_replenish_arena" );
	if ( !flag( "wave1_done" ) )
	{
		level thread replenish_bp1();
		if ( cointoss() )
		{
			level.woods thread say_dialog( "wood_where_the_fuck_are_y_0", 0 );
		}
		else
		{
			level.woods thread say_dialog( "wood_get_back_here_we_ca_0", 0 );
		}
	}
	spawn_manager_disable( "manager_soviet_bp1" );
	spawn_manager_kill( "manager_bp1_reinforce" );
	spawn_manager_disable( "manager_muj_bp1" );
	wait 0,1;
	cleanup_bp_ai();
	maps/afghanistan_arena_manager::respawn_arena();
}

replenish_bp1()
{
	trigger_wait( "spawn_bp1" );
	maps/afghanistan_arena_manager::cleanup_arena();
	wait 0,1;
	spawn_manager_enable( "manager_soviet_bp1" );
	spawn_manager_enable( "manager_muj_bp1" );
	level thread bp1_replenish_arena();
}

zhao_wave1_bp1()
{
	flag_wait( "zhao_at_bp1" );
	self makevehicleunusable();
	level.zhao notify( "stop_riding" );
	level.zhao set_force_color( "r" );
	self vehicle_unload( 0,1 );
	self waittill( "unloaded" );
	if ( !flag( "enter_bp1" ) )
	{
		level.zhao setgoalpos( level.zhao.origin );
	}
	wait 1;
	self thread horse_zhao_runaway();
	level thread nag_follow( "bp1_stop_horse" );
	flag_wait( "goto_cache" );
	level.zhao change_movemode( "cqb_sprint" );
	flag_wait( "wave1_done" );
	level.zhao reset_movemode();
	flag_wait( "dome_exploded" );
	flag_set( "ready_to_leave_bp1" );
	wait 2;
	self clearvehgoalpos();
	level.zhao clear_force_color();
	level.zhao ai_mount_horse( self );
	level thread bp1_exit_battle();
	level thread arena_hip_land();
	wait 1;
	flag_set( "zhao_ready_bp1exit" );
}

woods_wave1_bp1()
{
	flag_wait( "woods_at_bp1" );
	self makevehicleunusable();
	level.woods notify( "stop_riding" );
	level.woods set_force_color( "r" );
	self vehicle_unload( 0,1 );
	self waittill( "unloaded" );
	if ( !flag( "enter_bp1" ) )
	{
		level.woods setgoalpos( level.woods.origin );
	}
	wait 1;
	self thread horse_woods_runaway();
	flag_wait( "goto_cache" );
	level.woods change_movemode( "cqb_sprint" );
	flag_wait( "wave1_done" );
	level.woods reset_movemode();
	flag_wait( "dome_exploded" );
	wait 0,2;
	self horse_rearback();
	wait 2;
	self clearvehgoalpos();
	level.woods clear_force_color();
	level.woods ai_mount_horse( self );
	wait 1,5;
}

horse_zhao_runaway()
{
	s_run = getstruct( "zhao_bp1wave3_goal", "targetname" );
	s_ready = getstruct( "zhao_bp1_horse", "targetname" );
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_run.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	self clearvehgoalpos();
	flag_wait( "soviet_fallback" );
	self.origin = s_ready.origin;
	self.angles = s_ready.angles;
	wait 0,1;
	self setvehgoalpos( self.origin, 1, 1 );
	self setbrake( 1 );
	self thread horse_panic();
}

horse_woods_runaway()
{
	s_run = getstruct( "woods_bp1wave3_goal", "targetname" );
	s_ready = getstruct( "woods_bp1_horse", "targetname" );
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_run.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	self clearvehgoalpos();
	flag_wait( "soviet_fallback" );
	self.origin = s_ready.origin;
	self.angles = s_ready.angles;
	wait 0,1;
	self setvehgoalpos( self.origin, 1, 1 );
	self setbrake( 1 );
	self thread horse_panic();
}

bp1_hips_flyby()
{
	trigger_wait( "trigger_hip_flyby" );
	s_hip_spawnpt = getstruct( "hip_flyby_spawnpt", "targetname" );
	i = 0;
	while ( i < 4 )
	{
		vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet" );
		v_spawnpt = s_hip_spawnpt.origin + ( 0, randomintrange( -1000, 1000 ), randomintrange( -800, 800 ) );
		vh_hip1.origin = v_spawnpt;
		vh_hip1.angles = s_hip_spawnpt.angles;
		vh_hip1 thread hip_flyby_bp2( v_spawnpt, i );
		wait randomfloatrange( 0,8, 1,5 );
		i++;
	}
}

hip_flyby_bp2( v_spawnpt, n_index )
{
	self endon( "death" );
	s_goal1 = getstruct( "hip_flyby_goal1", "targetname" );
	s_goal2 = getstruct( "hip_flyby_goal2", "targetname" );
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self setspeed( 100, 50, 45 );
	if ( n_index == 1 )
	{
		self thread hip_flyby_stingers();
	}
	else
	{
		if ( n_index == 3 )
		{
			self thread hip_flyby_shot();
		}
	}
	self setvehgoalpos( s_goal1.origin + ( randomintrange( -300, 300 ), randomintrange( -300, 300 ), randomintrange( -200, 200 ) ), 0 );
	self waittill_any( "goal", "near_goal" );
	self thread hip_flyby_flares();
	self setvehgoalpos( s_goal2.origin + ( randomintrange( -300, 300 ), randomintrange( -300, 300 ), randomintrange( -200, 200 ) ), 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip_flyby_stingers()
{
	self endon( "death" );
	wait 2;
	s_stinger = getstruct( "hip_flyby_stinger", "targetname" );
	i = 0;
	while ( i < 4 )
	{
		magicbullet( "stinger_sp", s_stinger.origin, self.origin + ( randomintrange( -300, 300 ), randomintrange( -300, 300 ), randomintrange( -100, 200 ) ) );
		wait randomfloatrange( 1, 3 );
		i++;
	}
}

hip_flyby_shot()
{
	self endon( "death" );
	wait 2,5;
	s_stinger = getstruct( "hip_flyby_stinger", "targetname" );
	magicbullet( "stinger_sp", s_stinger.origin, self.origin, undefined, self, vectorScale( ( 0, 0, -1 ), 50 ) );
}

hip_flyby_flares()
{
	self endon( "death" );
	i = 0;
	while ( i < 5 )
	{
		playfx( level._effect[ "aircraft_flares" ], self.origin + vectorScale( ( 0, 0, -1 ), 120 ) );
		wait 0,25;
		i++;
	}
}

bp1_exit_battle()
{
	trigger_wait( "bp1_exit_battle" );
	level thread vo_get_horse();
	level thread vo_leave_bp1();
	trigger_on( "trigger_btr_chase", "script_noteworthy" );
	flag_set( "leaving_bp1" );
	flag_set( "bp1_exit_done" );
	flag_wait( "bp1_exit_done" );
	autosave_by_name( "bp1_exit" );
}

spawn_bp1exit_uazs()
{
	s_uaz1_spawnpt = getstruct( "uaz_bp1exit_spawnpt1", "targetname" );
	s_uaz2_spawnpt = getstruct( "uaz_bp1exit_spawnpt2", "targetname" );
	s_uaz3_spawnpt = getstruct( "uaz_bp1exit_spawnpt3", "targetname" );
	s_uaz4_spawnpt = getstruct( "uaz_bp1exit_spawnpt4", "targetname" );
	nd_start1 = getvehiclenode( "uaz_startnode1", "targetname" );
	nd_start2 = getvehiclenode( "uaz_startnode2", "targetname" );
	nd_start3 = getvehiclenode( "uaz_startnode3", "targetname" );
	nd_start4 = getvehiclenode( "uaz_startnode4", "targetname" );
	vh_uaz1 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz1.origin = s_uaz1_spawnpt.origin;
	vh_uaz1.angles = s_uaz1_spawnpt.angles;
	vh_uaz1 thread uaz_bp1_exit_logic( nd_start1 );
	vh_uaz2 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz2.origin = s_uaz2_spawnpt.origin;
	vh_uaz2.angles = s_uaz2_spawnpt.angles;
	vh_uaz2 thread uaz_bp1_exit_logic( nd_start2 );
	wait 3;
	vh_uaz3 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz3.origin = s_uaz3_spawnpt.origin;
	vh_uaz3.angles = s_uaz3_spawnpt.angles;
	vh_uaz3 thread uaz_bp1_exit_logic( nd_start3 );
	vh_uaz4 = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz4.origin = s_uaz4_spawnpt.origin;
	vh_uaz4.angles = s_uaz4_spawnpt.angles;
	vh_uaz4 thread uaz_bp1_exit_logic( nd_start4 );
	wait 2;
	level thread monitor_bp1exit_soviet();
}

bp1_muj_exit_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	self.goalradius = 64;
	self setgoalvolumeauto( getent( "vol_cache4", "targetname" ) );
}

uaz_bp1_exit_logic( nd_start )
{
	self endon( "death" );
	self.overridevehicledamage = ::sticky_grenade_damage;
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
			ai_rider.arena_guy = 1;
			ai_rider.bp1exit_guy = 1;
			ai_rider.targetname = "bp1exit_soviet";
			wait 0,05;
			ai_rider enter_vehicle( self );
		}
		i++;
	}
	self thread go_path( nd_start );
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self setbrake( 1 );
	flag_wait( "wave2_started" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

monitor_bp1exit_soviet()
{
	while ( 1 )
	{
		a_ai_guys = getentarray( "bp1exit_soviet", "targetname" );
		if ( !a_ai_guys.size )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	wait 2;
	flag_set( "bp1_exit_done" );
}

spawn_arena_crossers()
{
	sp_crosser = getent( "soviet_cache5", "targetname" );
	i = 0;
	while ( i < 3 )
	{
		sp_crosser spawn_ai( 1 );
		wait randomfloatrange( 1, 2 );
		i++;
	}
}

arena_crosser_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	vol_cache = getent( "vol_cache2", "targetname" );
	self setgoalvolumeauto( vol_cache );
}

arena_hip_land()
{
	trigger_wait( "trigger_mig1_strafe" );
	level thread spawn_mig_strafe();
	spawn_manager_kill( "manager_bp1_muj_exit" );
	a_ai_muj = getentarray( "bp1_muj_exit_ai", "targetname" );
	_a2217 = a_ai_muj;
	_k2217 = getFirstArrayKey( _a2217 );
	while ( isDefined( _k2217 ) )
	{
		ai_muj = _a2217[ _k2217 ];
		ai_muj die();
		_k2217 = getNextArrayKey( _a2217, _k2217 );
	}
}

spawn_mig_strafe()
{
	s_spawnpt = getstruct( "mig1_strafe_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig thread mig1_strafe_logic();
}

arena_hip_land_logic()
{
	self endon( "death" );
	target_set( self, ( -50, 0, -32 ) );
	self.dropoff_heli = 1;
	self setforcenocull();
	self hidepart( "tag_back_door" );
	self.overridevehicledamage = ::heli_vehicle_damage;
	sp_rappel = getent( "ambient_troops1", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 175, 85, 75 );
	s_goal1 = getstruct( "arena_hip_land_goal1", "targetname" );
	s_goal2 = getstruct( "arena_hip_land_goal2", "targetname" );
	s_goal3 = getstruct( "arena_hip_land_goal3", "targetname" );
	s_goal4 = getstruct( "arena_hip_land_goal4", "targetname" );
	s_goal5 = getstruct( "arena_hip_land_goal5", "targetname" );
	self setvehgoalpos( s_goal1.origin, 0 );
	self waittill_any( "near_goal", "goal" );
	hip_land_dropoff( "arena_hip_land_goal2", sp_rappel );
	self setvehgoalpos( s_goal3.origin, 0 );
	self waittill_any( "near_goal", "goal" );
	self setvehgoalpos( s_goal4.origin, 0 );
	self waittill_any( "near_goal", "goal" );
	self setvehgoalpos( s_goal5.origin, 0 );
	self waittill_any( "near_goal", "goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip_land_dropoff( drop_struct_name, sp_rappel )
{
	self endon( "death" );
	self sethoverparams( 0, 0, 10 );
	drop_struct = getstruct( drop_struct_name, "targetname" );
	drop_origin = drop_struct.origin;
	original_drop_origin = drop_origin;
	original_drop_origin = ( original_drop_origin[ 0 ], original_drop_origin[ 1 ], original_drop_origin[ 2 ] + self.dropoffset );
	drop_origin = ( drop_origin[ 0 ], drop_origin[ 1 ], drop_origin[ 2 ] + 350 );
	self setneargoalnotifydist( 100 );
	self setvehgoalpos( drop_origin, 1 );
	self waittill( "goal" );
	n_pos = 2;
	i = 0;
	while ( i < 4 )
	{
		ai_rappeller = sp_rappel spawn_ai( 1 );
		ai_rappeller.script_startingposition = n_pos;
		ai_rappeller.arena_guy = 1;
		ai_rappeller enter_vehicle( self );
		n_pos++;
		wait 0,1;
		i++;
	}
	self setvehgoalpos( original_drop_origin, 1 );
	self waittill( "goal" );
	self notify( "unload" );
	self waittill( "unloaded" );
}

spawn_arena_sniper()
{
	sp_sniper = getent( "sniper_arena", "targetname" );
	ai_sniper = sp_sniper spawn_ai( 1 );
	ai_sniper thread arena_sniper_behavior();
}

arena_sniper_behavior()
{
	self endon( "death" );
	self.no_cleanup = 1;
	self set_ignoreme( 1 );
	self set_ignoreme( 0 );
}

vo_enter_bp1()
{
	level endon( "soviet_fallback" );
	flag_wait( "bp1_stop_horse" );
	level.woods say_dialog( "maso_too_fucking_close_0", 2 );
	level.zhao say_dialog( "zhao_follow_me_2", 1 );
	wait 3;
	level thread nag_follow( "goto_town" );
	level thread vo_bp1_player_enters_blocking_point();
}

vo_engagement_bp1()
{
	level endon( "spawn_vehicles_bp1" );
	trigger_wait( "zhao_to_weapons" );
	level thread maps/afghanistan_arena_manager::cleanup_arena();
	flag_set( "goto_cache" );
	flag_wait( "soviet_fallback" );
	level.woods say_dialog( "wood_right_flank_0", 2,5 );
	level.zhao say_dialog( "muj0_the_cowards_are_retr_0", 1 );
	level.zhao say_dialog( "muj0_do_not_die_without_y_0", 1 );
	level thread vo_bp1_player_pushed_into_blocking_point();
}

vo_vehicles_bp1()
{
	level endon( "wave1_done" );
	level thread vo_vehicles_bp1_safeguard();
	flag_wait( "spawn_btr1_bp1" );
	wait 2;
	if ( level.player is_looking_at( level.first_bp1_btr, 0,6, 1, 60 ) )
	{
		level.player say_dialog( "maso_they_re_bringing_in_0", 0,2 );
	}
	else
	{
		level.woods say_dialog( "wood_we_got_a_btr_pushing_0", 0,2 );
	}
	wait 1;
	if ( !flag( "player_has_rpg" ) )
	{
		level.woods say_dialog( "wood_gonna_need_more_than_0", 0 );
		flag_set( "btr_dialog_done" );
		level.woods say_dialog( "wood_grab_an_rpg_from_the_0", 0,5 );
	}
	flag_set( "btr_dialog_done" );
	level.zhao say_dialog( "zhao_we_cannot_let_their_0", 1,5 );
	flag_wait( "spawn_btr2_bp1" );
	level.zhao say_dialog( "zhao_another_btr_is_heade_0", 1 );
	wait 7;
	while ( !flag( "player_has_rpg" ) )
	{
		level.woods say_dialog( "wood_grab_an_rpg_from_the_0", 0 );
		wait 8;
	}
}

vo_vehicles_bp1_safeguard()
{
	level endon( "btr_dialog_done" );
	level waittill( "wave1_done" );
	flag_set( "btr_dialog_done" );
}

vo_done_bp1()
{
	level endon( "started_crater_charge" );
	flag_wait( "wave1_done" );
	setmusicstate( "AFGHAN_C4" );
	level.woods say_dialog( "wood_nice_work_mason_0", 1 );
	level.zhao say_dialog( "zhao_the_mujahideen_can_h_0", 0,5 );
	level.woods say_dialog( "wood_mason_put_some_c4_u_0", 1 );
	flag_set( "dialog_crater_charge_done" );
	level.woods say_dialog( "wood_let_s_make_damn_sure_0", 0,5 );
	level thread nag_crater_charge();
}

nag_crater_charge()
{
	level endon( "started_crater_charge" );
	wait 8;
	n_nag = 0;
	while ( 1 )
	{
		level.woods say_dialog( "wood_mason_put_some_c4_u_0", 0 );
		wait 8;
		n_nag++;
		if ( n_nag > 5 )
		{
		}
	}
}

vo_nag_safe_distance()
{
	level endon( "dome_exploded" );
	level endon( "safe_to_explode" );
	level endon( "safe_to_explode_player" );
	while ( 1 )
	{
		wait 5;
		switch( randomint( 5 ) )
		{
			case 0:
				level.woods say_dialog( "wood_back_it_up_mason_0", 0 );
				break;
			continue;
			case 1:
				level.woods say_dialog( "wood_retreat_to_a_safe_di_1", 1 );
				break;
			continue;
			case 2:
				level.woods say_dialog( "wood_you_re_too_close_ma_1", 1 );
				break;
			continue;
			case 3:
				level.woods say_dialog( "wood_mason_come_over_he_1", 1 );
				break;
			continue;
			case 4:
				level.woods say_dialog( "wood_come_here_and_blow_t_0", 1 );
				break;
			continue;
		}
	}
}

vo_explosive_bp1()
{
	flag_wait( "started_crater_charge" );
	if ( level.b_plant_stairs )
	{
		scene_wait( "plant_explosive_dome_stairs" );
	}
	else
	{
		scene_wait( "plant_explosive_dome" );
	}
	level thread vo_detonation_warning();
	level.player say_dialog( "maso_set_0", 0,5 );
	flag_wait( "dome_exploded" );
	level.player say_dialog( "maso_hudson_the_west_ch_0", 0,5 );
	flag_set( "vo_end_of_bp1_done" );
}

vo_detonation_warning()
{
	while ( !level.player attackbuttonpressed() )
	{
		wait 0,1;
	}
	if ( !flag( "safe_to_explode" ) )
	{
		level.woods say_dialog( "wood_you_trying_to_blow_y_1", 0 );
	}
}

vo_head_to_bp1exit()
{
	if ( flag( "leaving_bp1" ) )
	{
		return;
	}
	level endon( "leaving_bp1" );
	wait 6;
	level.woods say_dialog( "wood_where_the_hell_are_y_0", 0 );
	wait 6;
	level.woods say_dialog( "wood_we_need_you_with_us_0", 0 );
	wait 6;
	level.woods say_dialog( "wood_there_s_nothing_else_0", 0 );
	wait 6;
	level.woods say_dialog( "wood_job_s_done_gotta_m_0", 0 );
	wait 6;
	level.woods say_dialog( "wood_don_t_get_left_behin_0", 0 );
	wait 5;
	if ( !flag( "leaving_bp1" ) )
	{
	}
}

vo_leave_bp1()
{
	level endon( "bp1_exit_done" );
	level.zhao say_dialog( "zhao_we_must_hurry_the_c_0", 1 );
	level.zhao say_dialog( "zhao_the_mujahideen_are_l_0", 0,5 );
	level.player say_dialog( "maso_the_muj_ain_t_gonna_0", 1 );
	level.woods say_dialog( "huds_do_what_you_can_but_0", 0,5 );
}

zhao_goto_wave2()
{
	level.zhao.vh_horse = self;
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	s_exit_battle = getstruct( "exit_battle_goal", "targetname" );
	s_zhao_wave2 = getstruct( "zhao_bp3", "targetname" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		s_zhao_wave2 = getstruct( "zhao_bp2", "targetname" );
	}
	self setvehgoalpos( s_exit_battle.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	wait 0,3;
	level.zhao notify( "stop_riding" );
	self vehicle_unload( 0,1 );
	self waittill( "unloaded" );
	level.zhao set_fixednode( 0 );
	flag_wait( "bp1_exit_done" );
	wait 1;
	level.zhao ai_mount_horse( self );
	wait 1;
	flag_set( "leaving_bp1_exit" );
	level.zhao thread say_dialog( "zhao_i_will_head_to_the_n_0", 0 );
	self setvehgoalpos( s_zhao_wave2.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	if ( level.wave2_loc == "blocking point 2" )
	{
		flag_set( "zhao_at_bp2" );
	}
	else
	{
		flag_set( "zhao_at_bp3" );
	}
	s_exit_battle = undefined;
	s_zhao_wave2 = undefined;
	if ( level.wave2_loc == "blocking point 2" )
	{
		s_zhao_wave2 = undefined;
	}
}

woods_goto_wave2()
{
	level.woods.vh_horse = self;
	s_ready = getstruct( "bp1_hitch", "targetname" );
	s_exit_battle = getstruct( "exit_battle_goal", "targetname" );
	s_zhao_wave2 = getstruct( "zhao_bp3", "targetname" );
	if ( level.wave2_loc == "blocking point 2" )
	{
		s_zhao_wave2 = getstruct( "zhao_bp2", "targetname" );
	}
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 300 );
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_exit_battle.origin + ( 150, -100, 0 ), 1, 1 );
	self waittill_any( "goal", "near_goal" );
}

btr_chase_event()
{
	level endon( "btr_chase_dead" );
	self thread monitor_btr_chase_over();
	s_goal = getstruct( "btr_chase_approach_goal", "targetname" );
	self.vh_horse setvehgoalpos( s_goal.origin, 0, 1 );
	self.vh_horse waittill_any( "goal", "near_goal" );
	if ( !flag( "btr_chase_dead" ) )
	{
		self thread shoot_at_btr();
	}
	if ( self.targetname == "zhao_ai" )
	{
		s_btr_goal = getstruct( "zhao_btr_chase_goal1", "targetname" );
	}
	else
	{
		s_btr_goal = getstruct( "woods_btr_chase_goal1", "targetname" );
	}
	self.vh_horse setvehgoalpos( s_btr_goal.origin, 0, 1 );
	self.vh_horse waittill_any( "goal", "near_goal" );
	self.vh_horse setbrake( 1 );
	if ( !flag( "btr_chase_dead" ) )
	{
		self thread defend_against_btr();
	}
}

monitor_btr_chase_over()
{
	flag_wait( "btr_chase_dead" );
	if ( self == level.zhao )
	{
		vh_horse = level.zhao_horse;
	}
	else
	{
		vh_horse = level.woods_horse;
	}
	wait 1;
	if ( !isDefined( vh_horse get_driver() ) )
	{
		wait 1;
		self ai_mount_horse( vh_horse );
	}
	vh_horse setbrake( 0 );
	vh_horse setvehgoalpos( getstruct( "btr_chase_over_goal", "targetname" ).origin, 0, 1 );
	vh_horse waittill_any( "goal", "near_goal" );
	vh_horse ent_flag_set( "btr_chase_over" );
}

shoot_at_btr()
{
	vh_btr = getent( "btr_chase", "targetname" );
	while ( !flag( "btr_chase_dead" ) )
	{
		if ( isalive( vh_btr ) && isDefined( vh_btr ) )
		{
			self shoot_at_target( vh_btr, undefined, 1, randomfloatrange( 2, 3,5 ) );
		}
		wait randomfloatrange( 1, 2 );
	}
	self stop_shoot_at_target();
}

defend_against_btr()
{
	level endon( "btr_chase_dead" );
	flag_set( "defend_against_btr" );
	self ai_dismount_horse( self.vh_horse );
	self set_fixednode( 0 );
	if ( self.targetname == "woods_ai" )
	{
		self thread force_goal( getnode( "node_woods_base_entrance", "targetname" ), 32 );
	}
	else
	{
		self thread force_goal( getnode( "node_zhao_base_entrance", "targetname" ), 32 );
	}
}

bp1_vehicle_chooser()
{
	level thread spawn_btr1_bp1();
	level thread spawn_btr2_bp1();
	level thread trigger_vehicles();
}

spawn_btr1_bp1()
{
	flag_wait( "spawn_btr1_bp1" );
	level thread vo_bp1_btr1_spawn();
	s_spawnpt = getstruct( "btr1_bp1_spawnpt", "targetname" );
	vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_spawnpt.origin;
	vh_btr.angles = s_spawnpt.angles;
	vh_btr thread btr1_bp1_logic();
	vh_btr makesentient();
	level.first_bp1_btr = vh_btr;
}

spawn_btr2_bp1()
{
	flag_wait( "spawn_btr2_bp1" );
	s_spawnpt = getstruct( "btr2_bp1_spawnpt", "targetname" );
	vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_spawnpt.origin;
	vh_btr.angles = s_spawnpt.angles;
	vh_btr thread btr2_bp1_logic();
	vh_btr makesentient();
}

trigger_vehicles()
{
	level endon( "wave1_done" );
	flag_wait( "spawn_vehicles_bp1" );
	wait 0,5;
	flag_set( "spawn_btr1_bp1" );
	wait 2;
	flag_set( "spawn_btr2_bp1" );
}

btr1_bp1_logic()
{
	self endon( "death" );
	self thread bp1_vehicle_destroyed();
	self thread delete_corpse_bp1();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread nag_destroy_vehicle();
	self thread create_objective_after_rpg_taken();
	self.overridevehicledamage = ::sticky_grenade_damage;
	nd_start = getvehiclenode( "wave1_btr1_start", "targetname" );
	self thread go_path( nd_start );
	self playsound( "veh_btr_drive_in" );
	nd_attack = getvehiclenode( "guard_blocking_point", "targetname" );
	nd_attack waittill( "trigger" );
	self setspeedimmediate( 0 );
}

create_objective_after_rpg_taken()
{
	self endon( "death" );
	level endon( "wave1_done" );
	flag_wait( "player_has_rpg" );
	set_objective( level.obj_afghan_bp1_vehicles, self, "destroy", -1 );
}

btr2_bp1_logic()
{
	self endon( "death" );
	self thread bp1_vehicle_destroyed();
	self thread delete_corpse_bp1();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread nag_destroy_vehicle();
	self thread create_objective_after_rpg_taken();
	self.overridevehicledamage = ::sticky_grenade_damage;
	nd_start = getvehiclenode( "wave1_btr2_start", "targetname" );
	nd_pause1 = getvehiclenode( "btr2_village_pause1", "targetname" );
	nd_pause2 = getvehiclenode( "btr2_village_pause2", "targetname" );
	nd_pause3 = getvehiclenode( "btr2_village_pause3", "targetname" );
	self thread go_path( nd_start );
	while ( 1 )
	{
		nd_pause3 waittill( "trigger" );
		self setspeedimmediate( 0 );
		wait randomintrange( 5, 8 );
		self resumespeed( 5 );
		nd_pause2 waittill( "trigger" );
		self setspeedimmediate( 0 );
		wait randomintrange( 5, 8 );
		self resumespeed( 5 );
		nd_pause1 waittill( "trigger" );
		self setspeedimmediate( 0 );
		wait randomintrange( 5, 8 );
		self resumespeed( 5 );
	}
}

projectile_fired_at_bp1btr()
{
	self endon( "death" );
	while ( 1 )
	{
		level.player waittill( "missile_fire", missile );
		self notify( "stop_attack" );
		wait 2;
		self shoot_turret_at_target( level.player, randomintrange( 3, 8 ), ( randomint( 64 ), randomint( 64 ), randomint( 64 ) ), 1, 0 );
		break;
	}
	cache_bp1_dest = getent( "bp1_cache_origin", "targetname" );
	self thread attack_cache_btr( cache_bp1_dest );
}

hip1_bp1_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::heli_vehicle_damage;
	self setvehicleavoidance( 1 );
	self setforcenocull();
	target_set( self, ( -50, 0, -32 ) );
	self thread bp1_vehicle_destroyed();
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	set_objective( level.obj_afghan_bp1_vehicles, self, "destroy", -1 );
	s_goal01 = getstruct( "hip1_bp1_goal01", "targetname" );
	s_goal02 = getstruct( "hip1_bp1_goal02", "targetname" );
	s_goal03 = getstruct( "hip1_bp1_goal03", "targetname" );
	s_goal04 = getstruct( "hip1_bp1_goal04", "targetname" );
	s_goal05 = getstruct( "hip1_bp1_goal05", "targetname" );
	s_goal06 = getstruct( "hip1_bp1_goal06", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 50, 20, 10 );
	self setvehgoalpos( s_goal01.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal01 = undefined;
	self setvehgoalpos( s_goal02.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal02 = undefined;
	self setvehgoalpos( s_goal03.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal03 = undefined;
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal04 = undefined;
	self setvehgoalpos( s_goal05.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal05 = undefined;
	self setvehgoalpos( s_goal06.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	s_goal06 = undefined;
	self setspeed( 0, 25, 20 );
	wait 1;
	self setspeedimmediate( 0 );
	wait 1;
	self.b_rappel_done = 0;
	wait 5;
	self.b_rappel_done = 1;
	s_start = getstruct( "hip1_bp1_circle02", "targetname" );
	self thread bp1_hip_circle( s_start );
	self thread hip_attack();
	s_start = undefined;
	flag_wait( "attack_cache_bp1" );
	self notify( "stop_attack" );
	wait 2;
	self clear_turret_target( 2 );
	self thread hip_attack();
}

bp1_hip1_rappel()
{
	self endon( "death" );
	s_rappel_point = spawnstruct();
	s_rappel_point.origin = ( ( self.origin + ( anglesToForward( self.angles ) * 135 ) ) - ( anglesToRight( self.angles ) * 55 ) ) + vectorScale( ( 0, 0, -1 ), 155 );
	sp_rappell = getent( "bp1_hip1_rappel", "targetname" );
	spawn_manager_enable( "manager_wave1bp1_rappel1" );
}

bp1_rappel_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
}

hip2_bp1_logic()
{
	self endon( "death" );
	self.overridevehicledamage = ::heli_vehicle_damage;
	self setvehicleavoidance( 1 );
	self setforcenocull();
	target_set( self, ( -50, 0, -32 ) );
	self thread bp1_vehicle_destroyed();
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	set_objective( level.obj_afghan_bp1_vehicles, self, "destroy", -1 );
	s_goal01 = getstruct( "hip2_bp1_goal01", "targetname" );
	s_goal02 = getstruct( "hip2_bp1_goal02", "targetname" );
	s_goal03 = getstruct( "hip2_bp1_goal03", "targetname" );
	s_goal04 = getstruct( "hip2_bp1_goal04", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 50, 20, 10 );
	self setvehgoalpos( s_goal01.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal01 = undefined;
	self setvehgoalpos( s_goal02.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal02 = undefined;
	self setvehgoalpos( s_goal03.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal03 = undefined;
	self setvehgoalpos( s_goal04.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	s_goal04 = undefined;
	s_start = getstruct( "hip1_bp1_circle05", "targetname" );
	self thread bp1_hip_circle( s_start );
	self thread hip_attack();
	flag_wait( "attack_cache_bp1" );
	self notify( "stop_attack" );
	wait 2;
	self clear_turret_target( 2 );
	self thread hip_attack();
}

bp1_hip_circle( s_start )
{
	self endon( "death" );
	self endon( "stop_circle" );
	self setspeed( 50, 25, 20 );
	s_goal = s_start;
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin );
		self waittill_any( "goal", "near_goal" );
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

bp1_crew_spawn()
{
	flag_wait( "crew_showoff" );
	level thread bp1_crew_showoff();
}

bp1_crew_showoff()
{
	e_fire = getent( "crew_rpg_fire", "targetname" );
	e_target = getent( "crew_rpg_target", "targetname" );
	wait 0,1;
	e_rocket = magicbullet( "rpg_magic_bullet_sp", e_fire.origin, e_target.origin );
	e_rocket thread crew_rocket_explode();
	e_fire delete();
	e_target delete();
	level thread vo_bp1_rpg_shot();
}

crew_rocket_explode()
{
	self waittill( "death" );
	playfx( level._effect[ "explode_grenade_sand" ], self.origin );
	earthquake( 0,2, 1, level.player.origin, 100 );
	ai_victim = getent( "bp1_initial_guard_ai", "targetname" );
	if ( isalive( ai_victim ) )
	{
		ai_victim stop_magic_bullet_shield();
		ai_victim.deathanim = %death_explosion_right13;
		radiusdamage( ai_victim.origin, 100, ai_victim.health, ai_victim.health, undefined, "MOD_PROJECTILE" );
	}
	level.zhao say_dialog( "muj0_enemy_killed_0", 1 );
}

defend_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "o" );
}

initial_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "p" );
}

reinforce_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "p" );
}

reinforce_bp1_green_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
}

fixed_bp1_logic()
{
	self endon( "death" );
	node = undefined;
	if ( isDefined( self.script_noteworthy ) )
	{
		node = getnode( self.script_noteworthy, "script_noteworthy" );
	}
	if ( isDefined( node ) )
	{
		self thread force_goal( node );
	}
	else
	{
		self thread force_goal();
	}
	self.bp_ai = 1;
	self.goalradius = 32;
	self waittill( "goal" );
	self set_fixednode( 1 );
}

bp1_rooftop_logic()
{
	self endon( "death" );
	self thread force_goal();
	self.bp_ai = 1;
	self.goalradius = 32;
	self waittill( "goal" );
	self set_fixednode( 1 );
}

roof_jumper_logic()
{
	self endon( "death" );
	self thread force_goal( ( 6504, -19405, -251 ), 32, 0 );
	self.bp_ai = 1;
	self waittill( "goal" );
	self set_fixednode( 1 );
}

victim_bp1_logic()
{
	self endon( "death" );
	self thread force_goal();
	self thread magic_bullet_shield();
	self.bp_ai = 1;
	self.goalradius = 32;
	self waittill( "goal" );
	self set_fixednode( 1 );
}

assault_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	self set_force_color( "p" );
}

bp1wave1_monitor_soviets()
{
	level.n_bp1wave1_soviet_killed++;
	if ( level.n_bp1wave1_soviet_killed > 11 && !flag( "attack_crew_bp1" ) )
	{
		flag_set( "attack_crew_bp1" );
		flag_set( "attack_cache_bp1" );
	}
	return 0;
}

monitor_enemy_bp1()
{
	trigger_use( "triggercolor_soviet_entrance" );
	spawn_manager_enable( "manager_initial_bp1" );
	spawn_manager_enable( "manager_bp1_bottom", 1 );
	sp_guard1 = getent( "bp1_cache_guard1", "targetname" );
	sp_guard2 = getent( "bp1_cache_guard2", "targetname" );
	sp_guard1 spawn_ai( 1 );
	trigger_wait( "zhao_to_town" );
	trigger_use( "triggercolor_soviet_cache" );
	flag_set( "goto_town" );
	flag_wait( "tower_fall" );
	ai_cache_guard2 = sp_guard2 spawn_ai( 1 );
	if ( isDefined( ai_cache_guard2 ) )
	{
		ai_cache_guard2 thread crosser_logic();
	}
	level thread bp1_soviet_chain_p3();
	level thread bp1_soviet_chain_p3_sm();
	level thread bp1_set_btr_spawn_flags();
	sp_sniper = getent( "bp1_initial_sniper", "targetname" );
	ai_sniper = sp_sniper spawn_ai( 1 );
	level thread spawn_tower_guys();
	spawn_manager_enable( "manager_soviet_bp1" );
	flag_wait( "soviet_fallback" );
	spawn_manager_kill( "manager_initial_bp1" );
	trigger_use( "triggercolor_soviet_crosstown" );
	spawn_manager_disable( "manager_soviet_bp1" );
	wait 3;
	spawn_manager_enable( "manager_bp1_reinforce" );
	spawn_manager_disable( "manager_bp1_bottom", 1 );
	autosave_by_name( "bp1_vehicle_spawn" );
	flag_wait( "wave1_done" );
	trigger_use( "triggercolor_crosstown" );
	spawn_manager_enable( "manager_muj_advance" );
	spawn_manager_kill( "manager_muj_bp1" );
	wait 5;
	spawn_manager_kill( "manager_soviet_bp1" );
	spawn_manager_kill( "manager_bp1_reinforce" );
	spawn_manager_kill( "manager_bp1_last_troops" );
	flag_wait( "wave1_complete" );
	spawn_manager_kill( "manager_muj_advance" );
	spawn_manager_kill( "manager_bp1_bottom", 1 );
}

monitor_enemy_bp1_bottom()
{
	level endon( "wave1_done" );
	bottom_trigger = getent( "bp1_bottom_trigger", "targetname" );
	while ( !flag( "wave1_done" ) )
	{
		level.player waittill_player_touches( bottom_trigger );
		spawn_manager_enable( "manager_bp1_bottom", 1 );
		level.player waittill_player_leaves( bottom_trigger );
		spawn_manager_disable( "manager_bp1_bottom", 1 );
	}
}

bp1_set_btr_spawn_flags()
{
	trigger_wait( "zhao_to_weapons" );
	wait 1;
	flag_set( "spawn_vehicles_bp1" );
	wait 6;
	flag_set( "spawn_btr2_bp1" );
}

bp1_soviet_chain_p3()
{
	trigger_wait( "zhao_to_weapons" );
	flag_set( "zhao_to_weapons" );
	trigger_use( "triggercolor_p3" );
}

bp1_soviet_chain_p3_sm()
{
	level endon( "zhao_to_weapons" );
	waittill_spawn_manager_spawned_count( "manager_soviet_bp1", 11 );
	trigger_use( "zhao_to_weapons" );
}

crosser_logic()
{
	self endon( "death" );
	self thread force_goal( ( 6492, -18995, -203 ), 64 );
}

spawn_tower_guys()
{
	wait 2;
	sp_rooftop = getent( "bp1_tower_rooftop", "targetname" );
	sp_rooftop spawn_ai( 1 );
}

reinforce1_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	nd_1 = getnode( "alt1_1_goal", "targetname" );
	nd_2 = getnode( "alt1_2_goal", "targetname" );
	nd_3 = getnode( "alt1_3_goal", "targetname" );
	nd_4 = getnode( "alt1_4_goal", "targetname" );
	self change_movemode( "sprint" );
	if ( self.script_noteworthy == "alt1_1" )
	{
		self thread force_goal( nd_1, 64, 1 );
		self waittill( "goal" );
		self reset_movemode();
		self set_fixednode( 1 );
		self thread shoot_at_target( level.player, undefined, 1, 5 );
		wait 5;
		self set_fixednode( 0 );
	}
	self waittill( "goal" );
	self reset_movemode();
}

reinforce2_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	nd_1 = getnode( "alt2_1_goal", "targetname" );
	nd_2 = getnode( "alt2_2_goal", "targetname" );
	nd_3 = getnode( "alt2_3_goal", "targetname" );
	nd_4 = getnode( "alt2_4_goal", "targetname" );
	self change_movemode( "sprint" );
	if ( self.script_noteworthy == "alt2_1" )
	{
		self thread force_goal( nd_1, 64, 1 );
		self waittill( "goal" );
		self reset_movemode();
		self set_fixednode( 1 );
		self thread shoot_at_target( level.player, undefined, 1, 5 );
		wait 5;
		self set_fixednode( 0 );
	}
	else if ( self.script_noteworthy == "alt2_2" )
	{
		self thread force_goal( nd_2, 64, 1 );
	}
	else if ( self.script_noteworthy == "alt2_3" )
	{
		self thread force_goal( nd_3, 64, 1 );
	}
	else
	{
		if ( self.script_noteworthy == "alt2_4" )
		{
			self thread force_goal( nd_4, 64, 1 );
		}
	}
	self waittill( "goal" );
	self reset_movemode();
}

reinforce3_bp1_logic()
{
	self endon( "death" );
	self.bp_ai = 1;
	nd_1 = getnode( "alt3_1_goal", "targetname" );
	nd_2 = getnode( "alt3_2_goal", "targetname" );
	nd_3 = getnode( "alt3_3_goal", "targetname" );
	nd_4 = getnode( "alt3_4_goal", "targetname" );
	self change_movemode( "sprint" );
	if ( self.script_noteworthy == "alt3_1" )
	{
		self thread force_goal( nd_1, 64, 1 );
		self waittill( "goal" );
		self reset_movemode();
		self set_fixednode( 1 );
		self thread shoot_at_target( level.player, undefined, 1, 5 );
		wait 5;
		self set_fixednode( 0 );
	}
	else if ( self.script_noteworthy == "alt3_2" )
	{
		self thread force_goal( nd_2, 64, 1 );
	}
	else if ( self.script_noteworthy == "alt3_3" )
	{
		self thread force_goal( nd_3, 64, 1 );
	}
	else
	{
		if ( self.script_noteworthy == "alt3_4" )
		{
			self thread force_goal( nd_4, 64, 1 );
		}
	}
	self waittill( "goal" );
	self reset_movemode();
}

monitor_cache_bp1()
{
	level endon( "cache_destroyed_bp1" );
	level endon( "wave1_complete" );
	cache_bp1_pris = getent( "ammo_cache_BP1_pristine", "targetname" );
	cache_bp1_dmg = getent( "ammo_cache_BP1_damaged", "targetname" );
	cache_bp1_dest = getent( "ammo_cache_BP1_destroyed", "targetname" );
	cache_bp1_clip = getent( "ammo_cache_BP1_clip", "targetname" );
	cache_bp1_origin = getent( "bp1_cache_origin", "targetname" );
	cache_bp1_pris setcandamage( 1 );
	n_cache_health = 100;
	b_under_attack = 0;
	b_down_50 = 0;
	b_down_25 = 0;
	b_destroyed = 0;
	cache = cache_bp1_pris;
	while ( 1 )
	{
		cache waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "apc_btr60" )
		{
			n_cache_health -= 0,5;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "heli_hip" )
		{
			n_cache_health -= 0,5;
		}
		if ( type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" )
		{
			n_cache_health -= 10;
		}
		if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			n_cache_health -= 4;
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
				cache_bp1_dmg setcandamage( 1 );
				cache = cache_bp1_dmg;
				cache_bp1_pris delete();
				cache_bp1_dmg show();
				playfx( level._effect[ "cache_dmg" ], cache_bp1_dmg.origin );
			}
		}
		if ( n_cache_health < 25 )
		{
			if ( !b_down_25 )
			{
				b_down_25 = 1;
			}
		}
		if ( n_cache_health < 1 )
		{
			if ( !b_destroyed )
			{
				b_destroyed = 1;
				playfx( level._effect[ "cache_dest" ], cache_bp1_dest.origin );
				wait 0,1;
				cache_bp1_dest show();
				cache_bp1_dmg delete();
				cache_bp1_clip delete();
				cache_bp1_origin delete();
				level.caches_lost++;
				flag_set( "cache_destroyed_bp1" );
			}
		}
	}
}

monitor_cache_bp1exit()
{
	cache_pris = getent( "ammo_cache_arena_4_pristine", "targetname" );
	cache_dmg = getent( "ammo_cache_arena_4_damaged", "targetname" );
	cache_dest = getent( "ammo_cache_arena_4_destroyed", "targetname" );
	cache_clip = getent( "ammo_cache_arena_4_clip", "targetname" );
	cache_dest setcandamage( 1 );
	n_cache_health = 100;
	b_under_attack = 0;
	b_down_50 = 0;
	b_down_25 = 0;
	b_destroyed = 0;
	cache = cache_dest;
	while ( 1 )
	{
		cache waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "apc_btr60" )
		{
			n_cache_health -= 0,5;
		}
		if ( isDefined( attacker.vehicletype ) && attacker.vehicletype == "heli_hip" )
		{
			n_cache_health -= 0,5;
		}
		if ( type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" )
		{
			n_cache_health -= 10;
		}
		if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
		{
			n_cache_health -= 4;
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
				cache_pris delete();
				cache_dmg show();
				cache = cache_dmg;
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
		if ( n_cache_health < 1 )
		{
			if ( !b_destroyed )
			{
				b_destroyed = 1;
				flag_set( "cache4_destroyed" );
				playfx( level._effect[ "cache_dest" ], cache_dest.origin );
				wait 0,1;
				cache_dest show();
				cache_dmg delete();
				cache_clip delete();
				level.caches_lost++;
			}
		}
	}
}

bp1_vehicle_destroyed()
{
	self waittill( "death", attacker );
	set_objective( level.obj_afghan_bp1_vehicles, self, "remove" );
	level.n_bp1_veh_destroyed++;
	wait 0,2;
	set_objective( level.obj_afghan_bp1_vehicles, undefined, undefined, level.n_bp1_veh_destroyed );
	if ( level.n_bp1_veh_destroyed == 1 )
	{
		level.player say_dialog( "maso_the_btr_s_history_0", 0,5 );
		level thread vo_bp1_btr1_dead();
		level.woods say_dialog( "wood_fucking_a_0", 0,5 );
		level.zhao say_dialog( "muj0_cheer_0", 1 );
	}
	if ( level.n_bp1_veh_destroyed > 1 )
	{
		flag_set( "wave1_done" );
		flag_set( "soviet_fallback" );
		set_objective( level.obj_afghan_bp1_vehicles, undefined, "done" );
		set_objective( level.obj_afghan_bp1_vehicles, undefined, "delete" );
		level thread vo_bp1_btr2_dead();
	}
	autosave_by_name( "bp1_vehicle_destroyed" );
}
