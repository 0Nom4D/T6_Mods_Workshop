#include animscripts/run;
#include animscripts/debug;
#include common_scripts/utility;
#include animscripts/anims;
#include animscripts/shared;
#include animscripts/utility;
#include animscripts/combat_utility;
#include animscripts/setposemovement;

#using_animtree( "generic_human" );

moveturnglobalsinit()
{
	anim.turn_prediction_type_axis = 0;
	anim.turn_prediction_type_allies = 2;
	anim.turn_min_angle = 45;
/#
	anim.debugturns = getDvarInt( #"32B996B1" );
#/
}

doturn( overrideanim, overrideblendoutanim, faceangleoffset, keependyaw )
{
	self endon( "killanimscript" );
	self endon( "death" );
	turnangle = self.a.turnangle;
	self.a.isturning = 1;
/#
	anglestr = "";
	if ( turnangle < 0 )
	{
		anglestr = "right " + turnangle;
	}
	else
	{
		anglestr = "left " + turnangle;
	}
	self animscripts/debug::debugpushstate( "turn", anglestr );
#/
	animscripts/run::stopupdaterunanimweights();
	self notify( "stopShooting" );
	self notify( "stopTurnBlendOut" );
	self delay_thread( 0,05, ::stoptracking );
	turnanim = getturnanim( turnangle );
	if ( isDefined( overrideanim ) )
	{
		turnanim = overrideanim;
	}
	if ( isDefined( turnanim ) )
	{
		self animmode( "gravity", 0 );
		self orientmode( "face angle", self.angles[ 1 ] );
		self clearanim( %body, 0,2 );
		self setflaggedanimrestart( "turn_anim", turnanim, 1, 0,2 );
		self thread forceclearclientruntree( 0,2 );
		animstarttime = getTime();
		animlength = getanimlength( turnanim );
		hasexitalign = animhasnotetrack( turnanim, "exit_align" );
/#
		if ( !hasexitalign )
		{
			println( "^3Warning: turn animation for angle " + turnangle + " has no "exit_align" notetrack." );
#/
		}
		self thread doturnnotetracks( "turn_anim" );
		self thread turnblendout( animlength, "turn_anim", hasexitalign, overrideblendoutanim );
		self waittillmatch( "turn_anim" );
		return "exit_align";
		elapsed = ( getTime() - animstarttime ) / 1000;
		timeleft = animlength - elapsed;
		hascodemovenotetrack = animhasnotetrack( turnanim, "code_move" );
		if ( hascodemovenotetrack )
		{
			times = getnotetracktimes( turnanim, "code_move" );
/#
			assert( times.size == 1, "More than one code_move notetrack found" );
#/
			timeleft = ( times[ 0 ] * animlength ) - elapsed;
/#
			if ( anim.debugturns )
			{
				recordenttext( "hasCodeMove", self, level.color_debug[ "red" ], "Animscript" );
#/
			}
		}
/#
		if ( anim.debugturns )
		{
			recordenttext( "animLength: " + animlength + " elapsed: " + elapsed + " timeLeft: " + timeleft, self, level.color_debug[ "red" ], "Animscript" );
#/
		}
		self animmode( "pos deltas", 0 );
		if ( !isDefined( faceangleoffset ) )
		{
			faceangleoffset = 0;
		}
		intendedyawchangeperframe = abs( turnangle ) / ( timeleft / 0,05 );
		turnrateyawchangeperframe = self.turnrate / 20;
		lookaheadyaw = vectorToAngle( self.lookaheaddir )[ 1 ];
		prevlookaheadyaw = lookaheadyaw;
		while ( timeleft > 0 )
		{
			lookaheadyawchange = absangleclamp180( lookaheadyaw - prevlookaheadyaw );
			maxyawchangeperframe = intendedyawchangeperframe + min( lookaheadyawchange, turnrateyawchangeperframe );
			yawdelta = angleClamp180( ( lookaheadyaw - self.angles[ 1 ] ) + faceangleoffset );
			yawdelta /= ceil( timeleft / 0,05 );
			yawdelta = min( abs( yawdelta ), maxyawchangeperframe ) * sign( yawdelta );
			newangles = ( self.angles[ 0 ], self.angles[ 1 ] + yawdelta, self.angles[ 2 ] );
			self teleport( self.origin, newangles );
/#
			if ( anim.debugturns )
			{
				recordenttext( "face angle: " + self.angles[ 1 ] + yawdelta, self, level.color_debug[ "red" ], "Animscript" );
#/
			}
			timeleft -= 0,05;
			wait 0,05;
			prevlookaheadyaw = lookaheadyaw;
			lookaheadyaw = vectorToAngle( self.lookaheaddir )[ 1 ];
		}
		self clearmovehistory();
		self animmode( "normal", 0 );
		if ( isDefined( keependyaw ) && !keependyaw )
		{
			self orientmode( "face motion" );
		}
		elapsed = ( getTime() - animstarttime ) / 1000;
		timeleft = animlength - elapsed;
		while ( timeleft > 0 )
		{
			if ( shouldturn() )
			{
				break;
			}
			else
			{
				timeleft -= 0,05;
				wait 0,05;
			}
		}
		self orientmode( "face default" );
	}
	self.a.isturning = 0;
/#
	self animscripts/debug::debugpopstate();
#/
}

forceclearclientruntree( blendtime )
{
	self endon( "killanimscript" );
	self endon( "death" );
	wait 0,05;
	self clearanim( %stand_and_crouch, blendtime - 0,05 );
}

turnblendout( animlength, animname, hasexitalign, overrideblendoutanim )
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stopTurnBlendOut" );
/#
	assert( animlength > 0,2 );
#/
	wait ( animlength - 0,2 );
	nextanim = animscripts/run::getrunanim();
	if ( isDefined( overrideblendoutanim ) )
	{
		nextanim = overrideblendoutanim;
	}
	self.a.movement = "run";
	self clearanim( %body, 0,2 );
	self setflaggedanimrestart( "run_anim", nextanim, 1, 0,2 );
	if ( !hasexitalign )
	{
		self notify( animname );
	}
}

getturnangle()
{
	if ( isDefined( self.a.turnangletime ) && self.a.turnangletime == getTime() )
	{
/#
		assert( isDefined( self.a.turnangle ) );
#/
		return self.a.turnangle;
	}
	turnangle = self animscripts/run::getlookaheadangle();
/#
	anglestr = "lookahead: " + int( turnangle );
#/
	if ( self.team == "allies" )
	{
		turnpreditiontype = anim.turn_prediction_type_allies;
	}
	else
	{
		turnpreditiontype = anim.turn_prediction_type_axis;
	}
	while ( abs( turnangle ) < anim.turn_min_angle && turnpreditiontype > 0 )
	{
		forwarddist = min( self.lookaheaddist, 30 );
		futurepos = self.origin + vectorScale( self.lookaheaddir, forwarddist );
		lookaheadnode = undefined;
		lookaheadnextnode = undefined;
		prevnodeangle = undefined;
		i = 0;
		while ( i < turnpreditiontype )
		{
			if ( i == 0 )
			{
				currentlookahead = self calclookaheadpos( futurepos, 0 );
				if ( isDefined( currentlookahead ) )
				{
					lookaheadnode = currentlookahead[ "node" ];
					lookaheadnextnode = currentlookahead[ "next_node" ];
				}
			}
			else
			{
				doexpensivelookahead = 1;
				lookaheadnode = lookaheadnextnode;
				if ( isDefined( lookaheadnextnode ) )
				{
					nextnodeangle = getyawtoorigin( lookaheadnextnode ) * -1;
					if ( abs( nextnodeangle ) <= max( anim.turn_min_angle, abs( prevnodeangle ) ) )
					{
						doexpensivelookahead = 0;
					}
					else
					{
						if ( isDefined( prevnodeangle ) && sign( nextnodeangle ) != sign( prevnodeangle ) )
						{
							doexpensivelookahead = 0;
						}
					}
				}
				else
				{
					doexpensivelookahead = 0;
				}
				if ( doexpensivelookahead )
				{
					lookaheadnode = undefined;
					predictedlookahead = self calclookaheadpos( futurepos, 3 );
					if ( isDefined( predictedlookahead ) )
					{
						lookaheadnode = predictedlookahead[ "node" ];
					}
				}
			}
			if ( !isDefined( lookaheadnode ) )
			{
				i++;
				continue;
			}
			else
			{
				nextnodeangle = getyawtoorigin( lookaheadnode ) * -1;
/#
				if ( i == 0 )
				{
					anglestr += " node: " + int( nextnodeangle );
				}
				else
				{
					anglestr += " predicted: " + int( nextnodeangle );
#/
				}
				if ( abs( nextnodeangle ) <= max( anim.turn_min_angle, abs( turnangle ) ) )
				{
/#
					if ( anim.debugturns )
					{
						recordline( futurepos, lookaheadnode, level.color_debug[ "yellow" ], "Animscript", self );
#/
					}
				}
				else if ( isDefined( prevnodeangle ) && sign( nextnodeangle ) != sign( prevnodeangle ) )
				{
/#
					if ( anim.debugturns )
					{
						recordline( futurepos, lookaheadnode, level.color_debug[ "yellow" ], "Animscript", self );
#/
					}
				}
				else
				{
					if ( !self maymovefrompointtopoint( futurepos, lookaheadnode ) )
					{
/#
						if ( anim.debugturns )
						{
							recordline( futurepos, lookaheadnode, level.color_debug[ "red" ], "Animscript", self );
#/
						}
						break;
					}
					else
					{
/#
						if ( anim.debugturns )
						{
							recordline( futurepos, lookaheadnode, level.color_debug[ "green" ], "Animscript", self );
#/
						}
						turnangle = nextnodeangle;
					}
				}
				prevnodeangle = nextnodeangle;
			}
			i++;
		}
	}
/#
	if ( anim.debugturns )
	{
		if ( abs( turnangle ) > anim.turn_min_angle )
		{
			recordenttext( anglestr, self, level.color_debug[ "green" ], "Animscript" );
		}
		else
		{
			recordenttext( anglestr, self, level.color_debug[ "red" ], "Animscript" );
#/
		}
	}
	return turnangle;
}

shouldturn()
{
	if ( isDefined( self.disableturns ) && self.disableturns )
	{
		return 0;
	}
	if ( self.a.pose != "stand" )
	{
		return 0;
	}
	if ( !self.facemotion )
	{
		return 0;
	}
	pathgoalpos = self.pathgoalpos;
	traversalstartnode = self getnegotiationstartnode();
	if ( isDefined( traversalstartnode ) )
	{
		pathgoalpos = traversalstartnode.origin;
	}
	if ( isDefined( pathgoalpos ) )
	{
		disttogoal = distancesquared( pathgoalpos, self.origin );
		if ( disttogoal < 2500 )
		{
/#
			if ( anim.debugturns )
			{
				recordenttext( "distSq: " + disttogoal, self, level.color_debug[ "red" ], "Animscript" );
#/
			}
			return 0;
		}
	}
	self.a.turnignoremotionangle = 0;
	minspeed = 9,5;
	minspeed *= minspeed;
	minspeed *= 0,25;
	turnangle = self animscripts/run::getlookaheadangle();
	motionangle = self getmotionangle();
	if ( !self.a.turnignoremotionangle && abs( motionangle ) > 45 && abs( turnangle ) > 135 )
	{
		if ( !animscripts/run::shouldfullsprint() && isDefined( self.enemy ) && distancesquared( self.origin, self.enemy.origin ) < animscripts/run::getrunbackwardsdistancesquared() )
		{
			return 0;
		}
		if ( isDefined( self.pathgoalpos ) && distancesquared( self.origin, self.pathgoalpos ) < 22500 )
		{
			return 0;
		}
	}
	velocity = self getvelocity();
	velocity = ( velocity[ 0 ], velocity[ 1 ], 0 );
	speedsq = lengthsquared( velocity );
	turnangle = getturnangle();
	if ( abs( turnangle ) < anim.turn_min_angle )
	{
		return 0;
	}
	if ( abs( turnangle ) <= 90 && isDefined( self.pathgoalpos ) && distancesquared( self.origin, self.pathgoalpos ) < 40000 )
	{
		return 0;
	}
	if ( speedsq < minspeed )
	{
		if ( self.a.prevscript == "traverse" && self.a.movement == "run" && self.a.scriptstarttime == getTime() )
		{
			self.a.turnignoremotionangle = 1;
		}
		else
		{
			return 0;
		}
	}
	if ( !isDefined( getturnanim( turnangle ) ) )
	{
		return 0;
	}
	self.a.turnangle = turnangle;
	self.a.turnangletime = getTime();
	return 1;
}

getturnanim( turnangle )
{
	turnanim = undefined;
	turnanimlookupkey = undefined;
	turnanimlookupspecial = shoulddospecialturn();
	motionangle = self getmotionangle();
	if ( isDefined( self.a.turnignoremotionangle ) && !self.a.turnignoremotionangle && abs( motionangle ) > 45 )
	{
		if ( abs( turnangle ) > 135 )
		{
			if ( turnangle > 0 )
			{
				turnanimlookupkey = "turn_b_r_180";
			}
			else
			{
				turnanimlookupkey = "turn_b_l_180";
			}
		}
	}
	else
	{
		if ( turnangle >= 115 && turnangle <= 155 )
		{
			turnanimlookupkey = "turn_f_l_135";
			if ( !animarrayanyexist( turnanimlookupkey + turnanimlookupspecial, "turn" ) )
			{
				turnanimlookupkey = "turn_f_l_180";
			}
		}
		else
		{
			if ( turnangle > 155 )
			{
				turnanimlookupkey = "turn_f_l_180";
			}
			else if ( turnangle >= 65 )
			{
				turnanimlookupkey = "turn_f_l_90";
			}
			else if ( turnangle >= 35 )
			{
				turnanimlookupkey = "turn_f_l_45";
			}
			else if ( turnangle <= -115 && turnangle >= -155 )
			{
				turnanimlookupkey = "turn_f_r_135";
				if ( !animarrayanyexist( turnanimlookupkey + turnanimlookupspecial, "turn" ) )
				{
					turnanimlookupkey = "turn_f_r_180";
				}
			}
			else
			{
				if ( turnangle < -155 )
				{
					turnanimlookupkey = "turn_f_r_180";
				}
				else if ( turnangle <= -65 )
				{
					turnanimlookupkey = "turn_f_r_90";
				}
				else
				{
					if ( turnangle < -35 )
					{
						turnanimlookupkey = "turn_f_r_45";
					}
				}
			}
		}
	}
	if ( isDefined( turnanimlookupkey ) )
	{
		turnanimlookupkey += turnanimlookupspecial;
		turnanim = animarray( turnanimlookupkey, "turn" );
	}
	return turnanim;
}

shoulddospecialturn()
{
	specialturnsuffix = "";
	if ( isDefined( self.cqb ) && self.cqb && self animscripts/utility::weaponanims() != "pistol" )
	{
		specialturnsuffix = "_cqb";
	}
	return specialturnsuffix;
}

doturnnotetracks( flagname )
{
	self notify( "stop_DoNotetracks" );
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stop_DoNotetracks" );
	self animscripts/shared::donotetracks( flagname );
}
