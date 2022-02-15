#include maps/afghanistan_deserted;
#include maps/afghanistan_krav_captured;
#include maps/afghanistan_horse_charge;
#include maps/afghanistan_wave_1;
#include maps/afghanistan_firehorse;
#include maps/createart/afghanistan_art;
#include maps/voice/voice_afghanistan;
#include maps/_music;
#include maps/_turret;
#include maps/_anim;
#include maps/_dialog;
#include maps/_scene;
#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "player" );
#using_animtree( "generic_human" );
#using_animtree( "animated_props" );
#using_animtree( "horse" );
#using_animtree( "vehicles" );
#using_animtree( "fxanim_props" );

main()
{
	maps/voice/voice_afghanistan::init_voice();
	e1_s1_pulwar_scene();
	e1_s1_pulwar_single_scene();
	e2_s1_base_props();
	lockbreaker_perk_scene();
	intruder_perk_scene();
	e1_s1_player_wood_scene();
	e1_s2_horse_approach();
	e1_s2_lotr_horse_scene();
	e1_s2_lotr_woods_horse_scene();
	e1_s2_ride_vignettes();
	patroller_anims();
	setup_brainwash_anims();
	level.scr_anim[ "generic" ][ "ai_mantle_over_40_across_30" ] = %ai_mantle_over_40_across_30;
	level.scr_anim[ "generic" ][ "ai_jump_across_72_down_30" ] = %ai_jump_across_72_down_30;
	precache_assets();
}

init_afghan_anims_part1()
{
	e2_s1_ride_scenes();
	e2_s1_base_activity();
	walkto_cave_entrance_scene();
	cave_entrance_wait_scene();
	cave_enter_scene();
	map_room_wait_scene();
	map_room_scene();
	precache_assets( 1 );
}

init_afghan_anims_part1b()
{
	e3_s1_leave_map_room_scene();
	e3_s1_map_room_idle_scene();
	e3_s1_ride_out_scene();
	e3_s1_chopper_crash_scene();
	e3_s1_arena_rocks_scene();
	plant_explosive_dome_scene();
	plant_explosive_dome_stairs_scene();
	precache_assets( 1 );
}

init_afghan_anims_part2()
{
	e4_s1_return_base_lineup_scene();
	e4_s1_binoc_scene();
	e4_s5_player_and_horse_fall();
	e4_s5_tank_fall();
	e4_s6_player_grabs_on_tank_scene();
	e4_s6_tank_fight_scene();
	e4_s6_strangle_scene();
	e5_s2_interrogation();
	e5_s4_beatdown_scene();
	e6_s2_deserted_bush_anim_scene();
	e6_s2_ontruck_1_scene();
	e6_s2_ontruck_trucks_scene();
	e6_s2_offtruck_scene();
	e6_s2_deserted_part1_scene();
	e6_s2_deserted_part2_scene();
	e6_s2_deserted_part3_scene();
	precache_assets( 1 );
}

intruder_perk_scene()
{
	add_scene( "intruder", "intruder_strongbox" );
	add_prop_anim( "intruder_box_cutter", %o_specialty_afghanistan_intruder_boltcutter, "t6_wpn_boltcutters_prop_view", 1 );
	add_player_anim( "player_hands", %int_specialty_afghanistan_intruder, 1 );
	add_scene( "intruder_box_and_mine", "intruder_strongbox" );
	add_prop_anim( "intruder_grabbed_mine", %o_specialty_afghanistan_intruder_grabbed_mine, "t6_wpn_mine_tc6_world", 1 );
	add_prop_anim( "intruder_box", %o_specialty_afghanistan_intruder_strongbox );
}

lockbreaker_perk_scene()
{
	add_scene( "lockbreaker", "mortar_door_align" );
	add_player_anim( "player_hands", %int_specialty_afghanistan_lockbreaker, 1 );
	add_prop_anim( "cutter", %o_specialty_afghanistan_lockbreaker_device, "t6_wpn_lock_pick_view", 1 );
	add_prop_anim( "mortar1", %o_specialty_afghanistan_lockbreaker_mortar1, "t6_wpn_mortar_shell_prop_view", 1 );
	add_prop_anim( "mortar2", %o_specialty_afghanistan_lockbreaker_mortar2, "t6_wpn_mortar_shell_prop_view", 1 );
	add_prop_anim( "afghan_lockbreaker_door", %o_specialty_afghanistan_lockbreaker_door, "p6_lockbreaker_door", 0 );
}

e1_s1_pulwar_scene()
{
	add_scene( "e1_s1_pulwar", "dead_guy_node" );
	add_player_anim( "player_body", %p_af_01_03_pulwar_player, 1 );
	add_prop_anim( "crowbar", %o_af_01_03_pulwar_crowbar, "t6_wpn_crowbar_prop", 1 );
	add_prop_anim( "sword", %o_af_01_03_pulwar_pulwar, "t6_wpn_pulwar_sword_prop", 1 );
	add_notetrack_custom_function( "player_body", "spark_fx", ::pulwar_fx );
	add_scene( "e1_s1_pulwar_player", "dead_guy_node" );
	add_player_anim( "player_body", %p_af_01_03_pulwar_player, 1 );
}

pulwar_fx( guy )
{
	exploder( 110 );
}

e1_s1_pulwar_single_scene()
{
	add_scene( "e1_s1_pulwar_single", "dead_guy_node" );
	add_prop_anim( "sword", %o_af_01_03_pulwar_pulwar, "t6_wpn_pulwar_sword_prop" );
}

e1_s1_player_wood_scene()
{
	add_scene( "e1_player_wood_greeting", "special_delivery_start" );
	add_actor_anim( "woods", %ch_af_01_01_intro_woods_start );
	add_player_anim( "player_body", %p_af_01_01_intro_player_start, 0, 0, undefined, 0, 1, 30, 20, 20, 20 );
	add_notetrack_flag( "player_body", "start_horses", "start_horses" );
	add_notetrack_custom_function( "player_body", "dof_lookout", ::maps/createart/afghanistan_art::dof_lookout );
	add_notetrack_custom_function( "player_body", "dof_rappell", ::maps/createart/afghanistan_art::dof_rappell );
	add_notetrack_custom_function( "player_body", "dof_landed", ::maps/createart/afghanistan_art::dof_landed );
	add_notetrack_custom_function( "player_body", "dof_run2wall", ::maps/createart/afghanistan_art::dof_run2wall );
	add_notetrack_custom_function( "player_body", "dof_hit_wall", ::run2wall_allow_headlook );
	add_notetrack_custom_function( "player_body", "dof_hit_wall", ::maps/createart/afghanistan_art::dof_hit_wall );
	add_notetrack_fx_on_tag( "woods", "jump", "fx_afgh_sand_body_impact", "J_Ankle_LE" );
	add_notetrack_fx_on_tag( "woods", "impact", "fx_afgh_rappel_impact", "J_Ankle_RI" );
	add_notetrack_fx_on_tag( "woods", "land", "fx_afgh_rappel_impact_lg", "J_Ankle_RI" );
}

run2wall_allow_headlook( player_body )
{
	level.player setlowready( 1 );
	level.player enableweapons();
	level.player showviewmodel();
	level.player switch_player_scene_to_delta();
	player_body setmodel( "c_usa_mason_afgan_viewbody" );
}

e1_s2_horse_approach()
{
	add_scene( "e1_zhao_horse_approach_spread", "special_delivery_start" );
	add_actor_model_anim( "zhao_approach", %ch_af_01_05_zhaoapproach_spread_zhao, undefined, 1, undefined, undefined, "zhao_approach" );
	add_actor_model_anim( "horse_approach_1", %ch_af_01_05_zhaoapproach_spread_muj01, undefined, 1, undefined, undefined, "zhao_approach" );
	add_actor_model_anim( "horse_approach_2", %ch_af_01_05_zhaoapproach_spread_muj02, undefined, 1, undefined, undefined, "zhao_approach" );
	add_actor_model_anim( "horse_approach_3", %ch_af_01_05_zhaoapproach_spread_muj03, undefined, 1, undefined, undefined, "zhao_approach" );
	add_actor_model_anim( "horse_approach_4", %ch_af_01_05_zhaoapproach_spread_muj04, undefined, 1, undefined, undefined, "zhao_approach" );
	add_horse_anim( "zhao_spread_horse", %ch_af_01_05_zhaoapproach_spread_zhao_horse, 1 );
	add_horse_anim( "muj_horse_approach_1", %ch_af_01_05_zhaoapproach_spread_muj01_horse, 1 );
	add_horse_anim( "muj_horse_approach_2", %ch_af_01_05_zhaoapproach_spread_muj02_horse, 1 );
	add_horse_anim( "muj_horse_approach_3", %ch_af_01_05_zhaoapproach_spread_muj03_horse, 1 );
	add_horse_anim( "muj_horse_approach_4", %ch_af_01_05_zhaoapproach_spread_muj04_horse, 1 );
}

e1_s2_lotr_horse_scene()
{
	add_scene( "e1_zhao_horse_charge_woods_intro", "special_delivery_start" );
	add_actor_anim( "woods", %ch_af_01_05_zhaointro_woods );
	add_notetrack_flag( "woods", "start_woods_horse", "start_woods_horse" );
	add_scene( "e1_zhao_horse_charge_woods_horse_intro", "special_delivery_start" );
	add_horse_anim( "woods_horse", %ch_af_01_05_zhaointro_horse_woods );
	add_scene( "e1_zhao_horse_charge_woods_intro_idle", "special_delivery_start", 0, 0, 1 );
	add_actor_anim( "woods", %ch_af_01_05_zhaointro_woods_endidl );
	add_horse_anim( "woods_horse", %ch_af_01_05_zhaointro_horse_woods_endidl );
	add_scene( "e1_zhao_horse_charge_player", "special_delivery_start" );
	add_notetrack_flag( "player_body", "start_rocks", "time_scale_horse" );
	add_notetrack_flag( "player_body", "unhide_riders", "unhide_riders" );
	add_player_anim( "player_body", %p_af_01_05_zhaointro_player, 1, 0, undefined, 1, 1, 30, 20, 20, 20 );
	set_player_anim_use_lowready( "player_body" );
	add_notetrack_custom_function( "player_body", "raise_weapon", ::raise_weapon );
	add_notetrack_level_notify( "player_body", "raise_weapon", "show_woods_horse" );
	add_notetrack_custom_function( "player_body", "lower_weapon", ::lower_weapon );
	add_notetrack_custom_function( "player_body", "dof_woods", ::maps/createart/afghanistan_art::dof_woods );
	add_notetrack_custom_function( "player_body", "dof_horses", ::maps/createart/afghanistan_art::dof_horses );
	add_notetrack_custom_function( "player_body", "dof_jumped", ::maps/createart/afghanistan_art::dof_jumped );
	add_notetrack_custom_function( "player_body", "dof_woods_up", ::maps/createart/afghanistan_art::dof_woods_up );
	add_notetrack_custom_function( "player_body", "dof_zhao", ::maps/createart/afghanistan_art::dof_zhao );
	add_notetrack_custom_function( "player_body", "dof_woods_end", ::maps/createart/afghanistan_art::dof_woods_end );
	add_scene( "e1_zhao_horse_charge", "special_delivery_start" );
	add_actor_anim( "zhao", %ch_af_01_05_zhaointro_zhao );
	add_horse_anim( "zhao_approach_horse", %ch_af_01_05_zhaointro_horse_zhao );
	set_vehicle_unusable_in_scene( "zhao_approach_horse" );
	add_scene( "e1_zhao_horse_charge_idle", "special_delivery_start", 0, 0, 1 );
	add_actor_anim( "zhao", %ch_af_01_05_zhaointro_zhao_endidl );
	add_horse_anim( "zhao_approach_horse", %ch_af_01_05_zhaointro_horse_zhao_endidl );
	add_scene( "e1_horse_charge_muj1", "special_delivery_start" );
	add_actor_anim( "horse_muj_1", %ch_af_01_05_henchman1, 0, 0, 0, 1 );
	add_horse_anim( "muj_horse_1", %ch_af_01_05_horse1 );
	set_vehicle_unusable_in_scene( "muj_horse_1" );
	add_notetrack_fx_on_tag( "muj_horse_1", "Start_spin", "fx_afgh_sand_body_impact", "tag_origin" );
	add_scene( "e1_horse_charge_muj2", "special_delivery_start" );
	add_actor_anim( "horse_muj_2", %ch_af_01_05_henchman2, 0, 0, 0, 1 );
	add_horse_anim( "muj_horse_2", %ch_af_01_05_horse2 );
	set_vehicle_unusable_in_scene( "muj_horse_2" );
	add_scene( "e1_horse_charge_muj3", "special_delivery_start" );
	add_actor_anim( "horse_muj_3", %ch_af_01_05_henchman3, 0, 0, 0, 1 );
	add_horse_anim( "muj_horse_3", %ch_af_01_05_horse3 );
	set_vehicle_unusable_in_scene( "muj_horse_3" );
	add_notetrack_fx_on_tag( "muj_horse_3", "Start_spin", "fx_afgh_sand_body_impact", "tag_origin" );
	add_scene( "e1_horse_charge_muj4", "special_delivery_start" );
	add_actor_anim( "horse_muj_4", %ch_af_01_05_henchman4, 0, 0, 0, 1 );
	add_horse_anim( "muj_horse_4", %ch_af_01_05_horse4 );
	set_vehicle_unusable_in_scene( "muj_horse_4" );
	add_prop_anim( "ammo_box", %o_af_01_05_gunbox, "p6_anim_ammo_box" );
	add_scene( "e1_horse_charge_muj1_endloop", "special_delivery_start", 0, 0, 1 );
	add_horse_anim( "muj_horse_1", %ch_af_01_05_horse1_endloop );
	add_actor_anim( "horse_muj_1", %ch_af_01_05_henchman1_endloop, 0, 0, 0, 1 );
	add_scene( "e1_horse_charge_muj2_endloop", "special_delivery_start", 0, 0, 1 );
	add_horse_anim( "muj_horse_2", %ch_af_01_05_horse2_endloop );
	add_actor_anim( "horse_muj_2", %ch_af_01_05_henchman2_endloop, 0, 0, 0, 1 );
	add_scene( "e1_horse_charge_muj3_endloop", "special_delivery_start", 0, 0, 1 );
	add_horse_anim( "muj_horse_3", %ch_af_01_05_horse3_endloop );
	add_actor_anim( "horse_muj_3", %ch_af_01_05_henchman3_endloop, 0, 0, 0, 1 );
	add_scene( "e1_horse_charge_muj4_endloop", "special_delivery_start", 0, 0, 1 );
	add_horse_anim( "muj_horse_4", %ch_af_01_05_horse4_endloop );
	add_actor_anim( "horse_muj_4", %ch_af_01_05_henchman4_endloop, 0, 0, 0, 1 );
}

raise_weapon( player )
{
	setsaveddvar( "cg_DrawCrosshair", 0 );
	level.player setlowready( 0 );
	level.player disableweaponfire();
	level.player disableoffhandweapons();
	level.player allowsprint( 0 );
	a_gun_crate = getentarray( "crate_guns", "targetname" );
	_a313 = a_gun_crate;
	_k313 = getFirstArrayKey( _a313 );
	while ( isDefined( _k313 ) )
	{
		gun = _a313[ _k313 ];
		gun show();
		_k313 = getNextArrayKey( _a313, _k313 );
	}
}

lower_weapon( player )
{
	level.player enableweaponfire();
	level.player enableoffhandweapons();
	level.player allowsprint( 1 );
	level.player setlowready( 1 );
	setsaveddvar( "cg_DrawCrosshair", 1 );
}

ready_weapon( player )
{
	level.player showviewmodel();
	level.player enableweapons();
	level.player setlowready( 1 );
}

e1_s2_ride_vignettes()
{
	add_scene( "e1_truck_offload", "jeep_unloading_weaponcache" );
	add_actor_anim( "truck_muj_1", %ch_af_02_02_truck_offload_muj1, 0, 0, 0, 1 );
	add_actor_anim( "truck_muj_2", %ch_af_02_02_truck_offload_muj2, 1, 0, 0, 1 );
	add_vehicle_anim( "truck_offload", %v_af_02_02_truck_offload_truck, undefined, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	add_scene( "e1_truck_offload_idle", "jeep_unloading_weaponcache" );
	add_actor_anim( "truck_muj_1", %ch_af_02_02_truck_offload_muj1_idle, 0, 0, 0, 1 );
	add_scene( "e1_truck_hold_truck_idle", "truck_vig_offload", 0, 0, 0, 0 );
	add_actor_anim( "truck_muj_2", %ch_af_02_02_truck_offload_muj2_idle, 0, 0, 0, 1, "tag_origin" );
	add_scene( "e1_ride_lookout", undefined, undefined, undefined, 1, 1 );
	add_actor_anim( "e1_ride_vig_lookout1", %ch_af_02_01_ridge_lookout_guy1, 0, 0, 0, 1 );
	add_actor_anim( "e1_ride_vig_lookout2", %ch_af_02_01_ridge_lookout_guy2, 0, 0, 0, 1 );
}

e1_s2_lotr_woods_horse_scene()
{
	add_scene( "e1_zhao_horse_charge_woods", "special_delivery_start" );
	add_horse_anim( "woods_horse", %ch_af_01_05_horse_woods );
}

walkto_cave_entrance_scene()
{
	add_scene( "walkto_cave_entrance", "rats_nest_struct" );
	add_actor_anim( "woods", %ch_af_02_01_map_room_woods_walktocave, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_02_01_map_room_zhao_walktocave, 0, 1, 0, 1 );
}

cave_entrance_wait_scene()
{
	add_scene( "cave_entrance_wait", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "woods", %ch_af_02_01_enter_cave_woods_entrance_idle, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_02_01_enter_cave_zhao_entrance_idle, 0, 1, 0, 1 );
}

cave_enter_scene()
{
	add_scene( "cave_enter", "rats_nest_struct" );
	add_player_anim( "player_body", %p_af_02_01_enter_cave_player, 0, 0, undefined, 1, 1, 45, 25, 10, 10 );
	add_actor_anim( "woods", %ch_af_02_01_enter_cave_woods, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_02_01_enter_cave_zhao, 0, 1, 0, 1 );
	add_actor_anim( "hudson", %ch_af_02_01_enter_cave_hudson, 0, 1, 0, 1 );
	add_actor_anim( "rebel_leader", %ch_af_02_01_enter_cave_leader, 0, 1, 0, 1 );
	add_actor_anim( "guard1", %ch_af_02_01_enter_cave_guard1, 0, 1, 0, 1, undefined, "spawner_unique_muj_3" );
	add_actor_anim( "guard2", %ch_af_02_01_enter_cave_guard2, 0, 1, 0, 1, undefined, "spawner_unique_muj_2" );
	add_scene( "cave_enter_player_only", "rats_nest_struct" );
	add_player_anim( "player_body", %p_af_02_01_enter_cave_player, 0, 0, undefined, 1, 1, 45, 25, 10, 10 );
}

map_room_wait_scene()
{
}

show_woods_ak47()
{
	woods = get_ais_from_scene( "map_room", "woods" );
	ak47 = get_model_or_models_from_scene( "map_room", "woods_ak47" );
	woods gun_remove();
	ak47 show();
}

hide_woods_ak47()
{
	woods = get_ais_from_scene( "e3_exit_map_room", "woods" );
	ak47 = get_model_or_models_from_scene( "e3_exit_map_room", "woods_ak47" );
	woods gun_recall();
	ak47 hide();
}

map_room_scene()
{
	add_scene( "map_room", "rats_nest_struct" );
	add_actor_anim( "woods", %ch_af_02_01_map_room_conversation_woods, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_02_01_map_room_conversation_zhao, 0, 1, 0, 1 );
	add_actor_anim( "hudson", %ch_af_02_01_map_room_conversation_hudson, 0, 1, 0, 1 );
	add_actor_anim( "rebel_leader", %ch_af_02_01_map_room_conversation_omar, 0, 1, 0, 1 );
	add_actor_anim( "guard1", %ch_af_02_01_map_room_conversation_guard1, 0, 1, 0, 1, undefined, "spawner_unique_muj_3" );
	add_actor_anim( "guard2", %ch_af_02_01_map_room_conversation_guard2, 0, 1, 0, 1, undefined, "spawner_unique_muj_2" );
	add_player_anim( "player_body", %p_af_02_01_map_room_conversation_player, 0, 0, undefined, 1, 1, 45, 25, 10, 10 );
	add_prop_anim( "woods_ak47", %o_af_02_01_map_room_conversation_prop_gun, "t6_wpn_ar_ak47_prop", 0 );
	add_notetrack_custom_function( "player_body", "dof_woods", ::maps/createart/afghanistan_art::dof_omar );
	add_notetrack_custom_function( "woods", "prop_gun_start", ::show_woods_ak47 );
}

e3_s1_leave_map_room_scene()
{
	add_scene( "e3_exit_map_room", "rats_nest_struct" );
	add_actor_anim( "woods", %ch_af_03_01_base_leave_woods_exit, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_03_01_base_leave_zhao_exit, 0, 1, 0, 1 );
	add_prop_anim( "woods_ak47", %o_af_03_01_base_leave_prop_gun, "t6_wpn_ar_ak47_prop", 1 );
	add_horse_anim( "zhao_horse", %ch_af_03_01_base_leave_horse_zhao_exit );
	add_horse_anim( "woods_horse", %ch_af_03_01_base_leave_horse_woods_exit );
	add_notetrack_custom_function( "woods", "prop_gun_stop", ::hide_woods_ak47 );
	add_scene( "e3_exit_map_room_guards", "rats_nest_struct" );
	add_actor_anim( "guard1", %ch_af_03_01_base_leave_guard1_exit, 0, 1, 0, 1, undefined, "spawner_unique_muj_3" );
	add_actor_anim( "guard2", %ch_af_03_01_base_leave_guard2_exit, 0, 1, 0, 1, undefined, "spawner_unique_muj_2" );
	add_actor_anim( "rebel_leader", %ch_af_03_01_base_leave_leader_exit, 0, 1, 0, 1 );
	add_actor_anim( "hudson", %ch_af_03_01_base_leave_hudson_exit, 0, 1, 0, 1 );
	add_scene( "e3_exit_map_room_player", "rats_nest_struct" );
	add_player_anim( "player_body", %p_af_03_01_base_leave_player_intro, 1, 0, undefined, 1, 1, 45, 15, 10, 10 );
	add_notetrack_custom_function( "player_body", "start_rifle_load", ::ready_weapon );
	add_notetrack_custom_function( "player_body", "dof_woods", ::maps/createart/afghanistan_art::dof_woods_end );
}

e3_s1_map_room_idle_scene()
{
	add_scene( "e3_map_room_idle", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "woods", %ch_af_03_01_base_leave_woods_idl, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_03_01_base_leave_zhao_idl, 0, 1, 0, 1 );
	add_horse_anim( "zhao_horse", %ch_af_03_01_base_leave_horse_zhao_idl );
	add_horse_anim( "woods_horse", %ch_af_03_01_base_leave_horse_woods_idl );
	add_scene( "e3_map_room_idle_everyone_else", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "guard1", %ch_af_03_01_base_leave_guard1_idle, 1, 1, 1, 1, undefined, "spawner_unique_muj_3" );
	add_actor_anim( "guard2", %ch_af_03_01_base_leave_guard2_idle, 1, 1, 1, 1, undefined, "spawner_unique_muj_2" );
	add_actor_anim( "rebel_leader", %ch_af_03_01_base_leave_leader_idl, 1, 1, 1, 1 );
	add_actor_anim( "hudson", %ch_af_03_01_base_leave_hudson_idl, 1, 1, 1, 1 );
	add_prop_anim( "chair1", %o_af_03_01_base_leave_chair1_idle, "p6_wooden_chair_anim", 1 );
	add_prop_anim( "chair2", %o_af_03_01_base_leave_chair2_idle, "p6_wooden_chair_anim", 1 );
}

e3_s1_ride_out_scene()
{
	add_scene( "e3_ride_out", "rats_nest_struct" );
	add_actor_anim( "woods", %ch_af_03_01_base_leave_woods_ride, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_03_01_base_leave_zhao_ride, 0, 1, 0, 1 );
	add_horse_anim( "woods_horse", %ch_af_03_01_base_leave_horse_woods_ride );
	add_horse_anim( "zhao_horse", %ch_af_03_01_base_leave_horse_zhao_ride );
	add_scene( "fire_horse", "rats_nest_struct" );
	add_horse_anim( "flaming_horse", %ch_af_03_01_base_leave_horse_onfire, 1 );
}

e3_s1_chopper_crash_scene()
{
	add_scene( "chopper_crash_overlooking_arena", undefined, 0, 0, 0, 1 );
	add_vehicle_anim( "arena_chopper_crash", %fxanim_afghan_chopper_crash_anim );
	add_notetrack_custom_function( "arena_chopper_crash", "exploder 10316 #cliff_impact", ::maps/afghanistan_firehorse::arena_chopper_crash );
	add_notetrack_custom_function( "arena_chopper_crash", "exploder 10317 #ground_impact", ::maps/afghanistan_firehorse::arena_rock_crash );
	add_notetrack_custom_function( "arena_chopper_crash", "exploder 10315 #chopper_hit", ::maps/afghanistan_firehorse::arena_chopper_trail );
}

e3_s1_arena_rocks_scene()
{
	add_scene( "chopper_crash_rocks", undefined, 0, 0, 0, 1 );
	add_prop_anim( "chopper_crash_rockfall", %fxanim_afghan_chopper_crash_rocks_anim );
	add_prop_anim( "chopper_crash_blades", %fxanim_afghan_chopper_crash_blades_anim );
}

plant_explosive_dome_scene()
{
	add_scene( "plant_explosive_dome", "explosion_struct" );
	add_player_anim( "player_hands", %int_afghan_cratercharge_plant, 1 );
	add_prop_anim( "crater_charge", %o_afghan_cratercharge_plant );
	add_notetrack_custom_function( "player_hands", "plant", ::maps/afghanistan_wave_1::crater_charge_fx1 );
	add_notetrack_custom_function( "player_hands", "twist1", ::maps/afghanistan_wave_1::crater_charge_fx2 );
	add_notetrack_custom_function( "player_hands", "twist2", ::maps/afghanistan_wave_1::crater_charge_fx3 );
	add_notetrack_custom_function( "player_hands", "twist3", ::maps/afghanistan_wave_1::crater_charge_fx4 );
	add_notetrack_custom_function( "player_hands", "finalpush", ::maps/afghanistan_wave_1::crater_charge_fx5 );
}

plant_explosive_dome_stairs_scene()
{
	add_scene( "plant_explosive_dome_stairs", "explosion_struct" );
	add_player_anim( "player_hands", %int_afghan_cratercharge_plant_from_stairs, 1 );
	add_prop_anim( "crater_charge", %o_afghan_cratercharge_plant_from_stairs );
	add_notetrack_custom_function( "player_hands", "plant", ::maps/afghanistan_wave_1::crater_charge_fx1 );
	add_notetrack_custom_function( "player_hands", "twist1", ::maps/afghanistan_wave_1::crater_charge_fx2 );
	add_notetrack_custom_function( "player_hands", "twist2", ::maps/afghanistan_wave_1::crater_charge_fx3 );
	add_notetrack_custom_function( "player_hands", "twist3", ::maps/afghanistan_wave_1::crater_charge_fx4 );
	add_notetrack_custom_function( "player_hands", "finalpush", ::maps/afghanistan_wave_1::crater_charge_fx5 );
}

e2_s1_base_activity()
{
	add_scene( "e2_tower_lookout_startidl", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_lookout_1", %ch_af_02_01_tower_lookout_1_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_lookout_2", %ch_af_02_01_tower_lookout_2_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_tower_lookout_follow", "rats_nest_struct" );
	add_actor_model_anim( "muj_lookout_1", %ch_af_02_01_tower_lookout_1_follow, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_lookout_2", %ch_af_02_01_tower_lookout_2_follow, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_tower_lookout_endidl", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_lookout_1", %ch_af_02_01_tower_lookout_1_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_lookout_2", %ch_af_02_01_tower_lookout_2_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_window_startidl", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_window", %ch_af_02_01_window_lookout_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_window_follow", "rats_nest_struct" );
	add_actor_model_anim( "muj_window", %ch_af_02_01_window_lookout_follow, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_drum_burner", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_drum_burner", %ch_af_02_01_fire_drum_burner, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_stacker_carry_1", "rats_nest_struct" );
	add_actor_anim( "muj_stacker_1", %ch_af_02_01_gun_stackers_muj1_carry, 0, 0, 0, 1 );
	add_prop_anim( "muj_stacker_gun1", %o_af_02_01_gun_stackers_ak1_carry, "t6_wpn_ar_ak47_prop" );
	add_notetrack_level_notify( "muj_stacker_1", "start_muj2_mainanim", "stacker_2_carry" );
	add_scene( "e2_stacker_carry_2", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_stacker_2", %ch_af_02_01_gun_stackers_muj2_carry, 0, 0, 0, 1 );
	add_prop_anim( "muj_stacker_gun2", %o_af_02_01_gun_stackers_ak2_carry, "t6_wpn_ar_ak47_prop" );
	add_scene( "e2_stacker_3", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_stacker_3", %ch_af_02_01_gun_stackers_muj3, 0, 0, 1, 1 );
	add_prop_anim( "muj_stacker_gun3", %o_af_02_01_gun_stackers_ak3, "t6_wpn_ar_ak47_prop" );
	add_scene( "e2_stacker_main_2", "rats_nest_struct" );
	add_actor_anim( "muj_stacker_2", %ch_af_02_01_gun_stackers_muj2_main, 0, 0, 0, 1 );
	add_scene( "e2_stacker_endidl", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_stacker_1", %ch_af_02_01_gun_stackers_muj1_endidl, 0, 0, 1, 1 );
	add_actor_anim( "muj_stacker_2", %ch_af_02_01_gun_stackers_muj2_endidl, 0, 0, 1, 1 );
	add_prop_anim( "muj_stacker_gun1", %o_af_02_01_gun_stackers_ak1_endidl, "t6_wpn_ar_ak47_prop" );
	add_prop_anim( "muj_stacker_gun2", %o_af_02_01_gun_stackers_ak2_endidl, "t6_wpn_ar_ak47_prop" );
	add_scene( "e2_generator", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_generator", %ch_af_02_01_generatorguy, 1, 0, 0, 1 );
	add_scene( "e2_walltop_start", "base_wall_struct_2", 0, 0, 1 );
	add_actor_model_anim( "muj_walltop1", %ch_af_02_01_walltop1_muj1_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop2", %ch_af_02_01_walltop1_muj2_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop3", %ch_af_02_01_walltop2_muj1_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop4", %ch_af_02_01_walltop2_muj2_startidl, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_walltop_lookout", "base_wall_struct_2" );
	add_actor_model_anim( "muj_walltop1", %ch_af_02_01_walltop1_muj1_lookout, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop2", %ch_af_02_01_walltop1_muj2_lookout, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop3", %ch_af_02_01_walltop2_muj1_lookout, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop4", %ch_af_02_01_walltop2_muj2_lookout, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_walltop_end", "base_wall_struct_2", 0, 0, 1 );
	add_actor_model_anim( "muj_walltop1", %ch_af_02_01_walltop1_muj1_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop2", %ch_af_02_01_walltop1_muj2_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop3", %ch_af_02_01_walltop2_muj1_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_walltop4", %ch_af_02_01_walltop2_muj2_endidl, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_runout_startidl_1", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_1", %ch_af_02_01_runout_muj1_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_startidl_2", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_2", %ch_af_02_01_runout_muj2_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_startidl_3", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_3", %ch_af_02_01_runout_muj3_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_startidl_4", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_4", %ch_af_02_01_runout_muj4_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_startidl_5", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_5", %ch_af_02_01_runout_muj5_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_startidl_6", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_runout_6", %ch_af_02_01_runout_muj6_startidl, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_1", "rats_nest_struct" );
	add_actor_anim( "muj_runout_1", %ch_af_02_01_runout_muj1_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_2", "rats_nest_struct" );
	add_actor_anim( "muj_runout_2", %ch_af_02_01_runout_muj2_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_3", "rats_nest_struct" );
	add_actor_anim( "muj_runout_3", %ch_af_02_01_runout_muj3_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_4", "rats_nest_struct" );
	add_actor_anim( "muj_runout_4", %ch_af_02_01_runout_muj4_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_5", "rats_nest_struct" );
	add_actor_anim( "muj_runout_5", %ch_af_02_01_runout_muj5_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_runout_run_6", "rats_nest_struct" );
	add_actor_anim( "muj_runout_6", %ch_af_02_01_runout_muj6_run, undefined, undefined, undefined, 1 );
	add_scene( "e2_tank_guy", "rats_nest_struct" );
	add_actor_anim( "muj_tank_guy", %ch_af_02_01_tankguy_gesture, undefined, undefined, undefined, 1 );
	add_scene( "e2_rooftop_guys", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_rooftop1", %ch_af_02_01_rooftops_muj1, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_rooftop2", %ch_af_02_01_rooftops_muj2, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_rooftop3", %ch_af_02_01_rooftops_muj3, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_rooftop4", %ch_af_02_01_rooftops_muj4, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_rooftop6", %ch_af_02_01_rooftops_muj6, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
}

e2_s1_ride_scenes()
{
	add_scene( "e2_tank_ride_idle_start", "dead_tank_riverbed", 0, 0, 1 );
	add_actor_model_anim( "muj_tank_ride1", %ch_af_02_01_tank_ruin_muj1_startidl, undefined, 0, undefined, undefined, "muj_assault" );
	add_actor_model_anim( "muj_tank_ride2", %ch_af_02_01_tank_ruin_muj2_startidl, undefined, 0, undefined, undefined, "muj_assault" );
	add_scene( "e2_tank_ride_idle", "dead_tank_riverbed" );
	add_actor_model_anim( "muj_tank_ride1", %ch_af_02_01_tank_ruin_muj1_tracking, undefined, 0, undefined, undefined, "muj_assault" );
	add_actor_model_anim( "muj_tank_ride2", %ch_af_02_01_tank_ruin_muj2_tracking, undefined, 0, undefined, undefined, "muj_assault" );
	add_scene( "e2_tank_ride_idle_end", "dead_tank_riverbed", 0, 0, 1 );
	add_actor_model_anim( "muj_tank_ride1", %ch_af_02_01_tank_ruin_muj1_endidl, undefined, 1, undefined, undefined, "muj_assault" );
	add_actor_model_anim( "muj_tank_ride2", %ch_af_02_01_tank_ruin_muj2_endidl, undefined, 1, undefined, undefined, "muj_assault" );
}

e2_s1_base_props()
{
	add_scene( "e2_cooking_muj", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_cooking_1", %ch_af_02_01_cooking_muj1, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_cooking_2", %ch_af_02_01_cooking_muj2, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_cooking_3", %ch_af_02_01_cooking_muj3, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_prop_anim( "muj_cooking_pipe", %o_af_02_01_cooking_muj_pipe, "p6_anim_smoking_pipe" );
	add_scene( "e2_smokers", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_smoker_1", %ch_af_02_01_smoker1, undefined, 1, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "muj_smoker_2", %ch_af_02_01_smoker2, undefined, 1, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "muj_smoker_pipe", %o_af_02_01_smoker_hookah, "com_hookah_pipe_anim" );
	add_scene( "e2_stinger_move", "rats_nest_struct" );
	add_actor_anim( "muj_stingers_1", %ch_af_02_01_stingers_muj1_move, 0, 0, 0, 1 );
	add_actor_anim( "muj_stingers_2", %ch_af_02_01_stingers_muj2_move, 0, 0, 0, 1 );
	add_prop_anim( "muj_stingers_crate", %o_af_02_01_stingers_crate_move, "jun_ammo_crate_anim" );
	add_prop_anim( "muj_stingers_barrow", %ch_af_02_01_stingers_cart_move, "p6_street_vendor_wheel_barrow_anim" );
	add_scene( "e2_stinger_endidl", "rats_nest_struct", 0, 0, 1 );
	add_actor_anim( "muj_stingers_1", %ch_af_02_01_stingers_muj1_endidl, 0, 0, 1, 1 );
	add_actor_anim( "muj_stingers_2", %ch_af_02_01_stingers_muj2_endidl, 0, 0, 1, 1 );
	add_prop_anim( "muj_stingers_crate", %o_af_02_01_stingers_crate_endidl, "jun_ammo_crate_anim" );
	add_prop_anim( "muj_stingers_barrow", %ch_af_02_01_stingers_cart_endidl, "p6_street_vendor_wheel_barrow_anim" );
	add_scene( "e2_gunsmith", "rats_nest_struct", 0, 0, 1 );
	add_actor_model_anim( "muj_hammer", %ch_af_02_01_gunsmith_hammerguy, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "muj_grinder", %ch_af_02_01_gunsmith_polishguy_no_grinder, undefined, 1, undefined, undefined, "celebrating_muj_sec3_1" );
	add_scene( "e2_ammo", "rats_nest_struct" );
	add_actor_anim( "muj_ammo", %ch_af_02_01_ammoguy, 1, 0, 0, 1 );
	add_prop_anim( "muj_ammo1", %ch_af_02_01_ammoguy_ammo1, "mil_ammo_case_anim_1" );
	add_prop_anim( "muj_ammo2", %ch_af_02_01_ammoguy_ammo2, "mil_ammo_case_anim_1" );
	add_prop_anim( "muj_ammo3", %ch_af_02_01_ammoguy_ammo3, "mil_ammo_case_anim_1" );
	add_scene( "e2_ammo02", "rats_nest_struct" );
	add_actor_anim( "muj_ammo", %ch_af_02_01_ammoguy02, 1, 0, 0, 1 );
	add_scene( "e2_ammo03", "rats_nest_struct" );
	add_actor_anim( "muj_ammo", %ch_af_02_01_ammoguy03, 1, 0, 0, 1 );
	add_scene( "e2_ammo04", "rats_nest_struct" );
	add_actor_anim( "muj_ammo", %ch_af_02_01_ammoguy04, 1, 0, 0, 1 );
}

e4_s1_return_base_lineup_scene()
{
	add_scene( "e4_s1_return_base_lineup", "skipto_horse_charge" );
	add_player_anim( "player_body", %p_af_04_01_return_base_player_lineup, 0, 0, undefined, 1, 1, 30, 10, 30, 5 );
	add_horse_anim( "mason_horse", %ch_af_04_01_return_base_player_horse_lineup );
	set_vehicle_unusable_in_scene( "mason_horse" );
	add_horse_anim( "zhao_horse", %ch_af_04_01_return_base_zhao_horse_lineup );
	set_vehicle_unusable_in_scene( "zhao_horse" );
	add_horse_anim( "woods_horse", %ch_af_04_01_return_base_woods_horse_lineup );
	set_vehicle_unusable_in_scene( "woods_horse" );
	add_actor_anim( "woods", %ch_af_04_01_return_base_woods_lineup, 0, 1, 0, 1 );
	add_actor_anim( "zhao", %ch_af_04_01_return_base_zhao_lineup, 0, 1, 0, 1 );
}

e4_s1_binoc_scene()
{
	add_scene( "e4_s1_binoc", "arena_struct" );
	add_vehicle_anim( "krav_tank", %v_af_04_03_through_binoculars_tank );
	add_player_anim( "player_body", %p_af_04_03_through_binoculars_player, 0, 0, undefined, 1, 1, 30, 30, 30, 5 );
	add_actor_anim( "battle_muj1", %ch_af_04_03_through_binoculars_helper, 0, 0, 1, 1 );
	add_actor_anim( "battle_muj2", %ch_af_04_03_through_binoculars_wounded, 0, 0, 1, 1 );
	add_notetrack_fx_on_tag( "battle_muj1", "impact", "sand_body_impact_sm", "tag_origin" );
	add_notetrack_custom_function( "krav_tank", "shoot_machinegun", ::krav_tank_machinegun );
	add_notetrack_custom_function( "krav_tank", "shoot_canon", ::krav_tank_cannon );
	add_scene( "e4_s1_player_speech", "skipto_horse_charge" );
	add_player_anim( "player_body", %p_af_04_01_return_base_player_speech, 1, 0, undefined, 1, 1, 30, 30, 30, 5 );
	add_horse_anim( "mason_horse", %ch_af_04_01_return_base_player_horse_speech );
	set_vehicle_unusable_in_scene( "mason_horse" );
	add_notetrack_custom_function( "player_body", "sndCheer", ::sndcheers );
}

krav_tank_machinegun( krav_tank )
{
	ai_muj = get_ais_from_scene( "e4_s1_binoc", "battle_muj2" );
	i = 0;
	while ( i < 20 )
	{
		magicbullet( "btr60_heavy_machinegun", krav_tank gettagorigin( "tag_flash_gunner1" ), ai_muj.origin + ( randomintrange( -100, 100 ), 0, 0 ) );
		if ( i == 5 )
		{
			playfxontag( level._effect[ "sniper_impact" ], ai_muj, "J_Head" );
		}
		wait 0,05;
		i++;
	}
}

krav_tank_cannon( krav_tank )
{
	ai_muj = get_ais_from_scene( "e4_s1_binoc", "battle_muj1" );
	playfx( level._effect[ "explode_grenade_sand" ], ai_muj.origin );
}

e4_s5_player_and_horse_fall()
{
	add_scene( "e4_s5_player_horse_fall", "arena_struct" );
	add_player_anim( "player_body", %p_af_04_05_thrown_player_fall );
	add_prop_anim( "prop_horse", %ch_af_04_05_thown_horse_fall );
	add_notetrack_fx_on_tag( "player_body", "horse_lands_on_player", "sand_body_impact_sm", "J_SpineLower" );
	add_scene( "e4_s5_player_horse_pushloop", "arena_struct", 0, 0, 1 );
	add_player_anim( "player_body", %p_af_04_05_thrown_player_pushloop );
	add_prop_anim( "prop_horse", %ch_af_04_05_thown_horse_pushloop );
	add_scene( "e4_s5_player_horse_push_success", "arena_struct" );
	add_player_anim( "player_body", %p_af_04_05_thrown_player_push_success );
	add_prop_anim( "prop_horse", %ch_af_04_05_thrown_horse_success );
	level.scr_anim[ "player_body" ][ "e4_s5_player_horse_push_loop" ] = %p_af_04_05_thrown_player_pushloop;
	level.scr_anim[ "prop_horse" ][ "e4_s5_horse_horse_push_loop" ] = %ch_af_04_05_thown_horse_pushloop;
	level.scr_anim[ "player_body" ][ "e4_s5_player_horse_push" ] = %p_af_04_05_thrown_player_push;
	level.scr_anim[ "prop_horse" ][ "e4_s5_horse_horse_push" ] = %ch_af_04_05_thrown_horse_push;
}

e4_s5_tank_fall()
{
	add_scene( "e4_s5_tank_path_horsepush", "arena_struct" );
	add_vehicle_anim( "krav_tank", %v_af_04_06_reunion_tank_horsepush );
	add_scene( "e4_s5_tank_path_runtowoods", "arena_struct" );
	add_vehicle_anim( "krav_tank", %v_af_04_06_reunion_tank_runtowoods );
	add_scene( "e4_s5_tank_path_tankbattle", "arena_struct" );
	add_vehicle_anim( "krav_tank", %v_af_04_06_reunion_tank_tankbattle );
}

e4_s6_player_grabs_on_tank_scene()
{
	add_scene( "e4_s6_player_grabs_on_tank", "arena_struct" );
	add_player_anim( "player_body", %p_af_04_06_reunion_player_run2tank );
	add_notetrack_flag( "player_body", "runtowoods", "start_runtowoods_tank" );
	add_notetrack_flag( "player_body", "tankbattle", "start_tankbattle_tank" );
	add_actor_anim( "woods", %ch_af_04_06_reunion_woods_run2tank );
	add_horse_anim( "woods_horse", %ch_af_04_06_reunion_horse_woods_run2tank );
	add_notetrack_flag( "player_body", "start_shake", "start_kravchenko_tank_earthquake" );
}

e4_s6_tank_fight_scene()
{
	add_scene( "e4_s6_tank_fight", "krav_tank" );
	add_player_anim( "player_body", %p_af_04_06_reunion_player_tankfight, 1, 0, "origin_animate_jnt", 1, 1, 10, 10, 10, 10 );
	add_prop_anim( "mortar", %o_af_04_06_reunion_mortar_tankfight, "t6_wpn_mortar_shell_prop_view", 1, 0, undefined, "origin_animate_jnt" );
	add_actor_anim( "kravchenko", %ch_af_04_06_reunion_krav_tankfight, 1, 0, 0, 1, "origin_animate_jnt" );
	add_actor_anim( "woods", %ch_af_04_06_reunion_woods_tankfight, 0, 0, 0, 1, "origin_animate_jnt" );
	add_horse_anim( "woods_horse", %ch_af_04_06_reunion_horse_woods_tankfight, 0, undefined, "origin_animate_jnt" );
	add_actor_anim( "soviet_guard", %ch_af_04_06_reunion_guard_tankfight, 0, 0, 1, 1, "origin_animate_jnt" );
	add_notetrack_custom_function( "player_body", "DOF_tank_on", ::maps/createart/afghanistan_art::dof_tank_on );
	add_notetrack_custom_function( "player_body", "DOF_tank_off", ::maps/createart/afghanistan_art::dof_tank_off );
	add_notetrack_custom_function( "player_body", "numbers", ::maps/afghanistan_horse_charge::handle_numbers );
	add_notetrack_custom_function( "player_body", "tank_explosion", ::maps/afghanistan_horse_charge::handle_tank_explosion );
	add_notetrack_custom_function( "player_body", "audioCutSound", ::maps/afghanistan_horse_charge::audiocutsound );
	add_notetrack_custom_function( "player_body", "punched", ::kravchenko_punches_face );
	add_notetrack_fx_on_tag( "soviet_guard", "soldier_shot", "head_shot_woods", "J_Head" );
}

kravchenko_punches_face( e_guy )
{
	level.player disableinvulnerability();
	earthquake( 0,15, 0,6, level.player.origin, 128 );
	level.player dodamage( 30, level.player.origin );
	level.player enableinvulnerability();
}

e4_s6_strangle_scene()
{
	add_scene( "e4_s6_strangle", "arena_struct" );
	add_player_anim( "player_body", %p_af_04_09_reunion_player_strangle, 1, 0, undefined, 1, 1, 10, 10, 10, 10 );
	add_actor_anim( "kravchenko", %ch_af_04_09_reunion_krav_strangle, 1 );
	add_actor_anim( "woods", %ch_af_04_09_reunion_woods_strangle );
	add_horse_anim( "woods_horse", %ch_af_04_09_reunion_horse_strangle );
	add_vehicle_anim( "krav_tank", %v_af_04_09_reunion_tank_strangle, 1 );
	add_notetrack_custom_function( "player_body", "DOF_strangle", ::maps/createart/afghanistan_art::dof_strangle );
	add_notetrack_custom_function( "player_body", "strong_number_attack1", ::strangle_number_attack_number_1 );
	add_notetrack_custom_function( "player_body", "strong_number_attack2", ::strangle_number_attack_number_2 );
	add_notetrack_flag( "player_body", "fade_out", "strangle_fade_out", 0 );
}

strangle_number_attack_number_1( guy )
{
	guy setviewmodelrenderflag( 1 );
	tag_origin = guy gettagorigin( "tag_camera" );
	tag_angles = guy gettagangles( "tag_camera" );
	level.player play_fx( "numbers_close", tag_origin, tag_angles );
}

strangle_number_attack_number_2( guy )
{
	tag_origin = guy gettagorigin( "tag_camera" );
	tag_angles = guy gettagangles( "tag_camera" );
	level.player play_fx( "numbers_close", tag_origin, tag_angles );
	flag_set( "strangle_fade_out" );
	level.player thread screen_fade_to_alpha_with_blur( 1, 3,5, 4 );
	wait 1,5;
	level.player thread say_dialog( "dragovich_kravche_001" );
	wait 2;
	level notify( "end_strangle_scene" );
}

e5_s1_celebration_scene()
{
}

e5_s1_celebration_riders_scene()
{
}

e5_s1_walk_in_scene()
{
}

e5_s2_interrogation()
{
	add_scene( "e5_s2_interrogation_start", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_start_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_start_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_start_krav, 1, 0 );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_start_omar, 1, 0 );
	add_notetrack_fx_on_tag( "kravchenko", "punched", "head_punch", "J_Mouth_LE" );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_start_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_start_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_start_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_start_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_start_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_start_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_start_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_start_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "woods_knife", "flick", "knife_tip", "tag_origin" );
	add_notetrack_custom_function( "woods_knife", "flick", ::swap_to_cut_model_head );
	add_notetrack_custom_function( "woods_knife", "flick", ::adjust_fov_for_mature );
	add_scene( "e5_s2_interrogation_threat", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_threat_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_threat_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_threat_krav, 1, 0 );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_threat_omar, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_threat_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_threat_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_threat_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_threat_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_threat_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_threat_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_threat_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_threat_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "kravchenko", "spit", "krav_spit", "J_Mouth_LE" );
	add_notetrack_fx_on_tag( "kravchenko", "stab", "hand_stab", "J_Ring_RI_2" );
	add_notetrack_fx_on_tag( "kravchenko", "stab_done", "hand_stab", "J_Ring_RI_2" );
	add_notetrack_custom_function( "kravchenko", "stab", ::change_music );
	add_notetrack_custom_function( "kravchenko", "stab", ::swap_to_cut_model_hand );
	add_notetrack_custom_function( "kravchenko", "play_vox#i_sell_him_weapons_011", ::play_vox_on_fake_head, 0, 1 );
	add_scene( "e5_s2_interrogation_first_intel", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_first_intel_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_first_intel_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_first_intel_krav, 1, 0 );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_first_intel_omar, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_first_intel_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_first_intel_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_first_intel_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_first_intel_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_first_intel_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_first_intel_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_first_intel_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_first_intel_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_custom_function( "kravchenko", "play_vox#the_soviet_union_i_013", ::play_vox_on_fake_head, 0, 1 );
	add_scene( "e5_s2_interrogation_second_intel", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_second_intel_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_second_intel_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_second_intel_krav, 1, 0 );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_second_intel_omar, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_second_intel_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_second_intel_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_second_intel_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_second_intel_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_second_intel_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_second_intel_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_second_intel_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_second_intel_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_custom_function( "kravchenko", "play_vox#he_wants_your_worl_018", ::play_vox_on_fake_head, 0, 1 );
	add_notetrack_custom_function( "kravchenko", "play_vox#how_can_you_be_sur_020", ::play_vox_on_fake_head, 0, 1 );
	add_scene( "e5_s2_interrogation_third_intel", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_third_intel_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_third_intel_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_third_intel_krav );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_third_intel_omar, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_third_intel_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_third_intel_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_third_intel_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_third_intel_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_third_intel_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_third_intel_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_third_intel_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_third_intel_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_custom_function( "kravchenko", "play_vox#he_has_people_in_t_021", ::play_vox_on_fake_head, 0, 1 );
	add_scene( "e5_s2_interrogation_succeed", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_succeed_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_succeed_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_succeed_krav, 1, 0 );
	add_actor_anim( "rebel_leader", %ch_af_05_02_interrog_succeed_omar, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_succeed_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_succeed_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_succeed_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_succeed_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_gun", %o_af_05_02_interrog_succeed_woods_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_succeed_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_succeed_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_succeed_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_succeed_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "woods_gun", "shoot", "pistol_flash", "tag_fx" );
	add_notetrack_fx_on_tag( "kravchenko", "headshot", "head_shot_woods", "J_Head" );
	add_notetrack_custom_function( "kravchenko", "headshot", ::play_final_numbers );
	add_scene( "e5_s2_interrogation_fail", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_fail_krav, 1, 0 );
	add_scene( "e5_s2_interrogation_start_player", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_start_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_start_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_notetrack_custom_function( "player_body", "dof_chair", ::maps/createart/afghanistan_art::dof_omar );
	add_scene( "e5_s2_interrogation_threat_player", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_threat_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_threat_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_notetrack_custom_function( "player_body", "cock", ::look_down_numbers );
	add_scene( "e5_s2_interrogation_threat_player_edit", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_threat_player, 0, 0, undefined, 0, 1, 10, 10, 10, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_threat_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_scene( "e5_s2_interrogation_test1", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test1_player );
	add_prop_anim( "gun", %o_af_05_02_interrog_test1_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_notetrack_custom_function( "player_body", "decision", ::maps/afghanistan_krav_captured::end_hands_animator );
	add_scene( "e5_s2_interrogation_test1_succeed", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test1_player_succeed, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_test1_pistol_succeed, "t6_wpn_pistol_m1911_prop_view" );
	add_scene( "e5_s2_interrogation_test2", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test2_player );
	add_prop_anim( "gun", %o_af_05_02_interrog_test2_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_notetrack_custom_function( "player_body", "decision", ::maps/afghanistan_krav_captured::end_hands_animator );
	add_scene( "e5_s2_interrogation_test2_succeed", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test2_player_succeed, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_test2_pistol_succeed, "t6_wpn_pistol_m1911_prop_view" );
	add_scene( "e5_s2_interrogation_test3", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test3_player );
	add_prop_anim( "gun", %o_af_05_02_interrog_test3_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_notetrack_custom_function( "player_body", "decision", ::maps/afghanistan_krav_captured::end_hands_animator );
	add_scene( "e5_s2_interrogation_test3_succeed", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test3_player_succeed, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_prop_anim( "gun", %o_af_05_02_interrog_test3_pistol_succeed, "t6_wpn_pistol_m1911_prop_view" );
	add_scene( "e5_s2_interrogation_all_succeed", "by_numbers_struct_mason" );
	add_player_anim( "player_body", %p_af_05_02_interrog_all_tests_succeed_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_notetrack_custom_function( "player_body", "dof_pair", ::maps/createart/afghanistan_art::dof_omar );
	add_notetrack_custom_function( "player_body", "dof_ambush", ::maps/createart/afghanistan_art::dof_omar );
	add_prop_anim( "gun", %o_af_05_02_interrog_all_tests_succeed_pistol, "t6_wpn_pistol_m1911_prop_view" );
	add_scene( "e5_s2_interrogation_test1_fail", "by_numbers_struct" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test1_fail_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test1_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test1_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test1_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test1_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test1_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test1_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test1_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_test1_fail_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test1_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test1_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test1_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "gun", "shoot", "pistol_flash", "tag_fx" );
	add_notetrack_fx_on_tag( "kravchenko", "headshot", "head_shot", "J_Head" );
	add_notetrack_custom_function( "kravchenko", "headshot", ::play_final_numbers );
	add_scene( "e5_s2_interrogation_test1_fail_no_player", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test1_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test1_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test1_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test1_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test1_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test1_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test1_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "woods_knife", %o_af_05_02_interrog_test1_fail_woods_karambit, "p6_knife_karambit" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test1_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test1_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test1_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_scene( "e5_s2_interrogation_test2_fail", "by_numbers_struct" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test2_fail_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test2_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test2_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test2_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test2_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test2_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test2_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test2_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test2_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test2_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test2_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "gun", "shoot", "pistol_flash", "tag_fx" );
	add_notetrack_fx_on_tag( "kravchenko", "headshot", "head_shot", "J_Head" );
	add_notetrack_custom_function( "kravchenko", "headshot", ::play_final_numbers );
	add_scene( "e5_s2_interrogation_test2_fail_no_player", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test2_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test2_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test2_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test2_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test2_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test2_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test2_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test2_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test2_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test2_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_scene( "e5_s2_interrogation_test3_fail", "by_numbers_struct" );
	add_player_anim( "player_body", %p_af_05_02_interrog_test3_fail_player, 0, 0, undefined, 1, 1, 20, 20, 20, 10 );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test3_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test3_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test3_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test3_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test3_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test3_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test3_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test3_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test3_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test3_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
	add_notetrack_fx_on_tag( "gun", "shoot", "pistol_flash", "tag_fx" );
	add_notetrack_fx_on_tag( "kravchenko", "headshot", "head_shot", "J_Head" );
	add_notetrack_custom_function( "kravchenko", "headshot", ::play_final_numbers );
	add_scene( "e5_s2_interrogation_test3_fail_no_player", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_02_interrog_test3_fail_woods, 1, 0 );
	add_actor_anim( "hudson", %ch_af_05_02_interrog_test3_fail_hudson );
	add_actor_anim( "kravchenko", %ch_af_05_02_interrog_test3_fail_krav, 1, 0 );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_02_interrog_test3_fail_guard1, undefined, 0, undefined, undefined, "spawner_unique_muj_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_02_interrog_test3_fail_guard2, undefined, 0, undefined, undefined, "spawner_unique_muj_3" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_02_interrog_test3_fail_muj2, undefined, 0, undefined, undefined, "spawner_unique_muj_wrap" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_02_interrog_test3_fail_muj3, undefined, 0, undefined, undefined, "spawner_unique_muj_2" );
	add_prop_anim( "chair", %o_af_05_02_interrog_test3_fail_chair, "p6_wooden_chair_anim" );
	add_prop_anim( "krav_rope_l", %o_af_05_02_interrog_test3_fail_wristrope_l, "p6_anim_afghan_interrogation_rope" );
	add_prop_anim( "krav_rope_r", %o_af_05_02_interrog_test3_fail_wristrope_r, "p6_anim_afghan_interrogation_rope" );
}

look_down_numbers( guy )
{
	level.player play_fx( "numbers_strong", level.player.origin + vectorScale( ( 0, 0, 1 ), 60 ), vectorScale( ( 0, 0, 1 ), 90 ), "stop_down_numbers" );
	wait 2;
	level.player notify( "stop_down_numbers" );
}

play_vox_on_fake_head( guy, notetrack )
{
	if ( !isDefined( level.krav_vo_lines ) )
	{
		level.krav_vo_lines = [];
		level.krav_vo_lines[ "play_vox#i_sell_him_weapons_011" ] = "i_sell_him_weapons_011";
		level.krav_vo_lines[ "play_vox#the_soviet_union_i_013" ] = "the_soviet_union_i_013";
		level.krav_vo_lines[ "play_vox#he_wants_your_worl_018" ] = "he_wants_your_worl_018";
		level.krav_vo_lines[ "play_vox#how_can_you_be_sur_020" ] = "how_can_you_be_sur_020";
		level.krav_vo_lines[ "play_vox#he_has_people_in_t_021" ] = "he_has_people_in_t_021";
	}
	level.krav_fake_head = spawn( "script_model", guy gettagorigin( "J_Head" ) );
	level.krav_fake_head setmodel( "tag_origin" );
	level.krav_fake_head say_dialog( level.krav_vo_lines[ notetrack ], undefined, 1 );
	if ( isDefined( level.krav_fake_head ) )
	{
		level.krav_fake_head delete();
	}
}

play_final_numbers( guy )
{
	if ( isDefined( level.krav_fake_head ) )
	{
		level.krav_fake_head stopsounds();
	}
	if ( isDefined( level.brainwash_model ) )
	{
		level.brainwash_model play_fx( "player_muzzle_flash", undefined, undefined, undefined, 1, "tag_fx" );
	}
	level.player notify( "stop_numbers" );
	level notify( "stop_numbers" );
	level.player play_fx( "numbers_final", level.player.origin, level.player.angles );
}

swap_to_cut_model_head( guy )
{
	if ( is_mature() )
	{
		e_krav = getent( "kravchenko_ai", "targetname" );
		e_krav detach( "c_rus_afghan_kravchenko_head" );
		e_krav attach( "c_rus_afghan_kravchenko_head_cut" );
	}
}

adjust_fov_for_mature( guy )
{
	if ( !is_mature() )
	{
		level.player thread lerp_fov_overtime( 6, 36, 1 );
	}
}

swap_to_cut_model_hand( guy )
{
	if ( is_mature() )
	{
		e_krav = getent( "kravchenko_ai", "targetname" );
		e_krav detach( "c_rus_afghan_kravchenko_rarm" );
		e_krav attach( "c_rus_afghan_kravchenko_rarm_cut" );
	}
}

change_music( guy )
{
	setmusicstate( "AFGHAN_KNIFE_PLUNGE" );
	body = getent( "player_body", "targetname" );
	tag_origin = body gettagorigin( "tag_camera" );
	tag_angles = body gettagangles( "tag_camera" );
	level.player play_fx( "numbers_base", tag_origin, tag_angles, "stop_numbers" );
}

e5_s4_beatdown_scene()
{
	add_scene( "e5_s4_beatdown", "by_numbers_struct" );
	add_actor_anim( "woods", %ch_af_05_04_betrayal_woods );
	add_actor_anim( "hudson", %ch_af_05_04_betrayal_hudson );
	add_actor_model_anim( "beatdown_guard1", %ch_af_05_04_betrayal_muj1, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "beatdown_guard2", %ch_af_05_04_betrayal_muj2, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "beatdown_guard3", %ch_af_05_04_betrayal_muj3, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "beatdown_guard4", %ch_af_05_04_betrayal_muj4, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "beatdown_stomper", %ch_af_05_04_betrayal_new_stomper, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_anim( "rebel_leader", %ch_af_05_04_betrayal_omar );
	add_actor_model_anim( "interrogation_guard1", %ch_af_05_04_betrayal_guard1, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_actor_model_anim( "interrogation_guard2", %ch_af_05_04_betrayal_guard2, undefined, 0, undefined, undefined, "celebrating_muj_sec3_1" );
	add_prop_anim( "player_rope", %o_af_05_04_betrayal_rope_player, "p6_anim_afghan_rope" );
	add_prop_anim( "woods_rope", %o_af_05_04_betrayal_rope_woods, "p6_anim_afghan_rope" );
	add_prop_anim( "woods_knife", %o_af_05_04_betrayal_woods_karambit, "p6_knife_karambit" );
	add_player_anim( "player_body", %p_af_05_04_betrayal_player, undefined, 0, undefined, 1, 1, 10, 10, 20, 10 );
	add_notetrack_fx_on_tag( "player_body", "spit", "choke_spit", "tag_camera" );
	add_notetrack_fx_on_tag( "player_body", "hit_ground", "sand_body_impact_sm", "tag_origin" );
	add_notetrack_custom_function( "player_body", "kicked_1", ::player_beat_down );
	add_notetrack_custom_function( "player_body", "kicked_2", ::player_beat_down );
	add_notetrack_custom_function( "player_body", "kicked_3", ::player_beat_down );
	add_notetrack_custom_function( "player_body", "kicked_4", ::player_beat_down );
	add_notetrack_custom_function( "player_body", "kicked_5", ::player_beat_down );
	add_notetrack_custom_function( "player_body", "dof_omar", ::maps/createart/afghanistan_art::dof_omar );
	add_notetrack_custom_function( "player_body", "dof_ambush", ::maps/createart/afghanistan_art::dof_omar );
	add_notetrack_custom_function( "player_body", "dof_kicking", ::maps/createart/afghanistan_art::dof_beatdown );
	add_notetrack_custom_function( "player_body", "spit", ::maps/afghanistan_krav_captured::choke_spit_fx );
}

player_beat_down( e_player_rig )
{
	level.player disableinvulnerability();
	earthquake( 0,25, 0,6, level.player.origin, 512 );
	level.player dodamage( 15, level.player.origin );
	level.player playrumbleonentity( "damage_heavy" );
	level.player enableinvulnerability();
}

e6_s2_ontruck_1_scene()
{
	add_scene( "e6_s2_ontruck_1", "deserted_pickup1" );
	add_actor_anim( "rebel_leader", %ch_af_06_01_deserted_leader_ontruck, 1, 0, 0, 1, "tag_origin" );
	add_actor_anim( "woods_beatup", %ch_af_06_01_deserted_woods_ontruck, 1, 0, 0, 1, "tag_origin" );
	add_actor_anim( "hudson_beatup", %ch_af_06_01_deserted_hudson_ontruck, 1, 0, 0, 1, "tag_origin" );
	add_actor_anim( "zhao_beatup", %ch_af_06_01_deserted_zhao_ontruck, 1, 0, 0, 1, "tag_origin" );
	add_actor_anim( "m01_guard", %ch_af_06_01_deserted_muj1_ontruck, 0, 0, 0, 1, "tag_origin" );
	add_player_anim( "player_body", %p_af_06_01_deserted_player_ontruck, 1, 0, "tag_origin", 1, 1, 20, 20, 5, 5 );
}

e6_s2_ontruck_trucks_scene()
{
	add_scene( "e6_s2_ontruck_trucks", "truck_struct" );
	a_hide_tags = [];
	a_hide_tags[ 0 ] = "tag_gunner_barrel1";
	a_hide_tags[ 1 ] = "tag_gun_mount";
	a_hide_tags[ 2 ] = "tag_gunner_turret1";
	add_vehicle_anim( "deserted_pickup1", %v_af_06_01_deserted_maintruck_ontruck, 0, a_hide_tags, undefined, 1, "civ_pickup_wturret_afghan" );
}

e6_s2_offtruck_scene()
{
	add_scene( "e6_s2_offtruck", "truck_struct" );
	add_actor_anim( "woods_beatup", %ch_af_06_01_deserted_woods_offtruck );
	add_notetrack_custom_function( "woods_beatup", "hit_ground", ::maps/afghanistan_deserted::deserted_truck_kickout_impact );
	add_actor_anim( "hudson_beatup", %ch_af_06_01_deserted_hudson_offtruck );
	add_notetrack_custom_function( "hudson_beatup", "hit_ground", ::maps/afghanistan_deserted::deserted_truck_kickout_impact );
	add_actor_anim( "zhao_beatup", %ch_af_06_01_deserted_zhao_offtruck );
	add_notetrack_custom_function( "zhao_beatup", "hit_ground", ::maps/afghanistan_deserted::deserted_truck_kickout_impact );
	add_actor_anim( "rebel_leader", %ch_af_06_01_deserted_leader_offtruck );
	add_actor_anim( "m01_guard", %ch_af_06_01_deserted_muj1_offtruck );
	add_vehicle_anim( "deserted_pickup1", %v_af_06_01_deserted_maintruck_offtruck );
	add_notetrack_custom_function( "deserted_pickup1", "start_moving", ::maps/afghanistan_deserted::deserted_truck_kickup_dust );
	add_player_anim( "player_body", %p_af_06_01_deserted_player_offtruck );
	add_notetrack_custom_function( "player_body", "hit_ground", ::maps/afghanistan_deserted::deserted_truck_kickout_impact_player );
	add_notetrack_custom_function( "player_body", "player_flip_over", ::maps/afghanistan_deserted::deserted_flip_over );
	add_notetrack_custom_function( "player_body", "start_fade_out", ::maps/afghanistan_deserted::deserted_start_fade_out );
}

e6_s2_deserted_part1_scene()
{
	add_scene( "e6_s2_deserted_part1", "truck_struct" );
	add_actor_anim( "woods_beatup", %ch_af_06_02_deserted_woods_view01 );
	add_actor_anim( "hudson_beatup", %ch_af_06_02_deserted_hudson_view01 );
	add_actor_anim( "zhao_beatup", %ch_af_06_02_deserted_zhao_view01 );
	add_actor_model_anim( "reznov", %ch_af_06_02_deserted_reznov_view01 );
	add_actor_model_anim( "nomad", %ch_af_06_02_deserted_nomad_view01 );
	add_horse_anim( "reznov_horse", %ch_af_06_02_deserted_reznov_horse_view01 );
	add_horse_anim( "nomad_horse", %ch_af_06_02_deserted_nomad_horse_view01 );
	add_player_anim( "player_body", %p_af_06_02_deserted_player_view01, 0, 0, undefined, 1, 1, 20, 10, 5, 5 );
}

e6_s2_deserted_part2_scene()
{
	add_scene( "e6_s2_deserted_part2", "truck_struct" );
	add_actor_anim( "woods_beatup", %ch_af_06_02_deserted_woods_view02 );
	add_actor_anim( "hudson_beatup", %ch_af_06_02_deserted_hudson_view02 );
	add_actor_anim( "zhao_beatup", %ch_af_06_02_deserted_zhao_view01 );
	add_actor_model_anim( "reznov", %ch_af_06_02_deserted_reznov_view02 );
	add_actor_model_anim( "nomad", %ch_af_06_02_deserted_nomad_view02 );
	add_horse_anim( "reznov_horse", %ch_af_06_02_deserted_reznov_horse_view02 );
	add_horse_anim( "nomad_horse", %ch_af_06_02_deserted_nomad_horse_view02 );
	add_player_anim( "player_body", %p_af_06_02_deserted_player_view02, 0, 0, undefined, 1, 1, 20, 10, 5, 5 );
}

e6_s2_deserted_part3_scene()
{
	add_scene( "e6_s2_deserted_part3", "truck_struct" );
	add_actor_anim( "hudson_beatup", %ch_af_06_02_deserted_hudson_view03 );
	add_actor_model_anim( "reznov", %ch_af_06_02_deserted_reznov_view03 );
	add_actor_model_anim( "nomad", %ch_af_06_02_deserted_nomad_view03 );
	add_horse_anim( "reznov_horse", %ch_af_06_02_deserted_reznov_horse_view03 );
	add_horse_anim( "nomad_horse", %ch_af_06_02_deserted_nomad_horse_view03 );
	add_player_anim( "player_body", %p_af_06_02_deserted_player_view03, 0, 0, undefined, 1, 1, 20, 10, 5, 5 );
	add_notetrack_custom_function( "player_body", "dof_03", ::maps/createart/afghanistan_art::dof_03 );
	add_scene( "e6_s2_deserted_part3_extras", "truck_struct" );
	add_actor_anim( "zhao_beatup", %ch_af_06_02_deserted_zhao_view03 );
	add_actor_anim( "woods_beatup", %ch_af_06_02_deserted_woods_view03 );
}

e6_s2_deserted_bush_anim_scene()
{
	add_scene( "e6_s2_deserted_bush_normal", undefined, 0, 0, 1, 1 );
	add_prop_anim( "fxanim_shrub_01", %fxanim_afghan_shrubs_time_lapse_norm_anim );
	add_scene( "e6_s2_deserted_bush_ramp", undefined, 0, 0, 0, 1 );
	add_prop_anim( "fxanim_shrub_01", %fxanim_afghan_shrubs_time_lapse_ramp_anim );
	add_scene( "e6_s2_deserted_bush_fast", undefined, 0, 0, 1, 1 );
	add_prop_anim( "fxanim_shrub_01", %fxanim_afghan_shrubs_time_lapse_fast_anim );
}

setup_brainwash_anims()
{
	level.scr_animtree[ "player_hands_brainwash" ] = #animtree;
	level.scr_model[ "player_hands_brainwash" ] = level.player_interactive_model;
}

patroller_anims()
{
	level.scr_anim[ "generic" ][ "patrol_walk" ] = %patrol_bored_patrolwalk;
	level.scr_anim[ "zhao" ][ "patrol_walk" ] = %patrol_bored_patrolwalk;
	level.scr_anim[ "woods" ][ "patrol_walk" ] = %patrol_bored_patrolwalk;
}

sndcheers( guy )
{
	playsoundatposition( "evt_horsecharge_cheer_l", ( 11403, -9728, 255 ) );
	playsoundatposition( "evt_horsecharge_cheer_r", ( 11403, -9417, 273 ) );
}
