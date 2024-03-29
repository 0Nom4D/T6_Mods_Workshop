#include maps/_friendlyfire;
#include maps/la_2_player_f35;
#include maps/_turret;
#include maps/_objectives;
#include maps/_skipto;
#include maps/_vehicle;
#include maps/_music;
#include maps/la_utility;
#include maps/_dialog;
#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
	wait_for_first_player();
	flag_wait( "la_transition_setup_done" );
	convoy_setup();
	convoy_set_leader();
	level thread convoy_pathing_start();
	level thread convoy_regroup_check();
	level thread convoy_distance_check( 26000, 0,8 );
}

convoy_setup()
{
	level.convoy = spawnstruct();
	level.convoy.vehicles = [];
	level.convoy.distance_warning_percentage = 0,75;
	level.convoy.distance_warning_percentage_default = level.convoy.distance_warning_percentage;
	level.convoy.vh_potus = get_ent( "convoy_potus", "targetname", 1 );
	level.convoy.vehicles[ level.convoy.vehicles.size ] = level.convoy.vh_potus;
	level.convoy.vh_potus thread func_on_death( ::potus_death );
	level.convoy.vh_potus thread convoy_ground_health_warning();
	level.convoy.vh_potus thread _init_cougar_turret( "bullet" );
	level.convoy.vh_van = get_ent( "convoy_van", "targetname", 1 );
	level.convoy.vh_van thread convoy_vehicle_think_van( "convoy_start_default" );
	level.convoy.vh_van thread convoy_setup_fakehealth();
	level.convoy.vh_van thread convoy_add_glow_shader();
	level.convoy.vh_van.overridevehicledamage = ::convoy_vehicle_damage;
	level.convoy.vh_g20_1 = get_ent( "convoy_g20_1", "targetname", 1 );
	level.convoy.vehicles[ level.convoy.vehicles.size ] = level.convoy.vh_g20_1;
	level.convoy.vh_g20_1 thread func_on_death( ::g20_1_death );
	level.convoy.vh_g20_1 thread _init_cougar_turret( "bullet" );
	if ( !flag( "G20_1_saved" ) )
	{
		level.convoy.vh_g20_1 delete();
	}
	level.convoy.vh_g20_2 = get_ent( "convoy_g20_2", "targetname", 1 );
	level.convoy.vehicles[ level.convoy.vehicles.size ] = level.convoy.vh_g20_2;
	level.convoy.vh_g20_2 thread func_on_death( ::g20_2_death );
	level.convoy.vh_g20_2 thread _init_cougar_turret( "bullet" );
	if ( !flag( "G20_2_saved" ) )
	{
		level.convoy.vh_g20_2 delete();
	}
	level.convoy.lapd_escort = [];
	level.convoy.lapd_escort[ 0 ] = maps/_vehicle::spawn_vehicle_from_targetname( "police_escort_front_right" );
	level.convoy.lapd_escort[ 1 ] = maps/_vehicle::spawn_vehicle_from_targetname( "police_escort_front_left" );
	level.convoy.lapd_escort[ 2 ] = maps/_vehicle::spawn_vehicle_from_targetname( "police_escort_rear" );
	level.convoy.vehicles = array_removedead( level.convoy.vehicles );
	i = 0;
	while ( i < level.convoy.vehicles.size )
	{
		if ( !maps/_skipto::is_after_skipto( "f35_flying" ) )
		{
			level.convoy.vehicles[ i ] thread convoy_vehicle_think( "convoy_start_default" );
		}
		level.convoy.vehicles[ i ] thread convoy_setup_fakehealth();
		level.convoy.vehicles[ i ] thread add_scripted_damage_state( 0,33, ::convoy_low_health_func );
		level.convoy.vehicles[ i ] thread convoy_add_glow_shader();
		i++;
	}
	level thread begin_lapd_convoy_escort();
	if ( maps/_skipto::is_after_skipto( "f35_boarding" ) )
	{
		level thread clientnotify_delay( "player_put_on_helmet", 2 );
	}
}

convoy_ground_health_warning()
{
	self endon( "death" );
	level endon( "convoy_at_dogfight" );
	flag_wait( "roadblock_done" );
	wait 0,05;
	while ( self.armor >= ( self.armor_max / 2 ) )
	{
		wait 0,05;
	}
	maps/_objectives::set_objective( level.obj_protect, level.convoy.vh_potus, "protect", undefined, 0, 120 );
}

temp_avoidance_on_noteworthy()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "temp_avoidance" );
		b_avoidance = self getvehicleavoidance();
		wait 6;
		self setvehicleavoidance( b_avoidance );
	}
}

convoy_add_glow_shader()
{
	flag_wait( "player_flying" );
	self setclientflag( 14 );
	waittill_any_ents( self, "death", level.player, "exit_f35" );
	self clearclientflag( 14 );
}

police_sirens()
{
	siren_ent = spawn( "script_origin", self.origin );
	siren_ent playloopsound( "amb_cop_siren" );
	siren_ent linkto( self );
	waittill_any( "death", "delete", "kill_siren" );
	siren_ent stoploopsound( 1 );
	siren_ent delete();
}

convoy_setup_misc()
{
	a_temp = level.convoy.vehicles;
	a_temp[ a_temp.size ] = level.convoy.vh_van;
	i = 0;
	while ( i < a_temp.size )
	{
		a_temp[ i ] thread func_on_notify( "rooftops_slow_down", ::set_vehicle_speed, 60 );
		a_temp[ i ] thread func_on_notify( "rooftops_speed_up", ::set_vehicle_speed, 60 );
		a_temp[ i ] thread func_on_notify( "trenchruns_slow_down", ::set_vehicle_speed, 30 );
		i++;
	}
}

set_vehicle_speed( n_speed )
{
	self setspeed( n_speed );
}

harper_fires_from_van()
{
	self endon( "_convoy_vehicle_think_stop" );
	flag_wait( "player_flying" );
	ai_harper = get_ent( "harper_ai", "targetname" );
	if ( !isDefined( ai_harper ) )
	{
		ai_harper = simple_spawn_single( "harper" );
	}
	ai_harper.animname = "harper";
	b_has_unloaded = 0;
	while ( isDefined( ai_harper.ridingvehicle ) )
	{
		if ( !b_has_unloaded )
		{
			vh_temp = ai_harper.ridingvehicle;
			vh_temp vehicle_unload();
			b_has_unloaded = 1;
		}
		wait 0,1;
	}
	ai_harper enter_vehicle( self );
	ai_harper.vehicle_idle_override = %ch_la_09_01_harpershooting_harper;
	ai_harper thread _harper_fires_at_targets();
}

_harper_fires_at_targets()
{
}

_init_cougar_turret( str_type )
{
	self endon( "death" );
/#
	assert( isDefined( str_type ), "str_type is a required parameter for _init_cougar_turret" );
#/
	n_index = 1;
	n_fire_min = 3;
	n_fire_max = 6;
	n_wait_min = 2;
	n_wait_max = 3;
	flag_wait_all( "hotel_street_truck_group_1_spawned", "convoy_at_roadblock" );
	self.turret_index_used = n_index;
	self maps/_turret::set_turret_burst_parameters( n_fire_min, n_fire_max, n_wait_min, n_wait_max, n_index );
	self maps/_turret::set_turret_target_flags( 1, n_index );
	self thread maps/_turret::enable_turret( n_index );
	flag_wait( "convoy_at_rooftops" );
	self maps/_turret::disable_turret( n_index );
}

_shoot_at_drones()
{
	e_target = undefined;
	b_has_target = 0;
	while ( !b_has_target )
	{
		a_drones = level.aerial_vehicles.axis;
		if ( isDefined( a_drones ) && a_drones.size > 0 )
		{
			e_target = random( a_drones );
			if ( maps/la_2_player_f35::_can_bullet_hit_target( self.origin, e_target ) )
			{
				b_has_target = 1;
			}
		}
		wait 0,1;
	}
	return e_target;
}

convoy_setup_fakehealth()
{
	self.armor_max = 10000;
	self.armor = self.armor_max;
	self.friendlyfire_shield = 0;
	self.overridevehicledamage = ::convoy_vehicle_damage;
	flag_wait( "dogfights_story_done" );
	self.armor = self.armor_max * 2;
}

convoy_low_health_func()
{
	playfxontag( level._effect[ "cougar_damage_smoke" ], self, "tag_origin" );
	if ( self == level.convoy.vh_potus )
	{
		level notify( "POTUS_health_low" );
	}
}

begin_lapd_convoy_escort()
{
	self waittill( "convoy_at_roadblock" );
	_a319 = level.convoy.lapd_escort;
	_k319 = getFirstArrayKey( _a319 );
	while ( isDefined( _k319 ) )
	{
		car = _a319[ _k319 ];
		if ( maps/_skipto::is_default_skipto() )
		{
			car thread convoy_vehicle_think( "convoy_start_default" );
		}
		car thread temp_avoidance_on_noteworthy();
		_k319 = getNextArrayKey( _a319, _k319 );
	}
}

convoy_vehicle_think( node_or_string )
{
/#
	assert( isDefined( node_or_string ), "node_or_string is a required parameter for convoy_vehicle_think!" );
#/
	self notify( "_convoy_vehicle_think_stop" );
	self endon( "_convoy_vehicle_think_stop" );
	self endon( "death" );
	if ( !isDefined( self.ent_flag[ "is_moving" ] ) )
	{
		self ent_flag_init( "is_moving" );
	}
	if ( isstring( node_or_string ) )
	{
		nd_path = convoy_get_path_node( node_or_string );
	}
	else
	{
		nd_path = node_or_string;
	}
	n_acceleration = 30;
	flag_wait( "convoy_movement_started" );
	if ( !is_alive( self ) )
	{
		return;
	}
	self thread go_path( nd_path );
	self ent_flag_set( "is_moving" );
	while ( 1 )
	{
		self waittill( "convoy_stop" );
/#
		println( self.targetname + " is stopping\n" );
#/
		n_speed = self getmaxspeed( 1 );
		self setspeed( 0, 60, 60 );
		self ent_flag_clear( "is_moving" );
		flag_wait_all( "convoy_can_move", "player_in_range_of_convoy", "convoy_in_position" );
/#
		println( self.targetname + " is moving\n" );
#/
		self resumespeed( n_acceleration );
		if ( n_speed < 0 )
		{
			n_speed = 0;
		}
		self ent_flag_set( "is_moving" );
	}
}

convoy_get_count_moving()
{
	a_temp = level.convoy.vehicles;
	n_moving = 0;
	n_speed_threshold = 2;
	i = 0;
	while ( i < a_temp.size )
	{
		n_speed = a_temp[ i ] getspeedmph();
		if ( n_speed > n_speed_threshold )
		{
			a_temp[ i ] ent_flag_set( "is_moving" );
		}
		if ( a_temp[ i ] ent_flag( "is_moving" ) )
		{
			n_moving++;
		}
		i++;
	}
	return n_moving;
}

convoy_get_count_stopped()
{
	a_temp = level.convoy.vehicles;
	n_stopped = 0;
	n_speed_threshold = 2;
	i = 0;
	while ( i < a_temp.size )
	{
		if ( is_alive( a_temp[ i ] ) )
		{
			n_speed = a_temp[ i ] getspeedmph();
			if ( n_speed < n_speed_threshold )
			{
				a_temp[ i ] ent_flag_clear( "is_moving" );
			}
			if ( !a_temp[ i ] ent_flag( "is_moving" ) )
			{
				n_stopped++;
			}
		}
		i++;
	}
	return n_stopped;
}

convoy_get_path_node( node_or_string )
{
/#
	assert( isDefined( node_or_string ), "node_or_string is a required parameter for convoy_get_path_node!" );
#/
/#
	assert( isDefined( self.script_int ), "script int missing on convoy vehicle " + self.targetname );
#/
	a_nodes = getvehiclenodearray( node_or_string, "script_noteworthy" );
/#
	assert( a_nodes.size > 0, "convoy_get_path_node found no vehicle nodes with script noteworthy " + node_or_string );
#/
	n_my_int = self.script_int;
	b_found_node = 0;
	nd_path = undefined;
	i = 0;
	while ( i < a_nodes.size )
	{
		if ( a_nodes[ i ].script_int == n_my_int )
		{
			b_found_node = 1;
			nd_path = a_nodes[ i ];
		}
		i++;
	}
/#
	assert( b_found_node, "convoy_get_path_node found no nodes with script_int of " + n_my_int );
#/
	return nd_path;
}

convoy_vehicle_think_van( node_or_string )
{
/#
	assert( isDefined( node_or_string ), "node_or_string is a required parameter for convoy_vehicle_think_van!" );
#/
	self notify( "_convoy_vehicle_think_stop" );
	self endon( "_convoy_vehicle_think_stop" );
	self endon( "death" );
	if ( !isDefined( self.ent_flag[ "is_moving" ] ) )
	{
		self ent_flag_init( "is_moving" );
		self thread func_on_notify( "pacing_wait_for_convoy", ::stop_and_wait_for_flag, "roadblock_done", 30 );
		self thread func_on_notify( "dogfights_wait_for_convoy", ::stop_and_wait_for_flag, "dogfight_done", 30 );
	}
	if ( !isDefined( self.ent_flag[ "ignore_convoy_path" ] ) )
	{
		self ent_flag_init( "ignore_convoy_path" );
	}
	if ( isstring( node_or_string ) )
	{
		nd_path = convoy_get_path_node( node_or_string );
	}
	else
	{
		nd_path = node_or_string;
	}
	n_acceleration = 15;
	flag_wait( "player_flying" );
	self clearanim( %root, 0,2 );
	t_debris_trigger = get_ent( "player_inside_debris_cloud_trigger", "targetname", 1 );
	while ( level.player istouching( t_debris_trigger ) )
	{
		wait 0,1;
	}
	if ( is_greenlight_build() )
	{
		self setspeed( 0 );
		self hide();
	}
	self.drivepath = 1;
	self thread go_path( nd_path );
	self ent_flag_set( "is_moving" );
	s_check = getstruct( "player_out_of_intro", "targetname" );
	while ( self.origin[ 0 ] < s_check.origin[ 0 ] )
	{
		wait 0,05;
	}
	wait 1;
	if ( level.player.origin[ 0 ] < s_check.origin[ 0 ] )
	{
		self setspeed( 0 );
		while ( level.player.origin[ 0 ] < s_check.origin[ 0 ] )
		{
			wait 0,05;
		}
		self setspeed( 60 );
	}
	while ( 1 )
	{
		self ent_flag_wait( "ignore_convoy_path" );
		self waittill( "convoy_stop" );
/#
		println( self.targetname + " is stopping\n" );
#/
		self setspeed( 0 );
		self ent_flag_clear( "is_moving" );
		flag_wait_all( "convoy_can_move", "player_in_range_of_convoy", "convoy_in_position" );
/#
		println( self.targetname + " is moving\n" );
#/
		self setspeed( 60 );
		self ent_flag_set( "is_moving" );
	}
}

stop_and_wait_for_flag( str_flag, n_speed_resume )
{
	n_speed = 60;
	self setspeed( 0 );
	flag_wait( str_flag );
	self setspeed( n_speed );
}

_van_watch_for_notify( str_notify, func_on_notify, str_rejoin_convoy_vehicle_node )
{
/#
	assert( isDefined( str_notify ), "str_notify is a required parameter for _van_watch_for_notify" );
#/
/#
	assert( isDefined( func_on_notify ), "func_on_notify is a required parameter for _van_watch_for_notify" );
#/
/#
	assert( isDefined( str_rejoin_convoy_vehicle_node ), "str_rejoin_convoy_vehicle_node is a required parameter for _van_watch_for_notify" );
#/
	nd_rejoin_convoy = getvehiclenode( str_rejoin_convoy_vehicle_node, "targetname" );
/#
	assert( isDefined( nd_rejoin_convoy ), "nd_rejoin_convoy is missing for van_roadblock_behavior" );
#/
	self waittill( str_notify );
	self ent_flag_set( "ignore_convoy_path" );
	self [[ func_on_notify ]]();
	self ent_flag_clear( "ignore_convoy_path" );
	self setvehgoalpos( nd_rejoin_convoy.origin );
	self waittill_either( "goal", "near_goal" );
	self thread go_path( nd_rejoin_convoy );
}

van_roadblock_behavior()
{
	a_structs = get_struct_array( "roadblock_van_drive_points", "targetname", 1 );
	n_near_goal_dist = 256;
	n_wait_time_min = 2;
	n_wait_time_max = 4;
	n_wait_time_default = 0,5;
	self setneargoalnotifydist( n_near_goal_dist );
	s_drive_point_last = undefined;
	while ( !flag( "ground_targets_done" ) )
	{
		s_drive_point = random( a_structs );
		v_drive_point = s_drive_point.origin;
		b_can_path = bullettracepassed( self.origin, v_drive_point, 1, self );
		n_wait_time = n_wait_time_default;
		if ( !isDefined( s_drive_point_last ) )
		{
			s_drive_point_last = s_drive_point;
		}
		if ( isDefined( s_drive_point_last ) && s_drive_point == s_drive_point_last )
		{
			b_can_path = 0;
		}
		if ( b_can_path )
		{
			self setvehgoalpos( v_drive_point );
			self waittill_either( "near_goal", "goal" );
			n_wait_time = randomfloatrange( n_wait_time_min, n_wait_time_max );
			s_drive_point_last = s_drive_point;
		}
		wait n_wait_time;
	}
}

set_avoidance_for_time()
{
	self endon( "death" );
	if ( isDefined( self getvehicleavoidance() ) )
	{
		b_old_avoidance = self getvehicleavoidance();
	}
	self setvehicleavoidance( 1 );
	wait 10;
	self setvehicleavoidance( b_old_avoidance );
}

g20_1_death()
{
	if ( flag( "G20_1_saved" ) )
	{
		arrayremovevalue( level.convoy.vehicles, self );
		flag_set( "G20_1_dead" );
		convoy_set_leader();
	}
}

g20_2_death()
{
	if ( flag( "G20_2_saved" ) )
	{
		arrayremovevalue( level.convoy.vehicles, self );
		flag_set( "G20_2_dead" );
		convoy_set_leader();
	}
}

potus_death()
{
	if ( flag( "trenchruns_start" ) && !flag( "eject_sequence_started" ) )
	{
	}
	wait 1;
	if ( level.skipto_point != "f35_eject" )
	{
		setdvar( "ui_deadquote", &"LA_2_OBJ_PROTECT_FAIL" );
		missionfailed();
	}
}

convoy_stop_point_setup()
{
	level thread convoy_regroup_check();
}

convoy_regroup_check()
{
	while ( 1 )
	{
		flag_wait( "convoy_can_move" );
		n_vehicles = level.convoy.vehicles.size;
		n_vehicles_stopped = convoy_get_count_stopped();
		if ( n_vehicles == n_vehicles_stopped )
		{
			flag_set( "convoy_in_position" );
		}
		else
		{
			flag_clear( "convoy_in_position" );
		}
		wait 1;
	}
}

convoy_register_stop_point( str_trigger_name, str_wait_flag, func_on_trigger, param_1 )
{
/#
	assert( isDefined( str_trigger_name ), "str_trigger_name is a required parameter for convoy_register_stop_point" );
#/
/#
	assert( isDefined( str_wait_flag ), "str_wait_flag is a required parameter for convoy_register_stop_point" );
#/
	t_stop = get_ent( str_trigger_name, "targetname", 1 );
	t_stop _waittill_triggered_by_convoy();
	flag_clear( "convoy_can_move" );
/#
	println( str_trigger_name + " hit\n" );
#/
	if ( isDefined( func_on_trigger ) )
	{
		self [[ func_on_trigger ]]( param_1 );
	}
	flag_wait( str_wait_flag );
/#
	println( str_wait_flag + " = 1\n" );
#/
	flag_set( "convoy_can_move" );
	if ( isDefined( t_stop ) )
	{
		t_stop delete();
	}
}

_waittill_triggered_by_convoy( b_potus )
{
	if ( !isDefined( b_potus ) )
	{
		b_potus = 0;
	}
	b_is_convoy_vehicle = 0;
	while ( !b_is_convoy_vehicle )
	{
		self waittill( "trigger", e_triggered );
		i = 0;
		while ( i < level.convoy.vehicles.size )
		{
			if ( e_triggered == level.convoy.vehicles[ i ] )
			{
				b_is_convoy_vehicle = 1;
				if ( isDefined( b_potus ) && b_potus && e_triggered != level.convoy.vh_potus )
				{
					b_is_convoy_vehicle = 0;
				}
			}
			i++;
		}
	}
}

convoy_set_leader()
{
	level.convoy.vehicles = array_removedead( level.convoy.vehicles );
	if ( flag( "G20_1_saved" ) && !flag( "G20_1_dead" ) )
	{
		level.convoy.leader = level.convoy.vh_g20_1;
	}
	else
	{
		if ( flag( "G20_2_saved" ) && !flag( "G20_2_dead" ) )
		{
			level.convoy.leader = level.convoy.vh_g20_2;
			return;
		}
		else
		{
			level.convoy.leader = level.convoy.vh_potus;
		}
	}
}

convoy_get_leader()
{
	n_counter = 0;
	n_counter_threshold = 10;
	n_wait = 0,05;
	b_found_leader = 0;
	while ( !b_found_leader && n_counter < n_counter_threshold )
	{
		if ( isDefined( level.convoy.leader ) )
		{
			b_found_leader = 1;
			vh_leader = level.convoy.leader;
		}
		n_counter++;
	}
	return vh_leader;
}

convoy_pathing_start()
{
	flag_wait( "player_flying" );
	n_threshold = 16000;
	while ( distance2d( level.convoy.leader.origin, level.f35.origin ) > n_threshold )
	{
		wait 0,1;
	}
	flag_set( "convoy_movement_started" );
	level.convoy.lapd_escort[ 0 ] thread police_sirens();
	level.convoy.lapd_escort[ 1 ] thread police_sirens();
	level.convoy.lapd_escort[ 2 ] thread police_sirens();
	setmusicstate( "LA_2_ESCORT\t" );
	level clientnotify( "sgc" );
}

convoy_distance_check( n_distance, n_distance_warning_percentage )
{
	level notify( "convoy_distance_check_stop" );
	level endon( "convoy_distance_check_stop" );
/#
	assert( isDefined( n_distance ), "n_distance is a required parameter for convoy_distance_check" );
#/
	flag_wait( "convoy_movement_started" );
	if ( isDefined( n_distance_warning_percentage ) )
	{
		level.convoy.distance_warning_percentage = n_distance_warning_percentage;
	}
	level.convoy.distance_max = n_distance;
	n_counter = 0;
	n_counter_max = 6;
	n_distance_max = level.convoy.distance_max;
	level.convoy.distance_warning = n_distance_max * level.convoy.distance_warning_percentage;
	n_distance_warning = level.convoy.distance_warning;
	while ( !flag( "eject_sequence_started" ) )
	{
		n_delta = distance2d( level.f35.origin, level.convoy.vh_potus.origin );
		if ( n_delta > n_distance_warning )
		{
			flag_clear( "player_in_range_of_convoy" );
		}
		else
		{
			flag_set( "player_in_range_of_convoy" );
		}
		if ( n_delta > n_distance_max )
		{
			if ( !flag( "no_fail_from_distance" ) && !isgodmode( level.player ) )
			{
				level.convoy.vh_potus notify( "death" );
			}
		}
		wait 1;
	}
}

convoy_distance_check_update( n_distance, n_warning_distance_percentage )
{
/#
	assert( isDefined( level.convoy.distance_max ), "convoy_distance_check_update ran before convoy_distance_check" );
#/
	level.convoy.distance_max = n_distance;
	level.convoy.distance_warning_percentage = level.convoy.distance_warning_percentage_default;
	if ( isDefined( n_warning_distance_percentage ) )
	{
		level.convoy.distance_warning_percentage = n_warning_distance_percentage;
	}
	level thread convoy_distance_check( n_distance, n_warning_distance_percentage );
}

convoy_vehicle_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	should_flash = 0;
	if ( isplayer( eattacker ) )
	{
		should_flash = 1;
		if ( !isDefined( self.player_damage ) )
		{
			self.player_damage = 0;
		}
		else
		{
			if ( issubstr( sweapon, "missile_turret" ) )
			{
				self.player_damage += 200;
			}
			else
			{
				self.player_damage += 10;
			}
			if ( self.player_damage > 500 )
			{
				level.player thread maps/_friendlyfire::missionfail();
			}
		}
		idamage = 0;
	}
	else if ( isai( eattacker ) )
	{
		str_team = eattacker.team;
		if ( str_team == "allies" )
		{
			return 0;
		}
		else
		{
			if ( str_team == "axis" )
			{
				should_flash = 1;
			}
		}
	}
	else
	{
		if ( isDefined( eattacker.classname ) && eattacker.classname == "script_vehicle" )
		{
			if ( issubstr( eattacker.vehicletype, "cougar" ) || eattacker == level.convoy.vh_van )
			{
				should_flash = 0;
			}
			else
			{
				should_flash = 1;
			}
			idamage = 25;
			if ( issubstr( sweapon, "missile_turret" ) )
			{
				idamage = 200;
			}
			if ( self == level.convoy.vh_van )
			{
				idamage = 0;
			}
		}
	}
	if ( should_flash )
	{
		self thread convoy_vehicle_flash_damage();
	}
	if ( type == "MOD_CRUSH" )
	{
		idamage = 0;
	}
	self.armor -= idamage;
	if ( !flag( "eject_sequence_started" ) )
	{
		if ( ( self.armor - idamage ) <= 0 )
		{
			if ( !isgodmode( level.player ) )
			{
				self notify( "death" );
			}
		}
	}
	idamage = 1;
	return idamage;
}

convoy_vehicle_flash_damage()
{
	self notify( "start_convoy_vehicle_flash" );
	self endon( "start_convoy_vehicle_flash" );
	self clearclientflag( 14 );
	wait 0,1;
	self setclientflag( 14 );
}
