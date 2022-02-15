#include maps/_utility_code;
#include maps/_so_rts_poi;
#include maps/_vehicle;
#include animscripts/combat_utility;
#include maps/_so_rts_squad;
#include maps/_so_rts_support;
#include maps/_utility;
#include common_scripts/utility;

enemy_player()
{
	level endon( "rts_terminated" );
	level endon( "end_enemy_player" );
	level.rts.enemy_think_wait = 4;
	level.rts.poi_ideal = 4;
	level.rts.enemy_units = [];
	level.rts.nag_units = [];
	level.rts.nag_targets = [];
	level.rts.enemy_units_nextid = 0;
	flag_init( "rts_enemy_squad_spawner_enabled" );
	flag_set( "rts_enemy_squad_spawner_enabled" );
	flag_wait( "start_rts_enemy" );
	level thread enemy_squad_spawner();
	level thread enemy_unit_delayzones();
	while ( !flag( "rts_game_over" ) )
	{
		packages_avail = maps/_so_rts_catalog::package_generateavailable( "axis" );
		i = 0;
		while ( i < packages_avail.size )
		{
			if ( !is_true( packages_avail[ i ].selectable ) )
			{
				i++;
				continue;
			}
			else ref = packages_avail[ i ].ref;
			total = get_number_in_queue( ref );
			squad = maps/_so_rts_squad::getsquadbypkg( ref, "axis" );
			if ( isDefined( squad ) )
			{
				maps/_so_rts_squad::removedeadfromsquad( squad.id );
				total += squad.members.size;
			}
			total += maps/_so_rts_catalog::getnumberofpkgsbeingtransported( "axis", ref ) * packages_avail[ i ].numunits;
			if ( total >= packages_avail[ i ].max_axis )
			{
				i++;
				continue;
			}
			else
			{
				if ( total <= packages_avail[ i ].min_axis )
				{
					level.rts.enemy_squad_queue[ level.rts.enemy_squad_queue.size ] = ref;
/#
					println( "@@@@@@@@ AXIS (" + getTime() + ") ORDERING:" + ref + " CURRENT:" + total + " MAX:" + packages_avail[ i ].max_axis + " MIN:" + packages_avail[ i ].min_axis );
#/
				}
			}
			i++;
		}
		wait level.rts.enemy_think_wait;
		units = unitsprune();
		create_units_from_allsquads();
/#
		if ( getDvarInt( #"109698A9" ) == 1 )
		{
			badguys = getaiarray( "axis" );
			ainotinunit = 0;
			_a79 = badguys;
			_k79 = getFirstArrayKey( _a79 );
			while ( isDefined( _k79 ) )
			{
				guy = _a79[ _k79 ];
				if ( !isDefined( guy.unitid ) )
				{
					ainotinunit++;
				}
				_k79 = getNextArrayKey( _a79, _k79 );
			}
			badveh = getvehiclearray( "axis" );
			vehnotinunit = 0;
			_a86 = badveh;
			_k86 = getFirstArrayKey( _a86 );
			while ( isDefined( _k86 ) )
			{
				guy = _a86[ _k86 ];
				if ( !isDefined( guy.unitid ) )
				{
					vehnotinunit++;
				}
				_k86 = getNextArrayKey( _a86, _k86 );
			}
			get_best_poi_target();
			units = unitsprune();
			enemydeployed = 0;
			_a94 = units;
			_k94 = getFirstArrayKey( _a94 );
			while ( isDefined( _k94 ) )
			{
				deployedunit = _a94[ _k94 ];
				enemydeployed += deployedunit.members.size;
				_k94 = getNextArrayKey( _a94, _k94 );
			}
			onplayer = 0;
			while ( isDefined( level.rts.player.ally ) )
			{
				_a101 = level.rts.nag_units;
				_k101 = getFirstArrayKey( _a101 );
				while ( isDefined( _k101 ) )
				{
					unit = _a101[ _k101 ];
					if ( isDefined( unit.target ) && unit.target == level.rts.player )
					{
						onplayer++;
					}
					_k101 = getNextArrayKey( _a101, _k101 );
				}
			}
			println( "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\nENEMY THINK (" + getTime() + ")" );
			println( "\tACTIVE ALLY SQUADS:" + maps/_so_rts_squad::getactivesquads( "allies" ).size );
			println( "\n\tTOTAL AXIS SQUADS:" + maps/_so_rts_squad::getactivesquads( "axis" ).size );
			println( "\n\tTOTAL AXIS UNITS:" + units.size );
			println( "\tTOTAL UNIT ENEMY:" + enemydeployed );
			println( "\tTOTAL AI ENEMY:" + badguys.size + " (" + ainotinunit + ")" );
			println( "\tTOTAL VEH ENEMY:" + badveh.size + " (" + vehnotinunit + ")" );
			println( "\tSQUAD QUEUE:" + level.rts.enemy_squad_queue.size );
			println( "\tNAG UNITS:" + level.rts.nag_units.size + "\tWANTED:" + level.rts.game_rules.num_nag_squads + "\tON PLAYER:" + onplayer );
			println( "POIs:" );
			i = 0;
			while ( i < level.rts.poi.size )
			{
				if ( is_true( level.rts.poi[ i ].ignoreme ) )
				{
					i++;
					continue;
				}
				else if ( isDefined( level.rts.poi[ i ].score ) )
				{
					println( "\t" + level.rts.poi[ i ].ref + " \t\tAI DEFENDING:" + level.rts.poi[ i ].score.defenders + "\tSCORE:" + level.rts.poi[ i ].score.totalscore );
					i++;
					continue;
				}
				else
				{
					println( "\t" + level.rts.poi[ i ].ref );
				}
				i++;
			}
			println( "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" );
#/
		}
	}
}

delay_unit_think( who )
{
	level endon( "rts_terminated" );
	self endon( "death" );
	if ( !isDefined( who ) )
	{
		return;
	}
	delayunit = getunit( who.unitid );
	if ( !isDefined( delayunit ) )
	{
		return;
	}
	if ( isDefined( delayunit.delayed ) && delayunit.delayed == self )
	{
		return;
	}
	delayunit.delayed = self;
	unitcenter = delayunit.center;
	delayunit.center = who.origin;
	delayunit.suspendthink = 1;
	_a167 = delayunit.members;
	_k167 = getFirstArrayKey( _a167 );
	while ( isDefined( _k167 ) )
	{
		guy = _a167[ _k167 ];
		if ( isDefined( guy ) )
		{
			guy.oldgoalradius = guy.goalradius;
			guy.goalradius = 64;
			guy setgoalpos( guy.origin );
		}
		_k167 = getNextArrayKey( _a167, _k167 );
	}
	while ( self.delay_queue[ 0 ] != delayunit.unitid )
	{
		wait 1;
	}
	if ( self.unitdelay > 0 )
	{
		wait self.unitdelay;
	}
	if ( self.randomunitdelay > 0 )
	{
		wait randomint( self.randomunitdelay );
	}
	delayunit.center = unitcenter;
	valid = [];
	_a194 = delayunit.members;
	_k194 = getFirstArrayKey( _a194 );
	while ( isDefined( _k194 ) )
	{
		guy = _a194[ _k194 ];
		if ( isDefined( guy ) )
		{
			valid[ valid.size ] = guy;
		}
		_k194 = getNextArrayKey( _a194, _k194 );
	}
	delayunit.members = sortarraybyclosest( self.origin, valid );
	while ( self.individualdelay > 0 )
	{
		_a202 = delayunit.members;
		_k202 = getFirstArrayKey( _a202 );
		while ( isDefined( _k202 ) )
		{
			guy = _a202[ _k202 ];
			if ( isDefined( guy ) )
			{
				guy.goalradius = guy.oldgoalradius;
				guy.oldgoalradius = undefined;
				guy setgoalpos( delayunit.center );
				wait self.individualdelay;
			}
			_k202 = getNextArrayKey( _a202, _k202 );
		}
	}
	delayunit.suspendthink = undefined;
	arrayremoveindex( self.delay_queue, 0, 0 );
}

delay_trigger_think()
{
	level endon( "rts_terminated" );
	self endon( "death" );
	self.unitdelay = 0;
	self.individualdelay = 0;
	self.randomunitdelay = 0;
	while ( isDefined( self.script_parameters ) )
	{
		tokens = strtok( self.script_parameters, " " );
		_a231 = tokens;
		_k231 = getFirstArrayKey( _a231 );
		while ( isDefined( _k231 ) )
		{
			token = _a231[ _k231 ];
			if ( issubstr( token, "individual_member_delay=" ) )
			{
				self.individualdelay = int( strtok( token, "=" )[ 1 ] );
			}
			else if ( issubstr( token, "random_unit_delay=" ) )
			{
				self.randomunitdelay = int( strtok( token, "=" )[ 1 ] );
			}
			else
			{
				if ( issubstr( token, "unit_delay=" ) )
				{
					self.unitdelay = int( strtok( token, "=" )[ 1 ] );
				}
			}
			_k231 = getNextArrayKey( _a231, _k231 );
		}
	}
	if ( self.unitdelay == 0 && self.individualdelay == 0 && self.randomunitdelay == 0 )
	{
		return;
	}
	self.delay_queue = [];
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isDefined( who.unitid ) )
		{
			delayunit = getunit( who.unitid );
			while ( !isDefined( delayunit ) )
			{
				continue;
			}
			if ( isDefined( delayunit.delayed ) && delayunit.delayed == self )
			{
				continue;
			}
			self.delay_queue[ self.delay_queue.size ] = delayunit.unitid;
			self thread delay_unit_think( who );
		}
	}
}

enemy_unit_delayzones()
{
	delayzones = getentarray( "rts_unit_delay", "targetname" );
	_a276 = delayzones;
	_k276 = getFirstArrayKey( _a276 );
	while ( isDefined( _k276 ) )
	{
		zone = _a276[ _k276 ];
		zone thread delay_trigger_think();
		_k276 = getNextArrayKey( _a276, _k276 );
	}
}

enemy_squad_spawnasquad( cb )
{
	if ( level.rts.enemy_squad_queue.size == 0 )
	{
		return;
	}
	ref = level.rts.enemy_squad_queue[ 0 ];
	pkg = maps/_so_rts_catalog::package_getpackagebytype( ref );
	squad = maps/_so_rts_squad::getsquadbypkg( ref, "axis" );
	if ( isDefined( cb ) )
	{
	}
	else
	{
	}
	squadid = maps/_so_rts_catalog::spawn_package( ref, "axis", 0, ::order_new_squad, cb );
	arrayremoveindex( level.rts.enemy_squad_queue, 0 );
/#
	if ( isDefined( squadid ) )
	{
	}
	else
	{
	}
	println( "success" + "failed" + " at time (" + getTime() + ")", "##### Spawning enemy squad (" + ref + ")  Result=" );
#/
}

enemy_squad_spawner()
{
	level endon( "rts_terminated" );
	level endon( "end_enemy_player" );
	level.rts.enemy_squad_queue = [];
	while ( flag( "rts_enemy_squad_spawner_enabled" ) )
	{
/#
		while ( getDvarInt( "scr_rts_enemyDisabled" ) == 1 )
		{
			wait 1;
#/
		}
		time = 1;
		i = 0;
		while ( i < level.rts.enemy_squad_queue.size )
		{
			ref = level.rts.enemy_squad_queue[ i ];
			pkg = maps/_so_rts_catalog::package_getpackagebytype( ref );
			squad = maps/_so_rts_squad::getsquadbypkg( ref, "axis" );
			total = 0;
			if ( isDefined( squad ) )
			{
				maps/_so_rts_squad::removedeadfromsquad( squad.id );
				total = squad.members.size;
			}
			total += maps/_so_rts_catalog::getnumberofpkgsbeingtransported( "axis", ref ) * pkg.numunits;
			if ( total >= pkg.max_axis )
			{
				arrayremoveindex( level.rts.enemy_squad_queue, i );
				i++;
				continue;
			}
			else
			{
				squadid = maps/_so_rts_catalog::spawn_package( ref, "axis", 0, ::order_new_squad );
				if ( isDefined( squadid ) )
				{
					arrayremoveindex( level.rts.enemy_squad_queue, i );
					time = 0,1;
					break;
				}
			}
			else
			{
				i++;
			}
		}
		wait time;
	}
}

removemefromunit()
{
	while ( isDefined( self.unitid ) )
	{
		i = 0;
		while ( i < level.rts.enemy_units.size )
		{
			unit = level.rts.enemy_units[ i ];
			if ( unit.unitid == self.unitid )
			{
				arrayremovevalue( unit.members, self );
				self.unitid = undefined;
				return;
			}
			i++;
		}
	}
}

ai_poi_near_watch()
{
	self endon( "death" );
	self notify( "ai_poi_near_Watch" );
	self endon( "ai_poi_near_Watch" );
	self endon( "unit_dispersed" );
	self waittill( "near_poi", poi );
	if ( isDefined( self.unitid ) )
	{
		unitdisperse( getunit( self.unitid ), poi.origin );
	}
}

ai_unit_individual_think()
{
	self thread ai_poi_near_watch();
}

createunit( ai_array, center )
{
	if ( !isDefined( ai_array ) || ai_array.size == 0 )
	{
		return undefined;
	}
	unit = spawnstruct();
	unit.members = ai_array;
	unit.unitid = level.rts.enemy_units_nextid;
	unit.poi = undefined;
	if ( isDefined( center ) )
	{
	}
	else
	{
	}
	unit.center = level.rts.enemy_center.origin;
	unit.destroyed = 0;
	i = 0;
	while ( i < unit.members.size )
	{
		if ( isDefined( unit.members[ i ] ) )
		{
			unit.members[ i ].unitid = unit.unitid;
			unit.members[ i ] thread ai_unit_individual_think();
		}
		i++;
	}
	level.rts.enemy_units[ level.rts.enemy_units.size ] = unit;
	level.rts.enemy_units_nextid += 1;
	unitdefend( unit, unit.center );
	return unit;
}

create_units_from_squad( squadid, centerselforigin )
{
	squad = maps/_so_rts_squad::getsquad( squadid );
	unit = [];
	if ( squad.pkg_ref.squad_type == "infantry" )
	{
		maxsize = 2;
	}
	else
	{
		maxsize = 1;
	}
	i = 0;
	while ( i < squad.members.size )
	{
		if ( isDefined( centerselforigin ) )
		{
			center = squad.members[ i ].origin;
		}
		if ( !isDefined( squad.members[ i ].unitid ) )
		{
			unit[ unit.size ] = squad.members[ i ];
		}
		if ( unit.size == maxsize )
		{
			break;
		}
		else
		{
			i++;
		}
	}
	if ( unit.size == 0 )
	{
		return undefined;
	}
	return createunit( unit, center );
}

create_units_from_allsquads()
{
	_a455 = level.rts.squads;
	_k455 = getFirstArrayKey( _a455 );
	while ( isDefined( _k455 ) )
	{
		squad = _a455[ _k455 ];
		if ( squad.team != "axis" )
		{
		}
		else
		{
			unit = undefined;
			unit = create_units_from_squad( squad.id );
			if ( isDefined( unit ) )
			{
				level thread unitthink( unit, get_best_poi_target( unit ) );
			}
			wait 0,05;
		}
		_k455 = getNextArrayKey( _a455, _k455 );
	}
}

getunit( unitid )
{
	if ( !isDefined( level.rts.enemy_units ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < level.rts.enemy_units.size )
	{
		if ( level.rts.enemy_units[ i ].unitid == unitid )
		{
			return level.rts.enemy_units[ i ];
		}
		i++;
	}
	return undefined;
}

chase_downsquads( unit, targetid )
{
	if ( !isDefined( targetid ) )
	{
		targetid = undefined;
	}
	level endon( "rts_terminated" );
	if ( !isDefined( unit ) || is_true( unit.destroyed ) )
	{
		return;
	}
	level notify( "chase_DownSquads" + unit.unitid );
	level endon( "chase_DownSquads" + unit.unitid );
	if ( isDefined( level.rts.chase_logic_override ) )
	{
		[[ level.rts.chase_logic_override ]]( unit );
		return;
	}
	valid = [];
	_a508 = level.rts.nag_units;
	_k508 = getFirstArrayKey( _a508 );
	while ( isDefined( _k508 ) )
	{
		curunit = _a508[ _k508 ];
		if ( isDefined( curunit.target ) )
		{
			valid[ valid.size ] = curunit;
		}
		_k508 = getNextArrayKey( _a508, _k508 );
	}
	level.rts.nag_units = valid;
	if ( isDefined( targetid ) )
	{
		target = maps/_so_rts_squad::getsquad( targetid );
		if ( isDefined( target ) && target.members.size == 0 )
		{
			target = undefined;
		}
	}
	if ( !isDefined( target ) )
	{
		if ( level.rts.nag_units.size >= level.rts.game_rules.num_nag_squads )
		{
			chosenpoi = get_best_poi_target( unit );
			if ( isDefined( chosenpoi ) )
			{
				level thread new_unit_init( unit, chosenpoi );
				return;
			}
			else
			{
				unitdisperse( unit, unit.center );
				wait 20;
				if ( !isDefined( unit ) || is_true( unit.destroyed ) )
				{
					arrayremovevalue( level.rts.nag_units, unit );
					return;
				}
				level thread new_unit_init( unit, undefined );
				return;
			}
		}
		if ( level.rts.nag_targets.size > 0 )
		{
			target = maps/_so_rts_squad::getsquad( level.rts.nag_targets[ randomint( level.rts.nag_targets.size ) ] );
		}
		else targets = maps/_so_rts_squad::getsquadsbytype( undefined, "allies", 1 );
		if ( targets.size > 0 )
		{
			target = targets[ randomint( targets.size ) ];
			found = 0;
			if ( isDefined( level.rts.player.ally ) )
			{
				i = 0;
				while ( i < level.rts.nag_units.size )
				{
					if ( level.rts.nag_units[ i ].target == level.rts.player )
					{
						found = 1;
						break;
					}
					else
					{
						i++;
					}
				}
				if ( !found )
				{
					if ( !is_true( level.rts.squads[ level.rts.player.ally.squadid ].no_nag ) )
					{
						target = level.rts.squads[ level.rts.player.ally.squadid ];
					}
				}
			}
		}
		else
		{
			target = undefined;
		}
		if ( isDefined( target ) )
		{
			if ( !isinarray( level.rts.nag_units, unit ) )
			{
				level.rts.nag_units[ level.rts.nag_units.size ] = unit;
			}
			if ( isDefined( level.rts.player.ally ) && target.id == level.rts.player.ally.squadid )
			{
				unit.target = level.rts.player;
			}
			else
			{
				unit.target = target.members[ randomint( target.members.size ) ];
			}
			unit.targetsquad = target.id;
		}
		else
		{
			unit.target = undefined;
		}
	}
	while ( isDefined( unit.target ) )
	{
		if ( unit.target == level.rts.player || !isDefined( level.rts.player.ally ) && level.rts.player.ally.squadid != unit.targetsquad )
		{
			unit.target = undefined;
			break;
		}
		else
		{
			unit.center = unit.target.origin;
			unitdefend( unit, unit.center );
			wait 5;
			if ( !isDefined( unit ) || is_true( unit.destroyed ) )
			{
				arrayremovevalue( level.rts.nag_units, unit );
				return;
			}
		}
	}
	unitdisperse( unit, unit.center );
	wait 20;
	if ( !isDefined( unit ) || is_true( unit.destroyed ) )
	{
		arrayremovevalue( level.rts.nag_units, unit );
		return;
	}
	level thread new_unit_init( unit, undefined );
}

redeploy_on_poi_attemptedtakeover( unit )
{
	level endon( "rts_terminated" );
	level notify( "redeploy_on_poi_takeover" + unit.unitid );
	level endon( "redeploy_on_poi_takeover" + unit.unitid );
	level waittill_any( "poi_contested", "poi_nolonger_contested" );
	chosenpoi = get_best_poi_target( unit );
	level thread new_unit_init( unit, chosenpoi );
}

redeploy_on_poi_lost( unit )
{
	level endon( "rts_terminated" );
	level notify( "redeploy_on_poi_lost" + unit.unitid );
	level endon( "redeploy_on_poi_lost" + unit.unitid );
	if ( !isDefined( unit.poi ) )
	{
		return;
	}
	while ( !is_true( unit.destroyed ) )
	{
		if ( isDefined( unit.poi ) && isinarray( level.rts.poi, unit.poi ) )
		{
			wait 2;
			continue;
		}
		else
		{
			chosenpoi = get_best_poi_target( unit );
			level thread new_unit_init( unit, chosenpoi );
			return;
		}
	}
}

gotopoint( goal )
{
	self notify( "gotoPoint" );
	self endon( "gotoPoint" );
	self endon( "death" );
	if ( is_corpse( self ) )
	{
		self.at_goal = 1;
		return;
	}
	if ( isDefined( self.last_goalradius ) )
	{
		self.goalradius = self.last_goalradius;
		self.last_goalradius = undefined;
	}
	self.at_goal = undefined;
	if ( self.goalradius > 512 )
	{
		self.last_goalradius = self.goalradius;
		self.goalradius = 512;
	}
	else
	{
		if ( self.goalradius < 350 )
		{
			self.last_goalradius = self.goalradius;
			self.goalradius = 350;
		}
	}
	if ( isai( self ) )
	{
/#
		self squaddebug( "gotoPoint", goal );
#/
		if ( is_true( self.isbigdog ) )
		{
			goingtonode = 0;
			node = get_closest_doublewidenode( goal, self.goalradius, 100 );
			if ( isDefined( node ) )
			{
				goal = node;
				goingtonode = 1;
			}
			else
			{
				node = get_closest_doublewidenode( goal, 1000, 600 );
				if ( isDefined( node ) )
				{
					goal = node;
					goingtonode = 1;
				}
			}
			if ( goingtonode )
			{
				self setgoalnode( goal );
			}
			else
			{
				self setgoalpos( goal );
			}
			self waittill( "goal" );
		}
		else
		{
			self setgoalpos( goal );
			self waittill( "goal" );
			if ( isalive( self ) )
			{
				self animscripts/combat_utility::lookforbettercover( 0 );
			}
		}
	}
	else if ( !issentient( self ) )
	{
		if ( self.classname == "script_vehicle" )
		{
			self setvehgoalpos( goal, 1 );
			self waittill_any( "goal", "near_goal" );
		}
	}
	else
	{
		self thread maps/_vehicle::defend( goal );
		self waittill( "goal" );
	}
	if ( isDefined( self.last_goalradius ) )
	{
		self.goalradius = self.last_goalradius;
		self.last_goalradius = undefined;
	}
	self.at_goal = 1;
}

unitdefend( unit, position )
{
	unit.center = position;
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
	_a830 = unit.members;
	_k830 = getFirstArrayKey( _a830 );
	while ( isDefined( _k830 ) )
	{
		guy = _a830[ _k830 ];
		guy.goalradius = 512;
		guy thread gotopoint( position );
		_k830 = getNextArrayKey( _a830, _k830 );
	}
}

unitdispersetolocation( origin )
{
	self endon( "death" );
/#
	thread maps/_so_rts_support::debug_sphere( origin, 10, ( 1, 1, 1 ), 0,6, 3 );
#/
	self.busy = 1;
	self.goalradius = 512;
	self gotopoint( origin );
	self.unitid = undefined;
	self.busy = undefined;
}

unitdisperse( unit, position )
{
/#
	println( "Unit " + unit.unitid + " dispersing at" + position );
#/
	nodes = getnodesinradius( position, 1024, 0, 256 );
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
	_a869 = unit.members;
	_k869 = getFirstArrayKey( _a869 );
	while ( isDefined( _k869 ) )
	{
		guy = _a869[ _k869 ];
		guy notify( "unit_dispersed" );
		if ( nodes.size > 0 )
		{
			guy thread unitdispersetolocation( nodes[ randomint( nodes.size ) ].origin );
		}
		_k869 = getNextArrayKey( _a869, _k869 );
	}
	unit.destroyed = 1;
	unit.members = [];
	arrayremovevalue( level.rts.nag_units, unit );
	arrayremovevalue( level.rts.enemy_units, unit );
}

new_unit_init( unit, poi )
{
	if ( isDefined( poi ) && isDefined( poi.entity ) )
	{
		if ( poi.nodes.size > 0 )
		{
			unit.center = poi.nodes[ 0 ].origin;
		}
		else
		{
			unit.center = poi.entity.origin;
		}
		unit.poi = poi;
		level thread redeploy_on_poi_lost( unit );
		level thread redeploy_on_poi_attemptedtakeover( unit );
		level unitdefend( unit, unit.center );
	}
	else
	{
		unit.poi = undefined;
		level thread chase_downsquads( unit );
	}
}

unitthink( unit, poi )
{
	level endon( "rts_terminated" );
	if ( isDefined( level.rts.enemy_unitthinkcb ) )
	{
		[[ level.rts.enemy_unitthinkcb ]]( unit, poi );
		return;
	}
	new_unit_init( unit, poi );
	while ( unit.members.size > 0 )
	{
		while ( !is_true( unit.suspendthink ) )
		{
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
				else if ( unit.members[ i ].health <= 0 )
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
			_a937 = unit.members;
			_k937 = getFirstArrayKey( _a937 );
			while ( isDefined( _k937 ) )
			{
				member = _a937[ _k937 ];
				if ( isDefined( member.goalpos ) )
				{
					distsq = distancesquared( member.goalpos, unit.center );
					if ( distsq > 262144 )
					{
						member.at_goal = undefined;
					}
				}
				if ( is_true( member.initialized ) && !is_true( member.at_goal ) )
				{
					member.goalradius = 512;
					member thread gotopoint( unit.center );
				}
				_k937 = getNextArrayKey( _a937, _k937 );
			}
		}
		wait 1;
	}
	unit.destroyed = 1;
}

unitsprune()
{
	units = [];
	i = 0;
	while ( i < level.rts.enemy_units.size )
	{
		if ( is_false( level.rts.enemy_units[ i ].destroyed ) )
		{
			units[ units.size ] = level.rts.enemy_units[ i ];
			i++;
			continue;
		}
		else
		{
/#
			println( "$$$$ Unit destroyed:" + level.rts.enemy_units[ i ].unitid );
#/
		}
		i++;
	}
	level.rts.enemy_units = units;
	units = [];
	i = 0;
	while ( i < level.rts.nag_units.size )
	{
		if ( is_false( level.rts.nag_units[ i ].destroyed ) )
		{
			units[ units.size ] = level.rts.nag_units[ i ];
			i++;
			continue;
		}
		else
		{
/#
			println( "$$$$ NagUnit destroyed:" + level.rts.nag_units[ i ].unitid );
#/
		}
		i++;
	}
	level.rts.nag_units = units;
	return level.rts.enemy_units;
}

create_nagsquads( num )
{
	level.rts.game_rules.num_nag_squads = num;
	left = num;
	_a1004 = level.rts.enemy_units;
	_k1004 = getFirstArrayKey( _a1004 );
	while ( isDefined( _k1004 ) )
	{
		unit = _a1004[ _k1004 ];
		new_unit_init( unit, undefined );
		left--;

		if ( left == 0 )
		{
			return;
		}
		else
		{
			_k1004 = getNextArrayKey( _a1004, _k1004 );
		}
	}
}

order_new_squad( squadid )
{
	squad = maps/_so_rts_squad::getsquad( squadid );
	squad.nextstate = 7;
	unit = create_units_from_squad( squadid );
	if ( !isDefined( unit ) || unit.size == 0 )
	{
		return;
	}
	nagchance = 100 - ( ( level.rts.nag_units.size / level.rts.game_rules.num_nag_squads ) * 100 );
	chosenpoi = get_best_poi_target( unit );
	if ( !isDefined( chosenpoi ) )
	{
		nagchance = 100;
	}
	else
	{
		if ( chosenpoi.score.totalscore > 1,5 )
		{
			nagchance += 30;
		}
	}
	if ( level.rts.game_rules.num_nag_squads > 0 && level.rts.nag_units.size == 0 )
	{
		chosenpoi = undefined;
	}
	if ( randomint( 100 ) < nagchance )
	{
		chosenpoi = undefined;
	}
	level thread unitthink( unit, chosenpoi );
}

get_best_poi_target( unit )
{
	_a1050 = level.rts.poi;
	_k1050 = getFirstArrayKey( _a1050 );
	while ( isDefined( _k1050 ) )
	{
		poi = _a1050[ _k1050 ];
		poi.score = spawnstruct();
		poi.score.defenders = 0;
		poi.score.totalscore = 0;
		_k1050 = getNextArrayKey( _a1050, _k1050 );
	}
	activeunits = unitsprune();
	activeenemysquads = maps/_so_rts_squad::getactivesquads( "allies" );
	playerbasepoi = maps/_so_rts_poi::getpoibyref( "rts_base_player" );
	poioptions = [];
	enemydeployed = 0;
	_a1066 = activeunits;
	_k1066 = getFirstArrayKey( _a1066 );
	while ( isDefined( _k1066 ) )
	{
		deployedunit = _a1066[ _k1066 ];
		enemydeployed += deployedunit.members.size;
		_k1066 = getNextArrayKey( _a1066, _k1066 );
	}
	_a1072 = level.rts.poi;
	_k1072 = getFirstArrayKey( _a1072 );
	while ( isDefined( _k1072 ) )
	{
		poi = _a1072[ _k1072 ];
		if ( is_true( poi.captured ) )
		{
		}
		else if ( !isDefined( poi.entity ) )
		{
		}
		else if ( is_true( poi.ignoreme ) )
		{
		}
		else poi.score.disttosquad = 1;
		if ( isDefined( unit ) )
		{
			if ( isDefined( unit.poi ) && unit.poi == poi )
			{
				poi.score.totalscore = 0;
			}
			else
			{
				disttopoi = distance( poi.entity.origin, unit.center );
				if ( disttopoi > 0 )
				{
					poi.score.disttosquad = 1 - min( 1, disttopoi / 7000 );
					break;
				}
				else
				{
					poi.score.disttosquad = 1;
				}
			}
			poi.score.defenders = 0;
			_a1104 = activeunits;
			_k1104 = getFirstArrayKey( _a1104 );
			while ( isDefined( _k1104 ) )
			{
				deployedunit = _a1104[ _k1104 ];
				if ( !isDefined( deployedunit.poi ) )
				{
				}
				else
				{
					if ( poi.nodes.size > 0 && distancesquared( deployedunit.center, poi.nodes[ 0 ].origin ) < 4096 )
					{
						poi.score.defenders += deployedunit.members.size;
					}
					if ( poi.nodes.size == 0 && distancesquared( deployedunit.center, poi.entity.origin ) < 4096 )
					{
						poi.score.defenders += deployedunit.members.size;
					}
				}
				_k1104 = getNextArrayKey( _a1104, _k1104 );
			}
			ideal = level.rts.poi_ideal;
			actual = poi.score.defenders / ideal;
			poi.score.vacant = 1 - actual;
			if ( isDefined( playerbasepoi ) )
			{
				disttopoi = distance( poi.entity.origin, playerbasepoi.entity.origin );
				if ( disttopoi > 0 )
				{
					poi.score.disttoplayerbase = 1 - min( 1, disttopoi / 7000 );
				}
				else
				{
					poi.score.disttoplayerbase = 1;
				}
			}
			else
			{
				poi.score.disttoplayerbase = 0;
			}
			poi.score.enemiespresent = 0;
			_a1138 = activeenemysquads;
			_k1138 = getFirstArrayKey( _a1138 );
			while ( isDefined( _k1138 ) )
			{
				activeenemysquad = _a1138[ _k1138 ];
				squadcenter = getsquadcenter( activeenemysquad );
				if ( distancesquared( squadcenter, poi.entity.origin ) < 262144 )
				{
					poi.score.enemiespresent = 1;
					break;
				}
				else
				{
					_k1138 = getNextArrayKey( _a1138, _k1138 );
				}
			}
			poi.score.belongstoenemy = 0;
			if ( is_true( poi.canbe_retaken ) )
			{
				if ( is_true( poi.has_intruder ) || poi.team == "allies" )
				{
					poi.score.belongstoenemy = 1;
				}
			}
			else
			{
				if ( is_true( poi.has_intruder ) )
				{
					poi.score.belongstoenemy = 0,65;
				}
				if ( poi.team == "allies" )
				{
					poi.score.belongstoenemy += 0,35;
				}
			}
			poi.score.objective = 0;
			objectives = maps/_so_rts_poi::getpoiobjectives();
			if ( isinarray( objectives, poi ) )
			{
				poi.score.objective = 1 / objectives.size;
			}
			poi.score.totalscore = ( ( ( ( ( poi.score.disttosquad * 2 ) + ( poi.score.disttoplayerbase * 0,7 ) ) + ( poi.score.vacant * 2 ) ) + ( poi.score.enemiespresent * 1 ) ) + ( poi.score.objective * 1,2 ) ) + ( poi.score.belongstoenemy * 2 );
			poi.score.totalscore += poi.extraweight;
			if ( isDefined( level.rts.max_poi_infantry ) && poi.score.defenders >= level.rts.max_poi_infantry )
			{
				poi.score.totalscore = 0;
				break;
			}
			else
			{
				if ( poi.score.totalscore <= 0 )
				{
					poi.score.totalscore = 0;
					lastzeropoi = poi;
					break;
				}
				else
				{
					poioptions[ poioptions.size ] = poi;
/#
					if ( getDvarInt( "scr_rts_enemyDebug" ) )
					{
						if ( isDefined( unit ) )
						{
							recordline( poi.entity.origin, unit.center, ( 1, 1, 1 ), "Script" );
						}
						recordenttext( "distToSquad: " + formatfloat( poi.score.disttosquad * 2, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "distToPlayerBase: " + formatfloat( poi.score.disttoplayerbase * 0,7, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "vacant: " + formatfloat( poi.score.vacant * 2, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "defenders: " + poi.score.defenders, poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "enemiesPresent: " + formatfloat( poi.score.enemiespresent * 1, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "belongsToEnemy: " + formatfloat( poi.score.belongstoenemy * 2, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "objective: " + formatfloat( poi.score.objective * 1,2, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						recordenttext( "total: " + formatfloat( poi.score.totalscore, 2 ), poi.entity, ( 1, 1, 1 ), "Script" );
						if ( isDefined( unit ) )
						{
							println( "\nUnit: " + unit.unitid + " POI: " + poi.ref );
						}
						else
						{
							println( "\nPOI: " + poi.ref );
						}
						println( "distToSquad: " + formatfloat( poi.score.disttosquad * 2, 2 ) );
						println( "distToPlayerBase: " + formatfloat( poi.score.disttoplayerbase * 0,7, 2 ) );
						println( "vacant: " + formatfloat( poi.score.vacant * 2, 2 ) );
						println( "defenders: " + poi.score.defenders );
						println( "enemiesPresent: " + formatfloat( poi.score.enemiespresent * 1, 2 ) );
						println( "belongsToEnemy: " + formatfloat( poi.score.belongstoenemy * 2, 2 ) );
						println( "objective: " + formatfloat( poi.score.objective * 1,2, 2 ) );
						println( "extraweight: " + formatfloat( poi.extraweight, 2 ) );
						println( "total: " + formatfloat( poi.score.totalscore, 2 ) );
#/
					}
				}
			}
		}
		_k1072 = getNextArrayKey( _a1072, _k1072 );
	}
	if ( poioptions.size == 0 && isDefined( lastzeropoi ) )
	{
		poioptions[ poioptions.size ] = lastzeropoi;
	}
	if ( poioptions.size > 0 )
	{
		poioptions = maps/_utility_code::mergesort( poioptions, ::poiscorecomparefunc, undefined );
		chosenpoi = poioptions[ 0 ];
		if ( chosenpoi.score.totalscore > 0 )
		{
			return chosenpoi;
		}
		else
		{
			return undefined;
		}
	}
	return undefined;
}

poiscorecomparefunc( e1, e2, param )
{
	return e1.score.totalscore > e2.score.totalscore;
}

get_num_ai()
{
	numai = 0;
	activeunits = unitsprune();
	_a1263 = activeunits;
	_k1263 = getFirstArrayKey( _a1263 );
	while ( isDefined( _k1263 ) )
	{
		unit = _a1263[ _k1263 ];
		numai += unit.members.size;
		_k1263 = getNextArrayKey( _a1263, _k1263 );
	}
	return numai;
}

get_number_in_queue( ref )
{
	pkg_ref = package_getpackagebytype( ref );
	if ( !isDefined( pkg_ref ) )
	{
		return 0;
	}
	count = 0;
	i = 0;
	while ( i < level.rts.enemy_squad_queue.size )
	{
		if ( level.rts.enemy_squad_queue[ i ] == ref )
		{
			count += pkg_ref.numunits;
		}
		i++;
	}
	return count;
}

formatfloat( number, decimals )
{
	power = pow( 10, decimals );
	temp = int( number * power );
	temp = float( temp / power );
	return temp;
}
