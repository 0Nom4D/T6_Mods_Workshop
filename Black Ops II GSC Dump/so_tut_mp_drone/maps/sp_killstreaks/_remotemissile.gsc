#include maps/_hud_util;
#include maps/sp_killstreaks/_killstreakrules;
#include maps/sp_killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/_utility;

preload()
{
	precacheitem( "remote_missile_sp" );
	precacheitem( "remote_missile_missile_sp" );
	precacheshader( "tow_filter_overlay_no_signal" );
	level.remotemissile_fx[ "explode" ] = loadfx( "explosions/fx_exp_bomb_huge" );
	maps/sp_killstreaks/_killstreaks::registerkillstreak( "remote_missile_sp", "remote_missile_sp", "killstreak_remote_missile", "remote_missle_used", ::tryusepredatormissile, 1 );
	maps/sp_killstreaks/_killstreaks::registerkillstreakaltweapon( "remote_missile_sp", "remote_missile_missile_sp" );
	maps/sp_killstreaks/_killstreaks::registerkillstreakstrings( "remote_missile_sp", &"KILLSTREAK_EARNED_REMOTE_MISSILE", &"KILLSTREAK_REMOTE_MISSILE_NOT_AVAILABLE", &"KILLSTREAK_REMOTE_MISSILE_INBOUND" );
	maps/sp_killstreaks/_killstreaks::registerkillstreakdialog( "remote_missile_sp", "mpl_killstreak_rmissile_strt", "kls_remote_missile_used", "", "kls_remote_missile_enemy", "", "kls_remote_missile_ready" );
	maps/sp_killstreaks/_killstreaks::registerkillstreakdevdvar( "remote_missile_sp", "scr_givemissileremote" );
}

init()
{
	level.rockets = [];
	level.missilesforsighttraces = [];
}

tryusepredatormissile( lifeid )
{
	team = self.team;
	if ( !self maps/sp_killstreaks/_killstreakrules::killstreakstart( "remote_missile_sp", team, 0, 1 ) )
	{
		return 0;
	}
	if ( isDefined( level.remotemissile_override_origin ) )
	{
	}
	else
	{
	}
	origin = undefined;
	if ( isDefined( level.remotemissile_override_angles ) )
	{
	}
	else
	{
	}
	angles = undefined;
	if ( isDefined( level.remotemissile_override_target ) )
	{
	}
	else
	{
	}
	target = undefined;
	returnvar = _fire( lifeid, self, team, origin, angles, target );
	return returnvar;
}

getbestspawnpoint( remotemissilespawnpoints )
{
	validenemies = [];
	_a50 = remotemissilespawnpoints;
	_k50 = getFirstArrayKey( _a50 );
	while ( isDefined( _k50 ) )
	{
		spawnpoint = _a50[ _k50 ];
		spawnpoint.validplayers = [];
		spawnpoint.spawnscore = 0;
		_k50 = getNextArrayKey( _a50, _k50 );
	}
	_a56 = level.players;
	_k56 = getFirstArrayKey( _a56 );
	while ( isDefined( _k56 ) )
	{
		player = _a56[ _k56 ];
		if ( player.team == self.team )
		{
		}
		else if ( player.team == "spectator" )
		{
		}
		else
		{
			bestdistance = 999999999;
			bestspawnpoint = undefined;
			_a70 = remotemissilespawnpoints;
			_k70 = getFirstArrayKey( _a70 );
			while ( isDefined( _k70 ) )
			{
				spawnpoint = _a70[ _k70 ];
				spawnpoint.validplayers[ spawnpoint.validplayers.size ] = player;
				potentialbestdistance = distance2d( spawnpoint.targetent.origin, player.origin );
				if ( potentialbestdistance <= bestdistance )
				{
					bestdistance = potentialbestdistance;
					bestspawnpoint = spawnpoint;
				}
				_k70 = getNextArrayKey( _a70, _k70 );
			}
			bestspawnpoint.spawnscore += 2;
		}
		_k56 = getNextArrayKey( _a56, _k56 );
	}
	bestspawn = remotemissilespawnpoints[ 0 ];
	_a89 = remotemissilespawnpoints;
	_k89 = getFirstArrayKey( _a89 );
	while ( isDefined( _k89 ) )
	{
		spawnpoint = _a89[ _k89 ];
		_a91 = spawnpoint.validplayers;
		_k91 = getFirstArrayKey( _a91 );
		while ( isDefined( _k91 ) )
		{
			player = _a91[ _k91 ];
			spawnpoint.spawnscore += 1;
			if ( bullettracepassed( player.origin + vectorScale( ( 0, 0, 1 ), 32 ), spawnpoint.origin, 0, player ) )
			{
				spawnpoint.spawnscore += 3;
			}
			if ( spawnpoint.spawnscore > bestspawn.spawnscore )
			{
				bestspawn = spawnpoint;
			}
			else
			{
				if ( spawnpoint.spawnscore == bestspawn.spawnscore )
				{
					if ( cointoss() )
					{
						bestspawn = spawnpoint;
					}
				}
			}
			_k91 = getNextArrayKey( _a91, _k91 );
		}
		_k89 = getNextArrayKey( _a89, _k89 );
	}
	return bestspawn;
}

drawline( start, end, timeslice, color )
{
/#
	drawtime = int( timeslice * 20 );
	time = 0;
	while ( time < drawtime )
	{
		line( start, end, color, 0, 1 );
		wait 0,05;
		time++;
#/
	}
}

_fire( lifeid, player, team, origin, angles, targetpos )
{
	level.missileremotelaunchvert = 14000;
	level.missileremotelaunchhorz = 7000;
	level.missileremotelaunchtargetdist = 1500;
	if ( !isDefined( angles ) )
	{
		angles = player.angles;
	}
	if ( isDefined( origin ) )
	{
		startpos = origin;
	}
	else
	{
		origin = player.origin;
	}
	if ( !isDefined( startpos ) )
	{
		upvector = ( 0, 0, level.missileremotelaunchvert );
		backdist = level.missileremotelaunchhorz;
		targetdist = level.missileremotelaunchtargetdist;
		forward = anglesToForward( angles );
		startpos = ( origin + upvector ) + ( forward * backdist * -1 );
	}
	if ( !isDefined( targetpos ) )
	{
		targetpos = origin + ( forward * targetdist );
	}
	player.killstreak_waitamount = 10;
	player thread maps/_hud_util::fadetoblackforxsec( 0, 0,5, 0,5, 0,5 );
	wait 0,75;
	if ( isDefined( player ) )
	{
		player notify( "remote_missile_start" );
		wait 0,05;
	}
	if ( !isDefined( self ) || !isalive( self ) )
	{
		player.killstreak_waitamount = undefined;
		maps/sp_killstreaks/_killstreakrules::killstreakstop( "remote_missile_sp", team );
		if ( isDefined( player ) )
		{
			player notify( "remotemissile_done" );
		}
		return 0;
	}
	level notify( "remote_missile_start" );
	type = "remote_missile_missile_sp";
	if ( isDefined( level.remote_missile_type ) )
	{
		type = level.remote_missile_type;
	}
	rocket = magicbullet( type, startpos, targetpos, player );
	rocket hide();
	player linktomissile( rocket, 1 );
	rocket.owner = player;
	player.missile_sp = rocket;
	player thread cleanupwaiter( rocket );
	rocket missile_sound_play( player );
	player thread missile_sound_boost( rocket );
	player notify( "missile_fired" );
	level notify( "missile_fired" );
	rocket waittill( "death" );
	rocket missile_sound_stop();
	if ( isDefined( player ) )
	{
		player playrumbleonentity( "grenade_rumble" );
		player thread staticeffect( 0,5 );
		player.killstreak_waitamount = undefined;
		player unlinkfrommissile();
		player notify( "remotemissile_done" );
	}
	maps/sp_killstreaks/_killstreakrules::killstreakstop( "remote_missile_sp", team );
	return 1;
}

cleanupwaiter( rocket )
{
	self endon( "remotemissile_done" );
	rocket endon( "death" );
	self waittill_any( "joined_team", "joined_spectators", "disconnect" );
	self.killstreak_waitamount = undefined;
	if ( isDefined( rocket.owner ) )
	{
		rocket.owner unlink();
	}
	rocket delete();
}

_fire_noplayer( lifeid, player )
{
/#
	upvector = ( 0, 0, level.missileremotelaunchvert );
	backdist = level.missileremotelaunchhorz;
	targetdist = level.missileremotelaunchtargetdist;
	forward = anglesToForward( player.angles );
	startpos = ( player.origin + upvector ) + ( forward * backdist * -1 );
	targetpos = player.origin + ( forward * targetdist );
	rocket = magicbullet( "remotemissile_projectile_sp", startpos, targetpos, player );
	if ( !isDefined( rocket ) )
	{
		return;
	}
	rocket thread handledamage();
	rocket.lifeid = lifeid;
	rocket.type = "remote";
	rocket thread rocket_cleanupondeath();
	wait 2;
#/
}

handledamage()
{
	self endon( "death" );
	self endon( "deleted" );
	self setcandamage( 1 );
	for ( ;; )
	{
		self waittill( "damage" );
	}
}

missileeyes( player, rocket )
{
}

delayedfofoverlay()
{
}

staticeffect( duration )
{
	self endon( "disconnect" );
	staticbg = newclienthudelem( self );
	staticbg.horzalign = "fullscreen";
	staticbg.vertalign = "fullscreen";
	staticbg setshader( "white", 640, 480 );
	staticbg.archive = 1;
	staticbg.sort = 10;
	static = newclienthudelem( self );
	static.horzalign = "fullscreen";
	static.vertalign = "fullscreen";
	static setshader( "tow_filter_overlay_no_signal", 640, 480 );
	static.archive = 1;
	static.sort = 20;
	wait duration;
	static destroy();
	staticbg destroy();
}

player_cleanuponteamchange( rocket )
{
}

rocket_cleanupondeath()
{
	entitynumber = self getentitynumber();
	level.rockets[ entitynumber ] = self;
	self waittill( "death" );
}

player_cleanupongameended( rocket )
{
}

missile_sound_play( player )
{
	snd_first_person = spawn( "script_origin", self.origin );
	snd_first_person playloopsound( "wpn_remote_missile_loop_plr", 0,5 );
	self.snd_first = snd_first_person;
}

missile_sound_boost( rocket )
{
	self endon( "remotemissile_done" );
	self endon( "disconnect" );
	self waittill( "missile_boost" );
	rocket.snd_first playloopsound( "wpn_remote_missile_boost_plr" );
	rocket.snd_first playsound( "wpn_remote_missile_fire_boost" );
}

missile_sound_stop()
{
	self.snd_first delete();
}
