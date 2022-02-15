
main()
{
	level thread docks_glass_smash();
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
