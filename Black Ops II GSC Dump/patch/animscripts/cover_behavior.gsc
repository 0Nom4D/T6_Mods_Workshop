#include animscripts/shoot_behavior;
#include maps/_utility;
#include common_scripts/utility;
#include animscripts/utility;
#include animscripts/shared;
#include animscripts/debug;
#include animscripts/cover_utility;
#include animscripts/combat_utility;

coverglobalsinit()
{
	anim.coverglobals = spawnstruct();
	anim.coverglobals.desynched_time = 2500;
	anim.coverglobals.respond_to_death_retry_interval = 30000;
	anim.coverglobals.min_grenade_throw_distance_sq = 562500;
	anim.coverglobals.suppress_wait_min = 3000;
	anim.coverglobals.suppress_wait_ambush_min = 6000;
	anim.coverglobals.suppress_wait_max = 20000;
	anim.coverglobals.look_wait_min = 4000;
	anim.coverglobals.look_wait_max = 15000;
	anim.coverglobals.enemy_blindfire_wait_time_min = 3000;
	anim.coverglobals.enemy_blindfire_wait_time_max = 12000;
	anim.coverglobals.ally_blindfire_wait_time_min = 8000;
	anim.coverglobals.ally_blindfire_wait_time_max = 12000;
	anim.coverglobals.peekout_offset = 30;
	anim.coverglobals.corner_left_lean_yaw_max = -60;
	anim.coverglobals.corner_right_lean_yaw_max = 60;
	anim.coverglobals.corner_left_ab_yaw = 14;
	anim.coverglobals.corner_right_ab_yaw = -14;
}

main( behaviorcallbacks )
{
	self.couldntseeenemypos = self.origin;
	behaviorstarttime = getTime();
	resetlookforbettercovertime();
	resetseekoutenemytime();
	resetrespondtodeathtime();
	self.a.lastencountertime = behaviorstarttime;
	self.a.nextallowedlooktime = behaviorstarttime;
	self.a.nextallowedsuppresstime = behaviorstarttime;
	self.a.idlingatcover = 0;
	self.a.movement = "stop";
	self thread watchplayeraim();
	self thread watchsuppression();
	self thread animscripts/utility::idlelookatbehavior( 160, 1 );
	desynched = getTime() > anim.coverglobals.desynched_time;
	correctangles = getcorrectcoverangles();
	for ( ;; )
	{
		if ( isDefined( behaviorcallbacks.mainloopstart ) )
		{
			starttime = getTime();
			self thread endidleatframeend();
			[[ behaviorcallbacks.mainloopstart ]]();
			if ( getTime() == starttime )
			{
				self notify( "dont_end_idle" );
			}
		}
/#
		if ( runforcedbehaviors( behaviorcallbacks ) )
		{
			continue;
#/
		}
		else if ( movetonearbycover() )
		{
			continue;
		}
		else angles = ( correctangles[ 0 ], angleClamp180( correctangles[ 1 ] ), correctangles[ 2 ] );
		self teleport( self.covernode.origin, angles );
		if ( !desynched )
		{
			idle( behaviorcallbacks, 0,05 + randomfloat( 1,5 ) );
			desynched = 1;
			continue;
		}
		else if ( throwgrenadeatenemyasap( behaviorcallbacks ) )
		{
			continue;
		}
		else if ( dononattackcoverbehavior( behaviorcallbacks ) )
		{
			continue;
		}
		else if ( respondtodeadteammate() )
		{
			return;
		}
		visibleenemy = 0;
		suppressableenemy = 0;
		if ( isalive( self.enemy ) )
		{
			visibleenemy = isenemyvisiblefromexposed();
			suppressableenemy = cansuppressenemyfromexposed();
		}
		if ( visibleenemy )
		{
			if ( self.a.getboredofthisnodetime < getTime() )
			{
				if ( lookforbettercover() )
				{
					return;
				}
			}
			attackvisibleenemy( behaviorcallbacks );
			continue;
		}
		else if ( isDefined( self.aggressivemode ) || self.aggressivemode && enemyishiding() )
		{
			if ( advanceonhidingenemy() )
			{
				return;
			}
		}
		if ( suppressableenemy )
		{
			attacksuppressableenemy( behaviorcallbacks );
			continue;
		}
		else
		{
			if ( attacknothingtodo( behaviorcallbacks ) )
			{
				return;
			}
		}
	}
}

end_script()
{
	self.turntomatchnode = 0;
	self.a.prevattack = undefined;
	if ( isDefined( self.meleecoverchargemintime ) && self.meleecoverchargemintime <= getTime() )
	{
		self.meleecoverchargegraceendtime = getTime() + 0;
		self.meleecoverchargemintime = undefined;
	}
}

getcorrectcoverangles()
{
	correctangles = ( self.covernode.angles[ 0 ], getnodeforwardyaw( self.covernode ), self.covernode.angles[ 2 ] );
	return correctangles;
}

resetrespondtodeathtime()
{
	self.a.respondtodeathtime = 0;
}

resetlookforbettercovertime()
{
	currenttime = getTime();
	if ( isDefined( self.didshufflemove ) && currenttime > self.a.getboredofthisnodetime )
	{
		self.a.getboredofthisnodetime = currenttime + randomintrange( 2000, 5000 );
	}
	else
	{
		if ( isDefined( self.enemy ) )
		{
			dist = distance2d( self.origin, self.enemy.origin );
			if ( dist < self.engagemindist )
			{
				self.a.getboredofthisnodetime = currenttime + randomintrange( 5000, 10000 );
			}
			else if ( dist > self.engagemaxdist && dist < self.goalradius )
			{
				self.a.getboredofthisnodetime = currenttime + randomintrange( 2000, 5000 );
			}
			else
			{
				self.a.getboredofthisnodetime = currenttime + randomintrange( 10000, 15000 );
			}
			return;
		}
		else
		{
			self.a.getboredofthisnodetime = currenttime + randomintrange( 5000, 15000 );
		}
	}
}

respondtodeadteammate()
{
	if ( self atdangerousnode() && self.a.respondtodeathtime < getTime() )
	{
		if ( lookforbettercover() )
		{
			return 1;
		}
		self.a.respondtodeathtime = getTime() + anim.coverglobals.respond_to_death_retry_interval;
	}
	return 0;
}

dononattackcoverbehavior( behaviorcallbacks )
{
	if ( isDefined( self.covernode.script_onlyidle ) || self.covernode.script_onlyidle && isDefined( self.a.coveridleonly ) && self.a.coveridleonly )
	{
		idle( behaviorcallbacks );
		return 1;
	}
	if ( shouldswitchsides( 1 ) )
	{
		if ( switchsides( behaviorcallbacks ) )
		{
			return 1;
		}
	}
	if ( suppressedbehavior( behaviorcallbacks ) )
	{
		if ( isenemyvisiblefromexposed() )
		{
			resetseekoutenemytime();
		}
		self.a.lastencountertime = getTime();
		return 1;
	}
	if ( coverreload( behaviorcallbacks, 0 ) )
	{
		return 1;
	}
	if ( animscripts/shared::shouldswitchweapons() )
	{
		animscripts/shared::switchweapons();
		if ( isDefined( behaviorcallbacks.resetweaponanims ) )
		{
			[[ behaviorcallbacks.resetweaponanims ]]();
		}
		return 1;
	}
	return 0;
}

throwgrenadeatenemyasap( behaviorcallbacks )
{
	if ( isDefined( anim.throwgrenadeatplayerasap ) && anim.throwgrenadeatplayerasap )
	{
		players = getplayers();
		if ( isalive( players[ 0 ] ) )
		{
			self.grenadeammo++;
			if ( trythrowinggrenade( behaviorcallbacks, players[ 0 ], 1 ) )
			{
				return 1;
			}
		}
	}
	if ( isDefined( anim.throwgrenadeatenemyasap ) && anim.throwgrenadeatenemyasap )
	{
		if ( isDefined( self.enemy ) && isalive( self.enemy ) )
		{
			self.grenadeammo++;
			if ( trythrowinggrenade( behaviorcallbacks, self.enemy, 1 ) )
			{
				return 1;
			}
		}
	}
	return 0;
}

providecoveringfire( behaviorcallbacks )
{
	if ( shouldprovidecoveringfire() )
	{
		if ( leavecoverandshoot( behaviorcallbacks, "suppress" ) )
		{
			resetseekoutenemytime();
			self.a.lastencountertime = getTime();
			return 1;
		}
	}
	return 0;
}

attackvisibleenemy( behaviorcallbacks )
{
	if ( providecoveringfire( behaviorcallbacks ) )
	{
		return;
	}
	if ( distancesquared( self.origin, self.enemy.origin ) > anim.coverglobals.min_grenade_throw_distance_sq )
	{
		if ( trythrowinggrenade( behaviorcallbacks, self.enemy ) )
		{
			return;
		}
	}
	if ( leavecoverandshoot( behaviorcallbacks, "normal" ) )
	{
		resetseekoutenemytime();
		self.a.lastencountertime = getTime();
	}
	else
	{
		idle( behaviorcallbacks );
	}
}

attacksuppressableenemy( behaviorcallbacks )
{
	if ( self.doingambush )
	{
		if ( leavecoverandshoot( behaviorcallbacks, "ambush" ) )
		{
			return;
		}
	}
	else
	{
		if ( self.providecoveringfire || getTime() >= self.a.nextallowedsuppresstime )
		{
			preferredactivity = "suppress";
			if ( !self.providecoveringfire && ( getTime() - self.lastsuppressiontime ) > 5000 && randomint( 3 ) < 2 )
			{
				preferredactivity = "ambush";
			}
			else
			{
				if ( !self animscripts/shoot_behavior::shouldsuppress() )
				{
					preferredactivity = "ambush";
				}
			}
			if ( leavecoverandshoot( behaviorcallbacks, preferredactivity ) )
			{
				self.a.nextallowedsuppresstime = getTime() + randomintrange( anim.coverglobals.suppress_wait_min, anim.coverglobals.suppress_wait_max );
				if ( isenemyvisiblefromexposed() )
				{
					self.a.lastencountertime = getTime();
				}
				return;
			}
		}
	}
	if ( trythrowinggrenade( behaviorcallbacks, self.enemy ) )
	{
		return;
	}
	idle( behaviorcallbacks );
}

attacknothingtodo( behaviorcallbacks )
{
	if ( coverreload( behaviorcallbacks, 0,1 ) )
	{
		return 0;
	}
	if ( isvalidenemy( self.enemy ) )
	{
		if ( trythrowinggrenade( behaviorcallbacks, self.enemy ) )
		{
			return 0;
		}
	}
	if ( !self.doingambush && getTime() >= self.a.nextallowedlooktime )
	{
		if ( lookforenemy( behaviorcallbacks ) )
		{
			self.a.nextallowedlooktime = getTime() + randomintrange( anim.coverglobals.look_wait_min, anim.coverglobals.look_wait_max );
			return 0;
		}
	}
	if ( getTime() > self.a.getboredofthisnodetime )
	{
		if ( cantfindanythingtodo() )
		{
			return 1;
		}
	}
	if ( self.doingambush || getTime() >= self.a.nextallowedsuppresstime && isvalidenemy( self.enemy ) )
	{
		if ( leavecoverandshoot( behaviorcallbacks, "ambush" ) )
		{
			if ( isenemyvisiblefromexposed() )
			{
				resetseekoutenemytime();
			}
			self.a.lastencountertime = getTime();
			self.a.nextallowedsuppresstime = getTime() + randomintrange( anim.coverglobals.suppress_wait_ambush_min, anim.coverglobals.suppress_wait_max );
			return 0;
		}
	}
	idle( behaviorcallbacks );
	return 0;
}

isenemyvisiblefromexposed()
{
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( distancesquared( self.enemy.origin, self.couldntseeenemypos ) < 256 )
	{
		return 0;
	}
	else
	{
		return canseeenemyfromexposed();
	}
}

suppressedbehavior( behaviorcallbacks )
{
	if ( !issuppressedwrapper() )
	{
		return 0;
	}
	nextallowedblindfiretime = getTime();
	justlooked = 1;
/#
	self animscripts/debug::debugpushstate( "suppressedBehavior" );
#/
	while ( issuppressedwrapper() )
	{
		justlooked = 0;
		self teleport( self.covernode.origin );
/#
		if ( runforcedbehaviors( behaviorcallbacks ) )
		{
			return 0;
#/
		}
		trymovingnodes = 1;
		if ( isDefined( self.a.favor_blindfire ) && self.a.favor_blindfire )
		{
			trymovingnodes = cointoss();
		}
		if ( trymovingnodes && trytogetoutofdangeroussituation() )
		{
			self notify( "killanimscript" );
			waittillframeend;
/#
			self animscripts/debug::debugpopstate( "suppressedBehavior", "found better cover" );
#/
			return 1;
		}
		if ( shouldprovidecoveringfire() )
		{
/#
			self animscripts/debug::debugpopstate( "suppressedBehavior", "should provide covering fire" );
#/
			return 0;
		}
		if ( self.a.atconcealmentnode && self canseeenemy() )
		{
/#
			self animscripts/debug::debugpopstate( "suppressedBehavior", "at unsafe concealment node" );
#/
			return 0;
		}
		while ( isenemyvisiblefromexposed() || cansuppressenemyfromexposed() )
		{
			while ( throwgrenadeatenemyasap( behaviorcallbacks ) )
			{
				continue;
			}
			while ( coverreload( behaviorcallbacks, 0 ) )
			{
				continue;
			}
			while ( getTime() >= nextallowedblindfiretime )
			{
				while ( blindfire( behaviorcallbacks ) )
				{
					if ( isDefined( self.a.favor_blindfire ) && !self.a.favor_blindfire )
					{
						if ( self.team != "allies" )
						{
							nextallowedblindfiretime += randomintrange( anim.coverglobals.enemy_blindfire_wait_time_min, anim.coverglobals.enemy_blindfire_wait_time_max );
						}
						else
						{
							nextallowedblindfiretime += randomintrange( anim.coverglobals.ally_blindfire_wait_time_min, anim.coverglobals.ally_blindfire_wait_time_max );
						}
						continue;
					}
					else
					{
						nextallowedblindfiretime = getTime();
					}
				}
			}
			while ( trythrowinggrenade( behaviorcallbacks, self.enemy ) )
			{
				justlooked = 1;
			}
		}
		while ( shouldswitchsides( 0 ) )
		{
			while ( switchsides( behaviorcallbacks ) )
			{
				continue;
			}
		}
		while ( coverreload( behaviorcallbacks, 0,1 ) )
		{
			continue;
		}
		idle( behaviorcallbacks );
	}
	if ( !justlooked && randomint( 2 ) == 0 )
	{
		peekout( behaviorcallbacks );
	}
/#
	self animscripts/debug::debugpopstate( "suppressedBehavior" );
#/
	return 1;
}

calloptionalbehaviorcallback( callback, arg, arg2, arg3 )
{
	if ( !isDefined( callback ) )
	{
		return 0;
	}
	self thread endidleatframeend();
	starttime = getTime();
	val = undefined;
	if ( isDefined( arg3 ) )
	{
		val = [[ callback ]]( arg, arg2, arg3 );
	}
	else if ( isDefined( arg2 ) )
	{
		val = [[ callback ]]( arg, arg2 );
	}
	else if ( isDefined( arg ) )
	{
		val = [[ callback ]]( arg );
	}
	else
	{
		val = [[ callback ]]();
	}
/#
	if ( isDefined( val ) )
	{
		if ( val != 1 )
		{
			assert( val == 0, "behavior callback must return true or false" );
		}
	}
	if ( isDefined( val ) && val )
	{
		assert( getTime() != starttime, "behavior callback must return true only if its lets time pass" );
	}
	else
	{
		assert( getTime() == starttime, "behavior callbacks returning false must not have a wait in them" );
#/
	}
	if ( !val )
	{
		self notify( "dont_end_idle" );
	}
	return val;
}

watchsuppression()
{
	self endon( "killanimscript" );
	self.lastsuppressiontime = getTime() - 100000;
	self.suppressionstart = self.lastsuppressiontime;
	while ( 1 )
	{
		self waittill( "suppression" );
		time = getTime();
		if ( self.lastsuppressiontime < ( time - 700 ) )
		{
			self.suppressionstart = time;
		}
		self.lastsuppressiontime = time;
	}
}

coverreload( behaviorcallbacks, threshold )
{
	if ( isDefined( self.covernode.turret ) )
	{
		return 0;
	}
/#
	assert( isDefined( self.bulletsinclip ) );
#/
/#
	assert( isDefined( self.weapon ) );
#/
/#
	assert( isDefined( threshold ) );
#/
/#
	assert( isDefined( weaponclipsize( self.weapon ) ) );
#/
	forcebehavior = 0;
/#
	forcebehavior = shouldforcebehavior( "reload" );
#/
	if ( !forcebehavior && self.bulletsinclip > ( weaponclipsize( self.weapon ) * threshold ) )
	{
		return 0;
	}
	self.isreloading = 1;
/#
	self animscripts/debug::debugpushstate( "reload" );
#/
	result = calloptionalbehaviorcallback( behaviorcallbacks.reload );
/#
	self animscripts/debug::debugpopstate( "reload" );
#/
	self.isreloading = 0;
	return result;
}

rambo( behaviorcallbacks )
{
	return calloptionalbehaviorcallback( behaviorcallbacks.rambo );
}

leavecoverandshoot( behaviorcallbacks, initialgoal )
{
	self thread animscripts/shoot_behavior::decidewhatandhowtoshoot( initialgoal );
	if ( !self.fixednode && !self.doingambush )
	{
		self thread breakoutofshootingifwanttomoveup();
	}
/#
	self animscripts/debug::debugpushstate( "leaveCoverAndShoot" );
#/
	val = rambo( behaviorcallbacks );
	if ( !val )
	{
		val = calloptionalbehaviorcallback( behaviorcallbacks.leavecoverandshoot );
	}
/#
	self animscripts/debug::debugpopstate( "leaveCoverAndShoot" );
#/
	self notify( "stop_deciding_how_to_shoot" );
	return val;
}

lookforenemy( behaviorcallbacks )
{
	if ( self.a.atconcealmentnode && self canseeenemy() )
	{
		return 0;
	}
/#
	self animscripts/debug::debugpushstate( "lookForEnemy" );
#/
	looked = 0;
	if ( ( self.a.lastencountertime + 6000 ) > getTime() )
	{
		looked = peekout( behaviorcallbacks );
	}
	else
	{
		if ( weaponisgasweapon( self.weapon ) )
		{
			looked = calloptionalbehaviorcallback( behaviorcallbacks.look, 5 + randomfloat( 2 ) );
		}
		else
		{
			looked = calloptionalbehaviorcallback( behaviorcallbacks.look, 2 + randomfloat( 2 ) );
		}
		if ( !looked )
		{
			looked = calloptionalbehaviorcallback( behaviorcallbacks.fastlook );
/#
			self animscripts/debug::debugaddstateinfo( "lookForEnemy", "look failed, used fastlook" );
#/
		}
	}
/#
	self animscripts/debug::debugpopstate( "lookForEnemy" );
#/
	return looked;
}

peekout( behaviorcallbacks )
{
/#
	self animscripts/debug::debugpushstate( "peekOut" );
#/
	looked = calloptionalbehaviorcallback( behaviorcallbacks.fastlook );
	if ( !looked )
	{
		looked = calloptionalbehaviorcallback( behaviorcallbacks.look, 0 );
/#
		self animscripts/debug::debugaddstateinfo( "peekOut", "fastlook failed, used look" );
#/
	}
/#
	self animscripts/debug::debugpopstate( "peekOut" );
#/
	return looked;
}

idle( behaviorcallbacks, howlong )
{
/#
	self animscripts/debug::debugpushstate( "idle" );
#/
	self.flinching = 0;
	if ( isDefined( behaviorcallbacks.flinch ) )
	{
		if ( !self.a.idlingatcover && ( getTime() - self.suppressionstart ) < 600 )
		{
			if ( [[ behaviorcallbacks.flinch ]]() )
			{
/#
				self animscripts/debug::debugpopstate( "idle", "flinched" );
#/
				return 1;
			}
		}
		else
		{
			self thread flinchwhensuppressed( behaviorcallbacks );
		}
	}
	if ( !self.a.idlingatcover )
	{
/#
		assert( isDefined( behaviorcallbacks.idle ) );
#/
		self thread idlethread( behaviorcallbacks.idle );
		self.a.idlingatcover = 1;
	}
	if ( isDefined( howlong ) )
	{
		self idlewait( howlong );
	}
	else
	{
		self idlewaitabit();
	}
	if ( self.flinching )
	{
		self waittill( "flinch_done" );
	}
	self notify( "stop_waiting_to_flinch" );
/#
	self animscripts/debug::debugpopstate( "idle" );
#/
}

idlewait( howlong )
{
	self endon( "end_idle" );
	wait howlong;
}

idlewaitabit()
{
	self endon( "end_idle" );
	wait ( 0,3 + randomfloat( 0,1 ) );
	self waittill( "do_slow_things" );
}

idlethread( idlecallback )
{
	self endon( "killanimscript" );
	self [[ idlecallback ]]();
}

flinchwhensuppressed( behaviorcallbacks )
{
	self endon( "killanimscript" );
	self endon( "stop_waiting_to_flinch" );
	lastsuppressiontime = self.lastsuppressiontime;
	while ( 1 )
	{
		self waittill( "suppression" );
		time = getTime();
		if ( lastsuppressiontime < ( time - 2000 ) )
		{
			break;
		}
		else
		{
			lastsuppressiontime = time;
		}
	}
/#
	self animscripts/debug::debugpushstate( "flinchWhenSuppressed" );
#/
	self.flinching = 1;
	self thread endidleatframeend();
/#
	assert( isDefined( behaviorcallbacks.flinch ) );
#/
	val = [[ behaviorcallbacks.flinch ]]();
	if ( !val )
	{
		self notify( "dont_end_idle" );
	}
	self.flinching = 0;
	self notify( "flinch_done" );
/#
	self animscripts/debug::debugpopstate( "flinchWhenSuppressed" );
#/
}

endidleatframeend()
{
	self endon( "killanimscript" );
	self endon( "dont_end_idle" );
	waittillframeend;
	if ( !isDefined( self ) )
	{
		return;
	}
	self notify( "end_idle" );
	self.a.idlingatcover = 0;
}

trythrowinggrenade( behaviorcallbacks, throwat, forcethrow )
{
	result = undefined;
	if ( isDefined( forcethrow ) )
	{
		forcethrow = forcethrow;
	}
/#
	self animscripts/debug::debugpushstate( "tryThrowingGrenade" );
#/
/#
	assert( isDefined( throwat ) );
#/
	if ( !canthrowgrenade() )
	{
/#
		self animscripts/debug::debugpopstate( "tryThrowingGrenade", "Cant throw grenade, canThrowGrenade() failed" );
#/
	}
	forward = anglesToForward( self.angles );
	dir = vectornormalize( throwat.origin - self.origin );
	if ( vectordot( forward, dir ) < 0 && self.a.script != "cover_pillar" )
	{
/#
		self animscripts/debug::debugpopstate( "tryThrowingGrenade", "don't want to throw backwards" );
#/
		return 0;
	}
	if ( self.a.script == "cover_pillar" && isDefined( self.covernode ) )
	{
		forward = anglesToForward( self.covernode.angles );
		dir = vectornormalize( throwat.origin - self.covernode.origin );
		if ( vectordot( forward, dir ) < 0 )
		{
/#
			self animscripts/debug::debugpopstate( "tryThrowingGrenade", "don't want to throw backwards" );
#/
			return 0;
		}
	}
	if ( !forcethrow && self.doingambush && !recentlysawenemy() )
	{
/#
		self animscripts/debug::debugpopstate( "tryThrowingGrenade", "doingAmbush and haven't seen enemy recently" );
#/
		return 0;
	}
	if ( shouldswitchsides( 0 ) )
	{
		switchsides( behaviorcallbacks );
	}
	if ( self ispartiallysuppressedwrapper() || isDefined( forcethrow ) && forcethrow )
	{
		result = calloptionalbehaviorcallback( behaviorcallbacks.grenadehidden, throwat, forcethrow );
	}
	else
	{
		result = calloptionalbehaviorcallback( behaviorcallbacks.grenade, throwat );
	}
/#
	self animscripts/debug::debugpopstate( "tryThrowingGrenade" );
#/
	return result;
}

blindfire( behaviorcallbacks )
{
	if ( !canblindfire() )
	{
		return 0;
	}
	if ( isDefined( self.enemy ) )
	{
		self animscripts/shoot_behavior::setshootent( self.enemy );
	}
/#
	self animscripts/debug::debugpushstate( "blindfire" );
#/
	result = calloptionalbehaviorcallback( behaviorcallbacks.blindfire );
/#
	self animscripts/debug::debugpopstate( "blindfire" );
#/
	return result;
}

breakoutofshootingifwanttomoveup()
{
	self endon( "killanimscript" );
	self endon( "stop_deciding_how_to_shoot" );
	while ( 1 )
	{
		if ( self.fixednode || self.doingambush )
		{
			return;
		}
		wait ( 0,5 + randomfloat( 0,75 ) );
		while ( !isvalidenemy( self.enemy ) )
		{
			continue;
		}
		if ( enemyishiding() )
		{
			if ( advanceonhidingenemy() )
			{
				return;
			}
		}
		if ( !self recentlysawenemy() && !self cansuppressenemy() )
		{
			if ( getTime() > self.a.getboredofthisnodetime )
			{
				if ( cantfindanythingtodo() )
				{
					return;
				}
			}
		}
	}
}

enemyishiding()
{
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( self.enemy isflashed() )
	{
		return 1;
	}
	if ( isplayer( self.enemy ) )
	{
		if ( isDefined( self.enemy.health ) && self.enemy.health < self.enemy.maxhealth )
		{
			return 1;
		}
	}
	else
	{
		if ( issentient( self.enemy ) && self.enemy issuppressedwrapper() )
		{
			return 1;
		}
	}
	if ( isDefined( self.enemy.isreloading ) && self.enemy.isreloading )
	{
		return 1;
	}
	return 0;
}

wouldbesmartformyaitypetoseekoutenemy()
{
	if ( self weaponanims() == "rocketlauncher" )
	{
		return 0;
	}
	if ( self issniper() )
	{
		return 0;
	}
	return 1;
}

resetseekoutenemytime()
{
	if ( isDefined( self.aggressivemode ) && self.aggressivemode )
	{
		self.seekoutenemytime = getTime() + randomintrange( 500, 1000 );
	}
	else
	{
		self.seekoutenemytime = getTime() + randomintrange( 3000, 5000 );
	}
}

cantfindanythingtodo()
{
	return advanceonhidingenemy();
}

advanceonhidingenemy()
{
	if ( self.fixednode || self.doingambush )
	{
		return 0;
	}
	if ( isDefined( self.aggressivemode ) && self.aggressivemode && getTime() >= self.seekoutenemytime )
	{
		return tryrunningtoenemy( 0 );
	}
	foundbettercover = 0;
	if ( !isvalidenemy( self.enemy ) || !self.enemy isflashed() )
	{
		foundbettercover = lookforbettercover();
	}
	if ( !foundbettercover && isvalidenemy( self.enemy ) && wouldbesmartformyaitypetoseekoutenemy() && !self canseeenemyfromexposed() )
	{
		if ( getTime() >= self.seekoutenemytime || self.enemy isflashed() )
		{
			return tryrunningtoenemy( 0 );
		}
	}
	return foundbettercover;
}

trytogetoutofdangeroussituation()
{
	if ( movetonearbycover() )
	{
		return 1;
	}
	return lookforbettercover();
}

movetonearbycover()
{
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( isDefined( self.didshufflemove ) && self.didshufflemove )
	{
		self.didshufflemove = undefined;
		return 0;
	}
	if ( aihasonlypistol() )
	{
		return 0;
	}
	if ( !isDefined( self.node ) )
	{
		return 0;
	}
	if ( !self.fixednode && !self.doingambush || self.keepclaimednode && self.keepclaimednodeifvalid )
	{
		return 0;
	}
	if ( distancesquared( self.origin, self.node.origin ) > 256 )
	{
		return 0;
	}
	node = self findshufflecovernode();
	if ( !isDefined( self.node ) )
	{
		return 0;
	}
	if ( isDefined( node ) && distancesquared( node.origin, self.node.origin ) <= anim.moveglobals.shuffle_cover_min_distsq )
	{
		return 0;
	}
	if ( isDefined( node ) && node != self.node && self usecovernode( node ) )
	{
		self.shufflemove = 1;
		self.shufflenode = node;
		self.didshufflemove = 1;
		self.keepclaimednode = 0;
		wait 0,5;
		return 1;
	}
	return 0;
}

shouldprovidecoveringfire()
{
	return 0;
}

watchplayeraim()
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stop_watchPlayerAim" );
	if ( isDefined( self.coverlookattrigger ) )
	{
		self.coverlookattrigger delete();
	}
/#
	assert( isDefined( self.covernode ) );
#/
	self.coversafetopopout = 1;
	stepoutpos = self.covernode.origin;
	if ( self.a.script == "cover_left" || self.a.script == "cover_pillar" && self.cornerdirection == "left" )
	{
		stepoutpos -= vectorScale( anglesToRight( self.covernode.angles ), 32 );
	}
	else
	{
		if ( self.a.script == "cover_right" || self.a.script == "cover_pillar" && self.cornerdirection == "right" )
		{
			stepoutpos += vectorScale( anglesToRight( self.covernode.angles ), 32 );
		}
	}
	triggerheight = 72;
	if ( self.a.pose == "crouch" )
	{
		triggerheight = 48;
	}
	self.coverlookattrigger = spawn( "trigger_lookat", stepoutpos, 0, 15, triggerheight );
/#
#/
	while ( 1 )
	{
		waittillframeend;
		self.coversafetopopout = 1;
		self.playeraimsuppression = 0;
		self.coverlookattrigger waittill( "trigger", watcher );
		if ( isDefined( watcher ) && isDefined( self.enemy ) && watcher == self.enemy )
		{
/#
			self thread watchplayeraimdebug( 12 );
#/
			self.coversafetopopout = 0;
			self.playeraimsuppression = randomfloat( 1 ) < 0,9;
			wait 0,5;
		}
		wait 0,05;
	}
	self.coversafetopopout = 1;
	self.playeraimsuppression = 0;
	self.coverlookattrigger delete();
}

watchplayeraimdebug( numframes )
{
/#
	self endon( "death" );
	i = 0;
	while ( i < numframes )
	{
		recordenttext( "Cover Trigger Watched", self, level.color_debug[ "white" ], "Suppression" );
		i++;
		wait 0,05;
#/
	}
}

shouldswitchsides( forvariety )
{
	if ( !canswitchsides() )
	{
		return 0;
	}
/#
	forcecornermode = shouldforcebehavior( "force_corner_direction" );
	if ( forcecornermode == self.cornerdirection )
	{
		return 0;
#/
	}
	enemyrightbehindme = 0;
	if ( self.cornerdirection != self.covernode.desiredcornerdirection )
	{
		return 1;
	}
	else
	{
		if ( isDefined( self.enemy ) )
		{
			yaw = self.covernode getyawtoorigin( self.enemy.origin );
			desiredcornerdirection = self.cornerdirection;
			if ( yaw < -5 && !self.covernode has_spawnflag( 1024 ) )
			{
				desiredcornerdirection = "right";
			}
			else
			{
				if ( yaw > 5 && !self.covernode has_spawnflag( 2048 ) )
				{
					desiredcornerdirection = "left";
				}
				else
				{
					enemyrightbehindme = 1;
				}
			}
			if ( !enemyrightbehindme && self.cornerdirection != desiredcornerdirection )
			{
				self.covernode.desiredcornerdirection = desiredcornerdirection;
				return 1;
			}
		}
	}
	if ( !enemyrightbehindme && forvariety && getTime() > self.a.nextallowedswitchsidestime )
	{
		if ( self.cornerdirection == "left" && !self.covernode has_spawnflag( 1024 ) )
		{
			self.covernode.desiredcornerdirection = "right";
		}
		else
		{
			if ( !self.covernode has_spawnflag( 2048 ) )
			{
				self.covernode.desiredcornerdirection = "left";
			}
		}
		return 1;
	}
	return 0;
}

switchsides( behaviorcallbacks )
{
/#
	self animscripts/debug::debugpushstate( "switchSides" );
#/
	result = [[ behaviorcallbacks.switchsides ]]();
	if ( result )
	{
		self notify( "stop_watchPlayerAim" );
		self thread watchplayeraim();
		self.a.nextallowedswitchsidestime = getTime() + randomintrange( 5000, 7500 );
		self.a.lastswitchsidestime = getTime();
	}
/#
	self animscripts/debug::debugpopstate( "switchSides" );
#/
	return result;
}

runforcedbehaviors( behaviorcallbacks )
{
/#
	didsomething = 0;
	if ( !didsomething && shouldforcebehavior( "idle" ) )
	{
		idle( behaviorcallbacks );
		didsomething = 1;
	}
	if ( !didsomething && shouldforcebehavior( "look" ) )
	{
		if ( calloptionalbehaviorcallback( behaviorcallbacks.look, 2 + randomfloat( 2 ) ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "lookFast" ) )
	{
		if ( calloptionalbehaviorcallback( behaviorcallbacks.fastlook ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "reload" ) )
	{
		if ( coverreload( behaviorcallbacks, 0 ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "switchSides" ) )
	{
		if ( getTime() > self.a.nextallowedswitchsidestime )
		{
			if ( switchsides( behaviorcallbacks ) )
			{
				didsomething = 1;
			}
		}
	}
	if ( !didsomething && shouldforcebehavior( "stepOut" ) )
	{
		if ( leavecoverandshoot( behaviorcallbacks, "normal" ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "advance" ) )
	{
		if ( advanceonhidingenemy() )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "blindfire" ) )
	{
		if ( blindfire( behaviorcallbacks ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "grenade" ) )
	{
		if ( self.grenadeammo <= 0 )
		{
			self.grenadeammo = 1;
		}
		if ( isDefined( self.enemy ) && trythrowinggrenade( behaviorcallbacks, self.enemy ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "flinch" ) )
	{
		if ( calloptionalbehaviorcallback( behaviorcallbacks.flinch ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "rambo" ) )
	{
		if ( rambo( behaviorcallbacks ) )
		{
			didsomething = 1;
		}
	}
	if ( !didsomething && shouldforcebehavior( "switchWeapons" ) )
	{
		if ( animscripts/shared::shouldswitchweapons() )
		{
			animscripts/shared::switchweapons();
			didsomething = 1;
		}
	}
	return didsomething;
#/
}
