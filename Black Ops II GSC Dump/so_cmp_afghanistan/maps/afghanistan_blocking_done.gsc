#include maps/_horse_rider;
#include maps/afghanistan_arena_manager;
#include maps/afghanistan_anim;
#include maps/createart/afghanistan_art;
#include maps/_dialog;
#include maps/_vehicle_aianim;
#include maps/_turret;
#include maps/_horse;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

init_flags()
{
	flag_init( "blocking_done" );
}

init_spawn_funcs()
{
	add_spawn_function_veh( "bp1wave4_btr1", ::bp1wave4_btr1_behavior );
	add_spawn_function_veh( "bp1wave4_btr2", ::bp1wave4_btr2_behavior );
	add_spawn_function_veh( "bp1wave4_tank1", ::bp1wave4_tank1_behavior );
	add_spawn_function_veh( "bp1wave4_tank2", ::bp1wave4_tank2_behavior );
	add_spawn_function_group( "bp1wave4_hip1_rappel", "targetname", ::bp1wave4_hip1_rappel_logic );
	add_spawn_function_group( "base_launcher_defender", "targetname", ::launcher_defender_logic );
	add_spawn_function_group( "base_stinger_defender", "targetname", ::stinger_defender_logic );
}

skipto_blockingdone()
{
	skipto_setup();
	init_hero( "zhao" );
	init_hero( "woods" );
	skipto_teleport( "skipto_blockingdone", level.heroes );
	level.player setclientdvar( "cg_objectiveIndicatorFarFadeDist", 13000 );
	level thread maps/_horse::set_horse_in_combat( 1 );
	level.zhao = getent( "zhao_ai", "targetname" );
	level.woods = getent( "woods_ai", "targetname" );
	s_horse_zhao = getstruct( "last_zhao_horse", "targetname" );
	s_horse_woods = getstruct( "last_woods_horse", "targetname" );
	s_horse_player = getstruct( "last_player_horse", "targetname" );
	level.zhao_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.zhao_horse.origin = s_horse_zhao.origin;
	level.zhao_horse.angles = s_horse_zhao.angles;
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.woods_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods_horse.origin = s_horse_woods.origin;
	level.woods_horse.angles = s_horse_woods.angles;
	level.woods_horse veh_magic_bullet_shield( 1 );
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_horse_player.origin;
	level.mason_horse.angles = s_horse_player.angles;
	wait 0,1;
	level.mason_horse makevehicleusable();
	wait 0,1;
	level.player_wave3_loc = 1;
	level thread monitor_base_health();
	level thread stock_weapon_caches();
	flag_wait( "afghanistan_gump_arena" );
}

zhao_return_base()
{
	level endon( "blocking_done" );
	s_return_base = getstruct( "zhao_return", "targetname" );
	self setbrake( 0 );
	self setneargoalnotifydist( 200 );
	self setvehicleavoidance( 1 );
	if ( !isDefined( self get_driver() ) )
	{
		level.zhao ai_mount_horse( self );
	}
	wait 0,5;
	self setspeed( 25, 20, 10 );
	self setvehgoalpos( s_return_base.origin, 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	wait 0,5;
	level.zhao ai_dismount_horse( self );
	level.zhao set_fixednode( 0 );
}

woods_return_base()
{
	level endon( "blocking_done" );
	s_return_base = getstruct( "zhao_return", "targetname" );
	self setbrake( 0 );
	self setneargoalnotifydist( 200 );
	self setvehicleavoidance( 1 );
	if ( !isDefined( self get_driver() ) )
	{
		level.woods ai_mount_horse( self );
	}
	wait 1,5;
	self setspeed( 25, 20, 10 );
	self setvehgoalpos( s_return_base.origin + vectorScale( ( 0, 0, -1 ), 100 ), 1, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	wait 0,5;
	level.woods ai_dismount_horse( self );
	level.woods set_fixednode( 0 );
}

main()
{
	maps/createart/afghanistan_art::open_area();
	if ( level.skipto_point == "blocking_done" )
	{
		maps/afghanistan_anim::init_afghan_anims_part1b();
		delete_section1_scenes();
		delete_section3_scenes();
	}
	init_spawn_funcs();
	maps/afghanistan_arena_manager::cleanup_arena();
	level.n_wave4_bp = 0;
	level.b_tank_warn = 0;
	level thread base_reinforcement();
	level thread spawn_base_defenders();
	level thread objectives_wave4();
	level thread bp1wave4_start_event();
	level thread bp2wave4_start_event();
	level thread bp3wave4_start_event();
	level.zhao_horse thread zhao_return_base();
	level.woods_horse thread woods_return_base();
	spawn_manager_enable( "manager_arena_fight" );
	if ( level.player_wave3_loc == 1 )
	{
		if ( cointoss() )
		{
			flag_set( "bp2wave4_start" );
		}
		else
		{
			flag_set( "bp3wave4_start" );
		}
		wait 9;
		if ( flag( "bp2wave4_start" ) )
		{
			flag_set( "bp3wave4_start" );
		}
		else
		{
			flag_set( "bp2wave4_start" );
		}
		wait 5;
		flag_set( "bp1wave4_start" );
	}
	else if ( level.player_wave3_loc == 2 )
	{
		if ( cointoss() )
		{
			flag_set( "bp1wave4_start" );
		}
		else
		{
			flag_set( "bp3wave4_start" );
		}
		wait 9;
		if ( flag( "bp1wave4_start" ) )
		{
			flag_set( "bp3wave4_start" );
		}
		else
		{
			flag_set( "bp1wave4_start" );
		}
		wait 5;
		flag_set( "bp2wave4_start" );
	}
	else
	{
		if ( cointoss() )
		{
			flag_set( "bp1wave4_start" );
		}
		else
		{
			flag_set( "bp2wave4_start" );
		}
		wait 9;
		if ( flag( "bp1wave4_start" ) )
		{
			flag_set( "bp2wave4_start" );
		}
		else
		{
			flag_set( "bp1wave4_start" );
		}
		wait 5;
		flag_set( "bp3wave4_start" );
	}
	level thread struct_cleanup_wave2();
	flag_set( "wave4_started" );
	flag_wait( "arena_return" );
	flag_wait( "blocking_done" );
}

objectives_wave4()
{
	flag_wait_any( "bp1wave4_start", "bp2wave4_start", "bp3wave4_start" );
	set_objective( level.obj_defend_all, undefined, undefined, level.n_wave4_bp );
}

vo_defend()
{
	level.woods say_dialog( "wood_how_the_hell_d_they_0", 0 );
	level.zhao say_dialog( "zhao_brute_force_and_stre_0", 1 );
	level.woods say_dialog( "wood_doesn_t_mean_i_wante_0", 0,5 );
	flag_wait_all( "bp1wave4_start", "bp2wave4_start", "bp3wave4_start" );
	level.woods say_dialog( "wood_they_russians_must_h_0", 1 );
	level.woods say_dialog( "wood_tear_em_up_mason_0", 2 );
}

update_wave4_objective()
{
	level endon( "all_veh_destroyed" );
	self waittill( "death" );
	if ( level.n_wave4_bp < 6 )
	{
		level.n_wave4_bp++;
		if ( level.n_wave4_bp == 1 )
		{
			autosave_by_name( "arena_half_done" );
		}
		else if ( level.n_wave4_bp == 2 )
		{
			level.player thread say_dialog( "maso_come_on_0", 1 );
			autosave_by_name( "wave4_vehicle" );
		}
		else if ( level.n_wave4_bp == 3 )
		{
			level.woods thread say_dialog( "wood_keep_it_up_brother_0", 1 );
		}
		else if ( level.n_wave4_bp == 4 )
		{
			level.woods thread say_dialog( "wood_come_on_0", 1 );
		}
		else
		{
			level.player thread say_dialog( "maso_fuck_you_1", 1 );
		}
		wait 1;
		set_objective( level.obj_defend_all, undefined, undefined, level.n_wave4_bp );
		if ( level.n_wave4_bp > 5 && !flag( "all_veh_destroyed" ) )
		{
			level thread back_to_base();
			flag_set( "all_veh_destroyed" );
		}
	}
}

back_to_base()
{
	set_objective( level.obj_protect, undefined, "done" );
	set_objective( level.obj_defend_all, undefined, "done" );
	wait 1;
	set_objective( level.obj_defend_all, undefined, "delete" );
	s_return_base = getstruct( "return_base_pos", "targetname" );
	flag_wait( "all_veh_destroyed" );
	autosave_by_name( "wave4_done" );
	level.woods say_dialog( "huds_nice_work_guys_c_0", 0,5 );
	level.woods say_dialog( "huds_leave_the_mopping_up_0", 0,5 );
	level.woods say_dialog( "wood_fucking_a_0", 0,5 );
	wait 1;
	flag_set( "blocking_done" );
	level.player freezecontrols( 1 );
}

base_reinforcement()
{
	s_defend = getstruct( "base_defend_pos", "targetname" );
	set_objective( level.obj_protect, s_defend, "defend" );
	trigger_wait( "trigger_horse_reinforcement" );
	level thread vo_defend();
	set_objective( level.obj_protect, s_defend, "remove" );
	s_spawnpt = getstruct( "reinforcement_spawnpt", "targetname" );
	vh_horses = [];
	i = 0;
	while ( i < 4 )
	{
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		vh_horses[ i ] setvehicleavoidance( 1, undefined, 3 );
		sp_rider = getent( "reinforcement_rider", "targetname" );
		ai_rider = sp_rider spawn_ai( 1 );
		vh_horses[ i ] thread horse_reinforcement_behavior( ai_rider );
		wait 0,3;
		i++;
	}
	flag_wait( "blocking_done" );
	spawn_manager_kill( "manager_arena_fight" );
	spawn_manager_kill( "manager_hip3_troops" );
	flag_set( "end_arena_migs" );
}

horse_reinforcement_behavior( ai_rider )
{
	self endon( "death" );
	level endon( "blocking_done" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self makevehicleunusable();
	self setspeed( 25, 20, 10 );
	if ( isDefined( ai_rider ) )
	{
		ai_rider enter_vehicle( self );
		wait 0,1;
		self notify( "groupedanimevent" );
		if ( isDefined( ai_rider ) )
		{
			ai_rider maps/_horse_rider::ride_and_shoot( self );
		}
	}
	s_goal0 = getstruct( "reinforcement_goal0", "targetname" );
	s_goal1 = getstruct( "reinforcement_goal1", "targetname" );
	s_goal2 = getstruct( "reinforcement_goal2", "targetname" );
	s_goal3 = getstruct( "reinforcement_goal3", "targetname" );
	while ( 1 )
	{
		self setvehgoalpos( s_goal0.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		self setvehgoalpos( s_goal1.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		self setvehgoalpos( s_goal2.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		self setvehgoalpos( s_goal3.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
	}
}

truck_base_defense_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self veh_magic_bullet_shield( 1 );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self makevehicleunusable();
	self setspeed( 30, 20, 10 );
	s_goal0 = getstruct( "reinforcement_goal0", "targetname" );
	s_goal1 = getstruct( "truck_goal1", "targetname" );
	s_goal2 = getstruct( "truck_goal2", "targetname" );
	s_goal3 = getstruct( "truck_goal3", "targetname" );
	self setvehgoalpos( s_goal0.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal1.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal2.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( s_goal3.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setbrake( 1 );
	self notify( "unload" );
	self waittill( "unloaded" );
	self makevehicleusable();
}

spawn_base_defenders()
{
	trigger_wait( "trigger_horse_reinforcement" );
	ai_stinger = getent( "base_stinger_defender", "targetname" ) spawn_ai( 1 );
	wait 0,1;
	ai_launcher = getent( "base_launcher_defender", "targetname" ) spawn_ai( 1 );
}

stinger_defender_logic()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self magic_bullet_shield();
	self thread crew_stinger_logic();
	flag_wait( "all_veh_destroyed" );
	self stop_magic_bullet_shield();
	self die();
}

launcher_defender_logic()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self magic_bullet_shield();
	self thread crew_rpg_logic();
	flag_wait( "all_veh_destroyed" );
	self stop_magic_bullet_shield();
	self die();
}

bp1wave4_start_event()
{
	level thread bp1wave4_start_vehicles();
	level thread bp1wave4_start_trigger();
}

bp1wave4_start_trigger()
{
	level endon( "bp1wave4_start" );
	level endon( "bp2wave4_start" );
	level endon( "bp3wave4_start" );
	trigger_wait( "spawn_bp1" );
	flag_set( "bp1wave4_start" );
}

bp1wave4_start_vehicles()
{
	level endon( "blocking_done" );
	flag_wait( "bp1wave4_start" );
	level thread bp1wave4_boss_chooser();
	wait randomintrange( 5, 10 );
	level thread bp1wave4_vehicle_chooser();
}

bp1wave4_vehicle_chooser()
{
	level endon( "blocking_done" );
	level.n_bp1wave4_vehicles = 1;
	s_hip1_spawnpt = getstruct( "bp1wave4_hip1_spawnpt", "targetname" );
	s_hip2_spawnpt = getstruct( "bp1wave4_hip2_spawnpt", "targetname" );
	if ( level.n_bp1wave4_vehicles == 1 )
	{
		vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip1.origin = s_hip1_spawnpt.origin;
		vh_hip1.angles = s_hip1_spawnpt.angles;
		vh_hip1 thread bp1wave4_hip1_behavior();
		vh_hip1 waittill( "death" );
		vh_hip2 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip2.origin = s_hip2_spawnpt.origin;
		vh_hip2.angles = s_hip2_spawnpt.angles;
		vh_hip2 thread bp1wave4_hip2_behavior();
	}
}

bp1wave4_boss_chooser()
{
	level endon( "blocking_done" );
	level.n_bp1wave4_boss = 1;
	s_hind1_spawnpt = getstruct( "bp1wave4_hind1_spawnpt", "targetname" );
	s_hind2_spawnpt = getstruct( "bp1wave4_hind2_spawnpt", "targetname" );
	if ( level.n_bp1wave4_boss == 1 )
	{
		vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind1.origin = s_hind1_spawnpt.origin;
		vh_hind1.angles = s_hind1_spawnpt.angles;
		vh_hind1 thread bp1wave4_hind1_behavior();
	}
}

bp1wave4_hip1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread vehicle_delete_after_defend();
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp1wave4_hip1_spawnpt", "targetname" );
	i = 1;
	while ( i < 12 )
	{
		a_s_goal[ i ] = getstruct( "bp1wave4_hip1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self setspeed( 100, 50, 25 );
	self.b_rappel_done = 0;
	i = 1;
	while ( i < 12 )
	{
		if ( i == 8 || i == 11 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 7 )
		{
			self setspeed( 50, 25, 20 );
		}
		if ( i == 8 )
		{
			if ( distance2d( self.origin, level.player.origin ) < 1000 )
			{
				self setspeedimmediate( 0, 25, 20 );
				wait 3;
				self.b_rappel_done = 0;
				wait 3;
				self.b_rappel_done = 1;
				self setspeed( 50, 25, 20 );
				self.b_rappel_done = 1;
			}
		}
		i++;
	}
	if ( !self.b_rappel_done )
	{
		self setspeedimmediate( 0, 25, 20 );
		wait 3;
		self bp1wave4_hip1_rappel();
		wait 5;
		self setspeed( 50, 25, 20 );
		self.b_rappel_done = 1;
	}
	s_start = getstruct( "bp1wave4_hip1_goal12", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
}

bp1wave4_hip1_rappel()
{
	self endon( "death" );
	level endon( "blocking_done" );
	s_rappel_point = spawnstruct();
	s_rappel_point.origin = ( ( self.origin + ( anglesToForward( self.angles ) * 135 ) ) - ( anglesToRight( self.angles ) * 55 ) ) + vectorScale( ( 0, 0, -1 ), 155 );
	sp_rappell = getent( "bp1wave4_hip1_rappel", "targetname" );
	spawn_manager_enable( "manager_bp1wave4_hip1_rappel" );
	level thread bp1wave4_hip1_rappel_cache();
}

bp1wave4_hip1_rappel_logic()
{
	self endon( "death" );
	level endon( "blocking_done" );
	vol_cache = getent( "vol_cache4", "targetname" );
	self setgoalvolumeauto( vol_cache );
}

bp1wave4_hip1_rappel_cache()
{
	flag_wait( "arena_return" );
	wait 5;
	a_ai_guys = getentarray( "bp1wave4_hip1_rappel_ai", "targetname" );
	vol_cache = getent( "vol_cache3", "targetname" );
	while ( a_ai_guys.size )
	{
		_a806 = a_ai_guys;
		_k806 = getFirstArrayKey( _a806 );
		while ( isDefined( _k806 ) )
		{
			ai_guy = _a806[ _k806 ];
			wait randomfloatrange( 0,5, 2 );
			if ( isalive( ai_guy ) )
			{
				ai_guy cleargoalvolume();
				ai_guy setgoalvolumeauto( vol_cache );
			}
			_k806 = getNextArrayKey( _a806, _k806 );
		}
	}
}

bp1wave4_hip1_rappel_arena()
{
	a_ai_guys = getentarray( "bp1wave4_hip1_rappel_ai", "targetname" );
	vol_arena = getent( "vol_arena", "targetname" );
	while ( a_ai_guys.size )
	{
		_a828 = a_ai_guys;
		_k828 = getFirstArrayKey( _a828 );
		while ( isDefined( _k828 ) )
		{
			ai_guy = _a828[ _k828 ];
			wait randomfloatrange( 0,5, 2 );
			if ( isalive( ai_guy ) )
			{
				ai_guy cleargoalvolume();
				ai_guy setgoalvolumeauto( vol_arena );
			}
			_k828 = getNextArrayKey( _a828, _k828 );
		}
	}
}

bp1wave4_hip2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	target_set( self, ( -50, 0, -32 ) );
	self thread vehicle_delete_after_defend();
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp1wave4_hip2_spawnpt", "targetname" );
	i = 1;
	while ( i < 15 )
	{
		a_s_goal[ i ] = getstruct( "bp1wave4_hip2_goal" + i, "targetname" );
		i++;
	}
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( i < 14 )
	{
		self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		self waittill_any( "goal", "near_goal" );
		i++;
	}
	s_start = getstruct( "bp1wave4_hip2_goal14", "targetname" );
	self thread hip_circle( s_start );
	self thread hip_attack();
}

bp1wave4_btr1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
}

bp1wave4_btr2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
}

bp1wave4_hind1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp1wave4_hind1_spawnpt", "targetname" );
	i = 1;
	while ( i < 23 )
	{
		a_s_goal[ i ] = getstruct( "bp1wave4_hind1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 19 || i == 20 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 11 )
		{
			self thread hind_attack_base();
		}
		if ( i == 12 )
		{
			self notify( "stop_attack" );
		}
		if ( i == 20 )
		{
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 5, 8 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		i++;
		if ( i > 22 )
		{
			i = 10;
		}
	}
}

bp1wave4_hind2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp1wave4_hind2_spawnpt", "targetname" );
	i = 1;
	while ( i < 19 )
	{
		a_s_goal[ i ] = getstruct( "bp1wave4_hind2_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setforcenocull();
	self setneargoalnotifydist( 200 );
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 17 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 11 )
		{
			self thread hind_attack_base();
		}
		if ( i == 12 )
		{
			self notify( "stop_attack" );
		}
		if ( i == 17 )
		{
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 5, 8 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		i++;
		if ( i > 18 )
		{
			i = 9;
		}
	}
}

bp1wave4_tank1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::tank_damage;
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	self notify( "stop_attack" );
	self thread tank_baseattack();
}

bp1wave4_tank2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::tank_damage;
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	self notify( "stop_attack" );
	self thread tank_baseattack();
}

bp2wave4_start_event()
{
	level thread bp2wave4_start_vehicles();
	level thread bp2wave4_start_trigger();
}

bp2wave4_start_trigger()
{
	level endon( "bp1wave4_start" );
	level endon( "bp2wave4_start" );
	level endon( "bp3wave4_start" );
	trigger_wait( "spawn_wave2_bp2" );
	flag_set( "bp2wave4_start" );
}

bp2wave4_start_vehicles()
{
	level endon( "blocking_done" );
	flag_wait( "bp2wave4_start" );
	level thread bp2wave4_boss_chooser();
	wait randomintrange( 5, 10 );
	level thread bp2wave4_vehicle_chooser();
}

bp2wave4_vehicle_chooser()
{
	level endon( "blocking_done" );
	level.n_bp2wave4_vehicles = randomint( 3 );
	s_hip1_spawnpt = getstruct( "bp2wave4_hip1_spawnpt", "targetname" );
	s_hip2_spawnpt = getstruct( "bp2wave4_hip2_spawnpt", "targetname" );
	s_btr1_spawnpt = getstruct( "wave4bp2_btr1_spawnpt", "targetname" );
	s_btr2_spawnpt = getstruct( "wave4bp2_btr2_spawnpt", "targetname" );
	if ( level.n_bp2wave4_vehicles == 0 )
	{
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_hip1_spawnpt.origin;
		vh_hip.angles = s_hip1_spawnpt.angles;
		vh_hip thread bp2wave4_hip1_behavior();
		vh_hip thread vehicle_delete_after_defend();
		vh_hip waittill( "death" );
		vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr.origin = s_btr1_spawnpt.origin;
		vh_btr.angles = s_btr1_spawnpt.angles;
		vh_btr.targetname = "wave4bp2_btr1";
		vh_btr thread wave4bp2_btr1_behavior();
		vh_btr thread vehicle_delete_after_defend();
	}
	else if ( level.n_bp2wave4_vehicles == 1 )
	{
		vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip1.origin = s_hip1_spawnpt.origin;
		vh_hip1.angles = s_hip1_spawnpt.angles;
		vh_hip1 thread bp2wave4_hip1_behavior();
		vh_hip1 thread vehicle_delete_after_defend();
		vh_hip1 waittill( "death" );
		vh_hip2 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip2.origin = s_hip2_spawnpt.origin;
		vh_hip2.angles = s_hip2_spawnpt.angles;
		vh_hip2 thread bp2wave4_hip2_behavior();
		vh_hip2 thread vehicle_delete_after_defend();
	}
	else vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_btr1_spawnpt.origin;
	vh_btr.angles = s_btr1_spawnpt.angles;
	vh_btr.targetname = "wave4bp2_btr1";
	vh_btr thread wave4bp2_btr1_behavior();
	vh_btr thread vehicle_delete_after_defend();
	vh_btr = getent( "wave4bp2_btr1", "targetname" );
	if ( isalive( vh_btr ) )
	{
		vh_btr waittill( "death" );
		vh_btr2 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr2.origin = s_btr2_spawnpt.origin;
		vh_btr2.angles = s_btr2_spawnpt.angles;
		vh_btr2.targetname = "wave4bp2_btr2";
		vh_btr2 thread wave4bp2_btr2_behavior();
		vh_btr2 thread vehicle_delete_after_defend();
	}
	else
	{
		vh_btr2 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr2.origin = s_btr2_spawnpt.origin;
		vh_btr2.angles = s_btr2_spawnpt.angles;
		vh_btr2.targetname = "wave4bp2_btr2";
		vh_btr2 thread wave4bp2_btr2_behavior();
		vh_btr2 thread vehicle_delete_after_defend();
	}
}

bp2wave4_hip1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp2wave4_hip1_spawnpt", "targetname" );
	i = 1;
	while ( i < 17 )
	{
		a_s_goal[ i ] = getstruct( "bp2wave4_hip1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self setspeed( 50, 25, 20 );
	i = 1;
	self.b_rappel_done = 0;
	while ( i < 17 )
	{
		if ( i == 9 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 9 )
		{
			if ( !self.b_rappel_done )
			{
				self setspeedimmediate( 0, 25, 20 );
				wait 3;
				wait 5;
				self setspeed( 50, 25, 20 );
				self.b_rappel_done = 1;
				self thread hip_attack();
			}
		}
		i++;
		if ( i > 16 )
		{
			i = 10;
		}
	}
}

bp2wave4_hip1_rappel()
{
	self endon( "death" );
	level endon( "blocking_done" );
	s_rappel_point = spawnstruct();
	s_rappel_point.origin = ( ( self.origin + ( anglesToForward( self.angles ) * 135 ) ) - ( anglesToRight( self.angles ) * 55 ) ) + vectorScale( ( 0, 0, -1 ), 155 );
	sp_rappell = getent( "bp2wave4_hip1_rappel", "targetname" );
	level thread bp2wave4_hip1_rappel_cache();
}

bp2wave4_hip1_rappel_logic()
{
	self endon( "death" );
	level endon( "blocking_done" );
	vol_cache = getent( "vol_cache7", "targetname" );
	self setgoalvolumeauto( vol_cache );
}

bp2wave4_hip1_rappel_cache()
{
	flag_wait( "arena_return" );
	wait 5;
	a_ai_guys = getentarray( "bp2wave4_hip1_rappel_ai", "targetname" );
	vol_cache = getent( "vol_cache5", "targetname" );
	while ( a_ai_guys.size )
	{
		_a1329 = a_ai_guys;
		_k1329 = getFirstArrayKey( _a1329 );
		while ( isDefined( _k1329 ) )
		{
			ai_guy = _a1329[ _k1329 ];
			if ( isalive( ai_guy ) )
			{
				ai_guy cleargoalvolume();
				ai_guy setgoalvolumeauto( vol_cache );
			}
			_k1329 = getNextArrayKey( _a1329, _k1329 );
		}
	}
}

bp2wave4_hip1_rappel_arena()
{
	a_ai_guys = getentarray( "bp1wave4_hip1_rappel_ai", "targetname" );
	vol_arena = getent( "vol_arena", "targetname" );
	while ( a_ai_guys.size )
	{
		_a1349 = a_ai_guys;
		_k1349 = getFirstArrayKey( _a1349 );
		while ( isDefined( _k1349 ) )
		{
			ai_guy = _a1349[ _k1349 ];
			wait randomfloatrange( 0,5, 2 );
			if ( isalive( ai_guy ) )
			{
				ai_guy cleargoalvolume();
				ai_guy setgoalvolumeauto( vol_arena );
			}
			_k1349 = getNextArrayKey( _a1349, _k1349 );
		}
	}
}

bp2wave4_hip2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp2wave4_hip2_spawnpt", "targetname" );
	i = 1;
	while ( i < 17 )
	{
		a_s_goal[ i ] = getstruct( "bp2wave4_hip2_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self thread hip_attack();
	self setspeed( 50, 25, 20 );
	self.b_rappel_done = 0;
	i = 1;
	while ( 1 )
	{
		if ( i == 8 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		i++;
		if ( i > 16 )
		{
			i = 9;
		}
	}
}

wave4bp2_btr1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
	nd_start = getvehiclenode( "wave4bp2_btr1_startnode", "targetname" );
	wait 0,5;
	self thread go_path( nd_start );
}

wave4bp2_btr2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
	nd_start = getvehiclenode( "wave4bp2_btr2_startnode", "targetname" );
	wait 0,5;
	self thread go_path( nd_start );
}

bp2wave4_boss_chooser()
{
	level endon( "blocking_done" );
	level.n_bp2wave4_boss = randomint( 3 );
	if ( level.n_bp2wave4_boss == 0 )
	{
		s_spawnpt = getstruct( "wave4bp2_tank1_spawnpt", "targetname" );
		vh_tank1 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank1.origin = s_spawnpt.origin;
		vh_tank1.angles = s_spawnpt.angles;
		vh_tank1 thread wave4bp2_tank1_behavior();
		vh_tank1 thread vehicle_delete_after_defend();
		s_hind1_spawnpt = getstruct( "bp2wave4_hind1_spawnpt", "targetname" );
		vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind1.origin = s_hind1_spawnpt.origin;
		vh_hind1.angles = s_hind1_spawnpt.angles;
		vh_hind1 thread bp2wave4_hind1_behavior();
		vh_hind1 thread vehicle_delete_after_defend();
	}
	else if ( level.n_bp2wave4_boss == 1 )
	{
		s_hind1_spawnpt = getstruct( "bp2wave4_hind1_spawnpt", "targetname" );
		s_hind2_spawnpt = getstruct( "bp2wave4_hind2_spawnpt", "targetname" );
		vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind1.origin = s_hind1_spawnpt.origin;
		vh_hind1.angles = s_hind1_spawnpt.angles;
		vh_hind1 thread bp2wave4_hind1_behavior();
		vh_hind1 thread vehicle_delete_after_defend();
		wait 2;
		vh_hind2 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind2.origin = s_hind2_spawnpt.origin;
		vh_hind2.angles = s_hind2_spawnpt.angles;
		vh_hind2 thread bp2wave4_hind2_behavior();
		vh_hind2 thread vehicle_delete_after_defend();
	}
	else
	{
		s_spawnpt = getstruct( "wave4bp2_tank1_spawnpt", "targetname" );
		vh_tank1 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank1.origin = s_spawnpt.origin;
		vh_tank1.angles = s_spawnpt.angles;
		vh_tank1 thread wave4bp2_tank1_behavior();
		vh_tank1 thread vehicle_delete_after_defend();
		wait 5;
		s_spawnpt = getstruct( "wave4bp2_tank2_spawnpt", "targetname" );
		vh_tank2 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank2.origin = s_spawnpt.origin;
		vh_tank2.angles = s_spawnpt.angles;
		vh_tank2 thread wave4bp2_tank2_behavior();
		vh_tank2 thread vehicle_delete_after_defend();
	}
}

bp2wave4_hind1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp2wave4_hind1_spawnpt", "targetname" );
	i = 1;
	while ( i < 12 )
	{
		a_s_goal[ i ] = getstruct( "bp2wave4_hind1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 2 || i == 3 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 2 )
		{
			wait randomfloatrange( 2, 3 );
		}
		if ( i == 3 )
		{
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 4, 6 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		if ( i == 5 )
		{
			self thread hind_attack_base();
		}
		if ( i == 6 )
		{
			self notify( "stop_attack" );
		}
		if ( i == 9 )
		{
			self setspeed( 200, 50, 25 );
		}
		if ( i == 10 )
		{
			self setspeed( 100, 50, 25 );
		}
		i++;
		if ( i > 11 )
		{
			i = 2;
		}
	}
}

bp2wave4_hind2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread vehicle_delete_after_defend();
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp2wave4_hind2_spawnpt", "targetname" );
	i = 1;
	while ( i < 12 )
	{
		a_s_goal[ i ] = getstruct( "bp2wave4_hind2_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 2 || i == 3 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 2 )
		{
			wait randomfloatrange( 2, 3 );
		}
		if ( i == 3 )
		{
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 4, 6 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		if ( i == 4 )
		{
			self thread hind_attack_base();
		}
		if ( i == 5 )
		{
			self notify( "stop_attack" );
		}
		if ( i == 7 )
		{
			self setspeed( 200, 50, 25 );
		}
		if ( i == 8 )
		{
			self setspeed( 100, 50, 25 );
		}
		i++;
		if ( i > 10 )
		{
			i = 2;
		}
	}
}

hind_attackbase_timer( n_timer )
{
	self endon( "death" );
	level endon( "blocking_done" );
	wait n_timer;
	self notify( "bp2wave4_hind_attackbase" );
	self clearlookatent();
	self clearvehgoalpos();
	self setspeed( 50, 25, 20 );
	s_goal1 = getstruct( "bp2wave4_hind_attackpos", "targetname" );
	self setvehgoalpos( s_goal1.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	wait 3;
	self thread hind_baseattack();
}

wave4bp2_tank1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	nd_start = getvehiclenode( "wave4bp2_tank1_startnode", "targetname" );
	wait 0,1;
	self thread go_path( nd_start );
	self.overridevehicledamage = ::tank_damage;
	self thread update_wave4_objective();
	self thread vehicle_delete_after_defend();
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	if ( !level.b_tank_warn )
	{
		level.woods thread say_dialog( "wood_watch_the_tanks_0", 0 );
		level.b_tank_warn = 1;
	}
	self notify( "stop_attack" );
	self thread tank_baseattack();
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

wave4bp2_tank2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	nd_start = getvehiclenode( "wave4bp2_tank2_startnode", "targetname" );
	wait 0,1;
	self thread go_path( nd_start );
	self.overridevehicledamage = ::tank_damage;
	self thread update_wave4_objective();
	self thread vehicle_delete_after_defend();
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	if ( !level.b_tank_warn )
	{
		level.woods thread say_dialog( "wood_watch_the_tanks_0", 0 );
		level.b_tank_warn = 1;
	}
	self notify( "stop_attack" );
	self thread tank_baseattack();
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

bp3wave4_start_event()
{
	level thread bp3wave4_start_vehicles();
	level thread bp3wave4_start_trigger();
}

bp3wave4_start_vehicles()
{
	level endon( "blocking_done" );
	flag_wait( "bp3wave4_start" );
	level thread bp3wave4_boss_chooser();
	wait randomintrange( 5, 10 );
	level thread bp3wave4_vehicle_chooser();
}

bp3wave4_start_trigger()
{
	level endon( "bp1wave4_start" );
	level endon( "bp2wave4_start" );
	level endon( "bp3wave4_start" );
	trigger_wait( "bp3_defense" );
	flag_set( "bp3wave4_start" );
}

bp3wave4_vehicle_chooser()
{
	level endon( "blocking_done" );
	level.n_bp3wave4_vehicles = randomint( 3 );
	s_hip1_spawnpt = getstruct( "bp3wave4_hip1_spawnpt", "targetname" );
	s_hip2_spawnpt = getstruct( "bp3wave4_hip2_spawnpt", "targetname" );
	if ( level.n_bp3wave4_vehicles == 0 )
	{
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_hip1_spawnpt.origin;
		vh_hip.angles = s_hip1_spawnpt.angles;
		vh_hip thread bp3wave4_hip1_behavior();
		vh_hip thread vehicle_delete_after_defend();
		vh_hip waittill( "death" );
		s_spawnpt = getstruct( "wave4bp3_btr1_spawnpt", "targetname" );
		vh_btr1 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr1.origin = s_spawnpt.origin;
		vh_btr1.angles = s_spawnpt.angles;
		vh_btr1 thread wave4bp3_btr1_behavior();
	}
	else if ( level.n_bp3wave4_vehicles == 1 )
	{
		vh_hip1 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip1.origin = s_hip1_spawnpt.origin;
		vh_hip1.angles = s_hip1_spawnpt.angles;
		vh_hip1 thread bp3wave4_hip1_behavior();
		vh_hip1 thread vehicle_delete_after_defend();
		vh_hip1 waittill( "death" );
		vh_hip2 = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip2.origin = s_hip2_spawnpt.origin;
		vh_hip2.angles = s_hip2_spawnpt.angles;
		vh_hip2 thread bp3wave4_hip2_behavior();
		vh_hip2 thread vehicle_delete_after_defend();
	}
	else
	{
		s_spawnpt = getstruct( "wave4bp3_btr1_spawnpt", "targetname" );
		vh_btr1 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr1.origin = s_spawnpt.origin;
		vh_btr1.angles = s_spawnpt.angles;
		vh_btr1 thread wave4bp3_btr1_behavior();
		wait 0,5;
		if ( isalive( vh_btr1 ) )
		{
			vh_btr1 waittill( "death" );
		}
		s_spawnpt = getstruct( "wave4bp3_btr2_spawnpt", "targetname" );
		vh_btr2 = spawn_vehicle_from_targetname( "btr_soviet" );
		vh_btr2.origin = s_spawnpt.origin;
		vh_btr2.angles = s_spawnpt.angles;
		vh_btr2 thread wave4bp3_btr2_behavior();
	}
}

bp3wave4_boss_chooser()
{
	level endon( "blocking_done" );
	level.n_bp3wave4_boss = randomint( 3 );
	s_hind1_spawnpt = getstruct( "bp3wave4_hind1_spawnpt", "targetname" );
	s_hind2_spawnpt = getstruct( "bp3wave4_hind2_spawnpt", "targetname" );
	if ( level.n_bp3wave4_boss == 0 )
	{
		s_spawnpt = getstruct( "wave4bp3_tank1_spawnpt", "targetname" );
		vh_tank1 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank1.origin = s_spawnpt.origin;
		vh_tank1.angles = s_spawnpt.angles;
		vh_tank1 thread wave4bp3_tank1_behavior();
		vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind1.origin = s_hind1_spawnpt.origin;
		vh_hind1.angles = s_hind1_spawnpt.angles;
		vh_hind1 thread bp3wave4_hind1_behavior();
		vh_hind1 thread vehicle_delete_after_defend();
	}
	else if ( level.n_bp3wave4_boss == 1 )
	{
		vh_hind1 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind1.origin = s_hind1_spawnpt.origin;
		vh_hind1.angles = s_hind1_spawnpt.angles;
		vh_hind1 thread bp3wave4_hind1_behavior();
		vh_hind1 thread vehicle_delete_after_defend();
		wait 5;
		vh_hind2 = spawn_vehicle_from_targetname( "hind_soviet" );
		vh_hind2.origin = s_hind2_spawnpt.origin;
		vh_hind2.angles = s_hind2_spawnpt.angles;
		vh_hind2 thread bp3wave4_hind2_behavior();
		vh_hind2 thread vehicle_delete_after_defend();
	}
	else
	{
		s_spawnpt = getstruct( "wave4bp3_tank1_spawnpt", "targetname" );
		vh_tank1 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank1.origin = s_spawnpt.origin;
		vh_tank1.angles = s_spawnpt.angles;
		vh_tank1 thread wave4bp3_tank1_behavior();
		wait 4;
		s_spawnpt = getstruct( "wave4bp3_tank2_spawnpt", "targetname" );
		vh_tank2 = spawn_vehicle_from_targetname( "tank_soviet" );
		vh_tank2.origin = s_spawnpt.origin;
		vh_tank2.angles = s_spawnpt.angles;
		vh_tank2 thread wave4bp3_tank2_behavior();
	}
}

bp3wave4_hip1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp3wave4_hip1_spawnpt", "targetname" );
	i = 1;
	while ( i < 14 )
	{
		a_s_goal[ i ] = getstruct( "bp3wave4_hip1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 200 );
	self setforcenocull();
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 6 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 3 )
		{
			self setspeed( 50, 25, 20 );
		}
		if ( i == 6 )
		{
			self setspeedimmediate( 0, 25, 20 );
			wait 3;
			self.b_rappel_done = 0;
			wait 5;
			self.b_rappel_done = 1;
			self setspeed( 50, 25, 20 );
			self thread hip_attack();
		}
		i++;
		if ( i > 13 )
		{
			i = 7;
		}
	}
}

bp3wave4_hip2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread heli_select_death();
	self thread update_wave4_objective();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp3wave4_hip2_spawnpt", "targetname" );
	i = 1;
	while ( i < 14 )
	{
		a_s_goal[ i ] = getstruct( "bp3wave4_hip2_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self thread hip_attack();
	self setspeed( 50, 25, 20 );
	i = 1;
	while ( 1 )
	{
		self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		self waittill_any( "goal", "near_goal" );
		i++;
		if ( i > 13 )
		{
			i = 7;
		}
	}
}

wave4bp3_btr1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread go_path( getvehiclenode( "wave4bp3_btr1_startnode", "targetname" ) );
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
}

wave4bp3_btr2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::sticky_grenade_damage;
	self thread go_path( getvehiclenode( "wave4bp3_btr2_startnode", "targetname" ) );
	self thread vehicle_delete_after_defend();
	self thread btr_attack();
	self thread projectile_fired_at_btr();
	self thread update_wave4_objective();
}

bp3wave4_hind1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp3wave4_hind1_spawnpt", "targetname" );
	i = 1;
	while ( i < 13 )
	{
		a_s_goal[ i ] = getstruct( "bp3wave4_hind1_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i == 5 || i == 9 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 5 || i == 9 )
		{
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 4, 6 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		if ( i == 6 )
		{
			self thread hind_attack_base();
		}
		if ( i == 7 )
		{
			self notify( "stop_attack" );
		}
		i++;
		if ( i > 12 )
		{
			i = 4;
		}
	}
}

bp3wave4_hind2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	e_base_pos = getent( "base_entrance_pos", "targetname" );
	self thread update_wave4_objective();
	self thread heli_select_death();
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "bp3wave4_hind2_spawnpt", "targetname" );
	i = 1;
	while ( i < 13 )
	{
		a_s_goal[ i ] = getstruct( "bp3wave4_hind2_goal" + i, "targetname" );
		i++;
	}
	target_set( self, ( -50, 0, -32 ) );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 500 );
	self setforcenocull();
	self setspeed( 80, 50, 25 );
	i = 1;
	while ( 1 )
	{
		if ( i != 5 || i == 6 && i == 12 )
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 1 );
		}
		else
		{
			self setvehgoalpos( a_s_goal[ i ].origin, 0 );
		}
		self waittill_any( "goal", "near_goal" );
		if ( i == 6 || i == 12 )
		{
			self setlookatent( e_base_pos );
			wait 3;
			self thread hind_attack_base();
			wait randomfloatrange( 4, 6 );
			self notify( "stop_attack" );
			self thread hind_attack_indefinitely();
			wait randomfloatrange( 4, 6 );
			self notify( "stop_attack" );
			self clearlookatent();
		}
		i++;
		if ( i > 12 )
		{
			i = 5;
		}
	}
}

wave4bp3_tank1_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::tank_damage;
	self thread update_wave4_objective();
	self thread vehicle_delete_after_defend();
	self thread go_path( getvehiclenode( "wave4bp3_tank1_startnode", "targetname" ) );
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	if ( !level.b_tank_warn )
	{
		level.woods thread say_dialog( "wood_watch_the_tanks_0", 0 );
		level.b_tank_warn = 1;
	}
	self notify( "stop_attack" );
	self thread tank_baseattack();
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

wave4bp3_tank2_behavior()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self.overridevehicledamage = ::tank_damage;
	self thread update_wave4_objective();
	self thread vehicle_delete_after_defend();
	self thread go_path( getvehiclenode( "wave4bp3_tank2_startnode", "targetname" ) );
	self thread tank_targetting();
	self waittill( "reached_end_node" );
	if ( !level.b_tank_warn )
	{
		level.woods thread say_dialog( "wood_watch_the_tanks_0", 0 );
		level.b_tank_warn = 1;
	}
	self notify( "stop_attack" );
	self thread tank_baseattack();
	self vehicle_detachfrompath();
	self setbrake( 1 );
}

wave4_hip_circle( s_start )
{
	self endon( "death" );
	self endon( "stop_circle" );
	level endon( "blocking_done" );
	self thread bp3wave4_hip_fire_support();
	self setspeed( 50, 25, 20 );
	s_goal = s_start;
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin, 0 );
		self waittill_any( "goal", "near_goal" );
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

wave4_hind1_circle( s_start )
{
	self endon( "death" );
	self endon( "stop_circle" );
	self endon( "bp1wave4_hind1_attackbase" );
	level endon( "blocking_done" );
	self setspeed( 50, 25, 20 );
	s_goal = s_start;
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin, 0 );
		self waittill_any( "goal", "near_goal" );
		if ( s_goal.targetname == "bp1wave4_hind1_goal11" || s_goal.targetname == "bp1wave4_hind1_goal15" )
		{
			self thread hind_stop_attack_aftertime( randomintrange( 4, 8 ) );
			self hind_attack_think( 3000 );
		}
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

wave4_hind2_circle( s_start )
{
	self endon( "death" );
	self endon( "stop_circle" );
	self endon( "bp1wave4_hind2_attackbase" );
	level endon( "blocking_done" );
	self setspeed( 50, 25, 20 );
	s_goal = s_start;
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin, 0 );
		self waittill_any( "goal", "near_goal" );
		if ( s_goal.targetname != "bp1wave4_hind2_goal9" || s_goal.targetname == "bp1wave4_hind2_goal13" && s_goal.targetname == "bp1wave4_hind2_goal17" )
		{
			self thread hind_stop_attack_aftertime( randomintrange( 4, 8 ) );
			self hind_attack_think( 3000 );
		}
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

bp3wave4_hip_fire_support()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self waittill_any( "goal", "near_goal" );
	self enable_turret( 2 );
}

vehicle_delete_after_defend()
{
	flag_wait( "blocking_done" );
}

horse_follow_player()
{
	self endon( "death" );
	level endon( "blocking_done" );
	self setvehicleavoidance( 1 );
	while ( 1 )
	{
		if ( distance2d( self.origin, level.player.origin ) > 500 )
		{
			self setvehgoalpos( level.player.origin, 1, 1 );
		}
		wait 2;
	}
	self clearvehgoalpos();
	self setbrake( 1 );
	self setspeedimmediate( 0 );
	self makevehicleusable();
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
}
