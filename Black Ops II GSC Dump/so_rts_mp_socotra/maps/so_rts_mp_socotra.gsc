#include maps/so_rts_mp_socotra_s1;
#include maps/_compass;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	level.era = "twentytwenty";
	maps/so_rts_mp_socotra_fx::main();
	level.rts_def_table = "sp/so_rts/mp_socotra_rts.csv";
	maps/_so_rts_main::preload();
	level.compass_map_name = "compass_map_mp_socotra";
	level.supportsvomitingdeaths = 1;
	socotra_level_precache();
	maps/_load::main();
	maps/_compass::setupminimap( level.compass_map_name );
	screen_fade_out( 0 );
	objective_clearall();
	maps/_so_rts_main::postload();
	socotra_level_setup();
	maps/_so_rts_main::main();
}

socotra_setstart()
{
	ent = getent( "rts_player_start", "targetname" );
/#
	assert( isDefined( ent ), "Player starting location must be defined." );
#/
	self.origin = ent.origin;
	self setplayerangles( ent.angles );
}

socotra_level_setup()
{
	level.onspawnplayer = ::socotra_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level.custom_mission_complete = ::maps/so_rts_mp_socotra_s1::socotra_mission_complete_s1;
			level thread maps/so_rts_mp_socotra_s1::socotra_level_scenario_one();
			break;
		case 2:
			case 3:
				default:
/#
					assertmsg( "Unhandled war scenario specified" );
#/
					break;
			}
		}
	}
}

socotra_level_precache()
{
	level.onspawnplayer = ::socotra_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level thread maps/so_rts_mp_socotra_s1::precache();
			break;
		case 2:
			case 3:
				default:
/#
					assertmsg( "Unhandled war scenario specified" );
#/
					break;
			}
		}
	}
}
