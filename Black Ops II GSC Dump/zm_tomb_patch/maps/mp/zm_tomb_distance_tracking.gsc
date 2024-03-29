#include maps/mp/zm_tomb_chamber;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

zombie_tracking_init()
{
	level.zombie_respawned_health = [];
	if ( !isDefined( level.zombie_tracking_dist ) )
	{
		level.zombie_tracking_dist = 1520;
	}
	if ( !isDefined( level.zombie_tracking_high ) )
	{
		level.zombie_tracking_high = 1000;
	}
	if ( !isDefined( level.zombie_tracking_wait ) )
	{
		level.zombie_tracking_wait = 10;
	}
	for ( ;; )
	{
		while ( 1 )
		{
			a_players = get_players();
			_a33 = a_players;
			_k33 = getFirstArrayKey( _a33 );
			while ( isDefined( _k33 ) )
			{
				player = _a33[ _k33 ];
				if ( !player maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_air_stairs" ) && !player maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_bolt_stairs" ) || player maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_fire_stairs" ) && player maps/mp/zombies/_zm_zonemgr::player_in_zone( "zone_ice_stairs" ) )
				{
					player.b_in_tunnels = 1;
				}
				else
				{
					player.b_in_tunnels = 0;
				}
				_k33 = getNextArrayKey( _a33, _k33 );
			}
			zombies = get_round_enemy_array();
			if ( !isDefined( zombies ) || isDefined( level.ignore_distance_tracking ) && level.ignore_distance_tracking )
			{
				wait level.zombie_tracking_wait;
			}
		}
		else i = 0;
		while ( i < zombies.size )
		{
			if ( isDefined( zombies[ i ] ) && isDefined( zombies[ i ].ignore_distance_tracking ) && !zombies[ i ].ignore_distance_tracking )
			{
				zombies[ i ] thread delete_zombie_noone_looking( level.zombie_tracking_dist, level.zombie_tracking_high );
			}
			i++;
		}
		wait level.zombie_tracking_wait;
	}
}

delete_zombie_noone_looking( how_close, how_high )
{
	self endon( "death" );
	if ( !isDefined( how_close ) )
	{
		how_close = 1500;
	}
	if ( !isDefined( how_high ) )
	{
		how_high = 600;
	}
	distance_squared_check = how_close * how_close;
	too_far_dist = distance_squared_check * 3;
	if ( isDefined( level.zombie_tracking_too_far_dist ) )
	{
		too_far_dist = level.zombie_tracking_too_far_dist * level.zombie_tracking_too_far_dist;
	}
	self.inview = 0;
	self.player_close = 0;
	n_distance_squared = 0;
	n_height_difference = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" )
		{
			i++;
			continue;
		}
		else if ( isDefined( level.only_track_targeted_players ) )
		{
			if ( !isDefined( self.favoriteenemy ) || self.favoriteenemy != players[ i ] )
			{
				i++;
				continue;
			}
		}
		else
		{
			can_be_seen = self player_can_see_me( players[ i ] );
			if ( can_be_seen && distancesquared( self.origin, players[ i ].origin ) < too_far_dist )
			{
				self.inview++;
			}
			n_modifier = 1;
			if ( isDefined( players[ i ].b_in_tunnels ) && players[ i ].b_in_tunnels )
			{
				n_modifier = 2,25;
			}
			n_distance_squared = distancesquared( self.origin, players[ i ].origin );
			n_height_difference = abs( self.origin[ 2 ] - players[ i ].origin[ 2 ] );
			if ( n_distance_squared < ( distance_squared_check * n_modifier ) && n_height_difference < how_high )
			{
				self.player_close++;
			}
		}
		i++;
	}
	if ( self.inview == 0 && self.player_close == 0 )
	{
		if ( !isDefined( self.animname ) || self.animname != "zombie" && self.animname != "mechz_zombie" )
		{
			return;
		}
		if ( isDefined( self.electrified ) && self.electrified == 1 )
		{
			return;
		}
		if ( isDefined( self.in_the_ground ) && self.in_the_ground == 1 )
		{
			return;
		}
		zombies = getaiarray( "axis" );
		if ( isDefined( self.damagemod ) && self.damagemod == "MOD_UNKNOWN" && self.health < self.maxhealth )
		{
			if ( isDefined( self.exclude_distance_cleanup_adding_to_total ) && !self.exclude_distance_cleanup_adding_to_total && isDefined( self.isscreecher ) && !self.isscreecher )
			{
				level.zombie_total++;
				level.zombie_respawned_health[ level.zombie_respawned_health.size ] = self.health;
			}
		}
		else
		{
			if ( ( zombies.size + level.zombie_total ) > 24 || ( zombies.size + level.zombie_total ) <= 24 && self.health >= self.maxhealth )
			{
				if ( isDefined( self.exclude_distance_cleanup_adding_to_total ) && !self.exclude_distance_cleanup_adding_to_total && isDefined( self.isscreecher ) && !self.isscreecher )
				{
					level.zombie_total++;
					if ( self.health < level.zombie_health )
					{
						level.zombie_respawned_health[ level.zombie_respawned_health.size ] = self.health;
					}
				}
			}
		}
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		self notify( "zombie_delete" );
		if ( isDefined( self.is_mechz ) && self.is_mechz )
		{
			self notify( "mechz_cleanup" );
			level.mechz_left_to_spawn++;
			wait_network_frame();
			level notify( "spawn_mechz" );
		}
		self delete();
		recalc_zombie_array();
	}
}

player_can_see_me( player )
{
	playerangles = player getplayerangles();
	playerforwardvec = anglesToForward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
	if ( forwarddotbanzai >= 1 )
	{
		anglefromcenter = 0;
	}
	else if ( forwarddotbanzai <= -1 )
	{
		anglefromcenter = 180;
	}
	else
	{
		anglefromcenter = acos( forwarddotbanzai );
	}
	playerfov = getDvarFloat( "cg_fov" );
	banzaivsplayerfovbuffer = getDvarFloat( "g_banzai_player_fov_buffer" );
	if ( banzaivsplayerfovbuffer <= 0 )
	{
		banzaivsplayerfovbuffer = 0,2;
	}
	playercanseeme = anglefromcenter <= ( ( playerfov * 0,5 ) * ( 1 - banzaivsplayerfovbuffer ) );
	return playercanseeme;
}

escaped_zombies_cleanup_init()
{
	self endon( "death" );
	self.zombie_path_bad = 0;
	while ( 1 )
	{
		if ( !self.zombie_path_bad )
		{
			self waittill( "bad_path" );
		}
		found_player = undefined;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( is_player_valid( players[ i ] ) && self maymovetopoint( players[ i ].origin, 1 ) )
			{
				self.favoriteenemy = players[ i ];
				found_player = 1;
				i++;
				continue;
			}
			i++;
		}
		n_delete_distance = 1500;
		n_delete_height = 1000;
		if ( !isDefined( found_player ) && isDefined( self.in_the_ground ) && !isDefined( self.completed_emerging_into_playable_area ) )
		{
			self thread delete_zombie_noone_looking( n_delete_distance, n_delete_height );
			self.zombie_path_bad = 1;
			self escaped_zombies_cleanup();
		}
		else
		{
			if ( !isDefined( found_player ) && isDefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area )
			{
				self thread delete_zombie_noone_looking( n_delete_distance, n_delete_height );
				self.zombie_path_bad = 1;
				self escaped_zombies_cleanup();
			}
		}
		wait 0,1;
	}
}

escaped_zombies_cleanup()
{
	self endon( "death" );
	s_escape = self get_escape_position();
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if ( isDefined( s_escape ) )
	{
		self setgoalpos( s_escape.origin );
		self thread check_player_available();
		self waittill_any( "goal", "reaquire_player" );
	}
	self.zombie_path_bad = !can_zombie_path_to_any_player();
	wait 0,1;
	if ( !self.zombie_path_bad )
	{
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

get_escape_position()
{
	self endon( "death" );
	str_zone = get_current_zone();
	if ( !isDefined( str_zone ) )
	{
		str_zone = self.zone_name;
	}
	if ( isDefined( str_zone ) )
	{
		a_zones = get_adjacencies_to_zone( str_zone );
		a_dog_locations = get_dog_locations_in_zones( a_zones );
		s_farthest = self get_farthest_dog_location( a_dog_locations );
	}
	return s_farthest;
}

check_player_available()
{
	self notify( "_check_player_available" );
	self endon( "_check_player_available" );
	self endon( "death" );
	self endon( "goal" );
	while ( self.zombie_path_bad )
	{
		wait randomfloatrange( 0,2, 0,5 );
		if ( self can_zombie_see_any_player() )
		{
			self notify( "reaquire_player" );
			return;
		}
	}
	self notify( "reaquire_player" );
}

can_zombie_path_to_any_player()
{
	a_players = get_players();
	i = 0;
	while ( i < a_players.size )
	{
		if ( !is_player_valid( a_players[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			v_player_origin = a_players[ i ].origin;
			if ( isDefined( self.b_on_tank ) )
			{
				if ( isDefined( a_players[ i ].b_already_on_tank ) )
				{
					if ( self.b_on_tank != a_players[ i ].b_already_on_tank )
					{
						v_player_origin = level.vh_tank gettagorigin( "window_left_rear_jmp_jnt" );
					}
				}
			}
			if ( findpath( self.origin, v_player_origin ) )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

can_zombie_see_any_player()
{
	a_players = get_players();
	zombie_in_chamber = maps/mp/zm_tomb_chamber::is_point_in_chamber( self.origin );
	i = 0;
	while ( i < a_players.size )
	{
		if ( !is_player_valid( a_players[ i ] ) )
		{
			i++;
			continue;
		}
		else player_origin = a_players[ i ].origin;
		if ( isDefined( a_players[ i ].b_already_on_tank ) && a_players[ i ].b_already_on_tank )
		{
			if ( isDefined( self.b_on_tank ) && self.b_on_tank )
			{
				return 1;
			}
			else
			{
				player_origin = level.vh_tank gettagorigin( "window_left_rear_jmp_jnt" );
			}
		}
		else
		{
			player_in_chamber = maps/mp/zm_tomb_chamber::is_point_in_chamber( a_players[ i ].origin );
			if ( player_in_chamber != zombie_in_chamber )
			{
				i++;
				continue;
			}
		}
		else
		{
			path_length = 0;
			path_length = self calcpathlength( player_origin );
			if ( self maymovetopoint( player_origin, 1 ) || path_length != 0 )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

get_adjacencies_to_zone( str_zone )
{
	a_adjacencies = [];
	a_adjacencies[ 0 ] = str_zone;
	a_adjacent_zones = getarraykeys( level.zones[ str_zone ].adjacent_zones );
	i = 0;
	while ( i < a_adjacent_zones.size )
	{
		if ( level.zones[ str_zone ].adjacent_zones[ a_adjacent_zones[ i ] ].is_connected )
		{
			a_adjacencies[ a_adjacencies.size ] = a_adjacent_zones[ i ];
		}
		i++;
	}
	return a_adjacencies;
}

get_dog_locations_in_zones( a_zones )
{
	a_dog_locations = [];
	_a471 = a_zones;
	_k471 = getFirstArrayKey( _a471 );
	while ( isDefined( _k471 ) )
	{
		zone = _a471[ _k471 ];
		a_dog_locations = arraycombine( a_dog_locations, level.zones[ zone ].dog_locations, 0, 0 );
		_k471 = getNextArrayKey( _a471, _k471 );
	}
	return a_dog_locations;
}

get_farthest_dog_location( a_dog_locations )
{
	n_farthest_index = 0;
	n_distance_farthest = 0;
	i = 0;
	while ( i < a_dog_locations.size )
	{
		n_distance_sq = distancesquared( self.origin, a_dog_locations[ i ].origin );
		if ( n_distance_sq > n_distance_farthest )
		{
			n_distance_farthest = n_distance_sq;
			n_farthest_index = i;
		}
		i++;
	}
	return a_dog_locations[ n_farthest_index ];
}
