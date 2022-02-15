#include common_scripts/utility;
#include maps/_utility;
#include maps/_music;

main()
{
	level thread flag_watch_base();
	level thread music_for_swing();
}

flag_watch_base()
{
	wait 0,5;
	level waittill( "ruins_stealth_over" );
	setmusicstate( "MONSOON_BATTLE_1" );
}

music_for_swing()
{
	level waittill( "bpgm" );
	setmusicstate( "MONSOON_SWING" );
}

missionfailsndspecial()
{
}
