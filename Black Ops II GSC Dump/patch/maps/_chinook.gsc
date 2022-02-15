#include maps/_vehicle;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
	self.script_badplace = 0;
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::unload_groups );
}

set_vehicle_anims( positions )
{
	return positions;
}

setanims()
{
	positions = [];
	i = 0;
	while ( i < 9 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "all" ] = [];
	return unload_groups;
}
