#include animscripts/shared;
#include animscripts/debug;
#include maps/_utility;
#include maps/_turret;
#include common_scripts/utility;
#include animscripts/bigdog/bigdog_utility;
#include animscripts/utility;
#include animscripts/anims;

#using_animtree( "bigdog" );

main()
{
	self endon( "killanimscript" );
	animscripts/bigdog/bigdog_utility::initialize( "combat" );
	combatidle();
}

end_script()
{
}

combatidle()
{
/#
	self animscripts/debug::debugpushstate( "combatIdle" );
#/
	self orientmode( "face angle", self.angles[ 1 ] );
	self animmode( "zonly_physics" );
	hunkerdown();
	lastsawenemytime = getTime();
	while ( 1 )
	{
		while ( combatturn() )
		{
			continue;
		}
		if ( isDefined( self.enemy ) )
		{
			canseeenemy = self cansee( self.enemy );
		}
		if ( canseeenemy )
		{
			lastsawenemytime = getTime();
		}
		if ( self.canmove && isDefined( self.enemy ) && !self.fixednode && !bigdog_isemped() )
		{
			canshootenemy = self.turret can_turret_hit_target( self.enemy );
			if ( !canseeenemy || !canshootenemy )
			{
				if ( ( getTime() - lastsawenemytime ) > 2000 )
				{
					betternode = self findbestcovernode();
					if ( isDefined( betternode ) || !isDefined( self.node ) && betternode != self.node )
					{
						self usecovernode( betternode );
						break;
					}
					else
					{
						if ( tryreacquire() )
						{
							return;
						}
					}
				}
				break;
			}
			else
			{
				if ( trymovetonextbestnode() )
				{
					return;
				}
			}
		}
		animname = getidleanimname();
		self setflaggedanimrestart( "combat_idle", animarray( animname, "stop" ), 1, 0,2, 1 );
		self animscripts/shared::donotetracks( "combat_idle" );
	}
/#
	self animscripts/debug::debugpopstate();
#/
}

hunkerdown()
{
	if ( !self.hunkereddown )
	{
/#
		self animscripts/debug::debugpushstate( "hunkerDown" );
#/
		self orientmode( "face angle", self.angles[ 1 ] );
		self animmode( "zonly_physics", 0 );
		playfx( anim._effect[ "bigdog_dust_cloud" ], self.origin );
		animname = "hunker_down" + animsuffix();
		hunkeranim = animarray( animname, "stop" );
		self setflaggedanimknoballrestart( "hunker", hunkeranim, %root, 1, 0,2, 1 );
		self animscripts/shared::donotetracks( "hunker" );
		self clearanim( hunkeranim, 0,2 );
		self.hunkereddown = 1;
/#
		self animscripts/debug::debugpopstate();
#/
	}
}

hunkerup()
{
	if ( self.hunkereddown )
	{
/#
		self animscripts/debug::debugpushstate( "hunkerUp" );
#/
		self orientmode( "face angle", self.angles[ 1 ] );
		self animmode( "zonly_physics", 0 );
		animname = "hunker_up" + animsuffix();
		hunkeranim = animarray( animname, "stop" );
		self setflaggedanimknoballrestart( "hunker", hunkeranim, %root, 1, 0,2, 1 );
		self animscripts/shared::donotetracks( "hunker" );
		self clearanim( hunkeranim, 0,2 );
		self.hunkereddown = 0;
/#
		self animscripts/debug::debugpopstate();
#/
	}
}

combatturn()
{
	return 0;
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( !self.canmove )
	{
		return 0;
	}
	if ( getTime() < ( self.a.scriptstarttime + 5000 ) )
	{
		return 0;
	}
	if ( !self cansee( self.enemy ) )
	{
		return 0;
	}
	toenemy = self.enemy.origin - self.origin;
	desiredangle = vectorToAngle( toenemy )[ 1 ];
	anglediff = angleClamp180( desiredangle - self.angles[ 1 ] );
	if ( abs( anglediff ) > 10 )
	{
		self.safetochangescript = 0;
		turn( anglediff );
		self.safetochangescript = 1;
		return 1;
	}
	return 0;
}

turn( anglediff )
{
	turnrate = 10;
	absanglediff = abs( anglediff );
	sign = sign( anglediff );
	if ( absanglediff < self.turnanglethreshold )
	{
		return 0;
	}
/#
	self animscripts/debug::debugpushstate( "turn", anglediff );
#/
	if ( !self.hunkereddown )
	{
		hunkerdown();
	}
	self orientmode( "face angle", self.angles[ 1 ] );
	self animmode( "zonly_physics", 0 );
	animname = "hunker_up_turn";
	hunkeranim = animarray( animname, "stop" );
	self setflaggedanimknoballrestart( "hunker", hunkeranim, %root, 1, 0,2, 1 );
	self animscripts/shared::donotetracks( "hunker" );
	while ( absanglediff > 0 )
	{
		delta = min( turnrate, absanglediff );
		absanglediff -= delta;
		newyaw = self.angles[ 1 ] + ( delta * sign );
		newangles = ( self.angles[ 0 ], newyaw, self.angles[ 2 ] );
		self forceteleport( self.origin, newangles );
		wait 0,05;
	}
	self.hunkereddown = 0;
	self clearanim( %root, 0,2 );
/#
	self animscripts/debug::debugpopstate();
#/
	return 1;
}

trymovetonextbestnode()
{
	if ( getTime() >= self.nextmovetonextbestcovernodetime )
	{
		if ( movetonextbestnode() )
		{
			self.nextmovetonextbestcovernodetime = getTime() + randomintrange( 7000, 12000 );
			return 1;
		}
	}
	return 0;
}

movetonextbestnode()
{
	if ( self.fixednode )
	{
		return 0;
	}
	betternodes = self findbestcovernodes( self.goalradius, self.goalpos );
	bestnode = undefined;
	bestdistsq = 9999999;
	_a270 = betternodes;
	_k270 = getFirstArrayKey( _a270 );
	while ( isDefined( _k270 ) )
	{
		node = _a270[ _k270 ];
		if ( !isDefined( self.node ) || node != self.node )
		{
			distsq = distancesquared( self.origin, node.origin );
			if ( distsq < bestdistsq && distsq > 16384 )
			{
				bestdistsq = distsq;
				bestnode = node;
			}
		}
		_k270 = getNextArrayKey( _a270, _k270 );
	}
	if ( isDefined( bestnode ) )
	{
/#
		recordline( self.origin, bestnode.origin, ( 0, 1, 0 ), "Script", self );
#/
		self usecovernode( bestnode );
		return 1;
	}
	return 0;
}

getidleanimname()
{
	animsuffix = animsuffix();
	animname = "idle" + animsuffix;
	if ( self.hunkereddown )
	{
		animname = "hunker_idle" + animsuffix;
	}
	return animname;
}

tryreacquire()
{
	if ( self reacquirestep( 64 ) )
	{
		return 1;
	}
	else
	{
		if ( self reacquirestep( 128 ) )
		{
			return 1;
		}
		else
		{
			if ( self reacquirestep( 192 ) )
			{
				return 1;
			}
			else
			{
				if ( self reacquirestep( 256 ) )
				{
					return 1;
				}
			}
		}
	}
	return 0;
}
