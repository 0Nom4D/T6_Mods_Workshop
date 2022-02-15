#include maps/_so_rts_catalog;
#include maps/_so_rts_main;
#include maps/_so_rts_ai;
#include maps/_so_rts_squad;
#include maps/_so_rts_poi;
#include maps/_so_rts_event;
#include maps/_so_rts_support;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

preload()
{
/#
	assert( isDefined( level.rts ) );
#/
/#
	assert( isDefined( level.rts_def_table ) );
#/
	level.rts.packages = [];
	level.rts.packages_avail = [];
	level.rts.packages = package_populate();
	_a45 = level.rts.packages;
	_k45 = getFirstArrayKey( _a45 );
	while ( isDefined( _k45 ) )
	{
		pkg = _a45[ _k45 ];
		if ( isDefined( pkg.marker ) && pkg.marker != "" )
		{
			precachemodel( pkg.marker );
		}
		_k45 = getNextArrayKey( _a45, _k45 );
	}
}

lookup_value( ref, idx, column_index )
{
/#
	assert( isDefined( idx ) );
#/
	return tablelookup( level.rts_def_table, 0, idx, column_index );
}

pkg_exist( ref )
{
	if ( isDefined( level.rts.packages ) )
	{
		return isDefined( level.rts.packages[ ref ] );
	}
}

get_pkg_ref_by_index( idx )
{
	return tablelookup( level.rts_def_table, 0, idx, 1 );
}

init()
{
	level.rts.packages_avail = package_generateavailable( "allies" );
/#
	assert( isDefined( level.rts.rules ), "rules must be initialized first" );
#/
	level.rts.transport = spawnstruct();
	level.rts.transport.helo = [];
	level.rts.transport.vtol = [];
	level.rts.enemy_notification = 0;
	unith = 0;
	unitv = 0;
	i = 0;
	while ( i < level.rts.game_rules.player_helo )
	{
		unith = level.rts.transport.helo.size;
		level.rts.transport.helo[ unith ] = spawnstruct();
		level.rts.transport.helo[ unith ].state = 0;
		level.rts.transport.helo[ unith ].type = "helo";
		level.rts.transport.helo[ unith ].num = unith;
		level.rts.transport.helo[ unith ].team = "allies";
		level thread transportthink( level.rts.transport.helo[ unith ] );
		i++;
	}
	i = 0;
	while ( i < level.rts.game_rules.enemy_helo )
	{
		unith = level.rts.transport.helo.size;
		level.rts.transport.helo[ unith ] = spawnstruct();
		level.rts.transport.helo[ unith ].state = 0;
		level.rts.transport.helo[ unith ].type = "helo";
		level.rts.transport.helo[ unith ].num = unith;
		level.rts.transport.helo[ unith ].team = "axis";
		level thread transportthink( level.rts.transport.helo[ unith ] );
		i++;
	}
	i = 0;
	while ( i < level.rts.game_rules.player_vtol )
	{
		unitv = level.rts.transport.vtol.size;
		level.rts.transport.vtol[ unitv ] = spawnstruct();
		level.rts.transport.vtol[ unitv ].state = 0;
		level.rts.transport.vtol[ unitv ].type = "vtol";
		level.rts.transport.vtol[ unitv ].num = unitv;
		level.rts.transport.vtol[ unitv ].team = "allies";
		level thread transportthink( level.rts.transport.vtol[ unitv ] );
		i++;
	}
	i = 0;
	while ( i < level.rts.game_rules.enemy_vtol )
	{
		unitv = level.rts.transport.vtol.size;
		level.rts.transport.vtol[ unitv ] = spawnstruct();
		level.rts.transport.vtol[ unitv ].state = 0;
		level.rts.transport.vtol[ unitv ].type = "vtol";
		level.rts.transport.vtol[ unitv ].num = unitv;
		level.rts.transport.vtol[ unitv ].team = "axis";
		level thread transportthink( level.rts.transport.vtol[ unitv ] );
		i++;
	}
	maps/_so_rts_support::set_closestunitparams();
}

package_populate()
{
	pkg_types = [];
	i = 100;
	while ( i <= 120 )
	{
		ref = get_pkg_ref_by_index( i );
		if ( !isDefined( ref ) || ref == "" )
		{
			i++;
			continue;
		}
		else
		{
			pkg = spawnstruct();
			pkg.idx = i;
			pkg.ref = ref;
			pkg.name = lookup_value( ref, i, 2 );
			pkg.desc = lookup_value( ref, i, 3 );
			pkg.cost = [];
			cost = strtok( lookup_value( ref, i, 4 ), " " );
/#
			if ( cost.size >= 1 )
			{
				assert( cost.size <= 2, "unexpected cost parameters" );
			}
#/
			if ( cost.size == 1 )
			{
				if ( cost[ 0 ] == "na" )
				{
					cost[ 0 ] = -1;
				}
				pkg.cost[ "axis" ] = int( cost[ 0 ] );
				pkg.cost[ "allies" ] = int( cost[ 0 ] );
			}
			else
			{
				if ( cost[ 0 ] == "na" )
				{
					cost[ 0 ] = -1;
				}
				if ( cost[ 1 ] == "na" )
				{
					cost[ 1 ] = -1;
				}
				pkg.cost[ "axis" ] = int( cost[ 0 ] );
				pkg.cost[ "allies" ] = int( cost[ 1 ] );
			}
			if ( pkg.cost[ "axis" ] != -1 )
			{
				pkg.cost[ "axis" ] *= 1000;
			}
			if ( pkg.cost[ "allies" ] != -1 )
			{
				pkg.cost[ "allies" ] *= 1000;
			}
			pkg.units = [];
			pkg.units = strtok( lookup_value( ref, i, 5 ), " " );
			pkg.numunits = pkg.units.size;
			pkg.delivery = lookup_value( ref, i, 6 );
			pkg.marker = lookup_value( ref, i, 7 );
			pkg.selectable = 0;
			pkg.nextavail = [];
			pkg.nextavail[ "axis" ] = getTime();
			pkg.nextavail[ "allies" ] = getTime();
			pkg.poi_deps = [];
			pkg.poi_deps = strtok( lookup_value( ref, i, 8 ), " " );
/#
			assert( isDefined( pkg.name ) );
#/
/#
			assert( isDefined( pkg.desc ) );
#/
/#
			assert( isDefined( pkg.delivery ) );
#/
			while ( pkg.delivery != "CODE" )
			{
				_a203 = pkg.units;
				_k203 = getFirstArrayKey( _a203 );
				while ( isDefined( _k203 ) )
				{
					unit = _a203[ _k203 ];
/#
					assert( isDefined( level.rts.ai[ unit ] ), "Package is referencing undefined ai unit-->" + unit );
#/
					_k203 = getNextArrayKey( _a203, _k203 );
				}
			}
			pkg.enforce_deps = [];
			pkg.enforce_deps[ "axis" ] = 1;
			pkg.enforce_deps[ "allies" ] = 1;
			pkg.squad_type = lookup_value( ref, i, 9 );
			pkg.squad_material = lookup_value( ref, i, 10 );
			pkg.qty = [];
			qty = strtok( lookup_value( ref, i, 11 ), " " );
/#
			if ( qty.size >= 1 )
			{
				assert( qty.size <= 2, "unexpected qty parameters" );
			}
#/
			if ( qty.size == 1 )
			{
				if ( qty[ 0 ] == "inf" )
				{
					qty[ 0 ] = -1;
				}
				pkg.qty[ "axis" ] = -1;
				pkg.qty[ "allies" ] = int( qty[ 0 ] );
			}
			else
			{
				if ( qty[ 0 ] == "inf" )
				{
					qty[ 0 ] = -1;
				}
				if ( qty[ 1 ] == "inf" )
				{
					qty[ 1 ] = -1;
				}
				pkg.qty[ "axis" ] = int( qty[ 0 ] );
				pkg.qty[ "allies" ] = int( qty[ 1 ] );
			}
			pkg.min_friendly = int( lookup_value( ref, i, 12 ) );
			pkg.max_friendly = int( lookup_value( ref, i, 13 ) );
/#
			assert( pkg.min_friendly <= pkg.max_friendly, "Bad data" );
#/
			pkg.min_axis = pkg.min_friendly;
			pkg.max_axis = pkg.max_friendly;
			pkg.hot_key_buy = lookup_value( ref, i, 14 );
			pkg.hot_key_command = lookup_value( ref, i, 15 );
			pkg.hot_key_takeover = lookup_value( ref, i, 16 );
			if ( pkg.hot_key_buy != "" )
			{
				maps/_so_rts_support::registerkeybinding( pkg.hot_key_buy, ::package_buyunitpressed, pkg );
			}
			else
			{
				pkg.hot_key_buy = undefined;
			}
			if ( pkg.hot_key_command != "" )
			{
				maps/_so_rts_support::registerkeybinding( pkg.hot_key_command, ::package_commandunitpressed, pkg );
			}
			else
			{
				pkg.hot_key_command = undefined;
			}
			if ( pkg.hot_key_takeover != "" )
			{
				maps/_so_rts_support::registerkeybinding( pkg.hot_key_takeover, ::package_takeoverunitpressed, pkg );
			}
			else
			{
				pkg.hot_key_takeover = undefined;
			}
			pkg.notifyavail = lookup_value( ref, i, 17 );
			if ( pkg.notifyavail == "" )
			{
				pkg.notifyavail = undefined;
			}
			pkg.gateflag = lookup_value( ref, i, 18 );
			if ( pkg.gateflag == "" )
			{
				pkg.gateflag = undefined;
			}
			pkg_types[ pkg_types.size ] = pkg;
		}
		i++;
	}
	return pkg_types;
}

package_commandunitfps( squadid )
{
/#
	assert( flag( "fps_mode" ) );
#/
	if ( !isDefined( squadid ) )
	{
		return;
	}
	squads = [];
	if ( squadid == 99 )
	{
		if ( isDefined( level.rts.targetteamenemy ) )
		{
			level notify( "all_squads_attack" );
			wait 0,05;
		}
		else
		{
			level notify( "all_squads_move" );
			wait 0,05;
		}
		maps/_so_rts_event::trigger_event( "move_all_fps" );
		allysquads = getteamsquads( level.rts.player.team );
		i = 0;
		while ( i < allysquads.size )
		{
			if ( !is_true( allysquads[ i ].selectable ) )
			{
				i++;
				continue;
			}
			else if ( is_true( allysquads[ i ].no_group_commands ) )
			{
				i++;
				continue;
			}
			else
			{
				squads[ squads.size ] = allysquads[ i ];
			}
			i++;
		}
	}
	else squad = level.rts.squads[ squadid ];
	squads[ 0 ] = squad;
	direction = maps/_so_rts_support::get_player_angles();
	if ( isDefined( level.rts.player.ally ) && isDefined( level.rts.player.ally.vehicle ) )
	{
		if ( isDefined( level.rts.player.ally.vehicle.ai_ref.cmd_tag ) )
		{
			eye = level.rts.player.ally.vehicle gettagorigin( level.rts.player.ally.vehicle.ai_ref.cmd_tag );
		}
		else
		{
			eye = level.rts.player.origin;
		}
	}
	else
	{
		eye = level.rts.player.origin + vectorScale( ( 0, 0, 1 ), 60 );
	}
	direction_vec = anglesToForward( direction );
	trace = bullettrace( eye, eye + vectorScale( direction_vec, 100000 ), 1, level.rts.player );
	hitent = trace[ "entity" ];
	tracepoint = trace[ "position" ];
/#
	thread maps/_so_rts_support::debugline( eye, tracepoint, ( 0, 0, 1 ), 3 );
	thread maps/_so_rts_support::debug_sphere( tracepoint, 10, ( 0, 0, 1 ), 0,6, 3 );
#/
	while ( level.rts.trace_blockers.size > 0 )
	{
		_a359 = level.rts.trace_blockers;
		_k359 = getFirstArrayKey( _a359 );
		while ( isDefined( _k359 ) )
		{
			volume = _a359[ _k359 ];
			if ( maps/_utility::is_point_inside_volume( tracepoint, volume ) )
			{
				level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_UNIT_CANT_MOVE_THERE" );
				return;
			}
			_k359 = getNextArrayKey( _a359, _k359 );
		}
	}
	level.rts.targetpoi = undefined;
	level.rts.targetteamenemy = undefined;
	level.rts.targetteammate = undefined;
	if ( isDefined( hitent ) )
	{
		if ( isDefined( maps/_so_rts_poi::ispoient( hitent ) ) )
		{
			level.rts.targetpoi = hitent;
		}
		else if ( !isDefined( hitent.team ) )
		{
			return;
		}
		if ( hitent.team != level.rts.player.team )
		{
			level.rts.targetteamenemy = hitent;
		}
		else
		{
			level.rts.targetteammate = hitent;
		}
	}
	_a395 = squads;
	_k395 = getFirstArrayKey( _a395 );
	while ( isDefined( _k395 ) )
	{
		squad = _a395[ _k395 ];
		if ( isDefined( squad.package_commandunitfps_cb ) )
		{
			[[ squad.package_commandunitfps_cb ]]( trace );
		}
		if ( isDefined( level.rts.targetteamenemy ) )
		{
/#
			thread maps/_so_rts_support::debug_sphere( tracepoint, 8, ( 0, 0, 1 ), 0,6, 3 );
#/
			maps/_so_rts_squad::ordersquadattack( squad.id, level.rts.targetteamenemy );
		}
		else if ( isDefined( level.rts.targetpoi ) )
		{
/#
			thread maps/_so_rts_support::debug_sphere( tracepoint, 8, ( 0, 0, 1 ), 0,6, 3 );
#/
			if ( !isDefined( level.rts.targetpoi.ai_ref ) )
			{
				maps/_so_rts_squad::ordersquaddefend( level.rts.targetpoi.origin, squad.id );
			}
			else
			{
				maps/_so_rts_squad::ordersquadfollowai( squad.id, level.rts.targetpoi );
			}
			if ( level.rts.targetpoi.team != level.rts.player.team )
			{
				luinotifyevent( &"rts_squad_start_attack", 3, squad.id, level.rts.targetpoi getentitynumber(), int( level.rts.targetpoi.ref.obj_zoff ) );
				maps/_so_rts_event::trigger_event( "dlg_target_fps_" + level.rts.targetpoi.ref.ref );
			}
		}
		else if ( level.rts.closestunitparams.allowplayerteampip )
		{
			if ( isDefined( level.rts.targetteammate ) )
			{
/#
				thread maps/_so_rts_support::debug_sphere( tracepoint, 8, ( 0, 0, 1 ), 0,6, 3 );
#/
				maps/_so_rts_squad::ordersquadfollowai( squad.id, level.rts.targetteammate );
			}
		}
		else
		{
			groundpos = bullettrace( tracepoint + vectorScale( trace[ "normal" ], 36 ), tracepoint + vectorScale( trace[ "normal" ], 36 ) + vectorScale( ( 0, 0, 1 ), 100000 ), 0, level.rts.player )[ "position" ] + vectorScale( ( 0, 0, 1 ), 6 );
			level notify( "squad_moved" );
			level thread maps/_so_rts_squad::rts_move_squadstocursor( squad.id, groundpos );
		}
		_k395 = getNextArrayKey( _a395, _k395 );
	}
}

package_commandunitrts( squadid )
{
/#
	assert( flag( "rts_mode" ) );
#/
	squads = [];
	if ( !isDefined( squadid ) )
	{
		if ( isDefined( level.rts.targetteammate ) )
		{
			level.rts.activesquad = level.rts.targetteammate.squadid;
		}
		return;
	}
	if ( squadid == 99 )
	{
		if ( isDefined( level.rts.targetteamenemy ) )
		{
			level notify( "all_squads_attack" );
			wait 0,05;
		}
		else
		{
			level notify( "all_squads_move" );
			wait 0,05;
		}
		maps/_so_rts_event::trigger_event( "move_all_pkg" );
		allysquads = getteamsquads( level.rts.player.team );
		i = 0;
		while ( i < allysquads.size )
		{
			if ( !is_true( allysquads[ i ].selectable ) )
			{
				i++;
				continue;
			}
			else if ( is_true( allysquads[ i ].no_group_commands ) )
			{
				i++;
				continue;
			}
			else
			{
				squads[ squads.size ] = allysquads[ i ];
			}
			i++;
		}
	}
	else squad = level.rts.squads[ squadid ];
	squads[ 0 ] = squad;
	_a496 = squads;
	_k496 = getFirstArrayKey( _a496 );
	while ( isDefined( _k496 ) )
	{
		squad = _a496[ _k496 ];
		if ( isDefined( level.rts.targetteamenemy ) )
		{
			maps/_so_rts_squad::ordersquadattack( squad.id, level.rts.targetteamenemy );
		}
		else if ( isDefined( level.rts.targetpoi ) )
		{
			maps/_so_rts_squad::ordersquaddefend( level.rts.targetpoi.origin, squad.id );
			if ( level.rts.targetpoi.team != level.rts.player.team )
			{
				luinotifyevent( &"rts_squad_start_attack", 3, squad.id, level.rts.targetpoi getentitynumber(), int( level.rts.targetpoi.ref.obj_zoff ) );
				maps/_so_rts_event::trigger_event( "dlg_target_" + level.rts.targetpoi.ref.ref );
			}
		}
		else if ( level.rts.closestunitparams.allowplayerteampip )
		{
			if ( isDefined( level.rts.targetteammate ) && level.rts.targetteammate.squadid != squad.id )
			{
				maps/_so_rts_squad::ordersquadfollowai( squad.id, level.rts.targetteammate );
			}
		}
		else
		{
			point = maps/_so_rts_support::playerlinkobj_gettargetgroundpos();
			if ( !isDefined( point ) )
			{
				level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_UNIT_CANT_MOVE_THERE" );
				return;
			}
			while ( level.rts.trace_blockers.size > 0 )
			{
				_a532 = level.rts.trace_blockers;
				_k532 = getFirstArrayKey( _a532 );
				while ( isDefined( _k532 ) )
				{
					volume = _a532[ _k532 ];
					if ( maps/_utility::is_point_inside_volume( point, volume ) )
					{
						level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_UNIT_CANT_MOVE_THERE" );
						return;
					}
					_k532 = getNextArrayKey( _a532, _k532 );
				}
			}
			level notify( "squad_moved" );
			level thread maps/_so_rts_squad::rts_move_squadstocursor( squad.id, point );
		}
		_k496 = getNextArrayKey( _a496, _k496 );
	}
}

package_highlightunits( squadid, clear )
{
	if ( !isDefined( clear ) )
	{
		clear = 1;
	}
	if ( squadid == 99 )
	{
		if ( is_true( clear ) )
		{
			luinotifyevent( &"rts_highlight_squad", 1, -1 );
			rpc( "clientscripts/_so_rts", "set_SquadIsHighlighted", -1 );
		}
		level.rts.activesquad = squadid;
		luinotifyevent( &"rts_highlight_squad", 1, level.rts.activesquad );
		squads = [];
		allysquads = getteamsquads( level.rts.player.team );
		i = 0;
		while ( i < allysquads.size )
		{
			if ( !is_true( allysquads[ i ].selectable ) )
			{
				i++;
				continue;
			}
			else if ( is_true( allysquads[ i ].no_group_commands ) )
			{
				i++;
				continue;
			}
			else
			{
				squads[ squads.size ] = allysquads[ i ];
			}
			i++;
		}
		_a573 = squads;
		_k573 = getFirstArrayKey( _a573 );
		while ( isDefined( _k573 ) )
		{
			squad = _a573[ _k573 ];
			rpc( "clientscripts/_so_rts", "set_SquadIsHighlighted", squad.id );
			_k573 = getNextArrayKey( _a573, _k573 );
		}
	}
	else if ( level.rts.squads[ squadid ].selectable )
	{
		if ( is_true( clear ) )
		{
			luinotifyevent( &"rts_highlight_squad", 1, -1 );
			rpc( "clientscripts/_so_rts", "set_SquadIsHighlighted", -1 );
		}
		level.rts.activesquad = squadid;
		luinotifyevent( &"rts_highlight_squad", 1, level.rts.activesquad );
		rpc( "clientscripts/_so_rts", "set_SquadIsHighlighted", squadid );
	}
}

package_commandunitpressed( pkg_ref, squad )
{
	if ( !isDefined( squad ) )
	{
		squad = maps/_so_rts_squad::getsquadbypkg( pkg_ref.ref, level.rts.player.team );
	}
	if ( isDefined( squad ) )
	{
		if ( !is_true( squad.selectable ) )
		{
			return;
		}
		package_highlightunits( squad.id );
	}
}

package_takeoverunitpressed( pkg_ref )
{
	squad = maps/_so_rts_squad::getsquadbypkg( pkg_ref.ref, level.rts.player.team );
	if ( isDefined( squad ) )
	{
		maps/_so_rts_squad::removedeadfromsquad( squad.id );
		if ( squad.members.size == 0 || !is_true( squad.selectable ) )
		{
			return;
		}
		maps/_so_rts_event::trigger_event( "switch_character" );
		maps/_so_rts_event::trigger_event( "switch_" + squad.pkg_ref.ref );
		if ( flag( "rts_mode" ) )
		{
			point = maps/_so_rts_support::playerlinkobj_gettargetgroundpos();
			closest = undefined;
			sortedunits = sortarraybyclosest( point, squad.members );
			i = 0;
			while ( i < sortedunits.size )
			{
				unit = sortedunits[ i ];
				if ( !maps/_so_rts_ai::ai_isselectable( unit ) )
				{
					i++;
					continue;
				}
				else
				{
					closest = unit;
					break;
				}
				i++;
			}
			if ( isDefined( level.rts.targetteammate ) )
			{
				luinotifyevent( &"rts_deselect", 1, level.rts.targetteammate getentitynumber() );
				level.rts.targetteammate = undefined;
			}
			if ( isDefined( level.rts.targetteamenemy ) )
			{
				luinotifyevent( &"rts_deselect_enemy", 1, level.rts.targetteamenemy getentitynumber() );
				level.rts.targetteamenemy = undefined;
			}
			if ( isDefined( level.rts.targetpoi ) )
			{
				luinotifyevent( &"rts_deselect_poi", 1, level.rts.targetpoi getentitynumber() );
				level.rts.targetpoi = undefined;
			}
			level.rts.targetteammate = closest;
			thread maps/_so_rts_main::player_in_control();
			return;
		}
		else direction = maps/_so_rts_support::get_player_angles();
		direction_vec = anglesToForward( direction );
		eye = level.rts.player geteye();
		trace = bullettrace( eye, eye + vectorScale( direction_vec, 10000 ), 1, level.rts.player );
		hitent = trace[ "entity" ];
		if ( isDefined( hitent ) && isDefined( hitent.squadid ) && hitent.squadid == squad.id )
		{
			thread maps/_so_rts_squad::squadselectnextaiandtakeover( squad.id, undefined, hitent );
			return;
		}
		else
		{
			if ( isDefined( level.rts.squads[ squad.id ].primary_ai_switchtarget ) )
			{
				thread maps/_so_rts_squad::squadselectnextaiandtakeover( squad.id, undefined, level.rts.squads[ squad.id ].primary_ai_switchtarget );
				return;
			}
			else
			{
				thread maps/_so_rts_squad::squadselectnextaiandtakeover( squad.id );
			}
		}
	}
}

package_buyunitpressed( pkg_ref )
{
	if ( flag( "block_input" ) )
	{
		return;
	}
	level.rts.packages_avail = package_generateavailable( level.rts.player.team );
	if ( isinarray( level.rts.packages_avail, pkg_ref ) && pkg_ref.selectable )
	{
		package_select( pkg_ref.ref );
	}
	else
	{
		return;
	}
}

package_getnumteamresources( team )
{
	resources = 0;
	i = 0;
	while ( i < level.rts.packages_avail.size )
	{
		if ( level.rts.packages_avail[ i ].selectable == 0 )
		{
			i++;
			continue;
		}
		else if ( level.rts.packages_avail[ i ].cost[ team ] >= 0 )
		{
			if ( level.rts.packages_avail[ i ].qty[ team ] == -1 )
			{
			}
			else
			{
			}
			resources = 1 + level.rts.packages_avail[ i ].qty[ team ];
		}
		i++;
	}
	resources += numtransportsinboundforteam( team );
	_a733 = level.rts.squads;
	_k733 = getFirstArrayKey( _a733 );
	while ( isDefined( _k733 ) )
	{
		squad = _a733[ _k733 ];
		if ( squad.team != team )
		{
		}
		else
		{
			resources += squad.members.size;
		}
		_k733 = getNextArrayKey( _a733, _k733 );
	}
	if ( team == "allies" && isDefined( level.rts.player.ally ) )
	{
		resources += 1;
	}
	return resources;
}

package_select( pkg_ref, initial, cb )
{
	if ( !isDefined( initial ) )
	{
		initial = 0;
	}
	if ( !isDefined( pkg_ref ) )
	{
		if ( level.rts.packages_avail[ level.rts.package_index ].selectable )
		{
			thread spawn_package( level.rts.packages_avail[ level.rts.package_index ].ref, "allies", initial, cb );
		}
		else
		{
			level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_UNIT_NOTAVAIL" );
		}
	}
	else i = 0;
	while ( i < level.rts.packages_avail.size )
	{
		if ( level.rts.packages_avail[ i ].ref == pkg_ref )
		{
			level.rts.package_index = i;
			thread spawn_package( pkg_ref, "allies", initial, cb );
			return;
		}
		else
		{
			i++;
		}
	}
}

package_setpackagecost( ref, axiscost, allycost )
{
	pkg = package_getpackagebytype( ref );
/#
	assert( isDefined( ref ) );
#/
	axiscost = int( axiscost );
	if ( axiscost != -1 )
	{
		axiscost *= 1000;
	}
	allycost = int( allycost );
	if ( allycost != -1 )
	{
		allycost *= 1000;
	}
	pkg.cost[ "axis" ] = axiscost;
	pkg.cost[ "allies" ] = allycost;
}

package_getpackagebytype( ref )
{
	i = 0;
	while ( i < level.rts.packages.size )
	{
		if ( level.rts.packages[ i ].ref == ref )
		{
			return level.rts.packages[ i ];
		}
		i++;
	}
	return undefined;
}

package_generateavailable( myteam, forceall )
{
	if ( !isDefined( myteam ) )
	{
		myteam = "allies";
	}
	available_pkgs = [];
	time = getTime();
	i = 0;
	while ( i < level.rts.packages.size )
	{
		pkg = level.rts.packages[ i ];
		if ( pkg.cost[ myteam ] == -1 )
		{
			i++;
			continue;
		}
		else if ( pkg.qty[ myteam ] == 0 && !is_true( forceall ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( pkg.gateflag ) && !flag( pkg.gateflag ) )
			{
				i++;
				continue;
			}
			else
			{
				pkg.lastselectablestate = pkg.selectable;
				pkg.selectable = getTime() > pkg.nextavail[ myteam ];
				while ( is_true( pkg.enforce_deps[ myteam ] ) && pkg.poi_deps.size > 0 )
				{
					_a827 = pkg.poi_deps;
					_k827 = getFirstArrayKey( _a827 );
					while ( isDefined( _k827 ) )
					{
						dep = _a827[ _k827 ];
						poi = strtok( dep, "|" );
						hasone = 0;
						j = 0;
						while ( j < poi.size )
						{
							actualpoi = maps/_so_rts_poi::getpoibyref( poi[ j ] );
							if ( !isDefined( actualpoi ) || isDefined( actualpoi ) && actualpoi.team == myteam )
							{
								hasone = 1;
								break;
							}
							else
							{
								j++;
							}
						}
						if ( !hasone )
						{
							pkg.selectable = 0;
							break;
						}
						else
						{
							_k827 = getNextArrayKey( _a827, _k827 );
						}
					}
				}
				available_pkgs[ available_pkgs.size ] = pkg;
			}
		}
		i++;
	}
	while ( !isDefined( forceall ) )
	{
		_a854 = available_pkgs;
		_k854 = getFirstArrayKey( _a854 );
		while ( isDefined( _k854 ) )
		{
			pkg = _a854[ _k854 ];
			if ( isDefined( pkg.notifyavail ) && pkg.selectable == 1 && pkg.selectable != pkg.lastselectablestate )
			{
				level notify( pkg.notifyavail );
			}
			_k854 = getNextArrayKey( _a854, _k854 );
		}
	}
	return available_pkgs;
}

setpkgdelivery( ref, delivery )
{
/#
	assert( isDefined( delivery ) );
#/
/#
	if ( delivery != "STANDARD" && delivery != "CODE" && delivery != "FASTROPE_HELO" && delivery != "FASTROPE_VTOL" )
	{
		assert( delivery == "CARGO_VTOL", "Unknown delivery option" );
	}
#/
	pkg_ref = package_getpackagebytype( ref );
	if ( isDefined( pkg_ref ) )
	{
		pkg_ref.delivery = delivery;
	}
}

setpkgqty( ref, team, qty, squadid )
{
	pkg_ref = package_getpackagebytype( ref );
	if ( isDefined( pkg_ref ) )
	{
		pkg_ref.qty[ team ] = qty;
/#
		println( "Setting pkg quantity for (" + ref + ") of team:" + team + " to:" + qty );
#/
	}
	if ( team == "allies" )
	{
		level.rts.packages_avail = package_generateavailable( "allies" );
		if ( isDefined( squadid ) )
		{
			if ( pkg_ref.qty[ "allies" ] > 0 )
			{
			}
			else
			{
			}
			luinotifyevent( &"rts_update_remaining_count", 2, squadid, -1, pkg_ref.qty[ "allies" ] );
		}
	}
}

setpkgdependancyenforcement( ref, team, state )
{
	pkg_ref = package_getpackagebytype( ref );
	if ( isDefined( pkg_ref ) )
	{
		pkg_ref.enforce_deps[ team ] = state;
	}
	if ( team == "allies" )
	{
		level.rts.packages_avail = package_generateavailable( "allies" );
	}
}

candeliverpkg( team, delivery, pkg_ref )
{
	if ( pkg_ref.delivery == "CODE" || pkg_ref.delivery == "STANDARD" )
	{
		if ( pkg_ref.nextavail[ "allies" ] > getTime() )
		{
			return "not_ready";
		}
	}
	if ( pkg_ref.qty[ team ] != -1 )
	{
		if ( pkg_ref.qty[ team ] > 0 )
		{
			return "ok";
		}
		else
		{
			return "not_ready";
		}
	}
	return "ok";
}

spawn_package( package_name, team, initial, callback )
{
	pkg_ref = maps/_so_rts_catalog::package_getpackagebytype( package_name );
/#
	assert( isDefined( pkg_ref ) );
#/
	delivery = pkg_ref.delivery;
	if ( is_true( initial ) && delivery != "CODE" )
	{
		delivery = "STANDARD";
	}
	if ( delivery == "STANDARD" || delivery == "CODE" )
	{
		if ( is_true( initial ) || pkg_ref.selectable && getTime() >= pkg_ref.nextavail[ team ] )
		{
			if ( pkg_ref.qty[ team ] > 0 )
			{
				pkg_ref.qty[ team ]--;

			}
			pkg_ref.nextavail[ team ] = getTime() + pkg_ref.cost[ team ];
			switch( delivery )
			{
				case "STANDARD":
					squadid = maps/_so_rts_ai::spawn_ai_package_standard( pkg_ref, team, callback );
					if ( isDefined( squadid ) && squadid == -1 )
					{
						squadid = undefined;
					}
					if ( team == level.rts.player.team && pkg_ref.qty[ team ] >= 0 )
					{
						if ( pkg_ref.qty[ team ] > 0 )
						{
						}
						else
						{
						}
						luinotifyevent( &"rts_update_remaining_count", 2, squadid, -1, pkg_ref.qty[ team ] );
					}
					return squadid;
					case "CODE":
						squadid = maps/_so_rts_catalog::spawn_package_code( pkg_ref, team, callback );
						if ( isDefined( squadid ) && squadid == -1 )
						{
							squadid = undefined;
						}
						if ( team == level.rts.player.team && pkg_ref.qty[ team ] >= 0 )
						{
							if ( pkg_ref.qty[ team ] > 0 )
							{
							}
							else
							{
							}
							luinotifyevent( &"rts_update_remaining_count", 2, squadid, -1, pkg_ref.qty[ team ] );
						}
						return squadid;
					}
				}
				else
				{
					return undefined;
				}
			}
			result = candeliverpkg( team, delivery, pkg_ref );
			if ( result == "ok" )
			{
				cb = undefined;
				type = "helo";
				switch( delivery )
				{
					case "FASTROPE_HELO":
						cb = ::maps/_so_rts_ai::spawn_ai_package_helo;
						break;
					case "FASTROPE_VTOL":
						cb = ::maps/_so_rts_ai::spawn_ai_package_helo;
						type = "vtol";
						break;
					case "CARGO_VTOL":
						cb = ::maps/_so_rts_ai::spawn_ai_package_cargo;
						type = "vtol";
						break;
					default:
/#
						assert( 0, "Unhandled case" );
#/
						break;
				}
				unit = allocatetransport( team, type, pkg_ref, cb, callback );
				if ( isDefined( unit ) )
				{
					if ( pkg_ref.qty[ team ] > 0 )
					{
						pkg_ref.qty[ team ]--;

					}
					if ( team == level.rts.player.team && pkg_ref.qty[ team ] >= 0 )
					{
						if ( pkg_ref.qty[ team ] > 0 )
						{
						}
						else luinotifyevent( &"rts_update_remaining_count", 2, unit.squadid, -1, pkg_ref.qty[ team ] );
					}
				}
			}
			if ( result == "ok" && isDefined( unit ) )
			{
				return unit.squadid;
			}
			return undefined;
		}
	}
}

spawn_package_code( pkg_ref, team, callback )
{
	if ( isDefined( level.rts.codespawncb ) )
	{
		squadid = [[ level.rts.codespawncb ]]( pkg_ref, team, callback );
/#
		assert( isDefined( squadid ), "Custom Code must return squadID" );
#/
		return squadid;
	}
	if ( isDefined( level.rts.switch_trans ) )
	{
		return -1;
	}
	_a1047 = pkg_ref.units;
	_k1047 = getFirstArrayKey( _a1047 );
	while ( isDefined( _k1047 ) )
	{
		unit = _a1047[ _k1047 ];
		switch( unit )
		{
			case "airstrike":
				thread maps/_so_rts_support::fire_missile();
				break;
			default:
/#
				assert( 0, "Unhandled case" );
#/
				break;
		}
		_k1047 = getNextArrayKey( _a1047, _k1047 );
	}
	return -1;
}

transportthink( unit )
{
	level endon( "rts_terminated" );
	flag_wait( "start_rts" );
	unit.state = 0;
	unit.refueltime = 0;
	unit.loadtime = 0;
	waittillframeend;
	while ( 1 )
	{
		switch( unit.state )
		{
			case 0:
				break;
			case 2:
				if ( getTime() > unit.refueltime )
				{
					unit.delivered_pkg = undefined;
					unit.state = 0;
					unit.refueltime = 0;
					unit.loadtime = 0;
				}
				else
				{
					if ( !is_true( level.rts.blockfastdelivery ) && unit.team != level.rts.player.team && level.rts.squads[ unit.squadid ].members.size == 0 )
					{
						unit.refueltime = getTime();
					}
				}
				break;
			case 3:
				if ( getTime() > unit.loadtime )
				{
					if ( unit.team == "allies" )
					{
						maps/_so_rts_event::trigger_event( "inc_" + unit.pkg_ref.ref );
					}
					unit.state = 1;
					if ( [[ unit.cb ]]( unit ) == -1 )
					{
						unit.delivered_pkg = undefined;
						unit.state = 0;
						unit.refueltime = 0;
						unit.loadtime = 0;
					}
					unit.flightannounce = getTime() + 4000;
				}
				else
				{
					if ( !is_true( level.rts.blockfastdelivery ) && unit.team != level.rts.player.team && level.rts.squads[ unit.squadid ].members.size == 0 )
					{
						unit.loadtime = getTime();
/#
						println( "@@@@@@@@@@@@@@@@@@@  Transport loadTime for [" + unit.pkg_ref.ref + "] zero'd out due to insufficient units (0)" );
#/
					}
				}
				break;
			case 1:
				if ( isDefined( unit.flightannounce ) && getTime() > unit.flightannounce && unit.team == "allies" )
				{
					unit.flightannounce = undefined;
				}
				break;
		}
		wait 0,25;
	}
}

getnumtransports( type, team, avail )
{
	count = 0;
	if ( type == "helo" )
	{
		transports = level.rts.transport.helo;
	}
	else
	{
		if ( type == "vtol" )
		{
			transports = level.rts.transport.vtol;
		}
	}
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team )
		{
			if ( isDefined( avail ) )
			{
				if ( transports[ i ].state == 0 )
				{
					count++;
				}
				i++;
				continue;
			}
			else
			{
				count++;
			}
		}
		i++;
	}
	return count;
}

units_delivered( team, squadid )
{
	if ( team == "allies" && isDefined( level.rts.squads[ squadid ].pkg_ref.hot_key_takeover ) )
	{
		luinotifyevent( &"rts_add_squad", 3, squadid, level.rts.squads[ squadid ].pkg_ref.idx, 0 );
		wait 0,05;
	}
	maps/_so_rts_squad::squad_unloaded( squadid );
	if ( team == level.rts.player.team )
	{
		level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_DELIVERY_ARRIVED" );
		level.rts.squads[ squadid ].selectable = 1;
	}
	else
	{
		if ( level.rts.enemy_notification < getTime() )
		{
			level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_ENEMY_ARRIVED" );
			level.rts.enemy_notification = getTime() + 6000;
		}
	}
	if ( isDefined( level.rts.activesquad ) )
	{
		package_highlightunits( level.rts.activesquad );
	}
}

unloadtransport( unit )
{
	unit.delivered_pkg = unit.pkg_ref;
	unit.cb = undefined;
	unit.param = undefined;
	unit.pkg_ref = undefined;
}

deallocatetransport( unit )
{
	unit.refueltime = getTime() + level.rts.transport_refuel_delay;
	unit.state = 2;
}

istransportavailable( team, type )
{
	availtransport = undefined;
	if ( type == "helo" )
	{
		transports = level.rts.transport.helo;
	}
	else if ( type == "vtol" )
	{
		transports = level.rts.transport.vtol;
	}
	else
	{
/#
		assert( 0, "bad type passed" );
#/
	}
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team && transports[ i ].state == 0 )
		{
			availtransport = transports[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	return isDefined( availtransport );
}

allocatetransport( team, type, pkg_ref, cb, paramcb )
{
	availtransport = undefined;
	if ( type == "helo" )
	{
		transports = level.rts.transport.helo;
	}
	else if ( type == "vtol" )
	{
		transports = level.rts.transport.vtol;
	}
	else
	{
/#
		assert( 0, "bad type passed" );
#/
	}
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team && transports[ i ].state == 0 )
		{
			availtransport = transports[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	if ( isDefined( availtransport ) )
	{
		availtransport.cb = cb;
		availtransport.param = paramcb;
		availtransport.pkg_ref = pkg_ref;
		availtransport.type = type;
		availtransport.state = 3;
		availtransport.loadtime = getTime() + pkg_ref.cost[ team ];
		availtransport.droptarget = get_package_drop_target( team );
		availtransport.squadid = maps/_so_rts_squad::createsquad( availtransport.droptarget, team, pkg_ref );
		if ( team == level.rts.player.team )
		{
			startloc = maps/_so_rts_support::get_transport_startloc( availtransport.droptarget, team, type );
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
/#
			assert( isDefined( unloadnode ), "no script_unload was found" );
#/
			timeto = ( gettimefromvehiclenodetonode( startloc, unloadnode ) * 1000 ) + pkg_ref.cost[ team ];
			timeback = ( gettimefromvehiclenodetonode( unloadnode, lastnode ) * 1000 ) + level.rts.transport_refuel_delay;
/#
			println( "**** transport - timeTo: (" + timeto + ")   timeBack: (" + timeback + ")" );
#/
			if ( team == "allies" && isDefined( pkg_ref.hot_key_takeover ) )
			{
			}
		}
	}
	return availtransport;
}

getnumberofpkgsbeingtransported( team, ref )
{
	transports = arraycombine( level.rts.transport.helo, level.rts.transport.vtol, 0, 0 );
	count = 0;
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team && transports[ i ].state != 0 && isDefined( transports[ i ].pkg_ref ) && transports[ i ].pkg_ref.ref == ref )
		{
			count++;
		}
		i++;
	}
	return count;
}

getnumberoftypebeingtransported( team, pkgtype )
{
	transports = arraycombine( level.rts.transport.helo, level.rts.transport.vtol, 0, 0 );
	count = 0;
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team && transports[ i ].state != 0 && isDefined( transports[ i ].pkg_ref ) && transports[ i ].pkg_ref.squad_type == pkgtype )
		{
			count++;
		}
		i++;
	}
	return count;
}

numtransportsinboundforteam( team )
{
	transports = arraycombine( level.rts.transport.helo, level.rts.transport.vtol, 0, 0 );
	count = 0;
	i = 0;
	while ( i < transports.size )
	{
		if ( transports[ i ].team == team && transports[ i ].state != 0 && isDefined( transports[ i ].pkg_ref ) )
		{
			count++;
		}
		i++;
	}
	return count;
}

pkg_ref_checkmaxspawn( pkg, team )
{
/#
	assert( isDefined( pkg ) );
#/
	ai_list = arraycombine( getaiarray( team ), getvehiclearray( team ), 0, 0 );
	count = 0;
	_a1367 = ai_list;
	_k1367 = getFirstArrayKey( _a1367 );
	while ( isDefined( _k1367 ) )
	{
		guy = _a1367[ _k1367 ];
		if ( isDefined( guy.squadid ) )
		{
			if ( level.rts.squads[ guy.squadid ].pkg_ref.ref == pkg.ref )
			{
				count++;
			}
		}
		_k1367 = getNextArrayKey( _a1367, _k1367 );
	}
	if ( team == "allies" )
	{
		max = pkg.max_friendly;
	}
	else
	{
		max = pkg.max_axis;
	}
	return count < max;
}
