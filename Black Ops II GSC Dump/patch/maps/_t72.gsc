#include maps/_vehicle;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
}

set_vehicle_anims( positions )
{
	return positions;
}

setanims()
{
	positions = [];
	i = 0;
	while ( i < 11 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	positions[ 0 ].getout_delete = 1;
	return positions;
}
