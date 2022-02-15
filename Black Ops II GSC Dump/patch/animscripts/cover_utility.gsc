#include animscripts/combat;
#include animscripts/weaponlist;
#include maps/_dds;
#include animscripts/cover_corner;
#include animscripts/debug;
#include common_scripts/utility;
#include animscripts/utility;
#include animscripts/shared;
#include animscripts/anims;

#using_animtree( "generic_human" );

blindfire()
{
	if ( !animarrayanyexist( "blind_fire" ) )
	{
/#
		self animscripts/debug::debugpopstate( undefined, "no blind fire anim" );
#/
		return 0;
	}
	blindfiremodes = [];
	blindfiremodes[ blindfiremodes.size ] = "blind_fire";
	if ( self.a.script != "cover_left" && self.a.script != "cover_right" && self.a.script == "cover_pillar" && !aihasonlypistol() )
	{
		if ( self.a.pose == "crouch" || self.a.pose == "stand" && self.a.script == "cover_pillar" )
		{
			modes = self.covernode getvalidcoverpeekouts();
			if ( isinarray( modes, "over" ) && animarrayanyexist( "blind_over" ) )
			{
				blindfiremodes[ blindfiremodes.size ] = "blind_over";
			}
		}
		if ( self.a.pose == "stand" )
		{
			animscripts/cover_corner::setstepoutanimspecial( "blindfire" );
		}
	}
	blindfiremode = blindfiremodes[ randomintrange( 0, blindfiremodes.size ) ];
	if ( self.a.script == "cover_stand" || self.a.script == "cover_crouch" )
	{
		pitch = getshootpospitch( self.covernode.origin + getnodeoffset( self.covernode ) );
		if ( pitch > 10 )
		{
/#
			self animscripts/debug::debugpopstate( undefined, "can't blind fire at a target below" );
#/
			return 0;
		}
	}
	self animmode( "zonly_physics" );
	self.keepclaimednodeifvalid = 1;
	self.a.cornermode = "blindfire";
	self.a.prevattack = self.a.cornermode;
	blindfireanim = animarraypickrandom( blindfiremode );
	self setflaggedanimknoballrestart( blindfiremode, blindfireanim, %body, 1, 0,2, 1 );
	self animscripts/shared::updatelaserstatus( 1, 1 );
	if ( canuseblindaiming( blindfiremode ) && !aihasonlypistol() )
	{
		self thread startblindaiming( blindfireanim, blindfiremode );
		self thread stopblindaiming( blindfireanim, blindfiremode );
	}
	else
	{
		stopblindaiming();
	}
	self maps/_dds::dds_notify( "react_cover", self.team == "allies" );
	self animscripts/shared::donotetracks( blindfiremode );
	self.keepclaimednodeifvalid = 0;
	self animscripts/shared::updatelaserstatus( 0 );
	waittillframeend;
	return 1;
}

canuseblindaiming( blindfiremode )
{
/#
	if ( getDvarInt( #"5BDF0C62" ) == 1 )
	{
		return 0;
#/
	}
	if ( self.a.script == "cover_pillar" && blindfiremode == "blind_over" )
	{
		return 0;
	}
	blindfireaimexist = animarrayanyexist( blindfiremode + "_add_aim_up" );
	if ( blindfireaimexist && shootposoutsidelegalyawrange() )
	{
		return 1;
	}
	return 0;
}

startblindaiming( aimanim, type )
{
	self animscripts/shared::setaiminganims( %blind_aim_2, %blind_aim_4, %blind_aim_6, %blind_aim_8 );
	self animscripts/shared::setanimaimweight( 1, 0 );
	if ( animhasnotetrack( aimanim, "start_aim" ) )
	{
		self waittillmatch( type );
		return "start_aim";
	}
	playadditiveaiminganims( type + "_add", 0,2 );
	self animscripts/shared::trackloopstart();
}

getanimaimlimit( aimanim, defaultlimit )
{
	if ( !isDefined( defaultlimit ) )
	{
		defaultlimit = 20;
	}
	aimlimit = defaultlimit;
	notetracks = getnotetracksindelta( aimanim, 0, 1 );
	_a127 = notetracks;
	_k127 = getFirstArrayKey( _a127 );
	while ( isDefined( _k127 ) )
	{
		note = _a127[ _k127 ];
/#
		assert( isDefined( note[ 1 ] ) );
#/
		if ( issubstr( note[ 1 ], "aim_limit" ) )
		{
			tokens = strtok( note[ 1 ], " " );
			if ( isDefined( tokens ) && tokens.size > 1 )
			{
				aimlimit = tokens[ 1 ];
				break;
			}
		}
		else
		{
			_k127 = getNextArrayKey( _a127, _k127 );
		}
	}
	return int( aimlimit );
}

stopblindaiming( fireanim, animname )
{
	self endon( "death" );
	self endon( "killanimscript" );
	if ( isDefined( fireanim ) && isDefined( animname ) )
	{
		if ( animhasnotetrack( fireanim, "stop_aim" ) )
		{
			self waittillmatch( animname );
			return "stop_aim";
		}
		else
		{
			self waittillmatch( animname );
			return "end";
		}
	}
	self animscripts/shared::stoptracking();
	self animscripts/shared::setanimaimweight( 0, 0 );
	self clearanim( %blind_aim_2, 0,2 );
	self clearanim( %blind_aim_4, 0,2 );
	self clearanim( %blind_aim_6, 0,2 );
	self clearanim( %blind_aim_8, 0,2 );
}

canblindfire()
{
	if ( self.a.atconcealmentnode )
	{
		return 0;
	}
	if ( self.weaponclass == "mg" )
	{
		return 0;
	}
	if ( isDefined( self.disable_blindfire ) && self.disable_blindfire == 1 )
	{
		return 0;
	}
	if ( isDefined( self.node ) && isDefined( self.node.script_dontblindfire ) )
	{
		return 0;
	}
	if ( !animscripts/weaponlist::usingautomaticweapon() && !usingpistol() )
	{
		return 0;
	}
	return 1;
}

canrambo()
{
	ramboanimsexist = animarrayanyexist( "rambo" );
/#
	if ( shouldforcebehavior( "rambo" ) )
	{
		return ramboanimsexist;
#/
	}
	if ( self.team == "allies" )
	{
		return 0;
	}
	if ( isDefined( self.covernode.script_norambo ) || self.covernode.script_norambo && isDefined( level.norambo ) )
	{
		return 0;
	}
	if ( !animscripts/weaponlist::usingautomaticweapon() )
	{
		return 0;
	}
	if ( ramboanimsexist )
	{
		return 1;
	}
	return 0;
}

debugrambooutposition( rambooutpos )
{
/#
	if ( getDvar( #"7927E91F" ) != "1" )
	{
		return;
	}
	self endon( "death" );
	i = 0;
	while ( i < 600 )
	{
		recordline( self.origin, rambooutpos, ( 1, 1, 1 ), "Animscript", self );
		i++;
#/
	}
}

canswitchsides()
{
	if ( !self.a.atpillarnode )
	{
		return 0;
	}
	if ( self usingpistol() )
	{
		return 0;
	}
	return 1;
}

turntomatchnodedirection( nodeangleoffset )
{
	if ( isDefined( self.node ) )
	{
		node = self.node;
		absrelyaw = abs( angleClamp180( self.angles[ 1 ] - ( node.angles[ 1 ] + nodeangleoffset ) ) );
		if ( self.a.pose == "stand" && node gethighestnodestance() != "stand" )
		{
			if ( absrelyaw > 45 && absrelyaw < 90 )
			{
				self orientmode( "face angle", self.angles[ 1 ] );
			}
			else
			{
				self orientmode( "face current" );
			}
			standtocrouchanim = animarray( "stand_2_crouch", "combat" );
			notetime = getnotetracktimes( standtocrouchanim, "anim_pose = "crouch"" )[ 0 ];
			notetime = min( 1, notetime * 1,1 );
			time = ( notetime * getanimlength( standtocrouchanim ) ) / 1,5;
			self setflaggedanimknoballrestart( "crouchanim", standtocrouchanim, %body, 1, 0,2, 1,5 );
			self donotetracksfortime( time, "crouchanim" );
			self clearanim( %body, 0,2 );
		}
		self orientmode( "face angle", self.angles[ 1 ] );
		relyaw = angleClamp180( self.angles[ 1 ] - ( node.angles[ 1 ] + nodeangleoffset ) );
		if ( abs( relyaw ) > 45 )
		{
			self.turnthreshold = 45;
			self.turntomatchnode = 1;
			animscripts/combat::turntofacerelativeyaw( relyaw );
			self.turntomatchnode = 0;
		}
	}
}

getrandomcovermode( modes )
{
	if ( modes.size == 0 )
	{
		return undefined;
	}
	if ( modes.size == 1 )
	{
		return modes[ 0 ];
	}
	while ( isDefined( self.a.prevattack ) && randomint( 100 ) > 20 )
	{
		_a292 = modes;
		i = getFirstArrayKey( _a292 );
		while ( isDefined( i ) )
		{
			mode = _a292[ i ];
			if ( mode == self.a.prevattack )
			{
				if ( i < ( modes.size - 1 ) )
				{
					modes[ i ] = modes[ modes.size - 1 ];
				}
				break;
			}
			else
			{
				i = getNextArrayKey( _a292, i );
			}
		}
	}
	return modes[ randomint( modes.size ) ];
}

playadditiveaiminganims( prefix, transtime, defaultaimlimit )
{
	aimupanim = animarray( prefix + "_aim_up" );
	aimdownanim = animarray( prefix + "_aim_down" );
	aimleftanim = animarray( prefix + "_aim_left" );
	aimrightanim = animarray( prefix + "_aim_right" );
	self.rightaimlimit = getanimaimlimit( aimrightanim, defaultaimlimit );
	self.leftaimlimit = getanimaimlimit( aimleftanim, defaultaimlimit ) * -1;
	self.upaimlimit = getanimaimlimit( aimupanim, defaultaimlimit );
	self.downaimlimit = getanimaimlimit( aimdownanim, defaultaimlimit ) * -1;
	self setanimknoblimited( aimupanim, 1, transtime );
	self setanimknoblimited( aimdownanim, 1, transtime );
	self setanimknoblimited( aimleftanim, 1, transtime );
	self setanimknoblimited( aimrightanim, 1, transtime );
}

getshootpospitch( frompos )
{
	shootpos = getenemyeyepos();
	return angleClamp180( vectorToAngle( shootpos - frompos )[ 0 ] );
}

resetanimspecial( delay )
{
	self endon( "killanimscript" );
	if ( isDefined( delay ) && delay > 0 )
	{
		wait delay;
	}
	self.a.special = "none";
}

canthrowgrenade()
{
	if ( self.script_forcegrenade )
	{
		return 1;
	}
	if ( self.weapon == "mg42" || self.grenadeammo <= 0 )
	{
		return 0;
	}
	if ( weaponisgasweapon( self.weapon ) )
	{
		return 0;
	}
	return 1;
}
