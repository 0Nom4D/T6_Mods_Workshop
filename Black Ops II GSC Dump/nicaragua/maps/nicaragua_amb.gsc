#include maps/_music;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	level thread bunker_music_watcher();
}

bunker_music_watcher()
{
	level waittill_any( "bunker_1stroom_alerted", "bunker_2ndroom_alerted" );
	setmusicstate( "NIC_RAID_BUNKER_ALERTED" );
}
