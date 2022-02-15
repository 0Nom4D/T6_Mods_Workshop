#include maps/_utility;
#include maps/_music;

main()
{
	level.sndf35_death_sound = 0;
}

radio_chatter()
{
	level endon( "player_ejected" );
	while ( 1 )
	{
		wait randomintrange( 1, 6 );
		level.player playsound( "blk_f35_radio_chatter", "sound_done" );
		level.player waittill( "sound_done" );
	}
}
