#include codescripts/character;
#include maps/_colors;
#include maps/_spawn_manager;
#include maps/_gameskill;
#include maps/_music;
#include maps/_busing;
#include animscripts/death;
#include maps/_scene;
#include maps/_loadout;
#include maps/_createfx;
#include maps/_fxanim;
#include maps/_callbacksetup;
#include maps/_vehicle;
#include maps/_gamemode;
#include maps/_skipto;
#include animscripts/shared;
#include animscripts/weaponlist;
#include maps/_perks_sp;
#include maps/_load_common;
#include maps/_hud_util;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main( bscriptgened, bcsvgened, bsgenabled )
{
	level.script = tolower( getDvar( "mapname" ) );
	maps/_perks_sp::initperkdvars();
	init_session_mode_flags();
	level thread init_leaderboards();
	init_client_flags();
/#
	println( "_LOAD START TIME = " + getTime() );
#/
	set_early_level();
	level.era = get_level_era();
	if ( !isDefined( level.era ) )
	{
		level.era = "default";
	}
	animscripts/weaponlist::precacheweaponswitchfx();
	if ( !isDefined( level.revivefeature ) )
	{
		level.revivefeature = 0;
	}
	maps/_constants::main();
	level.scr_anim[ "generic" ][ "signal_onme" ] = %cqb_stand_wave_on_me;
	level.scr_anim[ "generic" ][ "signal_go" ] = %cqb_stand_wave_go_v1;
	level.scr_anim[ "generic" ][ "signal_stop" ] = %cqb_stand_signal_stop;
	level.scr_anim[ "generic" ][ "signal_moveup" ] = %cqb_stand_signal_move_up;
	level.scr_anim[ "generic" ][ "signal_moveout" ] = %cqb_stand_signal_move_out;
	if ( !isDefined( level.script_gen_dump_reasons ) )
	{
		level.script_gen_dump_reasons = [];
	}
	if ( !isDefined( bsgenabled ) )
	{
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "First run";
	}
	if ( !isDefined( bcsvgened ) )
	{
		bcsvgened = 0;
	}
	level.bcsvgened = bcsvgened;
	if ( !isDefined( bscriptgened ) )
	{
		bscriptgened = 0;
	}
	else
	{
		bscriptgened = 1;
	}
	level.bscriptgened = bscriptgened;
/#
	ascii_logo();
#/
	if ( getDvar( "debug" ) == "" )
	{
		setdvar( "debug", "0" );
	}
	if ( getDvar( "fallback" ) == "" )
	{
		setdvar( "fallback", "0" );
	}
	if ( getDvar( "angles" ) == "" )
	{
		setdvar( "angles", "0" );
	}
	if ( getDvar( "noai" ) == "" )
	{
		setdvar( "noai", "off" );
	}
	if ( getDvar( "scr_RequiredMapAspectratio" ) == "" )
	{
		setdvar( "scr_RequiredMapAspectratio", "1" );
	}
/#
	createprintchannel( "script_debug" );
#/
	if ( !isDefined( anim.notetracks ) )
	{
		anim.notetracks = [];
		animscripts/shared::registernotetracks();
	}
	add_skipto( "no_game", ::maps/_skipto::skipto_nogame );
	level._loadstarted = 1;
	level.first_frame = 1;
	level.level_specific_dof = 0;
	flag_init( "running_skipto" );
	flag_init( "all_players_connected" );
	flag_init( "level.player" );
	flag_init( "all_players_spawned" );
	flag_init( "drop_breadcrumbs" );
	flag_set( "drop_breadcrumbs" );
	if ( !level flag_exists( "screen_fade_in_end" ) )
	{
		flag_init( "screen_fade_out_start" );
		flag_init( "screen_fade_out_end" );
		flag_init( "screen_fade_in_start" );
		flag_init( "screen_fade_in_end" );
	}
	flag_init( "player_has_intruder" );
	flag_init( "player_has_lockbreaker" );
	flag_init( "player_has_bruteforce" );
	level thread perk_flags();
	thread remove_level_first_frame();
	level.wait_any_func_array = [];
	level.run_func_after_wait_array = [];
	level.do_wait_endons_array = [];
	level.radiation_totalpercent = 0;
	level.clientscripts = getDvar( "cg_usingClientScripts" ) != "";
	level._client_exploders = [];
	level._client_exploder_ids = [];
	registerclientsys( "levelNotify" );
	registerclientsys( "lsm" );
	flag_init( "missionfailed" );
	flag_init( "auto_adjust_initialized" );
	flag_init( "global_hint_in_use" );
	level.default_run_speed = 190;
	setsaveddvar( "g_speed", level.default_run_speed );
	setsaveddvar( "phys_vehicleWheelEntityCollision", 0 );
	setdvar( "ui_deadquote", "" );
	setsaveddvar( "sv_saveOnStartMap", maps/_gamemode::shouldsaveonstartup() );
	level thread maps/_vehicle::init_vehicles();
	struct_class_init();
	level_struct_array_free();
	delete_bounce_light_brushes();
	init_triggers();
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
	}
	else
	{
		flags = getarraykeys( level.flag );
		level array_ent_thread( flags, ::check_flag_for_stat_tracking );
	}
	flag_init( "respawn_friendlies" );
	flag_init( "player_flashed" );
	flag_init( "scriptgen_done" );
	level.script_gen_dump_reasons = [];
	if ( !isDefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = [];
		level.script_gen_dump_reasons[ 0 ] = "First run";
	}
	if ( !isDefined( level.script_gen_dump2 ) )
	{
		level.script_gen_dump2 = [];
	}
	if ( isDefined( level.createfxent ) )
	{
		script_gen_dump_addline( "maps\\createfx\\" + level.script + "_fx::main(); ", level.script + "_fx" );
	}
	while ( isDefined( level.script_gen_dump_preload ) )
	{
		i = 0;
		while ( i < level.script_gen_dump_preload.size )
		{
			script_gen_dump_addline( level.script_gen_dump_preload[ i ].string, level.script_gen_dump_preload[ i ].signature );
			i++;
		}
	}
	level.last_mission_sound_time = -5000;
	level.hero_list = [];
	level.ai_array = [];
	thread precache_script_models();
/#
	precachemodel( "fx" );
#/
	precachemodel( "tag_origin" );
	precachemodel( "tag_origin_animate" );
	precachemodel( "drone_collision" );
	precacheshellshock( "level_end" );
	precacheshellshock( "default" );
	precacheshellshock( "flashbang" );
	precacheshellshock( "dog_bite" );
	precacheshellshock( "pain" );
	precacherumble( "damage_heavy" );
	precacherumble( "dtp_rumble" );
	precacherumble( "slide_rumble" );
	precacherumble( "damage_light" );
	precacherumble( "grenade_rumble" );
	precacherumble( "artillery_rumble" );
	precacherumble( "reload_small" );
	precacherumble( "reload_medium" );
	precacherumble( "reload_large" );
	precacherumble( "reload_clipin" );
	precacherumble( "reload_clipout" );
	precacherumble( "reload_rechamber" );
	precacherumble( "pullout_small" );
	precacherumble( "riotshield_impact" );
	precachemodel( "weapon_parabolic_knife" );
	level._effect[ "flesh_hit_knife" ] = loadfx( "impacts/fx_flesh_hit_knife" );
	precachestring( &"GAME_GET_TO_COVER" );
	precachestring( &"SCRIPT_GRENADE_DEATH" );
	precachestring( &"SCRIPT_GRENADE_SUICIDE_LINE1" );
	precachestring( &"SCRIPT_GRENADE_SUICIDE_LINE2" );
	precachestring( &"SCRIPT_EXPLODING_VEHICLE_DEATH" );
	precachestring( &"SCRIPT_EXPLODING_BARREL_DEATH" );
	precachestring( &"SCRIPT_EXPLODING_NITROGEN_TANK_DEATH" );
	precachestring( &"STARTS_AVAILABLE_STARTS" );
	precachestring( &"STARTS_CANCEL" );
	precachestring( &"STARTS_DEFAULT" );
	precachestring( &"hud_expand_ammo" );
	precachestring( &"hud_shrink_ammo" );
	precacheshader( "overlay_low_health_splat" );
	precacheshader( "hud_monsoon_nitrogen_barrel" );
	precacheshader( "overlay_low_health" );
	precacheshader( "hud_grenadeicon_256" );
	precacheshader( "hud_grenadepointer" );
	precacheshader( "hud_explosive_arrow_icon" );
	precacheshader( "hud_monsoon_titus_arrow" );
	precacheshader( "hud_exploding_vehicles" );
	precacheshader( "black" );
	precacheshader( "white" );
	precacheshellshock( "death" );
	precacheshellshock( "explosion" );
	precacheshellshock( "tank_mantle" );
	precacheshellshock( "concussion_grenade_mp" );
	maps/_damagefeedback::precache();
	if ( isDefined( level._gamemode_precache ) )
	{
		[[ level._gamemode_precache ]]();
	}
	maps/_callbackglobal::init();
	maps/_callbacksetup::setupcallbacks();
	maps/_anim::init();
	maps/_autosave::main();
	level thread maps/_fxanim::fxanim_init();
	level.createfx_enabled = getDvar( "createfx" ) != "";
	maps/_cheat::init();
	setupexploders();
	maps/_art::main();
	maps/_dds::dds_init();
	level thread massnodeinitfunctions();
	level thread maps/_spawner::main();
/#
	level thread level_notify_listener();
	level thread client_notify_listener();
	level thread save_game_on_notify();
#/
	thread maps/_createfx::fx_init();
/#
	if ( level.createfx_enabled )
	{
		maps/_callbackglobal::init();
		maps/_callbacksetup::setupcallbacks();
		calculate_map_center();
		maps/_loadout::init_loadout();
		level thread all_players_connected();
		level thread all_players_spawned();
		thread maps/_introscreen::main();
		level thread maps/_scene::run_scene_tests();
		level thread maps/_scene::toggle_scene_menu();
		maps/_createfx::createfx();
#/
	}
	thread setup_simple_primary_lights();
	animscripts/death::precache_ai_death_fx();
/#
	if ( getDvar( #"F7B30924" ) == "1" )
	{
		maps/_global_fx::main();
		maps/_loadout::init_loadout();
		level waittill( "eternity" );
#/
	}
	level thread maps/_skipto::handle_skiptos();
	if ( getDvar( "g_connectpaths" ) == "2" )
	{
/#
		println( "g_connectpaths == 2; halting script execution" );
#/
		level waittill( "eternity" );
	}
/#
	println( "level.script: ", level.script );
#/
	if ( isDefined( level._gamemode_initcallbacks ) )
	{
		[[ level._gamemode_initcallbacks ]]();
	}
	maps/_skipto::do_no_game_skipto();
	maps/_ar::init();
	maps/_anim::init();
	maps/_busing::businit();
	maps/_music::music_init();
/#
	thread maps/_radiant_live_update::main();
#/
	anim.usefacialanims = 0;
	if ( !isDefined( level.missionfailed ) )
	{
		level.missionfailed = 0;
	}
	if ( getDvar( "g_gametype" ) != "vs" )
	{
		if ( isDefined( level.skill_override ) )
		{
			maps/_gameskill::setskill( undefined, level.skill_override );
		}
		else
		{
			maps/_gameskill::setskill();
		}
	}
	maps/_loadout::init_loadout();
	maps/_weapons::init();
	maps/_detonategrenades::init();
	thread maps/_flareweapon::init();
	maps/_destructible::init();
	maps/_hud_message::init();
	setobjectivetextcolors();
	thread maps/_cooplogic::init();
	thread maps/_ingamemenus::init();
	calculate_map_center();
	maps/_global_fx::main();
	if ( !isDefined( level.campaign ) )
	{
		level.campaign = "american";
	}
	setsaveddvar( "ui_campaign", level.campaign );
/#
	thread maps/_debug::maindebug();
	thread animscripts/debug::maindebug();
#/
/#
	maps/_createdynents::init_once();
	thread maps/_createdynents::main();
#/
	level thread all_players_connected();
	level thread all_players_spawned();
	thread maps/_introscreen::main();
	thread maps/_minefields::main();
	thread maps/_endmission::main();
	maps/_friendlyfire::main();
	level array_ent_thread( getentarray( "badplace", "targetname" ), ::badplace_think );
	array_delete( getentarray( "delete_on_load", "targetname" ) );
	setup_traversals();
	array_thread( getentarray( "water", "targetname" ), ::waterthink );
	thread maps/_interactive_objects::main();
	thread maps/_audio::main();
	thread maps/_collectibles::main();
	thread maps/_ammo_refill::main();
	flag_init( "spawning_friendlies" );
	flag_init( "friendly_wave_spawn_enabled" );
	flag_clear( "spawning_friendlies" );
	level.spawn_funcs = [];
	level.spawn_funcs[ "allies" ] = [];
	level.spawn_funcs[ "axis" ] = [];
	level.spawn_funcs[ "team3" ] = [];
	level.spawn_funcs[ "neutral" ] = [];
	thread maps/_spawner::goalvolumes();
	update_script_forcespawn_based_on_flags();
	trigs = getentarray( "explodable_volume", "targetname" );
	array_thread( trigs, ::explodable_volume );
	level.shared_portable_turrets = [];
	maps/_spawner::spawner_targets_init();
	maps/_spawn_manager::spawn_manager_main();
	maps/_hud::init();
	thread load_friendlies();
	thread maps/_animatedmodels::main();
/#
	script_gen_dump();
#/
	thread weapon_ammo();
	precacheshellshock( "default" );
	level thread onfirstplayerready();
	level thread onplayerconnect();
	level thread adjust_placed_weapons();
	if ( !isDefined( level.splitscreen_fog ) )
	{
		set_splitscreen_fog();
	}
	level notify( "load main complete" );
/#
	thread maps/_dev::init();
#/
	maps/_dialog::main();
	level thread level_auto_complete();
/#
	println( "_LOAD END TIME = " + getTime() );
#/
}

level_auto_complete()
{
	level waittill( "skip_level" );
	levelname = getsubstr( level.script, 0, 6 );
	if ( levelname != "so_rts" )
	{
		nextmission();
	}
}

init_client_flags()
{
	level.cf_player_underwater = 15;
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		if ( !isDefined( player.a ) )
		{
			player.a = spawnstruct();
		}
		player thread animscripts/init::onplayerconnect();
		player thread onplayerspawned();
		player thread onplayerdisconnect();
		if ( issplitscreen() )
		{
			setdvar( "r_watersim", 0 );
		}
	}
}

onplayerdisconnect()
{
	self waittill( "disconnect" );
	if ( issplitscreen() )
	{
		setdvar( "r_watersim", 1 );
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self.maxhealth = 100;
		self.attackeraccuracy = 1;
		self.pers[ "class" ] = "closequarters";
		self.pers[ "team" ] = "allies";
/#
		println( "player health: " + self.health );
#/
		if ( level.createfx_enabled )
		{
			continue;
		}
		else
		{
			self setthreatbiasgroup( "allies" );
			self notify( "noHealthOverlay" );
			self.starthealth = self.maxhealth;
			self.shellshocked = 0;
			self.inwater = 0;
			self detachall();
			self maps/_loadout::give_model();
			maps/_loadout::give_loadout( 1 );
			self notify( "CAC_loadout" );
			self maps/_art::setdefaultdepthoffield();
			if ( !isDefined( self.player_inited ) || !self.player_inited )
			{
				self maps/_friendlyfire::player_init();
				self thread player_death_detection();
				self thread maps/_audio::death_sounds();
				self thread shock_ondeath();
				self thread shock_onpain();
				self thread maps/_detonategrenades::watchgrenadeusage();
				self maps/_dds::player_init();
				self thread playerdamagerumble();
				self thread maps/_gameskill::playerhealthregen();
				self thread maps/_colors::player_init_color_grouping();
				self thread maps/_cheat::player_init();
				self maps/_damagefeedback::init();
				wait 0,05;
				self.player_inited = 1;
			}
		}
	}
}

devhelp_hudelements( hudarray, alpha )
{
	i = 0;
	while ( i < hudarray.size )
	{
		p = 0;
		while ( p < 2 )
		{
			hudarray[ i ][ p ].alpha = alpha;
			p++;
		}
		i++;
	}
}

create_start( start, index )
{
	hudelem = newhudelem();
	hudelem.alignx = "left";
	hudelem.aligny = "middle";
	hudelem.x = 10;
	hudelem.y = 80 + ( index * 20 );
	hudelem.label = start;
	hudelem.alpha = 0;
	hudelem.fontscale = 2;
	hudelem fadeovertime( 0,5 );
	hudelem.alpha = 1;
	return hudelem;
}

load_friendlies()
{
	if ( isDefined( game[ "total characters" ] ) )
	{
		game_characters = game[ "total characters" ];
/#
		println( "Loading Characters: ", game_characters );
#/
	}
	else
	{
/#
		println( "Loading Characters: None!" );
#/
		return;
	}
	ai = getaiarray( "allies" );
	total_ai = ai.size;
	index_ai = 0;
	spawners = getspawnerteamarray( "allies" );
	total_spawners = spawners.size;
	index_spawners = 0;
	while ( 1 )
	{
		if ( total_ai <= 0 || total_spawners <= 0 && game_characters <= 0 )
		{
			return;
		}
		while ( total_ai > 0 )
		{
			while ( isDefined( ai[ index_ai ].script_friendname ) )
			{
				total_ai--;

				index_ai++;
			}
/#
			println( "Loading character.. ", game_characters );
#/
			ai[ index_ai ] codescripts/character::new();
			ai[ index_ai ] thread codescripts/character::load( game[ "character" + ( game_characters - 1 ) ] );
			total_ai--;

			index_ai++;
			game_characters--;

		}
		while ( total_spawners > 0 )
		{
			while ( isDefined( spawners[ index_spawners ].script_friendname ) )
			{
				total_spawners--;

				index_spawners++;
			}
/#
			println( "Loading character.. ", game_characters );
#/
			info = game[ "character" + ( game_characters - 1 ) ];
			precache( info[ "model" ] );
			precache( info[ "model" ] );
			spawners[ index_spawners ] thread spawn_setcharacter( game[ "character" + ( game_characters - 1 ) ] );
			total_spawners--;

			index_spawners++;
			game_characters--;

		}
	}
}

init_triggers()
{
	level.trigger_hint_string = [];
	level.trigger_hint_func = [];
	level.fog_trigger_current = undefined;
	if ( !isDefined( level.trigger_flags ) )
	{
		init_trigger_flags();
	}
	trigger_funcs = [];
	trigger_funcs[ "flood_spawner" ] = ::maps/_spawner::flood_trigger_think;
	trigger_funcs[ "trigger_spawner" ] = ::maps/_spawner::trigger_spawner;
	trigger_funcs[ "trigger_autosave" ] = ::maps/_autosave::trigger_autosave;
	trigger_funcs[ "autosave_now" ] = ::maps/_autosave::autosave_now_trigger;
	trigger_funcs[ "trigger_unlock" ] = ::trigger_unlock;
	trigger_funcs[ "flag_set" ] = ::flag_set_trigger;
	trigger_funcs[ "flag_clear" ] = ::flag_clear_trigger;
	trigger_funcs[ "flag_on_cleared" ] = ::flag_on_cleared;
	trigger_funcs[ "flag_set_touching" ] = ::flag_set_touching;
	trigger_funcs[ "objective_event" ] = ::maps/_spawner::objective_event_init;
	trigger_funcs[ "friendly_respawn_trigger" ] = ::friendly_respawn_trigger;
	trigger_funcs[ "friendly_respawn_clear" ] = ::friendly_respawn_clear;
	trigger_funcs[ "trigger_ignore" ] = ::trigger_ignore;
	trigger_funcs[ "trigger_pacifist" ] = ::trigger_pacifist;
	trigger_funcs[ "trigger_delete" ] = ::trigger_turns_off;
	trigger_funcs[ "trigger_delete_on_touch" ] = ::trigger_delete_on_touch;
	trigger_funcs[ "trigger_off" ] = ::trigger_turns_off;
	trigger_funcs[ "trigger_outdoor" ] = ::maps/_spawner::outdoor_think;
	trigger_funcs[ "trigger_indoor" ] = ::maps/_spawner::indoor_think;
	trigger_funcs[ "trigger_hint" ] = ::trigger_hint;
	trigger_funcs[ "trigger_grenade_at_player" ] = ::throw_grenade_at_player_trigger;
	trigger_funcs[ "delete_link_chain" ] = ::delete_link_chain;
	trigger_funcs[ "trigger_fog" ] = ::trigger_fog;
	trigger_funcs[ "no_crouch_or_prone" ] = ::no_crouch_or_prone_think;
	trigger_funcs[ "no_prone" ] = ::no_prone_think;
	triggers = get_triggers( "trigger_radius", "trigger_multiple", "trigger_once", "trigger_box" );
	_a845 = triggers;
	_k845 = getFirstArrayKey( _a845 );
	while ( isDefined( _k845 ) )
	{
		trig = _a845[ _k845 ];
		if ( trig has_spawnflag( 32 ) )
		{
			level thread maps/_spawner::trigger_spawner( trig );
		}
		if ( trig has_spawnflag( 256 ) )
		{
			level thread trigger_look( trig );
		}
		_k845 = getNextArrayKey( _a845, _k845 );
	}
	triggers = get_triggers();
	_a859 = triggers;
	_k859 = getFirstArrayKey( _a859 );
	while ( isDefined( _k859 ) )
	{
		trig = _a859[ _k859 ];
		if ( trig.classname != "trigger_once" && is_trigger_once( trig ) )
		{
			level thread trigger_once( trig );
		}
		if ( isDefined( trig.script_flag_true ) )
		{
			level thread script_flag_true_trigger( trig );
		}
		if ( isDefined( trig.script_flag_set ) )
		{
			level thread flag_set_trigger( trig, trig.script_flag_set );
		}
		if ( isDefined( trig.script_flag_clear ) )
		{
			level thread flag_clear_trigger( trig, trig.script_flag_clear );
		}
		if ( isDefined( trig.script_flag_false ) )
		{
			level thread script_flag_false_trigger( trig );
		}
		if ( isDefined( trig.script_autosavename ) || isDefined( trig.script_autosave ) )
		{
			level thread maps/_autosave::autosave_name_think( trig );
		}
		if ( isDefined( trig.script_fallback ) )
		{
			level thread maps/_spawner::fallback_think( trig );
		}
		if ( isDefined( trig.script_killspawner ) )
		{
			level thread maps/_spawner::kill_spawner_trigger( trig );
		}
		if ( isDefined( trig.script_emptyspawner ) )
		{
			level thread maps/_spawner::empty_spawner( trig );
		}
		if ( isDefined( trig.script_prefab_exploder ) )
		{
			trig.script_exploder = trig.script_prefab_exploder;
		}
		if ( isDefined( trig.script_exploder ) )
		{
			level thread exploder_load( trig );
		}
		if ( isDefined( trig.script_trigger_group ) )
		{
			trig thread trigger_group();
		}
		if ( isDefined( trig.script_notify ) )
		{
			level thread trigger_notify( trig, trig.script_notify );
		}
		if ( isDefined( trig.targetname ) )
		{
			targetname = trig.targetname;
			if ( isDefined( trigger_funcs[ targetname ] ) )
			{
				level thread [[ trigger_funcs[ targetname ] ]]( trig );
			}
		}
		_k859 = getNextArrayKey( _a859, _k859 );
	}
}

level_struct_array_free()
{
	i = level.struct.size;
	while ( i >= 0 )
	{
		i--;

	}
	level.struct = undefined;
}

delete_bounce_light_brushes()
{
	a_m_lights = getentarray( "bounce_light_brush", "targetname" );
	_a957 = a_m_lights;
	_k957 = getFirstArrayKey( _a957 );
	while ( isDefined( _k957 ) )
	{
		m_light = _a957[ _k957 ];
		m_light delete();
		_k957 = getNextArrayKey( _a957, _k957 );
	}
}

perk_flags()
{
	flag_wait( "level.player" );
	level thread set_intruder_flag();
	level thread set_lockbreaker_flag();
	level thread set_bruteforce_flag();
}

set_intruder_flag()
{
	level.player waittill_player_has_intruder_perk();
	flag_set( "player_has_intruder" );
}

set_lockbreaker_flag()
{
	level.player waittill_player_has_lock_breaker_perk();
	flag_set( "player_has_lockbreaker" );
}

set_bruteforce_flag()
{
	level.player waittill_player_has_brute_force_perk();
	flag_set( "player_has_bruteforce" );
}
