#include common_scripts/utility;
#include maps/_utility;

init()
{
	level.medalsettings.waittime = 1,25;
	level.contractsettings = spawnstruct();
	level.contractsettings.waittime = 4,2;
	level.killstreaksettings = spawnstruct();
	level.killstreaksettings.waittime = 3;
	level.ranksettings = spawnstruct();
	level.ranksettings.waittime = 3;
	level.startmessage = spawnstruct();
	level.startmessagedefaultduration = 2;
	level.endmessagedefaultduration = 2;
	level.challengesettings = spawnstruct();
	level.challengesettings.waittime = 3;
	level.teammessage = spawnstruct();
	level.teammessage.waittime = 3;
	level.regulargamemessages = spawnstruct();
	level.regulargamemessages.waittime = 6;
	level.wagersettings = spawnstruct();
	level.wagersettings.waittime = 3;
	level.momentumnotifywaittime = 0,5;
	level thread onplayerconnect();
}

displaypopupswaiter()
{
	self endon( "disconnect" );
	self.killstreaknotifyqueue = [];
	self.messagenotifyqueue = [];
	self.startmessagenotifyqueue = [];
	while ( 1 )
	{
		if ( self.killstreaknotifyqueue.size == 0 && self.messagenotifyqueue.size == 0 )
		{
			self waittill( "received award" );
		}
		waittillframeend;
		if ( self.startmessagenotifyqueue.size > 0 )
		{
			self clearcenterpopups();
			nextnotifydata = self.startmessagenotifyqueue[ 0 ];
			i = 1;
			while ( i < self.startmessagenotifyqueue.size )
			{
				self.startmessagenotifyqueue[ i - 1 ] = self.startmessagenotifyqueue[ i ];
				i++;
			}
			if ( isDefined( nextnotifydata.duration ) )
			{
				duration = nextnotifydata.duration;
			}
			else
			{
				duration = level.startmessagedefaultduration;
			}
			wait duration;
			continue;
		}
		else if ( self.killstreaknotifyqueue.size > 0 )
		{
			streakcount = self.killstreaknotifyqueue[ 0 ].streakcount;
			killstreaktablenumber = self.killstreaknotifyqueue[ 0 ].killstreaktablenumber;
			hardpointtype = self.killstreaknotifyqueue[ 0 ].hardpointtype;
			i = 1;
			while ( i < self.killstreaknotifyqueue.size )
			{
				self.killstreaknotifyqueue[ i - 1 ] = self.killstreaknotifyqueue[ i ];
				i++;
			}
			if ( !isDefined( streakcount ) )
			{
				streakcount = 0;
			}
			self displaykillstreak( streakcount, killstreaktablenumber );
			wait level.killstreaksettings.waittime;
			continue;
		}
		else if ( self.messagenotifyqueue.size > 0 )
		{
			self clearcenterpopups();
			nextnotifydata = self.messagenotifyqueue[ 0 ];
			i = 1;
			while ( i < self.messagenotifyqueue.size )
			{
				self.messagenotifyqueue[ i - 1 ] = self.messagenotifyqueue[ i ];
				i++;
			}
			if ( isDefined( nextnotifydata.duration ) )
			{
				duration = nextnotifydata.duration;
				break;
			}
			else
			{
				duration = level.regulargamemessages.waittime;
			}
		}
	}
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player clearendgame();
		player clearpopups();
		player.resetgameoverhudrequired = 0;
		player thread displaypopupswaiter();
	}
}
