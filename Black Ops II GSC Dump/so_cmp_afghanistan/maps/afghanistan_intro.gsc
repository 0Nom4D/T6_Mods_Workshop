#include maps/_horse_rider;
#include maps/afghanistan_horse_intro;
#include maps/_music;
#include maps/_horse;
#include maps/_dialog;
#include maps/_objectives;
#include maps/_vehicle;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

init_flags()
{
	flag_init( "e1_woods_arrived_at_wall" );
	flag_init( "e1_zhao_finished" );
	flag_init( "e1_woods_finished" );
	flag_init( "e1_begin_charge" );
}

skipto_intro()
{
	skipto_setup();
}

main()
{
	exploder( 100 );
	exploder( 200 );
	exploder( 201 );
	exploder( 230 );
	exploder( 300 );
	temp_move = get_struct( "special_delivery_start", "targetname", 1 );
	init_flags();
	spawn_heroes();
	woods_zhao_trigger = getent( "wood_zhao_wait_canyon_wait_trigger", "targetname" );
	woods_zhao_trigger triggeroff();
	post_intro_blocker_trigger = getent( "post_intro_blocker_trigger", "script_noteworthy" );
	post_intro_blocker_trigger triggeroff();
	insta_fail_trigger = getent( "e1_intro_insta_fail_trigger", "targetname" );
	insta_fail_trigger thread insta_fail_trigger();
	setmusicstate( "AFGHAN_INTRO" );
	e1_start();
}

spawn_heroes()
{
	woods = getent( "woods", "targetname" );
	woods add_spawn_function( ::set_horse_anim );
	level.woods = init_hero( "woods" );
	level.woods setgoalpos( level.woods.origin );
	s_player_horse = getstruct( "horse_player_pos", "targetname" );
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_player_horse.origin;
	level.mason_horse.angles = s_player_horse.angles;
	level.mason_horse makevehicleunusable();
	level.woods.vh_my_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods.vh_my_horse.animname = "woods_horse";
	level.woods.vh_my_horse makevehicleunusable();
	level.woods.vh_my_horse hide();
	wait 0,5;
	level.mason_horse hide();
	s_player_horse structdelete();
	s_player_horse = undefined;
}

e1_start()
{
	level thread spawn_horses();
	level thread spawn_far_loop_entities();
	level thread unhide_riders();
	level.woods attach( "t5_weapon_static_binoculars", "tag_weapon1" );
	run_scene_first_frame( "e1_player_wood_greeting" );
	flag_wait( "starting final intro screen fadeout" );
	set_objective( level.obj_initial );
	level.player setviewmodeldepthoffield( 0,5, 8 );
	setsaveddvar( "r_stereo3DEyeSeparationScaler", 0,1 );
	level notify( "fxanim_rappel_rope_start" );
	level thread run_scene( "e1_player_wood_greeting" );
	level thread run_scene( "e1_zhao_horse_approach_spread" );
	wrap_body = get_model_or_models_from_scene( "e1_player_wood_greeting", "player_body" );
	wrap_body setmodel( "c_usa_mason_afgan_wrap_viewbody" );
	wrap_body setviewmodelrenderflag( 1 );
	wrap_body setforcenocull();
	scene_wait( "e1_player_wood_greeting" );
	level.woods detach( "t5_weapon_static_binoculars", "tag_weapon1" );
	level thread remove_woods_facemask_util();
	level thread stereo3d_lerp_depth();
	level.player thread depth_of_field_off( 0,5 );
	rappel_rope = getent( "rappel_rope", "targetname" );
	rappel_rope delete();
	flag_set( "e1_begin_charge" );
	level.player enableinvulnerability();
	level thread run_scene( "e1_zhao_horse_charge_player" );
	level thread run_scene( "e1_zhao_horse_charge_woods_intro" );
	level thread start_woods_horse();
	setmusicstate( "AFGHAN_LOW_WALL" );
	level thread manage_anim_timescale();
	level thread zhao_horse_charge();
	level thread horse_charge_muj1();
	level thread horse_charge_muj2();
	level thread horse_charge_muj3();
	level thread horse_charge_muj4();
	level.player setstance( "stand" );
	level thread wait_and_play_woods_end_idle();
	level thread wait_and_play_zhao_end_idle();
	scene_wait( "e1_zhao_horse_charge_player" );
	level.mason_horse makevehicleusable();
	level.player disableinvulnerability();
	autosave_by_name( "e1_intro" );
	level thread maps/afghanistan_horse_intro::play_ride_dialog();
	level thread too_far_fail_managment();
}

stereo3d_lerp_depth()
{
	val = 0,1;
	while ( val <= 1 )
	{
		setsaveddvar( "r_stereo3DEyeSeparationScaler", val );
		wait 0,1;
		val += 0,1;
	}
	setsaveddvar( "r_stereo3DEyeSeparationScaler", 1 );
}

spotlight_on_woods()
{
	e_spotlight = spawn( "script_model", self gettagorigin( "tag_eye" ) + ( anglesToForward( self gettagangles( "tag_eye" ) ) * 16 ) );
	e_spotlight.angles = self gettagangles( "tag_eye" ) * -1;
	e_spotlight setmodel( "tag_origin" );
	e_spotlight linkto( self, "tag_eye" );
	playfxontag( level._effect[ "spotlight_intro" ], e_spotlight, "tag_origin" );
	scene_wait( "e1_player_wood_greeting" );
	e_spotlight delete();
}

start_woods_horse()
{
	level waittill( "show_woods_horse" );
	wait 3;
	level.woods.vh_my_horse show();
	level thread run_scene_first_frame( "e1_zhao_horse_charge_woods_horse_intro" );
	flag_wait( "start_woods_horse" );
	level thread run_scene( "e1_zhao_horse_charge_woods_horse_intro" );
}

zhao_horse_charge()
{
	level thread run_scene( "e1_zhao_horse_charge" );
	wait 0,1;
	zhaos_horse = get_model_or_models_from_scene( "e1_zhao_horse_charge", "zhao_approach_horse" );
	zhaos_horse setmodel( "anim_horse1_closeup_fb" );
}

horse_charge_muj1()
{
	level run_scene( "e1_horse_charge_muj1" );
	level thread run_scene( "e1_horse_charge_muj1_endloop" );
}

horse_charge_muj2()
{
	level run_scene( "e1_horse_charge_muj2" );
	level thread run_scene( "e1_horse_charge_muj2_endloop" );
}

horse_charge_muj3()
{
	level run_scene( "e1_horse_charge_muj3" );
	level thread run_scene( "e1_horse_charge_muj3_endloop" );
}

horse_charge_muj4()
{
	level run_scene( "e1_horse_charge_muj4" );
	level thread run_scene( "e1_horse_charge_muj4_endloop" );
}

wait_and_play_zhao_end_idle()
{
	level endon( "player_mounted_horse" );
	level scene_wait( "e1_zhao_horse_charge" );
	level notify( "e1_zhao_finished" );
	level thread run_scene( "e1_zhao_horse_charge_idle" );
}

wait_and_play_woods_end_idle()
{
	level endon( "player_mounted_horse" );
	level scene_wait( "e1_zhao_horse_charge_woods_intro" );
	level notify( "e1_woods_finished" );
	if ( isDefined( level.woods.vh_my_horse ) )
	{
		level thread run_scene( "e1_zhao_horse_charge_woods_intro_idle" );
	}
}

spawn_horses()
{
	zhao = getent( "zhao", "targetname" );
	zhao add_spawn_function( ::set_horse_anim );
	level.zhao = init_hero( "zhao" );
	level.zhao.vh_my_horse = spawn_vehicle_from_targetname( "zhao_approach_horse" );
	level.zhao.vh_my_horse.animname = "zhao_horse";
	level.zhao hide();
	level.zhao.vh_my_horse hide();
	level.zhao setgoalpos( level.zhao.origin );
	horse_colors = [];
	horse_colors[ 0 ] = "anim_horse1_light_brown_fb";
	horse_colors[ 1 ] = "anim_horse1_brown_spots_fb";
	horse_colors[ 2 ] = "anim_horse1_brown_black_fb";
	horse_colors[ 3 ] = "anim_horse1_brown_black_fb";
	level.muj_horses = [];
	i = 0;
	while ( i < 4 )
	{
		level.muj_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		level.muj_horses[ i ] setmodel( horse_colors[ i ] );
		i++;
	}
	muj_spawner = getent( "e1_zhao_horseman_spawner", "targetname" );
	muj_spawner add_spawn_function( ::set_horse_anim );
	level.intro_horsemen = [];
	level.intro_horsemen[ level.intro_horsemen.size ] = simple_spawn_single( "e1_zhao_horseman_spawner" );
	level.intro_horsemen[ level.intro_horsemen.size ] = simple_spawn_single( "e1_zhao_horseman_spawner" );
	level.intro_horsemen[ level.intro_horsemen.size ] = simple_spawn_single( "e1_zhao_horseman_spawner" );
	level.intro_horsemen[ level.intro_horsemen.size ] = simple_spawn_single( "e1_zhao_horseman_spawner" );
	i = 0;
	while ( i < level.muj_horses.size )
	{
		level.intro_horsemen[ i ].animname = "horse_muj_" + ( i + 1 );
		level.intro_horsemen[ i ] hide();
		level.muj_horses[ i ].animname = "muj_horse_" + ( i + 1 );
		level.muj_horses[ i ] hide();
		i++;
	}
	level waittill( "start_horse_event" );
	i = 0;
	while ( i < level.muj_horses.size )
	{
		level.muj_horses[ i ].cleanup_time = "e3_clean_up";
		i++;
	}
	horse_colors = undefined;
}

unhide_riders()
{
	flag_wait( "unhide_riders" );
	level.zhao show();
	level.zhao.vh_my_horse show();
	i = 0;
	while ( i < level.muj_horses.size )
	{
		level.intro_horsemen[ i ] show();
		level.muj_horses[ i ] show();
		i++;
	}
}

spawn_far_loop_entities()
{
	muj_men = [];
	x = 0;
	while ( x < 5 )
	{
		muj_men[ x ] = spawn_model( "c_usa_jungmar_assault_fb" );
		muj_men[ x ].animname = "muj_horse_" + x + 1;
		wait 0,05;
		x++;
	}
	muj_horse = [];
	x = 0;
	while ( x < 5 )
	{
		muj_horse[ x ] = spawn_model( "anim_horse1_fb" );
		muj_horse[ x ].animname = "horse_muj_" + x + 1;
		wait 0,05;
		x++;
	}
	flag_wait( "e1_begin_charge" );
	x = 0;
	while ( x < muj_men.size )
	{
		muj_men[ x ] delete();
		x++;
	}
	x = 0;
	while ( x < muj_horse.size )
	{
		muj_horse[ x ] delete();
		x++;
	}
	muj_men = undefined;
	muj_horse = undefined;
}

horse_jump( node_number )
{
	zhao_node = getvehiclenode( "e1_zhao_node", "targetname" );
	self waittill( "reached_end_node" );
	if ( self == level.zhao.vh_my_horse )
	{
		self go_path( zhao_node );
	}
	else
	{
		self go_path( level.muj_encircling_node[ node_number ] );
	}
}

set_horse_anim()
{
	self waittill( "enter_vehicle", vehicle );
	vehicle notify( "groupedanimevent" );
	self notify( "ride" );
	self maps/_horse_rider::ride_and_shoot( vehicle );
}

manage_anim_timescale()
{
	flag_wait( "time_scale_horse" );
	delete_exploder( 100 );
	delay_thread( 0,6, ::manage_wall_fxanim );
	level.mason_horse show();
}

manage_wall_fxanim()
{
	level notify( "fxanim_horse_wall_break_start" );
	exploder( 10150 );
}

send_player_horse()
{
	level.mason_horse attachpath( getvehiclenode( "start_horse_path", "targetname" ) );
	level.mason_horse startpath();
	level.mason_horse waittill( "reached_end_node" );
	level.mason_horse vehicle_detachfrompath();
}
