#include maps/_audio;
#include maps/afghanistan_anim;
#include maps/_objectives;
#include maps/_music;
#include maps/_dialog;
#include maps/_anim;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "player" );

init_flags()
{
	flag_init( "interrogation_started" );
	flag_init( "numbers_struggle_completed" );
	flag_init( "interrogation_running" );
	flag_init( "instant_fail_running" );
	flag_init( "brainwash_active" );
}

init_spawn_funcs()
{
}

skipto_krav_captured()
{
	skipto_setup();
	skipto_cleanup();
	level maps/afghanistan_anim::init_afghan_anims_part2();
	level.woods = init_hero( "woods" );
	level.zhao = init_hero( "zhao" );
	level.hudson = init_hero( "hudson" );
	level.kravchenko = init_hero( "kravchenko_cut" );
	skipto_teleport( "skipto_krav_captured", level.heroes );
	e_hudson_pos = getent( "krav_capture_hudson_pos", "targetname" );
	e_zhao_pos = getent( "krav_capture_zhao_pos", "targetname" );
	e_krav_pos = getent( "krav_capture_krav_pos", "targetname" );
	e_woods_pos = getent( "krav_capture_woods_pos", "targetname" );
	level.hudson forceteleport( e_hudson_pos.origin, e_hudson_pos.angles );
	level.zhao forceteleport( e_zhao_pos.origin, e_zhao_pos.angles );
	level.kravchenko forceteleport( e_krav_pos.origin, e_krav_pos.angles );
	level.woods forceteleport( e_woods_pos.origin, e_woods_pos.angles );
	level.player enableinvulnerability();
	flag_wait( "afghanistan_gump_ending" );
}

skipto_krav_interrogation()
{
	skipto_setup();
	skipto_cleanup();
	maps/createart/afghanistan_art::interrogation();
	level maps/afghanistan_anim::init_afghan_anims_part2();
	level.woods = init_hero( "woods" );
	level.zhao = init_hero( "zhao" );
	level.hudson = init_hero( "hudson" );
	level.kravchenko = init_hero( "kravchenko_cut" );
	level.rebel_leader = init_hero( "rebel_leader" );
	skipto_teleport( "skipto_krav_interrogation", level.heroes );
	e_hudson_pos = getent( "krav_interrogation_hudson_pos", "targetname" );
	e_zhao_pos = getent( "krav_interrogation_zhao_pos", "targetname" );
	e_krav_pos = getent( "krav_interrogation_krav_pos", "targetname" );
	e_woods_pos = getent( "krav_interrogation_woods_pos", "targetname" );
	e_leader_pos = getent( "krav_interrogation_leader_pos", "targetname" );
	level.hudson forceteleport( e_hudson_pos.origin, e_hudson_pos.angles );
	level.zhao forceteleport( e_zhao_pos.origin, e_zhao_pos.angles );
	level.kravchenko forceteleport( e_krav_pos.origin, e_krav_pos.angles );
	level.woods forceteleport( e_woods_pos.origin, e_woods_pos.angles );
	level.rebel_leader forceteleport( e_leader_pos.origin, e_leader_pos.angles );
	level.zhao setgoalpos( e_zhao_pos.origin );
	level.woods setgoalpos( e_woods_pos.origin );
	remove_woods_facemask_util();
	level.player enableinvulnerability();
	flag_wait( "afghanistan_gump_ending" );
}

skipto_beat_down()
{
	skipto_setup();
	skipto_cleanup();
	level maps/afghanistan_anim::init_afghan_anims_part2();
	level.woods = init_hero( "woods" );
	level.zhao = init_hero( "zhao" );
	level.hudson = init_hero( "hudson" );
	level.kravchenko = init_hero( "kravchenko_cut" );
	level.rebel_leader = init_hero( "rebel_leader" );
	skipto_teleport( "skipto_krav_interrogation", level.heroes );
	e_hudson_pos = getent( "krav_interrogation_hudson_pos", "targetname" );
	e_zhao_pos = getent( "krav_interrogation_zhao_pos", "targetname" );
	e_krav_pos = getent( "krav_interrogation_krav_pos", "targetname" );
	e_woods_pos = getent( "krav_interrogation_woods_pos", "targetname" );
	e_leader_pos = getent( "krav_interrogation_leader_pos", "targetname" );
	level.hudson forceteleport( e_hudson_pos.origin, e_hudson_pos.angles );
	level.zhao forceteleport( e_zhao_pos.origin, e_zhao_pos.angles );
	level.kravchenko forceteleport( e_krav_pos.origin, e_krav_pos.angles );
	level.woods forceteleport( e_woods_pos.origin, e_woods_pos.angles );
	level.rebel_leader forceteleport( e_leader_pos.origin, e_leader_pos.angles );
	level.kravchenko stop_magic_bullet_shield();
	level.kravchenko dodamage( level.kravchenko.health * 2, level.kravchenko.origin );
	level.zhao setgoalpos( e_zhao_pos.origin );
	level.woods setgoalpos( e_woods_pos.origin );
	level.player enableinvulnerability();
	flag_wait( "afghanistan_gump_ending" );
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
	level.player hide_hud( 1 );
	wait_network_frame();
	level thread old_man_woods( "afghanistan_int_2", 0 );
	level maps/createart/afghanistan_art::turn_down_fog();
	maps/createart/afghanistan_art::interrogation();
	cleanup_for_walkin();
	flag_wait( "afghanistan_gump_ending" );
	flag_waitopen( "old_man_woods_talking" );
	rpc( "clientscripts/afghanistan_amb", "setInterrogationSnap" );
	chairs = getentarray( "chair_cave", "targetname" );
	array_delete( chairs );
	level thread muj_celebration();
	move_heroes_interrogation_room();
}

cleanup_for_walkin()
{
	a_ai_guys = getaiarray( "all" );
	if ( isDefined( level.woods ) )
	{
		a_ai_guys = array_exclude( a_ai_guys, level.woods );
	}
	if ( isDefined( level.zhao ) )
	{
		a_ai_guys = array_exclude( a_ai_guys, level.zhao );
	}
	if ( isDefined( level.kravchenko ) )
	{
		a_ai_guys = array_exclude( a_ai_guys, level.kravchenko );
	}
	array_delete( a_ai_guys );
}

interrogation()
{
	set_objective( level.obj_interrogate_krav );
	level.b_player_failed_brainwash = 0;
	level.kravchenko stop_magic_bullet_shield();
	level thread play_interrogation_player_anims();
	level thread run_scene( "e5_s2_interrogation_start" );
	m_guard1 = get_model_or_models_from_scene( "e5_s2_interrogation_start", "interrogation_guard1" );
	m_guard1 attach_weapon( "ak47_sp" );
	m_guard2 = get_model_or_models_from_scene( "e5_s2_interrogation_start", "interrogation_guard2" );
	m_guard2 attach_weapon( "ak47_sp" );
	m_guard3 = get_model_or_models_from_scene( "e5_s2_interrogation_start", "beatdown_guard2" );
	m_guard3 attach_weapon( "ak47_sp" );
	m_guard4 = get_model_or_models_from_scene( "e5_s2_interrogation_start", "beatdown_guard3" );
	m_guard4 attach_weapon( "ak47_sp" );
	ai_woods = get_ais_from_scene( "e5_s2_interrogation_start", "woods" );
	ai_woods attach_weapon( "m1911_sp" );
	scene_wait( "e5_s2_interrogation_start" );
	run_scene( "e5_s2_interrogation_threat" );
	if ( !level.b_player_failed_brainwash )
	{
		run_scene( "e5_s2_interrogation_first_intel" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		run_scene( "e5_s2_interrogation_second_intel" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		end_scene( "e5_s2_interrogation_second_intel" );
		run_scene( "e5_s2_interrogation_third_intel" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		level notify( "krav_gives_all_intel" );
		krav_tag_head_origin = level.kravchenko gettagorigin( "J_Neck" );
		krav_tag_head_angles = level.kravchenko gettagangles( "J_Neck" );
		level.hudson gun_switchto( level.hudson.sidearm, "right" );
		run_scene( "e5_s2_interrogation_succeed" );
		level.player set_story_stat( "KRAVCHENKO_INTERROGATED", 1 );
	}
	level waittill( "interrogation_done" );
	level.player notify( "stop_numbers" );
	level.player notify( "stop_face" );
}

prep_interrogation()
{
	x = 0;
	while ( x < 2 )
	{
		e_temp_guard = simple_spawn_single( "interrogation_guard" );
		e_temp_guard.animname = "interrogation_guard" + ( x + 1 );
		x++;
	}
}

play_interrogation_player_anims()
{
	level thread run_scene( "e5_s2_interrogation_start_player" );
	scene_wait( "e5_s2_interrogation_start" );
	end_scene( "e5_s2_interrogation_start_player" );
	if ( is_mature() )
	{
		run_scene( "e5_s2_interrogation_threat_player" );
	}
	else
	{
		run_scene( "e5_s2_interrogation_threat_player_edit" );
	}
	level.fail_animation = "none";
	level.player thread say_dialog( "dragovich_kravche_005" );
	level thread handle_interrogation_shake();
	level thread run_scene( "e5_s2_interrogation_test1" );
	flag_set( "interrogation_running" );
	level.player thread say_dialog( "dragovich_kravche_005" );
	level thread gun_resist_controls();
	body = get_model_or_models_from_scene( "e5_s2_interrogation_test1", "player_body" );
	tag_origin = body gettagorigin( "tag_camera" );
	tag_angles = body gettagangles( "tag_camera" );
	level.player playsound( "evt_numbers" );
	level notify( "player_needs_control_back" );
	level.player thread playnumbersaudio();
	level thread wait_for_interrogation_scene_end( "e5_s2_interrogation_test1" );
	flag_waitopen( "interrogation_running" );
	if ( flag( "instant_fail_running" ) )
	{
		end_scene( "e5_s2_interrogation_test1" );
		run_scene_first_frame( "e5_s2_interrogation_test1_fail_no_player" );
		flag_waitopen( "instant_fail_running" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		run_scene( "e5_s2_interrogation_test1_succeed" );
	}
	else
	{
		earthquake( 0,25, 6, level.player.origin, 128 );
		setmusicstate( "AFGHAN_MASON_SHOOTS" );
		level.fail_animation = "e5_s2_interrogation_test1_fail";
		krav_tag_head_origin = level.kravchenko gettagorigin( "J_Neck" );
		krav_tag_head_angles = level.kravchenko gettagangles( "J_Neck" );
		level.player notify( "stop_numbers_strong" );
		level.brainwash_model clearanim( %root, 0 );
		level.brainwash_model setanim( %int_player_afghan_gun_fire, 1 );
		level run_scene( "e5_s2_interrogation_test1_fail" );
		level.brainwash_model delete();
		level.player notify( "stop_numbers" );
		level notify( "interrogation_done" );
		return;
	}
	level.intel_round_multiplier = 0,15;
	level.player play_fx( "numbers_mid", tag_origin, tag_angles, "stop_numbers" );
	level.player playsound( "evt_numbers" );
	level.player thread say_dialog( "rezn_these_men_must_die_0" );
	flag_set( "interrogation_running" );
	level thread run_scene( "e5_s2_interrogation_test2" );
	level thread wait_for_interrogation_scene_end( "e5_s2_interrogation_test2" );
	flag_waitopen( "interrogation_running" );
	if ( flag( "instant_fail_running" ) )
	{
		end_scene( "e5_s2_interrogation_test2" );
		run_scene_first_frame( "e5_s2_interrogation_test2_fail_no_player" );
		flag_waitopen( "instant_fail_running" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		run_scene( "e5_s2_interrogation_test2_succeed" );
	}
	else
	{
		earthquake( 0,25, 6, level.player.origin, 128 );
		setmusicstate( "AFGHAN_MASON_SHOOTS" );
		level.fail_animation = "e5_s2_interrogation_test2_fail";
		krav_tag_head_origin = level.kravchenko gettagorigin( "J_Neck" );
		krav_tag_head_angles = level.kravchenko gettagangles( "J_Neck" );
		level.player notify( "stop_numbers_strong" );
		level.brainwash_model clearanim( %root, 0 );
		level.brainwash_model setanim( %int_player_afghan_gun_fire, 1 );
		level run_scene( "e5_s2_interrogation_test2_fail" );
		level.brainwash_model delete();
		level.player notify( "stop_numbers" );
		level notify( "interrogation_done" );
		return;
	}
	level.intel_round_multiplier = 0,2;
	anim_length = getanimlength( %p_af_05_02_interrog_test3_player );
	level.player play_fx( "numbers_center", tag_origin, tag_angles, "stop_numbers" );
	level.player playsound( "evt_numbers" );
	level.player thread say_dialog( "dragovich_kravche_005" );
	flag_set( "interrogation_running" );
	level thread run_scene( "e5_s2_interrogation_test3" );
	level thread wait_for_interrogation_scene_end( "e5_s2_interrogation_test3" );
	flag_waitopen( "interrogation_running" );
	if ( flag( "instant_fail_running" ) )
	{
		end_scene( "e5_s2_interrogation_test3" );
		run_scene_first_frame( "e5_s2_interrogation_test3_fail_no_player" );
		flag_waitopen( "instant_fail_running" );
	}
	if ( !level.b_player_failed_brainwash )
	{
		run_scene( "e5_s2_interrogation_test3_succeed" );
	}
	else
	{
		earthquake( 0,25, 6, level.player.origin, 128 );
		setmusicstate( "AFGHAN_MASON_SHOOTS" );
		level.fail_animation = "e5_s2_interrogation_test3_fail";
		krav_tag_head_origin = level.kravchenko gettagorigin( "J_Neck" );
		krav_tag_head_angles = level.kravchenko gettagangles( "J_Neck" );
		level.player notify( "stop_numbers_strong" );
		level.brainwash_model clearanim( %root, 0 );
		level.brainwash_model setanim( %int_player_afghan_gun_fire, 1 );
		level run_scene( "e5_s2_interrogation_test3_fail" );
		level.brainwash_model delete();
		level.player notify( "stop_numbers" );
		level notify( "interrogation_done" );
		return;
	}
	level thread run_scene( "e5_s2_interrogation_all_succeed" );
	wait 1,65;
	level.player notify( "stop_numbers" );
	level scene_wait( "e5_s2_interrogation_succeed" );
	level notify( "interrogation_done" );
}

wait_for_interrogation_scene_end( str_scene_name )
{
	level scene_wait( str_scene_name );
	flag_clear( "interrogation_running" );
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
		playsoundatposition( "evt_numbers_flux_quiet", self.origin + ( a, b, c ) );
		wait randomfloatrange( 1, 3 );
	}
}

beatdown()
{
	set_objective( level.obj_interrogate_krav, undefined, "done" );
	level thread maps/_audio::switch_music_wait( "AFGHAN_TURN", 0,15 );
	level thread run_scene( "e5_s4_beatdown" );
	level thread prep_beatdown_guards();
	anim_durration = getanimlength( %p_af_05_04_betrayal_player );
	wait ( anim_durration - 2 );
	clientnotify( "snp_desert" );
	level thread screen_fade_out( 2 );
	level.player visionsetnaked( "infrared_snow", 2 );
	level.player lerp_dof_over_time_pass_out( 2 );
	level.player visionsetnaked( "afghanistan", 0,05 );
	level.player reset_dof();
}

prep_beatdown_guards()
{
	m_guard1 = get_model_or_models_from_scene( "e5_s4_beatdown", "beatdown_guard1" );
	m_guard1 attach_weapon( "ak47_sp" );
}

muj_celebration()
{
	level.player freezecontrols( 0 );
	level thread krav_face_impact();
	level screen_fade_in( 2, undefined, undefined, 1 );
	level.player resetfov();
	level.player allowsprint( 0 );
	level.player setlowready( 1 );
	flag_set( "interrogation_started" );
}

krav_face_impact()
{
	level endon( "interrogation_done" );
	level.kravchenko endon( "death" );
	while ( 1 )
	{
		krav_tag_head_origin = level.kravchenko gettagorigin( "J_Head" );
		krav_tag_head_angles = level.kravchenko gettagangles( "J_Head" );
		level.kravchenko play_fx( "fx_punch_kravchenko", krav_tag_head_origin, krav_tag_head_angles, "stop_face", 1, "J_Head" );
		wait 3;
	}
}

move_heroes_interrogation_room()
{
	if ( !isDefined( level.woods ) )
	{
		level.woods = init_hero( "woods" );
	}
	if ( !isDefined( level.zhao ) )
	{
		level.zhao = init_hero( "zhao" );
	}
	if ( !isDefined( level.hudson ) )
	{
		level.hudson = init_hero( "hudson" );
	}
	if ( !isDefined( level.kravchenko ) )
	{
		level.kravchenko = init_hero( "kravchenko_cut" );
	}
	if ( !isDefined( level.rebel_leader ) )
	{
		level.rebel_leader = init_hero( "rebel_leader" );
	}
	e_hudson_pos = getent( "krav_interrogation_hudson_pos", "targetname" );
	e_zhao_pos = getent( "krav_interrogation_zhao_pos", "targetname" );
	e_krav_pos = getent( "krav_interrogation_krav_pos", "targetname" );
	e_woods_pos = getent( "krav_interrogation_woods_pos", "targetname" );
	e_leader_pos = getent( "krav_interrogation_leader_pos", "targetname" );
	level.hudson forceteleport( e_hudson_pos.origin, e_hudson_pos.angles );
	level.zhao forceteleport( e_zhao_pos.origin, e_zhao_pos.angles );
	level.kravchenko forceteleport( e_krav_pos.origin, e_krav_pos.angles );
	level.woods forceteleport( e_woods_pos.origin, e_woods_pos.angles );
	level.rebel_leader forceteleport( e_leader_pos.origin, e_leader_pos.angles );
	level.zhao setgoalpos( e_zhao_pos.origin );
	level.woods setgoalpos( e_woods_pos.origin );
	level.kravchenko setgoalpos( e_krav_pos.origin );
}

brainwash_instant_fail()
{
	level endon( "gun_control_stop_instant_fail" );
	level waittill( "ready_to_embrace_numbers" );
	while ( !level.player attackbuttonpressed() )
	{
		wait 0,05;
	}
	flag_set( "instant_fail_running" );
	level notify( "kill_other_gun_anim_threads" );
	level notify( "stop_button_mash" );
	screen_message_delete();
	level.b_player_failed_brainwash = 1;
	n_anim_rate = 1,5;
	anim_length = getanimlength( %int_player_afghan_gun_raise_middle_to_finish ) / n_anim_rate;
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_offscreen, 0, 1, 1 );
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_finish, 1, 1, n_anim_rate );
	level.player thread lerp_fov_overtime( anim_length, 20, 1 );
	wait anim_length;
	flag_clear( "interrogation_running" );
	flag_clear( "instant_fail_running" );
	wait 1;
	level.player notify( "stop_numbers_strong" );
	level.player thread lerp_fov_overtime( 0,3, getDvarFloat( "cg_fov_default" ), 1 );
	maps/createart/afghanistan_art::dof_krav_unfocus();
}

gun_resist_controls()
{
	level endon( "kill_other_gun_anim_threads" );
	level.direction_input_ls = 0;
	level.n_time_max = getanimlength( %p_af_05_02_interrog_test1_player );
	level thread brainwash_strength_test_update( level.player, 1, 0,5, undefined );
	level thread brainwash_instant_fail();
	level thread animate_brainwash_anims( "e5_s2_interrogation_test1", 1 );
	watch_and_wait_scene( level.n_time_max, 0,3 );
	level notify( "stop_button_mash" );
	if ( level.b_player_failed_brainwash )
	{
		return;
	}
	level notify( "gun_control_stop_instant_fail" );
	level.direction_input_ls = 0;
	level.n_time_max = getanimlength( %p_af_05_02_interrog_test2_player );
	level scene_wait( "e5_s2_interrogation_test1_succeed" );
	level thread brainwash_strength_test_update( level.player, 1, 0,5, 0,2 );
	level thread brainwash_instant_fail();
	level thread animate_brainwash_anims( "e5_s2_interrogation_test2", 2 );
	watch_and_wait_scene( level.n_time_max, 0,2 );
	level notify( "stop_button_mash" );
	if ( level.b_player_failed_brainwash )
	{
		return;
	}
	level notify( "gun_control_stop_instant_fail" );
	level.direction_input_ls = 0;
	level.n_time_max = getanimlength( %p_af_05_02_interrog_test3_player );
	level scene_wait( "e5_s2_interrogation_test2_succeed" );
	level thread brainwash_strength_test_update( level.player, 1, 0,8, 0,2 );
	level thread brainwash_instant_fail();
	level thread animate_brainwash_anims( "e5_s2_interrogation_test3", 3 );
	watch_and_wait_scene( level.n_time_max, 0,1 );
	level notify( "stop_button_mash" );
	if ( level.b_player_failed_brainwash )
	{
		return;
	}
	level notify( "gun_control_stop_instant_fail" );
}

watch_and_wait_scene( n_timer, n_time_flash )
{
	msg_on = 0;
	level thread screen_message_create( &"AFGHANISTAN_BRAINWASH_PROMPT2" );
	wait n_timer;
	level screen_message_delete();
}

check_and_set_interrogation_failure( n_scene_time, n_player_input )
{
	if ( n_player_input != 0 )
	{
		if ( level.brainwash_weights[ 1 ] > 0,95 )
		{
			level.b_player_failed_brainwash = 1;
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		level.b_player_failed_brainwash = 1;
		return 1;
	}
}

handle_interrogation_shake()
{
	level endon( "interrogation_done" );
	level.b_player_input = 0;
	level.intel_round_multiplier = 0,5;
	while ( 1 )
	{
		if ( flag( "interrogation_running" ) )
		{
			if ( !level.b_player_input )
			{
				earthquake( 0,1, 1, level.player.origin, 128 );
				level.player playrumbleonentity( "pullout_small" );
				break;
			}
			else
			{
				earthquake( 0,12, 1, level.player.origin, 128 );
				level.player playrumbleonentity( "anim_heavy" );
			}
		}
		wait 0,1;
	}
}

choke_spit_fx()
{
	body = get_model_or_models_from_scene( "e5_s4_beatdown", "player_body" );
	tag_origin = body gettagorigin( "tag_camera" );
	tag_angles = body gettagangles( "tag_camera" );
	body play_fx( "choke_spit", tag_origin, tag_angles, 5, 1, "tag_camera" );
}

brainwash_anims_init( str_scene )
{
	level.player_body_model = get_model_or_models_from_scene( str_scene, "player_body" );
	align_struct = getstruct( "by_numbers_struct_mason", "targetname" );
	model_origin = getstartorigin( align_struct.origin, ( 0, 0, 1 ), %p_af_05_02_interrog_test1_player );
	model_angles = getstartangles( align_struct.origin, ( 0, 0, 1 ), %p_af_05_02_interrog_test1_player );
	level.brainwash_model = spawn_anim_model( "player_hands_brainwash", model_origin - vectorScale( ( 0, 0, 1 ), 8 ), ( model_angles[ 0 ], model_angles[ 1 ], 0 ) );
	level.brainwash_model attach( "t6_wpn_pistol_m1911_prop_view", "tag_weapon" );
}

animate_brainwash_anims( str_scene, num_scene )
{
	level endon( "kill_other_gun_anim_threads" );
	n_brainwash_count = 0;
	brainwash_anims_init( str_scene );
	wait 0,05;
	flag_set( "brainwash_active" );
	level.brainwash_model setanim( %int_player_afghan_gun_raise_intro_to_middle, 1, 0, 1 );
	wait_time = getanimlength( %int_player_afghan_gun_raise_intro_to_middle );
	maps/createart/afghanistan_art::dof_krav_focus();
	level.player thread lerp_fov_overtime( wait_time, 35, 1 );
	wait wait_time;
	tag_origin = level.player_body_model gettagorigin( "tag_camera" );
	tag_angles = level.player_body_model gettagangles( "tag_camera" );
	level.player play_fx( "numbers_strong", tag_origin, tag_angles, "stop_numbers_strong" );
	level.brainwash_weights[ 0 ] = 1;
	level.brainwash_weights[ 1 ] = 0;
	level.brainwash_model clearanim( %root, 0 );
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_offscreen, level.brainwash_weights[ 0 ], 0, 1 );
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_finish, level.brainwash_weights[ 1 ], 0, 1 );
	level notify( "ready_to_embrace_numbers" );
	while ( flag( "brainwash_active" ) )
	{
		if ( isDefined( level.player.strengthtest_button_presses ) )
		{
			player_leftstick_y = level.player.strengthtest_button_presses;
		}
		else
		{
			player_leftstick_y = 0;
		}
		if ( player_leftstick_y != 0 )
		{
			brainwash_hands_animator( player_leftstick_y, num_scene );
		}
		else if ( str_scene == "e5_s2_interrogation_test3" )
		{
			brainwash_hands_animator( -0,55, num_scene );
		}
		else
		{
			brainwash_hands_animator( -0,35, num_scene );
		}
		n_brainwash_count += 1;
		wait 0,05;
	}
	level.player thread lerp_fov_overtime( 1, getDvarFloat( "cg_fov_default" ), 1 );
	maps/createart/afghanistan_art::dof_krav_unfocus();
	if ( check_and_set_interrogation_failure( level.n_time_max, level.player.strengthtest_button_presses ) )
	{
		level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_offscreen, 0, 0,1, 1 );
		level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_finish, 1, 0,1, 1 );
		return;
	}
	else
	{
		anim_length = getanimlength( %int_player_afghan_gun_raise_middle_to_outofview );
		level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_outofview, 1, anim_length / 1,5, 1 );
		level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_finish, 0, anim_length / 1,5, 1 );
		level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_offscreen, 0, anim_length / 1,5, 1 );
		level.player notify( "stop_numbers_strong" );
		wait anim_length;
	}
	level.player notify( "stop_numbers_strong" );
	level.brainwash_model delete();
}

end_hands_animator( player_body )
{
	flag_clear( "brainwash_active" );
}

brainwash_hands_animator( player_leftstick_y, num_scene )
{
	weights = set_brainwash_weights( player_leftstick_y, num_scene );
	thread brainwash_aim( weights );
}

brainwash_bump()
{
	level.brainwash_weights[ 1 ] += 0,1;
	level.brainwash_weights[ 0 ] -= 0,1;
	i = 0;
	while ( i < 2 )
	{
		level.brainwash_weights[ i ] = clamp( level.brainwash_weights[ i ], 0, 1 );
		i++;
	}
	thread brainwash_aim( level.brainwash_weights );
}

check_for_bump( n_time_passed )
{
	if ( ( level.n_time_max - ( n_time_passed * 0,05 ) ) > 2 )
	{
		if ( int( n_time_passed ) % choose_random_bump_count() )
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 0;
	}
}

choose_random_bump_count()
{
	switch( randomint( 3 ) )
	{
		case 0:
			return 10;
			case 1:
				return 20;
				default:
					return 25;
				}
			}
		}
	}
}

brainwash_strength_test_update( player, n_input_per_press, n_decay_not_pressed, n_decay_button_held )
{
	level endon( "stop_button_mash" );
	player.strengthtest_button_presses = 0;
	player.strengthtest_max_button_presses = 100000;
	button_state = 1;
	while ( 1 )
	{
		if ( player usebuttonpressed() )
		{
			if ( button_state == 1 || button_state == 3 )
			{
				button_state = 2;
			}
			else
			{
				if ( button_state == 2 )
				{
					button_state = 0;
				}
			}
		}
		else if ( button_state == 0 || button_state == 2 )
		{
			button_state = 3;
		}
		else
		{
			if ( button_state == 3 )
			{
				button_state = 1;
			}
		}
		if ( button_state == 1 )
		{
			player.strengthtest_button_presses -= n_decay_not_pressed / 100;
			level.b_player_input = 0;
		}
		if ( button_state == 0 && isDefined( n_decay_button_held ) )
		{
			player.strengthtest_button_presses -= n_decay_button_held / 100;
		}
		if ( button_state == 2 )
		{
			player.strengthtest_button_presses += n_input_per_press / 100;
			level.b_player_input = 1;
		}
		if ( player.strengthtest_button_presses <= 0 )
		{
			player.strengthtest_button_presses = 0;
		}
		wait 0,05;
	}
}

brainwash_aim( weights )
{
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_offscreen, weights[ 0 ], 0,05, 1 );
	level.brainwash_model setanim( %int_player_afghan_gun_raise_middle_to_finish, weights[ 1 ], 0,05, 1 );
}

set_brainwash_weights( player_leftstick_y, num_scene )
{
	player_leftstick_y = clamp( player_leftstick_y, -1, 1 );
	level.brainwash_input = player_leftstick_y * -1;
	if ( abs( level.brainwash_input ) < 0,01 )
	{
		return level.brainwash_weights;
	}
	if ( !isDefined( level.brainwash_weights_negative ) )
	{
		level.brainwash_weights_negative = 0;
	}
	if ( num_scene == 1 )
	{
		weightchangespeed = 0,02;
		if ( level.brainwash_weights[ 1 ] >= 0,6 )
		{
			weightchangespeedstruggle = randomfloatrange( 0, 0,03 );
		}
		else if ( level.brainwash_weights[ 1 ] >= 0,3 )
		{
			weightchangespeedstruggle = randomfloatrange( -0,01, 0,03 );
		}
		else
		{
			weightchangespeedstruggle = randomfloatrange( -0,02, 0,02 );
		}
	}
	else if ( num_scene == 2 )
	{
		weightchangespeed = randomfloatrange( -0,01, 0,04 );
		if ( weightchangespeed > 0 )
		{
			clamp( weightchangespeed, 3, 4 );
		}
		if ( level.brainwash_weights[ 1 ] >= 0,7 )
		{
			weightchangespeedstruggle = randomfloatrange( -0,01, 0,03 );
		}
		else if ( level.brainwash_weights[ 1 ] >= 0,5 )
		{
			weightchangespeedstruggle = randomfloatrange( -0,02, 0,03 );
		}
		else
		{
			weightchangespeedstruggle = randomfloatrange( -0,03, 0,03 );
		}
	}
	else if ( num_scene == 3 )
	{
		weightchangespeed = randomfloatrange( -0,01, 0,1 );
		if ( weightchangespeed > 0 )
		{
			clamp( weightchangespeed, 4, 5 );
		}
		if ( level.brainwash_weights[ 1 ] >= 0,9 )
		{
			weightchangespeedstruggle = randomfloatrange( 0,01, 0,02 );
		}
		if ( level.brainwash_weights[ 1 ] >= 0,8 )
		{
			weightchangespeedstruggle = randomfloatrange( -0,03, 0,03 );
		}
		else if ( level.brainwash_weights[ 1 ] >= 0,6 )
		{
			weightchangespeedstruggle = randomfloatrange( -0,04, 0,04 );
		}
		else
		{
			weightchangespeedstruggle = randomfloatrange( -0,07, 0,02 );
		}
	}
	if ( level.brainwash_input > 0 )
	{
		level.brainwash_weights[ 0 ] -= weightchangespeed;
		level.brainwash_weights[ 1 ] += weightchangespeed;
	}
	else
	{
		level.brainwash_weights[ 0 ] += weightchangespeedstruggle;
		level.brainwash_weights[ 1 ] -= weightchangespeedstruggle;
	}
	i = 0;
	while ( i < 2 )
	{
		level.brainwash_weights[ i ] = clamp( level.brainwash_weights[ i ], 0, 1 );
		i++;
	}
	return level.brainwash_weights;
}
