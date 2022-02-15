#include maps/_horse_rider;
#include maps/createart/afghanistan_art;
#include maps/_audio;
#include maps/afghanistan_anim;
#include maps/afghanistan_intro_rebel_base;
#include maps/_music;
#include maps/_dialog;
#include maps/_vehicle_aianim;
#include maps/_vehicle;
#include maps/_horse;
#include maps/afghanistan_utility;
#include maps/_objectives;
#include maps/_anim;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "animated_props" );
#using_animtree( "horse" );
#using_animtree( "generic_human" );
#using_animtree( "vehicles" );

init_flags()
{
	flag_init( "playerat_exit" );
	flag_init( "start_firehorse" );
	flag_init( "player_pickup" );
	flag_init( "player_onhorse" );
	flag_init( "horse_rearback" );
	flag_init( "zhao_mount" );
	flag_init( "mig_spawned" );
	flag_init( "arena_mig1" );
	flag_init( "arena_overlook" );
	flag_init( "arena_chopper_takeoff" );
	flag_init( "chopper_blow_up" );
	flag_init( "firehorse_done" );
	flag_init( "hip3_troops_spawned" );
	flag_init( "monitor_hip3" );
	flag_init( "hip3_spawned" );
	flag_init( "hip4_spawned" );
	flag_init( "hip4_troops_spawned" );
	flag_init( "stop_arena_explosions" );
	flag_init( "zhao_at_bp1" );
	flag_init( "woods_at_bp1" );
	flag_init( "clear_arena" );
	flag_init( "stop_horse_patrols" );
	flag_init( "hip1_rappellers" );
	flag_init( "hip2_rappellers" );
	flag_init( "uaz_spawned" );
	flag_init( "end_arena_migs" );
}

init_spawn_funcs()
{
	add_spawn_function_veh( "arena_chopper_crash", ::hip_arena_takeoff_logic );
	add_spawn_function_group( "tunnel_runner_exp", "script_noteworthy", ::tunnel_runner_logic );
	add_spawn_function_group( "corral_jumper", "targetname", ::corral_jumper_logic );
	add_spawn_function_group( "tunnel_runner_delete", "script_noteworthy", ::runners_logic );
	add_spawn_function_group( "rooftop_mig_shooter", "targetname", ::rooftop_shooter_logic );
	add_spawn_function_group( "muj_rider_base", "targetname", ::muj_rider_base_logic );
	add_spawn_function_group( "hip3_troops", "targetname", ::hip3_guy_logic );
	add_spawn_function_group( "hip4_troops", "targetname", ::hip4_guy_logic );
	add_spawn_function_group( "base_guard", "targetname", ::arena_guy_logic );
	add_spawn_function_group( "muj_guard", "targetname", ::arena_guy_logic );
	add_spawn_function_group( "first_arena_enemy", "targetname", ::arena_guy_logic );
	add_spawn_function_group( "firehorse_cache_guard", "targetname", ::firehorse_cache_guard_logic );
}

event_setup_firehorse()
{
	t_cache_guard = getent( "trigger_firehorse_cache_guard", "targetname" );
	t_cache_guard trigger_on();
	t_exit = getent( "tunnel_exit", "targetname" );
	t_exit trigger_on();
	t_overlook = getent( "player_at_overlook", "targetname" );
	t_overlook trigger_on();
	trigger_use( "map_room_exit" );
	level.woods = getent( "woods_ai", "targetname" );
	level.woods setcandamage( 0 );
}

skipto_firehorse()
{
	skipto_setup();
	init_hero( "zhao" );
	level.woods = init_hero( "woods" );
	init_hero( "hudson" );
	level.rebel_leader = init_hero( "rebel_leader" );
	skipto_teleport( "skipto_firehorse", level.heroes );
	remove_woods_facemask_util();
	level thread maps/afghanistan_intro_rebel_base::spawn_map_room_personnel();
	flag_wait( "afghanistan_gump_arena" );
	exploder( 300 );
}

objectives_firehorse()
{
	set_objective( level.obj_afghan_bp1, level.zhao, "follow" );
	trigger_wait( "trigger_maproom_exit" );
	level thread spawn_base_horses();
	level thread muj_tank_exit();
	level thread spawn_mig_cave_strafe();
	set_objective( level.obj_afghan_bp1, level.zhao, "remove" );
	set_objective( level.obj_afghan_bp1, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
	objective_setflag( level.obj_afghan_bp1, "fadeoutonscreen", 0 );
	level thread watch_for_player_leaves_base_on_horse();
	flag_wait( "player_onhorse" );
	set_objective( level.obj_afghan_bp1, level.mason_horse, "remove" );
	set_objective( level.obj_afghan_bp1, level.zhao, "follow" );
}

watch_for_player_leaves_base_on_horse()
{
	player_exit_base_on_horse = 0;
	while ( !player_exit_base_on_horse )
	{
		trigger_wait( "player_at_overlook" );
		if ( flag( "player_onhorse" ) )
		{
			player_exit_base_on_horse = 1;
		}
		else
		{
			missionfailedwrapper( &"AFGHANISTAN_NEED_HORSE" );
		}
		wait 0,05;
	}
}

main()
{
/#
	iprintln( "Firehorse" );
#/
	flag_wait( "afghanistan_gump_arena" );
	stop_exploder( 200 );
	stop_exploder( 201 );
	stop_exploder( 230 );
	if ( level.skipto_point == "firehorse" )
	{
		maps/afghanistan_anim::init_afghan_anims_part1b();
		delete_section1_scenes();
	}
	a_gun_crate = getentarray( "crate_guns", "targetname" );
	array_delete( a_gun_crate );
	level notify( level.ammo_cache_waittill_notify );
	level thread run_firehorse_anims();
	level clientnotify( "start_fx_on_swinging_lights" );
	wait_network_frame();
	spawn_firehorses();
	event_setup_firehorse();
	init_spawn_funcs();
	level thread instructions_firehorse();
	level thread ambience_manager();
	spawn_manager_enable( "manager_rooftop_shooters" );
	level thread maps/_audio::switch_music_wait( "AFGHAN_BATTLE_START", 4 );
	level clientnotify( "abs_1" );
	flag_wait( "firehorse_done" );
}

spawn_firehorses()
{
	s_zhao_horse = getstruct( "firehorse_zhao_spawnpt", "targetname" );
	s_woods_horse = getstruct( "firehorse_woods_spawnpt", "targetname" );
	s_mason_horse = getstruct( "firehorse_mason_spawnpt", "targetname" );
	level.zhao_horse = getent( "zhao_horse", "targetname" );
	if ( !isDefined( level.zhao_horse ) )
	{
		level.zhao_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	}
	level.zhao_horse.origin = s_zhao_horse.origin;
	level.zhao_horse.angles = s_zhao_horse.angles;
	level.zhao_horse.animname = "firehorse_zhao";
	level.zhao_horse thread firehorse_zhao_logic();
	level.woods_horse = getent( "woods_horse", "targetname" );
	if ( !isDefined( level.woods_horse ) )
	{
		level.woods_horse = spawn_vehicle_from_targetname( "woods_horse" );
	}
	level.woods_horse.origin = s_woods_horse.origin;
	level.woods_horse.angles = s_woods_horse.angles;
	level.woods_horse.animname = "horse_woods";
	level.woods_horse thread firehorse_woods_logic();
	level.mason_horse = getent( "mason_horse", "targetname" );
	if ( !isDefined( level.mason_horse ) )
	{
		level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	}
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_mason_horse.origin;
	level.mason_horse.angles = s_mason_horse.angles;
	level.mason_horse thread firehorse_mason_logic();
}

run_firehorse_anims()
{
	level thread exit_map_room_scene();
	level thread run_scene( "e3_exit_map_room_guards" );
	level thread play_other_maproom_idle();
	run_scene( "e3_exit_map_room" );
	setsaveddvar( "g_speed", level.default_run_speed );
	level.player setlowready( 0 );
	if ( !flag( "playerat_exit" ) )
	{
		level thread run_scene( "e3_map_room_idle" );
	}
	autosave_by_name( "map_room_exit" );
	flag_wait( "playerat_exit" );
	if ( !flag( "player_onhorse" ) )
	{
		run_scene( "e3_ride_out" );
	}
}

play_other_maproom_idle()
{
	scene_wait( "e3_exit_map_room_guards" );
	level thread run_scene( "e3_map_room_idle_everyone_else" );
	flag_wait( "firehorse_done" );
	end_scene( "e3_map_room_idle_everyone_else" );
}

spotlight_on_zhao()
{
	e_spotlight = spawn( "script_model", self gettagorigin( "tag_eye" ) + ( anglesToForward( self gettagangles( "tag_eye" ) ) * 16 ) );
	e_spotlight.angles = self gettagangles( "tag_eye" ) * -1;
	e_spotlight setmodel( "tag_origin" );
	e_spotlight linkto( self, "tag_eye" );
	playfxontag( level._effect[ "spotlight_cave" ], e_spotlight, "tag_origin" );
	scene_wait( "e3_exit_map_room" );
	e_spotlight delete();
}

exit_map_room_scene()
{
	level run_scene( "e3_exit_map_room_player" );
	level.player enableweaponfire();
	delete_scene( "e3_exit_map_room_player", 1 );
}

instructions_firehorse()
{
	level clientnotify( "battle_walla" );
	if ( level.press_demo )
	{
		level clientnotify( "fin" );
		level maps/createart/afghanistan_art::rebel_camp();
		level screen_fade_in( 3 );
		level.player freezecontrols( 0 );
	}
	flag_wait( "playerat_exit" );
	level.zhao say_dialog( "zhao_we_must_hurry_we_c_0", 0 );
	get_muj() thread say_dialog( "muj0_save_the_stingers_fo_0", 1 );
	level.woods say_dialog( "wood_saddle_up_mason_0", 0,5 );
	flag_wait( "horse_rearback" );
	setmusicstate( "HORSE_REARBACK" );
	level thread maps/_audio::switch_music_wait( "ON_TO_BATTLE", 3 );
	level.player say_dialog( "maso_this_may_be_tougher_0", 0,25 );
	flag_wait( "firehorse_done" );
	level.woods say_dialog( "wood_leave_them_to_the_mu_0", 0,5 );
}

arena_chopper_crash( vh_chopper )
{
	vh_chopper hidepart( "tag_main_rotor_blur" );
	m_blades = getent( "fxanim_chopper_crash_blades", "targetname" );
	m_blades show();
	run_scene( "chopper_crash_rocks" );
}

arena_rock_crash( vh_chopper )
{
	vh_chopper godoff();
	flag_set( "chopper_blow_up" );
	hip_dead = spawn( "script_model", vh_chopper.origin );
	hip_dead setmodel( "t5_veh_helo_mi8_woodland_dead" );
	hip_dead.angles = vh_chopper.angles;
	hip_dead.fire_pos = spawn( "script_model", hip_dead.origin );
	hip_dead.fire_pos setmodel( "tag_origin" );
	hip_dead.fire_pos linkto( hip_dead );
	playfxontag( level._effect[ "dead_hip_fire" ], hip_dead.fire_pos, "tag_origin" );
	m_blades = getent( "fxanim_chopper_crash_blades", "targetname" );
	m_blades delete();
	vh_chopper.delete_on_death = 1;
	vh_chopper notify( "death" );
	if ( !isalive( vh_chopper ) )
	{
		vh_chopper delete();
	}
}

arena_chopper_trail( vh_chopper )
{
	playfx( level._effect[ "missile_impact_hip" ], vh_chopper.origin );
	vh_chopper playsound( "fxa_hip_stinger_hit" );
	playfxontag( level._effect[ "dmg_trail_hip" ], vh_chopper, "tag_origin" );
}

stinger_hit_chopper()
{
	flag_wait( "arena_chopper_takeoff" );
	s_rpg = getstruct( "rpg_fireat_hip1", "targetname" );
	wait 1,6;
	magicbullet( "stinger_sp", s_rpg.origin, self.origin, undefined, self, vectorScale( ( 0, 0, -1 ), 32 ) );
}

flaming_horse_logic()
{
	e_fire_tag = getent( "tag_firehorse", "targetname" );
	e_fire_tag linkto( self, "Bone_H_Saddle", vectorScale( ( 0, 0, -1 ), 12 ) );
	playfxontag( level._effect[ "fire_horse" ], e_fire_tag, "tag_origin" );
	e_fire_tag playsound( "evt_horse_pain_vox" );
	e_fire_tag playloopsound( "evt_horse_fire", 0,25 );
	self waittill( "death" );
	e_fire_tag delete();
}

horse_remove()
{
	flag_wait( "wave1_done" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

muj_rider_base_logic()
{
	self endon( "death" );
	self waittill( "enter_vehicle", vehicle );
	vehicle notify( "groupedanimevent" );
	self maps/_horse_rider::ride_and_shoot( vehicle );
	self.arena_guy = 1;
}

arena_guy_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	if ( flag( "wave1_started" ) )
	{
		wait 0,1;
		if ( isalive( self ) )
		{
			self die();
		}
	}
}

firehorse_cache_guard_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	self change_movemode( "sprint" );
	self thread force_goal( undefined, 32 );
	self waittill( "goal" );
	self reset_movemode();
}

spawn_mig_cave_strafe()
{
	s_spawnpt = getstruct( "mig_cave_strafe_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig thread mig_cave_strafe_logic();
}

mig_cave_strafe_logic()
{
	self endon( "death" );
	s_goal1 = getstruct( "mig_cave_strafe_goal2", "targetname" );
	s_goal2 = getstruct( "mig_cave_strafe_goal2", "targetname" );
	self setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	self.overridevehicledamage = ::sticky_grenade_damage;
	target_set( self );
	self setforcenocull();
	self setneargoalnotifydist( 400 );
	self setspeed( 400, 100, 50 );
	self thread mig_cave_gun_strafe();
	self setvehgoalpos( s_goal1.origin );
	self waittill_any( "near_goal", "goal" );
	self setvehgoalpos( s_goal2.origin );
	self waittill_any( "near_goal", "goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

mig_cave_gun_strafe()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		v_gunl = self gettagorigin( "tag_weapons_l" ) + ( anglesToForward( self.angles ) * 500 );
		v_gunr = self gettagorigin( "tag_weapons_r" ) + ( anglesToForward( self.angles ) * 500 );
		v_targetl = self gettagorigin( "tag_weapons_l" ) + ( anglesToForward( self.angles ) * 800 );
		v_targetr = self gettagorigin( "tag_weapons_r" ) + ( anglesToForward( self.angles ) * 800 );
		magicbullet( "btr60_heavy_machinegun", v_gunl, v_targetl + vectorScale( ( 0, 0, -1 ), 200 ) );
		magicbullet( "btr60_heavy_machinegun", v_gunr, v_targetr + vectorScale( ( 0, 0, -1 ), 200 ) );
		wait 0,05;
	}
}

mig23_arena_strafe()
{
	flag_wait( "arena_mig1" );
	s_mig23 = getstruct( "arena_mig1_start", "targetname" );
	s_mig23_mid = getstruct( "arena_mig1_mid", "targetname" );
	s_mig23_end = getstruct( "arena_mig1_end", "targetname" );
	vh_mig23 = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig23 setforcenocull();
	vh_mig23.origin = s_mig23.origin;
	vh_mig23.angles = s_mig23.angles;
	vh_mig23 setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	target_set( vh_mig23, ( -230, 0, -12 ) );
	vh_mig23 endon( "death" );
	vh_mig23 setneargoalnotifydist( 600 );
	vh_mig23 setspeed( 300, 150, 100 );
	vh_mig23 setvehgoalpos( s_mig23_mid.origin );
	vh_mig23 waittill_any( "goal", "near_goal" );
	vh_mig23 setvehgoalpos( s_mig23_end.origin );
	vh_mig23 waittill_any( "goal", "near_goal" );
	vh_mig23 delete();
}

arena_mig1_bombs()
{
	self endon( "death" );
	s_bomb1 = getstruct( "arena_mig1_bomb1", "targetname" );
	s_bomb2 = getstruct( "arena_mig1_bomb2", "targetname" );
	s_bomb3 = getstruct( "arena_mig1_bomb3", "targetname" );
	s_bomb4 = getstruct( "arena_mig1_bomb4", "targetname" );
	playsoundatposition( "exp_mortar", s_bomb1.origin );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb1.origin );
	radiusdamage( s_bomb1.origin, 500, 1000, 800 );
	wait 0,5;
	playsoundatposition( "exp_mortar", s_bomb2.origin );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb2.origin );
	radiusdamage( s_bomb2.origin, 500, 1000, 800 );
	wait 0,5;
	playsoundatposition( "exp_mortar", s_bomb3.origin );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb3.origin );
	radiusdamage( s_bomb3.origin, 500, 1000, 800 );
	wait 0,5;
	playsoundatposition( "exp_mortar", s_bomb4.origin );
	playfx( level._effect[ "explode_mortar_sand" ], s_bomb4.origin );
	radiusdamage( s_bomb4.origin, 500, 1000, 800 );
}

first_mig_bombs()
{
	s_bomb1 = getstruct( "mig23_bomb_exp1", "targetname" );
	s_bomb2 = getstruct( "mig23_bomb_exp2", "targetname" );
	wait 2;
	playfx( level._effect[ "explode_large_sand" ], s_bomb1.origin );
	earthquake( 0,4, 2,5, level.player.origin, 100 );
	self thread shootat_mig23_flyby();
	wait 1;
	playfx( level._effect[ "explode_large_sand" ], s_bomb2.origin );
	earthquake( 0,5, 3, level.player.origin, 100 );
}

migs_flyover_base()
{
	level endon( "end_base_migs" );
	level endon( "horse_charge_finished" );
	a_s_mig_start = getstructarray( "mig_base_flyover1", "targetname" );
	a_s_mig_delete = getstructarray( "mig_flyover_delete1", "targetname" );
	if ( cointoss() )
	{
		a_s_mig_start = getstructarray( "mig_base_flyover2", "targetname" );
		a_s_mig_delete = getstructarray( "mig_flyover_delete2", "targetname" );
	}
	while ( 1 )
	{
		s_mig_start = a_s_mig_start[ randomint( a_s_mig_start.size ) ];
		s_mig_delete = a_s_mig_delete[ randomint( a_s_mig_delete.size ) ];
		vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
		vh_mig.origin = s_mig_start.origin;
		vh_mig.angles = s_mig_start.angles;
		vh_mig setforcenocull();
		vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
		target_set( vh_mig, ( -230, 0, -12 ) );
		vh_mig thread mig_flyover_goal( s_mig_delete );
		wait randomfloatrange( 6, 9 );
	}
}

migs_flyover_arena()
{
	level endon( "end_arena_migs" );
	level endon( "horse_charge_finished" );
	flag_wait( "arena_overlook" );
	while ( 1 )
	{
		n_index = randomintrange( 1, 4 );
		a_s_arena_start = getstructarray( "mig_arena_flyover" + n_index, "targetname" );
		a_s_arena_delete = getstructarray( "mig_arena_delete" + n_index, "targetname" );
		s_arena_start = a_s_arena_start[ randomint( a_s_arena_start.size ) ];
		s_arena_delete = a_s_arena_delete[ randomint( a_s_arena_delete.size ) ];
		n_waittime = randomfloatrange( 6, 9 );
		vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
		vh_mig setforcenocull();
		vh_mig.origin = s_arena_start.origin;
		vh_mig.angles = s_arena_start.angles;
		vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
		target_set( vh_mig, ( -230, 0, -12 ) );
		vh_mig thread mig_flyover_goal( s_arena_delete );
		wait n_waittime;
	}
}

mig_flyover_goal( s_goal )
{
	self endon( "death" );
	self setneargoalnotifydist( 300 );
	self setspeedimmediate( 400 );
	self setvehgoalpos( s_goal.origin, 0 );
	self waittill_any_or_timeout( 5, "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

shootat_mig23_flyby()
{
	s_shootat = getstruct( "mig_shootat", "targetname" );
	magicbullet( "stinger_sp", s_shootat.origin + vectorScale( ( 0, 0, -1 ), 80 ), self.origin );
	level thread fire_guns_base();
	wait 2;
	level thread fire_stingers_base();
}

fire_stingers_base()
{
	a_s_stingers_right = getstructarray( "stinger_shootat_right", "targetname" );
	a_s_stingers_left = getstructarray( "stinger_shootat_left", "targetname" );
	a_stinger_structs = arraycombine( a_s_stingers_right, a_s_stingers_left, 0, 0 );
	level thread shoot_stingers( a_stinger_structs );
}

fire_guns_base()
{
	a_s_guns_left = getstructarray( "gun_shootat_left", "targetname" );
	a_s_guns_right = getstructarray( "gun_shootat_right", "targetname" );
	array_thread( a_s_guns_right, ::shoot_guns, 0 );
	array_thread( a_s_guns_left, ::shoot_guns, 1 );
}

shoot_stingers( a_starting_structs )
{
	level endon( "stop_stingers_base" );
	while ( 1 )
	{
		start_struct = random( a_starting_structs );
		if ( cointoss() )
		{
			v_target = ( randomintrange( -100, -50 ), randomintrange( 0, 200 ), randomintrange( 50, 400 ) );
		}
		else
		{
			v_target = ( randomintrange( -100, -50 ), randomintrange( -200, 0 ), randomintrange( 50, 400 ) );
		}
		magicbullet( "stinger_sp", start_struct.origin, start_struct.origin + v_target );
		wait randomfloatrange( 10, 15 );
	}
}

shoot_guns( n_side )
{
	level endon( "stop_guns_base" );
	while ( 1 )
	{
		if ( n_side )
		{
			v_target = ( randomintrange( -100, -50 ), randomintrange( 0, 200 ), randomintrange( 50, 400 ) );
		}
		else
		{
			v_target = ( randomintrange( -100, -50 ), randomintrange( -200, 0 ), randomintrange( 50, 400 ) );
		}
		n_burst = randomintrange( 5, 12 );
		i = 0;
		while ( i < n_burst )
		{
			magicbullet( "ak47_sp", self.origin, self.origin + v_target );
			wait 0,1;
			i++;
		}
		wait randomfloatrange( 5, 10 );
	}
}

tunnel_runner_logic()
{
	self endon( "death" );
	self.deathanim = %death_explosion_run_b_v1;
	self.goalradius = 120;
	self waittill( "goal" );
	s_killer = getstruct( "tunnel_runner_killer", "targetname" );
	playfx( level._effect[ "explode_large_sand" ], s_killer.origin );
	self dodamage( self.health, s_killer.origin );
}

runners_logic()
{
	self endon( "death" );
	self.goalradius = 32;
	self waittill( "goal" );
	self die();
}

corral_jumper_logic()
{
	self endon( "death" );
	self.goalradius = 32;
	self waittill( "goal" );
	self die();
}

rooftop_shooter_logic()
{
	self endon( "death" );
	self allowedstances( "stand" );
	while ( 1 )
	{
		e_target = spawn( "script_model", self.origin + ( randomintrange( -2400, -1200 ), randomintrange( -1200, -300 ), randomintrange( 1200, 1800 ) ) );
		e_target setmodel( "tag_origin" );
		self shoot_at_target( e_target, "tag_origin", randomfloatrange( 6, 8 ) );
		wait randomfloatrange( 4, 6,5 );
		e_target delete();
	}
}

firehorse_mason_logic()
{
	level.mason_horse = self;
	level thread player_horse_fx();
	level thread arena_explosion_fx();
	level thread player_arena_overlook();
	level thread mig_scares_horse();
	level thread watch_tower_collapse();
	level thread visionset_firehorse();
	self makevehicleusable();
	trigger_wait( "tunnel_exit" );
	level thread spawn_ambient_migs();
	wait 2;
	level thread maps/_horse::set_horse_in_combat( 1 );
	level thread firehorse_actual_logic();
	self horse_rearback();
	self horse_panic();
	self ent_flag_wait( "mounting_horse" );
	flag_set( "player_onhorse" );
	end_scene( "e3_map_room_idle" );
	end_scene( "e3_exit_map_room" );
	end_scene( "e3_ride_out" );
	flag_set( "e3_ride_out_done" );
	autosave_by_name( "player_horse" );
	flag_wait( "arena_overlook" );
	delete_section3_scenes();
	level thread spawn_mig_flyby();
	wait 0,8;
	self setbrake( 1 );
	if ( level.player is_on_horseback() )
	{
		level.player disableweapons();
	}
	if ( isDefined( self.being_dismounted ) && !self.being_dismounted )
	{
		self horse_rearback();
	}
	level.player enableweapons();
	maps/createart/afghanistan_art::open_area();
	flag_set( "horse_rearback" );
	wait 1;
	self setbrake( 0 );
}

spawn_mig_flyby()
{
	s_mig_spawnpt = getstruct( "mig_in_face_spawnpt", "targetname" );
	nd_start = getvehiclenode( "mig_flyby_startnode", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig_soviet" );
	vh_mig.origin = s_mig_spawnpt.origin;
	vh_mig.angles = s_mig_spawnpt.angles;
	vh_mig thread mig23_overbase_logic();
	vh_mig thread go_path( nd_start );
}

mig23_overbase_logic()
{
	self endon( "death" );
	self setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	level.player playsound( "evt_mig_flyover" );
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

spawn_ambient_migs()
{
	s_mig_spawnpt = getstruct( "mig23_firehorse_spawnpt", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig_soviet" );
	vh_mig.origin = s_mig_spawnpt.origin;
	vh_mig.angles = s_mig_spawnpt.angles;
	vh_mig thread mig23_flyby_logic();
}

mig23_flyby_logic()
{
	flag_set( "mig_spawned" );
	self setcandamage( 0 );
	self setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	self thread first_mig_bombs();
	s_delete = getstruct( "first_mig_delete", "targetname" );
	self setspeedimmediate( 250 );
	self setneargoalnotifydist( 500 );
	self setvehgoalpos( s_delete.origin, 0 );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
	wait 2;
	level thread migs_flyover_base();
	level thread migs_flyover_arena();
}

visionset_firehorse()
{
	trigger_wait( "trigger_vision_firehorse" );
	maps/createart/afghanistan_art::rebel_entrance();
	vh_chopper = spawn_vehicle_from_targetname( "arena_chopper_crash" );
}

watch_tower_collapse()
{
	trigger_wait( "trigger_tower_collapse" );
	level notify( "fxanim_water_tower_start" );
	wait 0,2;
	a_ai_guys = getentarray( "rooftop_mig_shooter_ai", "targetname" );
	_a1113 = a_ai_guys;
	_k1113 = getFirstArrayKey( _a1113 );
	while ( isDefined( _k1113 ) )
	{
		ai_guy = _a1113[ _k1113 ];
		if ( isalive( ai_guy ) )
		{
			radiusdamage( ai_guy.origin, 64, ai_guy.health, ai_guy.health, undefined, "MOD_EXPLOSIVE" );
		}
		_k1113 = getNextArrayKey( _a1113, _k1113 );
	}
}

player_arena_overlook()
{
	trigger_wait( "player_at_overlook" );
	flag_set( "arena_overlook" );
	level thread remove_maproom_personnel();
	t_chase = getent( "trigger_uaz_chase", "targetname" );
	t_chase trigger_on();
	wait 1;
	flag_set( "arena_chopper_takeoff" );
	run_scene( "chopper_crash_overlooking_arena" );
}

mig_scares_horse()
{
	trigger_wait( "trigger_arena_hip" );
	level thread hip3_arena_land();
}

hip3_guy_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	flag_set( "hip3_troops_spawned" );
}

hip4_guy_logic()
{
	self endon( "death" );
	self.arena_guy = 1;
	flag_set( "hip4_troops_spawned" );
}

player_horse_fx()
{
	a_s_explosion = getstructarray( "explosion_player", "targetname" );
	_a1175 = a_s_explosion;
	_k1175 = getFirstArrayKey( _a1175 );
	while ( isDefined( _k1175 ) )
	{
		s_explosion = _a1175[ _k1175 ];
		s_explosion thread player_explosion_fx();
		_k1175 = getNextArrayKey( _a1175, _k1175 );
	}
}

player_explosion_fx()
{
	while ( distance2dsquared( level.player.origin, self.origin ) > 490000 )
	{
		wait 0,05;
	}
	playsoundatposition( "prj_mortar_incoming", self.origin );
	wait 0,5;
	playsoundatposition( "exp_small_scripted", self.origin );
	playfx( level._effect[ "explode_grenade_sand" ], self.origin );
	earthquake( 0,2, 1, level.player.origin, 100 );
}

arena_explosion_fx()
{
	level endon( "stop_arena_explosions" );
	flag_wait( "arena_overlook" );
	a_s_explosion = getstructarray( "arena_explosion_far", "targetname" );
	num = a_s_explosion.size;
	while ( 1 )
	{
		array_choice = randomint( num );
		playfx( level._effect[ "explode_mortar_sand" ], a_s_explosion[ array_choice ].origin );
		playsoundatposition( "exp_mortar", a_s_explosion[ array_choice ].origin );
		earthquake( 0,2, 1, level.player.origin, 100 );
		wait randomfloatrange( 2,5, 4 );
	}
}

stop_arena_explosions()
{
	trigger_wait( "stop_arena_explosions" );
	flag_set( "stop_arena_explosions" );
}

firehorse_zhao_logic()
{
	s_zhao_base = getstruct( "zhao_base_entrance", "targetname" );
	s_zhao_bp1 = getstruct( "zhao_bp1_goal", "targetname" );
	nd_zhao_horse = getnode( "node_firehorse_zhao", "targetname" );
	level.zhao = getent( "zhao_ai", "targetname" );
	self makevehicleunusable();
	self setneargoalnotifydist( 100 );
	self setvehicleavoidance( 0 );
	self veh_magic_bullet_shield( 1 );
	level.zhao setcandamage( 0 );
	level thread objectives_firehorse();
	flag_wait( "playerat_exit" );
	level.zhao.fixednode = 0;
	flag_wait( "e3_ride_out_done" );
	self ent_flag_clear( "playing_scripted_anim" );
	wait 0,05;
	level.zhao enter_vehicle( self );
	wait 0,05;
	self notify( "groupedanimevent" );
	level.zhao maps/_horse_rider::ride_and_shoot( self );
	wait 0,05;
	self setspeed( 25, 5, 2 );
	self setvehgoalpos( s_zhao_base.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self horse_stop();
	self thread horse_panic();
	flag_wait( "arena_overlook" );
	level thread spawn_arena_uaz();
	wait 2,5;
	self setbrake( 0 );
	self setspeed( 25, 5, 2 );
	self setvehgoalpos( s_zhao_bp1.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self setspeedimmediate( 0 );
	flag_set( "zhao_at_bp1" );
}

firehorse_actual_logic()
{
	wait 1;
	level thread run_scene_and_delete( "fire_horse" );
	wait 0,1;
	v_firehorse = get_model_or_models_from_scene( "fire_horse" )[ 0 ];
	v_firehorse thread flaming_horse_logic();
}

firehorse_woods_logic()
{
	s_exit = getstruct( "woods_base_entrance", "targetname" );
	s_bp1_goal = getstruct( "woods_bp1_goal", "targetname" );
	self makevehicleunusable();
	self setneargoalnotifydist( 200 );
	self setvehicleavoidance( 0 );
	self veh_magic_bullet_shield( 1 );
	flag_wait( "playerat_exit" );
	level.woods = getent( "woods_ai", "targetname" );
	level.woods setcandamage( 0 );
	flag_wait( "e3_ride_out_done" );
	self ent_flag_clear( "playing_scripted_anim" );
	wait 0,05;
	level.woods enter_vehicle( self );
	wait 0,05;
	self notify( "groupedanimevent" );
	level.woods maps/_horse_rider::ride_and_shoot( self );
	wait 0,05;
	self setspeed( 25, 20, 10 );
	self setvehgoalpos( s_exit.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self horse_stop();
	self thread horse_panic();
	level.woods setcandamage( 0 );
	flag_wait( "arena_overlook" );
	wait 3;
	self setbrake( 0 );
	self setvehgoalpos( s_bp1_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self setspeedimmediate( 0 );
	flag_set( "woods_at_bp1" );
	level.woods setcandamage( 0 );
}

hip_arena_takeoff_logic()
{
	self veh_magic_bullet_shield( 1 );
	wait 0,1;
	m_blades = getent( "fxanim_chopper_crash_blades", "targetname" );
	m_blades hide();
	m_blades moveto( self.origin, 0,1 );
	m_blades waittill( "movedone" );
	m_blades linkto( self, "tag_origin" );
	flag_wait( "arena_overlook" );
	self thread stinger_hit_chopper();
}

spawn_arena_uaz()
{
	level notify( "stop_base_exp" );
	level notify( "end_base_migs" );
	level thread mig23_arena_strafe();
	spawn_manager_enable( "manager_first_arena" );
	level thread kill_manager_first_arena_on_flag();
	level thread spawn_uaz1_arena();
	wait 1;
	level thread spawn_uaz2_arena();
	flag_set( "firehorse_done" );
}

kill_manager_first_arena_on_flag()
{
	flag_wait( "wave1_started" );
	spawn_manager_kill( "manager_first_arena" );
}

spawn_uaz1_arena()
{
	s_uaz1_spawnpt = getstruct( "arena_uaz1_spawnpt", "targetname" );
	vh_uaz = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz.origin = s_uaz1_spawnpt.origin;
	vh_uaz.angles = s_uaz1_spawnpt.angles;
	vh_uaz.targetname = "uaz_tank_target";
	sp_soviet = getent( "soviet_assault", "targetname" );
	ai_soviet1 = sp_soviet spawn_ai( 1 );
	ai_soviet1 enter_vehicle( vh_uaz );
	wait 0,1;
	ai_soviet2 = sp_soviet spawn_ai( 1 );
	ai_soviet2 enter_vehicle( vh_uaz );
	vh_uaz thread uaz1_arena_logic();
	flag_set( "uaz_spawned" );
}

uaz1_arena_logic()
{
	self endon( "death" );
	self thread delete_corpse_arena();
	self thread brake_on_death();
	self.overridevehicledamage = ::sticky_grenade_damage;
	s_entry = getstruct( "uaz1_entry", "targetname" );
	s_goal = getstruct( "arena_goal_01", "targetname" );
	self veh_magic_bullet_shield( 1 );
	self setneargoalnotifydist( 200 );
	self setspeed( 25, 15, 12 );
	self setvehgoalpos( s_entry.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self notify( "unload" );
}

stinger_hits_uaz()
{
	self endon( "death" );
	self veh_magic_bullet_shield( 1 );
	s_stinger = getstruct( "uaz_stinger", "targetname" );
	e_missile = magicbullet( "stinger_sp", s_stinger.origin, self.origin, undefined, self, vectorScale( ( 0, 0, -1 ), 32 ) );
	e_missile waittill( "death" );
	self launchvehicle( vectorScale( ( 0, 0, -1 ), 100 ), anglesToRight( self.angles ) * -180, 1, 1 );
	self veh_magic_bullet_shield( 0 );
	wait 1;
	radiusdamage( self.origin, 200, self.health, self.health, undefined, "MOD_PROJECTILE" );
}

muj_tank_exit()
{
	s_spawnpt = getstruct( "afghan_tank_spawnpt", "targetname" );
	level.muj_tank = spawn_vehicle_from_targetname( "tank_soviet" );
	level.muj_tank.origin = s_spawnpt.origin;
	level.muj_tank.angles = s_spawnpt.angles;
	s_goal0 = getstruct( "muj_tank_wait", "targetname" );
	s_goal1 = getstruct( "muj_tank_pos", "targetname" );
	s_goal2 = getstruct( "muj_tank_move", "targetname" );
	level.muj_tank setvehicleavoidance( 1 );
	level.muj_tank setneargoalnotifydist( 200 );
	level.muj_tank setspeed( 20, 15, 10 );
	level.muj_tank setvehgoalpos( s_goal0.origin, 0, 1 );
	level.muj_tank waittill_any( "near_goal", "goal" );
	flag_wait( "player_riding_out" );
	level.muj_tank setvehgoalpos( s_goal1.origin, 0, 1 );
	level.muj_tank waittill_any( "near_goal", "goal" );
	level.muj_tank setbrake( 1 );
	flag_wait( "uaz_spawned" );
	vh_uaz = getent( "uaz_tank_target", "targetname" );
	level.muj_tank settargetentity( vh_uaz );
	level.muj_tank waittill( "turret_on_target" );
	level.muj_tank fireweapon();
	level thread mig_destroy_tank();
	vh_uaz launchvehicle( vectorScale( ( 0, 0, -1 ), 100 ), anglesToRight( vh_uaz.angles ) * -180, 1, 1 );
	vh_uaz veh_magic_bullet_shield( 0 );
	wait 1;
	radiusdamage( vh_uaz.origin, 200, vh_uaz.health, vh_uaz.health, undefined, "MOD_PROJECTILE" );
}

mig_destroy_tank()
{
	s_spawnpt = getstruct( "mig_tank_destroy_spawnpt", "targetname" );
	s_goal1 = getstruct( "mig_tank_destroy_goal1", "targetname" );
	s_goal2 = getstruct( "mig_tank_destroy_goal2", "targetname" );
	vh_mig = spawn_vehicle_from_targetname( "mig23_spawner" );
	vh_mig setforcenocull();
	vh_mig.origin = s_spawnpt.origin;
	vh_mig.angles = s_spawnpt.angles;
	vh_mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	vh_mig setneargoalnotifydist( 500 );
	vh_mig setspeed( 300, 150, 100 );
	vh_mig thread launch_missile_muj_tank();
	vh_mig setvehgoalpos( s_goal1.origin, 0 );
	vh_mig waittill_any( "goal", "near_goal" );
	vh_mig setvehgoalpos( s_goal2.origin, 0 );
	vh_mig waittill_any( "goal", "near_goal" );
	vh_mig.delete_on_death = 1;
	vh_mig notify( "death" );
	if ( !isalive( vh_mig ) )
	{
		vh_mig delete();
	}
}

launch_missile_muj_tank()
{
	e_missile = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_left" ), level.muj_tank.origin, self, level.muj_tank );
	e_missile = magicbullet( "stinger_sp", self gettagorigin( "tag_missle_right" ), level.muj_tank.origin, self, level.muj_tank );
	e_missile waittill( "death" );
	radiusdamage( level.muj_tank.origin, 200, level.muj_tank.health, level.muj_tank.health, undefined, "MOD_PROJECTILE" );
	wait 0,3;
	level.muj_tank.delete_on_death = 1;
	level.muj_tank notify( "death" );
	if ( !isalive( level.muj_tank ) )
	{
		level.muj_tank delete();
	}
	level.tank_dest show();
	level.tank_dest solid();
	level.tank_dest disconnectpaths();
}

spawn_uaz2_arena()
{
	s_uaz2_spawnpt = getstruct( "arena_uaz2_spawnpt", "targetname" );
	vh_uaz = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz.origin = s_uaz2_spawnpt.origin;
	vh_uaz.angles = s_uaz2_spawnpt.angles;
	sp_soviet = getent( "soviet_assault", "targetname" );
	ai_soviet1 = sp_soviet spawn_ai( 1 );
	ai_soviet1 enter_vehicle( vh_uaz );
	wait 0,1;
	ai_soviet2 = sp_soviet spawn_ai( 1 );
	ai_soviet2 enter_vehicle( vh_uaz );
	vh_uaz thread uaz2_arena_logic();
	trigger_wait( "trigger_firehorse_cache_guard" );
	level thread spawn_uaz3_arena();
}

uaz2_arena_logic()
{
	self endon( "death" );
	self thread delete_corpse_arena();
	self.overridevehicledamage = ::sticky_grenade_damage;
	s_goal3 = getstruct( "uaz2_goal_03", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 20, 10, 5 );
	self setvehgoalpos( s_goal3.origin, 1 );
	flag_wait( "chopper_blow_up" );
	self thread launch_arena_uaz();
}

spawn_uaz3_arena()
{
	s_uaz3_spawnpt = getstruct( "arena_uaz3_spawnpt", "targetname" );
	vh_uaz = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz.origin = s_uaz3_spawnpt.origin;
	vh_uaz.angles = s_uaz3_spawnpt.angles;
	sp_soviet = getent( "soviet_assault", "targetname" );
	ai_soviet1 = sp_soviet spawn_ai( 1 );
	ai_soviet1 enter_vehicle( vh_uaz );
	ai_soviet1 thread arena_guy_logic();
	wait 0,1;
	ai_soviet2 = sp_soviet spawn_ai( 1 );
	ai_soviet2 enter_vehicle( vh_uaz );
	ai_soviet2 thread arena_guy_logic();
	vh_uaz thread uaz3_arena_logic();
}

uaz3_arena_logic()
{
	self endon( "death" );
	self thread delete_corpse_arena();
	self.overridevehicledamage = ::sticky_grenade_damage;
	s_goal = getstruct( "uaz3_goal", "targetname" );
	self setneargoalnotifydist( 100 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_goal.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self notify( "unload" );
}

brake_on_death()
{
	self waittill( "death" );
	self setbrake( 1 );
}

launch_arena_uaz()
{
	self endon( "death" );
	self launchvehicle( vectorScale( ( 0, 0, -1 ), 200 ), anglesToRight( self.angles ) * 180, 1, 1 );
	self setbrake( 1 );
	wait 1;
	radiusdamage( self.origin, 100, self.health, self.health );
}

uaz_rpg_launch()
{
	wait 1;
	self launchvehicle( vectorScale( ( 0, 0, -1 ), 270 ), ( 0, 20, 20 ), 1 );
	wait 0,5;
	radiusdamage( self.origin, 100, 5000, 5000 );
}

hip2_arena_land()
{
	s_hip2 = getstruct( "arena_hip2_spawn", "targetname" );
	s_hip2_start = getstruct( "arena_hip2_start", "targetname" );
	s_hip2_mid = getstruct( "arena_hip2_mid", "targetname" );
	s_hip2_dest = getstruct( "arena_hip2_destroy", "targetname" );
	self setneargoalnotifydist( 200 );
	self setspeed( 100, 25, 10 );
	self setvehgoalpos( s_hip2_start.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip2_mid.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 20, 18, 15 );
	self setvehgoalpos( s_hip2_dest.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	radiusdamage( self.origin, 100, 5000, 5000 );
}

hip3_arena_land()
{
	s_hip3 = getstruct( "arena_hip3", "targetname" );
	s_hip3_start = getstruct( "arena_hip3_start", "targetname" );
	s_hip3_mid = getstruct( "arena_hip3_mid", "targetname" );
	s_hip3_land = getstruct( "arena_hip3_land", "targetname" );
	s_hip3_takeoff = getstruct( "arena_hip3_takeoff", "targetname" );
	s_hip3_air = getstruct( "arena_hip3_air", "targetname" );
	s_hip3_far = getstruct( "arena_hip3_far", "targetname" );
	s_hip3_end = getstruct( "arena_hip3_end", "targetname" );
	vh_hip3 = spawn_vehicle_from_targetname( "hip_soviet_land" );
	vh_hip3.origin = s_hip3.origin;
	vh_hip3.angles = s_hip3.angles;
	vh_hip3 endon( "death" );
	vh_hip3 thread heli_select_death();
	target_set( vh_hip3, ( -50, 0, -32 ) );
	vh_hip3 setneargoalnotifydist( 200 );
	vh_hip3 setspeed( 120, 25, 10 );
	vh_hip3 setvehgoalpos( s_hip3_start.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3 setvehgoalpos( s_hip3_mid.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3 sethoverparams( 0, 0, 10 );
	vh_hip3 setvehgoalpos( s_hip3_land.origin, 1 );
	vh_hip3 waittill_any( "goal", "near_goal" );
	wait 1;
	level thread manage_hip3_troops_spawn();
	flag_wait_or_timeout( "arena_hip_takeoff", 5 );
	vh_hip3 playsound( "evt_heli_take_off" );
	vh_hip3 setspeed( 25, 10, 5 );
	vh_hip3 setforcenocull();
	vh_hip3 setvehgoalpos( s_hip3_takeoff.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3 setspeed( 150, 25, 15 );
	vh_hip3 setvehgoalpos( s_hip3_air.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3 thread hip3_countermeasures();
	vh_hip3 setspeed( 350, 35, 25 );
	vh_hip3 setvehgoalpos( s_hip3_far.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3 setvehgoalpos( s_hip3_end.origin );
	vh_hip3 waittill_any( "goal", "near_goal" );
	vh_hip3.delete_on_death = 1;
	vh_hip3 notify( "death" );
	if ( !isalive( vh_hip3 ) )
	{
		vh_hip3 delete();
	}
	flag_set( "monitor_hip3" );
}

manage_hip3_troops_spawn()
{
	if ( !flag( "wave1_started" ) )
	{
		spawn_manager_enable( "manager_hip3_troops" );
		wait 2;
		spawn_manager_disable( "manager_hip3_troops" );
	}
}

hip3_replenish()
{
	s_hip3_spawn = getstruct( "hip3_factory", "targetname" );
	vh_hip3 = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip3.origin = s_hip3_spawn.origin;
	vh_hip3.angles = s_hip3_spawn.angles;
	vh_hip3 thread hip3_behavior();
}

hip3_behavior()
{
	self endon( "death" );
	s_hip3_takeoff = getstruct( "hip3_takeoff", "targetname" );
	s_hip3_air = getstruct( "hip3_air", "targetname" );
	s_hip3_app = getstruct( "hip3_approach", "targetname" );
	s_hip3_land = getstruct( "hip3_land", "targetname" );
	self thread monitor_hip3();
	self thread delete_corpse_arena();
	target_set( self, ( -50, 0, -32 ) );
	self hidepart( "tag_back_door" );
	flag_set( "hip3_spawned" );
	self setneargoalnotifydist( 200 );
	self setspeed( 100, 25, 10 );
	self setvehgoalpos( s_hip3_takeoff.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 150, 25, 10 );
	self setvehgoalpos( s_hip3_air.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 100, 25, 20 );
	self setvehgoalpos( s_hip3_app.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 20, 18, 15 );
	self setvehgoalpos( s_hip3_land.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self setspeedimmediate( 0 );
	wait 1;
	if ( !flag( "sm_manager_hip3_troops_enabled" ) && !flag( "wave1_started" ) )
	{
		spawn_manager_enable( "manager_hip3_troops" );
	}
	wait 3;
	spawn_manager_disable( "manager_hip3_troops" );
	self thread hip3_leave_arena();
}

hip3_leave_arena()
{
	self endon( "death" );
	s_hip3_takeoff = getstruct( "arena_hip3_takeoff", "targetname" );
	s_hip3_air = getstruct( "arena_hip3_air", "targetname" );
	s_hip3_far = getstruct( "arena_hip3_far", "targetname" );
	s_hip3_end = getstruct( "arena_hip3_end", "targetname" );
	self setspeed( 25, 10, 5 );
	self setvehgoalpos( s_hip3_takeoff.origin );
	self waittill_any( "goal", "near_goal" );
	self thread hip3_countermeasures();
	self setspeed( 150, 25, 15 );
	self setvehgoalpos( s_hip3_air.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 350, 35, 25 );
	self setvehgoalpos( s_hip3_far.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip3_end.origin );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip3_countermeasures()
{
	self endon( "death" );
	s_rpg = getstruct( "rpg_fireat_hip1", "targetname" );
	magicbullet( "stinger_sp", s_rpg.origin, self.origin );
	wait 1;
	i = 0;
	while ( i < 5 )
	{
		playfx( level._effect[ "aircraft_flares" ], self.origin + vectorScale( ( 0, 0, -1 ), 120 ) );
		wait 0,25;
		i++;
	}
}

hip4_replenish()
{
	s_hip_spawn = getstruct( "hip4_factory", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_hip_spawn.origin;
	vh_hip.angles = s_hip_spawn.angles;
	vh_hip hip4_behavior();
}

hip4_behavior()
{
	self endon( "death" );
	s_hip_liftoff = getstruct( "hip4_liftoff", "targetname" );
	s_hip_air = getstruct( "hip4_air", "targetname" );
	s_hip_mid = getstruct( "hip4_mid", "targetname" );
	s_hip_approach = getstruct( "hip4_approach", "targetname" );
	s_hip_descent = getstruct( "hip4_descent", "targetname" );
	s_hip_hover = getstruct( "hip4_hover", "targetname" );
	self thread monitor_hip4();
	self thread heli_select_death();
	self thread delete_corpse_arena();
	target_set( self, ( -50, 0, -32 ) );
	self hidepart( "tag_back_door" );
	flag_set( "hip4_spawned" );
	self endon( "death" );
	self setneargoalnotifydist( 200 );
	self setspeed( 100, 25, 10 );
	self setvehgoalpos( s_hip_liftoff.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip_air.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip_mid.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 40, 30, 25 );
	self setvehgoalpos( s_hip_approach.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip_descent.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	sp_rappel = getent( "hip4_troops", "targetname" );
	ambient_rappel( sp_rappel, "hip4_hover" );
	self thread hip4_leave_arena();
}

hip4_leave_arena()
{
	self endon( "death" );
	s_hip_dustoff = getstruct( "hip4_dustoff", "targetname" );
	s_hip_bank = getstruct( "hip4_bank", "targetname" );
	s_hip_away = getstruct( "hip4_away", "targetname" );
	s_hip_turn = getstruct( "hip4_turn", "targetname" );
	s_hip_over = getstruct( "hip4_over", "targetname" );
	s_hip_dive = getstruct( "hip4_dive", "targetname" );
	self setspeed( 25, 10, 5 );
	self setvehgoalpos( s_hip_dustoff.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 150, 25, 15 );
	self setvehgoalpos( s_hip_bank.origin );
	self waittill_any( "goal", "near_goal" );
	self thread hip4_countermeasures();
	self setvehgoalpos( s_hip_away.origin );
	self waittill_any( "goal", "near_goal" );
	self setspeed( 350, 35, 25 );
	self setvehgoalpos( s_hip_turn.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip_over.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_hip_dive.origin );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

hip4_countermeasures()
{
	i = 0;
	while ( i < 5 )
	{
		playfx( level._effect[ "aircraft_flares" ], self.origin + vectorScale( ( 0, 0, -1 ), 120 ) );
		wait 0,25;
		i++;
	}
}

explosion_base()
{
	level thread explosion_cave_ambient();
	trigger_wait( "trigger_explosion_base01" );
	level thread spawn_base_personnel();
	flag_set( "playerat_exit" );
	s_explosion01 = getstruct( "explosion_base01", "targetname" );
	playfx( level._effect[ "explode_mortar_sand" ], s_explosion01.origin );
	playsoundatposition( "exp_mortar", s_explosion01.origin );
	earthquake( 0,2, 2,5, level.player.origin, 100 );
	wait 1;
	level thread explosion_baseclose_manager();
	level thread explosion_basefar_manager();
}

spawn_base_personnel()
{
	trigger_wait( "tunnel_exit" );
	wait 3;
	spawn_manager_enable( "manager_muj_entrance" );
	wait 3;
	waittill_spawn_manager_ai_remaining( "manager_muj_entrance", 3 );
	if ( !flag( "firehorse_done" ) )
	{
		spawn_manager_enable( "manager_troops_exit" );
	}
}

spawn_base_horses()
{
	a_vh_base_horses = [];
	a_s_spawnpts = getstructarray( "base_horse_spawnpt", "targetname" );
	sp_rider = getent( "muj_assault", "targetname" );
	i = 0;
	while ( i < a_s_spawnpts.size )
	{
		a_vh_base_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		a_vh_base_horses[ i ].origin = a_s_spawnpts[ i ].origin;
		a_vh_base_horses[ i ].angles = a_s_spawnpts[ i ].angles;
		a_vh_base_horses[ i ].rider = sp_rider spawn_ai( 1 );
		ride_horse( a_vh_base_horses[ i ].rider, a_vh_base_horses[ i ] );
		a_vh_base_horses[ i ] thread muj_horse_logic();
		wait 0,5;
		i++;
	}
}

muj_horse_logic()
{
	self endon( "death" );
	self thread horse_remove();
	self makevehicleunusable();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	s_goal = getstruct( "base_horse_goal1", "targetname" );
	self setspeed( 25, 15, 10 );
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		if ( flag( "wave1_started" ) )
		{
			playfx( level._effect[ "explode_large_sand" ], self.origin );
			radiusdamage( self.origin, 64, 5000, 4000, undefined, "MOD_PROJECTILE" );
		}
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

remove_maproom_personnel()
{
	ai_hudson = getent( "hudson_ai", "targetname" );
	ai_rebel_leader = getent( "rebel_leader_ai", "targetname" );
	if ( isDefined( ai_hudson ) )
	{
		ai_hudson delete();
	}
	if ( isDefined( ai_rebel_leader ) )
	{
		ai_rebel_leader delete();
	}
}

explosion_cave_ambient()
{
	level endon( "playerat_exit" );
	rpc( "clientscripts/afghanistan_amb", "sndPlayYellingVox" );
	while ( 1 )
	{
		playsoundatposition( "prj_mortar_launch_indoor", ( -3127, -36443, 3469 ) );
		wait 1;
		level.player playsound( "evt_mortar_incoming_indoor" );
		wait 1,25;
		earthquake( randomfloatrange( 0,2, 0,5 ), randomfloatrange( 0,5, 2 ), level.player.origin, 100 );
		level.player playsound( "evt_mortar_explosion_indoor" );
		exploder( 150 );
		level thread shake_base_lights();
		wait randomfloatrange( 2, 4,5 );
	}
}

explosion_baseclose_manager()
{
	level endon( "stop_base_exp" );
	a_s_explosion = getstructarray( "explosion_close_base", "targetname" );
	while ( 1 )
	{
		_a2230 = a_s_explosion;
		_k2230 = getFirstArrayKey( _a2230 );
		while ( isDefined( _k2230 ) )
		{
			s_explosion = _a2230[ _k2230 ];
			playsoundatposition( "prj_mortar_launch", ( -3127, -36443, 3469 ) );
			wait 1,5;
			playsoundatposition( "prj_mortar_incoming", s_explosion.origin );
			wait 0,45;
			playsoundatposition( "exp_mortar", s_explosion.origin );
			playfx( level._effect[ "explode_grenade_sand" ], s_explosion.origin );
			earthquake( 0,2, 1, level.player.origin, 100 );
			wait randomfloatrange( 1,5, 3 );
			_k2230 = getNextArrayKey( _a2230, _k2230 );
		}
	}
}

explosion_basefar_manager()
{
	level endon( "stop_base_exp" );
	a_s_explosion = getstructarray( "explosion_far_base", "targetname" );
	while ( 1 )
	{
		_a2258 = a_s_explosion;
		_k2258 = getFirstArrayKey( _a2258 );
		while ( isDefined( _k2258 ) )
		{
			s_explosion = _a2258[ _k2258 ];
			playsoundatposition( "prj_mortar_launch", ( -3127, -36443, 3469 ) );
			wait 1;
			playsoundatposition( "prj_mortar_incoming", s_explosion.origin );
			wait 0,45;
			playsoundatposition( "exp_mortar", s_explosion.origin );
			playfx( level._effect[ "explode_mortar_sand" ], s_explosion.origin );
			earthquake( 0,1, 1, level.player.origin, 100 );
			wait randomfloatrange( 1,5, 3 );
			_k2258 = getNextArrayKey( _a2258, _k2258 );
		}
	}
}

ambience_manager()
{
	flag_wait( "monitor_hip3" );
	level thread hip3_arena_manager();
	wait 5;
	level thread hip4_arena_manager();
}

hip3_arena_manager()
{
	level endon( "stop_arena_explosions" );
	while ( 1 )
	{
		while ( flag( "hip3_spawned" ) )
		{
			wait 1;
		}
		while ( 1 )
		{
			a_ai_guys = getentarray( "hip3_troops_ai", "targetname" );
			if ( a_ai_guys.size < 3 )
			{
				break;
			}
			else
			{
				wait 1;
			}
		}
		if ( flag( "stop_arena_explosions" ) )
		{
			return;
		}
		else
		{
			level thread hip3_replenish();
			wait 1;
		}
	}
}

monitor_hip3()
{
	self waittill( "death" );
	wait randomintrange( 1, 4 );
	flag_clear( "hip3_spawned" );
}

hip4_arena_manager()
{
	level endon( "stop_arena_explosions" );
	while ( 1 )
	{
		while ( flag( "hip4_spawned" ) )
		{
			wait 1;
		}
		while ( 1 )
		{
			a_ai_guys = getentarray( "hip4_troops_ai", "targetname" );
			if ( a_ai_guys.size < 3 )
			{
				break;
			}
			else
			{
				wait 1;
			}
		}
		if ( flag( "stop_arena_explosions" ) )
		{
			return;
		}
		else
		{
			level thread hip4_replenish();
			wait 1;
		}
	}
}

monitor_hip4()
{
	self waittill( "death" );
	wait randomintrange( 1, 4 );
	flag_clear( "hip4_spawned" );
}
