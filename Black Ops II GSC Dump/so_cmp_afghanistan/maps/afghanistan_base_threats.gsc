#include maps/afghanistan_arena_manager;
#include maps/afghanistan_bp2;
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

base_attack_manager()
{
	flag_init( "base_under_attack" );
	flag_init( "current_wave_cleared" );
	flag_init( "vo_base_talking" );
	flag_init( "woods_nagging_target" );
	flag_init( "vo_wave_complete" );
	level thread mortar_fx_anim_setup();
	level thread base_objectives_think();
	level thread enable_base_spawn_managers();
	initialize_base_icon();
	initialize_arena_vo();
	initialize_waves();
	b_challenge_helos_spawned = 0;
	i = 0;
	while ( i < level.available_wave_types.size )
	{
		flag_clear( "current_wave_cleared" );
		level thread watch_current_wave( level.available_wave_types[ i ].size );
		wave_type = level.available_wave_types[ i ][ 0 ];
		arrayremovevalue( level.available_wave_types[ i ], wave_type );
		a_blocking_points = array( 1, 2, 3 );
		num_closest = get_blocking_point_closest_to_player();
		arrayremovevalue( a_blocking_points, num_closest );
		blocking_point = 1;
		if ( wave_type == "air" )
		{
			if ( i == 0 )
			{
				blocking_point = 1;
			}
			else
			{
				blocking_point = random( a_blocking_points );
			}
		}
		else
		{
			if ( wave_type == "ground" )
			{
				blocking_point = 2;
			}
		}
		if ( isDefined( level.player_location ) && level.player_location != "arena" )
		{
			if ( level.player_location == "bp2" )
			{
				if ( blocking_point == 2 )
				{
					blocking_point = 3;
				}
				break;
			}
			else
			{
				if ( level.player_location == "bp3" )
				{
					if ( blocking_point == 3 )
					{
						blocking_point = 2;
					}
				}
			}
		}
		if ( i == 0 )
		{
			level notify( "immune_vehicle_notify" );
			watch_for_wave_start_or_incoming_timer( blocking_point, wave_type, i == ( level.available_wave_types.size - 1 ), 1 );
		}
		else
		{
			watch_for_wave_start_or_incoming_timer( blocking_point, wave_type, i == ( level.available_wave_types.size - 1 ) );
		}
		switch( wave_type )
		{
			case "air":
				level thread base_attack_air_wave( blocking_point );
				break;
			case "ground":
				level thread base_attack_ground_wave( blocking_point, i );
				break;
		}
		level thread next_wave_timer( i == ( level.available_wave_types.size - 1 ) );
		waittill_either( "base_wave_cleared", "time_to_spawn_new_wave" );
		level notify( "all_waves_spawned" );
		flag_wait( "current_wave_cleared" );
		if ( i == ( level.available_wave_types.size - 1 ) )
		{
			level notify( "base_secure" );
			setmusicstate( "AFGHAN_FINAL_WAVE" );
		}
		autosave_by_name( "arena_wave_cleared" );
		i++;
	}
/#
	iprintlnbold( "ALL WAVES COMPLETE" );
#/
	base_cleanup();
	wait 0,25;
	flag_waitopen( "vo_wave_complete" );
	flag_set( "bp3_infantry_event" );
	level thread maps/afghanistan_bp2::bp3_infantry_event();
	flag_waitopen( "bp3_infantry_event" );
	autosave_by_name( "afghan_bp3_infantry_done" );
	set_objective( level.obj_protect, undefined, "done" );
	flag_set( "base_successfully_defended" );
}

get_blocking_point_closest_to_player()
{
	struct_1 = get_struct( "zhao_bp1wave3_goal", "targetname" );
	struct_2 = get_struct( "zhao_bp2", "targetname" );
	struct_3 = get_struct( "zhao_bp3", "targetname" );
	a_str_structs = array( struct_1, struct_2, struct_3 );
	s_closest = get_array_of_closest( level.player.origin, a_str_structs, undefined, 1 )[ 0 ];
	if ( s_closest == struct_1 )
	{
		return 1;
	}
	else
	{
		if ( s_closest == struct_2 )
		{
			return 2;
		}
		else
		{
			if ( s_closest == struct_3 )
			{
				return 3;
			}
		}
	}
	return 1;
}

watch_current_wave( num_waves )
{
	level waittill( "all_waves_spawned" );
	while ( level.a_arena_hinds.size > 0 || level.a_arena_tanks.size > 0 )
	{
		wait 0,1;
	}
	flag_set( "current_wave_cleared" );
}

initialize_waves()
{
	level.available_wave_types = [];
	wave_types = array( "ground", "air" );
	level.available_wave_types[ 0 ][ 0 ] = "ground";
	level.available_wave_types[ 1 ][ 0 ] = "air";
	level.available_wave_types[ 2 ][ 0 ] = random( wave_types );
}

watch_for_wave_start_or_incoming_timer( blocking_point, wave_type, b_no_guide, instant_spawn )
{
	if ( !isDefined( b_no_guide ) )
	{
		b_no_guide = 0;
	}
	if ( !isDefined( instant_spawn ) )
	{
		instant_spawn = 0;
	}
	level endon( "start_next_wave" );
	level thread vo_incoming_at_blocking_points( blocking_point, wave_type );
	if ( !instant_spawn )
	{
		level waittill( "hudson_vo_said" );
	}
	else
	{
		level waittill( "hudson_vo_first_time" );
	}
	if ( !isDefined( level.zhao_headed_to_reinforce_bp ) )
	{
		level.zhao_headed_to_reinforce_bp = 0;
		level.woods_headed_to_reinforce_bp = 0;
	}
	if ( !level.zhao_headed_to_reinforce_bp )
	{
		e_bp_objective = level.zhao;
		level thread maps/afghanistan_arena_manager::send_zhao_to_bp( blocking_point );
	}
	else if ( !level.woods_headed_to_reinforce_bp )
	{
		e_bp_objective = level.woods;
		level thread maps/afghanistan_arena_manager::send_woods_to_bp( blocking_point );
	}
	else
	{
/#
		assert( 0, "needed to send someone to a blocking point, but no one was free" );
#/
	}
	level notify( "start_next_wave" );
}

clear_blocking_point_objective( obj_struct )
{
	level waittill( "start_next_wave" );
	if ( obj_struct == level.woods )
	{
		level.woods_headed_to_reinforce_bp = 0;
	}
	else
	{
		if ( obj_struct == level.zhao )
		{
			level.zhao_headed_to_reinforce_bp = 0;
		}
	}
	set_objective( level.obj_defend_bp, obj_struct, "remove" );
}

watch_incoming_timer( spawn_array_empty )
{
	if ( !isDefined( spawn_array_empty ) )
	{
		spawn_array_empty = 0;
	}
	level endon( "start_next_wave" );
	if ( spawn_array_empty )
	{
		level thread notify_next_wave_if_no_targets();
	}
	wait 15;
	level notify( "start_next_wave" );
}

notify_next_wave_if_no_targets()
{
	level endon( "start_next_wave" );
	level endon( "end_next_wave_timer" );
	while ( 1 )
	{
		if ( level.a_arena_hinds.size == 0 && level.a_arena_tanks.size == 0 )
		{
			level notify( "start_next_wave" );
			level notify( "end_next_wave_timer" );
		}
		wait 0,05;
	}
}

next_wave_timer( spawn_array_empty )
{
	if ( !isDefined( spawn_array_empty ) )
	{
		spawn_array_empty = 0;
	}
	level notify( "end_next_wave_timer" );
	level endon( "end_next_wave_timer" );
	if ( spawn_array_empty )
	{
		level thread notify_next_wave_if_no_targets();
	}
	wait 15;
	level notify( "time_to_spawn_new_wave" );
}

base_attacker_label()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), "BASE ATTACKER" );
		wait 0,05;
#/
	}
}

base_attack_air_wave( blocking_point )
{
/#
	iprintln( "Base Attack: air attack incoming" );
#/
	num_helos = 2;
	if ( !isDefined( level.a_arena_hinds ) )
	{
		level.a_arena_hinds = [];
	}
	if ( !isDefined( level.a_arena_hind_playerattack ) )
	{
		level.a_arena_hind_playerattack = [];
	}
	a_helo_base_structs = getstructarray( "struct_airwave_over_base", "targetname" );
	i = 0;
	while ( i < num_helos )
	{
		if ( i == ( num_helos - 1 ) && level.a_arena_hind_playerattack.size == 0 )
		{
			helo = base_attack_spawn_hind( blocking_point, 1, a_helo_base_structs[ a_helo_base_structs.size - 2 ] );
		}
		else
		{
			helo = base_attack_spawn_hind( blocking_point, undefined, a_helo_base_structs[ i ] );
		}
		level.a_arena_hinds[ level.a_arena_hinds.size ] = helo;
		wait 5;
		i++;
	}
	previous_size = level.a_arena_hinds.size;
	while ( level.a_arena_hinds.size > 0 )
	{
		level.a_arena_hinds = array_removedead( level.a_arena_hinds );
		if ( previous_size > level.a_arena_hinds.size && level.a_arena_hinds.size > 0 )
		{
			level thread vo_helo_killed();
			previous_size = level.a_arena_hinds.size;
			autosave_by_name( "helicopter_killed" );
		}
		wait 0,1;
	}
	vo_helo_wave_completed();
	level notify( "base_wave_cleared" );
/#
	iprintln( "air wave cleared" );
#/
}

base_attack_spawn_hind( blocking_point, guard, goal_struct )
{
	if ( !isDefined( guard ) )
	{
		guard = 0;
	}
	if ( blocking_point == 2 )
	{
		s_spawnpt = getstruct( "struct_airwave_bp2_start", "targetname" );
	}
	else if ( blocking_point == 3 )
	{
		s_spawnpt = getstruct( "struct_airwave_bp3_start", "targetname" );
	}
	else
	{
		s_spawnpt = getstruct( "struct_airwave_bp1_start", "targetname" );
	}
	vh_hind = spawn_vehicle_from_targetname( "hind_soviet" );
	vh_hind.origin = s_spawnpt.origin;
	vh_hind.angles = s_spawnpt.angles;
	vh_hind.targetname = "base_attack_chopper";
	vh_hind makesentient();
	target_set( vh_hind, ( -50, 0, -32 ) );
	vh_hind.overridevehicledamage = ::heli_vehicle_damage;
	z_offset = randomintrange( 600, 1000 );
	vh_hind.flyheight = z_offset;
	vh_hind pathfixedoffset( ( 0, 0, z_offset ) );
	if ( guard )
	{
		vh_hind thread guard_hind_logic( goal_struct );
		level.a_arena_hind_playerattack[ level.a_arena_hind_playerattack.size ] = vh_hind;
		vh_hind thread update_attack_hind_on_death();
		vh_hind thread woods_play_nag_for_target_while_alive( "helo" );
	}
	else
	{
		vh_hind thread base_attack_hind_logic( goal_struct );
		vh_hind thread woods_play_nag_for_target_while_alive( "helo" );
	}
	return vh_hind;
}

update_attack_hind_on_death()
{
	self waittill( "death" );
	arrayremovevalue( level.a_arena_hind_playerattack, self, 0 );
	arrayremovevalue( level.a_arena_hinds, self, 0 );
	if ( level.a_arena_hinds.size > 1 )
	{
		vh_hind = level.a_arena_hinds[ 0 ];
		vh_hind notify( "stop_base_attack" );
		vh_hind thread guard_hind_logic();
		level.a_arena_hind_playerattack[ level.a_arena_hind_playerattack.size ] = vh_hind;
		vh_hind thread update_attack_hind_on_death();
	}
}

base_attack_hind_logic( goal_struct )
{
	self endon( "death" );
	self endon( "stop_base_attack" );
	self thread heli_select_death();
	self thread nag_destroy_vehicle();
	self setneargoalnotifydist( 1000 );
	self setvehmaxspeed( 75 );
	self setvehgoalpos( goal_struct.origin, 0, 1 );
	self waittill_any( "goal", "near_goal" );
	self setvehgoalpos( self.origin, 1 );
	self thread hind_baseattack();
}

guard_hind_logic( goal_struct )
{
	self endon( "death" );
	a_enemies = getaiarray( "allies" );
	a_targets = sort_by_distance( a_enemies, self.origin );
	e_target = level.player;
	self setneargoalnotifydist( 2000 );
	self setvehmaxspeed( 75 );
	self thread guard_hind_attack_targets();
	if ( isDefined( goal_struct ) )
	{
		self setvehgoalpos( goal_struct.origin, 0, 1 );
		self waittill_any( "goal", "near_goal" );
	}
	self.goalpos = self.origin;
	self.goalradius = 1000;
	self.near_goal_notify = 450;
	self thread guard_hind_movement();
}

guard_hind_attack_targets()
{
	self endon( "death" );
	self.e_target = level.player;
	while ( 1 )
	{
		self setlookatent( self.e_target );
		wait 2;
		self hind_fireat_target( self.e_target );
		wait randomfloatrange( 3, 5 );
	}
}

guard_hind_movement()
{
	self endon( "death" );
	self endon( "change_state" );
/#
	assert( isalive( self ) );
#/
	old_goalpos = self.goalpos;
	if ( !self.vehonpath )
	{
		self setvehgoalpos( self.goalpos, 1 );
		self pathvariableoffset( vectorScale( ( 0, 0, 1 ), 20 ), 2 );
		if ( self.goalpos[ 2 ] > ( old_goalpos[ 2 ] + 10 ) || ( self.origin[ 2 ] + 10 ) < self.goalpos[ 2 ] )
		{
			self waittill_notify_or_timeout( "near_goal", 4 );
		}
		else
		{
			wait 0,5;
		}
	}
/#
	assert( isalive( self ) );
#/
	goalfailures = 0;
	while ( 1 )
	{
		goalpos = helo_find_new_position();
		goalpos = helo_adjust_goal_for_enemy_height( goalpos );
		if ( self setvehgoalpos( goalpos, 1, 1 ) )
		{
			goalfailures = 0;
			while ( distance2dsquared( ( self.origin[ 0 ], self.origin[ 1 ], 0 ), ( goalpos[ 0 ], goalpos[ 1 ], 0 ) ) > ( self.near_goal_notify * self.near_goal_notify ) )
			{
				wait 0,05;
			}
		}
		else goalfailures++;
		if ( isDefined( self.goal_node ) )
		{
			self.goal_node.quadrotor_fails = 1;
		}
		if ( goalfailures > 4 )
		{
		}
		else if ( goalfailures > 2 )
		{
		}
		else
		{
			goalpos = self.origin;
		}
		self setvehgoalpos( goalpos, 1 );
		old_goalpos = goalpos;
		offset = ( randomfloatrange( -50, 50 ), randomfloatrange( -50, 50 ), randomfloatrange( 50, 150 ) );
		goalpos += offset;
		wait 0,5;
	}
}

helo_adjust_goal_for_enemy_height( goalpos )
{
	if ( isDefined( self.enemy ) )
	{
		if ( ( self.enemy.origin[ 2 ] - 100 ) > goalpos[ 2 ] )
		{
			goal_z = self.enemy.origin[ 2 ] - 100;
			if ( goal_z > ( goalpos[ 2 ] + 350 ) )
			{
				goal_z = goalpos[ 2 ] + 350;
			}
			goalpos = ( goalpos[ 0 ], goalpos[ 1 ], goal_z );
		}
	}
	return goalpos;
}

helo_find_new_position()
{
	if ( !isDefined( self.goalpos ) )
	{
		self.goalpos = self.origin;
	}
	origin = self.goalpos;
	if ( isDefined( self.e_target ) )
	{
		self.goalpos = self.e_target.origin;
	}
	nodes = getnodesinradius( self.goalpos, self.goalradius, 0, self.flyheight + 300, "Path" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradius( self.goalpos, self.goalradius + 1000, 0, self.flyheight + 1000, "Path" );
	}
	best_node = undefined;
	best_score = 0;
	_a773 = nodes;
	_k773 = getFirstArrayKey( _a773 );
	while ( isDefined( _k773 ) )
	{
		node = _a773[ _k773 ];
		if ( node.type == "BAD NODE" )
		{
		}
		else
		{
			if ( isDefined( node.quadrotor_fails ) )
			{
				score = randomfloat( 30 );
			}
			else
			{
				score = randomfloat( 100 );
			}
			if ( score > best_score )
			{
				best_score = score;
				best_node = node;
			}
		}
		_k773 = getNextArrayKey( _a773, _k773 );
	}
	if ( isDefined( best_node ) )
	{
		origin = best_node.origin + ( 0, 0, self.flyheight + randomfloatrange( -50, 50 ) );
		self.goal_node = best_node;
	}
	return origin;
}

waittill_pathing_done()
{
	self endon( "death" );
	if ( self.vehonpath )
	{
		self waittill_any( "near_goal", "reached_end_node", "goal" );
	}
}

base_attack_ground_wave( blocking_point, num_wave )
{
/#
	iprintlnbold( "ground attack incoming" );
#/
	tank_path_start_nodes = [];
	if ( num_wave == 0 )
	{
		blocking_point = 1;
		tank_path_start_nodes[ 1 ] = "exit_bp1_tank_spawn";
	}
	else
	{
		tank_path_start_nodes[ 2 ][ 0 ] = "bp2_tank1_crest";
		tank_path_start_nodes[ 2 ][ 1 ] = "bp2_tank2_crest";
		tank_path_start_nodes[ 3 ] = "bp3_tank1_crest";
	}
	if ( !isDefined( level.ground_attack_tank_points ) )
	{
		level.ground_attack_tank_points = [];
		a_tank_spots = getentarray( "tank_sit_spot", "targetname" );
		_a849 = a_tank_spots;
		_k849 = getFirstArrayKey( _a849 );
		while ( isDefined( _k849 ) )
		{
			spot = _a849[ _k849 ];
			current_index = level.ground_attack_tank_points.size;
			level.ground_attack_tank_points[ current_index ] = [];
			level.ground_attack_tank_points[ current_index ][ "vec_goal" ] = spot.origin;
			level.ground_attack_tank_points[ current_index ][ "vec_target" ] = getent( spot.target, "targetname" ).origin;
			level.ground_attack_tank_points[ current_index ][ "occupied" ] = 0;
			_k849 = getNextArrayKey( _a849, _k849 );
		}
		array_delete( a_tank_spots );
	}
	if ( !isDefined( level.a_arena_tanks ) )
	{
		level.a_arena_tanks = [];
	}
	num_vehicles = randomintrange( 1, 2 );
	i = 0;
	while ( i < num_vehicles )
	{
		if ( isarray( tank_path_start_nodes[ blocking_point ] ) )
		{
			btr = base_attack_spawn_btr( random( tank_path_start_nodes[ blocking_point ] ) );
		}
		else
		{
			btr = base_attack_spawn_btr( tank_path_start_nodes[ blocking_point ] );
		}
		level.a_arena_tanks[ level.a_arena_tanks.size ] = btr;
		if ( num_wave != 0 )
		{
			wait 5;
		}
		i++;
	}
	if ( num_wave == 0 )
	{
		tank_path_start_nodes[ 1 ] = "bp2_tank1_crest";
	}
	num_tanks = 1;
	i = 0;
	while ( i < num_tanks )
	{
		if ( isarray( tank_path_start_nodes[ blocking_point ] ) )
		{
			tank = base_attack_spawn_tank( tank_path_start_nodes[ blocking_point ][ i ] );
		}
		else
		{
			tank = base_attack_spawn_tank( tank_path_start_nodes[ blocking_point ] );
		}
		level.a_arena_tanks[ level.a_arena_tanks.size ] = tank;
		wait 10;
		i++;
	}
	previous_size = level.a_arena_tanks.size;
	while ( level.a_arena_tanks.size > 0 )
	{
		level.a_arena_tanks = array_removedead( level.a_arena_tanks );
		if ( previous_size > level.a_arena_tanks.size && level.a_arena_tanks.size > 0 )
		{
			level thread vo_tank_killed();
			previous_size = level.a_arena_tanks.size;
			autosave_by_name( "ground_threat_killed" );
		}
		wait 0,1;
	}
	vo_tank_wave_completed();
	level notify( "base_wave_cleared" );
/#
	iprintln( "BASE ATTACK: ground wave cleared" );
#/
}

base_attack_spawn_tank( str_start_node )
{
	s_spawnpt = getvehiclenode( str_start_node, "targetname" );
	vh_tank = spawn_vehicle_from_targetname( "tank_soviet" );
	vh_tank.origin = s_spawnpt.origin;
	vh_tank.angles = s_spawnpt.angles;
	vh_tank.targetname = "base_attack_tank";
	vh_tank makesentient();
	vh_tank setspeed( 10 );
	vh_tank setvehicleavoidance( 1, 128, 5 );
	vh_tank pathfixedoffset( vectorScale( ( 0, 0, 1 ), 120 ) );
	vh_tank thread delete_veh_corpse_player_not_around();
	vh_tank thread base_attack_tank_logic( s_spawnpt );
	vh_tank thread woods_play_nag_for_target_while_alive( "tank" );
	return vh_tank;
}

tank_lower_avoidance_on_death()
{
	self waittill( "death" );
	self setvehicleavoidance( 1, 64, 3 );
}

base_attack_spawn_btr( str_start_node )
{
	s_spawnpt = getvehiclenode( str_start_node, "targetname" );
	vh_btr = spawn_vehicle_from_targetname( "btr_soviet" );
	vh_btr.origin = s_spawnpt.origin;
	vh_btr.angles = s_spawnpt.angles;
	vh_btr.targetname = "base_attack_tank";
	vh_btr makesentient();
	vh_btr setspeed( 10 );
	vh_btr setvehicleavoidance( 1, undefined, 2 );
	vh_btr pathfixedoffset( vectorScale( ( 0, 0, 1 ), 120 ) );
	vh_btr thread base_attack_btr_logic( s_spawnpt );
	vh_btr thread delete_veh_corpse_player_not_around();
	return vh_btr;
}

base_attack_btr_logic( start_node )
{
	self endon( "death" );
	self.overridevehicledamage = ::tank_damage;
	self drivepath( start_node );
	self setspeed( 20 );
	self thread btr_attack_if_anyone_is_attacked();
	nd_approach = getvehiclenode( "bp3_tank2_approach", "targetname" );
	nd_exit = getvehiclenode( "bp3_tank2_exit", "targetname" );
	self waittill( "reached_end_node" );
	i = 0;
	while ( i < level.ground_attack_tank_points.size )
	{
		if ( !level.ground_attack_tank_points[ i ][ "occupied" ] )
		{
			self.ground_attack_index = i;
			self thread clear_tank_attack_point_on_death( self.ground_attack_index );
			break;
		}
		else
		{
			i++;
		}
	}
/#
	assert( isDefined( self.ground_attack_index ) );
#/
	level.ground_attack_tank_points[ self.ground_attack_index ][ "occupied" ] = 1;
	self setvehgoalpos( level.ground_attack_tank_points[ self.ground_attack_index ][ "vec_goal" ], 1 );
}

base_attack_tank_logic( start_node )
{
	self endon( "death" );
	self.overridevehicledamage = ::tank_damage;
	self drivepath( start_node );
	self setspeed( 15 );
	self setneargoalnotifydist( 100 );
	self thread tank_attack_if_attacked();
	self waittill( "reached_end_node" );
	i = 0;
	while ( i < level.ground_attack_tank_points.size )
	{
		if ( !level.ground_attack_tank_points[ i ][ "occupied" ] )
		{
			self.ground_attack_index = i;
			self thread clear_tank_attack_point_on_death( self.ground_attack_index );
			break;
		}
		else
		{
			i++;
		}
	}
/#
	assert( isDefined( self.ground_attack_index ) );
#/
	level.ground_attack_tank_points[ self.ground_attack_index ][ "occupied" ] = 1;
	self setvehgoalpos( level.ground_attack_tank_points[ self.ground_attack_index ][ "vec_goal" ], 1 );
	self thread tank_baseattack();
	self waittill_any( "goal", "near_goal" );
	self setspeed( 0 );
	self setbrake( 1 );
}

btr_attack_if_anyone_is_attacked()
{
	self endon( "death" );
	self endon( "end_watch_for_attacks" );
	self thread btr_attack_allied_drones_and_ai();
	level waittill( "vehicle_wave_attacked_by_player" );
	str_difficulty = getdifficulty();
	if ( str_difficulty == "easy" )
	{
		n_offset_x = randomintrange( -64, 64 );
		n_offset_y = randomintrange( -64, 64 );
		n_offset_z = randomintrange( -64, 84 );
	}
	else if ( str_difficulty == "medium" )
	{
		n_offset_x = randomintrange( -64, 64 );
		n_offset_y = randomintrange( -24, 24 );
		n_offset_z = randomintrange( -64, 64 );
	}
	else if ( str_difficulty == "hard" )
	{
		n_offset_x = randomintrange( -32, 32 );
		n_offset_y = randomintrange( -12, 12 );
		n_offset_z = randomintrange( -32, 32 );
	}
	else
	{
		if ( str_difficulty == "fu" )
		{
			n_offset_x = randomintrange( -16, 16 );
			n_offset_y = randomintrange( -8, 8 );
			n_offset_z = randomintrange( -8, 8 );
		}
	}
	while ( 1 )
	{
		self thread shoot_turret_at_target( level.player, -1, ( n_offset_x, n_offset_y, n_offset_z ), 1 );
		wait randomfloatrange( 3, 5 );
		self stop_turret( 1 );
	}
}

btr_attack_allied_drones_and_ai()
{
	self endon( "death" );
	self endon( "end_watch_for_attacks" );
	level endon( "vehicle_wave_attacked_by_player" );
	a_targets = [];
	a_drones = [];
	while ( 1 )
	{
		a_targets = getaiarray( "allies" );
		arrayremovevalue( a_targets, level.woods, 0 );
		arrayremovevalue( a_targets, level.zhao, 0 );
		a_drones = getentarray( "drone", "targetname" );
		_a1132 = a_drones;
		_k1132 = getFirstArrayKey( _a1132 );
		while ( isDefined( _k1132 ) )
		{
			drone = _a1132[ _k1132 ];
			if ( drone.team == "allies" )
			{
				a_targets[ a_targets.size ] = drone;
			}
			_k1132 = getNextArrayKey( _a1132, _k1132 );
		}
		if ( a_targets.size > 0 )
		{
			target = get_array_of_closest( self.origin, a_targets, undefined, 1 )[ 0 ];
			self thread shoot_turret_at_target( target, 3, vectorScale( ( 0, 0, 1 ), 30 ), 1 );
			wait 4;
			self stop_turret( 1 );
		}
		wait 0,15;
	}
}

tank_attack_if_attacked()
{
	self endon( "death" );
	self endon( "end_watch_for_attacks" );
	self thread _tank_attack_if_attacked_waittill();
	self thread _tank_attack_if_whizby_or_close();
	self thread tank_attack_allied_drones_and_ai();
	self waittill( "being_attacked", e_attacker );
	level notify( "vehicle_wave_attacked_by_player" );
	while ( 1 )
	{
		if ( isplayer( e_attacker ) )
		{
			self thread _tank_targetting_a_player();
			self waittill( "turret_on_target" );
		}
		else
		{
			self settargetentity( e_attacker );
			self waittill( "turret_on_target" );
			wait 0,25;
		}
		self fireweapon();
		wait randomintrange( 3, 6 );
	}
}

tank_attack_allied_drones_and_ai()
{
	self endon( "death" );
	self endon( "end_watch_for_attacks" );
	level endon( "vehicle_wave_attacked_by_player" );
	a_targets = [];
	a_drones = [];
	while ( 1 )
	{
		a_targets = getaiarray( "allies" );
		arrayremovevalue( a_targets, level.woods, 0 );
		arrayremovevalue( a_targets, level.zhao, 0 );
		a_drones = getentarray( "drone", "targetname" );
		_a1205 = a_drones;
		_k1205 = getFirstArrayKey( _a1205 );
		while ( isDefined( _k1205 ) )
		{
			drone = _a1205[ _k1205 ];
			if ( drone.team == "allies" )
			{
				a_targets[ a_targets.size ] = drone;
			}
			_k1205 = getNextArrayKey( _a1205, _k1205 );
		}
		i = 0;
		while ( i < a_targets.size )
		{
			if ( !within_fov( self.origin, self.angles, a_targets[ i ].origin, cos( 90 ) ) )
			{
				a_targets[ i ] = "blah";
			}
			i++;
		}
		arrayremovevalue( a_targets, "blah", 0 );
		if ( a_targets.size > 0 )
		{
			target = get_array_of_closest( self.origin, a_targets, undefined, 1 )[ 0 ];
			self settargetentity( target );
			wait 3;
			self fireweapon();
		}
		wait 0,15;
	}
}

_tank_targetting_a_player()
{
	self endon( "turret_on_target" );
	self endon( "death" );
	while ( 1 )
	{
		target_pos = level.player.origin;
		if ( isDefined( level.player.my_horse ) )
		{
			target_pos += level.player.my_horse getvelocity();
		}
		else
		{
			target_pos += level.player getvelocity();
		}
		target_pos += anglesToForward( level.player getplayerangles() ) * 200;
		self settargetorigin( target_pos );
		wait 0,1;
	}
}

_tank_attack_if_attacked_waittill()
{
	self endon( "death" );
	self endon( "being_attacked" );
	while ( 1 )
	{
		self waittill( "damage", num_damage, e_attacker );
		if ( isplayer( e_attacker ) )
		{
			break;
		}
		else
		{
		}
	}
	self notify( "being_attacked" );
}

_tank_attack_if_whizby_or_close()
{
	self endon( "death" );
	self endon( "being_attacked" );
	self waittill_either( "close_impact", "whizby" );
	self notify( "being_attacked" );
}

clear_tank_attack_point_on_death( n_index )
{
	self waittill( "death" );
	level.ground_attack_tank_points[ n_index ][ "occupied" ] = 0;
}

mortar_fx_anim_setup()
{
	m_mortar1 = getent( "bp2_mortar1_emplacement", "targetname" );
	m_mortar2 = getent( "bp2_mortar2_emplacement", "targetname" );
	s_mortar1_obj = getstruct( "bp2_mortar1_animated", "targetname" );
	s_mortar2_obj = getstruct( "bp2_mortar2_animated", "targetname" );
	m_mortar1 setcandamage( 1 );
	m_mortar2 setcandamage( 1 );
	m_mortar1 thread mortar_fxanim( s_mortar1_obj, "mortar_1_destroyed" );
	m_mortar2 thread mortar_fxanim( s_mortar2_obj, "mortar_2_destroyed" );
}

mortar_fxanim( s_obj_pos, str_for_obj )
{
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type != "MOD_EXPLOSIVE" && type != "MOD_EXPLOSIVE_SPLASH" || type == "MOD_PROJECTILE" && type == "MOD_PROJECTILE_SPLASH" )
		{
			if ( self.targetname == "bp2_mortar2_emplacement" )
			{
				flag_set( "mortar2_destroyed" );
				level thread mortar2_destroyed_fx();
				autosave_by_name( "mortar2" );
				break;
			}
			else
			{
				flag_set( "mortar1_destroyed" );
				level thread mortar1_destroyed_fx();
				autosave_by_name( "mortar1" );
			}
		}
	}
}

mortar1_destroyed_fx()
{
	exploder( 651 );
	level notify( "fxanim_rock_peak_explosion_start" );
}

mortar2_destroyed_fx()
{
	exploder( 466 );
	level notify( "fxanim_cliff_collapse_start" );
}

base_objectives_think()
{
	level endon( "stop_sandbox" );
	set_objective( level.obj_protect );
	if ( !isDefined( level.a_arena_tanks ) )
	{
		level.a_arena_tanks = [];
		level.a_arena_hinds = [];
	}
	level thread base_objectives_cleanup();
	level thread base_attack_screen_message();
	level.e_hind_obj = undefined;
	level.e_tank_obj = undefined;
	while ( 1 )
	{
		if ( !isDefined( level.e_hind_obj ) && level.a_arena_hinds.size > 0 )
		{
			level.e_hind_obj = level.a_arena_hinds[ 0 ];
			if ( isDefined( level.e_hind_obj ) )
			{
				n_prev_num_hinds = level.a_arena_hinds.size;
				set_objective( level.obj_destroy_helo, level.e_hind_obj, "destroy", -1 );
				objective_setflag( level.obj_destroy_helo, "fadeoutonscreen", 0 );
				objective_setflag( level.obj_destroy_helo, "drawdistance", 1 );
			}
			level.e_hind_obj thread remove_base_obj_on_death( "hind" );
		}
		if ( !isDefined( level.e_tank_obj ) && level.a_arena_tanks.size > 0 )
		{
			level.e_tank_obj = level.a_arena_tanks[ 0 ];
			if ( isDefined( level.e_tank_obj ) )
			{
				n_prev_num_tanks = level.a_arena_tanks.size;
				set_objective( level.obj_destroy_tank, level.e_tank_obj, "destroy", -1 );
				objective_setflag( level.obj_destroy_tank, "fadeoutonscreen", 0 );
				objective_setflag( level.obj_destroy_tank, "drawdistance", 1 );
			}
			level.e_tank_obj thread remove_base_obj_on_death( "tank" );
		}
		wait 0,05;
	}
}

base_attack_screen_message()
{
	level endon( "stop_sandbox" );
	while ( 1 )
	{
		if ( flag( "base_under_attack" ) )
		{
			level notify( "base_under_attack" );
			level thread screen_message_create( &"AFGHANISTAN_MSG_BASEATTACK", undefined, undefined, undefined, 5 );
			flag_waitopen( "base_under_attack" );
		}
		wait 0,05;
	}
}

remove_base_obj_on_death( str_type )
{
	self waittill( "death" );
	if ( str_type == "hind" )
	{
		set_objective( level.obj_destroy_helo, self, "remove" );
		arrayremovevalue( level.a_arena_hinds, level.e_hind_obj, 0 );
		wait_network_frame();
		level.e_hind_obj = undefined;
	}
	else
	{
		if ( str_type == "tank" )
		{
			set_objective( level.obj_destroy_tank, self, "remove" );
			arrayremovevalue( level.a_arena_tanks, level.e_tank_obj, 0 );
			wait_network_frame();
			level.e_tank_obj = undefined;
		}
	}
}

base_objectives_cleanup()
{
	level waittill( "stop_sandbox" );
	set_objective( level.obj_destroy_helo, undefined, "delete" );
	set_objective( level.obj_destroy_tank, undefined, "delete" );
	screen_message_delete();
}

ammo_show_caches_when_ooa()
{
	level endon( "stop_sandbox" );
	a_ammo_triggers = getentarray( "trigger_ammo_cache", "targetname" );
	while ( 1 )
	{
		while ( player_has_ammo() )
		{
			wait 0,25;
		}
		curr_trigger = undefined;
		while ( !player_has_ammo() )
		{
			a_close_array = get_array_of_closest( level.player.origin, a_ammo_triggers );
			if ( !isDefined( curr_trigger ) )
			{
				curr_trigger = a_close_array[ 0 ];
				set_objective( level.obj_ammo, curr_trigger, "ammo" );
				level thread cleanup_ammo_obj( curr_trigger );
			}
			else
			{
				if ( curr_trigger != a_close_array[ 0 ] )
				{
					set_objective( level.obj_ammo, curr_trigger, "remove" );
					wait_network_frame();
					set_objective( level.obj_ammo, a_close_array[ 0 ], "ammo" );
					level thread cleanup_ammo_obj( curr_trigger );
					wait_network_frame();
					curr_trigger = a_close_array[ 0 ];
				}
			}
			wait 0,1;
		}
		level notify( "end_ammo_cleanup" );
		set_objective( level.obj_ammo, curr_trigger, "remove" );
	}
}

cleanup_ammo_obj( curr_trigger )
{
	level notify( "end_ammo_cleanup" );
	level endon( "end_ammo_cleanup" );
	level waittill( "stop_sandbox" );
	set_objective( level.obj_ammo, curr_trigger, "remove" );
}

cleanup_weap_obj( curr_trigger )
{
	level notify( "end_weap_cleanup" );
	level endon( "end_weap_cleanup" );
	level waittill( "stop_sandbox" );
	set_objective( level.obj_weapon, curr_trigger, "remove" );
}

weapon_show_caches_when_need_launcher()
{
	level endon( "stop_sandbox" );
	a_ammo_triggers = getentarray( "trigger_ammo_cache", "targetname" );
	trig_to_remove = undefined;
	i = a_ammo_triggers.size - 1;
	while ( i >= 0 )
	{
		if ( isDefined( a_ammo_triggers[ i ].script_int ) && a_ammo_triggers[ i ].script_int == int( 1337 ) )
		{
			trig_to_remove = a_ammo_triggers[ i ];
		}
		i--;

	}
	arrayremovevalue( a_ammo_triggers, trig_to_remove, 0 );
	while ( 1 )
	{
		level waittill( "immune_vehicle_notify" );
		curr_trigger = undefined;
		a_items = getitemarray();
		a_stinger_items = [];
		_a1643 = a_items;
		_k1643 = getFirstArrayKey( _a1643 );
		while ( isDefined( _k1643 ) )
		{
			item = _a1643[ _k1643 ];
			if ( isDefined( item.classname ) && item.classname == "weapon_afghanstinger_sp" )
			{
				a_stinger_items[ a_stinger_items.size ] = item;
			}
			_k1643 = getNextArrayKey( _a1643, _k1643 );
		}
		while ( !player_has_launcher() )
		{
			a_close_array = get_array_of_closest( level.player.origin, a_stinger_items );
			if ( !isDefined( curr_trigger ) )
			{
				curr_trigger = a_close_array[ 0 ];
				set_objective( level.obj_weapon, curr_trigger, &"AFGHANISTAN_OBJ_WEAPONS" );
				level thread cleanup_weap_obj( curr_trigger );
			}
			else
			{
				if ( curr_trigger != a_close_array[ 0 ] )
				{
					set_objective( level.obj_weapon, curr_trigger, "remove" );
					wait_network_frame();
					set_objective( level.obj_weapon, a_close_array[ 0 ], &"AFGHANISTAN_OBJ_WEAPONS" );
					level thread cleanup_weap_obj( curr_trigger );
					wait_network_frame();
					curr_trigger = a_close_array[ 0 ];
				}
			}
			wait 0,1;
		}
		level notify( "end_weap_cleanup" );
		set_objective( level.obj_weapon, curr_trigger, "remove" );
	}
}

player_has_launcher()
{
	a_player_weapons = level.player getweaponslistprimaries();
	b_has_launcher = 0;
	_a1693 = a_player_weapons;
	_k1693 = getFirstArrayKey( _a1693 );
	while ( isDefined( _k1693 ) )
	{
		str_weapon = _a1693[ _k1693 ];
		if ( issubstr( str_weapon, "stinger" ) )
		{
			b_has_launcher = 1;
		}
		_k1693 = getNextArrayKey( _a1693, _k1693 );
	}
	return b_has_launcher;
}

player_has_ammo()
{
	a_player_weapons = level.player getweaponslistprimaries();
	b_has_ammo = 1;
	_a1709 = a_player_weapons;
	_k1709 = getFirstArrayKey( _a1709 );
	while ( isDefined( _k1709 ) )
	{
		str_weapon = _a1709[ _k1709 ];
		total_ammo = 0;
		total_ammo += level.player getweaponammoclip( str_weapon );
		total_ammo += level.player getweaponammostock( str_weapon );
		if ( total_ammo == 0 )
		{
			b_has_ammo = 0;
		}
		_k1709 = getNextArrayKey( _a1709, _k1709 );
	}
	return b_has_ammo;
}

initialize_base_icon()
{
	level thread base_track_health();
}

base_track_mortar_fire()
{
	level endon( "cleanup_base_icons" );
	while ( 1 )
	{
		level waittill( "mortarteam_fire" );
		level notify( "base_attacked" );
	}
}

base_track_health()
{
	level endon( "cleanup_base_icons" );
	level thread base_track_mortar_fire();
	level.base_total_health = 200;
	level.a_base_attackers = [];
	level thread watch_base_attacked_flag();
	while ( level.base_total_health > 0 )
	{
		level waittill( "base_attacked", vehicle_type, e_vehicle );
		if ( !isinarray( level.a_base_attackers, e_vehicle ) )
		{
			level.a_base_attackers[ level.a_base_attackers.size ] = e_vehicle;
			e_vehicle thread remove_from_base_attackers_on_death();
		}
		switch( vehicle_type )
		{
			case "tank":
				level.base_total_health -= 4;
				break;
			case "helo":
				level.base_total_health -= 8;
				break;
			case "mortar":
				level.base_total_health -= 0,5;
				break;
			default:
			}
			level thread vo_base_under_attack( vehicle_type );
			base_update_icon();
		}
	}
}

watch_base_attacked_flag()
{
	level endon( "cleanup_base_icons" );
	while ( 1 )
	{
		if ( flag( "base_under_attack" ) && level.a_base_attackers.size == 0 )
		{
			flag_clear( "base_under_attack" );
		}
		else
		{
			if ( !flag( "base_under_attack" ) && level.a_base_attackers.size > 0 )
			{
				flag_set( "base_under_attack" );
			}
		}
		wait 0,05;
	}
}

remove_from_base_attackers_on_death()
{
	self waittill( "death" );
	arrayremovevalue( level.a_base_attackers, self, 0 );
	arrayremovevalue( level.a_arena_hinds, self, 0 );
	arrayremovevalue( level.a_arena_tanks, self, 0 );
}

base_update_icon()
{
	if ( level.base_total_health <= 0 )
	{
		missionfailedwrapper( &"AFGHANISTAN_PROTECT_FAILED" );
	}
	current_health_ratio = level.base_total_health / 200;
	if ( !isDefined( level.str_base_curr_color ) )
	{
		level.str_base_curr_color = "green";
	}
	if ( current_health_ratio <= 0,2 )
	{
		if ( level.str_base_curr_color != "red" )
		{
			level.str_base_curr_color = "red";
			exploder( 830 );
			base_wall_destroy( 3 );
			wait 0,25;
			base_wall_destroy( 1 );
		}
	}
	else if ( current_health_ratio <= 0,5 )
	{
		if ( level.str_base_curr_color != "orange" )
		{
			level.str_base_curr_color = "orange";
			exploder( 820 );
			base_wall_destroy( 2 );
		}
	}
	else
	{
		if ( current_health_ratio <= 0,8 )
		{
			if ( level.str_base_curr_color != "yellow" )
			{
				level.str_base_curr_color = "yellow";
				exploder( 810 );
				base_wall_destroy( 4 );
			}
		}
	}
}

base_cleanup()
{
	level notify( "cleanup_base_icons" );
}

vo_base_under_attack( threat_type )
{
	if ( flag( "vo_base_talking" ) )
	{
		return;
	}
	if ( !isDefined( level.n_time_last_base_vo ) )
	{
		level.n_time_last_base_vo = getTime();
	}
	else
	{
		if ( getTime() < ( level.n_time_last_base_vo + 7500 ) )
		{
			return;
		}
	}
	flag_set( "vo_base_talking" );
	if ( cointoss() )
	{
		line_played = 0;
		line_played = woods_play_nag_for_target( threat_type );
		if ( line_played )
		{
			flag_clear( "vo_base_talking" );
			return;
		}
	}
	if ( !isDefined( level.a_base_being_attacked_vo ) )
	{
		level.a_base_being_attacked_vo = array( "huds_the_base_is_under_at_0", "huds_the_muj_defenses_are_0", "huds_we_re_in_danger_of_l_0", "huds_the_muj_can_t_hold_t_0", "huds_the_muj_can_t_hold_o_0" );
	}
	if ( !isDefined( level.a_base_being_attacked_tank_vo ) )
	{
		level.a_base_being_attacked_tank_vo = array( "huds_enemy_tanks_are_firi_0", "huds_we_have_tanks_right_0", "huds_russian_tanks_are_ri_0" );
	}
	if ( !isDefined( level.a_base_being_attacked_helo_vo ) )
	{
		level.a_base_being_attacked_helo_vo = array( "huds_we_ve_got_gunships_r_0", "huds_russian_helicopters_0", "huds_we_re_taking_fire_fr_0" );
	}
	if ( !isDefined( level.a_base_being_attacked_come_back_vo ) )
	{
		level.a_base_being_attacked_come_back_vo = array( "huds_you_have_to_return_t_0", "huds_we_need_you_back_at_0", "huds_you_have_to_defend_t_0" );
	}
	first_line_played = 0;
	first_line_played = level.hudson_vo queue_line_and_remove( level.a_base_being_attacked_vo );
	play_second_line = 0;
	if ( first_line_played )
	{
		if ( cointoss() )
		{
			play_second_line = 1;
		}
	}
	else
	{
		play_second_line = 1;
	}
	if ( play_second_line )
	{
		switch( threat_type )
		{
			case "helo":
				level.hudson_vo queue_line_and_remove( level.a_base_being_attacked_helo_vo );
				break;
			case "tank":
				level.hudson_vo queue_line_and_remove( level.a_base_being_attacked_tank_vo );
				break;
			default:
			}
		}
		else if ( isDefined( level.player.location ) && level.player_location != "arena" )
		{
			level.hudson_vo queue_line_and_remove( level.a_base_being_attacked_come_back_vo );
		}
		flag_clear( "vo_base_talking" );
		level.n_time_last_base_vo = getTime();
	}
}

queue_line_and_remove( a_vo_lines )
{
	if ( !isDefined( a_vo_lines ) || a_vo_lines.size == 0 )
	{
		return 0;
	}
	str_vo_line = random( a_vo_lines );
	arrayremovevalue( a_vo_lines, str_vo_line );
	self queue_dialog( str_vo_line, 0,3 );
	return 1;
}

initialize_arena_vo()
{
	add_vo_to_nag_group( "move", level.woods, "wood_let_s_go_mason_0" );
	add_vo_to_nag_group( "move", level.woods, "wood_time_to_go_come_on_0" );
	add_vo_to_nag_group( "move", level.woods, "wood_forward_mason_0" );
	add_vo_to_nag_group( "move", level.woods, "wood_we_need_to_go_0" );
	add_vo_to_nag_group( "move", level.woods, "wood_come_on_let_s_go_0" );
	add_vo_to_nag_group( "move", level.woods, "wood_let_s_get_the_hell_o_0" );
}

vo_bp3_story()
{
	flag_set( "bp3_dialog_happening" );
	level.hudson_vo say_dialog( "huds_mullah_rahmaan_is_co_0" );
	level.woods say_dialog( "wood_tell_rahmaan_from_me_0" );
	flag_clear( "bp3_dialog_happening" );
	wait 0,05;
	if ( flag( "bp3_dialog_happening" ) )
	{
		return;
	}
	flag_set( "bp3_dialog_happening" );
	level.woods say_dialog( "wood_we_ll_kick_fucking_a_0" );
	flag_clear( "bp3_dialog_happening" );
	wait 0,05;
	if ( flag( "bp3_dialog_happening" ) )
	{
		return;
	}
	level.woods say_dialog( "wood_just_tell_him_he_d_b_0" );
	flag_clear( "bp3_dialog_happening" );
}

vo_after_bp3_story()
{
}

vo_incoming_at_blocking_points( blocking_point, str_threat_type )
{
	wait 0,05;
	flag_waitopen( "vo_wave_complete" );
	if ( !isDefined( level.vo_incoming_first_time ) )
	{
		level.vo_incoming_first_time = 1;
	}
	if ( !isDefined( level.num_hudson_vo_helos ) )
	{
		level.num_hudson_vo_helos = 0;
		level.num_hudson_vo_tanks = 0;
	}
	if ( level.vo_incoming_first_time )
	{
		level.hudson_vo say_dialog( "huds_woods_mason_they_0" );
		wait 0,2;
	}
	level notify( "hudson_vo_first_time" );
	hudson_vo = [];
	hudson_vo[ "helos" ] = [];
	hudson_vo[ "helos" ][ 1 ] = array( "huds_muj_scouts_are_track_0", "huds_we_re_tracking_a_num_0" );
	hudson_vo[ "helos" ][ 2 ] = array( "huds_scouts_report_enemy_0", "huds_we_have_more_russian_0" );
	hudson_vo[ "helos" ][ 3 ] = array( "huds_we_re_seeing_enemy_h_0", "huds_more_russian_gunship_0" );
	hudson_vo[ "tanks" ] = [];
	hudson_vo[ "tanks" ][ 2 ] = array( "huds_muj_are_reporting_ru_0", "huds_russian_tanks_are_ad_0" );
	hudson_vo[ "tanks" ][ 3 ] = array( "huds_spotters_report_russ_0", "huds_we_re_seeing_another_0" );
	if ( str_threat_type == "ground" )
	{
		level.hudson_vo say_dialog( hudson_vo[ "tanks" ][ blocking_point ][ level.num_hudson_vo_tanks ] );
		level.num_hudson_vo_tanks++;
	}
	else
	{
		if ( str_threat_type == "air" )
		{
			level.hudson_vo say_dialog( hudson_vo[ "helos" ][ blocking_point ][ level.num_hudson_vo_helos ] );
			level.num_hudson_vo_helos++;
		}
	}
	level notify( "hudson_vo_said" );
	if ( cointoss() && !level.vo_incoming_first_time )
	{
		a_follow_up_vo = array( "huds_ensure_they_don_t_pu_0", "huds_move_to_engage_0", "huds_take_them_down_0", "huds_take_them_down_any_0" );
		if ( isDefined( level.hudson_last_followup ) )
		{
			arrayremovevalue( a_follow_up_vo, level.hudson_last_followup );
		}
		str_follow_up = random( a_follow_up_vo );
		level.hudson_last_followup = str_follow_up;
		level.hudson_vo say_dialog( str_follow_up, 0,3 );
	}
	if ( cointoss() && !level.vo_incoming_first_time )
	{
		a_follow_up_player_vo = array( "maso_it_won_t_0", "maso_roger_that_hudson_0" );
		if ( isDefined( level.player.vo_last_followup ) )
		{
			arrayremovevalue( a_follow_up_player_vo, level.player.vo_last_followup );
		}
		str_follow_up = random( a_follow_up_player_vo );
		level.player.vo_last_followup = str_follow_up;
		level.player say_dialog( str_follow_up, 0,3 );
	}
	if ( cointoss() && !level.vo_incoming_first_time )
	{
		a_follow_up_woods_vo = array( "wood_let_s_ride_hya_0", "wood_leave_it_to_us_huds_0" );
		if ( isDefined( level.woods.vo_last_followup ) )
		{
			arrayremovevalue( a_follow_up_woods_vo, level.woods.vo_last_followup );
		}
		str_follow_up = random( a_follow_up_woods_vo );
		level.woods.vo_last_followup = str_follow_up;
		level.woods say_dialog( str_follow_up, 0,3 );
	}
	if ( level.vo_incoming_first_time )
	{
		wait 1;
		level.zhao say_dialog( "zhao_brute_force_and_stre_0" );
		level.woods say_dialog( "wood_doesn_t_mean_i_wante_0", 0,5 );
	}
	if ( level.vo_incoming_first_time )
	{
		level.vo_incoming_first_time = 0;
	}
}

vo_clear_vehicle_wave()
{
	a_vo_lines = array( "wood_vehicles_are_down_0", "wood_job_s_done_gotta_m_0" );
	level.woods say_dialog( random( a_vo_lines ), 1 );
}

vo_vehicles_headed_to_base()
{
	a_vo_lines = array( "wood_can_t_let_it_reach_t_0", "wood_take_em_down_before_0", "wood_don_t_let_them_get_t_0", "wood_gotta_stop_them_mas_0" );
	level.woods say_dialog( random( a_vo_lines ), 1 );
}

vo_helo_killed()
{
	if ( !isDefined( level.a_helo_killed_vo ) )
	{
		level.a_helo_killed_vo = array( "wood_you_got_him_0", "wood_good_fucking_hit_ma_0", "wood_good_hit_man_0", "wood_it_s_coming_down_0" );
	}
	str_vo_line = random( level.a_helo_killed_vo );
	level.woods say_dialog( str_vo_line, 1 );
	arrayremovevalue( level.a_helo_killed_vo, str_vo_line );
}

vo_helo_wave_completed()
{
	flag_set( "vo_wave_complete" );
	if ( !isDefined( level.a_helo_wave_end_vo ) )
	{
		level.a_helo_wave_end_vo = array( "maso_hudson_russian_gun_0", "maso_hudson_the_gunship_0", "maso_gunships_are_neutral_0" );
	}
	str_vo_line = random( level.a_helo_wave_end_vo );
	level.player say_dialog( str_vo_line, 1 );
	arrayremovevalue( level.a_helo_wave_end_vo, str_vo_line );
	flag_clear( "vo_wave_complete" );
}

woods_play_nag_for_target_while_alive( threat_type )
{
	self endon( "death" );
	wait 30;
	while ( 1 )
	{
		woods_play_nag_for_target( threat_type );
		wait randomintrange( 30, 40 );
	}
}

woods_play_nag_for_target( threat_type )
{
	if ( flag( "woods_nagging_target" ) )
	{
		return 0;
	}
	flag_set( "woods_nagging_target" );
	if ( !isDefined( level.a_helo_nag_vo ) )
	{
		level.a_helo_nag_vo = array( "wood_bring_down_those_gun_0", "wood_take_out_the_gunship_0", "wood_ground_those_russian_0" );
		level.a_tank_nag_vo = array( "wood_mason_we_gotta_tak_0", "wood_tanks_are_still_movi_0", "wood_good_hit_man_0", "wood_hit_the_tanks_0" );
	}
	if ( threat_type == "helo" )
	{
		if ( level.a_helo_nag_vo.size != 0 )
		{
			str_vo_line = random( level.a_helo_nag_vo );
			level.woods say_dialog( str_vo_line, 1 );
			arrayremovevalue( level.a_helo_nag_vo, str_vo_line );
		}
	}
	else
	{
		if ( threat_type == "tank" )
		{
			if ( level.a_tank_nag_vo.size != 0 )
			{
				str_vo_line = random( level.a_tank_nag_vo );
				level.woods say_dialog( str_vo_line, 1 );
				arrayremovevalue( level.a_tank_nag_vo, str_vo_line );
			}
		}
	}
	flag_clear( "woods_nagging_target" );
	if ( !isDefined( str_vo_line ) )
	{
		return 0;
	}
	return 1;
}

vo_tank_killed()
{
	if ( !isDefined( level.a_tank_killed_vo ) )
	{
		level.a_tank_killed_vo = array( "wood_tank_s_down_0", "wood_good_kill_mason_t_0", "wood_oh_you_got_him_0", "wood_fucked_him_good_0", "wood_that_s_how_you_deal_0", "wood_he_ain_t_gonna_be_an_0", "wood_that_s_it_for_him_0", "wood_got_him_good_mason_0", "wood_nice_work_0" );
	}
	str_tank_down_line = random( level.a_tank_killed_vo );
	level.woods say_dialog( str_tank_down_line, 1 );
	arrayremovevalue( level.a_tank_killed_vo, str_tank_down_line );
}

vo_tank_wave_completed()
{
	flag_set( "vo_wave_complete" );
	if ( !isDefined( level.a_tank_wave_end_vo ) )
	{
		level.a_tank_wave_end_vo = array( "maso_hudson_tanks_are_d_0", "maso_tanks_are_down_huds_0", "maso_tanks_are_down_and_o_0" );
	}
	str_tank_wave_over_line = random( level.a_tank_wave_end_vo );
	level.player say_dialog( str_tank_wave_over_line, 1 );
	arrayremovevalue( level.a_tank_wave_end_vo, str_tank_wave_over_line );
	flag_clear( "vo_wave_complete" );
}
