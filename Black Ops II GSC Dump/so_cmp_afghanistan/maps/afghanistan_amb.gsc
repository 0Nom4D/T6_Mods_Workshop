#include common_scripts/utility;
#include maps/_utility;
#include maps/_music;

main()
{
}

start_music_manager()
{
	level endon( "base_secure" );
	tracks = array( "RIDE_TO_FIGHT_TWO", "AFGHAN_BRIDGE_FIGHT", "AFGHAN_WAVE2_PART2", "AFGHAN_WAVE3_PART1", "AFGHAN_ARENA" );
	while ( 1 )
	{
		if ( isDefined( level.current_music ) )
		{
			a_temp = array( "RIDE_TO_FIGHT_TWO", "AFGHAN_BRIDGE_FIGHT", "AFGHAN_WAVE2_PART2", "AFGHAN_WAVE3_PART1" );
			arrayremovevalue( a_temp, level.current_music );
			level.current_music = a_temp[ randomintrange( 0, a_temp.size ) ];
		}
		else
		{
			level.current_music = tracks[ randomintrange( 0, tracks.size ) ];
		}
		level waittill( "current_wave_cleared" );
		setmusicstate( level.current_music );
		wait 0,1;
	}
}
