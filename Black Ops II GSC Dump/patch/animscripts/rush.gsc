#include maps/_utility;
#include common_scripts/utility;
#include animscripts/debug;
#include animscripts/shared;
#include animscripts/utility;
#include animscripts/combat_utility;
#include animscripts/setposemovement;

#using_animtree( "generic_human" );

sidestepinit()
{
	self.a.rushersteppeddir = 0;
	self.a.rushergunhand = "rh";
	self.a.rusherlastsidesteptime = getTime();
	self.a.rusherhadsidestepevent = 0;
	if ( allowevasivemovement() )
	{
		self addaieventlistener( "bulletwhizby" );
		self thread sidestepwatchforevent();
	}
}

sidestepwatchforevent()
{
	self endon( "death" );
	self endon( "killanimscript" );
	self.a.rusherhadsidestepevent = 0;
	while ( 1 )
	{
		self waittill_any( "bulletwhizby" );
		self.a.rusherhadsidestepevent = 1;
		wait 0,05;
		waittillframeend;
		self.a.rusherhadsidestepevent = 0;
	}
}

cansidestep()
{
	if ( !allowevasivemovement() )
	{
		return 0;
	}
	if ( ( getTime() - self.a.rusherlastsidesteptime ) < 500 )
	{
		return 0;
	}
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( !self usingrifle() && !self usingpistol() )
	{
		return 0;
	}
	if ( self.a.pose != "stand" )
	{
		return 0;
	}
	if ( distancesquared( self.origin, self.enemy.origin ) < 90000 )
	{
		return 0;
	}
	if ( !isDefined( self.pathgoalpos ) || distancesquared( self.origin, self.pathgoalpos ) < 90000 )
	{
		return 0;
	}
	if ( abs( self getmotionangle() ) > 15 )
	{
		return 0;
	}
	yaw = getyawtoorigin( self.enemy.origin );
	if ( abs( yaw ) > 15 )
	{
		return 0;
	}
	return 1;
}

shouldsidestep()
{
	if ( cansidestep() )
	{
		runlooptime = self getanimtime( %walk_and_run_loops );
		if ( self.a.rusherhadsidestepevent )
		{
			return "roll";
		}
		else
		{
			if ( isplayer( self.enemy ) && self.enemy islookingat( self ) )
			{
				if ( randomfloat( 1 ) < 0,2 )
				{
					return "step";
				}
				else
				{
					return "roll";
				}
			}
			else
			{
				if ( runlooptime > 0,9 && randomfloat( 1 ) < 0,75 )
				{
					return "step";
				}
			}
		}
	}
	return "none";
}

trysidestep()
{
	self.rushersidesteptype = shouldsidestep();
	if ( self.rushersidesteptype == "none" )
	{
		return 0;
	}
/#
	self animscripts/debug::debugpushstate( "sideStep" );
#/
	self.rusherdesiredstepdir = getdesiredsidestepdir( self.rushersidesteptype );
	self.rusherdesiredgunhand = self.a.rushergunhand;
	if ( self.a.rushersteppeddir == 0 && self.rusherdesiredstepdir == "left" && randomfloat( 1 ) < 0,5 )
	{
		self.rusherdesiredgunhand = "lh";
	}
	animname = ( self.rushersidesteptype + "_" ) + self.rusherdesiredstepdir + "_" + self.rusherdesiredgunhand;
	self.stepanim = animscripts/anims::animarraypickrandom( animname );
/#
	assert( isDefined( self.stepanim ), "rusher anim " + animname + " not found" );
#/
	if ( !self checkroomforanim( self.stepanim ) )
	{
		hasroom = 0;
		if ( self.rushersidesteptype == "roll" && self.rusherdesiredstepdir != "forward" )
		{
			self.rusherdesiredstepdir = "forward";
			animname = ( self.rushersidesteptype + "_" ) + self.rusherdesiredstepdir + "_" + self.rusherdesiredgunhand;
			self.stepanim = animscripts/anims::animarraypickrandom( animname );
/#
			assert( isDefined( self.stepanim ), "rusher anim " + animname + " not found" );
#/
			hasroom = self checkroomforanim( self.stepanim );
		}
		if ( !hasroom )
		{
/#
			self animscripts/debug::debugpopstate( "sideStep", "no room for sidestep" );
#/
			return 0;
		}
	}
	self animcustom( ::dosidestep );
}

dosidestep()
{
	self endon( "death" );
	self endon( "killanimscript" );
	if ( self.rusherdesiredstepdir == "right" && self.rusherdesiredgunhand == "lh" )
	{
		self.rusherdesiredgunhand = "rh";
	}
	self.a.rushergunhand = self.rusherdesiredgunhand;
	setruncycle();
	playsidestepanim( self.stepanim, self.rushersidesteptype );
	if ( self.rusherdesiredstepdir == "left" )
	{
		self.a.rushersteppeddir--;

	}
	else
	{
		self.a.rushersteppeddir++;
	}
	self.a.rusherlastsidesteptime = getTime();
/#
	self animscripts/debug::debugpopstate( "sideStep" );
#/
	return 1;
}

playsidestepanim( stepanim, rushersidesteptype )
{
	self animmode( "gravity", 0 );
	self orientmode( "face angle", self.angles[ 1 ] );
	self clearanim( %body, 0,2 );
	self setflaggedanimrestart( "stepAnim", stepanim, 1, 0,2, self.moveplaybackrate );
	if ( rushersidesteptype == "step" )
	{
		self aimingon();
		self.shoot_while_moving_thread = undefined;
		self thread animscripts/run::runshootwhilemovingthreads();
	}
	else
	{
		self disable_pain();
		self thread restorepainonkillanimscript();
		self.deathfunction = ::do_ragdoll_death;
	}
	animstarttime = getTime();
	animlength = getanimlength( stepanim );
	hasexitalign = animhasnotetrack( stepanim, "exit_align" );
	if ( !hasexitalign )
	{
/#
		println( "^1Side step animation has no "exit_align" notetrack" );
#/
	}
	self thread animscripts/shared::donotetracks( "stepAnim" );
	self thread sidestepblendout( animlength, "stepAnim", hasexitalign );
	self waittillmatch( "stepAnim" );
	return "exit_align";
	elapsed = ( getTime() - animstarttime ) / 1000;
	timeleft = animlength - elapsed;
	hascodemovenotetrack = animhasnotetrack( stepanim, "code_move" );
	if ( hascodemovenotetrack )
	{
		times = getnotetracktimes( stepanim, "code_move" );
/#
		assert( times.size == 1, "More than one code_move notetrack found" );
#/
		timeleft = ( times[ 0 ] * animlength ) - elapsed;
	}
	self animmode( "pos deltas", 0 );
	timer = 0;
	while ( timer < timeleft )
	{
		lookaheadangles = vectorToAngle( self.lookaheaddir );
		yawdelta = angleClamp180( lookaheadangles[ 1 ] - self.angles[ 1 ] );
		if ( yawdelta > 2 )
		{
			yawdelta = 2;
		}
		else
		{
			if ( yawdelta < ( 2 * -1 ) )
			{
				yawdelta = 2 * -1;
			}
		}
		newangles = ( self.angles[ 0 ], self.angles[ 1 ] + yawdelta, self.angles[ 2 ] );
		self teleport( self.origin, newangles );
/#
		if ( getDvarInt( #"32B996B1" ) )
		{
			recordenttext( "face angle: " + self.angles[ 1 ] + yawdelta, self, level.color_debug[ "red" ], "Animscript" );
#/
		}
		timer += 0,05 * self.moveplaybackrate;
		wait 0,05;
	}
	self orientmode( "face angle", self.angles[ 1 ] );
	elapsed = ( getTime() - animstarttime ) / 1000;
	timeleft = animlength - elapsed;
	if ( timeleft > 0 )
	{
		wait ( timeleft / self.moveplaybackrate );
	}
	if ( isalive( self ) )
	{
		self thread facelookaheadforabit();
		animscripts/run::stopshootwhilemovingthreads();
		self enable_pain();
		self.deathfunction = undefined;
	}
}

facelookaheadforabit()
{
	self endon( "death" );
	self endon( "killanimscript" );
	lookaheadangles = vectorToAngle( self.lookaheaddir );
	self orientmode( "face angle", lookaheadangles[ 1 ] );
	wait 0,2;
	self animmode( "normal", 0 );
	self orientmode( "face default" );
}

sidestepblendout( animlength, animname, hasexitalign )
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stopTurnBlendOut" );
/#
	assert( animlength > 0 );
#/
	wait ( ( animlength - 0 ) / self.moveplaybackrate );
	if ( !hasexitalign )
	{
		self notify( animname );
	}
	self clearanim( %exposed_modern, 0 );
	self setflaggedanimknoballrestart( "run_anim", animarray( "run_n_gun_f" ), %body, 1, 0, self.moveplaybackrate );
	self animscripts/run::aimingon();
}

restorepainonkillanimscript()
{
	self waittill( "killanimscript" );
	if ( isDefined( self ) && isalive( self ) )
	{
		self enable_pain();
		self.deathfunction = undefined;
	}
}

allowevasivemovement()
{
	if ( !self.a.allowevasivemovement )
	{
		return 0;
	}
	if ( self.animtype != "spetsnaz" )
	{
		return 0;
	}
	else
	{
		if ( self.iswounded )
		{
			return 0;
		}
	}
	return 1;
}

setruncycle()
{
	if ( is_rusher() )
	{
		if ( self.animtype == "spetsnaz" || self.lastanimtype == "spetsnaz" )
		{
			self.anim_array_cache[ "run_n_gun_f" ] = animarraypickrandom( "rusher_run_f_" + self.a.rushergunhand );
		}
	}
}

aimingon()
{
	self animscripts/shared::setaiminganims( %aim_2, %aim_4, %aim_6, %aim_8 );
	self setanim( %exposed_aiming, 1, 0 );
	self setanimknoblimited( animarray( "add_aim_up", "turn" ), 1, 0 );
	self setanimknoblimited( animarray( "add_aim_down", "turn" ), 1, 0 );
	self setanimknoblimited( animarray( "add_aim_left", "turn" ), 1, 0 );
	self setanimknoblimited( animarray( "add_aim_right", "turn" ), 1, 0 );
	self.a.isaiming = 1;
}

checkroomforanim( stepanim )
{
	if ( !self maymovefrompointtopoint( self.origin, getanimendpos( stepanim ) ) )
	{
/#
		recordline( self.origin, getanimendpos( stepanim ), ( 0, 1, 0 ), "Animscript", self );
#/
		return 0;
	}
/#
	recordline( self.origin, getanimendpos( stepanim ), ( 0, 1, 0 ), "Animscript", self );
#/
	return 1;
}

getdesiredsidestepdir( rushersidesteptype )
{
	rightchance = 0,333;
	if ( rushersidesteptype == "step" )
	{
		rightchance = 0,5;
	}
	randomroll = randomfloat( 1 );
	if ( self.a.rushersteppeddir < 0 )
	{
		self.rusherdesiredstepdir = "right";
	}
	else if ( self.a.rushersteppeddir > 0 )
	{
		self.rusherdesiredstepdir = "left";
	}
	else if ( randomroll < rightchance )
	{
		self.rusherdesiredstepdir = "right";
	}
	else if ( randomroll < ( rightchance * 2 ) )
	{
		self.rusherdesiredstepdir = "left";
	}
	else
	{
		self.rusherdesiredstepdir = "forward";
	}
	return self.rusherdesiredstepdir;
}
