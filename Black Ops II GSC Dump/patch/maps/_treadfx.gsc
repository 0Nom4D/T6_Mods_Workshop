
loadtreadfx( vehicle )
{
	treadfx = getvehicletreadfxarray( vehicle.vehicletype );
	i = 0;
	while ( i < treadfx.size )
	{
		loadfx( treadfx[ i ] );
		i++;
	}
	lightfx = vehicle.lightfxnamearray;
	i = 0;
	while ( i < lightfx.size )
	{
		loadfx( lightfx[ i ] );
		i++;
	}
	if ( isDefined( vehicle.friendlylightfxname ) && vehicle.friendlylightfxname != "" )
	{
		loadfx( vehicle.friendlylightfxname );
	}
	if ( isDefined( vehicle.enemylightfxname ) && vehicle.enemylightfxname != "" )
	{
		loadfx( vehicle.enemylightfxname );
	}
	if ( vehicle.vehicletype == "boat_soct_player" )
	{
		vehicle.throttlefx = [];
		vehicle.throttlefx[ 0 ] = loadfx( "water/fx_vwater_soct_wake_accelerate_1" );
		vehicle.throttlefx[ 1 ] = loadfx( "water/fx_vwater_soct_wake_accelerate_2" );
		vehicle.throttlefx[ 2 ] = loadfx( "water/fx_vwater_soct_wake_accelerate_3" );
		vehicle.wakefx[ 0 ] = loadfx( "water/fx_vwater_soct_churn_0" );
		vehicle.wakefx[ 1 ] = loadfx( "water/fx_vwater_soct_churn_0" );
		vehicle.wakefx[ 2 ] = loadfx( "water/fx_vwater_soct_churn_1" );
		vehicle.wakefx[ 3 ] = loadfx( "water/fx_vwater_soct_churn_2" );
		vehicle.wakefx[ 4 ] = loadfx( "water/fx_vwater_soct_churn_3" );
	}
}
