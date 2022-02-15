#include maps/_utility_code;
#include maps/_so_rts_support;
#include maps/_so_rts_event;
#include maps/_music;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

init()
{
	level.rts.events = [];
	level.rts.event_queue = [];
	level.rts.events_dialogchannellock = undefined;
	level.rts.voxids = [];
	level.rts.voxids[ "allies" ] = [];
	flag_init( "rts_event_ready" );
	types = [];
	types[ 0 ] = "dialog";
	types[ 1 ] = "sfx";
	types[ 2 ] = "music";
	types[ 3 ] = "fx";
	types[ 4 ] = "callback";
	types[ 5 ] = "multi";
	level.rts.event_types = types;
	event_populate( "sp/so_rts/rts.csv" );
	event_populate( level.rts_def_table );
	maps/_so_rts_event::register_event( "friendly_select", maps/_so_rts_event::make_event_param( 4, ::maps/_so_rts_support::get_selection_alias_from_targetname ), 850 );
	level thread event_process();
}

lookup_value( ref, idx, column_index, table )
{
/#
	assert( isDefined( idx ) );
#/
	return tablelookup( table, 0, idx, column_index );
}

get_event_ref_by_index( idx, table )
{
	return tablelookup( table, 0, idx, 1 );
}

event_populate( table )
{
	types = [];
	types[ "dialog" ] = 0;
	types[ "sfx" ] = 1;
	types[ "music" ] = 2;
	types[ "fx" ] = 3;
	types[ "multi" ] = 5;
	i = 500;
	while ( i <= 800 )
	{
		ref = get_event_ref_by_index( i, table );
		if ( !isDefined( ref ) || ref == "" )
		{
			i++;
			continue;
		}
		else
		{
			type = lookup_value( ref, i, 2, table );
			param1 = lookup_value( ref, i, 3, table );
			param2 = lookup_value( ref, i, 4, table );
			param3 = lookup_value( ref, i, 5, table );
			cooldown = float( lookup_value( ref, i, 6, table ) );
			latency = float( lookup_value( ref, i, 7, table ) );
			triggernotify = lookup_value( ref, i, 8, table );
			maxplays = int( lookup_value( ref, i, 9, table ) );
			priority = int( lookup_value( ref, i, 10, table ) );
			daisy = lookup_value( ref, i, 11, table );
			unique = int( lookup_value( ref, i, 12, table ) );
/#
			assert( isDefined( types[ type ] ), "Illegal type parsed in event table:" + type );
#/
			type = types[ type ];
			if ( param1 == "" )
			{
				param1 = undefined;
			}
			if ( param2 == "" )
			{
				param2 = undefined;
			}
			if ( param3 == "" )
			{
				param3 = undefined;
			}
			if ( cooldown == 0 )
			{
				cooldown = undefined;
			}
			if ( latency == 0 )
			{
				latency = undefined;
			}
			if ( triggernotify == "" )
			{
				triggernotify = undefined;
			}
			if ( maxplays == 0 )
			{
				maxplays = undefined;
			}
			if ( daisy == "" )
			{
				daisy = undefined;
			}
			if ( type == 5 )
			{
/#
				assert( isDefined( param1 ), "param1 must contain the list of event refs to trigger seperated by a space" );
#/
			}
			register_event( ref, make_event_param( type, param1, param2, param3 ), cooldown, latency, triggernotify, maxplays, priority, daisy, unique );
		}
		i++;
	}
}

event_clearall( type )
{
	if ( !isDefined( type ) )
	{
		level.rts.event_queue = [];
	}
	else
	{
		unprocessed = [];
		i = 0;
		while ( i < level.rts.event_queue.size )
		{
			event = level.rts.event_queue[ i ];
			if ( event.data.type != type )
			{
				unprocessed[ unprocessed.size ] = event;
			}
			i++;
		}
		level.rts.event_queue = unprocessed;
	}
}

event_clearqueuebyref( ref )
{
	unprocessed = [];
	i = 0;
	while ( i < level.rts.event_queue.size )
	{
		event = level.rts.event_queue[ i ];
		if ( event.def.ref != ref )
		{
			unprocessed[ unprocessed.size ] = event;
		}
		i++;
	}
	level.rts.event_queue = unprocessed;
}

event_process()
{
	while ( 1 )
	{
		processed = [];
		unprocessed = [];
		while ( level.rts.event_queue.size > 0 )
		{
			time = getTime();
			i = 0;
			while ( i < level.rts.event_queue.size )
			{
				event = level.rts.event_queue[ i ];
				if ( isDefined( event.def.latency ) )
				{
					if ( time > ( event.timestamp + event.def.latency ) )
					{
						event.executedat = time;
						event.expired = 1;
						processed[ processed.size ] = event;
						i++;
						continue;
					}
				}
				else if ( isDefined( event.def.lastexecutedat ) && isDefined( event.def.cooldown ) )
				{
					if ( time < ( event.def.lastexecutedat + event.def.cooldown ) )
					{
						i++;
						continue;
					}
				}
				else result = event_trigger( event );
/#
				assert( isDefined( result ), "event callbacks need to return result" );
#/
				if ( result )
				{
					event.executedat = time;
					processed[ processed.size ] = event;
					i++;
					continue;
				}
				i++;
			}
			i = 0;
			while ( i < level.rts.event_queue.size )
			{
				if ( !isDefined( level.rts.event_queue[ i ].executedat ) )
				{
					unprocessed[ unprocessed.size ] = level.rts.event_queue[ i ];
				}
				i++;
			}
			level.rts.event_queue = unprocessed;
			i = 0;
			while ( i < processed.size )
			{
				event = processed[ i ];
/#
				assert( isDefined( event.executedat ) );
#/
				level notify( "rts_event_" + event.def.ref );
/#
				if ( isDefined( event.data.param1 ) )
				{
				}
				else
				{
				}
				param = "";
				if ( isDefined( event.expired ) && event.expired )
				{
					param = "n/a";
				}
				if ( level.rts.event_types[ event.data.type ] == "callback" )
				{
					param = "n/a";
				}
				if ( level.rts.event_types[ event.data.type ] == "sfx" || level.rts.event_types[ event.data.type ] == "fx" )
				{
					tabtype = "\t\t\t";
				}
				else
				{
					tabtype = "\t\t";
				}
				if ( isDefined( event.expired ) && event.expired )
				{
				}
				else
				{
				}
				if ( isDefined( event.dynamic_alias ) )
				{
				}
				else
				{
				}
				println( event.dynamic_alias + param, "EXPIRED: " + "processed: " + event.executedat + "\t\tType: " + level.rts.event_types[ event.data.type ] + tabtype + "(" + event.def.priority + ")Event (" + event.def.ref + ")\t\tTriggered: ", "[Events in queue: " + level.rts.event_queue.size + "]\t" );
#/
				event.def.lastexecutedat = event.executedat;
				i++;
			}
		}
		wait 0,05;
	}
}

make_event_param( type, param1, param2, param3 )
{
	dataparam = spawnstruct();
	dataparam.type = type;
	dataparam.param1 = param1;
	dataparam.param2 = param2;
	dataparam.param3 = param3;
	return dataparam;
}

register_event( ref, dataparam, cooldown, latency, trignotify, onetimeonly, priority, daisy, unique )
{
	if ( !isDefined( priority ) )
	{
		priority = 0;
	}
	if ( !isDefined( unique ) )
	{
		unique = 0;
	}
/#
	assert( !isDefined( level.rts.events[ ref ] ), "Event with this ref name already exists" );
#/
	event = spawnstruct();
	event.ref = ref;
	event.cooldown = cooldown;
	event.latency = latency;
	event.data = dataparam;
	event.onnotify = trignotify;
	event.onetimeonly = onetimeonly;
	event.priority = priority;
	event.count = 0;
	event.daisy = daisy;
	event.unique = unique;
	if ( isDefined( event.onnotify ) )
	{
		level thread event_listener( event );
	}
	if ( isDefined( event.latency ) && event.latency <= 0 )
	{
		event.latency = 100;
	}
	level.rts.events[ ref ] = event;
}

event_listener( event )
{
	level endon( "rts_event_" + event.ref );
	level waittill( event.onnotify );
	add_event_to_trigger( event );
	if ( isDefined( event.onetimeonly ) && event.onetimeonly )
	{
		return;
	}
	else
	{
		level thread event_listener( event );
	}
}

priorityeventcompfunc( e1, e2, param )
{
	return e1.def.priority >= e2.def.priority;
}

add_event_to_trigger( event_ref, param )
{
	timestamp = getTime();
	if ( isDefined( event_ref.lastexecutedat ) && isDefined( event_ref.cooldown ) )
	{
		if ( timestamp < ( event_ref.lastexecutedat + event_ref.cooldown ) )
		{
			return 0;
		}
	}
	if ( isDefined( event_ref.onetimeonly ) && event_ref.onetimeonly && event_ref.count > 0 )
	{
		return 0;
	}
	while ( event_ref.unique )
	{
		_a333 = level.rts.event_queue;
		_k333 = getFirstArrayKey( _a333 );
		while ( isDefined( _k333 ) )
		{
			ev = _a333[ _k333 ];
			if ( ev.def.ref == event_ref.ref )
			{
				return 0;
			}
			_k333 = getNextArrayKey( _a333, _k333 );
		}
	}
	if ( event_ref.data.type == 5 )
	{
		refs = strtok( event_ref.data.param1, " " );
		i = 0;
		while ( i < refs.size )
		{
			trigger_event( refs[ i ], param );
			i++;
		}
		return 1;
	}
	event = spawnstruct();
	event.def = event_ref;
	event.data = event_ref.data;
	event.timestamp = timestamp;
	event.dparam = param;
	event_ref.count++;
	level.rts.event_queue[ level.rts.event_queue.size ] = event;
	if ( level.rts.event_queue.size > 1 )
	{
		level.rts.event_queue = maps/_utility_code::mergesort( level.rts.event_queue, ::priorityeventcompfunc );
	}
	if ( isDefined( event_ref.daisy ) )
	{
		trigger_event( event_ref.daisy, param );
	}
/#
#/
	return 1;
}

trigger_event( ref, param )
{
	if ( !flag( "rts_event_ready" ) )
	{
		return 0;
	}
	if ( isDefined( level.rts.events[ ref ] ) )
	{
		return add_event_to_trigger( level.rts.events[ ref ], param );
	}
	else
	{
/#
		println( "@@@@@ (" + getTime() + ") WARNING: Event triggered but no reference was found (" + ref + ")" );
#/
	}
	return 0;
}

event_notesendondeath( note )
{
	num = self getentitynumber();
	level endon( note + "done" );
	self waittill( "death" );
	if ( isDefined( level.rts.events_dialogchannellock ) && level.rts.events_dialogchannellock == num )
	{
		level.rts.events_dialogchannellock = undefined;
/#
		println( "[Event ** ABORT **]\t\t\t\t\t\tUnlocking channel due to entity death(" + num + "," + note + ")" );
#/
	}
	level notify( note + "done" );
}

event_playsound( alias, note, guy )
{
	level.rts.events_dialogchannellock = guy getentitynumber();
/#
#/
	guy thread event_notesendondeath( note );
	guy playsound( alias, note );
	guy waittill( note );
	level.rts.events_dialogchannellock = undefined;
	level notify( note + "_done" );
}

event_trigger( event )
{
	time = getTime();
	switch( event.data.type )
	{
		case 0:
			if ( isDefined( level.rts.events_dialogchannellock ) )
			{
				return 0;
			}
			alias = event.data.param1;
/#
			assert( isDefined( alias ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
			if ( isDefined( event.data.param2 ) )
			{
				if ( event.data.param2 == "player" )
				{
					target = level.rts.player;
				}
				else
				{
					target = getent( event.data.param2, "targetname" );
				}
			}
			if ( isDefined( target ) || target == level.rts.player && isDefined( target.rts_unloaded ) )
			{
				thread event_playsound( alias, event.def.ref, target );
			}
			else
			{
				target = event.data.param3;
/#
				if ( target != "allies" && target != "axis" )
				{
					assert( target == "dparam", "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
				}
#/
				if ( target == "dparam" )
				{
/#
					assert( isDefined( event.dparam ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
				}
				guys = getvalidvoxlist( target, event.dparam );
				if ( guys.size == 0 )
				{
					return 0;
				}
				guy = guys[ randomint( guys.size ) ];
				if ( !isDefined( guy ) )
				{
					return 0;
				}
				if ( issubstr( alias, "#%#" ) )
				{
					tokens = strtok( alias, "#%#" );
					alias = tokens[ 0 ] + guy.voxid + tokens[ 1 ];
				}
				event.dynamic_alias = alias;
				thread event_playsound( alias, event.def.ref, guy );
			}
			return 1;
		case 1:
			alias = event.data.param1;
/#
			assert( isDefined( alias ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
			if ( isDefined( event.data.param2 ) )
			{
				if ( event.data.param2 == "player" )
				{
					position = level.rts.player.origin;
				}
				else
				{
					target = getent( event.data.param2, "targetname" );
/#
					assert( isDefined( target ), "entity not found" );
#/
					if ( isDefined( target ) )
					{
						position = target.origin;
					}
				}
			}
			if ( isDefined( event.dparam ) )
			{
				entity = event.dparam;
			}
			if ( isDefined( entity ) )
			{
				entity playsound( alias );
			}
			else if ( isDefined( position ) )
			{
				playsoundatposition( alias, position );
			}
			else
			{
				level.rts.player playlocalsound( alias );
			}
			return 1;
		case 2:
			alias = event.data.param1;
/#
			assert( isDefined( alias ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
			setmusicstate( alias );
			return 1;
		case 3:
			alias = event.data.param1;
/#
			assert( isDefined( alias ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
/#
			assert( isDefined( level._effect[ alias ] ), "Undefined FX alias passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
			tag = event.data.param3;
			if ( isDefined( tag ) )
			{
				if ( isDefined( event.dparam ) )
				{
					entity = event.dparam;
				}
				else
				{
					if ( isDefined( event.data.param2 ) )
					{
						entity = getent( event.data.param2, "targetname" );
					}
				}
/#
				assert( isDefined( entity ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
				playfxontag( level._effect[ alias ], entity, tag );
			}
			else
			{
				if ( isDefined( event.dparam ) )
				{
					position = event.dparam;
				}
				else if ( isDefined( event.data.param2 ) )
				{
					if ( event.data.param2 == "player" )
					{
						position = level.rts.player.origin;
					}
					else
					{
						entity = getent( event.data.param2, "targetname" );
/#
						assert( isDefined( entity ), "entity not found" );
#/
						position = entity.origin;
					}
				}
/#
				assert( isDefined( position ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
				playfx( level._effect[ alias ], position );
			}
			return 1;
		case 4:
/#
			assert( isDefined( event.data.param1 ), "Unexpected data passed to event_trigger Type:" + event.data.type + " Ref:" + event.def.ref );
#/
			return [[ event.data.param1 ]]( event.dparam, event.data.param2, event.data.param3 );
	}
/#
	assert( 0, "Unhandled event type" );
#/
	return 1;
}

allocvoxid( param )
{
	if ( !isDefined( level.rts.voxids[ self.team ] ) )
	{
		return;
	}
	if ( isDefined( level.rts.customvoxallocid ) )
	{
		return [[ level.rts.customvoxallocid ]]( param );
	}
	i = 0;
	while ( i <= 5 )
	{
		voxid = "so" + i;
		if ( !isDefined( level.rts.voxids[ "allies" ][ voxid ] ) )
		{
			level.rts.voxids[ "allies" ][ voxid ] = self;
			self.voxid = voxid;
			self thread voxdeallocatewatch();
			return;
		}
		i++;
	}
}

voxdeallocatewatch()
{
	team = self.team;
	voxid = self.voxid;
	self waittill( "death" );
}

getvalidvoxlist( team, dparam )
{
	if ( isDefined( level.rts.customvoxlist ) )
	{
		return [[ level.rts.customvoxlist ]]( team, dparam );
	}
	guys = [];
	i = 0;
	while ( i <= 5 )
	{
		voxid = "so" + i;
		if ( isDefined( level.rts.voxids[ "allies" ][ voxid ] ) )
		{
			guys[ guys.size ] = level.rts.voxids[ "allies" ][ voxid ];
		}
		i++;
	}
	return guys;
}
