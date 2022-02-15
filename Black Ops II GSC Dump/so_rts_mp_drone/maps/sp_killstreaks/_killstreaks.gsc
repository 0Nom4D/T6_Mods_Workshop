#include maps/_callbackglobal;
#include maps/sp_killstreaks/_killstreaks;
#include maps/sp_killstreaks/_killstreak_weapons;
#include common_scripts/utility;
#include maps/gametypes/_hud_util;
#include maps/_utility;

preload()
{
	level.killstreaks = [];
	level.killstreakweapons = [];
	level.menureferenceforkillstreak = [];
	level.numkillstreakreservedobjectives = 0;
	level.killstreakcounter = 0;
	level.spawnmaxs = ( 1, 0, 0 );
	level.spawnmins = ( 1, 0, 0 );
	level.globalkillstreakscalled = 0;
	if ( !isDefined( level.killstreakrounddelay ) )
	{
		level.killstreakrounddelay = 0;
	}
	if ( getDvar( "scr_allow_killstreak_building" ) == "" )
	{
		setdvar( "scr_allow_killstreak_building", "0" );
	}
	precachestring( &"MP_KILLSTREAK_N" );
	killstreak_setup();
	maps/sp_killstreaks/_remotemissile::preload();
}

init()
{
	level.killstreaksenabled = 1;
	level.actionslotpressed = ::isactionslotpressed;
	level.actionslot = 2;
	level.hardcoremode = 0;
	maps/gametypes/_gameobjects::init();
	maps/sp_killstreaks/_killstreakrules::init();
	maps/sp_killstreaks/_remotemissile::init();
	level.overrideactorkilled = ::callback_killstreakactorkilled;
	_a65 = getplayers();
	_k65 = getFirstArrayKey( _a65 );
	while ( isDefined( _k65 ) )
	{
		player = _a65[ _k65 ];
		player thread onplayerspawned();
		_k65 = getNextArrayKey( _a65, _k65 );
	}
	level thread onplayerconnect();
/#
	level thread killstreak_debug_think();
#/
}

isactionslotpressed()
{
	switch( level.actionslot )
	{
		case 1:
			return self actionslottwobuttonpressed();
		case 2:
			return self actionslottwobuttonpressed();
		case 3:
			return self actionslotthreebuttonpressed();
		case 4:
			return self actionslotfourbuttonpressed();
	}
	return 0;
}

iskillstreakregistered( killstreaktype )
{
/#
	assert( isDefined( killstreaktype ), "Cannot pass undefined as parameter" );
#/
	if ( !isDefined( level.killstreaks ) )
	{
		return 0;
	}
	if ( isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

registerkillstreak( killstreaktype, killstreakweapon, killstreakmenuname, killstreakusagekey, killstreakusefunction, killstreakdelaystreak, weaponholdallowed, killstreakstatsname )
{
/#
	assert( isDefined( killstreaktype ), "Can not register a killstreak without a valid type name." );
#/
/#
	assert( !isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak " + killstreaktype + " already registered" );
#/
/#
	assert( isDefined( killstreakusefunction ), "No use function defined for killstreak " + killstreaktype );
#/
	level.killstreaks[ killstreaktype ] = spawnstruct();
	level.killstreaks[ killstreaktype ].killstreaklevel = int( tablelookup( "sp/statsTable.csv", level.cac_creference, killstreakmenuname, level.cac_ccount ) );
	level.killstreaks[ killstreaktype ].usagekey = killstreakusagekey;
	level.killstreaks[ killstreaktype ].usefunction = killstreakusefunction;
	level.killstreaks[ killstreaktype ].menuname = killstreakmenuname;
	level.killstreaks[ killstreaktype ].delaystreak = killstreakdelaystreak;
	level.killstreaks[ killstreaktype ].allowassists = 0;
	if ( isDefined( killstreakweapon ) )
	{
/#
		assert( !isDefined( level.killstreakweapons[ killstreakweapon ] ), "Can not have a weapon associated with multiple killstreaks." );
#/
		precacheitem( killstreakweapon );
		level.killstreaks[ killstreaktype ].weapon = killstreakweapon;
		level.killstreakweapons[ killstreakweapon ] = killstreaktype;
	}
	if ( !isDefined( weaponholdallowed ) )
	{
		weaponholdallowed = 0;
	}
	if ( isDefined( killstreakstatsname ) )
	{
		level.killstreaks[ killstreaktype ].killstreakstatsname = killstreakstatsname;
	}
	level.killstreaks[ killstreaktype ].weaponholdallowed = weaponholdallowed;
	level.menureferenceforkillstreak[ killstreakmenuname ] = killstreaktype;
}

registerkillstreakstrings( killstreaktype, receivedtext, notusabletext, inboundtext, inboundnearplayertext )
{
/#
	assert( isDefined( killstreaktype ), "Can not register a killstreak without a valid type name." );
#/
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak needs to be registered before calling registerKillstreakStrings." );
#/
	level.killstreaks[ killstreaktype ].receivedtext = receivedtext;
	level.killstreaks[ killstreaktype ].notavailabletext = notusabletext;
	level.killstreaks[ killstreaktype ].inboundtext = inboundtext;
	level.killstreaks[ killstreaktype ].inboundnearplayertext = inboundnearplayertext;
	if ( isDefined( level.killstreaks[ killstreaktype ].receivedtext ) )
	{
		precachestring( level.killstreaks[ killstreaktype ].receivedtext );
	}
	if ( isDefined( level.killstreaks[ killstreaktype ].notavailabletext ) )
	{
		precachestring( level.killstreaks[ killstreaktype ].notavailabletext );
	}
	if ( isDefined( level.killstreaks[ killstreaktype ].inboundtext ) )
	{
		precachestring( level.killstreaks[ killstreaktype ].inboundtext );
	}
	if ( isDefined( level.killstreaks[ killstreaktype ].inboundnearplayertext ) )
	{
		precachestring( level.killstreaks[ killstreaktype ].inboundnearplayertext );
	}
}

registerkillstreakdialog( killstreaktype, receiveddialog, friendlystartdialog, friendlyenddialog, enemystartdialog, enemyenddialog, dialog )
{
/#
	assert( isDefined( killstreaktype ), "Can not register a killstreak without a valid type name." );
#/
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak needs to be registered before calling registerKillstreakDialog." );
#/
	level.killstreaks[ killstreaktype ].informdialog = receiveddialog;
	game[ "dialog" ][ killstreaktype + "_start" ] = friendlystartdialog;
	game[ "dialog" ][ killstreaktype + "_end" ] = friendlyenddialog;
	game[ "dialog" ][ killstreaktype + "_enemy_start" ] = enemystartdialog;
	game[ "dialog" ][ killstreaktype + "_enemy_end" ] = enemyenddialog;
	game[ "dialog" ][ killstreaktype ] = dialog;
}

registerkillstreakaltweapon( killstreaktype, weapon )
{
/#
	assert( isDefined( killstreaktype ), "Can not register a killstreak without a valid type name." );
#/
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak needs to be registered before calling registerKillstreakAltWeapon." );
#/
	if ( level.killstreaks[ killstreaktype ].weapon == weapon )
	{
		return;
	}
	if ( !isDefined( level.killstreaks[ killstreaktype ].altweapons ) )
	{
		level.killstreaks[ killstreaktype ].altweapons = [];
	}
	if ( !isDefined( level.killstreakweapons[ weapon ] ) )
	{
		level.killstreakweapons[ weapon ] = killstreaktype;
	}
	level.killstreaks[ killstreaktype ].altweapons[ level.killstreaks[ killstreaktype ].altweapons.size ] = weapon;
}

registerkillstreakdevdvar( killstreaktype, dvar )
{
/#
	assert( isDefined( killstreaktype ), "Can not register a killstreak without a valid type name." );
#/
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak needs to be registered before calling registerKillstreakDevDvar." );
#/
	level.killstreaks[ killstreaktype ].devdvar = dvar;
}

allowkillstreakassists( killstreaktype, allow )
{
	level.killstreaks[ killstreaktype ].allowassists = allow;
}

doesplayerhavekillstreak( killstreak )
{
	if ( !isDefined( self.pers ) )
	{
		return 0;
	}
	if ( !isDefined( self.pers[ "killstreaks" ] ) )
	{
		return 0;
	}
	i = 0;
	while ( i < self.pers[ "killstreaks" ].size )
	{
		if ( self.pers[ "killstreaks" ][ i ] == killstreak )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

iskillstreakavailable( killstreak )
{
	if ( isDefined( level.menureferenceforkillstreak[ killstreak ] ) )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

getkillstreakbymenuname( killstreak )
{
	return level.menureferenceforkillstreak[ killstreak ];
}

getkillstreakmenuname( killstreaktype )
{
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ) );
#/
	return level.killstreaks[ killstreaktype ].menuname;
}

drawline( start, end, timeslice, color )
{
/#
	drawtime = int( timeslice * 20 );
	time = 0;
	while ( time < drawtime )
	{
		line( start, end, ( 1, 0, 0 ), 0, 1 );
		wait 0,05;
		time++;
#/
	}
}

getkillstreaklevel( index, killstreak )
{
	killstreaklevel = level.killstreaks[ getkillstreakbymenuname( killstreak ) ].killstreaklevel;
	if ( getDvarInt( #"826EB3B9" ) == 2 )
	{
		if ( isDefined( self.killstreak[ index ] ) && killstreak == self.killstreak[ index ] )
		{
			killsrequired = getDvarInt( 2404036340 + index + 1 + "_kills" );
			if ( killsrequired )
			{
				killstreaklevel = getDvarInt( 2404036340 + index + 1 + "_kills" );
			}
		}
	}
	return killstreaklevel;
}

givekillstreakifstreakcountmatches( index, killstreak, streakcount )
{
	if ( !iskillstreaksstreakcountsenabled() )
	{
		return 0;
	}
/#
	if ( !isDefined( killstreak ) )
	{
		println( "Killstreak Undefined.\n" );
	}
	if ( isDefined( killstreak ) )
	{
		println( "Killstreak listed as." + killstreak + "\n" );
	}
	if ( !iskillstreakavailable( killstreak ) )
	{
		println( "Killstreak Not Available.\n" );
#/
	}
	hasalreadyearnedkillstreak = 0;
	if ( isDefined( killstreak ) && iskillstreakavailable( killstreak ) && !hasalreadyearnedkillstreak )
	{
		killstreaklevel = getkillstreaklevel( index, killstreak );
		if ( killstreaklevel == streakcount )
		{
			self givekillstreak( getkillstreakbymenuname( killstreak ), streakcount );
			self.pers[ "killstreaksEarnedThisKillstreak" ] = index + 1;
			return 1;
		}
	}
	return 0;
}

givekillstreakforstreak()
{
	if ( !iskillstreaksenabled() )
	{
		return;
	}
	if ( !isDefined( self.pers[ "totalKillstreakCount" ] ) )
	{
		self.pers[ "totalKillstreakCount" ] = 0;
	}
	given = 0;
	i = 0;
	while ( i < self.killstreak.size )
	{
		given |= givekillstreakifstreakcountmatches( i, self.killstreak[ i ], self.pers[ "totalKillstreakCount" ] );
		i++;
	}
}

isoneawayfromkillstreak()
{
	if ( !isDefined( self.pers[ "kill_streak_before_death" ] ) )
	{
		self.pers[ "kill_streak_before_death" ] = 0;
	}
	streakplusone = self.pers[ "kill_streak_before_death" ] + 1;
	if ( self hasperk( "specialty_killstreak" ) )
	{
		reduction = getDvarInt( "perk_killstreakReduction" );
		streakplusone += reduction;
	}
	oneaway = 0;
	killstreakcount = self.killstreak.size;
	killstreaknum = 0;
	while ( killstreaknum < killstreakcount )
	{
		oneaway |= doesstreakcountmatch( self.killstreak[ killstreaknum ], streakplusone );
		killstreaknum++;
	}
	return oneaway;
}

doesstreakcountmatch( killstreak, streakcount )
{
	if ( isDefined( killstreak ) && iskillstreakavailable( killstreak ) )
	{
		killstreaklevel = level.killstreaks[ getkillstreakbymenuname( killstreak ) ].killstreaklevel;
		if ( killstreaklevel == streakcount )
		{
			return 1;
		}
	}
	return 0;
}

streaknotify( streakval )
{
	self endon( "disconnect" );
	self waittill( "playerKilledChallengesProcessed" );
	wait 0,05;
	notifydata = spawnstruct();
	notifydata.titlelabel = &"MP_KILLSTREAK_N";
	notifydata.titletext = streakval;
	notifydata.iconheight = 32;
}

givekillstreak( killstreaktype, streak, suppressnotification, noxp )
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	had_to_delay = 0;
	killstreakgiven = 0;
	if ( isDefined( noxp ) )
	{
		if ( self givekillstreakinternal( killstreaktype, undefined, noxp ) )
		{
			killstreakgiven = 1;
			self addkillstreaktoqueue( level.killstreaks[ killstreaktype ].menuname, streak, killstreaktype, noxp );
		}
	}
	else
	{
		if ( self givekillstreakinternal( killstreaktype, noxp ) )
		{
			killstreakgiven = 1;
			self addkillstreaktoqueue( level.killstreaks[ killstreaktype ].menuname, streak, killstreaktype, noxp );
		}
	}
}

givekillstreakinternal( killstreaktype, do_not_update_death_count, noxp )
{
	if ( level.gameended )
	{
		return 0;
	}
	if ( !iskillstreaksenabled() )
	{
		return 0;
	}
	if ( !isDefined( killstreaktype ) )
	{
		return 0;
	}
	if ( !isDefined( level.killstreaks ) )
	{
		return 0;
	}
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return 0;
	}
	if ( !isDefined( self.pers ) )
	{
		self.pers = [];
	}
	if ( !isDefined( self.pers[ "killstreaks" ] ) )
	{
		self.pers[ "killstreaks" ] = [];
	}
	if ( !isDefined( self.pers[ "killstreak_has_been_used" ] ) )
	{
		self.pers[ "killstreak_has_been_used" ] = [];
	}
	if ( !isDefined( self.pers[ "killstreak_unique_id" ] ) )
	{
		self.pers[ "killstreak_unique_id" ] = [];
	}
	if ( !isDefined( self.pers[ "team" ] ) )
	{
		self.pers[ "team" ] = self.team;
	}
	self.pers[ "killstreaks" ][ self.pers[ "killstreaks" ].size ] = killstreaktype;
	self.pers[ "killstreak_unique_id" ][ self.pers[ "killstreak_unique_id" ].size ] = level.killstreakcounter;
	level.killstreakcounter++;
	if ( isDefined( noxp ) )
	{
		self.pers[ "killstreak_has_been_used" ][ self.pers[ "killstreak_has_been_used" ].size ] = noxp;
	}
	else
	{
		self.pers[ "killstreak_has_been_used" ][ self.pers[ "killstreak_has_been_used" ].size ] = 0;
	}
	weapon = getkillstreakweapon( killstreaktype );
	givekillstreakweapon( weapon );
	return 1;
}

addkillstreaktoqueue( menuname, streakcount, hardpointtype, nonotify )
{
	killstreaktablenumber = level.killstreakindices[ menuname ];
/#
	assert( isDefined( killstreaktablenumber ) );
#/
	if ( !isDefined( killstreaktablenumber ) )
	{
		return;
	}
	if ( isDefined( nonotify ) && nonotify )
	{
		return;
	}
	if ( !isDefined( self.killstreaknotifyqueue ) )
	{
		self.killstreaknotifyqueue = [];
	}
	size = self.killstreaknotifyqueue.size;
	self.killstreaknotifyqueue[ size ] = spawnstruct();
	self.killstreaknotifyqueue[ size ].streakcount = streakcount;
	self.killstreaknotifyqueue[ size ].killstreaktablenumber = killstreaktablenumber;
	self.killstreaknotifyqueue[ size ].hardpointtype = hardpointtype;
	self notify( "received award" );
}

haskillstreakequipped()
{
	currentweapon = self getcurrentweapon();
	keys = getarraykeys( level.killstreaks );
	i = 0;
	while ( i < keys.size )
	{
		if ( level.killstreaks[ keys[ i ] ].weapon == currentweapon )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

givekillstreakweapon( weapon )
{
	weaponslist = self getweaponslist();
	currentweapon = self getcurrentweapon();
	idx = 0;
	while ( idx < weaponslist.size )
	{
		carriedweapon = weaponslist[ idx ];
		if ( currentweapon == carriedweapon )
		{
			idx++;
			continue;
		}
		else if ( currentweapon == "none" )
		{
			idx++;
			continue;
		}
		else switch( carriedweapon )
		{
			case "m202_flash_mp":
			case "m220_tow_mp":
			case "minigun_mp":
			case "mp40_blinged_mp":
				idx++;
				continue;
			}
			if ( iskillstreakweapon( carriedweapon ) )
			{
				self takeweapon( carriedweapon );
			}
			idx++;
		}
		if ( currentweapon != weapon && !self hasweapon( weapon ) )
		{
			self takeweapon( weapon );
			self giveweapon( weapon );
		}
		self setactionslot( level.actionslot, "weapon", weapon );
	}
}

activatenextkillstreak( do_not_update_death_count )
{
	if ( level.gameended )
	{
		return 0;
	}
	self setactionslot( level.actionslot, "" );
	if ( !isDefined( self.pers[ "killstreaks" ] ) || self.pers[ "killstreaks" ].size == 0 )
	{
		return 0;
	}
	killstreaktype = self.pers[ "killstreaks" ][ self.pers[ "killstreaks" ].size - 1 ];
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return 0;
	}
	weapon = level.killstreaks[ killstreaktype ].weapon;
	wait 0,05;
	givekillstreakweapon( weapon );
	if ( !isDefined( do_not_update_death_count ) || do_not_update_death_count != 0 )
	{
		self.pers[ "killstreakItemDeathCount" + killstreaktype ] = self.deathcount;
	}
	return 1;
}

takekillstreak( killstreaktype )
{
	if ( level.gameended )
	{
		return;
	}
	if ( !iskillstreaksenabled() )
	{
		return 0;
	}
	if ( isDefined( self.selectinglocation ) )
	{
		return 0;
	}
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return 0;
	}
	weapon = getkillstreakweapon( killstreaktype );
	self takeweapon( weapon );
	self setactionslot( level.actionslot, "" );
	self.pers[ "killstreakItemDeathCount" + killstreaktype ] = 0;
	return 1;
}

takeallkillstreaks()
{
	if ( hasanykillstreak() )
	{
		takekillstreak( gettopkillstreak() );
		self.pers[ "killstreaks" ] = [];
		self.pers[ "killstreak_has_been_used" ] = [];
		self.pers[ "killstreak_unique_id" ] = [];
	}
}

giveownedkillstreak()
{
	if ( isDefined( self.pers[ "killstreaks" ] ) && self.pers[ "killstreaks" ].size > 0 )
	{
		self activatenextkillstreak( 0 );
	}
}

changeweaponafterkillstreak( killstreak )
{
	self endon( "disconnect" );
	self endon( "death" );
	currentweapon = self getcurrentweapon();
	if ( level.killstreaks[ killstreak ].weaponholdallowed )
	{
		return;
	}
	self waittill( "killstreak_done" );
	if ( isDefined( self.laststand ) && self.laststand && isDefined( self.laststandpistol ) && self hasweapon( self.laststandpistol ) )
	{
		self switchtoweapon( self.laststandpistol );
	}
	else
	{
		if ( isDefined( self.lastnonkillstreakweapon ) && self hasweapon( self.lastnonkillstreakweapon ) )
		{
			self switchtoweapon( self.lastnonkillstreakweapon );
			return;
		}
		else
		{
			if ( isDefined( self.lastdroppableweapon ) && self hasweapon( self.lastdroppableweapon ) )
			{
				self switchtoweapon( self.lastdroppableweapon );
			}
		}
	}
}

removekillstreakwhendone( killstreak, haskillstreakbeenused )
{
	self endon( "disconnect" );
	self waittill( "killstreak_done", successful, killstreaktype );
	if ( successful )
	{
		logstring( "killstreak: " + getkillstreakmenuname( killstreak ) );
		if ( isDefined( haskillstreakbeenused ) )
		{
			removeusedkillstreak( killstreak );
		}
		self setactionslot( level.actionslot, "" );
		success = 1;
	}
	waittillframeend;
	currentweapon = self getcurrentweapon();
	if ( maps/sp_killstreaks/_killstreak_weapons::isheldkillstreakweapon( killstreaktype ) && currentweapon == killstreaktype )
	{
		return;
	}
	activatenextkillstreak();
}

usekillstreak( killstreak )
{
	if ( !isDefined( killstreak ) )
	{
		killstreak = gettopkillstreak();
	}
	haskillstreakbeenused = getiftopkillstreakhasbeenused();
	if ( isDefined( self.selectinglocation ) )
	{
		return;
	}
	self thread changeweaponafterkillstreak( killstreak );
	self thread removekillstreakwhendone( killstreak, haskillstreakbeenused );
	self thread triggerkillstreak( killstreak );
}

removeusedkillstreak( killstreak, killstreakid )
{
	killstreakindex = undefined;
	i = self.pers[ "killstreaks" ].size - 1;
	while ( i >= 0 )
	{
		if ( self.pers[ "killstreaks" ][ i ] == killstreak )
		{
			if ( isDefined( killstreakid ) && self.pers[ "killstreak_unique_id" ][ i ] != killstreakid )
			{
				i--;
				continue;
			}
			else
			{
				killstreakindex = i;
				break;
			}
		}
		else
		{
			i--;

		}
	}
	if ( !isDefined( killstreakindex ) )
	{
		return;
	}
	arraysize = self.pers[ "killstreaks" ].size;
	i = killstreakindex;
	while ( i < ( arraysize - 1 ) )
	{
		self.pers[ "killstreaks" ][ i ] = self.pers[ "killstreaks" ][ i + 1 ];
		self.pers[ "killstreak_has_been_used" ][ i ] = self.pers[ "killstreak_has_been_used" ][ i + 1 ];
		self.pers[ "killstreak_unique_id" ][ i ] = self.pers[ "killstreak_unique_id" ][ i + 1 ];
		i++;
	}
}

gettopkillstreak()
{
	if ( !isDefined( self.pers[ "killstreaks" ] ) || self.pers[ "killstreaks" ].size == 0 )
	{
		return undefined;
	}
	return self.pers[ "killstreaks" ][ self.pers[ "killstreaks" ].size - 1 ];
}

hasanykillstreak()
{
	return isDefined( self gettopkillstreak() );
}

getiftopkillstreakhasbeenused()
{
	if ( !isDefined( self.pers ) )
	{
		self.pers = [];
	}
	if ( !isDefined( self.pers[ "killstreak_has_been_used" ] ) )
	{
		self.pers[ "killstreak_has_been_used" ] = [];
	}
	if ( self.pers[ "killstreak_has_been_used" ].size == 0 )
	{
		return undefined;
	}
	return self.pers[ "killstreak_has_been_used" ][ self.pers[ "killstreak_has_been_used" ].size - 1 ];
}

gettopkillstreakuniqueid()
{
	if ( self.pers[ "killstreak_unique_id" ].size == 0 )
	{
		return undefined;
	}
	return self.pers[ "killstreak_unique_id" ][ self.pers[ "killstreak_unique_id" ].size - 1 ];
}

getkillstreakweapon( killstreak )
{
	if ( !isDefined( killstreak ) )
	{
		return "none";
	}
/#
	assert( isDefined( level.killstreaks[ killstreak ] ) );
#/
	return level.killstreaks[ killstreak ].weapon;
}

getkillstreakforweapon( weapon )
{
	return level.killstreakweapons[ weapon ];
}

iskillstreakweapon( weapon )
{
	if ( isweaponassociatedwithkillstreak( weapon ) )
	{
		return 1;
	}
	switch( weapon )
	{
		case "briefcase_bomb_defuse_mp":
		case "briefcase_bomb_mp":
		case "none":
		case "scavenger_item_mp":
		case "syrette_mp":
		case "tabun_center_mp":
		case "tabun_fx_mp":
		case "tabun_large_mp":
		case "tabun_medium_mp":
		case "tabun_small_mp":
		case "tabun_tiny_mp":
			return 0;
	}
	specificuse = 0;
	if ( isDefined( specificuse ) && specificuse == 1 )
	{
		return 1;
	}
	return 0;
}

iskillstreakweaponassistallowed( weapon )
{
	killstreak = getkillstreakforweapon( weapon );
	if ( !isDefined( killstreak ) )
	{
		return 0;
	}
	if ( level.killstreaks[ killstreak ].allowassists )
	{
		return 1;
	}
	return 0;
}

trackweaponusage()
{
	self endon( "death" );
	self endon( "disconnect" );
	self.lastnonkillstreakweapon = self getcurrentweapon();
	lastvalidpimary = self getcurrentweapon();
	if ( self.lastnonkillstreakweapon == "none" )
	{
		weapons = self getweaponslistprimaries();
		if ( weapons.size > 0 )
		{
			self.lastnonkillstreakweapon = weapons[ 0 ];
		}
		else
		{
			self.lastnonkillstreakweapon = "knife_mp";
		}
	}
/#
	assert( self.lastnonkillstreakweapon != "none" );
#/
	for ( ;; )
	{
		currentweapon = self getcurrentweapon();
		self waittill( "weapon_change", weapon );
		lastvalidpimary = weapon;
		if ( weapon == self.lastnonkillstreakweapon )
		{
			continue;
		}
		else switch( weapon )
		{
			case "knife_mp":
			case "none":
			case "syrette_mp":
				continue;
			}
			name = getkillstreakforweapon( weapon );
			if ( isDefined( name ) )
			{
				killstreak = level.killstreaks[ name ];
				if ( killstreak.weaponholdallowed == 1 )
				{
					self.lastnonkillstreakweapon = weapon;
				}
				continue;
			}
			else
			{
				self.lastnonkillstreakweapon = weapon;
			}
		}
	}
}

killstreakwaiter()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self thread trackweaponusage();
	self giveownedkillstreak();
	for ( ;; )
	{
		self waittill( "weapon_change", weapon );
		if ( !iskillstreakweapon( weapon ) )
		{
			continue;
		}
		else killstreak = gettopkillstreak();
		if ( weapon != getkillstreakweapon( killstreak ) )
		{
			continue;
		}
		else waittillframeend;
		if ( isDefined( self.usingkillstreakheldweapon ) && maps/sp_killstreaks/_killstreak_weapons::isheldkillstreakweapon( killstreak ) )
		{
			continue;
		}
		else
		{
			thread usekillstreak();
			if ( isDefined( self.selectinglocation ) )
			{
				event = self waittill_any_return( "cancel_location", "game_ended", "used", "weapon_change" );
				if ( event == "cancel_location" || event == "weapon_change" )
				{
					wait 1;
				}
			}
		}
	}
}

shoulddelaykillstreak( killstreaktype )
{
	if ( !isDefined( level.starttime ) )
	{
		return 0;
	}
	if ( level.killstreakrounddelay < ( ( getTime() - level.starttime - level.discardtime ) / 1000 ) )
	{
		return 0;
	}
	if ( !isdelayablekillstreak( killstreaktype ) )
	{
		return 0;
	}
	if ( maps/sp_killstreaks/_killstreak_weapons::isheldkillstreakweapon( killstreaktype ) )
	{
		return 0;
	}
	return 1;
}

isdelayablekillstreak( killstreaktype )
{
	if ( isDefined( level.killstreaks[ killstreaktype ] ) && isDefined( level.killstreaks[ killstreaktype ].delaystreak ) && level.killstreaks[ killstreaktype ].delaystreak )
	{
		return 1;
	}
	return 0;
}

getxpamountforkillstreak( killstreaktype )
{
	xpamount = 0;
	switch( level.killstreaks[ killstreaktype ].killstreaklevel )
	{
		case 1:
		case 2:
		case 3:
		case 4:
			xpamount = 100;
			break;
		case 5:
			xpamount = 150;
			break;
		case 6:
		case 7:
			xpamount = 200;
			break;
		case 8:
			xpamount = 250;
			break;
		case 9:
			xpamount = 300;
			break;
		case 10:
		case 11:
			xpamount = 350;
			break;
		case 12:
		case 13:
		case 14:
		case 15:
			xpamount = 500;
			break;
	}
	return xpamount;
}

triggerkillstreak( killstreaktype )
{
/#
	assert( isDefined( level.killstreaks[ killstreaktype ].usefunction ), "No use function defined for killstreak " + killstreaktype );
#/
	if ( [[ level.killstreaks[ killstreaktype ].usefunction ]]( killstreaktype ) )
	{
		if ( isDefined( level.killstreaks[ killstreaktype ].killstreaklevel ) )
		{
			xpamount = getxpamountforkillstreak( killstreaktype );
		}
		if ( isDefined( self ) )
		{
			if ( !isDefined( self.pers[ level.killstreaks[ killstreaktype ].usagekey ] ) )
			{
				self.pers[ level.killstreaks[ killstreaktype ].usagekey ] = 0;
			}
			self.pers[ level.killstreaks[ killstreaktype ].usagekey ]++;
			self notify( "killstreak_used" );
			self notify( "killstreak_done" );
		}
		return 1;
	}
	if ( isDefined( self ) )
	{
		self notify( "killstreak_done" );
	}
	return 0;
}

addtokillstreakcount( weapon )
{
	if ( !isDefined( self.pers[ "totalKillstreakCount" ] ) )
	{
		self.pers[ "totalKillstreakCount" ] = 0;
	}
	self.pers[ "totalKillstreakCount" ]++;
}

isweaponassociatedwithkillstreak( weapon )
{
	return isDefined( level.killstreakweapons[ weapon ] );
}

getfirstvalidkillstreakaltweapon( killstreaktype )
{
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak not registered." );
#/
	while ( isDefined( level.killstreaks[ killstreaktype ].altweapons ) )
	{
		i = 0;
		while ( i < level.killstreaks[ killstreaktype ].altweapons.size )
		{
			if ( isDefined( level.killstreaks[ killstreaktype ].altweapons[ i ] ) )
			{
				return level.killstreaks[ killstreaktype ].altweapons[ i ];
			}
			i++;
		}
	}
	return "none";
}

shouldgivekillstreak( weapon )
{
	if ( !iskillstreaksstreakcountsenabled() )
	{
		return 0;
	}
	killstreakbuilding = getDvarInt( "scr_allow_killstreak_building" );
	if ( killstreakbuilding == 0 )
	{
		if ( isweaponassociatedwithkillstreak( weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

pointisindangerarea( point, targetpos, radius )
{
	return distance2d( point, targetpos ) <= ( radius * 1,25 );
}

printkillstreakstarttext( killstreaktype, owner, team, targetpos, dangerradius )
{
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return;
	}
}

playkillstreakstartdialog( killstreaktype, team, playnonteambasedenemysounds )
{
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return;
	}
	if ( killstreaktype == "radar_mp" )
	{
		if ( ( getTime() - level.radartimers[ team ] ) > 30000 )
		{
			level.radartimers[ team ] = getTime();
		}
		return;
	}
}

playkillstreakreadydialog( killstreaktype )
{
}

playkillstreakreadyandinformdialog( killstreaktype )
{
	if ( isDefined( level.killstreaks[ killstreaktype ].informdialog ) )
	{
		self playlocalsound( level.killstreaks[ killstreaktype ].informdialog );
	}
}

playkillstreakenddialog( killstreaktype, team )
{
	if ( !isDefined( level.killstreaks[ killstreaktype ] ) )
	{
		return;
	}
}

getkillstreakusagebykillstreak( killstreaktype )
{
/#
	assert( isDefined( level.killstreaks[ killstreaktype ] ), "Killstreak needs to be registered before calling getKillstreakUsage." );
#/
	return getkillstreakusage( level.killstreaks[ killstreaktype ].usagekey );
}

getkillstreakusage( usagekey )
{
	if ( !isDefined( self.pers[ usagekey ] ) )
	{
		return 0;
	}
	return self.pers[ usagekey ];
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
	self thread maps/sp_killstreaks/_killstreaks::killstreakwaiter();
	for ( ;; )
	{
		self waittill( "spawned_player" );
		giveownedkillstreak();
		if ( !isDefined( self.pers[ "killstreaks" ] ) )
		{
			self.pers[ "killstreaks" ] = [];
		}
		if ( !isDefined( self.pers[ "killstreak_has_been_used" ] ) )
		{
			self.pers[ "killstreak_has_been_used" ] = [];
		}
		if ( !isDefined( self.pers[ "killstreak_unique_id" ] ) )
		{
			self.pers[ "killstreak_unique_id" ] = [];
		}
		size = self.pers[ "killstreaks" ].size;
		if ( size > 0 )
		{
			playkillstreakreadydialog( self.pers[ "killstreaks" ][ size - 1 ] );
		}
	}
}

killstreak_debug_think()
{
/#
	setdvar( "debug_killstreak", "" );
	for ( ;; )
	{
		cmd = getDvar( "debug_killstreak" );
		switch( cmd )
		{
			case "data_dump":
				killstreak_data_dump();
				break;
		}
		if ( cmd != "" )
		{
			setdvar( "debug_killstreak", "" );
		}
		wait 0,5;
#/
	}
}

killstreak_data_dump()
{
/#
	iprintln( "Killstreak Data Sent to Console" );
	println( "##### Killstreak Data #####" );
	println( "killstreak,killstreaklevel,weapon,altweapon1,altweapon2,altweapon3,altweapon4,type1,type2,type3,type4" );
	keys = getarraykeys( level.killstreaks );
	i = 0;
	while ( i < keys.size )
	{
		data = level.killstreaks[ keys[ i ] ];
		type_data = level.killstreaktype[ keys[ i ] ];
		print( keys[ i ] + "," );
		print( data.killstreaklevel + "," );
		print( data.weapon + "," );
		alt = 0;
		while ( isDefined( data.altweapons ) )
		{
			assert( data.altweapons.size <= 4 );
			alt = 0;
			while ( alt < data.altweapons.size )
			{
				print( data.altweapons[ alt ] + "," );
				alt++;
			}
		}
		while ( alt < 4 )
		{
			print( "," );
			alt++;
		}
		type = 0;
		while ( isDefined( type_data ) )
		{
			assert( type_data.size < 4 );
			type_keys = getarraykeys( type_data );
			while ( type < type_keys.size )
			{
				if ( type_data[ type_keys[ type ] ] == 1 )
				{
					print( type_keys[ type ] + "," );
				}
				type++;
			}
		}
		while ( type < 4 )
		{
			print( "," );
			type++;
		}
		println( "" );
		i++;
	}
	println( "##### End Killstreak Data #####" );
#/
}

killstreak_setup()
{
	level.cac_size = 5;
	level.cac_max_item = 256;
	level.cac_numbering = 0;
	level.cac_cstat = 1;
	level.cac_cgroup = 2;
	level.cac_cname = 3;
	level.cac_creference = 4;
	level.cac_ccount = 5;
	level.cac_cimage = 6;
	level.cac_cdesc = 7;
	level.cac_cstring = 8;
	level.cac_cint = 9;
	level.cac_cunlock = 10;
	level.cac_cint2 = 11;
	level.cac_cost = 12;
	level.cac_slot = 13;
	level.cac_classified = 15;
	level.cac_momentum = 16;
	level.killstreaknames = [];
	level.killstreakicons = [];
	level.killstreakindices = [];
	i = 0;
	while ( i < level.cac_max_item )
	{
		itemrow = tablelookuprownum( "sp/statsTable.csv", level.cac_numbering, i );
		if ( itemrow > -1 )
		{
			group_s = tablelookupcolumnforrow( "sp/statsTable.csv", itemrow, level.cac_cgroup );
			if ( group_s == "killstreak" )
			{
				reference_s = tablelookupcolumnforrow( "sp/statsTable.csv", itemrow, level.cac_creference );
				if ( reference_s != "" )
				{
					level.tbl_killstreakdata[ i ] = reference_s;
					icon = tablelookupcolumnforrow( "sp/statsTable.csv", itemrow, level.cac_cimage );
					name = tablelookupistring( "sp/statsTable.csv", level.cac_numbering, i, level.cac_cname );
					precachestring( name );
					level.killstreaknames[ reference_s ] = name;
					level.killstreakicons[ reference_s ] = icon;
					level.killstreakindices[ reference_s ] = i;
					precacheshader( icon );
				}
			}
		}
		i++;
	}
}

callback_killstreakactorkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( shouldgivekillstreak( sweapon ) )
		{
			attacker addtokillstreakcount( sweapon );
			attacker thread givekillstreakforstreak();
		}
	}
	self maps/_callbackglobal::callback( "on_actor_killed" );
}
