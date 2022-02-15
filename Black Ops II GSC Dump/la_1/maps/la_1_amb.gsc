#include maps/_music;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	level thread play_post_cougar_blend();
}

play_sam_ambience()
{
	wait_for_first_player();
	level.player endon( "death" );
	level.player endon( "missileTurret_off" );
	level.player waittill( "missileTurret_on" );
	clientnotify( "mTon" );
	temp_ent = spawn( "script_origin", level.player.origin );
	temp_ent playloopsound( "wpn_sam_interface_loop", 1 );
	level.player thread end_looping_sound( temp_ent );
	level.player thread play_sam_radio();
	level.player thread play_sam_creaking_sounds();
}

end_looping_sound( ent )
{
	level.player waittill( "missileTurret_off" );
	clientnotify( "mToff" );
	ent stoploopsound( 1 );
	wait 1;
	ent delete();
}

play_sam_radio()
{
	level.player endon( "death" );
	level.player endon( "missileTurret_off" );
	while ( 1 )
	{
		level.player playsound( "amb_sam_radio_chatter" );
		wait randomintrange( 5, 10 );
	}
}

play_sam_creaking_sounds()
{
	level.player endon( "death" );
	level.player endon( "missileTurret_off" );
	wait_max = undefined;
	while ( 1 )
	{
		if ( !isDefined( level.num_planes_shot ) )
		{
			wait_max = 15;
		}
		else
		{
			wait_max = get_wait_max();
		}
		level.player playsound( "evt_cougar_creak" );
		wait randomintrange( 2, wait_max );
	}
}

get_wait_max()
{
	if ( level.num_planes_shot < 2 )
	{
		return 12;
	}
	else
	{
		if ( level.num_planes_shot < 6 )
		{
			return 8;
		}
		else
		{
			if ( level.num_planes_shot < 9 )
			{
				return 6;
			}
			else
			{
				return 4;
			}
		}
	}
}

play_post_cougar_blend()
{
	level waittill( "cougar_blend_go" );
	playsoundatposition( "vox_blend_post_cougar", ( 7780, -57300, 670 ) );
}

snapshot_drone()
{
	wait 10,5;
	clientnotify( "sds1" );
	wait 2;
	clientnotify( "sdfs1" );
}

sndactivatedrivingsnapshot( guy )
{
	clientnotify( "snd_ADS" );
}

sndchangecrawlsnapshot( guy )
{
	clientnotify( "snd_ECRWL" );
}
