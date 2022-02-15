#include maps/so_rts_mp_dockside_s1;
#include maps/voice/voice_singapore;
#include maps/_compass;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	level.era = "twentytwenty";
	maps/so_rts_mp_dockside_fx::main();
	level.rts_def_table = "sp/so_rts/mp_dockside_rts.csv";
	maps/_so_rts_main::preload();
	level.compass_map_name = "compass_map_mp_dockside_rts";
	level.supportsvomitingdeaths = 1;
	dockside_level_precache();
	maps/_load::main();
	maps/_compass::setupminimap( level.compass_map_name );
	screen_fade_out( 0 );
	objective_clearall();
	maps/_so_rts_main::postload();
	maps/voice/voice_singapore::init_voice();
	dockside_level_setup();
	maps/_so_rts_main::main();
}

dockside_setstart()
{
	ent = getent( "rts_player_start", "targetname" );
/#
	assert( isDefined( ent ), "Player starting location must be defined." );
#/
	self.origin = ent.origin;
	self setplayerangles( ent.angles );
}

dockside_level_setup()
{
	level.onspawnplayer = ::dockside_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level.custom_mission_complete = ::maps/so_rts_mp_dockside_s1::dockside_mission_complete_s1;
			level thread maps/so_rts_mp_dockside_s1::dockside_level_scenario_one();
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

dockside_level_precache()
{
	setheliheightpatchenabled( "mp_mode_heli_height_lock", 0 );
	level.onspawnplayer = ::dockside_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level thread maps/so_rts_mp_dockside_s1::precache();
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
