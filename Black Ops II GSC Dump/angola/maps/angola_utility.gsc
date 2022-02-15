#include maps/_mortar;
#include animscripts/shared;
#include maps/_mpla_unita;
#include maps/_challenges_sp;
#include maps/_drones;
#include maps/_dialog;
#include maps/_anim;
#include maps/_scene;
#include maps/_skipto;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );
#using_animtree( "fxanim_props" );

level_init_flags()
{
	flag_init( "show_introscreen_title" );
	flag_init( "end_angola" );
	maps/angola_riverbed::init_flags();
	maps/angola_savannah::init_flags();
}

skipto_setup()
{
	skipto = level.skipto_point;
	if ( skipto == "riverbed_intro" )
	{
		return;
	}
	flag_set( "riverbed_player_intro_done" );
	if ( skipto == "riverbed" )
	{
		return;
	}
	if ( skipto == "savannah_start" )
	{
		return;
	}
	flag_set( "savannah_brim_reached" );
	if ( skipto == "savannah_hill" )
	{
		return;
	}
	if ( skipto == "savannah_finish" )
	{
		return;
	}
}

setup_objectives()
{
	level.obj_start = register_objective( &"ANGOLA_OBJ_START" );
	level.obj_follow_buffel = register_objective( &"ANGOLA_OBJ_FOLLOW_BUFFEL" );
	level.obj_destroy_mortar_crew = register_objective( &"ANGOLA_OBJ_DESTROY_MORTAR" );
	level.obj_destroy_first_wave = register_objective( &"ANGOLA_OBJ_DESTROY_FIRST_WAVE" );
	level.obj_destroy_technical = register_objective( &"ANGOLA_OBJ_DESTROY_TECHNICAL" );
	level.obj_destroy_second_wave = register_objective( &"ANGOLA_OBJ_DESTROY_SECOND_WAVE" );
	level.obj_get_to_buffel = register_objective( &"ANGOLA_OBJ_GET_TO_BUFFEL" );
	level.obj_lockbreaker = register_objective( "" );
	level thread angola_objectives();
}

angola_objectives()
{
	while ( !isDefined( level.savimbi ) )
	{
		wait 0,05;
	}
	flag_wait( "riverbed_player_intro_done" );
	wait 3;
	set_objective( level.obj_start );
	set_objective( level.obj_start, undefined, "done" );
	flag_wait( "savimbi_rally_done" );
	set_objective( level.obj_follow_buffel, level.savimbi, "follow" );
	flag_wait( "savannah_brim_reached" );
	set_objective( level.obj_follow_buffel, level.savimbi, "delete" );
}

setup_challenges()
{
	wait_for_first_player();
	level.player thread maps/_challenges_sp::register_challenge( "machetegib", ::maps/angola_savannah::challenge_machete_gibs );
	level.player thread maps/_challenges_sp::register_challenge( "mortarkills", ::maps/angola_savannah::challenge_mortar_kills );
	level.player thread maps/_challenges_sp::register_challenge( "tankkills", ::maps/angola_savannah::challenge_tank_kills );
}

blackscreen( fadein, stay, fadeout )
{
	blackscreen = newhudelem();
	blackscreen.alpha = 0;
	blackscreen.horzalign = "fullscreen";
	blackscreen.vertalign = "fullscreen";
	blackscreen setshader( "black", 640, 480 );
	if ( fadein > 0 )
	{
		blackscreen fadeovertime( fadein );
	}
	blackscreen.alpha = 1;
	wait stay;
	if ( fadeout > 0 )
	{
		blackscreen fadeovertime( fadeout );
	}
	blackscreen.alpha = 0;
	blackscreen destroy();
}

init_fight( str_node, str_friend, str_enemy )
{
	level.a_nd_engage = getnodearray( str_node, "targetname" );
	_a147 = level.a_nd_engage;
	_k147 = getFirstArrayKey( _a147 );
	while ( isDefined( _k147 ) )
	{
		node = _a147[ _k147 ];
		node.open = 1;
		_k147 = getNextArrayKey( _a147, _k147 );
	}
	level.a_sp_friend = getentarray( str_friend, "targetname" );
	level.a_sp_enemy = getentarray( str_enemy, "targetname" );
}

create_fight( e_friend, e_enemy, b_start_spawn, str_noteworthy )
{
	if ( !isDefined( b_start_spawn ) )
	{
		b_start_spawn = 0;
	}
	if ( !isDefined( e_enemy ) )
	{
		if ( b_start_spawn )
		{
			n_allowed_fights = 9;
		}
		else
		{
			n_allowed_fights = 6;
		}
		current_enemy_fighters = getentarray( level.a_sp_enemy[ 0 ].targetname + "_ai", "targetname" );
		if ( current_enemy_fighters.size <= n_allowed_fights )
		{
			sp_enemy = level.a_sp_enemy[ randomint( level.a_sp_enemy.size ) ];
			if ( distance2dsquared( sp_enemy.origin, level.player.origin ) < 250000 )
			{
				if ( !within_fov( level.player.origin, level.player.angles, sp_enemy.origin, cos( 100 ) ) )
				{
					e_enemy = sp_enemy spawn_ai( 1 );
				}
				else
				{
					return;
				}
			}
			else
			{
				e_enemy = sp_enemy spawn_ai( 1 );
			}
		}
		else
		{
			return;
		}
		if ( isDefined( e_enemy ) )
		{
			if ( isDefined( str_noteworthy ) )
			{
				e_enemy.script_noteworthy = str_noteworthy;
			}
			if ( randomint( 100 ) > 60 )
			{
				e_enemy.script_string = "machete";
				e_enemy maps/_mpla_unita::setup_mpla();
			}
			e_enemy setthreatbiasgroup( "enemy_dancer" );
			e_enemy thread magic_bullet_shield();
		}
	}
	if ( !isDefined( e_friend ) )
	{
		while ( level.a_sp_friend.size )
		{
			while ( !isDefined( e_friend ) )
			{
				sp_friendly = level.a_sp_friend[ randomint( level.a_sp_friend.size ) ];
				if ( !within_fov( level.player.origin, level.player.angles, sp_friendly.origin, cos( 100 ) ) && distance2dsquared( sp_friendly.origin, level.player.origin ) > 250000 )
				{
					e_friend = sp_friendly spawn_ai( 1 );
				}
				wait 0,05;
			}
		}
		if ( isDefined( e_friend ) )
		{
			e_friend thread setup_friendly_dancer();
		}
	}
	nd_e_goal = _get_fight_node();
	if ( isDefined( nd_e_goal ) && isDefined( e_enemy ) && isDefined( e_friend ) )
	{
		e_enemy.e_opp = e_friend;
		e_friend.e_opp = e_enemy;
		nd_f_goal = getnode( nd_e_goal.target, "targetname" );
/#
		e_enemy thread _fight_think_debug( nd_e_goal, nd_f_goal );
#/
		e_enemy thread _fight_think( nd_e_goal );
		e_friend thread _fight_think( nd_f_goal );
	}
	else
	{
		if ( isDefined( e_enemy ) && isalive( e_enemy ) )
		{
			e_enemy stop_magic_bullet_shield();
			e_enemy die();
		}
		if ( isDefined( e_friend ) && isalive( e_friend ) )
		{
			e_friend stop_magic_bullet_shield();
			e_friend die();
		}
		wait 1;
	}
}

setup_friendly_dancer()
{
	self endon( "death" );
	self setthreatbiasgroup( "friendly_dancer" );
	self thread magic_bullet_shield();
}

cleanup_fight( str_name, str_key, n_delay )
{
	if ( isDefined( n_delay ) )
	{
		wait n_delay;
	}
	a_fighter_name = getentarray( str_name, str_key );
	_a280 = a_fighter_name;
	_k280 = getFirstArrayKey( _a280 );
	while ( isDefined( _k280 ) )
	{
		fighter = _a280[ _k280 ];
		if ( isDefined( fighter ) )
		{
			fighter stop_fighter_magic_bullet_shield();
			fighter kill( fighter.origin, level.player );
		}
		wait randomfloatrange( 0,1, 0,3 );
		_k280 = getNextArrayKey( _a280, _k280 );
	}
}

enemy_melee_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, n_model_index, psoffsettime, str_bone_name )
{
	if ( !isalive( self ) )
	{
		return n_damage;
	}
	new_damage = n_damage;
	if ( e_attacker == level.player )
	{
		return new_damage;
	}
	else
	{
		if ( self.a.pose != "back" )
		{
			if ( isai( e_inflictor ) )
			{
				savimbi = getent( "savimbi", "targetname" );
				if ( e_inflictor != savimbi )
				{
					n_damage = int( n_damage / 4 );
				}
				else
				{
					return new_damage;
				}
			}
		}
		else
		{
			if ( isDefined( self.favoriteenemy ) && e_attacker == self.favoriteenemy && isDefined( self.melee ) )
			{
				return 0;
			}
		}
	}
	return new_damage;
}

_get_fight_node()
{
	vh_lead_buffel = getent( "savimbi_buffel", "targetname" );
	i = 0;
	while ( i < level.a_nd_engage.size )
	{
		nd_eval = level.a_nd_engage[ i ];
		level.a_nd_engage[ i ].valid = 1;
		i++;
	}
	a_valid_nodes = [];
	i = 0;
	while ( i < level.a_nd_engage.size )
	{
		if ( level.a_nd_engage[ i ].open && level.a_nd_engage[ i ].valid )
		{
			a_valid_nodes[ a_valid_nodes.size ] = level.a_nd_engage[ i ];
		}
		i++;
	}
	nd_goal = undefined;
	if ( a_valid_nodes.size )
	{
		nd_goal = a_valid_nodes[ randomint( a_valid_nodes.size ) ];
		nd_goal.open = 0;
	}
	return nd_goal;
}

_fight_node_cooldown()
{
	wait 10;
	self.open = 1;
}

_fight_think_debug( nd_goal, nd_f_goal )
{
/#
	self endon( "death" );
	self.e_opp endon( "death" );
	while ( 1 )
	{
		recordline( self.e_opp.origin, nd_f_goal.origin, ( 0, 0, 0 ), "Script", self );
		recordline( self.origin, nd_goal.origin, ( 0, 0, 0 ), "Script", self );
		recordline( self.origin, self.e_opp.origin, ( 0, 0, 0 ), "Script", self );
		recordenttext( "M", self, ( 0, 0, 0 ), "Script" );
		recordenttext( "M", self.e_opp, ( 0, 0, 0 ), "Script" );
		if ( isDefined( nd_goal.open ) )
		{
			record3dtext( nd_goal.open, nd_goal.origin, ( 0, 0, 0 ), "Script", self );
		}
		if ( isDefined( nd_f_goal.open ) )
		{
			record3dtext( nd_f_goal.open, nd_f_goal.origin, ( 0, 0, 0 ), "Script", self );
		}
		wait 0,05;
#/
	}
}

_init_fighter()
{
	self endon( "death" );
	self ent_flag_init( "ready_for_fight" );
	self ent_flag_init( "engaged", 1 );
	self.goalradius = 32;
	if ( self.team == "allies" )
	{
		self.health = 300;
	}
	if ( isalive( self.e_opp ) )
	{
		self.favoriteenemy = self.e_opp;
	}
	self thread _player_nearby_watcher();
	self disable_long_death();
	self.pathenemyfightdist = 0;
	self.pathenemylookahead = 0;
	self.ignoresuppression = 1;
	self.overrideactordamage = ::enemy_melee_damage_override;
}

_release_fighter()
{
	self ent_flag_clear( "ready_for_fight" );
	self ent_flag_clear( "engaged" );
	self.favoriteenemy = undefined;
	self.overrideactordamage = undefined;
}

_fight_think( nd_goal )
{
	self _init_fighter();
	if ( !within_fov( level.player.origin, level.player.angles, nd_goal.origin, cos( 100 ) ) )
	{
		self teleport( nd_goal.origin, nd_goal.angles );
	}
	self thread _fight_get_to_my_node( nd_goal );
	self stop_magic_bullet_shield();
	if ( isalive( self.e_opp ) )
	{
		self thread _opponent_death_watcher();
		self waittill_any( "death", "opp_death", "player_nearby" );
	}
	nd_goal.open = 1;
	if ( isalive( self ) )
	{
		self _release_fighter();
	}
	wait 0,2;
	if ( isDefined( self.hunting_player ) && !self.hunting_player )
	{
		if ( isDefined( self.melee ) )
		{
			self thread _random_death( 6 );
			return;
		}
		else
		{
			self thread _random_death();
		}
	}
}

_fight_get_to_my_node( nd_goal )
{
	self endon( "death" );
	self setgoalnode( nd_goal );
	self waittill( "goal" );
	self ent_flag_set( "ready_for_fight" );
}

_opponent_death_watcher()
{
	self endon( "death" );
	self endon( "player_nearby" );
	self.e_opp waittill( "death" );
	self notify( "opp_death" );
}

_player_nearby_watcher()
{
	self endon( "death" );
	if ( self.team != "allies" )
	{
		return;
	}
	while ( 1 )
	{
		if ( isDefined( level.player ) && distancesquared( self.origin, level.player.origin ) < 40000 )
		{
			self notify( "player_nearby" );
			if ( self.team == "axis" )
			{
				self.e_opp notify( "player_nearby" );
			}
			return;
		}
		wait 0,2;
	}
}

_random_death( offset, b_short_death )
{
	self endon( "death" );
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( isDefined( offset ) )
	{
		wait ( randomfloatrange( 5, 7 ) + offset );
	}
	else if ( isDefined( b_short_death ) && b_short_death )
	{
		wait randomfloatrange( 1, 1,5 );
	}
	else
	{
		if ( isDefined( self.team == "allies" ) && isDefined( self.targetname ) && issubstr( self.targetname, "brim_" ) )
		{
			wait 0,5;
		}
		else
		{
			wait randomfloatrange( 5, 7 );
		}
	}
	if ( isDefined( self ) && isalive( self ) )
	{
		self kill();
	}
}

equip_machete()
{
	self animscripts/shared::placeweaponon( self.weapon, "none" );
	self.melee_weapon = spawn( "script_model", self gettagorigin( "tag_weapon_right" ) );
	self.melee_weapon.angles = self gettagangles( "tag_weapon_right" );
	self.melee_weapon setmodel( "t6_wpn_machete_prop" );
	self.melee_weapon linkto( self, "tag_weapon_right" );
}

unequip_machete()
{
	self animscripts/shared::placeweaponon( self.weapon, "right" );
	self.melee_weapon delete();
}

equip_savimbi_machete()
{
	self.melee_weapon = spawn( "script_model", self gettagorigin( "tag_weapon_left" ) );
	self.melee_weapon.angles = self gettagangles( "tag_weapon_left" );
	self.melee_weapon setmodel( "t6_wpn_machete_prop" );
	self.melee_weapon linkto( self, "tag_weapon_left" );
}

unequip_savimbi_machete()
{
	if ( isDefined( self.melee_weapon ) )
	{
		self.melee_weapon delete();
	}
}

unequip_savimbi_machete_battle()
{
	self detach( "t6_wpn_machete_prop", "tag_weapon_chest" );
}

_drop_machete_on_death()
{
	self waittill( "death" );
	melee_weapon = self.melee_weapon;
	melee_weapon unlink();
	melee_weapon physicslaunch();
	wait 15;
	melee_weapon delete();
}

load_buffel( b_less_full, real_gunner )
{
	if ( !isDefined( real_gunner ) )
	{
		real_gunner = 0;
	}
	if ( !issubstr( self.vehicletype, "buffel" ) )
	{
		return;
	}
	if ( self.riders.size > 0 )
	{
		return;
	}
	self.riders = [];
	if ( self.vehicletype == "apc_buffel" )
	{
		n_vehicle_size = level.vehicle_aianims[ "apc_buffel" ].size - 1;
	}
	else
	{
		n_vehicle_size = level.vehicle_aianims[ "apc_buffel" ].size;
	}
	i = 0;
	while ( i < n_vehicle_size )
	{
		if ( i > 0 && i < 9 && isDefined( b_less_full ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( self.vehicletype != "apc_buffel_gun_turret" && self.vehicletype == "apc_buffel_gun_turret_nophysics" || i == 5 && i == 6 )
			{
				i++;
				continue;
			}
			else
			{
				if ( self.targetname != "savimbi_buffel" && self.targetname != "convoy_destroy_2" && self.targetname != "buffel_mortar" && self.targetname != "convoy_destroy_1" && self.targetname == "riverbed_convoy_buffel" && i > 0 && i < 9 )
				{
					i++;
					continue;
				}
				else
				{
					if ( real_gunner && i == 9 )
					{
						sp_gunner_spawner = getent( "buffel_gunner", "targetname" );
						ai_buffel_gunner = simple_spawn_single( sp_gunner_spawner, ::buffel_gunner, self, level.vehicle_aianims[ "apc_buffel" ][ i ].sittag );
						self.riders[ self.riders.size ] = ai_buffel_gunner;
						i++;
						continue;
					}
					else
					{
						m_rider = self create_friendly_model_actor( i );
						m_rider useanimtree( -1 );
						m_rider linkto( self, level.vehicle_aianims[ "apc_buffel" ][ i ].sittag );
						m_rider.seat = i;
						v_origin = self gettagorigin( level.vehicle_aianims[ "apc_buffel" ][ i ].sittag );
						v_angles = self gettagangles( level.vehicle_aianims[ "apc_buffel" ][ i ].sittag );
						anim_ride = level.vehicle_aianims[ "apc_buffel" ][ i ].idle;
						m_rider animscripted( "ride_buffel_" + i, v_origin, v_angles, anim_ride );
						self.riders[ self.riders.size ] = m_rider;
					}
				}
			}
		}
		i++;
	}
}

unload_buffel()
{
	if ( !issubstr( self.vehicletype, "buffel" ) )
	{
		return;
	}
	_a709 = self.riders;
	_k709 = getFirstArrayKey( _a709 );
	while ( isDefined( _k709 ) )
	{
		m_rider = _a709[ _k709 ];
		if ( isDefined( m_rider ) )
		{
			m_rider delete();
		}
		_k709 = getNextArrayKey( _a709, _k709 );
	}
}

buffel_gunner( vh_to_enter, str_seat_tag )
{
	self enter_vehicle( vh_to_enter, str_seat_tag );
	self thread magic_bullet_shield();
}

load_gaz66( b_less_full )
{
	if ( !issubstr( self.vehicletype, "gaz66" ) )
	{
		return;
	}
	self.riders = [];
	n_random_max = 1;
	i = 0;
	while ( i < n_random_max )
	{
		m_rider = create_friendly_model_actor();
		m_rider useanimtree( -1 );
		m_rider linkto( self, level.vehicle_aianims[ "truck_gaz66_cargo_doors" ][ i ].sittag );
		v_origin = self gettagorigin( level.vehicle_aianims[ "truck_gaz66_cargo_doors" ][ i ].sittag );
		v_angles = self gettagangles( level.vehicle_aianims[ "truck_gaz66_cargo_doors" ][ i ].sittag );
		anim_ride = %ai_crew_gaz66_driver_idle;
		m_rider animscripted( "ride_gaz66_" + i, v_origin, v_angles, anim_ride );
		self.riders[ self.riders.size ] = m_rider;
		i++;
	}
}

unload_gaz66()
{
	if ( self.vehicletype != "truck_gaz66_cargo" )
	{
		return;
	}
	_a759 = self.riders;
	_k759 = getFirstArrayKey( _a759 );
	while ( isDefined( _k759 ) )
	{
		m_rider = _a759[ _k759 ];
		m_rider delete();
		_k759 = getNextArrayKey( _a759, _k759 );
	}
}

destroy_buffel()
{
	self.fire_turret = 0;
	playfxontag( getfx( "buffel_explode" ), self, "tag_body" );
	self notify( "stop_fire" );
	self unload_buffel();
}

create_friendly_model_actor( index )
{
	sp_model = getent( "post_heli_friendly", "targetname" );
	if ( isDefined( self.targetname ) && self.targetname == "convoy_destroy_1" && index == 0 )
	{
		drone = getent( "drone_name", "targetname" );
		sp_model.script_friendname = drone.script_noteworthy;
	}
	else
	{
		if ( isDefined( self.targetname ) && self.targetname == "convoy_destroy_2" && index == 0 )
		{
			drone = getent( "drone_name", "targetname" );
			sp_model.script_friendname = drone.script_string;
		}
		else
		{
			sp_model.script_friendname = undefined;
		}
	}
	m_actor = sp_model spawn_drone( 1 );
	return m_actor;
}

create_enemy_model_actor()
{
	sp_model = getent( "post_heli_enemy", "targetname" );
	m_actor = sp_model spawn_drone( 1 );
	return m_actor;
}

savimbi_setup()
{
	self attach( "t6_wpn_launch_mm1_world", "tag_weapon_right" );
	self set_ignoreme( 1 );
	self.a.allow_sidearm = 0;
	self.disableaivsaimelee = 1;
}

savimbi_fire_mgl_left( savimbi )
{
	v_start = savimbi gettagorigin( "tag_flash" );
	fire_node = getent( "mgl_fire_left", "targetname" );
	magicbullet( "mgl_sp", v_start, fire_node.origin );
}

savimbi_fire_mgl_right( savimbi )
{
	v_start = savimbi gettagorigin( "tag_flash" );
	fire_node = getent( "mgl_fire_right", "targetname" );
	magicbullet( "mgl_sp", v_start, fire_node.origin );
}

savimbi_fire_mgl_forward( savimbi )
{
	v_start = savimbi gettagorigin( "tag_flash" );
	fire_node = getent( "mgl_fire_forward", "targetname" );
	magicbullet( "mgl_sp", v_start, fire_node.origin );
}

player_convoy_watch( str_flag )
{
	vh_lead_buffel = self;
	while ( !flag( str_flag ) )
	{
		if ( !flag( "player_in_helicopter" ) )
		{
			n_player_x = level.player.origin[ 0 ];
			n_player_y = level.player.origin[ 1 ];
			n_buffel_x = vh_lead_buffel.origin[ 0 ];
			n_buffel_y = vh_lead_buffel.origin[ 1 ];
			if ( !flag( "savannah_brim_reached" ) )
			{
				distx_max = 1000;
				distx_death = 1400;
				disty_min = 1800;
				disty_max = 1950;
				disty_death = 2100;
			}
			else if ( flag( "savannah_brim_reached" ) && flag( "reset_distance_fail" ) )
			{
				distx_max = 2800;
				distx_death = 3000;
				disty_min = 1800;
				disty_max = 1950;
				disty_death = 2100;
			}
			else
			{
				distx_max = 1750;
				distx_death = 2000;
				disty_min = 1800;
				disty_max = 1950;
				disty_death = 2100;
			}
			if ( ( n_buffel_x + distx_max ) <= n_player_x && ( n_buffel_x - 2050 ) >= n_player_x || n_player_y > ( n_buffel_y + disty_max ) && n_player_y < ( n_buffel_y - disty_max ) )
			{
				if ( n_player_x < ( n_buffel_x - 2050 ) )
				{
					missionfailedwrapper_nodeath( &"ANGOLA_ABANDON_FAIL" );
				}
				else
				{
					level.player dodamage( 60, vh_lead_buffel.origin + vectorScale( ( 0, 0, 0 ), 3000 ) );
					wait randomfloatrange( 0,1, 0,2 );
				}
				break;
			}
			else
			{
				if ( ( n_buffel_x + distx_death ) <= n_player_x && ( n_buffel_x - distx_death ) >= n_player_x || n_player_y > ( n_buffel_y + disty_death ) && n_player_y < ( n_buffel_y - disty_death ) )
				{
					if ( n_player_x < ( n_buffel_x - distx_death ) )
					{
					}
					else if ( n_player_x > ( n_buffel_x + distx_death ) )
					{
						level.player dodamage( 90, vh_lead_buffel.origin + vectorScale( ( 0, 0, 0 ), 3000 ) );
						wait randomfloatrange( 0,1, 0,2 );
					}
					else
					{
						level.player kill();
					}
					break;
				}
				else
				{
					if ( ( n_buffel_x + 1600 ) <= n_player_x && ( n_buffel_x - 1900 ) >= n_player_x || n_player_y > ( n_buffel_y + disty_min ) && n_player_y < ( n_buffel_y - disty_min ) )
					{
						if ( n_player_y > ( n_buffel_y + disty_min ) )
						{
							level thread set_fail_mortars( 1 );
						}
						else
						{
							if ( n_player_y < ( n_buffel_y - disty_min ) )
							{
								level thread set_fail_mortars( 0 );
							}
						}
						level thread savimbi_say_convoy_warning();
						flag_set( "fail_mortars" );
						if ( !flag( "strafe_hint_active" ) )
						{
							screen_message_create( &"ANGOLA_CONVOY_WARNING" );
						}
						wait randomfloatrange( 2, 2,5 );
						break;
					}
					else
					{
						if ( flag( "fail_mortars" ) && !flag( "strafe_hint_active" ) )
						{
							flag_clear( "fail_mortars" );
							screen_message_delete();
						}
					}
				}
			}
		}
		wait 0,1;
	}
}

prep_savimbi_nag_array()
{
	level.savimbi_nag = [];
	level.savimbi_nag[ 0 ] = "savi_you_should_stay_with_0";
	level.savimbi_nag[ 1 ] = "savi_where_are_you_going_0";
	level.savimbi_nag[ 2 ] = "savi_you_cannot_leave_the_0";
	level.savimbi_nag[ 3 ] = "savi_stay_close_protect_0";
	level.savimbi_nag[ 4 ] = "savi_you_must_stay_close_0";
	level.savimbi_nag[ 5 ] = "savi_there_is_strength_in_0";
	level.savimbi_nag[ 6 ] = "savi_do_not_abandon_the_c_0";
	level.savimbi_nag[ 7 ] = "savi_you_are_too_far_from_0";
}

savimbi_say_convoy_warning()
{
	if ( !flag( "fail_mortars" ) )
	{
		savimbi = level.savimbi;
		if ( level.savimbi_nag.size )
		{
			index = randomintrange( 0, level.savimbi_nag.size - 1 );
			level.savimbi say_dialog( level.savimbi_nag[ index ] );
			arrayremoveindex( level.savimbi_nag, index );
		}
	}
}

set_fail_mortars( n_side )
{
	if ( flag( "fail_mortars" ) )
	{
		return;
	}
	else
	{
		flag_set( "fail_mortars" );
	}
	if ( n_side )
	{
		switch( level.mortar_fail )
		{
			case 1:
				a_mortars = getstructarray( "mortar_savannah_hill_left", "targetname" );
				break;
			case 2:
				a_mortars = getstructarray( "mortar_savannah_left", "targetname" );
				break;
			default:
				a_mortars = getstructarray( "mortar_savannah_start_left", "targetname" );
				break;
		}
		break;
}
else switch( level.mortar_fail )
{
	case 1:
		a_mortars = getstructarray( "mortar_savannah_hill_right", "targetname" );
		break;
	case 2:
		a_mortars = getstructarray( "mortar_savannah_right", "targetname" );
		break;
	default:
		a_mortars = getstructarray( "mortar_savannah_start_right", "targetname" );
		break;
}
while ( flag( "fail_mortars" ) )
{
	e_mortar = a_mortars[ randomint( a_mortars.size ) ];
	e_mortar thread maps/_mortar::mortar_boom( e_mortar.origin, 0,15, 1, 200, getfx( "mortar_savannah" ), 1 );
	wait randomfloatrange( 0,5, 1,5 );
	break;
}
}

watch_savannah_deep_fail()
{
	level endon( "savannah_player_boarded_buffel" );
	deep_fail_trig = getent( "savannah_deep_fail", "targetname" );
	deep_fail_trig waittill( "trigger" );
	level.player kill();
}

watch_savannah_deep_warn()
{
	level endon( "savannah_player_boarded_buffel" );
	level thread watch_savannah_deep_fail();
	t_deep_warn = getent( "savannah_deep_warn", "targetname" );
	while ( !flag( "savannah_player_boarded_buffel" ) )
	{
		if ( level.player istouching( t_deep_warn ) )
		{
			while ( level.player istouching( t_deep_warn ) )
			{
				if ( !flag( "strafe_hint_active" ) )
				{
					screen_message_create( &"ANGOLA_CONVOY_WARNING" );
				}
				wait 0,05;
			}
			if ( !flag( "strafe_hint_active" ) && !flag( "fail_mortars" ) )
			{
				screen_message_delete();
			}
		}
		wait 0,05;
	}
}

watch_savannah_short_fail()
{
	level endon( "savannah_start_hill" );
	fail_trig = getent( "savannah_short_fail", "targetname" );
	fail_trig waittill( "trigger" );
	missionfailedwrapper_nodeath( &"ANGOLA_ABANDON_FAIL" );
}

watch_savannah_short_warn()
{
	level endon( "savannah_start_hudson" );
	level thread watch_savannah_short_fail();
	t_warn = getent( "savannah_short_warn", "targetname" );
	while ( !flag( "savannah_start_hudson" ) )
	{
		if ( level.player istouching( t_warn ) )
		{
			if ( !flag( "strafe_hint_active" ) )
			{
				screen_message_create( &"ANGOLA_CONVOY_WARNING" );
			}
		}
		else
		{
			if ( !flag( "strafe_hint_active" ) && !flag( "fail_mortars" ) )
			{
				screen_message_delete();
			}
		}
		wait 0,05;
	}
}

create_after_strafe_fights( n_heli_runs )
{
	switch( n_heli_runs )
	{
		case 1:
			a_spots = getstructarray( "post_heli_fight_spot", "targetname" );
			break;
		case 2:
			a_spots = getstructarray( "post_heli_fight_spot2", "targetname" );
			break;
		case 4:
			a_spots = getstructarray( "push_fight_spot", "targetname" );
			break;
		default:
			return;
			break;
	}
	goal_array = getnodearray( "final_push_goal", "script_noteworthy" );
	a_scenes[ 0 ] = "_01";
	a_scenes[ 1 ] = "_02";
	a_scenes[ 2 ] = "_03";
	a_scenes[ 3 ] = "_04";
	a_scenes[ 4 ] = "_05";
	v_angles = level.player getplayerangles();
	v_check = level.player.origin + ( anglesToForward( v_angles ) * 500 );
	scene = array_randomize( a_scenes );
	align = get_array_of_closest( v_check, a_spots, undefined, 3 );
	a_old_align = getentarray( "fight_align", "script_noteworthy" );
	i = 0;
	while ( i < a_old_align.size )
	{
		a_old_align[ i ] delete();
		i++;
	}
	i = 0;
	while ( i < 3 )
	{
		level thread _fight_vignette( align[ i ], scene[ i ], goal_array );
		wait 0,05;
		i++;
	}
}

_fight_vignette( align, scene, goal_array )
{
	sp_enemy = getent( "post_heli_enemy", "targetname" );
	sp_friend = getent( "post_heli_friendly", "targetname" );
	m_align = spawn( "script_origin", align.origin );
	if ( isDefined( align.angles ) )
	{
		m_align.angles = ( align.angles[ 0 ], randomint( 360 ), align.angles[ 2 ] );
	}
	else
	{
		m_align.angles = ( 0, randomint( 360 ), 0 );
	}
	m_align.targetname = "hill_fight" + scene;
	m_align.script_noteworthy = "fight_align";
	add_scene_properties( "hill_fight" + scene, m_align.targetname );
	enemy = sp_enemy spawn_ai( 1 );
	if ( isDefined( enemy ) )
	{
		enemy.animname = "hill_fight_mpla" + scene;
		enemy.script_string = "machete_scripted";
		enemy maps/_mpla_unita::setup_mpla();
		enemy setthreatbiasgroup( "enemy_dancer" );
		enemy.a.deathforceragdoll = 1;
	}
	friend = sp_friend spawn_ai( 1 );
	if ( isDefined( friend ) )
	{
		friend.animname = "hill_fight_unita" + scene;
		friend.script_string = "machete_scripted";
		friend maps/_mpla_unita::setup_mpla();
		friend.a.deathforceragdoll = 1;
	}
	if ( isDefined( enemy ) && isDefined( friend ) )
	{
		level thread run_scene( "hill_fight" + scene );
		enemy thread _fight_vignette_think( "hill_fight" + scene );
		friend thread _fight_vignette_think( "hill_fight" + scene );
		scene_wait( "hill_fight" + scene );
		if ( isalive( enemy ) )
		{
			enemy notify( "stop_think" );
			enemy thread _random_death();
		}
		if ( isalive( friend ) )
		{
			enemy notify( "stop_think" );
			if ( friend.animname == "hill_fight_unita_03" )
			{
				friend kill();
			}
			else
			{
				friend thread _random_death();
				if ( isDefined( goal_array ) )
				{
					wait 0,5;
					friend set_goal_node( goal_array[ randomintrange( 0, goal_array.size ) ] );
				}
			}
		}
	}
	else
	{
		if ( isDefined( enemy ) && isalive( enemy ) )
		{
			enemy die();
		}
		if ( isDefined( friend ) && isalive( friend ) )
		{
			friend die();
		}
		wait 1;
	}
}

_fight_vignette_think( scene )
{
	self endon( "stop_think" );
	self waittill( "death" );
	end_scene( scene );
}

attach_weapon()
{
	weaponmodel = "t6_wpn_ar_ak47_world";
	self attach( weaponmodel, "tag_weapon_right" );
	self useweaponhidetags( self.weapon );
}

animate_grass( is_default )
{
	grass_array = getentarray( "fxanim_heli_grass_flyover", "targetname" );
	far_grass_array = getentarray( "fxanim_heli_grass_flyover_2", "targetname" );
	_a1292 = grass_array;
	_k1292 = getFirstArrayKey( _a1292 );
	while ( isDefined( _k1292 ) )
	{
		grass = _a1292[ _k1292 ];
		grass useanimtree( -1 );
		if ( is_default )
		{
			grass notify( "stop_loop" );
			grass thread anim_loop( grass, "grass_standing_amb_loop", "stop_loop", "fxanim_props" );
		}
		else
		{
			grass thread animate_grass_single();
		}
		_k1292 = getNextArrayKey( _a1292, _k1292 );
	}
	_a1306 = far_grass_array;
	_k1306 = getFirstArrayKey( _a1306 );
	while ( isDefined( _k1306 ) )
	{
		grass = _a1306[ _k1306 ];
		grass useanimtree( -1 );
		if ( is_default )
		{
			grass notify( "stop_loop" );
			grass thread anim_loop( grass, "grass_standing_amb_loop", "stop_loop", "fxanim_props" );
		}
		else
		{
			grass delay_thread( 0,4, ::animate_grass_single );
		}
		_k1306 = getNextArrayKey( _a1306, _k1306 );
	}
}

animate_grass_single()
{
	self notify( "stop_loop" );
	self anim_single( self, "grass_heli_fly_over", "fxanim_props" );
	level thread animate_grass( 1 );
}

stop_savannah_grass()
{
	grass_array = getentarray( "fxanim_heli_grass_flyover", "targetname" );
	_a1331 = grass_array;
	_k1331 = getFirstArrayKey( _a1331 );
	while ( isDefined( _k1331 ) )
	{
		grass = _a1331[ _k1331 ];
		grass notify( "stop_loop" );
		_k1331 = getNextArrayKey( _a1331, _k1331 );
	}
	grass_array = getentarray( "fxanim_heli_grass_flyover_2", "targetname" );
	_a1337 = grass_array;
	_k1337 = getFirstArrayKey( _a1337 );
	while ( isDefined( _k1337 ) )
	{
		grass = _a1337[ _k1337 ];
		grass notify( "stop_loop" );
		_k1337 = getNextArrayKey( _a1337, _k1337 );
	}
}

animate_heli_grass( is_default )
{
	grass_array = getentarray( "fxanim_heli_grass_land", "targetname" );
	_a1346 = grass_array;
	_k1346 = getFirstArrayKey( _a1346 );
	while ( isDefined( _k1346 ) )
	{
		grass = _a1346[ _k1346 ];
		grass useanimtree( -1 );
		grass notify( "stop_loop" );
		if ( is_default )
		{
			grass thread anim_loop( grass, "grass_standing_amb_loop", "stop_loop", "fxanim_props" );
		}
		else
		{
			grass thread anim_loop( grass, "grass_heli_fly_over_loop", "stop_loop", "fxanim_props" );
		}
		_k1346 = getNextArrayKey( _a1346, _k1346 );
	}
}

victory_grass()
{
	static_grass = getentarray( "static_heli_grass_land", "targetname" );
	_a1365 = static_grass;
	_k1365 = getFirstArrayKey( _a1365 );
	while ( isDefined( _k1365 ) )
	{
		grass = _a1365[ _k1365 ];
		grass delete();
		_k1365 = getNextArrayKey( _a1365, _k1365 );
	}
	cloth_grass = getentarray( "fxanim_heli_grass_land", "targetname" );
	_a1372 = cloth_grass;
	_k1372 = getFirstArrayKey( _a1372 );
	while ( isDefined( _k1372 ) )
	{
		grass = _a1372[ _k1372 ];
		grass show();
		_k1372 = getNextArrayKey( _a1372, _k1372 );
	}
}

hide_victory_grass()
{
	cloth_grass = getentarray( "fxanim_heli_grass_land", "targetname" );
	_a1382 = cloth_grass;
	_k1382 = getFirstArrayKey( _a1382 );
	while ( isDefined( _k1382 ) )
	{
		grass = _a1382[ _k1382 ];
		grass hide();
		_k1382 = getNextArrayKey( _a1382, _k1382 );
	}
}

turn_on_convoy_headlights()
{
	a_vh = getentarray( "convoy", "script_noteworthy" );
	_a1391 = a_vh;
	_k1391 = getFirstArrayKey( _a1391 );
	while ( isDefined( _k1391 ) )
	{
		vehicle = _a1391[ _k1391 ];
		vehicle setclientflag( 10 );
		_k1391 = getNextArrayKey( _a1391, _k1391 );
	}
}

delete_array( value, key )
{
	stuff = getentarray( value, key );
	i = 0;
	while ( i < stuff.size )
	{
		stuff[ i ] delete();
		i++;
	}
}

delete_struct_array( value, key )
{
	stuff = getstructarray( value, key );
	i = 0;
	while ( i < stuff.size )
	{
		stuff[ i ] structdelete();
		i++;
	}
}

refill_player_clip()
{
	a_str_weapons = level.player getweaponslistprimaries();
	_a1418 = a_str_weapons;
	_k1418 = getFirstArrayKey( _a1418 );
	while ( isDefined( _k1418 ) )
	{
		str_weapon = _a1418[ _k1418 ];
		level.player givemaxammo( str_weapon );
		level.player setweaponammoclip( str_weapon, weaponclipsize( str_weapon ) );
		_k1418 = getNextArrayKey( _a1418, _k1418 );
	}
}

savannah_player_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, n_model_index, psoffsettime )
{
	damage_modifier = get_difficulty_damage_modifier();
	if ( isDefined( str_weapon ) || str_weapon == "buffel_gun_turret" && str_weapon == "eland_turret" )
	{
		return 0;
	}
	if ( !flag( "fail_stop_protection" ) )
	{
		if ( str_means_of_death == "MOD_PROJECTILE_SPLASH" || str_means_of_death == "MOD_PROJECTILE" )
		{
			n_damage = int( n_damage / ( damage_modifier * 4 ) );
		}
		else
		{
			n_damage = int( n_damage / damage_modifier );
		}
	}
	else
	{
		return n_damage * 3;
	}
	return n_damage;
}

get_difficulty_damage_modifier()
{
	str_difficulty = getdifficulty();
	switch( str_difficulty )
	{
		case "fu":
			return 3;
			case "hard":
				return 3;
				case "medium":
					return 3;
					default:
						return 6;
					}
				}
			}
		}
	}
}

enemy_rpg_damage_override( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, n_model_index, psoffsettime, str_bone_name )
{
	if ( e_inflictor == level.player )
	{
		return n_damage;
	}
	else
	{
		if ( isDefined( self.targetname ) && issubstr( self.targetname, "final_launcher" ) )
		{
			return 0;
		}
		else
		{
			n_damage = int( n_damage / 3 );
			return n_damage;
		}
	}
}

show_victory_vehicles( b_show )
{
	m_buffel = getent( "destroyed_buffel", "targetname" );
	m_tank = getent( "destroyed_tank", "targetname" );
	if ( b_show )
	{
		m_buffel show();
		m_buffel solid();
		m_tank show();
		m_tank solid();
	}
	else
	{
		m_buffel hide();
		m_buffel notsolid();
		m_tank hide();
		m_tank notsolid();
	}
}

angola_challenge_actor_killed_callback( e_inflictor, e_attacker, n_damage, str_mod, str_weapon, v_hit_direction, str_hit_location, psoffsettime )
{
	if ( e_attacker == level.player )
	{
		if ( str_weapon == "machete_sp" )
		{
			level.player notify( level.machete_notify );
			return;
		}
		else
		{
			if ( str_weapon == "mortar_shell_dpad_sp" )
			{
				level.mortar_kills++;
				if ( level.mortar_kills == 1 )
				{
					level thread mortar_kill_timer();
				}
			}
		}
	}
}

mortar_kill_timer()
{
	wait 0,3;
	if ( level.mortar_kills > 4 )
	{
		flag_set( "mortar_challenge_complete" );
	}
	else
	{
		level.mortar_kills = 0;
	}
}

check_player_weapons()
{
	n_clip = level.player getweaponammoclip( "mortar_shell_dpad_sp" );
	level.player set_temp_stat( 1, n_clip );
	n_stock = level.player getweaponammostock( "mortar_shell_dpad_sp" );
	level.player set_temp_stat( 2, n_stock );
}

remove_buffel_riders()
{
	_a1565 = self.riders;
	_k1565 = getFirstArrayKey( _a1565 );
	while ( isDefined( _k1565 ) )
	{
		rider = _a1565[ _k1565 ];
		if ( rider.seat != 0 && rider.seat != 9 )
		{
			rider delete();
		}
		_k1565 = getNextArrayKey( _a1565, _k1565 );
	}
}

riverbed_fail_watch()
{
	array_thread( getentarray( "riverbed_warning", "targetname" ), ::riverbed_fail_warning );
	array_thread( getentarray( "riverbed_fail", "targetname" ), ::riverbed_fail_kill );
}

riverbed_fail_warning()
{
	n_count = 1;
	while ( !flag( "savannah_base_reached" ) && !flag( "clash_runners_ready" ) && !flag( "savimbi_reached_savannah" ) )
	{
		self waittill( "trigger" );
		if ( ( n_count % 2 ) != 0 )
		{
			level.savimbi say_dialog( "savi_i_would_not_wish_you_0", 0,5 );
		}
		else
		{
			level.savimbi say_dialog( "savi_stay_close_to_the_co_0", 0,5 );
		}
		wait randomfloatrange( 5, 7,5 );
		n_count++;
	}
}

riverbed_fail_kill()
{
	self waittill( "trigger" );
	setdvar( "ui_deadquote", &"ANGOLA_CONVOY_FAIL" );
	level.player maps/_mortar::explosion_boom( "mortar_savannah" );
	wait 0,45;
	level.player dodamage( level.player.health + 1000, ( 0, 0, 0 ) );
}

mpla_scripted_attach_machete( ai_guy )
{
	ai_guy.scripted_melee_weapon = spawn( "script_model", ai_guy gettagorigin( "tag_weapon_left" ) );
	ai_guy.scripted_melee_weapon.angles = ai_guy gettagangles( "tag_weapon_left" );
	ai_guy.scripted_melee_weapon setmodel( "t6_wpn_machete_prop" );
	ai_guy.scripted_melee_weapon linkto( ai_guy, "tag_weapon_left", ( 0, 0, 0 ), ( 0, 0, 0 ) );
}

mpla_scripted_drop_machete( ai_guy )
{
	scripted_melee_weapon = ai_guy.scripted_melee_weapon;
	scripted_melee_weapon unlink();
	scripted_melee_weapon physicslaunch();
	wait 15;
	scripted_melee_weapon delete();
}

mpla_disable_aim_assist( ai_guy )
{
	ai_guy disableaimassist();
}

gib_arm( ai_guy )
{
	ai_guy.force_gib = 1;
	ai_guy.custom_gib_refs = "left_arm";
}

gib_head( ai_guy )
{
	ai_guy.force_gib = 1;
	ai_guy.custom_gib_refs = "left_arm";
}

toggle_player_radio( b_toggle )
{
	player = level.player;
	if ( b_toggle )
	{
		player.currentweapon = player getcurrentweapon();
		player giveweapon( "air_support_radio_sp" );
		player setactionslot( 1, "weapon", "air_support_radio_sp" );
	}
	else
	{
		player switchtoweapon( player.currentweapon );
		player takeweapon( "air_support_radio_sp" );
	}
}

riverbed_lockbreaker_perk()
{
	mortar_array = getentarray( "pickup_mortar", "targetname" );
	_a1673 = mortar_array;
	_k1673 = getFirstArrayKey( _a1673 );
	while ( isDefined( _k1673 ) )
	{
		mortar = _a1673[ _k1673 ];
		mortar delete();
		_k1673 = getNextArrayKey( _a1673, _k1673 );
	}
	run_scene_first_frame( "lockbreaker" );
	t_open = getent( "lockbreaker_buffel_trigger", "targetname" );
	t_open sethintstring( &"SCRIPT_HINT_BRUTE_FORCE" );
	t_open setcursorhint( "HINT_NOICON" );
	t_open trigger_off();
	a_weapons = getentarray( "lockbreaker_weapon", "script_noteworthy" );
	_a1691 = a_weapons;
	_k1691 = getFirstArrayKey( _a1691 );
	while ( isDefined( _k1691 ) )
	{
		weapon = _a1691[ _k1691 ];
		weapon trigger_off();
		_k1691 = getNextArrayKey( _a1691, _k1691 );
	}
	level.player waittill_player_has_brute_force_perk();
	t_open trigger_on();
	set_objective( level.obj_lockbreaker, t_open, "interact" );
	t_open waittill( "trigger" );
	set_objective( level.obj_lockbreaker, t_open, "remove" );
	t_open delete();
	a_weapons = getentarray( "lockbreaker_weapon", "script_noteworthy" );
	_a1706 = a_weapons;
	_k1706 = getFirstArrayKey( _a1706 );
	while ( isDefined( _k1706 ) )
	{
		weapon = _a1706[ _k1706 ];
		weapon trigger_on();
		_k1706 = getNextArrayKey( _a1706, _k1706 );
	}
	level thread run_scene( "lockbreaker_interact" );
	lockpick = get_model_or_models_from_scene( "lockbreaker_interact", "lockbreaker" );
	lockpick setforcenocull();
	scene_wait( "lockbreaker_interact" );
	level thread give_player_mortars();
}

give_player_mortars()
{
	level.player set_temp_stat( 3, 1 );
	level.player giveweapon( "mortar_shell_dpad_sp" );
	level.player setactionslot( 4, "weapon", "mortar_shell_dpad_sp" );
	level.player givemaxammo( "mortar_shell_dpad_sp" );
	level thread mortar_helper_message( 2 );
	level.player thread monitor_mortar_ammo();
}

monitor_mortar_ammo()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( !self getammocount( "mortar_shell_dpad_sp" ) && self getcurrentweapon() == "mortar_shell_dpad_sp" )
		{
			a_weapons = self getweaponslistprimaries();
			self switchtoweapon( a_weapons[ 0 ] );
		}
		wait 0,1;
	}
}

fake_fire( m_model )
{
	fire_origin = m_model gettagorigin( "tag_flash" );
	fire_angles = m_model gettagangles( "tag_flash" );
	forward = anglesToForward( fire_angles );
	forward = vectorScale( forward, 750 );
	playfxontag( level._effect[ "scene_weapon_flash" ], m_model, "tag_flash" );
	m_model playsoundontag( "wpn_ak47_fire_npc", "tag_flash" );
	magicbullet( "ak47_sp", fire_origin, m_model.origin + ( anglesToForward( fire_angles ) * 500 ) );
}

fake_weapon( m_model )
{
	m_model setactorweapon( "ak47_sp" );
}

warn_to_kill_player( n_time_to_fail )
{
	if ( !isDefined( n_time_to_fail ) )
	{
		n_time_to_fail = 0;
	}
	level endon( "strafe_run_called" );
	fake_mortar = spawn( "script_origin", ( 0, 0, 0 ) );
	savimbi_buffel = getent( "savimbi_buffel", "targetname" );
	x = 1;
	while ( x < ( n_time_to_fail + 1 ) )
	{
		area_forward = ( anglesToForward( savimbi_buffel.angles ) * 500 ) * ( ( n_time_to_fail + 1 ) - x );
		fake_mortar.origin = savimbi_buffel.origin + area_forward + ( randomintrange( -500, 500 ), 0, 0 );
		fake_mortar thread maps/_mortar::mortar_boom( fake_mortar.origin, 0,05, 0,25, 50, getfx( "mortar_savannah" ), 0, 0 );
		wait 1;
		x++;
	}
	fake_mortar.origin = level.player.origin;
	fake_mortar thread maps/_mortar::mortar_boom( level.player.origin, 1, 1, 200, getfx( "mortar_savannah" ), 0 );
	level.player kill();
}

stop_fighter_magic_bullet_shield( ent )
{
	self endon( "death" );
	if ( !isDefined( ent ) )
	{
		ent = self;
	}
	if ( isai( ent ) )
	{
		ent bloodimpact( "normal" );
	}
	ent.attackeraccuracy = 1;
	ent notify( "stop_magic_bullet_shield" );
	ent.magic_bullet_shield = undefined;
	ent._mbs = undefined;
}

drone_killer()
{
	level endon( "push_warp_ready" );
	while ( 1 )
	{
		a_drones = get_array_of_closest( level.player.origin, level.drones.team[ "axis" ].array, undefined, undefined, 1024 );
		_a1826 = a_drones;
		_k1826 = getFirstArrayKey( _a1826 );
		while ( isDefined( _k1826 ) )
		{
			drone = _a1826[ _k1826 ];
			if ( isDefined( drone ) )
			{
				drone dodamage( 100, drone.origin );
			}
			wait 0,05;
			_k1826 = getNextArrayKey( _a1826, _k1826 );
		}
		wait 0,05;
	}
}

unita_say( str_vo )
{
	ai_unita = get_closest_ai( level.player.origin, "allies" );
	ai_unita say_dialog( str_vo );
}
