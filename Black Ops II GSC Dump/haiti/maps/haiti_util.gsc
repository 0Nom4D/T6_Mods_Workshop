#include maps/_turret;
#include maps/_vehicle;
#include maps/_jetpack_ai;
#include maps/_dialog;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

add_cleanup_ent( str_category )
{
	if ( !isDefined( level.a_e_cleanup ) )
	{
		level.a_e_cleanup = [];
	}
	if ( !isDefined( level.a_e_cleanup[ str_category ] ) )
	{
		level.a_e_cleanup[ str_category ] = [];
	}
	if ( isarray( self ) )
	{
		level.a_e_cleanup[ str_category ] = arraycombine( level.a_e_cleanup[ str_category ], self, 1, 0 );
	}
	else
	{
		level.a_e_cleanup[ str_category ][ level.a_e_cleanup[ str_category ].size ] = self;
	}
}

cleanup_ents( str_category, n_delay )
{
	if ( !isDefined( n_delay ) )
	{
		n_delay = 0;
	}
	level notify( str_category );
	if ( n_delay > 0 )
	{
		wait n_delay;
	}
	n_deleted = 0;
	if ( isDefined( level.a_e_cleanup ) && isDefined( level.a_e_cleanup[ str_category ] ) )
	{
		_a49 = level.a_e_cleanup[ str_category ];
		_k49 = getFirstArrayKey( _a49 );
		while ( isDefined( _k49 ) )
		{
			ent = _a49[ _k49 ];
			if ( isDefined( ent ) )
			{
				ent delete();
				n_deleted++;
				if ( ( n_deleted % 20 ) == 0 )
				{
					wait 0,05;
				}
			}
			_k49 = getNextArrayKey( _a49, _k49 );
		}
	}
	a_ents = getentarray( str_category, "script_noteworthy" );
	_a68 = a_ents;
	_k68 = getFirstArrayKey( _a68 );
	while ( isDefined( _k68 ) )
	{
		ent = _a68[ _k68 ];
		if ( isDefined( ent ) )
		{
			ent delete();
			n_deleted++;
			if ( ( n_deleted % 20 ) == 0 )
			{
				wait 0,05;
			}
		}
		_k68 = getNextArrayKey( _a68, _k68 );
	}
}

kill_and_cleanup_ents( str_category )
{
	a_e_kill = getentarray( str_category, "script_noteworthy" );
	kill_array( a_e_kill );
	cleanup_ents( str_category );
}

player_stick( b_look, n_clamp_right, n_clamp_left, n_clamp_top, n_clamp_bottom )
{
	if ( !isDefined( b_look ) )
	{
		b_look = 0;
	}
	self.m_link = spawn( "script_model", self.origin );
	self.m_link.angles = self.angles;
	self.m_link setmodel( "tag_origin" );
	self allowsprint( 0 );
	if ( b_look )
	{
		self playerlinktodelta( self.m_link, "tag_origin", 1, n_clamp_right, n_clamp_left, n_clamp_top, n_clamp_bottom, 1 );
	}
	else
	{
		self playerlinktoabsolute( self.m_link, "tag_origin" );
	}
}

player_unstick()
{
	if ( isDefined( self.m_link ) )
	{
		self.m_link delete();
		self allowsprint( 1 );
	}
}

harper_think()
{
	self.ignoresuppression = 1;
	self.script_accuracy = 1,5;
}

setup_harper()
{
	a_sp_harpers = getentarray( "harper", "targetname" );
	str_search = "normal";
	if ( !level.is_harper_alive )
	{
		str_search = "substitute";
	}
	else
	{
		if ( level.is_harper_scarred )
		{
			str_search = "scarred";
		}
	}
	_a178 = a_sp_harpers;
	_k178 = getFirstArrayKey( _a178 );
	while ( isDefined( _k178 ) )
	{
		sp_harper = _a178[ _k178 ];
		if ( !isDefined( sp_harper.script_string ) || sp_harper.script_string != str_search )
		{
			sp_harper delete();
		}
		_k178 = getNextArrayKey( _a178, _k178 );
	}
	if ( level.is_harper_alive )
	{
		level.ai_harper = init_hero( "harper", ::harper_think );
		return;
	}
}

enemy_battle_think( b_aggressive, b_ally_priority )
{
	if ( !isDefined( b_aggressive ) )
	{
		b_aggressive = 0;
	}
	if ( !isDefined( b_ally_priority ) )
	{
		b_ally_priority = 0;
	}
	self.goalradius = 2000;
	self.script_radius = 2000;
	self.fixednode = 0;
	self.canflank = 1;
	if ( b_aggressive )
	{
		self.aggressivemode = 1;
	}
	if ( b_ally_priority )
	{
		self setthreatbiasgroup( "ally_priority" );
	}
	if ( issubstr( self.classname, "sniper" ) )
	{
		self thread sniper_think();
	}
}

ally_battle_think( str_aigroup, str_goalnode, b_delete_on_goal )
{
	if ( !isDefined( b_delete_on_goal ) )
	{
		b_delete_on_goal = 1;
	}
	self endon( "death" );
	self.goalradius = 900;
	self.script_radius = 900;
	self.fixednode = 0;
	self.canflank = 1;
	if ( isDefined( str_aigroup ) && isDefined( str_goalnode ) )
	{
		waittill_ai_group_cleared( str_aigroup );
		wait randomfloatrange( 1, 3 );
		n_goal = getnode( str_goalnode, "targetname" );
		self.goalradius = 12;
		self setgoalpos( n_goal.origin );
		self waittill( "goal" );
		if ( b_delete_on_goal )
		{
			self delete();
		}
	}
}

ai_jetpack_ally_attack_think( str_aigroup )
{
	self endon( "death" );
	self waittill( "landed" );
	self setthreatbiasgroup( "ally" );
	self.health = 200;
	self.script_goalradius = 512;
	self.script_accuracy = 4;
	self.fixednode = 0;
	self.attackeraccuracy = 0,5;
	self change_movemode( "cqb_run" );
	if ( isDefined( self.s_align.target ) )
	{
		nd_goal = getnode( self.s_align.target, "targetname" );
	}
	while ( isDefined( nd_goal ) )
	{
		if ( isDefined( nd_goal.target ) )
		{
			self setgoalnode( nd_goal );
		}
		else
		{
			self setgoalpos( nd_goal.origin );
		}
		self waittill( "goal" );
		if ( isDefined( nd_goal.script_flag_set ) )
		{
			flag_set( nd_goal.script_flag_set );
		}
		if ( isDefined( nd_goal.script_flag_wait ) )
		{
			flag_wait( nd_goal.script_flag_wait );
			wait randomfloatrange( 0,05, 1 );
		}
		if ( isDefined( nd_goal.target ) )
		{
			nd_goal = getnode( nd_goal.target, "targetname" );
			continue;
		}
		else
		{
		}
	}
	self delete();
}

ai_ally_attack_think( str_aigroup, nd_exit )
{
	self endon( "death" );
	self setthreatbiasgroup( "ally" );
	self.health = 300;
	self.script_goalradius = 256;
	self.script_accuracy = 4;
	self.fixednode = 0;
	self.attackeraccuracy = 0,5;
	if ( isDefined( str_aigroup ) )
	{
		waittill_ai_group_cleared( str_aigroup );
	}
	if ( isDefined( nd_exit ) )
	{
		self force_goal( nd_exit, 32 );
		self waittill( "goal" );
		self delete();
	}
}

camo_suit_think()
{
	self ent_flag_init( "camo_suit_on" );
	self ent_flag_set( "camo_suit_on" );
	self.camo_sound_ent = spawn( "script_origin", self.origin );
	self.camo_sound_ent linkto( self, "tag_origin" );
	self playsound( "fly_camo_suit_npc_on", self.origin );
	self.camo_sound_ent playloopsound( "fly_camo_suit_npc_loop", 0,5 );
	self thread enemy_battle_think( 1 );
	self.health = 150;
	self.moveplaybackrate = 1,3;
	self.attackeraccuracy = 0,5;
	self.a.disablewoundedset = 1;
	self.overrideactordamage = ::camo_damage_callback;
	self thread camo_emp_behavior();
}

camo_emp_behavior()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "doEmpBehavior", attacker, duration );
		self.emped = 1;
		self.blockingpain = 1;
		playfxontag( level._effect[ "camo_transition" ], self, "J_SpineLower" );
		self setclientflag( 12 );
		wait duration;
		self.emped = 0;
		self.blockingpain = 0;
		playfxontag( level._effect[ "camo_transition" ], self, "J_SpineLower" );
		self clearclientflag( 12 );
	}
}

camo_damage_callback( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, n_model_index, psoffsettime, str_bone_name )
{
	if ( e_attacker == level.player && str_means_of_death == "MOD_MELEE" )
	{
		level notify( "player_melee_camo" );
	}
	if ( n_damage >= self.health )
	{
		if ( self ent_flag( "camo_suit_on" ) )
		{
			self toggle_camo_suit( 1 );
		}
	}
	return n_damage;
}

toggle_camo_suit( b_disable, b_play_fx )
{
	if ( !isDefined( b_play_fx ) )
	{
		b_play_fx = 1;
	}
	if ( b_disable )
	{
		self setclientflag( 12 );
		self ent_flag_clear( "camo_suit_on" );
		self playsound( "fly_camo_suit_npc_off", self.origin );
		if ( isDefined( self.camo_sound_ent ) )
		{
			self.camo_sound_ent stoploopsound( 1 );
			self.camo_sound_ent delete();
		}
	}
	else
	{
		self clearclientflag( 12 );
		self ent_flag_set( "camo_suit_on" );
	}
	if ( b_play_fx )
	{
		playfxontag( getfx( "camo_transition" ), self, "J_SpineLower" );
	}
}

sniper_think()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( isDefined( self.enemy ) )
		{
			n_dist_sq = distancesquared( self.origin, self.enemy.origin );
			if ( n_dist_sq < 1000000 )
			{
				self.script_accuracy = 8;
				break;
			}
			else if ( n_dist_sq < 2250000 )
			{
				self.script_accuracy = 4;
				break;
			}
			else
			{
				self.script_accuracy = 2;
			}
		}
		wait 1;
	}
}

ai_player_squad_think()
{
	self endon( "death" );
	level.a_ai_player_squad[ level.a_ai_player_squad.size ] = self;
	self.health = 200;
	self.fixednode = 0;
	self.canflank = 1;
}

squad_replenish_init()
{
	level.a_ai_player_squad = [];
	level.a_sp_player_squad = getentarray( "ally_player_squad", "targetname" );
	if ( level.is_harper_alive )
	{
		level.n_player_squad_size = 3;
	}
	else
	{
		level.n_player_squad_size = 4;
	}
	if ( !isDefined( level.a_s_squad_spawn ) )
	{
		level.a_s_squad_spawn = getstructarray( "s_replenish_ally", "targetname" );
	}
	level.n_squad_spawn_index = 0;
	run_thread_on_targetname( "replenish_loc_update", ::replenish_loc_update );
	wait 0,1;
	flag_set( "squad_spawning" );
	while ( 1 )
	{
		flag_wait( "squad_spawning" );
		level.a_ai_player_squad = remove_dead_from_array( level.a_ai_player_squad );
		if ( level.a_ai_player_squad.size < level.n_player_squad_size )
		{
			level spawn_squad_member();
		}
		wait randomfloatrange( 1, 2 );
	}
}

replenish_loc_update()
{
	self endon( "death" );
	self waittill( "trigger" );
	if ( isDefined( self.script_flag_wait ) )
	{
		level endon( "replenish_loc_updated" );
		flag_wait( self.script_flag_wait );
	}
	level.a_s_squad_spawn = getstructarray( self.target, "targetname" );
	level.n_squad_spawn_index = 0;
	level notify( "replenish_loc_updated" );
}

spawn_squad_member( n_delay )
{
	if ( !isDefined( n_delay ) )
	{
		n_delay = 0;
	}
	if ( n_delay > 0 )
	{
		wait n_delay;
	}
	flag_wait( "squad_spawning" );
	level.a_ai_player_squad = remove_dead_from_array( level.a_ai_player_squad );
	s_loc = level.a_s_squad_spawn[ level.n_squad_spawn_index ];
	if ( isDefined( s_loc.script_string ) && s_loc.script_string == "jetwing" )
	{
		level thread maps/_jetpack_ai::create_jetpack_ai( s_loc, "ally_player_squad" );
	}
	else
	{
		ai_squad_member = undefined;
		while ( !isDefined( ai_squad_member ) )
		{
			wait 0,5;
			flag_wait( "squad_spawning" );
			ai_squad_member = simple_spawn_single( random( level.a_sp_player_squad ) );
		}
		while ( !ai_squad_member teleport( s_loc.origin, s_loc.angles ) )
		{
			wait 0,5;
		}
	}
	level.n_squad_spawn_index++;
	if ( level.n_squad_spawn_index >= level.a_s_squad_spawn.size )
	{
		level.n_squad_spawn_index = 0;
		level.a_s_squad_spawn = array_randomize( level.a_s_squad_spawn );
	}
}

spawn_ambient_drones( trig_name, kill_trig_name, str_targetname, str_targetname_allies, path_start, n_count_axis, n_count_allies, min_interval, max_interval, speed, delay, count )
{
	if ( !isDefined( speed ) )
	{
		speed = 400;
	}
	if ( !isDefined( delay ) )
	{
		delay = 0;
	}
	if ( !isDefined( count ) )
	{
		count = 999;
	}
	level endon( "end_ambient_drones" );
	level endon( "end_ambient_drones_" + path_start );
	if ( isDefined( kill_trig_name ) )
	{
		level thread ambient_drones_kill_trig_watcher( kill_trig_name, path_start );
	}
	if ( isDefined( trig_name ) )
	{
		trigger_wait( trig_name, "targetname" );
	}
	drones = [];
	vehicles = getvehiclearray();
	total = n_count_axis + n_count_allies;
	while ( ( vehicles.size + total ) > 70 )
	{
		wait 0,05;
		vehicles = getvehiclearray();
	}
	if ( delay > 0 )
	{
		wait delay;
	}
	while ( 1 )
	{
		i = 0;
		while ( i < n_count_axis )
		{
			vh_plane = maps/_vehicle::spawn_vehicle_from_targetname( str_targetname );
			vh_plane setspeedimmediate( speed, 300 );
			vh_plane thread delete_me();
			vh_plane setforcenocull();
			vh_plane thread ambient_drone_die();
			vh_plane pathfixedoffset( ( randomintrange( -1000, 1000 ), randomintrange( -1000, 1000 ), randomintrange( -500, 500 ) ) );
			vh_plane pathvariableoffset( vectorScale( ( 0, 0, 0 ), 500 ), randomfloatrange( 1, 2 ) );
			vh_plane thread go_path( getvehiclenode( path_start, "targetname" ) );
			vh_plane thread play_fake_flyby();
			vh_plane.b_is_ambient = 1;
			drones[ drones.size ] = vh_plane;
			wait 0,25;
			i++;
		}
		i = 0;
		while ( i < n_count_allies )
		{
			vh_plane = maps/_vehicle::spawn_vehicle_from_targetname( str_targetname_allies );
			vh_plane setspeedimmediate( speed, 300 );
			vh_plane.drone_targets = drones;
			vh_plane thread ambient_allies_weapons_think( 0 );
			vh_plane thread delete_me();
			vh_plane setforcenocull();
			vh_plane pathfixedoffset( ( randomintrange( -2000, 0 ), randomintrange( -1000, 1000 ), randomintrange( -500, 500 ) ) );
			vh_plane pathvariableoffset( vectorScale( ( 0, 0, 0 ), 500 ), randomfloatrange( 1, 2 ) );
			vh_plane thread go_path( getvehiclenode( path_start, "targetname" ) );
			vh_plane.b_is_ambient = 1;
			wait 0,1;
			i++;
		}
		wait randomfloatrange( min_interval, max_interval );
		count--;

		if ( count == 0 )
		{
			return;
		}
	}
}

play_fake_flyby()
{
	wait 0,1;
	sound_ent = spawn( "script_origin", self.origin );
	sound_ent linkto( self, "tag_body" );
	wait randomfloatrange( 1, 3 );
	sound_ent playsound( "evt_fake_flyby" );
	self waittill( "reached_end_node" );
	sound_ent delete();
}

ambient_drones_kill_trig_watcher( trig_name, kill_name )
{
	trigger_wait( trig_name, "targetname" );
	level notify( "end_ambient_drones_" + kill_name );
}

delete_me()
{
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

ambient_drone_die()
{
	self waittill( "death" );
	wait 0,05;
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.delete_on_death ) && isDefined( level._effect[ "fireball_trail_lg" ] ) )
	{
		playfxontag( level._effect[ "fireball_trail_lg" ], self, "tag_origin" );
		playsoundatposition( "evt_amb_drone_explo", self.origin );
		wait 5;
		if ( isDefined( self ) )
		{
			self delete();
		}
	}
	else
	{
		wait 2;
		if ( isDefined( self ) )
		{
			self delete();
		}
	}
}

ambient_allies_weapons_think( n_missile_pct )
{
	self endon( "death" );
	while ( 1 )
	{
		target = undefined;
		if ( isDefined( self.drone_targets ) && self.drone_targets.size > 0 )
		{
			target = random( self.drone_targets );
			if ( isDefined( target ) )
			{
				self maps/_turret::set_turret_target( target, ( 0, 0, 0 ), 1 );
				self maps/_turret::set_turret_target( target, ( 0, 0, 0 ), 2 );
				self thread maps/_turret::fire_turret_for_time( randomfloatrange( 3, 5 ), 1 );
				self thread maps/_turret::fire_turret_for_time( randomfloatrange( 3, 5 ), 2 );
			}
		}
		if ( !isDefined( target ) )
		{
			wait 0,05;
			continue;
		}
		else
		{
			wait randomfloatrange( 4, 6 );
		}
	}
}

spawn_static_actors( str_structname, n_delay_max )
{
	if ( !isDefined( n_delay_max ) )
	{
		n_delay_max = 2;
	}
	a_s_static_locs = getstructarray( str_structname, "targetname" );
	n_index = 0;
	_a806 = a_s_static_locs;
	_k806 = getFirstArrayKey( _a806 );
	while ( isDefined( _k806 ) )
	{
		s_static_loc = _a806[ _k806 ];
		if ( isDefined( s_static_loc.script_string ) && isDefined( level.a_sp_actors[ s_static_loc.script_string ] ) )
		{
			sp_actor = level.a_sp_actors[ s_static_loc.script_string ];
		}
		else
		{
			sp_actor = level.a_sp_actors[ randomint( level.a_sp_actors.size ) ];
		}
		m_drone = spawn( "script_model", s_static_loc.origin );
		m_drone.angles = s_static_loc.angles;
		m_drone.script_noteworthy = s_static_loc.script_noteworthy;
		m_drone getdronemodel( sp_actor.classname );
		m_drone useanimtree( -1 );
		if ( !issubstr( s_static_loc.script_animation, "loop" ) )
		{
			m_drone animscripted( "drone_anim", m_drone.origin, m_drone.angles, level.scr_anim[ s_static_loc.script_animation ] );
			n_index++;
			continue;
		}
		else
		{
			m_drone delay_thread( randomfloat( n_delay_max ), ::loop_anim, level.drones.anims[ s_static_loc.script_animation ] );
		}
		n_index++;
		if ( ( n_index % 5 ) == 0 )
		{
			wait 0,05;
		}
		_k806 = getNextArrayKey( _a806, _k806 );
	}
}

loop_anim( anim_loop )
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self animscripted( "drone_idle_anim", self.origin, self.angles, anim_loop );
		self waittillmatch( "drone_idle_anim" );
		return "end";
	}
}

door_think( str_targetname, str_flag_open, str_flag_close, v_slide, n_time )
{
	if ( !isDefined( n_time ) )
	{
		n_time = 2;
	}
	a_m_doors = getentarray( str_targetname, "targetname" );
	if ( a_m_doors.size == 0 )
	{
		return;
	}
	_a875 = a_m_doors;
	_k875 = getFirstArrayKey( _a875 );
	while ( isDefined( _k875 ) )
	{
		m_door = _a875[ _k875 ];
		while ( isDefined( m_door.target ) )
		{
			a_m_link = getentarray( m_door.target, "targetname" );
			_a881 = a_m_link;
			_k881 = getFirstArrayKey( _a881 );
			while ( isDefined( _k881 ) )
			{
				m_link = _a881[ _k881 ];
				m_link linkto( m_door );
				_k881 = getNextArrayKey( _a881, _k881 );
			}
		}
		m_door disconnectpaths();
		_k875 = getNextArrayKey( _a875, _k875 );
	}
	if ( isDefined( str_flag_open ) )
	{
		flag_wait( str_flag_open );
	}
	_a895 = a_m_doors;
	_k895 = getFirstArrayKey( _a895 );
	while ( isDefined( _k895 ) )
	{
		m_door = _a895[ _k895 ];
		m_door moveto( m_door.origin + v_slide, n_time );
		m_door connectpaths();
		_k895 = getNextArrayKey( _a895, _k895 );
	}
	while ( isDefined( str_flag_close ) )
	{
		flag_wait( str_flag_close );
		_a906 = a_m_doors;
		_k906 = getFirstArrayKey( _a906 );
		while ( isDefined( _k906 ) )
		{
			m_door = _a906[ _k906 ];
			m_door moveto( m_door.origin - v_slide, n_time );
			m_door disconnectpaths();
			_k906 = getNextArrayKey( _a906, _k906 );
		}
	}
}

blend_exposure_over_time( n_exposure_final, n_time )
{
	n_frames = int( n_time * 20 );
	n_exposure_current = getDvarFloat( "r_exposureValue" );
	n_exposure_change_total = n_exposure_final - n_exposure_current;
	n_exposure_change_per_frame = n_exposure_change_total / n_frames;
	setdvar( "r_exposureTweak", 1 );
	i = 0;
	while ( i < n_frames )
	{
		setdvar( "r_exposureValue", n_exposure_current + ( n_exposure_change_per_frame * i ) );
		wait 0,05;
		i++;
	}
	setdvar( "r_exposureValue", n_exposure_final );
}

get_sequence_array( n_sequences, b_randomize )
{
	if ( !isDefined( b_randomize ) )
	{
		b_randomize = 1;
	}
	a_n_sequence = [];
	i = 0;
	while ( i < n_sequences )
	{
		a_n_sequence[ i ] = i;
		i++;
	}
	if ( b_randomize )
	{
		a_n_sequence = array_randomize( a_n_sequence );
	}
	return a_n_sequence;
}

harper_dialog( str_dialog, n_delay, str_endon )
{
	if ( level.is_harper_alive )
	{
		if ( isDefined( str_endon ) )
		{
			level endon( str_endon );
		}
		level.ai_harper queue_dialog( str_dialog, n_delay );
	}
}

get_nearest_squadmate()
{
	n_closest_dist_sq = 2250000;
	ai_closest_squadmate = undefined;
	_a980 = level.a_ai_player_squad;
	_k980 = getFirstArrayKey( _a980 );
	while ( isDefined( _k980 ) )
	{
		ai_squadmate = _a980[ _k980 ];
		if ( isalive( ai_squadmate ) )
		{
			n_dist_sq = distancesquared( level.player.origin, ai_squadmate.origin );
			if ( n_dist_sq < n_closest_dist_sq )
			{
				ai_closest_squadmate = ai_squadmate;
				n_closest_dist_sq = n_dist_sq;
			}
		}
		_k980 = getNextArrayKey( _a980, _k980 );
	}
	return ai_closest_squadmate;
}

squadmate_dialog( str_dialog, n_delay, str_endon )
{
	if ( isDefined( str_endon ) )
	{
		level endon( str_endon );
	}
	ai_squadmate = get_nearest_squadmate();
	while ( !isDefined( ai_squadmate ) )
	{
		wait 1;
		ai_squadmate = get_nearest_squadmate();
	}
	ai_squadmate queue_dialog( str_dialog, n_delay );
}

kill_array( a_stuff_to_kill )
{
	_a1020 = a_stuff_to_kill;
	_k1020 = getFirstArrayKey( _a1020 );
	while ( isDefined( _k1020 ) )
	{
		e_thing = _a1020[ _k1020 ];
		if ( isalive( e_thing ) )
		{
			e_thing dodamage( e_thing.health, ( 0, 0, 0 ) );
			wait randomfloatrange( 0,1, 1 );
		}
		_k1020 = getNextArrayKey( _a1020, _k1020 );
	}
}

turn_on_interior_light_fx()
{
	structs = getstructarray( "fx_struct", "targetname" );
	_a1034 = structs;
	_k1034 = getFirstArrayKey( _a1034 );
	while ( isDefined( _k1034 ) )
	{
		struct = _a1034[ _k1034 ];
		if ( isDefined( struct.script_string ) )
		{
			playfx( level._effect[ struct.script_string ], struct.origin );
		}
		_k1034 = getNextArrayKey( _a1034, _k1034 );
	}
}

save_when_dead( a_e_targets, str_savename, str_endon )
{
	level endon( str_endon );
	if ( !isarray( a_e_targets ) )
	{
		e_target = a_e_targets;
		a_e_targets = [];
		a_e_targets[ 0 ] = e_target;
	}
	b_all_dead = 0;
	while ( !b_all_dead )
	{
		b_all_dead = 1;
		_a1063 = a_e_targets;
		_k1063 = getFirstArrayKey( _a1063 );
		while ( isDefined( _k1063 ) )
		{
			e_target = _a1063[ _k1063 ];
			if ( isalive( e_target ) )
			{
				b_all_dead = 0;
				break;
			}
			else
			{
				_k1063 = getNextArrayKey( _a1063, _k1063 );
			}
		}
		wait 0,5;
	}
	wait 1;
	level thread autosave_by_name( str_savename );
}

scale_model_lods( n_lod_scale_rigid, n_lod_scale_skinned )
{
/#
	assert( isDefined( n_lod_scale_rigid ), "n_lod_scale_rigid is a required parameter for scale_model_LODs!" );
#/
/#
	assert( isDefined( n_lod_scale_skinned ), "n_lod_scale_skinned is a required parameter for scale_model_LODs!" );
#/
	level.player setclientdvar( "r_lodScaleRigid", n_lod_scale_rigid );
	level.player setclientdvar( "r_lodScaleSkinned", n_lod_scale_skinned );
}
