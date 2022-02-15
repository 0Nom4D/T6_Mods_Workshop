#include maps/frontend_sf_a;
#include maps/_patrol;
#include maps/frontend_util;
#include maps/war_room_util;
#include common_scripts/utility;
#include maps/_utility;
#include maps/_scene;
#include maps/_objectives;

main()
{
	maps/frontend_fx::main();
	frontend_so_precache();
	maps/_load::main();
	maps/frontend_amb::main();
	maps/frontend_anim::main();
	maps/_objectives::init();
	maps/_patrol::patrol_init();
	maps/createart/frontend_art::main();
	level.m_rts_map_list = array( "so_rts_mp_dockside" );
	flag_init( "strikeforce_stats_loaded" );
	frontend_init_common();
	level thread frontend_so_run();
}

frontend_so_run()
{
	screen_fade_out( 0 );
	wait_for_first_player();
	on_player_connect();
	warp_to_random_player_start();
	holo_city = getent( "P6_hologram_city_buildings", "targetname" );
	holo_city hide();
	level thread maps/frontend_sf_a::run_briefing_forceplay( "so_rts_mp_dockside" );
	scene_drop_arm();
	wait_network_frame();
	t_war_room = getent( "war_room_trigger", "targetname" );
	set_objective( level.obj_war_room, t_war_room, "breadcrumb" );
	t_war_room waittill( "trigger" );
	set_objective( level.obj_war_room, undefined, "done" );
}

frontend_so_precache()
{
	precachemodel( "c_usa_cia_frnd_viewbody_vson" );
	precachemodel( "c_usa_cia_frnd_viewbody_vsoff" );
}

scene_drop_arm()
{
	level thread run_scene( "data_glove_idle" );
	wait_network_frame();
	level thread hud_show_warmap_available();
	player_body = get_model_or_models_from_scene( "data_glove_idle", "player_body" );
	player_body attach( "c_usa_cia_frnd_viewbody_vson", "J_WristTwist_LE" );
	screen_fade_in( 0,5 );
	wait 1,5;
	run_scene( "data_glove_finish" );
}
