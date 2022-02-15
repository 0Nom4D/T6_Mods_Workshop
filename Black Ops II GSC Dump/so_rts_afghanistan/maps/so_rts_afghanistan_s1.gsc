#include maps/_turret;
#include maps/_horse_rider;
#include animscripts/init;
#include animscripts/utility;
#include animscripts/combat_utility;
#include animscripts/shared;
#include maps/_so_rts_enemy;
#include maps/_so_rts_poi;
#include maps/_glasses;
#include maps/_so_rts_main;
#include maps/createart/so_rts_afghanistan_art;
#include maps/_so_rts_squad;
#include maps/_challenges_sp;
#include maps/_callbackglobal;
#include maps/_so_rts_ai;
#include maps/_debug;
#include maps/_so_rts_rules;
#include maps/_so_rts_catalog;
#include maps/so_rts_afghanistan_s1;
#include maps/_so_rts_event;
#include maps/_music;
#include maps/_audio;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "player" );
#using_animtree( "animated_props" );
#using_animtree( "vehicles" );
#using_animtree( "generic_human" );
#using_animtree( "horse" );

precache()
{
	maps/_metal_storm::init();
	maps/_quadrotor::init();
	maps/_horse::precache_models();
	level._effect[ "ied_death" ] = loadfx( "explosions/fx_exp_equipment" );
	level._effect[ "ied_explode" ] = loadfx( "explosions/fx_exp_bomb_huge" );
	level._effect[ "truck_stall_smoke" ] = loadfx( "env/smoke/fx_grenade_smoke_w" );
	level._effect[ "aircraft_flares" ] = loadfx( "vehicle/vexplosion/fx_heli_chaff_flares" );
	level._effect[ "dmg_trail_hip" ] = loadfx( "fire/fx_vfire_mi8_afgh" );
	level._effect[ "tank_damage" ] = loadfx( "vehicle/vfire/fx_pow_veh_smoke" );
	precacheitem( "rpg_magic_bullet_sp" );
	precacheitem( "rts_missile_sp" );
	precacheitem( "quadrotor_turret_rts_afghan" );
	precachemodel( "p_jun_suicide_rts" );
	precachemodel( "veh_t6_air_v78_vtol" );
	precachemodel( "veh_t6_drone_claw_mk2" );
	precachemodel( "veh_t6_drone_claw_mk2_turret" );
	precachemodel( "veh_t6_drone_claw_viewmodel" );
	precacheshader( "hud_rts_mech_reticle" );
	precachestring( &"SO_RTS_AFGHANISTAN_HAMP_ONLINE" );
	precachestring( &"SO_RTS_AFGHANISTAN_HAMP_ATTACKING" );
	precachestring( &"SO_RTS_AFGHANISTAN_HAMP_OFFLINE" );
	precachestring( &"SO_RTS_AFGHANISTAN_HAMP_ABORT" );
	precachestring( &"SO_RTS_AFGHANISTAN_OBJ_ESCORT" );
	precachestring( &"heli_quadrotor_rts" );
	precachestring( &"hud_update_vehicle_custom" );
	precachestring( &"drone_claw_rts" );
	flag_init( "rts_tank_moving" );
	flag_init( "rts_convoy_go" );
	flag_init( "rts_horse_charge" );
	flag_init( "rts_afghan_outro" );
	flag_init( "rts_afghan_fail" );
	flag_init( "rts_allow_last_vehicle_explode" );
	flag_init( "innocuous_ieds" );
	setsaveddvar( "vehHelicopterTiltFromViewangles", "5.0" );
	setsaveddvar( "vehicle_selfCollision", "0" );
}

intro_threat_rockets()
{
	sources = getstructarray( "intro_rocket_source", "targetname" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	convoy_members = array_copy( convoy.members );
	while ( sources.size > 0 && convoy_members.size > 0 )
	{
		source = random( sources );
		arrayremovevalue( sources, source );
		target = random( convoy_members );
		arrayremovevalue( convoy_members, target );
		target endon( "death" );
		offset = ( 0, 0, randomfloatrange( 250, 350 ) );
		magicbullet( "rpg_magic_bullet_sp", source.origin, target.origin + offset );
		maps/_so_rts_event::trigger_event( "dlg_intro_rpg_fire" );
		wait randomfloatrange( 1, 3 );
	}
}

afghanistan_level_scenario_one()
{
	level.custom_introscreen = ::afghanistan_custom_introscreen;
	level.rts.endlocs_route1 = getentarray( "rts_vtol_transport_loc1", "targetname" );
	level.rts.iedlocs = getentarray( "ied_location", "targetname" );
	level.rts.custom_ai_getgrenadecb = ::afghan_aigrenadeget;
	level.custom_mission_complete = ::afghanistan_mission_complete_s1;
	level.rts.spawn = spawnstruct();
	level.rts.spawn.horselocs = getentarray( "ai_horse_spawn_loc", "targetname" );
	level.rts.spawn.enemyrpglocs = getentarray( "rpg", "script_noteworthy" );
	level.rts.spawn.enemylocs = [];
	enemylocs = getentarray( "ai_ied_spawn_loc", "targetname" );
	_a130 = enemylocs;
	_k130 = getFirstArrayKey( _a130 );
	while ( isDefined( _k130 ) )
	{
		loc = _a130[ _k130 ];
		if ( isDefined( loc.script_noteworthy ) && loc.script_noteworthy == "rpg" )
		{
		}
		else
		{
			level.rts.spawn.enemylocs[ level.rts.spawn.enemylocs.size ] = loc;
		}
		_k130 = getNextArrayKey( _a130, _k130 );
	}
	level.debug = 0;
/#
	level.debug = 1;
#/
	level.rts.spawn.activeenemylocs = [];
	level.rts.spawn.activerpglocs = [];
	level.rts.spawn.activehorselocs = [];
	level thread afghanistan_spawnlocthink();
/#
	afghan_setup_devgui();
#/
	maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_enemy_ied_pkg", "axis", 0 );
	maps/_so_rts_catalog::setpkgqty( "infantry_afghan_rpg_pkg", "axis", 0 );
	maps/_so_rts_catalog::setpkgqty( "horse_enemy_pkg", "axis", -1 );
	createthreatbiasgroup( "convoy_pkg" );
	createthreatbiasgroup( "infantry_enemy_reg_pkg" );
	createthreatbiasgroup( "infantry_enemy_ied_pkg" );
	createthreatbiasgroup( "infantry_afghan_rpg_pkg" );
	createthreatbiasgroup( "quadrotors" );
	createthreatbiasgroup( "tanks" );
	createthreatbiasgroup( "helis" );
	createthreatbiasgroup( "rts_player" );
	createthreatbiasgroup( "asds" );
	setthreatbias( "convoy_pkg", "infantry_enemy_reg_pkg", -80000 );
	setthreatbias( "convoy_pkg", "infantry_enemy_ied_pkg", -80000 );
	setthreatbias( "convoy_pkg", "infantry_afghan_rpg_pkg", 10000 );
	setthreatbias( "tanks", "quadrotors", -80000 );
	setthreatbias( "quadrotors", "tanks", -80000 );
	setthreatbias( "rts_player", "tanks", 8000 );
	setthreatbias( "rts_player", "infantry_enemy_reg_pkg", 10000 );
	setthreatbias( "rts_player", "infantry_afghan_rpg_pkg", 9000 );
	setthreatbias( "rts_player", "helis", 10000 );
	setthreatbias( "convoy_pkg", "helis", 9000 );
	setthreatbias( "quadrotors", "helis", 9000 );
	setthreatbias( "asds", "helis", 9000 );
	setthreatbias( "helis", "asds", 0 );
	level thread afghanistan_rpg_onoff();
	level thread afghanistan_convoytriggers();
	level thread afghanistan_convoy_speedcap_triggers();
	level thread afghanistan_convoy_watch_speed();
	level thread afghanistan_hind_spawning();
	level thread afghanistan_ant_spawnwatch();
	level thread afghanistan_ied_onoff();
	level thread afghanistan_horse_onoff();
	maps/_lockonmissileturret::init( 0, undefined, 1, 1 );
	maps/_so_rts_rules::set_gamemode( "afghanistan1" );
	flag_wait( "start_rts" );
	level.rts.closestunitparams.allowplayerteampip = 1;
	level thread sonar_keep_on();
	level.player setthreatbiasgroup( "rts_player" );
	level.quadrotor_forcegoal_if_closer = 1;
	level.rts.enemy_think_wait = 0,1;
	afghanistan_level_scenario_one_registerevents();
	afghanistan_geo_changes();
	level.rts.codespawncb = ::afghanistancodespawner;
	level.rts.game_rules.num_nag_squads = 99;
	level thread setup_objectives();
	level.player thread setup_challenges();
	level thread duststorm_local_drone();
	add_spawn_function_veh_by_type( "horse", ::dead_horse_cleanup );
	add_spawn_function_veh_by_type( "horse", ::horse_auto_kill_watch );
/#
	level thread monitor_vehicle_counts();
#/
	exploder( 700 );
	fxanim_bridges();
	maps/_so_rts_catalog::package_select( "convoy_pkg", 1 );
	maps/_so_rts_catalog::package_select( "quadrotor_pkg", 1, ::afghanistan_level_player_startfps );
	level waittill( "intro_go" );
	setmusicstate( "AFGHANISTAN_ACTION" );
	scene_wait( "intro_convoy" );
	level thread ied_initialspawns();
	level thread intro_threat_rockets();
	squad = getsquadbypkg( "quadrotor_pkg", "allies" );
	squad.package_commandunitfps_cb = ::additional_targetselection;
	squad = getsquadbypkg( "quadrotor2_pkg", "allies" );
	squad.package_commandunitfps_cb = ::additional_targetselection;
	squad = getsquadbypkg( "metalstorm_pkg", "allies" );
	squad.package_commandunitfps_cb = ::additional_targetselection;
	level.player resetfov();
	level thread afghanistan_handofnodwatcher();
	flag_wait( "rts_afghan_outro" );
	flag_clear( "rts_enemy_squad_spawner_enabled" );
	maps/_so_rts_rules::mission_complete( 1 );
}

afghan_aigrenadeget( team )
{
	roll = randomint( 100 );
	if ( team == "axis" )
	{
		if ( roll > 90 )
		{
			return "frag_grenade_sp";
		}
		else
		{
			if ( roll > 80 )
			{
				return "willy_pete_sp";
			}
			else
			{
				return undefined;
			}
		}
	}
	return "";
}

additional_targetselection( trace )
{
	if ( !isDefined( trace[ "entity" ] ) )
	{
		tracepoint = trace[ "position" ];
		ieds = getentarray( "ied", "script_noteworthy" );
		ieds = sortarraybyclosest( tracepoint, ieds, 9216 );
		if ( ieds.size > 0 )
		{
			level.rts.targetteamenemy = ieds[ 0 ];
		}
	}
}

ied_getiedmodel()
{
	return "p_jun_suicide_rts";
}

ied_initialspawns()
{
	level.rts.iedlocs = array_randomize( level.rts.iedlocs );
	ieds_to_spawn = getentarray( "ied_start_spawned", "script_noteworthy" );
	_a300 = ieds_to_spawn;
	_k300 = getFirstArrayKey( _a300 );
	while ( isDefined( _k300 ) )
	{
		loc = _a300[ _k300 ];
		arrayremovevalue( level.rts.iedlocs, loc, 0 );
		ied = spawn( "script_model", loc.origin + vectorScale( ( 0, 0, 1 ), 4 ) );
		ied setmodel( ied_getiedmodel() );
		ied ignorecheapentityflag( 1 );
		ied.script_noteworthy = "ied";
		ied.team = "axis";
		ied.pkg_ref = package_getpackagebytype( "ied_pkg" );
		ied thread afghan_iedthink();
		_k300 = getNextArrayKey( _a300, _k300 );
	}
	wait 20;
	maps/_so_rts_event::trigger_event( "dlg_intro_ieds" );
}

duststorm_local_drone()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		level waittill( "taken_control_over", unit );
		unit maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 3 ) + 0 );
	}
}

sonar_keep_on()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		wait 0,05;
		rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 1, 1 );
		level waittill( "eye_in_the_sky" );
		wait 0,05;
		rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 0, 0 );
		level waittill( "rts_OFF" );
	}
}

fov_set( guy, note )
{
	if ( issubstr( note, "fov_" ) )
	{
		tokens = strtok( note, "_" );
/#
		assert( tokens.size >= 2 );
#/
		if ( tokens[ 1 ] == "reset" )
		{
			if ( tokens.size > 2 )
			{
				lerp_time = float( tokens[ 2 ] );
				level.rts.player thread lerp_fov_overtime( lerp_time, getDvarFloat( "cg_fov_default" ), 1 );
			}
			else
			{
				level.rts.player resetfov();
			}
			return;
		}
		else
		{
			if ( tokens.size == 2 )
			{
				level.rts.player setclientdvar( "cg_fov", tokens[ 1 ] );
			}
			if ( tokens.size == 3 )
			{
				lerp_time = float( tokens[ 2 ] );
				level.rts.player thread lerp_fov_overtime( lerp_time, tokens[ 1 ], 1 );
			}
		}
	}
}

create_anim_model( pos, model_name, animname )
{
	model = spawn( "script_model", pos );
	model setmodel( model_name );
	model.animname = animname;
	model hide();
	return model;
}

create_player_model( pos, model_name, animname )
{
	model = create_anim_model( pos, model_name, animname );
	model useanimtree( -1 );
	return model;
}

create_prop_model( pos, model_name, animname )
{
	model = create_anim_model( pos, model_name, animname );
	model useanimtree( -1 );
	return model;
}

create_veh_model( pos, model_name, animname )
{
	model = create_anim_model( pos, model_name, animname );
	model useanimtree( -1 );
	return model;
}

convoy_flag_go( guy, note )
{
	flag_set( "rts_convoy_go" );
}

intro_quad_on( quad )
{
	intro_quad_showfps( 1 );
}

intro_quad_off( quad )
{
	intro_quad_showfps( 0 );
}

intro_quad_heavydmg( quad )
{
	level.player playrumbleonentity( "anim_heavy" );
	rpc( "clientscripts/_vehicle", "damage_filter_heavy" );
}

intro_quad_fire( body )
{
	self endon( "death" );
	level.rts.intro_quad thread fire_turret_for_time( 1, 0 );
	i = 0;
	while ( i < 4 )
	{
		wait 0,1;
		level.player playrumbleonentity( "damage_light" );
		i++;
	}
}

intro_quad_showfps( on )
{
	if ( on )
	{
		rpc( "clientscripts/so_rts_afghanistan_amb", "set_intro_gfutz" );
		rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 1, 1 );
		if ( !isDefined( level.rts.intro_quad.first ) )
		{
			rpc( "clientscripts/_vehicle", "init_damage_filter", 0 );
			level.rts.intro_quad.first = 1;
		}
		else
		{
			rpc( "clientscripts/_vehicle", "damage_filter_light" );
		}
		level.rts.player linkto( level.rts.intro_quad, "tag_player", ( 9,3, 0, -68,8 ) );
		level.rts.intro_quad show();
		level.rts.intro_quad hidepart( "tag_turret" );
		level.rts.intro_quad hidepart( "body_animate_jnt" );
		level.rts.intro_quad hidepart( "tag_flaps" );
		level.rts.intro_quad hidepart( "tag_ammo_case" );
		level.rts.intro_quad showpart( "tag_viewmodel" );
		luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"heli_quadrotor_rts" );
		rpc( "clientscripts/_vehicle", "damage_filter_enable", 0, 0 );
	}
	else
	{
		rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 0, 0 );
		level.rts.intro_quad show();
		level.rts.intro_quad showpart( "tag_turret" );
		level.rts.intro_quad showpart( "body_animate_jnt" );
		level.rts.intro_quad showpart( "tag_flaps" );
		level.rts.intro_quad showpart( "tag_ammo_case" );
		level.rts.intro_quad hidepart( "tag_viewmodel" );
		luinotifyevent( &"hud_update_vehicle_custom", 1, 0 );
		rpc( "clientscripts/_vehicle", "damage_filter_disable" );
		rpc( "clientscripts/_vehicle", "damage_filter_off" );
	}
}

watch_intro_rocket()
{
	self.shoot_notify = "rpg_fired";
	self waittill( "rpg_fired", rocket );
	rocket endon( "death" );
	prev_dist = distance2dsquared( rocket.origin, level.player.origin );
	wait_network_frame();
	rocket kill();
}

intro_ai_fire( guy )
{
	guy endon( "death" );
	muzzlepoint = guy getweaponmuzzlepoint();
	rocket = magicbullet( "rpg_magic_bullet_sp", muzzlepoint, level.player.origin + ( anglesToForward( level.player.angles ) * 512 ) );
	rocket endon( "death" );
	wait_network_frame();
	dist_to_player = distancesquared( level.player.origin, rocket.origin );
	rocket resetmissiledetonationtime( 0 );
}

intro_ai_start( guy )
{
	guy endon( "death" );
	guy thread watch_intro_rocket();
	guy allowedstances( "prone", "crouch" );
	guy.ignoreme = 1;
	guy maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 0 );
	scene_wait( "intro_convoy" );
	guy.ignoreme = 0;
}

intro_ai_scopeup( guy )
{
	level.player setclientdvar( "cg_drawBreathHint", 0 );
	level.rts.player enableweapons();
	level.rts.player setforceads( 1 );
	level.rts.player showviewmodel();
}

intro_ai_scopedown( guy )
{
	level.rts.player hideviewmodel();
	level.rts.player disableweapons();
	level.rts.player setforceads( 0 );
	wait 0,1;
	level.player setclientdvar( "cg_drawBreathHint", 1 );
}

afghan_fade_out( pluhr )
{
	level notify( "outro_fading" );
	screen_fade_out( 1 );
}

run_turret_fx( stop_notify )
{
	self endon( stop_notify );
	self thread ally_turret_sound( stop_notify );
	while ( 1 )
	{
		self play_fx( "fx_outro_muzzle_flash", ( 0, 0, 1 ), ( 0, 0, 1 ), undefined, 1, "tag_flash" );
		wait 0,3;
	}
}

ally_turret_sound( stop_notify )
{
	snd_ent = spawn( "script_origin", self.origin );
	snd_ent playloopsound( "wpn_bigdog_turret_fire_loop_npc", 0,1 );
	self waittill( stop_notify );
	snd_ent stoploopsound( 0,1 );
	snd_ent playsound( "wpn_bigdog_turret_fire_loop_ring_npc" );
}

afghan_outro_turret_run( claw_turret )
{
	e_target = getent( "outro_aim_target", "targetname" );
	player_target = getent( "outro_aim_target", "targetname" );
	level waittill( "outro_claws_fire" );
	claw_turret thread run_turret_fx( "stop_fx" );
	while ( !flag( "afghan_outro_done" ) )
	{
		barrel_origin = claw_turret gettagorigin( "tag_barrel" );
		barrel_fwd = barrel_origin + ( anglesToForward( claw_turret gettagangles( "tag_barrel" ) ) * 1000 );
		magicbullet( "bigdog_dual_turret_player", barrel_origin, barrel_fwd, level.rts.player );
		level.player playrumbleonentity( "damage_light" );
		wait_network_frame();
	}
	claw_turret notify( "stop_fx" );
}

callback_horse_hit_ground( horse )
{
	horse notify( "kill_dust" );
	horse play_fx( "fx_horse_dust", ( 0, 0, 1 ), ( 0, 0, 1 ), undefined, 1, "Bone_H_Shoulder_R" );
}

callback_horse_blood( horse )
{
	blood_tags = array( "J_Stirrup_1_RI", "J_Stirrup_2_RI", "J_Stirrup_3_RI" );
	tag = random( blood_tags );
	horse play_fx( "fx_horse_blood", ( 0, 0, 1 ), ( 0, 0, 1 ), undefined, 1, tag );
}

setup_scenes()
{
	add_scene( "intro_convoy", "SO_sniper_position_1" );
	add_player_anim( "player_body", %p_afghan_intro_player, 0, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	add_notetrack_custom_function( "player_body", "any", ::fov_set, undefined, 1 );
	add_notetrack_custom_function( "player_body", "sustain_damage", ::intro_quad_heavydmg );
	add_notetrack_custom_function( "player_body", "fire", ::intro_quad_fire );
	add_notetrack_custom_function( "player_body", "sndPlayLoop", ::sndplayloop );
	add_notetrack_custom_function( "player_body", "sndStopLoop", ::sndstoploop );
	add_actor_anim( "intro_sniper_1", %ch_afghan_intro_sniper1, 0, 0, 1, 1 );
	add_notetrack_custom_function( "intro_sniper_1", "start", ::intro_ai_start );
	add_notetrack_custom_function( "intro_sniper_1", "fire_rpg", ::intro_ai_fire );
	add_actor_anim( "intro_sniper_2", %ch_afghan_intro_sniper2, 0, 0, 1, 1 );
	add_notetrack_custom_function( "intro_sniper_2", "start", ::intro_ai_start );
	add_notetrack_custom_function( "intro_sniper_2", "start_convoy", ::convoy_flag_go );
	add_notetrack_custom_function( "intro_sniper_2", "fade_up", ::level_fade_in );
	add_notetrack_custom_function( "intro_sniper_2", "scope_overlay_on", ::intro_ai_scopeup );
	add_notetrack_custom_function( "intro_sniper_2", "scope_overlay_off", ::intro_ai_scopedown );
	add_notetrack_custom_function( "intro_sniper_2", "fire_rpg", ::intro_ai_fire );
	add_vehicle_anim( "intro_quad", %v_afghan_intro_quad );
	add_vehicle_anim( "intro_quad2", %v_afghan_intro_quad2 );
	add_vehicle_anim( "intro_quad3", %v_afghan_intro_quad3 );
	add_vehicle_anim( "intro_quad4", %v_afghan_intro_quad4 );
	add_scene( "fail_camera", "rts_outro" );
	add_player_anim( "player_body", %p_afghan_fail_camera );
	add_scene( "afghan_outro", "rts_outro" );
	add_player_anim( "player_body", %p_afghan_outroplayer, 0, 0, undefined, 0, 1, undefined, undefined, undefined, undefined, undefined, undefined, 0 );
	add_prop_anim( "outro_claw_ally", %v_afghan_outro_claw2 );
	add_prop_anim( "outro_claw2_turret", %v_afghan_outro_claw2_turret );
	add_prop_anim( "outro_claw_turret", %v_afghan_outro_claw_turret );
	add_vehicle_anim( "outro_claw1", %v_afghan_outro_claw );
	add_vehicle_anim( "outro_cougar", %w_afghan_outro_convoy1 );
	add_vehicle_anim( "outro_vtol1", %v_afghan_outro_vtol1 );
	add_vehicle_anim( "outro_vtol2", %v_afghan_outro_vtol2 );
	add_notetrack_custom_function( "outro_claw_ally", "fire", ::play_outro_claw_exploder );
	add_notetrack_level_notify( "outro_claw_ally", "fire", "outro_claws_fire" );
	add_notetrack_custom_function( "outro_claw2_turret", "start", ::afghan_outro_turret_run );
	add_notetrack_custom_function( "player_body", "fade_out", ::afghan_fade_out );
	add_scene( "afghan_outro_riders", "rts_outro" );
	add_horse_anim( "outro_horse1", %ch_afghan_outro_horse1 );
	add_horse_anim( "outro_horse2", %ch_afghan_outro_horse2 );
	add_horse_anim( "outro_horse3", %ch_afghan_outro_horse3 );
	add_horse_anim( "outro_horse4", %ch_afghan_outro_horse4 );
	add_horse_anim( "outro_horse5", %ch_afghan_outro_horse5 );
	add_horse_anim( "outro_horse6", %ch_afghan_outro_horse6 );
	add_horse_anim( "outro_horse7", %ch_afghan_outro_horse7 );
	add_horse_anim( "outro_horse8", %ch_afghan_outro_horse8 );
	add_horse_anim( "outro_horse9", %ch_afghan_outro_horse9 );
	add_horse_anim( "outro_horse10", %ch_afghan_outro_horse10 );
	add_horse_anim( "outro_horse11", %ch_afghan_outro_horse11 );
	add_horse_anim( "outro_horse12", %ch_afghan_outro_horse12 );
	add_horse_anim( "outro_horse13", %ch_afghan_outro_horse13 );
	add_horse_anim( "outro_horse14", %ch_afghan_outro_horse14 );
	level.num_outro_horses = 14;
	i = 1;
	while ( i <= level.num_outro_horses )
	{
		add_notetrack_custom_function( "outro_horse" + i, "hit", ::callback_horse_blood );
		add_notetrack_custom_function( "outro_horse" + i, "hit_ground", ::callback_horse_hit_ground );
		i++;
	}
	add_actor_anim( "outro_rider1", %ch_afghan_outro_rider1, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider2", %ch_afghan_outro_rider2, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider3", %ch_afghan_outro_rider3, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider4", %ch_afghan_outro_rider4, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider5", %ch_afghan_outro_rider5, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider6", %ch_afghan_outro_rider6, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider7", %ch_afghan_outro_rider7, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider8", %ch_afghan_outro_rider8, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider9", %ch_afghan_outro_rider9, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider10", %ch_afghan_outro_rider10, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider11", %ch_afghan_outro_rider11, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider12", %ch_afghan_outro_rider12, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider13", %ch_afghan_outro_rider13, 0, 1, 0, 1, undefined, "outro_rider" );
	add_actor_anim( "outro_rider14", %ch_afghan_outro_rider14, 0, 1, 0, 1, undefined, "outro_rider" );
	add_scene( "rts_celebrating_muj", undefined, 0, 1, 1, 1 );
	add_multiple_generic_actors( "generic", %ch_af_05_01_victory_muhaj_cheering );
	precache_assets();
}

fire_vehicle_until_notify( notify_name )
{
	level endon( notify_name );
	while ( 1 )
	{
		num_shots = randomintrange( 20, 25 );
		i = 0;
		while ( i < num_shots )
		{
			self fireweapon();
			wait 0,05;
			i++;
		}
		wait randomfloatrange( 0,2, 0,4 );
	}
}

player_turret_fire()
{
	wait 3;
	self thread turret_barrel_snd();
	self setturretspinning( 1 );
/#
	println( "Afghanistan Outro: spinning up turret" );
#/
	level waittill( "outro_claws_fire" );
	self thread turret_fire_snd();
/#
	println( "Afghanistan Outro: firing turret" );
#/
	self fire_turret_for_time( 6, 0 );
}

turret_fire_snd()
{
	sound_ent2 = spawn( "script_origin", self.origin );
	sound_ent2 playloopsound( "wpn_bigdog_fire_loop_plr", 0,1 );
	wait 6;
	sound_ent2 stoploopsound( 0,1 );
	sound_ent2 playsound( "wpn_bigdog_fire_loop_ring_plr" );
}

turret_barrel_snd()
{
	sound_ent = spawn( "script_origin", self.origin );
	sound_ent playsound( "wpn_bigdog_start_plr" );
	wait 0,6;
	sound_ent playloopsound( "wpn_bigdog_barrel_loop_plr", 0,1 );
	wait 9;
	sound_ent stoploopsound( 1 );
	sound_ent playsound( "wpn_bigdog_stop_plr" );
}

player_target_move()
{
	outro_player_claw = getent( "outro_claw1", "targetname" );
	outro_player_claw thread player_turret_fire();
	original_pos = self.origin;
	rvec = anglesToRight( self.angles );
	claw_turret = level.dummy_turret;
	claw_turret endon( "death" );
/#
	self thread maps/_debug::draworgforever();
#/
	while ( 1 )
	{
		fvec = anglesToForward( level.rts.player getplayerangles() );
		self.origin = level.rts.player.origin + ( fvec * 2000 ) + vectorScale( ( 0, 0, 1 ), 128 );
		wait 0,05;
	}
}

afghanistan_outro()
{
	level.rts.player set_ignoreme( 1 );
	maps/_so_rts_event::event_clearall( 0 );
	maps/_so_rts_event::trigger_event( "dlg_mission_success" );
	flag_clear( "rts_event_ready" );
	flag_clear( "rts_hud_on" );
	flag_set( "block_input" );
	level.rts.player freezecontrols( 1 );
	maps/_so_rts_support::hide_player_hud();
	level.rts.player enableinvulnerability();
	enemies = getaiarray( "axis" );
	_a814 = enemies;
	_k814 = getFirstArrayKey( _a814 );
	while ( isDefined( _k814 ) )
	{
		enemy = _a814[ _k814 ];
		enemy dodamage( enemy.health * 2, enemy.origin );
		_k814 = getNextArrayKey( _a814, _k814 );
	}
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	_a826 = convoy.members;
	_k826 = getFirstArrayKey( _a826 );
	while ( isDefined( _k826 ) )
	{
		member = _a826[ _k826 ];
		member veh_magic_bullet_shield( 1 );
		_k826 = getNextArrayKey( _a826, _k826 );
	}
	level.rts.player magic_bullet_shield();
	outro_claw2 = create_prop_model( level.rts.player.origin, "veh_t6_drone_claw_mk2", "outro_claw_ally" );
	outro_claw2.m_turret = create_prop_model( level.rts.player.origin, "veh_t6_drone_claw_mk2_turret", "outro_claw2_turret" );
	level.dummy_turret = create_prop_model( level.rts.player.origin, "veh_t6_drone_claw_mk2_turret", "outro_claw_turret" );
	outro_claw2 show();
	outro_claw2.m_turret show();
	level.dummy_turret hide();
	dudes = getaiarray( "axis" );
	_a846 = dudes;
	_k846 = getFirstArrayKey( _a846 );
	while ( isDefined( _k846 ) )
	{
		dude = _a846[ _k846 ];
		dude delete();
		_k846 = getNextArrayKey( _a846, _k846 );
	}
	level.rts.player maps/_so_rts_ai::restorereplacement();
	level thread run_scene( "afghan_outro_riders" );
	level thread run_scene( "afghan_outro" );
	flag_wait( "afghan_outro_started" );
	flag_wait( "afghan_outro_riders_started" );
	level notify( "check_for_convoy_success" );
	riders = get_ais_from_scene( "afghan_outro_riders" );
	_a863 = riders;
	_k863 = getFirstArrayKey( _a863 );
	while ( isDefined( _k863 ) )
	{
		rider = _a863[ _k863 ];
		rider maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 0 );
		_k863 = getNextArrayKey( _a863, _k863 );
	}
	i = 1;
	while ( i <= level.num_outro_horses )
	{
		horse = getent( "outro_horse" + i, "targetname" );
		if ( isDefined( horse ) )
		{
			horse setcandamage( 0 );
			horse maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 0 );
			horse play_fx( "outro_horse_dust_01", horse.origin, horse.angles, "kill_dust", 1, "tag_origin" );
		}
		i++;
	}
	outro_player_claw = getent( "outro_claw1", "targetname" );
	wait_network_frame();
	luinotifyevent( &"hud_update_vehicle_custom", 2, 1, &"drone_claw_rts" );
	rpc( "clientscripts/_vehicle", "damage_filter_enable", 0, 0 );
	rpc( "clientscripts/so_rts_afghanistan_amb", "set_outro_gfutz" );
	rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 1, 1 );
	player_target = getent( "outro_aim_target", "targetname" );
	player_target thread player_target_move();
	angles_to_target = vectorToAngle( vectornormalize( player_target.origin - outro_player_claw.origin ) );
	outro_player_claw settargetentity( player_target );
	outro_player_claw setturrettargetent( player_target );
	wait 0,5;
	screen_fade_in( 0,5 );
	reticle = newhudelem();
	reticle.aligny = "middle";
	reticle.alignx = "center";
	reticle.horzalign = "center";
	reticle.vertalign = "middle";
	reticle setshader( "hud_rts_mech_reticle", 32, 32 );
	level waittill( "outro_fading" );
	reticle.alpha = 0;
	scene_wait( "afghan_outro" );
	luinotifyevent( &"hud_update_vehicle_custom", 1, 0 );
}

play_outro_claw_exploder( guy )
{
	if ( isDefined( level.outro_claw_exploder ) && level.outro_claw_exploder )
	{
		return;
	}
	level.outro_claw_exploder = 1;
	exploder( 432 );
}

level_fade_in( player )
{
	if ( !isDefined( player ) )
	{
		player = level.rts.player;
	}
	thread screen_fade_in( 0,5 );
}

is_quadrotor( ent )
{
	if ( !isDefined( ent.vehicletype ) )
	{
		return 0;
	}
	return issubstr( ent.vehicletype, "quad" );
}

outro_rocket()
{
	self waittill( "death" );
	level.rts.player playrumbleonentity( "anim_med" );
}

scene_afghanistan_fail_animated()
{
	screen_fade_out( 1 );
	last_cougar = undefined;
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	_a953 = convoy.members;
	_k953 = getFirstArrayKey( _a953 );
	while ( isDefined( _k953 ) )
	{
		member = _a953[ _k953 ];
		if ( isalive( member ) )
		{
			last_cougar = member;
		}
		_k953 = getNextArrayKey( _a953, _k953 );
	}
	convoy.top_speed = 10;
/#
	assert( isDefined( last_cougar ) );
#/
	vnode = getvehiclenode( "failure_cougar_path", "targetname" );
	last_cougar setbrake( 0 );
	last_cougar.origin = vnode.origin;
	last_cougar.angles = vnode.angles;
	last_cougar thread go_path( vnode );
	level.rts.player thread maps/_so_rts_ai::restorereplacement();
	level.rts.player unlink();
	level.rts.player hideviewmodel();
	rpc( "clientscripts/so_rts_afghanistan_amb", "clear_fail_gfutz" );
	run_scene_first_frame( "fail_camera" );
	wait 1;
	screen_fade_in( 1 );
	level thread run_scene( "fail_camera" );
	last_cougar veh_magic_bullet_shield( 1 );
	level.player magic_bullet_shield();
	rocket = undefined;
	rocket_source = getstruct( "fail_rpg_source", "targetname" );
	wait 1;
	i = 0;
	while ( i < 3 )
	{
		wait randomfloatrange( 0,2, 0,5 );
		rocket = magicbullet( "rpg_magic_bullet_sp", rocket_source.origin + ( 0, 0, randomfloatrange( -50, 50 ) ), last_cougar.origin );
		rocket thread outro_rocket();
		i++;
	}
	rocket waittill( "death" );
	last_cougar play_fx( "fx_fail_explosion", ( 0, 0, 1 ), ( 0, 0, 1 ), undefined, 1, "tag_origin" );
	level.rts.player playrumbleonentity( "anim_heavy" );
	level.rts.player shellshock( "death", 3 );
	flag_set( "rts_allow_last_vehicle_explode" );
	last_cougar veh_magic_bullet_shield( 0 );
	last_cougar dodamage( last_cougar.health * 2, last_cougar.origin );
	scene_wait( "fail_camera" );
}

scene_afghanistan_fail()
{
	last_cougar = undefined;
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	_a1015 = convoy.members;
	_k1015 = getFirstArrayKey( _a1015 );
	while ( isDefined( _k1015 ) )
	{
		member = _a1015[ _k1015 ];
		if ( isalive( member ) )
		{
			last_cougar = member;
		}
		_k1015 = getNextArrayKey( _a1015, _k1015 );
	}
/#
	assert( isDefined( last_cougar ) );
#/
	level.rts.player thread maps/_so_rts_ai::restorereplacement();
	level.rts.player unlink();
	level.rts.player freezecontrols( 1 );
	view_location = last_cougar.origin + ( anglesToForward( last_cougar.angles ) * 1000 ) + vectorScale( ( 0, 0, 1 ), 500 );
	view_angles = vectorToAngle( vectornormalize( last_cougar.origin - view_location ) );
	view_location_ent = spawn_model( "tag_origin", view_location, view_angles );
	view_location_ent linkto( last_cougar );
	level.rts.player setorigin( view_location );
	level.rts.player setplayerangles( view_angles );
	level.rts.player playerlinktoabsolute( view_location_ent, "tag_origin" );
	level.rts.player hideviewmodel();
	wait 2;
	rocket = magicbullet( "rpg_magic_bullet_sp", view_location_ent.origin - vectorScale( ( 0, 0, 1 ), 100 ), last_cougar.origin );
	rocket waittill( "death" );
	level.rts.player playrumbleonentity( "anim_heavy" );
	level.rts.player shellshock( "death", 3 );
	view_location_ent unlink();
	flag_set( "rts_allow_last_vehicle_explode" );
	last_cougar dodamage( 10000, last_cougar.origin );
	wait 3;
	level.rts.player freezecontrols( 0 );
}

report_global_vehicle_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname )
{
	if ( self.vehicletype == "heli_quadrotor_rts_player" && smeansofdeath == "MOD_CRUSH" && isDefined( einflictor ) )
	{
		if ( !isDefined( einflictor.team ) || !isDefined( self.team ) && isDefined( einflictor.team ) && isDefined( self.team ) && einflictor.team == self.team )
		{
			return;
		}
	}
	if ( self.vehicletype == "horse" && isplayer( eattacker ) && is_quadrotor( einflictor ) )
	{
		smeansofdeath = "MOD_RIFLE_BULLET";
	}
	else
	{
		if ( issubstr( self.vehicletype, "cougar" ) )
		{
			if ( idamage >= self.health )
			{
				convoy = getsquadbypkg( "convoy_pkg", "allies" );
				if ( convoy.members.size == 1 )
				{
					if ( !flag( "rts_afghan_fail" ) )
					{
						flag_set( "rts_afghan_fail" );
						flag_set( "block_input" );
						level thread maps/_so_rts_rules::mission_complete( 0 );
					}
					if ( !flag( "rts_allow_last_vehicle_explode" ) )
					{
						return;
					}
				}
			}
		}
	}
	if ( self.vehicletype == "horse" && isDefined( self.attachedguys ) && isalive( self.attachedguys[ 0 ] ) && isplayer( eattacker ) )
	{
		maps/_so_rts_challenges::process_challenge_kill_riders( self.attachedguys[ 0 ], idamage );
		maps/_so_rts_challenges::process_challenge_quad_kills( self.attachedguys[ 0 ], idamage );
	}
	maps/_callbackglobal::callback_vehicledamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname );
}

global_actor_killed_challenges_callback( e_inflictor, e_attacker, n_damage, str_means_of_death, str_weapon, v_dir, str_hit_loc, timeoffset )
{
	if ( !isDefined( e_attacker ) )
	{
		e_attacker = self.attacker;
	}
	else
	{
		if ( e_attacker.classname == "worldspawn" )
		{
			e_attacker = self.attacker;
		}
	}
	if ( isplayer( e_attacker ) )
	{
		if ( self.team == "axis" )
		{
			level notify( "player_kill" );
		}
	}
}

watch_tank_death()
{
	if ( self.team != "axis" )
	{
		return;
	}
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( flag( "rts_afghan_outro" ) )
	{
		return;
	}
	if ( isplayer( attacker ) || !isDefined( weapon ) || !isDefined( "rts_missile_sp" ) && isDefined( weapon ) && isDefined( "rts_missile_sp" ) && weapon == "rts_missile_sp" )
	{
		level notify( "player_killed_tank" );
	}
}

watch_helo_death()
{
	if ( self.team != "axis" )
	{
		return;
	}
	self waittill( "death", attacker, param2, weapon, v_loc, v_dir, dmg_type, param7, param8, param9 );
	if ( flag( "rts_afghan_outro" ) )
	{
		return;
	}
	if ( isplayer( attacker ) || !isDefined( weapon ) || !isDefined( "rts_missile_sp" ) && isDefined( weapon ) && isDefined( "rts_missile_sp" ) && weapon == "rts_missile_sp" )
	{
		level notify( "player_killed_helo" );
	}
}

run_cow_catcher( real_cougar )
{
	fvec = anglesToForward( real_cougar.angles );
	self.origin = real_cougar.origin + ( fvec * 300 );
	self linkto( real_cougar );
	self notsolid();
	while ( isalive( real_cougar ) )
	{
		self disconnectpaths();
		wait 2;
	}
	self delete();
}

run_allied_cougar()
{
	self endon( "death" );
	wait 2;
	cow_catchers = getentarray( "rts_cougar_cow_catcher", "targetname" );
	_a1179 = cow_catchers;
	_k1179 = getFirstArrayKey( _a1179 );
	while ( isDefined( _k1179 ) )
	{
		catcher = _a1179[ _k1179 ];
		if ( !is_true( catcher.catcher_being_used ) )
		{
			catcher.catcher_being_used = 1;
			catcher thread run_cow_catcher( self );
			break;
		}
		else
		{
			_k1179 = getNextArrayKey( _a1179, _k1179 );
		}
	}
	while ( 1 )
	{
		wait 2;
		self disconnectpaths();
	}
}

setup_challenges()
{
	self thread maps/_so_rts_support::track_unit_type_usage();
	add_spawn_function_veh_by_type( "tank_t72_rts", ::watch_tank_death );
	add_spawn_function_veh_by_type( "heli_hind_afghan_rts", ::watch_helo_death );
	add_spawn_function_veh_by_type( "apc_cougar_rts", ::run_allied_cougar );
	level.callbackactorkilled = ::maps/_so_rts_challenges::global_actor_killed_challenges_callback;
	level.callbackvehicledamage = ::report_global_vehicle_damage;
	level.rts.kill_stats = spawnstruct();
	level.rts.kill_stats.total_kills = 0;
	level.rts.kill_stats.asd_rundown_kills = 0;
	level.rts.kill_stats.kill_riders = 0;
	level.rts.kill_stats.quad_kills = 0;
	level.rts.kill_stats.kill_ied = 0;
	level.rts.kill_stats.asd_rundown_kills_total = 10;
	level.rts.kill_stats.kill_riders_total = 10;
	level.rts.kill_stats.quad_kills_total = 20;
	level.rts.kill_stats.kill_ied_total = 3;
	self maps/_challenges_sp::register_challenge( "ASD_RUNDOWN" );
	self maps/_challenges_sp::register_challenge( "KILL_RIDERS" );
	self maps/_challenges_sp::register_challenge( "QUAD_KILLS" );
	self maps/_challenges_sp::register_challenge( "KILL_IED" );
	self maps/_challenges_sp::register_challenge( "NO_IED_CONVOY", ::challenge_no_ied_convoy );
	self maps/_challenges_sp::register_challenge( "ROD_KILL_TANK", ::challenge_rod_kill_tank );
	self maps/_challenges_sp::register_challenge( "ROD_KILL_HELO", ::challenge_rod_kill_helo );
	self maps/_challenges_sp::register_challenge( "ASD_VS_TANK", ::challenge_asd_vs_tank );
	self maps/_challenges_sp::register_challenge( "CONVOY_ALL", ::challenge_convoy_all );
	self maps/_challenges_sp::register_challenge( "TACTICAL", ::maps/_so_rts_support::challenge_tactical );
}

challenge_no_ied_convoy( str_notify )
{
	level endon( "convoy_stopped_by_ied" );
	level waittill( "mission_success" );
	self notify( str_notify );
}

challenge_rod_kill_tank( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_tank", sweapon, rts_mode );
		if ( sweapon == "rts_missile_sp" )
		{
			self notify( str_notify );
		}
	}
}

challenge_rod_kill_helo( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_helo", sweapon );
		if ( sweapon == "rts_missile_sp" )
		{
			self notify( str_notify );
		}
	}
}

challenge_asd_vs_tank( str_notify )
{
	while ( 1 )
	{
		level waittill( "player_killed_tank", sweapon, rts_mode );
		if ( sweapon == "metalstorm_launcher_afghan_rts" )
		{
			self notify( str_notify );
		}
	}
}

challenge_convoy_all( str_notify )
{
	flag_wait( "rts_start_clock" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	num_convoy_members = convoy.members.size;
	level waittill( "check_for_convoy_success" );
	num_convoy_members_alive = 0;
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	_a1281 = convoy.members;
	_k1281 = getFirstArrayKey( _a1281 );
	while ( isDefined( _k1281 ) )
	{
		member = _a1281[ _k1281 ];
		if ( isalive( member ) )
		{
			num_convoy_members_alive++;
		}
		_k1281 = getNextArrayKey( _a1281, _k1281 );
	}
	if ( num_convoy_members_alive == num_convoy_members )
	{
		self notify( str_notify );
	}
}

setup_objectives()
{
	level thread maps/_objectives::init();
	level.player setclientdvar( "cg_objectiveIndicatorFarFadeDist", 24000 );
	e_extraction_point_1 = getent( "rts_obj_loc1", "targetname" );
	e_extraction_point_2 = getent( "rts_obj_loc2", "targetname" );
	level.obj_escort = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_ESCORT" );
	level.obj_protect_hvc = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_PROTECT_HVC" );
	level.obj_protect = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_PROTECT" );
	level.obj_tank = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_DESTROY_TANK" );
	level.obj_heli = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_DESTROY_HELI" );
	level.obj_heli2 = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_DESTROY_HELI" );
	level.obj_escort2 = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_ESCORT2" );
	level.obj_destroy_ied = register_objective( &"SO_RTS_AFGHANISTAN_OBJ_DESTROY_IED" );
	set_objective( level.obj_escort, e_extraction_point_1 );
	objective_set3d( level.obj_escort, 1 );
	level waittill( "change_extraction_point" );
	wait 5;
	set_objective( level.obj_escort, undefined );
	objective_set3d( level.obj_escort, 0 );
	set_objective( level.obj_escort2, e_extraction_point_2 );
	objective_set3d( level.obj_escort2, 0 );
}

convoy_triggerwatch()
{
	level endon( "rts_afghan_fail" );
	level endon( "rts_terminated" );
	while ( 1 )
	{
		self waittill( "trigger", who );
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		maps/_so_rts_squad::removedeadfromsquad( convoy.id );
		target = convoy.members[ 0 ];
		if ( isDefined( self.vehpos ) )
		{
			if ( self.vehpos == "back" )
			{
				target = convoy.members[ convoy.members.size - 1 ];
			}
		}
		if ( target == who )
		{
			break;
		}
		else
		{
		}
	}
	while ( isDefined( self.flags ) )
	{
		_a1356 = self.flags;
		_k1356 = getFirstArrayKey( _a1356 );
		while ( isDefined( _k1356 ) )
		{
			flag = _a1356[ _k1356 ];
			flag_set( flag );
			_k1356 = getNextArrayKey( _a1356, _k1356 );
		}
	}
	while ( isDefined( self.notes ) )
	{
		_a1361 = self.notes;
		_k1361 = getFirstArrayKey( _a1361 );
		while ( isDefined( _k1361 ) )
		{
			note = _a1361[ _k1361 ];
			level notify( note );
			_k1361 = getNextArrayKey( _a1361, _k1361 );
		}
	}
	if ( !isDefined( self.script_noteworthy ) )
	{
		self delete();
	}
	else level notify( self.script_noteworthy );
}

afghanistan_convoy_speedcap_trigger()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		self waittill( "trigger", who );
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		target = convoy.members[ 0 ];
		if ( target == who )
		{
			break;
		}
		else
		{
		}
	}
	convoy.top_speed = int( self.script_noteworthy );
	self delete();
}

waittill_past_or_death( past_dist_sq )
{
	if ( !isDefined( past_dist_sq ) )
	{
		past_dist_sq = 1440000;
	}
	self endon( "death" );
	while ( 1 )
	{
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		one_still_near = 0;
		_a1404 = convoy.members;
		_k1404 = getFirstArrayKey( _a1404 );
		while ( isDefined( _k1404 ) )
		{
			cougar = _a1404[ _k1404 ];
			dist_sq = distance2dsquared( self.origin, cougar.origin );
			if ( dist_sq <= past_dist_sq )
			{
				one_still_near = 1;
				break;
			}
			else
			{
				_k1404 = getNextArrayKey( _a1404, _k1404 );
			}
		}
		if ( !one_still_near )
		{
			return;
		}
		else
		{
			wait 1;
		}
	}
}

waittill_near_or_death( near_dist )
{
	near_dist_sq = near_dist * near_dist;
	self endon( "death" );
	flag_wait( "intro_convoy_started" );
	while ( 1 )
	{
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		_a1431 = convoy.members;
		_k1431 = getFirstArrayKey( _a1431 );
		while ( isDefined( _k1431 ) )
		{
			cougar = _a1431[ _k1431 ];
			dist_sq = distance2dsquared( self.origin, cougar.origin );
			if ( dist_sq <= near_dist_sq )
			{
				return dist_sq;
			}
			_k1431 = getNextArrayKey( _a1431, _k1431 );
		}
		wait 1;
	}
}

afghan_iedwarningradiusthink( warning_dist )
{
	if ( !isDefined( level.m_num_nearby_ieds ) )
	{
		level.m_num_nearby_ieds = 0;
	}
	passed_dist_sq = ( warning_dist + 30 ) * ( warning_dist + 30 );
	while ( isalive( self ) )
	{
		dist_sq_from_ied = self waittill_near_or_death( warning_dist );
		if ( !isDefined( dist_sq_from_ied ) )
		{
			return;
		}
		level.m_num_nearby_ieds++;
		flag_set( "convoy_stopped" );
		level notify( "convoy_stopped_by_ied" );
		ied_marker = spawnstruct();
		ied_marker.origin = self.origin + vectorScale( ( 0, 0, 1 ), 64 );
		set_objective( level.obj_destroy_ied, ied_marker, "destroy", -1, 0 );
		self waittill_past_or_death( passed_dist_sq );
		level.m_num_nearby_ieds--;

		if ( level.m_num_nearby_ieds <= 0 )
		{
			flag_clear( "convoy_stopped" );
		}
		set_objective( level.obj_destroy_ied, ied_marker, "remove" );
		wait 0,05;
	}
}

afghanistan_ied_warning_watch()
{
	level.m_ied_warning_time = getTime() - 1000;
	while ( 1 )
	{
		time_since_warning = getTime() - level.m_ied_warning_time;
		if ( time_since_warning < 2000 )
		{
			self.top_speed = 4;
		}
		else
		{
			self.top_speed = 10;
		}
		wait 1;
	}
}

afghanistan_convoy_stop_1()
{
	level waittill( "tanks_spawned" );
	blocking_tank1 = level.m_tanks[ "t72_unit4" ];
/#
	assert( isDefined( blocking_tank1 ) );
#/
	level waittill( "convoy_stop_1" );
	if ( isalive( blocking_tank1 ) )
	{
		set_objective( level.obj_tank, blocking_tank1, "destroy" );
		flag_set( "convoy_stopped" );
		while ( isalive( blocking_tank1 ) )
		{
			wait_network_frame();
		}
		flag_clear( "convoy_stopped" );
		set_objective( level.obj_tank, undefined, "done" );
	}
}

run_objective_heli( objective_id )
{
	set_objective( objective_id, self, "destroy", -1 );
	self waittill( "death" );
	if ( flag( "rts_afghan_outro" ) )
	{
		return;
	}
	set_objective( objective_id, self, "remove" );
}

waittill_all_helis_killed( objective_id )
{
	any_alive = 0;
	_a1542 = level.m_helis;
	_k1542 = getFirstArrayKey( _a1542 );
	while ( isDefined( _k1542 ) )
	{
		heli = _a1542[ _k1542 ];
		if ( isalive( heli ) )
		{
			any_alive = 1;
			heli thread run_objective_heli( objective_id );
		}
		_k1542 = getNextArrayKey( _a1542, _k1542 );
	}
	if ( any_alive )
	{
		helis_alive = 0;
		helis_alive = 0;
		_a1556 = level.m_helis;
		_k1556 = getFirstArrayKey( _a1556 );
		while ( isDefined( _k1556 ) )
		{
			heli = _a1556[ _k1556 ];
			if ( isalive( heli ) )
			{
				helis_alive++;
			}
			_k1556 = getNextArrayKey( _a1556, _k1556 );
		}
		wait 0,5;
		return 1;
	}
	else
	{
		return 0;
	}
}

afghanistan_convoy_stop_2()
{
	level waittill( "convoy_stop_2" );
/#
	assert( isDefined( level.m_helis ) );
#/
	flag_set( "convoy_stopped" );
	killed_helis = waittill_all_helis_killed( level.obj_heli );
	if ( killed_helis )
	{
		set_objective( level.obj_heli, undefined, "done" );
	}
	flag_clear( "convoy_stopped" );
}

afghanistan_convoy_stop_3()
{
	level waittill( "convoy_stop_3" );
	flag_set( "convoy_stopped" );
	any_alive = 0;
	_a1594 = level.m_helis;
	_k1594 = getFirstArrayKey( _a1594 );
	while ( isDefined( _k1594 ) )
	{
		heli = _a1594[ _k1594 ];
		if ( isalive( heli ) )
		{
			any_alive = 1;
		}
		_k1594 = getNextArrayKey( _a1594, _k1594 );
	}
	if ( any_alive )
	{
		set_objective( level.obj_heli, undefined, "delete" );
	}
	killed_helis = waittill_all_helis_killed( level.obj_heli2 );
	if ( killed_helis )
	{
		set_objective( level.obj_heli2, undefined, "delete" );
	}
	flag_clear( "convoy_stopped" );
}

afghanistan_convoy_watch_speed()
{
	level endon( "mission_success" );
	flag_wait( "intro_convoy_started" );
	flag_init( "convoy_stopped" );
	level thread afghanistan_convoy_stop_1();
	level thread afghanistan_convoy_stop_2();
	level thread afghanistan_convoy_stop_3();
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	convoy.top_speed = 10;
	min_distance = 500;
	max_distance = 800;
	_a1630 = convoy.members;
	_k1630 = getFirstArrayKey( _a1630 );
	while ( isDefined( _k1630 ) )
	{
		member = _a1630[ _k1630 ];
		member setvehmaxspeed( convoy.top_speed );
		_k1630 = getNextArrayKey( _a1630, _k1630 );
	}
	stop_occurred = 0;
	while ( 1 )
	{
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		member_ahead = undefined;
		i = 0;
		while ( i < convoy.members.size )
		{
			if ( i == 0 )
			{
				level.rts.level_default_fps_pos = convoy.members[ i ].origin;
			}
			member = convoy.members[ i ];
			if ( !isDefined( member_ahead ) )
			{
				if ( flag( "convoy_stopped" ) )
				{
					member setbrake( 1 );
				}
				else
				{
					member setbrake( 0 );
					member setvehmaxspeed( convoy.top_speed );
				}
			}
			else dist_behind = distance2d( member.origin, member_ahead.origin );
			top_speed = convoy.top_speed;
			if ( dist_behind < min_distance || flag( "convoy_stopped" ) )
			{
				top_speed = 1;
			}
			else
			{
				if ( dist_behind > max_distance )
				{
					amount_behind = ( dist_behind - min_distance ) / min_distance;
					top_speed = lerpfloat( convoy.top_speed, convoy.top_speed * 2, amount_behind );
				}
			}
			member setvehmaxspeed( top_speed );
			if ( top_speed <= 1 )
			{
				member setbrake( 1 );
			}
			else
			{
				member setbrake( 0 );
			}
			member_ahead = member;
			i++;
		}
		if ( stop_occurred && !flag( "convoy_stopped" ) )
		{
			stop_occurred = 0;
		}
		else
		{
			while ( !stop_occurred && flag( "convoy_stopped" ) )
			{
				stop_occurred = 1;
				while ( isDefined( convoy.members[ 0 ] ) )
				{
					_a1691 = level.rts.squads;
					_k1691 = getFirstArrayKey( _a1691 );
					while ( isDefined( _k1691 ) )
					{
						squad = _a1691[ _k1691 ];
						if ( squad.team != "allies" )
						{
						}
						else if ( isDefined( squad.selectable ) && !squad.selectable )
						{
						}
						else
						{
							if ( isDefined( squad.foltarget ) )
							{
								break;
							}
							else if ( isDefined( squad.no_group_commands ) && squad.no_group_commands )
							{
								break;
							}
							else
							{
								if ( distance2dsquared( squad.centerpoint, convoy.members[ 0 ].origin ) < ( 4096 * 4096 ) )
								{
									break;
								}
								else
								{
									maps/_so_rts_squad::ordersquadfollowai( squad.id, convoy.members[ 0 ] );
								}
							}
						}
						_k1691 = getNextArrayKey( _a1691, _k1691 );
					}
				}
			}
		}
		wait 0,5;
	}
}

afghanistan_heli_path( info_struct )
{
	self endon( "death" );
	self veh_magic_bullet_shield( 1 );
	self delay_thread( 10, ::veh_magic_bullet_shield, 0 );
	node = getvehiclenode( info_struct.target, "targetname" );
	loop_node = getvehiclenode( info_struct.target + "_loop", "targetname" );
	self thread afghanistan_hind_fire_update();
	self thread go_path( node );
	self waittill( "reached_end_node" );
	while ( isDefined( loop_node ) )
	{
		while ( 1 )
		{
			self thread go_path( loop_node );
			self waittill( "reached_end_node" );
		}
	}
}

afghanistan_convoy_speedcap_triggers()
{
	level endon( "rts_terminated" );
	trigs = getentarray( "convoy_speed_trigger", "targetname" );
	array_thread( trigs, ::afghanistan_convoy_speedcap_trigger );
}

afghanistan_convoytriggers()
{
	triggers = getentarray( "convoy_trigger", "targetname" );
	_a1750 = triggers;
	_k1750 = getFirstArrayKey( _a1750 );
	while ( isDefined( _k1750 ) )
	{
		trigger = _a1750[ _k1750 ];
		while ( isDefined( trigger.script_parameters ) )
		{
			tokens = strtok( trigger.script_parameters, " " );
			_a1756 = tokens;
			_k1756 = getFirstArrayKey( _a1756 );
			while ( isDefined( _k1756 ) )
			{
				token = _a1756[ _k1756 ];
				if ( issubstr( token, "flag=" ) )
				{
					if ( !isDefined( trigger.flags ) )
					{
						trigger.flags = [];
					}
					trigger.flags[ trigger.flags.size ] = strtok( token, "=" )[ 1 ];
					flag_init( trigger.flags[ trigger.flags.size - 1 ] );
				}
				if ( issubstr( token, "note=" ) )
				{
					if ( !isDefined( trigger.notes ) )
					{
						trigger.notes = [];
					}
					trigger.notes[ trigger.notes.size ] = strtok( token, "=" )[ 1 ];
					flag_init( trigger.notes[ trigger.notes.size - 1 ] );
				}
				if ( issubstr( token, "convoy=" ) )
				{
					trigger.vehpos = strtok( token, "=" )[ 1 ];
/#
					if ( trigger.vehpos != "back" )
					{
						assert( trigger.vehpos == "front" );
					}
#/
				}
				_k1756 = getNextArrayKey( _a1756, _k1756 );
			}
		}
		trigger thread convoy_triggerwatch();
		_k1750 = getNextArrayKey( _a1750, _k1750 );
	}
}

afghanistan_t72_death()
{
	self waittill( "death" );
	if ( flag( "rts_afghan_outro" ) )
	{
		return;
	}
	maps/_so_rts_event::trigger_event( "fx_ied_explode", self.origin );
	maps/_so_rts_event::trigger_event( "sfx_ied_explode" );
	earthquake( 0,5, 2, self.origin, 1000 );
}

afghanistan_t72_damage()
{
	level endon( "rts_terminated" );
	self endon( "death" );
	self notify( "afghanistan_t72_damage" );
	self endon( "afghanistan_t72_damage" );
	self thread afghanistan_t72_death();
/#
	assert( !isDefined( self.overridevehicledamage ) );
#/
	self.overridevehicledamage = ::afghanistan_t72_vehicledamage;
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type );
		platform = getsquadbypkg( "missle_strike_pkg", "allies" );
		if ( self.health < 1000 && !isDefined( self.smoking ) )
		{
			self.smoking = 1;
			playfxontag( level._effect[ "tank_damage" ], self, "tag_engine_left" );
		}
		else
		{
			if ( self.health < 600 && isDefined( self.smoking ) && self.smoking == 1 )
			{
				self.smoking = 2;
				playfxontag( level._effect[ "tank_damage" ], self, "tag_origin" );
				break;
			}
			else
			{
				if ( self.health < 300 && isDefined( self.smoking ) && self.smoking == 2 )
				{
					self.smoking = 3;
					playfxontag( level._effect[ "tank_damage" ], self, "tag_engine_right" );
				}
			}
		}
		if ( isDefined( attacker ) )
		{
			if ( isplayer( attacker ) && isDefined( attacker.viewlockedentity ) && attacker.viewlockedentity isvehicle() )
			{
				attacker = attacker.viewlockedentity;
				self vehsetentitytarget( attacker );
			}
		}
		if ( isDefined( platform ) && isinarray( platform.members, attacker ) )
		{
			break;
		}
		else
		{
		}
	}
	self kill();
}

afghanistan_t72_vehicledamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( smeansofdeath != "MOD_PROJECTILE" )
	{
		idamage = 0;
	}
	return idamage;
}

afghanistan_t72_convoy_unit_move( path )
{
	self notify( "t72_moveout" );
	self.drivepath = 1;
	self thread go_path( getvehiclenode( path, "targetname" ) );
}

afghanistan_t72_convoy_unit( path )
{
	level endon( "rts_terminated" );
	self endon( "death" );
	self thread afghanistan_t72_damage();
	self thread afghanistan_t72_weapon_update();
	if ( !isDefined( self.move_stage ) )
	{
		self.move_stage = "";
	}
	path += self.move_stage;
	while ( isDefined( path ) )
	{
		self thread afghanistan_t72_convoy_unit_move( path );
		self waittill( "reached_end_node" );
		level waittill( path );
		self.move_stage = int( self.move_stage ) + 1;
		path += self.move_stage;
	}
}

t72_wait_vis()
{
	self endon( "death" );
	self endon( "" );
	self waittill( "turret_on_target" );
	self waittill( "turret_on_vistarget" );
	self.has_vis = 1;
	self notify( "vis_check_done" );
}

t72_wait_novis()
{
	self endon( "death" );
	self endon( "vis_check_done" );
	self waittill( "turret_on_target" );
	self waittill( "turret_no_vis" );
	self.has_vis = undefined;
	self notify( "vis_check_done" );
}

afghanistan_t72_waittill_turret_on_target()
{
	self.has_vis = undefined;
	self thread t72_wait_vis();
	self thread t72_wait_novis();
	self waittill_any_or_timeout( 10, "vis_check_done" );
	self notify( "vis_check_done" );
}

afghanistan_t72_weapon_update()
{
	level endon( "rts_terminated" );
	self endon( "death" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	maps/_so_rts_squad::removedeadfromsquad( convoy.id );
	while ( convoy.members.size )
	{
		target = self.enemy;
		if ( !isDefined( target ) )
		{
			target = convoy.members[ randomint( convoy.members.size ) ];
		}
		if ( isDefined( target ) )
		{
			self settargetentity( target );
			self afghanistan_t72_waittill_turret_on_target();
			if ( isDefined( self.has_vis ) )
			{
				self fireweapon();
				wait randomfloatrange( 2, 4 );
			}
		}
		maps/_so_rts_squad::removedeadfromsquad( convoy.id );
		wait 0,25;
	}
}

afghanistan_truckdeathwatch()
{
	self endon( "truck_is_up" );
	self waittill( "death" );
	set_objective( level.obj_protect, undefined, "failed" );
}

afghanistan_truckstall( time, endspeed )
{
	if ( !isDefined( endspeed ) )
	{
		endspeed = 2;
	}
	self endon( "death" );
	self thread afghanistan_truckdeathwatch();
	speed = self getspeed();
	self setspeed( 0, 2 );
	maps/_so_rts_event::trigger_event( "fx_truck_stall", self.origin );
	if ( flag( "fps_mode" ) )
	{
		maps/_so_rts_event::trigger_event( "dlg_sect_veh_stuck" );
	}
	else
	{
		maps/_so_rts_event::trigger_event( "dlg_veh_stuck" );
	}
	self setbrake( 1 );
	wait time;
	self setbrake( 0 );
	self notify( "truck_is_up" );
	self setspeed( endspeed );
	set_objective( level.obj_protect, undefined, "done" );
}

afghanistan_convoydamagewatch()
{
	level endon( "rts_terminated" );
	self endon( "death" );
	old_health = self.health;
	while ( 1 )
	{
		self waittill( "damage", damage, attacker );
		if ( isDefined( self ) )
		{
			if ( isDefined( attacker ) )
			{
/#
				if ( isDefined( attacker ) )
				{
					if ( isDefined( attacker.ai_ref ) )
					{
					}
					else
					{
					}
					println( attacker.ai_ref.ref + attacker getentitynumber() + " HEALTH LEFT:" + self.health, "CONVOY UNIT " + self getentitynumber() + " took DAMAGE:" + damage + " from attacker:" );
#/
				}
			}
			if ( ( old_health - self.health ) > 1200 )
			{
				playfxontag( level._effect[ "tank_damage" ], self, "tag_grill" );
				old_health = self.health;
			}
		}
	}
}

afghanistan_convoy_vehicledamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( smeansofdeath == "MOD_RIFLE_BULLET" || smeansofdeath == "MOD_PISTOL_BULLET" )
	{
		idamage *= 0,25;
	}
	return int( idamage );
}

follow_convoy( squadid )
{
	self waittill( "follow_convoy" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	maps/_so_rts_squad::ordersquadfollowai( squadid, convoy.members[ 0 ] );
}

attack_snipers( squadid )
{
	self endon( "follow_convoy" );
	self thread maps/_so_rts_support::notifymeinnsec( "follow_convoy", 20 );
	targets = getentarray( "intro_quad_target", "script_noteworthy" );
	if ( targets.size > 0 )
	{
		maps/_so_rts_squad::ordersquadattack( squadid, targets[ 0 ] );
	}
	while ( targets.size > 0 )
	{
		wait 0,05;
	}
	self notify( "follow_convoy" );
}

quad_fire_randomly( target )
{
	self endon( "death" );
	wait randomfloatrange( 0, 2 );
	while ( 1 )
	{
		i = 0;
		while ( i < 4 )
		{
			self fireweapon( target, undefined, 1 );
			wait 0,1;
			i++;
		}
		wait randomfloatrange( 3, 4 );
	}
}

run_buddy_quad()
{
	self quadrotor_set_team( "allies" );
	flag_wait( "intro_convoy_started" );
	ais = get_ais_from_scene( "intro_convoy" );
	target = random( ais );
	self thread quad_fire_randomly( target );
	scene_wait( "intro_convoy" );
	self delete();
}

afghanistan_level_player_startfps()
{
	setup_scenes();
	maps/_so_rts_support::hide_player_hud();
	nextsquad = getsquadbypkg( "quadrotor_pkg", "allies" );
/#
	assert( isDefined( nextsquad ), "player squad should be created" );
#/
	level.rts.player freezecontrols( 1 );
	flag_set( "block_input" );
	level notify( "intro_go" );
	buddy_quads = getentarray( "intro_buddy_quad", "script_noteworthy" );
	array_thread( buddy_quads, ::run_buddy_quad );
	level.rts.intro_quad = getent( "intro_quad", "targetname" );
	level.rts.intro_quad veh_magic_bullet_shield( 1 );
	level.rts.intro_quad quadrotor_set_team( "allies" );
	maps/_so_rts_event::trigger_event( "dlg_intro_defensive" );
	flag_set( "rts_event_ready" );
	run_scene_first_frame( "intro_convoy" );
	flag_wait( "introscreen_complete" );
	level thread maps/createart/so_rts_afghanistan_art::intro_igc();
	level_fade_in();
	level thread run_scene( "intro_convoy" );
	flag_wait( "intro_convoy_started" );
	intro_quad_showfps( 1 );
	wait 0,5;
	maps/_so_rts_event::trigger_event( "dlg_intro_echo" );
	level waittill_any_timeout( 4, "dlg_intro_echo_done" );
	scene_wait( "intro_convoy" );
	maps/_so_rts_event::trigger_event( "dlg_intro_quad" );
	maps/_so_rts_catalog::package_select( "quadrotor2_pkg", 1 );
	quad_rotor_squadinit();
	maps/_so_rts_catalog::package_setpackagecost( "quadrotor_pkg", -1, 20 );
	maps/_so_rts_catalog::package_setpackagecost( "quadrotor2_pkg", -1, 20 );
	level.rts.activesquad = nextsquad.id;
	flag_set( "rts_hud_on" );
	maps/_so_rts_support::show_player_hud();
	quads = sortarraybyclosest( level.rts.intro_quad.origin, nextsquad.members );
	level.rts.targetteammate = quads[ 0 ];
	spot = getstruct( "quad_player_intro_loc", "targetname" );
	level.rts.targetteammate.origin = spot.origin;
	level.rts.targetteammate.angles = spot.angles;
	level thread attack_snipers( nextsquad.id );
	level thread follow_convoy( nextsquad.id );
	level thread maps/_so_rts_main::player_in_control( 1, 1 );
	quads[ 1 ].origin = level.rts.intro_quad.origin;
	quads[ 1 ].angles = level.rts.intro_quad.angles;
	quads[ 1 ] dodamage( quads[ 1 ].health + 1, quads[ 1 ].origin, level.rts.player, level.rts.player );
	level.rts.intro_quad delete();
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	convoy.members[ 0 ] thread afghanistan_convoy_leadupdate();
	set_objective( level.obj_protect_hvc, convoy.members[ 0 ], "*", convoy.members.size );
	objective_icon( level.obj_protect_hvc, "waypoint_defend" );
	flag_set( "start_rts_enemy" );
	level.rts.player.ignoreme = 0;
	level.rts.player disableinvulnerability();
	level.rts.player freezecontrols( 0 );
	flag_clear( "block_input" );
	flag_set( "rts_start_clock" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	nextsquad = getsquadbypkg( "quadrotor_pkg", "allies" );
	maps/_so_rts_squad::ordersquadfollowai( nextsquad.id, convoy.members[ 0 ] );
	nextsquad = getsquadbypkg( "quadrotor2_pkg", "allies" );
	maps/_so_rts_squad::ordersquadfollowai( nextsquad.id, convoy.members[ 0 ] );
	_a2177 = nextsquad.members;
	_k2177 = getFirstArrayKey( _a2177 );
	while ( isDefined( _k2177 ) )
	{
		quad = _a2177[ _k2177 ];
		quad.origin = convoy.members[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 90 );
		_k2177 = getNextArrayKey( _a2177, _k2177 );
	}
	nextsquad = getsquadbypkg( "metalstorm_pkg", "allies" );
	maps/_so_rts_squad::ordersquadfollowai( nextsquad.id, convoy.members[ 0 ] );
	nodes = getnodesinradius( convoy.members[ 0 ].origin, 800, 256 );
	i = 0;
	_a2185 = nextsquad.members;
	_k2185 = getFirstArrayKey( _a2185 );
	while ( isDefined( _k2185 ) )
	{
		storm = _a2185[ _k2185 ];
		storm.origin = nodes[ i ].origin + vectorScale( ( 0, 0, 1 ), 12 );
		i++;
		_k2185 = getNextArrayKey( _a2185, _k2185 );
	}
	wait 1;
	maps/_so_rts_event::trigger_event( "dlg_intro_recon" );
	level waittill_any_timeout( 4, "dlg_intro_recon_done" );
	wait 1;
	maps/_so_rts_event::trigger_event( "dlg_intro_path" );
	level waittill_any_timeout( 4, "dlg_intro_path_done" );
	wait 1;
	maps/_so_rts_event::trigger_event( "dlg_intro_freefire" );
	level waittill_any_timeout( 4, "dlg_intro_freefire_done" );
	wait 1;
	maps/_so_rts_event::trigger_event( "dlg_intro_vehicles" );
}

afghanistan_handofnodwatcher()
{
	level endon( "rts_terminated" );
	scene_wait( "intro_convoy" );
	wait 10;
	maps/_so_rts_catalog::setpkgqty( "missle_strike_pkg", "allies", 1 );
	maps/_so_rts_catalog::package_select( "missle_strike_pkg", 1 );
	while ( 1 )
	{
		hamp = getsquadbypkg( "missle_strike_pkg", "allies" );
/#
#/
		thread maps/_glasses::add_visor_text( "SO_RTS_AFGHANISTAN_HAMP_ONLINE", 0, "orange" );
		maps/_so_rts_event::trigger_event( "dlg_hamp_online" );
		hamp.selectable = 1;
		level waittill( "HandOfNOD_ATTACK" );
		hamp.selectable = 0;
		thread maps/_glasses::add_visor_text( "SO_RTS_AFGHANISTAN_HAMP_ATTACKING", 0, "orange" );
		thread maps/_glasses::remove_visor_text( "SO_RTS_AFGHANISTAN_HAMP_ONLINE" );
		maps/_so_rts_event::trigger_event( "dlg_hamp_targeting" );
/#
#/
		note = level waittill_any_return( "HandOfNOD_LAUNCHED", "HandOfNOD_LAUNCH_ABORT" );
		thread maps/_glasses::remove_visor_text( "SO_RTS_AFGHANISTAN_HAMP_ATTACKING" );
/#
#/
		luinotifyevent( &"rts_remove_squad", 1, hamp.id );
		if ( note == "HandOfNOD_LAUNCH_ABORT" )
		{
			hamp.nextavailattack = getTime() + 5000;
			thread maps/_glasses::add_visor_text( "SO_RTS_AFGHANISTAN_HAMP_ABORT", 5, "orange" );
		}
		else
		{
			thread maps/_glasses::add_visor_text( "SO_RTS_AFGHANISTAN_HAMP_OFFLINE", 5, "orange" );
		}
		time = 0;
		while ( time < hamp.nextavailattack )
		{
			time = getTime();
			wait 1;
		}
		luinotifyevent( &"rts_add_squad", 3, hamp.id, hamp.pkg_ref.idx, 0 );
		luinotifyevent( &"rts_add_friendly_ai", 4, hamp.members[ 0 ] getentitynumber(), hamp.id, 0, hamp.pkg_ref.idx );
	}
}

setcount()
{
	if ( isDefined( self.script_parameters ) && issubstr( self.script_parameters, "count=" ) )
	{
		tokens = strtok( self.script_parameters, " " );
		_a2266 = tokens;
		_k2266 = getFirstArrayKey( _a2266 );
		while ( isDefined( _k2266 ) )
		{
			token = _a2266[ _k2266 ];
			if ( issubstr( token, "count=" ) )
			{
				self.count = int( strtok( token, "=" )[ 1 ] );
				break;
			}
			else
			{
				_k2266 = getNextArrayKey( _a2266, _k2266 );
			}
		}
	}
	else self.count = 1;
}

afghanistan_spawnlocthink()
{
	level thread afghanistan_setupspawnvolumes();
	level endon( "rts_terminated" );
	flag_wait( "start_rts" );
	_a2289 = level.rts.spawn.enemylocs;
	_k2289 = getFirstArrayKey( _a2289 );
	while ( isDefined( _k2289 ) )
	{
		spot = _a2289[ _k2289 ];
		spot.recheck = 0;
		spot setcount();
		_k2289 = getNextArrayKey( _a2289, _k2289 );
	}
	_a2294 = level.rts.spawn.horselocs;
	_k2294 = getFirstArrayKey( _a2294 );
	while ( isDefined( _k2294 ) )
	{
		spot = _a2294[ _k2294 ];
		spot.recheck = 0;
		spot setcount();
		_k2294 = getNextArrayKey( _a2294, _k2294 );
	}
	_a2299 = level.rts.spawn.enemyrpglocs;
	_k2299 = getFirstArrayKey( _a2299 );
	while ( isDefined( _k2299 ) )
	{
		spot = _a2299[ _k2299 ];
		spot.recheck = 0;
		spot setcount();
		_k2299 = getNextArrayKey( _a2299, _k2299 );
	}
	wait 2;
	target = getsquadbypkg( "convoy_pkg", "allies" );
	while ( target.members.size > 0 )
	{
		level.rts.spawn.activeenemylocs = maps/_so_rts_support::sortarraybyclosest( target.centerpoint, level.rts.spawn.enemylocs, 4096 * 4096 );
		level.rts.spawn.activehorselocs = maps/_so_rts_support::sortarraybyclosest( target.centerpoint, level.rts.spawn.horselocs, 6000 * 6000 );
		level.rts.spawn.activerpglocs = maps/_so_rts_support::sortarraybyclosest( target.centerpoint, level.rts.spawn.enemyrpglocs, 4096 * 4096 );
		_a2313 = level.rts.spawn.enemylocs;
		_k2313 = getFirstArrayKey( _a2313 );
		while ( isDefined( _k2313 ) )
		{
			spot = _a2313[ _k2313 ];
			spot.active = undefined;
			_k2313 = getNextArrayKey( _a2313, _k2313 );
		}
		_a2315 = level.rts.spawn.horselocs;
		_k2315 = getFirstArrayKey( _a2315 );
		while ( isDefined( _k2315 ) )
		{
			spot = _a2315[ _k2315 ];
			spot.active = undefined;
			_k2315 = getNextArrayKey( _a2315, _k2315 );
		}
		_a2317 = level.rts.spawn.enemyrpglocs;
		_k2317 = getFirstArrayKey( _a2317 );
		while ( isDefined( _k2317 ) )
		{
			spot = _a2317[ _k2317 ];
			spot.active = undefined;
			_k2317 = getNextArrayKey( _a2317, _k2317 );
		}
		_a2321 = level.rts.spawn.activeenemylocs;
		_k2321 = getFirstArrayKey( _a2321 );
		while ( isDefined( _k2321 ) )
		{
			spot = _a2321[ _k2321 ];
			spot.active = 1;
			_k2321 = getNextArrayKey( _a2321, _k2321 );
		}
		_a2323 = level.rts.spawn.activerpglocs;
		_k2323 = getFirstArrayKey( _a2323 );
		while ( isDefined( _k2323 ) )
		{
			spot = _a2323[ _k2323 ];
			spot.active = 1;
			_k2323 = getNextArrayKey( _a2323, _k2323 );
		}
		_a2325 = level.rts.spawn.activehorselocs;
		_k2325 = getFirstArrayKey( _a2325 );
		while ( isDefined( _k2325 ) )
		{
			spot = _a2325[ _k2325 ];
			spot.active = 1;
			_k2325 = getNextArrayKey( _a2325, _k2325 );
		}
/#
		_a2330 = level.rts.spawn.activeenemylocs;
		_k2330 = getFirstArrayKey( _a2330 );
		while ( isDefined( _k2330 ) )
		{
			spot = _a2330[ _k2330 ];
			thread maps/_so_rts_support::debug_sphere( spot.origin, 32, ( 0, 0, 1 ), 0,5, 50 );
			_k2330 = getNextArrayKey( _a2330, _k2330 );
		}
		_a2332 = level.rts.spawn.activerpglocs;
		_k2332 = getFirstArrayKey( _a2332 );
		while ( isDefined( _k2332 ) )
		{
			spot = _a2332[ _k2332 ];
			thread maps/_so_rts_support::debug_sphere( spot.origin, 32, ( 0, 0, 1 ), 0,5, 50 );
			_k2332 = getNextArrayKey( _a2332, _k2332 );
		}
		_a2334 = level.rts.spawn.activehorselocs;
		_k2334 = getFirstArrayKey( _a2334 );
		while ( isDefined( _k2334 ) )
		{
			spot = _a2334[ _k2334 ];
			thread maps/_so_rts_support::debug_sphere( spot.origin, 32, ( 0, 0, 1 ), 0,5, 50 );
			_k2334 = getNextArrayKey( _a2334, _k2334 );
#/
		}
		wait 1;
	}
}

afghanistan_removespawnloc( spot )
{
	if ( spot.spawn.count > 0 )
	{
		return;
	}
	if ( isDefined( spot.spawn.script_parameters ) && issubstr( spot.spawn.script_parameters, "no_delete" ) )
	{
		spot.spawn.count = 1;
		return;
	}
	switch( spot.type )
	{
		case "rpg":
			arrayremovevalue( level.rts.spawn.activerpglocs, spot.spawn );
			arrayremovevalue( level.rts.spawn.enemyrpglocs, spot.spawn );
			break;
		case "inf":
			arrayremovevalue( level.rts.spawn.activeenemylocs, spot.spawn );
			arrayremovevalue( level.rts.spawn.enemylocs, spot.spawn );
			break;
		case "horse":
			arrayremovevalue( level.rts.spawn.activehorselocs, spot.spawn );
			arrayremovevalue( level.rts.spawn.horselocs, spot.spawn );
			break;
	}
	spot.spawn delete();
}

leastcomparefunc( e1, e2, val )
{
	return e1.spawntime < e2.spawntime;
}

afghanistan_setupspawnvolumes()
{
	volume_groups = array( "spawn_volume_set_3", "spawn_volume_set_2", "spawn_volume_set_1" );
	spawn_volumes = [];
	_a2384 = volume_groups;
	_k2384 = getFirstArrayKey( _a2384 );
	while ( isDefined( _k2384 ) )
	{
		group_name = _a2384[ _k2384 ];
		volumes = getentarray( group_name, "script_noteworthy" );
		spawn_volumes = arraycombine( spawn_volumes, volumes, 1, 0 );
		_k2384 = getNextArrayKey( _a2384, _k2384 );
	}
	_a2390 = level.rts.spawn.enemylocs;
	_k2390 = getFirstArrayKey( _a2390 );
	while ( isDefined( _k2390 ) )
	{
		spot = _a2390[ _k2390 ];
		_a2392 = spawn_volumes;
		_k2392 = getFirstArrayKey( _a2392 );
		while ( isDefined( _k2392 ) )
		{
			volume = _a2392[ _k2392 ];
			if ( is_point_inside_volume( spot.origin, volume ) )
			{
				spot.spawn_volume = volume.script_noteworthy;
				break;
			}
			else
			{
				_k2392 = getNextArrayKey( _a2392, _k2392 );
			}
		}
		_k2390 = getNextArrayKey( _a2390, _k2390 );
	}
	_a2402 = level.rts.spawn.horselocs;
	_k2402 = getFirstArrayKey( _a2402 );
	while ( isDefined( _k2402 ) )
	{
		spot = _a2402[ _k2402 ];
		_a2404 = spawn_volumes;
		_k2404 = getFirstArrayKey( _a2404 );
		while ( isDefined( _k2404 ) )
		{
			volume = _a2404[ _k2404 ];
			if ( is_point_inside_volume( spot.origin, volume ) )
			{
				spot.spawn_volume = volume.script_noteworthy;
				break;
			}
			else
			{
				_k2404 = getNextArrayKey( _a2404, _k2404 );
			}
		}
		_k2402 = getNextArrayKey( _a2402, _k2402 );
	}
	_a2414 = level.rts.spawn.enemyrpglocs;
	_k2414 = getFirstArrayKey( _a2414 );
	while ( isDefined( _k2414 ) )
	{
		spot = _a2414[ _k2414 ];
		_a2416 = spawn_volumes;
		_k2416 = getFirstArrayKey( _a2416 );
		while ( isDefined( _k2416 ) )
		{
			volume = _a2416[ _k2416 ];
			if ( is_point_inside_volume( spot.origin, volume ) )
			{
				spot.spawn_volume = volume.script_noteworthy;
				break;
			}
			else
			{
				_k2416 = getNextArrayKey( _a2416, _k2416 );
			}
		}
		_k2414 = getNextArrayKey( _a2414, _k2414 );
	}
	flag_wait( "intro_convoy_started" );
	while ( 1 )
	{
		level.m_active_spawn_volume = undefined;
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		while ( isDefined( convoy.members[ 0 ] ) )
		{
			_a2433 = spawn_volumes;
			_k2433 = getFirstArrayKey( _a2433 );
			while ( isDefined( _k2433 ) )
			{
				volume = _a2433[ _k2433 ];
				if ( convoy.members[ 0 ] istouching( volume ) )
				{
					level.m_active_spawn_volume = volume.script_noteworthy;
					break;
				}
				else
				{
					_k2433 = getNextArrayKey( _a2433, _k2433 );
				}
			}
		}
		wait 2;
	}
}

afghanistan_getspawnloc( activelist, totallist, type )
{
	spawn = undefined;
	time = getTime();
	_a2450 = activelist;
	_k2450 = getFirstArrayKey( _a2450 );
	while ( isDefined( _k2450 ) )
	{
		spot = _a2450[ _k2450 ];
		if ( !isDefined( spot.recheck ) )
		{
		}
		else if ( time < spot.recheck )
		{
		}
		else if ( spot.count <= 0 )
		{
		}
		else spot.dot = 0;
		spot.cue = "";
		if ( isDefined( spot.script_parameters ) && issubstr( spot.script_parameters, "flag=" ) )
		{
			tokens = strtok( spot.script_parameters, " " );
			_a2466 = tokens;
			_k2466 = getFirstArrayKey( _a2466 );
			while ( isDefined( _k2466 ) )
			{
				token = _a2466[ _k2466 ];
				if ( issubstr( token, "flag=" ) )
				{
					tflag = strtok( token, "=" )[ 1 ];
					if ( !flag( tflag ) )
					{
						skip = 1;
						break;
					}
				}
				_k2466 = getNextArrayKey( _a2466, _k2466 );
			}
			if ( isDefined( skip ) && skip )
			{
			}
		}
		else
		{
			if ( isDefined( spot.script_parameters ) && issubstr( spot.script_parameters, "force" ) )
			{
				spot.cue = "FORCE";
				spawn = spot;
				break;
			}
			else
			{
				distsq = distancesquared( level.rts.player.origin, spot.origin );
				if ( distsq < 360000 )
				{
					break;
				}
				else if ( isDefined( level.m_active_spawn_volume ) )
				{
					if ( !isDefined( spot.spawn_volume ) && isDefined( level.m_active_spawn_volume ) && isDefined( spot.spawn_volume ) && isDefined( level.m_active_spawn_volume ) && level.m_active_spawn_volume != spot.spawn_volume )
					{
						break;
					}
				}
				else
				{
					if ( distsq > 16777216 )
					{
						spot.cue = "FAR";
						spawn = spot;
						break;
					}
					else angles = level.rts.player getplayerangles();
					vieworg = level.rts.player.origin;
					v_forward = anglesToForward( angles );
					v_dir = vectornormalize( spot.origin - vieworg );
					spot.dot = vectordot( v_forward, v_dir );
					if ( spot.dot < 0,6 )
					{
						spot.cue = "DOT";
						spawn = spot;
						break;
					}
				}
			}
			else
			{
				_k2450 = getNextArrayKey( _a2450, _k2450 );
			}
		}
	}
	if ( !isDefined( spawn ) )
	{
		return undefined;
	}
	if ( spawn.count > 0 )
	{
		spawn.count--;

	}
/#
	print3d( spawn.origin + vectorScale( ( 0, 0, 1 ), 72 ), "CUE:" + spawn.cue + " DOT:" + spot.dot, ( 0, 0, 1 ), 1, 6, 50 );
	thread maps/_so_rts_support::debug_sphere( spawn.origin, 72, ( 0, 0, 1 ), 0,5, 50 );
#/
	spot = spawnstruct();
	if ( isDefined( spawn.target ) )
	{
		targets = getentarray( spawn.target, "targetname" );
		if ( targets.size > 0 )
		{
			target = targets[ randomint( targets.size ) ];
		}
	}
	if ( isDefined( target ) )
	{
	}
	else
	{
	}
	spot.goalpos = undefined;
	spot.type = type;
	spot.spawn = spawn;
	return spot;
}

afghanistan_getspawnlocationforenemyrpg()
{
	if ( level.rts.spawn.activerpglocs.size == 0 )
	{
		return undefined;
	}
	return afghanistan_getspawnloc( level.rts.spawn.activerpglocs, level.rts.spawn.enemyrpglocs, "rpg" );
}

afghanistan_getspawnlocationforenemyinfantry()
{
	if ( level.rts.spawn.activeenemylocs.size == 0 )
	{
		return undefined;
	}
	return afghanistan_getspawnloc( level.rts.spawn.activeenemylocs, level.rts.spawn.enemylocs, "inf" );
}

afghanistan_getspawnlocationforenemyhorses()
{
	if ( level.rts.spawn.activehorselocs.size == 0 )
	{
		return undefined;
	}
	return afghanistan_getspawnloc( level.rts.spawn.activehorselocs, level.rts.spawn.horselocs, "horse" );
}

afghan_autokillondist( distsq )
{
	level endon( "rts_terminated" );
	self notify( "afghan_autoKillOnDist" );
	self endon( "afghan_autoKillOnDist" );
	self endon( "death" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	while ( convoy.members.size > 0 )
	{
		wait 1;
		maps/_so_rts_squad::removedeadfromsquad( convoy.id );
		killme = 1;
		_a2587 = convoy.members;
		_k2587 = getFirstArrayKey( _a2587 );
		while ( isDefined( _k2587 ) )
		{
			truck = _a2587[ _k2587 ];
			if ( distancesquared( self.origin, truck.origin ) < distsq )
			{
				killme = 0;
				break;
			}
			else
			{
				_k2587 = getNextArrayKey( _a2587, _k2587 );
			}
		}
		if ( killme )
		{
/#
			println( "AI RIP Time:" + getTime() + " AI killing self for being to far from confoy:" + self.ai_ref.ref + " at (" + self.origin + ")" );
#/
			self.takedamage = 1;
			self dodamage( self.health + 1, self.origin );
		}
	}
}

quad_rotor_squadinit()
{
	quadsquad = getsquadbypkg( "quadrotor_pkg", "allies" );
	_a2609 = quadsquad.members;
	_k2609 = getFirstArrayKey( _a2609 );
	while ( isDefined( _k2609 ) )
	{
		quad = _a2609[ _k2609 ];
		quad.vehicle_weapon_override = "quadrotor_turret_rts_afghan";
		_k2609 = getNextArrayKey( _a2609, _k2609 );
	}
	quadsquad.squad_nonodecheckonmove = 1;
	quadsquad = getsquadbypkg( "quadrotor2_pkg", "allies" );
	_a2617 = quadsquad.members;
	_k2617 = getFirstArrayKey( _a2617 );
	while ( isDefined( _k2617 ) )
	{
		quad = _a2617[ _k2617 ];
		quad.vehicle_weapon_override = "quadrotor_turret_rts_afghan";
		_k2617 = getNextArrayKey( _a2617, _k2617 );
	}
	quadsquad.squad_nonodecheckonmove = 1;
}

afghanistan_hind_spawner()
{
	level waittill( self.script_noteworthy );
	maps/_so_rts_catalog::setpkgqty( self.script_noteworthy, "axis", 1 );
}

afghanistan_hind_spawning()
{
	spawn_nodes = getstructarray( "hind_spawn", "targetname" );
	_a2635 = spawn_nodes;
	_k2635 = getFirstArrayKey( _a2635 );
	while ( isDefined( _k2635 ) )
	{
		node = _a2635[ _k2635 ];
		if ( isDefined( node.script_parameters ) )
		{
			difficulty = getdifficulty();
			if ( !issubstr( node.script_parameters, difficulty ) )
			{
			}
		}
		else
		{
			node thread afghanistan_hind_spawner();
		}
		_k2635 = getNextArrayKey( _a2635, _k2635 );
	}
}

afghanistan_ant_spawnwatch()
{
	level endon( "rts_terminated" );
	maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", -1 );
	while ( 1 )
	{
		flag_wait( "turn_ants_off" );
		flag_clear( "turn_ants_on" );
/#
#/
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", 0 );
		flag_wait( "turn_ants_on" );
		flag_clear( "turn_ants_off" );
/#
#/
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_reg_pkg", "axis", -1 );
	}
}

afghanistan_rpg_onoff()
{
	level endon( "rts_terminated" );
	flag_wait( "rts_start_clock" );
	while ( 1 )
	{
		maps/_so_rts_catalog::setpkgqty( "infantry_afghan_rpg_pkg", "axis", -1 );
		level waittill( "rts_rpg_notavailable" );
		maps/_so_rts_catalog::setpkgqty( "infantry_afghan_rpg_pkg", "axis", 0 );
		level waittill( "rts_rpg_available" );
	}
}

afghanistan_ied_onoff()
{
	level endon( "rts_terminated" );
	flag_wait( "rts_start_clock" );
	while ( 1 )
	{
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_ied_pkg", "axis", 0 );
		level waittill( "ied_spawn_enabled" );
		maps/_so_rts_catalog::setpkgqty( "infantry_enemy_ied_pkg", "axis", -1 );
		level waittill( "ied_spawn_disabled" );
	}
}

afghanistan_horse_onoff()
{
	level endon( "rts_terminated" );
	flag_wait( "rts_start_clock" );
	while ( 1 )
	{
		maps/_so_rts_catalog::setpkgqty( "horse_enemy_pkg", "axis", 0 );
		level waittill( "horse_spawn_enabled" );
		maps/_so_rts_catalog::setpkgqty( "horse_enemy_pkg", "axis", -1 );
		level waittill( "horse_spawn_disabled" );
	}
}

badplace_manager()
{
	self endon( "death" );
	badplace_name = "convoy_" + self getentitynumber();
	radius = 300;
	height = 100;
	while ( 1 )
	{
		forward = anglesToForward( self.angles );
		offset = self.origin + ( forward * 256 );
		badplace_cylinder( badplace_name, 0,25, offset, radius, height, "all" );
/#
		thread maps/_so_rts_support::drawcylinder( offset, radius, height, 0,25 );
#/
		wait 0,25;
	}
}

afghanistancodespawner( pkg_ref, team, callback, squadid )
{
	switch( pkg_ref.ref )
	{
		case "missle_strike_pkg":
			origin = getstruct( "hamp_loc", "targetname" ).origin;
			squadid = maps/_so_rts_squad::createsquad( origin, team, pkg_ref );
			luinotifyevent( &"rts_add_squad", 3, squadid, pkg_ref.idx, 0 );
			_a2761 = pkg_ref.units;
			_k2761 = getFirstArrayKey( _a2761 );
			while ( isDefined( _k2761 ) )
			{
				unit = _a2761[ _k2761 ];
				ai_ref = level.rts.ai[ unit ];
				ai = maps/_so_rts_support::placevehicle( ai_ref.ref, origin, team );
				ai maps/_so_rts_squad::addaitosquad( squadid );
				ai.ai_ref = ai_ref;
				_k2761 = getNextArrayKey( _a2761, _k2761 );
			}
			level.rts.squads[ squadid ].squad_nonodecheckonmove = 1;
			level.rts.squads[ squadid ].squad_execute_cb = ::afghanistan_missileplatform;
			level.rts.squads[ squadid ].nextavailattack = 0;
			maps/_so_rts_catalog::units_delivered( team, squadid );
			level.rts.squads[ squadid ].selectable = 1;
			_a2774 = level.rts.squads[ squadid ].members;
			_k2774 = getFirstArrayKey( _a2774 );
			while ( isDefined( _k2774 ) )
			{
				unit = _a2774[ _k2774 ];
				unit.no_takeover = 1;
				unit.ignoreme = 1;
				unit.ignoreall = 1;
				unit.allow_oob = 1;
				unit.takedamage = 0;
				unit hide();
				_k2774 = getNextArrayKey( _a2774, _k2774 );
			}
			level.rts.squads[ squadid ].no_group_commands = 1;
			level.rts.squads[ squadid ].state = 7;
			level.rts.squads[ squadid ].nextstate = 7;
			break;
		case "metalstorm_pkg":
			spawn = getent( "asd_spawn_loc", "targetname" );
			squadid = maps/_so_rts_squad::createsquad( spawn.origin, team, pkg_ref );
			luinotifyevent( &"rts_add_squad", 3, squadid, pkg_ref.idx, 0 );
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			if ( convoy.members.size > 0 )
			{
			}
			else
			{
			}
			nodes = [];
			origin = spawn.origin;
			i = 0;
			_a2795 = pkg_ref.units;
			_k2795 = getFirstArrayKey( _a2795 );
			while ( isDefined( _k2795 ) )
			{
				unit = _a2795[ _k2795 ];
				if ( convoy.members.size )
				{
					if ( nodes.size > i )
					{
						origin = maps/_so_rts_support::find_ground_pos( nodes[ i ].origin + vectorScale( ( 0, 0, 1 ), 1000 ) );
						i++;
					}
				}
				ai_ref = level.rts.ai[ unit ];
				ai = maps/_so_rts_support::placevehicle( ai_ref.ref, origin, team );
				ai.angles = spawn.angles;
				ai.ai_ref = ai_ref;
				ai.vmaxspeedoverridge = 22;
				ai.vmaxaispeedoverridge = 12;
				ai maps/_so_rts_squad::addaitosquad( squadid );
				ai thread maps/_so_rts_squad::gotopoint( level.rts.squads[ squadid ].centerpoint );
				ai setthreatbiasgroup( "asds" );
				_k2795 = getNextArrayKey( _a2795, _k2795 );
			}
			maps/_so_rts_catalog::units_delivered( team, squadid );
			level.rts.squads[ squadid ].squad_nonodecheckonmove = 1;
			_a2819 = level.rts.squads[ squadid ].members;
			_k2819 = getFirstArrayKey( _a2819 );
			while ( isDefined( _k2819 ) )
			{
				unit = _a2819[ _k2819 ];
				unit.maxvisibledist = 2048;
				unit.maxsightdistsqrd = 4194304;
				_k2819 = getNextArrayKey( _a2819, _k2819 );
			}
			case "quadrotor2_pkg":
			case "quadrotor_pkg":
				spawn = getent( "quad_spawn_loc", "targetname" );
				squadid = maps/_so_rts_squad::createsquad( spawn.origin, team, pkg_ref );
				luinotifyevent( &"rts_add_squad", 3, squadid, pkg_ref.idx, 0 );
				convoy = getsquadbypkg( "convoy_pkg", "allies" );
				if ( convoy.members.size > 0 )
				{
				}
				else nodes = [];
				origin = spawn.origin;
				i = 0;
				_a2835 = pkg_ref.units;
				_k2835 = getFirstArrayKey( _a2835 );
				while ( isDefined( _k2835 ) )
				{
					unit = _a2835[ _k2835 ];
					if ( convoy.members.size )
					{
						if ( nodes.size > i )
						{
							origin = nodes[ i ].origin + vectorScale( ( 0, 0, 1 ), 72 );
							i++;
						}
					}
					ai_ref = level.rts.ai[ unit ];
					ai = maps/_so_rts_support::placevehicle( ai_ref.ref, origin, team );
					ai.angles = spawn.angles;
					ai.ai_ref = ai_ref;
					ai maps/_so_rts_squad::addaitosquad( squadid );
					ai thread maps/_so_rts_squad::gotopoint( level.rts.squads[ squadid ].centerpoint );
					ai.vehicle_weapon_override = "quadrotor_turret_rts_afghan";
					ai setvehweapon( ai.vehicle_weapon_override );
					ai setthreatbiasgroup( "quadrotors" );
					_k2835 = getNextArrayKey( _a2835, _k2835 );
				}
				maps/_so_rts_catalog::units_delivered( team, squadid );
				level.rts.squads[ squadid ].squad_nonodecheckonmove = 1;
				break;
			case "convoy_pkg":
				origin = getent( "rts_player_start", "targetname" ).origin;
				squadid = maps/_so_rts_squad::createsquad( origin, team, pkg_ref );
				spots = getstructarray( "convoy_gaz_spawn", "targetname" );
/#
				assert( spots.size >= pkg_ref.units.size );
#/
				i = 0;
				_a2866 = pkg_ref.units;
				_k2866 = getFirstArrayKey( _a2866 );
				while ( isDefined( _k2866 ) )
				{
					unit = _a2866[ _k2866 ];
					spot = spots[ i ];
					i++;
					ai_ref = level.rts.ai[ unit ];
					ai = maps/_so_rts_support::placevehicle( ai_ref.ref, spot.origin, team );
					ai.angles = spot.angles;
					ai.ai_ref = ai_ref;
					ai maps/_so_rts_squad::addaitosquad( squadid );
					if ( isDefined( spot.script_noteworthy ) )
					{
						ai.script_noteworthy = spot.script_noteworthy;
					}
					self.script_crashtypeoverride = "tank";
					ai.rollingdeath = 1;
					ai.no_takeover = 1;
					ai thread afghanistan_vehicle_think( i );
					ai thread badplace_manager();
					ai setthreatbiasgroup( pkg_ref.ref );
					_k2866 = getNextArrayKey( _a2866, _k2866 );
				}
				level.rts.squads[ squadid ].team = "neutral";
				maps/_so_rts_catalog::units_delivered( team, squadid );
				level.rts.squads[ squadid ].team = "allies";
				level.rts.squads[ squadid ].selectable = 0;
				level.rts.squads[ squadid ].forceallowselect = 1;
				i = 1;
				_a2894 = level.rts.squads[ squadid ].members;
				_k2894 = getFirstArrayKey( _a2894 );
				while ( isDefined( _k2894 ) )
				{
					truck = _a2894[ _k2894 ];
					if ( i == 1 )
					{
						truck.voxid = "alpha";
					}
					else if ( i == 2 )
					{
						truck.voxid = "bravo";
					}
					else if ( i == 3 )
					{
						truck.voxid = "charlie";
					}
					else
					{
						if ( i == 4 )
						{
							truck.voxid = "delta";
						}
					}
					truck thread convoy_dialogwatch();
					truck.maxvisibledist = 2048;
					truck.maxsightdistsqrd = 4194304;
					maps/_so_rts_poi::add_poi( "POI_CONVOY" + i, truck, "allies", 1, 0, 1 );
					truck.team = "allies";
					i++;
					_k2894 = getNextArrayKey( _a2894, _k2894 );
				}
				case "t72_convoy_pkg":
					spots = getentarray( "t72_convoy_loc", "targetname" );
					squadid = maps/_so_rts_squad::createsquad( spots[ 0 ].origin, team, pkg_ref );
					level.m_tanks = [];
					_a2924 = spots;
					_k2924 = getFirstArrayKey( _a2924 );
					while ( isDefined( _k2924 ) )
					{
						spot = _a2924[ _k2924 ];
						ai_ref = level.rts.ai[ pkg_ref.units[ 0 ] ];
						ai = maps/_so_rts_support::placevehicle( ai_ref.ref, spot.origin, team );
						if ( isDefined( ai ) )
						{
							level.m_tanks[ spot.script_noteworthy ] = ai;
							ai.script_noteworhty = spot.script_noteworthy + "_tank";
							ai.angles = spot.angles;
							ai.ai_ref = ai_ref;
							ai.allow_oob = 1;
							ai maps/_so_rts_squad::addaitosquad( squadid );
							ai setthreatbiasgroup( "tanks" );
							ai thread afghanistan_t72_convoy_unit( spot.script_noteworthy );
							ai thread afghanistan_enemy_vehicle_death( spot.script_noteworthy );
						}
						_k2924 = getNextArrayKey( _a2924, _k2924 );
					}
					maps/_so_rts_catalog::units_delivered( team, squadid );
					_a2942 = level.rts.squads[ squadid ].members;
					_k2942 = getFirstArrayKey( _a2942 );
					while ( isDefined( _k2942 ) )
					{
						unit = _a2942[ _k2942 ];
						unit.maxvisibledist = 2048;
						unit.maxsightdistsqrd = 4194304;
						_k2942 = getNextArrayKey( _a2942, _k2942 );
					}
					level notify( "tanks_spawned" );
					break;
				case "horse_enemy_pkg":
					vehicle_count = getvehiclearray().size;
					if ( vehicle_count >= 65 )
					{
						return -1;
					}
					spot = afghanistan_getspawnlocationforenemyhorses();
					if ( !isDefined( spot ) )
					{
						return -1;
					}
					squadid = maps/_so_rts_squad::createsquad( spot.spawn.origin, team, pkg_ref );
					_a2962 = pkg_ref.units;
					_k2962 = getFirstArrayKey( _a2962 );
					while ( isDefined( _k2962 ) )
					{
						unit = _a2962[ _k2962 ];
						ai_ref = level.rts.ai[ unit ];
						ai = maps/_so_rts_support::placevehicle( ai_ref.ref, spot.spawn.origin, team );
						if ( isDefined( ai ) )
						{
							ai.angles = spot.spawn.angles;
							ai.ai_ref = ai_ref;
							ai.no_sonar = 1;
							ai.unselectable = 1;
							ai maps/_so_rts_squad::addaitosquad( squadid );
							rider = ai afghanistan_horse_init( spot );
							maps/_so_rts_support::addadditionaltarget( rider, team );
							remove = 1;
						}
						_k2962 = getNextArrayKey( _a2962, _k2962 );
					}
					if ( isDefined( remove ) && remove )
					{
						afghanistan_removespawnloc( spot );
					}
					maps/_so_rts_catalog::units_delivered( team, squadid );
					_order_new_squad( squadid, spot );
					maps/_so_rts_event::trigger_event( "dlg_announce_horse" );
					break;
				case "infantry_ally_reg_pkg":
					squadid = maps/_so_rts_squad::createsquad( level.rts.player_startpos, team, pkg_ref );
					_a2990 = pkg_ref.units;
					_k2990 = getFirstArrayKey( _a2990 );
					while ( isDefined( _k2990 ) )
					{
						unit = _a2990[ _k2990 ];
						ai_ref = level.rts.ai[ unit ];
						ai = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
						if ( isDefined( ai ) )
						{
							ai forceteleport( level.rts.player_startpos );
							ai.ai_ref = ai_ref;
							ai maps/_so_rts_squad::addaitosquad( squadid );
							ai.dropweapon = 0;
							ai.ignoreme = 1;
							if ( level.debug == 0 )
							{
								ai.no_takeover = 1;
							}
						}
						_k2990 = getNextArrayKey( _a2990, _k2990 );
					}
					maps/_so_rts_catalog::units_delivered( team, squadid );
					break;
				case "infantry_afghan_rpg_pkg":
					spot = afghanistan_getspawnlocationforenemyrpg();
					if ( !isDefined( spot ) )
					{
						return -1;
				}
				case "infantry_enemy_ied_pkg":
					if ( !isDefined( spot ) )
					{
						spot = afghanistan_getspawnlocationforenemyinfantry();
					}
					if ( !isDefined( spot ) )
					{
						return -1;
					}
					squadid = maps/_so_rts_squad::createsquad( spot.spawn.origin, team, pkg_ref );
					_a3020 = pkg_ref.units;
					_k3020 = getFirstArrayKey( _a3020 );
					while ( isDefined( _k3020 ) )
					{
						unit = _a3020[ _k3020 ];
						ai_ref = level.rts.ai[ unit ];
						ai = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
						if ( isDefined( ai ) )
						{
							ai forceteleport( spot.spawn.origin );
							ai.ai_ref = ai_ref;
							ai maps/_so_rts_squad::addaitosquad( squadid );
							ai.dropweapon = 0;
							ai setthreatbiasgroup( pkg_ref.ref );
							ai.animname = "celebrating_muj";
							remove = 1;
						}
						_k3020 = getNextArrayKey( _a3020, _k3020 );
					}
					if ( isDefined( remove ) && remove )
					{
						afghanistan_removespawnloc( spot );
					}
					maps/_so_rts_catalog::units_delivered( team, squadid );
					_order_new_squad( squadid, spot );
					break;
				case "desert_hind_1":
				case "desert_hind_2":
				case "desert_hind_3":
				case "desert_hind_4":
				case "valley_hind_1":
				case "valley_hind_2":
				case "valley_hind_3":
				case "valley_hind_final":
					node = getstruct( pkg_ref.ref, "script_noteworthy" );
					squadid = maps/_so_rts_squad::createsquad( node.origin, team, pkg_ref );
					if ( !isDefined( level.m_helis ) )
					{
						level.m_helis = [];
					}
					_a3058 = pkg_ref.units;
					_k3058 = getFirstArrayKey( _a3058 );
					while ( isDefined( _k3058 ) )
					{
						unit = _a3058[ _k3058 ];
						ai_ref = level.rts.ai[ unit ];
						ai = maps/_so_rts_support::placevehicle( ai_ref.ref, node.origin, team );
						ai setthreatbiasgroup( "helis" );
						level.m_helis[ pkg_ref.ref ] = ai;
						if ( isDefined( ai ) )
						{
							ai.angles = node.angles;
							ai.ai_ref = ai_ref;
							ai maps/_so_rts_squad::addaitosquad( squadid );
							ai thread afghanistan_heli_path( node );
						}
						_k3058 = getNextArrayKey( _a3058, _k3058 );
					}
					maps/_so_rts_catalog::units_delivered( team, squadid );
					_a3074 = level.rts.squads[ squadid ].members;
					_k3074 = getFirstArrayKey( _a3074 );
					while ( isDefined( _k3074 ) )
					{
						unit = _a3074[ _k3074 ];
						unit.maxvisibledist = 5000;
						unit.maxsightdistsqrd = 25000000;
						_k3074 = getNextArrayKey( _a3074, _k3074 );
					}
					case "infantry_enemy_reg_pkg":
/#
						assert( 0, "legacy code spawn" );
#/
						default:
/#
							assert( 0, "Unhandled code spawn" );
#/
							break;
					}
					if ( isDefined( callback ) )
					{
						thread [[ callback ]]( squadid );
					}
					return squadid;
				}
			}
		}
	}
}

_order_new_squad( squadid, spot )
{
	squad = maps/_so_rts_squad::getsquad( squadid );
	unit = maps/_so_rts_enemy::create_units_from_squad( squadid );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	if ( isDefined( unit ) || unit.members.size == 0 && flag( "rts_afghan_fail" ) )
	{
		return;
	}
	squad.nextstate = 7;
	if ( squad.pkg_ref.ref == "horse_enemy_pkg" )
	{
		dist = 6000 + 1024;
	}
	else
	{
		dist = 4096 + 1024;
	}
	distsq = dist * dist;
	_a3117 = unit.members;
	_k3117 = getFirstArrayKey( _a3117 );
	while ( isDefined( _k3117 ) )
	{
		guy = _a3117[ _k3117 ];
		guy thread afghan_autokillondist( distsq );
		guy.goalradius = 512;
		guy.maxvisibledist = 8192;
		guy.maxsightdistsqrd = 67108864;
		guy.pathenemyfightdist = 1024;
		guy.goodenemyonly = 0;
		_k3117 = getNextArrayKey( _a3117, _k3117 );
	}
	switch( squad.pkg_ref.ref )
	{
		case "infantry_afghan_rpg_pkg":
			if ( isDefined( spot.goalpos ) )
			{
				pos = spot.goalpos;
			}
			else
			{
				maps/_so_rts_squad::removedeadfromsquad( convoy.id );
				pos = undefined;
			}
			level thread unit_keep_distancefromconvoy( unit, pos );
			break;
		case "infantry_enemy_ied_pkg":
			level thread unit_plant_ieds( unit );
			level thread unit_think( unit );
			break;
		case "horse_enemy_pkg":
			if ( isDefined( spot.goalpos ) )
			{
				position = spot.goalpos;
			}
			else
			{
				maps/_so_rts_squad::removedeadfromsquad( convoy.id );
				position = convoy.members[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 24 );
			}
			horse_unitdisperse( unit, position );
			break;
		default:
			if ( isDefined( spot.goalpos ) )
			{
				pos = spot.goalpos;
			}
			else
			{
				maps/_so_rts_squad::removedeadfromsquad( convoy.id );
				pos = undefined;
			}
			level thread unit_think( unit, pos );
			break;
	}
}

ai_keep_distancefromconvoy( center )
{
	level endon( "rts_terminated" );
	self endon( "death" );
	if ( isDefined( center ) )
	{
		self waittill( "goal" );
	}
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	while ( convoy.members.size > 0 )
	{
		maps/_so_rts_squad::removedeadfromsquad( convoy.id );
		if ( self.origin[ 2 ] > convoy.members[ 0 ].origin[ 2 ] )
		{
			diff = self.origin[ 2 ] - convoy.members[ 0 ].origin[ 2 ];
		}
		else
		{
			diff = convoy.members[ 0 ].origin[ 2 ] - self.origin[ 2 ];
		}
		while ( diff < 48 )
		{
			distsq = distancesquared( convoy.members[ 0 ].origin, self.origin );
			while ( distsq < 490000 || distsq > 4000000 )
			{
				nodes = getnodesinradius( convoy.members[ 0 ].origin, 1800, 512, 300 );
				while ( nodes.size > 0 )
				{
					_a3195 = nodes;
					_k3195 = getFirstArrayKey( _a3195 );
					while ( isDefined( _k3195 ) )
					{
						node = _a3195[ _k3195 ];
						if ( findpath( self.origin, node.origin ) )
						{
							goalpos = node.origin;
/#
							thread maps/_so_rts_support::debugline( self.origin, goalpos, ( 1, 0,64, 0 ), 50 );
							thread maps/_so_rts_support::debug_sphere( goalpos, 32, ( 1, 0,64, 0 ), 0,5, 50 );
#/
							self setgoalpos( goalpos );
							self waittill( "goal" );
						}
						else
						{
							wait 0,1;
						}
						_k3195 = getNextArrayKey( _a3195, _k3195 );
					}
				}
			}
		}
		wait 10;
	}
}

unit_keep_distancefromconvoy( unit, center )
{
	if ( isDefined( center ) )
	{
		maps/_so_rts_enemy::unitdisperse( unit, center );
	}
	_a3225 = unit.members;
	_k3225 = getFirstArrayKey( _a3225 );
	while ( isDefined( _k3225 ) )
	{
		guy = _a3225[ _k3225 ];
		guy thread ai_keep_distancefromconvoy( center );
		_k3225 = getNextArrayKey( _a3225, _k3225 );
	}
}

unit_think( unit, center )
{
	level endon( "rts_terminated" );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	if ( isDefined( center ) )
	{
		maps/_so_rts_enemy::unitdisperse( unit, center );
		wait 10;
	}
	_a3242 = unit.members;
	_k3242 = getFirstArrayKey( _a3242 );
	while ( isDefined( _k3242 ) )
	{
		guy = _a3242[ _k3242 ];
		guy.targetmode = randomint( 3 );
		_k3242 = getNextArrayKey( _a3242, _k3242 );
	}
	while ( unit.members.size > 0 && convoy.members.size > 0 )
	{
		maps/_so_rts_squad::removedeadfromsquad( convoy.id );
		valid = [];
		_a3251 = unit.members;
		_k3251 = getFirstArrayKey( _a3251 );
		while ( isDefined( _k3251 ) )
		{
			guy = _a3251[ _k3251 ];
			if ( isDefined( guy ) )
			{
				guy.goalradius = 512;
				valid[ valid.size ] = guy;
			}
			_k3251 = getNextArrayKey( _a3251, _k3251 );
		}
		unit.members = valid;
		_a3260 = unit.members;
		_k3260 = getFirstArrayKey( _a3260 );
		while ( isDefined( _k3260 ) )
		{
			guy = _a3260[ _k3260 ];
			if ( isDefined( guy.busy ) && guy.busy )
			{
			}
			else
			{
				switch( guy.targetmode )
				{
					case 0:
						position = convoy.members[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 24 );
						break;
					case 1:
						if ( isDefined( convoy.members[ 0 ].currentnode ) )
						{
							position = convoy.members[ 0 ].currentnode.origin;
						}
						else
						{
							position = convoy.members[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 24 );
						}
						break;
					case 2:
						if ( isDefined( convoy.members[ 0 ].nextnode ) )
						{
							position = convoy.members[ 0 ].nextnode.origin;
						}
						else
						{
							position = convoy.members[ 0 ].origin + vectorScale( ( 0, 0, 1 ), 24 );
						}
						break;
				}
				guy setgoalpos( position );
			}
			_k3260 = getNextArrayKey( _a3260, _k3260 );
		}
		wait 10;
	}
}

horse_unitdispersetolocation( origin )
{
	self endon( "death" );
/#
	assert( isDefined( origin ) );
#/
	while ( isDefined( self.rider_initialized ) && !self.rider_initialized )
	{
		wait 0,05;
	}
/#
	thread maps/_so_rts_support::debug_sphere( origin, 10, ( 0, 0, 1 ), 0,6, 3 );
#/
	self.goalradius = 512;
	self setvehgoalpos( origin, 1, 1 );
	self.unitid = undefined;
}

horse_unitdisperse( unit, position )
{
/#
	println( "Unit " + unit.unitid + " dispersing at" + position );
#/
	alive = [];
	i = 0;
	while ( i < unit.members.size )
	{
		if ( !isDefined( unit.members[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( is_corpse( unit.members[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			alive[ alive.size ] = unit.members[ i ];
		}
		i++;
	}
	unit.members = alive;
	nodes = getnodesinradius( position, 1024, 0, 256, "Cover" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradius( position, 1024, 0, 256 );
	}
	_a3336 = unit.members;
	_k3336 = getFirstArrayKey( _a3336 );
	while ( isDefined( _k3336 ) )
	{
		guy = _a3336[ _k3336 ];
		if ( nodes.size > 0 )
		{
			spot = nodes[ randomint( nodes.size ) ];
			position = spot.origin;
			guy thread horse_unitdispersetolocation( position );
		}
		_k3336 = getNextArrayKey( _a3336, _k3336 );
	}
	unit.destroyed = 1;
	unit.members = [];
	arrayremovevalue( level.rts.nag_units, unit );
	arrayremovevalue( level.rts.enemy_units, unit );
}

afghan_ied_detonate()
{
	self.takedamage = 0;
	maps/_so_rts_event::trigger_event( "fx_ied_explode", self.origin );
	maps/_so_rts_event::trigger_event( "sfx_ied_explode" );
	earthquake( 0,5, 2, self.origin, 1000 );
	damage = get_ied_damage_amount();
	if ( !flag( "innocuous_ieds" ) )
	{
		radiusdamage( self.origin + vectorScale( ( 0, 0, 1 ), 15 ), 512, damage, damage, self, "MOD_EXPLOSIVE" );
	}
	if ( isDefined( self.trigger ) )
	{
		self.trigger delete();
	}
	maps/_so_rts_support::deladditionaltarget( self, "axis" );
	self setclientflag( 8 );
	wait 0,2;
	self delete();
}

afghan_iedtriggerthink( ied )
{
	ied endon( "death" );
	self waittill( "trigger", entity );
	if ( isDefined( entity ) )
	{
		if ( entity.team != level.rts.player.team )
		{
			self thread afghan_iedtriggerthink( ied );
			return;
		}
		level notify( "ied_exploded" );
		if ( isDefined( entity.vehicletype ) )
		{
			if ( issubstr( entity.vehicletype, "cougar" ) )
			{
				level notify( "ied_hit_convoy" );
			}
		}
		self delete();
		ied.trigger = undefined;
		ied afghan_ied_detonate();
	}
}

get_ied_damage_amount()
{
	difficulty = getdifficulty();
	switch( difficulty )
	{
		case "easy":
			return 10000;
		case "hard":
			return 14500;
		case "fu":
			return 15000;
		case "medium":
		default:
			return 12000;
	}
}

afghan_iedthink()
{
/#
	println( "@@@@ (" + getTime() + ") IED planted at " + self.origin );
#/
	self.takedamage = 1;
	self.health = 10;
	self maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 0 );
	self.rts_unloaded = 1;
	self.initialized = 1;
	maps/_so_rts_support::addadditionaltarget( self, "axis" );
	self.trigger = spawn( "trigger_radius", self.origin - vectorScale( ( 0, 0, 1 ), 32 ), 24, 64, 512 );
	self.trigger thread afghan_iedtriggerthink( self );
	self thread afghan_iedwarningradiusthink( 1000 );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker );
/#
		if ( isDefined( self.objid ) )
		{
		}
		else
		{
		}
		println( self.objid + "NA", "@@@@ (" + getTime() + ") IED damage at " + self.origin + "Objective:" );
#/
		if ( isDefined( attacker ) && attacker != self )
		{
			self afghan_ied_detonate();
		}
	}
}

afghan_plant_ieds()
{
	self endon( "death" );
	self.busy = 1;
	level.rts.iedlocs = maps/_so_rts_support::sortarraybyclosest( self.origin, level.rts.iedlocs );
	if ( level.rts.iedlocs.size == 0 )
	{
		self.ied_planted = 1;
		return;
	}
	iedspot = level.rts.iedlocs[ 0 ];
	arrayremoveindex( level.rts.iedlocs, 0 );
	self.so_old_goalradius = self.goalradius;
	self.goalradius = 16;
	self setgoalpos( iedspot.origin );
	self ent_flag_init( "planting_ied", 1 );
	self waittill( "goal" );
	self animcustom( ::ai_ied_plant, ::ai_ied_plant_post_func );
}

ai_ied_plant()
{
	self endon( "death" );
	ied = spawn_model( "p_jun_suicide_rts", self gettagorigin( "tag_inhand" ), self gettagangles( "tag_inhand" ) );
	if ( !isDefined( ied ) )
	{
		self.goalradius = 512;
		return;
	}
	ied linkto( self, "tag_inhand", ( 0, 0, 1 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	ied.script_noteworthy = "ied";
	self.ied = ied;
/#
	recordent( ied );
#/
	self.a.movement = "stop";
	self.ignoreall = 1;
	self thread ai_ied_plant_cleanup( ied );
	self clearanim( %root, 0,2 );
	self setflaggedanimknobrestart( "plantAnim", %ai_plant_claymore, 1, 0,2, 1 );
	self animscripts/shared::donotetracks( "plantAnim", ::ai_ied_handle_notetracks, undefined, ied );
	self animscripts/combat_utility::lookforbettercover( 0 );
}

ai_ied_plant_cleanup( ied )
{
	self endon( "death" );
	self waittill( "planting_ied" );
	ied unlink();
}

ai_ied_handle_notetracks( notetrack, ied )
{
	if ( notetrack == "plant" )
	{
		self notify( "planting_ied" );
		if ( isDefined( ied ) )
		{
			ied ignorecheapentityflag( 1 );
			ied.team = "axis";
		}
		self.ignoreall = 0;
		if ( isDefined( ied ) )
		{
			ied thread afghan_iedthink();
		}
	}
}

ai_ied_plant_post_func()
{
	self endon( "death" );
	self.ied_planted = 1;
	wait 1;
	self ent_flag_clear( "planting_ied" );
	self.goalradius = self.so_old_goalradius;
	nodes = getnodesinradius( self.origin, 1024, 0, 256, "Cover" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradius( self.origin, 1024, 0, 256 );
	}
	if ( nodes.size )
	{
		self setgoalnode( nodes[ randomint( nodes.size ) ] );
	}
	self.busy = undefined;
}

unit_plant_ieds( unit )
{
/#
	assert( unit.members.size <= 2, "more than two probably wont work very well" );
#/
	_a3565 = unit.members;
	_k3565 = getFirstArrayKey( _a3565 );
	while ( isDefined( _k3565 ) )
	{
		guy = _a3565[ _k3565 ];
		guy thread afghan_plant_ieds();
		_k3565 = getNextArrayKey( _a3565, _k3565 );
	}
}

afghanistan_convoy( squadid )
{
	return 0;
}

afghanistan_missileplatform( squadid )
{
	origin = getstruct( "hamp_loc", "targetname" ).origin;
	squad = maps/_so_rts_squad::getsquad( squadid );
	centerpoint = level.rts.squads[ squadid ].centerpoint;
	squad.centerpoint = ( squad.centerpoint[ 0 ], squad.centerpoint[ 1 ], origin[ 2 ] );
	ret = 1;
	switch( squad.nextstate )
	{
		case 4:
			afghanistan_missileplatformattack( squadid, level.rts.squads[ squadid ].target.origin, level.rts.squads[ squadid ].target );
			ret = 0;
			break;
		case 1:
		case 2:
			afghanistan_missileplatformattack( squadid, centerpoint );
			ret = 0;
			break;
		case 3:
		case 5:
		case 7:
			maps/_so_rts_squad::reissuesquadlastorders( squadid );
			ret = 0;
			break;
	}
	return ret;
}

rocket_expl()
{
	origin = self.origin;
	while ( isDefined( self ) )
	{
		origin = self.origin;
		wait 0,05;
	}
	angles = vectorScale( ( 0, 0, 1 ), 90 );
	play_fx( "fx_rts_exp_godrod_dirt", origin, angles );
	radiusdamage( origin + vectorScale( ( 0, 0, 1 ), 15 ), 768, 1000, 800, undefined, "MOD_EXPLOSIVE" );
}

afghanistan_missileplatformattack( squadid, hitdest, targetent )
{
	squad = level.rts.squads[ squadid ];
	origin = getstruct( "hamp_loc", "targetname" ).origin;
	if ( !isDefined( hitdest ) )
	{
		return 0;
	}
	if ( isDefined( squad.selectable ) && !squad.selectable )
	{
		return 0;
	}
	squad.centerpoint = ( hitdest[ 0 ], hitdest[ 1 ], origin[ 2 ] );
	cost = squad.pkg_ref.cost[ squad.team ];
	time = getTime();
	if ( squad.nextavailattack > time )
	{
		return 0;
	}
	level notify( "HandOfNOD_ATTACK" );
	squad.nextavailattack = time + cost;
	_a3640 = level.rts.squads[ squadid ].members;
	_k3640 = getFirstArrayKey( _a3640 );
	while ( isDefined( _k3640 ) )
	{
		unit = _a3640[ _k3640 ];
		unit.goalradius = 1024;
		unit setvehgoalpos( squad.centerpoint, 1 );
		unit waittill_any_or_timeout( 15, "goal" );
		if ( distancesquared( unit.origin, squad.centerpoint ) <= 1102500 )
		{
			if ( isDefined( targetent ) )
			{
				rocket = magicbullet( "rts_missile_sp", unit.origin + vectorScale( ( 0, 0, 1 ), 256 ), targetent.origin, unit, targetent );
			}
			else
			{
				rocket = magicbullet( "rts_missile_sp", unit.origin + vectorScale( ( 0, 0, 1 ), 256 ), hitdest, unit );
			}
			rocket.owner = squad.members[ 0 ];
			rocket thread rocket_expl();
			maps/_so_rts_squad::movesquadmarker( squadid, 1 );
			level notify( "HandOfNOD_LAUNCHED" );
			return 1;
		}
		else
		{
			squad.centerpoint = ( level.rts.player.origin[ 0 ], level.rts.player.origin[ 1 ], origin[ 2 ] );
			unit setvehgoalpos( squad.centerpoint, 1 );
			level notify( "HandOfNOD_LAUNCH_ABORT" );
			return 0;
		}
		_k3640 = getNextArrayKey( _a3640, _k3640 );
	}
}

ai_rider_think( vh_horse )
{
	self endon( "death" );
	self animscripts/utility::setsecondaryweapon( "rpg_sp_rts" );
	self animscripts/init::initweapon( self.secondaryweapon );
	self animscripts/shared::placeweaponon( self.secondaryweapon, "back" );
	self.dropweapon = 0;
	vh_horse waittill( "goal" );
	self ai_dismount_horse( vh_horse );
	self thread afghan_plant_ieds();
	while ( isDefined( self.ied_planted ) && !self.ied_planted )
	{
		wait 0,05;
	}
	if ( self.weapon != "rpg_sp_rts" )
	{
		self.a.weapon_switch_asap = 1;
		self waittill( "weapon_switched" );
	}
}

ai_mount_immediate( vh_horse )
{
	self enter_vehicle( vh_horse );
	vh_horse notify( "has_rider" );
	vh_horse notify( "groupedanimevent" );
	self maps/_horse_rider::ride_and_shoot( vh_horse );
}

ai_mount_horse( vh_horse )
{
	self endon( "death" );
	self run_to_vehicle_load( vh_horse );
	while ( !isDefined( vh_horse get_driver() ) )
	{
		wait 0,05;
	}
	self notify( "on_horse" );
	vh_horse notify( "has_rider" );
	vh_horse notify( "groupedanimevent" );
	wait 0,1;
	self maps/_horse_rider::ride_and_shoot( vh_horse );
}

ai_dismount_horse( vh_horse )
{
	self endon( "death" );
	self notify( "stop_riding" );
	self notify( "off_horse" );
	vh_horse vehicle_unload( 0,1 );
	vh_horse waittill( "unloaded" );
}

ai_horse_killer()
{
	self endon( "death" );
	self waittill( "has_rider" );
	while ( isDefined( self get_driver() ) )
	{
		wait 0,05;
	}
	while ( 1 )
	{
		angles = level.rts.player getplayerangles();
		vieworg = level.rts.player.origin;
		v_forward = anglesToForward( angles );
		v_dir = vectornormalize( self.origin - vieworg );
		dot = vectordot( v_forward, v_dir );
		if ( dot < 0,6 )
		{
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	self dodamage( self.health + 1, self.origin );
}

afghanistan_horse_path( start_node )
{
	if ( !isDefined( start_node.target ) )
	{
		return;
	}
	next_node = getent( start_node.target, "targetname" );
	self setvehgoalpos( next_node.origin );
	self waittill( "goal" );
	next_node = getent( next_node.target, "targetname" );
}

get_num_horses_per_rpg()
{
	difficulty = getdifficulty();
	switch( difficulty )
	{
		case "fu":
			return 2;
		case "hard":
		case "medium":
			return 3;
		case "easy":
		default:
			return 10;
	}
}

afghanistan_horse_init( spot )
{
	self endon( "death" );
	self setneargoalnotifydist( 300 );
	self makevehicleunusable();
	self setspeedimmediate( 25 );
	self thread ai_horse_killer();
	if ( !isDefined( level.m_num_horses_spawned ) )
	{
		level.m_num_horses_spawned = 0;
	}
	level.m_num_horses_spawned++;
	num_horses_per_rpg = get_num_horses_per_rpg();
	if ( ( level.m_num_horses_spawned % num_horses_per_rpg ) == 0 )
	{
		ai_rider = simple_spawn_single( "ai_afghan_rpg_spawner", undefined, undefined, undefined, undefined, undefined, undefined, 1 );
		ai_rider.horse_shoot_wait_time = 4;
	}
	else
	{
		ai_rider = simple_spawn_single( "ai_afghan_assault_spawner", undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	}
	if ( isDefined( ai_rider ) )
	{
		if ( self.team == "allies" )
		{
		}
		else
		{
		}
		ai_rider maps/_so_rts_support::set_gpr( 1 + 0, maps/_so_rts_support::make_gpr_opcode( 1 ) );
		ai_rider.team = "axis";
		if ( isDefined( spot.spawn.script_parameters ) && issubstr( spot.spawn.script_parameters, "unmounted" ) )
		{
			nodes = getnodesinradius( self.origin, 256, 0, 128 );
			ai_rider forceteleport( nodes[ randomint( nodes.size ) ].origin, ai_rider.angles );
			ai_rider ai_mount_horse( self );
		}
		else
		{
			ai_rider thread ai_mount_immediate( self );
			self delay_thread( 0,5, ::afghanistan_horse_path, spot );
		}
		ai_rider thread ai_rider_think( self );
		ai_rider.rts_unloaded = 1;
		ai_rider.initialized = 1;
	}
	self.rider_initialized = 1;
	return ai_rider;
}

afghanistan_vehicle_takeoverwatch()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "taken_control_over" );
	}
}

afghanistan_vehicle_ied_watch()
{
	self endon( "death" );
	speed = self getspeedmph();
	while ( 1 )
	{
		level waittill( "ied_exploded", entity );
		while ( entity != self )
		{
			continue;
		}
	}
}

afghanistan_allied_vehicle_death()
{
	level endon( "mission_success" );
	self waittill( "death" );
	maps/_so_rts_event::trigger_event( "fx_ied_explode", self.origin );
	wait 0,2;
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	maps/_so_rts_squad::removedeadfromsquad( convoy.id );
	if ( convoy.members.size > 0 )
	{
/#
		assert( isDefined( convoy.members[ 0 ] ) );
#/
		set_objective( level.obj_protect_hvc, convoy.members[ 0 ], "*", convoy.members.size );
		_a3912 = level.rts.squads;
		_k3912 = getFirstArrayKey( _a3912 );
		while ( isDefined( _k3912 ) )
		{
			squad = _a3912[ _k3912 ];
			if ( isDefined( squad.foltarget ) && squad.foltarget == self )
			{
				maps/_so_rts_squad::ordersquadfollowai( squad.id, convoy.members[ 0 ] );
			}
			_k3912 = getNextArrayKey( _a3912, _k3912 );
		}
	}
	else set_objective( level.obj_protect_hvc, undefined, "failed" );
	set_objective( level.obj_escort2, undefined, "failed" );
	if ( !flag( "rts_afghan_fail" ) )
	{
		self delete();
	}
}

afghanistan_enemy_vehicle_death( name )
{
	self waittill( "death" );
	if ( !flag( "rts_afghan_outro" ) )
	{
		maps/_so_rts_event::trigger_event( "fx_ied_explode", self.origin );
		if ( name == "t72_unit1" )
		{
			level notify( "horse_spawn_enabled" );
		}
	}
}

afghanistan_vehicle_think( i )
{
	level endon( "skip_to" );
	self endon( "death" );
	self.drivepath = 1;
	self thread afghanistan_allied_vehicle_death();
	self thread afghanistan_vehicle_ied_watch();
	self thread afghanistan_vehicle_takeoverwatch();
	self pathvariableoffset( vectorScale( ( 0, 0, 1 ), 50 ), randomintrange( 15, 30 ) );
	self thread go_path( getvehiclenode( "rts_convoy_start", "targetname" ) );
	self waittill( "reached_end_node" );
/#
	assert( isDefined( level.rts.endlocs_route1[ 0 ] ) );
#/
	spot = level.rts.endlocs_route1[ 0 ];
	arrayremoveindex( level.rts.endlocs_route1, 0 );
	self.drivepath = 0;
	self setvehgoalpos( spot.origin, 1 );
	self waittill_any( "goal" );
	spot delete();
}

afghanistan_convoy_leaddeath()
{
	squadid = self.squadid;
	self waittill( "death" );
	maps/_so_rts_squad::removedeadfromsquad( squadid );
	if ( level.rts.squads[ squadid ].size > 0 )
	{
		if ( isDefined( level.rts.squads[ squadid ].members[ 0 ] ) )
		{
			level.rts.squads[ squadid ].members[ 0 ] thread afghanistan_convoy_leadupdate();
		}
	}
}

afghanistan_convoy_leadupdate()
{
	self endon( "death" );
	self thread afghanistan_convoy_leaddeath();
	while ( 1 )
	{
		if ( isDefined( self.currentnode ) && isDefined( self.currentnode.target ) )
		{
			node = getvehiclenode( self.currentnode.target, "targetname" );
			level.rts.squads[ self.squadid ].centerpoint = node.origin;
		}
		else
		{
			level.rts.squads[ self.squadid ].centerpoint = self.origin;
		}
/#
		thread maps/_so_rts_support::debug_sphere( level.rts.squads[ self.squadid ].centerpoint, 60, ( 0, 0, 1 ) );
		thread maps/_so_rts_support::debug_circle( level.rts.squads[ self.squadid ].centerpoint + vectorScale( ( 0, 0, 1 ), 250 ), 4096, ( 0, 0, 1 ) );
		thread maps/_so_rts_support::debug_circle( level.rts.squads[ self.squadid ].centerpoint + vectorScale( ( 0, 0, 1 ), 250 ), 6000, ( 0, 0, 1 ) );
#/
		wait 0,05;
	}
}

afghanistan_hind_think()
{
/#
#/
	target_set( self );
	self.takedamage = 1;
	self thread afghanistan_hind_movement();
	self thread afghanistan_hind_fire_update();
	self thread afghanistan_hind_damage_watcher();
}

circle_target()
{
	self notify( "movementUpdate" );
	self endon( "movementUpdate" );
	self endon( "death" );
	self clearlookatent();
	while ( !isDefined( self.cur_target ) )
	{
		wait 1;
	}
	self.heliheightlockoffset = randomfloatrange( 500, 1000 );
	vec_from_target = self.origin - self.cur_target.origin;
	yaw = vectorToAngle( vec_from_target )[ 1 ];
	if ( lengthsquared( vec_from_target ) < 4000000 )
	{
		yaw += 180;
	}
	while ( 1 )
	{
		offset = anglesToForward( ( 0, yaw, 0 ) );
		while ( !isDefined( self.cur_target ) )
		{
			wait 1;
		}
		goal = self.cur_target.origin;
		yaw += 2;
		goal += offset * 2000;
		ret = maps/_so_rts_support::clamporigintomapboundary( goal );
		self setvehgoalpos( ( ret.origin[ 0 ], ret.origin[ 1 ], self.cur_target.origin[ 2 ] + 1500 ), 1 );
		self cleartargetyaw();
		wait 0,1;
	}
}

delete_after_time( n_time )
{
	self endon( "death" );
	wait n_time;
	self delete();
}

heli_deploy_flares( missile )
{
	self endon( "death" );
	if ( !isDefined( missile ) )
	{
		return;
	}
	vec_toforward = anglesToForward( self.angles );
	vec_toright = anglesToRight( self.angles );
	self.chaff_fx = spawn( "script_model", self.origin );
	self.chaff_fx.angles = vectorScale( ( 0, 0, 1 ), 180 );
	self.chaff_fx setmodel( "tag_origin" );
	self.chaff_fx linkto( self, "tag_origin", vectorScale( ( 0, 0, 1 ), 120 ), ( 0, 0, 1 ) );
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
	self.chaff_target = spawn( "script_model", self.chaff_fx.origin );
	self.chaff_target setmodel( "tag_origin" );
	self.chaff_target movegravity( velocity, 5 );
	self.chaff_fx thread delete_after_time( 5 );
	wait 0,1;
	n_odds = 10;
	n_chance = randomint( n_odds );
	if ( n_chance < 8 )
	{
		self.chaff_fx thread play_flares_fx();
		missile missile_settarget( self.chaff_target );
		wait 0,5;
		if ( isDefined( self.chaff_target ) )
		{
			self.chaff_target delete();
		}
		if ( isDefined( missile ) )
		{
			missile missile_settarget( undefined );
		}
		wait 1;
		if ( isDefined( missile ) )
		{
			missile resetmissiledetonationtime( 0 );
		}
	}
}

play_flares_fx()
{
	self endon( "death" );
	i = 0;
	while ( i < 3 )
	{
		playfxontag( level._effect[ "aircraft_flares" ], self, "tag_origin" );
		self playsound( "veh_huey_chaff_explo_npc" );
		wait 0,25;
		i++;
	}
}

setup_defenses()
{
	self endon( "movementUpdate" );
	self endon( "death" );
	while ( isDefined( self.last_attacker ) )
	{
		level.player waittill( "missile_fire", missile );
		self thread heli_deploy_flares( missile );
		wait 2,5;
	}
}

set_hind_goal_pos_wrapper( position )
{
	nodes = getnodesinradiussorted( position, 500, 0, 1000, "Path" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradiussorted( position, 1000, 0, 2000, "Path" );
	}
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradiussorted( position, 5000, 0, 5000, "Path" );
	}
	while ( nodes.size > 0 )
	{
		_a4198 = nodes;
		_k4198 = getFirstArrayKey( _a4198 );
		while ( isDefined( _k4198 ) )
		{
			node = _a4198[ _k4198 ];
			if ( node.type == "BAD NODE" || !node has_spawnflag( 2097152 ) )
			{
			}
			else
			{
				if ( !self setvehgoalpos( node.origin, 1, 2, 1 ) )
				{
					self setvehgoalpos( node.origin, 1 );
				}
			}
			_k4198 = getNextArrayKey( _a4198, _k4198 );
		}
	}
}

attack_special_target( attack_duration )
{
	level endon( "rts_terminated" );
	self notify( "movementUpdate" );
	self endon( "movementUpdate" );
	self endon( "death" );
	self thread setup_defenses();
	self clearvehgoalpos();
	self cancelaimove();
	self maps/_turret::add_turret_priority_target( self.last_attacker, 0 );
	self setgunnertargetent( self.last_attacker, vectorScale( ( 0, 0, 1 ), 20 ), 0 );
	self setgunnertargetent( self.last_attacker, vectorScale( ( 0, 0, 1 ), 20 ), 1 );
	while ( isDefined( self.last_attacker ) && attack_duration > 0 )
	{
		self setlookatent( self.last_attacker );
		vec_to_attacker = self.last_attacker.origin - self.origin;
		vec_to_attacker = vectornormalize( vec_to_attacker );
		if ( self.last_attacker isvehicle() )
		{
			driver = self.last_attacker getseatoccupant( 0 );
			if ( isDefined( driver ) )
			{
				vec_to_attacker -= anglesToForward( driver getplayerangles() );
				vec_to_attacker = vectornormalize( vec_to_attacker );
			}
		}
		else
		{
			if ( isplayer( self.last_attacker ) )
			{
				vec_to_attacker -= anglesToForward( self.last_attacker getplayerangles() );
				vec_to_attacker = vectornormalize( vec_to_attacker );
			}
		}
		right = vectorcross( vec_to_attacker, ( 0, 0, 1 ) );
		start_pos = self.last_attacker.origin - ( vec_to_attacker * randomfloatrange( 2000, 5000 ) );
		self.heliheightlockoffset = randomfloatrange( 400, 1000 );
		self setvehgoalpos( start_pos + ( right * 1000 ) );
		wait 1;
		self firegunnerweapon( 0 );
		self firegunnerweapon( 1 );
		wait 2;
		self set_hind_goal_pos_wrapper( start_pos + ( right * 1000 ) );
		self waittill( "goal" );
		self firegunnerweapon( 0 );
		self firegunnerweapon( 1 );
		self.heliheightlockoffset = randomfloatrange( 400, 1000 );
		self set_hind_goal_pos_wrapper( start_pos + ( right * -1000 ) );
		self waittill( "goal" );
		self firegunnerweapon( 0 );
		self firegunnerweapon( 1 );
		if ( randomint( 100 ) > 40 && isDefined( self.last_attacker ) )
		{
			vec_to_attacker = self.last_attacker.origin - self.origin;
			vec_to_attacker = vectornormalize( vec_to_attacker );
			start_pos = self.last_attacker.origin + ( vec_to_attacker * randomfloatrange( 2000, 5000 ) );
			self.heliheightlockoffset = 300;
			self set_hind_goal_pos_wrapper( start_pos + ( right * 1000 ) );
			self thread afghanistan_hind_fire_barrage( self.last_attacker );
			self waittill( "goal" );
			self notify( "stop_fire_barrage" );
		}
		wait 2;
		attack_duration -= 6;
	}
	self.last_attacker = undefined;
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	if ( convoy.members.size > 0 )
	{
		self.cur_target = convoy.members[ randomint( convoy.members.size ) ];
	}
	self thread circle_target();
}

afghanistan_hind_fire_barrage( target )
{
	self endon( "movementUpdate" );
	self endon( "death" );
	self endon( "stop_fire_barrage" );
	while ( isDefined( target ) && distance2dsquared( self.origin, target.origin ) > 250000 )
	{
		self firegunnerweapon( 0 );
		wait 0,5;
		self firegunnerweapon( 1 );
		wait 0,5;
	}
	self clearlookatent();
}

afghanistan_hind_damage_watcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, dir, point, type );
		if ( self.health < 1000 && !isDefined( self.damagefx ) )
		{
			self.damagefx = 1;
			playfxontag( level._effect[ "dmg_trail_hip" ], self, "tag_origin" );
		}
		if ( isDefined( attacker ) )
		{
			if ( isplayer( attacker ) && isDefined( attacker.viewlockedentity ) && attacker.viewlockedentity isvehicle() )
			{
				attacker = attacker.viewlockedentity;
			}
			if ( isDefined( self.last_attacker ) && self.last_attacker == attacker )
			{
				continue;
			}
			self.last_attacker = attacker;
			self thread attack_special_target( 30 );
		}
	}
}

afghanistan_hind_movement()
{
	self endon( "death" );
	self endon( "rts_afghan_outro" );
	self setheliheightlock( 1 );
	self.heliheightlockoffset = randomfloatrange( 500, 1000 );
	convoy = getsquadbypkg( "convoy_pkg", "allies" );
	if ( convoy.members.size > 0 )
	{
		self.cur_target = convoy.members[ randomint( convoy.members.size ) ];
	}
	self thread circle_target();
	while ( 1 )
	{
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		if ( convoy.members.size > 0 )
		{
			self.cur_target = convoy.members[ randomint( convoy.members.size ) ];
		}
		wait 10;
		if ( randomint( 100 ) < 50 && !isDefined( self.last_attacker ) && convoy.members.size )
		{
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			self.last_attacker = convoy.members[ randomint( convoy.members.size ) ];
			self thread attack_special_target( 20 );
		}
	}
}

afghanistan_hind_fire_update()
{
	self endon( "death" );
	self maps/_turret::set_turret_burst_parameters( 2, 5, 4, 6, 0 );
	self thread maps/_turret::enable_turret( 0, 0 );
	self maps/_turret::set_turret_target_flags( 11, 0 );
	while ( 1 )
	{
		wait 1;
	}
}

afghanistan_custom_introscreen( level_prefix, number_of_lines, totaltime, text_color )
{
	flag_wait( "all_players_connected" );
	wait 1;
	luinotifyevent( &"hud_add_title_line", 4, level_prefix, number_of_lines, totaltime, text_color );
	waittill_textures_loaded();
	flag_set( "introscreen_complete" );
}

afghanistan_mission_complete_s1( success, gorts, origin )
{
	if ( !isDefined( gorts ) )
	{
		gorts = 1;
	}
	if ( !isDefined( origin ) )
	{
		origin = level.rts.player.origin;
	}
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
	screen_fade_out( 1 );
	flag_set( "rts_mode_locked_out" );
	flag_clear( "rts_mode" );
	flag_set( "fps_mode" );
	level clientnotify( "rts_OFF" );
	luinotifyevent( &"rts_hud_visibility", 1, 0 );
	level.rts.player clearclientflag( 3 );
	flag_set( "rts_game_over" );
	maps/_so_rts_event::event_clearall( 0 );
	if ( success )
	{
	}
	else
	{
	}
	objective_state( level.obj_escort, "failed", "done" );
	if ( isDefined( success ) && success )
	{
		level thread maps/createart/so_rts_afghanistan_art::success_igc();
		level thread afghanistan_outro();
		level thread maps/_so_rts_support::missioncompletemsg( success );
		scene_wait( "afghan_outro" );
		level.player set_story_stat( "SO_WAR_AFGHANISTAN_SUCCESS", 1 );
		level.player giveachievement_wrapper( "SP_RTS_AFGHANISTAN" );
		level notify( "mission_success" );
		flag_clear( "rts_event_ready" );
		level.rts.player freezecontrols( 0 );
		screen_fade_out( 0,5 );
		maps/_so_rts_poi::deleteallpoi();
		maps/_so_rts_support::missionsuccessmenu();
	}
	else
	{
		level thread maps/createart/so_rts_afghanistan_art::fail_igc();
		level.rts.player freezecontrols( 1 );
		level.rts.player set_ignoreme( 1 );
		flag_clear( "rts_hud_on" );
		maps/_so_rts_support::hide_player_hud();
		level.rts.player enableinvulnerability();
		maps/_so_rts_event::trigger_event( "dlg_mission_fail" );
		flag_clear( "rts_event_ready" );
		scene_afghanistan_fail_animated();
		level.rts.player freezecontrols( 0 );
		wait 1;
		maps/_so_rts_poi::deleteallpoi();
		level thread maps/_so_rts_support::missioncompletemsg( success );
		maps/_so_rts_support::missionfailuremenu();
	}
	level clientnotify( "rts_fd" );
	maps/_so_rts_support::show_player_hud();
	maps/_so_rts_support::toggle_damage_indicators( 1 );
	nextmission();
}

afghanistan_geo_changes()
{
	delobjs = getentarray( "rts_obj_remove", "targetname" );
	_a4496 = delobjs;
	_k4496 = getFirstArrayKey( _a4496 );
	while ( isDefined( _k4496 ) )
	{
		item = _a4496[ _k4496 ];
		item delete();
		_k4496 = getNextArrayKey( _a4496, _k4496 );
	}
	bp2_clip = getent( "BP2_tankdebris", "targetname" );
	if ( isDefined( bp2_clip ) )
	{
		bp2_clip delete();
	}
	bm_clips1 = getentarray( "bridge1_clip", "targetname" );
	_a4507 = bm_clips1;
	_k4507 = getFirstArrayKey( _a4507 );
	while ( isDefined( _k4507 ) )
	{
		bm_clip = _a4507[ _k4507 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k4507 = getNextArrayKey( _a4507, _k4507 );
	}
	bm_clips2 = getentarray( "bridge2_clip", "targetname" );
	_a4514 = bm_clips2;
	_k4514 = getFirstArrayKey( _a4514 );
	while ( isDefined( _k4514 ) )
	{
		bm_clip = _a4514[ _k4514 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k4514 = getNextArrayKey( _a4514, _k4514 );
	}
	bm_clips3 = getentarray( "bridge3_clip", "targetname" );
	_a4521 = bm_clips3;
	_k4521 = getFirstArrayKey( _a4521 );
	while ( isDefined( _k4521 ) )
	{
		bm_clip = _a4521[ _k4521 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k4521 = getNextArrayKey( _a4521, _k4521 );
	}
	bm_clips4 = getentarray( "bridge4_clip", "targetname" );
	_a4528 = bm_clips4;
	_k4528 = getFirstArrayKey( _a4528 );
	while ( isDefined( _k4528 ) )
	{
		bm_clip = _a4528[ _k4528 ];
		bm_clip trigger_off();
		bm_clip connectpaths();
		_k4528 = getNextArrayKey( _a4528, _k4528 );
	}
	ents = getentarray( "base_wall_1_d", "targetname" );
	_a4536 = ents;
	_k4536 = getFirstArrayKey( _a4536 );
	while ( isDefined( _k4536 ) )
	{
		ent = _a4536[ _k4536 ];
		ent delete();
		_k4536 = getNextArrayKey( _a4536, _k4536 );
	}
	ents = getentarray( "base_wall_2_d", "targetname" );
	_a4541 = ents;
	_k4541 = getFirstArrayKey( _a4541 );
	while ( isDefined( _k4541 ) )
	{
		ent = _a4541[ _k4541 ];
		ent delete();
		_k4541 = getNextArrayKey( _a4541, _k4541 );
	}
	ents = getentarray( "base_wall_3_d", "targetname" );
	_a4546 = ents;
	_k4546 = getFirstArrayKey( _a4546 );
	while ( isDefined( _k4546 ) )
	{
		ent = _a4546[ _k4546 ];
		ent delete();
		_k4546 = getNextArrayKey( _a4546, _k4546 );
	}
	ents = getentarray( "base_wall_4_d", "targetname" );
	_a4551 = ents;
	_k4551 = getFirstArrayKey( _a4551 );
	while ( isDefined( _k4551 ) )
	{
		ent = _a4551[ _k4551 ];
		ent delete();
		_k4551 = getNextArrayKey( _a4551, _k4551 );
	}
	ents = getentarray( "clip_gates_base", "targetname" );
	_a4557 = ents;
	_k4557 = getFirstArrayKey( _a4557 );
	while ( isDefined( _k4557 ) )
	{
		ent = _a4557[ _k4557 ];
		ent delete();
		_k4557 = getNextArrayKey( _a4557, _k4557 );
	}
	m_destroyed_dome_clip = getent( "archway_destroyed_static_clip", "targetname" );
	if ( isDefined( m_destroyed_dome_clip ) )
	{
		m_destroyed_dome_clip movez( 2080, 0,1 );
		m_destroyed_dome_clip waittill( "movedone" );
		m_destroyed_dome_clip disconnectpaths();
	}
	script_ent_cleanup();
}

script_ent_cleanup()
{
	smodels = getentarray( "script_model", "classname" );
	_a4580 = smodels;
	_k4580 = getFirstArrayKey( _a4580 );
	while ( isDefined( _k4580 ) )
	{
		smodel = _a4580[ _k4580 ];
		if ( isDefined( smodel.script_index ) )
		{
			if ( smodel.script_index == 999 )
			{
				if ( isDefined( smodel.script_noteworthy ) )
				{
					if ( smodel.script_noteworthy == "fxanim" )
					{
						smodel notify( "fxanim_delete" );
					}
				}
				smodel delete();
			}
		}
		_k4580 = getNextArrayKey( _a4580, _k4580 );
	}
	sbmodels = getentarray( "script_brushmodel", "classname" );
	_a4598 = sbmodels;
	_k4598 = getFirstArrayKey( _a4598 );
	while ( isDefined( _k4598 ) )
	{
		sbmodel = _a4598[ _k4598 ];
		if ( isDefined( sbmodel.script_index ) )
		{
			if ( sbmodel.script_index == 999 )
			{
				sbmodel delete();
			}
		}
		_k4598 = getNextArrayKey( _a4598, _k4598 );
	}
}

is_facing_target( target, half_angle )
{
	if ( !isDefined( half_angle ) )
	{
		half_angle = 90;
	}
	min_dot = cos( half_angle );
	to_target = vectornormalize( target.origin - self.origin );
	fvec = anglesToForward( self.angles );
	return vectordot( fvec, to_target ) > min_dot;
}

horse_auto_kill_watch()
{
	self endon( "death" );
	wait 8;
	driver = self maps/_horse::get_driver();
	if ( isDefined( driver ) )
	{
		driver endon( "death" );
	}
	vehicles_ahead = [];
	kill_driver = 0;
	kill_horse = 0;
	while ( !kill_driver && !kill_horse )
	{
		convoy = getsquadbypkg( "convoy_pkg", "allies" );
		vehicles_ahead = [];
		_a4635 = convoy.members;
		_k4635 = getFirstArrayKey( _a4635 );
		while ( isDefined( _k4635 ) )
		{
			member = _a4635[ _k4635 ];
			dist_to_target = distance2dsquared( self.origin, member.origin );
			if ( dist_to_target < 360000 )
			{
				if ( member is_facing_target( self, 30 ) )
				{
					kill_horse = 1;
				}
			}
			else if ( dist_to_target > 2250000 )
			{
				if ( self is_facing_target( member ) )
				{
					vehicles_ahead[ vehicles_ahead.size ] = member;
				}
			}
			else
			{
				vehicles_ahead[ vehicles_ahead.size ] = member;
			}
			_k4635 = getNextArrayKey( _a4635, _k4635 );
		}
		if ( vehicles_ahead.size == 0 )
		{
			wait 2;
			kill_driver = 1;
		}
		wait 0,2;
	}
	squad1 = getsquadbypkg( "quadrotor_pkg", "allies" );
	squad2 = getsquadbypkg( "quadrotor2_pkg", "allies" );
	squad = arraycombine( squad1.members, squad2.members, 1, 0 );
	while ( squad.size > 0 )
	{
		closest_quad_index = get_closest_index( self.origin, squad );
		while ( isDefined( closest_quad_index ) )
		{
			quad = squad[ closest_quad_index ];
			while ( isDefined( quad ) )
			{
				source_pos = quad.origin;
				i = 0;
				while ( i < 4 )
				{
					if ( isalive( quad ) )
					{
						magicbullet( "quadrotor_turret_rts_afghan", source_pos, self.origin, quad, self );
						wait 0,1;
					}
					i++;
				}
			}
		}
	}
	if ( kill_driver )
	{
		driver = self maps/_horse::get_driver();
		if ( isDefined( driver ) )
		{
			driver dodamage( driver.health * 2, driver.origin );
		}
	}
	wait 0,5;
	self dodamage( self.health * 2, self.origin );
}

dead_horse_cleanup()
{
	self endon( "delete" );
	self makevehicleunusable();
	delete_dist_sq = 16000000;
	delete_behind_dist_sq = 1048576;
	self waittill( "death" );
	if ( flag( "rts_afghan_outro" ) )
	{
		return;
	}
	wait 20;
	while ( 1 )
	{
		dist_sq = distance2dsquared( level.player.origin, self.origin );
		if ( dist_sq > delete_dist_sq )
		{
			break;
		}
		else if ( dist_sq > delete_behind_dist_sq )
		{
			to_horse = self.origin - level.player.origin;
			to_horse = vectornormalize( to_horse );
			cam_fvec = anglesToForward( level.player.angles );
			dot_to_horse = vectordot( cam_fvec, to_horse );
			if ( dot_to_horse < 0 )
			{
				break;
			}
		}
		else
		{
			wait 0,5;
		}
	}
	self delete();
}

afghanistan_level_scenario_one_registerevents()
{
}

afghan_setup_devgui()
{
/#
	setdvar( "cmd_skipto", "" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Skipto:1/IED Clear:1" "cmd_skipto ied"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Skipto:1/T72 Attack:1" "cmd_skipto turnback"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Skipto:1/Bridges:2" "cmd_skipto bridge"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Skipto:1/Outro:3" "cmd_skipto outro"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Skipto:1/Failure:4" "cmd_skipto failure"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Afghan:10/Invulnerable Convoy:2" "cmd_skipto invulnerable_convoy"\n" );
	level thread afghan_watch_devgui();
#/
}

afghan_watch_devgui()
{
/#
	while ( 1 )
	{
		cmd_skipto = getDvar( "cmd_skipto" );
		if ( cmd_skipto == "ied" )
		{
			level notify( "skip_to" );
			level notify( "ied_spawn_enabled" );
			trigger_off( "rts_ied_event", "script_noteworthy" );
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			i = 0;
			while ( i < 4 )
			{
				if ( isDefined( convoy.members[ i ] ) )
				{
					name = "c" + ( i + 1 ) + "_skipto_" + cmd_skipto;
					vnode = getvehiclenode( name, "targetname" );
					assert( isDefined( vnode ) );
					convoy.members[ i ].origin = vnode.origin;
					convoy.members[ i ].angles = vnode.angles;
					convoy.members[ i ] drivepath( vnode );
					if ( i == 0 && isDefined( level.rts.player.ally ) )
					{
						if ( isDefined( level.rts.player.ally.vehicle ) )
						{
							level.rts.player.ally.vehicle.origin = vnode.origin + vectorScale( ( 0, 0, 1 ), 256 );
							i++;
							continue;
						}
						else
						{
							level.rts.player setorigin( vnode.origin + ( 256, 0, 128 ) );
						}
					}
				}
				i++;
			}
			setdvar( "cmd_skipto", "" );
		}
		else if ( cmd_skipto == "bridge" )
		{
			level notify( "skip_to" );
			level notify( "turn_hind_off" );
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			if ( convoy.members.size == 4 )
			{
				convoy.members[ 3 ] veh_magic_bullet_shield( 0 );
				convoy.members[ 3 ] kill();
			}
			i = 0;
			while ( i < 3 )
			{
				if ( isDefined( convoy.members[ i ] ) )
				{
					name = "c" + ( i + 1 ) + "_skipto_" + cmd_skipto;
					vnode = getvehiclenode( name, "targetname" );
					assert( isDefined( vnode ) );
					convoy.members[ i ].origin = vnode.origin;
					convoy.members[ i ].angles = vnode.angles;
					convoy.members[ i ] drivepath( vnode );
					if ( i == 0 && isDefined( level.rts.player.ally ) )
					{
						if ( isDefined( level.rts.player.ally.vehicle ) )
						{
							level.rts.player.ally.vehicle.origin = vnode.origin + vectorScale( ( 0, 0, 1 ), 256 );
							i++;
							continue;
						}
						else
						{
							level.rts.player setorigin( vnode.origin + ( 256, 0, 128 ) );
						}
					}
				}
				i++;
			}
			setdvar( "cmd_skipto", "" );
		}
		else if ( cmd_skipto == "turnback" )
		{
			level notify( "skip_to" );
			level notify( "change_extraction_point" );
			level notify( "t72_unit4" );
			level notify( "t72_unit2" );
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			flag_set( "innocuous_ieds" );
			i = 0;
			while ( i < convoy.members.size )
			{
				if ( isDefined( convoy.members[ i ] ) )
				{
					name = "c" + ( i + 1 ) + "_skipto_" + cmd_skipto;
					vnode = getvehiclenode( name, "targetname" );
					assert( isDefined( vnode ) );
					convoy.members[ i ].origin = vnode.origin;
					convoy.members[ i ].angles = vnode.angles;
					convoy.members[ i ] drivepath( vnode );
					convoy.members[ i ] thread afghanistan_truckstall( 10 + ( i * 4 ), 5 );
					if ( i == 0 && isDefined( level.rts.player.ally ) )
					{
						if ( isDefined( level.rts.player.ally.vehicle ) )
						{
							level.rts.player.ally.vehicle.origin = vnode.origin + vectorScale( ( 0, 0, 1 ), 256 );
							i++;
							continue;
						}
						else
						{
							level.rts.player setorigin( vnode.origin + ( 256, 0, 128 ) );
						}
					}
				}
				i++;
			}
			wait 5;
			flag_clear( "innocuous_ieds" );
			setdvar( "cmd_skipto", "" );
		}
		else if ( cmd_skipto == "invulnerable_convoy" )
		{
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			_a4914 = convoy.members;
			_k4914 = getFirstArrayKey( _a4914 );
			while ( isDefined( _k4914 ) )
			{
				member = _a4914[ _k4914 ];
				member veh_magic_bullet_shield( 1 );
				_k4914 = getNextArrayKey( _a4914, _k4914 );
			}
			setdvar( "cmd_skipto", "" );
		}
		else if ( cmd_skipto == "failure" )
		{
			level notify( "skip_to" );
			convoy = getsquadbypkg( "convoy_pkg", "allies" );
			i = 0;
			while ( i < convoy.members.size )
			{
				convoy.members[ i ] veh_magic_bullet_shield( 0 );
				convoy.members[ i ] dodamage( convoy.members[ i ].health, convoy.members[ i ].origin );
				i++;
			}
			setdvar( "cmd_skipto", "" );
		}
		else
		{
			if ( cmd_skipto == "outro" )
			{
				level notify( "skip_to" );
				convoy = getsquadbypkg( "convoy_pkg", "allies" );
				i = 0;
				while ( i < convoy.members.size )
				{
					if ( isDefined( convoy.members[ i ] ) )
					{
						name = "c" + ( i + 1 ) + "_skipto_" + cmd_skipto;
						vnode = getvehiclenode( name, "targetname" );
						assert( isDefined( vnode ) );
						convoy.members[ i ].origin = vnode.origin;
						convoy.members[ i ].angles = vnode.angles;
						convoy.members[ i ] setbrake( 0 );
						convoy.members[ i ] drivepath( vnode );
						convoy.members[ i ] thread afghanistan_truckstall( 10 + ( i * 4 ), 5 );
						if ( i == 0 && isDefined( level.rts.player.ally ) )
						{
							if ( isDefined( level.rts.player.ally.vehicle ) )
							{
								level.rts.player.ally.vehicle.origin = vnode.origin + vectorScale( ( 0, 0, 1 ), 256 );
								i++;
								continue;
							}
							else
							{
								level.rts.player setorigin( vnode.origin + ( 256, 0, 128 ) );
							}
						}
					}
					i++;
				}
				flag_set( "rts_afghan_outro" );
				setdvar( "cmd_skipto", "" );
			}
		}
		wait 0,05;
#/
	}
}

monitor_vehicle_counts()
{
/#
	while ( 1 )
	{
		vehicle_array = getvehiclearray();
		n_vehicles = vehicle_array.size;
		if ( n_vehicles > 45 )
		{
			println( "--------------------------" );
			println( "Vehicle Count: " + n_vehicles );
			println( "--------------------------" );
			vehicle_type_count = [];
			numdead = 0;
			_a4992 = vehicle_array;
			_k4992 = getFirstArrayKey( _a4992 );
			while ( isDefined( _k4992 ) )
			{
				vehicle = _a4992[ _k4992 ];
				if ( !isDefined( vehicle_type_count[ vehicle.vehicletype ] ) )
				{
					vehicle_type_count[ vehicle.vehicletype ] = 0;
				}
				vehicle_type_count[ vehicle.vehicletype ]++;
				if ( !isalive( vehicle ) && vehicle.vehicletype == "horse" )
				{
					numdead++;
				}
				_k4992 = getNextArrayKey( _a4992, _k4992 );
			}
			keys = getarraykeys( vehicle_type_count );
			_a5003 = keys;
			_k5003 = getFirstArrayKey( _a5003 );
			while ( isDefined( _k5003 ) )
			{
				key = _a5003[ _k5003 ];
				println( ( key + ": " ) + vehicle_type_count[ key ] );
				_k5003 = getNextArrayKey( _a5003, _k5003 );
			}
			println( "Dead Horses: " + numdead );
			println( "--------------------------" );
			wait 10;
		}
		wait 1;
#/
	}
}

fxanim_bridges()
{
	m_bridge1_clip = getent( "BP3_bridge_1", "targetname" );
	m_bridge2_clip = getent( "BP3_bridge_2", "targetname" );
	m_bridge3_clip = getent( "BP3_bridge_3", "targetname" );
	m_bridge4_clip = getent( "BP3_bridge_4", "targetname" );
	m_bridge1 = getent( "pristine_bridge01_break", "targetname" );
	m_bridge2 = getent( "pristine_bridge02_break", "targetname" );
	m_bridge3 = getent( "pristine_bridge01_long_break", "targetname" );
	m_bridge4 = getent( "pristine_bridge02_long_break", "targetname" );
	str_bridge1 = "fxanim_bridge01_break_start";
	str_bridge2 = "fxanim_bridge02_break_start";
	str_bridge3 = "fxanim_bridge01_long_break_start";
	str_bridge4 = "fxanim_bridge02_long_break_start";
	m_bridge1 thread trigger_fxanim_objbridge( m_bridge1_clip, str_bridge1 );
	m_bridge2 thread trigger_fxanim_objbridge( m_bridge2_clip, str_bridge2 );
	m_bridge3 thread trigger_fxanim_objbridge( m_bridge3_clip, str_bridge3 );
	m_bridge4 thread trigger_fxanim_objbridge( m_bridge4_clip, str_bridge4 );
}

trigger_fxanim_objbridge( m_bridge_clip, str_notify )
{
	self setcandamage( 1 );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( str_notify == "fxanim_bridge01_break_start" && attacker == level.player )
		{
			self thread disable_bridge_nodes();
			self delete();
			m_bridge_clip delete();
			level notify( str_notify );
			return;
		}
		else if ( str_notify == "fxanim_bridge02_break_start" && attacker == level.player )
		{
			self thread disable_bridge_nodes();
			self delete();
			m_bridge_clip delete();
			level notify( str_notify );
			return;
		}
		else
		{
			if ( str_notify == "fxanim_bridge01_long_break_start" && attacker == level.player )
			{
				self thread disable_bridge_nodes();
				self delete();
				m_bridge_clip delete();
				level notify( str_notify );
				return;
			}
			else if ( str_notify == "fxanim_bridge02_long_break_start" && attacker == level.player )
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
}

disable_bridge_nodes()
{
	if ( self.targetname == "pristine_bridge01_break" )
	{
		t_bridge = getent( "bridge1_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge1_clip", "targetname" );
		_a5103 = bm_clips;
		_k5103 = getFirstArrayKey( _a5103 );
		while ( isDefined( _k5103 ) )
		{
			bm_clip = _a5103[ _k5103 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5103 = getNextArrayKey( _a5103, _k5103 );
		}
	}
	else if ( self.targetname == "pristine_bridge02_break" )
	{
		t_bridge = getent( "bridge2_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge2_clip", "targetname" );
		_a5118 = bm_clips;
		_k5118 = getFirstArrayKey( _a5118 );
		while ( isDefined( _k5118 ) )
		{
			bm_clip = _a5118[ _k5118 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5118 = getNextArrayKey( _a5118, _k5118 );
		}
	}
	else if ( self.targetname == "pristine_bridge01_long_break" )
	{
		t_bridge = getent( "bridge3_physics_trigger", "targetname" );
		t_bridge thread bridge_destruction_physics();
		t_bridge thread bridge_destruction_kill();
		bm_clips = getentarray( "bridge3_clip", "targetname" );
		_a5133 = bm_clips;
		_k5133 = getFirstArrayKey( _a5133 );
		while ( isDefined( _k5133 ) )
		{
			bm_clip = _a5133[ _k5133 ];
			bm_clip trigger_on();
			bm_clip disconnectpaths();
			_k5133 = getNextArrayKey( _a5133, _k5133 );
		}
	}
	else t_bridge = getent( "bridge4_physics_trigger", "targetname" );
	t_bridge thread bridge_destruction_physics();
	t_bridge thread bridge_destruction_kill();
	bm_clips = getentarray( "bridge4_clip", "targetname" );
	_a5148 = bm_clips;
	_k5148 = getFirstArrayKey( _a5148 );
	while ( isDefined( _k5148 ) )
	{
		bm_clip = _a5148[ _k5148 ];
		bm_clip trigger_on();
		bm_clip disconnectpaths();
		_k5148 = getNextArrayKey( _a5148, _k5148 );
	}
}

bridge_destruction_kill()
{
	a_ai_guys = getaiarray( "all" );
	rally_points = getentarray( "bridge_rally_point", "script_noteworthy" );
	_a5162 = a_ai_guys;
	_k5162 = getFirstArrayKey( _a5162 );
	while ( isDefined( _k5162 ) )
	{
		ai_guy = _a5162[ _k5162 ];
		if ( ai_guy istouching( self ) && isDefined( ai_guy ) )
		{
			radiusdamage( ai_guy.origin, 100, ai_guy.health, ai_guy.health, undefined, "MOD_PROJECTILE" );
		}
		_k5162 = getNextArrayKey( _a5162, _k5162 );
	}
	_a5170 = rally_points;
	_k5170 = getFirstArrayKey( _a5170 );
	while ( isDefined( _k5170 ) )
	{
		spot = _a5170[ _k5170 ];
		if ( spot istouching( self ) )
		{
			spot delete();
		}
		_k5170 = getNextArrayKey( _a5170, _k5170 );
	}
}

bridge_destruction_physics()
{
	wait 1;
	a_ai_corpses = entsearch( level.contents_corpse, self.origin, 1200 );
	_a5187 = a_ai_corpses;
	_k5187 = getFirstArrayKey( _a5187 );
	while ( isDefined( _k5187 ) )
	{
		ai_corpse = _a5187[ _k5187 ];
		if ( ai_corpse istouching( self ) )
		{
			if ( ai_corpse isragdoll() )
			{
				physicsexplosionsphere( ai_corpse.origin, 10, 5, 0,01 );
			}
		}
		_k5187 = getNextArrayKey( _a5187, _k5187 );
	}
	wait 1;
	delete_ents( level.contents_corpse, self.origin, 1200 );
	self delete();
}

convoy_dialogdeathwatch()
{
	if ( !isDefined( level.convoy_deaths ) )
	{
		level.convoy_deaths = 0;
	}
	voxid = self.voxid;
	self waittill( "death" );
	level.convoy_deaths++;
	maps/_so_rts_event::trigger_event( "dlg_" + voxid + "_died" );
	maps/_so_rts_event::trigger_event( "dlg_convoy_unit_died_" + level.convoy_deaths );
}

convoy_dialogiedproximitywatch()
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		ieds = getentarray( "ied", "script_noteworthy" );
		ieds = sortarraybyclosest( self.origin, ieds, 384400 );
		if ( ieds.size > 0 )
		{
			if ( flag( "fps_mode" ) )
			{
				maps/_so_rts_event::trigger_event( "dlg_veh_announce_ied" );
				break;
			}
			else
			{
				maps/_so_rts_event::trigger_event( "dlg_announce_ied" );
			}
		}
		wait randomint( 6 );
	}
}

convoy_dialogwatch()
{
	self endon( "death" );
	self thread convoy_dialogdeathwatch();
	self thread convoy_dialogiedproximitywatch();
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type );
		if ( isDefined( attacker ) && isDefined( attacker.ai_ref ) )
		{
			if ( issubstr( attacker.ai_ref.ref, "t72" ) )
			{
				if ( flag( "fps_mode" ) )
				{
					maps/_so_rts_event::trigger_event( "dlg_veh_announce_tank" );
				}
				else
				{
					maps/_so_rts_event::trigger_event( "dlg_announce_tank" );
				}
				break;
			}
			else if ( issubstr( attacker.ai_ref.ref, "rpg" ) )
			{
				if ( flag( "fps_mode" ) )
				{
					maps/_so_rts_event::trigger_event( "dlg_veh_announce_rpg" );
				}
				else
				{
					maps/_so_rts_event::trigger_event( "dlg_announce_rpg" );
				}
				break;
			}
			else if ( issubstr( attacker.ai_ref.ref, "hind" ) )
			{
				if ( flag( "fps_mode" ) )
				{
					maps/_so_rts_event::trigger_event( "dlg_veh_announce_heli" );
					break;
				}
				else
				{
					maps/_so_rts_event::trigger_event( "dlg_announce_heli" );
				}
			}
		}
		if ( isDefined( attacker ) && isDefined( attacker.script_noteworthy ) && issubstr( attacker.script_noteworthy, "ied" ) )
		{
			maps/_so_rts_event::trigger_event( "dlg_" + self.voxid + "_ied_hit" );
		}
		if ( flag( "fps_mode" ) )
		{
			if ( randomint( 100 ) > 50 )
			{
				maps/_so_rts_event::trigger_event( "dlg_" + self.voxid + "_veh_attack" );
			}
			else
			{
				maps/_so_rts_event::trigger_event( "dlg_" + self.voxid + "_veh_hurt" );
			}
			continue;
		}
		else if ( randomint( 100 ) > 50 )
		{
			maps/_so_rts_event::trigger_event( "dlg_" + self.voxid + "_attack" );
			continue;
		}
		else
		{
			maps/_so_rts_event::trigger_event( "dlg_" + self.voxid + "_hurt" );
		}
	}
}

sndplayloop( guy )
{
	ent = spawn( "script_origin", self.origin );
	ent playloopsound( "evt_rts_quadrotor_1stperson_lp", 1 );
	level waittill( "sndStopLoop" );
	ent delete();
}

sndstoploop( guy )
{
	level notify( "sndStopLoop" );
}
