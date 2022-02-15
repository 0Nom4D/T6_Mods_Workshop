#include maps/afghanistan_intro_rebel_base;
#include maps/_friendlyfire;
#include maps/_patrol;
#include maps/_horse_rider;
#include maps/createart/afghanistan_art;
#include maps/_audio;
#include maps/_music;
#include maps/_horse;
#include maps/_dialog;
#include maps/_objectives;
#include maps/_vehicle;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "critter" );
#using_animtree( "horse" );
#using_animtree( "generic_human" );

init_flags()
{
	flag_init( "zhao_got_to_base" );
	flag_init( "woods_got_to_base" );
	flag_init( "skipto_horse_intro" );
	flag_init( "cleanup_ride" );
}

skipto_intro()
{
	skipto_setup();
	level.woods = init_hero( "woods" );
	level.zhao = init_hero( "zhao" );
	remove_woods_facemask_util();
	s_player_horse = getstruct( "horse_player_pos", "targetname" );
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_player_horse.origin;
	level.mason_horse.angles = s_player_horse.angles;
	wait 0,05;
	skipto_teleport( "skipto_horse_intro", level.heroes );
	woods_zhao_trigger = getent( "wood_zhao_wait_canyon_wait_trigger", "targetname" );
	woods_zhao_trigger triggeroff();
	post_intro_blocker_trigger = getent( "post_intro_blocker_trigger", "script_noteworthy" );
	post_intro_blocker_trigger triggeroff();
	insta_fail_trigger = getent( "e1_intro_insta_fail_trigger", "targetname" );
	insta_fail_trigger thread insta_fail_trigger();
	flag_set( "skipto_horse_intro" );
	level thread too_far_fail_managment();
	s_player_horse structdelete();
	s_player_horse = undefined;
	flag_wait( "afghanistan_gump_intro" );
	exploder( 300 );
}

main()
{
/#
	iprintln( "Horse Intro" );
#/
	level thread e2_objective();
	level thread setup_tank();
	level thread player_on_horse_trigger();
	level.mason_horse thread wait_until_player_on_horse();
	level thread start_vulture_shooting_event();
	level thread slow_down_player_horse();
	level thread music_horse_watcher();
	level thread setup_ride_vignettes();
	start_sprinting_tutorial();
}

music_horse_watcher()
{
	level.mason_horse waittill( "mounting_horse" );
	wait 0,6;
	level thread maps/_audio::switch_music_wait( "AFGHAN_HORSE_RIDE", 5 );
}

e2_objective()
{
	set_objective( level.obj_initial, undefined, "deactivate" );
	wait_network_frame();
	set_objective( level.obj_afghan_bc3, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
}

slow_down_player_horse()
{
	trigger_wait( "turn_down_player_horse_speed" );
	level.mason_horse sprint_end( level.player );
	allow_horse_sprint( 0 );
	override_player_horse_speed( 20 );
	maps/createart/afghanistan_art::rebel_entrance();
	wait 2;
	override_player_horse_speed( 10 );
	level thread maps/_audio::switch_music_wait( "AFGHAN_BASE_CALM", 15 );
}

get_horse_rider( ai_rider, nd_start )
{
	ai_rider enter_vehicle( self );
	wait 0,05;
	self thread go_path( nd_start );
}

end_horse_charge_scenes()
{
	level endon( "player_mounted_horse" );
	end_scene( "e1_zhao_horse_charge_woods_intro_idle" );
	end_scene( "e1_zhao_horse_charge_idle" );
	end_scene( "e1_zhao_horse_charge_woods_intro" );
	end_scene( "e1_zhao_horse_charge" );
}

woods_nag_mason_about_horse()
{
	level endon( "player_mounted_horse" );
	wait 60;
	level.woods say_dialog( "wood_it_s_too_far_to_walk_0" );
}

wait_until_player_on_horse()
{
	level thread woods_nag_mason_about_horse();
	level.mason_horse ent_flag_wait( "mounting_horse" );
	level.mason_horse.dismount_enabled = 0;
	level.mason_horse makevehicleunusable();
	wait 0,5;
	if ( isDefined( level.woods.vh_my_horse ) )
	{
		level.woods.vh_my_horse.delete_on_death = 1;
		level.woods.vh_my_horse notify( "death" );
		if ( !isalive( level.woods.vh_my_horse ) )
		{
			level.woods.vh_my_horse delete();
		}
		level.woods setgoalpos( level.woods.origin );
	}
	if ( isDefined( level.zhao.vh_my_horse ) )
	{
		level.zhao.vh_my_horse.delete_on_death = 1;
		level.zhao.vh_my_horse notify( "death" );
		if ( !isalive( level.zhao.vh_my_horse ) )
		{
			level.zhao.vh_my_horse delete();
		}
		level.zhao setgoalpos( level.zhao.origin );
	}
	setup_ally_horses();
	set_objective( level.obj_afghan_bc3a, undefined, "done" );
	level notify( "player_mounted_horse" );
	override_player_horse_speed( 10 );
	level.current_intro_horse_override = 10;
	end_horse_charge_scenes();
	intro_fail_trigger = getent( "e1_intro_fail_trigger", "script_noteworthy" );
	intro_fail_trigger delete();
	insta_fail_trigger = getent( "e1_intro_insta_fail_trigger", "targetname" );
	insta_fail_trigger delete();
	woods_zhao_trigger = getent( "wood_zhao_wait_canyon_wait_trigger", "targetname" );
	woods_zhao_trigger triggeron();
	set_objective( level.obj_afghan_bc3, level.zhao, "follow" );
	level.zhao.vh_my_horse setneargoalnotifydist( 64 );
	level.zhao.vh_my_horse.dontunloadonend = 1;
	level.zhao.vh_my_horse thread wait_for_player( "zhao_wait" );
	level.zhao thread get_off_horse_at_end_of_path();
	level.woods.vh_my_horse setneargoalnotifydist( 64 );
	level.woods.vh_my_horse.dontunloadonend = 1;
	level.woods.vh_my_horse thread wait_for_player( "wood_wait" );
	level.woods thread get_off_horse_at_end_of_path();
	level thread dismount_message();
	if ( flag( "skipto_horse_intro" ) )
	{
		level.woods.vh_my_horse notify( "groupedanimevent" );
		level.woods notify( "ride" );
		level.woods maps/_horse_rider::ride_and_shoot( level.woods.vh_my_horse );
		level.zhao.vh_my_horse notify( "groupedanimevent" );
		level.zhao notify( "ride" );
		level.zhao maps/_horse_rider::ride_and_shoot( level.zhao.vh_my_horse );
	}
	level thread adjust_player_horse_speed_based_on_closeness_to_goal();
	v_base_pos = getent( "krav_capture_hudson_pos", "targetname" );
	i = 0;
	while ( i < 4 )
	{
		level waittill( "slowdown" + i );
		if ( abs( distance( level.zhao.origin, level.player.origin ) ) > 1400 && abs( distance( level.zhao.origin, v_base_pos.origin ) ) < abs( distance( level.player.origin, v_base_pos.origin ) ) )
		{
			level.zhao.vh_my_horse setspeed( 0, 15, 10 );
			level.woods.vh_my_horse setspeed( 0, 15, 10 );
			if ( i < 3 )
			{
				level wait_till_player_close_enough( 1400 );
			}
			else
			{
				level wait_till_player_close_enough( 1000 );
			}
			level.zhao.vh_my_horse resumespeed( 10 );
			wait 0,1;
			level.woods.vh_my_horse resumespeed( 10 );
		}
		i++;
	}
}

setup_ally_horses()
{
	nd_woods = getvehiclenode( "e2_woods_horse_spline", "targetname" );
	nd_zhao = getvehiclenode( "e2_zhao_horse_spline", "targetname" );
	level.woods.vh_my_horse = getent( "woods_horse", "targetname" );
	if ( isDefined( level.woods.vh_my_horse ) )
	{
		level.woods.vh_my_horse.delete_on_death = 1;
		level.woods.vh_my_horse notify( "death" );
		if ( !isalive( level.woods.vh_my_horse ) )
		{
			level.woods.vh_my_horse delete();
		}
	}
	level.woods.vh_my_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.zhao.vh_my_horse = getent( "zhao_horse", "targetname" );
	if ( !isDefined( level.zhao.vh_my_horse ) )
	{
		level.zhao.vh_my_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	}
	level.woods.vh_my_horse thread get_horse_rider( level.woods, nd_woods );
	level.zhao.vh_my_horse thread get_horse_rider( level.zhao, nd_zhao );
	level.woods.vh_my_horse.animname = "woods_horse";
	level.zhao.vh_my_horse.animname = "zhao_horse";
	level.woods.vh_my_horse makevehicleunusable();
	level.zhao.vh_my_horse makevehicleunusable();
}

player_on_horse_trigger()
{
	level endon( "first_rebel_base_visit" );
	while ( 1 )
	{
		if ( level.player is_on_horseback() )
		{
			trigger_on( "player_on_horse" );
		}
		else
		{
			if ( !level.player is_on_horseback() )
			{
				trigger_off( "player_on_horse" );
			}
		}
		wait 0,05;
	}
}

wait_for_player( node )
{
	vehicle_node_wait( node, "script_noteworthy" );
	self setspeed( 0, 5, 5 );
	trigger_wait( "player_on_horse" );
	self resumespeed( 5 );
	level.current_intro_horse_override = undefined;
	level allow_horse_sprint( 0 );
}

go_to_vulture()
{
	self clearvehgoalpos();
	if ( self == level.zhao_horse )
	{
		zhao_vulture_struct = getstruct( "zhao_vulture_stop", "targetname" );
		self setspeed( 30, 15, 10 );
		self setvehgoalpos( zhao_vulture_struct.origin, 0, 1 );
		self waittill_any( "near_goal" );
		self setbrake( 1 );
	}
	else
	{
		wait 0,25;
		woods_vulture_struct = getstruct( "woods_vulture_path", "targetname" );
		self setspeed( 30, 15, 10 );
		self setvehgoalpos( woods_vulture_struct.origin, 1, 1 );
		self waittill_any( "near_goal" );
		woods_vulture_struct2 = getstruct( "woods_vulture_stop", "targetname" );
		self setvehgoalpos( woods_vulture_struct2.origin, 1, 1 );
		self waittill_any( "near_goal" );
		self setbrake( 1 );
	}
	zhao_vulture_struct structdelete();
	zhao_vulture_struct = undefined;
	woods_vulture_struct structdelete();
	woods_vulture_struct = undefined;
	woods_vulture_struct2 structdelete();
	woods_vulture_struct2 = undefined;
}

start_vulture_shooting_event()
{
	level endon( "vulture_flew_away" );
	trigger_wait( "vulture_spawning_trigger" );
	level thread run_tank_scene();
	vulture_start = getstructarray( "vulture_starting_struct", "targetname" );
	i = 0;
	while ( i < vulture_start.size )
	{
		vulture_start[ i ] structdelete();
		i++;
	}
}

setup_vulture( start )
{
	self endon( "death" );
	end_struct = getstruct( start.target, "targetname" );
	self.origin = start.origin;
	self.angles = start.angles;
	self.linked_to = spawn( "script_model", start.origin );
	self.linked_to setmodel( "tag_origin" );
	self linkto( self.linked_to );
	level thread ai_gets_too_close_to_vulture();
	level.player waittill( "weapon_fired" );
	self playsound( "evt_vultures_fly" );
	self.flight = 1;
	self notify( "flying" );
	self.linked_to moveto( end_struct.origin, 17 );
	self.linked_to rotateyaw( self.angles[ 1 ] + end_struct.angles[ 1 ], 0,35 );
	wait 17;
	level notify( "vulture_flew_away" );
	self notify( "deleted" );
	self delete();
}

ai_gets_too_close_to_vulture()
{
	trigger_wait( "vulture_run_away_trigger" );
	level.player notify( "weapon_fired" );
}

start_sprinting_tutorial()
{
	trigger_wait( "zhao_horse_sprint_trigger" );
	level thread sprint_message();
	prep_base_vignettes();
	level notify( "horse_intro_allow_sprint" );
	if ( isDefined( level.intro_horsemen ) )
	{
		array_delete( level.intro_horsemen );
	}
	level.intro_horsemen = undefined;
	level thread cleanup_ride();
	level thread run_muj_lookout_animations();
	level thread run_muj_wall_animations();
	level thread run_muj_runout_animations();
	wait 0,25;
	level thread run_muj_window_animations();
	level thread run_muj_stinger_animations();
	level thread run_muj_stacker_1_animations();
	level thread run_muj_stacker_2_animations();
	wait 0,25;
	level thread run_scene( "e2_cooking_muj" );
	level thread run_scene( "e2_drum_burner" );
	level thread run_scene( "e2_gunsmith" );
	wait 0,25;
	level thread run_scene( "e2_smokers" );
	ai_ammoguy = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_ammoguy.animname = "muj_ammo";
	ai_ammoguy.script_noteworthy = "e2_muj_clean_up";
	ai_generator = get_muj_ai();
	if ( isDefined( ai_generator ) )
	{
		ai_generator.animname = "muj_generator";
		ai_generator.script_noteworthy = "e2_muj_clean_up";
	}
	level thread ammo_guy_scene();
	level thread run_scene( "e2_generator" );
	ai_stacker_3 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_stacker_3.animname = "muj_stacker_3";
	ai_stacker_3.script_noteworthy = "e2_muj_clean_up";
	level thread run_scene( "e2_stacker_3" );
	level thread run_scene( "e2_rooftop_guys" );
	wait 0,25;
	level thread setup_base_horses();
	level thread base_horse_rideout();
	m_gunsmith = get_model_or_models_from_scene( "e2_gunsmith", "muj_hammer" );
	m_gunsmith attach( "p_glo_tools_hammer", "tag_weapon_left" );
	m_drum_burner = get_model_or_models_from_scene( "e2_drum_burner", "muj_drum_burner" );
	m_drum_burner attach( "p6_Afghanistan_herding_staff", "tag_weapon_left" );
	m_rooftop_array = get_model_or_models_from_scene( "e2_rooftop_guys" );
	_a535 = m_rooftop_array;
	_k535 = getFirstArrayKey( _a535 );
	while ( isDefined( _k535 ) )
	{
		rooftop_guy = _a535[ _k535 ];
		rooftop_guy attach( "t6_wpn_ar_ak47_prop", "tag_weapon_right" );
		_k535 = getNextArrayKey( _a535, _k535 );
	}
	if ( level.press_demo )
	{
		level thread press_demo_fadeout_watcher();
	}
	else
	{
		level.zhao thread track_zhao_and_woods_unload_horse();
		level.woods thread track_zhao_and_woods_unload_horse();
		flag_wait( "zhao_got_to_base" );
		flag_wait( "woods_got_to_base" );
	}
}

ammo_guy_scene()
{
	while ( 1 )
	{
		run_scene( "e2_ammo" );
		if ( flag( "map_room_started" ) )
		{
			break;
		}
		else run_scene( "e2_ammo02" );
		if ( flag( "map_room_started" ) )
		{
			break;
		}
		else run_scene( "e2_ammo03" );
		if ( flag( "map_room_started" ) )
		{
			break;
		}
		else run_scene( "e2_ammo04" );
		if ( flag( "map_room_started" ) )
		{
			break;
		}
		else
		{
			end_scene( "e2_ammo" );
			end_scene( "e2_ammo02" );
			end_scene( "e2_ammo03" );
			end_scene( "e2_ammo04" );
			delete_scene( "e2_ammo" );
			delete_scene( "e2_ammo02" );
			delete_scene( "e2_ammo03" );
			delete_scene( "e2_ammo04" );
		}
	}
	end_scene( "e2_ammo" );
	end_scene( "e2_ammo02" );
	end_scene( "e2_ammo03" );
	end_scene( "e2_ammo04" );
	delete_scene_all( "e2_ammo", 1 );
	delete_scene_all( "e2_ammo02", 1 );
	delete_scene_all( "e2_ammo03", 1 );
	delete_scene_all( "e2_ammo04", 1 );
}

cleanup_ride()
{
	trigger_wait( "trigger_ride_cleanup" );
	cleanup_ride_vignettes();
}

base_horse_rideout()
{
	a_s_spawnpts = [];
	i = 1;
	while ( i < 5 )
	{
		a_s_spawnpts[ i ] = getstruct( "base_horse_spawnpt" + i, "targetname" );
		i++;
	}
	a_nd_horses = [];
	i = 1;
	while ( i < 5 )
	{
		a_nd_horses[ i ] = getvehiclenode( "base_horse_node" + i, "targetname" );
		i++;
	}
	a_vh_horses = [];
	i = 1;
	while ( i < 5 )
	{
		a_vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		a_vh_horses[ i ] setmodel( a_s_spawnpts[ i ].script_string );
		a_vh_horses[ i ].origin = a_s_spawnpts[ i ].origin;
		a_vh_horses[ i ].angles = a_s_spawnpts[ i ].angles;
		a_vh_horses[ i ] makevehicleunusable();
		a_vh_horses[ i ] thread go_path( a_nd_horses[ i ] );
		i++;
	}
	sp_rideout_guy = getent( "muj_assault", "targetname" );
	a_ai_riders = [];
	i = 1;
	while ( i < 5 )
	{
		a_ai_riders[ i ] = sp_rideout_guy spawn_ai( 1 );
		a_ai_riders[ i ].script_noteworthy = "e2_muj_clean_up";
		a_ai_riders[ i ] enter_vehicle( a_vh_horses[ i ] );
		a_vh_horses[ i ] notify( "groupedanimevent" );
		a_ai_riders[ i ] notify( "ride" );
		a_ai_riders[ i ] maps/_horse_rider::ride_and_shoot( a_vh_horses[ i ] );
		i++;
	}
	trigger_wait( "demo_fade_trigger" );
	i = 1;
	while ( i < 5 )
	{
		if ( isalive( a_ai_riders[ i ] ) )
		{
			a_ai_riders[ i ] delete();
		}
		a_vh_horses[ i ].delete_on_death = 1;
		a_vh_horses[ i ] notify( "death" );
		if ( !isalive( a_vh_horses[ i ] ) )
		{
			a_vh_horses[ i ] delete();
		}
		i++;
	}
	a_vh_horses = undefined;
	i = 1;
	while ( i < 5 )
	{
		a_s_spawnpts[ i ] structdelete();
		i++;
	}
	level thread delete_section1_ride_scenes();
}

track_zhao_and_woods_unload_horse()
{
	self.vh_my_horse waittill( "unloaded" );
	if ( self == level.zhao )
	{
		flag_set( "zhao_got_to_base" );
		self set_fixednode( 0 );
	}
	if ( self == level.woods )
	{
		flag_set( "woods_got_to_base" );
		self set_fixednode( 0 );
	}
}

run_muj_lookout_animations()
{
	level endon( "demo_fade" );
	level thread run_scene( "e2_tower_lookout_startidl" );
	wait 0,05;
	m_lookout1 = get_model_or_models_from_scene( "e2_tower_lookout_startidl", "muj_lookout_1" );
	m_lookout2 = get_model_or_models_from_scene( "e2_tower_lookout_startidl", "muj_lookout_2" );
	m_lookout1 attach( "com_hand_radio", "tag_weapon_left" );
	m_lookout2 attach( "com_hand_radio", "tag_weapon_left" );
	trigger_wait( "muj_lookout_trigger" );
	level run_scene( "e2_tower_lookout_follow" );
	level thread run_scene( "e2_tower_lookout_endidl" );
}

run_muj_wall_animations()
{
	level thread give_guns_to_walltop_dudes();
	level thread run_scene( "e2_walltop_start" );
	trigger_wait( "vulture_run_away_trigger" );
	level run_scene( "e2_walltop_lookout" );
	level thread run_scene( "e2_walltop_end" );
}

give_guns_to_walltop_dudes()
{
	flag_wait( "e2_walltop_start_started" );
	a_walltop_dudes = get_model_or_models_from_scene( "e2_walltop_start" );
	_a747 = a_walltop_dudes;
	_k747 = getFirstArrayKey( _a747 );
	while ( isDefined( _k747 ) )
	{
		m_walltop_dudes = _a747[ _k747 ];
		m_walltop_dudes attach_weapon( "ak47_sp" );
		_k747 = getNextArrayKey( _a747, _k747 );
	}
}

run_muj_runout_animations()
{
	level thread e2_runout_startidl( "1", 1 );
	level thread e2_runout_startidl( "2", 2 );
	level thread e2_runout_startidl( "3", 3 );
	level thread e2_runout_startidl( "4", 4 );
	level thread e2_runout_startidl( "5", 5 );
	level thread e2_runout_startidl( "6", 6 );
}

e2_runout_startidl( num, wait_time )
{
	level thread run_scene( "e2_runout_startidl_" + num );
	wait 0,05;
	a_ai = get_ais_from_scene( "e2_runout_startidl_" + num )[ 0 ];
	str_nodename = "muj_runout_" + num;
	goto_node = getnode( str_nodename, "targetname" );
	a_ai setgoalnode( goto_node );
	wait wait_time;
	trigger_wait( "muj_lookout_trigger" );
	level run_scene( "e2_runout_run_" + num );
}

run_muj_window_animations()
{
	level thread run_scene( "e2_window_startidl" );
	trigger_wait( "muj_lookout_trigger" );
	level run_scene( "e2_window_follow" );
}

run_muj_stinger_animations()
{
	level endon( "demo_fade" );
	trigger_wait( "muj_lookout_trigger" );
	ai_stingers_1 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_stingers_1.animname = "muj_stingers_1";
	ai_stingers_1.script_noteworthy = "e2_muj_clean_up";
	ai_stingers_2 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_stingers_2.animname = "muj_stingers_2";
	ai_stingers_2.script_noteworthy = "e2_muj_clean_up";
	run_scene( "e2_stinger_move" );
	level thread run_scene( "e2_stinger_endidl" );
}

run_muj_herder_animations()
{
	level endon( "demo_fade" );
	level thread run_scene( "e2_herder_startidl" );
	trigger_wait( "vulture_run_away_trigger" );
	wait 2;
	level run_scene( "e2_herder_move" );
	level thread run_scene( "e2_herder_endidl" );
}

run_muj_stacker_1_animations()
{
	level endon( "demo_fade" );
	ai_stacker_1 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_stacker_1.animname = "muj_stacker_1";
	ai_stacker_1.script_noteworthy = "e2_muj_clean_up";
	run_scene( "e2_stacker_carry_1" );
	level thread run_scene( "e2_stacker_endidl" );
}

run_muj_stacker_2_animations()
{
	ai_stacker_2 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_stacker_2.animname = "muj_stacker_2";
	ai_stacker_2.script_noteworthy = "e2_muj_clean_up";
	level thread run_scene( "e2_stacker_carry_2" );
	level waittill( "stacker_2_carry" );
	run_scene( "e2_stacker_main_2" );
}

sprint_message()
{
	level.zhao say_dialog( "we_must_hurry_w_008", 0,3 );
	screen_message_create( &"AFGHANISTAN_SPRINT" );
	sprint_timer = 10;
	allow_horse_sprint( 1 );
	level.woods thread say_dialog( "wood_kick_it_up_a_gear_m_0" );
	level thread sprint_or_not_vo();
	while ( !level.player sprintbuttonpressed() && sprint_timer > 0 )
	{
		sprint_timer -= 0,05;
		wait 0,05;
	}
	if ( sprint_timer > 0 )
	{
		level.player thread say_dialog( "maso_hya_hya_0", 0 );
	}
	screen_message_delete();
}

sprint_or_not_vo()
{
	level endon( "sprint_vo_delete" );
	wait 10;
	if ( level.woods is_behind( level.player.my_horse.origin ) )
	{
		level.woods say_dialog( "wood_dammit_mason_can_t_0" );
	}
}

dismount_message()
{
	trigger_wait( "demo_fade_trigger" );
	override_player_horse_speed( 4 );
	level.mason_horse.dismount_enabled = 1;
	level.mason_horse makevehicleusable();
	if ( level.player is_on_horseback() && !level.press_demo )
	{
		screen_message_create( &"AFGHANISTAN_HORSE_DISMOUNT" );
		n_timer = 80;
		while ( 1 )
		{
			wait 0,05;
			n_timer--;

			if ( n_timer < 1 )
			{
				level clientnotify( "cease_aiming" );
				level.player disableusability();
				level.mason_horse use_horse( level.player );
				wait_network_frame();
				if ( isDefined( level.mason_horse.being_dismounted ) && level.mason_horse.being_dismounted )
				{
					break;
				}
				else level.player enableusability();
			}
			if ( level.player usebuttonpressed() )
			{
				level.player disableusability();
				level.mason_horse use_horse( level.player );
				wait_network_frame();
				if ( isDefined( level.mason_horse.being_dismounted ) && level.mason_horse.being_dismounted )
				{
					break;
				}
				else level.player enableusability();
			}
		}
		screen_message_delete();
	}
	while ( level.player is_on_horseback() )
	{
		wait 0,05;
	}
	if ( !level.press_demo )
	{
		level.mason_horse makevehicleunusable();
	}
	level.player enableusability();
	level.player setlowready( 1 );
	level.player thread player_walk_speed_adjustment( level.zhao, "reset_walk_speed", 256, 2048, 0,35, 0,7 );
	trigger_wait( "trigger_map_room_table" );
}

get_off_horse_at_end_of_path()
{
	self.vh_my_horse waittill( "reached_end_node" );
	self notify( "stop_riding" );
	self.vh_my_horse vehicle_unload( 0,05 );
	self.vh_my_horse waittill( "unloaded" );
}

go_to_rebel_base()
{
	self clearvehgoalpos();
	self setbrake( 0 );
	if ( self == level.zhao_horse )
	{
		level.zhao_horse setneargoalnotifydist( 64 );
		self setspeed( 35, 15, 10 );
		self setvehgoalpos( ( 6040, -7152, 112 ), 1, 0 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 9720, -9464, 40 ), 1 );
		self waittill( "near_goal" );
		self setspeed( 20, 15, 10 );
		self setvehgoalpos( ( 12856, -9520, -112 ), 1 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 13560, -10104, -88 ), 1 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 14872, -10184, -96 ), 1 );
		self waittill( "near_goal" );
		self setbrake( 1 );
		level.zhao notify( "stop_riding" );
		self vehicle_unload( 0,05 );
		self waittill( "unloaded" );
		flag_set( "zhao_got_to_base" );
	}
	else
	{
		level.wood_horse setneargoalnotifydist( 64 );
		self setspeed( 34, 15, 10 );
		self setvehgoalpos( ( 6100, -7052, 112 ), 1, 1 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 9620, -9564, 40 ), 1 );
		self waittill( "near_goal" );
		self setspeed( 20, 15, 10 );
		self setvehgoalpos( ( 12856, -9520, -112 ), 1 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 13560, -10104, -88 ), 1 );
		self waittill( "near_goal" );
		self setvehgoalpos( ( 14752, -10184, -96 ), 1 );
		self waittill( "near_goal" );
		self setbrake( 1 );
		level.woods notify( "stop_riding" );
		level.woods change_movemode( "cqb_walk" );
		self vehicle_unload( 0,05 );
		self waittill( "unloaded" );
		flag_set( "woods_got_to_base" );
	}
}

setup_tank()
{
	trigger_wait( "muj_lookout_trigger" );
	level.muj_tank = spawn_vehicle_from_targetname( "tank_muj" );
	tank_starting = getvehiclenode( "ally_tank_start_node", "targetname" );
	level thread setup_tank_guy();
	sound_ent = spawn( "script_origin", level.muj_tank.origin );
	sound_ent linkto( level.muj_tank, "tag_origin" );
	sound_ent playloopsound( "evt_village_tank_loop", 2 );
	level.muj_tank go_path( tank_starting );
	sound_ent stoploopsound( 0,25 );
	sound_ent playsound( "evt_village_tank_stop" );
	level waittill( "first_rebel_base_visit" );
	sound_ent delete();
}

setup_tank_guy()
{
	level thread run_scene( "e2_tank_guy" );
	ai_tank_guy = get_ais_from_scene( "e2_tank_guy" );
	ai_tank_guy[ 0 ] waittill( "goal" );
}

setup_vultures()
{
	level.vultures = [];
	level.vulture[ 0 ] = getent( "vulture1", "targetname" );
	level.vulture[ 1 ] = getent( "vulture2", "targetname" );
	level.vulture[ 2 ] = getent( "vulture3", "targetname" );
	i = 0;
	while ( i < 3 )
	{
		level.vulture[ i ] useanimtree( -1 );
		level.vulture[ i ].flight = 0;
		level.vulture[ i ] enableaimassist();
		level.vulture[ i ] thread vulture_anim_loop_ground();
		level.vulture[ i ] thread vulture_anim_loop_air();
		level.vulture[ i ] thread vulture_anim_death( i + 1 );
		i++;
	}
}

vulture_anim_loop_ground()
{
	self endon( "deleted" );
	self endon( "death" );
	self endon( "flying" );
	self setcandamage( 1 );
	self.health = 99999;
	while ( 1 )
	{
		rand = randomint( 100 );
		self clearanim( %root, 0 );
		if ( rand < 70 )
		{
			self setanim( %a_vulture_idle, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_idle );
		}
		else
		{
			self setanim( %a_vulture_idle_twitch, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_idle_twitch );
		}
		wait anim_durration;
	}
}

vulture_anim_loop_air()
{
	self endon( "deleted" );
	self endon( "death" );
	self waittill( "flying" );
	while ( 1 )
	{
		self clearanim( %root, 0 );
		self setanim( %a_vulture_fly, 1, 0, 1 );
		anim_durration = getanimlength( %a_vulture_fly );
		wait anim_durration;
	}
}

vulture_anim_death( index )
{
	self endon( "deleted" );
	self waittill( "damage" );
	self notify( "death" );
	self clearanim( %root, 0 );
	rand = randomint( 100 );
	if ( self.flight )
	{
		self thread handle_vulture_falling_death();
		trace = bullettrace( self.origin, self.origin - vectorScale( ( 0, 1, 0 ), 5000 ), 1, undefined );
		self unlink();
		self.link_to = undefined;
		move_to_z = self.origin[ 2 ] - trace[ "position" ][ 2 ];
		self movez( -1 * move_to_z, 2 );
		wait 2;
		self notify( "hit_the_ground" );
		self setanim( %a_vulture_death_hitground_a, 1, 0, 1 );
		anim_durration = getanimlength( %a_vulture_death_hitground_a );
		wait anim_durration;
	}
	else
	{
		if ( rand < 25 )
		{
			self setanim( %a_vulture_death_from_idle, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_death_from_idle );
		}
		else if ( rand < 50 )
		{
			self setanim( %a_vulture_death_from_idle_a, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_death_from_idle_a );
		}
		else if ( rand < 75 )
		{
			self setanim( %a_vulture_death_from_idle_b, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_death_from_idle_b );
		}
		else
		{
			self setanim( %a_vulture_death_from_idle_c, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_death_from_idle_c );
		}
		wait anim_durration;
	}
	level notify( "vulture_died" );
}

handle_vulture_falling_death()
{
	self endon( "hit_the_ground" );
	self endon( "deleted" );
	self setanim( %a_vulture_death_from_flight_a, 1, 0, 1 );
	anim_durration = getanimlength( %a_vulture_death_from_flight_a );
	wait anim_durration;
	while ( 1 )
	{
		self setanim( %a_vulture_death_fall_loop_a, 1, 0, 1 );
		anim_durration = getanimlength( %a_vulture_death_fall_loop_a );
		wait anim_durration;
	}
}

wait_till_player_close_enough( n_units )
{
	while ( player_close_enough_to_riders( n_units ) )
	{
		wait 0,25;
	}
}

player_close_enough_to_riders( n_units )
{
	v_base_pos = getent( "krav_capture_hudson_pos", "targetname" );
	if ( abs( distance( level.zhao.origin, level.player.origin ) ) > n_units )
	{
		return abs( distance( level.zhao.origin, v_base_pos.origin ) ) < abs( distance( level.player.origin, v_base_pos.origin ) );
	}
}

adjust_player_horse_speed_based_on_closeness_to_goal( n_units )
{
	level endon( "horse_intro_allow_sprint" );
	while ( 1 )
	{
		if ( player_close_enough_to_riders( 1000 ) )
		{
			if ( isDefined( level.current_intro_horse_override ) )
			{
				override_player_horse_speed( level.current_intro_horse_override );
			}
			else
			{
				override_player_horse_speed( 35 );
			}
		}
		else if ( player_close_enough_to_riders( 500 ) )
		{
			override_player_horse_speed( level.zhao.vh_my_horse getspeedmph() + 2 );
		}
		else
		{
			if ( player_close_enough_to_riders( 380 ) )
			{
				override_player_horse_speed( level.zhao.vh_my_horse getspeedmph() );
			}
		}
		wait 0,25;
	}
}

reset_player_horse_max_speed()
{
	level override_player_horse_speed( undefined );
}

setup_base_horses()
{
	horse1_pos = getstruct( "base_horse_pos1", "targetname" );
	m_horse1 = spawn_model( "anim_horse1_fb", horse1_pos.origin, horse1_pos.angles );
	horse2_pos = getstruct( "base_horse_pos2", "targetname" );
	m_horse2 = spawn_model( "anim_horse1_fb", horse2_pos.origin, horse2_pos.angles );
	horse3_pos = getstruct( "base_horse_pos3", "targetname" );
	m_horse3 = spawn_model( "anim_horse1_fb", horse3_pos.origin, horse3_pos.angles );
	horse4_pos = getstruct( "base_horse_pos4", "targetname" );
	m_horse4 = spawn_model( "anim_horse1_fb", horse4_pos.origin, horse4_pos.angles );
	m_horse1 thread horse_eater_idles();
	m_horse1 thread kill_base_horse();
	m_horse2 thread horse_eater_idles();
	m_horse2 thread kill_base_horse();
	m_horse3 thread horse_eater_idles();
	m_horse3 thread kill_base_horse();
	m_horse4 thread horse_eater_idles();
	m_horse4 thread kill_base_horse();
	wait 0,1;
	horse1_pos structdelete();
	horse1_pos = undefined;
	horse2_pos structdelete();
	horse2_pos = undefined;
	horse3_pos structdelete();
	horse3_pos = undefined;
	horse4_pos structdelete();
	horse4_pos = undefined;
}

horse_eater_idles()
{
	level endon( "first_rebel_base_visit" );
	self useanimtree( -1 );
	while ( 1 )
	{
		self setanim( %a_horse_eat_idle );
		wait randomintrange( 8, 12 );
		self clearanim( %a_horse_eat_idle, 0 );
		self set_and_wait_for_anim( %a_horse_eat_idle_to_eat_idle_b );
		self setanim( %a_horse_eat_idle_b );
		wait randomintrange( 8, 12 );
		self clearanim( %a_horse_eat_idle_b, 0 );
		self set_and_wait_for_anim( %a_horse_eat_idle_b_to_eat_idle );
	}
}

set_and_wait_for_anim( anim_name )
{
	self setanim( anim_name );
	wait_time = getanimlength( anim_name );
	wait wait_time;
	self clearanim( anim_name, 0 );
}

kill_base_horse()
{
	level waittill( "first_rebel_base_visit" );
	wait 1;
	self delete();
}

prep_base_vignettes()
{
	delete_section1_scenes();
	ai_base_runners = [];
	i = 0;
	while ( i < 6 )
	{
		ai_base_runners[ i ] = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
		wait 0,05;
		ai_base_runners[ i ].animname = "muj_runout_" + ( i + 1 );
		i++;
	}
	ai_tank_guy = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	ai_tank_guy.animname = "muj_tank_guy";
	ai_tank_guy.script_noteworthy = "e2_muj_clean_up";
	level thread setup_base_patrollers();
	ai_base_runners = undefined;
}

setup_base_patrollers()
{
	patroller2_node = getnode( "base_parapet_node", "targetname" );
	patroller2 = getent( "muj_assault", "targetname" ) spawn_ai( 1 );
	patroller2 teleport( patroller2_node.origin + vectorScale( ( 0, 1, 0 ), 10 ), patroller2_node.angles );
	patroller2 thread maps/_patrol::patrol( "base_parapet_node" );
	patroller2.script_noteworthy = "e2_muj_clean_up";
	level waittill( "first_rebel_base_visit" );
	if ( isDefined( patroller2 ) )
	{
		patroller2 delete();
	}
}

setup_ride_vignettes()
{
	trigger_wait( "wood_zhao_wait_canyon_wait_trigger" );
	level maps/createart/afghanistan_art::canyon();
	ai_e1_ride_vig_bridge1 = get_muj_ai();
	ai_e1_ride_vig_bridge1.arena_guy = 1;
	ai_e1_ride_vig_bridge1 teleport( ( 1586,5, -3011, 571 ), vectorScale( ( 0, 1, 0 ), 180 ) );
	ai_e1_ride_vig_bridge1 thread e1_bridge_walker( ( -293, -2685, 617 ) );
	wait 0,05;
	ai_e1_ride_vig_bridge2 = get_muj_ai();
	ai_e1_ride_vig_bridge2.arena_guy = 1;
	ai_e1_ride_vig_bridge2 teleport( ( 2621, -5033, 708 ), vectorScale( ( 0, 1, 0 ), 90 ) );
	ai_e1_ride_vig_bridge2 thread e1_bridge_walker( ( 2788, -3393, 768 ) );
	ai_e1_ride_vig_bridge2b = get_muj_ai();
	ai_e1_ride_vig_bridge2b.arena_guy = 1;
	ai_e1_ride_vig_bridge2b teleport( ( 2703, -3599, 294 ), vectorScale( ( 0, 1, 0 ), 270 ) );
	ai_e1_ride_vig_bridge2b thread e1_bridge_walker( ( 2463, -5366, 295 ) );
	wait 0,05;
	ai_e1_ride_vig_lookout_stand = get_muj_ai();
	ai_e1_ride_vig_lookout_stand.arena_guy = 1;
	ai_e1_ride_vig_lookout_stand teleport( ( 3754, -5668, 374 ), vectorScale( ( 0, 1, 0 ), 90 ) );
	ai_e1_ride_vig_lookout_stand thread e1_bridge_walker( ( 3751, -4765, 238 ) );
	wait 0,05;
	level thread drive_by_truck();
	level.intro_area_horses = [];
	level.intro_horses_pos = [];
	i = 1;
	while ( i < 6 )
	{
		level.intro_horses_pos[ i ] = getstruct( "open_area_intro_horse_pos" + i, "targetname" );
		i++;
	}
	i = 1;
	while ( i < 6 )
	{
		level.intro_area_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		level.intro_area_horses[ i ].origin = level.intro_horses_pos[ i ].origin;
		level.intro_area_horses[ i ].angles = level.intro_horses_pos[ i ].angles;
		level.intro_area_horses[ i ] makevehicleunusable();
		i++;
	}
	horse_colors = [];
	horse_colors[ 1 ] = "anim_horse1_white_fb";
	horse_colors[ 2 ] = "anim_horse1_light_brown_fb";
	horse_colors[ 3 ] = "anim_horse1_brown_spots_fb";
	horse_colors[ 4 ] = "anim_horse1_light_brown_fb";
	horse_colors[ 5 ] = "anim_horse1_white_fb";
	i = 1;
	while ( i < 6 )
	{
		level.intro_area_horses[ i ] setmodel( horse_colors[ i ] );
		i++;
	}
	horse_colors = undefined;
	level thread horse_hitching_post();
	level thread run_scene( "e2_tank_ride_idle_start" );
	trigger_wait( "truck_unload_vignette_trigger" );
	post_intro_blocker_trigger = getent( "post_intro_blocker_trigger", "script_noteworthy" );
	post_intro_blocker_trigger triggeron();
	intro_block_triggers = getentarray( "intro_desert_fail_trigger", "script_noteworthy" );
	_a1557 = intro_block_triggers;
	_k1557 = getFirstArrayKey( _a1557 );
	while ( isDefined( _k1557 ) )
	{
		intro_trigger = _a1557[ _k1557 ];
		intro_trigger delete();
		_k1557 = getNextArrayKey( _a1557, _k1557 );
	}
	level maps/createart/afghanistan_art::open_area();
	i = 1;
	while ( i < 6 )
	{
		level.intro_horses_pos[ i ] structdelete();
		i++;
	}
}

horse_hitching_post()
{
	s_spawnpt = getstruct( "bp3_hitch", "targetname" );
	horse = spawn_vehicle_from_targetname( "mason_horse" );
	horse.origin = s_spawnpt.origin;
	horse.angles = vectorScale( ( 0, 1, 0 ), 270 );
	horse veh_magic_bullet_shield( 1 );
	horse thread horse_panic();
	while ( distance2dsquared( horse.origin, level.player.origin ) > 2250000 )
	{
		wait 0,1;
	}
	horse horse_rearback();
	trigger_wait( "demo_fade_trigger" );
	horse.delete_on_death = 1;
	horse notify( "death" );
	if ( !isalive( horse ) )
	{
		horse delete();
	}
}

drive_by_truck()
{
	s_spawnpt = getstruct( "truck_ride_spawnpt", "targetname" );
	vh_truck = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck.origin = s_spawnpt.origin;
	vh_truck.angles = s_spawnpt.angles;
	ai_driver = get_muj_ai();
	ai_driver.script_noteworthy = "e1_ride_vig_cleanup";
	ai_driver.script_startingposition = 0;
	ai_driver.arena_guy = 1;
	ai_driver enter_vehicle( vh_truck );
	ai_gunner = get_muj_ai();
	ai_gunner.script_noteworthy = "e1_ride_vig_cleanup";
	ai_gunner.script_startingposition = 2;
	ai_gunner.arena_guy = 1;
	ai_gunner.ff_kill_penalty = -10000;
	ai_gunner enter_vehicle( vh_truck );
	nd_truck_start = getvehiclenode( "truck_path", "targetname" );
	vh_truck attachpath( nd_truck_start );
	vh_truck startpath();
	vh_truck setspeed( 0 );
	vh_truck thread destroy_driveby_truck();
	vh_truck thread fail_if_killed_by_player();
	trigger_wait( "truck_start_up" );
	vh_truck setspeed( 15 );
	trigger_wait( "vulture_spawning_trigger" );
	vh_truck setspeed( 25 );
	trigger_wait( "truck_speed_up" );
	if ( isDefined( vh_truck ) && vh_truck.health > 0 )
	{
		vh_truck setspeed( 33 );
	}
	trigger_wait( "demo_fade_trigger" );
	vh_truck.delete_on_death = 1;
	vh_truck notify( "death" );
	if ( !isalive( vh_truck ) )
	{
		vh_truck delete();
	}
	s_spawnpt structdelete();
	s_spawnpt = undefined;
}

fail_if_killed_by_player()
{
	self waittill( "death", attacker );
	if ( isplayer( attacker ) )
	{
		level.player thread maps/_friendlyfire::missionfail();
	}
}

destroy_driveby_truck()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
	self vehicle_detachfrompath();
	self launchvehicle( ( 0, -100, 200 ), anglesToForward( self.angles ) * 180, 1, 1 );
	if ( isalive( self.gunner ) )
	{
		self.gunner die();
	}
	wait 1;
	self setbrake( 1 );
	radiusdamage( self.origin, 100, self.health, self.health );
}

run_tank_scene()
{
	run_scene( "e2_tank_ride_idle" );
	run_scene( "e2_tank_ride_idle_end" );
	flag_wait( "cleanup_ride" );
	end_scene( "e2_tank_ride_idle_end" );
}

wait_and_play_unload_idle()
{
	self endon( "death" );
	n_time = getanimlength( %ch_af_02_02_truck_offload_muj1 );
	wait n_time;
	run_scene( "e1_truck_offload_idle" );
}

wait_and_play_truck_hold( vh_link_truck )
{
	self endon( "death" );
	n_time = getanimlength( %ch_af_02_02_truck_offload_muj2_idle );
	wait n_time;
	run_scene_first_frame( "e1_truck_hold_truck_idle" );
}

wait_and_goto_idle()
{
	self endon( "death" );
	wait 0,5;
	self setspeed( 20, 20 );
	x = 1;
	while ( x < 5 )
	{
		goto_node = getvehiclenode( "truck_vig_goto" + x, "targetname" );
		self setvehgoalpos( goto_node.origin, 0, 0 );
		self waittill_any( "goal", "near_goal" );
		x++;
	}
}

e1_cache_idle1()
{
	self endon( "death" );
	while ( 1 )
	{
		n_time = self prep_and_play_idle( %ch_af_02_01_gun_stackers_muj1_endidl );
		wait n_time;
	}
}

e1_cache_idle2()
{
	self endon( "death" );
	while ( 1 )
	{
		n_time = self prep_and_play_idle( %ch_af_02_01_gun_stackers_muj2_endidl );
		wait n_time;
	}
}

e1_ride_lookout1()
{
	self endon( "death" );
	while ( 1 )
	{
		n_time = self prep_and_play_idle( %ch_af_02_01_ridge_lookout_guy1 );
		wait n_time;
	}
}

e1_ride_lookout2()
{
	self endon( "death" );
	while ( 1 )
	{
		n_time = self prep_and_play_idle( %ch_af_02_01_ridge_lookout_guy2 );
		wait n_time;
	}
}

prep_and_play_idle( anim_play )
{
	self clearanim( anim_play, 0 );
	self setanim( anim_play );
	n_time = getanimlength( anim_play );
	return n_time;
}

e1_bridge_walker( v_goal )
{
	self.script_noteworthy = "e1_ride_vig_cleanup";
	self.animname = "generic";
	self set_run_anim( "patrol_walk" );
	self.goalradius = 5;
	self setgoalpos( v_goal );
}

cleanup_ride_vignette_by_goal()
{
	self waittill( "goal" );
	self delete();
}

cleanup_ride_vignettes()
{
	flag_set( "cleanup_ride" );
	delete_ride_vignette_array = getentarray( "e1_ride_vig_cleanup", "script_noteworthy" );
	_a1840 = delete_ride_vignette_array;
	_k1840 = getFirstArrayKey( _a1840 );
	while ( isDefined( _k1840 ) )
	{
		cleanup_ent = _a1840[ _k1840 ];
		cleanup_ent delete();
		_k1840 = getNextArrayKey( _a1840, _k1840 );
	}
	t_unload_trigger = getent( "truck_unload_vignette_trigger", "targetname" );
	if ( isDefined( t_unload_trigger ) )
	{
		t_unload_trigger delete();
	}
	i = 1;
	while ( i < 6 )
	{
		level.intro_area_horses[ i ].delete_on_death = 1;
		level.intro_area_horses[ i ] notify( "death" );
		if ( !isalive( level.intro_area_horses[ i ] ) )
		{
			level.intro_area_horses[ i ] delete();
		}
		i++;
	}
	level.intro_area_horses = undefined;
}

play_ride_dialog()
{
	wait 2;
	level.player say_dialog( "mason__its_hudso_012" );
	level.player say_dialog( "hudson_h__were_on_013" );
	while ( !level.player is_on_horseback() )
	{
		wait 0,05;
	}
	level.player say_dialog( "im_sure_i_dont_n_014" );
	level.player say_dialog( "there_will_be_seri_001" );
	wait 1;
	level.woods say_dialog( "wood_the_only_way_they_ll_0" );
	level.woods say_dialog( "wood_you_know_that_ain_t_0" );
}

press_demo_fadeout_watcher()
{
	trigger_wait( "demo_fade_trigger" );
	level.mason_horse makevehicleunusable();
	level clientnotify( "fout" );
/#
	println( "PRESS DEMO FADE OUT HERE" );
#/
	runout_clip = getent( "runguys_out_clip", "targetname" );
	runout_clip delete();
	level screen_fade_out( 2 );
	flag_wait( "screen_fade_out_end" );
	level notify( "demo_fade" );
	if ( level.player is_on_horseback() )
	{
		level.mason_horse useby( level.player );
		level.player waittill( "exit_vehicle" );
		level.mason_horse delete();
	}
	flag_set( "zhao_got_to_base" );
	flag_set( "woods_got_to_base" );
	level.zhao change_movemode( "walk" );
	level.zhao disable_tactical_walk();
	level.woods change_movemode( "walk" );
	level.woods disable_tactical_walk();
	level.player freezecontrols( 1 );
	level.player setlowready( 0 );
	level.woods setgoalpos( level.woods.origin );
	level.zhao setgoalpos( level.zhao.origin );
	end_scene( "e2_cooking_muj" );
	end_scene( "e2_drum_burner" );
	end_scene( "e2_gunsmith" );
	end_scene( "e2_smokers" );
	end_scene( "e2_ammo" );
	end_scene( "e2_generator" );
	end_scene( "e2_tower_lookout_endidl" );
	end_scene( "e2_stinger_endidl" );
	end_scene( "e2_stacker_endidl" );
	end_scene( "e2_stacker_3" );
	delete_section_2_scenes();
	level thread maps/afghanistan_intro_rebel_base::cleanup();
	level thread maps/afghanistan_intro_rebel_base::cleanup_intro();
	level thread maps/afghanistan_intro_rebel_base::rebel_base_clean_up();
	if ( isDefined( level.mason_horse ) )
	{
		level.mason_horse delete();
	}
	flag_set( "first_rebel_base_visit" );
	load_gump( "afghanistan_gump_arena" );
}
