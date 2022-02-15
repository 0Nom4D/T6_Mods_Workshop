#include maps/_utility;

music_init()
{
/#
	assert( level.clientscripts );
#/
	level.musicstate = "";
	registerclientsys( "musicCmd" );
}

setmusicstate( state )
{
	if ( level.musicstate != state )
	{
		setclientsysstate( "musicCmd", state );
	}
	level.musicstate = state;
}
