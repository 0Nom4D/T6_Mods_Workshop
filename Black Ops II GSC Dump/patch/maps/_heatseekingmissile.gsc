#include common_scripts/utility;
#include maps/_utility;

init()
{
	game[ "locking_on_sound" ] = "wpn_sam_locking";
	game[ "locked_on_sound" ] = "wpn_f35_lockon";
	game[ "acquired_sound" ] = "wpn_sam_acquired";
	game[ "killshot_sound" ] = "wpn_sam_hit";
	game[ "tracking_sound" ] = "wpn_sam_tracking";
	level.minimum_sti_distance = 0;
	thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self clearirtarget();
		thread stingertoggleloop();
		self thread stingerfirednotify();
	}
}

clearirtarget()
{
	self notify( "stinger_irt_cleartarget" );
	self notify( "stop_lockon_sound" );
	self notify( "stop_locked_sound" );
	self.stingerlocksound = undefined;
	self.stingerlockstarttime = 0;
	self.stingerlockstarted = 0;
	self.stingerlockfinalized = 0;
	if ( isDefined( self.stingertarget ) )
	{
		self.stingertarget.no_lock = 0;
		self.stingertarget.locked_on = 0;
	}
	self.stingertarget = undefined;
	self weaponlockfree();
	self weaponlocktargettooclose( 0 );
	self weaponlocknoclearance( 0 );
	self stoplocalsound( game[ "locking_on_sound" ] );
	self stoplocalsound( game[ "locked_on_sound" ] );
}

stingerfirednotify()
{
	self endon( "disconnect" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "weapon_fired" );
		weap = self getcurrentweapon();
		while ( weap != "strela_sp" && weap != "stinger_sp" && weap != "afghanstinger_ff_sp" && weap != "fhj18_sp" && weap != "fhj18_dpad_sp" && weap != "smaw_sp" )
		{
			continue;
		}
		if ( isDefined( self.stingertarget ) )
		{
			self.stingertarget notify( "stinger_fired_at_me" );
		}
		self notify( "stinger_fired" );
	}
}

stingertoggleloop()
{
	self endon( "disconnect" );
	self endon( "death" );
	for ( ;; )
	{
		while ( !self playerstingerads() )
		{
			wait 0,05;
		}
		self thread stingerirtloop();
		while ( self playerstingerads() )
		{
			wait 0,05;
		}
		self notify( "stinger_IRT_off" );
		self clearirtarget();
	}
}

stingerirtloop()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "stinger_IRT_off" );
	locklength = self getlockonspeed();
	for ( ;; )
	{
		wait 0,05;
		if ( self.stingerlockfinalized )
		{
			passed = softsighttest();
			if ( !passed )
			{
				continue;
			}
			else if ( !isstillvalidtarget( self.stingertarget ) )
			{
				self clearirtarget();
				continue;
			}
			else self.stingertarget.no_lock = 0;
			self.stingertarget.locked_on = 1;
			thread looplocallocksound( game[ "locked_on_sound" ], 0,75 );
			self settargettooclose( self.stingertarget );
			self setnoclearance();
			continue;
		}
		else if ( self.stingerlockstarted )
		{
			if ( !isstillvalidtarget( self.stingertarget ) )
			{
				self clearirtarget();
				continue;
			}
			else self.stingertarget.no_lock = 1;
			self.stingertarget.locked_on = 0;
			passed = softsighttest();
			if ( !passed )
			{
				continue;
			}
			else timepassed = getTime() - self.stingerlockstarttime;
			if ( timepassed < locklength )
			{
				continue;
			}
			else /#
			assert( isDefined( self.stingertarget ) );
#/
			self notify( "stop_lockon_sound" );
			self.stingerlockfinalized = 1;
			self weaponlockfinalize( self.stingertarget );
			self settargettooclose( self.stingertarget );
			self setnoclearance();
			continue;
		}
		else besttarget = self getbeststingertarget();
		if ( !isDefined( besttarget ) )
		{
			continue;
		}
		else if ( !self locksighttest( besttarget ) )
		{
			continue;
		}
		else
		{
			self.stingertarget = besttarget;
			self.stingerlockstarttime = getTime();
			self.stingerlockstarted = 1;
			if ( self getcurrentweapon() == "afghanstinger_sp" )
			{
				screen_message_create( &"SCRIPT_AFGHANSTINGER_SWITCHTO_LOCKON" );
				self thread kill_lockon_screen_message( 3 );
				while ( self getcurrentweapon() != "afghanstinger_ff_sp" )
				{
					wait 0,05;
				}
				level thread screen_message_delete( 1 );
				self notify( "lockon_msg_killed" );
				return;
			}
			self thread looplocalseeksound( game[ "locking_on_sound" ], 0,6 );
		}
	}
}

kill_lockon_screen_message( n_time )
{
	self endon( "lockon_msg_killed" );
	count = 0;
	while ( ( n_time * 20 ) > count )
	{
		count++;
		wait 0,05;
	}
	screen_message_delete();
}

locksighttest( target )
{
	eyepos = self geteye();
	if ( !isDefined( target ) )
	{
		return 0;
	}
	passed = 0;
	passed = bullettracepassed( eyepos, target.origin, 0, target );
	if ( !passed )
	{
		return 0;
	}
	front = target getpointinbounds( 1, 0, 0 );
	bullettracepassed( eyepos, front, 0, target );
	if ( !passed )
	{
		return 0;
	}
	back = target getpointinbounds( -1, 0, 0 );
	passed = bullettracepassed( eyepos, back, 0, target );
	if ( !passed )
	{
		return 0;
	}
	return 1;
}

softsighttest()
{
	if ( self locksighttest( self.stingertarget ) )
	{
		self.stingerlostsightlinetime = 0;
		return 1;
	}
	if ( self.stingerlostsightlinetime == 0 )
	{
		self.stingerlostsightlinetime = getTime();
	}
	timepassed = getTime() - self.stingerlostsightlinetime;
	if ( timepassed >= 500 )
	{
		self clearirtarget();
		return 0;
	}
	return 1;
}

getbeststingertarget()
{
	targetsall = target_getarray();
	besttarget = undefined;
	bestdist = 100000;
	idx = 0;
	while ( idx < targetsall.size )
	{
		dist = insidestingerreticlenolock( targetsall[ idx ] );
		if ( dist && dist < bestdist )
		{
			besttarget = targetsall[ idx ];
		}
		idx++;
	}
	return besttarget;
}

insidestingerreticlenolock( target )
{
	radius = self getlockonradius();
	return target_isincircle( target, self, 65, radius );
}

insidestingerreticlelocked( target )
{
	radius = self getlockonradius();
	return target_isincircle( target, self, 65, radius );
}

isstillvalidtarget( ent )
{
	if ( !isDefined( ent ) )
	{
		return 0;
	}
	if ( !target_istarget( ent ) )
	{
		return 0;
	}
	if ( !insidestingerreticlelocked( ent ) )
	{
		return 0;
	}
	return 1;
}

playerstingerads()
{
	weap = self getcurrentweapon();
	if ( weap != "strela_sp" && weap != "fhj18_sp" && weap != "fhj18_dpad_sp" && weap != "stinger_sp" && weap != "afghanstinger_ff_sp" && weap != "afghanstinger_sp" && weap != "smaw_sp" )
	{
		return 0;
	}
	if ( self playerads() == 1 )
	{
		return 1;
	}
	return 0;
}

setnoclearance()
{
	color_passed = ( 1, 0, 1 );
	color_failed = ( 1, 0, 1 );
	checks = [];
	checks[ 0 ] = vectorScale( ( 1, 0, 1 ), 80 );
	checks[ 1 ] = ( -40, 0, 120 );
	checks[ 2 ] = ( 40, 0, 120 );
	checks[ 3 ] = vectorScale( ( 1, 0, 1 ), 40 );
	checks[ 4 ] = vectorScale( ( 1, 0, 1 ), 40 );
	debug = 0;
/#
	if ( getDvar( #"64296AD0" ) == "1" )
	{
		debug = 1;
#/
	}
	playerangles = self getplayerangles();
	forward = anglesToForward( playerangles );
	right = anglesToRight( playerangles );
	up = anglesToUp( playerangles );
	origin = ( self.origin + ( 0, 0, 60 ) ) + ( right * 10 );
	obstructed = 0;
	idx = 0;
	while ( idx < checks.size )
	{
		endpoint = ( ( origin + ( forward * 400 ) ) + ( up * checks[ idx ][ 2 ] ) ) + ( right * checks[ idx ][ 0 ] );
		trace = bullettrace( origin, endpoint, 0, undefined );
		if ( trace[ "fraction" ] < 1 )
		{
			obstructed = 1;
			if ( debug )
			{
/#
				line( origin, trace[ "position" ], color_failed, 1 );
#/
			}
			else
			{
			}
		}
		else /#
		if ( debug )
		{
			line( origin, trace[ "position" ], color_passed, 1 );
#/
		}
		idx++;
	}
	self weaponlocknoclearance( obstructed );
	self.noclearance = obstructed;
}

settargettooclose( ent )
{
	if ( !isDefined( ent ) )
	{
		return 0;
	}
	dist = distance2d( self.origin, ent.origin );
	if ( dist < level.minimum_sti_distance )
	{
		self.targettoclose = 1;
		self weaponlocktargettooclose( 1 );
	}
	else
	{
		self.targettoclose = 0;
		self weaponlocktargettooclose( 0 );
	}
}

looplocalseeksound( alias, interval )
{
	self endon( "stop_lockon_sound" );
	self endon( "disconnect" );
	self endon( "death" );
	for ( ;; )
	{
		self playlocalsound( alias );
		wait interval;
	}
}

looplocallocksound( alias, interval )
{
	if ( isDefined( self.stingerlocksound ) )
	{
		return;
	}
	self.stingerlocksound = 1;
	player = get_players()[ 0 ];
	player playloopsound( alias, 0,05 );
	self waittill_any( "stop_locked_sound", "disconnect", "death" );
	player stoploopsound( 0,05 );
	self.stingerlocksound = undefined;
}

setminimumstidistance( dist )
{
	level.minimum_sti_distance = dist;
}
