#include animscripts/shared;
#include animscripts/run;
#include maps/_utility;
#include animscripts/anims;
#include animscripts/combat_utility;
#include common_scripts/utility;
#include animscripts/weaponlist;
#include animscripts/utility;

#using_animtree( "generic_human" );

main()
{
	self setflashbanged( 0 );
	self flamethrower_stop_shoot();
	self trackscriptstate( "React Main", "code" );
	self notify( "anim entered react" );
	self endon( "killanimscript" );
	animscripts/utility::initialize( "react" );
	self animmode( "gravity" );
	if ( newenemysurprisedreaction() )
	{
		return;
	}
	reactanim = getreactanim();
/#
	if ( getDvarInt( #"817739B8" ) == 1 )
	{
		record3dtext( "going to react", self.origin + vectorScale( ( 0, 1, 0 ), 70 ), ( 0, 1, 0 ), "Animscript" );
#/
	}
	if ( isDefined( reactanim ) )
	{
		playreactanim( reactanim );
	}
	return;
}

reactglobalsinit()
{
	reactinit();
	initreacttimers();
}

reactinit()
{
	anim.lastreactiontime = 0;
	anim.reactioncooldowntime = 3000;
	anim.reactiondistancesquaredmax = 1000000;
	anim.reactiondistancesquaredmin = 10000;
	anim.reactionawarenessdist = 32;
	anim.nextreactiontimeforaimin = 5000;
	anim.nextreactiontimeforaimax = 10000;
}

initreacttimers()
{
	self.a.newenemyreacttime = 0;
	self.a.eventreactiontime = 0;
}

playreactanim( reactanim )
{
	self.nextallowedreacttime = getTime() + randomintrange( anim.nextreactiontimeforaimin, anim.nextreactiontimeforaimax );
	if ( isplayer( self.attacker ) && self.team == "allies" )
	{
	}
	else
	{
		anim.lastreactiontime = getTime();
	}
	self.a.pose = "stand";
	self setflaggedanimknoballrestart( "reactAnim", reactanim, %body, 1, 0,1, 1 );
	if ( animhasnotetrack( reactanim, "start_aim" ) )
	{
		self thread notifystartaim( "reactAnim" );
		self endon( "start_aim" );
	}
	self thread doreactnotetracks( "reactAnim" );
	reaction_blendout( reactanim );
}

reaction_blendout( reactanim )
{
	time = getanimlength( reactanim );
	wait ( time - 0,2 );
	nextanim = animscripts/run::getrunanim();
	self clearanim( %body, 0,2 );
	self setflaggedanimrestart( "run_anim", nextanim, 1, 0,2 );
}

notifystartaim( animflag )
{
	self endon( "killanimscript" );
	self waittillmatch( animflag );
	return "start_aim";
	self notify( "start_aim" );
}

shouldreact()
{
/#
	assert( isDefined( self.reactorigin ) );
#/
/#
	self thread draweventpointanddir( self.reactorigin, undefined, ( 0, 1, 0 ) );
	if ( getDvarInt( #"3B5BF640" ) )
	{
		return 1;
#/
	}
	if ( self.a.disablereact )
	{
		return 0;
	}
	if ( weaponisgasweapon( self.weapon ) )
	{
		return 0;
	}
	if ( self.a.pose == "prone" )
	{
		return 0;
	}
	if ( isDefined( self.covernode ) )
	{
		return 0;
	}
	if ( self.ignoreall && !isDefined( self.specialreact ) )
	{
		return 0;
	}
	if ( isDefined( self.attacker ) && self.attacker isvehicle() )
	{
		return 0;
	}
	if ( self.a.script == "move" && self.lookaheaddist < 250 )
	{
		return 0;
	}
	if ( isDefined( self.a.runonlyreact ) && self.a.runonlyreact )
	{
		if ( self.a.script != "move" )
		{
			return 0;
		}
	}
	if ( self animscripts/run::shouldtacticalwalk() )
	{
		return 0;
	}
	reactanim = getreactanim();
	if ( !isDefined( reactanim ) )
	{
		return 0;
	}
	if ( self.team == "allies" && isDefined( self.attacker ) && isplayer( self.attacker ) )
	{
		dist = distancesquared( self.attacker.origin, self.origin );
		if ( dist < anim.reactiondistancesquaredmax && dist > anim.reactiondistancesquaredmin )
		{
			if ( distancesquared( self.reactorigin, self.origin ) < 16384 )
			{
				forwardvec = anglesToForward( self.angles );
				dirtoreactorigin = vectornormalize( self.reactorigin - self.origin );
				isreactoriginfront = vectordot( dirtoreactorigin, forwardvec ) >= 0;
				if ( isreactoriginfront && sighttracepassed( self geteye(), self.reactorigin, 0, undefined ) )
				{
					return 1;
				}
			}
		}
	}
	if ( anim.lastreactiontime == 0 || getTime() > ( anim.lastreactiontime + anim.reactioncooldowntime ) && randomint( 100 ) > 40 )
	{
		dist = distancesquared( self.attacker.origin, self.origin );
		if ( dist < anim.reactiondistancesquaredmax && dist > anim.reactiondistancesquaredmin )
		{
			if ( sighttracepassed( self geteye(), self.reactorigin, 0, undefined ) )
			{
				return 1;
			}
		}
	}
	return 0;
}

getreactanim()
{
	reactanim = undefined;
	location = geteventlocationinfo();
/#
	self thread draweventpointanddir( self.reactorigin, location, ( 0, 1, 0 ) );
#/
	if ( self.team == "allies" && isDefined( self.attacker ) )
	{
		friendlyreaction = isplayer( self.attacker );
	}
	if ( self.a.pose == "stand" && self.a.movement == "run" && self getmotionangle() < 60 && self getmotionangle() > -60 )
	{
		reactanim = getrunningforwardreactanim( location, friendlyreaction );
		if ( isDefined( reactanim ) )
		{
			return reactanim;
		}
	}
	return reactanim;
}

getreactaniminternal( location )
{
	reactarray = [];
	type = "exposed";
	reactarray[ reactarray.size ] = animarray( ( type + "_" ) + location, "react" );
/#
	assert( reactarray.size > 0, reactarray.size );
#/
	return reactarray[ randomint( reactarray.size ) ];
}

getrunningforwardreactanim( location, friendlyreaction )
{
	reactarray = [];
	type = "run";
	if ( self.sprint )
	{
		type = "sprint";
	}
	if ( is_true( friendlyreaction ) )
	{
		reactarray[ reactarray.size ] = animarray( type + "_lower_torso_stop", "react" );
	}
	else if ( issubstr( location, "upper" ) || issubstr( location, "head" ) )
	{
		reactarray[ reactarray.size ] = animarray( type + "_head", "react" );
	}
	else
	{
		if ( cointoss() )
		{
			reactarray[ reactarray.size ] = animarray( type + "_lower_torso_fast", "react" );
		}
		else
		{
			reactarray[ reactarray.size ] = animarray( type + "_lower_torso_stop", "react" );
		}
	}
	reactarray = removeblockedanims( reactarray );
	if ( reactarray.size > 0 )
	{
		return reactarray[ randomint( reactarray.size ) ];
	}
	else
	{
		return undefined;
	}
}

geteventlocationinfo()
{
/#
	assert( isDefined( self.reactorigin ) );
#/
	position_info = calculatelocationinfo( self.reactorigin );
	return position_info;
}

calculatelocationinfo( point )
{
	direction = getpointdirection( point );
	pos = self gettagorigin( "j_neck" );
	tag_neck_dist = distancefromtagorigin( pos );
	pos = self gettagorigin( "j_mainroot" );
	tag_main_root_dist = distancefromtagorigin( pos );
	point_dist = distancefromtagorigin( ( self.origin[ 0 ], self.origin[ 1 ], point[ 2 ] ) );
	if ( point_dist < tag_main_root_dist )
	{
		location = direction + "_lower_torso";
	}
	else if ( point_dist < tag_neck_dist )
	{
		location = direction + "_upper_torso";
	}
	else
	{
		location = direction + "_head";
	}
	return location;
}

getpointdirection( point )
{
	closestpointdir = point - self.origin;
	forwarddir = anglesToRight( self.angles );
	dotproduct = vectordot( forwarddir, closestpointdir );
	if ( dotproduct > 0 )
	{
		side = "right";
	}
	else
	{
		side = "left";
	}
	return side;
}

distancefromtagorigin( org )
{
	return distancesquared( self.origin, org );
}

removeblockedanims( array )
{
	newarray = [];
	index = 0;
	while ( index < array.size )
	{
		localdeltavector = getmovedelta( array[ index ], 0, 1 );
		endpoint = self localtoworldcoords( localdeltavector );
		if ( self maymovetopoint( endpoint ) )
		{
			newarray[ newarray.size ] = array[ index ];
		}
		index++;
	}
	return newarray;
}

doreactnotetracks( flagname )
{
	self notify( "stop_DoNotetracks" );
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "stop_DoNotetracks" );
	self animscripts/shared::donotetracks( flagname );
}

canreacttonewenemyagain()
{
	if ( !isDefined( self.a.newenemyreacttime ) )
	{
		return 1;
	}
	if ( self.a.newenemyreacttime )
	{
		return ( getTime() - self.a.newenemyreacttime ) > 2000;
	}
}

newenemyreactionanim()
{
	self endon( "death" );
	self endon( "endNewEnemyReactionAnim" );
	self.a.newenemyreacttime = getTime();
	reactanim = self getnewenemyreactionanim();
	if ( !isDefined( reactanim ) )
	{
		return 0;
	}
	self clearanim( %root, 0,2 );
	self setflaggedanimknobrestart( "reactanim", reactanim, 1, 0,2, 1 );
	self animscripts/shared::donotetracks( "reactanim" );
	self notify( "newEnemyReactionDone" );
	return 1;
}

getnewenemyreactionanim()
{
	reactanim = undefined;
	if ( self nearclaimnodeandangle() )
	{
		if ( !animarrayanyexist( self.a.prevscript + "_ne" ) )
		{
			return reactanim;
		}
		nodeforward = anglesToForward( self.node.angles );
		dirtoreactiontarget = vectornormalize( self.newenemyreactionpos - self.origin );
		if ( vectordot( nodeforward, dirtoreactiontarget ) < -0,5 )
		{
			self orientmode( "face current" );
			reactanim = animarraypickrandom( self.a.prevscript + "_ne" );
		}
	}
	if ( !isDefined( reactanim ) )
	{
		reactanimarray = animarray( "combat_ne" );
		if ( isDefined( self.enemy ) && distancesquared( self.enemy.origin, self.newenemyreactionpos ) < 65536 )
		{
			self orientmode( "face enemy" );
		}
		else
		{
			self orientmode( "face point", self.newenemyreactionpos );
		}
		if ( self.a.pose == "crouch" )
		{
			dirtoreactiontarget = vectornormalize( self.newenemyreactionpos - self.origin );
			forward = anglesToForward( self.angles );
			if ( vectordot( forward, dirtoreactiontarget ) < -0,5 )
			{
				self orientmode( "face current" );
				reactanimarray = animarray( "cover_crouch_ne" );
			}
		}
		reactanim = reactanimarray[ randomint( reactanimarray.size ) ];
	}
	return reactanim;
}

newenemysurprisedreaction()
{
	self endon( "death" );
	if ( isDefined( self.a.disablereact ) && self.a.disablereact )
	{
		return 0;
	}
	if ( self weaponanims() == "pistol" )
	{
		return 0;
	}
	if ( !self.newenemyreaction )
	{
		return 0;
	}
	if ( !canreacttonewenemyagain() )
	{
		return 0;
	}
	if ( self.a.pose == "prone" || self.a.pose == "back" )
	{
		return 0;
	}
	self animmode( "gravity" );
	if ( isDefined( self.enemy ) )
	{
		return newenemyreactionanim();
	}
}

end_script()
{
}

draweventpointanddir( position, location, color )
{
/#
	self endon( "death" );
	current_time = getTime();
	if ( !getDvarInt( #"817739B8" ) )
	{
		return;
	}
	if ( isDefined( location ) )
	{
		recordenttext( "Location - " + location, self, level.color_debug[ "white" ], "Animscript" );
	}
	while ( 1 )
	{
		drawdebugcross( position, 1, color, 0,05 );
		if ( ( getTime() - current_time ) > 2000 )
		{
			return;
		}
		else
		{
			wait 0,05;
#/
		}
	}
}

debugline( frompoint, topoint, color, durationframes )
{
/#
	self endon( "death" );
	i = 0;
	while ( i < ( durationframes * 20 ) )
	{
		line( frompoint, topoint, color );
		recordline( frompoint, topoint, color, "Animscript", self );
		wait 0,05;
		i++;
#/
	}
}

drawdebugcross( atpoint, radius, color, durationframes )
{
/#
	self endon( "death" );
	atpoint_high = atpoint + ( 0, 0, radius );
	atpoint_low = atpoint + ( 0, 0, -1 * radius );
	atpoint_left = atpoint + ( 0, radius, 0 );
	atpoint_right = atpoint + ( 0, -1 * radius, 0 );
	atpoint_forward = atpoint + ( radius, 0, 0 );
	atpoint_back = atpoint + ( -1 * radius, 0, 0 );
	thread debugline( atpoint_high, atpoint_low, color, durationframes );
	thread debugline( atpoint_left, atpoint_right, color, durationframes );
	thread debugline( atpoint_forward, atpoint_back, color, durationframes );
#/
}
