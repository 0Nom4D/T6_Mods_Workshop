#include maps/_turret;
#include maps/_dds;
#include maps/_rusher;
#include maps/_patrol;
#include maps/_stealth_logic;
#include animscripts/death;
#include maps/_gameskill;
#include maps/_drones;
#include maps/ai_subclass/_subclass_main;
#include common_scripts/utility;
#include maps/_serverfaceanim;
#include maps/_anim;

main()
{
	createthreatbiasgroup( "allies" );
	createthreatbiasgroup( "axis" );
	level._nextcoverprint = 0;
	level._ai_group = [];
	level.killedaxis = 0;
	level.ffpoints = 0;
	level.missionfailed = 0;
	level.gather_delay = [];
	level.smoke_thrown = [];
	level.deathflags = [];
	level.spawner_number = 0;
	level.go_to_node_arrays = [];
	level.next_health_drop_time = 0;
	level.guys_to_die_before_next_health_drop = randomintrange( 1, 4 );
	level.default_goalradius = 2048;
	level.default_goalheight = 80;
	level.portable_mg_gun_tag = "J_Shoulder_RI";
	level.mg42_hide_distance = 1024;
	if ( !isDefined( level.maxfriendlies ) )
	{
		level.maxfriendlies = 11;
	}
	ai = getaispeciesarray( "all" );
	array_thread( ai, ::living_ai_prethink );
	level.ai_classname_in_level = [];
	spawners = getspawnerarray();
	i = 0;
	while ( i < spawners.size )
	{
		spawners[ i ] thread spawn_prethink();
		i++;
	}
	maps/ai_subclass/_subclass_main::subclass_setup_spawn_functions();
	thread process_deathflags();
	precache_player_weapon_drops( array( "rpg", "panzerschreck" ) );
	if ( isDefined( level.hiding_door_spawner ) )
	{
		run_thread_on_noteworthy( "hiding_door_spawner", level.hiding_door_spawner );
	}
	level thread trigger_spawner_monitor();
	waittillframeend;
	_a79 = ai;
	_k79 = getFirstArrayKey( _a79 );
	while ( isDefined( _k79 ) )
	{
		ai_guy = _a79[ _k79 ];
		if ( isalive( ai_guy ) )
		{
			ai_guy thread spawn_think();
		}
		_k79 = getNextArrayKey( _a79, _k79 );
	}
}

precache_player_weapon_drops( weapon_names )
{
	level.ai_classname_in_level_keys = getarraykeys( level.ai_classname_in_level );
	i = 0;
	while ( i < level.ai_classname_in_level_keys.size )
	{
		if ( weapon_names.size <= 0 )
		{
			break;
		}
		else
		{
			j = 0;
			while ( j < weapon_names.size )
			{
				weaponname = weapon_names[ j ];
				if ( !issubstr( tolower( level.ai_classname_in_level_keys[ i ] ), weaponname ) )
				{
					j++;
					continue;
				}
				else
				{
					precacheitem( weaponname + "_player_sp" );
					arrayremovevalue( weapon_names, weaponname );
					i++;
					continue;
				}
				j++;
			}
			i++;
		}
	}
	level.ai_classname_in_level_keys = undefined;
}

process_deathflags()
{
	keys = getarraykeys( level.deathflags );
	level.deathflags = [];
	i = 0;
	while ( i < keys.size )
	{
		deathflag = keys[ i ];
		level.deathflags[ deathflag ] = [];
		level.deathflags[ deathflag ][ "ai" ] = [];
		if ( !isDefined( level.flag[ deathflag ] ) )
		{
			flag_init( deathflag );
		}
		i++;
	}
}

spawn_guys_until_death_or_no_count()
{
	self endon( "death" );
	self waittill( "count_gone" );
}

ai_deathflag()
{
	level.deathflags[ self.script_deathflag ][ "ai" ][ self.ai_number ] = self;
	ai_number = self.ai_number;
	deathflag = self.script_deathflag;
	if ( isDefined( self.script_deathflag_longdeath ) )
	{
		self waittilldeathorpaindeath();
	}
	else
	{
		self waittill( "death" );
	}
	update_deathflag( deathflag );
}

spawner_deathflag()
{
	level.deathflags[ self.script_deathflag ] = 1;
	waittillframeend;
	if ( !isDefined( self ) || self.count == 0 )
	{
		return;
	}
	self.spawner_number = level.spawner_number;
	level.spawner_number++;
	level.deathflags[ self.script_deathflag ][ "spawners" ][ self.spawner_number ] = self;
	deathflag = self.script_deathflag;
	id = self.spawner_number;
	spawn_guys_until_death_or_no_count();
	update_deathflag( deathflag );
}

update_deathflag( deathflag )
{
	level notify( "updating_deathflag_" + deathflag );
	level endon( "updating_deathflag_" + deathflag );
	waittillframeend;
	aikeys = getarraykeys( level.deathflags[ deathflag ][ "ai" ] );
	if ( aikeys.size > 0 )
	{
		return;
	}
	flag_set( deathflag );
}

outdoor_think( trigger )
{
/#
	if ( !trigger has_spawnflag( 1 ) && !trigger has_spawnflag( 2 ) )
	{
		assert( trigger has_spawnflag( 4 ), "trigger_outdoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );
	}
#/
	trigger endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", guy );
		if ( !isai( guy ) )
		{
			continue;
		}
		else
		{
			guy thread ignore_triggers( 0,15 );
			guy reset_movemode();
			guy.wantshotgun = 0;
		}
	}
}

indoor_think( trigger )
{
/#
	if ( !trigger has_spawnflag( 1 ) && !trigger has_spawnflag( 2 ) )
	{
		assert( trigger has_spawnflag( 4 ), "trigger_indoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );
	}
#/
	trigger endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", guy );
		if ( !isai( guy ) )
		{
			continue;
		}
		else
		{
			guy thread ignore_triggers( 0,15 );
			guy change_movemode( "cqb" );
			guy.wantshotgun = 1;
		}
	}
}

trigger_spawner_monitor()
{
/#
	println( "Trigger spawner monitor running..." );
#/
	level._numtriggerspawned = 0;
	while ( 1 )
	{
		wait_network_frame();
		wait_network_frame();
		level._numtriggerspawned = 0;
	}
}

ok_to_trigger_spawn( forcechoke )
{
	if ( isDefined( forcechoke ) )
	{
		choked = forcechoke;
	}
	else
	{
		choked = 0;
	}
	if ( isDefined( self.script_trigger ) && numremoteclients() )
	{
		trigger = self.script_trigger;
		if ( isDefined( trigger.targetname ) && trigger.targetname == "flood_spawner" )
		{
			choked = 1;
			if ( isDefined( trigger.script_choke ) && !trigger.script_choke )
			{
				choked = 0;
			}
		}
		else
		{
			if ( trigger has_spawnflag( 32 ) )
			{
				if ( isDefined( trigger.script_choke ) && trigger.script_choke )
				{
					choked = 1;
				}
			}
		}
	}
	if ( isDefined( self.targetname ) || self.targetname == "drone_axis" && self.targetname == "drone_allies" )
	{
		choked = 1;
	}
	if ( isDefined( level._forcechoke ) && level._numtriggerspawned > 2 )
	{
		return 0;
	}
	if ( choked && numremoteclients() )
	{
		if ( level._numtriggerspawned > 2 )
		{
/#
			println( "Triggerspawn choke." );
#/
			return 0;
		}
	}
	return 1;
}

trigger_spawner( trigger )
{
/#
	assert( isDefined( trigger.target ), "Triggers with flag TRIGGER_SPAWN at " + trigger.origin + " must target at least one spawner." );
#/
	trigger endon( "death" );
	trigger trigger_wait();
	spawners = getentarray( trigger.target, "targetname" );
	_a337 = spawners;
	_k337 = getFirstArrayKey( _a337 );
	while ( isDefined( _k337 ) )
	{
		sp = _a337[ _k337 ];
		if ( isspawner( sp ) )
		{
			sp.script_trigger = trigger;
			sp thread trigger_spawner_spawns_guy();
		}
		_k337 = getNextArrayKey( _a337, _k337 );
	}
}

trigger_spawner_spawns_guy()
{
	self endon( "death" );
	self script_flag_wait();
	self script_delay();
	while ( !self ok_to_trigger_spawn() )
	{
		wait_network_frame();
	}
	self spawn_ai();
	level._numtriggerspawned++;
}

flood_spawner_scripted( spawners )
{
/#
	if ( isDefined( spawners ) )
	{
		assert( spawners.size, "Script tried to flood spawn without any spawners" );
	}
#/
	array_thread( spawners, ::flood_spawner_init );
	array_thread( spawners, ::flood_spawner_think );
}

reincrement_count_if_deleted( spawner )
{
	spawner endon( "death" );
	self waittill( "death" );
	if ( !isDefined( self ) )
	{
		spawner.count++;
	}
}

kill_trigger( trigger )
{
	if ( !isDefined( trigger ) )
	{
		return;
	}
	if ( isDefined( trigger.targetname ) && trigger.targetname != "flood_spawner" )
	{
		return;
	}
	trigger delete();
}

kill_spawner_trigger( trigger )
{
	trigger waittill( "trigger" );
	kill_spawnernum( trigger.script_killspawner );
}

empty_spawner( trigger )
{
	emptyspawner = trigger.script_emptyspawner;
	trigger waittill( "trigger" );
	spawners = getspawnerarray();
	i = 0;
	while ( i < spawners.size )
	{
		if ( !isDefined( spawners[ i ].script_emptyspawner ) )
		{
			i++;
			continue;
		}
		else if ( emptyspawner != spawners[ i ].script_emptyspawner )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( spawners[ i ].script_flanker ) )
			{
				level notify( "stop_flanker_behavior" + spawners[ i ].script_flanker );
			}
			spawners[ i ].count = 0;
			spawners[ i ] notify( "emptied spawner" );
		}
		i++;
	}
	trigger notify( "deleted spawners" );
}

waittilldeathorpaindeath()
{
	self endon( "death" );
	self waittill( "pain_death" );
}

drop_gear()
{
	team = self.team;
	waittilldeathorpaindeath();
	if ( !isDefined( self ) )
	{
		return;
	}
	self.ignoreforfixednodesafecheck = 1;
	if ( self.grenadeammo <= 0 )
	{
		return;
	}
	if ( isDefined( self.dropweapon ) && !self.dropweapon )
	{
		return;
	}
	level.nextgrenadedrop--;

	if ( level.nextgrenadedrop > 0 )
	{
		return;
	}
	level.nextgrenadedrop = 2 + randomint( 2 );
	spawn_grenade_bag( self.origin + ( randomint( 25 ) - 12, randomint( 25 ) - 12, 2 ) + vectorScale( ( 0, 0, 1 ), 42 ), ( 0, randomint( 360 ), 0 ), self.team );
}

spawn_grenade_bag( origin, angles, team )
{
	if ( !isDefined( level.grenade_cache ) || !isDefined( level.grenade_cache[ team ] ) )
	{
		level.grenade_cache_index[ team ] = 0;
		level.grenade_cache[ team ] = [];
	}
	index = level.grenade_cache_index[ team ];
	grenade = level.grenade_cache[ team ][ index ];
	if ( isDefined( grenade ) )
	{
		grenade delete();
	}
	count = self.grenadeammo;
	grenade = spawn( "weapon_" + self.grenadeweapon, origin );
	level.grenade_cache[ team ][ index ] = grenade;
	level.grenade_cache_index[ team ] = ( index + 1 ) % 16;
	grenade.angles = angles;
	grenade.count = count;
}

spawn_prethink()
{
/#
	assert( self != level );
#/
	level.ai_classname_in_level[ self.classname ] = 1;
/#
	if ( getDvar( "noai" ) != "off" )
	{
		self.count = 0;
		return;
#/
	}
	self maps/_drones::drone_add_spawner();
	if ( isDefined( self.script_aigroup ) )
	{
		aigroup_init( self.script_aigroup, self );
	}
	if ( isDefined( self.script_delete ) )
	{
		array_size = 0;
		if ( isDefined( level._ai_delete ) )
		{
			if ( isDefined( level._ai_delete[ self.script_delete ] ) )
			{
				array_size = level._ai_delete[ self.script_delete ].size;
			}
		}
		level._ai_delete[ self.script_delete ][ array_size ] = self;
	}
	if ( isDefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}
}

spawn_think( spawner )
{
	if ( !isalive( self ) )
	{
		return;
	}
/#
	assert( self != level );
#/
	self endon( "death" );
	if ( isDefined( self.script_aigroup ) )
	{
		flag_set( self.script_aigroup + "_spawning" );
		self thread aigroup_soldier_think( level._ai_group[ self.script_aigroup ] );
	}
	while ( isDefined( spawner ) && isDefined( spawner.script_delete ) )
	{
		i = 0;
		while ( i < level._ai_delete[ spawner.script_delete ].size )
		{
			if ( level._ai_delete[ spawner.script_delete ][ i ] != spawner )
			{
				level._ai_delete[ spawner.script_delete ][ i ] delete();
			}
			i++;
		}
	}
	if ( isDefined( spawner ) && isDefined( spawner.spawn_funcs ) )
	{
		self.spawn_funcs = spawner.spawn_funcs;
	}
	level.ai_classname_in_level[ self.classname ] = 1;
	spawn_think_action( spawner );
/#
	assert( isalive( self ) );
#/
	if ( !isDefined( self.name ) && self.type == "human" )
	{
		self waittill( "set name and rank" );
	}
	self.finished_spawning = 1;
	self notify( "finished spawning" );
	if ( !level.createfx_enabled )
	{
		self thread run_spawn_functions();
	}
/#
	assert( isDefined( self.team ) );
#/
}

run_spawn_functions()
{
	self endon( "death" );
	waittillframeend;
	i = 0;
	while ( i < level.spawn_funcs[ self.team ].size )
	{
		func = level.spawn_funcs[ self.team ][ i ];
		single_thread( self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ], func[ "param5" ] );
		i++;
	}
	if ( isDefined( self.spawn_funcs ) )
	{
		i = 0;
		while ( i < self.spawn_funcs.size )
		{
			func = self.spawn_funcs[ i ];
			single_thread( self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
			i++;
		}
/#
		self.saved_spawn_functions = self.spawn_funcs;
#/
		self.spawn_funcs = undefined;
/#
		self.spawn_funcs = self.saved_spawn_functions;
		self.saved_spawn_functions = undefined;
#/
		self.spawn_funcs = undefined;
	}
}

living_ai_prethink()
{
	if ( isDefined( self.script_deathflag ) )
	{
		level.deathflags[ self.script_deathflag ] = 1;
	}
	if ( isDefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}
}

crawl_through_targets_to_init_flags()
{
	array = get_node_funcs_based_on_target();
	while ( isDefined( array ) )
	{
		targets = array[ "node" ];
		get_func = array[ "get_target_func" ];
		i = 0;
		while ( i < targets.size )
		{
			crawl_target_and_init_flags( targets[ i ], get_func );
			i++;
		}
	}
}

remove_spawner_values()
{
	self.spawner_number = undefined;
}

spawn_think_action( spawner )
{
	remove_spawner_values();
	self thread maps/_serverfaceanim::init_serverfaceanim();
	if ( isDefined( spawner ) )
	{
		if ( isDefined( spawner.targetname ) && !isDefined( self.targetname ) )
		{
			self.targetname = spawner.targetname + "_ai";
		}
	}
	if ( isDefined( self.script_animname ) )
	{
		self.animname = self.script_animname;
	}
	if ( !isDefined( self.ai_number ) )
	{
		set_ai_number();
	}
	if ( isDefined( level.createfx_enabled ) && !level.createfx_enabled )
	{
		self thread maps/_utility::ent_flag_init_ai_standards();
/#
		thread show_bad_path();
#/
		set_default_pathenemy_settings();
		maps/ai_subclass/_subclass_main::run_subclass_spawn_function();
		if ( isDefined( self.script_dontshootwhilemoving ) )
		{
			self.dontshootwhilemoving = 1;
		}
		if ( isDefined( self.script_deathflag ) )
		{
			thread ai_deathflag();
		}
		if ( isDefined( self.script_forcecolor ) )
		{
			set_force_color( self.script_forcecolor );
			if ( isDefined( self.script_no_respawn ) && self.script_no_respawn < 1 && !isDefined( level.no_color_respawners_sm ) )
			{
				self thread replace_on_death();
			}
		}
		if ( isDefined( self.script_fixednode ) )
		{
			self.fixednode = self.script_fixednode == 1;
		}
		else
		{
			self.fixednode = self.team == "allies";
		}
		set_default_covering_fire();
		if ( isDefined( self.script_moveoverride ) && self.script_moveoverride == 1 )
		{
			override = 1;
		}
		else
		{
			override = 0;
		}
		if ( isDefined( self.script_threatbiasgroup ) )
		{
			self setthreatbiasgroup( self.script_threatbiasgroup );
		}
		else if ( self.team == "allies" )
		{
			self setthreatbiasgroup( "allies" );
		}
		else
		{
			self setthreatbiasgroup( "axis" );
		}
		self.heavy_machine_gunner = issubstr( self.classname, "mgportable" );
		maps/_gameskill::grenadeawareness();
		if ( isDefined( self.script_ignoreme ) )
		{
/#
			assert( self.script_ignoreme == 1, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
#/
			self.ignoreme = 1;
		}
		if ( isDefined( self.script_ignore_suppression ) )
		{
/#
			assert( self.script_ignore_suppression == 1, "Tried to set self.script_ignore_suppresion to false, not allowed. Just set it to undefined." );
#/
			self.ignoresuppression = 1;
		}
		if ( isDefined( self.script_hero ) )
		{
/#
			assert( self.script_hero == 1, "Tried to set script_hero to something other than 1" );
#/
			self make_hero();
		}
		if ( isDefined( self.script_ignoreall ) )
		{
/#
			assert( self.script_ignoreall == 1, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
#/
			self.ignoreall = 1;
			self clearenemy();
		}
		if ( isDefined( self.script_disablereact ) )
		{
			self disable_react();
		}
		if ( isDefined( self.script_disablepain ) )
		{
			self disable_pain();
		}
		if ( isDefined( self.script_disableturns ) )
		{
			self.disableturns = 1;
		}
		if ( isDefined( self.script_sightrange ) )
		{
			self.maxsightdistsqrd = self.script_sightrange;
		}
		else
		{
			if ( self.weaponclass == "gas" )
			{
				self.maxsightdistsqrd = 1048576;
			}
		}
		if ( self.team != "axis" )
		{
			if ( isDefined( self.script_followmin ) )
			{
				self.followmin = self.script_followmin;
			}
			if ( isDefined( self.script_followmax ) )
			{
				self.followmax = self.script_followmax;
			}
		}
		if ( self.team == "axis" )
		{
			if ( self.type == "human" )
			{
				self thread drop_gear();
			}
		}
		if ( isDefined( self.script_fightdist ) )
		{
			self.pathenemyfightdist = self.script_fightdist;
		}
		if ( isDefined( self.script_maxdist ) )
		{
			self.pathenemylookahead = self.script_maxdist;
		}
		if ( isDefined( self.script_longdeath ) )
		{
/#
			assert( !self.script_longdeath, "Long death is enabled by default so don't set script_longdeath to true, check ai with export " + self.export );
#/
			self.a.disablelongdeath = 1;
/#
			assert( self.team != "allies", "Allies can't do long death, so why disable it on guy with export " + self.export );
#/
		}
		if ( isDefined( self.script_grenades ) )
		{
			self.grenadeammo = self.script_grenades;
		}
		if ( isDefined( self.script_pacifist ) )
		{
			self.pacifist = 1;
		}
		if ( isDefined( self.script_startinghealth ) )
		{
			self.health = self.script_startinghealth;
		}
		if ( isDefined( self.script_allowdeath ) )
		{
			self.allowdeath = self.script_allowdeath;
		}
		if ( isDefined( self.script_nodropweapon ) )
		{
			self.dropweapon = 0;
		}
		if ( isDefined( self.script_forcegib ) )
		{
			self.force_gib = 1;
			if ( animscripts/death::isvalidgibref( self.script_forcegib ) )
			{
				self.custom_gib_refs[ 0 ] = self.script_forcegib;
			}
		}
		if ( isDefined( self.script_lights_on ) )
		{
			self.has_ir = 1;
		}
		if ( isDefined( self.script_stealth ) )
		{
			self thread maps/_stealth_logic::stealth_ai();
		}
		if ( isDefined( self.script_patroller ) )
		{
			self thread maps/_patrol::patrol();
			return;
		}
		if ( isDefined( self.script_rusher ) && self.script_rusher )
		{
			self maps/_rusher::rush();
			return;
		}
		if ( isDefined( self.script_enable_cqb ) )
		{
			self maps/_utility::change_movemode( "cqb" );
		}
		if ( isDefined( self.script_enable_heat ) )
		{
			self maps/_utility::enable_heat();
		}
		if ( isDefined( self.script_playerseek ) )
		{
			if ( self.script_playerseek == 1 )
			{
				self thread player_seek();
				return;
			}
			else
			{
				self thread player_seek( self.script_playerseek );
			}
		}
		if ( isDefined( self.used_an_mg42 ) )
		{
			return;
		}
/#
		if ( self.goalradius != 8 )
		{
			assert( self.goalradius == 4, "Changed the goalradius on guy without waiting for spawn_failed. Note that this change will NOT show up by putting a breakpoint on the actors goalradius field because breakpoints don't properly handle the first frame an actor exists." );
		}
#/
		if ( override )
		{
			self thread set_goalradius_based_on_settings();
			self setgoalpos( self.origin );
			return;
		}
		if ( isDefined( self.target ) )
		{
			self thread go_to_node();
		}
		else
		{
			self thread set_goalradius_based_on_settings();
			if ( isDefined( self.script_spawner_targets ) )
			{
				self thread go_to_spawner_target( strtok( self.script_spawner_targets, " " ) );
			}
		}
		if ( isDefined( self.script_goalvolume ) )
		{
			self thread set_goal_volume();
		}
		if ( isDefined( self.script_turnrate ) )
		{
			self.turnrate = self.script_turnrate;
		}
		self maps/_dds::dds_ai_init();
	}
}

set_default_covering_fire()
{
	if ( self.team == "allies" )
	{
		self.providecoveringfire = self.fixednode;
	}
}

set_goal_volume()
{
	self endon( "death" );
	waittillframeend;
	volume = level.goalvolumes[ self.script_goalvolume ];
	if ( !isDefined( volume ) )
	{
		return;
	}
	if ( isDefined( volume.target ) )
	{
		node = getnode( volume.target, "targetname" );
		ent = getent( volume.target, "targetname" );
		struct = getstruct( volume.target, "targetname" );
		pos = undefined;
		if ( isDefined( node ) )
		{
			pos = node;
			self setgoalnode( pos );
		}
		else if ( isDefined( ent ) )
		{
			pos = ent;
			self setgoalpos( pos.origin );
		}
		else
		{
			if ( isDefined( struct ) )
			{
				pos = struct;
				self setgoalpos( pos.origin );
			}
		}
		if ( isDefined( pos.radius ) && pos.radius != 0 )
		{
			self.goalradius = pos.radius;
		}
		if ( isDefined( pos.goalheight ) && pos.goalheight != 0 )
		{
			self.goalheight = pos.goalheight;
		}
	}
	if ( isDefined( self.target ) )
	{
		self setgoalvolume( volume );
	}
	else if ( isDefined( self.script_spawner_targets ) )
	{
		self waittill( "spawner_target_set" );
		self setgoalvolume( volume );
	}
	else
	{
		self setgoalvolumeauto( volume );
	}
}

get_target_ents( target )
{
	return getentarray( target, "targetname" );
}

get_target_nodes( target )
{
	return getnodearray( target, "targetname" );
}

get_target_structs( target )
{
	return getstructarray( target, "targetname" );
}

node_has_radius( node )
{
	if ( isDefined( node.radius ) )
	{
		return node.radius != 0;
	}
}

go_to_origin( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "origin", optional_arrived_at_node_func );
}

go_to_struct( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "struct", optional_arrived_at_node_func );
}

go_to_node( node, goal_type, optional_arrived_at_node_func )
{
	self endon( "death" );
	if ( isDefined( self.used_an_mg42 ) )
	{
		return;
	}
	array = get_node_funcs_based_on_target( node, goal_type );
	if ( !isDefined( array ) )
	{
		self notify( "reached_path_end" );
		return;
	}
	if ( !isDefined( optional_arrived_at_node_func ) )
	{
		optional_arrived_at_node_func = ::empty;
	}
	go_to_node_using_funcs( array[ "node" ], array[ "get_target_func" ], array[ "set_goal_func_quits" ], optional_arrived_at_node_func );
}

spawner_targets_init()
{
	allnodes = getallnodes();
	level.script_spawner_targets_nodes = [];
	i = 0;
	while ( i < allnodes.size )
	{
		if ( isDefined( allnodes[ i ].script_spawner_targets ) )
		{
			level.script_spawner_targets_nodes[ level.script_spawner_targets_nodes.size ] = allnodes[ i ];
		}
		i++;
	}
}

go_to_spawner_target( target_names )
{
	self endon( "death" );
	self notify( "go_to_spawner_target" );
	self endon( "go_to_spawner_target" );
	nodes = [];
	a_nodes_unavailable = [];
	nodespresent = 0;
	i = 0;
	while ( i < target_names.size )
	{
		target_nodes = get_spawner_target_nodes( target_names[ i ] );
		if ( target_nodes.size > 0 )
		{
			nodespresent = 1;
		}
		_a1211 = target_nodes;
		_k1211 = getFirstArrayKey( _a1211 );
		while ( isDefined( _k1211 ) )
		{
			node = _a1211[ _k1211 ];
			if ( isnodeoccupied( node ) || isDefined( node.node_claimed ) && node.node_claimed )
			{
				a_nodes_unavailable[ a_nodes_unavailable.size ] = node;
			}
			else
			{
				if ( node has_spawnflag( 512 ) )
				{
					a_nodes_unavailable[ a_nodes_unavailable.size ] = node;
					break;
				}
				else
				{
					nodes[ nodes.size ] = node;
				}
			}
			_k1211 = getNextArrayKey( _a1211, _k1211 );
		}
		i++;
	}
	while ( nodes.size == 0 )
	{
		while ( nodes.size == 0 )
		{
			_a1233 = a_nodes_unavailable;
			_k1233 = getFirstArrayKey( _a1233 );
			while ( isDefined( _k1233 ) )
			{
				node = _a1233[ _k1233 ];
				if ( !isnodeoccupied( node ) && isDefined( node.node_claimed ) && !node.node_claimed && !node has_spawnflag( 512 ) )
				{
					nodes[ nodes.size ] = node;
					break;
				}
				else
				{
					_k1233 = getNextArrayKey( _a1233, _k1233 );
				}
			}
			wait 0,2;
		}
	}
/#
	assert( nodespresent, "No spawner target nodes for AI." );
#/
	goal = undefined;
	if ( nodes.size > 0 )
	{
		goal = random( nodes );
	}
	if ( isDefined( goal ) )
	{
		if ( isDefined( self.script_radius ) )
		{
			self.goalradius = self.script_radius;
		}
		else
		{
			self.goalradius = 400;
		}
		goal.node_claimed = 1;
		self setgoalnode( goal );
		self notify( "spawner_target_set" );
		self thread release_spawner_target_node( goal );
		self waittill( "goal" );
	}
	self set_goalradius_based_on_settings( goal );
}

release_spawner_target_node( node )
{
	self waittill_any( "death", "goal_changed" );
	node.node_claimed = undefined;
}

get_spawner_target_nodes( group )
{
	if ( group == "" )
	{
		return [];
	}
	nodes = [];
	i = 0;
	while ( i < level.script_spawner_targets_nodes.size )
	{
		groups = strtok( level.script_spawner_targets_nodes[ i ].script_spawner_targets, " " );
		j = 0;
		while ( j < groups.size )
		{
			if ( groups[ j ] == group )
			{
				nodes[ nodes.size ] = level.script_spawner_targets_nodes[ i ];
			}
			j++;
		}
		i++;
	}
	return nodes;
}

get_least_used_from_array( array )
{
/#
	assert( array.size > 0, "Somehow array had zero entrees" );
#/
	if ( array.size == 1 )
	{
		return array[ 0 ];
	}
	targetname = array[ 0 ].targetname;
	if ( !isDefined( level.go_to_node_arrays[ targetname ] ) )
	{
		level.go_to_node_arrays[ targetname ] = array;
	}
	array = level.go_to_node_arrays[ targetname ];
	first = array[ 0 ];
	newarray = [];
	i = 0;
	while ( i < ( array.size - 1 ) )
	{
		newarray[ i ] = array[ i + 1 ];
		i++;
	}
	newarray[ array.size - 1 ] = array[ 0 ];
	level.go_to_node_arrays[ targetname ] = newarray;
	return first;
}

go_to_node_using_funcs( node, get_target_func, set_goal_func_quits, optional_arrived_at_node_func, require_player_dist )
{
	self endon( "stop_going_to_node" );
	self endon( "death" );
	for ( ;; )
	{
		node = get_least_used_from_array( node );
		player_wait_dist = require_player_dist;
		if ( isDefined( node.script_requires_player ) )
		{
			if ( node.script_requires_player > 1 )
			{
				player_wait_dist = node.script_requires_player;
			}
			else
			{
				player_wait_dist = 256;
			}
			node.script_requires_player = 0;
		}
		self set_goalradius_based_on_settings( node );
		if ( isDefined( node.height ) )
		{
			self.goalheight = node.height;
		}
		else
		{
			self.goalheight = level.default_goalheight;
		}
		[[ set_goal_func_quits ]]( node );
		self waittill( "goal" );
		[[ optional_arrived_at_node_func ]]( node );
		if ( isDefined( node.script_flag_set ) )
		{
			flag_set( node.script_flag_set );
		}
		if ( isDefined( node.script_flag_clear ) )
		{
			flag_set( node.script_flag_clear );
		}
		if ( isDefined( node.script_ent_flag_set ) )
		{
			if ( !self flag_exists( node.script_ent_flag_set ) )
			{
/#
				assertmsg( "Tried to set a ent flag  " + node.script_ent_flag_set + "  on a node, but it doesnt exist." );
#/
			}
			self ent_flag_set( node.script_ent_flag_set );
		}
		if ( isDefined( node.script_ent_flag_clear ) )
		{
			if ( !self flag_exists( node.script_ent_flag_clear ) )
			{
/#
				assertmsg( "Tried to clear a ent flag  " + node.script_ent_flag_clear + "  on a node, but it doesnt exist." );
#/
			}
			self ent_flag_clear( node.script_ent_flag_clear );
		}
		if ( targets_and_uses_turret( node ) )
		{
			return 1;
		}
		if ( isDefined( node.script_enable_cqb ) )
		{
			self change_movemode( "cqb" );
		}
		if ( isDefined( node.script_disable_cqb ) )
		{
			self reset_movemode();
		}
		if ( isDefined( node.script_enable_heat ) )
		{
			self enable_heat();
		}
		if ( isDefined( node.script_disable_heat ) )
		{
			self disable_heat();
		}
		if ( isDefined( node.script_sprint ) )
		{
			if ( node.script_sprint )
			{
				self.sprint = 1;
				break;
			}
			else
			{
				self.sprint = 0;
			}
		}
		if ( isDefined( node.script_flag_wait ) )
		{
			flag_wait( node.script_flag_wait );
		}
		while ( isDefined( node.script_requires_player ) )
		{
			node.script_requires_player = 0;
			if ( self go_to_node_wait_for_player( node, get_target_func, player_wait_dist ) )
			{
				node.script_requires_player = 1;
				node notify( "script_requires_player" );
				break;
			}
			else
			{
				wait 0,1;
			}
		}
		if ( isDefined( node.script_aigroup ) )
		{
			waittill_ai_group_cleared( node.script_aigroup );
		}
		node script_delay();
		if ( !isDefined( node.target ) )
		{
			break;
		}
		else nextnode_array = [[ get_target_func ]]( node.target );
		if ( !nextnode_array.size )
		{
			break;
		}
		else
		{
			node = nextnode_array;
		}
	}
	if ( isDefined( self.arrived_at_end_node_func ) )
	{
		[[ self.arrived_at_end_node_func ]]( node );
	}
	self notify( "reached_path_end" );
	if ( isDefined( self.delete_on_path_end ) )
	{
		self delete();
	}
	self set_goalradius_based_on_settings( node );
}

go_to_node_wait_for_player( node, get_target_func, dist )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( distancesquared( player.origin, node.origin ) < distancesquared( self.origin, node.origin ) )
		{
			return 1;
		}
		i++;
	}
	vec = anglesToForward( self.angles );
	if ( isDefined( node.target ) )
	{
		temp = [[ get_target_func ]]( node.target );
		if ( temp.size == 1 )
		{
			vec = vectornormalize( temp[ 0 ].origin - node.origin );
		}
		else
		{
			if ( isDefined( node.angles ) )
			{
				vec = anglesToForward( node.angles );
			}
		}
	}
	else
	{
		if ( isDefined( node.angles ) )
		{
			vec = anglesToForward( node.angles );
		}
	}
	vec2 = [];
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		vec2[ vec2.size ] = vectornormalize( player.origin - self.origin );
		i++;
	}
	i = 0;
	while ( i < vec2.size )
	{
		value = vec2[ i ];
		if ( vectordot( vec, value ) > 0 )
		{
			return 1;
		}
		i++;
	}
	dist2rd = dist * dist;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( distancesquared( player.origin, self.origin ) < dist2rd )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

go_to_node_set_goal_pos( ent )
{
	self set_goal_pos( ent.origin );
}

go_to_node_set_goal_node( node )
{
	self set_goal_node( node );
}

targets_and_uses_turret( node )
{
	if ( !isDefined( node.target ) )
	{
		return 0;
	}
	turrets = getentarray( node.target, "targetname" );
	if ( !turrets.size )
	{
		return 0;
	}
	turret = turrets[ 0 ];
	if ( turret.classname != "misc_turret" )
	{
		return 0;
	}
	self thread maps/_turret::use_turret( turret );
	return 1;
}

remove_crawled( ent )
{
	waittillframeend;
	if ( isDefined( ent ) )
	{
		ent.crawled = undefined;
	}
}

crawl_target_and_init_flags( ent, get_func )
{
	targets = [];
	index = 0;
	for ( ;; )
	{
		if ( !isDefined( ent.crawled ) )
		{
			ent.crawled = 1;
			level thread remove_crawled( ent );
			if ( isDefined( ent.script_flag_set ) )
			{
				if ( !isDefined( level.flag[ ent.script_flag_set ] ) )
				{
					flag_init( ent.script_flag_set );
				}
			}
			if ( isDefined( ent.script_flag_wait ) )
			{
				if ( !isDefined( level.flag[ ent.script_flag_wait ] ) )
				{
					flag_init( ent.script_flag_wait );
				}
			}
			if ( isDefined( ent.target ) )
			{
				new_targets = [[ get_func ]]( ent.target );
				targets = add_to_array( targets, new_targets );
			}
		}
		index++;
		if ( index >= targets.size )
		{
			return;
		}
		else
		{
			ent = targets[ index ];
		}
	}
}

get_node_funcs_based_on_target( node, goal_type )
{
	get_target_func[ "origin" ] = ::get_target_ents;
	get_target_func[ "node" ] = ::get_target_nodes;
	get_target_func[ "struct" ] = ::get_target_structs;
	set_goal_func_quits[ "origin" ] = ::go_to_node_set_goal_pos;
	set_goal_func_quits[ "struct" ] = ::go_to_node_set_goal_pos;
	set_goal_func_quits[ "node" ] = ::go_to_node_set_goal_node;
	if ( !isDefined( goal_type ) )
	{
		goal_type = "node";
	}
	array = [];
	if ( isDefined( node ) )
	{
		array[ "node" ][ 0 ] = node;
	}
	else
	{
		node = getentarray( self.target, "targetname" );
		if ( node.size > 0 )
		{
			goal_type = "origin";
		}
		if ( goal_type == "node" )
		{
			node = getnodearray( self.target, "targetname" );
			if ( !node.size )
			{
				node = getstructarray( self.target, "targetname" );
				if ( !node.size )
				{
					return;
				}
				goal_type = "struct";
			}
		}
		array[ "node" ] = node;
	}
	array[ "get_target_func" ] = get_target_func[ goal_type ];
	array[ "set_goal_func_quits" ] = set_goal_func_quits[ goal_type ];
	return array;
}

set_goalradius_based_on_settings( node )
{
	self endon( "death" );
	waittillframeend;
	if ( isDefined( self.script_radius ) )
	{
		self.goalradius = self.script_radius;
	}
	else if ( isDefined( node ) && node_has_radius( node ) )
	{
		self.goalradius = node.radius;
	}
	else
	{
		self.goalradius = level.default_goalradius;
	}
	if ( isDefined( self.script_forcegoal ) && self.script_forcegoal )
	{
		if ( self.script_forcegoal > 1 )
		{
		}
		else
		{
		}
		n_radius = undefined;
		self thread force_goal( undefined, n_radius );
	}
}

fallback_spawner_think( num, node_array, ignorewhilefallingback )
{
	self endon( "death" );
	level.max_fallbackers[ num ] += self.count;
	firstspawn = 1;
	while ( self.count > 0 )
	{
		self waittill( "spawned", spawn );
		if ( firstspawn )
		{
/#
			if ( getDvar( "fallback" ) == "1" )
			{
				println( "^a First spawned: ", num );
#/
			}
			level notify( "fallback_firstspawn" + num );
			firstspawn = 0;
		}
		wait 0,05;
		while ( spawn_failed( spawn ) )
		{
			level notify( "fallbacker_died" + num );
			level.max_fallbackers[ num ]--;

		}
		spawn thread fallback_ai_think( num, node_array, "is spawner", ignorewhilefallingback );
	}
}

fallback_ai_think_death( ai, num )
{
	ai waittill( "death" );
	level.current_fallbackers[ num ]--;

	level notify( "fallbacker_died" + num );
}

fallback_ai_think( num, node_array, spawner, ignorewhilefallingback )
{
	if ( !isDefined( self.fallback ) || !isDefined( self.fallback[ num ] ) )
	{
		self.fallback[ num ] = 1;
	}
	else
	{
		return;
	}
	self.script_fallback = num;
	if ( !isDefined( spawner ) )
	{
		level.current_fallbackers[ num ]++;
	}
	if ( isDefined( node_array ) && level.fallback_initiated[ num ] )
	{
		self thread fallback_ai( num, node_array, ignorewhilefallingback );
	}
	level thread fallback_ai_think_death( self, num );
}

fallback_death( ai, num )
{
	ai waittill( "death" );
	if ( isDefined( ai.fallback_node ) )
	{
		ai.fallback_node.fallback_occupied = 0;
	}
	level notify( "fallback_reached_goal" + num );
}

fallback_goal( ignorewhilefallingback )
{
	self waittill( "goal" );
	self.ignoresuppression = 0;
	if ( isDefined( ignorewhilefallingback ) && ignorewhilefallingback )
	{
		self.ignoreall = 0;
	}
	self notify( "fallback_notify" );
	self notify( "stop_coverprint" );
}

fallback_interrupt()
{
	self notify( "stop_fallback_interrupt" );
	self endon( "stop_fallback_interrupt" );
	self endon( "stop_going_to_node" );
	self endon( "goto next fallback" );
	self endon( "fallback_notify" );
	self endon( "death" );
	while ( 1 )
	{
		origin = self.origin;
		wait 2;
		if ( self.origin == origin )
		{
			self.ignoreall = 0;
			return;
		}
	}
}

fallback_ai( num, node_array, ignorewhilefallingback )
{
	self notify( "stop_going_to_node" );
	self endon( "stop_going_to_node" );
	self endon( "goto next fallback" );
	self endon( "death" );
	node = undefined;
	while ( 1 )
	{
/#
		assert( node_array.size >= level.current_fallbackers[ num ], "Number of fallbackers exceeds number of fallback nodes for fallback # " + num + ". Add more fallback nodes or reduce possible fallbackers." );
#/
		node = node_array[ randomint( node_array.size ) ];
		if ( !isDefined( node.fallback_occupied ) || !node.fallback_occupied )
		{
			node.fallback_occupied = 1;
			self.fallback_node = node;
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self stopuseturret();
	self.ignoresuppression = 1;
	if ( self.ignoreall == 0 && isDefined( ignorewhilefallingback ) && ignorewhilefallingback )
	{
		self.ignoreall = 1;
		self thread fallback_interrupt();
	}
	self setgoalnode( node );
	if ( node.radius != 0 )
	{
		self.goalradius = node.radius;
	}
	self endon( "death" );
	level thread fallback_death( self, num );
	self thread fallback_goal( ignorewhilefallingback );
/#
	if ( getDvar( "fallback" ) == "1" )
	{
		self thread coverprint( node.origin );
#/
	}
	self waittill( "fallback_notify" );
	level notify( "fallback_reached_goal" + num );
}

coverprint( org )
{
/#
	self endon( "fallback_notify" );
	self endon( "stop_coverprint" );
	self endon( "death" );
	while ( 1 )
	{
		line( self.origin + vectorScale( ( 0, 0, 1 ), 35 ), org, ( 0,2, 0,5, 0,8 ), 0,5 );
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 70 ), "Falling Back", ( 0,98, 0,4, 0,26 ), 0,85 );
		wait 0,05;
#/
	}
}

fallback_overmind( num, group, ignorewhilefallingback, percent )
{
	fallback_nodes = undefined;
	nodes = getallnodes();
	i = 0;
	while ( i < nodes.size )
	{
		if ( isDefined( nodes[ i ].script_fallback ) && nodes[ i ].script_fallback == num )
		{
			fallback_nodes = add_to_array( fallback_nodes, nodes[ i ] );
		}
		i++;
	}
	if ( isDefined( fallback_nodes ) )
	{
		level thread fallback_overmind_internal( num, group, fallback_nodes, ignorewhilefallingback, percent );
	}
}

fallback_overmind_internal( num, group, fallback_nodes, ignorewhilefallingback, percent )
{
	level.current_fallbackers[ num ] = 0;
	level.max_fallbackers[ num ] = 0;
	level.spawner_fallbackers[ num ] = 0;
	level.fallback_initiated[ num ] = 0;
	spawners = getspawnerarray();
	i = 0;
	while ( i < spawners.size )
	{
		if ( isDefined( spawners[ i ].script_fallback ) && spawners[ i ].script_fallback == num )
		{
			if ( spawners[ i ].count > 0 )
			{
				spawners[ i ] thread fallback_spawner_think( num, fallback_nodes, ignorewhilefallingback );
				level.spawner_fallbackers[ num ]++;
			}
		}
		i++;
	}
/#
	assert( level.spawner_fallbackers[ num ] <= fallback_nodes.size, "There are more fallback spawners than fallback nodes. Add more node or remove spawners from script_fallback: " + num );
#/
	ai = getaiarray();
	i = 0;
	while ( i < ai.size )
	{
		if ( isDefined( ai[ i ].script_fallback ) && ai[ i ].script_fallback == num )
		{
			ai[ i ] thread fallback_ai_think( num, undefined, undefined, ignorewhilefallingback );
		}
		i++;
	}
	if ( !level.current_fallbackers[ num ] && !level.spawner_fallbackers[ num ] )
	{
		return;
	}
	spawners = undefined;
	ai = undefined;
	thread fallback_wait( num, group, ignorewhilefallingback, percent );
	level waittill( "fallbacker_trigger" + num );
	fallback_add_previous_group( num, fallback_nodes );
/#
	if ( getDvar( "fallback" ) == "1" )
	{
		println( "^a fallback trigger hit: ", num );
#/
	}
	level.fallback_initiated[ num ] = 1;
	fallback_ai = undefined;
	ai = getaiarray();
	i = 0;
	while ( i < ai.size )
	{
		if ( isDefined( ai[ i ].script_fallback ) || ai[ i ].script_fallback == num && isDefined( ai[ i ].script_fallback_group ) && isDefined( group ) && ai[ i ].script_fallback_group == group )
		{
			fallback_ai = add_to_array( fallback_ai, ai[ i ] );
		}
		i++;
	}
	ai = undefined;
	if ( !isDefined( fallback_ai ) )
	{
		return;
	}
	if ( !isDefined( percent ) )
	{
		percent = 0,4;
	}
	first_half = fallback_ai.size * percent;
	first_half = int( first_half );
	level notify( "fallback initiated " + num );
	fallback_text( fallback_ai, 0, first_half );
	first_half_ai = [];
	i = 0;
	while ( i < first_half )
	{
		fallback_ai[ i ] thread fallback_ai( num, fallback_nodes, ignorewhilefallingback );
		first_half_ai[ i ] = fallback_ai[ i ];
		i++;
	}
	i = 0;
	while ( i < first_half )
	{
		level waittill( "fallback_reached_goal" + num );
		i++;
	}
	fallback_text( fallback_ai, first_half, fallback_ai.size );
	i = 0;
	while ( i < fallback_ai.size )
	{
		if ( isalive( fallback_ai[ i ] ) )
		{
			set_fallback = 1;
			p = 0;
			while ( p < first_half_ai.size )
			{
				if ( isalive( first_half_ai[ p ] ) )
				{
					if ( fallback_ai[ i ] == first_half_ai[ p ] )
					{
						set_fallback = 0;
					}
				}
				p++;
			}
			if ( set_fallback )
			{
				fallback_ai[ i ] thread fallback_ai( num, fallback_nodes, ignorewhilefallingback );
			}
		}
		i++;
	}
}

fallback_text( fallbackers, start, end )
{
	if ( getTime() <= level._nextcoverprint )
	{
		return;
	}
	i = start;
	while ( i < end )
	{
		if ( !isalive( fallbackers[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			level._nextcoverprint = getTime() + 2500 + randomint( 2000 );
			return;
		}
		i++;
	}
}

fallback_wait( num, group, ignorewhilefallingback, percent )
{
	level endon( "fallbacker_trigger" + num );
/#
	if ( getDvar( "fallback" ) == "1" )
	{
		println( "^a Fallback wait: ", num );
#/
	}
	i = 0;
	while ( i < level.spawner_fallbackers[ num ] )
	{
/#
		if ( getDvar( "fallback" ) == "1" )
		{
			println( "^a Waiting for spawners to be hit: ", num, " i: ", i );
#/
		}
		level waittill( "fallback_firstspawn" + num );
		i++;
	}
/#
	if ( getDvar( "fallback" ) == "1" )
	{
		println( "^a Waiting for AI to die, fall backers for group ", num, " is ", level.current_fallbackers[ num ] );
#/
	}
	ai = getaiarray();
	i = 0;
	while ( i < ai.size )
	{
		if ( isDefined( ai[ i ].script_fallback ) || ai[ i ].script_fallback == num && isDefined( ai[ i ].script_fallback_group ) && isDefined( group ) && ai[ i ].script_fallback_group == group )
		{
			ai[ i ] thread fallback_ai_think( num, undefined, undefined, ignorewhilefallingback );
		}
		i++;
	}
	ai = undefined;
	deadfallbackers = 0;
	while ( deadfallbackers < ( level.max_fallbackers[ num ] * percent ) )
	{
/#
		if ( getDvar( "fallback" ) == "1" )
		{
			println( ( "^cwaiting for " + deadfallbackers + " to be more than " ) + ( level.max_fallbackers[ num ] * 0,5 ) );
#/
		}
		level waittill( "fallbacker_died" + num );
		deadfallbackers++;
	}
/#
	println( deadfallbackers, " fallbackers have died, time to retreat" );
#/
	level notify( "fallbacker_trigger" + num );
}

fallback_think( trigger )
{
	ignorewhilefallingback = 0;
	if ( isDefined( trigger.script_ignoreall ) && trigger.script_ignoreall )
	{
		ignorewhilefallingback = 1;
	}
	if ( !isDefined( level.fallback ) || !isDefined( level.fallback[ trigger.script_fallback ] ) )
	{
		percent = 0,5;
		if ( isDefined( trigger.script_percent ) )
		{
			percent = trigger.script_percent / 100;
		}
		level thread fallback_overmind( trigger.script_fallback, trigger.script_fallback_group, ignorewhilefallingback, percent );
	}
	trigger waittill( "trigger" );
	level notify( "fallbacker_trigger" + trigger.script_fallback );
	kill_trigger( trigger );
}

fallback_add_previous_group( num, node_array )
{
	if ( !isDefined( level.current_fallbackers[ num - 1 ] ) )
	{
		return;
	}
	i = 0;
	while ( i < level.current_fallbackers[ num - 1 ] )
	{
		level.max_fallbackers[ num ]++;
		i++;
	}
	i = 0;
	while ( i < level.current_fallbackers[ num - 1 ] )
	{
		level.current_fallbackers[ num ]++;
		i++;
	}
	ai = getaiarray();
	i = 0;
	while ( i < ai.size )
	{
		if ( isDefined( ai[ i ].script_fallback ) && ai[ i ].script_fallback == ( num - 1 ) )
		{
			ai[ i ].script_fallback++;
			if ( isDefined( ai[ i ].fallback_node ) )
			{
				ai[ i ].fallback_node.fallback_occupied = 0;
				ai[ i ].fallback_node = undefined;
			}
		}
		i++;
	}
}

goalvolumes()
{
	volumes = getentarray( "info_volume", "classname" );
	level.deathchain_goalvolume = [];
	level.goalvolumes = [];
	i = 0;
	while ( i < volumes.size )
	{
		volume = volumes[ i ];
		if ( isDefined( volume.script_deathchain ) )
		{
			level.deathchain_goalvolume[ volume.script_deathchain ] = volume;
		}
		if ( isDefined( volume.script_goalvolume ) )
		{
			level.goalvolumes[ volume.script_goalvolume ] = volume;
		}
		i++;
	}
}

aigroup_init( aigroup, spawner )
{
	if ( !isDefined( level._ai_group[ aigroup ] ) )
	{
		level._ai_group[ aigroup ] = spawnstruct();
		level._ai_group[ aigroup ].aigroup = aigroup;
		level._ai_group[ aigroup ].aicount = 0;
		level._ai_group[ aigroup ].killed_count = 0;
		level._ai_group[ aigroup ].ai = [];
		level._ai_group[ aigroup ].spawners = [];
		level._ai_group[ aigroup ].cleared_count = 0;
		if ( !isDefined( level.flag[ aigroup + "_cleared" ] ) )
		{
			flag_init( aigroup + "_cleared" );
		}
		if ( !isDefined( level.flag[ aigroup + "_spawning" ] ) )
		{
			flag_init( aigroup + "_spawning" );
		}
		level thread set_ai_group_cleared_flag( level._ai_group[ aigroup ] );
	}
	if ( isDefined( spawner ) )
	{
		level._ai_group[ aigroup ].spawners[ level._ai_group[ aigroup ].spawners.size ] = spawner;
		spawner thread aigroup_spawner_death( level._ai_group[ aigroup ] );
	}
}

aigroup_spawner_death( tracker )
{
	self waittill( "death" );
	tracker notify( "update_aigroup" );
}

aigroup_soldier_think( tracker )
{
	tracker.aicount++;
	tracker.ai[ tracker.ai.size ] = self;
	tracker notify( "update_aigroup" );
	if ( isDefined( self.script_deathflag_longdeath ) )
	{
		self waittilldeathorpaindeath();
	}
	else
	{
		self waittill( "death" );
	}
	tracker.aicount--;

	tracker.killed_count++;
	tracker notify( "update_aigroup" );
}

set_ai_group_cleared_flag( tracker )
{
	waittillframeend;
	while ( ( tracker.aicount + get_ai_group_spawner_count( tracker.aigroup ) ) > tracker.cleared_count )
	{
		tracker waittill( "update_aigroup" );
	}
	flag_set( tracker.aigroup + "_cleared" );
}

flood_trigger_think( trigger )
{
/#
	assert( isDefined( trigger.target ), "flood_spawner at " + trigger.origin + " without target" );
#/
	floodspawners = getentarray( trigger.target, "targetname" );
/#
	assert( floodspawners.size, "flood_spawner at with target " + trigger.target + " without any targets" );
#/
	i = 0;
	while ( i < floodspawners.size )
	{
		floodspawners[ i ].script_trigger = trigger;
		i++;
	}
	array_thread( floodspawners, ::flood_spawner_init );
	trigger waittill( "trigger" );
	floodspawners = getentarray( trigger.target, "targetname" );
	array_thread( floodspawners, ::flood_spawner_think, trigger );
}

flood_spawner_init( spawner )
{
/#
	assert( self has_spawnflag( 1 ), "Spawner at origin" + self.origin + "/" + self getorigin() + " is not a spawner!" );
#/
}

trigger_requires_player( trigger )
{
	if ( !isDefined( trigger ) )
	{
		return 0;
	}
	return isDefined( trigger.script_requires_player );
}

flood_spawner_think( trigger )
{
	self endon( "death" );
	self notify( "stop current floodspawner" );
	self endon( "stop current floodspawner" );
	requires_player = trigger_requires_player( trigger );
	script_delay();
	while ( self.count > 0 )
	{
		while ( requires_player )
		{
			while ( !any_player_istouching( trigger ) )
			{
				wait 0,5;
			}
		}
		while ( !self ok_to_trigger_spawn() )
		{
			wait_network_frame();
		}
		soldier = self spawn_ai();
		while ( spawn_failed( soldier ) )
		{
			wait 2;
		}
		level._numtriggerspawned++;
		soldier thread reincrement_count_if_deleted( self );
		soldier waittill( "death", attacker );
		if ( !player_saw_kill( soldier, attacker ) )
		{
			self.count++;
		}
		while ( !isDefined( soldier ) )
		{
			continue;
		}
		if ( !script_wait( 1 ) )
		{
			players = get_players();
			if ( players.size == 1 )
			{
				wait randomfloatrange( 5, 9 );
				break;
			}
			else if ( players.size == 2 )
			{
				wait randomfloatrange( 3, 6 );
				break;
			}
			else if ( players.size == 3 )
			{
				wait randomfloatrange( 1, 4 );
				break;
			}
			else
			{
				if ( players.size == 4 )
				{
					wait randomfloatrange( 0,5, 1,5 );
				}
			}
		}
	}
}

player_saw_kill( guy, attacker )
{
	if ( isDefined( self.script_force_count ) )
	{
		if ( self.script_force_count )
		{
			return 1;
		}
	}
	if ( !isDefined( guy ) )
	{
		return 0;
	}
	if ( isalive( attacker ) )
	{
		if ( isplayer( attacker ) )
		{
			return 1;
		}
		players = get_players();
		q = 0;
		while ( q < players.size )
		{
			if ( distancesquared( attacker.origin, players[ q ].origin ) < 40000 )
			{
				return 1;
			}
			q++;
		}
	}
	else if ( isDefined( attacker ) )
	{
		if ( attacker.classname == "worldspawn" )
		{
			return 0;
		}
		player = get_closest_player( attacker.origin );
		if ( isDefined( player ) && distancesquared( attacker.origin, player.origin ) < 40000 )
		{
			return 1;
		}
	}
	closest_player = get_closest_player( guy.origin );
	if ( isDefined( closest_player ) && distancesquared( guy.origin, closest_player.origin ) < 40000 )
	{
		return 1;
	}
	return bullettracepassed( closest_player geteye(), guy geteye(), 0, undefined );
}

show_bad_path()
{
/#
	if ( getdebugdvar( "debug_badpath" ) == "" )
	{
		setdvar( "debug_badpath", "" );
	}
	self endon( "death" );
	last_bad_path_time = -5000;
	bad_path_count = 0;
	for ( ;; )
	{
		self waittill( "bad_path", badpathpos );
		if ( !isDefined( level.debug_badpath ) || !level.debug_badpath )
		{
			continue;
		}
		else
		{
			if ( ( getTime() - last_bad_path_time ) > 5000 )
			{
				bad_path_count = 0;
			}
			else
			{
				bad_path_count++;
			}
			last_bad_path_time = getTime();
			if ( bad_path_count < 10 )
			{
				break;
			}
			else
			{
				p = 0;
				while ( p < 200 )
				{
					line( self.origin, badpathpos, ( 1, 0,4, 0,1 ), 0, 200 );
					wait 0,05;
					p++;
				}
			}
		}
#/
	}
}

objective_event_init( trigger )
{
	flag = trigger get_trigger_flag();
/#
	assert( isDefined( flag ), "Objective event at origin " + trigger.origin + " does not have a script_flag. " );
#/
	flag_init( flag );
/#
	assert( isDefined( level.deathspawner[ trigger.script_deathchain ] ), "The objective event trigger for deathchain " + trigger.script_deathchain + " is not associated with any AI." );
#/
/#
	if ( !isDefined( level.deathspawner[ trigger.script_deathchain ] ) )
	{
		return;
#/
	}
	while ( level.deathspawner[ trigger.script_deathchain ] > 0 )
	{
		level waittill( "spawner_expired" + trigger.script_deathchain );
	}
	flag_set( flag );
}

watches_for_friendly_fire()
{
	return 1;
}
