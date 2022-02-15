#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_slums_fx::main();
	precachemodel( "collision_physics_64x64x64" );
	precachemodel( "collision_physics_64x64x10" );
	precachemodel( "collision_physics_wall_32x32x10" );
	precachemodel( "collision_physics_128x128x128" );
	precachemodel( "collision_physics_128x128x10" );
	precachemodel( "collision_physics_256x256x10" );
	precachemodel( "collision_physics_256x256x256" );
	precachemodel( "collision_physics_512x512x512" );
	precachemodel( "collision_physics_32x32x128" );
	precachemodel( "collision_nosight_wall_64x64x10" );
	precachemodel( "collision_physics_64x64x128" );
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "collision_physics_32x32x32" );
	precachemodel( "collision_physics_64x64x256" );
	precachemodel( "collision_physics_wall_64x64x10" );
	precachemodel( "collision_nosight_wall_64x64x10" );
	precachemodel( "me_corrugated_metal8x8_holes" );
	precachemodel( "me_corrugated_metal8x8" );
	precachemodel( "p_glo_corrugated_metal1" );
	precachemodel( "me_ac_window" );
	precachemodel( "collision_slums_curved_wall" );
	precachemodel( "collision_slums_curved_wall_bullet" );
	precachemodel( "intro_prayer_flags_unspecific_01" );
	precachemodel( "prop_brick_single_v2" );
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_slums" );
	maps/mp/mp_slums_amb::main();
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
	spawncollision( "collision_physics_64x64x64", "collider", ( -508, -3270, 928 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( -508, -3286, 928 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -72, 254, 930 ), vectorScale( ( 0, 0, 0 ), 15 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( 48, 284, 930 ), vectorScale( ( 0, 0, 0 ), 15 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -104, 248, 891 ), ( 341,421, 12,9047, 0,661127 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( 76,5, 293,5, 891,5 ), ( 340,335, 193,409, -5,20973 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -451, -2508, 466 ), ( 270, 290, -5,5 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -472, -2490, 476 ), vectorScale( ( 0, 0, 0 ), 289,4 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -458, -2528, 476 ), vectorScale( ( 0, 0, 0 ), 289,4 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -217, -944, 578 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -217, -944, 566 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -186, -962, 567 ), vectorScale( ( 0, 0, 0 ), 287 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -186, -962, 578 ), vectorScale( ( 0, 0, 0 ), 287 ) );
	spawncollision( "collision_physics_128x128x128", "collider", ( 1297,09, 777,435, 1093 ), vectorScale( ( 0, 0, 0 ), 9,39996 ) );
	spawncollision( "collision_physics_128x128x128", "collider", ( -1070,8, -1111,64, 1073 ), vectorScale( ( 0, 0, 0 ), 0,4 ) );
	spawncollision( "collision_physics_128x128x128", "collider", ( -760,8, -1883,64, 1041 ), vectorScale( ( 0, 0, 0 ), 0,4 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1605, -1869, 847 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1733, -1869, 847 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1861, -1869, 847 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1989, -1869, 847 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( 1706, -1918, 414 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( 1832, -1918, 414 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( 1935, -1918, 414 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1632, -1704, 674 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1760, -1704, 674 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1888, -1704, 674 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( 562, 2058, 580 ), vectorScale( ( 0, 0, 0 ), 270 ) );
	spawncollision( "collision_physics_wall_256x256x10", "collider", ( 823, 1672, 870 ), vectorScale( ( 0, 0, 0 ), 273,2 ) );
	spawncollision( "collision_physics_wall_256x256x10", "collider", ( 839, 1454, 869 ), vectorScale( ( 0, 0, 0 ), 273,2 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( 828, 1550, 816 ), vectorScale( ( 0, 0, 0 ), 5 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( 826, 1572, 816 ), vectorScale( ( 0, 0, 0 ), 5 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( -1513, -220, 771 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( -1321, -220, 771 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( -1513, -220, 517 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( -1321, -220, 517 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_64x64x128", "collider", ( -1536, -365, 733 ), ( 1, 90, 90 ) );
	spawncollision( "collision_physics_64x64x128", "collider", ( -1407, -365, 733 ), ( 1, 90, 90 ) );
	spawncollision( "collision_physics_64x64x128", "collider", ( -1278, -365, 733 ), ( 1, 90, 90 ) );
	spawncollision( "collision_slums_curved_wall", "collider", ( 1258,5, -445, 558,5 ), ( 0, 0, 0 ) );
	spawncollision( "collision_slums_curved_wall_bullet", "collider", ( 1258,5, -445, 558,5 ), ( 0, 0, 0 ) );
	balconymetal1 = spawn( "script_model", ( -778, -1922,37, 990,03 ) );
	balconymetal1.angles = ( 0, 270, -90 );
	balconymetal2 = spawn( "script_model", ( -743, -1922,37, 989,03 ) );
	balconymetal2.angles = ( 0, 270, -90 );
	balconymetal3 = spawn( "script_model", ( -1088, -1147,37, 1015,03 ) );
	balconymetal3.angles = ( 0, 270, -90 );
	balconymetal4 = spawn( "script_model", ( -1053, -1147,37, 1014,03 ) );
	balconymetal4.angles = ( 0, 270, -90 );
	balconymetal1 setmodel( "p_glo_corrugated_metal1" );
	balconymetal2 setmodel( "p_glo_corrugated_metal1" );
	balconymetal3 setmodel( "p_glo_corrugated_metal1" );
	balconymetal4 setmodel( "p_glo_corrugated_metal1" );
	crate1 = spawn( "script_model", ( 1530, -1738, 493 ) );
	crate1.angles = ( 354,4, 270, -16 );
	prop1 = spawn( "script_model", ( 1936,37, -1924,03, 470 ) );
	prop1.angles = ( 89, 179,6, 180 );
	prop2 = spawn( "script_model", ( 1876,37, -1923,03, 471,005 ) );
	prop2.angles = ( 89, 179,6, 180 );
	prop3 = spawn( "script_model", ( 1783,37, -1922,03, 472 ) );
	prop3.angles = ( 89, 179,6, 180 );
	prop4 = spawn( "script_model", ( 1707,37, -1924,03, 486,001 ) );
	prop4.angles = ( 72, 179,6, 180 );
	crate1 setmodel( "me_ac_window" );
	prop1 setmodel( "p_glo_corrugated_metal1" );
	prop2 setmodel( "p_glo_corrugated_metal1" );
	prop3 setmodel( "p_glo_corrugated_metal1" );
	prop4 setmodel( "p_glo_corrugated_metal1" );
	fencemetal1 = spawn( "script_model", ( -719, -2557, 532 ) );
	fencemetal1.angles = ( 90, 333,5, -26,5 );
	fencemetal1 setmodel( "me_corrugated_metal8x8_holes" );
	fencemetal1 = spawn( "script_model", ( -798, -2556, 532 ) );
	fencemetal1.angles = ( 90, 333,5, -26,5 );
	fencemetal1 setmodel( "me_corrugated_metal8x8_holes" );
	fencemetal1 = spawn( "script_model", ( -885, -2557, 532 ) );
	fencemetal1.angles = ( 90, 153,5, -26,5 );
	fencemetal1 setmodel( "me_corrugated_metal8x8_holes" );
	fencemetal1 = spawn( "script_model", ( -975, -2556, 532 ) );
	fencemetal1.angles = ( 90, 333,5, -26,5 );
	fencemetal1 setmodel( "me_corrugated_metal8x8_holes" );
	spawncollision( "collision_physics_512x512x512", "collider", ( 1435, 2393, 780 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1371, 2229, 1044 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1371, 2253, 1044 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1234, 2229, 1102 ), vectorScale( ( 0, 0, 0 ), 315,2 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 884, 1602, 1019 ), vectorScale( ( 0, 0, 0 ), 270 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 908, 1602, 1019 ), vectorScale( ( 0, 0, 0 ), 270 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 883, 1732, 1073 ), vectorScale( ( 0, 0, 0 ), 225 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1065,29, 1601,18, 1084,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1106,29, 1581,18, 1129,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1064,29, 1506,18, 1084,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1105,29, 1486,18, 1129,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1066,29, 1411,18, 1084,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_64x64x64", "collider", ( 1107,29, 1391,18, 1129,07 ), ( 315, 334,2, -4 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( 1501, 1687, 812 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( 1722, 1687, 812 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -640, -2561, 523 ), ( 0, 0, 0 ) );
	middlevisblock1 = spawn( "script_model", ( 348, -66, 672 ) );
	middlevisblock1.angles = ( 6,30742, 309,785, -7,51566 );
	middlevisblock1 setmodel( "me_corrugated_metal8x8" );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1011,5, -641,5, 801 ), ( 315, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1011,5, -541,5, 801 ), ( 315, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1011,5, -439, 801 ), ( 315, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -997,5, -641,5, 781,5 ), ( 330, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -997,5, -541,5, 781,5 ), ( 330, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -997,5, -439, 781,5 ), ( 330, 0, -90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1026, -641,5, 781,5 ), ( 330, 180, 90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1026, -541,5, 781,5 ), ( 330, 180, 90 ) );
	spawncollision( "collision_physics_32x32x128", "collider", ( -1026, -439, 781,5 ), ( 330, 180, 90 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( -211, -972,5, 578 ), vectorScale( ( 0, 0, 0 ), 335,8 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -636, -2562,5, 511 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -699,5, -2562,5, 511 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -763,5, -2562,5, 511 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -827,5, -2562,5, 511 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -636, -2562,5, 478 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -699,5, -2562,5, 478 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -763,5, -2562,5, 478 ), ( 0, 0, 0 ) );
	spawncollision( "collision_nosight_wall_64x64x10", "collider", ( -827,5, -2562,5, 478 ), ( 0, 0, 0 ) );
	prayerflags1 = spawn( "script_model", ( -967,622, -309,912, 794 ) );
	prayerflags1.angles = vectorScale( ( 0, 0, 0 ), 350,8 );
	prayerflags1 setmodel( "intro_prayer_flags_unspecific_01" );
	prayerflags2 = spawn( "script_model", ( -1065,16, -318,731, 833 ) );
	prayerflags2.angles = vectorScale( ( 0, 0, 0 ), 14,4 );
	prayerflags2 setmodel( "intro_prayer_flags_unspecific_01" );
	level.levelkillbrushes = [];
	level.levelkillbrushes[ level.levelkillbrushes.size ] = spawn( "trigger_radius", ( -1673, 252, 526 ), 0, 550, 322 );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -1171,5, -2502,5, 493,5 ), vectorScale( ( 0, 0, 0 ), 270 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -1231, -2502,5, 560,5 ), ( 6,83, 180, -90 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -1358,5, -2502,5, 560,5 ), ( 6,83, 180, -90 ) );
	blueroombrick = spawn( "script_model", ( -278,458, -803,132, 618,922 ) );
	blueroombrick.angles = ( 89,6232, 39,6618, 24,4607 );
	blueroombrick setmodel( "prop_brick_single_v2" );
	blueroombrick2 = spawn( "script_model", ( -284,21, -805,13, 618,92 ) );
	blueroombrick2.angles = ( 89,6232, 39,6618, 24,4607 );
	blueroombrick2 setmodel( "prop_brick_single_v2" );
	blueroombrick3 = spawn( "script_model", ( -278,46, -803,88, 643,17 ) );
	blueroombrick3.angles = ( 89,6232, 39,6618, 24,4607 );
	blueroombrick3 setmodel( "prop_brick_single_v2" );
	spawncollision( "collision_physics_32x32x32", "collider", ( 997,5, 633, 589 ), vectorScale( ( 0, 0, 0 ), 16,6 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -253, -374, 565 ), ( 4,27, 270, -35,9 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -253, -406, 565 ), ( 4,27, 270, -35,9 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -232,5, -374,455, 573,211 ), ( 346,3, 270, -0,39995 ) );
	spawncollision( "collision_physics_wall_64x64x10", "collider", ( -232,5, -405,545, 580,789 ), ( 346,3, 270, -0,39995 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( 726,5, 998,5, 607,5 ), ( 0, 0, 0 ) );
	spawncollision( "collision_physics_32x32x32", "collider", ( 726,5, 967,5, 607,5 ), ( 0, 0, 0 ) );
	level.remotemotarviewleft = 30;
	level.remotemotarviewright = 30;
	level.remotemotarviewup = 10;
	level.remotemotarviewdown = 25;
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2500", reset_dvars );
}
