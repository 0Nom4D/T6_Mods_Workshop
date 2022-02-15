#include maps/_vehicle;

#using_animtree( "generic_human" );

main()
{
	build_aianims( ::setanims );
	build_unload_groups( ::unload_groups );
}

setanims()
{
	positions = [];
	i = 0;
	while ( i < 1 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	positions[ 0 ].sittag = "tag_driver";
	positions[ 0 ].idle = %crew_zpu4_idle;
	positions[ 0 ].death = %crew_zpu4_death;
	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "all" ] = [];
	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ "default" ] = unload_groups[ "all" ];
	return unload_groups;
}
