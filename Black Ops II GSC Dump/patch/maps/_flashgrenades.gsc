
main()
{
	precacheshellshock( "flashbang" );
}

startmonitoringflash()
{
	self thread monitorflash();
}

flashrumbleloop( duration )
{
	self endon( "stop_monitoring_flash" );
	self endon( "flash_rumble_loop" );
	self notify( "flash_rumble_loop" );
	goaltime = getTime() + ( duration * 1000 );
	while ( getTime() < goaltime )
	{
		self playrumbleonentity( "damage_heavy" );
		wait 0,05;
	}
}

monitorflash()
{
	self endon( "disconnect" );
	self.flashendtime = 0;
	while ( 1 )
	{
		self waittill( "flashbang", amount_distance, amount_angle, attacker );
		while ( !isalive( self ) )
		{
			continue;
		}
		if ( amount_angle < 0,5 )
		{
			amount_angle = 0,5;
		}
		else
		{
			if ( amount_angle > 0,8 )
			{
				amount_angle = 1;
			}
		}
		duration = amount_distance * amount_angle * 6;
		while ( duration < 0,25 )
		{
			continue;
		}
		rumbleduration = undefined;
		if ( duration > 2 )
		{
			rumbleduration = 0,75;
		}
		else
		{
			rumbleduration = 0,25;
		}
		self thread applyflash( duration, rumbleduration );
	}
}

applyflash( duration, rumbleduration )
{
	if ( !isDefined( self.flashduration ) || duration > self.flashduration )
	{
		self.flashduration = duration;
	}
	if ( !isDefined( self.flashrumbleduration ) || rumbleduration > self.flashrumbleduration )
	{
		self.flashrumbleduration = rumbleduration;
	}
	wait 0,05;
	if ( isDefined( self.flashduration ) )
	{
		self shellshock( "flashbang", self.flashduration );
		self.flashendtime = getTime() + ( self.flashduration * 1000 );
	}
	if ( isDefined( self.flashrumbleduration ) )
	{
		self thread flashrumbleloop( self.flashrumbleduration );
	}
	self.flashduration = undefined;
	self.flashrumbleduration = undefined;
}

isflashbanged()
{
	if ( isDefined( self.flashendtime ) )
	{
		return getTime() < self.flashendtime;
	}
}
