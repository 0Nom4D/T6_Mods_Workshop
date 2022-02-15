#include maps/createart/afghanistan_art;
#include maps/afghanistan_anim;
#include maps/_music;
#include maps/_dialog;
#include maps/_vehicle;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "critter" );
#using_animtree( "player" );

init_flags()
{
	flag_init( "deserted_sequence" );
	flag_init( "start_deserted_first_fade_out" );
}

skipto_deserted()
{
	skipto_setup();
	skipto_teleport( "skipto_deserted_player" );
	level.woods = init_hero( "woods" );
	level.rebel_leader = init_hero( "rebel_leader" );
	level.hudson = init_hero( "hudson" );
	level.zhao = init_hero( "zhao" );
	level maps/afghanistan_anim::init_afghan_anims_part2();
	flag_wait( "afghanistan_gump_ending" );
}

main()
{
	maps/createart/afghanistan_art::turn_down_fog();
	maps/createart/afghanistan_art::open_area();
	maps/createart/afghanistan_art::deserted();
	setmusicstate( "AFGHAN_ENDING" );
	deserted_sequence();
}

deserted_sequence()
{
	level thread run_scene_first_frame( "e6_s2_ontruck_trucks" );
	level thread run_scene_first_frame( "e6_s2_ontruck_1" );
	level thread play_fx_anim_bush();
	level.player playsound( "evt_deserted_overblack_front" );
	rpc( "clientscripts/afghanistan_amb", "deserted_fadein_snapshot" );
	wait 3;
	exploder( 900 );
	autosave_by_name( "deserted_start" );
	wait 1;
	clientnotify( "snp_desert" );
	level.player disableweapons();
	setsundirection( ( -0,283548, -0,779041, 0,559193 ) );
	level thread run_scene( "e6_s2_ontruck_trucks" );
	level thread run_scene( "e6_s2_ontruck_1" );
	wait 1;
	level.player thread player_wakes_up_afghan();
	scene_wait( "e6_s2_ontruck_1" );
	level.player dodamage( 50, level.player.origin );
	earthquake( 0,5, 0,6, level.player.origin, 128 );
	level.rebel_leader unlink();
	getent( "woods_beatup_ai", "targetname" ) unlink();
	getent( "zhao_beatup_ai", "targetname" ) unlink();
	getent( "hudson_beatup_ai", "targetname" ) unlink();
	muj_guard = getent( "m01_guard_ai", "targetname" );
	muj_guard unlink();
	level thread run_scene( "e6_s2_offtruck" );
	anim_length = getanimlength( %p_af_06_01_deserted_player_offtruck );
	level waittill( "start_deserted_first_fade_out" );
	level.player playsound( "sce_timelapse_wind" );
	level.player thread lerp_dof_over_time_pass_out( 2 );
	wait 0,25;
	level.player screen_fade_to_alpha_with_blur( 1, 1, 1 );
	level thread run_scene_first_frame( "e6_s2_deserted_part3_extras" );
	setsaveddvar( "r_skyTransition", 1 );
	level notify( "timelapse" );
	exploder( 1000 );
	stop_exploder( 900 );
	wait 1;
	level.player visionsetnaked( "afghanistan_deserted_sunset", 8 );
	level.player reset_dof();
	level clientnotify( "set_deserted_fog_banks" );
	level.player screen_fade_to_alpha_with_blur( 0,8, 0,75, 1 );
	level thread lerp_sun_color_over_time();
	lerpsundirection( ( -0,283548, -0,779041, 0,559193 ), ( 0,283548, 0,779041, 0,359193 ), 10 );
	level.player screen_fade_to_alpha_with_blur( 0,35, 0,75, 0 );
	level.player screen_fade_to_alpha_with_blur( 0, 0,75, 0 );
	wait 0,75;
	wait 7,5;
	wait 0,5;
	level.player screen_fade_to_alpha_with_blur( 1, 2 );
	wait 1,5;
	stop_exploder( 1000 );
	exploder( 900 );
	level notify( "timelapse_end" );
	setsunlight( 0,7, 0,5, 0,6 );
	level thread run_scene( "e6_s2_deserted_part3" );
	level thread run_scene( "e6_s2_deserted_part3_extras" );
	wait 0,05;
	reznov_horse = get_model_or_models_from_scene( "e6_s2_deserted_part3", "reznov_horse" );
	reznov_horse setmodel( "anim_horse1_black_fb_nolod" );
	reznov = get_model_or_models_from_scene( "e6_s2_deserted_part3", "reznov" );
	reznov_tag_origin = reznov gettagorigin( "tag_weapon_left" );
	reznov_tag_angles = reznov gettagangles( "tag_weapon_left" );
	canteen = spawn_model( "p_jun_gear_canteen", reznov_tag_origin, reznov_tag_angles );
	canteen linkto( reznov, "tag_weapon_left" );
	level.player visionsetnaked( "afghanistan_deserted_sunset", 0,05 );
	level.player reset_dof();
	level.player screen_fade_to_alpha_with_blur( 0,25, 5, 3 );
	level.player thread screen_fade_to_alpha_with_blur( 0, 5, 0,3 );
	anim_length = getanimlength( %p_af_06_02_deserted_player_view03 );
	wait ( anim_length - 9 );
	level thread screen_fade_out( 1, undefined, undefined, 1 );
	wait 2;
	rpc( "clientscripts/_audio", "cmnLevelFadeout" );
	wait 2;
	level clientnotify( "fade_out" );
	level.player notify( "mission_finished" );
	level nextmission();
}

lerp_sun_color_over_time()
{
	end_sun_color = [];
	end_sun_color[ 0 ] = 0,9;
	end_sun_color[ 1 ] = 0,6;
	end_sun_color[ 2 ] = 0,6;
	current_sun_color = [];
	current_sun_color[ 0 ] = 0,992157;
	current_sun_color[ 1 ] = 0,956863;
	current_sun_color[ 2 ] = 0,839216;
	time = 10;
	lerp_sun_color = [];
	lerp_sun_color[ 0 ] = ( end_sun_color[ 0 ] - current_sun_color[ 0 ] ) / 200;
	lerp_sun_color[ 1 ] = ( end_sun_color[ 1 ] - current_sun_color[ 1 ] ) / 200;
	lerp_sun_color[ 2 ] = ( end_sun_color[ 2 ] - current_sun_color[ 2 ] ) / 200;
	while ( time > 0 )
	{
		current_sun_color[ 0 ] += lerp_sun_color[ 0 ];
		current_sun_color[ 1 ] += lerp_sun_color[ 1 ];
		current_sun_color[ 2 ] += lerp_sun_color[ 2 ];
		setsunlight( current_sun_color[ 0 ], current_sun_color[ 1 ], current_sun_color[ 2 ] );
		wait 0,05;
		time -= 0,05;
	}
}

handle_vulture()
{
	self endon( "deleted" );
	self useanimtree( -1 );
	while ( 1 )
	{
		rand = randomint( 100 );
		self clearanim( %root, 0 );
		if ( rand < 70 )
		{
			self setanim( %a_vulture_idle, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_idle );
		}
		else
		{
			self setanim( %a_vulture_idle_twitch, 1, 0, 1 );
			anim_durration = getanimlength( %a_vulture_idle_twitch );
		}
		wait anim_durration;
	}
}

deserted_truck_kickup_dust( vh_truck )
{
	fx_kickup = getfx( "truck_kickup_dust" );
	playfxontag( fx_kickup, vh_truck, "tag_origin" );
	level thread capture_screen_dirt();
}

deserted_truck_kickout_impact( e_guy )
{
	fx_impact = getfx( "fx_afgh_sand_body_impact" );
	fx_origin = e_guy gettagorigin( "j_spine4" );
	playfx( fx_impact, fx_origin );
}

deserted_truck_kickout_impact_player( e_guy )
{
	fx_impact = getfx( "fx_afgh_sand_body_impact" );
	earthquake( 0,5, 0,6, level.player.origin, 128 );
	level.player dodamage( 50, level.player.origin );
	playfx( fx_impact, e_guy.origin );
	level notify( "kicked_in_the_face" );
}

deserted_flip_over( e_guy )
{
	earthquake( 0,25, 0,6, e_guy.origin, 128 );
}

deserted_start_fade_out( e_guy )
{
	level notify( "start_deserted_first_fade_out" );
}

capture_screen_dirt()
{
	hud_dirt = newclienthudelem( level.player );
	hud_dirt setshader( "fullscreen_dirt_bottom_b", 640, 480 );
	hud_dirt.horzalign = "center";
	hud_dirt.vertalign = "middle";
	hud_dirt.alignx = "center";
	hud_dirt.aligny = "middle";
	hud_dirt.foreground = 1;
	hud_dirt.alpha = 0;
	hud_dirt fadeovertime( 0,5 );
	hud_dirt.alpha = 1;
	wait 3;
	hud_dirt fadeovertime( 2 );
	hud_dirt.alpha = 0;
	wait 2;
	hud_dirt destroy();
}

play_fx_anim_bush()
{
	level thread run_scene( "e6_s2_deserted_bush_normal" );
	level waittill( "timelapse" );
	level end_scene( "e6_s2_deserted_bush_normal" );
	level run_scene( "e6_s2_deserted_bush_ramp" );
	level thread run_scene( "e6_s2_deserted_bush_fast" );
	level waittill( "timelapse_end" );
	wait 1;
	level thread run_scene( "e6_s2_deserted_bush_normal" );
}
