#include maps/_challenges_sp;
#include maps/_so_rts_challenges;
#include maps/createart/so_rts_mp_dockside_art;
#include maps/_so_rts_ai;
#include maps/_so_rts_main;
#include maps/_so_rts_squad;
#include maps/_so_rts_event;
#include maps/_so_rts_enemy;
#include maps/_so_rts_catalog;
#include maps/_so_rts_support;
#include maps/_so_rts_rules;
#include maps/_music;
#include maps/_audio;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "animated_props" );
#using_animtree( "vehicles" );
#using_animtree( "player" );
#using_animtree( "generic_human" );

precache()
{
	level._effect[ "missile_explosion" ] = loadfx( "explosions/fx_exp_war_rocket_air_death" );
	level._effect[ "missile_exhaust" ] = loadfx( "weapon/rocket/fx_rocket_war_exhaust" );
	level._effect[ "missile_launch" ] = loadfx( "weapon/rocket/fx_rocket_war_smoke_kickup" );
	level._effect[ "sam_missile_explosion" ] = loadfx( "explosions/fx_war_exp_sam_air" );
	level._effect[ "boat_explosion_xlg" ] = loadfx( "explosions/fx_war_exp_ship_fireball_xlg" );
	level._effect[ "boat_explosion_lg" ] = loadfx( "explosions/fx_war_exp_ship_fireball_lg" );
	level._effect[ "boat_water" ] = loadfx( "water/fx_war_water_cargo_ship_sink" );
	level._effect[ "heli_light" ] = loadfx( "light/fx_war_light_interior_blackhawk" );
	level._effect[ "laser_turret_light_green" ] = loadfx( "light/fx_war_light_laser_turret_grn" );
	level._effect[ "laser_turret_light_red" ] = loadfx( "light/fx_war_light_laser_turret_red" );
	level._effect[ "laser_turret_disabled" ] = loadfx( "electrical/fx_war_laser_turret_disabled" );
	level._effect[ "water_splash_tall" ] = loadfx( "water/fx_war_water_cargo_hit_tall" );
	level._effect[ "water_splash_wide" ] = loadfx( "water/fx_war_water_cargo_hit_wide" );
	level._effect[ "predator_trail" ] = loadfx( "weapon/predator/fx_predator_trail" );
	level._effect[ "boat_fire" ] = loadfx( "fire/fx_war_ship_fire_billow_lg" );
	level._effect[ "sniper_glint" ] = loadfx( "misc/fx_misc_sniper_scope_glint" );
	level._effect[ "base_fire" ] = loadfx( "env/fire/fx_fire_md" );
	level._effect[ "base_hurt" ] = loadfx( "explosions/fx_default_explosion" );
	level._effect[ "base_blow" ] = loadfx( "explosions/fx_airlift_explosion_large" );
	level._effect[ "network_intruder_death" ] = loadfx( "explosions/fx_rts_exp_hack_device" );
	level._effect[ "network_intruder_blink" ] = loadfx( "misc/fx_equip_light_green" );
	level._effect[ "missile_reticle" ] = loadfx( "misc/fx_reticle_war_missile_target" );
	level._effect[ "fx_light_floodlight_sqr_wrm_vista_lg" ] = loadfx( "light/fx_light_floodlight_sqr_wrm_vista_lg" );
	level._effect[ "fx_rts_steam_missile_truck" ] = loadfx( "smoke/fx_rts_steam_missile_truck" );
	level._effect[ "laser_turret_beam_green" ] = loadfx( "light/fx_war_beam_laser_turret_grn" );
	level._effect[ "laser_turret_beam_red" ] = loadfx( "light/fx_war_beam_laser_turret_red" );
	precachemodel( "p6_boat_cargo_ship_singapore" );
	precachemodel( "veh_t6_missile_truck" );
	precachemodel( "veh_t6_missile_truck_missile" );
	precachemodel( "T6_wpn_turret_sam_larger" );
	precachemodel( "com_ammo_pallet" );
	precachemodel( "fxanim_war_sing_cargo_ship_sink_mod" );
	precachemodel( "fxanim_war_sing_rappel_rope_01_mod" );
	precachemodel( "fxanim_war_sing_rappel_rope_02_mod" );
	precachemodel( "t6_wpn_turret_sentry_gun" );
	precachemodel( "t5_weapon_sam_turret_detect" );
	precacheshader( "hud_icon_helicopter" );
	precacheshader( "compass_a10" );
	level.rts.intrudermodel = "t6_wpn_hacking_device_world";
	precachemodel( level.rts.intrudermodel );
	precachemodel( "p6_ammo_resupply_01" );
	precachemodel( "fxanim_gp_vtol_drop_asd_drone_mod" );
	precachemodel( "fxanim_gp_vtol_drop_claw_mod" );
	precacheitem( "smaw_sp" );
	precacheitem( "remote_missile_missile_rts" );
	precacheitem( "tow_turret_sp" );
	precachestring( &"SO_RTS_AIRSTRIKE_AVAIL" );
	level.remote_missile_type = "remote_missile_missile_rts";
	maps/_quadrotor::init();
	maps/_metal_storm::init();
	maps/_claw::init();
}

dockside_setup_devgui()
{
/#
	setdvar( "cmd_skipto", "" );
	adddebugcommand( "devgui_cmd "|RTS|/Dockside:10/Skipto:1/Mission Win:1" "cmd_skipto end"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Dockside:10/Skipto:1/Mission Lose:2" "cmd_skipto fail"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Dockside:10/Skipto:1/Plant All POI:3" "cmd_skipto plant_all"\n" );
	level thread dockside_watch_devgui();
#/
}

dockside_watch_devgui()
{
/#
	while ( 1 )
	{
		cmd_skipto = getDvar( "cmd_skipto" );
		if ( cmd_skipto != "" )
		{
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
			while ( cmd_skipto == "plant_all" )
			{
				_a117 = level.rts.poi;
				_k117 = getFirstArrayKey( _a117 );
				while ( isDefined( _k117 ) )
				{
					poi = _a117[ _k117 ];
					if ( poi.capture_time > 0 )
					{
						network_intruder = spawn( "script_model", poi.origin );
						network_intruder.team = "allies";
						network_intruder setmodel( level.rts.intrudermodel );
						network_intruder thread maps/_so_rts_support::setupnetworkintruder( poi );
					}
					_k117 = getNextArrayKey( _a117, _k117 );
				}
			}
			setdvar( "cmd_skipto", "" );
		}
		wait 0,05;
#/
	}
}

dockside_level_scenario_one()
{
	setup_scenes();
	flag_init( "airstrike_avail" );
	level.custom_introscreen = ::maps/_so_rts_support::custom_introscreen;
	level.rts.custom_ai_getgrenadecb = ::dockside_aigrenadeget;
	flag_wait( "all_players_connected" );
	flag_set( "block_input" );
	maps/_so_rts_rules::set_gamemode( "attack" );
	flag_wait( "start_rts" );
	level.player thread setup_challenges();
	maps/_so_rts_support::hide_player_hud();
	dockside_geo_changes();
	thread dockside_missile_deathring();
	level.rts.remotemissile_target = getent( "remoteMissileTarget", "targetname" );
	setupmissileboundary();
	level.rts.missile_oob_check = ::dockside_missile_oob_check;
/#
	dockside_setup_devgui();
#/
/#
	if ( isDefined( level.rts.enemy_base ) )
	{
		assert( isDefined( level.rts.enemy_base.entity ), "enemy base not defined" );
	}
#/
	level.rts.enemy_base.entity thread dockside_enemybasewatch();
	df21poi = getpoibyref( "rts_poi_df21" );
	df21poi.intruder_prefix = "scrambler";
	maps/_so_rts_catalog::package_select( "infantry_ally_reg_pkg", 1, ::dockside_level_player_startfps );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1, ::maps/_so_rts_enemy::order_new_squad );
	maps/_so_rts_catalog::spawn_package( "infantry_enemy_reg_pkg", "axis", 1, ::maps/_so_rts_enemy::order_new_squad );
	bigdogsquadid = maps/_so_rts_catalog::spawn_package( "bigdog_pkg", "axis", 1, ::docksdie_order_to_samsite );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg2_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "metalstorm_pkg", "allies", 0 );
	maps/_so_rts_catalog::setpkgqty( "bigdog_pkg", "allies", 0 );
	enemybasepoi = maps/_so_rts_poi::getpoibyref( "rts_base_enemy" );
	enemybasepoi.ignoreme = 1;
	level notify( "redeploy_on_poi_takeover" + bigdogsquadid );
	level thread dockside_level_waitforpoinotify();
	flag_set( "rts_event_ready" );
	maps/_so_rts_event::trigger_event( "main_music_state" );
	wait 1;
	if ( maps/_so_rts_event::trigger_event( "intro_dlg_10sec" ) )
	{
		level waittill_any_timeout( 4, "intro_dlg_10sec_done" );
	}
	wait 0,4;
	if ( maps/_so_rts_event::trigger_event( "intro_dlg_approaching" ) )
	{
		level waittill_any_timeout( 4, "intro_dlg_approaching_done" );
	}
	if ( maps/_so_rts_event::trigger_event( "intro_dlg_kickropes" ) )
	{
		level waittill_any_timeout( 4, "intro_dlg_kickropes_done" );
	}
	wait 0,1;
	if ( maps/_so_rts_event::trigger_event( "intro_dlg_herewego" ) )
	{
		level waittill_any_timeout( 4, "intro_dlg_herewego_done" );
	}
	exploder( 99 );
	maps/_so_rts_event::trigger_event( "intro_dlg_outthedoor" );
	wait 3;
	if ( maps/_so_rts_event::trigger_event( "intro_dlg_gogogo" ) )
	{
		level waittill_any_timeout( 4, "intro_dlg_gogogo_done" );
	}
	level thread maps/_so_rts_support::player_oobwatch();
	level.rts.player visionsetnaked( "sp_singapore_default", 2 );
	level.rts.player depth_of_field_off( 2 );
	wait 4;
	maps/_so_rts_event::trigger_event( "intro_dlg_ondeck" );
	wait 2;
	maps/_so_rts_event::trigger_event( "intro_dlg_mylead" );
	wait 2;
	maps/_so_rts_event::trigger_event( "intro_dlg_onground" );
	thread setup_objectives();
}

dockside_aigrenadeget( team )
{
	roll = randomint( 100 );
	if ( team == "axis" )
	{
		if ( roll >= 85 )
		{
			return "flash_grenade_sp";
		}
		if ( roll >= 55 )
		{
			return "willy_pete_sp";
		}
		if ( roll >= 25 )
		{
			return "emp_grenade_sp";
		}
		if ( roll >= 15 )
		{
			return "frag_grenade_sp";
		}
		return undefined;
	}
	return "";
}

setup_objectives()
{
	level thread maps/_objectives::init();
	level.obj_destroy_cargo = register_objective( &"SO_RTS_MP_DOCKSIDE_OBJ_BOAT" );
	level.obj_destroy_hellads1 = register_objective( &"SO_RTS_MP_DOCKSIDE_OBJ_POI_HELLADS" );
	level.obj_destroy_missile = register_objective( &"SO_RTS_MP_DOCKSIDE_OBJ_POI_MISSILE" );
	level.obj_destroy_hellads2 = register_objective( &"SO_RTS_MP_DOCKSIDE_OBJ_POI_HELLADS" );
	set_objective( level.obj_destroy_cargo );
	wait 5;
	set_objective( level.obj_destroy_hellads1 );
	wait 5;
	set_objective( level.obj_destroy_missile );
	wait 5;
	set_objective( level.obj_destroy_hellads2 );
	maps/_so_rts_poi::poi_setobjectivenumber( "rts_poi_hellads2", level.obj_destroy_hellads1, "waypoint_capture_a" );
	maps/_so_rts_poi::poi_setobjectivenumber( "rts_poi_df21", level.obj_destroy_missile, "waypoint_capture_b" );
	maps/_so_rts_poi::poi_setobjectivenumber( "rts_poi_hellads1", level.obj_destroy_hellads2, "waypoint_capture_c" );
	while ( level.rts.poi.size )
	{
		level waittill( "poi_captured_allies", ref );
		level.rts.game_rules.num_nag_squads += 2;
		switch( ref )
		{
			case "rts_poi_hellads1":
				set_objective( level.obj_destroy_hellads2, undefined, "done" );
				break;
			continue;
			case "rts_poi_df21":
				set_objective( level.obj_destroy_missile, undefined, "done" );
				break;
			continue;
			case "rts_poi_hellads2":
				set_objective( level.obj_destroy_hellads1, undefined, "done" );
				break;
			continue;
		}
	}
}

dockside_level_player_startfps()
{
	nextsquad = maps/_so_rts_squad::getnextvalidsquad( undefined );
/#
	assert( nextsquad != -1, "should not be -1, player squad should be created" );
#/
	level.rts.targetteammate = level.rts.squads[ nextsquad ].members[ 0 ];
	level.rts.activesquad = nextsquad;
	level.rts.targetteammate forceteleport( level.rts.player.origin, level.rts.player.angles );
	maps/_so_rts_main::player_in_control();
	flag_set( "block_input" );
	level.rts.player freezecontrols( 1 );
	level.rts.player thread player_waitfor_vehicleentry();
	level thread maps/_so_rts_support::flag_set_innseconds( "start_rts_enemy", 8 );
	level thread dockside_fastrope_intro();
	scene_wait( "intro_fastrope_player" );
	level.rts.player.ignoreme = 0;
	level.rts.player disableinvulnerability();
	level.rts.player freezecontrols( 0 );
	flag_clear( "block_input" );
	flag_set( "rts_start_clock" );
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg_pkg", "allies", -1 );
	startloc = maps/_so_rts_support::get_transport_startloc( maps/_so_rts_ai::get_package_drop_target( "allies" ), "allies" );
	lastnode = startloc;
	unloadnode = undefined;
	while ( isDefined( lastnode.target ) )
	{
		if ( !isDefined( unloadnode ) && isDefined( lastnode.script_unload ) )
		{
			unloadnode = lastnode;
		}
		lastnode = getvehiclenode( lastnode.target, "targetname" );
	}
	timeback = ( gettimefromvehiclenodetonode( unloadnode, lastnode ) * 1000 ) + level.rts.transport_refuel_delay;
	timetozone = gettimefromvehiclenodetonode( startloc, unloadnode ) * 1000;
	pkg_ref = maps/_so_rts_catalog::package_getpackagebytype( "metalstorm_pkg" );
	timeto = timetozone + pkg_ref.cost[ "allies" ];
	timeto /= 1000;
	timewait = 30 - timeto;
	if ( timewait > 0 )
	{
		wait timewait;
	}
	maps/_so_rts_catalog::setpkgqty( "metalstorm_pkg", "allies", 1 );
	maps/_so_rts_catalog::setpkgdependancyenforcement( "metalstorm_pkg", "allies", 0 );
	level waittill( "friendly_unit_spawned_metalstorm_pkg" );
	wait timeto;
	maps/_so_rts_catalog::setpkgqty( "metalstorm_pkg", "allies", -1 );
	pkg_ref = maps/_so_rts_catalog::package_getpackagebytype( "infantry_ally_reg2_pkg" );
	timeto = timetozone + pkg_ref.cost[ "allies" ];
	timeto /= 1000;
	timewait = 30 - timeto;
	if ( timewait > 0 )
	{
		wait timewait;
	}
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg2_pkg", "allies", 1 );
	maps/_so_rts_catalog::setpkgdependancyenforcement( "infantry_ally_reg2_pkg", "allies", 0 );
	level waittill( "friendly_unit_spawned_infantry_ally_reg2_pkg" );
	wait timeto;
	maps/_so_rts_catalog::setpkgqty( "infantry_ally_reg2_pkg", "allies", -1 );
	pkg_ref = maps/_so_rts_catalog::package_getpackagebytype( "bigdog_pkg" );
	timeto = timetozone + pkg_ref.cost[ "allies" ];
	timeto /= 1000;
	timewait = 30 - timeto;
	if ( timewait > 0 )
	{
		wait timewait;
	}
	maps/_so_rts_catalog::setpkgqty( "bigdog_pkg", "allies", 1 );
	maps/_so_rts_catalog::setpkgdependancyenforcement( "bigdog_pkg", "allies", 0 );
	level waittill( "friendly_unit_spawned_bigdog_pkg" );
	wait timeto;
	maps/_so_rts_catalog::setpkgqty( "bigdog_pkg", "allies", -1 );
}

fastrope_grab( player_model )
{
	level.player playrumbleonentity( "pullout_small" );
}

fastrope_land( player_model )
{
	level.player playrumbleonentity( "anim_heavy" );
}

fastrope_resetlighting( player_model )
{
	_a410 = level.rts.squads[ 0 ].members;
	_k410 = getFirstArrayKey( _a410 );
	while ( isDefined( _k410 ) )
	{
		guy = _a410[ _k410 ];
		guy clearclientflag( 12 );
		_k410 = getNextArrayKey( _a410, _k410 );
	}
}

setup_scenes()
{
	add_scene( "intro_fastrope_player", "sing_fastrope" );
	add_player_anim( "player_body", %p_intro_wm_fastrope_player, 1, 0, undefined, 1, 1, 15, 15, 15, 15 );
	add_notetrack_custom_function( "player_body", "start_fade_up", ::level_fade_in );
	add_notetrack_custom_function( "player_body", "grab_rope_r_hand", ::fastrope_grab );
	add_notetrack_custom_function( "player_body", "grab_rope_l_hand", ::fastrope_grab );
	add_notetrack_custom_function( "player_body", "feet_on_the _ground", ::fastrope_land );
	add_notetrack_custom_function( "player_body", "light_change", ::fastrope_resetlighting );
	add_scene( "intro_fastrope_heli", "sing_fastrope" );
	add_prop_anim( "fastrope_blackhawk", %v_intro_wp_fastrope_blackhawk, undefined, 0 );
	add_scene( "intro_fastrope_squad_1", "sing_fastrope" );
	add_actor_anim( "guy0", %ch_intro_wm_fastrope_guy1 );
	add_scene( "intro_fastrope_squad_2", "sing_fastrope" );
	add_actor_anim( "guy1", %ch_intro_wm_fastrope_guy2 );
	add_scene( "intro_fastrope_squad_3", "sing_fastrope" );
	add_actor_anim( "guy2", %ch_intro_wm_fastrope_guy3 );
	add_scene( "outro_failure", "rts_outro" );
	add_player_anim( "player_body", %p_singapore_fail_player );
	add_notetrack_flag( "player_body", "fade_out", "outro_failure_fade_out" );
	add_vehicle_anim( "outro_vtol1", %v_singapore_fail_vtol1 );
	add_vehicle_anim( "outro_vtol2", %v_singapore_fail_vtol2 );
	add_vehicle_anim( "outro_vtol3", %v_singapore_fail_vtol3 );
	add_vehicle_anim( "outro_blackhawk1", %v_singapore_fail_heli1 );
	add_vehicle_anim( "outro_blackhawk2", %v_singapore_fail_heli2 );
	add_vehicle_anim( "outro_blackhawk3", %v_singapore_fail_heli3 );
	precache_assets();
}

level_fade_in( player )
{
	screen_fade_in( 0,5 );
}

dockside_fastrope_intro()
{
	maps/_so_rts_squad::removedeadfromsquad( 0 );
/#
	assert( level.rts.squads[ 0 ].members.size >= 3, "Not enough guys around" );
#/
	vh_heli = spawn( "script_model", ( 0, 0, 0 ) );
	vh_heli setmodel( "Veh_iw_air_blackhawk" );
	vh_heli.script_animname = "fastrope_blackhawk";
	maps/_so_rts_event::trigger_event( "heli_light", vh_heli );
	vh_heli hidepart( "tag_tail_rotor_static" );
	vh_heli hidepart( "tag_main_rotor_static" );
	vh_heli setclientflag( 6 );
	intro_names = array( "Sgt. King", "Sgt. Snider", "Pvt. Walker" );
	lightingnode = getent( "rts_intro_lighting_source", "targetname" );
	lightingnode ignorecheapentityflag( 1 );
	lightingnode setclientflag( 12 );
	wait_network_frame();
	i = 0;
	while ( i < level.rts.squads[ 0 ].members.size )
	{
		guy = level.rts.squads[ 0 ].members[ i ];
		guy setclientflag( 12 );
		guy.animname = "guy" + i;
		guy.rts_unloaded = 0;
		guy.ignoreme = 1;
		guy.goalradius = 16;
		covernodename = guy.animname;
		covernode = getnode( covernodename, "targetname" );
		if ( i < intro_names.size )
		{
			guy.name = intro_names[ i ];
		}
		if ( isDefined( covernode ) )
		{
			guy notify( "new_squad_orders" );
			guy.selectable = 0;
			guy setgoalnode( covernode );
		}
		i++;
	}
	level.rts.player.ignoreme = 1;
	level.rts.player.takedamage = 0;
	level.rts.player enableinvulnerability();
	level.rts.intro_rope_l = spawn( "script_model", vh_heli.origin );
	level.rts.intro_rope_l setmodel( "fxanim_war_sing_rappel_rope_01_mod" );
	level.rts.intro_rope_l disableclientlinkto();
	level.rts.intro_rope_l linkto( vh_heli, "tag_origin" );
	level.rts.intro_rope_r = spawn( "script_model", vh_heli.origin );
	level.rts.intro_rope_r setmodel( "fxanim_war_sing_rappel_rope_02_mod" );
	level.rts.intro_rope_r disableclientlinkto();
	level.rts.intro_rope_r linkto( vh_heli, "tag_origin" );
	level thread rope_l();
	level thread rope_r();
	level thread maps/createart/so_rts_mp_dockside_art::intro_igc();
	level thread run_scene( "intro_fastrope_player", undefined, undefined, 0 );
	level thread scene_intro_heli();
	level thread run_scene( "intro_fastrope_squad_1", undefined, undefined, 0 );
	level thread run_scene( "intro_fastrope_squad_2", undefined, undefined, 0 );
	level thread run_scene( "intro_fastrope_squad_3", undefined, undefined, 0 );
	scene_wait( "intro_fastrope_player" );
	flag_set( "rts_hud_on" );
	maps/_so_rts_support::show_player_hud();
	level.rts.intro_rope_r delete();
	level.rts.intro_rope_l delete();
	level.rts.player.ignoreme = 0;
	level.rts.player.takedamage = 1;
	level.rts.player disableinvulnerability();
	i = 0;
	while ( i < level.rts.squads[ 0 ].members.size )
	{
		level.rts.squads[ 0 ].members[ i ].animname = undefined;
		level.rts.squads[ 0 ].members[ i ].rts_unloaded = 1;
		level.rts.squads[ 0 ].members[ i ].ignoreme = 0;
		i++;
	}
	wait 2;
	thread resume_normal_ai( level.rts.squads[ 0 ].members );
}

scene_intro_heli()
{
	level thread run_scene( "intro_fastrope_heli" );
	wait_network_frame();
	v_heli = get_model_or_models_from_scene( "intro_fastrope_heli", "fastrope_blackhawk" );
	scene_wait( "intro_fastrope_heli" );
	s_start = getstruct( "intro_heli_exit_path", "targetname" );
	s_next = s_start;
	while ( isDefined( s_next ) )
	{
		dist_to_point = distance( v_heli.origin, s_next.origin );
		time = dist_to_point / 600;
		if ( s_next.targetname == s_start.targetname )
		{
			v_heli moveto( s_next.origin, time, 1, 0 );
		}
		else
		{
			v_heli moveto( s_next.origin, time, 0, 0 );
		}
		wait time;
		if ( !isDefined( s_next.target ) )
		{
			s_next = undefined;
			continue;
		}
		else
		{
			s_next = getstruct( s_next.target, "targetname" );
		}
	}
	v_heli delete();
}

resume_normal_ai( introsquad )
{
	_a589 = introsquad;
	_k589 = getFirstArrayKey( _a589 );
	while ( isDefined( _k589 ) )
	{
		guy = _a589[ _k589 ];
		if ( isDefined( guy ) )
		{
			guy.goalradius = 512;
		}
		_k589 = getNextArrayKey( _a589, _k589 );
	}
	thread maps/_so_rts_squad::ordersquadfollowplayer( undefined, 0 );
}

dockside_mission_complete_s1( success, basejustlost )
{
	while ( !success )
	{
		while ( isDefined( level.rts.missile ) )
		{
			while ( isDefined( level.rts.missile ) )
			{
				wait 0,15;
			}
		}
	}
	if ( isDefined( level.rts.game_success ) )
	{
		return;
	}
	level notify( "mission_complete" );
	level notify( "end_enemy_player" );
	aiarray = arraycombine( getaiarray( "allies" ), getvehiclearray( "allies" ), 0, 0 );
	_a622 = aiarray;
	_k622 = getFirstArrayKey( _a622 );
	while ( isDefined( _k622 ) )
	{
		dude = _a622[ _k622 ];
		dude delete();
		_k622 = getNextArrayKey( _a622, _k622 );
	}
	flag_set( "block_input" );
	level.rts.game_success = success;
	while ( isDefined( level.rts.switch_trans ) )
	{
		wait 0,05;
	}
	self notify( "dockside_mission_complete_s1" );
	self endon( "dockside_mission_complete_s1" );
	flag_clear( "airstrike_avail" );
	screen_fade_out( 0 );
	del_poi( getpoibyref( "rts_poi_df21" ) );
	del_poi( getpoibyref( "rts_poi_hellads1" ) );
	del_poi( getpoibyref( "rts_poi_hellads2" ) );
	level.rts.player freezecontrols( 1 );
	level.rts.player set_ignoreme( 1 );
	flag_clear( "rts_hud_on" );
	maps/_so_rts_support::hide_player_hud();
	level.rts.player enableinvulnerability();
	level clientnotify( "rts_OFF" );
	flag_set( "rts_mode_locked_out" );
	flag_clear( "rts_mode" );
	flag_set( "fps_mode" );
	luinotifyevent( &"rts_hud_visibility", 1, 0 );
	level.rts.player clearclientflag( 3 );
	maps/_so_rts_event::event_clearall( 0 );
	if ( is_true( success ) )
	{
		set_objective( level.obj_destroy_cargo, undefined, "done" );
		level thread maps/createart/so_rts_mp_dockside_art::success_igc();
		maps/_so_rts_event::trigger_event( "dlg_thats_a_hit" );
		maps/_so_rts_event::trigger_event( "airstrike_hit_confirm" );
		maps/_so_rts_event::trigger_event( "mission_win_sfx" );
		level.player set_story_stat( "SO_WAR_SINGAPORE_SUCCESS", 1 );
		level.player giveachievement_wrapper( "SP_RTS_DOCKSIDE" );
		level notify( "mission_success" );
		flag_clear( "rts_event_ready" );
		thread boat_ending();
		flag_set( "rts_game_over" );
		wait 16;
		level thread maps/_so_rts_support::missioncompletemsg( success );
		maps/_so_rts_support::missionsuccessmenu();
	}
	else
	{
		if ( isDefined( level.rts.missile ) )
		{
			wait 0,5;
		}
		level thread maps/createart/so_rts_mp_dockside_art::fail_igc();
		maps/_so_rts_event::trigger_event( "mission_lose" );
		boat_failure();
		flag_clear( "rts_event_ready" );
		flag_set( "rts_game_over" );
		level thread maps/_so_rts_support::missioncompletemsg( success );
		maps/_so_rts_support::missionfailuremenu();
	}
	level clientnotify( "rts_fd" );
	screen_fade_out( 1 );
	level notify( "rts_terminated" );
	maps/_so_rts_support::show_player_hud();
	maps/_so_rts_support::toggle_damage_indicators( 1 );
	nextmission();
}

dockside_airstrikewatch()
{
	level notify( "watching_dockside_missile" );
	level endon( "watching_dockside_missile" );
	level.rts.player waittill( "missile_fired", missile );
	missile endon( "death" );
	level.rts.missile = missile;
	missile_boxes = getentarray( "missile_hit_box", "targetname" );
	missile_target = getent( "rts_base_enemy", "targetname" );
	while ( 1 )
	{
		_a724 = missile_boxes;
		_k724 = getFirstArrayKey( _a724 );
		while ( isDefined( _k724 ) )
		{
			missile_box = _a724[ _k724 ];
			if ( missile istouching( missile_box ) )
			{
				missile_target.takedamage = 1;
				missile_target dodamage( missile_target.health + 100, missile_target.origin, level.player );
				missile delete();
				return;
			}
			_k724 = getNextArrayKey( _a724, _k724 );
		}
		wait 0,05;
	}
}

missile_steering_hint()
{
	msg = newhudelem();
	msg.alignx = "center";
	msg.aligny = "middle";
	msg.horzalign = "center";
	msg.vertalign = "middle";
	msg.y -= 130;
	msg.foreground = 1;
	msg.fontscale = 2;
	msg.hidewheninmenu = 1;
	msg.alpha = 0;
	msg.color = ( 0, 0, 0 );
	msg settext( &"SO_RTS_MISSILE_HINT" );
	msg fadeovertime( 1 );
	msg.alpha = 0,75;
	level waittill_any( "fire_missile_done", "rts_terminated", "mission_control_abort" );
	msg fadeovertime( 1 );
	msg.alpha = 0;
	wait 1;
	msg destroy();
}

dockside_airstrikego()
{
	level endon( "rts_terminated" );
	level endon( "mission_control_abort" );
	level endon( "dockside_mission_complete_s1" );
	if ( is_true( level.dockside_airstrikemsg ) )
	{
		return;
	}
	flag_clear( "airstrike_avail" );
	packages_avail = maps/_so_rts_catalog::package_generateavailable( level.rts.player.team );
	level.dockside_airstrikemsg = 1;
	luinotifyevent( &"rts_airstrike_avail_in", 1, 0 );
	if ( maps/_so_rts_event::trigger_event( "airstrike_ready" ) )
	{
		level waittill( "airstrike_ready_done" );
	}
	wait 1;
	if ( maps/_so_rts_event::trigger_event( "my_air_clear" ) )
	{
		level waittill( "my_air_clear_done" );
	}
	luinotifyevent( &"rts_update_hint_text", 1, istring( "SO_RTS_AIRSTRIKE_AVAIL" ) );
	flag_set( "airstrike_avail" );
	packages_avail = maps/_so_rts_catalog::package_generateavailable( level.rts.player.team );
	level thread dockside_airstrikewatch();
	level waittill( "fire_missile" );
	flag_clear( "airstrike_avail" );
	luinotifyevent( &"rts_update_hint_text" );
	level.rts.player clearclientflag( 3 );
	maps/_so_rts_support::hide_player_hud();
	maps/_so_rts_event::event_clearall( 0 );
	maps/_so_rts_event::trigger_event( "airstrike_inc" );
	level.dockside_airstrikemsg = undefined;
	if ( !isDefined( level.missiles_fired ) )
	{
		level.missiles_fired = 0;
	}
	if ( level.missiles_fired == 0 )
	{
		level thread missile_steering_hint();
	}
	level.missiles_fired++;
}

dockside_level_waitforpoifailnotify()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		level waittill( "poi_nolonger_contested", entity );
		which = maps/_so_rts_poi::ispoient( entity );
		if ( isDefined( which ) )
		{
			if ( which == "rts_poi_hellads1" || which == "rts_poi_hellads2" )
			{
				maps/_so_rts_event::trigger_event( "hellads_hack_fail" );
				break;
			}
			else
			{
				if ( which == "rts_poi_df21" )
				{
					maps/_so_rts_event::trigger_event( "missile_hack_fail" );
				}
			}
		}
	}
}

dockside_mission_control_abort()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		level waittill( "mission_complete", success );
		if ( is_true( success ) )
		{
			level notify( "mission_control_abort" );
			return;
		}
	}
}

dockside_missile_control()
{
	level endon( "rts_terminated" );
	level endon( "mission_control_abort" );
	level endon( "dockside_mission_complete_s1" );
	strike_pkg = maps/_so_rts_catalog::package_getpackagebytype( "airstrike_pkg" );
	while ( !flag( "rts_game_over" ) )
	{
		flag_set( "airstrike_avail" );
		packages_avail = maps/_so_rts_catalog::package_generateavailable( level.rts.player.team );
		if ( isinarray( packages_avail, strike_pkg ) && strike_pkg.selectable )
		{
			level thread dockside_airstrikego();
			level waittill( "fire_missile_done" );
			level.rts.missile = undefined;
			maps/_so_rts_support::show_player_hud();
			if ( flag( "rts_mode" ) )
			{
				level.rts.player setclientflag( 3 );
			}
			if ( !flag( "rts_game_over" ) )
			{
				luinotifyevent( &"rts_airstrike_avail_in", 1, int( strike_pkg.cost[ "allies" ] / 1000 ) );
			}
			wait int( strike_pkg.cost[ "allies" ] / 1000 );
		}
		wait 0,05;
	}
}

dockside_level_waitforpoinotify()
{
	level endon( "rts_terminated" );
	level thread dockside_level_waitforpoifailnotify();
	poicaps = 0;
	while ( 1 )
	{
		level waittill( "poi_captured_allies", which );
		if ( isDefined( which ) )
		{
			if ( which == "rts_poi_hellads1" )
			{
				if ( isDefined( getpoibyref( "rts_poi_hellads2" ) ) )
				{
					maps/_so_rts_event::trigger_event( "hellads1_hacked" );
				}
				else
				{
					maps/_so_rts_event::trigger_event( "hellads2_hacked" );
				}
				poicaps++;
				continue;
			}
			else if ( which == "rts_poi_hellads2" )
			{
				if ( isDefined( getpoibyref( "rts_poi_hellads1" ) ) )
				{
					maps/_so_rts_event::trigger_event( "hellads1_hacked" );
				}
				else
				{
					maps/_so_rts_event::trigger_event( "hellads2_hacked" );
				}
				poicaps++;
				continue;
			}
			else
			{
				if ( which == "rts_poi_df21" )
				{
					maps/_so_rts_event::trigger_event( "missile_hack_success" );
				}
			}
		}
		poicaps++;
/#
		println( "POI CAP:" + poicaps );
#/
		switch( poicaps )
		{
			case 3:
				maps/_so_rts_event::trigger_event( "all_defenses_down" );
				level thread dockside_missile_control();
				break;
			continue;
			case 2:
				packages_avail = maps/_so_rts_catalog::package_generateavailable( "allies", 1 );
				i = 0;
				while ( i < packages_avail.size )
				{
					if ( packages_avail[ i ].ref == "metalstorm_pkg" )
					{
						packages_avail[ i ].min_friendly = 3;
						packages_avail[ i ].max_friendly = 3;
						break;
					}
					else
					{
						i++;
					}
				}
				case 1:
				}
			}
		}
	}
}

dockside_geo_changes()
{
	gatebrushes = getentarray( "rts_gate", "script_noteworthy" );
	_a966 = gatebrushes;
	_k966 = getFirstArrayKey( _a966 );
	while ( isDefined( _k966 ) )
	{
		brush = _a966[ _k966 ];
		brush connectpaths();
		brush delete();
		_k966 = getNextArrayKey( _a966, _k966 );
	}
	if ( isDefined( level.rts.enemy_base ) && isDefined( level.rts.enemy_base.entity ) )
	{
		boatanimrig = spawn( "script_model", ( -300, -2100, 900 ), 0 );
		boatanimrig setmodel( "fxanim_war_sing_cargo_ship_sink_mod" );
		boatanimrig.health = 10000;
		level.rts.enemy_base.entity.origin = boatanimrig gettagorigin( "cargo_ship_jnt" );
		level.rts.enemy_base.entity.angles = boatanimrig gettagangles( "cargo_ship_jnt" );
		level.rts.enemy_base.entity linkto( boatanimrig, "cargo_ship_jnt" );
		level.rts.enemy_base.entity.animrig = boatanimrig;
	}
	crates = getentarray( "crate", "targetname" );
	_a991 = crates;
	_k991 = getFirstArrayKey( _a991 );
	while ( isDefined( _k991 ) )
	{
		crate = _a991[ _k991 ];
		crate delete();
		_k991 = getNextArrayKey( _a991, _k991 );
	}
	crate = getent( "rts_crate_off", "targetname" );
	if ( isDefined( crate ) )
	{
		crate delete();
	}
	turretlocation = getent( "rts_poi_hellads1", "targetname" );
	covernodes = getcovernodearray( turretlocation.origin, 256 );
	_a1004 = covernodes;
	_k1004 = getFirstArrayKey( _a1004 );
	while ( isDefined( _k1004 ) )
	{
		node = _a1004[ _k1004 ];
		setenablenode( node, 0 );
		_k1004 = getNextArrayKey( _a1004, _k1004 );
	}
	sam_locations = getstructarray( "sam_launcher_location", "targetname" );
	_a1011 = sam_locations;
	_k1011 = getFirstArrayKey( _a1011 );
	while ( isDefined( _k1011 ) )
	{
		loc = _a1011[ _k1011 ];
		turret = spawnturret( "auto_turret", loc.origin, "tow_turret_sp" );
		turret.turrettype = "tow";
		turret setturrettype( turret.turrettype );
		turret setmodel( "T6_wpn_turret_sam_larger" );
		turret.angles = loc.angles;
		turret setturretteam( "axis" );
		turret.team = "axis";
		turret.health = 1000;
		turret setmode( "auto_nonai", "scan" );
		turret setscanningpitch( -35 );
		turret thread shoot_remote_missile();
		_k1011 = getNextArrayKey( _a1011, _k1011 );
	}
	poi = maps/_so_rts_poi::getpoibyref( "rts_poi_LZ" );
	poi.entity.ignoreme = 1;
	poi = maps/_so_rts_poi::getpoibyref( "rts_poi_df21" );
/#
	assert( isDefined( poi ) );
#/
	missiletagorigin = poi.entity gettagorigin( "tag_missle" );
	missiletagangles = poi.entity gettagangles( "tag_missle" );
	poi.missile = spawn( "script_model", missiletagorigin );
	poi.missile.angles = missiletagangles;
	poi.missile setmodel( "veh_t6_missile_truck_missile" );
	poi.missile linkto( poi.entity, "tag_missle" );
	poi.claimcallback = ::missiletrucklaunch;
	level thread missile_truck_steam();
	poi = maps/_so_rts_poi::getpoibyref( "rts_poi_hellads1" );
	poi thread laser_turret_think();
	poi = maps/_so_rts_poi::getpoibyref( "rts_poi_hellads2" );
	poi thread laser_turret_think();
	dudes = 0;
	switch( getdifficulty() )
	{
		case "easy":
			dudes = 0;
			break;
		case "medium":
			dudes = 1;
			break;
		case "hard":
			dudes = 2;
			break;
		case "fu":
			dudes = 3;
			break;
	}
	rpg_guy_locations = getstructarray( "rpg_guy_location", "targetname" );
	_a1098 = rpg_guy_locations;
	_k1098 = getFirstArrayKey( _a1098 );
	while ( isDefined( _k1098 ) )
	{
		loc = _a1098[ _k1098 ];
		if ( dudes > 0 )
		{
			ai = simple_spawn_single( "ai_spawner_enemy_rpg", undefined, undefined, undefined, undefined, undefined, undefined, 1 );
			ai forceteleport( loc.origin, loc.angles );
			ai setgoalpos( loc.origin );
			ai thread ai_rocketman_think();
			dudes--;

		}
		else
		{
		}
		_k1098 = getNextArrayKey( _a1098, _k1098 );
	}
	getent( "crane_rail", "targetname" ) delete();
	getent( "crane_roller", "targetname" ) delete();
	getent( "crane_wheel", "targetname" ) delete();
	getent( "claw_base", "targetname" ) delete();
	wires = getentarray( "crane_wire", "targetname" );
	_a1121 = wires;
	_k1121 = getFirstArrayKey( _a1121 );
	while ( isDefined( _k1121 ) )
	{
		wire = _a1121[ _k1121 ];
		wire delete();
		_k1121 = getNextArrayKey( _a1121, _k1121 );
	}
	arms = getentarray( "claw_arm_z", "targetname" );
	_a1125 = arms;
	_k1125 = getFirstArrayKey( _a1125 );
	while ( isDefined( _k1125 ) )
	{
		arm = _a1125[ _k1125 ];
		arm delete();
		_k1125 = getNextArrayKey( _a1125, _k1125 );
	}
	arms = getentarray( "claw_arm_y", "targetname" );
	_a1129 = arms;
	_k1129 = getFirstArrayKey( _a1129 );
	while ( isDefined( _k1129 ) )
	{
		arm = _a1129[ _k1129 ];
		arm delete();
		_k1129 = getNextArrayKey( _a1129, _k1129 );
	}
}

ai_rocketman_think()
{
	self endon( "death" );
	self.goalradius = 64;
	self.ignoreall = 1;
	pkg_ref = maps/_so_rts_catalog::package_getpackagebytype( "infantry_enemy_reg_pkg" );
	ai_ref = level.rts.ai[ pkg_ref.units[ 0 ] ];
	scene_wait( "intro_fastrope_player" );
	squad = maps/_so_rts_squad::getsquadbypkg( "infantry_enemy_reg_pkg", self.team );
	self maps/_so_rts_ai::ai_preinitialize( ai_ref, pkg_ref, self.team, squad.id );
	self maps/_so_rts_ai::ai_initialize( ai_ref, self.team, self.origin, squad.id, self.angles, pkg_ref, self.health );
	self.maxvisibledist = 2048;
	self.maxsightdistsqrd = 4194304;
	self.goalradius = 64;
	self.ignoreall = 1;
	self.ignoreme = 0;
	self.rts_unloaded = 1;
	self.takedamage = 1;
	while ( 1 )
	{
		targets = arraycombine( getaibyspecies( "robot_actor", "allies" ), getaibyspecies( "vehicle", "allies" ), 0, 0 );
		if ( targets.size > 0 )
		{
			i = 0;
			while ( i < targets.size )
			{
				target = targets[ i ];
				canshoottarget = bullettracepassed( self get_eye(), target.origin, 1, self, target );
				if ( isDefined( target ) && canshoottarget )
				{
					self.ignoreall = 0;
					self.favoriteenemy = target;
					while ( isalive( target ) )
					{
						wait 1;
					}
					self.ignoreall = 1;
					self.favoriteenemy = undefined;
					wait 5;
					i++;
					continue;
				}
				i++;
			}
		}
		else self.ignoreall = 0;
		self.favoriteenemy = undefined;
		wait 1;
	}
}

getrandomoffset()
{
	offset = randomintrange( 1000, 1500 );
	if ( randomint( 100 ) < 50 )
	{
		offset *= -1;
	}
	return offset;
}

shoot_remote_missile()
{
	level endon( "rts_terminated" );
	while ( !flag( "rts_game_over" ) )
	{
		level.rts.player waittill( "remote_missile_start" );
		level.rts.player waittill( "missile_fire", rocket );
		fakeent = spawn( "script_model", rocket.origin );
		fakeent setmodel( "tag_origin" );
		fakeent linkto( rocket, "tag_origin", ( getrandomoffset(), getrandomoffset(), randomintrange( 100, 1000 ) ) );
		self.fake_target = fakeent;
		self settargetentity( fakeent );
		self setconvergencetime( 0, "yaw" );
		self setconvergencetime( 0, "pitch" );
		wait randomfloatrange( 1, 2,5 );
		missileinterval = 3;
		i = 0;
		while ( i <= 1 )
		{
			self delay_thread( 0,05, ::shoot_turret );
			self waittill( "missile_fire", missile );
			missile thread missile_destroy_before_impact( rocket );
			wait missileinterval;
			i++;
		}
	}
}

shoot_turret()
{
	self shootturret();
}

missile_destroy_before_impact( target )
{
	self endon( "death" );
	maxdistsq = randomintrange( 1048576, 25000000 );
	while ( isDefined( target ) )
	{
		disttotargetsq = distancesquared( target.origin, self.origin );
		if ( disttotargetsq < maxdistsq )
		{
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	playsoundatposition( "evt_sam_explo", ( 0, 0, 0 ) );
	self missile_destroy();
}

missile_destroy()
{
	maps/_so_rts_event::trigger_event( "sam_missile_explosion", self.origin );
	if ( isDefined( self.fake_target ) )
	{
		self.fake_target delete();
	}
	self delete();
}

docksdie_order_to_samsite( squadid )
{
	poi = maps/_so_rts_poi::getpoibyref( "rts_poi_hellads1" );
	if ( !isDefined( poi ) )
	{
		maps/_so_rts_enemy::order_new_squad( squadid );
	}
	else
	{
		maps/_so_rts_squad::ordersquaddefend( poi.entity.origin, squadid );
	}
}

dockside_cargodamagewatch( boat )
{
	while ( isDefined( self ) && self.health > 0 )
	{
		boat waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
/#
		if ( isDefined( attacker ) )
		{
		}
		else
		{
		}
		println( attacker getentitynumber() + " unknown", "Animrig Damage: " + getTime() + " by ent:" );
#/
		boat.health = 100;
		if ( isDefined( attacker ) && attacker == level.rts.player )
		{
			maps/_so_rts_rules::mission_complete( 1 );
		}
	}
}

dockside_enemybasedamagewatch()
{
	while ( isDefined( self ) && self.health > 0 )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
/#
		if ( isDefined( attacker ) )
		{
		}
		else
		{
		}
		println( attacker getentitynumber() + " unknown", "base Damage: " + getTime() + " by ent:" );
#/
		self.health = 100;
		if ( isDefined( attacker ) && attacker == level.rts.player )
		{
			maps/_so_rts_rules::mission_complete( 1 );
		}
	}
}

dockside_enemybasewatch()
{
	self thread dockside_enemybasedamagewatch();
	self thread dockside_cargodamagewatch( self.animrig );
	while ( isDefined( self ) && self.health > 0 )
	{
		self.takedamage = 0;
		self.animrig.takedamage = 0;
		level waittill( "fire_missile" );
		self.takedamage = 1;
		self.animrig.takedamage = 1;
		level waittill( "fire_missile_done" );
	}
	maps/_so_rts_rules::mission_complete( 1 );
}

setup_challenges()
{
	self thread maps/_so_rts_support::track_unit_type_usage();
	add_spawn_function_veh_by_type( "heli_quadrotor_rts", ::watch_quad_death );
	add_spawn_function_veh_by_type( "drone_metalstorm_rts", ::watch_asd_death );
	level.callbackactorkilled = ::maps/_so_rts_challenges::global_actor_killed_challenges_callback;
	level.rts.kill_stats = spawnstruct();
	level.rts.kill_stats.total_kills = 0;
	level.rts.kill_stats.explosive_kills = 0;
	level.rts.kill_stats.claw_kills = 0;
	level.rts.kill_stats.headshot_kills = 0;
	level.rts.kill_stats.melee_kills = 0;
	level.rts.kill_stats.stun_kills = 0;
	level.rts.kill_stats.asd_rundown_kills = 0;
	level.rts.kill_stats.explosive_kills_total = 15;
	level.rts.kill_stats.claw_kills_total = 2;
	level.rts.kill_stats.headshot_kills_total = 10;
	level.rts.kill_stats.melee_kills_total = 15;
	level.rts.kill_stats.stun_kills_total = 15;
	level.rts.kill_stats.asd_rundown_kills_total = 20;
	self maps/_challenges_sp::register_challenge( "EXPLOSIVE_KILLS" );
	self maps/_challenges_sp::register_challenge( "KILL_CLAWS" );
	self maps/_challenges_sp::register_challenge( "HEADSHOTS" );
	self maps/_challenges_sp::register_challenge( "MELEE_KILLS" );
	self maps/_challenges_sp::register_challenge( "STUN_KILLS" );
	self maps/_challenges_sp::register_challenge( "ASD_RUNDOWN" );
	self maps/_challenges_sp::register_challenge( "MIN_MODULE", ::challenge_min_module );
	self maps/_challenges_sp::register_challenge( "TIME", ::challenge_time_limit );
	self maps/_challenges_sp::register_challenge( "CLAW_VS_ASD", ::challenge_kill_asd_as_claw );
	self maps/_challenges_sp::register_challenge( "TACTICAL", ::maps/_so_rts_support::challenge_tactical );
}

watch_asd_death()
{
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( isplayer( attacker ) )
	{
		level notify( "player_killed_asd" );
	}
}

watch_quad_death()
{
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( isplayer( attacker ) )
	{
		level notify( "player_killed_quad" );
	}
}

challenge_min_module( str_notify )
{
	level endon( "intruder_disrupted" );
	level waittill( "mission_success" );
	self notify( str_notify );
}

challenge_time_limit( str_notify )
{
	flag_wait( "rts_start_clock" );
	start_time = getTime();
	level waittill( "mission_success" );
	play_time = getTime() - start_time;
	seconds_remaining = ( ( level.rts.game_rules.time * 60000 ) - play_time ) / 1000;
	if ( seconds_remaining > 120 )
	{
		self notify( str_notify );
	}
}

challenge_kill_asd_as_claw( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_asd" );
		if ( isDefined( self.ally ) && self.ally.ai_ref.species == "robot_actor" )
		{
			self notify( str_notify );
		}
	}
}

loop_rumble_on_object( rumble_type, end_notify )
{
	if ( isDefined( end_notify ) )
	{
		self endon( end_notify );
	}
	self endon( "death" );
	while ( 1 )
	{
		playrumbleonposition( rumble_type, self.origin );
		wait 0,5;
	}
}

missiletrucklaunch( team )
{
	if ( team == "allies" )
	{
		level notify( "missile_launch" );
		self.entity useanimtree( -1 );
		self.entity setflaggedanim( "missile_launch", %v_missile_truck_raise, 1, 0,2, 1 );
		self.entity playsound( "evt_sam_servo_start" );
		playrumbleonposition( "artillery_rumble", self.entity.origin );
		self.entity waittillmatch( "missile_launch" );
		return "end";
		maps/_so_rts_event::trigger_event( "missile_launch", self.missile );
		self.entity playsound( "evt_sam_launch" );
		playrumbleonposition( "artillery_rumble", self.entity.origin );
		wait 5;
		maps/_so_rts_event::trigger_event( "missile_exhaust", self.missile );
		self.entity thread loop_rumble_on_object( "artillery_rumble", "stop_rumble" );
		self.entity thread notify_delay( "stop_rumble", 3 );
		missilegoal = self.missile.origin + vectorScale( ( 0, 0, 0 ), 3000 );
		self.missile unlink();
		self.missile moveto( missilegoal, 6, 4, 0 );
		self.missile waittill( "movedone" );
		maps/_so_rts_event::trigger_event( "missile_explosion", self.missile.origin + vectorScale( ( 0, 0, 0 ), 100 ) );
		self.missile playsound( "evt_sam_explo" );
		self.missile delete();
	}
}

missile_truck_steam()
{
	steam = getent( "rts_poi_df21", "targetname" );
	steam play_fx( "fx_rts_steam_missile_truck", steam.origin, undefined, "stop_fx" );
	level waittill( "missile_launch" );
	steam notify( "stop_fx" );
}

rope_l()
{
	level.rts.intro_rope_l useanimtree( -1 );
	level.rts.intro_rope_l setflaggedanimknoballrestart( "rope_kick", %fxanim_war_sing_rappel_rope_01_anim, %root, 1, 0,2, 1 );
	level.rts.intro_rope_l waittillmatch( "rope_kick" );
	return "end";
}

rope_r()
{
	level.rts.intro_rope_r useanimtree( -1 );
	level.rts.intro_rope_r setflaggedanimknoballrestart( "rope_kick", %fxanim_war_sing_rappel_rope_02_anim, %root, 1, 0,2, 1 );
	level.rts.intro_rope_r waittillmatch( "rope_kick" );
	return "end";
}

play_fx_on_tag( fx, ent, tag )
{
	tagorigin = ent gettagorigin( tag );
	tagangles = ent gettagangles( tag );
	fx_base = spawn( "script_model", tagorigin );
	fx_base.angles = tagangles;
	fx_base setmodel( "tag_origin" );
	fx_base linkto( ent, tag );
	playfxontag( fx, fx_base, "tag_origin" );
	return fx_base;
}

laser_turret_think()
{
	turret = self.entity;
	fx_base = play_fx_on_tag( level._effect[ "laser_turret_light_red" ], turret, "tag_fx_base" );
	fx_turret = play_fx_on_tag( level._effect[ "laser_turret_light_red" ], turret, "tag_fx_turret" );
	fx_beam = play_fx_on_tag( level._effect[ "laser_turret_beam_red" ], turret, "tag_flash" );
	turret useanimtree( -1 );
	idleanimarray = array( %fxanim_war_laser_turret_search_01_anim, %fxanim_war_laser_turret_search_02_anim, %fxanim_war_laser_turret_search_03_anim, %fxanim_war_laser_turret_search_04_anim );
	while ( !is_true( self.captured ) )
	{
		turret laser_turret_idle( idleanimarray );
		turret playsound( "evt_laser_servo" );
	}
	fx_base delete();
	fx_turret delete();
	fx_beam delete();
	fx_base = play_fx_on_tag( level._effect[ "laser_turret_disabled" ], turret, "tag_fx_turret" );
	fx_base playsound( "evt_laser_shutdown" );
	turret setflaggedanimknoballrestart( "deactivate", %fxanim_war_laser_turret_off_anim, %root, 1, 0,2, 1 );
	turret waittillmatch( "deactivate" );
	return "end";
	wait 2;
	fx_base delete();
	fx_base = play_fx_on_tag( level._effect[ "laser_turret_light_green" ], turret, "tag_fx_base" );
	fx_turret = play_fx_on_tag( level._effect[ "laser_turret_light_green" ], turret, "tag_fx_turret" );
	fx_beam = play_fx_on_tag( level._effect[ "laser_turret_beam_green" ], turret, "tag_flash" );
	turret setflaggedanimknoballrestart( "activate", %fxanim_war_laser_turret_on_anim, %root, 1, 0,2, 1 );
	turret waittillmatch( "activate" );
	return "end";
	turret playsound( "evt_laser_servo" );
	while ( 1 )
	{
		turret laser_turret_idle( idleanimarray );
	}
}

laser_turret_idle( idleanimarray )
{
	self setflaggedanimknoballrestart( "idle", idleanimarray[ randomint( idleanimarray.size ) ], %root, 1, 0,2, 0,5 );
	self waittillmatch( "idle" );
	return "end";
}

delete_all_transports()
{
	transport_array = getentarray( "transport", "script_noteworthy" );
	_a1623 = transport_array;
	_k1623 = getFirstArrayKey( _a1623 );
	while ( isDefined( _k1623 ) )
	{
		transport = _a1623[ _k1623 ];
		if ( isDefined( transport.cargo ) )
		{
			transport.cargo delete();
		}
		_k1623 = getNextArrayKey( _a1623, _k1623 );
	}
	array_delete( transport_array );
}

boat_failure()
{
	level.rts.player thread maps/_so_rts_ai::restorereplacement();
	while ( isDefined( level.rts.player.ally ) )
	{
		wait 0,05;
	}
	level.rts.player unlink();
	view_location = getstruct( "end_view_location", "targetname" );
	boat_location = getstruct( "boat_location", "targetname" );
	toboat = boat_location.origin - view_location.origin;
	view_angles = vectorToAngle( toboat );
	boat_location_ent = spawn_model( "tag_origin", boat_location.origin, boat_location.angles );
	view_location_ent = spawn_model( "tag_origin", view_location.origin, view_angles );
	level.rts.player setorigin( view_location.origin );
	level.rts.player setplayerangles( view_angles );
	level.rts.player playerlinktoabsolute( view_location_ent, "tag_origin" );
	level.rts.player hideviewmodel();
	level.rts.player freezecontrols( 1 );
	view_location_ent linkto( boat_location_ent );
	boat_location_ent rotateyaw( -30, 25 );
	delete_all_transports();
	mission_complete_clear_entities();
	wait_network_frame();
	maps/_so_rts_support::hide_player_hud();
	rig = level.rts.enemy_base.entity.animrig;
	rig useanimtree( -1 );
	rig animscripted( "outro_boat", rig.origin, rig.angles, %fxanim_war_sing_cargo_ship_leave_anim );
	level thread run_scene( "outro_failure" );
	level thread screen_fade_in( 2 );
	flag_wait( "outro_failure_fade_out" );
}

boat_ending()
{
	level.rts.player thread maps/_so_rts_ai::restorereplacement();
	level.rts.player unlink();
	view_location = getstruct( "end_view_location", "targetname" );
	boat_location = getstruct( "boat_location", "targetname" );
	toboat = boat_location.origin - view_location.origin;
	view_angles = vectorToAngle( toboat );
	boat_location_ent = spawn_model( "tag_origin", boat_location.origin, boat_location.angles );
	view_location_ent = spawn_model( "tag_origin", view_location.origin, view_angles );
	level.rts.player setorigin( view_location.origin );
	level.rts.player setplayerangles( view_angles );
	level.rts.player playerlinktoabsolute( view_location_ent, "tag_origin" );
	level.rts.player hideviewmodel();
	view_location_ent linkto( boat_location_ent );
	boat_location_ent rotateyaw( -30, 25 );
	maps/_so_rts_support::hide_player_hud();
	level thread screen_fade_in( 1,2 );
/#
	assert( isDefined( level.rts.enemy_base.entity.animrig ) );
#/
	level.rts.player freezecontrols( 1 );
	missile_end = getstruct( "boat_location", "targetname" ).origin + vectorScale( ( 0, 0, 0 ), 500 );
	missile_start = missile_end + vectorScale( ( 0, 0, 0 ), 2500 );
	missile_vector = missile_start - missile_end;
	missile_angles = vectorToAngle( missile_vector );
	missile = spawn_model( "projectile_javelin_missile", missile_start, missile_angles );
	playfxontag( level._effect[ "predator_trail" ], missile, "TAG_FX" );
	missile moveto( missile_end, 1,5 );
	missile waittill( "movedone" );
	playsoundatposition( "evt_ship_missle_exp", ( 0, 0, 0 ) );
	missile delete();
	rig = level.rts.enemy_base.entity.animrig;
	rig useanimtree( -1 );
	rig animscripted( "boat", rig.origin, rig.angles, %fxanim_war_sing_cargo_ship_sink_anim );
	level.rts.enemy_base.entity.animrig thread container_splashes();
	playfxontag( level._effect[ "boat_water" ], level.rts.enemy_base.entity.animrig, "tag_waterline" );
	level.rts.enemy_base.entity.animrig waittillmatch( "boat" );
	return "explosion01";
	playfxontag( level._effect[ "boat_explosion_xlg" ], level.rts.enemy_base.entity.animrig, "tag_explode1" );
	playfxontag( level._effect[ "boat_fire" ], level.rts.enemy_base.entity.animrig, "tag_explode1" );
	level thread boat_ending_explosion_1();
	level.rts.enemy_base.entity.animrig waittillmatch( "boat" );
	return "explosion02";
	playfxontag( level._effect[ "boat_explosion_lg" ], level.rts.enemy_base.entity.animrig, "tag_explode2" );
	playfxontag( level._effect[ "boat_fire" ], level.rts.enemy_base.entity.animrig, "tag_explode1" );
	level thread boat_ending_explosion_2();
	level.rts.enemy_base.entity.animrig waittillmatch( "boat" );
	return "explosion03";
	playfxontag( level._effect[ "boat_explosion_lg" ], level.rts.enemy_base.entity.animrig, "tag_explode3" );
	playfxontag( level._effect[ "boat_fire" ], level.rts.enemy_base.entity.animrig, "tag_explode1" );
	level thread boat_ending_explosion_3();
	level.rts.enemy_base.entity.animrig waittillmatch( "boat" );
	return "end";
}

mission_complete_clear_entities()
{
	flag_clear( "rts_event_ready" );
	array_func( getaiarray(), ::mission_complete_clear_entity );
	array_func( getvehiclearray(), ::mission_complete_clear_entity );
	wait 0,05;
	flag_set( "rts_event_ready" );
}

mission_complete_clear_entity()
{
	if ( is_true( self.donotclear ) )
	{
		return;
	}
	self delete();
}

boat_ending_explosion_1()
{
	earthquake( 0,5, 2,5, level.player.origin, 500 );
	level.player playrumblelooponentity( "artillery_rumble" );
	wait 2,5;
	level.player stoprumble( "artillery_rumble" );
}

boat_ending_explosion_2()
{
	earthquake( 0,3, 1,5, level.player.origin, 500 );
	level.player playrumbleonentity( "artillery_rumble" );
}

boat_ending_explosion_3()
{
	earthquake( 0,4, 1, level.player.origin, 500 );
	level.player playrumbleonentity( "artillery_rumble" );
}

container_splashes()
{
	splash_fx = [];
	splash_fx[ 1 ] = "water_splash_tall";
	splash_fx[ 2 ] = "water_splash_wide";
	splash_fx[ 3 ] = "water_splash_wide";
	splash_fx[ 4 ] = "water_splash_tall";
	splash_fx[ 5 ] = "water_splash_tall";
	splash_fx[ 6 ] = "water_splash_wide";
	splash_fx[ 7 ] = "water_splash_wide";
	splash_fx[ 8 ] = "water_splash_wide";
	splash_fx[ 9 ] = "water_splash_tall";
	splash_fx[ 10 ] = "water_splash_wide";
	splash_fx[ 11 ] = "water_splash_wide";
	splash_fx[ 12 ] = "water_splash_tall";
	splash_fx[ 13 ] = "water_splash_wide";
	splash_fx[ 14 ] = "water_splash_tall";
	splash_fx[ 15 ] = "water_splash_wide";
	containerindex = 1;
	while ( 1 )
	{
		self waittill( "boat", note );
		if ( isDefined( note ) )
		{
			if ( note == "end" )
			{
				return;
			}
			if ( issubstr( note, "cargo_splash" ) )
			{
				if ( containerindex < 10 )
				{
					tagname = "tag_fx_splash0" + containerindex;
				}
				else
				{
					tagname = "tag_fx_splash" + containerindex;
				}
/#
				assert( isDefined( splash_fx[ containerindex ] ) );
#/
				fxid = splash_fx[ containerindex ];
				playfxontag( level._effect[ fxid ], self, tagname );
				earthquake( 0,1, 0,1, level.player.origin, 500 );
				level.player playrumbleonentity( "damage_light" );
				containerindex++;
			}
		}
	}
}

player_waitfor_vehicleentry()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		self waittill( "vehicle_taken_over", entity );
		if ( isDefined( entity ) )
		{
			entity thread vehiclehealthregen();
		}
	}
}

vehiclehealthregen()
{
	self notify( "vehicleHealthRegen" );
	self endon( "vehicleHealthRegen" );
	self endon( "death" );
	self endon( "player_exited" );
	level endon( "eye_in_the_sky" );
	level endon( "switch_and_takeover" );
	if ( !isDefined( self.ai_ref.regenrate ) || self.ai_ref.regenrate == 0 )
	{
		return;
	}
	amount = int( float( self.health_max * self.ai_ref.regenrate ) );
	threshold = 5000;
	while ( 1 )
	{
		if ( isDefined( self.lasthitstamp ) )
		{
			curtime = getTime();
			if ( ( self.lasthitstamp + threshold ) < curtime )
			{
				if ( self.health < self.health_max )
				{
/#
					println( "$$$ Regenerating health on " + self.ai_ref.ref + ". Amount(" + amount + ") CurHealth: " + self.health );
#/
					self.health += amount;
					if ( self.health > self.health_max )
					{
						self.health = self.health_max;
					}
					if ( self.vehicletype == "drone_metalstorm_rts" )
					{
						self maps/_metal_storm::metalstorm_update_damage_fx();
						break;
					}
					else
					{
						if ( self.vehicletype == "heli_quadrotor_rts" || self.vehicletype == "heli_quadrotor_rts_player" )
						{
							self maps/_quadrotor::quadrotor_update_damage_fx();
						}
					}
				}
			}
		}
		wait 1;
	}
}

setupmissileboundary()
{
	ulxy = getstruct( "rts_ulxy_missile", "targetname" );
	if ( !isDefined( ulxy ) )
	{
		ulxy = getstruct( "rts_ulxy", "targetname" );
	}
	lrxy = getstruct( "rts_lrxy_missile", "targetname" );
	if ( !isDefined( lrxy ) )
	{
		lrxy = getstruct( "rts_lrxy", "targetname" );
	}
	if ( ulxy.origin[ 0 ] < lrxy.origin[ 0 ] )
	{
	}
	else
	{
	}
	ux = lrxy.origin[ 0 ];
	if ( ulxy.origin[ 0 ] < lrxy.origin[ 0 ] )
	{
	}
	else
	{
	}
	lx = ulxy.origin[ 0 ];
	if ( ulxy.origin[ 1 ] < lrxy.origin[ 1 ] )
	{
	}
	else
	{
	}
	uy = lrxy.origin[ 1 ];
	if ( ulxy.origin[ 1 ] < lrxy.origin[ 1 ] )
	{
	}
	else
	{
	}
	ly = ulxy.origin[ 1 ];
	level.rts.bounds.missile_ulx = ux;
	level.rts.bounds.missile_uly = uy;
	level.rts.bounds.missile_lrx = lx;
	level.rts.bounds.missile_lry = ly;
}

dockside_missile_oob_check( rocketorigin )
{
	x = rocketorigin[ 0 ];
	y = rocketorigin[ 1 ];
	z = rocketorigin[ 2 ];
	if ( x <= level.rts.bounds.missile_ulx )
	{
		return 0;
	}
	else
	{
		if ( x >= level.rts.bounds.missile_lrx )
		{
			return 0;
		}
	}
	if ( y <= level.rts.bounds.missile_uly )
	{
		return 0;
	}
	else
	{
		if ( y >= level.rts.bounds.missile_lry )
		{
			return 0;
		}
	}
	if ( z <= level.rts.bounds.minz )
	{
		return 0;
	}
	return 1;
}

dockside_create_death( loc )
{
	if ( flag( "fps_mode" ) )
	{
		player = level.rts.player;
		distsq = distancesquared( loc, player.origin );
		if ( distsq < 262144 )
		{
			player.blockalldamage = 0;
			if ( isDefined( player.ally.vehicle ) )
			{
				player.ally.vehicle dodamage( 99999, player.ally.vehicle.origin );
				return;
			}
			else
			{
				player dodamage( 99999, player.origin );
			}
		}
	}
}

dockside_missile_deathring()
{
	while ( 1 )
	{
		level waittill( "missile_fired", rocket );
		while ( isDefined( rocket ) )
		{
			deathloc = level.rts.player.missile_sp.origin;
			wait 0,05;
		}
		wait 0,25;
		level thread dockside_create_death( deathloc );
	}
}
