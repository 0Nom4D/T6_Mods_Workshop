#include maps/afghanistan_firehorse;
#include maps/_audio;
#include maps/_horse_rider;
#include maps/createart/afghanistan_art;
#include maps/afghanistan_anim;
#include maps/_fxanim;
#include maps/_music;
#include maps/_turret;
#include maps/_dialog;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );
#using_animtree( "vehicles" );
#using_animtree( "player" );

init_flags()
{
	flag_init( "horse_charge_finished" );
	flag_init( "player_pushed_off_horse" );
	flag_init( "kravchenko_time_scale_punch" );
	flag_init( "start_kravchenko_tank_earthquake" );
}

init_spawn_funcs()
{
	sp_rider_spawner = getent( "extra_rider", "targetname" );
	sp_rider_spawner add_spawn_function( ::set_horse_anim );
}

skipto_horse_charge()
{
	skipto_setup();
	level.woods = init_hero( "woods" );
	level.zhao = init_hero( "zhao" );
	level.skip_to_charge_used = 1;
	delete_section1_scenes();
	delete_section1_ride_scenes();
	delete_section_2_scenes();
	struct_cleanup_wave1();
	struct_cleanup_wave2();
	skipto_teleport( "skipto_horse_charge", level.heroes );
	remove_woods_facemask_util();
	flag_wait( "afghanistan_gump_arena" );
	exploder( 300 );
}

skipto_krav_tank()
{
	skipto_setup();
	level.woods = init_hero( "woods" );
	skipto_cleanup();
	level.player thread lerp_fov_overtime( 0,05, getDvarFloat( "cg_fov_default" ) );
	maps/afghanistan_anim::init_afghan_anims_part2();
	skipto_teleport( "skipto_horse_charge", level.heroes );
	remove_woods_facemask_util();
	flag_wait( "afghanistan_gump_arena" );
}

skipto_cleanup()
{
	delete_scene( "intruder" );
	delete_scene( "intruder_box_and_mine" );
	delete_scene( "lockbreaker" );
	delete_scene( "e1_s1_pulwar" );
	delete_scene( "e1_s1_pulwar_single" );
	delete_scene( "e1_player_wood_greeting" );
	delete_scene( "e1_zhao_horse_charge_player" );
	delete_scene( "e1_zhao_horse_charge" );
	delete_scene( "e1_horse_charge_muj1_endloop" );
	delete_scene( "e1_horse_charge_muj2_endloop" );
	delete_scene( "e1_horse_charge_muj3_endloop" );
	delete_scene( "e1_horse_charge_muj4_endloop" );
	delete_scene( "e1_zhao_horse_charge_woods" );
}

main()
{
	screen_fade_out( 1 );
	setmusicstate( "AFGHAN_END" );
	level notify( "base_secure" );
	if ( isDefined( level.mason_horse ) && level.player is_on_horseback() )
	{
		level.mason_horse useby( level.player );
		wait 0,05;
		if ( isDefined( level.mason_horse.driver ) && isDefined( level.mason_horse.driver.body ) )
		{
			level.mason_horse.driver.body hide();
		}
		level.mason_horse.delete_on_death = 1;
		level.mason_horse notify( "death" );
		if ( !isalive( level.mason_horse ) )
		{
			level.mason_horse delete();
		}
	}
	else
	{
		if ( isDefined( level.player.viewlockedentity ) )
		{
			level.player.viewlockedentity useby( level.player );
			wait 0,05;
			level.player.viewlockedentity.delete_on_death = 1;
			level.player.viewlockedentity notify( "death" );
			if ( !isalive( level.player.viewlockedentity ) )
			{
				level.player.viewlockedentity delete();
			}
		}
	}
	level thread maps/createart/afghanistan_art::turn_down_fog();
	maps/createart/afghanistan_art::open_area();
	level thread old_man_woods( "afghanistan_int_1" );
	level.player thread magic_bullet_shield();
	level thread struct_cleanup_wave3();
	level thread struct_cleanup_blocking_done();
	wait 0,25;
	clean_up_tower_defense_section();
	level thread cleanup_fxanims();
	level thread cleanup_tank_mines();
	autosave_by_name( "horse_charge" );
	flag_waitopen( "old_man_woods_talking" );
	maps/afghanistan_anim::init_afghan_anims_part2();
	level thread screen_fade_in( 4 );
	full_playthrough_set_up_charge();
}

cleanup_tank_mines()
{
	a_grenades = getentarray( "grenade", "classname" );
	i = a_grenades.size - 1;
	while ( i >= 0 )
	{
		if ( isDefined( a_grenades[ i ].name ) && a_grenades[ i ].name == "tc6_mine_sp" )
		{
			a_grenades[ i ] delete();
		}
		i--;

	}
}

cleanup_fxanims()
{
	wait 0,5;
	fxanim_delete( "afghan_fxanims" );
	a_targetnames = array( "pristine_bridge01_break", "pristine_bridge02_break", "pristine_bridge01_long_break", "pristine_bridge02_long_break" );
	_a193 = a_targetnames;
	_k193 = getFirstArrayKey( _a193 );
	while ( isDefined( _k193 ) )
	{
		targetname = _a193[ _k193 ];
		ent = getent( targetname, "targetname" );
		if ( isDefined( ent ) )
		{
			ent delete();
		}
		_k193 = getNextArrayKey( _a193, _k193 );
	}
	stop_exploder( 300 );
}

clean_up_tower_defense_section()
{
	flag_set( "stop_arena_explosions" );
	a_str_sms = array( "sm_muj_wall_1", "sm_muj_wall_2", "sm_muj_wall_3", "sm_muj_wall_4", "manager_rooftop_shooters", "manager_first_arena", "manager_hip3_troops", "manager_hip4_troops", "manager_muj_entrance", "manager_troops_exit", "manager_bp2_soviet", "manager_bp2_rpg", "manager_reinforce_bp2", "manager_bp3_exit_muj", "manager_bp3_exit_soviet", "manager_bp3wave2_soviet", "manager_bp3_foot", "manager_upper_bridge", "manager_assaultcrew_bp3", "manager_assault_soviet", "manager_areana_fight", "manager_bp1wave4_hip1_rappel", "manager_bp2wave4_hip1_rappel", "manager_bp3wave4_hip1_rappel", "manager_bp2_rpg", "manager_bp2_soviet" );
	i = 0;
	while ( i < a_str_sms.size )
	{
		spawn_manager_kill( a_str_sms[ i ], 1 );
		i++;
	}
	if ( isDefined( level.horse_zhao ) && isDefined( level.horse_zhao.rider ) )
	{
		level.zhao ai_ride_stop_riding();
		level.horse_zhao delete();
	}
	level.player get_player_off_horse();
	ai_array = getaiarray();
	n_ai = ai_array.size;
	i = 0;
	while ( i < n_ai )
	{
		if ( !ai_array[ i ] is_hero() )
		{
			ai_array[ i ] delete();
		}
		i++;
	}
	a_vh_cleanup = getvehiclearray();
	_a245 = a_vh_cleanup;
	_k245 = getFirstArrayKey( _a245 );
	while ( isDefined( _k245 ) )
	{
		vh_cleanup = _a245[ _k245 ];
		vh_cleanup.delete_on_death = 1;
		vh_cleanup notify( "death" );
		if ( !isalive( vh_cleanup ) )
		{
			vh_cleanup delete();
		}
		_k245 = getNextArrayKey( _a245, _k245 );
	}
	corpses = getentarray( "script_vehicle_corpse", "classname" );
	array_delete( corpses );
}

get_player_off_horse()
{
	if ( isDefined( self.viewlockedentity ) )
	{
		horse = self.viewlockedentity;
		level clientnotify( "cease_aiming" );
		wait 0,1;
		horse.disable_mount_anim = 1;
		horse maps/_horse::use_horse( self );
		horse waittill( "no_driver" );
		horse makevehicleunusable();
		horse.delete_on_death = 1;
		horse notify( "death" );
		if ( !isalive( horse ) )
		{
			horse delete();
		}
	}
}

delete_player_horse()
{
	wait 0,25;
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

full_playthrough_set_up_charge()
{
	level thread spawn_horse_charge();
	wait 0,05;
	horse_charge_event();
}

set_horse_anim()
{
	self endon( "charge_done" );
	self endon( "death" );
	self.ignoreme = 1;
	while ( 1 )
	{
		self waittill( "enter_vehicle", vehicle );
		vehicle notify( "groupedanimevent" );
		if ( self != level.woods )
		{
			vehicle thread delete_dead_horse_after_charge();
		}
		self notify( "ride" );
		self maps/_horse_rider::ride_and_shoot( vehicle );
	}
}

horse_charge_line_up_event()
{
	level.player freezecontrols( 0 );
	level.player enableinvulnerability();
	level.player takeallweapons();
	level thread maps/_audio::switch_music_wait( "AFGHAN_BINOCULARS", 0,5 );
	level notify( "base_secure" );
	self endon( "charge_done" );
	exploder( 700 );
	level thread run_scene( "e4_s1_return_base_lineup" );
	level thread horse_fidget_sounds();
	body = get_model_or_models_from_scene( "e4_s1_return_base_lineup", "player_body" );
	body attach( "viewmodel_binoculars", "tag_weapon1" );
	n_anim_time = getanimlength( %p_af_04_01_return_base_player_lineup );
	wait 5;
	body setviewmodelrenderflag( 1 );
	wait ( ( n_anim_time - 5 ) - 0,15 );
	screen_fade_out( 0,15 );
	wait 0,75;
	level.player startbinocs();
	level clientnotify( "binoc_on" );
	default_fov = getDvarFloat( "cg_fov" );
	level.krav_tank thread go_path();
	level.krav_tank thread stop_tank_at_end_node();
	level.charge_btrs[ 0 ] thread go_path();
	level.charge_btrs[ 1 ] thread go_path();
	level.player thread lerp_fov_overtime( 0,05, 23 );
	level.player thread lerp_dof_over_time( 2 );
	level thread screen_fade_in( 0,5 );
	level thread hind_hover();
	level thread run_scene( "e4_s1_binoc" );
	wait 2;
	level.krav_tank thread krav_tank_fire();
	wait 2;
	n_anim_time = getanimlength( %v_af_04_03_through_binoculars_tank );
	wait ( n_anim_time - 6,15 );
	exploder( 710 );
	wait 1;
	wait 0,9;
	screen_fade_out( 0,15 );
	wait 0,25;
	clientnotify( "binoc_off" );
	level.player stopbinocs();
	level.player setdepthoffield( 0, 1, 8000, 10000, 6, 0 );
	level.player thread lerp_fov_overtime( 0,05, default_fov );
	level.woods.vh_horse.delete_on_death = 1;
	level.woods.vh_horse notify( "death" );
	if ( !isalive( level.woods.vh_horse ) )
	{
		level.woods.vh_horse delete();
	}
	level.zhao.vh_horse.delete_on_death = 1;
	level.zhao.vh_horse notify( "death" );
	if ( !isalive( level.zhao.vh_horse ) )
	{
		level.zhao.vh_horse delete();
	}
	level.player.vh_horse.delete_on_death = 1;
	level.player.vh_horse notify( "death" );
	if ( !isalive( level.player.vh_horse ) )
	{
		level.player.vh_horse delete();
	}
	scene_wait( "e4_s1_binoc" );
	wait 0,25;
	level thread screen_fade_in( 0,5 );
	level thread get_ai_on_horse();
	level thread run_scene( "e4_s1_player_speech" );
	wait 0,05;
	e_player_scene_horse = get_model_or_models_from_scene( "e4_s1_player_speech", "mason_horse" );
	scene_wait( "e4_s1_player_speech" );
	flag_clear( "end_arena_migs" );
	level thread maps/afghanistan_firehorse::migs_flyover_arena();
	level thread maps/afghanistan_firehorse::fire_guns_base();
	flag_set( "arena_overlook" );
	level.player startcameratween( 1 );
	get_player_on_horse( e_player_scene_horse );
	wait 0,05;
	stop_exploder( 700 );
	stop_exploder( 710 );
	level thread maps/_audio::switch_music_wait( "AFGHAN_HORSE_CHARGE", 2 );
}

krav_tank_fire()
{
	level endon( "horse_done" );
	while ( 1 )
	{
		level.krav_tank fire_turret( 0 );
		wait 2;
		level.krav_tank fire_turret( 1 );
		wait 2;
		level.krav_tank fire_turret( 2 );
		wait 4;
	}
}

get_player_on_horse( e_horse_from_scene )
{
	s_mason_horse_spawnpt = getstruct( "mason_horse_charge_spawnpt", "targetname" );
	level.player.vh_horse = e_horse_from_scene;
	level.player.vh_horse.disable_mount_anim = 1;
	level.player.vh_horse.disable_make_useable = 1;
	level.player.vh_horse veh_magic_bullet_shield( 1 );
	level.player.vh_horse setbrake( 1 );
	level.player.vh_horse use_horse( level.player );
	level.player.vh_horse makevehicleunusable();
	s_mason_horse_spawnpt structdelete();
	s_mason_horse_spawnpt = undefined;
}

get_ai_on_horse()
{
	self endon( "charge_done" );
	s_woods_horse_spawnpt = getstruct( "woods_horse_charge_spawnpt", "targetname" );
	s_zhao_horse_spawnpt = getstruct( "zhao_horse_charge_spawnpt", "targetname" );
	level.woods.vh_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods ai_horse_ride( level.woods.vh_horse );
	level.zhao.vh_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.zhao ai_horse_ride( level.zhao.vh_horse );
	scene_wait( "e4_s1_player_speech" );
	level.woods.vh_horse.origin = s_woods_horse_spawnpt.origin;
	level.woods.vh_horse.angles = s_woods_horse_spawnpt.angles;
	level.woods.vh_horse attachpath( getvehiclenode( "woods_horse_path", "targetname" ) );
	level.woods.vh_horse startpath();
	level.woods.vh_horse setspeedimmediate( 0 );
	level.woods.vh_horse makevehicleunusable();
	level.woods.vh_horse horse_panic();
	level.woods.vh_horse thread woods_after_charge();
	level.zhao.vh_horse.origin = s_zhao_horse_spawnpt.origin;
	level.zhao.vh_horse.angles = s_zhao_horse_spawnpt.angles;
	level.zhao.vh_horse attachpath( getvehiclenode( "zhao_horse_path", "targetname" ) );
	level.zhao.vh_horse startpath();
	level.zhao.vh_horse setspeedimmediate( 0 );
	level.zhao.vh_horse makevehicleunusable();
	level.zhao.vh_horse horse_panic();
	level.player.ignoreme = 0;
	level.zhao.ignoreme = 0;
	level.woods.ignoreme = 0;
	level.zhao.ignoreall = 0;
	level.woods.ignoreall = 0;
	level.zhao thread magic_bullet_shield();
	level.woods thread magic_bullet_shield();
	level.zhao.vh_horse thread veh_magic_bullet_shield( 1 );
	level.woods.vh_horse thread veh_magic_bullet_shield( 1 );
	level thread give_zhao_and_woods_health();
	level.charge_btrs[ 0 ] thread btr_attack();
	level.charge_btrs[ 1 ] thread btr_attack();
	s_woods_horse_spawnpt structdelete();
	s_woods_horse_spawnpt = undefined;
	s_zhao_horse_spawnpt structdelete();
	s_zhao_horse_spawnpt = undefined;
}

woods_after_charge()
{
	self waittill( "reached_end_node" );
	if ( isDefined( self get_driver() ) )
	{
		level.woods ai_dismount_horse( self );
	}
}

give_zhao_and_woods_health()
{
	self endon( "charge_done" );
	while ( 1 )
	{
		if ( level.zhao.health < 1000 )
		{
			level.zhao.health += 2000;
		}
		if ( level.woods.health < 1000 )
		{
			level.woods.health += 2000;
		}
		wait 0,1;
	}
}

handle_horse_charge_intro_hind()
{
	self endon( "charge_done" );
	hind = spawn_vehicle_from_targetname( "hind_soviet" );
	hind thread go_path( getvehiclenode( "hind_attack_muj_path_start", "targetname" ) );
	hind_look_at = getent( "hind_look_at", "targetname" );
	hind setlookatent( hind_look_at );
	hind thread hind_strafe();
	level waittill( "stop_look_at" );
	hind clearlookatent();
	hind waittill( "reached_end_node" );
	hind.delete_on_death = 1;
	hind notify( "death" );
	if ( !isalive( hind ) )
	{
		hind delete();
	}
}

handle_horse_charge_extra_horses()
{
	self endon( "charge_done" );
	level waittill( "kill_horses" );
	level.extra_muj_riders[ 0 ].vh_my_horse vehicle_go_path_on_node( "extra_horse_path_0" );
	level.extra_muj_riders[ 1 ].vh_my_horse vehicle_go_path_on_node( "extra_horse_path_1" );
	level.extra_muj_riders[ 0 ].vh_my_horse makevehicleunusable();
	level.extra_muj_riders[ 1 ].vh_my_horse makevehicleunusable();
	level waittill( "start_2nd_set_of_extra_horses" );
	rider1 = simple_spawn_single( "extra_rider" );
	rider2 = simple_spawn_single( "extra_rider" );
	horse1 = spawn_vehicle_from_targetname( "horse_afghan_low" );
	horse2 = spawn_vehicle_from_targetname( "horse_afghan_low" );
	rider1 enter_vehicle( horse1 );
	rider2 enter_vehicle( horse2 );
	horse1 makevehicleunusable();
	horse2 makevehicleunusable();
	horse1 vehicle_go_path_on_node( "extra_horse_path_2" );
	horse2 vehicle_go_path_on_node( "extra_horse_path_3" );
	level waittill( "fire_rpg_at_btr" );
	wait 0,1;
	if ( isalive( horse1 ) )
	{
		radiusdamage( horse1.origin, 64, horse1.health * 2, horse1.health * 2 );
	}
	if ( isalive( horse2 ) )
	{
		radiusdamage( horse2.origin, 64, horse2.health * 2, horse2.health * 2 );
	}
}

handle_horse_charge_blow_up_horses()
{
	self endon( "charge_done" );
	level waittill( "start_blow_up_horses" );
	wait 2;
	ai_muj = getent( "muj_rider_shot", "targetname" );
	if ( isDefined( ai_muj ) )
	{
		ai_muj stop_magic_bullet_shield();
		wait 0,1;
		playfx( level._effect[ "sniper_impact" ], ai_muj gettagorigin( "J_Head" ) );
		ai_muj playsound( "evt_horse_death_1" );
		ai_muj die();
		wait 2;
		level.a_vh_horses[ 3 ] setspeed( 0, 10, 5 );
		wait 5;
		level.a_vh_horses[ 3 ].delete_on_death = 1;
		level.a_vh_horses[ 3 ] notify( "death" );
		if ( !isalive( level.a_vh_horses[ 3 ] ) )
		{
			level.a_vh_horses[ 3 ] delete();
		}
	}
}

hind_hover()
{
	s_spawnpt = getstruct( "hind_hover_spawnpt", "targetname" );
	s_goal1 = getstruct( "hind_hover_goal1", "targetname" );
	s_goal2 = getstruct( "hind_hover_goal2", "targetname" );
	vh_hind = spawn_vehicle_from_targetname( "hind_soviet" );
	vh_hind.origin = s_spawnpt.origin;
	vh_hind.angles = s_spawnpt.angles;
	vh_hind setforcenocull();
	vh_hind setneargoalnotifydist( 300 );
	vh_hind setspeed( 20, 15, 5 );
	vh_hind setvehgoalpos( s_goal1.origin, 1 );
	vh_hind waittill_any( "goal", "near_goal" );
	wait 3;
	vh_hind setspeed( 50, 25, 15 );
	vh_hind setvehgoalpos( s_goal2.origin, 0 );
	vh_hind waittill_any( "goal", "near_goal" );
	vh_hind.delete_on_death = 1;
	vh_hind notify( "death" );
	if ( !isalive( vh_hind ) )
	{
		vh_hind delete();
	}
	s_spawnpt structdelete();
	s_spawnpt = undefined;
	s_goal1 structdelete();
	s_goal1 = undefined;
	s_goal2 structdelete();
	s_goal2 = undefined;
}

fxanim_rock_slide()
{
	level waittill( "mig_fly_over" );
	wait 1;
	play_mortar_fx( "mortar_rock_slide", "exp_rocket_rocks" );
	level notify( "fxanim_rock_slide_start" );
}

hind_charge_shoot()
{
	level waittill( "rpg_shot_at_uaz" );
	s_spawnpt = getstruct( "hind_charge_spawnpt", "targetname" );
	vh_hind = spawn_vehicle_from_targetname( "hind_soviet" );
	vh_hind.origin = s_spawnpt.origin;
	vh_hind.angles = s_spawnpt.angles;
	vh_hind thread hind_charge_logic();
	s_spawnpt structdelete();
	s_spawnpt = undefined;
}

hind_charge_logic()
{
	self endon( "death" );
	self setforcenocull();
	target_set( self, ( -50, 0, -32 ) );
	s_goal1 = getstruct( "hind_charge_goal1", "targetname" );
	s_goal2 = getstruct( "hind_charge_goal2", "targetname" );
	s_goal3 = getstruct( "hind_charge_goal3", "targetname" );
	self setneargoalnotifydist( 400 );
	self setspeed( 90, 50, 25 );
	self setvehgoalpos( s_goal1.origin );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin );
	self waittill_any( "goal", "near_goal" );
	s_stinger = getstruct( "hind_charge_stinger", "targetname" );
	magicbullet( "afghanstinger_ff_sp", s_stinger.origin, self.origin + vectorScale( ( 0, 0, 0 ), 20 ), undefined, self, vectorScale( ( 0, 0, 0 ), 30 ) );
	self thread waitfordeath();
	self setvehgoalpos( s_goal3.origin );
	self waittill_any( "goal", "near_goal" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
	s_goal1 structdelete();
	s_goal1 = undefined;
	s_goal2 structdelete();
	s_goal2 = undefined;
	s_goal3 structdelete();
	s_goal3 = undefined;
	s_stinger structdelete();
	s_stinger = undefined;
}

waitfordeath()
{
	self waittill( "death" );
}

handle_horse_charge_rpg_shot_at_uaz()
{
	self endon( "charge_done" );
	level waittill( "rpg_shot_at_uaz" );
	if ( isalive( level.vh_before_charge_uaz ) )
	{
		if ( isDefined( level.ai_rpg_muj ) )
		{
			magicbullet( "rpg_magic_bullet_sp", level.ai_rpg_muj.origin - ( 10, 10, -60 ), level.vh_before_charge_uaz.origin + ( 550, -50, 0 ) );
		}
	}
	wait 0,7;
	if ( isalive( level.vh_before_charge_uaz ) )
	{
		radiusdamage( level.vh_before_charge_uaz.origin, 100, level.vh_before_charge_uaz.health * 2, level.vh_before_charge_uaz.health * 2 );
	}
}

handle_horse_charge_mig_fly_overs()
{
	level endon( "horse_charge_finished" );
	level endon( "end_arena_migs" );
	self endon( "charge_done" );
	level waittill( "mig_fly_over" );
	mig = level vehicle_go_path_on_node( "mig23_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig playsound( "evt_fake_mig_flyby" );
	mig = level vehicle_go_path_on_node( "mig23_start_12", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_13", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig playsound( "evt_fake_mig_flyby" );
	level waittill( "mig_fly_over_2" );
	mig = level vehicle_go_path_on_node( "horse_charge_mig_2_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig playsound( "evt_fake_mig_flyby" );
	mig thread mig_gun_strafe();
}

handle_horse_charge_hind()
{
	self endon( "charge_done" );
	level waittill( "start_hind" );
	level.vh_charge_hind = vehicle_go_path_on_node( "hind_start_node", "hind_soviet" );
	level.vh_charge_hind thread hind_fire_missiles();
	level.vh_charge_hind thread delete_vehicle_at_end_of_node();
	level.player playsound( "evt_horse_charge_heli_flyover" );
}

hind_fire_missiles()
{
	self endon( "death" );
	while ( 1 )
	{
		self fire_turret( 1 );
		wait randomfloatrange( 0,3, 0,5 );
		self fire_turret( 2 );
		wait randomfloatrange( 0,8, 1,2 );
	}
}

handle_horse_charge_mortars()
{
	self endon( "charge_done" );
	i = 1;
	while ( i < 4 )
	{
		level waittill( "mig_morter_" + i );
		i++;
	}
	level waittill( "mortar_4_explo" );
	level waittill( "mig_morter_4" );
}

handle_horse_charge_new_horses()
{
	self endon( "charge_done" );
	level waittill( "release_new_horses" );
	a_s_horse_spawnpts = [];
	i = 0;
	while ( i < 3 )
	{
		a_s_horse_spawnpts[ i ] = getvehiclenode( "new_horse_node_" + i, "targetname" );
		i++;
	}
	level.a_vh_newhorses = [];
	i = 0;
	while ( i < a_s_horse_spawnpts.size )
	{
		wait 0,05;
		level.a_vh_newhorses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_newhorses[ i ].origin = a_s_horse_spawnpts[ i ].origin;
		level.a_vh_newhorses[ i ].angles = a_s_horse_spawnpts[ i ].angles;
		level.a_vh_newhorses[ i ] attachpath( getvehiclenode( "new_horse_node_" + i, "targetname" ) );
		level.a_vh_newhorses[ i ] makevehicleunusable();
		level.a_vh_newhorses[ i ] horse_panic();
		level.a_vh_newhorses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_newhorses[ i ].ai_rider ) )
		{
			level.a_vh_newhorses[ i ].ai_rider ai_horse_ride( level.a_vh_newhorses[ i ] );
		}
		level.a_vh_newhorses[ i ] startpath();
		level.a_vh_newhorses[ i ] thread delete_vehicle_at_end_of_node();
		i++;
	}
	level waittill( "mig_fly_over_2" );
	s_cache = getstruct( "cache5_explosion", "targetname" );
	playfx( level._effect[ "cache_dest" ], s_cache.origin );
	wait 0,1;
	e_temp_origin = spawn( "script_origin", s_cache.origin );
	e_temp_origin playsound( "evt_horse_death_2" );
	if ( isalive( level.a_vh_newhorses[ 0 ] ) )
	{
		radiusdamage( level.a_vh_newhorses[ 0 ].origin, 32, level.a_vh_newhorses[ 0 ].health * 2, level.a_vh_newhorses[ 0 ].health * 2 );
	}
	if ( isalive( level.a_vh_newhorses[ 1 ] ) )
	{
		radiusdamage( level.a_vh_newhorses[ 1 ].origin, 32, level.a_vh_newhorses[ 1 ].health * 2, level.a_vh_newhorses[ 1 ].health * 2 );
		earthquake( 0,3, 0,6, level.a_vh_newhorses[ 1 ].origin, 400 );
	}
	if ( isalive( level.a_vh_newhorses[ 2 ] ) )
	{
		radiusdamage( level.a_vh_newhorses[ 2 ].origin, 32, level.a_vh_newhorses[ 2 ].health * 2, level.a_vh_newhorses[ 2 ].health * 2 );
	}
	e_temp_origin delete();
	s_cache structdelete();
	s_cache = undefined;
}

handle_horse_charge_rpg_shot_at_btr()
{
	self endon( "charge_done" );
	level waittill( "fire_rpg_at_btr" );
	if ( isalive( level.charge_btrs[ 0 ] ) )
	{
		fire_magic_bullet_rpg( "fire_magic_rpg_at_btr", level.charge_btrs[ 0 ].origin, vectorScale( ( 0, 0, 0 ), 50 ) );
	}
	play_mortar_fx( "mortar_left_explosion", "exp_mortar" );
	playsoundatposition( "evt_horse_death_3", ( 2416, -11355, -50 ) );
	s_exp = getstruct( "mortar_left_explosion", "targetname" );
	radiusdamage( s_exp.origin, 500, 2500, 2000 );
	s_exp structdelete();
	s_exp = undefined;
}

handle_horse_charge_ending()
{
	self endon( "charge_done" );
	level.player.vh_horse waittill( "reached_end_node" );
	level notify( "horse_done" );
	level.player.body notify( "stop_dust" );
	level.player.vh_horse.disable_weapon_changes = 1;
	if ( isalive( level.charge_btrs[ 0 ] ) )
	{
		level.charge_btrs[ 0 ] notify( "stop_attack" );
	}
	if ( isalive( level.charge_btrs[ 1 ] ) )
	{
		level.charge_btrs[ 1 ] notify( "stop_attack" );
	}
	s_blow_up_horse_loc = level play_mortar_fx( "blow_up_horse" );
	level.player playsound( "evt_horsecharge_imp" );
	level.player playsound( "evt_plr_horse_death" );
	level.player shellshock( "afghan_horsefall", 10 );
	level.player dodamage( level.player.health - 1, level.player.origin );
	wait 0,1;
	earthquake( 0,7, 2, s_blow_up_horse_loc.origin, 800 );
	s_blow_up_horse_loc = undefined;
	level.player.vh_horse use_horse( level.player );
	level.player.vh_horse makevehicleunusable();
	level.player disableweapons();
	level.player.vh_horse hide();
	m_prop_horse = spawn( "script_model", ( 0, 0, 0 ) );
	m_prop_horse setmodel( level.player.vh_horse.old_model );
	m_prop_horse.animname = "prop_horse";
	delete_ents( level.contents_corpse, level.player.body.origin, 1000 );
	level thread run_scene_first_frame( "e4_s5_tank_path_horsepush" );
	level run_scene( "e4_s5_player_horse_fall" );
	level notify( "horse_fallen" );
	level thread run_scene( "e4_s5_tank_path_horsepush" );
	level thread run_scene_first_frame( "e4_s5_player_horse_pushloop" );
	level thread handle_horse_charge_push_off_migs_and_mortars();
	level.player.vh_horse.delete_on_death = 1;
	level.player.vh_horse notify( "death" );
	if ( !isalive( level.player.vh_horse ) )
	{
		level.player.vh_horse delete();
	}
	screen_message_create( &"AFGHANISTAN_PUSH_OFF_HORSE" );
	push_horse_off_logic();
}

handle_horse_charge_push_off_migs_and_mortars()
{
	level endon( "horse_charge_finished" );
	level endon( "end_arena_migs" );
	self endon( "charge_done" );
	mig = level vehicle_go_path_on_node( "mig23_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_12", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_13", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	wait 2;
	s_mortar_drop = level play_mortar_fx( "push_off_mortars_1", "exp_mortar" );
	wait 0,1;
	earthquake( 0,4, 1, s_mortar_drop.origin, 800 );
	wait 0,15;
	s_mortar_drop = undefined;
	s_mortar_drop = level play_mortar_fx( "push_off_mortars_2", "exp_mortar" );
	wait 0,1;
	earthquake( 0,4, 1, s_mortar_drop.origin, 800 );
	s_mortar_drop = undefined;
}

horse_charge_event()
{
	flag_set( "in_horse_charge" );
	horse_charge_clean_up_weapons();
	horse_charge_line_up_event();
	start_horse_charge_vehicles();
	level thread fxanim_rock_slide();
	level thread hind_charge_shoot();
	level thread handle_horse_charge_mig_fly_overs();
	level thread handle_horse_charge_blow_up_horses();
	level thread handle_horse_charge_hind();
	level thread handle_horse_charge_mortars();
	level thread handle_horse_charge_rpg_shot_at_btr();
	level thread handle_horse_charge_rpg_shot_at_uaz();
	level thread handle_horse_charge_new_horses();
	handle_horse_charge_ending();
}

horse_charge_clean_up_weapons()
{
	a_items = getitemarray();
	n_size = a_items.size;
	i = 0;
	while ( i < n_size )
	{
		if ( isDefined( a_items[ i ].classname ) && issubstr( a_items[ i ].classname, "weapon_" ) )
		{
			a_items[ i ] delete();
		}
		i++;
	}
}

clean_up_charge()
{
	self endon( "charge_done" );
	level.kravchenko = init_hero( "kravchenko" );
	if ( level.skipto_point != "krav_tank" )
	{
		i = 0;
		while ( i < 6 )
		{
			if ( isDefined( level.a_vh_horses[ i ] ) )
			{
				level.a_vh_horses[ i ].delete_on_death = 1;
				level.a_vh_horses[ i ] notify( "death" );
				if ( !isalive( level.a_vh_horses[ i ] ) )
				{
					level.a_vh_horses[ i ] delete();
				}
				if ( isDefined( level.a_vh_horses[ i ].ai_rider ) )
				{
					level.a_vh_horses[ i ].ai_rider delete();
				}
			}
			i++;
		}
		if ( isDefined( level.vh_charge_hind ) )
		{
			level.vh_charge_hind.delete_on_death = 1;
			level.vh_charge_hind notify( "death" );
			if ( !isalive( level.vh_charge_hind ) )
			{
				level.vh_charge_hind delete();
			}
		}
	}
}

stop_tank_at_end_node()
{
	self endon( "charge_done" );
	self waittill( "tank_pause_pos" );
	self notify( "tank_stop_attack" );
	self setspeed( 0, 1 );
	self setcandamage( 0 );
	level waittill( "horse_fallen" );
	self resumespeed( 3 );
	self setcandamage( 1 );
}

push_horse_off_logic()
{
	self endon( "charge_done" );
	b_success = 0;
	n_time_remaining = 5,5;
	n_pushed_counter = 0;
	vox_ent = spawn( "script_origin", level.player.origin );
	vox_ent thread play_push_vox();
	level thread fake_mortar_sounds();
	anim_horse_push_loop = level.scr_anim[ "prop_horse" ][ "e4_s5_horse_horse_push_loop" ];
	anim_player_push_loop = level.scr_anim[ "player_body" ][ "e4_s5_player_horse_push_loop" ];
	anim_horse_push = level.scr_anim[ "prop_horse" ][ "e4_s5_horse_horse_push" ];
	anim_player_push = level.scr_anim[ "player_body" ][ "e4_s5_player_horse_push" ];
	n_push_time_total = getanimlength( anim_player_push );
	n_push_frames_total = n_push_time_total * 20;
	m_player_hands = get_model_or_models_from_scene( "e4_s5_player_horse_pushloop", "player_body" );
	m_horse = get_model_or_models_from_scene( "e4_s5_player_horse_pushloop", "prop_horse" );
	m_player_hands stopanimscripted();
	m_horse stopanimscripted();
	n_weight_push = 0;
	n_weight_idle = 1;
	b_need_to_tween = 1;
	while ( n_time_remaining > 0 && !b_success )
	{
		n_push_strength = level.player _get_horse_push_strength();
		if ( b_need_to_tween )
		{
			level.player startcameratween( 0,25 );
			b_need_to_tween = 0;
		}
		else
		{
			if ( n_push_strength == 0 )
			{
				b_need_to_tween = 1;
			}
		}
		if ( n_push_strength > 1,9 )
		{
			n_pushed_counter += 1;
			n_playback_rate = 1;
			vox_ent notify( "plr_pushing" );
			if ( n_weight_push == 0 )
			{
				n_weight_push = 1;
				n_weight_idle = 0;
			}
			else
			{
				n_weight_push += 0,1;
				n_weight_idle -= 0,1;
			}
			level.player playrumbleonentity( "anim_light" );
		}
		else
		{
			n_pushed_counter -= 10;
			n_playback_rate = 1;
			n_weight_push -= 0,1;
			n_weight_idle += 0,1;
			vox_ent notify( "plr_stopped" );
		}
		n_pushed_counter = clamp( n_pushed_counter, 0, 100000 );
		n_weight_push = clamp( n_weight_push, 0, 1 );
		n_weight_idle = clamp( n_weight_idle, 0, 1 );
		m_player_hands setanim( anim_player_push, n_weight_push, 0,05, n_playback_rate );
		m_horse setanim( anim_horse_push, n_weight_push, 0,05, n_playback_rate );
		m_player_hands setanim( anim_player_push_loop, n_weight_idle, 0,05, n_playback_rate );
		m_horse setanim( anim_horse_push_loop, n_weight_idle, 0,05, n_playback_rate );
		if ( n_pushed_counter > n_push_frames_total )
		{
			b_success = 1;
		}
		n_time_remaining -= 0,05;
		wait 0,05;
	}
	if ( b_success )
	{
		level thread play_sound_vox_push_last( vox_ent );
		flag_set( "player_pushed_off_horse" );
		screen_message_delete();
		end_scene( "e4_s5_player_horse_pushloop" );
		delay_thread( 6,75, ::_delete_pushed_horse, m_horse );
		run_scene( "e4_s5_player_horse_push_success" );
	}
	else
	{
		vox_ent stoploopsound( 0,4 );
		vox_ent playsound( "vox_push_fail" );
		screen_message_delete();
		n_weight_idle = 1;
		m_player_hands clearanim( anim_player_push, 1 );
		m_horse clearanim( anim_horse_push, 1 );
		m_player_hands setanim( anim_player_push_loop, n_weight_idle, 1, n_playback_rate );
		m_horse setanim( anim_horse_push_loop, n_weight_idle, 1, n_playback_rate );
		wait 1;
		missionfailedwrapper( &"SCRIPT_MISSIONFAIL_ESCAPE" );
		wait 1;
		level.player dodamage( 120, level.player.origin );
		wait 5;
	}
}

_delete_pushed_horse( m_horse )
{
	m_horse delete();
}

_get_horse_push_strength()
{
	total = 0;
	if ( level.player throwbuttonpressed() )
	{
		total += 1;
	}
	if ( level.player attackbuttonpressed() )
	{
		total += 1;
	}
	return total;
}

play_sound_vox_push_last( vox_ent )
{
	vox_ent stoploopsound( 1 );
	vox_ent playsound( "vox_push_last" );
	wait 4;
	vox_ent delete();
}

play_push_vox()
{
	while ( 1 )
	{
		self waittill( "plr_pushing" );
		self playloopsound( "vox_push_loop", 0,7 );
		self waittill( "plr_stopped" );
		self stoploopsound( 0,4 );
		self playsound( "vox_push_stop" );
		wait 0,05;
	}
}

fake_mortar_sounds()
{
	wait 0,2;
	playsoundatposition( "exp_mortar", ( 2988, -9207, -7 ) );
	wait 1;
	playsoundatposition( "exp_mortar", ( 2004, -6118, 142 ) );
	wait 2,7;
	playsoundatposition( "exp_mortar", ( 3100, -8089, -10 ) );
	wait 1,8;
	playsoundatposition( "exp_mortar", ( 2549, -7109, -11 ) );
	wait 1,2;
	playsoundatposition( "exp_mortar", ( 1890, -8062, -20 ) );
	wait 1;
	playsoundatposition( "exp_mortar", ( 1890, -5062, -20 ) );
}

tank_path_anims()
{
	flag_wait( "start_runtowoods_tank" );
	level thread run_scene( "e4_s5_tank_path_runtowoods" );
	flag_wait( "start_tankbattle_tank" );
	level thread run_scene( "e4_s5_tank_path_tankbattle" );
}

after_button_mash_scene()
{
	if ( level.skipto_point == "krav_tank" )
	{
		run_scene( "e4_s5_player_horse_fall" );
		level notify( "horse_fallen" );
		level thread run_scene( "e4_s5_tank_path_horsepush" );
		screen_message_create( &"AFGHANISTAN_PUSH_OFF_HORSE" );
		push_horse_off_logic();
		level.krav_tank = getent( "krav_tank", "targetname" );
	}
	level thread clean_up_charge();
	level clientnotify( "strt_tf" );
	level thread run_scene( "e4_s6_player_grabs_on_tank" );
	level thread tank_path_anims();
	level.player.ignoreme = 1;
	level.player thread lerp_fov_overtime( 0,05, getDvarFloat( "cg_fov_default" ) );
	if ( !isDefined( level.charge_btrs ) )
	{
		level.charge_btrs = spawn_vehicles_from_targetname( "horse_charge_btr" );
		level.charge_btrs[ 1 ] attachpath( getvehiclenode( "btr_skipto", "targetname" ) );
		level.charge_btrs[ 1 ] startpath();
	}
	level thread handle_tank_earthquake();
	level thread handle_tank_roll_over_mortars();
	anim_length = getanimlength( %p_af_04_06_reunion_player_run2tank );
	wait ( anim_length - 3,5 );
	level thread fire_magic_bullet_rpg( "fire_magic_rpg_at_btr_2", level.charge_btrs[ 1 ].origin, vectorScale( ( 0, 0, 0 ), 20 ) );
	ai_soviet = get_soviet_ai();
	if ( isDefined( ai_soviet ) )
	{
		ai_soviet.animname = "soviet_guard";
	}
	scene_wait( "e4_s6_player_grabs_on_tank" );
	level thread run_scene( "e4_s6_tank_fight" );
	level thread handle_punch_timescale();
	level.kravchenko.ignoreme = 1;
	level thread handle_tank_fight_run_migs();
	level thread handle_tank_fight_mortars();
	level thread handle_pickup_btr_chase();
	level thread handle_tank_climb_hind();
	level thread handle_tank_climb_migs_and_mortars();
	anim_length = getanimlength( %p_af_04_06_reunion_player_tankfight );
	wait ( anim_length - 2 );
	scene_wait( "e4_s6_tank_fight" );
	level clientnotify( "end_tf" );
	level clientnotify( "tank_explode" );
	level.kravchenko unlink();
	level.player unlink();
	wait 0,1;
	level.player shellshock( "death", 5 );
	level.player dodamage( 50, level.player.origin );
	level thread run_scene( "e4_s6_strangle" );
	anim_length = getanimlength( %p_af_04_09_reunion_player_strangle );
	level.krav_tank thread play_fx( "krav_tank_fire", level.krav_tank.origin, level.krav_tank.angles, undefined, 1, "tag_origin" );
	level thread handle_krav_tank_falling_out_of_the_world();
	level thread horses_after_krav_down();
	wait 1,8;
	level.player dodamage( 50, level.player.origin );
	wait ( anim_length - 13,8 );
	flag_set( "end_arena_migs" );
	level notify( "charge_done" );
	level notify( "stop_guns_base" );
	level notify( "stop_stingers_base" );
	flag_set( "horse_charge_finished" );
	level waittill( "end_strangle_scene" );
	level.player notify( "stop_numbers" );
	wait 0,25;
	if ( isDefined( level.zhao ) )
	{
		level.zhao show();
	}
	level.player setblur( 0, 0,05 );
	end_scene( "e4_s6_strangle" );
	vehicle_array = getentarray( "script_vehicle", "classname" );
	i = 0;
	while ( i < vehicle_array.size )
	{
		if ( isDefined( vehicle_array[ i ] ) )
		{
			vehicle_array[ i ].delete_on_death = 1;
			vehicle_array[ i ] notify( "death" );
			if ( !isalive( vehicle_array[ i ] ) )
			{
				vehicle_array[ i ] delete();
			}
		}
		i++;
	}
	wait 0,15;
	corpses = getentarray( "script_vehicle_corpse", "classname" );
	i = 0;
	while ( i < corpses.size )
	{
		if ( isDefined( corpses[ i ] ) )
		{
			corpses[ i ] delete();
		}
		i++;
	}
	enemies = getaiarray( "axis" );
	i = 0;
	while ( i < enemies.size )
	{
		if ( isDefined( enemies[ i ] ) )
		{
			enemies[ i ] delete();
		}
		i++;
	}
	ai_corpse = getcorpsearray();
	i = 0;
	while ( i < ai_corpse.size )
	{
		if ( isDefined( ai_corpse[ i ] ) )
		{
			ai_corpse[ i ] delete();
		}
		i++;
	}
	wait 0,15;
	load_gump( "afghanistan_gump_ending" );
}

audiocutsound( guy )
{
	level clientnotify( "cut_tf" );
}

delete_rider_and_horse_at_end_of_node()
{
	self endon( "death" );
	self endon( "delete" );
	self endon( "charge_done" );
	self.vh_my_horse waittill( "reached_end_node" );
	self.vh_my_horse.delete_on_death = 1;
	self.vh_my_horse notify( "death" );
	if ( !isalive( self.vh_my_horse ) )
	{
		self.vh_my_horse delete();
	}
	self delete();
}

delete_vehicle_at_end_of_node()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
	if ( isDefined( self.riders[ 0 ] ) )
	{
		self.riders[ 0 ] delete();
	}
	wait 0,1;
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

handle_krav_tank_falling_out_of_the_world()
{
	level endon( "charge_done" );
	scene_wait( "e4_s6_strangle" );
}

handle_tank_climb_setup_horses()
{
	level endon( "charge_done" );
	level.tank_climb_muj = [];
	i = 0;
	while ( i < 4 )
	{
		level.tank_climb_muj[ i ] = simple_spawn_single( "extra_rider" );
		level.tank_climb_muj[ i ].vh_my_horse = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.tank_climb_muj[ i ] thread delete_rider_and_horse_at_end_of_node();
		level.tank_climb_muj[ i ] enter_vehicle( level.tank_climb_muj[ i ].vh_my_horse );
		i++;
	}
}

handle_tank_climb_migs_and_mortars()
{
	level endon( "horse_charge_finished" );
	level endon( "end_arena_migs" );
	level endon( "charge_done" );
	wait 22,75;
	mig = level vehicle_go_path_on_node( "mig23_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_12", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_13", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	wait 1;
	level play_mortar_fx( "tank_climb_mortar_0", "exp_mortar" );
	wait 0,3;
	level play_mortar_fx( "tank_climb_mortar_1", "exp_mortar" );
	wait 0,2;
	level play_mortar_fx( "tank_climb_mortar_2", "exp_mortar" );
}

handle_tank_climb_setup_axis()
{
	level endon( "charge_done" );
	wait 0,7;
	i = 0;
	while ( i < 3 )
	{
		axis = simple_spawn_single( "russian_charging_base_spawner" );
		axis_origin_struct = getstruct( "tank_climb_axis_" + i, "targetname" );
		vol = getent( "tank_climb_axis_volume", "targetname" );
		axis setgoalvolumeauto( vol );
		axis disable_tactical_walk();
		axis.ignoreme = 1;
		axis forceteleport( axis_origin_struct.origin, axis_origin_struct.angles );
		i++;
	}
	axis_origin = [];
	i = 0;
	while ( i < 3 )
	{
		axis_origin[ i ] = getstruct( "tank_climb_axis_" + i, "targetname" );
		axis_origin[ i ] structdelete();
		i++;
	}
}

handle_krav_strangle_setup_horses()
{
	level endon( "charge_done" );
	wait 11,15;
	level.krav_strangle_muj = [];
	i = 0;
	while ( i < 16 )
	{
		level.krav_strangle_muj[ i ] = simple_spawn_single( "extra_rider" );
		level.krav_strangle_muj[ i ].vh_my_horse = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.krav_strangle_muj[ i ] thread delete_rider_and_horse_at_end_of_node();
		level.krav_strangle_muj[ i ] enter_vehicle( level.krav_strangle_muj[ i ].vh_my_horse );
		i++;
	}
}

handle_tank_climb_hind()
{
	level endon( "charge_done" );
	wait 16,2;
	hind = spawn_vehicle_from_targetname( "hind_soviet" );
	hind thread go_path( getvehiclenode( "tank_climb_hind_path", "targetname" ) );
	level waittill( "fire_rpgs_at_hind" );
	i = 0;
	while ( i < 3 )
	{
		level fire_magic_bullet_huey_rocket( "tank_climb_hind_rpg_" + i, hind.origin );
		wait 0,4;
		i++;
	}
}

handle_tank_fight_mortars()
{
	level endon( "charge_done" );
	wait 3,7;
	s_mortar_drop = level play_mortar_fx( "push_off_mortars_3", "exp_mortar" );
	wait 0,25;
	s_mortar_drop = undefined;
	s_mortar_drop = level play_mortar_fx( "push_off_mortars_4", "exp_mortar" );
	s_mortar_drop = undefined;
}

handle_tank_fight_run_migs()
{
	level endon( "horse_charge_finished" );
	level endon( "end_arena_migs" );
	level endon( "charge_done" );
	wait 1;
	mig = level vehicle_go_path_on_node( "mig23_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_12", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
}

handle_tank_fight_run_horses()
{
	level endon( "charge_done" );
	wait 0,7;
	level.tank_climb_muj[ 0 ].vh_my_horse vehicle_go_path_on_node( "tank_climb_horse_path_0" );
	level.tank_climb_muj[ 1 ].vh_my_horse vehicle_go_path_on_node( "tank_climb_horse_path_1" );
	level.tank_climb_muj[ 2 ].vh_my_horse vehicle_go_path_on_node( "tank_climb_horse_path_2" );
	level.tank_climb_muj[ 3 ].vh_my_horse vehicle_go_path_on_node( "tank_climb_horse_path_3" );
}

handle_tank_strangle_run_horses()
{
	level endon( "charge_done" );
	level.krav_strangle_muj[ 0 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_0" );
	level.krav_strangle_muj[ 1 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_1" );
	level.krav_strangle_muj[ 2 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_2" );
	level.krav_strangle_muj[ 3 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_3" );
	level.krav_strangle_muj[ 4 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_4" );
	wait 4,5;
	level.krav_strangle_muj[ 5 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_5" );
	level.krav_strangle_muj[ 6 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_6" );
	level.krav_strangle_muj[ 7 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_7" );
	wait 1;
	level.krav_strangle_muj[ 8 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_8" );
	level.krav_strangle_muj[ 9 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_9" );
	level.krav_strangle_muj[ 10 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_10" );
	wait 6,5;
	level.krav_strangle_muj[ 11 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_11" );
	level.krav_strangle_muj[ 12 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_12" );
	level.krav_strangle_muj[ 13 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_13" );
	level.krav_strangle_muj[ 14 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_14" );
	level.krav_strangle_muj[ 15 ].vh_my_horse vehicle_go_path_on_node( "krav_stangle_horse_path_15" );
}

handle_tank_earthquake()
{
	level endon( "charge_done" );
	flag_wait( "start_kravchenko_tank_earthquake" );
	earthquake( 0,3, 5, level.player.origin, 800 );
}

handle_pickup_btr_chase()
{
	wait 2;
	sp_rider = getent( "muj_assault", "targetname" );
	pickup_1 = vehicle_go_path_on_node( "pick_up_btr_path_1", "truck_afghan" );
	pickup_1 thread delete_vehicle_at_end_of_node();
	pickup_1.driver = sp_rider spawn_ai( 1 );
	pickup_1.driver.script_startingposition = 0;
	pickup_1.driver enter_vehicle( pickup_1 );
	wait 0,25;
	pickup_1.gunner = sp_rider spawn_ai( 1 );
	pickup_1.gunner.script_startingposition = 2;
	pickup_1.gunner enter_vehicle( pickup_1 );
	pickup_2 = vehicle_go_path_on_node( "pick_up_btr_path_2", "truck_afghan" );
	pickup_2 thread delete_vehicle_at_end_of_node();
	pickup_2.driver = sp_rider spawn_ai( 1 );
	pickup_2.driver.script_startingposition = 0;
	pickup_2.driver enter_vehicle( pickup_2 );
	wait 0,1;
	pickup_2.gunner = sp_rider spawn_ai( 1 );
	pickup_2.gunner.script_startingposition = 2;
	pickup_2.gunner enter_vehicle( pickup_2 );
	wait 1,2;
	btr = vehicle_go_path_on_node( "pick_up_btr_path_1", "btr_soviet" );
	btr thread delete_vehicle_at_end_of_node();
	wait 1;
	btr thread btr_chase_logic( pickup_1 );
	pickup_1 thread truck_chase_logic( btr );
	pickup_2 thread truck_chase_logic( btr );
}

truck_chase_logic( vh_btr )
{
	self endon( "death" );
	wait 0,5;
	if ( isalive( vh_btr ) )
	{
		self set_turret_target( vh_btr, ( 0, -100, -32 ), 1 );
		self shoot_turret_at_target( vh_btr, 7, ( 0, 0, 0 ), 1 );
	}
}

btr_chase_logic( pickup_1 )
{
	self endon( "death" );
	wait 1,5;
	if ( isalive( pickup_1 ) )
	{
		self set_turret_target( pickup_1, ( 0, 0, 0 ), 1 );
		self shoot_turret_at_target( pickup_1, 7, ( 0, 0, 0 ), 1 );
	}
}

handle_punch_timescale()
{
	level endon( "charge_done" );
	flag_wait( "kravchenko_time_scale_punch" );
	level clientnotify( "punch_timescale_on" );
	settimescale( 0,15 );
	level.player play_fx( "numbers_base", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player play_fx( "numbers_center", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player play_fx( "numbers_mid", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player thread say_dialog( "dragovich_kravche_005" );
	timescale_tween( 0,15, 1, 2 );
	level clientnotify( "punch_timescale_off" );
	wait 3;
}

handle_numbers( m_player_body )
{
	level endon( "charge_done" );
	level.player play_fx( "tank_numbers_base", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player play_fx( "tank_numbers_center", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player play_fx( "tank_numbers_mid", level.player.origin, level.player.angles, "stop_numbers", 1 );
	level.player thread say_dialog( "dragovich_kravche_005" );
	level.player thread playnumbersaudio();
}

playnumbersaudio()
{
	self endon( "stop_numbers" );
	a = 0;
	b = 0;
	c = 0;
	while ( 1 )
	{
		a = randomintrange( -250, 250 );
		b = randomintrange( -250, 250 );
		c = randomintrange( -250, 250 );
		playsoundatposition( "evt_numbers_flux", self.origin + ( a, b, c ) );
		wait randomfloatrange( 1, 3 );
	}
}

handle_tank_explosion( m_player_body )
{
	krav_tank = get_model_or_models_from_scene( "e4_s5_tank_path_tankbattle", "krav_tank" );
	krav_tank play_fx( "fx_afgh_explo_krav_tank", krav_tank gettagorigin( "tag_origin" ), krav_tank gettagangles( "tag_origin" ), undefined, 0, undefined, 1 );
	krav_tank play_fx( "krav_tank_fire", krav_tank gettagorigin( "tag_origin" ), krav_tank gettagangles( "tag_origin" ), undefined, 0, undefined, 1 );
}

handle_tank_roll_over_mortars()
{
	level endon( "horse_charge_finished" );
	level endon( "end_arena_migs" );
	level endon( "charge_done" );
	wait 7;
	mig = level vehicle_go_path_on_node( "mig23_start", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_12", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	mig = level vehicle_go_path_on_node( "mig23_start_13", "mig23_spawner" );
	mig thread delete_vehicle_at_end_of_node();
	mig setanim( %veh_anim_mig23_wings_open, 1, 0, 1 );
	wait 1,5;
	i = 1;
	while ( i < 7 )
	{
		level play_mortar_fx( "roll_over mortar_" + i, "exp_mortar" );
		wait randomfloatrange( 0,5, 0,7 );
		i++;
	}
}

delete_dead_horse_after_charge()
{
	level endon( "charge_done" );
	self endon( "delete" );
	self waittill( "death" );
	if ( isDefined( self ) )
	{
		wait 5;
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
}

horse_fidget_sounds()
{
	horse_fidget_1 = spawn( "script_origin", ( 11429, -9734, 239 ) );
	horse_fidget_2 = spawn( "script_origin", ( 11462, -9398, 254 ) );
	horse_fidget_1 playloopsound( "evt_horse_fidget_00" );
	horse_fidget_2 playloopsound( "evt_horse_fidget_01" );
	wait 200;
	horse_fidget_1 delete();
	horse_fidget_2 delete();
}

spawn_horse_charge()
{
	level.charge_btrs = spawn_vehicles_from_targetname( "horse_charge_btr" );
	level.krav_tank = spawn_vehicle_from_targetname( "krav_tank" );
	level.krav_tank setcandamage( 0 );
	level.krav_tank thread detach_from_path();
	level.vh_before_charge_uaz = spawn_vehicle_from_targetname( "uaz_soviet" );
	level.ai_rpg_muj = simple_spawn_single( "rpg_muj" );
	level.ai_rpg_muj.ignoreme = 1;
	level.ai_rpg_muj.ignoreall = 1;
	level.woods.vh_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.zhao.vh_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.player.vh_horse = spawn_rideable_horse( "mason_horse" );
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
		level.a_vh_horses[ i ] horse_panic();
		level.a_vh_horses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_horses[ i ].ai_rider ) )
		{
			level.a_vh_horses[ i ].ai_rider ai_horse_ride( level.a_vh_horses[ i ] );
		}
		level.a_vh_horses[ i ] thread go_path( getvehiclenode( "horse_path_" + i, "targetname" ) );
		if ( i >= 3 )
		{
			level.a_vh_horses[ i ] thread walk_into_position( i );
			if ( i == 3 )
			{
				level.a_vh_horses[ i ] veh_magic_bullet_shield( 1 );
				level.a_vh_horses[ i ].ai_rider.targetname = "muj_rider_shot";
				level.a_vh_horses[ i ].ai_rider magic_bullet_shield();
			}
			if ( i == 5 )
			{
				level.a_vh_horses[ i ] thread additional_walkin_horses();
			}
		}
		else
		{
			level.a_vh_horses[ i ] setspeedimmediate( 0 );
		}
		level.a_vh_horses[ i ] thread delete_vehicle_at_end_of_node();
		i++;
	}
	i = 0;
	while ( i < 6 )
	{
		a_s_horse_spawnpts[ i ] structdelete();
		i++;
	}
}

walk_into_position( i )
{
	self endon( "death" );
	nd_wait = getvehiclenode( "path_wait" + i, "targetname" );
	nd_wait waittill( "trigger" );
	self setspeedimmediate( 0 );
}

additional_walkin_horses()
{
	self endon( "death" );
	wait 1,5;
	level.a_vh_walkin_horses = [];
	nd_spawnpt = getvehiclenode( "horse_path_5", "targetname" );
	i = 1;
	while ( i < 3 )
	{
		wait 0,05;
		level.a_vh_walkin_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_walkin_horses[ i ].origin = nd_spawnpt.origin + ( 0, i * -44, 0 );
		level.a_vh_walkin_horses[ i ].angles = nd_spawnpt.angles;
		level.a_vh_walkin_horses[ i ] makevehicleunusable();
		level.a_vh_walkin_horses[ i ] horse_panic();
		level.a_vh_walkin_horses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_walkin_horses[ i ].ai_rider ) )
		{
			level.a_vh_walkin_horses[ i ].ai_rider ai_horse_ride( level.a_vh_walkin_horses[ i ] );
		}
		level.a_vh_walkin_horses[ i ] thread horse_walk_lineup();
		i++;
	}
}

horse_walk_lineup()
{
	self endon( "death" );
	self setspeed( 2, 1, 0,5 );
	self setvehgoalpos( self.origin + ( randomintrange( -265, -240 ), 0, 0 ), 1 );
	level waittill( "mig_fly_over" );
	if ( isDefined( self.riders[ 0 ] ) )
	{
		self.riders[ 0 ] delete();
	}
	wait 0,1;
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

detach_from_path()
{
	flag_wait( "e4_s5_player_horse_fall_started" );
	self vehicle_detachfrompath();
}

start_horse_charge_vehicles()
{
	level.woods setcandamage( 0 );
	level.zhao setcandamage( 0 );
	level.player.vh_horse thread player_start_charge();
	level.woods.vh_horse thread ai_start_charge();
	level.zhao.vh_horse thread ai_start_charge();
	level.horse_ai_anims[ level.sprint ][ 0 ] = array( %ai_horse_rider_sprint_f_rally_a, %ai_horse_rider_sprint_f_rally_b, %ai_horse_rider_sprint_f_rally_c, %ai_horse_rider_sprint_f );
	i = 0;
	while ( i < level.a_vh_horses.size )
	{
		level.a_vh_horses[ i ] thread ai_start_charge();
		i++;
	}
	level thread supplemental_horses_go();
	level thread extra_horses_left();
	level thread charge_ambient_explosions();
	level.charge_btrs[ 0 ] thread btr_attack();
	level.charge_btrs[ 1 ] thread btr_attack();
}

charge_ambient_explosions()
{
	wait 3,5;
	play_mortar_fx( "charge_ambient_explosion0", "exp_mortar" );
	wait 1,5;
	play_mortar_fx( "charge_ambient_explosion1", "exp_mortar" );
	level waittill( "start_hind" );
	play_mortar_fx( "charge_ambient_explosion4", "exp_mortar" );
	level waittill( "release_new_horses" );
	play_mortar_fx( "charge_ambient_explosion5", "exp_mortar" );
	level waittill( "start_2nd_set_of_extra_horses" );
	play_mortar_fx( "charge_ambient_explosion2", "exp_mortar" );
	wait 0,5;
	play_mortar_fx( "charge_ambient_explosion3", "exp_mortar" );
}

player_start_charge()
{
	level.player.vh_horse setbrake( 0 );
	level.player.vh_horse horse_rearback();
	level.player playsound( "evt_horse_charge" );
	level.player.vh_horse thread vehicle_go_path_on_node( "mason_horse_path" );
	tag_origin = level.player.body gettagorigin( "tag_camera" );
	tag_angles = level.player.body gettagangles( "tag_camera" );
	level.player.body play_fx( "fx_afgh_horse_charge_clouds", tag_origin - vectorScale( ( 0, 0, 0 ), 36 ), tag_angles, "stop_dust", 1, "tag_camera" );
	level.player thread vo_rally_troops();
}

vo_rally_troops()
{
	level endon( "horse_done" );
	a_vo = array( "maso_heeeyaaaah_0", "maso_come_on_0", "maso_faster_come_on_0", "maso_gimme_all_you_got_b_0", "maso_fast_as_you_can_com_0" );
	a_vo = array_randomize( a_vo );
	i = 0;
	while ( i < a_vo.size )
	{
		level.player waittill_attack_button_pressed();
		level.player say_dialog( a_vo[ i ] );
		n_wait = randomfloatrange( 1, 2 );
		wait n_wait;
		i++;
	}
}

horse_strafe_controls()
{
	level endon( "horse_fallen" );
	offset = ( 0, 0, 0 );
	strafe_vel = ( 0, 0, 0 );
	max_strafe_vel = ( 0, 264, 264 );
	while ( 1 )
	{
		stick = level.player getnormalizedmovement();
		if ( abs( offset[ 1 ] ) >= 50 && ( offset[ 1 ] * stick[ 1 ] ) >= 0 )
		{
		}
		else
		{
		}
		desired_vel_y = stick[ 1 ] * max_strafe_vel[ 1 ];
		if ( abs( offset[ 2 ] ) >= 0 && ( offset[ 2 ] * stick[ 0 ] ) >= 0 )
		{
		}
		else
		{
		}
		desired_vel_z = stick[ 0 ] * max_strafe_vel[ 2 ];
		strafe_vel_y = difftrack( desired_vel_y, strafe_vel[ 1 ], 2, 0,05 );
		strafe_vel_z = difftrack( desired_vel_z, strafe_vel[ 2 ], 2, 0,05 );
		strafe_vel = ( 0, strafe_vel_y, strafe_vel_z );
		if ( 0 )
		{
			a = angleClamp180( level.player.angles[ 1 ] );
			path_a = self.pathlookpos - self.pathpos;
			path_a = vectoangles( path_a );
			delta = angleClamp180( path_a - a );
			a = ( 0, delta, 0 );
			forward = anglesToForward( a );
			right = anglesToRight( a );
			v = ( forward * strafe_vel[ 2 ] ) - ( right * strafe_vel[ 1 ] );
		}
		else
		{
			v = strafe_vel;
		}
		offset += v * 0,05;
		self pathfixedoffset( offset );
		wait 0,05;
	}
}

ai_start_charge()
{
	if ( self == level.woods.vh_horse )
	{
		wait 2,3;
	}
	else if ( self == level.zhao.vh_horse )
	{
		wait 2,6;
	}
	else
	{
		wait 2,75;
	}
	self resumespeed( 5 );
}

supplemental_horses_go()
{
	n_animlength = getanimlength( level.horse_anims[ level.rearback ] );
	wait ( n_animlength + 0,25 );
	a_s_spawnpts = [];
	i = 0;
	while ( i < 6 )
	{
		a_s_spawnpts[ i ] = getstruct( "horse_supplement_spawnpt" + i, "targetname" );
		i++;
	}
	level.a_vh_supphorses = [];
	i = 0;
	while ( i < a_s_spawnpts.size )
	{
		wait 0,05;
		level.a_vh_supphorses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_supphorses[ i ].origin = a_s_spawnpts[ i ].origin;
		level.a_vh_supphorses[ i ].angles = a_s_spawnpts[ i ].angles;
		level.a_vh_supphorses[ i ] makevehicleunusable();
		level.a_vh_supphorses[ i ] thread delete_vehicle_at_end_of_node();
		level.a_vh_supphorses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_supphorses[ i ].ai_rider ) )
		{
			level.a_vh_supphorses[ i ].ai_rider ai_horse_ride( level.a_vh_supphorses[ i ] );
		}
		level.a_vh_supphorses[ i ] thread go_path( getvehiclenode( "horse_suppath_" + i, "targetname" ) );
		i++;
	}
	i = 0;
	while ( i < 6 )
	{
		a_s_spawnpts[ i ] structdelete();
		i++;
	}
	level waittill( "release_new_horses" );
	wait 1;
	a_s_spawnpts = [];
	i = 0;
	while ( i < 4 )
	{
		a_s_spawnpts[ i ] = getvehiclenode( "left_horse_path_" + i, "targetname" );
		i++;
	}
	level.a_vh_extrahorses = [];
	i = 0;
	while ( i < a_s_spawnpts.size )
	{
		wait 0,05;
		level.a_vh_extrahorses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_extrahorses[ i ].origin = a_s_spawnpts[ i ].origin;
		level.a_vh_extrahorses[ i ].angles = a_s_spawnpts[ i ].angles;
		level.a_vh_extrahorses[ i ] makevehicleunusable();
		level.a_vh_extrahorses[ i ] thread delete_vehicle_at_end_of_node();
		level.a_vh_extrahorses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_extrahorses[ i ].ai_rider ) )
		{
			level.a_vh_extrahorses[ i ].ai_rider ai_horse_ride( level.a_vh_extrahorses[ i ] );
		}
		level.a_vh_extrahorses[ i ] thread go_path( getvehiclenode( "left_horse_path_" + i, "targetname" ) );
		i++;
	}
	wait 4,5;
	a_s_spawnpts = [];
	i = 0;
	while ( i < 5 )
	{
		a_s_spawnpts[ i ] = getvehiclenode( "last_horse_" + i, "targetname" );
		i++;
	}
	level.a_vh_lasthorses = [];
	i = 0;
	while ( i < a_s_spawnpts.size )
	{
		wait 0,05;
		level.a_vh_lasthorses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_lasthorses[ i ].origin = a_s_spawnpts[ i ].origin;
		level.a_vh_lasthorses[ i ].angles = a_s_spawnpts[ i ].angles;
		level.a_vh_lasthorses[ i ] makevehicleunusable();
		level.a_vh_lasthorses[ i ] thread delete_vehicle_at_end_of_node();
		level.a_vh_lasthorses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_lasthorses[ i ].ai_rider ) )
		{
			level.a_vh_lasthorses[ i ].ai_rider ai_horse_ride( level.a_vh_lasthorses[ i ] );
		}
		level.a_vh_lasthorses[ i ] thread go_path( getvehiclenode( "last_horse_" + i, "targetname" ) );
		i++;
	}
	a_s_spawnpts = undefined;
}

extra_horses_left()
{
	level waittill( "mig_fly_over" );
	s_spawnpt = getvehiclenode( "horse_extra_left", "targetname" );
	level.a_vh_extralefthorses = [];
	i = 0;
	while ( i < 4 )
	{
		wait 0,05;
		level.a_vh_extralefthorses[ i ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
		level.a_vh_extralefthorses[ i ].origin = s_spawnpt.origin;
		level.a_vh_extralefthorses[ i ].angles = s_spawnpt.angles;
		level.a_vh_extralefthorses[ i ] pathfixedoffset( ( 0, i * -40, 0 ) );
		level.a_vh_extralefthorses[ i ] makevehicleunusable();
		level.a_vh_extralefthorses[ i ] thread delete_vehicle_at_end_of_node();
		level.a_vh_extralefthorses[ i ].ai_rider = get_muj_ai();
		if ( isDefined( level.a_vh_extralefthorses[ i ].ai_rider ) )
		{
			level.a_vh_extralefthorses[ i ].ai_rider ai_horse_ride( level.a_vh_extralefthorses[ i ] );
		}
		level.a_vh_extralefthorses[ i ] thread go_path( getvehiclenode( "horse_extra_left", "targetname" ) );
		i++;
	}
}

horses_after_krav_down()
{
	level endon( "charge_done" );
	s_spawnpt = getstruct( "reinforcement_spawnpt", "targetname" );
	level.a_vh_krav_horses = [];
	while ( level.a_vh_krav_horses.size < 10 )
	{
		n_group = randomintrange( 3, 6 );
		i = 0;
		while ( i < n_group )
		{
			if ( level.a_vh_krav_horses.size >= 10 )
			{
				return;
			}
			current_index = level.a_vh_krav_horses.size;
			level.a_vh_krav_horses[ current_index ] = spawn_vehicle_from_targetname( "horse_afghan_low" );
			level.a_vh_krav_horses[ current_index ].origin = s_spawnpt.origin;
			level.a_vh_krav_horses[ current_index ].angles = s_spawnpt.angles;
			level.a_vh_krav_horses[ current_index ].ai_rider = get_muj_ai();
			if ( isDefined( level.a_vh_krav_horses[ current_index ].ai_rider ) )
			{
				level.a_vh_krav_horses[ current_index ].ai_rider ai_horse_ride( level.a_vh_krav_horses[ current_index ] );
			}
			level.a_vh_krav_horses[ current_index ] thread horses_after_krav_behavior();
			wait randomfloatrange( 0,3, 1,3 );
			i++;
		}
		wait randomintrange( 6, 8 );
	}
	s_spawnpt structdelete();
	s_spawnpt = undefined;
}

horses_after_krav_behavior()
{
	self endon( "death" );
	self thread delete_vehicle_at_end_of_node();
	nd_start = getvehiclenode( "start_krav_down1", "targetname" );
	if ( cointoss() )
	{
		nd_start = getvehiclenode( "start_krav_down2", "targetname" );
	}
	self pathfixedoffset( ( 0, randomintrange( -50, 50 ), 0 ) );
	self makevehicleunusable();
	self thread go_path( nd_start );
}
