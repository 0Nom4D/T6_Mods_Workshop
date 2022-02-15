#include maps/_damagefeedback;
#include maps/_friendlyfire;
#include maps/_names;
#include maps/_drones_aipath;
#include maps/_spawner;
#include common_scripts/utility;
#include animscripts/shared;
#include animscripts/combat_utility;
#include animscripts/setposemovement;
#include animscripts/utility;
#include maps/_utility;

#using_animtree( "fakeshooters" );

init()
{
/#
	if ( getDvar( #"F7B30924" ) == "1" )
	{
		return;
#/
	}
	if ( !isDefined( level.drones ) )
	{
		level.drones = spawnstruct();
	}
	if ( !isDefined( level.drones.impact_fx ) )
	{
		effect = loadfx( "impacts/fx_flesh_hit" );
		drones_set_impact_effect( effect );
	}
	if ( !isDefined( level.drones.muzzleflash ) )
	{
		effect = loadfx( "weapon/muzzleflashes/fx_standard_flash" );
		drones_set_muzzleflash( effect );
	}
	level.drones.step_height = 100;
	level.drones.trace_height = 400;
	drones_init_max();
	drones_set_friendly_fire( 0 );
	drones_disable_sound( 0 );
	drones_set_max_ragdolls( 8 );
	set_anim_array();
	if ( !isDefined( level.drones.team ) )
	{
		level.drones.team = [];
	}
	if ( !isDefined( level.drones.team[ "axis" ] ) )
	{
		level.drones.team[ "axis" ] = struct_arrayspawn();
	}
	if ( !isDefined( level.drones.team[ "allies" ] ) )
	{
		level.drones.team[ "allies" ] = struct_arrayspawn();
	}
	init_ai_drone_spawners();
	flag_init( "drones_stop_looped_anims" );
	flag_init( "reached_drone_spawn_cap" );
	level.drones.max_per_frame = 10;
	level.drones.spawned_this_frame = 0;
	level thread reset_drone_throttle();
	level.drones.respawn_death_delay_min = 1;
	level.drones.respawn_death_delay_max = 3;
	level.drones.respawners = [];
	if ( !isDefined( level.drone_spawnfunction ) )
	{
		level.drone_spawnfunction[ "axis" ] = ::spawn_random_axis_drone;
		level.drone_spawnfunction[ "allies" ] = ::spawn_random_allies_drone;
	}
	level.drones.anim_idle[ 0 ] = %stand_alert_1;
	level.drones.anim_idle[ 1 ] = %stand_alert_2;
	level.drones.anim_idle[ 2 ] = %stand_alert_3;
	level.drones.funcs = [];
}

init_ai_drone_spawners()
{
	drone_spawners = getspawnerarray( "ai_drone_spawner", "targetname" );
	_a289 = drone_spawners;
	_k289 = getFirstArrayKey( _a289 );
	while ( isDefined( _k289 ) )
	{
		spawner = _a289[ _k289 ];
		level.drones.team[ spawner.script_string ].spawner = spawner;
		_k289 = getNextArrayKey( _a289, _k289 );
	}
}

drones_add_custom_func( str_func_name, func_custom )
{
/#
	assert( isDefined( str_func_name ), "str_func_name is a required parameter for drones_add_custom_func!" );
#/
/#
	assert( isDefined( func_custom ), "func_custom is a required parameter for drones_add_custom_func!" );
#/
	level.drones.funcs[ str_func_name ] = func_custom;
}

get_min_value( value, is_integer )
{
	values = strtok( value, " " );
/#
	assert( values.size > 0, "_drones a non-number value was encountered: "" + value + """ );
#/
	if ( !isDefined( is_integer ) )
	{
		is_integer = 1;
	}
	if ( isDefined( values[ 0 ] ) )
	{
		if ( is_integer )
		{
			return int( values[ 0 ] );
		}
		else
		{
			return float( values[ 0 ] );
		}
	}
	return undefined;
}

get_max_value( value, is_integer )
{
	values = strtok( value, " " );
/#
	assert( values.size > 0, "_drones a non-number value was encountered: "" + value + """ );
#/
	if ( !isDefined( is_integer ) )
	{
		is_integer = 1;
	}
	if ( values.size > 1 )
	{
		if ( is_integer )
		{
			return int( values[ 1 ] );
		}
		else
		{
			return float( values[ 1 ] );
		}
	}
	else
	{
		if ( values.size == 1 )
		{
			if ( is_integer )
			{
				return int( values[ 0 ] );
			}
			else
			{
				return float( values[ 0 ] );
			}
		}
	}
	return undefined;
}

drones_system_initialized()
{
	if ( isDefined( level.drones ) )
	{
		if ( isDefined( level.drones.team ) )
		{
			return 1;
		}
	}
	return 0;
}

drones_get_trigger_from_script_string( script_string_name )
{
	drone_trigger = undefined;
	i = 0;
	while ( i < 2 )
	{
		if ( !i )
		{
			drone_trigger_array = getentarray( "drone_axis", "targetname" );
		}
		else
		{
			drone_trigger_array = getentarray( "drone_allies", "targetname" );
		}
		while ( isDefined( drone_trigger_array ) )
		{
			j = 0;
			while ( j < drone_trigger_array.size )
			{
				e_ent = drone_trigger_array[ j ];
				if ( isDefined( e_ent.script_string ) && e_ent.script_string == script_string_name )
				{
					drone_trigger = drone_trigger_array[ j ];
					i++;
					continue;
				}
				else
				{
					j++;
				}
			}
		}
		i++;
	}
	return drone_trigger;
}

drones_get_data_from_script_string( script_string_name )
{
	_a471 = level.drones.drone_spawners;
	_k471 = getFirstArrayKey( _a471 );
	while ( isDefined( _k471 ) )
	{
		s_data = _a471[ _k471 ];
		if ( isDefined( s_data.script_string ) && s_data.script_string == script_string_name )
		{
			return s_data;
		}
		_k471 = getNextArrayKey( _a471, _k471 );
	}
	return undefined;
}

drones_init_max()
{
	max_drones = 64;
	if ( issplitscreen() )
	{
		max_drones = 16;
	}
	if ( isDefined( level.drones.max_drones ) )
	{
		max_drones = level.drones.max_drones;
	}
	drones_set_max( max_drones );
}

drones_set_max( max_drones )
{
	if ( !isDefined( level.drones ) )
	{
		level.drones = spawnstruct();
	}
	level.drones.max_drones = max_drones;
}

drones_set_impact_effect( effect_handle )
{
	if ( !isDefined( level.drones ) )
	{
		level.drones = spawnstruct();
	}
	level.drones.impact_fx = effect_handle;
}

drones_set_muzzleflash( effect_handle )
{
	if ( !isDefined( level.drones ) )
	{
		level.drones = spawnstruct();
	}
	level.drones.muzzleflash = effect_handle;
}

drones_set_friendly_fire( friendly_fire )
{
	level.drones.friendly_fire = friendly_fire;
}

drones_disable_sound( disable_sound )
{
	level.drones.sounds_disabled = disable_sound;
}

save_target_links()
{
	_a600 = self.a_targeted;
	_k600 = getFirstArrayKey( _a600 );
	while ( isDefined( _k600 ) )
	{
		s_child = _a600[ _k600 ];
		if ( isDefined( s_child.target ) && !isDefined( s_child.a_targeted ) )
		{
			s_child.a_targeted = level.struct_class_names[ "targetname" ][ s_child.target ];
			s_child save_target_links();
		}
		_k600 = getNextArrayKey( _a600, _k600 );
	}
}

drones_setup_spawner( is_trigger )
{
	data = drones_get_spawner( self.targetname, self.target );
	if ( is_trigger )
	{
		data.parent_trigger = self;
	}
	else
	{
		data.parent_script_struct = self;
	}
	data.dr_group = self.dr_group;
	data.dr_need_player = self.dr_need_player;
	data.dr_player_trace = self.dr_player_trace;
	data.dr_populate = self.dr_populate;
	data.dr_respawn = self.dr_respawn;
	if ( isDefined( self.dr_delay ) )
	{
		data.n_delay_min = get_min_value( self.dr_delay, 0 );
		data.n_delay_max = get_max_value( self.dr_delay, 0 );
	}
	if ( isDefined( self.dr_wait ) )
	{
		data.n_wait_min = get_min_value( self.dr_wait, 0 );
		data.n_wait_max = get_max_value( self.dr_wait, 0 );
	}
	if ( isDefined( self.dr_wave_count ) )
	{
		data.n_wave_count_min = get_min_value( self.dr_wave_count );
		data.n_wave_count_max = get_max_value( self.dr_wave_count );
	}
	if ( isDefined( self.dr_wave_size ) )
	{
		data.n_wave_size_min = get_min_value( self.dr_wave_size );
		data.n_wave_size_max = get_max_value( self.dr_wave_size );
	}
	data.script_allowdeath = self.script_allowdeath;
	data.script_int = self.script_int;
	data.script_ender = self.script_ender;
	data.script_noteworthy = self.script_noteworthy;
	data.script_string = self.script_string;
	data.weaponinfo = self.weaponinfo;
	level thread drone_spawner_wait_for_activation( data );
	return data;
}

drones_get_spawner( targetname, target )
{
	data = spawnstruct();
	data.parent_trigger = undefined;
	data.parent_script_struct = undefined;
	if ( isDefined( target ) )
	{
		data.a_targeted = getstructarray( target, "targetname" );
	}
/#
	assert( isDefined( data.a_targeted ) );
#/
/#
	assert( isDefined( data.a_targeted[ 0 ] ) );
#/
	data save_target_links();
	if ( targetname == "drone_allies" )
	{
		data.team = "allies";
	}
	else
	{
		data.team = "axis";
	}
	data.paused = 1;
	data.drone_run_cycle_override = undefined;
	data.speed_modifier_min = undefined;
	data.speed_modifier_max = undefined;
	data.delete_spawner = 0;
	level.drones.drone_spawners[ level.drones.drone_spawners.size ] = data;
	return data;
}

drone_spawner_wait_for_activation( drones )
{
	if ( isDefined( drones.script_ender ) )
	{
		level endon( drones.script_ender );
	}
	if ( isDefined( drones.parent_trigger ) )
	{
		drones.parent_trigger endon( "death" );
		drones.parent_trigger waittill( "trigger" );
		drones.paused = 0;
	}
	else
	{
		drones.parent_script_struct waittill( "trigger" );
		drones.paused = 0;
	}
	level thread drone_spawner_active( drones );
}

drone_spawner_active( drones )
{
	repeat_times = 9999999;
	if ( isDefined( drones.n_wave_count_min ) )
	{
		repeat_times = randomintrange( drones.n_wave_count_min, drones.n_wave_count_max + 1 );
	}
	spawn_min = 1;
	spawn_max = spawn_min;
	if ( isDefined( drones.n_wave_size_min ) )
	{
		spawn_min = drones.n_wave_size_min;
	}
	if ( isDefined( drones.n_wave_size_max ) )
	{
		spawn_max = drones.n_wave_size_max;
	}
	if ( isDefined( drones.parent_trigger ) )
	{
		drones.parent_trigger endon( "stop_drone_loop" );
	}
	if ( isDefined( drones.n_delay_min ) )
	{
		wait randomfloatrange( drones.n_delay_min, drones.n_delay_max );
	}
	if ( isDefined( drones.dr_populate ) && drones.dr_populate )
	{
		level thread pre_populate_drones( drones, spawn_min, spawn_max, drones.team );
		wait_time = get_drone_spawn_wait( drones );
		wait wait_time;
	}
	i = 0;
	while ( i < repeat_times )
	{
		if ( drones.delete_spawner )
		{
			return;
		}
		level notify( "new drone Spawn wave" );
		spawn_size = spawn_min;
		if ( spawn_max > spawn_min )
		{
			spawn_size = randomintrange( spawn_min, spawn_max + 1 );
		}
		level thread drone_spawngroup( drones, drones.a_targeted, spawn_size, drones.team, 0 );
		respawn_wait_loop = 1;
		while ( respawn_wait_loop )
		{
			delay = get_drone_spawn_wait( drones );
			wait delay;
			if ( !drones_respawner_used( drones ) )
			{
				respawn_wait_loop = 0;
			}
		}
		if ( isDefined( drones.parent_trigger ) )
		{
			if ( isDefined( drones.parent_trigger.dr_need_player ) && drones.parent_trigger.dr_need_player )
			{
				drones.parent_trigger waittill( "trigger" );
			}
		}
		while ( drones.paused )
		{
			wait 1;
		}
		i++;
	}
}

get_drone_spawn_wait( drone_data )
{
	min_spawn_wait = 1;
	max_spawn_wait = 1;
	if ( isDefined( drone_data.n_wait_min ) )
	{
		min_spawn_wait = drone_data.n_wait_min;
		max_spawn_wait = drone_data.n_wait_max;
	}
	if ( max_spawn_wait > min_spawn_wait )
	{
		return randomfloatrange( min_spawn_wait, max_spawn_wait );
	}
	return min_spawn_wait;
}

drone_spawngroup( drones, spawnpoint, spawnsize, team, start_ahead )
{
	spawncount = spawnpoint.size;
	if ( isDefined( spawnsize ) )
	{
		spawncount = spawnsize;
		spawnpoint = array_randomize( spawnpoint );
	}
	if ( spawncount > spawnpoint.size && spawnpoint.size > 1 )
	{
		spawncount = spawnpoint.size;
	}
	offsets = [];
	if ( isDefined( drones.dr_group ) && drones.dr_group )
	{
		offsets = generate_offsets( spawncount );
	}
	i = 0;
	while ( i < spawncount )
	{
		if ( isDefined( drones.script_int ) )
		{
			wait randomfloatrange( 0,1, 1 );
		}
		while ( isDefined( drones.parent_trigger ) )
		{
			while ( !drones.parent_trigger ok_to_trigger_spawn() )
			{
				wait_network_frame();
			}
		}
		if ( i < spawnpoint.size )
		{
			spawnpoint[ i ] thread drone_spawn( team, offsets[ i ], start_ahead, drones );
		}
		else
		{
			if ( i > 0 && offsets[ i - 1 ] == offsets[ i ] )
			{
				wait randomfloatrange( 0,8, 1,1 );
			}
			else
			{
				wait randomfloatrange( 0,5, 0,9 );
			}
			spawnpoint[ spawnpoint.size - 1 ] thread drone_spawn( team, offsets[ i ], start_ahead, drones );
		}
		level._numtriggerspawned++;
		i++;
	}
}

drones_respawner_created( drone_struct )
{
	i = 0;
	while ( i < level.drones.respawners.size )
	{
		if ( level.drones.respawners[ i ] == drone_struct )
		{
			return;
		}
		i++;
	}
	trigger_alive = 0;
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		spawner = level.drones.drone_spawners[ i ];
		j = 0;
		while ( j < spawner.a_targeted.size )
		{
			if ( spawner.a_targeted[ j ] == drone_struct )
			{
				trigger_alive = 1;
				i++;
				continue;
			}
			else
			{
				j++;
			}
		}
		i++;
	}
	if ( trigger_alive )
	{
		level.drones.respawners[ level.drones.respawners.size ] = drone_struct;
	}
}

drones_respawner_used( drone_spawner )
{
	drone_structs = drone_spawner.a_targeted;
	i = 0;
	while ( i < drone_structs.size )
	{
		struct = drone_structs[ i ];
		j = 0;
		while ( j < level.drones.respawners.size )
		{
			if ( level.drones.respawners[ j ] == struct )
			{
				arrayremovevalue( level.drones.respawners, struct );
				return 1;
			}
			j++;
		}
		i++;
	}
	return 0;
}

generate_offsets( spawncount )
{
	offsets = [];
	delta = 0,5 / spawncount;
	i = 0;
	while ( i < spawncount )
	{
		id = randomint( spawncount * 2 );
		offsets[ i ] = id * delta;
		i++;
	}
	return offsets;
}

drone_spawn( team, leader_ent_num, offset, drones, check_path_near_player )
{
	total_drones = level.drones.team[ "axis" ].array.size + level.drones.team[ "allies" ].array.size;
	if ( total_drones >= level.drones.max_drones )
	{
		return;
	}
	if ( level.ai_drone_paths[ leader_ent_num ].size <= 1 )
	{
		return;
	}
	spawnpos = level.ai_drone_paths[ leader_ent_num ][ 1 ];
	if ( level.player is_looking_at( spawnpos, 0,45, 1 ) )
	{
		return;
	}
	while ( isDefined( check_path_near_player ) && check_path_near_player )
	{
		i = 1;
		while ( i < level.ai_drone_paths[ leader_ent_num ].size )
		{
			if ( distance2dsquared( level.player.origin, level.ai_drone_paths[ leader_ent_num ][ i ] ) < ( 360 * 360 ) )
			{
				return;
			}
			i++;
		}
	}
	if ( isDefined( self.radius ) )
	{
		angles = ( 0, 0, 1 );
		if ( isDefined( self.angles ) )
		{
			angles = self.angles;
		}
		right = anglesToRight( angles );
		spawnpos += vectorScale( right, 0 * self.radius );
	}
	level.drones.spawned_this_frame++;
	guy = spawn( "script_model", bullettrace( spawnpos, spawnpos + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self )[ "position" ] );
	guy.dronerunoffset = 0;
	guy.team = team;
	if ( isDefined( self.angles ) )
	{
		guy.angles = self.angles;
	}
	else
	{
		if ( isDefined( self.a_targeted ) )
		{
			guy.angles = vectorToAngle( self.a_targeted[ 0 ].origin - guy.origin );
		}
	}
/#
	assert( isDefined( level.drone_spawnfunction[ team ] ) );
#/
	guy thread drone_think();
	drone_spawner = level.drones.team[ team ].spawner;
	guy [[ level.drone_spawnfunction[ team ] ]]();
	guy maps/_drones_aipath::drone_assign_weapon( team, drone_spawner );
	guy.targetname = "drone";
	guy.dronerunoffset = randomintrange( -240, 240 );
	guy makefakeai();
	guy.team = team;
	guy useanimtree( -1 );
	if ( isDefined( drones ) && isDefined( drones.drone_run_cycle_override ) )
	{
		guy.drone_run_cycle_override = drones.drone_run_cycle_override;
	}
	guy maps/_drones_aipath::drone_set_run_cycle();
	if ( isDefined( level.drone_run_rate ) )
	{
		guy.dronerunrate = level.drone_run_rate;
	}
	else if ( isDefined( drones ) && isDefined( drones.speed_modifier_min ) && isDefined( drones.speed_modifier_max ) )
	{
		modifier = 1 + randomfloatrange( drones.speed_modifier_min, drones.speed_modifier_max );
		guy.dronerunrate *= modifier;
	}
	else
	{
		if ( isDefined( level.drone_run_rate_multiplier ) )
		{
			guy.dronerunrate *= level.drone_run_rate_multiplier;
		}
	}
	guy.path_index = 1;
	guy thread maps/_drones_aipath::drone_runchain_array( leader_ent_num );
}

get_drone_spawn_pos( required_distance )
{
	node = self;
	spawn_pos = node.origin;
	level.drones.new_target_node = undefined;
	if ( required_distance == 0 || !isDefined( node.target ) )
	{
		return spawn_pos;
	}
	next_node = node;
	dist_so_far = 0;
	while ( dist_so_far < required_distance )
	{
		if ( !isDefined( node.target ) )
		{
			return spawn_pos;
		}
		next_node = getstruct( node.target, "targetname" );
		dir = next_node.origin - node.origin;
		dir_norm = vectornormalize( dir );
		dist_to_next_node = distance( node.origin, next_node.origin );
		if ( ( dist_so_far + dist_to_next_node ) > required_distance )
		{
			frac = ( required_distance - dist_so_far ) / dist_to_next_node;
			spawn_pos += dir * frac;
			break;
		}
		else
		{
			dist_so_far += dist_to_next_node;
			spawn_pos += dir;
			level.drones.new_target_node = next_node;
			node = next_node;
		}
	}
	return spawn_pos;
}

drone_assign_weapon( team, drones )
{
	if ( isDefined( drones.weaponinfo ) )
	{
		self setcurrentweapon( drones.weaponinfo );
	}
	else if ( team == "allies" )
	{
		if ( isDefined( level.drone_weaponlist_allies ) && level.drone_weaponlist_allies.size > 0 )
		{
			if ( level.drone_weaponlist_allies[ 0 ] == "unarmed" )
			{
				self setcurrentweapon( undefined );
				return;
			}
			randweapon = randomint( level.drone_weaponlist_allies.size );
			self setcurrentweapon( level.drone_weaponlist_allies[ randweapon ] );
/#
			assert( isDefined( self.weapon ), "_drones::couldn't assign weapon from level.drone_weaponlist because the array value is undefined." );
#/
		}
	}
	else
	{
		if ( isDefined( level.drone_weaponlist_axis ) && level.drone_weaponlist_axis.size > 0 )
		{
			randweapon = randomint( level.drone_weaponlist_axis.size );
			self setcurrentweapon( level.drone_weaponlist_axis[ randweapon ] );
/#
			assert( isDefined( self.weapon ), "_drones::couldn't assign weapon from level.drone_weaponlist because the array value is undefined." );
#/
		}
	}
	if ( self.weapon != "none" )
	{
		self attach( self.weaponmodel, "tag_weapon_right" );
		self useweaponhidetags( self.weapon );
		self.bulletsinclip = weaponclipsize( self.weapon );
	}
}

drone_allies_assignweapon_american()
{
	array = [];
	array[ array.size ] = "m16_sp";
	return array[ randomint( array.size ) ];
}

drone_allies_assignweapon_british()
{
	array = [];
	array[ array.size ] = "m16_sp";
	return array[ randomint( array.size ) ];
}

drone_allies_assignweapon_russian()
{
	array = [];
	array[ array.size ] = "ak47_sp";
	return array[ randomint( array.size ) ];
}

drone_axis_assignweapon_german()
{
	array = [];
	array[ array.size ] = "ak47_sp";
	return array[ randomint( array.size ) ];
}

drone_axis_assignweapon_japanese()
{
	array = [];
	array[ array.size ] = "ak47_sp";
	return array[ randomint( array.size ) ];
}

check_drone_throttle()
{
	can_spawn = 0;
	while ( !can_spawn )
	{
		if ( level.drones.spawned_this_frame > level.drones.max_per_frame )
		{
			flag_set( "reached_drone_spawn_cap" );
		}
		flag_waitopen( "reached_drone_spawn_cap" );
		wait 0,05;
		if ( level.drones.spawned_this_frame < level.drones.max_per_frame )
		{
			can_spawn = 1;
		}
	}
}

reset_drone_throttle()
{
	while ( 1 )
	{
		waittillframeend;
		flag_clear( "reached_drone_spawn_cap" );
		level.drones.spawned_this_frame = 0;
		wait 0,05;
	}
}

drone_respawn_after_death( guy, start_struct, team, offset, ender, drones )
{
	min_respawn_time = level.drones.respawn_death_delay_min;
	max_respawn_time = level.drones.respawn_death_delay_max;
	if ( isDefined( ender ) )
	{
		level endon( ender );
	}
	guy waittill( "death" );
	wait randomfloatrange( min_respawn_time, max_respawn_time );
	drones_respawner_created( start_struct );
	start_struct thread drone_spawn( team, offset, 0, drones );
}

spawnpoint_playersview()
{
	if ( !isDefined( level.cos80 ) )
	{
		level.cos80 = cos( 80 );
	}
	players = get_players();
	player_view_count = 0;
	success = 0;
	i = 0;
	while ( i < players.size )
	{
		forwardvec = anglesToForward( players[ i ].angles );
		normalvec = vectornormalize( self.origin - players[ i ] getorigin() );
		vecdot = vectordot( forwardvec, normalvec );
		if ( vecdot > level.cos80 )
		{
			success = bullettracepassed( players[ i ] geteye(), self.origin + vectorScale( ( 0, 0, 1 ), 48 ), 0, self );
			if ( success )
			{
				player_view_count++;
			}
		}
		i++;
	}
	if ( player_view_count != 0 )
	{
		return 1;
	}
	return 0;
}

drone_setname()
{
	self endon( "drone_death" );
	wait 0,25;
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( self.team != "allies" )
	{
		return;
	}
	if ( !isDefined( level.names ) )
	{
		maps/_names::setup_names();
	}
	if ( isDefined( self.script_friendname ) )
	{
		self.name = self.script_friendname;
	}
	else
	{
		self maps/_names::get_name();
	}
/#
	assert( isDefined( self.name ) );
#/
	subtext = undefined;
	if ( !isDefined( self.weapon ) )
	{
		subtext = &"";
		break;
}
else switch( self.weapon )
{
	case "commando_sp":
		subtext = &"";
		break;
	case "SVT40":
	case "lee_enfield":
	case "m1carbine":
	case "m1garand":
	case "m1garand_wet":
	case "mosin_rifle":
		subtext = &"WEAPON_RIFLEMAN";
		break;
	case "thompson":
	case "thompson_wet":
		subtext = &"WEAPON_SUBMACHINEGUNNER";
		break;
	case "BAR":
	case "ppsh":
	default:
		subtext = &"WEAPON_SUPPORTGUNNER";
		break;
}
if ( isDefined( self.model ) && issubstr( self.model, "medic" ) )
{
	subtext = &"WEAPON_MEDICPLACEHOLDER";
}
/#
assert( isDefined( subtext ) );
#/
self setlookattext( self.name, &"" );
}

drone_think()
{
	self endon( "death" );
	self.health = 100;
	self thread drone_setname();
	if ( self.team == "allies" && level.drones.friendly_fire )
	{
		level thread maps/_friendlyfire::friendly_fire_think( self );
	}
	self thread drones_clear_variables();
	structarray_add( level.drones.team[ self.team ], self );
	level notify( "new_drone" );
	if ( isDefined( level.drones_mg_target ) )
	{
		self.turrettarget = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 50 ) );
		self.turrettarget linkto( self );
	}
	self endon( "drone_death" );
	if ( isDefined( level.drones.think_func ) )
	{
		self thread [[ level.drones.think_func ]]();
	}
	if ( !is_false( self.script_allowdeath ) )
	{
		if ( isDefined( level.drones.death_func ) )
		{
			self thread [[ level.drones.death_func ]]();
		}
		else
		{
			self thread drone_fakedeath();
		}
	}
	self.no_death_sink = 0;
	wait 0,05;
	self.running = undefined;
	level notify( "drone_at_last_node" );
}

drone_loop_anim( s_reference )
{
	self endon( "death" );
	self endon( "drone_death" );
	if ( !isDefined( s_reference.target ) )
	{
		if ( isDefined( s_reference.dr_animation ) && isDefined( level.drones.anims[ s_reference.dr_animation ] ) )
		{
			if ( isarray( level.drones.anims[ s_reference.dr_animation ] ) )
			{
				anim_idle[ 0 ] = random( level.drones.anims[ s_reference.dr_animation ] );
			}
			else
			{
				anim_idle[ 0 ] = level.drones.anims[ s_reference.dr_animation ];
			}
		}
	}
	if ( !isDefined( anim_idle ) )
	{
		while ( isDefined( self ) )
		{
			self animscripted( "drone_idle_anim", self.origin, self.angles, level.drones.anim_idle[ randomint( level.drones.anim_idle.size ) ] );
			self waittillmatch( "drone_idle_anim" );
			return "end";
		}
	}
	else while ( isDefined( self ) )
	{
		self animscripted( "drone_idle_anim", self.origin, self.angles, anim_idle[ randomint( anim_idle.size ) ] );
		self waittillmatch( "drone_idle_anim" );
		return "end";
	}
}

drone_mortardeath( direction )
{
	self useanimtree( -1 );
	switch( direction )
	{
		case "up":
			self thread drone_dodeath( %death_explosion_up10 );
			break;
		case "forward":
			self thread drone_dodeath( %death_explosion_forward13 );
			break;
		case "back":
			self thread drone_dodeath( %death_explosion_back13 );
			break;
		case "left":
			self thread drone_dodeath( %death_explosion_left11 );
			break;
		case "right":
			self thread drone_dodeath( %death_explosion_right13 );
			break;
	}
}

drone_flamedeath()
{
	self useanimtree( -1 );
	self thread drone_fakedeath( 1, 1 );
}

drone_fakedeath( instant, flamedeath )
{
	if ( !isDefined( instant ) )
	{
		instant = 0;
	}
	self endon( "delete" );
	self endon( "drone_death" );
	while ( isDefined( self ) )
	{
		if ( !instant )
		{
			self setcandamage( 1 );
			self waittill( "damage" );
			if ( type != "MOD_GRENADE" && type != "MOD_GRENADE_SPLASH" && type != "MOD_EXPLOSIVE" && type != "MOD_EXPLOSIVE_SPLASH" || type == "MOD_PROJECTILE" && type == "MOD_PROJECTILE_SPLASH" )
			{
				self.damageweapon = "none";
				explosivedeath = 1;
			}
			else
			{
				if ( type == "MOD_BURNED" )
				{
					flamedeath = 1;
					break;
				}
				else
				{
					if ( isDefined( attacker.vehicletype ) && attacker.vehicletype != "horse_player" && attacker.vehicletype != "horse" && attacker.vehicletype != "horse_player_low" && attacker.vehicletype == "horse_low" && type == "MOD_CRUSH" )
					{
						if ( isDefined( attacker.driver ) && isplayer( attacker.driver ) )
						{
							attacker.driver playrumbleonentity( "damage_heavy" );
							attacker.driver playsound( "evt_horse_trample_ai" );
							if ( self.team == "axis" )
							{
								level notify( "player_trampled_ai_with_horse" );
							}
						}
					}
				}
			}
			self death_notify_wrapper( attacker, type );
			if ( self.team == "axis" && !isplayer( attacker ) || attacker == level.playervehicle && isDefined( attacker.driver ) && isplayer( attacker.driver ) )
			{
				level notify( "player killed drone" );
				level.player thread maps/_damagefeedback::updatedamagefeedback();
			}
		}
		if ( !isDefined( self ) )
		{
			return;
		}
		self notify( "stop_shooting" );
		self.dontdelete = 1;
		self useanimtree( -1 );
		if ( isDefined( explosivedeath ) && explosivedeath && isDefined( level.disable_drone_explosive_deaths ) && !level.disable_drone_explosive_deaths )
		{
			direction = drone_get_explosion_death_dir( self.origin, self.angles, damage_ori, 50 );
			self thread drone_mortardeath( direction );
			return;
		}
		else
		{
			if ( isDefined( flamedeath ) && flamedeath )
			{
				deaths[ 0 ] = %ai_flame_death_a;
				deaths[ 1 ] = %ai_flame_death_b;
				deaths[ 2 ] = %ai_flame_death_c;
				deaths[ 3 ] = %ai_flame_death_d;
				break;
			}
			else
			{
				if ( isDefined( self.running ) )
				{
					deaths[ 0 ] = %run_death_facedown;
					deaths[ 1 ] = %run_death_fallonback;
					deaths[ 2 ] = %run_death_roll;
					deaths[ 3 ] = %run_death_flop;
					break;
				}
				else
				{
					deaths[ 0 ] = %ai_death_collapse_in_place;
					deaths[ 1 ] = %ai_death_faceplant;
					deaths[ 2 ] = %ai_death_fallforward;
					deaths[ 3 ] = %ai_death_fallforward_b;
				}
			}
		}
		self thread drone_dodeath( deaths[ randomint( deaths.size ) ] );
		return;
	}
}

drone_delayed_bulletdeath( waittime )
{
	if ( !isDefined( waittime ) )
	{
		waittime = 0;
	}
	self endon( "delete" );
	self endon( "drone_death" );
	self.dontdelete = 1;
	if ( waittime > 0 )
	{
		wait waittime;
	}
	self thread drone_fakedeath( 1 );
}

do_death_sound()
{
	camp = level.campaign;
	team = self.team;
	alias = undefined;
	if ( camp == "american" && team == "allies" )
	{
		alias = "dds_generic_death_american";
	}
	if ( camp == "american" && team == "axis" )
	{
		alias = "dds_generic_death_japanese";
	}
	if ( camp == "russian" && team == "allies" )
	{
		alias = "dds_generic_death_russian";
	}
	if ( camp == "russian" && team == "axis" )
	{
		alias = "dds_generic_death_german";
	}
	if ( camp == "vietnamese" && team == "axis" )
	{
		alias = "dds_generic_death_vietnamese ";
	}
	if ( isDefined( alias ) && soundexists( alias ) && !level.drones.sounds_disabled )
	{
		self thread play_sound_in_space( alias );
	}
}

drone_dodeath( deathanim, deathremovenotify )
{
	self endon( "delete" );
	if ( is_true( self.dead ) )
	{
		return;
	}
	else
	{
		self.dead = 1;
	}
	self moveto( self.origin, 0,05, 0, 0 );
	tracedeath = 0;
	if ( isDefined( self.running ) && self.running )
	{
		tracedeath = 1;
	}
	self.running = undefined;
	self notify( "drone_death" );
	self notify( "stop_shooting" );
	self unlink();
	self useanimtree( -1 );
	self thread drone_dodeath_impacts();
	do_death_sound();
	cancelrunningdeath = 0;
	if ( tracedeath )
	{
		offset = getcycleoriginoffset( self.angles, deathanim );
		endanimationlocation = self.origin + offset;
		endanimationlocation = physicstrace( endanimationlocation + vectorScale( ( 0, 0, 1 ), 128 ), endanimationlocation - vectorScale( ( 0, 0, 1 ), 128 ) );
		d1 = abs( endanimationlocation[ 2 ] - self.origin[ 2 ] );
		if ( d1 > 20 )
		{
			cancelrunningdeath = 1;
		}
		else
		{
			forwardvec = anglesToForward( self.angles );
			rightvec = anglesToRight( self.angles );
			upvec = anglesToUp( self.angles );
			relativeoffset = vectorScale( ( 0, 0, 1 ), 50 );
			secondpos = endanimationlocation;
			secondpos += vectorScale( forwardvec, relativeoffset[ 0 ] );
			secondpos += vectorScale( rightvec, relativeoffset[ 1 ] );
			secondpos += vectorScale( upvec, relativeoffset[ 2 ] );
			secondpos = physicstrace( secondpos + vectorScale( ( 0, 0, 1 ), 128 ), secondpos - vectorScale( ( 0, 0, 1 ), 128 ) );
			d2 = abs( secondpos[ 2 ] - self.origin[ 2 ] );
			if ( d2 > 20 )
			{
				cancelrunningdeath = 1;
			}
		}
	}
	if ( cancelrunningdeath )
	{
		deathanim = %ai_death_fallforward;
	}
	self animscripted( "drone_death_anim", self.origin, self.angles, deathanim, "deathplant" );
	self thread drone_drop_weapon( "drone_death_anim", deathanim );
	self thread drone_ragdoll( deathanim );
	self waittillmatch( "drone_death_anim" );
	return "end";
	if ( !isDefined( self ) )
	{
		return;
	}
	self setcontents( 0 );
	if ( isDefined( deathremovenotify ) )
	{
		level waittill( deathremovenotify );
	}
	else
	{
		wait 3;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.no_death_sink ) || isDefined( self.no_death_sink ) && !self.no_death_sink )
	{
		self moveto( self.origin - vectorScale( ( 0, 0, 1 ), 100 ), 7 );
		wait 3;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	self.dontdelete = undefined;
	self thread drone_delete( 10 );
}

drone_drop_weapon( drone_death_anim_flag, deathanim )
{
	if ( animhasnotetrack( deathanim, "dropgun" ) )
	{
		self waittillmatch( drone_death_anim_flag );
		return "dropgun";
	}
	else
	{
		wait 0,2;
	}
	if ( isDefined( self.weapon ) )
	{
		if ( isDefined( self.weaponmodel ) && self.weaponmodel != "" )
		{
			self detach( self.weaponmodel, "tag_weapon_right" );
		}
	}
}

drone_ragdoll( deathanim )
{
	time = self getanimtime( deathanim );
	wait ( time * 0,55 );
	if ( isDefined( level.no_drone_ragdoll ) && level.no_drone_ragdoll == 1 )
	{
	}
	else
	{
		if ( self drone_available_ragdoll() )
		{
			self add_to_ragdoll_bucket();
		}
	}
}

drone_dodeath_impacts()
{
	self endon( "death" );
	self endon( "drone_death" );
	bone[ 0 ] = "J_Knee_LE";
	bone[ 1 ] = "J_Ankle_LE";
	bone[ 2 ] = "J_Clavicle_LE";
	bone[ 3 ] = "J_Shoulder_LE";
	bone[ 4 ] = "J_Elbow_LE";
	impacts = 1 + randomint( 2 );
	i = 0;
	while ( i < impacts )
	{
		playfxontag( level.drones.impact_fx, self, bone[ randomint( bone.size ) ] );
		if ( !level.drones.sounds_disabled )
		{
			self playsound( "prj_bullet_impact_small_flesh" );
		}
		wait 0,05;
		i++;
	}
}

drone_runchain_array( leader_ent_num )
{
	self endon( "death" );
	self endon( "drone_death" );
	self.v_destination = undefined;
	while ( isDefined( self ) )
	{
		if ( self.path_index == ( level.ai_drone_paths[ leader_ent_num ].size - 1 ) )
		{
			if ( isDefined( level.specific_drone_death ) )
			{
				self thread [[ level.specific_drone_death ]]();
			}
			else
			{
				self thread drone_delete();
			}
			break;
		}
		else
		{
			self.v_destination = level.ai_drone_paths[ leader_ent_num ][ self.path_index + 1 ];
			pathvec = self.v_destination - level.ai_drone_paths[ leader_ent_num ][ self.path_index + 1 ];
			pathvec = vectorToAngle( pathvec );
			offsetvec = anglesToRight( pathvec ) * self.dronerunoffset;
			self.v_destination += offsetvec;
			self process_event_aipath( level.ai_drone_paths[ leader_ent_num ][ self.path_index ] );
			randomanimrate = 0,9 + randomfloat( 1,1 - 0,9 );
			self thread drone_loop_run_anim( randomanimrate );
			self drone_runto();
			self.path_index++;
			point_start = level.ai_drone_paths[ leader_ent_num ][ self.path_index ];
		}
	}
	self process_event_aipath( point_start );
}

drone_line_goal()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( self.v_destination ) )
		{
			line( self.origin + vectorScale( ( 0, 0, 1 ), 72 ), self.v_destination );
			print3d( self.origin + vectorScale( ( 0, 0, 1 ), 72 ), self.path_index );
		}
		wait 0,05;
#/
	}
}

drone_line_path( vec_start, vec_end )
{
/#
	while ( 1 )
	{
		line( vec_start, vec_end );
		wait 0,05;
#/
	}
}

process_event_aipath( s_start )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self endon( "death" );
	self endon( "drone_death" );
	self notify( "stop_shooting" );
	self useanimtree( -1 );
	d = distance( self.origin, self.v_destination );
	if ( !isDefined( self.dronerunrate ) )
	{
		self.dronerunrate = 200;
	}
	self.n_travel_time = d / self.dronerunrate;
	self.lowheight = 0;
	self turn_to_face_point( self.v_destination, self.n_travel_time );
}

drones_clear_variables()
{
	if ( isDefined( self.voice ) )
	{
		self.voice = undefined;
	}
}

drone_delete( delaytime )
{
	self endon( "death" );
	if ( isDefined( delaytime ) && delaytime > 0 )
	{
		wait delaytime;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	self notify( "drone_death" );
	self notify( "drone_idle_anim" );
	if ( isinarray( level.drones.team[ self.team ].array, self ) )
	{
		structarray_remove( level.drones.team[ self.team ], self );
	}
	if ( !isDefined( self.dontdelete ) )
	{
		if ( isDefined( self.turrettarget ) )
		{
			self.turrettarget delete();
		}
		if ( isDefined( self.temp_target ) )
		{
			self.temp_target delete();
		}
		self detachall();
		self delete();
	}
}

process_event( s_start )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self endon( "death" );
	self endon( "drone_death" );
	self notify( "stop_shooting" );
	self useanimtree( -1 );
	d = distance( self.origin, self.v_destination );
	if ( !isDefined( self.dronerunrate ) )
	{
		self.dronerunrate = 200;
	}
	self.n_travel_time = d / self.dronerunrate;
	self.lowheight = 0;
	self turn_to_face_point( self.v_destination, self.n_travel_time );
	skip = 0;
	if ( isDefined( s_start.dr_percent ) && randomint( 100 ) < s_start.dr_percent )
	{
		skip = 1;
	}
	if ( !skip && isDefined( s_start.dr_event ) )
	{
		switch( s_start.dr_event )
		{
			case "shoot":
				self drone_event_shoot( s_start, 0, 0 );
				break;
			case "shoot_burst":
				self drone_event_shoot( s_start, 0, 1 );
				break;
			case "shoot_forever":
				self.n_shots_to_fire = 999999;
				self drone_event_shoot( s_start, 0, 0 );
				break;
			case "shoot_bullets":
				self drone_event_shoot( s_start, 1 );
				break;
			case "run_and_shoot":
				self thread drone_event_run_and_shoot( 0 );
				break;
			case "run_and_shoot_burst":
				self thread drone_event_run_and_shoot( 1 );
				break;
			case "play_looped_anim":
				drone_event_looped_anim( s_start, self.v_destination );
				skip = 1;
				break;
			case "low_height":
				self.lowheight = 1;
				break;
			case "mortardeath_up":
				self thread drone_mortardeath( "up" );
				return;
				case "mortardeath_forward":
					self thread drone_mortardeath( "forward" );
					return;
					case "mortardeath_back":
						self thread drone_mortardeath( "back" );
						return;
						case "mortardeath_left":
							self thread drone_mortardeath( "left" );
							return;
							case "mortardeath_right":
								self thread drone_mortardeath( "right" );
								return;
								case "cover_stand":
									self thread drone_cover( s_start.dr_event );
									self waittill( "drone out of cover" );
									self setflaggedanimknob( "cover_exit", %coverstand_trans_out_m, 1, 0,1, 1 );
									self waittillmatch( "cover_exit" );
									return "end";
									break;
								case "cover_crouch":
									self thread drone_cover( s_start.dr_event );
									self waittill( "drone out of cover" );
									self setflaggedanimknob( "cover_exit", %covercrouch_run_out_m, 1, 0,1, 1 );
									self waittillmatch( "cover_exit" );
									return "end";
									break;
								case "cover_crouch_fire":
									self thread drone_cover_fire( s_start.dr_event );
									self waittill( "drone out of cover" );
									self setflaggedanimknob( "cover_exit", %covercrouch_run_out_m, 1, 0,5, 1 );
									self waittillmatch( "cover_exit" );
									return "end";
									break;
								case "flamedeath":
									self thread drone_flamedeath();
									break;
								case "run_fast":
									self drone_set_run_cycle();
									self.running = 0;
									d = distance( self.origin, self.v_destination );
									self.n_travel_time = d / self.dronerunrate;
									break;
								default:
									event_params = strtok( s_start.dr_event, "," );
									if ( isDefined( level.drones.funcs[ event_params[ 0 ] ] ) )
									{
										params = event_params;
										event_param = event_params[ 0 ];
										arrayremovevalue( params, event_params[ 0 ] );
										self [[ level.drones.funcs[ event_param ] ]]( s_start, self.v_destination, params );
									}
									else
									{
/#
										assertmsg( "The event "" + s_start.dr_event + "" is not a valid drone event.  If you are trying to use a custom event function, make sure it has been defined in level.drones.funcs" );
#/
									}
									break;
							}
						}
						if ( !skip && isDefined( s_start.dr_animation ) )
						{
/#
							assert( isDefined( level.drones.anims[ s_start.dr_animation ] ), "There is no animation defined for level.drones.anims[ "" + s_start.dr_animation + "" ].  dr_animation defined at: " + s_start.origin );
#/
							anim_custom = level.drones.anims[ s_start.dr_animation ];
							if ( isarray( anim_custom ) )
							{
								anim_custom = anim_custom[ randomint( anim_custom.size ) ];
							}
							self.is_playing_custom_anim = 1;
							self.running = undefined;
							angles = vectorToAngle( self.v_destination - self.origin );
							offset = getcycleoriginoffset( angles, anim_custom );
							endpos = self.origin + offset;
							endpos = physicstrace( endpos + vectorScale( ( 0, 0, 1 ), 64 ), endpos - ( 0, 0, level.drones.trace_height ) );
							t = getanimlength( anim_custom );
/#
							assert( t > 0 );
#/
							self moveto( endpos, t, 0, 0 );
							self clearanim( self.drone_run_cycle, 0,2 );
							self notify( "stop_drone_loop_run_anim" );
							self setflaggedanimknobrestart( "drone_custom_anim", anim_custom );
							self waittillmatch( "drone_custom_anim" );
							return "end";
							self.origin = endpos;
							self notify( "custom_anim_done" );
							d = distance( self.origin, self.v_destination );
							self.n_travel_time = d / self.dronerunrate;
							self.is_playing_custom_anim = undefined;
						}
					}
				}
			}
		}
	}
}

drone_runto()
{
	if ( self.n_travel_time < 0,1 )
	{
		return;
	}
	percentage = 0;
	startingpos = self.origin;
	oldz = startingpos[ 2 ];
	i = 0;
	while ( i < ( 1 / 0,1 ) )
	{
		percentage += 0,1;
		x = ( ( self.v_destination[ 0 ] - startingpos[ 0 ] ) * percentage ) + startingpos[ 0 ];
		y = ( ( self.v_destination[ 1 ] - startingpos[ 1 ] ) * percentage ) + startingpos[ 1 ];
		if ( self.lowheight == 1 )
		{
			percentagemark = physicstrace( ( x, y, self.v_destination[ 2 ] + 64 ), ( x, y, self.v_destination[ 2 ] - level.drones.trace_height ) );
		}
		else
		{
			percentagemark = physicstrace( ( x, y, self.v_destination[ 2 ] + level.drones.trace_height ), ( x, y, self.v_destination[ 2 ] - level.drones.trace_height ) );
		}
		if ( abs( percentagemark[ 2 ] - oldz ) > level.drones.step_height )
		{
			percentagemark = ( percentagemark[ 0 ], percentagemark[ 1 ], oldz );
		}
		oldz = percentagemark[ 2 ];
		self moveto( percentagemark, self.n_travel_time * 0,1, 0, 0 );
		wait ( self.n_travel_time * 0,1 );
		i++;
	}
}

drone_event_shoot( s_start, b_shoot_bullets, b_shoot_burst )
{
	self endon( "death" );
	if ( !isDefined( b_shoot_bullets ) )
	{
		b_shoot_bullets = 0;
	}
	if ( !isDefined( b_shoot_burst ) )
	{
		b_shoot_burst = 0;
	}
	if ( isDefined( s_start.script_int ) )
	{
		self.n_shots_to_fire = s_start.script_int;
	}
	e_target = undefined;
	if ( isDefined( s_start.script_string ) )
	{
		e_target = getent( s_start.script_string, "targetname" );
/#
		assert( isDefined( e_target ), "No target for drone event @ " + s_start.origin + ".  GetEnt failed looking for "" + s_start.script_string + """ );
#/
	}
	else
	{
		target_offset = anglesToForward( self.angles ) * 300;
		shootpos = self.origin + target_offset;
		if ( isDefined( self.temp_target ) )
		{
			self.temp_target.origin = shootpos;
		}
		else
		{
			self.temp_target = spawn( "script_origin", shootpos );
		}
		e_target = self.temp_target;
	}
	if ( isDefined( b_shoot_bullets ) && b_shoot_bullets )
	{
		self drone_shoot_bullets( e_target );
	}
	else
	{
		self drone_shoot_blanks( e_target, b_shoot_burst );
	}
	self clearanim( %combat_directions, 0,2 );
	self clearanim( %exposed_reload, 0,2 );
}

drone_shoot_bullets( e_target )
{
	self endon( "death" );
	self useanimtree( -1 );
	self.running = undefined;
	self thread drone_aim_at_target( e_target, "stop_shooting" );
	v_tag_flash = self.origin + vectorScale( ( 0, 0, 1 ), 50 );
	if ( !isDefined( self.n_shots_to_fire ) )
	{
		self.n_shots_to_fire = 1;
	}
	i = 0;
	while ( i < self.n_shots_to_fire )
	{
		if ( self.bulletsinclip <= 0 )
		{
			self setflaggedanimknoballrestart( "reloadanim", %exposed_reload, %root, 1, 0,4 );
			self.bulletsinclip = weaponclipsize( self.weapon );
			self waittillmatch( "reloadanim" );
			return "end";
		}
		self set3flaggedanimknobs( "no flag", "aim", "stand", 1, 0,3, 1 );
		wait ( 1 + randomfloat( 2 ) );
		v_tag_flash = self gettagorigin( "tag_flash" );
		magicbullet( self.weapon, v_tag_flash, e_target.origin, self );
		self.bulletsinclip--;

		wait ( 1 + randomfloat( 2 ) );
		i++;
	}
	self.n_shots_to_fire = undefined;
	self notify( "stop_shooting" );
}

drone_shoot_blanks( e_target, b_shoot_burst )
{
	self endon( "death" );
	self notify( "stop_shooting" );
	self endon( "stop_shooting" );
	if ( !isDefined( b_shoot_burst ) )
	{
		b_shoot_burst = 0;
	}
	self useanimtree( -1 );
	self.running = undefined;
	self thread drone_aim_at_target( e_target, "stop_shooting" );
	shootanimlength = 0;
	if ( !isDefined( self.n_shots_to_fire ) )
	{
		self.n_shots_to_fire = 1;
	}
	n_shots_fired = 0;
	while ( n_shots_fired < self.n_shots_to_fire )
	{
		if ( self.bulletsinclip <= 0 )
		{
			numattached = self getattachsize();
			attachname = [];
			i = 0;
			while ( i < numattached )
			{
				attachname[ i ] = self getattachmodelname( i );
				i++;
			}
			self setflaggedanimknoballrestart( "reloadanim", %exposed_reload, %root, 1, 0,4 );
			self.bulletsinclip = weaponclipsize( self.weapon );
			self waittillmatch( "reloadanim" );
			return "end";
		}
		self set3flaggedanimknobs( "no flag", "aim", "stand", 1, 0,3, 1 );
		wait ( 1 + randomfloat( 2 ) );
		if ( !isDefined( self ) )
		{
			return;
		}
		n_shots = randomint( 4 ) + 1;
		if ( n_shots > ( self.n_shots_to_fire - n_shots_fired ) )
		{
			n_shots = self.n_shots_to_fire - n_shots_fired;
		}
		if ( n_shots > self.bulletsinclip )
		{
			n_shots = self.bulletsinclip;
		}
		i = 0;
		while ( i < n_shots )
		{
			if ( !isDefined( self ) )
			{
				return;
			}
			self set3flaggedanimknobsrestart( "shootinganim", "shoot", "stand", 1, 0,05, 1 );
			blank_shot_fx( b_shoot_burst );
			if ( b_shoot_burst )
			{
				self.bulletsinclip -= 3;
				n_shots_fired++;
				continue;
			}
			else
			{
				self.bulletsinclip--;

			}
			n_shots_fired++;
			if ( shootanimlength == 0 )
			{
				shootanimlength = getTime();
				self waittillmatch( "shootinganim" );
				return "end";
				shootanimlength = ( getTime() - shootanimlength ) / 1000;
				i++;
				continue;
			}
			else
			{
				wait ( ( shootanimlength - 0,1 ) + randomfloat( 0,3 ) );
				if ( !isDefined( self ) )
				{
					return;
				}
			}
			i++;
		}
	}
	self.n_shots_to_fire = undefined;
	self notify( "stop_shooting" );
}

drone_event_run_and_shoot( b_shoot_burst )
{
	old_cycle = self.drone_run_cycle;
	self drone_set_run_cycle( %run_n_gun_f );
	self.running = 0;
	self thread drone_loop_run_anim();
	self thread drone_run_and_shoot_blanks( b_shoot_burst );
	self waittill( "stop_shooting" );
	self thread drone_set_run_cycle( old_cycle );
}

drone_run_and_shoot_blanks( b_shoot_burst )
{
	self endon( "death" );
	self endon( "stop_shooting" );
	n_shots = 1;
	if ( b_shoot_burst )
	{
		n_shots = 3;
	}
	while ( 1 )
	{
		wait ( 0,25 + randomfloat( 2 ) );
		blank_shot_fx( b_shoot_burst );
	}
}

blank_shot_fx( b_shoot_burst )
{
	self endon( "death" );
	str_wpn_sound = "wpn_mosin_fire";
	n_shots = 1;
	if ( b_shoot_burst )
	{
		n_shots = 3;
	}
	i = 0;
	while ( i < n_shots )
	{
		playfxontag( level.drones.muzzleflash, self, "tag_flash" );
		if ( !level.drones.sounds_disabled )
		{
			self playsound( str_wpn_sound );
		}
		wait 0,05;
		i++;
	}
}

drone_event_looped_anim( s_start, v_destination )
{
	self endon( "death" );
	if ( !isDefined( level.flag[ "drones_stop_looped_anims" ] ) )
	{
		flag_init( "drones_stop_looped_anims" );
	}
	if ( !flag( "drones_stop_looped_anims" ) && isDefined( s_start.dr_animation ) )
	{
/#
		assert( isDefined( level.drones.anims[ s_start.dr_animation ] ), "There is no animation defined for level.drones.anims[ "" + s_start.dr_animation + "" ].  dr_animation defined at: " + s_start.origin );
#/
		anim_custom = level.drones.anims[ s_start.dr_animation ];
		if ( isarray( anim_custom ) )
		{
			anim_custom = anim_custom[ randomint( anim_custom.size ) ];
		}
		self.is_playing_custom_anim = 1;
		self.running = undefined;
		angles = vectorToAngle( v_destination - self.origin );
		offset = getcycleoriginoffset( angles, anim_custom );
		endpos = self.origin + offset;
		endpos = physicstrace( endpos + vectorScale( ( 0, 0, 1 ), 64 ), endpos - ( 0, 0, level.drones.trace_height ) );
		t = getanimlength( anim_custom );
/#
		assert( t > 0 );
#/
		self moveto( endpos, t, 0, 0 );
		self clearanim( self.drone_run_cycle, 0,2 );
		self notify( "stop_drone_loop_run_anim" );
		self setanim( anim_custom, 1, 0,2 );
		flag_wait( "drones_stop_looped_anims" );
		wait randomfloatrange( 0,1, 0,5 );
		self clearanim( anim_custom, 0,2 );
		self.drone_run_cycle = drone_pick_run_anim();
		self.origin = endpos;
		self notify( "custom_anim_done" );
		self.is_playing_custom_anim = undefined;
	}
}

drone_loop_run_anim( animratemod )
{
	if ( isDefined( self.running ) && self.running )
	{
		return;
	}
	self notify( "stop_drone_loop_run_anim" );
	self endon( "stop_drone_loop_run_anim" );
	self endon( "delete" );
	self endon( "drone_death" );
	self.running = 1;
	if ( !isDefined( animratemod ) )
	{
		animratemod = 1;
	}
	while ( isDefined( self.running ) && self.running )
	{
		animrate = self.dronerunrate / self.drone_run_cycle_speed;
		self setflaggedanimknobrestart( "drone_run_anim", self.drone_run_cycle, 1, 0,2, animrate );
		self waittillmatch( "drone_run_anim" );
		return "end";
		if ( !isDefined( self ) )
		{
			return;
		}
	}
}

drone_debugline( frompoint, topoint, color, durationframes )
{
/#
	i = 0;
	while ( i < ( durationframes * 20 ) )
	{
		line( frompoint, topoint, color );
		wait 0,05;
		i++;
#/
	}
}

turn_to_face_point( point, n_time )
{
	desiredangles = vectorToAngle( point - self.origin );
	if ( !isDefined( n_time ) )
	{
		n_time = 0,5;
	}
	else
	{
		if ( n_time > 0,5 )
		{
			n_time = 0,5;
		}
	}
	if ( n_time < 0,1 )
	{
		return;
	}
	self rotateto( ( 0, desiredangles[ 1 ], 0 ), n_time, 0, 0 );
}

set3flaggedanimknobs( animflag, animarray, pose, weight, blendtime, rate )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self setanimknob( %combat_directions, weight, blendtime, rate );
	self setflaggedanimknob( animflag, level.drones.animarray[ animarray ][ pose ][ "up" ], 1, blendtime, 1 );
	self setanimknob( level.drones.animarray[ animarray ][ pose ][ "straight" ], 1, blendtime, 1 );
	self setanimknob( level.drones.animarray[ animarray ][ pose ][ "down" ], 1, blendtime, 1 );
}

set3flaggedanimknobsrestart( animflag, animarray, pose, weight, blendtime, rate )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self setanimknobrestart( %combat_directions, weight, blendtime, rate );
	self setflaggedanimknobrestart( animflag, level.drones.animarray[ animarray ][ pose ][ "up" ], 1, blendtime, 1 );
	self setanimknobrestart( level.drones.animarray[ animarray ][ pose ][ "straight" ], 1, blendtime, 1 );
	self setanimknobrestart( level.drones.animarray[ animarray ][ pose ][ "down" ], 1, blendtime, 1 );
}

apply_vertical_blend( offset )
{
	if ( offset < 0 )
	{
		unstraightanim = %combat_down;
		self setanim( %combat_up, 0,01, 0, 1 );
		offset *= -1;
	}
	else
	{
		unstraightanim = %combat_up;
		self setanim( %combat_down, 0,01, 0, 1 );
	}
	if ( offset > 1 )
	{
		offset = 1;
	}
	unstraight = offset;
	if ( unstraight >= 1 )
	{
		unstraight = 0,99;
	}
	if ( unstraight <= 0 )
	{
		unstraight = 0,01;
	}
	straight = 1 - unstraight;
	self setanim( unstraightanim, unstraight, 0, 1 );
	self setanim( %combat_straight, straight, 0, 1 );
}

drone_aim_at_target( target, stopstring )
{
	self endon( stopstring );
	while ( isDefined( self ) )
	{
		targetpos = target.origin;
		turn_to_face_point( targetpos );
		offset = get_target_vertical_offset( targetpos );
		apply_vertical_blend( offset );
		wait 0,05;
	}
}

get_target_vertical_offset( v_target_pos )
{
	dir = vectornormalize( v_target_pos - self.origin );
	return dir[ 2 ];
}

set_anim_array()
{
	level.drones.animarray[ "aim" ][ "stand" ][ "down" ] = %stand_aim_down;
	level.drones.animarray[ "aim" ][ "stand" ][ "straight" ] = %stand_aim_straight;
	level.drones.animarray[ "aim" ][ "stand" ][ "up" ] = %stand_aim_up;
	level.drones.animarray[ "aim" ][ "crouch" ][ "down" ] = %crouch_aim_down;
	level.drones.animarray[ "aim" ][ "crouch" ][ "straight" ] = %crouch_aim_straight;
	level.drones.animarray[ "aim" ][ "crouch" ][ "up" ] = %crouch_aim_up;
	level.drones.animarray[ "auto" ][ "stand" ][ "down" ] = %stand_shoot_auto_down;
	level.drones.animarray[ "auto" ][ "stand" ][ "straight" ] = %stand_shoot_auto_straight;
	level.drones.animarray[ "auto" ][ "stand" ][ "up" ] = %stand_shoot_auto_up;
	level.drones.animarray[ "auto" ][ "crouch" ][ "down" ] = %crouch_shoot_auto_down;
	level.drones.animarray[ "auto" ][ "crouch" ][ "straight" ] = %crouch_shoot_auto_straight;
	level.drones.animarray[ "auto" ][ "crouch" ][ "up" ] = %crouch_shoot_auto_up;
	level.drones.animarray[ "shoot" ][ "stand" ][ "down" ] = %stand_shoot_down;
	level.drones.animarray[ "shoot" ][ "stand" ][ "straight" ] = %stand_shoot_straight;
	level.drones.animarray[ "shoot" ][ "stand" ][ "up" ] = %stand_shoot_up;
	level.drones.animarray[ "shoot" ][ "crouch" ][ "down" ] = %crouch_shoot_down;
	level.drones.animarray[ "shoot" ][ "crouch" ][ "straight" ] = %crouch_shoot_straight;
	level.drones.animarray[ "shoot" ][ "crouch" ][ "up" ] = %crouch_shoot_up;
}

drone_cover_fire( type )
{
	self endon( "drone_stop_cover" );
	self endon( "drone_death" );
	self endon( "death" );
	while ( 1 )
	{
		drone_cover( type );
		self setanimknob( %stand_aim_straight, 1, 0,3, 1 );
		wait 0,3;
		forwardvec = anglesToForward( self.angles );
		rightvec = anglesToRight( self.angles );
		upvec = anglesToUp( self.angles );
		relativeoffset = vectorScale( ( 0, 0, 1 ), 300 );
		shootpos = self.origin;
		shootpos += vectorScale( forwardvec, relativeoffset[ 0 ] );
		shootpos += vectorScale( rightvec, relativeoffset[ 1 ] );
		shootpos += vectorScale( upvec, relativeoffset[ 2 ] );
		if ( isDefined( self.temp_target ) )
		{
			self.temp_target delete();
		}
		self.temp_target = spawn( "script_origin", shootpos );
		self.bulletsinclip = randomint( 4 ) + 3;
		self thread drone_shoot_blanks( self.temp_target, 1 );
		self waittill( "stop_shooting" );
	}
}

drone_cover( type )
{
	self endon( "drone_stop_cover" );
	if ( !isDefined( self.a ) )
	{
		self.a = spawnstruct();
	}
	self.running = undefined;
	self.a.array = [];
	if ( type == "cover_stand" )
	{
		self.a.array[ "hide_idle" ] = %coverstand_hide_idle;
		self.a.array[ "hide_idle_twitch" ] = array( %coverstand_hide_idle_twitch01, %coverstand_hide_idle_twitch02, %coverstand_hide_idle_twitch03, %coverstand_hide_idle_twitch04, %coverstand_hide_idle_twitch05 );
		self.a.array[ "hide_idle_flinch" ] = array( %coverstand_react01, %coverstand_react02, %coverstand_react03, %coverstand_react04 );
		self setflaggedanimknobrestart( "cover_approach", %coverstand_trans_in_m, 1, 0,3, 1 );
		self waittillmatch( "cover_approach" );
		return "end";
		self thread drone_cover_think();
	}
	else if ( type == "cover_crouch" )
	{
		self.a.array[ "hide_idle" ] = %covercrouch_hide_idle;
		self.a.array[ "hide_idle_twitch" ] = array( %covercrouch_twitch_1, %covercrouch_twitch_2, %covercrouch_twitch_3, %covercrouch_twitch_4 );
		self setflaggedanimknobrestart( "cover_approach", %covercrouch_run_in_m, 1, 0,3, 1 );
		self waittillmatch( "cover_approach" );
		return "end";
		self thread drone_cover_think();
	}
	else
	{
		if ( type == "cover_crouch_fire" )
		{
			self.a.array[ "hide_idle" ] = %covercrouch_hide_idle;
			self.a.array[ "hide_idle_twitch" ] = array( %covercrouch_twitch_1, %covercrouch_twitch_2, %covercrouch_twitch_3, %covercrouch_twitch_4 );
			self setanimknob( %covercrouch_hide_idle, 1, 0,4, 1 );
			wait 0,4;
			self drone_cover_think( 1 + randomint( 3 ) );
		}
	}
}

drone_cover_think( max_loops )
{
	self endon( "drone_stop_cover" );
	if ( !isDefined( max_loops ) )
	{
		max_loops = -1;
	}
	loops = 0;
	while ( loops < max_loops || max_loops == -1 )
	{
		usetwitch = randomint( 2 ) == 0;
		if ( usetwitch )
		{
			idleanim = animarraypickrandom( "hide_idle_twitch" );
		}
		else
		{
			idleanim = animarray( "hide_idle" );
		}
		self drone_playidleanimation( idleanim, usetwitch );
		loops++;
	}
}

drone_playidleanimation( idleanim, needsrestart )
{
	self endon( "drone_stop_cover" );
	if ( needsrestart )
	{
		self setflaggedanimknobrestart( "idle", idleanim, 1, 0,1, 1 );
	}
	else
	{
		self setflaggedanimknob( "idle", idleanim, 1, 0,1, 1 );
	}
	self.a.covermode = "Hide";
	self waittillmatch( "idle" );
	return "end";
}

drone_get_explosion_death_dir( self_pos, self_angle, explosion_pos, up_distance )
{
	if ( distance2d( self_pos, explosion_pos ) < up_distance )
	{
		return "up";
	}
	p1 = self_pos - ( vectornormalize( anglesToForward( self_angle ) ) * 10000 );
	p2 = self_pos + ( vectornormalize( anglesToForward( self_angle ) ) * 10000 );
	p_intersect = pointonsegmentnearesttopoint( p1, p2, explosion_pos );
	side_away_dist = distance2d( p_intersect, explosion_pos );
	side_close_dist = distance2d( p_intersect, self_pos );
	if ( side_close_dist != 0 )
	{
		angle = atan( side_away_dist / side_close_dist );
		dot_product = vectordot( anglesToForward( self_angle ), vectornormalize( explosion_pos - self_pos ) );
		if ( dot_product < 0 )
		{
			angle = 180 - angle;
		}
		if ( angle < 45 )
		{
			return "back";
		}
		else
		{
			if ( angle > 135 )
			{
				return "forward";
			}
		}
	}
	self_right_angle = vectornormalize( anglesToRight( self_angle ) );
	right_point = self_pos + ( self_right_angle * ( up_distance * 0,5 ) );
	if ( distance2d( right_point, explosion_pos ) < distance2d( self_pos, explosion_pos ) )
	{
		return "left";
	}
	else
	{
		return "right";
	}
}

animarray( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
	return self.a.array[ animname ];
}

animarrayanyexist( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
	return self.a.array[ animname ].size > 0;
}

animarraypickrandom( animname )
{
/#
	assert( isDefined( self.a.array ) );
#/
/#
	if ( !isDefined( self.a.array[ animname ] ) )
	{
		dumpanimarray();
		assert( isDefined( self.a.array[ animname ] ), "self.a.array[ "" + animname + "" ] is undefined" );
#/
	}
/#
	assert( self.a.array[ animname ].size > 0 );
#/
	if ( self.a.array[ animname ].size > 1 )
	{
		index = randomint( self.a.array[ animname ].size );
	}
	else
	{
		index = 0;
	}
	return self.a.array[ animname ][ index ];
}

dumpanimarray()
{
/#
	println( "self.a.array:" );
	keys = getarraykeys( self.a.array );
	i = 0;
	while ( i < keys.size )
	{
		if ( isarray( self.a.array[ keys[ i ] ] ) )
		{
			println( " array[ "" + keys[ i ] + "" ] = {array of size " + self.a.array[ keys[ i ] ].size + "}" );
			i++;
			continue;
		}
		else
		{
			println( " array[ "" + keys[ i ] + "" ] = ", self.a.array[ keys[ i ] ] );
		}
		i++;
#/
	}
}

drone_pick_run_anim()
{
	if ( isDefined( level.drone_run_cycle_override ) )
	{
		if ( isarray( level.drone_run_cycle_override ) )
		{
			return level.drone_run_cycle_override[ randomint( level.drone_run_cycle_override.size ) ];
		}
		else
		{
			return level.drone_run_cycle_override;
		}
	}
	else
	{
		if ( isDefined( self.drone_run_cycle_override ) )
		{
			if ( isarray( self.drone_run_cycle_override ) )
			{
				return self.drone_run_cycle_override[ randomint( self.drone_run_cycle_override.size ) ];
			}
			else
			{
				return self.drone_run_cycle_override;
			}
		}
	}
	dronerunanims = array( %run_n_gun_f, %run_lowready_f, %ai_militia_run_lowready_f_02, %ai_militia_run_lowready_f_03, %ai_sprint_f_05 );
	index = randomint( dronerunanims.size );
	index = randomint( 4 );
	return dronerunanims[ index ];
}

drone_set_run_cycle( runanim )
{
	if ( !isDefined( runanim ) )
	{
		runanim = drone_pick_run_anim();
	}
	self.drone_run_cycle = runanim;
	self.drone_run_cycle_speed = drone_run_anim_speed( runanim );
	self.dronerunrate = self.drone_run_cycle_speed;
}

drone_run_anim_speed( runanim )
{
	run_cycle_delta = getmovedelta( runanim, 0, 1 );
	run_cycle_dist = length( run_cycle_delta );
	run_cycle_length = getanimlength( runanim );
	run_cycle_speed = run_cycle_dist / run_cycle_length;
	return run_cycle_speed;
}

drones_get_triggers( script_string_trigger_name )
{
	triggers = [];
	while ( isDefined( level.drones.axis_triggers ) )
	{
		ents = level.drones.axis_triggers;
		i = 0;
		while ( i < ents.size )
		{
			if ( isDefined( ents[ i ].script_string ) )
			{
				if ( ents[ i ].script_string == script_string_trigger_name )
				{
					triggers[ triggers.size ] = ents[ i ];
				}
			}
			i++;
		}
	}
	while ( isDefined( level.drones.allies_triggers ) )
	{
		ents = level.drones.allies_triggers;
		i = 0;
		while ( i < ents.size )
		{
			if ( isDefined( ents[ i ].script_string ) )
			{
				if ( ents[ i ].script_string == script_string_trigger_name )
				{
					triggers[ triggers.size ] = ents[ i ];
				}
			}
			i++;
		}
	}
	return triggers;
}

drones_set_max_ragdolls( max_ragdolls )
{
	level.drones.max_ragdolls = max_ragdolls;
}

drone_available_ragdoll( force_remove )
{
	if ( !isDefined( level.drones.ragdoll_bucket ) )
	{
		level.drones.ragdoll_bucket = [];
	}
	if ( level.drones.ragdoll_bucket.size >= level.drones.max_ragdolls )
	{
		num_in_bucket = clean_up_ragdoll_bucket();
		if ( num_in_bucket < level.drones.max_ragdolls )
		{
			return 1;
		}
		else
		{
			if ( isDefined( force_remove ) )
			{
				if ( level.drones.ragdoll_bucket[ 0 ].targetname == "drone" )
				{
					self.dontdelete = undefined;
					level.drones.ragdoll_bucket[ 0 ] maps/_drones::drone_delete();
				}
				else
				{
					level.drones.ragdoll_bucket[ 0 ] delete();
				}
				arrayremoveindex( level.drones.ragdoll_bucket, 0 );
				return 1;
			}
		}
		return 0;
	}
	return 1;
}

add_to_ragdoll_bucket()
{
	if ( !isDefined( level.drones.ragdoll_bucket ) )
	{
		level.drones.ragdoll_bucket = [];
	}
	self.ragdoll_start_time = getTime();
	level.drones.ragdoll_bucket[ level.drones.ragdoll_bucket.size ] = self;
	self startragdoll();
}

clean_up_ragdoll_bucket()
{
	current_time = getTime();
	new_bucket = [];
	i = 0;
	while ( i < 16 )
	{
		if ( !isDefined( level.drones.ragdoll_bucket[ i ] ) )
		{
			i++;
			continue;
		}
		else ragdoll_time = ( current_time - level.drones.ragdoll_bucket[ i ].ragdoll_start_time ) / 1000;
		if ( ragdoll_time < 4 || isDefined( self.is_playing_custom_anim ) )
		{
			new_bucket[ new_bucket.size ] = level.drones.ragdoll_bucket[ i ];
			i++;
			continue;
		}
		else
		{
			if ( isDefined( level.drones.ragdoll_bucket[ i ].targetname ) && level.drones.ragdoll_bucket[ i ].targetname == "drone" )
			{
				level.drones.ragdoll_bucket[ i ].dontdelete = undefined;
				level.drones.ragdoll_bucket[ i ] maps/_drones::drone_delete();
				i++;
				continue;
			}
			else
			{
				level.drones.ragdoll_bucket[ i ] delete();
			}
		}
		i++;
	}
	level.drones.ragdoll_bucket = new_bucket;
	return level.drones.ragdoll_bucket.size;
}

drones_pause( script_string_name, paused )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		if ( isDefined( level.drones.drone_spawners[ i ].script_string ) )
		{
			if ( level.drones.drone_spawners[ i ].script_string == script_string_name )
			{
				level.drones.drone_spawners[ i ].paused = paused;
			}
		}
		i++;
	}
}

drones_speed_modifier( script_string_name, min_speed, max_speed )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		if ( isDefined( level.drones.drone_spawners[ i ].script_string ) )
		{
			if ( level.drones.drone_spawners[ i ].script_string == script_string_name )
			{
				level.drones.drone_spawners[ i ].speed_modifier_min = min_speed;
				level.drones.drone_spawners[ i ].speed_modifier_max = max_speed;
			}
		}
		i++;
	}
}

drones_setup_unique_anims( script_string_name, anim_array )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		if ( isDefined( level.drones.drone_spawners[ i ].script_string ) )
		{
			if ( level.drones.drone_spawners[ i ].script_string == script_string_name )
			{
				level.drones.drone_spawners[ i ].drone_run_cycle_override = anim_array;
			}
		}
		i++;
	}
}

drones_set_respawn_death_delay( min_delay, max_delay )
{
	level.drones.respawn_death_delay_min = min_delay;
	level.drones.respawn_death_delay_max = max_delay;
}

pre_populate_drones( drones, spawn_min, spawn_max, team )
{
	level notify( "new drone Spawn wave" );
	path_size = undefined;
	i = 0;
	while ( i < drones.a_targeted.size )
	{
		size = calc_drone_path_size( drones.a_targeted[ i ] );
		if ( !isDefined( path_size ) || size < path_size )
		{
			path_size = size;
		}
		i++;
	}
	dist = 0;
	while ( dist < path_size )
	{
		spawn_size = spawn_min;
		if ( spawn_max > spawn_min )
		{
			spawn_size = randomintrange( spawn_min, spawn_max + 1 );
		}
		level thread drone_spawngroup( drones, drones.a_targeted, spawn_size, team, dist );
		dist += 320;
	}
}

calc_drone_path_size( node )
{
	size = 0;
	while ( isDefined( node.target ) )
	{
		while ( 1 )
		{
			next_node_struct = getstruct( node.target, "targetname" );
			size += distance( node.origin, next_node_struct.origin );
			node = getstruct( node.target, "targetname" );
			if ( !isDefined( node.target ) )
			{
				break;
			}
			else
			{
			}
		}
	}
	return size;
}

drones_start( script_string_name )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		spawner = level.drones.drone_spawners[ i ];
		if ( isDefined( spawner.script_string ) )
		{
			if ( spawner.script_string == script_string_name )
			{
				if ( isDefined( spawner.parent_trigger ) )
				{
					spawner.parent_trigger notify( "trigger" );
					i++;
					continue;
				}
				else
				{
					if ( isDefined( spawner.parent_script_struct ) )
					{
						spawner.parent_script_struct notify( "trigger" );
					}
				}
			}
		}
		i++;
	}
}

drones_delete( script_string_name )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		spawner = level.drones.drone_spawners[ i ];
		if ( isDefined( spawner.script_string ) )
		{
			if ( spawner.script_string == script_string_name )
			{
				spawner.delete_spawner = 1;
			}
		}
		i++;
	}
}

drones_assign_spawner( script_string_name, spawner_guy )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		spawner = level.drones.drone_spawners[ i ];
		if ( isDefined( spawner.script_string ) )
		{
			if ( spawner.script_string == script_string_name )
			{
				if ( !isDefined( spawner.unique_guys ) )
				{
					spawner.unique_guys = [];
				}
				spawner.unique_guys[ spawner.unique_guys.size ] = spawner_guy;
			}
		}
		i++;
	}
}

drone_notify( param0, param1, param2 )
{
	self notify( param0 );
	iprintlnbold( param0 );
}

drones_death_notify_wrapper( attacker, damagetype )
{
	level drone_notify( "face", "death", self );
	self drone_notify( "death", attacker, damagetype );
}

drone_add_spawner()
{
	if ( !isDefined( self.classname ) )
	{
		return;
	}
	if ( !is_spawner( self ) )
	{
		return;
	}
	if ( !isDefined( level.drones ) )
	{
		level.drones = spawnstruct();
	}
	if ( !isDefined( level.drones.axis_classnames ) )
	{
		level.drones.axis_classnames = [];
	}
	if ( !isDefined( level.drones.allies_classnames ) )
	{
		level.drones.allies_classnames = [];
	}
	side = drone_spawner_side( self.classname );
	if ( side == "AXIS" )
	{
		i = 0;
		while ( i < level.drones.axis_classnames.size )
		{
			if ( level.drones.axis_classnames[ i ] == self.classname )
			{
				return;
			}
			i++;
		}
		level.drones.axis_classnames[ level.drones.axis_classnames.size ] = self.classname;
	}
	else
	{
		if ( side == "ALLIES" )
		{
			i = 0;
			while ( i < level.drones.allies_classnames.size )
			{
				if ( level.drones.allies_classnames[ i ] == self.classname )
				{
					return;
				}
				i++;
			}
			level.drones.allies_classnames[ level.drones.allies_classnames.size ] = self.classname;
		}
	}
}

drone_spawner_side( name )
{
	test = tolower( name );
	if ( issubstr( test, "_ally_" ) )
	{
		return "ALLIES";
	}
	else
	{
		if ( issubstr( test, "_a_" ) )
		{
			return "ALLIES";
		}
		else
		{
			if ( issubstr( test, "_enemy_" ) )
			{
				return "AXIS";
			}
			else
			{
				if ( issubstr( test, "_e_" ) )
				{
					return "AXIS";
				}
			}
		}
	}
	return "";
}

drone_get_axis_spawner_class()
{
	drone_class = undefined;
	if ( isDefined( level.drones.axis_classnames ) && level.drones.axis_classnames.size > 0 )
	{
		index = randomint( level.drones.axis_classnames.size );
		drone_class = level.drones.axis_classnames[ index ];
	}
	return drone_class;
}

drone_get_allies_spawner_class()
{
	drone_class = undefined;
	if ( isDefined( level.drones.allies_classnames ) && level.drones.allies_classnames.size > 0 )
	{
		index = randomint( level.drones.allies_classnames.size );
		drone_class = level.drones.allies_classnames[ index ];
	}
	return drone_class;
}

spawn_random_axis_drone( override_class )
{
	if ( isDefined( override_class ) )
	{
		class = override_class;
	}
	else
	{
		class = drone_get_axis_spawner_class();
	}
/#
	assert( isDefined( class ), "CANT FIND AXIS DRONE TO SPAWN" );
#/
	self getdronemodel( class );
	self setcurrentweapon( self.weapon );
}

spawn_random_allies_drone( override_class )
{
	if ( isDefined( override_class ) )
	{
		class = override_class;
	}
	else
	{
		class = drone_get_allies_spawner_class();
	}
/#
	assert( isDefined( class ), "CANT FIND ALLIES DRONE TO SPAWN" );
#/
	self getdronemodel( class );
	self.dr_ai_classname = class;
	self setcurrentweapon( self.weapon );
}

drones_get_array( str_team )
{
	array = [];
	if ( str_team == "axis" )
	{
		axis_drones = level.drones.team[ "axis" ].array;
		i = 0;
		while ( i < axis_drones.size )
		{
			if ( axis_drones[ i ].health > 0 )
			{
				array[ array.size ] = axis_drones[ i ];
			}
			i++;
		}
	}
	else while ( str_team == "allies" )
	{
		allies_drones = level.drones.team[ "allies" ].array;
		i = 0;
		while ( i < allies_drones.size )
		{
			if ( allies_drones[ i ].health > 0 )
			{
				array[ array.size ] = allies_drones[ i ];
			}
			i++;
		}
	}
	return array;
}

drones_delete_spawned( str_noteworthy )
{
	a_m_drones = getentarray( "drone", "targetname" );
	_a4480 = a_m_drones;
	index = getFirstArrayKey( _a4480 );
	while ( isDefined( index ) )
	{
		m_drone = _a4480[ index ];
		if ( isDefined( m_drone ) )
		{
			if ( !isDefined( str_noteworthy ) || isDefined( m_drone.script_noteworthy ) && str_noteworthy == m_drone.script_noteworthy )
			{
				m_drone.dontdelete = undefined;
				m_drone thread drone_delete();
			}
		}
		if ( ( index % 20 ) == 0 )
		{
			wait 0,05;
		}
		index = getNextArrayKey( _a4480, index );
	}
}

drones_set_cheap_flag( script_string_name, b_use_cheap_flag )
{
	i = 0;
	while ( i < level.drones.drone_spawners.size )
	{
		spawner = level.drones.drone_spawners[ i ];
		if ( isDefined( spawner.script_string ) && spawner.script_string == script_string_name )
		{
			spawner.b_use_cheap_flag = b_use_cheap_flag;
		}
		i++;
	}
}

prep_drone_path( start_struct, end_origin )
{
	if ( isstring( start_struct ) )
	{
		start_struct = get_struct( start_struct, "targetname" );
	}
	if ( !isDefined( end_origin ) )
	{
		end_struct = get_struct( start_struct.target, "targetname" );
		path_num = level leader_create( start_struct, end_struct.origin );
	}
	else
	{
		path_num = level leader_create( start_struct, end_origin );
	}
}

leader_create( struct_start, vec_end_pos )
{
	ai_spawner = getspawnerarray( "ai_drone_spawner", "targetname" )[ 0 ];
	ai_spawner.origin = struct_start.origin;
	if ( isDefined( struct_start.angles ) )
	{
		ai_spawner.angles = struct_start.angles;
	}
	ai = simple_spawn_single( ai_spawner );
	level notify( "ai_drone_ent_num" );
	wait 0,05;
	ai thread magic_bullet_shield();
	ai hide();
	ai set_ignoreall( 1 );
	ai set_ignoreme( 1 );
	ai.goalradius = 16;
	ai setphysparams( 28, 0, 72 );
	ai.ent_num = ai getentitynumber();
	ai.moveplaybackrate = 3;
	ai.drone_breadcrumbs = [];
	ai thread make_breadcrumbs( struct_start.targetname );
	ai thread kill_breadcrumbs_at_goal();
	ai setgoalpos( vec_end_pos );
	return ai.ent_num;
}

kill_breadcrumbs_at_goal()
{
	self endon( "death" );
	self waittill( "goal" );
	self notify( "stop_breadcrumbs" );
	level.ai_drone_paths[ self getentitynumber() ][ level.ai_drone_paths[ self getentitynumber() ].size ] = self.origin;
	self delete();
}

make_breadcrumbs( str_drone_path_name )
{
	self endon( "death" );
	self endon( "stop_breadcrumbs" );
	if ( !isDefined( level.ai_drone_paths ) )
	{
		level.ai_drone_paths = [];
	}
	ent_num = self getentitynumber();
	level.ai_drone_paths[ ent_num ] = [];
	level.ai_drone_paths[ ent_num ][ "ai" ] = self;
	while ( 1 )
	{
		level.ai_drone_paths[ ent_num ][ level.ai_drone_paths[ ent_num ].size ] = self.origin + vectorScale( ( 0, 0, 1 ), 24 );
		if ( level.ai_drone_paths[ ent_num ].size > 4 )
		{
			level notify( "ai_drone_ready_" + str_drone_path_name );
			level notify( "path_ready_" + ent_num );
		}
		wait 1;
	}
}
