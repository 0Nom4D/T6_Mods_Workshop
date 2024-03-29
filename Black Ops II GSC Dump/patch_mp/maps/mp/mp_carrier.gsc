#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_carrier_fx::main();
	precachemodel( "collision_physics_wall_512x512x10" );
	precachemodel( "collision_clip_cylinder_32x128" );
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "collision_clip_wall_32x32x10" );
	precachemodel( "collision_physics_wall_32x32x10" );
	precachemodel( "collision_physics_64x64x128" );
	precachemodel( "collision_physics_32x32x128" );
	precachemodel( "collision_physics_wall_128x128x10" );
	precachemodel( "collision_clip_wall_64x64x10" );
	precachemodel( "collision_physics_32x32x32" );
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "ac_prs_fps_road_chunk_lrg_a04" );
	precachemodel( "collision_clip_32x32x32" );
	maps/mp/_load::main();
	maps/mp/mp_carrier_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_carrier" );
	game[ "strings" ][ "war_callsign_a" ] = &"MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings" ][ "war_callsign_b" ] = &"MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings" ][ "war_callsign_c" ] = &"MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings" ][ "war_callsign_d" ] = &"MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings" ][ "war_callsign_e" ] = &"MPUI_CALLSIGN_MAPNAME_E";
	game[ "strings_menu" ][ "war_callsign_a" ] = "@MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings_menu" ][ "war_callsign_b" ] = "@MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings_menu" ][ "war_callsign_c" ] = "@MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings_menu" ][ "war_callsign_d" ] = "@MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings_menu" ][ "war_callsign_e" ] = "@MPUI_CALLSIGN_MAPNAME_E";
	spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3733, -1301,22, -204,5 ), vectorScale( ( 0, 0, 1 ), 75,2 ) );
	spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3509, -1301,22, -204,56 ), vectorScale( ( 0, 0, 1 ), 75,2 ) );
	spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3733, -808,22, -334,56 ), vectorScale( ( 0, 0, 1 ), 75,2 ) );
	spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3509, -808,22, -334,56 ), vectorScale( ( 0, 0, 1 ), 75,2 ) );
	spawncollision( "collision_clip_cylinder_32x128", "collider", ( -4821, 951, 82 ), vectorScale( ( 0, 0, 1 ), 344 ) );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -4820,39, 930,19, 123 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -4820,39, 930,19, 91 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -4820,39, 930,19, 59 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -4821, 951, 82 ), vectorScale( ( 0, 0, 1 ), 344 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -4820,39, 930,19, 123 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -4820,39, 930,19, 91 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -4820,39, 930,19, 59 ), vectorScale( ( 0, 0, 1 ), 245 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -5448, 912, 268 ), vectorScale( ( 0, 0, 1 ), 13 ) );
	spawncollision( "collision_physics_64x64x128", "collider", ( -2434, 806, 66 ), ( 270, 25, 0 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -5003, -963, -100 ), vectorScale( ( 0, 0, 1 ), 270 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -5003, -1091, -100 ), vectorScale( ( 0, 0, 1 ), 270 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -5003, -1219, -88 ), vectorScale( ( 0, 0, 1 ), 270 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -5013, -1128, -32 ), ( 270, 270, 180 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -3257,5, -1184,5, -45 ), ( 270, 270, 180 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -3257,5, -1128, -45 ), ( 270, 270, 180 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -4696,5, 662,5, 163,5 ), vectorScale( ( 0, 0, 1 ), 283,2 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -5017, -1083,5, 40 ), ( 1, 270, 180 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -6316, -1554,5, -30 ), vectorScale( ( 0, 0, 1 ), 49,9 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( -5852,5, -886, 159,5 ), vectorScale( ( 0, 0, 1 ), 2,59995 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( -5875,5, -887, 159,5 ), vectorScale( ( 0, 0, 1 ), 2,59995 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -5331,5, 727, 247,5 ), vectorScale( ( 0, 0, 1 ), 90 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( -5838, -913,5, 85 ), vectorScale( ( 0, 0, 1 ), 19,8001 ) );
	greenbarrel1 = spawn( "script_model", ( -5979,48, -347,391, 53,8051 ) );
	greenbarrel1.angles = ( 0, 0, 1 );
	greenbarrel1 setmodel( "ac_prs_fps_road_chunk_lrg_a04" );
	greenbarrel2 = spawn( "script_model", ( -5960,64, -349,489, 59,663 ) );
	greenbarrel2.angles = ( 5,97936, 96,3096, 13,1076 );
	greenbarrel2 setmodel( "ac_prs_fps_road_chunk_lrg_a04" );
	spawncollision( "collision_clip_32x32x32", "collider", ( -5987,5, -347,5, 47 ), vectorScale( ( 0, 0, 1 ), 64,8 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( -5957,2, -356,902, 47,25 ), vectorScale( ( 0, 0, 1 ), 102,9 ) );
	level thread water_trigger_init();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a141 = triggers;
	_k141 = getFirstArrayKey( _a141 );
	while ( isDefined( _k141 ) )
	{
		trigger = _a141[ _k141 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k141 = getNextArrayKey( _a141, _k141 );
	}
}

water_trigger_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) )
		{
			trace = worldtrace( entity.origin + vectorScale( ( 0, 0, 1 ), 30 ), entity.origin - vectorScale( ( 0, 0, 1 ), 256 ) );
			if ( trace[ "surfacetype" ] == "none" )
			{
				entity playsound( "mpl_splash_death" );
				playfx( level._effect[ "water_splash" ], entity.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
			}
		}
	}
}

leveloverridetime( defaulttime )
{
	if ( self isinwater() )
	{
		return 0,4;
	}
	return defaulttime;
}

useintermissionpointsonwavespawn()
{
	return self isinwater();
}

isinwater()
{
	triggers = getentarray( "trigger_hurt", "classname" );
	_a189 = triggers;
	_k189 = getFirstArrayKey( _a189 );
	while ( isDefined( _k189 ) )
	{
		trigger = _a189[ _k189 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			if ( self.origin[ 2 ] < trigger.origin[ 2 ] )
			{
				trace = worldtrace( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), self.origin - vectorScale( ( 0, 0, 1 ), 256 ) );
				return trace[ "surfacetype" ] == "none";
			}
		}
		_k189 = getNextArrayKey( _a189, _k189 );
	}
	return 0;
}
