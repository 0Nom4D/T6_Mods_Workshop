#include maps/_challenges_sp;
#include maps/_so_rts_challenges;
#include maps/_so_rts_ai;
#include maps/createart/so_rts_mp_overflow_art;
#include maps/_so_rts_main;
#include maps/_so_rts_poi;
#include maps/_osprey;
#include maps/_so_rts_catalog;
#include maps/_so_rts_event;
#include maps/_so_rts_support;
#include maps/_so_rts_rules;
#include maps/_statemachine;
#include maps/_anim;
#include maps/_music;
#include maps/_audio;
#include maps/_scene;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );
#using_animtree( "player" );
#using_animtree( "animated_props" );

precache()
{
	precacheshader( "compass_a10" );
	precacheshader( "cinematic2d" );
	precacheshader( "compass_static" );
	precachestring( &"hud_update_vehicle_custom" );
	precachestring( &"goggles_hud" );
	precachestring( &"SO_RTS_MP_OVERFLOW_IDENT" );
	precachestring( &"SO_RTS_MP_OVERFLOW_PROCESSING" );
	precachestring( &"SO_RTS_MP_OVERFLOW_POSITIVE" );
	precachemodel( "viewmodel_binoculars" );
	level.rts.intrudermodel = "t6_wpn_emp_device_world";
	precachemodel( level.rts.intrudermodel );
	precachemodel( "fxanim_gp_vtol_drop_asd_drone_mod" );
	precachemodel( "fxanim_gp_vtol_drop_claw_mod" );
	precachemodel( "veh_t6_air_v78_vtol_burned" );
	precachemodel( "t6_wpn_launch_smaw_prop_missile" );
	level._effect[ "network_intruder_death" ] = loadfx( "explosions/fx_rts_exp_hack_device" );
	level._effect[ "network_intruder_blink" ] = loadfx( "misc/fx_equip_light_green" );
	level._effect[ "rocket_fire_muzzleflash" ] = loadfx( "weapon/muzzleflashes/fx_at4_flash_world" );
	level._effect[ "rocket_trail" ] = loadfx( "trail/fx_rts_trail_shoulder_missile" );
	level._effect[ "vtol1_explosion" ] = loadfx( "explosions/fx_rts_vexp_overflow_vtol_future" );
	level._effect[ "vtol2_explosion" ] = loadfx( "explosions/fx_vexp_hind_future" );
	level._effect[ "vtol3_explosion" ] = loadfx( "maps/haiti/fx_haiti_vtol_crash" );
	level._effect[ "vtol_explosion_trail" ] = loadfx( "smoke/fx_rts_smoke_vtol_damage" );
	level._effect[ "outro_zhao_hit" ] = loadfx( "blood/fx_rts_overflow_blood_zhao" );
	level._effect[ "outro_player_picture" ] = loadfx( "misc/fx_rts_camera_snap_pic" );
	level._effect[ "kard_fake_flash" ] = loadfx( "weapon/muzzleflashes/fx_heavy_flash_base" );
	level._effect[ "zhao_vtol_damage_fx_1" ] = loadfx( "smoke/fx_rts_vtol_engine_smolder" );
	level._effect[ "zhao_vtol_damage_fx_2" ] = loadfx( "system_elements/fx_null" );
	level._effect[ "zhao_vtol_damage_fx_3" ] = loadfx( "system_elements/fx_null" );
	level._effect[ "zhao_vtol_damage_fx_4" ] = loadfx( "smoke/fx_rts_vtol_socotra_smoke_int" );
	level._effect[ "zhao_vtol_damage_fx_5" ] = loadfx( "electrical/fx_rts_elec_vtol_int_sparks" );
	level._effect[ "zhao_vtol_damage_fx_6" ] = loadfx( "electrical/fx_elec_claw_leg_joint_med_lft" );
	level._effect[ "zhao_vtol_damage_fx_7" ] = loadfx( "light/fx_rts_light_vtol_zhao_spot" );
	maps/_quadrotor::init();
	maps/_metal_storm::init();
	maps/_claw::init();
	maps/_cic_turret::init();
}

overflow_level_scenario_one()
{
	level.custom_introscreen = ::overflow_custom_introscreen;
	level.rts.codespawncb = ::overflowcodespawner;
	level.rts.custom_ai_getgrenadecb = ::overflow_aigrenadeget;
	level.rts.turretdamagecb = ::turret_damagewatch;
	level.rts.ai_damage_cb = ::ai_damagewatch;
	level.supportsaiweaponswitching = 1;
	flag_init( "intro_done" );
	flag_init( "outro_done" );
	flag_init( "red_alert" );
	maps/_so_rts_rules::set_gamemode( "overflow1" );
	setup_scenes();
	claymore_setup();
	overflow_geo_changes();
	flag_wait( "all_players_connected" );
	maps/_so_rts_support::hide_player_hud();
	flag_wait( "start_rts" );
	level.rts.enemy_unitthinkcb = ::new_enemy_squad;
	level.rts.patrollers = [];
	level.rts.disallow_player_sidearm = 1;
	maps/_so_rts_event::trigger_event( "main_music_state" );
	setmusicstate( "OVERFLOW_ACTION" );
	level thread overflow_intruderwatch();
	level thread maps/_so_rts_support::player_oobwatch();
	level thread overflow_ai_takeover_off();
	level thread overflow_ai_takeover_on();
/#
	overflow_setup_devgui();
#/
	infinite_ally = level.rts.player maps/_utility::get_story_stat( "ALL_PAKISTAN_RECORDINGS" );
	if ( infinite_ally > 0 )
	{
		maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg_pkg", "allies", -1 );
		maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg2_pkg", "allies", -1 );
		maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg3_pkg", "allies", -1 );
		maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg4_pkg", "allies", -1 );
	}
	else
	{
		level thread outofally_watch();
	}
	maps/_so_rts_catalog::spawn_package( "infantry_ally_reg_pkg", "allies", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_ally_reg2_pkg", "allies", 1, ::overflow_level_player_startfps );
	level.rts.game_rules.num_nag_squads = 2;
	flag_wait( "intro_done" );
	flag_set( "rts_start_clock" );
	maps/_so_rts_catalog::setpkgdelivery( "infantry_ally_reg_pkg", "CODE" );
	maps/_so_rts_catalog::setpkgdelivery( "infantry_ally_reg2_pkg", "CODE" );
	maps/_so_rts_catalog::spawn_package( "infantry_ally_reg3_pkg", "allies", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_ally_reg4_pkg", "allies", 1 );
	squad = maps/_so_rts_squad::getsquadbypkg( "infantry_ally_reg3_pkg", "allies" );
	maps/_so_rts_squad::ordersquaddefend( level.rts.player.origin, squad.id, 1 );
	squad = maps/_so_rts_squad::getsquadbypkg( "infantry_ally_reg4_pkg", "allies" );
	maps/_so_rts_squad::ordersquaddefend( level.rts.player.origin, squad.id, 1 );
	level thread maps/_so_rts_support::flag_set_innseconds( "start_rts_enemy", 20 );
	level thread setup_objectives();
	level.player thread setup_challenges();
	setup_patrolroutes();
	enemyspawninit();
	if ( infinite_ally > 0 )
	{
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", -1 );
	}
	else
	{
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", 10 );
	}
	level thread zhao_vtol_setup();
	level thread zhao_proximitywatch();
	if ( infinite_ally > 0 )
	{
		maps/_so_rts_event::trigger_event( "dlg_intro_yeshelp" );
	}
	else
	{
		maps/_so_rts_event::trigger_event( "dlg_intro_nohelp" );
	}
	wait 5;
	maps/_so_rts_event::trigger_event( "dlg_kill_order" );
	level waittill( "dlg_kill_order_done" );
	maps/_so_rts_event::trigger_event( "dlg_move_to_crash" );
	wait 5;
	maps/_so_rts_event::trigger_event( "dlg_obj_updated" );
	maps/_so_rts_event::trigger_event( "dlg_so_ack" );
}

overflow_custom_introscreen( level_prefix, number_of_lines, totaltime, text_color )
{
	flag_wait( "all_players_connected" );
	wait 1;
	luinotifyevent( &"hud_add_title_line", 4, level_prefix, number_of_lines, totaltime, text_color );
	waittill_textures_loaded();
	wait 11;
	flag_set( "introscreen_complete" );
}

overflow_intruderwatch()
{
	while ( !flag( "rts_game_over" ) )
	{
		level waittill( "intruder_planted", device );
		wait 3;
		if ( isDefined( device ) && device.team == "allies" )
		{
			maps/_so_rts_event::trigger_event( "dlg_intruder_plant_confirm" );
		}
	}
}

overflow_ai_takeover_trigger( oob )
{
	while ( isDefined( self ) )
	{
		self waittill( "trigger", who );
		if ( isDefined( oob ) && oob )
		{
			if ( isDefined( who ) )
			{
				who.allow_oob = 1;
				who.no_takeover = 1;
				who.unselectable = 1;
			}
			continue;
		}
		else
		{
			if ( isDefined( who ) )
			{
				who.allow_oob = undefined;
				who.no_takeover = undefined;
				who.unselectable = undefined;
				if ( isDefined( who.manual_lui_add ) && who.manual_lui_add )
				{
					who.manual_lui_add = undefined;
					luinotifyevent( &"rts_add_friendly_human", 5, who getentitynumber(), who.squadid, 35, 0, who.pkg_ref.idx );
				}
			}
		}
	}
}

overflow_ai_takeover_off()
{
	level endon( "rts_terminated" );
	triggers = getentarray( "rts_takeover_OFF", "targetname" );
	array_thread( triggers, ::overflow_ai_takeover_trigger, 1 );
}

overflow_ai_takeover_on()
{
	level endon( "rts_terminated" );
	triggers = getentarray( "rts_takeover_ON", "targetname" );
	array_thread( triggers, ::overflow_ai_takeover_trigger, 0 );
}

overflow_aigrenadeget( team )
{
	roll = randomint( 100 );
	if ( team == "allies" )
	{
		if ( roll > 50 )
		{
			return "emp_grenade_sp";
		}
		else
		{
			return "sticky_grenade_future_ai_sp";
		}
	}
	return "";
}

outroally_squadquantityupdate()
{
}

outofally_watch()
{
	level endon( "overflow_mission_complete" );
	while ( !flag( "rts_game_over" ) )
	{
		if ( maps/_so_rts_catalog::package_getnumteamresources( "allies" ) == 0 )
		{
			level thread maps/_so_rts_rules::mission_complete( 0 );
			return;
		}
		wait 1;
	}
}

zhao_vtol_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	return 0;
}

zhao_vtol_setup()
{
	zhao_vtol = getent( "zhao_vtol", "targetname" );
	zhao_vtol.overridevehicledamage = ::zhao_vtol_damage_override;
	level thread run_scene( "zhao_vtol_idle" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_1" ], zhao_vtol, "tag_engine_right" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_2" ], zhao_vtol, "tag_collective_left" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_3" ], zhao_vtol, "tag_light_cargo01" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_4" ], zhao_vtol, "tag_deathfx" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_5" ], zhao_vtol, "tag_body" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_6" ], zhao_vtol, "front_door_r_jnt" );
	playfxontag( level._effect[ "zhao_vtol_damage_fx_7" ], zhao_vtol, "tag_body_back" );
}

zhao_rtswatch( trigger )
{
	while ( isDefined( trigger ) )
	{
		if ( flag( "rts_mode" ) )
		{
			trigger notify( "trigger" );
			return;
		}
		wait 0,1;
	}
}

zhao_proximitywatch()
{
	getent( "zhao_vtol", "targetname" ) thread maps/_osprey::close_hatch();
	level waittill( "poi_captured_allies", ref );
	while ( isDefined( level.rts.switch_trans ) )
	{
		wait 0,05;
	}
	if ( flag( "fps_mode" ) )
	{
		vtol_trigger = getent( "downed_vtol_trigger", "targetname" );
		level thread zhao_rtswatch( vtol_trigger );
		set_objective( level.obj_kill_hvt, vtol_trigger, "breadcrumb" );
		vtol_trigger waittill( "trigger" );
		vtol_trigger delete();
	}
	set_objective( level.obj_kill_hvt, undefined, "done" );
	maps/_so_rts_rules::mission_complete( 1 );
}

setup_objectives()
{
	level thread maps/_objectives::init();
	level.obj_kill_hvt = register_objective( &"SO_RTS_MP_OVERFLOW_OBJ_ZHAO" );
	level.obj_hack_zhao = register_objective( &"SO_RTS_MP_OVERFLOW_OBJ_POI_ZHAO" );
	flag_wait( "intro_done" );
	set_objective( level.obj_kill_hvt );
	wait 5;
	set_objective( level.obj_hack_zhao );
	maps/_so_rts_poi::poi_setobjectivenumber( "rts_poi_zhao", level.obj_hack_zhao, "waypoint_destroy_a" );
}

dlg_notetrack_fired( ent, note )
{
	maps/_so_rts_event::trigger_event( note );
}

setup_scenes()
{
	add_scene( "pak_intro_pt1", "intro_loc" );
	add_player_anim( "player_body", %p_war_pak_intro_sc1_player, 1, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	add_notetrack_flag( "player_body", "start_binocular_fadein", "intro_fade_in" );
	add_notetrack_custom_function( "player_body", "dlg_intro_visual", ::dlg_notetrack_fired, 0, 1 );
	add_vehicle_anim( "intro_vtol1", %v_war_pak_intro_sc1_vtol_1 );
	add_vehicle_anim( "intro_vtol2", %v_war_pak_intro_sc1_vtol_2 );
	add_vehicle_anim( "intro_vtol3", %v_war_pak_intro_sc1_vtol_3 );
	add_scene( "pak_intro_pt2", "intro_loc" );
	add_actor_anim( "guy0", %ch_war_pak_intro_sc2_seal_1 );
	add_notetrack_custom_function( "guy0", "rocket_fire", ::play_rocket_muzzle_flash_guy0 );
	add_actor_anim( "guy1", %ch_war_pak_intro_sc2_seal_2 );
	add_notetrack_custom_function( "guy1", "rocket_fire", ::play_rocket_muzzle_flash_guy1 );
	add_player_anim( "player_body", %p_war_pak_intro_sc2_player, 1, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	add_notetrack_custom_function( "player_body", "rocket_fire", ::play_rocket_muzzle_flash_player );
	add_notetrack_custom_function( "player_body", "dlg_intro_hurry", ::dlg_notetrack_fired, 0, 1 );
	add_notetrack_custom_function( "player_body", "dlg_intro_rocket", ::dlg_notetrack_fired, 0, 1 );
	add_notetrack_custom_function( "player_body", "dlg_intro_impact", ::dlg_notetrack_fired, 0, 1 );
	add_notetrack_custom_function( "player_body", "dlg_intro_kia", ::dlg_notetrack_fired, 0, 1 );
	add_notetrack_custom_function( "player_body", "dlg_intro_moving", ::dlg_notetrack_fired, 0, 1 );
	add_vehicle_anim( "intro_vtol1", %v_war_pak_intro_sc2_vtol_1 );
	add_notetrack_custom_function( "intro_vtol1", "hit", ::intro_vtol1_explosion );
	add_notetrack_fx_on_tag( "intro_vtol1", "hit", "vtol_explosion_trail", "tag_fx_engine_left1" );
	add_notetrack_fx_on_tag( "intro_vtol1", "hit", "vtol_explosion_trail", "tag_fx_engine_right1" );
	add_vehicle_anim( "intro_vtol2", %v_war_pak_intro_sc2_vtol_2 );
	add_notetrack_custom_function( "intro_vtol2", "hit", ::intro_vtol2_explosion );
	add_notetrack_fx_on_tag( "intro_vtol2", "hit", "vtol2_explosion", "tag_deathfx" );
	add_notetrack_fx_on_tag( "intro_vtol2", "hit", "vtol_explosion_trail", "tag_fx_engine_left1" );
	add_notetrack_fx_on_tag( "intro_vtol2", "hit", "vtol_explosion_trail", "tag_fx_engine_right1" );
	add_notetrack_exploder( "intro_vtol2", "vtol_crash", 889 );
	add_vehicle_anim( "intro_vtol3", %v_war_pak_intro_sc2_vtol_3 );
	add_notetrack_custom_function( "intro_vtol3", "hit", ::intro_vtol3_explosion );
	add_notetrack_fx_on_tag( "intro_vtol3", "hit", "vtol3_explosion", "tag_deathfx" );
	add_notetrack_fx_on_tag( "intro_vtol3", "hit", "vtol_explosion_trail", "tag_fx_engine_left1" );
	add_notetrack_fx_on_tag( "intro_vtol3", "hit", "vtol_explosion_trail", "tag_fx_engine_right1" );
	add_notetrack_exploder( "intro_vtol3", "vtol_crash", 889 );
	add_prop_anim( "launcher_1", %o_war_pak_intro_sc2_launcher_1, "t6_wpn_launch_smaw_prop_world", 1 );
	add_prop_anim( "launcher_2", %o_war_pak_intro_sc2_launcher_2, "t6_wpn_launch_smaw_prop_world", 1 );
	add_prop_anim( "launcher_3", %o_war_pak_intro_sc2_launcher_player, "t6_wpn_launch_smaw_prop_view", 1 );
	add_prop_anim( "missile_1", %o_war_pak_intro_sc2_missile_01, "t6_wpn_launch_smaw_prop_missile", 1 );
	add_prop_anim( "missile_2", %o_war_pak_intro_sc2_missile_02, "t6_wpn_launch_smaw_prop_missile", 1 );
	add_prop_anim( "missile_3", %o_war_pak_intro_sc2_missile_03, "t6_wpn_launch_smaw_prop_missile", 1 );
	add_scene( "zhao_vtol_idle", "outro_loc", 0, 0, 1 );
	add_vehicle_anim( "zhao_vtol", %v_war_pak_succeed_crashed_vtol_startloop );
	add_scene( "pak_outro_success", "outro_loc" );
	add_vehicle_anim( "zhao_vtol", %v_war_pak_succeed_crashed_vtol );
	add_actor_anim( "ai_spawner_zhao", %ch_war_pak_succeed_zhao, undefined, undefined, undefined, 1 );
	add_notetrack_fx_on_tag( "ai_spawner_zhao", "hit", "outro_zhao_hit", "J_SpineUpper" );
	addnotetrack_customfunction( "ai_spawner_zhao", "hit", ::overflow_outro_zhao_hit_slowmo );
	add_player_anim( "player_body", %p_war_pak_succeed_player, 1, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	addnotetrack_customfunction( "player_body", "fire", ::overflow_outro_player_fire );
	addnotetrack_customfunction( "player_body", "take_picture", ::overflow_outro_player_takes_picture );
	add_notetrack_flag( "player_body", "fade_out", "outro_success_fade_out" );
	add_notetrack_fx_on_tag( "player_body", "take_picture", "outro_player_picture", "tag_camera" );
	add_scene( "pak_outro_failure", "outro_loc" );
	add_player_anim( "player_body", %p_war_pak_fail_player, 1, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	add_notetrack_flag( "player_body", "fade_in", "outro_fail_fade_in" );
	add_notetrack_flag( "player_body", "fade_out", "outro_fail_fade_out" );
	add_actor_anim( "ai_spawner_zhao", %ch_war_pak_fail_zhao );
	add_actor_anim( "guy0", %ch_war_pak_fail_seal, undefined, undefined, undefined, undefined, undefined, "ai_spawner_enemy_assault_scripted" );
	add_vehicle_anim( "zhao_vtol", %v_war_pak_fail_crashed_vtol );
	add_vehicle_anim( "outro_vtol1", %v_war_pak_fail_vtol_1, undefined, undefined, undefined, undefined, "heli_v78_rts" );
	add_vehicle_anim( "outro_vtol2", %v_war_pak_fail_vtol_2, undefined, undefined, undefined, undefined, "heli_v78_rts" );
	precache_assets();
}

intro_vtol1_explosion()
{
	vtol1 = getent( "intro_vtol1", "script_noteworthy" );
	origin = vtol1 gettagorigin( "tag_deathfx" );
	playfx( level._effect[ "vtol1_explosion" ], origin );
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_1" );
	rocket delete();
	vtol1.delete_on_death = 1;
	vtol1 notify( "death" );
	if ( !isalive( vtol1 ) )
	{
		vtol1 delete();
	}
}

intro_vtol2_explosion()
{
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_2" );
	rocket delete();
}

intro_vtol3_explosion()
{
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_3" );
	rocket delete();
}

play_rocket_muzzle_flash_guy0()
{
	launcher = get_model_or_models_from_scene( "pak_intro_pt2", "launcher_1" );
	playfxontag( level._effect[ "rocket_fire_muzzleflash" ], launcher, "TAG_FX" );
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_1" );
	playfxontag( level._effect[ "rocket_trail" ], rocket, "TAG_FX" );
}

play_rocket_muzzle_flash_guy1()
{
	launcher = get_model_or_models_from_scene( "pak_intro_pt2", "launcher_2" );
	playfxontag( level._effect[ "rocket_fire_muzzleflash" ], launcher, "TAG_FX" );
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_2" );
	playfxontag( level._effect[ "rocket_trail" ], rocket, "TAG_FX" );
}

play_rocket_muzzle_flash_player()
{
	launcher = get_model_or_models_from_scene( "pak_intro_pt2", "launcher_3" );
	playfxontag( level._effect[ "rocket_fire_muzzleflash" ], launcher, "TAG_FX" );
	rocket = get_model_or_models_from_scene( "pak_intro_pt2", "missile_3" );
	playfxontag( level._effect[ "rocket_trail" ], rocket, "TAG_FX" );
}

ai_damagewatch( einflictor, eattacker, idamage, meansofdeath )
{
	if ( flag( "rts_mode" ) && isDefined( eattacker ) && isai( eattacker ) && eattacker.team == "allies" )
	{
		idamage *= 2;
	}
	return idamage;
}

turret_damagewatch( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
	if ( flag( "rts_mode" ) && isDefined( eattacker ) && isai( eattacker ) && eattacker.team != self.team )
	{
		idamage *= 1,5;
	}
	return idamage;
}

setup_patrolroutes()
{
	level.rts.patrol_routes = [];
	i = 0;
	while ( i < 2 )
	{
		level.rts.patrol_routes[ i ] = getstructarray( "patrol_route_" + i, "script_noteworthy" );
		i++;
	}
}

overflow_level_player_startfps()
{
	playerstart = getent( "rts_player_start", "targetname" );
/#
	assert( isDefined( playerstart ) );
#/
	nextsquad = getsquadbypkg( "infantry_ally_reg_pkg", "allies" );
	level.rts.activesquad = nextsquad.id;
	level.rts.targetteammate = nextsquad.members[ 0 ];
	adjacentsquad = getsquadbypkg( "infantry_ally_reg2_pkg", "allies" );
	adjacentsquad.members[ 0 ].targetname = "guy0";
	adjacentsquad.members[ 0 ].animname = "guy0";
	adjacentsquad.members[ 1 ].targetname = "guy1";
	adjacentsquad.members[ 1 ].animname = "guy1";
	level.rts.targetteammate forceteleport( playerstart.origin, playerstart.angles );
	level thread maps/_so_rts_main::player_in_control();
	level waittill( "switch_complete" );
	level.rts.player setorigin( playerstart.origin );
	level.rts.player setplayerangles( playerstart.angles );
	flag_set( "block_input" );
	level.rts.player freezecontrols( 1 );
	overflow_startintro();
	flag_wait( "intro_done" );
	level.rts.player freezecontrols( 0 );
	wait 0,05;
	maps/_so_rts_squad::ordersquadfollowplayer( nextsquad.id, 0 );
	flag_clear( "block_input" );
}

hide_intro_vtols()
{
	vtols = getentarray( "intro_vtol", "targetname" );
	_a608 = vtols;
	_k608 = getFirstArrayKey( _a608 );
	while ( isDefined( _k608 ) )
	{
		vtol = _a608[ _k608 ];
		vtol hide();
		vtol notsolid();
		_k608 = getNextArrayKey( _a608, _k608 );
	}
	level waittill( "unhide_vtols" );
	vtols = getentarray( "intro_vtol", "targetname" );
	_a617 = vtols;
	_k617 = getFirstArrayKey( _a617 );
	while ( isDefined( _k617 ) )
	{
		vtol = _a617[ _k617 ];
		vtol show();
		_k617 = getNextArrayKey( _a617, _k617 );
	}
}

overflow_introsetupbinoculars()
{
	flag_wait( "pak_intro_pt2_started" );
	player_body = get_model_or_models_from_scene( "pak_intro_pt2", "player_body" );
	player_body attach( "viewmodel_binoculars", "tag_weapon1" );
}

overflow_startintro()
{
	flag_wait( "introscreen_complete" );
	flag_set( "rts_event_ready" );
	level.rts.player freezecontrols( 1 );
	level thread overflow_startintro_fadein();
	maps/_so_rts_support::hide_player_hud();
	level.player setclientflag( 8 );
	level.player visionsetnaked( "sp_monsoon_binoc", 1,5 );
	level.cin_id = play_movie_async( "mon_nocs_hud", 1, 1, undefined, 0, undefined, undefined, 0, 1, 0, 0 );
	level thread overflow_movie_think();
	thread run_scene( "pak_intro_pt1" );
	wait 2,5;
	screen_fade_out( 0,5 );
	luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"goggles_hud" );
	level.player visionsetnaked( "mp_socotra", 1,5 );
	level.player clearclientflag( 8 );
	level notify( "stop_intro_cinematic_bino" );
	luinotifyevent( &"hud_update_vehicle_custom", 1, 0 );
	level thread screen_fade_in( 1,5 );
	level thread maps/createart/so_rts_mp_overflow_art::intro_igc();
	level thread overflow_introsetupbinoculars();
	run_scene( "pak_intro_pt2" );
	scene_wait( "pak_intro_pt2" );
	flag_set( "intro_done" );
	flag_set( "rts_hud_on" );
	maps/_so_rts_support::show_player_hud();
	level.rts.player freezecontrols( 0 );
	level thread hide_intro_vtols();
}

overflow_movie_think()
{
	while ( !isDefined( level.fullscreen_cin_hud ) )
	{
		wait 0,05;
	}
	level.fullscreen_cin_hud.alpha = 0;
	level.fullscreen_cin_hud fadeovertime( 2 );
	level.fullscreen_cin_hud.alpha = 1;
	level waittill( "stop_intro_cinematic_bino" );
	level.fullscreen_cin_hud fadeovertime( 2 );
	level.fullscreen_cin_hud.alpha = 0;
	stop3dcinematic( level.cin_id );
}

overflow_startintro_fadein()
{
	flag_wait( "intro_fade_in" );
	maps/_so_rts_support::hide_player_hud();
	thread screen_fade_in( 1,5 );
}

overflowcodespawner( pkg_ref, team, callback, squadid )
{
	allies = getaiarray( "allies" );
	if ( team == "allies" )
	{
		if ( isDefined( pkg_ref.incodespawn ) && pkg_ref.incodespawn )
		{
			return -1;
		}
		pkg_ref.incodespawn = 1;
		squad = maps/_so_rts_squad::getsquadbypkg( pkg_ref.ref, "allies" );
		while ( isDefined( squad ) )
		{
			_a734 = squad.members;
			_k734 = getFirstArrayKey( _a734 );
			while ( isDefined( _k734 ) )
			{
				guy = _a734[ _k734 ];
				guy.already_existed = 1;
				_k734 = getNextArrayKey( _a734, _k734 );
			}
		}
		origin = getstruct( "ally_spawn_loc1", "targetname" ).origin;
		squadid = maps/_so_rts_ai::spawn_ai_package_standard( pkg_ref, team, undefined, origin, undefined, 1 );
		maps/_so_rts_squad::reissuesquadlastorders( squadid );
		squad = maps/_so_rts_squad::getsquadbypkg( pkg_ref.ref, "allies" );
		while ( isDefined( squad ) )
		{
			_a747 = squad.members;
			_k747 = getFirstArrayKey( _a747 );
			while ( isDefined( _k747 ) )
			{
				guy = _a747[ _k747 ];
				if ( isDefined( guy.already_existed ) && !guy.already_existed )
				{
					guy.allow_oob = 1;
					guy.no_takeover = 1;
				}
				else
				{
					guy.already_existed = undefined;
				}
				_k747 = getNextArrayKey( _a747, _k747 );
			}
		}
		pkg_ref.incodespawn = undefined;
	}
	else if ( pkg_ref.ref == "infantry_enemy_reg_pkg" )
	{
		spots = getentarray( "enemy_spawnLoc", "targetname" );
		if ( flag( "fps_mode" ) )
		{
			spot = maps/_so_rts_support::getfurthestinarray( level.rts.player.origin, spots );
		}
		else
		{
			allysquads = getteamsquads( "allies" );
			center = ( 0, 1, 0 );
			_a776 = allysquads;
			_k776 = getFirstArrayKey( _a776 );
			while ( isDefined( _k776 ) )
			{
				squad = _a776[ _k776 ];
				center += squad.centerpoint;
				_k776 = getNextArrayKey( _a776, _k776 );
			}
			center = ( center[ 0 ] / allysquads.size, center[ 1 ] / allysquads.size, center[ 2 ] / allysquads.size );
			spot = maps/_so_rts_support::getfurthestinarray( center, spots );
		}
		squadid = maps/_so_rts_squad::createsquad( level.rts.enemy_center.origin, team, pkg_ref );
		_a784 = pkg_ref.units;
		_k784 = getFirstArrayKey( _a784 );
		while ( isDefined( _k784 ) )
		{
			unit = _a784[ _k784 ];
			ai_ref = level.rts.ai[ unit ];
			ai = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
			if ( isDefined( ai ) )
			{
				ai forceteleport( spot.origin );
				ai.ai_ref = ai_ref;
				ai maps/_so_rts_squad::addaitosquad( squadid );
			}
			_k784 = getNextArrayKey( _a784, _k784 );
		}
		maps/_so_rts_catalog::units_delivered( team, squadid );
	}
	else
	{
		if ( pkg_ref.ref == "turret_pkg" )
		{
			ai_ref = level.rts.ai[ pkg_ref.units[ 0 ] ];
			squadid = maps/_so_rts_squad::createsquad( level.rts.enemy_center.origin, team, pkg_ref );
			turrets = getentarray( "sentry_turret_axis", "targetname" );
			_a803 = turrets;
			_k803 = getFirstArrayKey( _a803 );
			while ( isDefined( _k803 ) )
			{
				turret = _a803[ _k803 ];
				turret.ai_ref = ai_ref;
				turret maps/_so_rts_squad::addaitosquad( squadid );
				_k803 = getNextArrayKey( _a803, _k803 );
			}
			maps/_so_rts_catalog::units_delivered( team, squadid );
		}
	}
	if ( isDefined( callback ) )
	{
		thread [[ callback ]]( squadid );
	}
	return squadid;
}

overflow_mission_complete_s1( success, basejustlost )
{
	if ( isDefined( level.rts.game_success ) )
	{
		return;
	}
	level notify( "mission_complete" );
	flag_set( "block_input" );
	level.rts.player freezecontrols( 1 );
	level.rts.game_success = success;
	while ( isDefined( level.rts.switch_trans ) )
	{
		wait 0,05;
	}
	level notify( "overflow_mission_complete" );
	level endon( "overflow_mission_complete" );
	_a839 = level.rts.networkintruders[ "allies" ];
	_k839 = getFirstArrayKey( _a839 );
	while ( isDefined( _k839 ) )
	{
		intruder = _a839[ _k839 ];
		if ( isDefined( intruder ) )
		{
			intruder dodamage( intruder.health + 999, intruder.origin );
		}
		_k839 = getNextArrayKey( _a839, _k839 );
	}
	maps/_so_rts_poi::deleteallpoi();
	maps/_so_rts_support::time_countdown_delete();
	maps/_so_rts_squad::squad_hideallsquadmarkers( 1 );
	level.rts.player freezecontrols( 1 );
	level.rts.player set_ignoreme( 1 );
	level.rts.player enableinvulnerability();
	tactview = flag( "rts_mode" );
	if ( flag( "rts_mode" ) || !success )
	{
		screen_fade_out( 0,5 );
	}
	flag_clear( "rts_mode" );
	flag_set( "fps_mode" );
	level clientnotify( "rts_OFF" );
	flag_set( "rts_mode_locked_out" );
	luinotifyevent( &"rts_hud_visibility", 1, 0 );
	level.rts.player clearclientflag( 3 );
	maps/_so_rts_event::event_clearall( 0 );
	if ( success )
	{
		flag_set( "rts_hud_on" );
		maps/_so_rts_support::show_player_hud();
		luinotifyevent( &"rts_toggle_button_prompts", 1, 0 );
		overflow_outro_success( tactview );
		flag_clear( "rts_hud_on" );
		maps/_so_rts_support::hide_player_hud();
	}
	else
	{
		flag_clear( "rts_hud_on" );
		maps/_so_rts_support::hide_player_hud();
		overflow_outro_fail();
	}
	if ( success )
	{
	}
	else
	{
	}
	objective_state( level.obj_kill_hvt, "failed", "done" );
	flag_set( "rts_game_over" );
	flag_clear( "rts_mode_locked_out" );
	flag_clear( "rts_event_ready" );
	level thread maps/_so_rts_support::missioncompletemsg( success );
	if ( isDefined( success ) && success )
	{
		level notify( "mission_success" );
		level.player set_story_stat( "SO_WAR_PAKISTAN_SUCCESS", 1 );
		level.player set_story_stat( "CHINA_IS_ALLY", 1 );
		level.player giveachievement_wrapper( "SP_RTS_PAKISTAN" );
		screen_fade_out( 0,5 );
		maps/_so_rts_support::missionsuccessmenu();
	}
	else
	{
		maps/_so_rts_support::missionfailuremenu();
	}
	level clientnotify( "rts_fd" );
	maps/_so_rts_support::show_player_hud();
	maps/_so_rts_support::toggle_damage_indicators( 1 );
	nextmission();
}

mission_complete_clear_entities()
{
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg2_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg3_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg4_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", 0 );
	flag_clear( "rts_event_ready" );
	array_func( getaiarray(), ::mission_complete_clear_entity );
	array_func( getvehiclearray(), ::mission_complete_clear_entity );
	wait 0,05;
	flag_set( "rts_event_ready" );
}

mission_complete_clear_entity()
{
	if ( isDefined( self.donotclear ) && self.donotclear )
	{
		return;
	}
	self delete();
}

overflow_outro_success( tactview )
{
	zhao_vtol = getent( "zhao_vtol", "targetname" );
	zhao_vtol.donotclear = 1;
	mission_complete_clear_entities();
	level thread overflow_outro_player_switchtopistol();
	level thread run_scene( "pak_outro_success" );
	wait 1;
	if ( tactview )
	{
		screen_fade_in( 0,5 );
	}
	flag_wait( "outro_success_fade_out" );
	screen_fade_out( 1,5 );
}

overflow_outro_player_switchtopistol()
{
	flag_wait( "pak_outro_success_started" );
	player_body = get_model_or_models_from_scene( "pak_outro_success", "player_body" );
	player_body attach( getweaponmodel( "kard_sp" ), "tag_weapon" );
}

overflow_outro_player_fire()
{
	player_body = get_model_or_models_from_scene( "pak_outro_success", "player_body" );
	zhao = get_ais_from_scene( "pak_outro_success", "ai_spawner_zhao" );
	end_org = zhao gettagorigin( "J_SpineUpper" );
	muzzle_org = player_body gettagorigin( "tag_flash" );
	muzzle_ang = player_body gettagangles( "tag_flash" );
	playfxontag( level._effect[ "kard_fake_flash" ], player_body, "tag_flash" );
	magicbullet( "kard_sp", muzzle_org, end_org, level.player );
}

overflow_outro_zhao_hit_slowmo( guy )
{
	settimescale( 0,2 );
	wait 0,4;
	settimescale( 1 );
	exploder( 6643 );
	wait 2;
	maps/_so_rts_event::trigger_event( "dlg_mission_success" );
}

overflow_outro_player_takes_picture( guy )
{
	maps/_so_rts_support::create_hud_message( &"SO_RTS_MP_OVERFLOW_IDENT", 1 );
	wait 2;
	maps/_so_rts_support::create_hud_message( &"SO_RTS_MP_OVERFLOW_PROCESSING", 1 );
	wait 3;
	maps/_so_rts_support::create_hud_message( &"SO_RTS_MP_OVERFLOW_POSITIVE", 1 );
}

overflow_outro_fail()
{
	level thread maps/createart/so_rts_mp_overflow_art::fail_igc();
	zhao_vtol = getent( "zhao_vtol", "targetname" );
	zhao_vtol.donotclear = 1;
	exploder( 3412 );
	mission_complete_clear_entities();
	level notify( "unhide_vtols" );
	maps/_so_rts_event::trigger_event( "dlg_mission_fail" );
	scene = "pak_outro_failure";
	level thread run_scene( scene );
	flag_wait( "outro_fail_fade_in" );
	screen_fade_in( 0,5 );
	flag_wait( "outro_fail_fade_out" );
	screen_fade_out( 0,5 );
	scene_wait( scene );
	wait 0,1;
	level.rts.player disableweapons();
	level.rts.player disableoffhandweapons();
	level.rts.player enableinvulnerability();
	level.rts.player hideviewmodel();
	level.rts.player allowstand( 1 );
	level.rts.player setstance( "stand" );
	level.rts.player allowcrouch( 0 );
	level.rts.player allowprone( 0 );
}

level_fade_in()
{
	thread screen_fade_in( 0,5 );
}

overflow_geo_changes()
{
	ents = getentarray( "rts_remove", "targetname" );
	_a1052 = ents;
	_k1052 = getFirstArrayKey( _a1052 );
	while ( isDefined( _k1052 ) )
	{
		ent = _a1052[ _k1052 ];
		ent delete();
		_k1052 = getNextArrayKey( _a1052, _k1052 );
	}
}

aipostswapwatch()
{
	while ( 1 )
	{
		level waittill( "ai_gave_up_post", loc );
		infantry = maps/_so_rts_squad::getsquadbypkg( "infantry_enemy_reg_pkg", "axis" );
		maps/_so_rts_squad::removedeadfromsquad( infantry.id );
		dudes = sortarraybyclosest( loc.origin, infantry.members );
		time = getTime();
		valid = [];
		i = 0;
		while ( i < dudes.size )
		{
			if ( isDefined( dudes[ i ].nextswapavail ) && dudes[ i ].nextswapavail > time )
			{
				i++;
				continue;
			}
			else
			{
				valid[ valid.size ] = dudes[ i ];
			}
			i++;
		}
		if ( valid.size )
		{
			theguy = valid[ 0 ];
			if ( isinarray( level.rts.availenemylocs, loc ) )
			{
				arrayremovevalue( level.rts.availenemylocs, loc, 0 );
				level.rts.availenemylocs[ level.rts.availenemylocs.size ] = theguy.mypost;
				theguy.mypost = loc;
				theguy setgoalpos( theguy.mypost.origin );
				theguy thread aipostreturnwatch();
				theguy.nextswapavail = getTime() + 20000;
			}
		}
	}
}

airedalert()
{
	self endon( "death" );
	self waittill( "red_alert" );
	self.goalradius = 1024;
	self setgoalpos( level.rts.redalert_intruder.origin + vectorScale( ( 0, 1, 0 ), 12 ) );
	while ( isDefined( level.rts.redalert_intruder ) )
	{
		wait 0,05;
	}
}

aipostthink()
{
	self endon( "red_alert" );
	self endon( "death" );
	sawenemy = 0;
	while ( 1 )
	{
		if ( isDefined( self.enemy ) )
		{
			canseeenemy = self cansee( self.enemy );
		}
		if ( canseeenemy )
		{
			self setgoalpos( self.enemy.origin );
			sawenemy = 1;
		}
		else
		{
			if ( sawenemy )
			{
				wait 20;
			}
			sawenemy = 0;
			if ( isDefined( self.mypost ) )
			{
				self setgoalpos( self.mypost.origin );
			}
		}
		wait 1;
	}
}

aipostreturnwatch()
{
	self notify( "aiPostReturnWatch" );
	self endon( "aiPostReturnWatch" );
	loc = self.mypost;
	self waittill_any( "red_alert", "death" );
	level.rts.availenemylocs[ level.rts.availenemylocs.size ] = loc;
	level notify( "ai_gave_up_post" );
	if ( isDefined( self ) )
	{
		self.mypost = undefined;
	}
}

assignaitopost( teleport )
{
	if ( !isDefined( teleport ) )
	{
		teleport = 0;
	}
	self thread airedalert();
	if ( level.rts.availenemylocs.size > 0 )
	{
		loc = level.rts.availenemylocs[ 0 ];
		arrayremoveindex( level.rts.availenemylocs, 0, 0 );
		self.mypost = loc;
		self setgoalpos( self.mypost.origin );
		self thread aipostreturnwatch();
		self thread aipostthink();
		if ( isDefined( teleport ) && teleport )
		{
			self forceteleport( loc.origin, loc.angles );
		}
	}
}

new_enemy_squad( unit, poi )
{
	_a1170 = unit.members;
	_k1170 = getFirstArrayKey( _a1170 );
	while ( isDefined( _k1170 ) )
	{
		member = _a1170[ _k1170 ];
		if ( !isDefined( member.mypost ) )
		{
			if ( level.rts.squads[ member.squadid ].pkg_ref.squad_type == "infantry" )
			{
				member assignaitopost();
			}
		}
		_k1170 = getNextArrayKey( _a1170, _k1170 );
	}
}

enemyspawninit()
{
	maps/_so_rts_support::level_create_turrets( 0, 200 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1 );
	level.rts.availenemylocs = getentarray( "rts_enemy_inf_pos", "targetname" );
	infantry = maps/_so_rts_squad::getsquadbypkg( "infantry_enemy_reg_pkg", "axis" );
	i = 0;
	while ( i < infantry.members.size )
	{
		infantry.members[ i ] getperfectinfo( level.rts.player );
		infantry.members[ i ] assignaitopost( 1 );
		infantry.members[ i ].a.alertness = "alert";
		infantry.members[ i ] allowedstances( "crouch", "stand" );
		i++;
	}
	maps/_so_rts_squad::ordersquadmanaged( infantry.id );
	level thread aipostswapwatch();
	asdlocs = getentarray( "rts_enemy_asd_spawn", "targetname" );
	_a1210 = asdlocs;
	_k1210 = getFirstArrayKey( _a1210 );
	while ( isDefined( _k1210 ) )
	{
		loc = _a1210[ _k1210 ];
		maps/_so_rts_catalog::spawn_package( "metalstorm_pkg", "axis", 1 );
		_k1210 = getNextArrayKey( _a1210, _k1210 );
	}
	asdsquad = maps/_so_rts_squad::getsquadbypkg( "metalstorm_pkg", "axis" );
	i = 0;
	while ( i < asdsquad.members.size )
	{
		asdsquad.members[ i ].origin = asdlocs[ i ].origin;
		asdsquad.members[ i ].angles = asdlocs[ i ].angles;
		asdsquad.members[ i ].maxsightdistsqrd = 360000;
		asdsquad.members[ i ] maps/_vehicle::defend( asdsquad.members[ i ].origin, 1024 );
		asdsquad.members[ i ] thread ai_think_machine();
		i++;
	}
	maps/_so_rts_squad::ordersquadmanaged( asdsquad.id );
	maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", -1 );
	turretsquadid = maps/_so_rts_catalog::spawn_package( "turret_pkg", "axis", 1 );
	level thread intruder_plantwatch();
	level thread squadnotifylevelonempty( asdsquad.id, "asd_all_dead" );
	level thread squadnotifylevelonempty( turretsquadid, "turret_all_dead" );
}

squadnotifylevelonempty( squadid, note )
{
	level endon( "mission_complete" );
	while ( !flag( "rts_game_over" ) )
	{
		maps/_so_rts_squad::removedeadfromsquad( squadid );
		if ( level.rts.squads[ squadid ].members.size == 0 )
		{
			level notify( note );
			return;
		}
		wait 1;
	}
}

intruder_deathwatch()
{
	flag_set( "red_alert" );
	self waittill( "death" );
	flag_clear( "red_alert" );
}

intruder_plantwatch()
{
	while ( 1 )
	{
		level waittill( "intruder_planted", network_intruder );
		while ( isDefined( network_intruder ) )
		{
			network_intruder thread intruder_deathwatch();
			level.rts.redalert_intruder = network_intruder;
			enemies = getaiarray( "axis" );
			_a1268 = enemies;
			_k1268 = getFirstArrayKey( _a1268 );
			while ( isDefined( _k1268 ) )
			{
				guy = _a1268[ _k1268 ];
				guy notify( "red_alert" );
				_k1268 = getNextArrayKey( _a1268, _k1268 );
			}
			enemies = getvehiclearray( "axis" );
			_a1274 = enemies;
			_k1274 = getFirstArrayKey( _a1274 );
			while ( isDefined( _k1274 ) )
			{
				guy = _a1274[ _k1274 ];
				guy notify( "red_alert" );
				_k1274 = getNextArrayKey( _a1274, _k1274 );
			}
		}
	}
}

ai_think_machine()
{
	self endon( "death" );
	self.level_state_machine = create_state_machine( "level_brain", self, "rts_change_state" );
	defend = self.level_state_machine add_state( "rts_defend", undefined, undefined, ::ai_defend, undefined, undefined );
	patrol = self.level_state_machine add_state( "rts_patrol", ::ai_patrol_enter, ::ai_patrol_exit, ::ai_patrol, ::ai_can_patrol, undefined );
	attack = self.level_state_machine add_state( "rts_attack", undefined, undefined, ::ai_attack, undefined, undefined );
	defend add_connection_by_type( "rts_patrol", 1, 4, undefined, "rts_patrol" );
	defend add_connection_by_type( "rts_attack", 1, 4, undefined, "enemy" );
	patrol add_connection_by_type( "rts_defend", 1, 4, undefined, "rts_defend" );
	patrol add_connection_by_type( "rts_attack", 1, 4, undefined, "enemy" );
	attack add_connection_by_type( "rts_defend", 1, 4, undefined, "rts_defend" );
	self thread ai_think();
	self.level_state_machine set_state( "rts_defend" );
	self.level_state_machine thread update_state_machine( 0,05 );
}

ai_think()
{
	self endon( "death" );
	self endon( "stop_think" );
	while ( 1 )
	{
		self notify( "tick" );
		wait 1;
	}
}

ai_gotopoint( origin )
{
	if ( self.health <= 0 )
	{
		return;
	}
	if ( isai( self ) )
	{
		self setgoalpos( origin );
	}
	else if ( !issentient( self ) )
	{
		if ( !self setvehgoalpos( origin, 0, 2, 1 ) )
		{
			self notify( "no_path" );
		}
	}
	else
	{
		self thread maps/_vehicle::defend( origin );
	}
}

getdefendloc()
{
	return self.origin;
}

ai_defend()
{
/#
	println( "STATECHANGE " + getTime() + " ID:" + self getentitynumber() + "state: ai_defend" );
#/
	self endon( "death" );
	self endon( "stop_think" );
	self endon( "rts_change_state" );
	while ( isDefined( self.rts_unloaded ) && !self.rts_unloaded )
	{
		wait 0,5;
	}
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		self.goalradius = 24;
	}
	self.defendloc = self getdefendloc();
	ticks = 0;
	self thread maps/_vehicle::defend( self.defendloc, 128 );
	while ( 1 )
	{
		self waittill( "tick" );
		ticks++;
		shouldpatrol = randomint( 50 ) < ticks;
		if ( shouldpatrol )
		{
			self notify( "rts_patrol" );
			ticks = 0;
			continue;
		}
		else
		{
			wait 2;
		}
	}
}

ai_patrol_arraycompact()
{
	valid = [];
	i = 0;
	while ( i < level.rts.patrollers.size )
	{
		if ( isDefined( level.rts.patrollers[ i ] ) )
		{
			valid[ valid.size ] = level.rts.patrollers[ i ];
		}
		i++;
	}
	level.rts.patrollers = valid;
}

ai_patrol_enter()
{
	level.rts.patrollers[ level.rts.patrollers.size ] = self;
}

ai_patrol_exit()
{
	arrayremovevalue( level.rts.patrollers, self );
}

ai_can_patrol()
{
	ai_patrol_arraycompact();
	if ( level.rts.patrollers.size > 2 )
	{
		return 0;
	}
	if ( isDefined( self.stationary ) )
	{
		return self.stationary == 0;
	}
}

ai_patrol()
{
/#
	println( "STATECHANGE " + getTime() + " ID:" + self getentitynumber() + "state: ai_patrol" );
#/
	self endon( "death" );
	self endon( "stop_think" );
	self endon( "rts_change_state" );
	ticks = 0;
	route = randomint( 2 );
	start = level.rts.patrol_routes[ route ][ randomint( level.rts.patrol_routes[ route ].size ) ];
	self.goalradius = 128;
	current = start;
	while ( 1 )
	{
		if ( !isDefined( current.nodes ) )
		{
			current.nodes = array_randomize( getnodesinradiussorted( current.origin, 512, 0, 128, "Cover", 32 ) );
		}
		spot = current.nodes[ randomint( current.nodes.size ) ].origin;
/#
		self thread maps/_so_rts_support::debug_sphere_until_notify( spot, 24, vectorScale( ( 0, 1, 0 ), 0,64 ), 0,5, "goal", "rts_change_state" );
#/
		self ai_gotopoint( spot );
		self waittill_any( "goal", "no_path" );
		if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
		{
			self thread maps/_vehicle::defend( spot, 64 );
		}
		wait randomfloatrange( 10, 30 );
		current = getstruct( current.target, "targetname" );
		if ( current == start )
		{
			self notify( "rts_defend" );
			return;
		}
	}
}

ai_attack()
{
	if ( !isDefined( self ) )
	{
		return;
	}
/#
	println( "STATECHANGE " + getTime() + " ID:" + self getentitynumber() + "state: ai_attack" );
#/
	self endon( "death" );
	self endon( "stop_think" );
	self endon( "rts_change_state" );
	ticks = 0;
	self.goalradius = 512;
	while ( isDefined( self.enemy ) && ticks < 10 )
	{
		if ( isai( self ) )
		{
			if ( self cansee( self.enemy ) )
			{
				self ai_gotopoint( self.enemy.origin );
				ticks = 0;
			}
		}
		else
		{
			if ( self vehcansee( self.enemy ) )
			{
				self ai_gotopoint( self.enemy.origin );
				ticks = 0;
			}
		}
		self waittill( "tick" );
		ticks++;
	}
	self notify( "rts_defend" );
	return;
}

claymore_setup()
{
	a_claymores = getentarray( "claymore", "targetname" );
	_a1506 = a_claymores;
	_k1506 = getFirstArrayKey( _a1506 );
	while ( isDefined( _k1506 ) )
	{
		m_claymore = _a1506[ _k1506 ];
		m_claymore delete();
		_k1506 = getNextArrayKey( _a1506, _k1506 );
	}
}

watch_asd_death()
{
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( isplayer( attacker ) )
	{
		level notify( "player_killed_asd" );
	}
}

watch_sentry_death()
{
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( isplayer( attacker ) )
	{
		level notify( "player_killed_sentry" );
	}
}

setup_challenges()
{
	self thread maps/_so_rts_support::track_unit_type_usage();
	add_spawn_function_veh_by_type( "drone_metalstorm_rts", ::watch_asd_death );
	add_spawn_function_veh_by_type( "turret_sentry_rts", ::watch_sentry_death );
	level.rts.kill_stats = spawnstruct();
	level.rts.kill_stats.total_kills = 0;
	level.rts.kill_stats.explosive_kills = 0;
	level.rts.kill_stats.headshot_kills = 0;
	level.rts.kill_stats.melee_kills = 0;
	level.rts.kill_stats.stun_kills = 0;
	level.rts.kill_stats.explosive_kills_total = 15;
	level.rts.kill_stats.headshot_kills_total = 20;
	level.rts.kill_stats.melee_kills_total = 10;
	level.rts.kill_stats.stun_kills_total = 10;
	level.callbackactorkilled = ::maps/_so_rts_challenges::global_actor_killed_challenges_callback;
	self maps/_challenges_sp::register_challenge( "EXPLOSIVE_KILLS" );
	self maps/_challenges_sp::register_challenge( "HEADSHOTS" );
	self maps/_challenges_sp::register_challenge( "MELEE_KILLS" );
	self maps/_challenges_sp::register_challenge( "STUN_KILLS" );
	self maps/_challenges_sp::register_challenge( "EMP_KILLS_ASD", ::challenge_emp_kills_asd );
	self maps/_challenges_sp::register_challenge( "TIME", ::challenge_time );
	self maps/_challenges_sp::register_challenge( "EMP_KILLS_SENTRY", ::challenge_emp_kills_sentry );
	self maps/_challenges_sp::register_challenge( "TWO_ASD_ONE_EXPL", ::challenge_multiple_asd_explosion );
	self maps/_challenges_sp::register_challenge( "ONE_MODULE", ::challenge_one_module );
	self maps/_challenges_sp::register_challenge( "TACTICAL", ::maps/_so_rts_support::challenge_tactical );
}

challenge_emp_kills_asd( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_asd", rts_mode, damage_type, emp );
		if ( emp )
		{
			self notify( str_notify );
		}
	}
}

challenge_time( str_notify )
{
	flag_wait( "rts_start_clock" );
	start_time = getTime();
	level waittill( "mission_success" );
	end_time = getTime();
	total_time = ( level.rts.game_rules.time * 60 ) * 1000;
	time_remaining = total_time - end_time - start_time;
	if ( time_remaining >= 180000 )
	{
		self notify( str_notify );
	}
}

challenge_emp_kills_sentry( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_sentry", rts_mode, damage_type, emp );
		if ( emp )
		{
			self notify( str_notify );
		}
	}
}

challenge_multiple_asd_explosion( str_notify )
{
	num_killed = 0;
	when_last_killed = getTime() - 1000;
	while ( 1 )
	{
		level waittill( "player_killed_asd", rts_mode, damage_type, emp );
		switch( damage_type )
		{
			case "MOD_EXPLOSIVE":
			case "MOD_EXPLOSIVE_SPLASH":
			case "MOD_GRENADE":
			case "MOD_PROJECTILE":
			case "MOD_PROJECTILE_SPLASH":
				if ( ( getTime() - when_last_killed ) < 200 )
				{
					num_killed++;
				}
				else
				{
					num_killed = 1;
				}
				if ( num_killed >= 2 )
				{
					self notify( str_notify );
				}
				when_last_killed = getTime();
				break;
			continue;
			default:
			}
		}
	}
}

challenge_one_module( str_notify )
{
	level endon( "intruder_disrupted" );
	level waittill( "mission_success" );
	self notify( str_notify );
}

overflow_setup_devgui()
{
/#
	setdvar( "cmd_skipto", "" );
	adddebugcommand( "devgui_cmd "|RTS|/Overflow:10/Skipto:1/End:1" "cmd_skipto end"\n" );
	adddebugcommand( "devgui_cmd "|rts|/Overflow:10/Skipto:1/Fail:2" "cmd_skipto fail"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Overflow:10/Debug:2/Kill Infantry:1" "cmd_skipto delInf"\n" );
	level thread overflow_watch_devgui();
#/
}

overflow_watch_devgui()
{
/#
	while ( 1 )
	{
		cmd_skipto = getDvar( "cmd_skipto" );
		if ( cmd_skipto == "end" )
		{
			level thread maps/_so_rts_rules::mission_complete( 1 );
			setdvar( "cmd_skipto", "" );
		}
		if ( cmd_skipto == "fail" )
		{
			level thread maps/_so_rts_rules::mission_complete( 0 );
			setdvar( "cmd_skipto", "" );
		}
		if ( cmd_skipto == "delInf" )
		{
			enemyinf = getaiarray( "axis" );
			_a1714 = enemyinf;
			_k1714 = getFirstArrayKey( _a1714 );
			while ( isDefined( _k1714 ) )
			{
				guy = _a1714[ _k1714 ];
				if ( isDefined( guy.allow_oob ) && !guy.allow_oob && maps/_so_rts_ai::ai_isselectable( guy ) )
				{
					guy dodamage( guy.health + 1, guy.origin );
				}
				_k1714 = getNextArrayKey( _a1714, _k1714 );
			}
			setdvar( "cmd_skipto", "" );
		}
		wait 0,05;
#/
	}
}
