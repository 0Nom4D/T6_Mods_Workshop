#include maps/_music;
#include maps/_utility;
#include common_scripts/utility;

main()
{
}

yemen_drone_control_tones( activate )
{
	if ( activate )
	{
		level thread play_drone_control_tones();
	}
	else
	{
		level notify( "stop_drone_control_tones" );
	}
}

play_drone_control_tones()
{
	level endon( "stop_drone_control_tones" );
	level waitfor_enough_drones();
	while ( 1 )
	{
		level thread play_drone_control_tones_single();
		wait randomintrange( 19, 39 );
	}
}

waitfor_enough_drones()
{
	level endon( "stop_drone_control_tones" );
	while ( 1 )
	{
		drones = get_vehicle_array( "veh_t6_drone_quad_rotor_sp", "model" );
		if ( !isDefined( drones ) || drones.size <= 3 )
		{
			wait 1;
			continue;
		}
		else
		{
		}
	}
}

play_drone_control_tones_single()
{
	drones = get_vehicle_array( "veh_t6_drone_quad_rotor_sp", "model" );
	if ( drones.size <= 3 )
	{
		return;
	}
	drone = drones[ randomintrange( 0, drones.size ) ];
	drone playsound( "veh_qr_tones_activate" );
	wait 4;
	drones = get_vehicle_array( "veh_t6_drone_quad_rotor_sp", "model" );
	if ( isDefined( drone ) )
	{
		arrayremovevalue( drones, drone );
	}
	array_thread( drones, ::play_drone_reply );
}

play_drone_reply()
{
	wait randomfloatrange( 0,1, 0,85 );
	if ( isDefined( self ) )
	{
		self playsound( "veh_qr_tones_activate_reply" );
	}
}
