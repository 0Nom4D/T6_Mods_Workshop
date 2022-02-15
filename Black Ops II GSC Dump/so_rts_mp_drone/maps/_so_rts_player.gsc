#include maps/_so_rts_squad;
#include maps/_so_rts_catalog;
#include maps/_so_rts_support;
#include maps/_utility;
#include common_scripts/utility;

friendly_player()
{
	level endon( "rts_terminated" );
	flag_wait( "start_rts" );
	wait 1;
	level thread friendly_squad_spawner();
	while ( !flag( "rts_game_over" ) )
	{
		packages_avail = maps/_so_rts_catalog::package_generateavailable( "allies" );
		i = 0;
		while ( i < packages_avail.size )
		{
			ref = packages_avail[ i ].ref;
			total = get_number_in_queue( ref );
			squad = maps/_so_rts_squad::getsquadbypkg( ref, "allies" );
			if ( isDefined( squad ) )
			{
				total += squad.members.size;
			}
			total += maps/_so_rts_catalog::getnumberofpkgsbeingtransported( "allies", ref ) * packages_avail[ i ].numunits;
			if ( isDefined( level.rts.player.ally ) && level.rts.player.ally.pkg_ref.ref == ref )
			{
				total += 1;
			}
			if ( total >= packages_avail[ i ].max_friendly )
			{
				i++;
				continue;
			}
			else
			{
				if ( total <= packages_avail[ i ].min_friendly )
				{
					level.rts.friendly_squad_queue[ level.rts.friendly_squad_queue.size ] = ref;
/#
					println( "@@@@@@@@ ALLIES (" + getTime() + ") ORDERING:" + ref + " CURRENT:" + total + " MAX:" + packages_avail[ i ].max_friendly + " MIN:" + packages_avail[ i ].min_friendly );
#/
				}
			}
			i++;
		}
		wait 1;
	}
}

friendly_squad_spawner()
{
	level endon( "rts_terminated" );
	level.rts.friendly_squad_queue = [];
	while ( !flag( "rts_game_over" ) )
	{
		time = 2;
		i = 0;
		while ( i < level.rts.friendly_squad_queue.size )
		{
			squadref = level.rts.friendly_squad_queue[ i ];
			squadid = maps/_so_rts_catalog::spawn_package( squadref, "allies", 0, ::order_new_squad );
			if ( isDefined( squadid ) )
			{
				level notify( "friendly_unit_spawned_" + squadref );
				arrayremoveindex( level.rts.friendly_squad_queue, i );
				time = 0,1;
				break;
			}
			else
			{
				i++;
			}
		}
		wait time;
	}
}

order_new_squad( squadid )
{
	if ( isDefined( level.rts.order_new_allysquadcb ) )
	{
		[[ level.rts.order_new_allysquadcb ]]( squadid );
	}
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
	while ( i < level.rts.friendly_squad_queue.size )
	{
		if ( level.rts.friendly_squad_queue[ i ] == ref )
		{
			count += pkg_ref.numunits;
		}
		i++;
	}
	return count;
}
