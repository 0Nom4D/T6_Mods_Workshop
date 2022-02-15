#include animscripts/utility;
#include maps/_vehicle_aianim;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
	build_aianims( ::setanims, ::set_vehicle_anims );
}

set_vehicle_anims( positions )
{
	return positions;
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
	positions[ 0 ].idle[ 0 ] = %ai_crew_motorcycle_ride;
	positions[ 0 ].idle[ 1 ] = %ai_crew_motorcycle_ride_lookleft;
	positions[ 0 ].idle[ 2 ] = %ai_crew_motorcycle_ride_lookright;
	positions[ 0 ].idleoccurrence[ 0 ] = 1000;
	positions[ 0 ].idleoccurrence[ 1 ] = 400;
	positions[ 0 ].idleoccurrence[ 2 ] = 200;
	return positions;
}
