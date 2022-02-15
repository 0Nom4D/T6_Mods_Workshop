#include maps/sp_killstreaks/_killstreakrules;
#include maps/sp_killstreaks/_killstreaks;
#include maps/gametypes/_hud_util;
#include maps/_utility;
#include common_scripts/utility;

preload()
{
	precacheshader( "hud_ks_minigun" );
	precacheshader( "hud_ks_m202" );
}

init()
{
	level thread onplayerconnect();
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
		self.firedkillstreakweapon = 0;
		self.usingkillstreakheldweapon = undefined;
		self thread watchkillstreakweaponusage();
		self thread watchkillstreakweapondelay();
	}
}

watchkillstreakweapondelay()
{
	self endon( "disconnect" );
	self endon( "death" );
	while ( 1 )
	{
		currentweapon = self getcurrentweapon();
		self waittill( "weapon_change", newweapon );
		while ( !maps/sp_killstreaks/_killstreaks::iskillstreakweapon( newweapon ) )
		{
			wait 0,5;
		}
	}
}

usekillstreakweapondrop( hardpointtype )
{
	return 0;
}

usecarriedkillstreakweapon( hardpointtype )
{
	if ( self maps/sp_killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	if ( !isDefined( hardpointtype ) )
	{
		return 0;
	}
	currentweapon = self getcurrentweapon();
	if ( hardpointtype == "none" )
	{
		return 0;
	}
	self.firedkillstreakweapon = 0;
	self thread watchkillsteakweaponswitch( hardpointtype );
	self.usingkillstreakheldweapon = 1;
	return 0;
}

watchkillsteakweaponswitch( killstreakweapon )
{
	self endon( "disconnect" );
	self endon( "death" );
	killstreakid = maps/sp_killstreaks/_killstreaks::gettopkillstreakuniqueid();
	while ( 1 )
	{
		currentweapon = self getcurrentweapon();
		self waittill( "weapon_change", newweapon );
		while ( newweapon == "none" )
		{
			continue;
		}
		while ( !self checkifswitchableweapon( currentweapon, newweapon, killstreakweapon, killstreakid ) )
		{
			continue;
		}
		self takeweapon( killstreakweapon );
		self.firedkillstreakweapon = 0;
		self.usingkillstreakheldweapon = undefined;
		waittillframeend;
		self maps/sp_killstreaks/_killstreaks::activatenextkillstreak();
		return;
	}
}

checkifswitchableweapon( currentweapon, newweapon, killstreakweapon, currentkillstreakid )
{
	switchableweapon = 1;
	topkillstreak = maps/sp_killstreaks/_killstreaks::gettopkillstreak();
	killstreakid = maps/sp_killstreaks/_killstreaks::gettopkillstreakuniqueid();
	if ( !isDefined( killstreakid ) )
	{
		killstreakid = -1;
	}
	if ( self hasweapon( killstreakweapon ) && !self getammocount( killstreakweapon ) )
	{
		switchableweapon = 1;
	}
	else
	{
		if ( self.firedkillstreakweapon && newweapon == killstreakweapon && isheldkillstreakweapon( currentweapon ) )
		{
			switchableweapon = 1;
		}
		else
		{
			if ( isDefined( level.grenade_array[ newweapon ] ) )
			{
				switchableweapon = 0;
			}
			else if ( isheldkillstreakweapon( newweapon ) && isheldkillstreakweapon( currentweapon ) && currentkillstreakid != killstreakid )
			{
				switchableweapon = 1;
			}
			else
			{
				if ( maps/sp_killstreaks/_killstreaks::iskillstreakweapon( newweapon ) )
				{
					switchableweapon = 0;
				}
				else if ( isgameplayweapon( newweapon ) )
				{
					switchableweapon = 0;
				}
				else if ( self.firedkillstreakweapon )
				{
					switchableweapon = 1;
				}
				else if ( self.lastnonkillstreakweapon == killstreakweapon )
				{
					switchableweapon = 0;
				}
				else
				{
					if ( isDefined( topkillstreak ) && topkillstreak == killstreakweapon && currentkillstreakid == killstreakid )
					{
						switchableweapon = 0;
					}
				}
			}
		}
	}
	return switchableweapon;
}

watchkillstreakweaponusage()
{
	self endon( "disconnect" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "weapon_fired", killstreakweapon );
		while ( !isheldkillstreakweapon( killstreakweapon ) )
		{
			wait 0,1;
		}
		while ( self.firedkillstreakweapon )
		{
			continue;
		}
		self addweaponstat( killstreakweapon, "used", 1 );
		self maps/sp_killstreaks/_killstreaks::playkillstreakstartdialog( killstreakweapon, self.team );
		maps/sp_killstreaks/_killstreaks::removeusedkillstreak( killstreakweapon );
		self.firedkillstreakweapon = 1;
		self setactionslot( level.actionslot, "" );
		waittillframeend;
		maps/sp_killstreaks/_killstreaks::activatenextkillstreak();
	}
}

isheldkillstreakweapon( killstreaktype )
{
	switch( killstreaktype )
	{
		case "m202_flash_mp":
		case "m220_tow_mp":
		case "minigun_mp":
		case "mp40_drop_mp":
			return 1;
	}
	return 0;
}

isgameplayweapon( weapon )
{
	switch( weapon )
	{
		case "briefcase_bomb_defuse_mp":
		case "briefcase_bomb_mp":
		case "syrette_mp":
			return 1;
		default:
			return 0;
	}
	return 0;
}
