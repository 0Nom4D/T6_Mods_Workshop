#include animscripts/utility;
#include common_scripts/utility;

maindebug()
{
/#
	level thread sendaimonitorkeys();
#/
}

sendaimonitorkeys()
{
/#
	while ( 1 )
	{
		dvarval = getDvar( "ai_monitorNeedsKeys" );
		if ( !isDefined( dvarval ) )
		{
			println( "DVAR NOT DEFINED" );
		}
		else
		{
			if ( int( dvarval ) == 1 )
			{
				sendentinfokeys();
				sendanimscriptkeys();
				sendcodestatekeys();
				setdvar( "ai_monitorNeedsKeys", 0 );
			}
		}
		wait 0,05;
#/
	}
}

sendentinfokeys()
{
/#
	keys = array( "Targetname", "Script_noteworthy", "Enemy", "&newline", "Health", "Goal Radius", "&newline", "Current Weapon", "Primary Weapon", "Secondary Weapon", "Sidearm", "&newline", "Current Stance", "Allowed Stances", "&newline", "Ignore All", "Ignore Me", "&newline", "disableTurns", "disableArrivals", "disableExits", "disablePain", "ignoreSuppression", "&newline", "allowShooting", "grenadeAwareness", "takeDamage", "&newline", "CQB", "Heat", "Sprint", "&newline", "ScriptOrientMode", "CodeOrientMode", "MoveMode", "FixedNode", "&newline", "Movement", "PathEnemyFightDist", "WeaponClass" );
	keynames = "";
	i = 0;
	while ( i < keys.size )
	{
		keynames += keys[ i ] + "\n";
		i++;
	}
	sendaiscriptkeys( "entinfo", keynames );
#/
}

getstancestring()
{
/#
	stancestring = "";
	if ( self isstanceallowed( "stand" ) )
	{
		stancestring += "S";
	}
	if ( self isstanceallowed( "crouch" ) )
	{
		stancestring += "C";
	}
	if ( self isstanceallowed( "prone" ) )
	{
		stancestring += "P";
	}
	return stancestring;
#/
}

getval( variable )
{
/#
	if ( isDefined( variable ) )
	{
		return variable;
	}
	else
	{
		return "undefined";
#/
	}
}

sendentinfovals()
{
/#
	if ( !shouldmonitorai() )
	{
		return;
	}
	if ( isDefined( self.enemy ) )
	{
		enemynum = self.enemy getentitynumber();
	}
	else
	{
		enemynum = undefined;
	}
	if ( isDefined( self.cqb ) && self.cqb )
	{
		vals = array( getval( self.targetname ), getval( self.script_noteworthy ), getval( enemynum ), getval( self.health ), getval( self.goalradius ), getval( self.weapon ), getval( self.primaryweapon ), getval( self.secondaryweapon ), getval( self.sidearm ), getval( self.a.pose ), getval( self getstancestring() ), getval( self.ignoreall ), getval( self.ignoreme ), getval( self.disableturns ), getval( self.disablearrivals ), getval( self.disableexits ), getval( self.diablepain ), getval( self.ignoresuppression ), getval( self.a.allow_shooting ), getval( self.grenadeawareness ), getval( self.takedamage ), getval( self animscripts/utility::weaponanims() != "pistol" ), getval( self.heat ), getval( self.sprint ), getval( self getorientmode( "script" ) ), getval( self getorientmode( "code" ) ), getval( self.movemode ), getval( self.fixednode ), getval( self.a.movement ), getval( self.pathenemyfightdist ), getval( self.weaponclass ) );
	}
	valstring = "";
	i = 0;
	while ( i < vals.size )
	{
		valstring += vals[ i ] + "\n";
		i++;
	}
	self sendaiscriptvals( "entinfo", valstring );
#/
}

sendanimscriptkeys()
{
/#
	sendaiscriptkeys( "animscript", "" );
#/
}

sendcodestatekeys()
{
/#
	sendaiscriptkeys( "codestate", "" );
#/
}

isdebugon()
{
/#
	if ( getdebugdvarint( "animDebug" ) != 1 )
	{
		if ( isDefined( anim.debugent ) )
		{
			return anim.debugent == self;
#/
		}
	}
}

drawdebuglineinternal( frompoint, topoint, color, durationframes )
{
/#
	i = 0;
	while ( i < durationframes )
	{
		line( frompoint, topoint, color );
		wait 0,05;
		i++;
#/
	}
}

drawdebugline( frompoint, topoint, color, durationframes )
{
/#
	if ( isdebugon() )
	{
		thread drawdebuglineinternal( frompoint, topoint, color, durationframes );
#/
	}
}

debugline( frompoint, topoint, color, durationframes )
{
/#
	i = 0;
	while ( i < ( durationframes * 20 ) )
	{
		line( frompoint, topoint, color );
		wait 0,05;
		i++;
#/
	}
}

drawdebugcross( atpoint, radius, color, durationframes )
{
/#
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

updatedebuginfo()
{
/#
	self endon( "death" );
	self.debuginfo = spawnstruct();
	self.debuginfo.enabled = getDvarInt( "ai_debugAnimscript" ) > 0;
	debugclearstate();
	while ( 1 )
	{
		waittillframeend;
		updatedebuginfointernal();
		sendentinfovals();
		wait 0,05;
#/
	}
}

updatedebuginfointernal()
{
/#
	if ( isDefined( anim.debugent ) && anim.debugent == self )
	{
		doinfo = 1;
	}
	else
	{
		doinfo = getDvarInt( "ai_debugAnimscript" ) > 0;
		if ( doinfo )
		{
			ai_entnum = getDvarInt( "ai_debugEntIndex" );
			if ( ai_entnum > -1 && ai_entnum != self getentitynumber() )
			{
				doinfo = 0;
			}
		}
		if ( !self.debuginfo.enabled && doinfo )
		{
			self.debuginfo.shouldclearonanimscriptchange = 1;
		}
		self.debuginfo.enabled = doinfo;
	}
	if ( doinfo )
	{
		drawdebuginfo( doinfo );
#/
	}
}

drawdebuginfo( debuglevel )
{
/#
	allowedstancesstr = "";
	facemotion = "";
	if ( self isstanceallowed( "stand" ) )
	{
		allowedstancesstr += "s";
	}
	if ( self isstanceallowed( "crouch" ) )
	{
		allowedstancesstr += "c";
	}
	if ( self isstanceallowed( "prone" ) )
	{
		allowedstancesstr += "p";
	}
	drawdebugenttext( "(" + self getentitynumber() + ") : " + self.a.pose + " (" + allowedstancesstr + ") : " + self.a.movement + " : " + self.movemode + " : " + self.goalradius + " : " + self.pathenemyfightdist + " : " + self.subclass + " : " + self.animtype + " : KCM" + self.keepclaimednode + " : KCMV" + self.keepclaimednodeifvalid, self, level.color_debug[ "cyan" ], "Animscript" );
	extrainfostr = "";
	if ( self.combatmode != "cover" )
	{
		extrainfostr += self.combatmode + " ";
	}
	if ( self.ignoreall )
	{
		extrainfostr += "ignoreAll ";
	}
	if ( self.ignoreme )
	{
		extrainfostr += "ignoreMe ";
	}
	if ( self.pacifist )
	{
		extrainfostr += "pacifist ";
	}
	if ( self.ignoresuppression )
	{
		extrainfostr += "ignoreSuppression ";
	}
	if ( isDefined( self.a.allow_shooting ) && !self.a.allow_shooting )
	{
		extrainfostr += "!allow_shooting ";
	}
	if ( isDefined( self.cqb ) && self.cqb && self animscripts/utility::weaponanims() != "pistol" )
	{
		extrainfostr += "cqb ";
	}
	if ( isDefined( self.heat ) && self.heat )
	{
		extrainfostr += "heat ";
	}
	if ( isDefined( self.walk ) && self.walk )
	{
		extrainfostr += "walk ";
	}
	if ( isDefined( self.sprint ) && self.sprint )
	{
		extrainfostr += "sprint ";
	}
	if ( isDefined( self.disablearrivals ) && self.disablearrivals )
	{
		extrainfostr += "!arrivals ";
	}
	if ( isDefined( self.disableexits ) && self.disableexits )
	{
		extrainfostr += "!exits ";
	}
	if ( self.iswounded )
	{
		extrainfostr += "wounded ";
	}
	if ( self.grenadeawareness == 0 )
	{
		extrainfostr += "!grenadeAwareness ";
	}
	if ( !self.takedamage )
	{
		extrainfostr += "!takedamage ";
	}
	if ( !self.allowpain )
	{
		extrainfostr += "!allowPain ";
	}
	if ( self.delayeddeath )
	{
		extrainfostr += "delayedDeath ";
	}
	if ( isDefined( self.disableturns ) && self.disableturns )
	{
		extrainfostr += "disableTurns ";
	}
	if ( isDefined( self.a.script_suffix ) )
	{
		extrainfostr += "CD-" + self.a.script_suffix + " ";
	}
	if ( isDefined( self.a.special ) )
	{
		extrainfostr += self.a.special;
	}
	if ( isDefined( self.blockingpain ) )
	{
		extrainfostr += " blockingpain-" + self.blockingpain;
	}
	if ( isDefined( self.reacquire_state ) )
	{
		extrainfostr += " reacquire-" + self.reacquire_state;
	}
	extrainfostr += "\n";
	if ( isDefined( self.weaponclass ) )
	{
		extrainfostr += " WeaponClass-" + self.weaponclass;
	}
	if ( isDefined( self.bulletsinclip ) )
	{
		extrainfostr += " BulletsInClip-" + self.bulletsinclip;
	}
	if ( isDefined( self.a.rockets ) )
	{
		extrainfostr += " Rockets-" + self.a.rockets;
	}
	if ( extrainfostr != "" )
	{
		drawdebugenttext( extrainfostr, self, level.color_debug[ "grey" ], "Animscript" );
	}
	drawdebugenttext( ( self.primaryweapon + " : " ) + self.secondaryweapon + " : " + self.sidearm + " (" + self.weapon + ")", self, level.color_debug[ "grey" ], "Animscript" );
	i = 0;
	while ( i < self.debuginfo.states.size )
	{
		statestring = self.debuginfo.states[ i ].statename;
		if ( debuglevel > 1 )
		{
			statestring += " (" + ( ( getTime() - self.debuginfo.states[ i ].statetime ) / 1000 ) + ")";
		}
		if ( isDefined( self.debuginfo.states[ i ].extrainfo ) )
		{
			statestring += ": " + self.debuginfo.states[ i ].extrainfo;
		}
		linecolor = level.color_debug[ "white" ];
		if ( !self.debuginfo.states[ i ].statevalid )
		{
			statestring += " [end";
			linecolor = ( 1, 0,75, 0,75 );
			if ( isDefined( self.debuginfo.states[ i ].exitreason ) )
			{
				statestring += ": " + self.debuginfo.states[ i ].exitreason;
			}
			statestring += "]";
		}
		else
		{
			if ( self.debuginfo.states[ i ].statetime == ( getTime() - 50 ) )
			{
				linecolor = ( 0,75, 1, 0,75 );
			}
		}
		drawdebugenttext( indent( self.debuginfo.states[ i ].statelevel ) + "-" + statestring, self, linecolor, "Animscript" );
		i++;
	}
	drawdebugenttext( " ", self, level.color_debug[ "grey" ], "Animscript" );
	debugcleanstatestack();
#/
}

drawdebugenttext( text, ent, color, channel )
{
/#
	assert( isDefined( ent ) );
	if ( !getDvarInt( #"0099037B" ) )
	{
		if ( !isDefined( ent.debuganimscripttime ) || getTime() > ent.debuganimscripttime )
		{
			ent.debuganimscriptlevel = 0;
			ent.debuganimscripttime = getTime();
		}
		indentlevel = vectorScale( vectorScale( ( 0, 0, 1 ), 10 ), ent.debuganimscriptlevel );
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 70 ) + indentlevel, text, color );
		ent.debuganimscriptlevel++;
	}
	else
	{
		recordenttext( text, ent, color, channel );
#/
	}
}

debugpushstate( statename, extrainfo )
{
/#
	if ( !getDvarInt( "ai_debugAnimscript" ) )
	{
		return;
	}
	ai_entnum = getDvarInt( "ai_debugEntIndex" );
	if ( ai_entnum > -1 && ai_entnum != self getentitynumber() )
	{
		return;
	}
	assert( isDefined( self.debuginfo.states ) );
	assert( isDefined( statename ) );
	state = spawnstruct();
	state.statename = statename;
	state.statelevel = self.debuginfo.statelevel;
	state.statetime = getTime();
	state.statevalid = 1;
	self.debuginfo.statelevel++;
	if ( isDefined( extrainfo ) )
	{
		state.extrainfo = extrainfo + " ";
	}
	self.debuginfo.states[ self.debuginfo.states.size ] = state;
#/
}

debugaddstateinfo( statename, extrainfo )
{
/#
	if ( !getDvarInt( "ai_debugAnimscript" ) )
	{
		return;
	}
	ai_entnum = getDvarInt( "ai_debugEntIndex" );
	if ( ai_entnum > -1 && ai_entnum != self getentitynumber() )
	{
		return;
	}
	assert( isDefined( self.debuginfo.states ) );
	if ( isDefined( statename ) )
	{
		i = self.debuginfo.states.size - 1;
		while ( i >= 0 )
		{
			assert( isDefined( self.debuginfo.states[ i ] ) );
			if ( self.debuginfo.states[ i ].statename == statename )
			{
				if ( !isDefined( self.debuginfo.states[ i ].extrainfo ) )
				{
					self.debuginfo.states[ i ].extrainfo = "";
				}
				self.debuginfo.states[ i ].extrainfo += extrainfo + " ";
				break;
			}
			else
			{
				i--;

			}
		}
	}
	else if ( self.debuginfo.states.size > 0 )
	{
		lastindex = self.debuginfo.states.size - 1;
		assert( isDefined( self.debuginfo.states[ lastindex ] ) );
		if ( !isDefined( self.debuginfo.states[ lastindex ].extrainfo ) )
		{
			self.debuginfo.states[ lastindex ].extrainfo = "";
		}
		self.debuginfo.states[ lastindex ].extrainfo += extrainfo + " ";
#/
	}
}

debugpopstate( statename, exitreason )
{
/#
	if ( !getDvarInt( "ai_debugAnimscript" ) || self.debuginfo.states.size <= 0 )
	{
		return;
	}
	ai_entnum = getDvarInt( "ai_debugEntIndex" );
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( ai_entnum > -1 && ai_entnum != self getentitynumber() )
	{
		return;
	}
	assert( isDefined( self.debuginfo.states ) );
	if ( isDefined( statename ) )
	{
		i = 0;
		while ( i < self.debuginfo.states.size )
		{
			if ( self.debuginfo.states[ i ].statename == statename && self.debuginfo.states[ i ].statevalid )
			{
				self.debuginfo.states[ i ].statevalid = 0;
				self.debuginfo.states[ i ].exitreason = exitreason;
				self.debuginfo.statelevel = self.debuginfo.states[ i ].statelevel;
				j = i + 1;
				while ( j < self.debuginfo.states.size && self.debuginfo.states[ j ].statelevel > self.debuginfo.states[ i ].statelevel )
				{
					self.debuginfo.states[ j ].statevalid = 0;
					j++;
				}
			}
			else i++;
		}
	}
	else i = self.debuginfo.states.size - 1;
	while ( i >= 0 )
	{
		if ( self.debuginfo.states[ i ].statevalid )
		{
			self.debuginfo.states[ i ].statevalid = 0;
			self.debuginfo.states[ i ].exitreason = exitreason;
			self.debuginfo.statelevel--;

			return;
		}
		else
		{
			i--;

#/
		}
	}
}

debugclearstate()
{
/#
	self.debuginfo.states = [];
	self.debuginfo.statelevel = 0;
	self.debuginfo.shouldclearonanimscriptchange = 0;
#/
}

debugshouldclearstate()
{
/#
	if ( isDefined( self.debuginfo ) && isDefined( self.debuginfo.shouldclearonanimscriptchange ) && self.debuginfo.shouldclearonanimscriptchange )
	{
		return 1;
	}
	return 0;
#/
}

debugcleanstatestack()
{
/#
	newarray = [];
	i = 0;
	while ( i < self.debuginfo.states.size )
	{
		if ( self.debuginfo.states[ i ].statevalid )
		{
			newarray[ newarray.size ] = self.debuginfo.states[ i ];
		}
		i++;
	}
	self.debuginfo.states = newarray;
#/
}

indent( depth )
{
/#
	indent = "";
	i = 0;
	while ( i < depth )
	{
		indent += " ";
		i++;
	}
	return indent;
#/
}
