#include maps/_hud_util;
#include maps/_utility;
#include common_scripts/utility;

init()
{
	level.splitscreen = issplitscreen();
	if ( level.onlinegame || level.systemlink )
	{
		precachestring( &"GAME_HOST_ENDED_GAME" );
	}
	else
	{
		precachestring( &"GAME_ENDED_GAME" );
	}
	if ( !isDefined( game[ "state" ] ) )
	{
		game[ "state" ] = "playing";
	}
	level.gameended = 0;
	level.postroundtime = 4;
	level.forcedend = 0;
	level.hostforcedend = 0;
}

forceend()
{
	if ( level.hostforcedend || level.forcedend )
	{
		return;
	}
	forcelevelend();
	level.forcedend = 1;
	level.hostforcedend = 1;
	if ( level.onlinegame || level.systemlink )
	{
		endstring = &"GAME_HOST_ENDED_GAME";
	}
	else
	{
		endstring = "";
	}
	makedvarserverinfo( "ui_text_endreason", endstring );
	setdvar( "ui_text_endreason", endstring );
	thread endgame( endstring );
}

endgamemessage( endreasontext )
{
	self endon( "disconnect" );
	if ( level.splitscreen )
	{
		titlesize = 2;
		spacing = 10;
		font = "default";
	}
	else
	{
		titlesize = 3;
		spacing = 50;
		font = "objective";
	}
	outcometitle = maps/_hud_util::createfontstring( font, titlesize, self );
	outcometitle maps/_hud_util::setpoint( "TOP", undefined, 0, spacing );
	outcometitle settext( endreasontext );
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometitle setpulsefx( 100, 60000, 1000 );
}

endgame( endreasontext )
{
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	visionsetnaked( "mpOutro", 2 );
	game[ "state" ] = "postgame";
	level.gameendtime = getTime();
	level.gameended = 1;
	level.ingraceperiod = 0;
	level notify( "game_ended" );
	players = get_players();
	index = 0;
	while ( index < players.size )
	{
		player = players[ index ];
		player freezeplayerforroundend();
		player thread roundenddof();
		player setclientdvar( "cg_everyoneHearsEveryone", "1" );
		if ( isDefined( endreasontext ) )
		{
			player endgamemessage( endreasontext );
		}
		index++;
	}
	level.intermission = 1;
	roundendwait( level.postroundtime, 1 );
	players = get_players();
	index = 0;
	while ( index < players.size )
	{
		player = players[ index ];
		player closemenu();
		player closeingamemenu();
		index++;
	}
	logstring( "game ended" );
	exitlevel( 0 );
}

roundendwait( defaultdelay, matchbonus )
{
	notifiesdone = 0;
	while ( !notifiesdone )
	{
		players = get_players();
		notifiesdone = 1;
		index = 0;
		while ( index < players.size )
		{
			if ( !isDefined( players[ index ].doingnotify ) || !players[ index ].doingnotify )
			{
				index++;
				continue;
			}
			else
			{
				notifiesdone = 0;
			}
			index++;
		}
		wait 0,5;
	}
	if ( !matchbonus )
	{
		wait defaultdelay;
		return;
	}
	wait defaultdelay;
	notifiesdone = 0;
	while ( !notifiesdone )
	{
		players = get_players();
		notifiesdone = 1;
		index = 0;
		while ( index < players.size )
		{
			if ( !isDefined( players[ index ].doingnotify ) || !players[ index ].doingnotify )
			{
				index++;
				continue;
			}
			else
			{
				notifiesdone = 0;
			}
			index++;
		}
		wait 0,5;
	}
}

freezeplayerforroundend()
{
	self closemenu();
	self closeingamemenu();
	self freezecontrols( 1 );
}

roundenddof()
{
	self setdepthoffield( 0, 128, 512, 4000, 6, 1,8 );
}
