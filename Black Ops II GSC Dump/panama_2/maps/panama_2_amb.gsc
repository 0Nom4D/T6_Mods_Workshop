
main()
{
	level thread docks_glass_smash();
	level thread amb_radio_chatter();
}

docks_glass_smash()
{
	level endon( "entering_elevator" );
	while ( 1 )
	{
		level waittill( "glass_smash", pos );
		playsoundatposition( "dst_docks_window_shatter", pos );
	}
}

dingbat_shot_sound( e_digbat )
{
	level.player playsound( "evt_dingbat_shot" );
}

amb_radio_chatter()
{
	level endon( "kill_radio" );
	while ( 1 )
	{
		wait 4;
		playsoundatposition( "amb_radio_chatter_oneshots", ( 22386, 23435, 381 ) );
	}
}
