#include maps/so_rts_afghanistan_s1;
#include maps/_compass;
#include maps/_vehicle;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	level.era = "twentytwenty";
	level.skip_weapon_precache = 1;
	precacheitem( "frag_grenade_sp" );
	precacheitem( "metalstorm_mms_rts" );
	maps/so_rts_afghanistan_fx::main();
	level.rts_def_table = "sp/so_rts/afghanistan_rts.csv";
	maps/_so_rts_main::preload();
	level.onlyallowfrags = 1;
	level.compass_map_name = "compass_overlay_map_afghanistan";
	afghanistan_level_precache();
	maps/_load::main();
	maps/_compass::setupminimap( level.compass_map_name );
	setsaveddvar( "compassmaxrange", "7500" );
	screen_fade_out( 0 );
	objective_clearall();
	maps/_so_rts_main::postload();
	afghanistan_level_setup();
	maps/_so_rts_main::main();
}

afghanistan_setstart()
{
	ent = getent( "rts_player_start", "targetname" );
/#
	assert( isDefined( ent ), "Player starting location must be defined." );
#/
	self.origin = ent.origin;
	self setplayerangles( ent.angles );
}

afghanistan_level_setup()
{
	level.onspawnplayer = ::afghanistan_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level.custom_mission_complete = ::maps/so_rts_afghanistan_s1::afghanistan_mission_complete_s1;
			level thread maps/so_rts_afghanistan_s1::afghanistan_level_scenario_one();
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

afghanistan_level_precache()
{
	level.onspawnplayer = ::afghanistan_setstart;
	switch( getDvarInt( "map_scenario" ) )
	{
		case 0:
		case 1:
			level thread maps/so_rts_afghanistan_s1::precache();
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
