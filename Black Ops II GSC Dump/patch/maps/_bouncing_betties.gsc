#include maps/_utility;
#include common_scripts/utility;

init_bouncing_betties()
{
	level.betty_trigs = getentarray( "trip_betty", "targetname" );
	i = 0;
	while ( i < level.betty_trigs.size )
	{
		level thread betty_think( level.betty_trigs[ i ] );
		i++;
	}
}

betty_think( trigger )
{
	trigger waittill( "trigger" );
	tripwire = getent( trigger.target, "targetname" );
	betty = getent( tripwire.target, "targetname" );
	jumpheight = randomintrange( 68, 80 );
	dropheight = randomintrange( 10, 20 );
/#
	iprintln( "Click!" );
#/
	wait 0,05;
	playfx( level._effect[ "betty_groundPop" ], betty.origin + vectorScale( ( 0, 0, 1 ), 10 ) );
	betty thread betty_rotate();
	betty moveto( betty.origin + ( 0, 0, jumpheight ), 0,15, 0, 0,15 * 0,5 );
	betty waittill( "movedone" );
	betty moveto( betty.origin - ( 0, 0, dropheight ), 0,1, 0,1 * 0,5 );
	betty waittill( "movedone" );
	betty notify( "stop_rotate_thread" );
	playfx( level._effect[ "betty_explosion" ], betty.origin );
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( player getstance() == "prone" )
		{
			i++;
			continue;
		}
		else if ( player istouching( trigger ) )
		{
			player dodamage( player.health + 200, betty.origin );
			i++;
			continue;
		}
		else
		{
			if ( distance( player.origin, betty.origin ) < ( 90 + ( 90 * 1 ) ) )
			{
				player dodamage( player.health * 2, betty.origin );
			}
		}
		i++;
	}
	i = 0;
	while ( i < level.betty_trigs.size )
	{
		otherbetty = level.betty_trigs[ i ];
		if ( !isDefined( otherbetty ) || trigger == otherbetty )
		{
			i++;
			continue;
		}
		else
		{
			if ( distance2d( betty.origin, otherbetty.origin ) <= ( 90 + ( 90 * 1 ) ) )
			{
				otherbetty thread betty_pop( randomfloatrange( 0,15, 0,25 ) );
			}
		}
		i++;
	}
	betty delete();
	tripwire delete();
	trigger delete();
}

betty_rotate()
{
	self endon( "stop_rotate_thread" );
	self thread betty_rotate_fx();
	while ( 1 )
	{
		self rotateyaw( 360, 0,125 );
		self waittill( "rotatedone" );
	}
}

betty_rotate_fx()
{
	self endon( "stop_rotate_thread" );
	fxorg = spawn( "script_model", self.origin );
	fxorg setmodel( "tag_origin" );
	fxorg linkto( self );
	wait 0,75;
/#
	assert( isDefined( level._effect[ "betty_smoketrail" ] ), "level._effect['betty_smoketrail'] needs to be defined" );
#/
	fx = playfxontag( level._effect[ "betty_smoketrail" ], fxorg, "tag_origin" );
}

betty_pop( waittime )
{
	if ( isDefined( waittime ) && waittime > 0 )
	{
		wait waittime;
	}
	self notify( "trigger" );
}

betty_think_no_wires( trigger )
{
	trigger waittill( "trigger" );
	jumpheight = randomintrange( 68, 80 );
	dropheight = randomintrange( 10, 20 );
/#
	iprintln( "Click!" );
#/
	wait 1;
/#
	assert( isDefined( level._effect[ "betty_groundPop" ] ), "level._effect['betty_groundPop'] needs to be defined" );
#/
	playfx( level._effect[ "betty_groundPop" ], self.origin + vectorScale( ( 0, 0, 1 ), 10 ) );
	self hide();
	fake_betty = spawn( "script_model", self.origin );
	fake_betty setmodel( "viewmodel_usa_bbetty_mine" );
	fake_betty thread betty_rotate();
	fake_betty moveto( fake_betty.origin + ( 0, 0, jumpheight ), 0,15, 0, 0,15 * 0,5 );
	fake_betty waittill( "movedone" );
	fake_betty moveto( fake_betty.origin - ( 0, 0, dropheight ), 0,1, 0,1 * 0,5 );
	fake_betty waittill( "movedone" );
	self detonate();
	fake_betty notify( "stop_rotate_thread" );
	fake_betty delete();
	trigger delete();
}
