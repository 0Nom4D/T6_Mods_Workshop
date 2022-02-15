#include maps/_so_rts_main;
#include animscripts/utility;
#include maps/_anim;
#include maps/_osprey;
#include maps/_so_rts_squad;
#include maps/_quadrotor;
#include maps/_metal_storm;
#include maps/_names;
#include animscripts/bigdog/bigdog_init;
#include maps/_turret;
#include animscripts/shared;
#include maps/_so_rts_event;
#include maps/_damagefeedback;
#include maps/_so_rts_ai;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );
#using_animtree( "vehicles" );
#using_animtree( "fxanim_props" );

ai_preload()
{
/#
	assert( isDefined( level.rts ) );
#/
/#
	assert( isDefined( level.rts_def_table ) );
#/
	flag_init( "aggressive_mode" );
	level.rts.boss_drop_target = undefined;
	level.rts.helotargetlocations = [];
	level.rts.ai = [];
	level.rts.ai = ai_type_populate();
	level.allowexposedaigrenadethrow = 1;
	level.onlyallowfrags = 0;
}

ai_getgrenadetype( team )
{
	if ( is_true( level.onlyallowfrags ) )
	{
		return "frag_grenade_sp";
	}
	if ( isDefined( level.rts.custom_ai_getgrenadecb ) )
	{
		grenade = [[ level.rts.custom_ai_getgrenadecb ]]( team );
		if ( !isDefined( grenade ) )
		{
			return undefined;
		}
		if ( grenade != "" )
		{
			return grenade;
		}
	}
	roll = randomint( 100 );
	if ( team == "axis" )
	{
		if ( roll >= 90 )
		{
			return "flash_grenade_sp";
		}
		if ( roll >= 75 )
		{
			return "willy_pete_sp";
		}
		if ( level.era == "twentytwenty" )
		{
			if ( roll >= 60 )
			{
				return "sticky_grenade_future_ai_sp";
			}
			if ( roll >= 35 )
			{
				return "emp_grenade_sp";
			}
		}
		return "frag_grenade_sp";
	}
	if ( team == "allies" )
	{
		if ( roll >= 90 )
		{
			return "flash_grenade_sp";
		}
		if ( roll >= 75 )
		{
			return "willy_pete_sp";
		}
		if ( level.era == "twentytwenty" )
		{
			if ( roll >= 60 )
			{
				return "sticky_grenade_future_ai_sp";
			}
			if ( roll >= 35 )
			{
				return "emp_grenade_sp";
			}
		}
		return "frag_grenade_sp";
	}
}

ai_exist( ref )
{
	if ( isDefined( level.rts.ai ) )
	{
		return isDefined( level.rts.ai[ ref ] );
	}
}

get_ai_ref_by_index( idx )
{
	return tablelookup( level.rts_def_table, 0, idx, 1 );
}

lookup_value( ref, idx, column_index )
{
/#
	assert( isDefined( idx ) );
#/
	return tablelookup( level.rts_def_table, 0, idx, column_index );
}

ai_init()
{
	level.rts.additional_ai_initializers = [];
	level.rts.additional_ai_initializers[ "metalstorm" ] = ::vehicle_initialize;
	level.rts.additional_ai_initializers[ "bigdog" ] = ::bigdog_initialize;
	level.rts.additional_ai_initializers[ "quadrotor" ] = ::vehicle_initialize;
	level.rts.additional_ai_initializers[ "spider" ] = ::spider_initialize;
	add_global_spawn_function( "axis", ::no_grenade_bag_drop );
	add_global_spawn_function( "axis", ::update_enemy_remaining );
	add_global_spawn_function( "axis", ::ai_on_long_death );
	add_global_spawn_function( "axis", ::ai_on_flashed );
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	level thread ai_unload_watcher();
}

ai_unload_watcher()
{
	level endon( "rts_terminated" );
	while ( 1 )
	{
		level waittill( "helicopter_unloaded_ai", guy );
		guy maps/_so_rts_ai::ai_postinitialize();
		guy.rts_unloaded = 1;
		if ( guy.ai_ref.species == "human" )
		{
			guy getperfectinfo( level.rts.player );
		}
	}
}

ai_type_populate()
{
	ai_types = [];
	i = 0;
	while ( i <= 30 )
	{
		ref = get_ai_ref_by_index( i );
		if ( !isDefined( ref ) || ref == "" )
		{
			i++;
			continue;
		}
		else
		{
			ai = spawnstruct();
			ai.idx = i;
			ai.ref = ref;
			ai.equipment = lookup_value( ref, i, 2 );
			ai.armor = int( lookup_value( ref, i, 3 ) );
			ai.health = int( lookup_value( ref, i, 4 ) );
			ai.accuracy = float( lookup_value( ref, i, 5 ) );
			ai.name = lookup_value( ref, i, 6 );
			ai.desc = lookup_value( ref, i, 7 );
			ai.initializer = lookup_value( ref, i, 8 );
			ai.species = lookup_value( ref, i, 9 );
			ai.swap_spawner = lookup_value( ref, i, 10 );
			ai.swap_notify = lookup_value( ref, i, 11 );
			ai.regenrate = float( lookup_value( ref, i, 12 ) );
			ai.seat = int( lookup_value( ref, i, 13 ) );
			ai.cmd_tag = lookup_value( ref, i, 14 );
			if ( ai.swap_spawner == "" )
			{
				ai.swap_spawner = undefined;
			}
			if ( ai.swap_notify == "" )
			{
				ai.swap_notify = undefined;
			}
			if ( ai.cmd_tag == "" )
			{
				ai.cmd_tag = undefined;
			}
			ai_types[ ref ] = ai;
		}
		i++;
	}
	return ai_types;
}

ai_istakeoverpossible( ai )
{
	if ( !is_alive( ai ) )
	{
		return 0;
	}
	if ( !is_true( ai.rts_unloaded ) )
	{
		return 0;
	}
	if ( !is_true( ai.initialized ) )
	{
		return 0;
	}
	if ( isDefined( ai.melee ) )
	{
		return 0;
	}
	if ( isDefined( ai.no_takeover ) )
	{
		return 0;
	}
	return 1;
}

ai_isselectable( ai )
{
	if ( !is_alive( ai ) )
	{
		return 0;
	}
	if ( !is_true( ai.rts_unloaded ) )
	{
		return 0;
	}
	if ( !is_true( ai.initialized ) )
	{
		return 0;
	}
	if ( isDefined( ai.melee ) )
	{
		return 0;
	}
	if ( is_true( ai.unselectable ) )
	{
		return 0;
	}
	if ( isDefined( ai.squadid ) && !is_true( level.rts.squads[ ai.squadid ].selectable ) && !is_true( level.rts.squads[ ai.squadid ].forceallowselect ) )
	{
		return 0;
	}
	return 1;
}

getaibyspecies( species, team )
{
	ais = [];
	if ( isDefined( team ) )
	{
		ailist = arraycombine( getaiarray( team ), getvehiclearray( team ), 0, 0 );
	}
	else
	{
		ailist = arraycombine( getaiarray(), getvehiclearray(), 0, 0 );
	}
	_a282 = ailist;
	_k282 = getFirstArrayKey( _a282 );
	while ( isDefined( _k282 ) )
	{
		guy = _a282[ _k282 ];
		if ( isDefined( guy.ai_ref ) && guy.ai_ref.species == species && is_true( guy.rts_unloaded ) )
		{
			ais[ ais.size ] = guy;
		}
		_k282 = getNextArrayKey( _a282, _k282 );
	}
	return ais;
}

get_war_enemies_living()
{
	enemy_array = getaiarray( "axis" );
	if ( isDefined( level.bosses ) && level.bosses.size )
	{
		enemy_array = arraycombine( enemy_array, level.bosses, 0, 0 );
	}
	return enemy_array;
}

update_enemy_remaining()
{
	level endon( "rts_terminated" );
	waittillframeend;
	level.rts.enemy_remaining = get_war_enemies_living().size;
	level notify( "axis_spawned" );
	self waittill( "death" );
	waittillframeend;
	enemies_alive = get_war_enemies_living();
	level.rts.enemy_remaining = enemies_alive.size;
	level notify( "axis_died" );
	if ( flag( "aggressive_mode" ) && enemies_alive.size == 1 && isai( enemies_alive[ 0 ] ) && enemies_alive[ 0 ].type != "dog" )
	{
		enemies_alive[ 0 ] thread prevent_long_death();
	}
}

get_enemies_living()
{
	enemy_array = getaiarray( "axis" );
	if ( isDefined( level.rts.bosses ) && level.rts.bosses.size )
	{
		enemy_array = arraycombine( enemy_array, level.rts.bosses, 0, 0 );
	}
	return enemy_array;
}

prevent_long_death()
{
	level endon( "rts_terminated" );
	self endon( "death" );
	if ( !isDefined( self.a.doinglongdeath ) )
	{
		self disable_long_death();
		return;
	}
	while ( 1 )
	{
		safe_to_kill = 1;
		_a368 = getplayers();
		_k368 = getFirstArrayKey( _a368 );
		while ( isDefined( _k368 ) )
		{
			player = _a368[ _k368 ];
			player_too_close = distance2d( player.origin, self.origin ) < 540;
			if ( player_too_close )
			{
				safe_to_kill = 0;
				break;
			}
			else if ( self cansee( player ) )
			{
				safe_to_kill = 0;
				break;
			}
			else
			{
				wait 0,05;
				_k368 = getNextArrayKey( _a368, _k368 );
			}
		}
		if ( safe_to_kill )
		{
			attacker = self get_last_attacker();
			if ( isDefined( attacker ) )
			{
				self kill( self.origin, attacker );
			}
			else
			{
				self kill( self.origin );
			}
			return;
		}
		wait 0,1;
	}
}

get_last_attacker()
{
/#
	assert( isDefined( self ), "Self must be defined to check for last attacker." );
#/
	attacker = undefined;
	if ( isDefined( self.attacker_list ) && self.attacker_list.size )
	{
		attacker = self.attacker_list[ self.attacker_list.size - 1 ];
	}
	return attacker;
}

no_grenade_bag_drop()
{
	level.nextgrenadedrop = 100000;
}

ai_on_long_death()
{
	if ( !isai( self ) || isDefined( self.type ) && self.type == "dog" )
	{
		return;
	}
	self endon( "death" );
	level endon( "rts_terminated" );
	self waittill( "long_death" );
	self waittill( "flashbang", amount_distance, amount_angle, attacker, attackerteam );
	if ( isDefined( attacker ) && isDefined( attacker.team ) && attacker.team == "allies" )
	{
		self kill( self.origin, attacker );
	}
}

ai_on_flashed()
{
	self endon( "death" );
	level endon( "rts_terminated" );
	self waittill( "flashbang", flash_origin, flash_dist, flash_angle, attacker );
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		attacker maps/_damagefeedback::updatedamagefeedback();
	}
}

ai_getclassification( ai )
{
/#
	assert( isDefined( ai.ai_ref ) );
#/
	return istring( ai.ai_ref.name );
}

ai_deathmonitor()
{
	self notify( "ai_DeathMonitor" );
	self endon( "ai_DeathMonitor" );
	entnum = self getentitynumber();
	self waittill( "death" );
	luinotifyevent( &"rts_remove_ai", 1, entnum );
}

ai_died( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		self notsolid();
		self setclientflag( 7 );
	}
	else
	{
		self setclientflag( 6 );
	}
/#
	if ( isDefined( smeansofdeath ) )
	{
	}
	else
	{
	}
	if ( isDefined( self.squadid ) )
	{
	}
	else
	{
	}
	if ( isDefined( sweapon ) )
	{
	}
	else
	{
	}
	if ( isDefined( self.hits ) )
	{
	}
	else
	{
	}
	println( self.hits + 0, ( sweapon + "Unk" ) + "Damage: " + idamage + " Took #hits:", ( self.squadid + "NA" ) + " Team: " + self.team + " Type: " + self.classname + "Weapon: ", ( smeansofdeath + "unknown" ) + " SquadID:", "@@@ AI DIED (" + self getentnum() + ") at " + getTime() + " by " );
#/
}

ai_deathwatch( einflictor, eattacker, idamage, meansofdeath )
{
	if ( meansofdeath == "MOD_CRUSH" && isDefined( einflictor ) && isDefined( einflictor.vteam ) && einflictor.vteam == self.team )
	{
		return 0;
	}
	if ( isDefined( eattacker ) && isDefined( eattacker.team ) && eattacker.team == self.team )
	{
		return 0;
	}
	if ( isDefined( einflictor ) && isDefined( einflictor.team ) && einflictor.team == self.team )
	{
		return 0;
	}
	if ( isDefined( level.rts.ai_damage_cb ) )
	{
		idamage = [[ level.rts.ai_damage_cb ]]( einflictor, eattacker, idamage, meansofdeath );
	}
	if ( meansofdeath == "MOD_UNKNOWN" )
	{
		i = 1;
	}
	if ( self.team == "allies" )
	{
		if ( flag( "rts_mode" ) )
		{
			idamage = int( idamage * level.rts.game_rules.ally_dmg_reducerrts );
		}
		else
		{
			if ( flag( "fps_mode" ) )
			{
				idamage = int( idamage * level.rts.game_rules.ally_dmg_reducerfps );
			}
		}
	}
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" && isDefined( self.player ) )
	{
/#
		if ( isDefined( self.armor ) )
		{
		}
		else
		{
		}
		if ( isDefined( einflictor.ai_ref ) )
		{
		}
		else
		{
		}
		println( einflictor.ai_ref.ref + "Unk", ( self.armor + 0 ) + "\t Health: " + self.health + " eInflictor:", "@@@ PLAYER VEHICLE DAMAGE ENT(" + self getentnum() + ") Type:" + meansofdeath + " Damage: " + idamage + " Armor Left:" );
#/
		if ( isDefined( eattacker ) && eattacker == self.player )
		{
			return 0;
		}
	}
	self.lasthitstamp = getTime();
	if ( !isDefined( self.hits ) )
	{
		self.hits = 1;
	}
	else
	{
		self.hits++;
	}
	if ( isDefined( self.armor ) && self.armor > 0 )
	{
		self.armor -= idamage;
		if ( self.armor > 0 )
		{
			idamage = 0;
		}
		else
		{
			idamage = self.armor * -1;
			self.armor = undefined;
		}
	}
	if ( self.health > 0 )
	{
		if ( isDefined( self.armor ) && self.armor > 0 )
		{
/#
			if ( isDefined( self.armor ) )
			{
			}
			else
			{
			}
			println( ( self.armor + 0 ) + "\t Health: " + self.health, "@@@ AI(" + self getentnum() + ") Damage: " + idamage + " Armor Left:" );
#/
		}
		if ( idamage > self.health )
		{
			self notify( "death_incomming" );
			if ( self.team == "allies" )
			{
				if ( flag( "fps_mode" ) )
				{
					maps/_so_rts_event::trigger_event( "diedfps_" + self.pkg_ref.ref );
				}
				else
				{
					maps/_so_rts_event::trigger_event( "died_" + self.pkg_ref.ref );
				}
			}
		}
		else
		{
			if ( self.health < 0 )
			{
			}
			else
			{
			}
			luinotifyevent( &"rts_update_health", 3, self getentitynumber(), self.health, 0, self.health_max );
		}
	}
	return idamage;
}

set_vehicle_damage_override()
{
	self.overridevehicledamageorig = self.overridevehicledamage;
	if ( is_true( level.friendlyfiredisabled ) )
	{
		self.friendlyfire_shield = 0;
	}
	else
	{
		self.friendlyfire_shield = 1;
	}
	self.overridevehicledamage = ::veh_deathwatch;
	self.callbackvehiclekilled = ::ai_died;
	if ( isDefined( self.overridevehicledamageorig ) )
	{
/#
		assert( self.overridevehicledamageorig != self.overridevehicledamage, "Cyclical damage callbacks" );
#/
	}
}

veh_deathwatch( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
	if ( isDefined( self.player ) && isDefined( self.player.blockalldamage ) && getTime() < self.player.blockalldamage )
	{
		idamage = 0;
	}
	if ( isDefined( self.overridevehicledamageorig ) && self.overridevehicledamageorig != ::veh_deathwatch )
	{
		idamage = [[ self.overridevehicledamageorig ]]( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name );
	}
	return self ai_deathwatch( einflictor, eattacker, idamage, str_means_of_death );
}

set_actor_damage_override()
{
	self.overrideactordamageorig = self.overrideactordamage;
	self.overrideactordamage = ::actor_deathwatch;
	self.overrideactorkilled = ::ai_died;
	if ( isDefined( self.overrideactordamageorig ) )
	{
/#
		assert( self.overrideactordamageorig != self.overrideactordamage, "Cyclical damage callbacks" );
#/
	}
}

actor_deathwatch( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename )
{
	if ( isDefined( self.overrideactordamageorig ) && self.overrideactordamageorig != ::actor_deathwatch )
	{
		idamage = [[ self.overrideactordamageorig ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename );
	}
	return self ai_deathwatch( einflictor, eattacker, idamage, smeansofdeath );
}

enemy_contact_watcher()
{
	self notify( "enemy_contact_watcher" );
	self endon( "enemy_contact_watcher" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self waittill( "enemy" );
		while ( !is_true( self.rts_unloaded ) )
		{
			continue;
		}
		if ( isDefined( self.enemy ) && self canshootenemy() )
		{
			if ( isDefined( self.enemy.pkg_ref ) )
			{
				maps/_so_rts_event::trigger_event( "dlg_enemy_" + self.enemy.pkg_ref.ref );
			}
		}
		wait 1;
	}
}

enemy_death_watcher()
{
	self notify( "enemy_death_watcher" );
	self endon( "enemy_death_watcher" );
	pkg_ref = self.pkg_ref;
	self waittill( "death" );
	maps/_so_rts_event::trigger_event( "dlg_deadenemy_" + pkg_ref.ref );
}

ai_claymore_plant()
{
	self endon( "death" );
	self.a.deathforceragdoll = 1;
	self clearanim( %root, 0,2 );
	claymore = spawn_model( "weapon_claymore", self gettagorigin( "tag_inhand" ), self gettagangles( "tag_inhand" ) );
	claymore linkto( self, "tag_inhand", ( 0, 0, -1 ), vectorScale( ( 0, 0, -1 ), 90 ) );
/#
	recordent( claymore );
#/
	self thread ai_claymore_plant_cleanup( claymore );
	self.a.movement = "stop";
	self setflaggedanimknobrestart( "plantAnim", %ai_plant_claymore, 1, 0,2, 1 );
	self animscripts/shared::donotetracks( "plantAnim", ::ai_claymore_handle_notetracks );
	self.a.deathforceragdoll = 0;
	self findbestcovernode();
}

ai_claymore_plant_cleanup( claymore )
{
	self waittill_any( "death", "planted_claymore" );
	claymore delete();
}

ai_claymore_handle_notetracks( notetrack )
{
	if ( notetrack == "plant" )
	{
		self notify( "planted_claymore" );
		self thread maps/_so_rts_support::claymore_create( self.plant_origin, self.plant_angles, self.team );
		if ( self.team == level.rts.player.team )
		{
			maps/_so_rts_event::trigger_event( "dlg_claymoreplant" );
		}
	}
}

ai_claymore_abortwatch( oldrad, oldpos )
{
	self endon( "death" );
	self endon( "claymore_set" );
	self notify( "ai_claymore_AbortWatch" );
	self endon( "ai_claymore_AbortWatch" );
	self waittill( "new_squad_orders" );
	self.goalradius = oldrad;
	self setgoalpos( oldpos );
}

ai_claymore_plantwatch()
{
	self endon( "death" );
	while ( self.num_claymores > 0 )
	{
		wait 5;
		if ( is_true( self.at_goal ) )
		{
			if ( !isDefined( self.enemy ) )
			{
				claymore_locs = maps/_so_rts_support::sortarraybyclosest( self.goalpos, getentarray( "claymore_loc", "targetname" ), self.goalradius * self.goalradius );
				if ( claymore_locs.size > 0 )
				{
					self thread ai_claymore_abortwatch( self.goalradius, self.goalpos );
					oldgoalradius = self.goalradius;
					oldgoalpos = self.goalpos;
					self.goalradius = 24;
					self.plant_origin = claymore_locs[ 0 ].origin;
					self.plant_angles = claymore_locs[ 0 ].angles;
					claymore_locs[ 0 ] delete();
					self setgoalpos( self.plant_origin );
					self waittill( "goal" );
					while ( distance( self.origin, self.plant_origin ) > 32 )
					{
						continue;
					}
					self animcustom( ::ai_claymore_plant );
					self.num_claymores--;

					self.goalradius = oldgoalradius;
					self setgoalpos( oldgoalpos );
					self notify( "claymore_set" );
				}
			}
		}
	}
}

ai_initalize_equipment( ai_ref )
{
	if ( isDefined( ai_ref.equipment ) )
	{
		switch( ai_ref.equipment )
		{
			case "claymore":
				self.num_claymores = 2;
				break;
			return;
		}
	}
}

ai_preinitialize( ref, pkg_ref, team, squadid )
{
	self.ai_ref = ref;
	self.pkg_ref = pkg_ref;
	self.team = team;
	self.squadid = squadid;
	self.ignoreme = 1;
	self.ignoreall = 1;
	self.script_toggletakedamage = 1;
	self.takedamage = 0;
	self.goodenemyonly = 1;
	self.highlyawareradius = 512;
	self.pathenemyfightdist = 256;
	self.maxvisibledist = 1024;
	self.maxsightdistsqrd = 1048576;
	if ( !is_true( self.no_sonar ) )
	{
		if ( self.team == "allies" )
		{
		}
		else
		{
		}
		self maps/_so_rts_support::set_gpr( 1 + 0, maps/_so_rts_support::make_gpr_opcode( 1 ) );
	}
	if ( isDefined( ref ) )
	{
		if ( isDefined( ref.initializer ) && isDefined( level.rts.additional_ai_initializers[ ref.initializer ] ) )
		{
			self thread [[ level.rts.additional_ai_initializers[ ref.initializer ] ]]();
		}
	}
	self.preinitialized = 1;
}

ai_postinitialize()
{
	self.ignoreme = 0;
	self.ignoreall = 0;
	self.takedamage = 1;
	self.postinitialized = 1;
	if ( isai( self ) && !is_true( self.isbigdog ) && isalive( self ) )
	{
		self disable_react();
	}
	if ( is_true( self.isbigdog ) )
	{
		self.shoot_only_on_sight = 1;
		self.bigdogusebiggerbadplace = 1;
		self.turret maps/_turret::set_turret_team( self.team );
		animscripts/bigdog/bigdog_init::bigdog_lights_off();
		animscripts/bigdog/bigdog_init::bigdog_lights_on();
	}
}

ai_initialize( ref, team, origin, squadid, angles, pkg_ref, health )
{
	if ( flag( "rts_game_over" ) )
	{
		return;
	}
/#
	assert( !isDefined( self.initialized ), "AI being reinitialized" );
#/
/#
	assert( isDefined( self.preinitialized ), "AI not preinitialized" );
#/
	self.initialized = 1;
	if ( isDefined( health ) && health > 0 )
	{
		self.health = health;
	}
	else
	{
		self.health = ref.health;
	}
	if ( self.health < 10 )
	{
		self.health = 10;
	}
	if ( team == "allies" )
	{
		adjustedhealth = int( self.health * level.rts.game_rules.ally_health_scale );
	}
	else
	{
		adjustedhealth = int( self.health * level.rts.game_rules.axis_health_scale );
	}
/#
	println( "AI INITIALIZE: EntNum(" + self getentitynumber() + ") Health:" + self.health + " Adjusted Health:" + adjustedhealth );
#/
	if ( adjustedhealth < 10 )
	{
		adjustedhealth = 10;
	}
	self.health = adjustedhealth;
	self.health_max = self.health;
	self.maxhealth = self.health;
	self.goalradius = 512;
	self.accuracy = ref.accuracy;
	self.pkg_ref = pkg_ref;
	self ai_initalize_equipment( ref );
	if ( isDefined( origin ) )
	{
		if ( ref.species != "human" || ref.species == "dog" && ref.species == "robot_actor" )
		{
			self setgoalpos( origin );
			if ( isDefined( angles ) )
			{
				self forceteleport( origin, angles );
			}
			else
			{
				self forceteleport( origin );
			}
		}
		else
		{
			if ( ref.species == "vehicle" )
			{
				self.goalpos = origin;
				self.origin = origin;
			}
		}
	}
	if ( ref.species == "human" )
	{
		self maps/_names::get_name();
		self.canflank = 1;
		self.aggressivemode = 1;
		self maps/_so_rts_event::allocvoxid( self );
		grenadeweapon = ai_getgrenadetype( self.team );
		if ( isDefined( grenadeweapon ) )
		{
			self.grenadeweapon = grenadeweapon;
			self.grenadeammo = randomintrange( 2, 5 );
		}
		else
		{
			self.grenadeammo = 0;
		}
	}
	self thread maps/_so_rts_support::boundary_watcher( 1 );
	self.team = team;
	self setteam( team );
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		self set_vehicle_damage_override();
		if ( issubstr( self.vehicletype, "metalstorm" ) )
		{
			self thread maps/_metal_storm::metalstorm_set_team( team );
		}
		else if ( issubstr( self.vehicletype, "quadrotor" ) )
		{
			self thread maps/_quadrotor::quadrotor_set_team( team );
		}
		else
		{
			self.vteam = team;
		}
/#
		recordent( self );
#/
	}
	else
	{
		self set_actor_damage_override();
	}
	self thread ai_deathmonitor();
	if ( ref.species == "human" )
	{
		self thread ai_weaponselectwatch();
	}
	if ( self.team == "allies" && isDefined( squadid ) )
	{
		if ( isDefined( self.classname ) && self.classname != "script_vehicle" )
		{
			self thread enemy_contact_watcher();
		}
		if ( !is_true( self.manual_lui_add ) )
		{
			if ( ref.species == "human" )
			{
				luinotifyevent( &"rts_add_friendly_human", 5, self getentitynumber(), squadid, 35, 0, pkg_ref.idx );
			}
			else
			{
				luinotifyevent( &"rts_add_friendly_ai", 4, self getentitynumber(), squadid, 0, pkg_ref.idx );
			}
		}
		self.grenadeawareness = 0;
		self.fixednode = 0;
		self.coversearchinterval = 10000;
	}
	else
	{
		self thread enemy_death_watcher();
	}
	if ( self.ai_ref.armor > 0 )
	{
		self.armor = self.ai_ref.armor;
	}
	self maps/_so_rts_support::flush_gpr();
	if ( isDefined( level.rts.aux_ai_initializer ) )
	{
		self thread [[ level.rts.aux_ai_initializer ]]();
	}
}

spawn_ai_package_standard( pkg_ref, team, callback, searchpoint, findinitnode, manualluiadd )
{
	if ( !isDefined( findinitnode ) )
	{
		findinitnode = 1;
	}
	if ( !isDefined( manualluiadd ) )
	{
		manualluiadd = 0;
	}
	if ( !isDefined( searchpoint ) )
	{
		if ( team == "axis" )
		{
			searchpoint = level.rts.enemy_center.origin;
		}
		else
		{
			if ( team == "allies" )
			{
				searchpoint = level.rts.allied_center.origin;
			}
		}
	}
	squadid = maps/_so_rts_squad::createsquad( searchpoint, team, pkg_ref );
	if ( team == "allies" && isDefined( pkg_ref.hot_key_takeover ) )
	{
		if ( pkg_ref.qty[ "allies" ] > 0 )
		{
			luinotifyevent( &"rts_add_squad", 4, squadid, pkg_ref.idx, 0, pkg_ref.qty[ "allies" ] );
		}
		else
		{
			luinotifyevent( &"rts_add_squad", 3, squadid, pkg_ref.idx, 0 );
		}
	}
	maps/_so_rts_squad::removedeadfromsquad( squadid );
	nodes = getnodesinradiussorted( searchpoint, 512, 0, 128 );
	i = 0;
	_a1028 = pkg_ref.units;
	_k1028 = getFirstArrayKey( _a1028 );
	while ( isDefined( _k1028 ) )
	{
		unit = _a1028[ _k1028 ];
		if ( !pkg_ref_checkmaxspawn( pkg_ref, team ) )
		{
/#
			println( "@@@ Ending spawning of " + pkg_ref.ref + " due to being over maximum allowed" );
#/
			break;
		}
		else
		{
			ai_ref = level.rts.ai[ unit ];
			if ( ai_ref.species == "human" || ai_ref.species == "robot_actor" )
			{
				ai = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
			}
			else
			{
				if ( ai_ref.species == "vehicle" )
				{
					if ( isDefined( nodes[ i ] ) )
					{
					}
					else
					{
					}
					origin = searchpoint;
					ai = maps/_so_rts_support::placevehicle( ai_ref.ref, origin + vectorScale( ( 0, 0, -1 ), 36 ), team );
					break;
				}
				else
				{
					if ( ai_ref.species == "dog" )
					{
						ai = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
					}
				}
			}
			if ( isDefined( ai ) )
			{
				ai.ai_ref = ai_ref;
				ai.manual_lui_add = manualluiadd;
				ai maps/_so_rts_squad::addaitosquad( squadid );
				if ( is_true( findinitnode ) )
				{
					if ( !isDefined( nodes[ i ] ) )
					{
						ai.initnode = spawnstruct();
						ai.initnode.origin = searchpoint;
						ai.initnode.angles = ( 0, 0, -1 );
						break;
					}
					else
					{
						ai.initnode = nodes[ i ];
						i++;
						if ( i >= nodes.size )
						{
							i = 0;
						}
					}
				}
			}
			else
			{
/#
				ally = getaiarray( "allies" );
				axis = getaiarray( "axis" );
				println( "################### SPAWN FAILED #################" );
				println( "Tried to spawn: " + ai_ref.ref );
				println( "ALLY COUNT: " + ally.size + " AXIS COUNT: " + axis.size );
				_a1088 = level.rts.squads;
				_k1088 = getFirstArrayKey( _a1088 );
				while ( isDefined( _k1088 ) )
				{
					squad = _a1088[ _k1088 ];
					if ( squad.members.size > 0 )
					{
						maps/_so_rts_squad::removedeadfromsquad( squad.id );
						println( "Squad " + squad.id + " Pkg: " + squad.pkg_ref.ref + " has " + squad.members.size + " members." );
					}
					_k1088 = getNextArrayKey( _a1088, _k1088 );
				}
				if ( team == "allies" )
				{
					assert( 0, "couldnt spawn a friendly " + ai_ref.ref );
#/
				}
			}
			_k1028 = getNextArrayKey( _a1028, _k1028 );
		}
	}
	maps/_so_rts_catalog::units_delivered( team, squadid );
	if ( isDefined( callback ) )
	{
		thread [[ callback ]]( squadid );
	}
	return squadid;
}

get_package_drop_target( team )
{
	if ( team == "axis" )
	{
		droptarget = level.rts.enemy_center.origin;
	}
	else
	{
		droptarget = level.rts.allied_center.origin;
	}
	return droptarget;
}

transport_unload( team, squadid )
{
	self.unloading_cargo = 1;
}

spawn_ai_package_helo( transport )
{
	pkg_ref = transport.pkg_ref;
	team = transport.team;
	callback = transport.param;
	squadid = transport.squadid;
	droptarget = transport.droptarget;
	type = transport.type;
	spawned = 0;
	chopper = chopper_send( droptarget, team, type, 0 );
	maps/_so_rts_squad::removedeadfromsquad( squadid );
	if ( team == "axis" )
	{
		maps/_so_rts_squad::ordersquaddefend( get_package_drop_target( team ), squadid );
	}
	_a1147 = pkg_ref.units;
	_k1147 = getFirstArrayKey( _a1147 );
	while ( isDefined( _k1147 ) )
	{
		unit = _a1147[ _k1147 ];
		if ( !maps/_so_rts_catalog::pkg_ref_checkmaxspawn( pkg_ref, team ) )
		{
/#
			println( "@@@ Ending spawning of " + pkg_ref.ref + " due to being over maximum allowed" );
#/
			break;
		}
		else
		{
			ai_ref = level.rts.ai[ unit ];
			guy = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
			if ( isDefined( guy ) )
			{
				spawned++;
				guy enter_vehicle( chopper );
				guy.ai_ref = ai_ref;
				guy maps/_so_rts_squad::addaitosquad( squadid );
			}
			_k1147 = getNextArrayKey( _a1147, _k1147 );
		}
	}
	if ( spawned == 0 )
	{
		chopper maps/_so_rts_support::chopper_release_path();
		chopper delete();
		return -1;
	}
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_catalog::units_delivered, team, squadid );
	chopper thread callbackonnotify( "death", ::maps/_so_rts_catalog::deallocatetransport, transport );
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_catalog::unloadtransport, transport );
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_support::chopper_release_path );
	if ( isDefined( callback ) )
	{
		chopper thread callbackonnotify( "unloaded", callback, squadid );
	}
	return squadid;
}

spawn_ai_package_cargo( transport )
{
	pkg_ref = transport.pkg_ref;
	team = transport.team;
	callback = transport.param;
	squadid = transport.squadid;
	droptarget = transport.droptarget;
	maps/_so_rts_squad::removedeadfromsquad( squadid );
	chopper = chopper_send( droptarget, team, "vtol", 1 );
	chopper thread maps/_osprey::close_hatch();
	chopper thread chopper_unload_cargo( pkg_ref, team, squadid );
	chopper thread callbackonnotify( "unload", ::transport_unload, team, squadid );
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_catalog::units_delivered, team, squadid );
	chopper thread callbackonnotify( "death", ::maps/_so_rts_catalog::deallocatetransport, transport );
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_catalog::unloadtransport, transport );
	chopper thread callbackonnotify( "unloaded", ::maps/_so_rts_support::chopper_release_path );
	if ( isDefined( callback ) )
	{
		chopper thread callbackonnotify( "unloaded", callback, squadid );
	}
	return squadid;
}

chopper_unload_cargo( pkg_ref, team, squadid )
{
	self endon( "death" );
	self waittill( "unload" );
	self setflaggedanimrestart( "door_open", %v_vtol_doors_open, 1, 0,2, 1 );
	self waittillmatch( "door_open" );
	return "end";
	if ( issubstr( pkg_ref.ref, "quadrotor" ) )
	{
		self chopper_unload_cargo_quad( pkg_ref, team, squadid );
	}
	else if ( issubstr( pkg_ref.ref, "metalstorm" ) )
	{
		self chopper_unload_cargo_metalstorm( pkg_ref, team, squadid );
	}
	else if ( issubstr( pkg_ref.ref, "bigdog" ) )
	{
		self chopper_unload_cargo_claw( pkg_ref, team, squadid );
	}
	else
	{
/#
		assert( 0, "unhandled pkg" );
#/
	}
	wait 1;
	self notify( "unloaded" );
	level notify( "unloaded" );
}

chopper_unload_cargo_quad( pkg_ref, team, squadid, cb )
{
	if ( !isDefined( level.rts.quad_thrower_model ) )
	{
		aiarray = getaibyspecies( "human", team );
		if ( aiarray.size > 0 )
		{
			level.rts.quad_thrower_model = aiarray[ 0 ].model;
			level.rts.quad_thrower_headmodel = aiarray[ 0 ].headmodel;
		}
		else
		{
			spawner = getspawnerteamarray( "allies" )[ 0 ];
			guy = simple_spawn_single( spawner, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
/#
			assert( isDefined( guy ) );
#/
			level.rts.quad_thrower_model = guy.model;
			level.rts.quad_thrower_headmodel = guy.headmodel;
			guy delete();
		}
	}
/#
	assert( isDefined( level.rts.quad_thrower_model ) );
#/
	guy = spawn( "script_model", self.origin );
	guy setmodel( level.rts.quad_thrower_model );
	guy useanimtree( -1 );
	if ( isDefined( level.rts.quad_thrower_headmodel ) )
	{
		guy attach( level.rts.quad_thrower_headmodel, "", 1 );
	}
	tagorigin = self gettagorigin( "tag_detach" );
	tagangles = self gettagangles( "tag_detach" );
	throwtags = [];
	throwtags[ 0 ] = "tag_weapon_right";
	throwtags[ 1 ] = "tag_weapon_left";
/#
	assert( animhasnotetrack( %ai_crew_vtol_quad_launch, "quad_launch" ) );
#/
	i = 0;
	while ( i < pkg_ref.units.size )
	{
		guy animscripted( "throw", tagorigin, tagangles, %ai_crew_vtol_quad_launch );
		guy waittillmatch( "throw" );
		return "quad_launch";
		quads = [];
		j = i;
		while ( j < pkg_ref.units.size )
		{
			if ( !maps/_so_rts_catalog::pkg_ref_checkmaxspawn( pkg_ref, team ) )
			{
/#
				println( "@@@ Ending spawning of " + pkg_ref.ref + " due to being over maximum allowed" );
#/
				break;
			}
			else
			{
				unit = pkg_ref.units[ j ];
				ai_ref = level.rts.ai[ unit ];
				throwtag = throwtags[ j % 2 ];
				origin = guy gettagorigin( throwtag );
				if ( !isDefined( origin ) )
				{
					origin = guy.origin;
				}
				quad = placevehicle( ai_ref.ref, origin, team );
				quad linkto( guy, throwtag );
				quads[ quads.size ] = quad;
				if ( isDefined( quad ) )
				{
					quad.ai_ref = ai_ref;
					quad maps/_so_rts_squad::addaitosquad( squadid );
				}
				j++;
			}
		}
		guy waittillmatch( "throw" );
		return "end";
		_a1336 = quads;
		_k1336 = getFirstArrayKey( _a1336 );
		while ( isDefined( _k1336 ) )
		{
			quad = _a1336[ _k1336 ];
			quad unlink();
			quad maps/_vehicle::defend( level.rts.squads[ squadid ].centerpoint );
			_k1336 = getNextArrayKey( _a1336, _k1336 );
		}
		i += 2;
	}
	self notify( "unloaded_" + pkg_ref.ref );
	level notify( "unloaded_" + pkg_ref.ref );
	guy delete();
	if ( isDefined( cb ) )
	{
		thread [[ cb ]]( squadid );
	}
}

chopper_unload_cargo_metalstorm( pkg_ref, team, squadid )
{
	tagorigin = self gettagorigin( "tag_body" );
	tagangles = self gettagangles( "tag_body" );
	animrig = spawn( "script_model", tagorigin );
	animrig.angles = tagangles;
	animrig linkto( self, "tag_body" );
	animrig useanimtree( -1 );
	animrig setmodel( "fxanim_gp_vtol_drop_asd_drone_mod" );
	unit = pkg_ref.units[ 0 ];
	ai_ref = level.rts.ai[ unit ];
/#
	assert( isDefined( ai_ref ) );
#/
	asd = placevehicle( ai_ref.ref, animrig gettagorigin( "asd_attach_jnt" ), team );
	asd.angles = animrig gettagangles( "asd_attach_jnt" );
	asd hide();
	asd linkto( animrig, "asd_attach_jnt" );
	asd maps/_vehicle::godon();
	asd.ignoreme = 1;
	animrig setflaggedanimrestart( "drop", %fxanim_gp_vtol_drop_asd_drone_anim, 1, 0,2, 1 );
	wait 0,5;
	asd show();
	animrig waittillmatch( "drop" );
	return "drop_asd";
	asd unlink();
	asd maps/_vehicle::godoff();
	asd.ignoreme = 0;
	asd.ai_ref = ai_ref;
	asd maps/_so_rts_squad::addaitosquad( squadid );
	asd maps/_vehicle::defend( asd.origin, 600 );
	animrig waittillmatch( "drop" );
	return "end";
	animrig delete();
}

chopper_unload_cargo_claw( pkg_ref, team, squadid )
{
	unit = pkg_ref.units[ 0 ];
	ai_ref = level.rts.ai[ unit ];
/#
	assert( isDefined( ai_ref ) );
#/
	claw = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	while ( !isDefined( claw ) )
	{
		retry = 5;
		while ( retry && !isDefined( claw ) )
		{
			wait 0,1;
			retry--;

			claw = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
		}
	}
	if ( isDefined( claw ) )
	{
		tagorigin = self gettagorigin( "tag_body" );
		tagangles = self gettagangles( "tag_body" );
		animrig = spawn( "script_model", tagorigin );
		animrig.angles = tagangles;
		animrig linkto( self, "tag_body" );
		animrig useanimtree( -1 );
		animrig setmodel( "fxanim_gp_vtol_drop_claw_mod" );
		claw setteam( team );
		claw forceteleport( animrig gettagorigin( "claw_attach_jnt" ), animrig gettagangles( "claw_attach_jnt" ) );
		claw linkto( animrig, "claw_attach_jnt" );
		claw maps/_vehicle::godon();
		claw.ignoreme = 1;
		claw.animname = "dropoff_claw";
		claw.ai_ref = ai_ref;
		claw maps/_so_rts_squad::addaitosquad( squadid );
		animrig setflaggedanimrestart( "drop", %fxanim_gp_vtol_drop_claw_anim, 1, 0,2, 1 );
		animrig waittillmatch( "drop" );
		return "drop_claw";
		claw unlink();
		claw thread maps/_anim::anim_single( claw, "claw_touchdown" );
		claw maps/_vehicle::godoff();
		claw.ignoreme = 0;
		animrig waittillmatch( "drop" );
		return "end";
		animrig delete();
	}
}

cargocheck( pkg_ref )
{
	if ( isDefined( self.cargo ) )
	{
/#
		println( "@@@@@@@@@@@@@@@@@@@  RIP  Delivery [" + pkg_ref.ref + "] at (" + self.origin + ") self destructed for not being unloaded" );
#/
		self.cargo delete();
		self.cargo = undefined;
	}
}

spawnreplacement( spawner )
{
	if ( !isDefined( self.ally ) )
	{
		return undefined;
	}
	if ( !isDefined( spawner ) )
	{
		spawner = self.ally.ai_ref.ref;
	}
	guy = simple_spawn_single( spawner, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	if ( isDefined( guy ) )
	{
		guy.ai_ref = self.ally.ai_ref;
		guy maps/_so_rts_squad::addaitosquad( self.ally.squadid );
		goingtonode = 0;
		node = get_closest_pathnode( self.origin, 600, 100 );
		if ( isDefined( node ) )
		{
			goingtonode = 1;
			goal = node;
		}
		else
		{
			node = get_closest_pathnode( self.origin, 1000, 400 );
			if ( isDefined( node ) )
			{
				goingtonode = 1;
				goal = node;
			}
		}
		if ( goingtonode )
		{
			guy ai_initialize( self.ally.ai_ref, self.team, goal.origin, self.ally.squadid, self.angles, self.ally.pkg_ref );
		}
		else
		{
			guy ai_initialize( self.ally.ai_ref, self.team, self.origin, self.ally.squadid, self.angles, self.ally.pkg_ref );
		}
		guy.armor = self.ally.armor;
		guy.goalradius = self.ally.goalradius;
		guy.last_goalradius = self.ally.lastgoalrad;
		guy.accuracy = self.ally.accuracy;
		guy setgoalpos( self.origin );
		guy.name = self.ally.name;
		guy.rts_unloaded = 1;
		guy.playerinhabited = 1;
		if ( isDefined( self.ally.viewhands ) )
		{
			guy.viewhands = self.ally.viewhands;
		}
		guy ai_postinitialize();
		primary_weapons = self getweaponslistprimaries();
		arrayremovevalue( primary_weapons, self.ally.sidearm );
/#
		assert( isDefined( primary_weapons[ 0 ] ) );
#/
		guy gun_switchto( primary_weapons[ 0 ], "right" );
		guy animscripts/utility::setprimaryweapon( primary_weapons[ 0 ] );
		if ( primary_weapons.size > 1 )
		{
			guy animscripts/utility::setsecondaryweapon( primary_weapons[ 1 ] );
		}
		if ( isDefined( self.ally.grenadeweapon ) )
		{
			grenadeweapon = self.ally.grenadeweapon;
			guy.grenadeweapon = grenadeweapon;
			if ( grenadeweapon == "frag_grenade_sp" )
			{
				grenadeweapon = "frag_grenade_future_sp";
			}
			if ( grenadeweapon == "sticky_grenade_future_ai_sp" )
			{
				grenadeweapon = "sticky_grenade_future_sp";
			}
			guy.grenadeammo = self getweaponammoclip( grenadeweapon );
		}
		if ( self.ally.health > self.health )
		{
		}
		else
		{
		}
		guy.health = self.ally.health;
		if ( isDefined( guy.health_max ) )
		{
		}
		else
		{
		}
		luinotifyevent( &"rts_update_health", 3, guy getentitynumber(), guy.health, guy.health, guy.health_max );
		if ( isDefined( self.ally.restorenote ) )
		{
			level notify( self.ally.restorenote );
		}
	}
	else
	{
		if ( isDefined( self.ally.restorenote ) )
		{
/#
			assert( 0, "Entity with restore note did not spawn" );
#/
		}
	}
	self.ally = undefined;
	return guy;
}

restorereplacement()
{
	level.rts.last_teammate = undefined;
	if ( !isDefined( self.ally ) )
	{
		return;
	}
	luinotifyevent( &"rts_remove_ai", 1, self getentitynumber() );
	clientnotify( "restore_" + self.ally.pkg_ref.ref );
	if ( self.ally.ai_ref.species == "human" )
	{
		self setviewmodel( level.player_viewmodel );
		level.rts.last_teammate = spawnreplacement();
	}
	else if ( self.ally.ai_ref.species == "robot_actor" )
	{
/#
		assert( isDefined( self.ally.ai_ref.swap_spawner ) );
#/
		if ( isDefined( self.ally.vehicle ) )
		{
			self.ally.vehicle useby( self );
			self.ally.vehicle.playerdeleted = 1;
			health = self.ally.vehicle.health;
			origin = self.ally.vehicle.origin;
			angles = self.ally.vehicle.angles;
			self.ally.vehicle delete();
		}
		else
		{
			health = self.ally.health;
			origin = self.ally.origin;
			angles = self.ally.angles;
		}
/#
		assert( isDefined( self.ally.swapai ) );
#/
		self.ally.swapai.initialized = undefined;
		self.ally.swapai.overrideactordamage = undefined;
		self.ally.swapai maps/_so_rts_squad::addaitosquad( self.ally.squadid );
		goingtonode = 0;
		node = get_closest_doublewidenode( origin, 500, 100 );
		if ( isDefined( node ) )
		{
			goingtonode = 1;
			goal = node;
		}
		else
		{
			node = get_closest_doublewidenode( origin, 1000, 400 );
			if ( isDefined( node ) )
			{
				goingtonode = 1;
				goal = node;
			}
		}
		if ( goingtonode )
		{
			self.ally.swapai ai_initialize( self.ally.ai_ref, self.team, goal.origin, self.ally.squadid, self.angles, self.ally.pkg_ref );
		}
		else
		{
			self.ally.swapai ai_initialize( self.ally.ai_ref, self.team, self.origin, self.ally.squadid, self.angles, self.ally.pkg_ref );
		}
		self.ally.swapai.health = health;
		self.ally.swapai.armor = self.ally.armor;
		self.ally.swapai.goalradius = self.ally.goalradius;
		self.ally.swapai.last_goalradius = self.ally.last_goalradius;
		self.ally.swapai setgoalpos( level.rts.squads[ self.ally.squadid ].centerpoint );
		self.ally.swapai.rts_unloaded = 1;
		self.ally.swapai.selectable = 1;
		self.ally.swapai.allow_oob = undefined;
		self.ally.swapai.ignoreme = 0;
		self.ally.swapai.ignoreall = 0;
		self.ally.swapai.takedamage = 1;
		if ( isDefined( self.ally.restorenote ) )
		{
			level notify( self.ally.restorenote );
		}
		level.rts.last_teammate = self.ally.swapai;
	}
	else
	{
		if ( self.ally.ai_ref.species == "vehicle" )
		{
			if ( isDefined( self.ally.vehicle ) )
			{
				self.ally.vehicle useby( self );
				self.ally.vehicle notify( "player_exited" );
				self.ally.vehicle.selectable = 1;
				self.ally.vehicle.player = undefined;
				self.ally.vehicle.vehdontejectoccupantsondeath = 0;
				if ( isDefined( self.ally.restorenote ) )
				{
					level notify( self.ally.restorenote );
				}
				luinotifyevent( &"rts_update_health", 3, self.ally.vehicle getentitynumber(), self.ally.vehicle.health, self.ally.vehicle.health_max );
				level.rts.last_teammate = self.ally.vehicle;
			}
		}
	}
	self.ally = undefined;
	if ( isDefined( level.rts.activesquad ) )
	{
		package_highlightunits( level.rts.activesquad );
	}
}

takeoverselectedinfantry( entity )
{
	self.ally = spawnstruct();
	self.ally.ai_ref = entity.ai_ref;
	self.ally.pkg_ref = entity.pkg_ref;
	if ( entity.health > 0 )
	{
	}
	else
	{
	}
	self.ally.health = 1;
	self.ally.health_max = entity.health_max;
	self.ally.armor = entity.armor;
	self.ally.goalradius = entity.goalradius;
	self.ally.lastgoalrad = entity.last_goalradius;
	self.ally.accuracy = entity.accuracy;
	self.ally.squadid = entity.squadid;
	self.ally.goalpos = entity.goalpos;
	self.ally.grenadeweapon = entity.grenadeweapon;
	self.ally.grenadeammo = entity.grenadeammo;
	self.ally.name = entity.name;
	self.ally.primaryweapon = entity.primaryweapon;
	self.ally.secondaryweapon = entity.secondaryweapon;
	self.ally.sidearm = entity.sidearm;
	self.ally.origin = entity.origin;
	self.ally.angles = entity.angles;
	self.health = 100;
	if ( isDefined( entity.restorenote ) )
	{
	}
	else
	{
	}
	self.ally.restorenote = undefined;
	if ( isDefined( entity.takeovernote ) )
	{
	}
	else
	{
	}
	self.ally.takeovernote = undefined;
	if ( isDefined( entity.viewhands ) )
	{
		self setviewmodel( entity.viewhands );
		self.ally.viewhands = entity.viewhands;
	}
	if ( !is_true( entity.playerinhabited ) )
	{
		self.ally.grenadeammo = randomintrange( 2, 5 );
	}
	if ( entity.ai_ref.armor > 0 )
	{
		self.armor = entity.ai_ref.armor;
	}
	self takeallweapons();
	if ( isDefined( self.ally.grenadeweapon ) && self.ally.grenadeweapon != "" && self.ally.grenadeweapon != "none" )
	{
		grenadeweapon = self.ally.grenadeweapon;
		if ( self.ally.grenadeweapon == "frag_grenade_sp" )
		{
			grenadeweapon = "frag_grenade_future_sp";
		}
		if ( self.ally.grenadeweapon == "sticky_grenade_future_ai_sp" )
		{
			grenadeweapon = "sticky_grenade_future_sp";
		}
		self giveweapon( grenadeweapon );
		self setweaponammoclip( grenadeweapon, self.ally.grenadeammo );
	}
	else
	{
		self.ally.grenadeweapon = undefined;
	}
	if ( isDefined( self.ally.sidearm ) && self.ally.sidearm != "" && self.ally.sidearm != "none" )
	{
		if ( !is_true( level.rts.disallow_player_sidearm ) )
		{
			self giveweapon( self.ally.sidearm );
			self givestartammo( self.ally.sidearm );
		}
	}
	else
	{
		self.ally.sidearm = undefined;
	}
	if ( isDefined( self.ally.primaryweapon ) )
	{
		if ( self.ally.primaryweapon == "none" )
		{
			self.ally.primaryweapon = entity.initial_primaryweapon;
/#
			if ( isDefined( self.ally.primaryweapon ) )
			{
				assert( self.ally.primaryweapon != "none", "illegal weapon" );
			}
#/
		}
		self giveweapon( self.ally.primaryweapon );
		self givestartammo( self.ally.primaryweapon );
		self switchtoweapon( self.ally.primaryweapon );
	}
	else
	{
/#
		assert( 0, "must have a primary weapon" );
#/
	}
	if ( isDefined( self.ally.secondaryweapon ) )
	{
		if ( self.ally.secondaryweapon != "none" )
		{
			self giveweapon( self.ally.secondaryweapon );
			self givestartammo( self.ally.secondaryweapon );
		}
	}
	level.player giveweapon( "tazer_knuckles_sp" );
	level.rts.player setorigin( self.ally.origin );
	level.rts.player setplayerangles( getbestinitialorientangles( entity ) );
	entity maps/_so_rts_support::flush_gpr();
	if ( isDefined( entity.takeovernote ) )
	{
		level notify( entity.takeovernote );
	}
	entity delete();
	luinotifyevent( &"rts_add_friendly_human", 5, self getentitynumber(), self.ally.squadid, 0, 1, self.ally.pkg_ref.idx );
}

vehicledeathwatcher( vehicle )
{
	vehicle endon( "player_exited" );
	vehicle waittill_any( "death", "death_incomming" );
	if ( !isDefined( vehicle.playerdeleted ) )
	{
		maps/_so_rts_squad::removedeadfromsquad( self.ally.squadid );
		if ( level.rts.squads[ self.ally.squadid ].members.size == 0 )
		{
			nextsquad = maps/_so_rts_squad::getnextvalidsquad( self.ally.squadid );
		}
		else
		{
			nextsquad = self.ally.squadid;
		}
		maps/_so_rts_event::trigger_event( "vehicle_death" );
		if ( nextsquad == -1 )
		{
			level.rts.lastfpspoint = level.rts.player.origin;
			level thread player_eyeinthesky();
			self.ally = undefined;
		}
		else
		{
			maps/_so_rts_event::trigger_event( "forceswitch_" + level.rts.squads[ nextsquad ].pkg_ref.ref );
			maps/_so_rts_main::player_nextavailunit( nextsquad, 1 );
		}
		wait 1;
		if ( isDefined( vehicle ) && isDefined( vehicle.ai_ref.swap_spawner ) )
		{
			vehicle delete();
		}
	}
}

getbestinitialorientangles( entity )
{
	angles = entity.angles;
	eye = entity gettagangles( "tag_eye" );
	if ( isDefined( eye ) )
	{
		return ( 0, eye[ 1 ], 0 );
	}
	if ( isDefined( level.rts.enemy_base ) )
	{
		enemyent = level.rts.enemy_base.entity;
	}
	if ( isDefined( entity.enemy ) )
	{
		enemyent = entity.enemy;
	}
	else
	{
		closeenemy = getclosestai( self.origin, "axis", 562500 );
		if ( isDefined( closeenemy ) )
		{
			enemyent = closeenemy;
		}
	}
	if ( isDefined( enemyent ) )
	{
		dirtopos = enemyent.origin - level.rts.player.origin;
		angles = vectorToAngle( dirtopos );
	}
	return angles;
}

vehicle_airwatcher( vehicle )
{
	vehicle endon( "death" );
	vehicle endon( "player_exited" );
	if ( issubstr( vehicle.vehicletype, "quadrotor" ) )
	{
		return;
	}
}

takeoverselectedvehicle( entity )
{
	if ( isDefined( entity.ai_ref.swap_notify ) )
	{
		level notify( entity.ai_ref.swap_notify );
		clientnotify( entity.ai_ref.swap_notify );
		entity notify( entity.ai_ref.swap_notify );
	}
	if ( isDefined( entity.ai_ref.swap_spawner ) )
	{
		vehicle = maps/_vehicle::spawn_vehicle_from_targetname( entity.ai_ref.swap_spawner );
		if ( isDefined( vehicle ) )
		{
			self.ally = spawnstruct();
			self.ally.ai_ref = entity.ai_ref;
			self.ally.pkg_ref = entity.pkg_ref;
			if ( entity.health > 0 )
			{
			}
			else
			{
			}
			self.ally.health = 1;
			self.ally.health_max = entity.health_max;
			self.ally.armor = entity.armor;
			self.ally.goalradius = entity.goalradius;
			self.ally.lastgoalrad = entity.last_goalradius;
			self.ally.accuracy = entity.accuracy;
			self.ally.squadid = entity.squadid;
			self.ally.goalpos = entity.goalpos;
			self.ally.origin = entity.origin;
			self.ally.angles = entity.angles;
			self.ally.vehicle = vehicle;
			if ( isDefined( entity.restorenote ) )
			{
			}
			else
			{
			}
			self.ally.restorenote = undefined;
			if ( isDefined( entity.takeovernote ) )
			{
			}
			else
			{
			}
			self.ally.takeovernote = undefined;
			self.health = 100;
			vehicle.ai_ref = entity.ai_ref;
			vehicle.health = entity.health_max;
			vehicle.health_max = entity.health_max;
			entity maps/_so_rts_support::flush_gpr();
			vehicle.vehdontejectoccupantsondeath = 1;
			vehicle.origin = entity.origin;
			vehicle.angles = getbestinitialorientangles( entity );
			vehicle makevehicleusable();
			self.ignoreme = 1;
			self enableinvulnerability();
			self setorigin( vehicle.origin );
			self setplayerangles( vehicle.angles );
			vehicle usevehicle( self, entity.ai_ref.seat );
			self thread vehicledeathwatcher( vehicle );
			vehicle makevehicleunusable();
			vehicle maps/_so_rts_squad::addaitosquad( self.ally.squadid );
			vehicle ai_initialize( self.ally.ai_ref, self.team, undefined, self.ally.squadid, undefined, self.ally.pkg_ref, vehicle.health );
			vehicle.rts_unloaded = 1;
			vehicle ai_postinitialize();
			if ( vehicle.ai_ref.armor > 0 )
			{
				vehicle.armor = vehicle.ai_ref.armor;
			}
			entity maps/_so_rts_squad::removeaifromsquad();
			entity.rts_unloaded = 0;
			entity.selectable = 0;
			entity.allow_oob = 1;
			entity.ignoreme = 1;
			entity.ignoreall = 1;
			entity.takedamage = 0;
			entity forceteleport( vectorScale( ( 0, 0, -1 ), 30000 ) );
			self.ally.swapai = entity;
			if ( isDefined( entity.takeovernote ) )
			{
				level notify( entity.takeovernote );
			}
			entity = vehicle;
		}
	}
	else
	{
		entity maps/_vehicle::stop();
		entity veh_magic_bullet_shield( 0 );
		entity makevehicleusable();
		entity.vehdontejectoccupantsondeath = 1;
		self.ignoreme = 1;
		self enableinvulnerability();
		self.ally = spawnstruct();
		self.ally.ai_ref = entity.ai_ref;
		self.ally.pkg_ref = entity.pkg_ref;
		self.ally.vehicle = entity;
		self.ally.squadid = entity.squadid;
		if ( isDefined( entity.restorenote ) )
		{
		}
		else
		{
		}
		self.ally.restorenote = undefined;
		if ( isDefined( entity.takeovernote ) )
		{
		}
		else
		{
		}
		self.ally.takeovernote = undefined;
		self.health = 100;
		self.ally.vehicle notify( "player_entering" );
		self setorigin( entity.origin );
		entity usevehicle( self, entity.ai_ref.seat );
		self thread vehicledeathwatcher( entity );
		entity makevehicleunusable();
		if ( entity.ai_ref.armor > 0 )
		{
			entity.armor = entity.ai_ref.armor;
		}
		if ( isDefined( entity.takeovernote ) )
		{
			level notify( entity.takeovernote );
		}
	}
	entity.player = self;
	self notify( "vehicle_taken_over" );
	rpc( "clientscripts/_vehicle", "damage_filter_off" );
	return entity;
}

is_mechanical( entity )
{
	return entity.ai_ref.species == "robot_actor";
}

health_regen( amountpersec, maxhealth )
{
	self endon( "death" );
	while ( 1 )
	{
		self.health += amountpersec;
		if ( self.health > maxhealth )
		{
			self.health = maxhealth;
		}
		wait 1;
	}
}

takeoverselected( entity )
{
	self.ignoreme = 0;
	if ( !isDefined( entity ) )
	{
		return;
	}
/#
	assert( isDefined( entity.pkg_ref ) );
#/
/#
	assert( !is_true( entity.no_takeover ), "illegal target" );
#/
/#
	assert( is_true( entity.rts_unloaded ), "illegal target" );
#/
	luinotifyevent( &"hud_expand_ammo" );
	pkg_ref = entity.pkg_ref;
	if ( isDefined( entity.classname ) || entity.classname == "script_vehicle" && is_mechanical( entity ) )
	{
		if ( is_mechanical( entity ) )
		{
			entity.takedamage = 1;
		}
		else
		{
			entity veh_magic_bullet_shield( 0 );
		}
		entity = takeoverselectedvehicle( entity );
	}
	else
	{
		self thread takeoverselectedinfantry( entity );
	}
	self thread maps/_so_rts_support::block_player_damage_fortime( level.rts.game_rules.player_switch_invultime );
	level.rts.activesquad = self.ally.squadid;
	luinotifyevent( &"rts_highlight_squad", 1, level.rts.activesquad );
	level notify( "takeover_" + pkg_ref.ref );
	clientnotify( "takeover_" + pkg_ref.ref );
	level notify( "entity_taken_over" );
	return entity;
}

vehicle_initialize()
{
	self.dontdisconnectpaths = 1;
}

spider_initialize()
{
	self vehicle_initialize();
}

bigdog_initialize()
{
	if ( isai( self ) )
	{
		if ( self.team == "allies" )
		{
			self setmodel( "veh_t6_drone_claw_mk2" );
		}
		else
		{
			self setmodel( "veh_t6_drone_claw_mk2_alt" );
			self.turret setmodel( "veh_t6_drone_claw_mk2_turret_alt" );
		}
	}
	self vehicle_initialize();
}

removebaseasthreat()
{
	allenemies = getaiarray( "axis" );
	_a2109 = allenemies;
	_k2109 = getFirstArrayKey( _a2109 );
	while ( isDefined( _k2109 ) )
	{
		enemy = _a2109[ _k2109 ];
		enemy clearentitytarget();
		_k2109 = getNextArrayKey( _a2109, _k2109 );
	}
	allvehicles = getvehiclearray( "axis" );
	_a2114 = allvehicles;
	_k2114 = getFirstArrayKey( _a2114 );
	while ( isDefined( _k2114 ) )
	{
		vehicle = _a2114[ _k2114 ];
		if ( issentient( vehicle ) )
		{
			vehicle vehclearentitytarget();
		}
		_k2114 = getNextArrayKey( _a2114, _k2114 );
	}
}

ai_trytousebetterweapon()
{
	self endon( "death" );
	self notify( "ai_tryToUseBetterWeapon" );
	self endon( "ai_tryToUseBetterWeapon" );
	self.rts_next_grenade_force_attempt = 0;
	self.rts_next_secondary_force_attempt = 0;
	while ( isDefined( self.enemy ) )
	{
		time = getTime();
		while ( isDefined( self.secondaryweapon ) && self.secondaryweapon != "rpg_sp" && self.secondaryweapon == "smaw_sp" && self.rts_next_secondary_force_attempt < time && randomint( 100 ) > 50 )
		{
			if ( self.weapon != self.secondaryweapon )
			{
				self.a.allow_weapon_switch = 1;
				self switch_weapon_asap();
				self waittill( "weapon_switched" );
			}
			if ( !isDefined( self.enemy ) )
			{
				return;
			}
			else
			{
				self.shoot_notify = "rpg_fired";
				self.perfectaim = 1;
				self.ignoresuppression = 1;
				self.grenadeawareness = 0;
				self setentitytarget( self.enemy );
				self waittill( "rpg_fired", missile );
				self.shoot_notify = "rpg_fired";
				self.perfectaim = 0;
				self.ignoresuppression = 0;
				self.grenadeawareness = 1;
				self clearentitytarget();
				self.shoot_notify = undefined;
				self.rts_next_secondary_force_attempt = time + 8000;
				self switch_weapon_asap();
				wait 1;
			}
			if ( isDefined( self.grenadeweapon ) && self.grenadeammo > 0 && self.rts_next_grenade_force_attempt < time && randomint( 100 ) > 50 )
			{
				self thread throwgrenadeatenemyasap( 1 );
				self waittill( "threw_grenade_at_enemy" );
				self.rts_next_grenade_force_attempt = time + 8000;
			}
			wait 1;
		}
	}
}

ai_weaponselectwatch()
{
	self notify( "ai_weaponSelectWatch" );
	self endon( "ai_weaponSelectWatch" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "enemy" );
		while ( !isDefined( self.enemy ) )
		{
			continue;
		}
		if ( isDefined( self.rts_last_enemy ) && self.rts_last_enemy == self.enemy )
		{
			continue;
		}
		while ( self.enemy == level.rts.player )
		{
			continue;
		}
		while ( !is_true( self.enemy.initialized ) )
		{
			continue;
		}
		while ( !is_true( self.enemy.rts_unloaded ) )
		{
			continue;
		}
		while ( self.enemy.ai_ref.species == "human" )
		{
			continue;
		}
		self.rts_last_enemy = self.enemy;
		self thread ai_trytousebetterweapon();
	}
}
