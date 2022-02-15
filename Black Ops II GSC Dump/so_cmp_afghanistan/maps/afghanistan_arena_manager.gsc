#include maps/afghanistan_base_threats;
#include maps/_horse_rider;
#include maps/afghanistan_firehorse;
#include maps/_friendlyfire;
#include maps/_drones_aipath;
#include maps/_music;
#include maps/_dialog;
#include maps/_horse;
#include maps/_vehicle_aianim;
#include maps/_turret;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/afghanistan_utility;
#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

arena_manager_init()
{
	level.a_all_vehicle_pathnodes = getvehiclenodearray( "vehicle_path_nodes", "script_noteworthy" );
	level.arena = spawnstruct();
	level.arena.a_vehicle_path_nodes = level.a_all_vehicle_pathnodes;
	level.vehicle_immune_notify_func = ::msg_player_needs_new_weapon;
}

msg_player_needs_new_weapon( str_damage_mod, str_weapon )
{
	if ( str_damage_mod != "MOD_CRUSH" && !issubstr( self.vehicletype, "horse" ) && !issubstr( str_weapon, "mortar" ) && !issubstr( str_weapon, "sticky" ) )
	{
		level thread screen_message_create( &"AFGHANISTAN_INEFFECTIVE_WEAPON", undefined, undefined, undefined, 3 );
		level notify( "immune_vehicle_notify" );
	}
	attacker = level.player;
	if ( issubstr( self.vehicletype, "horse" ) )
	{
		attacker.participation -= 75;
		attacker maps/_friendlyfire::participation_point_cap();
		attacker maps/_friendlyfire::friendly_fire_checkpoints();
	}
}

respawn_arena()
{
	flag_clear( "clear_arena" );
	level.vehicle_immune_notify_func = ::msg_player_needs_new_weapon;
	level thread maps/afghanistan_firehorse::fire_stingers_base();
	level thread arena_explosions();
	level thread hips_arena_ambient();
	level thread manage_arena_enemy_squads();
	level thread spawn_arena_trucks();
	level thread start_horse_patrollers();
	level thread vo_muj_in_arena();
	level thread vo_russians_in_arena();
	spawn_manager_set_global_active_count( 30 );
	level thread track_player_in_blocking_points();
	flag_wait( "base_successfully_defended" );
	cleanup_arena();
}

spawn_arena_trucks()
{
	vh_truck1 = spawn_vehicle_from_targetname( "truck_afghan_arena_1" );
	vh_truck1.targetname = "arena_truck_ambient";
	vh_truck1 setvehicleavoidance( 1 );
	vh_truck1 setbrake( 1 );
	vh_truck1 makevehicleusable();
	vh_truck2 = spawn_vehicle_from_targetname( "truck_afghan_arena_2" );
	vh_truck2.targetname = "arena_truck_ambient";
	vh_truck2 setvehicleavoidance( 1 );
	vh_truck2 setbrake( 1 );
	vh_truck2 makevehicleusable();
	level.a_ambient_arena_trucks = array( vh_truck1, vh_truck2 );
}

cleanup_trucks_on_bp3()
{
	a_vh_trucks = getentarray( "arena_truck_ambient", "targetname" );
	while ( a_vh_trucks.size )
	{
		i = a_vh_trucks.size - 1;
		while ( i >= 0 )
		{
			if ( isalive( a_vh_trucks[ i ] ) )
			{
				a_vh_trucks[ i ].delete_on_death = 1;
				a_vh_trucks[ i ] notify( "death" );
				if ( !isalive( a_vh_trucks[ i ] ) )
				{
					a_vh_trucks[ i ] delete();
				}
			}
			i--;

		}
	}
}

track_player_in_blocking_points()
{
	level endon( "stop_sandbox" );
	level.player_location = "arena";
	previous_location = level.player_location;
	blocking_pt_1 = getent( "t_in_bp1", "targetname" );
	blocking_pt_2 = getent( "bp2_commit", "targetname" );
	blocking_pt_3 = getent( "t_in_bp3", "targetname" );
	while ( 1 )
	{
		if ( level.player istouching( blocking_pt_1 ) )
		{
			level.player_location = "bp1";
			flag_set( "bp_underway" );
		}
		else if ( level.player istouching( blocking_pt_2 ) )
		{
			level.player_location = "bp2";
			flag_set( "bp_underway" );
		}
		else if ( level.player istouching( blocking_pt_3 ) )
		{
			level.player_location = "bp3";
			flag_set( "bp_underway" );
		}
		else
		{
			level.player_location = "arena";
			flag_clear( "bp_underway" );
		}
		if ( level.player_location != previous_location )
		{
			level notify( "player_moved" );
			previous_location = level.player_location;
		}
		wait 1;
	}
}

horses_from_behind()
{
	a_offsets = array( 60, -32, 32, -60 );
	while ( flag( "bp_underway" ) )
	{
		wait 1;
	}
	a_behind_nodes = [];
	_a238 = level.arena.a_vehicle_path_nodes;
	_k238 = getFirstArrayKey( _a238 );
	while ( isDefined( _k238 ) )
	{
		node = _a238[ _k238 ];
		if ( level.player is_behind( node.origin ) )
		{
			a_behind_nodes[ a_behind_nodes.size ] = node;
		}
		_k238 = getNextArrayKey( _a238, _k238 );
	}
	spawnpt = get_array_of_closest( level.player.origin, a_behind_nodes )[ 0 ];
	n_horse_count = randomint( 2 ) + 2;
	i = 0;
	while ( i < n_horse_count )
	{
		e_horse = spawn_horse_and_rider_ambient( spawnpt );
		e_horse thread run_horse_passed_player_then_away();
		e_horse pathfixedoffset( ( 0, a_offsets[ i ], 0 ) );
		wait 0,5;
		i++;
	}
	arena_horses_alive = 1;
	while ( arena_horses_alive )
	{
		a_arena_horses = getentarray( "arena_rideby_horse", "targetname" );
		arena_horses_alive = 0;
		_a264 = a_arena_horses;
		_k264 = getFirstArrayKey( _a264 );
		while ( isDefined( _k264 ) )
		{
			e_horse = _a264[ _k264 ];
			if ( !is_corpse( e_horse ) )
			{
				arena_horses_alive = 1;
			}
			_k264 = getNextArrayKey( _a264, _k264 );
		}
		wait 1;
	}
}

run_horse_passed_player_then_away()
{
	self endon( "death" );
	in_front_of_player = 0;
	self setneargoalnotifydist( 500 );
	self setspeed( 25, 25, 10 );
	while ( !in_front_of_player )
	{
		vec_front_point = level.player.origin + ( anglesToForward( level.player.angles ) * 1200 );
		nd_closest = get_array_of_closest( vec_front_point, level.arena.a_vehicle_path_nodes )[ 0 ];
		self setvehgoalpos( nd_closest.origin, 1, 1 );
		wait 1;
		if ( level.player is_player_looking_at( self.origin, 0,5 ) )
		{
			in_front_of_player = 1;
		}
	}
	while ( 1 )
	{
		nd_farthest = get_array_of_farthest( level.player.origin, level.arena.a_vehicle_path_nodes )[ 0 ];
		self setvehgoalpos( nd_farthest.origin, 1, 1 );
		self waittill_either( "goal", "near_goal" );
		if ( isDefined( self.rider ) )
		{
			self.rider delete();
		}
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
		return;
	}
}

spawn_horse_and_rider_ambient( nd_spawnpt )
{
	horse = spawn_vehicle_from_targetname( "horse_afghan" );
	horse.origin = nd_spawnpt.origin;
	horse.angles = nd_spawnpt.angles;
	horse.targetname = "arena_rideby_horse";
	horse setvehicleavoidance( 1, undefined, 3 );
	wait 0,1;
	horse setneargoalnotifydist( 400 );
	horse makevehicleunusable();
	sp_rider = getent( "horse_patroller", "targetname" );
	ai_rider = sp_rider spawn_ai( 1 );
	if ( !isDefined( ai_rider ) )
	{
		horse.delete_on_death = 1;
		horse notify( "death" );
		if ( !isalive( horse ) )
		{
			horse delete();
		}
		return;
	}
	ai_rider enter_vehicle( horse );
	horse.rider = ai_rider;
	wait 0,1;
	horse notify( "groupedanimevent" );
	if ( isDefined( ai_rider ) )
	{
		ai_rider maps/_horse_rider::ride_and_shoot( horse );
		horse thread monitor_rider( ai_rider );
	}
	return horse;
}

vehicles_that_hunt()
{
}

hunt_horse_spawn()
{
	vh_horses = [];
	a_offsets = array( 60, -32, 32, -60 );
	vh_uazs = getentarray( "arena_uaz", "targetname" );
	if ( vh_uazs.size )
	{
		vh_uaz_targets = sort_by_distance( vh_uazs, self.origin );
		e_target = vh_uaz_targets[ 0 ];
	}
	else
	{
		wait 20;
	}
	i = 0;
	while ( i < 4 )
	{
		s_spawnpt = getstruct( "horse_patrol_spawnpt1", "targetname" );
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		vh_horses[ i ].targetname = "arena_horse";
		vh_horses[ i ] pathfixedoffset( ( 0, a_offsets[ i ], 0 ) );
		sp_rider = getent( "horse_patroller", "targetname" );
		ai_rider = sp_rider spawn_ai( 1 );
		vh_horses[ i ] thread hunt_horse_behavior( e_target, ai_rider );
		wait randomfloatrange( 0,5, 1 );
		i++;
	}
}

hunt_horse_behavior( e_target, ai_rider )
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 400 );
	self makevehicleunusable();
	self veh_magic_bullet_shield( 1 );
	if ( isalive( ai_rider ) )
	{
		ai_rider enter_vehicle( self );
		wait 0,1;
		self notify( "groupedanimevent" );
		if ( isDefined( ai_rider ) )
		{
			ai_rider maps/_horse_rider::ride_and_shoot( self );
			self thread monitor_rider( ai_rider );
			self thread choose_driveby_or_dismount( ai_rider );
		}
	}
	while ( isalive( e_target ) )
	{
		self setvehgoalpos( e_target.origin, 1, 1 );
		wait 1;
	}
}

hunt_uaz_spawn()
{
	s_spawnpt1 = getstruct( "truck_patrol_spawnpt1", "targetname" );
	vh_uaz = spawn_vehicle_from_targetname( "uaz_soviet" );
	vh_uaz.origin = s_spawnpt1.origin;
	vh_uaz.angles = s_spawnpt1.angles;
	vh_uaz.n_path = 1;
	vh_uaz.targetname = "arena_uaz";
	vh_uaz.dontfreeme = 1;
	s_uaz1_spawnpt = getstruct( "arena_uaz1_spawnpt", "targetname" );
	sp_soviet = getent( "soviet_assault", "targetname" );
	ai_soviet1 = sp_soviet spawn_ai( 1 );
	ai_soviet1 enter_vehicle( vh_uaz );
	wait 0,1;
	ai_soviet2 = sp_soviet spawn_ai( 1 );
	ai_soviet2 enter_vehicle( vh_uaz );
	vh_uaz thread hunt_uaz_behavior();
}

hunt_uaz_behavior()
{
	self endon( "death" );
	self setvehicleavoidance( 1, undefined, 2 );
	self setneargoalnotifydist( 400 );
	self makevehicleunusable();
	self veh_magic_bullet_shield( 1 );
	self setspeed( 30, 10, 5 );
	self pathfixedoffset( ( 0, 0, 0 ) );
	for ( ;; )
	{
		while ( 1 )
		{
			vh_trucks = getentarray( "arena_truck", "targetname" );
			if ( vh_trucks.size )
			{
				vh_truck_targets = sort_by_distance( vh_trucks, self.origin );
				e_target = vh_truck_targets[ 0 ];
				break;
			}
			else
			{
				wait 20;
			}
		}
		while ( isalive( e_target ) )
		{
			self setvehgoalpos( e_target.origin, 1, 1 );
			wait 1;
		}
	}
}

hunt_truck_spawn()
{
	s_spawnpt1 = getstruct( "truck_patrol_spawnpt1", "targetname" );
	vh_truck1 = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck1.origin = s_spawnpt1.origin;
	vh_truck1.angles = s_spawnpt1.angles;
	vh_truck1.n_path = 1;
	vh_truck1.targetname = "arena_truck";
	vh_truck1.dontfreeme = 1;
	ai_rider1 = get_muj_ai();
	ai_rider2 = get_muj_ai();
	if ( isDefined( ai_rider1 ) )
	{
		ai_rider1.script_startingposition = 0;
	}
	if ( isDefined( ai_rider2 ) )
	{
		ai_rider2.script_startingposition = 2;
		ai_rider2 thread magic_bullet_shield();
	}
	wait 0,05;
	if ( isDefined( ai_rider1 )vh_truck1 thread hunt_truck_behavior( ai_rider1, ai_rider2 );
}

hunt_truck_label()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		print3d( self.origin + vectorScale( ( 1, 0, 0 ), 60 ), "hunter truck" );
		wait 0,05;
#/
	}
}

hunt_truck_draw_target( e_target )
{
/#
	self endon( "death" );
	e_target endon( "death" );
	while ( isDefined( e_target ) )
	{
		line( self.origin, e_target.origin, ( 1, 0, 0 ) );
		wait 0,05;
#/
	}
}

hunt_truck_behavior( ai_rider1, ai_gunner )
{
	self endon( "death" );
	self setvehicleavoidance( 1, undefined, 1 );
	self setneargoalnotifydist( 400 );
	self makevehicleunusable();
	self veh_magic_bullet_shield();
	self setspeed( 30, 10, 5 );
	self pathfixedoffset( ( 0, 0, 0 ) );
	ai_rider1 enter_vehicle( self );
	ai_gunner enter_vehicle( self );
	wait 1;
	self thread truck_gunner( ai_gunner );
	while ( 1 )
	{
		a_targets = [];
		a_vehicles = getentarray( "script_vehicle", "classname" );
		_a654 = a_vehicles;
		_k654 = getFirstArrayKey( _a654 );
		while ( isDefined( _k654 ) )
		{
			e_veh = _a654[ _k654 ];
			if ( e_veh.vehicleclass == "helicopter" )
			{
				a_targets[ a_targets.size ] = e_veh;
			}
			_k654 = getNextArrayKey( _a654, _k654 );
		}
		if ( a_targets.size == 0 )
		{
		}
		if ( a_targets.size == 0 )
		{
			a_enemy_ais = getaiarray( "axis" );
			_a681 = a_enemy_ais;
			_k681 = getFirstArrayKey( _a681 );
			while ( isDefined( _k681 ) )
			{
				e_ai = _a681[ _k681 ];
				if ( !issubstr( e_ai.targetname, "drone" ) )
				{
					a_targets[ a_targets.size ] = e_ai;
				}
				_k681 = getNextArrayKey( _a681, _k681 );
			}
			a_targets = get_array_of_closest( self.origin, a_targets, undefined, 2 );
		}
		if ( a_targets.size > 0 )
		{
			e_target = a_targets[ 0 ];
			while ( isalive( e_target ) )
			{
				self setvehgoalpos( e_target.origin, 0, 2 );
				wait 0,25;
			}
		}
		else self setvehgoalpos( self.origin, 1 );
		wait 0,05;
	}
}

start_horse_patrollers()
{
	vh_horses = [];
	i = 0;
	while ( i < 4 )
	{
		s_spawnpt = getstruct( "horse_patrol_spawnpt1", "targetname" );
		if ( cointoss() )
		{
			s_spawnpt = getstruct( "horse_patrol_spawnpt2", "targetname" );
		}
		vh_horses[ i ] = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horses[ i ].origin = s_spawnpt.origin;
		vh_horses[ i ].angles = s_spawnpt.angles;
		vh_horses[ i ].targetname = "arena_horse";
		vh_horses[ i ] setvehicleavoidance( 1, undefined, 3 );
		sp_rider = getent( "horse_patroller", "targetname" );
		vh_horses[ i ] thread horse_patroller_behavior( undefined, s_spawnpt.targetname );
		wait randomfloatrange( 0,5, 1 );
		i++;
	}
}

monitor_arena_horse_death()
{
	self waittill( "death" );
	if ( !flag( "clear_arena" ) )
	{
		s_spawnpt = getstruct( "reinforcement_spawnpt", "targetname" );
		vh_horse = spawn_vehicle_from_targetname( "horse_afghan" );
		vh_horse.origin = s_spawnpt.origin;
		vh_horse.angles = s_spawnpt.angles;
		vh_horse.targetname = "arena_horse";
		sp_rider = getent( "horse_patroller", "targetname" );
		ai_rider = sp_rider spawn_ai( 1 );
		str_spawnpt = "horse_patrol_spawnpt1";
		if ( cointoss() )
		{
			str_spawnpt = "horse_patrol_spawnpt2";
		}
		vh_horse thread horse_patroller_behavior( ai_rider, str_spawnpt );
	}
}

horse_patroller_behavior( ai_rider, str_spawnpt )
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 400 );
	self makevehicleunusable();
	self thread monitor_arena_horse_death();
	self setspeed( 25, 20, 10 );
	n_offset = 0;
	if ( cointoss() )
	{
		n_offset += 50;
	}
	else
	{
		n_offset -= 50;
	}
	self pathfixedoffset( ( 0, n_offset, 0 ) );
	if ( str_spawnpt == "horse_patrol_spawnpt1" )
	{
		self thread horse_patrol_path_1();
	}
	else
	{
		self thread horse_patrol_path_2();
	}
}

choose_driveby_or_dismount( ai_rider )
{
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( ai_rider ) && isDefined( ai_rider.enemy ) && distance2dsquared( ai_rider.origin, ai_rider.enemy.origin ) < 1000000 )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	if ( randomint( 4 ) < 1 )
	{
		self setspeed( 0, 15, 10 );
		while ( self getspeed() > 0 )
		{
			wait 0,25;
		}
		if ( isalive( ai_rider ) )
		{
			ai_rider ai_dismount_horse( self );
			ai_rider set_fixednode( 0 );
			ai_rider thread muj_dismount_behavior();
		}
	}
	self setspeed( 25, 15, 10 );
}

muj_dismount_behavior()
{
	self endon( "death" );
	a_vol_caches = [];
	a_vol_caches[ 0 ] = getent( "vol_cache2", "targetname" );
	a_vol_caches[ 1 ] = getent( "vol_cache3", "targetname" );
	a_vol_caches[ 2 ] = getent( "vol_cache4", "targetname" );
	a_vol_caches[ 3 ] = getent( "vol_cache5", "targetname" );
	a_vol_caches[ 4 ] = getent( "vol_cache6", "targetname" );
	a_vol_caches[ 5 ] = getent( "vol_cache1", "targetname" );
	if ( isDefined( self.enemy ) )
	{
		self.goalradius = 64;
		self setgoalentity( self.enemy );
	}
	else
	{
		a_caches = [];
		a_caches = sort_by_distance( a_vol_caches, self.origin );
		self.goalradius = 64;
		self setgoalvolumeauto( a_caches[ a_caches.size - 1 ] );
	}
}

get_back_on_horse( vh_horse )
{
	self endon( "death" );
	while ( isDefined( self.enemy ) && distance2dsquared( self.origin, self.enemy.origin ) < 1000000 )
	{
		wait 1;
	}
	if ( isDefined( vh_horse ) )
	{
		self ai_mount_horse( vh_horse );
		wait 0,5;
		if ( isDefined( vh_horse ) )
		{
			vh_horse thread horse_choose_patrol_path();
		}
	}
}

monitor_rider( ai_rider )
{
	self endon( "death" );
	while ( isalive( ai_rider ) )
	{
		wait 1;
	}
	level.player waittill_player_not_looking_at( self.origin, undefined, 0 );
	while ( !isDefined( ai_rider ) )
	{
		ai_rider = get_muj_ai();
		if ( isDefined( ai_rider ) )
		{
			ai_rider enter_vehicle( self );
			wait 0,1;
			self notify( "groupedanimevent" );
			ai_rider maps/_horse_rider::ride_and_shoot( self );
		}
		wait 1;
	}
}

horse_patrol_path_1()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "horse_patrol_goal5", "targetname" );
	a_s_goal[ 1 ] = getstruct( "horse_patrol_goal4", "targetname" );
	a_s_goal[ 2 ] = getstruct( "horse_patrol_goal3", "targetname" );
	a_s_goal[ 3 ] = getstruct( "horse_patrol_goal2", "targetname" );
	a_s_goal[ 4 ] = getstruct( "horse_patrol_goal1", "targetname" );
	a_s_goal[ 5 ] = getstruct( "horse_patrol_goal6", "targetname" );
	a_s_goal[ 6 ] = getstruct( "horse_patrol_goal5", "targetname" );
	a_s_goal[ 7 ] = getstruct( "horse_patrol_goal4", "targetname" );
	a_s_goal[ 8 ] = getstruct( "horse_patrol_goal3", "targetname" );
	a_s_goal[ 9 ] = getstruct( "horse_patrol_goal2", "targetname" );
	self setspeed( 25, 15, 10 );
	i = 0;
	while ( i < a_s_goal.size )
	{
		if ( self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 ) )
		{
			self waittill( "near_goal" );
			i++;
			continue;
		}
		else
		{
			wait 1;
		}
		i++;
	}
	a_s_goal = undefined;
	self thread horse_choose_patrol_path();
}

horse_patrol_path_2()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "horse_patrol_goal11", "targetname" );
	a_s_goal[ 1 ] = getstruct( "horse_patrol_goal10", "targetname" );
	a_s_goal[ 2 ] = getstruct( "horse_patrol_goal9", "targetname" );
	a_s_goal[ 3 ] = getstruct( "horse_patrol_goal8", "targetname" );
	a_s_goal[ 4 ] = getstruct( "horse_patrol_goal7", "targetname" );
	a_s_goal[ 5 ] = getstruct( "horse_patrol_goal12", "targetname" );
	self setspeed( 25, 15, 10 );
	i = 0;
	while ( i < a_s_goal.size )
	{
		if ( self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 ) )
		{
			self waittill( "near_goal" );
			i++;
			continue;
		}
		else
		{
			wait 1;
		}
		i++;
	}
	a_s_goal = undefined;
	self thread horse_choose_patrol_path();
}

horse_patrol_path_3()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "horse_patrol_divert1", "targetname" );
	a_s_goal[ 1 ] = getstruct( "horse_patrol_divert2", "targetname" );
	a_s_goal[ 2 ] = getstruct( "horse_patrol_divert3", "targetname" );
	a_s_goal[ 3 ] = getstruct( "horse_patrol_divert4", "targetname" );
	a_s_goal[ 4 ] = getstruct( "horse_patrol_divert5", "targetname" );
	self setspeed( 25, 15, 10 );
	i = 0;
	while ( i < a_s_goal.size )
	{
		if ( self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 ) )
		{
			self waittill( "near_goal" );
			i++;
			continue;
		}
		else
		{
			wait 1;
		}
		i++;
	}
	a_s_goal = undefined;
	self thread horse_choose_patrol_path();
}

horse_choose_patrol_path()
{
	self endon( "death" );
	a_s_center = [];
	a_s_center[ 0 ] = getstruct( "horse_patrol1_center", "targetname" );
	a_s_center[ 1 ] = getstruct( "horse_patrol2_center", "targetname" );
	a_s_center[ 2 ] = getstruct( "horse_patrol3_center", "targetname" );
	a_s_points = sort_by_distance( a_s_center, level.player.origin );
	if ( cointoss() )
	{
		if ( a_s_points[ 2 ] == a_s_center[ 0 ] )
		{
			self thread horse_patrol_path_1();
		}
		else if ( a_s_points[ 2 ] == a_s_center[ 1 ] )
		{
			self thread horse_patrol_path_2();
		}
		else
		{
			self thread horse_patrol_path_3();
		}
	}
	else if ( randomint( 3 ) == 0 )
	{
		self thread horse_patrol_path_1();
	}
	else if ( randomint( 3 ) == 1 )
	{
		self thread horse_patrol_path_2();
	}
	else
	{
		self thread horse_patrol_path_3();
	}
	a_s_center = undefined;
	a_s_points = undefined;
}

truck_patrollers_bp1()
{
	s_spawnpt1 = getstruct( "truck_patrol_spawnpt1", "targetname" );
	vh_truck1 = spawn_vehicle_from_targetname( "truck_afghan" );
	vh_truck1.origin = s_spawnpt1.origin;
	vh_truck1.angles = s_spawnpt1.angles;
	vh_truck1.n_path = 1;
	vh_truck1.targetname = "arena_truck";
	vh_truck1.dontfreeme = 1;
	ai_rider1 = get_muj_ai();
	ai_rider2 = get_muj_ai();
	if ( isDefined( ai_rider1 ) )
	{
		ai_rider1.script_startingposition = 0;
	}
	if ( isDefined( ai_rider2 ) )
	{
		ai_rider2.script_startingposition = 2;
	}
	if ( isDefined( ai_rider1 ) && isDefined( ai_rider2 ) )
	{
		vh_truck1 thread truck_patroller_behavior( ai_rider1, ai_rider2 );
	}
	else
	{
		vh_truck1 thread truck_patroller_behavior();
	}
}

monitor_arena_truck_death()
{
	self waittill( "death" );
	self thread remove_vehicle_corpse();
	if ( !flag( "clear_arena" ) )
	{
		s_spawnpt = getstruct( "reinforcement_spawnpt", "targetname" );
		vh_truck1 = spawn_vehicle_from_targetname( "truck_afghan" );
		vh_truck1.origin = s_spawnpt.origin;
		vh_truck1.angles = s_spawnpt.angles;
		vh_truck1.targetname = "arena_truck";
		vh_truck1.n_path = 1;
		vh_truck1.dontfreeme = 1;
		sp_rider = getent( "horse_patroller", "targetname" );
		ai_rider1 = sp_rider spawn_ai( 1 );
		ai_gunner = sp_rider spawn_ai( 1 );
		if ( isDefined( ai_rider1 ) )
		{
			ai_rider1.script_startingposition = 0;
		}
		if ( isDefined( ai_gunner ) )
		{
			ai_gunner.script_startingposition = 2;
		}
		vh_truck1 thread truck_patroller_behavior( ai_rider1, ai_gunner );
	}
}

truck_patroller_behavior( ai_rider1, ai_gunner )
{
	self endon( "death" );
	self setvehicleavoidance( 1 );
	self setneargoalnotifydist( 400 );
	self makevehicleunusable();
	self thread monitor_arena_truck_death();
	self setspeed( 30, 10, 5 );
	n_offset = 0;
	if ( cointoss() )
	{
		n_offset += 50;
	}
	else
	{
		n_offset -= 50;
	}
	self pathfixedoffset( ( 0, n_offset, 0 ) );
	if ( isDefined( ai_rider1 ) )
	{
		ai_rider1 enter_vehicle( self );
	}
	if ( isDefined( ai_gunner ) )
	{
		ai_gunner enter_vehicle( self );
	}
	self thread truck_patrol_path_1();
	if ( isDefined( ai_gunner ) )
	{
		self thread truck_gunner( ai_gunner );
	}
}

truck_gunner( ai_gunner, e_target )
{
	self endon( "death" );
	if ( isDefined( e_target ) )
	{
		e_target endon( "death" );
	}
	self thread monitor_gunner( ai_gunner );
	while ( 1 )
	{
		a_targets = [];
		new_target = undefined;
		while ( isDefined( ai_gunner ) )
		{
			if ( !isDefined( new_target ) )
			{
				a_vehicles = getentarray( "script_vehicle", "classname" );
				_a1234 = a_vehicles;
				_k1234 = getFirstArrayKey( _a1234 );
				while ( isDefined( _k1234 ) )
				{
					e_veh = _a1234[ _k1234 ];
					if ( e_veh.vehicleclass == "helicopter" )
					{
						a_targets[ a_targets.size ] = e_veh;
					}
					_k1234 = getNextArrayKey( _a1234, _k1234 );
				}
				ai_enemies = getaiarray( "axis" );
				a_targets[ a_targets.size ] = e_veh;
				a_targets = sort_by_distance( a_targets, self.origin );
				new_target = a_targets[ 0 ];
			}
			while ( isDefined( new_target ) )
			{
				while ( isDefined( new_target ) && isalive( new_target ) )
				{
					a_v_offset = [];
					a_v_offset[ 0 ] = ( randomintrange( -300, 300 ), randomintrange( -300, 300 ), randomintrange( -300, 300 ) );
					a_v_offset[ 1 ] = ( randomintrange( -500, -300 ), 0, randomintrange( -500, -300 ) );
					a_v_offset[ 2 ] = ( 0, 0, randomintrange( -500, -300 ) );
					a_v_offset[ 3 ] = ( randomintrange( -500, -300 ), 0, randomintrange( -500, -300 ) );
					v_offset = a_v_offset[ randomint( 3 ) ];
					self set_turret_target( new_target, v_offset, 1 );
					self thread shoot_turret_at_target( new_target, randomfloatrange( 3, 5 ), v_offset, 1 );
					a_v_offset = undefined;
					wait 2;
				}
			}
		}
		wait 0,5;
	}
}

monitor_gunner( ai_gunner )
{
	self endon( "death" );
	while ( isalive( ai_gunner ) )
	{
		wait 0,1;
	}
	self stop_turret( 1, 1 );
	level.player waittill_player_not_looking_at( self.origin, undefined, 0 );
	while ( !isDefined( ai_gunner ) )
	{
		ai_gunner = get_muj_ai();
		ai_gunner.script_startingposition = 2;
		if ( isDefined( ai_gunner ) )
		{
			ai_gunner enter_vehicle( self );
		}
		wait 1;
	}
}

truck_patrol_path_1()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "truck_patrol_goal1", "targetname" );
	a_s_goal[ 1 ] = getstruct( "truck_patrol_goal2", "targetname" );
	a_s_goal[ 2 ] = getstruct( "truck_patrol_goal3", "targetname" );
	a_s_goal[ 3 ] = getstruct( "truck_patrol_goal4", "targetname" );
	a_s_goal[ 4 ] = getstruct( "truck_patrol_goal5", "targetname" );
	a_s_goal[ 5 ] = getstruct( "truck_patrol_goal6", "targetname" );
	a_s_goal[ 6 ] = getstruct( "truck_patrol_goal7", "targetname" );
	a_s_goal[ 7 ] = getstruct( "truck_patrol_goal8", "targetname" );
	a_s_goal[ 8 ] = getstruct( "truck_patrol_goal9", "targetname" );
	a_s_goal[ 9 ] = getstruct( "truck_patrol_goal10", "targetname" );
	a_s_goal[ 10 ] = getstruct( "truck_patrol_spawnpt1", "targetname" );
	i = 0;
	while ( i < a_s_goal.size )
	{
		self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		if ( i == 0 )
		{
			if ( cointoss() )
			{
				self thread truck_patrol_path_2();
				break;
			}
		}
		else if ( i == 3 )
		{
			if ( cointoss() )
			{
				self thread truck_patrol_path_3();
				break;
			}
		}
		else
		{
			i++;
		}
	}
	a_s_goal = undefined;
	self thread truck_patrol_path_1();
}

truck_patrol_path_2()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "truck_patrol2_goal1", "targetname" );
	a_s_goal[ 1 ] = getstruct( "truck_patrol2_goal2", "targetname" );
	a_s_goal[ 2 ] = getstruct( "truck_patrol2_goal3", "targetname" );
	a_s_goal[ 3 ] = getstruct( "truck_patrol2_goal4", "targetname" );
	a_s_goal[ 4 ] = getstruct( "truck_patrol_goal3", "targetname" );
	a_s_goal[ 5 ] = getstruct( "truck_patrol_goal4", "targetname" );
	a_s_goal[ 6 ] = getstruct( "truck_patrol_goal5", "targetname" );
	a_s_goal[ 7 ] = getstruct( "truck_patrol_goal6", "targetname" );
	a_s_goal[ 8 ] = getstruct( "truck_patrol_goal7", "targetname" );
	a_s_goal[ 9 ] = getstruct( "truck_patrol_goal8", "targetname" );
	a_s_goal[ 10 ] = getstruct( "truck_patrol_goal9", "targetname" );
	a_s_goal[ 11 ] = getstruct( "truck_patrol_goal10", "targetname" );
	a_s_goal[ 12 ] = getstruct( "truck_patrol_spawnpt1", "targetname" );
	i = 0;
	while ( i < a_s_goal.size )
	{
		self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		i++;
	}
	a_s_goal = undefined;
	self thread truck_patrol_path_1();
}

truck_patrol_path_3()
{
	self endon( "death" );
	a_s_goal = [];
	a_s_goal[ 0 ] = getstruct( "truck_patrol3_goal1", "targetname" );
	a_s_goal[ 1 ] = getstruct( "truck_patrol3_goal2", "targetname" );
	a_s_goal[ 2 ] = getstruct( "truck_patrol3_goal3", "targetname" );
	a_s_goal[ 3 ] = getstruct( "truck_patrol3_goal4", "targetname" );
	a_s_goal[ 4 ] = getstruct( "truck_patrol_goal8", "targetname" );
	a_s_goal[ 5 ] = getstruct( "truck_patrol_goal9", "targetname" );
	a_s_goal[ 6 ] = getstruct( "truck_patrol_goal10", "targetname" );
	a_s_goal[ 7 ] = getstruct( "truck_patrol_spawnpt1", "targetname" );
	i = 0;
	while ( i < a_s_goal.size )
	{
		self setvehgoalpos( a_s_goal[ i ].origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
		i++;
	}
	a_s_goal = undefined;
	self thread truck_patrol_path_1();
}

hips_arena_ambient()
{
	while ( !isDefined( level.player_location ) )
	{
		wait 1;
	}
	while ( level.player_location == "bp1" )
	{
		wait 1;
	}
	s_spawn = getstruct( "s_arena_hip1_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawn.origin;
	vh_hip.angles = s_spawn.angles;
	vh_hip.targetname = "arena_hip_rappel";
	vh_hip thread hip1_arena_behavior();
	wait 4;
	s_spawn = getstruct( "s_arena_hip2_spawnpt", "targetname" );
	vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
	vh_hip.origin = s_spawn.origin;
	vh_hip.angles = s_spawn.angles;
	vh_hip.targetname = "arena_hip_rappel";
	vh_hip thread hip2_arena_behavior();
}

cleanup_ambient_hips()
{
	level notify( "end_ambient_hips" );
	a_vh_hips = getentarray( "arena_hip_rappel", "targetname" );
	while ( a_vh_hips.size )
	{
		i = a_vh_hips.size - 1;
		while ( i >= 0 )
		{
			a_vh_hips[ i ].delete_on_death = 1;
			a_vh_hips[ i ] notify( "death" );
			if ( !isalive( a_vh_hips[ i ] ) )
			{
				a_vh_hips[ i ] delete();
			}
			i--;

		}
	}
}

ambient_hip1_death()
{
	level endon( "end_ambient_hips" );
	self waittill( "death" );
	wait randomfloatrange( 7, 10 );
	if ( !flag( "clear_arena" ) )
	{
		s_spawn1 = getstruct( "s_arena_hip1_spawnpt", "targetname" );
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_spawn1.origin;
		vh_hip.angles = s_spawn1.angles;
		vh_hip.targetname = "arena_hip_rappel";
		vh_hip thread hip1_arena_behavior();
	}
}

ambient_hip2_death()
{
	level endon( "end_ambient_hips" );
	self waittill( "death" );
	wait randomfloatrange( 7, 10 );
	if ( !isDefined( level.player_location ) || level.player_location == "bp1" )
	{
		wait 1;
	}
	if ( !flag( "clear_arena" ) )
	{
		s_spawn1 = getstruct( "s_arena_hip2_spawnpt", "targetname" );
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_spawn1.origin;
		vh_hip.angles = s_spawn1.angles;
		vh_hip.targetname = "arena_hip_rappel";
		vh_hip thread hip2_arena_behavior();
	}
}

ambient_hip_arena_death()
{
	self waittill( "death" );
	wait randomfloatrange( 7, 10 );
	if ( !isDefined( level.player_location ) || level.player_location == "bp1" )
	{
		wait 1;
	}
	if ( !flag( "clear_arena" ) )
	{
		s_spawn1 = getstruct( "s_arena_hip1_spawnpt", "targetname" );
		vh_hip = spawn_vehicle_from_targetname( "hip_soviet" );
		vh_hip.origin = s_spawn1.origin;
		vh_hip.angles = s_spawn1.angles;
		vh_hip thread hip_ambient_arena_behavior();
	}
}

hip1_arena_behavior()
{
	self endon( "death" );
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	self thread heli_select_death();
	self thread ambient_hip1_death();
	a_s_goal = [];
	i = 1;
	while ( i < 9 )
	{
		a_s_goal[ i ] = getstruct( "s_arena_hip1_goal" + i, "targetname" );
		i++;
	}
	sp_rappel = getent( "ambient_troops1", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 100, 25, 10 );
	i = 1;
	while ( 1 )
	{
		self setvehgoalpos( a_s_goal[ i ].origin );
		self waittill_any( "goal", "near_goal" );
		if ( flag( "clear_arena" ) )
		{
			self kill_arena_vehicle();
		}
		if ( randomint( 4 ) > 1 )
		{
			if ( i != 2 && i == 4 && !flag( "hip1_rappellers" ) )
			{
				self setspeed( 25, 20, 15 );
				if ( i == 2 )
				{
					s_drop_pt = "ambient_hip1_cache6";
					a_vol_caches = [];
					a_vol_caches[ 0 ] = getent( "vol_cache2", "targetname" );
					a_vol_caches[ 1 ] = getent( "vol_cache5", "targetname" );
					a_vol_caches[ 2 ] = getent( "vol_cache6", "targetname" );
					a_vol_caches[ 3 ] = getent( "vol_cache1", "targetname" );
					a_caches = [];
					a_caches = sort_by_distance( a_vol_caches, level.player.origin );
					vol_cache = a_caches[ a_caches.size - 1 ];
					a_vol_caches = undefined;
					a_caches = undefined;
				}
				else
				{
					if ( i == 4 )
					{
						s_drop_pt = "ambient_hip1_cache4";
						a_vol_caches = [];
						a_vol_caches[ 0 ] = getent( "vol_cache3", "targetname" );
						a_vol_caches[ 1 ] = getent( "vol_cache4", "targetname" );
						a_vol_caches[ 2 ] = getent( "vol_cache5", "targetname" );
						a_caches = [];
						a_caches = sort_by_distance( a_vol_caches, level.player.origin );
						vol_cache = a_caches[ a_caches.size - 1 ];
						a_vol_caches = undefined;
						a_caches = undefined;
					}
				}
				ambient_rappel( sp_rappel, s_drop_pt );
				flag_set( "hip1_rappellers" );
				level thread monitor_ambient_rapellers( sp_rappel, "hip1_rappellers", vol_cache );
				self setspeed( 100, 25, 10 );
			}
		}
		i++;
		if ( i == 9 )
		{
			i = 2;
		}
	}
}

hip2_arena_behavior()
{
	self endon( "death" );
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	self thread ambient_hip2_death();
	self thread heli_select_death();
	a_s_goal = [];
	i = 1;
	while ( i < 15 )
	{
		a_s_goal[ i ] = getstruct( "s_arena_hip2_goal" + i, "targetname" );
		i++;
	}
	sp_rappel = getent( "ambient_troops2", "targetname" );
	self setneargoalnotifydist( 500 );
	self setspeed( 80, 25, 10 );
	i = 1;
	while ( 1 )
	{
		self setvehgoalpos( a_s_goal[ i ].origin );
		self waittill_any( "goal", "near_goal" );
		if ( flag( "clear_arena" ) )
		{
			self kill_arena_vehicle();
		}
		if ( i != 6 && i != 8 && i == 12 && !flag( "hip2_rappellers" ) )
		{
			if ( randomint( 4 ) > 1 )
			{
				if ( i == 6 )
				{
					s_drop_pt = "ambient_hip_dropoff6";
					a_vol_caches = [];
					a_vol_caches[ 0 ] = getent( "vol_cache2", "targetname" );
					a_vol_caches[ 1 ] = getent( "vol_cache3", "targetname" );
					vol_cache = a_vol_caches[ randomint( a_vol_caches.size ) ];
				}
				else if ( i == 8 )
				{
					s_drop_pt = "ambient_hip_dropoff8";
					a_vol_caches = [];
					a_vol_caches[ 0 ] = getent( "vol_cache2", "targetname" );
					a_vol_caches[ 1 ] = getent( "vol_cache3", "targetname" );
					a_vol_caches[ 2 ] = getent( "vol_cache4", "targetname" );
					a_vol_caches[ 3 ] = getent( "vol_cache5", "targetname" );
					a_vol_caches[ 4 ] = getent( "vol_cache6", "targetname" );
					a_vol_caches[ 5 ] = getent( "vol_cache1", "targetname" );
					a_caches = [];
					a_caches = sort_by_distance( a_vol_caches, level.player.origin );
					vol_cache = a_caches[ a_caches.size - 1 ];
					a_vol_caches = undefined;
					a_caches = undefined;
				}
				else
				{
					s_drop_pt = "ambient_hip_dropoff12";
					a_vol_caches = [];
					a_vol_caches[ 0 ] = getent( "vol_cache2", "targetname" );
					a_vol_caches[ 1 ] = getent( "vol_cache3", "targetname" );
					a_vol_caches[ 2 ] = getent( "vol_cache5", "targetname" );
					a_caches = [];
					a_caches = sort_by_distance( a_vol_caches, level.player.origin );
					vol_cache = a_caches[ a_caches.size - 1 ];
					a_vol_caches = undefined;
					a_caches = undefined;
				}
				ambient_rappel( sp_rappel, s_drop_pt );
				flag_set( "hip2_rappellers" );
				level thread monitor_ambient_rapellers( sp_rappel, "hip2_rappellers", vol_cache );
				self setspeed( 80, 25, 10 );
			}
		}
		i++;
		if ( i > 14 )
		{
			i = 5;
		}
	}
}

hip_ambient_arena_behavior()
{
	self endon( "death" );
	target_set( self, ( -50, 0, -32 ) );
	self setforcenocull();
	self hidepart( "tag_back_door" );
	self thread heli_select_death();
	self thread ambient_hip_arena_death();
	a_s_goal = [];
	i = 2;
	while ( i < 9 )
	{
		a_s_goal[ i ] = getstruct( "s_arena_hip_ambient_goal" + i, "targetname" );
		i++;
	}
	self setneargoalnotifydist( 500 );
	self setspeed( 50, 25, 10 );
	i = 2;
	while ( 1 )
	{
		self setvehgoalpos( a_s_goal[ i ].origin );
		self waittill_any( "goal", "near_goal" );
		if ( flag( "clear_arena" ) )
		{
			self kill_arena_vehicle();
		}
		i++;
		if ( i == 9 )
		{
			i = 2;
		}
	}
}

monitor_ambient_rapellers( sp_rappel, str_rappel, vol_cache )
{
	a_ai_rappellers = getentarray( sp_rappel.targetname + "_ai", "targetname" );
	_a1800 = a_ai_rappellers;
	_k1800 = getFirstArrayKey( _a1800 );
	while ( isDefined( _k1800 ) )
	{
		ai_guy = _a1800[ _k1800 ];
		if ( isalive( ai_guy ) )
		{
			ai_guy.goalradius = 64;
			ai_guy.arena_guy = 1;
			ai_guy setgoalvolumeauto( vol_cache );
			wait randomfloatrange( 0,3, 1,5 );
		}
		_k1800 = getNextArrayKey( _a1800, _k1800 );
	}
	while ( 1 )
	{
		a_ai_rappellers = getentarray( sp_rappel.targetname + "_ai", "targetname" );
		if ( !a_ai_rappellers.size )
		{
			flag_clear( str_rappel );
			return;
		}
		else
		{
			while ( flag( "clear_arena" ) || flag( "bp_underway" ) )
			{
				_a1824 = a_ai_rappellers;
				_k1824 = getFirstArrayKey( _a1824 );
				while ( isDefined( _k1824 ) )
				{
					ai_guy = _a1824[ _k1824 ];
					if ( isalive( ai_guy ) )
					{
						ai_guy die();
					}
					_k1824 = getNextArrayKey( _a1824, _k1824 );
				}
				a_ai_muj = getentarray( "horse_patroller_ai", "targetname" );
				_a1834 = a_ai_muj;
				_k1834 = getFirstArrayKey( _a1834 );
				while ( isDefined( _k1834 ) )
				{
					ai_muj = _a1834[ _k1834 ];
					if ( isalive( ai_muj ) )
					{
						ai_muj die();
					}
					_k1834 = getNextArrayKey( _a1834, _k1834 );
				}
			}
			wait 1;
		}
	}
}

kill_arena_vehicle()
{
	self endon( "death" );
	wait randomfloat( 2 );
	radiusdamage( self.origin, 100, self.health, self.health );
}

cleanup_arena_horse()
{
	a_vh_horses = getentarray( "arena_horse", "targetname" );
	while ( a_vh_horses.size )
	{
		i = a_vh_horses.size - 1;
		while ( i >= 0 )
		{
			if ( isalive( a_vh_horses[ i ] ) )
			{
				a_vh_horses[ i ].delete_on_death = 1;
				a_vh_horses[ i ] notify( "death" );
				if ( !isalive( a_vh_horses[ i ] ) )
				{
					a_vh_horses[ i ] delete();
				}
			}
			i--;

		}
	}
}

cleanup_arena()
{
	level notify( "stop_guns_base" );
	level notify( "stop_stingers_base" );
	level notify( "stop_sandbox" );
	flag_set( "clear_arena" );
	flag_set( "stop_arena_explosions" );
	spawn_manager_disable( "manager_bp3wave2_soviet" );
	spawn_manager_disable( "manager_assault_soviet" );
	spawn_manager_disable( "manager_bp3_foot" );
	if ( !flag( "bridge3_destroyed" ) )
	{
		spawn_manager_disable( "manager_upper_bridge", 1 );
	}
	if ( !flag( "bridge4_destroyed" ) )
	{
		spawn_manager_disable( "manager_assaultcrew_bp3", 1 );
	}
	a_muj_guys = getaiarray( "allies" );
	_a1897 = a_muj_guys;
	_k1897 = getFirstArrayKey( _a1897 );
	while ( isDefined( _k1897 ) )
	{
		guy = _a1897[ _k1897 ];
		if ( isDefined( guy.arena_guy ) )
		{
			guy delete();
		}
		_k1897 = getNextArrayKey( _a1897, _k1897 );
	}
	a_bad_guys = getaiarray( "axis" );
	_a1907 = a_bad_guys;
	_k1907 = getFirstArrayKey( _a1907 );
	while ( isDefined( _k1907 ) )
	{
		guy = _a1907[ _k1907 ];
		if ( !isDefined( guy.no_cleanup ) && !isDefined( guy.bp_ai ) )
		{
			guy delete();
		}
		_k1907 = getNextArrayKey( _a1907, _k1907 );
	}
	a_vh_hips = getentarray( "arena_hip", "targetname" );
	while ( a_vh_hips.size )
	{
		i = a_vh_hips.size - 1;
		while ( i >= 0 )
		{
			if ( isDefined( a_vh_hips[ i ] ) )
			{
				a_vh_hips[ i ] thread kill_arena_vehicle();
			}
			i--;

		}
	}
	level thread cleanup_arena_horse();
	a_drones = getentarray( "drone", "targetname" );
	_a1948 = a_drones;
	_k1948 = getFirstArrayKey( _a1948 );
	while ( isDefined( _k1948 ) )
	{
		e_drone = _a1948[ _k1948 ];
		e_drone maps/_drones_aipath::drone_delete();
		_k1948 = getNextArrayKey( _a1948, _k1948 );
	}
}

arena_explosions()
{
	level endon( "clear_arena" );
	level endon( "stop_arena_explosions" );
	a_s_explosions = getstructarray( "arena_explosion_pos", "script_noteworthy" );
	a_s_explosion_in_view = [];
	n_count = 0;
	for ( ;; )
	{
		while ( 1 )
		{
			while ( isDefined( level.player_location ) && level.player_location != "arena" )
			{
				level waittill( "player_moved" );
				wait 0,05;
			}
			_a1979 = a_s_explosions;
			_k1979 = getFirstArrayKey( _a1979 );
			while ( isDefined( _k1979 ) )
			{
				s_explosion = _a1979[ _k1979 ];
				if ( level.player is_player_looking_at( s_explosion.origin, 0,6, 1 ) )
				{
					a_s_explosion_in_view[ a_s_explosion_in_view.size ] = s_explosion;
				}
				_k1979 = getNextArrayKey( _a1979, _k1979 );
			}
			if ( !a_s_explosion_in_view.size )
			{
				wait 0,3;
			}
		}
		else if ( a_s_explosion_in_view.size == 1 )
		{
			s_explosion = a_s_explosion_in_view[ 0 ];
		}
		else
		{
			s_explosion = a_s_explosion_in_view[ randomint( a_s_explosion_in_view.size ) ];
		}
		vec_explosion_origin = s_explosion.origin;
		vec_explosion_offset = ( randomintrange( -200, 200 ), randomintrange( -200, 200 ), 0 );
		vec_explosion_origin += vec_explosion_offset;
		playsoundatposition( "prj_mortar_launch", ( -3127, -36443, 3469 ) );
		wait 1;
		drop_a_mortar( vec_explosion_origin );
		if ( n_count > 3 )
		{
			wait randomfloatrange( 2, 4 );
			n_count = 0;
		}
		else
		{
			n_count++;
			wait randomfloatrange( 0,1, 0,2 );
		}
		a_s_explosion_in_view = [];
	}
}

drop_a_mortar( vec_explosion_origin, b_drones, no_delay, b_do_damage )
{
	if ( !isDefined( b_drones ) )
	{
		b_drones = undefined;
	}
	if ( !isDefined( no_delay ) )
	{
		no_delay = 0;
	}
	if ( !isDefined( b_do_damage ) )
	{
		b_do_damage = 1;
	}
	if ( !no_delay )
	{
		playsoundatposition( "prj_mortar_incoming", vec_explosion_origin );
		wait 0,45;
	}
	playsoundatposition( "exp_mortar", vec_explosion_origin );
	playfx( level._effect[ "explode_mortar_sand_short" ], vec_explosion_origin );
	if ( b_do_damage )
	{
		level thread check_explosion_radius( vec_explosion_origin, b_drones );
	}
	earthquake( 0,2, 1, level.player.origin, 100 );
}

check_explosion_radius( v_pos, b_drones )
{
	if ( !isDefined( b_drones ) )
	{
		b_drones = undefined;
	}
	a_ai_allies = getaiarray( "allies" );
	a_ai_riders = array_exclude( a_ai_allies, level.woods );
	a_ai_muj = array_exclude( a_ai_riders, level.zhao );
	if ( isDefined( b_drones ) && b_drones )
	{
		a_drones = getentarray( "drone", "targetname" );
		if ( a_drones.size )
		{
			a_ai_muj = arraycombine( a_ai_muj, a_drones, 0, 0 );
		}
	}
	_a2075 = a_ai_muj;
	_k2075 = getFirstArrayKey( _a2075 );
	while ( isDefined( _k2075 ) )
	{
		ai_rider = _a2075[ _k2075 ];
		if ( isDefined( ai_rider ) )
		{
			if ( distance2dsquared( v_pos, ai_rider.origin ) < 160000 )
			{
				radiusdamage( ai_rider.origin, 50, 5000, 5000, ai_rider );
				ai_rider dodamage( 200, v_pos, ai_rider, undefined, "grenadesplash" );
			}
		}
		_k2075 = getNextArrayKey( _a2075, _k2075 );
	}
	a_ai_allies = undefined;
	a_ai_riders = undefined;
	a_ai_muj = undefined;
}

woods_to_bp1()
{
	s_woods_bp1 = getstruct( "woods_bp1wave3_goal", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.woods ai_mount_horse( self );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_woods_bp1.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
/#
	iprintln( "woods at bp1" );
#/
}

woods_to_bp2()
{
	s_woods_bp2 = getstruct( "woods_bp2", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.woods ai_mount_horse( self );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_woods_bp2.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
/#
	iprintln( "woods at bp2" );
#/
	self thread maps/afghanistan_wave_2::woods_circle_bp2();
}

woods_to_bp3()
{
	s_woods_bp3 = getstruct( "woods_bp3", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.woods ai_mount_horse( self );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_woods_bp3.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
/#
	iprintln( "woods at bp3" );
#/
}

send_woods_to_bp( blocking_point )
{
	switch( blocking_point )
	{
		case 1:
			level.woods_horse thread woods_to_bp1();
			break;
		case 2:
			level.woods_horse thread woods_to_bp2();
			break;
		case 3:
			level.woods_horse thread woods_to_bp3();
			break;
		default:
		}
	}
}

vo_woods_to_bp()
{
	level.woods.a_vo_goto_bp = array( "wood_gotta_stop_them_mas_0", "wood_take_em_down_before_0", "wood_zhao_needs_our_help_0" );
	vo_line_chosen = random( level.woods.a_vo_goto_bp );
	arrayremovevalue( level.woods.a_vo_goto_bp, vo_line_chosen );
	level.woods say_dialog( vo_line_chosen );
	level.woods say_dialog( "wood_the_muj_need_our_hel_0" );
}

vo_zhao_to_bp()
{
	level.zhao.a_vo_goto_bp = array( "zhao_i_will_assist_the_mu_0", "zhao_i_will_defend_the_ne_0", "zhao_i_am_moving_to_suppo_0", "zhao_i_will_ensure_the_ch_0", "zhao_i_m_heading_to_the_c_0", "zhao_i_will_head_to_the_n_0" );
	vo_line_chosen = random( level.zhao.a_vo_goto_bp );
	arrayremovevalue( level.zhao.a_vo_goto_bp, vo_line_chosen );
	level.zhao say_dialog( vo_line_chosen );
}

send_zhao_to_bp( blocking_point )
{
	switch( blocking_point )
	{
		case 1:
			break;
		case 2:
			level.zhao_horse thread zhao_to_bp2();
			level.zhao_horse thread watch_for_stuck_spot( ::zhao_to_bp2 );
			break;
		case 3:
			level.zhao_horse thread zhao_to_bp3();
			level.zhao_horse thread watch_for_stuck_spot( ::zhao_to_bp3 );
			break;
		default:
		}
	}
}

watch_for_stuck_spot( goto_func )
{
	self endon( "reached_blocking_point" );
	self waittill( "veh_stuck" );
	goal_structs = [];
	goal_structs[ 0 ] = getstruct( "zhao_bp1wave3_goal", "targetname" );
	goal_structs[ 1 ] = getstruct( "zhao_bp2", "targetname" );
	goal_structs[ 2 ] = getstruct( "zhao_bp3", "targetname" );
	closest_struct = get_array_of_closest( self.origin, goal_structs )[ 0 ];
	self.origin = closest_struct.origin;
	self thread [[ goto_func ]]();
	self thread watch_for_stuck_spot( goto_func );
}

zhao_to_bp1()
{
	self endon( "veh_stuck" );
	s_zhao_bp1 = getstruct( "zhao_bp1wave3_goal", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.zhao ai_mount_horse( self );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_zhao_bp1.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self horse_stop();
	self notify( "reached_blocking_point" );
/#
	iprintln( "zhao at bp1" );
#/
}

zhao_to_bp2()
{
	self endon( "veh_stuck" );
	self setvehicleavoidance( 0 );
	s_zhao_bp2 = getstruct( "zhao_bp2", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.zhao ai_mount_horse( self, 1 );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_zhao_bp2.origin, 0, 2 );
	self thread horse_reverse_tether( s_zhao_bp2.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehicleavoidance( 1, 2 );
	self horse_stop();
	self notify( "reached_blocking_point" );
/#
	iprintln( "zhao at bp2" );
#/
	self thread maps/afghanistan_wave_2::zhao_circle_bp2();
}

zhao_to_bp3()
{
	self endon( "veh_stuck" );
	self setvehicleavoidance( 0 );
	s_zhao_bp3 = getstruct( "zhao_bp3", "targetname" );
	if ( !isDefined( self get_driver() ) )
	{
		level.zhao ai_mount_horse( self, 1 );
		wait 1;
	}
	self setbrake( 0 );
	self setspeed( 25, 15, 10 );
	self setvehgoalpos( s_zhao_bp3.origin, 0, 2 );
	self thread horse_reverse_tether( s_zhao_bp3.origin, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehicleavoidance( 1, 2 );
	self horse_stop();
	self notify( "reached_blocking_point" );
/#
	iprintln( "zhao at bp3" );
#/
	self thread maps/afghanistan_wave_2::zhao_bp3();
}

horse_reverse_tether( goal_origin, end_on_goal )
{
	if ( !isDefined( end_on_goal ) )
	{
		end_on_goal = 0;
	}
	if ( end_on_goal )
	{
		self endon( "goal" );
		self endon( "near_goal" );
	}
	else
	{
		self endon( "stop_horse_tether" );
	}
	while ( 1 )
	{
		while ( !isDefined( level.player.my_horse ) )
		{
			wait 0,05;
		}
		speed_zhao_up = abs( distancesquared( level.zhao.origin, goal_origin ) ) < abs( distancesquared( level.player.origin, goal_origin ) );
		if ( !speed_zhao_up )
		{
			if ( level.zhao is_behind( level.player.origin ) && distance2dsquared( level.zhao.origin, level.player.origin ) < 244 )
			{
				speed_zhao_up = 1;
			}
		}
		if ( speed_zhao_up )
		{
			players_speed = level.player.my_horse getspeedmph();
			if ( players_speed > 0 && players_speed > self getspeedmph() )
			{
				n_new_speed = players_speed + 0,5;
				self setvehmaxspeed( n_new_speed * 17,6 );
				self setspeed( n_new_speed, 25 );
				break;
			}
			else
			{
				if ( self getspeedmph() <= 25 )
				{
					self setspeed( 25 );
				}
			}
		}
		wait 0,05;
	}
}

woods_toggle_follow_behavior()
{
	level notify( "only_one_woods_follow_behavior_thread" );
	level endon( "stop_sandbox" );
	level endon( "fight_in_bp" );
	level endon( "only_one_woods_follow_behavior_thread" );
	flag_waitopen( "woods_getting_off_horse" );
	level notify( "woods_ride_with_player" );
	level.woods ai_mount_horse( level.woods_horse, 1 );
	wait 1;
	level.woods_horse setbrake( 0 );
	level.woods_horse setspeed( 35, 25, 10 );
	level thread woods_toggle_fight_in_bp();
	while ( 1 )
	{
		if ( isDefined( self.is_on_horse ) && self.is_on_horse )
		{
		}
		else
		{
			self waittill( "enter_vehicle", e_vehicle );
			if ( e_vehicle.vehicletype != "horse_player" && e_vehicle.vehicletype != "horse" )
			{
				continue;
			}
		}
		level.woods thread woods_ride_with_player();
		self waittill( "exit_vehicle" );
		level.woods notify( "stop_riding_with_player" );
	}
}

woods_toggle_fight_in_bp( current_player_location )
{
	if ( !isDefined( current_player_location ) )
	{
		current_player_location = undefined;
	}
	level notify( "only_one_fight_in_bp_tracking_thread" );
	level endon( "stop_sandbox" );
	level endon( "only_one_fight_in_bp_tracking_thread" );
	while ( 1 )
	{
		while ( !isDefined( level.player_location ) && !issubstr( level.player_location, "bp" ) )
		{
			wait 0,05;
		}
		wait 2;
		if ( level.player_location != "bp1" && level.player_location != "arena" )
		{
			current_location = level.player_location;
			level notify( "fight_in_bp" );
			if ( level.player_location == "bp2" )
			{
				level.woods_horse thread woods_circle_bp2();
			}
			else
			{
				if ( level.player_location == "bp3" )
				{
					level.woods_horse thread woods_bp3();
				}
			}
			while ( level.player_location == current_location )
			{
				wait 0,05;
			}
			flag_waitopen( "woods_getting_off_horse" );
			level.player thread woods_toggle_follow_behavior();
			continue;
		}
		else
		{
			wait 0,05;
		}
	}
}

woods_ride_with_player()
{
	self endon( "stop_riding_with_player" );
	level endon( "stop_sandbox" );
	level endon( "fight_in_bp" );
	num_frames_woods_leading = 0;
	num_frames_woods_behind = 0;
	prev_player_horse_forward = ( anglesToForward( level.player.my_horse.angles )[ 0 ], anglesToForward( level.player.my_horse.angles )[ 1 ], 0 );
	while ( 1 )
	{
		while ( isDefined( level.player_location ) || issubstr( level.player_location, "bp" ) && !isDefined( level.player.my_horse ) )
		{
			wait 0,05;
		}
		vec_player_horse_forward = ( anglesToForward( level.player.my_horse.angles )[ 0 ], anglesToForward( level.player.my_horse.angles )[ 1 ], 0 );
		vec_player_horse_right = anglesToRight( level.player.my_horse.angles );
		vec_player_look_forward = ( anglesToForward( level.player.angles )[ 0 ], anglesToForward( level.player.angles )[ 1 ], 0 );
		vec_player_look_right = anglesToRight( level.player.angles );
		if ( vectordot( vec_player_horse_forward, vec_player_look_forward ) < 0,7 )
		{
			vec_player_horse_forward = vec_player_look_forward;
			vec_player_horse_right = vec_player_look_right;
		}
		b_woods_on_right = 1;
		if ( vectordot( level.woods_horse.origin - level.player.my_horse.origin, vec_player_horse_right ) < 0 )
		{
			b_woods_on_right = 0;
		}
		num_distance = distance2d( level.player.my_horse.origin, level.woods_horse.origin );
		current_offset = 152;
		if ( num_distance < 600 )
		{
			current_offset = ( 152 * num_distance ) / 600;
			if ( current_offset < 96 )
			{
				current_offset = 96;
			}
		}
		if ( vectordot( prev_player_horse_forward, vec_player_horse_forward ) < 0,93 )
		{
			prev_player_horse_forward = vec_player_horse_forward;
		}
		while ( level.player.my_horse getspeedmph() < 2 )
		{
			wait 0,15;
		}
		if ( b_woods_on_right )
		{
			vec_woods_goal = ( level.player.origin + ( prev_player_horse_forward * 600 ) ) + ( vec_player_horse_right * current_offset );
		}
		else
		{
			vec_woods_goal = ( level.player.origin + ( prev_player_horse_forward * 600 ) ) - ( vec_player_horse_right * current_offset );
		}
		a_vehicles = getentarray( "script_vehicle", "classname" );
		while ( a_vehicles.size > 0 )
		{
			b_abort_from_vehicle = 0;
			a_close_vehicles = get_array_of_closest( vec_woods_goal, a_vehicles, undefined, undefined, 360 );
			_a2582 = a_vehicles;
			_k2582 = getFirstArrayKey( _a2582 );
			while ( isDefined( _k2582 ) )
			{
				e_vehicle = _a2582[ _k2582 ];
				if ( isDefined( e_vehicle.team ) && e_vehicle.team == "axis" && distancesquared( vec_woods_goal, e_vehicle.origin ) < 129600 )
				{
					b_abort_from_vehicle = 1;
				}
				_k2582 = getNextArrayKey( _a2582, _k2582 );
			}
			while ( b_abort_from_vehicle )
			{
				wait 0,15;
			}
		}
		b_able_to_path = 0;
		if ( level.player.my_horse getspeedmph() < 5 && level.woods_horse is_behind( level.player.my_horse.origin ) )
		{
			b_able_to_path = level.woods_horse setvehgoalpos( vec_woods_goal, 1, 2 );
		}
		else
		{
			b_able_to_path = level.woods_horse setvehgoalpos( vec_woods_goal, 0, 2 );
		}
		if ( !b_able_to_path )
		{
			a_pathnodes = getnodesinradiussorted( vec_woods_goal, 1000, 0, 1000, "Path" );
			if ( a_pathnodes.size > 0 )
			{
				b_able_to_path = level.woods_horse setvehgoalpos( a_pathnodes[ 0 ].origin, 1, 2 );
			}
			if ( !b_able_to_path && a_pathnodes.size > 0 )
			{
				b_able_to_path = level.woods_horse setvehgoalpos( a_pathnodes[ 0 ].origin, 1, 1 );
			}
		}
		while ( !b_able_to_path )
		{
			wait 0,15;
		}
		if ( level.player.my_horse is_behind( level.woods_horse.origin ) )
		{
			level.woods_horse setvehmaxspeed( ( level.player.my_horse getmaxspeed() / 17,6 ) + 20 );
			player_max_speed = level.player.my_horse getmaxspeed() / 17,6;
			player_speed = level.player.my_horse getspeedmph();
			woods_speed = 0;
			num_frames_woods_leading = 0;
			num_frames_woods_behind++;
			if ( num_frames_woods_behind > 20 )
			{
				if ( player_speed < 0 )
				{
					woods_speed = level.woods_horse getmaxspeed() / 17,6;
				}
				else if ( ( player_speed / player_max_speed ) < 0,5 )
				{
					woods_speed = player_speed + 10;
				}
				else
				{
					woods_speed = player_max_speed + 10;
				}
				level.woods_horse setspeed( player_max_speed + 1, 25 );
			}
			else
			{
				level.woods_horse setvehmaxspeed( ( level.player.my_horse getmaxspeed() / 17,6 ) - 0,1 );
			}
		}
		else
		{
			num_frames_woods_leading++;
			num_frames_woods_behind = 0;
			if ( num_frames_woods_leading > 90 )
			{
				level.woods_horse setvehmaxspeed( ( level.player.my_horse getmaxspeed() / 17,6 ) - 2 );
			}
		}
		wait 0,05;
	}
}

horse_stalk_player()
{
	self endon( "death" );
	self endon( "horse_stop_stalking_player" );
	self setvehicleavoidance( 1, undefined, 10 );
	while ( 1 )
	{
		if ( isDefined( level.player_location ) && !issubstr( level.player_location, "bp" ) )
		{
			if ( distance2d( self.origin, level.player.origin ) > 500 )
			{
				self setvehgoalpos( level.player.origin, 1, 1 );
			}
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

horse_toggle_follow_behavior()
{
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		if ( !isDefined( level.player.is_on_horse ) || !level.player.is_on_horse )
		{
		}
		else
		{
			level.player waittill( "exit_vehicle", e_vehicle );
			if ( e_vehicle.vehicletype != "horse_player" && e_vehicle.vehicletype != "horse" )
			{
				continue;
			}
		}
		level thread horse_watch_use_objective();
		self thread horse_stalk_player();
		level.player waittill( "enter_vehicle" );
		self notify( "horse_stop_stalking_player" );
	}
}

horse_watch_use_objective()
{
	level endon( "stop_sandbox" );
	level.player endon( "enter_vehicle" );
	wait 20;
	flag_waitopen( "bp3_infantry_event" );
	set_objective( level.obj_horse, level.mason_horse, &"AFGHANISTAN_OBJ_RIDE" );
	objective_setflag( level.obj_horse, "fadeoutonscreen", 0 );
	level thread clear_horse_objective_on_enter();
	level thread clear_horse_objective_on_end_of_event();
	level thread clear_horse_objective_on_bp3_event();
}

clear_horse_objective_on_enter()
{
	level endon( "bp3_infantry_event" );
	level endon( "stop_sandbox" );
	level.player waittill( "enter_vehicle" );
	set_objective( level.obj_horse, level.mason_horse, "remove" );
}

clear_horse_objective_on_end_of_event()
{
	level endon( "bp3_infantry_event" );
	level.player endon( "enter_vehicle" );
	level waittill( "stop_sandbox" );
	set_objective( level.obj_horse, level.mason_horse, "remove" );
}

clear_horse_objective_on_bp3_event()
{
	level.player endon( "enter_vehicle" );
	level endon( "stop_sandbox" );
	level waittill( "bp3_infantry_event" );
	while ( level.player_location != "bp3" )
	{
		wait 0,05;
	}
	set_objective( level.obj_horse, level.mason_horse, "remove" );
	level thread horse_watch_use_objective();
}

arena_drones()
{
	level.drones.step_height = 500;
	level.specific_drone_death = ::arena_hide_drone_delete;
	flag_init( "run_arena_drones" );
	arrayremovevalue( level.drones.axis_classnames, "actor_Enemy_Soviet_Afghan_Launcher_Base", 0 );
	arrayremovevalue( level.drones.allies_classnames, "actor_Ally_Afghan_Muj_Launcher_Base", 0 );
	arrayremovevalue( level.drones.allies_classnames, "actor_Ally_Afghan_Muj_Stinger_Base", 0 );
	level setup_drone_paths();
	level setup_russian_drone_paths();
	flag_set( "run_arena_drones" );
	level thread arena_drone_throttle();
	level thread arena_drone_kill_closest();
}

arena_drone_kill_closest()
{
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		a_drones = getentarray( "drone", "targetname" );
		n_original_size = a_drones.size;
		i = 0;
		while ( i < n_original_size )
		{
			if ( !isDefined( a_drones[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( isDefined( a_drones[ i ].marked_for_death ) || a_drones[ i ].marked_for_death && isDefined( a_drones[ i ].swapped_for_ai ) && a_drones[ i ].swapped_for_ai )
			{
				i++;
				continue;
			}
			else
			{
				if ( getaicount() < 22 && distance2dsquared( level.player.origin, a_drones[ i ].origin ) < ( 1200 * 1200 ) && within_fov( level.player.origin, level.player getplayerangles(), a_drones[ i ].origin, cos( 45 ) ) )
				{
					a_drones[ i ] drone_swap_for_ai();
					wait 0,25;
					i++;
					continue;
				}
				else
				{
					if ( distance2dsquared( level.player.origin, a_drones[ i ].origin ) < ( 1200 * 1200 ) )
					{
						if ( !isDefined( a_drones[ i ] ) )
						{
							i++;
							continue;
						}
						else if ( isDefined( a_drones[ i ].marked_for_death ) || a_drones[ i ].marked_for_death && isDefined( a_drones[ i ].swapped_for_ai ) && a_drones[ i ].swapped_for_ai )
						{
							i++;
							continue;
						}
						else
						{
							if ( getaicount() < 22 && within_fov( level.player.origin, level.player getplayerangles(), a_drones[ i ].origin, cos( 45 ) ) )
							{
								a_drones[ i ] drone_swap_for_ai();
								i++;
								continue;
							}
							else
							{
								if ( within_fov( level.player.origin, level.player getplayerangles(), a_drones[ i ].origin, cos( 65 ) ) )
								{
									a_drones[ i ].marked_for_death = 1;
									n_wait = randomintrange( 1, 3 );
									a_drones[ i ] thread delay_thread( n_wait, ::arena_hide_drone_delete );
									i++;
									continue;
								}
								else
								{
									a_drones[ i ] thread maps/_drones_aipath::drone_delete();
								}
							}
						}
					}
				}
			}
			i++;
		}
		wait 0,05;
	}
}

drone_swap_for_ai()
{
	if ( !isDefined( level.drones_swap_spawner_axis ) )
	{
		a_spawners = getentarray( "ai_drone_swapper", "targetname" );
		if ( a_spawners[ 0 ].script_string == "allies" )
		{
			level.drones_swap_spawner_axis = a_spawners[ 1 ];
			level.drones_swap_spawner_ally = a_spawners[ 0 ];
		}
		else
		{
			level.drones_swap_spawner_axis = a_spawners[ 0 ];
			level.drones_swap_spawner_ally = a_spawners[ 1 ];
		}
	}
	a_drones = getentarray( "drone", "targetname" );
	a_close_drones = [];
	_a2935 = a_drones;
	_k2935 = getFirstArrayKey( _a2935 );
	while ( isDefined( _k2935 ) )
	{
		drone = _a2935[ _k2935 ];
		if ( within_fov( level.player.origin, level.player getplayerangles(), drone.origin, cos( 35 ) ) )
		{
			a_close_drones[ a_close_drones.size ] = drone;
		}
		_k2935 = getNextArrayKey( _a2935, _k2935 );
	}
	a_close_drones = get_array_of_closest( level.player.origin, a_close_drones, undefined, 8, 2400 );
	if ( a_close_drones.size == 0 )
	{
		return;
	}
	vec_direction = a_close_drones[ 0 ].origin - level.player.origin;
	vec_direction *= 0,85;
	vec_mortar_pos = level.player.origin + vec_direction;
	level thread drop_a_mortar( vec_mortar_pos, 1, 1, 0 );
	while ( self.team == "axis" || getaiarray( "allies" ).size == 0 && self.team == "allies" && getaiarray( "axis" ).size == 0 )
	{
		n_original_size = a_close_drones.size;
		i = 0;
		while ( i < n_original_size )
		{
			if ( distancesquared( a_close_drones[ i ].origin, level.player.origin ) < 2560000 )
			{
				a_close_drones[ i ] maps/_drones_aipath::drone_delete();
			}
			i++;
		}
	}
	n_original_size = a_close_drones.size;
	i = 0;
	while ( i < n_original_size )
	{
		if ( !isDefined( a_close_drones[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			spawner = level.drones_swap_spawner_axis;
			if ( a_close_drones[ i ].team == "allies" )
			{
				spawner = level.drones_swap_spawner_ally;
			}
			spawner.origin = a_close_drones[ i ].origin;
			spawner.angles = a_close_drones[ i ].angles;
			a_close_drones[ i ].swapped_for_ai = 1;
			e_ai = simple_spawn_single( spawner, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
			if ( isDefined( e_ai ) )
			{
				e_ai thread arena_ai_behavior( i );
			}
			a_close_drones[ i ] maps/_drones_aipath::drone_delete();
		}
		i++;
	}
}

arena_ai_behavior( n_timing )
{
	self endon( "death" );
	wait ( 0,05 * n_timing );
	self thread arena_ai_cleanup();
	self.maxsightdistsqrd = 250000;
	self.pathenemyfightdist = 64;
	str_difficulty = getdifficulty();
	if ( str_difficulty == "easy" )
	{
		self.script_accuracy = 0,1;
	}
	else if ( str_difficulty == "medium" )
	{
		self.script_accuracy = 0,2;
	}
	else if ( str_difficulty == "hard" )
	{
		self.script_accuracy = 0,3;
	}
	else
	{
		if ( str_difficulty == "fu" )
		{
			self.script_accuracy = 0,4;
		}
	}
	while ( 1 )
	{
		if ( self.team == "allies" )
		{
			a_enemies = getaiarray( "axis" );
		}
		else
		{
			if ( self.team == "axis" )
			{
				a_enemies = getaiarray( "allies" );
			}
		}
		next_target = get_array_of_closest( self.origin, a_enemies, undefined, 1 );
		if ( next_target.size )
		{
			self setgoalpos( next_target[ 0 ].origin );
		}
		wait 1;
	}
}

arena_ai_cleanup()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( level.player_location ) || level.player_location == "bp2" && level.player_location == "bp3" )
		{
			if ( within_fov( level.player.origin, level.player getplayerangles(), self.origin, cos( 100 ) ) )
			{
				self thread maps/_utility::bloody_death();
			}
			else
			{
				self delete();
			}
		}
		else
		{
			if ( distance2dsquared( self.origin, level.player.origin ) > 12960000 )
			{
				if ( !within_fov( level.player.origin, level.player getplayerangles(), self.origin, cos( 100 ) ) )
				{
					self delete();
				}
			}
		}
		wait 0,25;
	}
}

arena_drone_throttle()
{
	level endon( "stop_sandbox" );
	max_drones = 74;
/#
	max_drones = 12;
#/
	while ( 1 )
	{
		n_extra_ai = getaicount() - 10;
		n_extra_veh = ( getvehiclearray( "axis", "allies" ).size * 2 ) - 8;
		n_drones_available = max_drones - n_extra_ai - n_extra_veh;
		if ( flag( "bp3_infantry_event" ) && isDefined( level.player_location ) && level.player_location == "bp3" )
		{
			level.drones.max_drones = 0;
		}
		else
		{
			if ( n_drones_available > max_drones )
			{
				level.drones.max_drones = max_drones;
				break;
			}
			else
			{
				level.drones.max_drones = n_drones_available;
			}
		}
		a_drones = getentarray( "drone", "targetname" );
		if ( n_drones_available < 0 )
		{
			n_drones_available = 0;
		}
		while ( n_drones_available < a_drones.size )
		{
			i = 0;
			while ( i < ( a_drones.size - n_drones_available ) )
			{
				a_drones[ i ] maps/_drones_aipath::drone_delete();
				i++;
			}
		}
		wait 0,15;
	}
}

arena_hide_drone_delete()
{
	self endon( "death" );
	if ( isDefined( self.marked_for_death ) || self.marked_for_death && isDefined( self.swapped_for_ai ) && self.swapped_for_ai )
	{
		return;
	}
	if ( !within_fov( level.player.origin, level.player getplayerangles(), self.origin, cos( 65 ) ) )
	{
		self thread maps/_drones_aipath::drone_delete();
		return;
	}
	if ( randomint( 100 ) > 30 )
	{
		a_impact_loc = array( "j_hip_le", "j_hip_ri", "j_head", "j_spine4", "j_clavicle_le", "j_clavicle_ri" );
		str_tag = random( a_impact_loc );
		playfxontag( level._effect[ "flesh_hit" ], self, str_tag );
		self dodamage( 200, self.origin, self, undefined, "riflebullet" );
	}
	else
	{
		level drop_a_mortar( self.origin, 1, 1 );
	}
}

north_pass_drones( n_path_id )
{
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		while ( isDefined( level.player_location ) || level.player_location == "bp2" && level.player_location == "bp3" )
		{
			wait 1;
		}
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 0,5;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 0,5;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 0,3;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 1;
		wait 1;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 0,5;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 0,3;
		level thread maps/_drones_aipath::drone_spawn( "allies", n_path_id, undefined, undefined, 1 );
		wait 1;
	}
}

setup_drone_paths()
{
	a_drone_structs = get_struct_array( "struct_ai_drones", "targetname" );
	front_structs = [];
	left_structs = [];
	right_structs = [];
	drone_path_ent = getent( "drone_angle_ent", "targetname" );
	vec_right = anglesToRight( drone_path_ent.angles );
	_a3243 = a_drone_structs;
	_k3243 = getFirstArrayKey( _a3243 );
	while ( isDefined( _k3243 ) )
	{
		struct = _a3243[ _k3243 ];
		if ( vectordot( struct.origin - drone_path_ent.origin, vec_right ) > 0 )
		{
			right_structs[ right_structs.size ] = struct;
		}
		else
		{
			left_structs[ left_structs.size ] = struct;
		}
		_k3243 = getNextArrayKey( _a3243, _k3243 );
	}
	paths = [];
	paths[ "start" ] = [];
	paths[ "end" ] = [];
	num_paths = left_structs.size;
	if ( right_structs.size < num_paths )
	{
		num_paths = right_structs.size;
	}
	if ( num_paths < 3 )
	{
		wait 1;
	}
	else
	{
		i = 0;
		while ( i < num_paths )
		{
			if ( ( i % 2 ) == 1 )
			{
				level thread prep_drone_path( left_structs[ i ], right_structs[ i ].origin );
			}
			else
			{
				level thread prep_drone_path( right_structs[ i ], left_structs[ i ].origin );
			}
			level waittill( "ai_drone_ent_num", path_num );
			level thread arena_random_drones( path_num );
			i++;
		}
		if ( 1 )
		{
			return;
		}
	}
}

setup_russian_drone_paths()
{
	a_drone_structs = getstructarray( "rus_drone_struct", "targetname" );
	_a3313 = a_drone_structs;
	_k3313 = getFirstArrayKey( _a3313 );
	while ( isDefined( _k3313 ) )
	{
		struct = _a3313[ _k3313 ];
		s_end = getstruct( struct.target, "targetname" );
		level thread prep_drone_path( struct, s_end.origin );
		level waittill( "ai_drone_ent_num", path_num );
		level thread arena_random_drones_controlled( path_num, "axis" );
		_k3313 = getNextArrayKey( _a3313, _k3313 );
	}
}

arena_random_drones_controlled( n_path_id, faction )
{
	level endon( "stop_sandbox" );
	level waittill( "path_ready_" + n_path_id );
	while ( 1 )
	{
		flag_wait( "run_arena_drones" );
		str_drone_type = need_more_allies_or_axis();
		if ( str_drone_type == faction )
		{
			level thread maps/_drones_aipath::drone_spawn( faction, n_path_id, undefined, undefined, 1 );
			wait 0,5;
			level thread maps/_drones_aipath::drone_spawn( faction, n_path_id, undefined, undefined, 1 );
			wait 0,5;
			level thread maps/_drones_aipath::drone_spawn( faction, n_path_id, undefined, undefined, 1 );
			wait 0,3;
			level thread maps/_drones_aipath::drone_spawn( faction, n_path_id, undefined, undefined, 1 );
		}
		wait 4;
	}
}

arena_random_drones( n_path_id )
{
	level endon( "stop_sandbox" );
	level waittill( "path_ready_" + n_path_id );
	while ( 1 )
	{
		flag_wait( "run_arena_drones" );
		str_drone_type = need_more_allies_or_axis();
		if ( str_drone_type != "axis" )
		{
			level thread maps/_drones_aipath::drone_spawn( str_drone_type, n_path_id, undefined, undefined, 1 );
			wait 0,5;
			level thread maps/_drones_aipath::drone_spawn( str_drone_type, n_path_id, undefined, undefined, 1 );
			wait 0,5;
			level thread maps/_drones_aipath::drone_spawn( str_drone_type, n_path_id, undefined, undefined, 1 );
			wait 0,3;
			level thread maps/_drones_aipath::drone_spawn( str_drone_type, n_path_id, undefined, undefined, 1 );
		}
		wait 4;
	}
}

need_more_allies_or_axis()
{
	a_axis = getaiarray( "axis" );
	a_allies = getaiarray( "allies" );
	if ( a_axis.size > a_allies.size )
	{
		if ( randomint( 100 ) > 20 )
		{
			return "allies";
		}
		else
		{
			return "axis";
		}
	}
	else
	{
		if ( randomint( 100 ) > 20 )
		{
			return "axis";
		}
		else
		{
			return "allies";
		}
	}
}

skipto_arena()
{
	skipto_setup();
	init_hero( "zhao" );
	init_hero( "woods" );
	skipto_teleport( "skipto_wave1", level.heroes );
	t_chase = getent( "trigger_uaz_chase", "targetname" );
	t_chase trigger_on();
	level thread maps/_horse::set_horse_in_combat( 1 );
	level.zhao = getent( "zhao_ai", "targetname" );
	level.woods = getent( "woods_ai", "targetname" );
	remove_woods_facemask_util();
	s_player_horse_spawnpt = getstruct( "wave1_player_horse_spawnpt", "targetname" );
	s_zhao_horse_spawnpt = getstruct( "wave1_zhao_horse_spawnpt", "targetname" );
	s_woods_horse_spawnpt = getstruct( "wave1_woods_horse_spawnpt", "targetname" );
	level.zhao_horse = spawn_vehicle_from_targetname( "zhao_horse" );
	level.zhao_horse.origin = s_zhao_horse_spawnpt.origin;
	level.zhao_horse.angles = s_zhao_horse_spawnpt.angles;
	level.woods_horse = spawn_vehicle_from_targetname( "woods_horse" );
	level.woods_horse.origin = s_woods_horse_spawnpt.origin;
	level.woods_horse.angles = s_woods_horse_spawnpt.angles;
	level.mason_horse = spawn_vehicle_from_targetname( "mason_horse" );
	level.mason_horse.origin = s_player_horse_spawnpt.origin;
	level.mason_horse.angles = s_player_horse_spawnpt.angles;
	level.woods_horse makevehicleunusable();
	level.zhao_horse makevehicleunusable();
	level.mason_horse makevehicleusable();
	level.woods_horse veh_magic_bullet_shield( 1 );
	level.zhao_horse veh_magic_bullet_shield( 1 );
	level.mason_horse veh_magic_bullet_shield( 1 );
	level.mason_horse thread horse_toggle_follow_behavior();
	wait 0,1;
	level.woods enter_vehicle( level.woods_horse );
	level.zhao enter_vehicle( level.zhao_horse );
	level clientnotify( "abs_1" );
	wait 0,05;
	level.woods_horse notify( "groupedanimevent" );
	level.zhao_horse notify( "groupedanimevent" );
	level.woods maps/_horse_rider::ride_and_shoot( level.woods_horse );
	level.zhao maps/_horse_rider::ride_and_shoot( level.zhao_horse );
	level clientnotify( "dbw1" );
	wait 3;
	load_gump( "afghanistan_gump_arena" );
	struct_cleanup_wave1();
	delete_section1_scenes();
	delete_section1_ride_scenes();
	delete_section_2_scenes();
	level.player thread vehicle_whizby_or_close_impact();
	level.player thread maps/afghanistan_base_threats::ammo_show_caches_when_ooa();
	level.player thread maps/afghanistan_base_threats::weapon_show_caches_when_need_launcher();
	level thread arena_drones();
	level thread stock_weapon_caches();
	level thread maps/afghanistan_base_threats::base_attack_manager();
	level thread close_base_gate();
	spawn_manager_enable( "sm_muj_wall_1" );
	spawn_manager_enable( "sm_muj_wall_2" );
	spawn_manager_enable( "sm_muj_wall_3" );
	spawn_manager_enable( "sm_muj_wall_4" );
}

woods_test_loop()
{
	while ( 1 )
	{
		level.woods_horse woods_to_bp1();
		level.woods_horse woods_to_bp2();
		level.woods_horse woods_to_bp3();
	}
}

zhao_test_loop()
{
	while ( 1 )
	{
		level.zhao_horse zhao_to_bp1();
		level.zhao_horse zhao_to_bp2();
		level.zhao_horse zhao_to_bp3();
	}
}
