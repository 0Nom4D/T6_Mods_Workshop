#include common_scripts/utility;
#include animscripts/shared;
#include animscripts/combat_utility;
#include animscripts/utility;

#using_animtree( "generic_human" );

shouldcqb()
{
	if ( is_true( self.cqb ) && self animscripts/utility::weaponanims() != "pistol" && !isDefined( self.grenade ) )
	{
		return !usingpistol();
	}
}

setupcqbpointsofinterest()
{
	level.cqbpointsofinterest = [];
	level.cqbsetupcomplete = 0;
	while ( !isDefined( level.struct_class_names ) )
	{
		wait 0,05;
	}
	level.cqbsetupcomplete = 1;
	pointents = getentarray( "cqb_point_of_interest", "targetname" );
	pointstructs = getstructarray( "cqb_point_of_interest", "targetname" );
	points = arraycombine( pointents, pointstructs, 1, 0 );
	i = 0;
	while ( i < points.size )
	{
		level.cqbpointsofinterest[ i ] = points[ i ].origin;
		if ( isDefined( points[ i ].classname ) || points[ i ].classname == "script_origin" && points[ i ].classname == "script_model" )
		{
			points[ i ] delete();
		}
		i++;
	}
}

findcqbpointsofinterest()
{
	if ( isDefined( anim.findingcqbpointsofinterest ) )
	{
		return;
	}
	anim.findingcqbpointsofinterest = 1;
	while ( !isDefined( level.cqbsetupcomplete ) || !level.cqbsetupcomplete )
	{
		wait 0,05;
	}
	if ( !level.cqbpointsofinterest.size )
	{
		return;
	}
	while ( 1 )
	{
		ai = getaiarray();
		waited = 0;
		i = 0;
		while ( i < ai.size )
		{
			if ( isalive( ai[ i ] ) && is_true( ai[ i ].cqb ) && ai[ i ] animscripts/utility::weaponanims() != "pistol" )
			{
				if ( isDefined( ai[ i ].avoidcqbpointsofinterests ) && ai[ i ].avoidcqbpointsofinterests )
				{
					i++;
					continue;
				}
				else
				{
					moving = ai[ i ].a.movement != "stop";
					shootatpos = ai[ i ] getshootatpos();
					lookaheadpoint = shootatpos;
					forward = anglesToForward( ai[ i ].angles );
					if ( moving )
					{
						trace = bullettrace( lookaheadpoint, lookaheadpoint + ( forward * 128 ), 0, undefined );
						lookaheadpoint = trace[ "position" ];
					}
					best = -1;
					bestdist = 1048576;
					j = 0;
					while ( j < level.cqbpointsofinterest.size )
					{
						point = level.cqbpointsofinterest[ j ];
						dist = distancesquared( point, lookaheadpoint );
						if ( dist < bestdist )
						{
							if ( moving )
							{
								if ( distancesquared( point, shootatpos ) < 4096 )
								{
									j++;
									continue;
								}
								else dot = vectordot( vectornormalize( point - shootatpos ), forward );
								if ( dot < 0,643 || dot > 0,966 )
								{
									j++;
									continue;
								}
								else
								{
								}
								else if ( dist < 2500 )
								{
									j++;
									continue;
								}
								else if ( !sighttracepassed( lookaheadpoint, point, 0, undefined ) )
								{
									j++;
									continue;
								}
								else
								{
									bestdist = dist;
									best = j;
								}
							}
						}
						j++;
					}
					if ( best < 0 )
					{
						ai[ i ].cqb_point_of_interest = undefined;
					}
					else
					{
						ai[ i ].cqb_point_of_interest = level.cqbpointsofinterest[ best ];
					}
					wait 0,05;
					waited = 1;
				}
			}
			i++;
		}
		if ( !waited )
		{
			wait 0,25;
		}
	}
}

cqbdebug()
{
/#
	self notify( "end_cqb_debug" );
	self endon( "end_cqb_debug" );
	self endon( "death" );
	if ( getDvar( "scr_cqbdebug" ) == "" )
	{
		setdvar( "scr_cqbdebug", "off" );
	}
	level thread cqbdebugglobal();
	while ( 1 )
	{
		while ( getdebugdvar( "scr_cqbdebug" ) == "on" || getdebugdvarint( "scr_cqbdebug" ) == self getentnum() )
		{
			if ( isDefined( self.shootpos ) )
			{
				line( self getshootatpos(), self.shootpos, ( 1, 1, 1 ) );
				print3d( self.shootpos, "shootPos", ( 1, 1, 1 ), 1, 0,5 );
				record3dtext( "cqb_target", self.shootpos + vectorScale( ( 1, 1, 1 ), 20 ), ( 0,5, 1, 0,5 ), "Animscript" );
			}
			else if ( isDefined( self.cqb_target ) )
			{
				line( self getshootatpos(), self.cqb_target.origin, ( 0,5, 1, 0,5 ) );
				print3d( self.cqb_target.origin, "cqb_target", ( 0,5, 1, 0,5 ), 1, 0,5 );
				record3dtext( "cqb_target", self.cqb_target.origin + vectorScale( ( 1, 1, 1 ), 70 ), ( 0,5, 1, 0,5 ), "Animscript" );
			}
			else
			{
				moving = self.a.movement != "stop";
				forward = anglesToForward( self.angles );
				shootatpos = self getshootatpos();
				lookaheadpoint = shootatpos;
				if ( moving )
				{
					lookaheadpoint += forward * 128;
					line( shootatpos, lookaheadpoint, ( 0,7, 0,5, 0,5 ) );
					right = anglesToRight( self.angles );
					leftscanarea = shootatpos + ( ( ( forward * 0,643 ) - right ) * 64 );
					rightscanarea = shootatpos + ( ( ( forward * 0,643 ) + right ) * 64 );
					line( shootatpos, leftscanarea, vectorScale( ( 1, 1, 1 ), 0,5 ), 0,7 );
					recordline( shootatpos, leftscanarea, vectorScale( ( 1, 1, 1 ), 0,5 ), "Animscript", self );
					line( shootatpos, rightscanarea, vectorScale( ( 1, 1, 1 ), 0,5 ), 0,7 );
					recordline( shootatpos, rightscanarea, vectorScale( ( 1, 1, 1 ), 0,5 ), "Animscript", self );
				}
				if ( isDefined( self.cqb_point_of_interest ) )
				{
					line( lookaheadpoint, self.cqb_point_of_interest, ( 1, 0,5, 0,5 ) );
					print3d( self.cqb_point_of_interest, "cqb_point_of_interest", ( 1, 0,5, 0,5 ), 1, 0,5 );
					record3dtext( "cqb_point_of_interest", self.cqb_point_of_interest, ( 1, 0,5, 0,5 ), "Animscript" );
				}
			}
			wait 0,05;
		}
		wait 1;
#/
	}
}

cqbdebugglobal()
{
/#
	if ( isDefined( level.cqbdebugglobal ) )
	{
		return;
	}
	level.cqbdebugglobal = 1;
	while ( 1 )
	{
		while ( getdebugdvar( "scr_cqbdebug" ) != "on" )
		{
			wait 1;
		}
		i = 0;
		while ( i < level.cqbpointsofinterest.size )
		{
			print3d( level.cqbpointsofinterest[ i ], ".", ( 0,7, 0,7, 1 ), 0,7, 3 );
			i++;
		}
		wait 0,05;
#/
	}
}
