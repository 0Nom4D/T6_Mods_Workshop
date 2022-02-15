#include maps/_horse_rider;
#include maps/_ammo_refill;
#include maps/createart/afghanistan_art;
#include maps/_rusher;
#include maps/_skipto;
#include maps/_scene;
#include maps/_dialog;
#include maps/_turret;
#include maps/_horse;
#include maps/_vehicle_aianim;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/_utility;
#include common_scripts/utility;

skipto_setup()
{
	load_gumps_afghanistan();
	skipto = level.skipto_point;
	if ( skipto == "intro" )
	{
		return;
	}
	if ( skipto == "horse_intro" )
	{
		return;
	}
	set_objective( level.obj_afghan_bc3a, undefined, "done" );
	maps/createart/afghanistan_art::turn_down_fog();
	if ( skipto == "rebel_base_intro" )
	{
		return;
	}
	flag_set( "first_rebel_base_visit" );
	if ( skipto == "firehorse" )
	{
		return;
	}
	if ( skipto == "wave_1" )
	{
		return;
	}
	flag_set( "wave1_done" );
	if ( skipto == "wave_2" )
	{
		return;
	}
	if ( skipto == "arena_sandbox" )
	{
		return;
	}
	flag_set( "wave2_done" );
	if ( skipto == "wave_3" )
	{
		return;
	}
	flag_set( "wave3_done" );
	if ( skipto == "blocking_done" )
	{
		return;
	}
	flag_set( "blocking_done" );
	if ( skipto == "horse_charge" )
	{
		return;
	}
	flag_set( "player_pushed_off_horse" );
	if ( skipto == "krav_tank" )
	{
		return;
	}
	if ( skipto == "krav_captured" )
	{
		return;
	}
	flag_set( "interrogation_started" );
	if ( skipto == "interrogation" )
	{
		return;
	}
	flag_set( "numbers_struggle_completed" );
	if ( skipto == "beat_down" )
	{
		return;
	}
	flag_set( "deserted_sequence" );
	if ( skipto == "deserted" )
	{
		return;
	}
}

load_gumps_afghanistan()
{
	if ( is_after_skipto( "krav_tank" ) )
	{
		load_gump( "afghanistan_gump_ending" );
	}
	else if ( is_after_skipto( "rebel_base_intro" ) )
	{
		load_gump( "afghanistan_gump_arena" );
	}
	else
	{
		load_gump( "afghanistan_gump_intro" );
	}
}

delete_section1_scenes()
{
	delete_scene_all( "e1_s1_pulwar", 1, 1 );
	delete_scene_all( "e1_s1_pulwar_single", 1, 1 );
	delete_scene( "e1_player_wood_greeting", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_woods_intro", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_woods_horse_intro", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_woods_intro_idle", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_idle", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_player", 1, 1 );
	delete_scene( "e1_zhao_horse_charge", 1, 1 );
	delete_scene( "e1_horse_charge_muj1_endloop", 1, 1 );
	delete_scene( "e1_horse_charge_muj2_endloop", 1, 1 );
	delete_scene( "e1_horse_charge_muj3_endloop", 1, 1 );
	delete_scene( "e1_horse_charge_muj4_endloop", 1, 1 );
	delete_scene_all( "e1_horse_charge_muj1", 1, 1 );
	delete_scene_all( "e1_horse_charge_muj2", 1, 1 );
	delete_scene_all( "e1_horse_charge_muj3", 1, 1 );
	delete_scene_all( "e1_horse_charge_muj4", 1, 1 );
	delete_scene( "e1_zhao_horse_approach_spread", 1, 1 );
	delete_scene( "e1_zhao_horse_charge_woods", 1, 1 );
}

delete_section1_ride_scenes()
{
	delete_scene_all( "e1_truck_offload", 1 );
	delete_scene_all( "e1_truck_offload_idle", 1 );
	delete_scene_all( "e1_truck_hold_truck_idle", 1 );
	delete_scene_all( "e1_ride_lookout", 1 );
	delete_scene_all( "e2_tank_ride_idle_start", 1 );
	delete_scene_all( "e2_tank_ride_idle", 1 );
	delete_scene_all( "e2_tank_ride_idle_end" );
}

delete_section_2_scenes()
{
	delete_scene_all( "e2_cooking_muj", 1 );
	delete_scene_all( "e2_drum_burner", 1 );
	delete_scene_all( "e2_gunsmith", 1 );
	delete_scene_all( "e2_smokers", 1 );
	delete_scene_all( "e2_generator", 1 );
	delete_scene_all( "e2_tower_lookout_startidl", 1 );
	delete_scene_all( "e2_tower_lookout_follow", 1 );
	delete_scene_all( "e2_tower_lookout_endidl", 1 );
	delete_scene_all( "e2_stinger_move", 1 );
	delete_scene_all( "e2_stinger_endidl", 1 );
	delete_scene_all( "e2_stacker_carry_1", 1, undefined, 1 );
	delete_scene_all( "e2_stacker_carry_2", 1, undefined, 1 );
	delete_scene_all( "e2_stacker_main_2", 1, undefined, 1 );
	delete_scene_all( "e2_stacker_endidl", 1, undefined, 1 );
	delete_scene_all( "e2_stacker_3", 1, undefined, 1 );
	delete_scene_all( "e2_window_startidl", 1, undefined, 1 );
	delete_scene_all( "e2_window_follow", 1, undefined, 1 );
	delete_scene_all( "e2_walltop_start", 1, undefined, 1 );
	delete_scene_all( "e2_walltop_lookout", 1, undefined, 1 );
	delete_scene_all( "e2_walltop_end", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_1", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_2", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_3", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_4", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_5", 1, undefined, 1 );
	delete_scene_all( "e2_runout_startidl_6", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_1", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_2", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_3", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_4", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_5", 1, undefined, 1 );
	delete_scene_all( "e2_runout_run_6", 1, undefined, 1 );
	delete_scene_all( "e2_tank_guy", 1, undefined, 1 );
	delete_scene_all( "e2_rooftop_guys", 1, undefined, 1 );
}

delete_section3_scenes()
{
	delete_scene( "e3_exit_map_room", 1 );
	delete_scene( "e3_map_room_idle", 1, 1 );
	delete_scene( "e3_ride_out", 1, 1 );
}

hero_setup( spawner_name )
{
	hero = simple_spawn_single( spawner_name );
	hero.name = spawner_name;
	hero thread make_hero();
}

player_lock_in_position( origin, angles )
{
	link_to_ent = spawn( "script_model", origin );
	link_to_ent.angles = angles;
	link_to_ent setmodel( "tag_origin" );
	self playerlinktoabsolute( link_to_ent, "tag_origin" );
	self waittill( "unlink_from_ent" );
	self unlink();
	link_to_ent delete();
}

get_player_horse()
{
	return level.player.viewlockedentity;
}

spawn_rideable_horse( horse_targetname )
{
	horse = spawn_vehicle_from_targetname( horse_targetname );
	horse makevehicleusable();
	return horse;
}

setup_rider( vh_riders_horse )
{
	self endon( "death" );
	self.vh_horse = vh_riders_horse;
	self.deathfunction = ::rider_died_make_horse_rideable;
}

rider_died_make_horse_rideable()
{
	self endon( "death" );
	self.vh_horse makevehicleusable();
}

make_horse_usable()
{
	self endon( "death" );
	wait 1;
	ai_rider = self get_driver();
	if ( isDefined( ai_rider ) )
	{
		ai_rider waittill( "death" );
		self makevehicleusable();
	}
}

horse_has_rider()
{
	self endon( "death" );
	while ( !isDefined( self get_driver() ) )
	{
		wait 1;
	}
	self notify( "got_rider" );
	self setvehgoalpos( self.origin, 1 );
}

get_ai_count( str_faction )
{
	if ( str_faction == "allies" )
	{
		a_ai_guys = getaiarray( "allies" );
	}
	else if ( str_faction == "axis" )
	{
		a_ai_guys = getaiarray( "axis" );
	}
	else if ( str_faction == "neutral" )
	{
		a_ai_guys = getaiarray( "neutral" );
	}
	else
	{
		if ( str_faction == "all" )
		{
			a_ai_guys = getaiarray( "all" );
		}
	}
	return a_ai_guys.size;
}

lerp_dof_over_time( time )
{
	incs = int( time / 0,05 );
	incnearstart = ( 0 - 0 ) / incs;
	incnearend = ( 400 - 650 ) / incs;
	incfarstart = ( 2000 - 700 ) / incs;
	incfarend = ( 3000 - 15000 ) / incs;
	incnearblur = ( 4 - 10 ) / incs;
	incfarblur = ( 3 - 7 ) / incs;
	current_nearstart = 0;
	current_nearend = 650;
	current_farstart = 700;
	current_farend = 15000;
	current_nearblur = 10;
	current_farblur = 7;
	i = 0;
	while ( i < incs )
	{
		self setdepthoffield( current_nearstart, current_nearend, current_farstart, current_farend, current_nearblur, current_farblur );
		current_nearstart += incnearstart;
		current_nearend += incnearend;
		current_farstart += incfarstart;
		current_farend += incfarend;
		current_nearblur += incnearblur;
		current_farblur += incfarblur;
		wait 0,05;
		i++;
	}
}

lerp_dof_over_time_pass_out( time )
{
	incs = int( time / 0,05 );
	incnearstart = ( 0 - 0 ) / incs;
	incnearend = ( 650 - 1 ) / incs;
	incfarstart = ( 700 - 8000 ) / incs;
	incfarend = ( 15000 - 10000 ) / incs;
	incnearblur = ( 10 - 6 ) / incs;
	incfarblur = ( 7 - 0 ) / incs;
	current_nearstart = 0;
	current_nearend = 1;
	current_farstart = 8000;
	current_farend = 10000;
	current_nearblur = 6;
	current_farblur = 0;
	i = 0;
	while ( i < incs )
	{
		self setdepthoffield( current_nearstart, current_nearend, current_farstart, current_farend, current_nearblur, current_farblur );
		current_nearstart += incnearstart;
		current_nearend += incnearend;
		current_farstart += incfarstart;
		current_farend += incfarend;
		current_nearblur += incnearblur;
		current_farblur += incfarblur;
		wait 0,05;
		i++;
	}
}

reset_dof()
{
	self setdepthoffield( 0, 1, 8000, 10000, 6, 0 );
}

spawn_weapon_cache( str_weapon )
{
	m_ammo_cache = getent( "weapon_cache", "script_noteworthy" );
	if ( str_weapon == "rpg" )
	{
		m_ammo_cache thread maps/_ammo_refill::activate_extra_slot( 1, "afghanstinger_sp" );
	}
	else
	{
		if ( str_weapon == "afghanstinger" )
		{
			m_ammo_cache thread maps/_ammo_refill::activate_extra_slot( 2, "afghanstinger_sp" );
		}
	}
}

setup_weapon_caches()
{
	a_ammo_caches = array( "bp3_cache", "bp2_cache", "cache1_cache", "cache2_cache", "cache3_cache", "cache4_cache", "cache5_cache", "cache6_cache", "cache7_cache" );
	_a445 = a_ammo_caches;
	_k445 = getFirstArrayKey( _a445 );
	while ( isDefined( _k445 ) )
	{
		str_cache_name = _a445[ _k445 ];
		m_ammo_cache = getent( str_cache_name, "script_noteworthy" );
		m_ammo_cache thread maps/_ammo_refill::activate_extra_slot( 1, "afghanstinger_sp" );
		m_ammo_cache thread maps/_ammo_refill::activate_extra_slot( 2, "afghanstinger_sp" );
		_k445 = getNextArrayKey( _a445, _k445 );
	}
}

init_weapon_cache()
{
	level thread spawn_weapon_cache( "afghanstinger" );
}

stock_weapon_caches()
{
	level thread setup_weapon_caches();
}

hind_fireat_target( e_target )
{
	self endon( "death" );
	str_difficulty = getdifficulty();
	n_burst = randomintrange( 12, 25 );
	if ( isplayer( e_target ) )
	{
		if ( str_difficulty == "easy" )
		{
			n_burst = randomintrange( 12, 25 );
		}
		else if ( str_difficulty == "medium" )
		{
			n_burst = randomintrange( 12, 25 );
		}
		else if ( str_difficulty == "hard" )
		{
			n_burst = randomintrange( 20, 25 );
		}
		else
		{
			if ( str_difficulty == "fu" )
			{
				n_burst = randomintrange( 30, 35 );
			}
		}
	}
	self setlookatent( e_target );
	wait 3;
	i = 0;
	while ( i < n_burst )
	{
		if ( isplayer( e_target ) )
		{
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
					n_offset_z = randomintrange( 0, 16 );
				}
			}
		}
		else
		{
			n_offset_x = randomintrange( -64, 64 );
			n_offset_y = randomintrange( -24, 24 );
			n_offset_z = randomintrange( -24, 84 );
		}
		if ( isDefined( e_target ) )
		{
			v_target = ( n_offset_x, n_offset_y, n_offset_z ) + e_target.origin;
			magicbullet( "btr60_heavy_machinegun", self.origin + ( 251, 0, -130 ), v_target );
		}
		wait 0,05;
		i++;
	}
	num_rockets = randomintrange( 1, 5 );
	if ( isplayer( e_target ) )
	{
		if ( str_difficulty == "easy" )
		{
			num_rockets = randomintrange( 1, 2 );
		}
		else if ( str_difficulty == "medium" )
		{
			num_rockets = randomintrange( 1, 2 );
		}
		else if ( str_difficulty == "hard" )
		{
			num_rockets = randomintrange( 2, 3 );
		}
		else
		{
			if ( str_difficulty == "fu" )
			{
				num_rockets = randomintrange( 3, 5 );
			}
		}
	}
	if ( isplayer( e_target ) )
	{
		if ( str_difficulty == "easy" )
		{
			n_offset_x = randomintrange( -300, 300 );
			n_offset_y = randomintrange( -300, 300 );
			n_offset_z = randomintrange( -300, 300 );
		}
		else if ( str_difficulty == "medium" )
		{
			n_offset_x = randomintrange( -200, 200 );
			n_offset_y = randomintrange( -200, 200 );
			n_offset_z = randomintrange( -200, 200 );
		}
		else if ( str_difficulty == "hard" )
		{
			n_offset_x = randomintrange( -100, 100 );
			n_offset_y = randomintrange( -100, 100 );
			n_offset_z = randomintrange( -100, 100 );
		}
		else
		{
			if ( str_difficulty == "fu" )
			{
				n_offset_x = randomintrange( -50, 50 );
				n_offset_y = randomintrange( -50, 50 );
				n_offset_z = randomintrange( -50, 50 );
			}
		}
	}
	else
	{
		n_offset_x = randomintrange( -200, 200 );
		n_offset_y = randomintrange( -200, 200 );
		n_offset_z = randomintrange( -200, 200 );
	}
	while ( isDefined( e_target ) )
	{
		i = 0;
		while ( i < num_rockets )
		{
			if ( isDefined( e_target ) )
			{
				v_missile_left = self gettagorigin( "tag_missile_left" ) + ( anglesToForward( self.angles ) * 200 );
				v_missile_right = self gettagorigin( "tag_missile_right" ) + ( anglesToForward( self.angles ) * 200 );
				i++;
				magicbullet( "hind_rockets", v_missile_left, e_target.origin, self, e_target, ( n_offset_x, n_offset_y, n_offset_z ) );
				if ( i < num_rockets )
				{
					wait 0,3;
					magicbullet( "hind_rockets", v_missile_right, e_target.origin, self, e_target, ( n_offset_x, n_offset_y, n_offset_z ) );
				}
			}
			wait randomfloatrange( 0,5, 1,5 );
			i++;
		}
	}
	self clearlookatent();
}

vehicle_acquire_target()
{
	self endon( "death" );
	a_enemies = getaiarray( "allies" );
	e_target = level.player;
	if ( cointoss() )
	{
		if ( a_enemies.size )
		{
			ai_muj = a_enemies[ randomint( a_enemies.size ) ];
			if ( isDefined( ai_muj ) && distance2dsquared( self.origin, ai_muj.origin ) < 64000000 )
			{
				e_target = ai_muj;
			}
		}
		else
		{
			e_target = level.player;
		}
	}
	else
	{
		e_target = level.player;
	}
	return e_target;
}

mig_gun_strafe()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		v_gunl = self gettagorigin( "tag_weapons_l" ) + ( anglesToForward( self.angles ) * 500 );
		v_gunr = self gettagorigin( "tag_weapons_r" ) + ( anglesToForward( self.angles ) * 500 );
		v_targetl = self gettagorigin( "tag_weapons_l" ) + ( anglesToForward( self.angles ) * 800 );
		v_targetr = self gettagorigin( "tag_weapons_r" ) + ( anglesToForward( self.angles ) * 800 );
		magicbullet( "btr60_heavy_machinegun", v_gunl, v_targetl + vectorScale( ( 0, 0, 1 ), 100 ) );
		magicbullet( "btr60_heavy_machinegun", v_gunr, v_targetr + vectorScale( ( 0, 0, 1 ), 100 ) );
		wait 0,1;
	}
}

hind_rocket_attack()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		a_guys = getaiarray( "allies" );
		i = 0;
		while ( i < a_guys.size )
		{
			if ( distance2d( self.origin, a_guys[ i ].origin ) <= 8000 )
			{
				b_canshoot = sighttracepassed( self gettagorigin( "tag_origin" ), a_guys[ i ] gettagorigin( "tag_origin" ), 1, undefined );
				if ( b_canshoot )
				{
					e_target = a_guys[ i ];
					break;
				}
			}
			else
			{
				i++;
			}
		}
		if ( randomint( 3 ) == 0 )
		{
			e_target = level.player;
		}
		if ( isalive( e_target ) )
		{
			v_target = e_target.origin;
			self setlookatent( e_target );
			wait 4,5;
			magicbullet( "stinger_sp", self gettagorigin( "tag_missile_left" ) + vectorScale( ( 0, 0, 1 ), 80 ), v_target );
			wait 1;
			magicbullet( "stinger_sp", self gettagorigin( "tag_missile_right" ) + vectorScale( ( 0, 0, 1 ), 80 ), v_target );
			wait 2;
			self clearlookatent();
		}
		wait randomintrange( 2, 5 );
	}
}

hind_rocket_target( e_target )
{
	self endon( "death" );
	if ( isDefined( e_target ) )
	{
		self setlookatent( e_target );
		wait 3;
		if ( isDefined( e_target ) )
		{
			v_target = e_target.origin;
			magicbullet( "stinger_sp", self gettagorigin( "tag_missile_left" ) + vectorScale( ( 0, 0, 1 ), 80 ), v_target );
			wait 1;
			magicbullet( "stinger_sp", self gettagorigin( "tag_missile_right" ) + vectorScale( ( 0, 0, 1 ), 80 ), v_target );
			wait 2;
			v_target = undefined;
		}
	}
}

hind_strafe()
{
	self endon( "death" );
	self endon( "stop_strafe" );
	self thread hind_rocket_strafe();
	while ( 1 )
	{
		v_target = self.origin + ( anglesToForward( self.angles ) * 5000 );
		magicbullet( "btr60_heavy_machinegun", self.origin + ( 251, 0, -130 ), v_target );
		wait 0,05;
	}
}

hind_rocket_strafe()
{
	self endon( "death" );
	self endon( "stop_strafe" );
	while ( 1 )
	{
		v_missile_left = self gettagorigin( "tag_missile_left" ) + ( anglesToForward( self.angles ) * 200 );
		v_left_target = self gettagorigin( "tag_missile_left" ) + ( anglesToForward( self.angles ) * 2500 ) + vectorScale( ( 0, 0, 1 ), 1000 );
		v_missile_right = self gettagorigin( "tag_missile_right" ) + ( anglesToForward( self.angles ) * 200 );
		v_right_target = self gettagorigin( "tag_missile_right" ) + ( anglesToForward( self.angles ) * 2500 ) + vectorScale( ( 0, 0, 1 ), 1000 );
		magicbullet( "hind_rockets", v_missile_left, v_left_target );
		magicbullet( "hind_rockets", v_missile_right, v_right_target );
		wait 0,5;
	}
}

hind_attack_indefinitely()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		e_target = self vehicle_acquire_target();
		if ( isDefined( e_target ) )
		{
			self hind_fireat_target( e_target );
		}
		self clearlookatent();
	}
}

hind_stop_attack_aftertime( n_time )
{
	self endon( "death" );
	wait n_time;
	self notify( "stop_attack" );
}

hind_attack_think( n_range )
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( distance2d( self.origin, level.player.origin ) < n_range )
	{
		while ( distance2d( self.origin, level.player.origin ) < n_range )
		{
			self hind_attack_indefinitely();
			wait 3;
		}
	}
}

hind_attack_base( n_delay )
{
	self endon( "death" );
	self endon( "stop_attack" );
	s_target = getstruct( "base_pos", "targetname" );
	if ( isDefined( n_delay ) )
	{
		wait n_delay;
	}
	while ( 1 )
	{
		magicbullet( "stinger_sp", self gettagorigin( "tag_missile_left" ) + vectorScale( ( 0, 0, 1 ), 80 ), s_target.origin + ( 0, 0, randomintrange( -50, 50 ) ) );
		magicbullet( "stinger_sp", self gettagorigin( "tag_missile_right" ) + vectorScale( ( 0, 0, 1 ), 80 ), s_target.origin + ( 0, 0, randomintrange( -50, 50 ) ) );
		wait 1;
	}
}

hind_baseattack()
{
	self endon( "death" );
	self endon( "stop_base_attack" );
	e_base_target = spawn_model( "tag_origin", ( 15104, -10100, 36 ), ( 0, 0, 1 ) );
	self setlookatent( e_base_target );
	wait 3;
	while ( 1 )
	{
		magicbullet( "stinger_sp", self gettagorigin( "tag_missile_left" ) + vectorScale( ( 0, 0, 1 ), 80 ), e_base_target.origin );
		magicbullet( "stinger_sp", self gettagorigin( "tag_missile_right" ) + vectorScale( ( 0, 0, 1 ), 80 ), e_base_target.origin );
		level notify( "base_attacked" );
		wait randomintrange( 3, 6 );
	}
}

heli_evade()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "missile_fire", missile );
		heli = self.stingertarget;
		if ( isDefined( heli ) )
		{
			if ( !isDefined( heli.b_rappel_done ) && !isDefined( heli.statue_target ) )
			{
				heli thread heli_deploy_flares( missile );
				break;
			}
			else
			{
				if ( isDefined( heli.b_rappel_done ) && heli.b_rappel_done )
				{
					heli thread heli_deploy_flares( missile );
					break;
				}
				else
				{
					if ( isDefined( heli.statue_target ) && !heli.statue_target )
					{
						heli thread heli_deploy_flares( missile );
					}
				}
			}
		}
	}
}

heli_deploy_flares( missile )
{
	self endon( "death" );
	if ( !isDefined( missile ) )
	{
		return;
	}
	vec_toforward = anglesToForward( self.angles );
	vec_toright = anglesToRight( self.angles );
	self.chaff_fx = spawn( "script_model", self.origin );
	self.chaff_fx.angles = vectorScale( ( 0, 0, 1 ), 180 );
	self.chaff_fx setmodel( "tag_origin" );
	self.chaff_fx linkto( self, "tag_origin", vectorScale( ( 0, 0, 1 ), 120 ), ( 0, 0, 1 ) );
	delta = self.origin - missile.origin;
	dot = vectordot( delta, vec_toright );
	sign = 1;
	if ( dot > 0 )
	{
		sign = -1;
	}
	chaff_dir = vectornormalize( vectorScale( vec_toforward, -0,2 ) + vectorScale( vec_toright, sign ) );
	velocity = vectorScale( chaff_dir, randomintrange( 400, 600 ) );
	velocity = ( velocity[ 0 ], velocity[ 1 ], velocity[ 2 ] - randomintrange( 10, 100 ) );
	self.chaff_target = spawn( "script_model", self.chaff_fx.origin );
	self.chaff_target setmodel( "tag_origin" );
	self.chaff_target movegravity( velocity, 5 );
	self.chaff_fx thread delete_after_time( 5 );
	wait 0,1;
	n_odds = 10;
	if ( self.vehicletype == "heli_hind_afghan" )
	{
		n_odds = 10;
	}
	else
	{
		if ( self.vehicletype == "heli_hip" )
		{
			n_odds = 20;
		}
	}
	n_chance = randomint( n_odds );
	if ( n_chance < 2 )
	{
		self.chaff_fx thread play_flares_fx();
		missile missile_settarget( self.chaff_target );
		wait 0,5;
		if ( isDefined( self.chaff_target ) )
		{
			self.chaff_target delete();
		}
		if ( isDefined( missile ) )
		{
			missile missile_settarget( undefined );
		}
		wait 1;
		if ( isDefined( missile ) )
		{
			missile resetmissiledetonationtime( 0 );
		}
	}
}

play_flares_fx()
{
	self endon( "death" );
	i = 0;
	while ( i < 3 )
	{
		playfxontag( level._effect[ "aircraft_flares" ], self, "tag_origin" );
		self playsound( "veh_huey_chaff_explo_npc" );
		wait 0,25;
		i++;
	}
}

vehicle_whizby_or_close_impact()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "missile_fire", missile );
		a_vehicles = getentarray( "script_vehicle", "classname" );
		missile waittill( "explode", impact_pos );
		a_vehicles = getentarray( "script_vehicle", "classname" );
		_a1055 = a_vehicles;
		_k1055 = getFirstArrayKey( _a1055 );
		while ( isDefined( _k1055 ) )
		{
			e_veh = _a1055[ _k1055 ];
			if ( distance2dsquared( impact_pos, e_veh.origin ) < 129600 )
			{
				e_veh notify( "close_impact" );
			}
			_k1055 = getNextArrayKey( _a1055, _k1055 );
		}
	}
}

hind_evade()
{
	self endon( "death" );
	while ( 1 )
	{
		level.player waittill( "missile_fire", missile );
		if ( level.player.stingertarget == self )
		{
			self thread hind_deploy_flares( missile );
			return;
		}
		else
		{
		}
	}
}

cleanup_bp_ai()
{
	a_ai_guys = getaiarray( "allies", "axis" );
	a_ai_heroes = [];
	a_ai_heroes[ 0 ] = level.zhao;
	a_ai_heroes[ 1 ] = level.woods;
	a_ai_bpguys = array_exclude( a_ai_guys, a_ai_heroes );
	_a1092 = a_ai_bpguys;
	_k1092 = getFirstArrayKey( _a1092 );
	while ( isDefined( _k1092 ) )
	{
		ai_guy = _a1092[ _k1092 ];
		if ( isDefined( ai_guy.bp_ai ) )
		{
			ai_guy delete();
		}
		_k1092 = getNextArrayKey( _a1092, _k1092 );
	}
}

ai_horse_ride( vh_horse )
{
	self enter_vehicle( vh_horse );
	wait 0,1;
	vh_horse notify( "groupedanimevent" );
	self maps/_horse_rider::ride_and_shoot( vh_horse );
}

ambient_rappel( sp_rappel, s_drop_pt )
{
	if ( flag( "bp_underway" ) )
	{
		return;
	}
	self endon( "death" );
	self sethoverparams( 0, 0, 10 );
	drop_struct = getstruct( s_drop_pt, "targetname" );
	drop_origin = drop_struct.origin;
	drop_offset_tag = "tag_fastrope_ri";
	drop_offset = self gettagorigin( "tag_origin" ) - self gettagorigin( drop_offset_tag );
	drop_offset = ( drop_offset[ 0 ], drop_offset[ 1 ], self.fastropeoffset );
	drop_origin += drop_offset;
	self setvehgoalpos( drop_origin, 1 );
	self waittill( "goal" );
	n_pos = 2;
	i = 0;
	while ( i < 3 )
	{
		ai_rappeller = sp_rappel spawn_ai( 1 );
		ai_rappeller.script_startingposition = n_pos;
		ai_rappeller enter_vehicle( self );
		n_pos++;
		wait 0,1;
		i++;
	}
	self notify( "unload" );
	self waittill( "unloaded" );
}

hind_deploy_flares( missile )
{
	self endon( "death" );
	self notify( "evade" );
	if ( !isDefined( missile ) )
	{
		return;
	}
	vec_toforward = anglesToForward( self.angles );
	vec_toright = anglesToRight( self.angles );
	self.chaff_fx = spawn( "script_model", self.origin );
	self.chaff_fx.angles = vectorScale( ( 0, 0, 1 ), 180 );
	self.chaff_fx setmodel( "tag_origin" );
	self.chaff_fx linkto( self, "tag_origin", vectorScale( ( 0, 0, 1 ), 120 ), ( 0, 0, 1 ) );
	delta = self.origin - missile.origin;
	dot = vectordot( delta, vec_toright );
	sign = 1;
	if ( dot > 0 )
	{
		sign = -1;
	}
	chaff_dir = vectornormalize( vectorScale( vec_toforward, -0,2 ) + vectorScale( vec_toright, sign ) );
	velocity = vectorScale( chaff_dir, randomintrange( 400, 600 ) );
	velocity = ( velocity[ 0 ], velocity[ 1 ], velocity[ 2 ] - randomintrange( 10, 100 ) );
	self.chaff_target = getent( "fx_statue_target", "targetname" );
	self.chaff_fx thread delete_after_time( 5 );
	wait 0,1;
	self.chaff_fx thread play_flares_fx();
	missile missile_settarget( self.chaff_target );
	wait 5;
	if ( isDefined( self.chaff_target ) )
	{
		self.chaff_target delete();
	}
	self.statue_target = 0;
}

fxanim_statue()
{
	m_clip = getent( "bp3_statue_clip", "targetname" );
	m_clip setcandamage( 1 );
	while ( 1 )
	{
		m_clip waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type == "MOD_PROJECTILE" )
		{
			level notify( "fxanim_statue_crumble_start" );
			return;
		}
		else
		{
		}
	}
}

fxanim_statue_entrance()
{
	m_clip = getent( "bp3_statue_clip_entrance", "targetname" );
	m_clip setcandamage( 1 );
	while ( 1 )
	{
		m_clip waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type == "MOD_PROJECTILE" )
		{
			level notify( "fxanim_statue_lrg_crumble_start" );
			return;
		}
		else
		{
		}
	}
}

fxanim_statue_end()
{
	m_clip = getent( "bp3_statue_clip_end", "targetname" );
	m_clip setcandamage( 1 );
	while ( 1 )
	{
		m_clip waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type == "MOD_PROJECTILE" )
		{
			level notify( "fxanim_statue_02_crumble_start" );
			return;
		}
		else
		{
		}
	}
}

heli_select_death()
{
	self endon( "death" );
	n_index = randomint( 5 );
	self thread heli_handle_challenge_death();
	if ( !n_index )
	{
		self.overridevehicledamage = ::heli_vehicle_damage;
	}
	else
	{
		self.overridevehicledamage = ::sticky_grenade_damage;
	}
	n_index = undefined;
}

heli_handle_challenge_death()
{
	self waittill( "check_helicopter_death", attacker, weapon );
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( weapon == "mortar_shell_dpad_sp" )
		{
			level notify( "helo_destroyed_by_mortar" );
		}
		if ( weapon == "civ_pickup_turret_afghan" )
		{
			level notify( "killed_heli_with_truck_mg" );
		}
		if ( weapon == "afghanstinger_sp" )
		{
			level notify( "helo_shot_down_by_rpg" );
		}
		if ( isDefined( self.is_bp2_heli ) )
		{
			level notify( "blocking_point_2_heli_shot_down" );
		}
	}
}

hind_vehicle_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( issubstr( sweapon, "hind" ) )
	{
		idamage = 0;
	}
	else if ( issubstr( sweapon, "rpg" ) || issubstr( sweapon, "stinger" ) )
	{
		self notify( "check_helicopter_death" );
		idamage = 1;
		m_explode = spawn( "script_model", self.origin );
		m_explode setmodel( "tag_origin" );
		m_explode linkto( self, "tag_origin" );
		playfxontag( level._effect[ "explosion_midair_heli" ], m_explode, "tag_origin" );
		wait 0,1;
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
		wait 5;
		m_explode delete();
	}
	else
	{
		if ( issubstr( sweapon, "sticky" ) )
		{
			idamage = 1;
			self notify( "check_helicopter_death" );
			einflictor waittill( "death" );
			radiusdamage( self.origin, 32, self.health, self.health );
		}
	}
	if ( ( self.health - idamage ) < 1 && sweapon != "none" )
	{
		self notify( "check_helicopter_death" );
	}
	return idamage;
}

heli_vehicle_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( sweapon != "rpg_player_sp" && sweapon != "afghanstinger_ff_sp" || sweapon == "afghanstinger_sp" && type == "MOD_EXPLOSIVE" )
	{
		self notify( "check_helicopter_death" );
		idamage = 1;
		m_explode = spawn( "script_model", self.origin );
		m_explode setmodel( "tag_origin" );
		m_explode linkto( self, "tag_origin" );
		playfxontag( level._effect[ "explosion_midair_heli" ], m_explode, "tag_origin" );
		wait 0,1;
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
		wait 5;
		m_explode delete();
	}
	if ( issubstr( sweapon, "sticky" ) )
	{
		self notify( "check_helicopter_death" );
		idamage = 1;
		einflictor waittill( "death" );
		if ( isDefined( self.dropoff_heli ) )
		{
			m_explode = spawn( "script_model", self.origin );
			m_explode setmodel( "tag_origin" );
			m_explode linkto( self, "tag_origin" );
			playfxontag( level._effect[ "explosion_midair_heli" ], m_explode, "tag_origin" );
			wait 0,1;
			self.delete_on_death = 1;
			self notify( "death" );
			if ( !isalive( self ) )
			{
				self delete();
			}
			wait 5;
			m_explode delete();
		}
		else
		{
			radiusdamage( self.origin, 100, 500, 500 );
		}
	}
	if ( ( self.health - idamage ) < 1 && sweapon != "none" )
	{
		self notify( "check_helicopter_death" );
	}
	return idamage;
}

sticky_grenade_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( issubstr( sweapon, "sticky" ) )
	{
		self notify( "check_helicopter_death" );
		idamage = 1;
		n_grenade_damage = 100;
		if ( self.vehicletype != "apc_btr60" && self.vehicletype != "heli_hind_afghan" && self.vehicletype != "heli_hip" || self.vehicletype == "jeep_uaz" && self.vehicletype == "heli_hip_afghanistan_land" )
		{
			einflictor waittill( "death" );
			if ( self.vehicletype != "heli_hind_afghan" || self.vehicletype == "heli_hip" && self.vehicletype == "heli_hip_afghanistan_land" )
			{
				radiusdamage( self.origin, 32, 500, 500, eattacker );
			}
			else
			{
				radiusdamage( self.origin, 32, n_grenade_damage, n_grenade_damage, eattacker );
				play_fx( "tank_dmg", self.origin, self.angles, undefined, 1, "tag_origin" );
			}
		}
	}
	else if ( !issubstr( sweapon, "tc6_mine" ) || sweapon == "satchel_charge_sp" && sweapon == "satchel_charge_80s_sp" )
	{
		self notify( "check_helicopter_death" );
		idamage = 1;
		n_grenade_damage = 400;
		if ( self.vehicletype != "apc_btr60" && self.vehicletype != "heli_hind_afghan" && self.vehicletype != "heli_hip" || self.vehicletype == "jeep_uaz" && self.vehicletype == "heli_hip_afghanistan_land" )
		{
			einflictor waittill( "death" );
			radiusdamage( self.origin, 32, n_grenade_damage, n_grenade_damage, eattacker );
			play_fx( "tank_dmg", self.origin, self.angles, undefined, 1, "tag_origin" );
		}
	}
	else
	{
		if ( issubstr( sweapon, "afghanstinger" ) )
		{
			self notify( "check_helicopter_death" );
			idamage = 1;
			einflictor waittill( "death" );
			radiusdamage( self.origin, 32, self.health, self.health, eattacker );
		}
		else
		{
			if ( issubstr( sweapon, "rpg" ) || issubstr( sweapon, "mortar" ) )
			{
				self notify( "check_helicopter_death" );
				idamage = 1;
				n_grenade_damage = 1000;
				einflictor waittill( "death" );
				radiusdamage( self.origin, 32, self.health, self.health, eattacker );
			}
		}
	}
	if ( ( self.health - idamage ) < 1 && sweapon != "none" )
	{
		self notify( "check_helicopter_death" );
	}
	return idamage;
}

tank_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( issubstr( sweapon, "sticky" ) )
	{
		idamage = 1;
		n_grenade_damage = 400;
		einflictor waittill( "death" );
		radiusdamage( self.origin, 32, n_grenade_damage, n_grenade_damage, eattacker );
		play_fx( "tank_dmg", self.origin, self.angles, undefined, 1, "tag_origin" );
	}
	else if ( !issubstr( sweapon, "tc6_mine" ) || sweapon == "satchel_charge_sp" && sweapon == "satchel_charge_80s_sp" )
	{
		idamage = 1;
		n_grenade_damage = 2000;
		einflictor waittill( "death" );
		if ( ( self.health - n_grenade_damage ) < 1 )
		{
			level notify( "tank_destroyed_by_mine" );
		}
		radiusdamage( self.origin, 32, n_grenade_damage, n_grenade_damage, eattacker );
		play_fx( "tank_dmg", self.origin, self.angles, undefined, 1, "tag_origin" );
	}
	else
	{
		if ( !issubstr( sweapon, "afghanstinger" ) || issubstr( sweapon, "rpg" ) && issubstr( sweapon, "mortar" ) )
		{
			idamage = 1;
			n_grenade_damage = 1000;
			if ( partname == "tag_tank_rear" )
			{
				n_grenade_damage *= 2;
			}
			einflictor waittill( "death" );
			radiusdamage( self.origin, 32, n_grenade_damage, n_grenade_damage, eattacker );
			play_fx( "tank_dmg", self.origin, self.angles, undefined, 1, "tag_origin" );
		}
	}
	if ( isplayer( eattacker ) )
	{
		if ( !issubstr( sweapon, "afghanstinger" ) || issubstr( sweapon, "rpg" ) && issubstr( sweapon, "mortar" ) )
		{
			self thread tank_damage_reaction();
		}
	}
	return idamage;
}

tank_damage_reaction()
{
	self endon( "death" );
	self play_fx( "t62_tank_damage", self.origin, self.angles, "death", 1, "tag_origin" );
	self setspeed( 0, 15 );
	wait 2;
	self resumespeed( 15 );
}

horse_damage( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( type == "MOD_PROJECTILE" )
	{
		idamage = 1;
		radiusdamage( self.origin, 32, 5000, 5000 );
	}
	return idamage;
}

delete_after_time( n_time )
{
	self endon( "death" );
	wait n_time;
	self delete();
}

tank_targetting()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		a_guys = getaiarray( "allies" );
		i = 0;
		while ( i < a_guys.size )
		{
			if ( distance2d( self.origin, a_guys[ i ].origin ) <= 5000 )
			{
				b_canshoot = sighttracepassed( self gettagorigin( "tag_flash" ), a_guys[ i ].origin, 1, undefined );
				if ( b_canshoot )
				{
					e_target = a_guys[ i ];
					break;
				}
			}
			else
			{
				i++;
			}
		}
		if ( randomint( 3 ) == 0 )
		{
			e_target = level.player;
		}
		if ( isDefined( level.muj_tank ) && distance2d( self.origin, level.muj_tank.origin ) <= 5000 )
		{
			if ( 1 || 1 )
			{
				e_target = level.muj_tank;
			}
		}
		if ( isDefined( e_target ) )
		{
			self settargetentity( e_target );
			self waittill( "turret_on_target" );
			wait 1;
			if ( isDefined( e_target ) )
			{
				self shoot_turret_at_target_once( e_target, ( randomintrange( -99, 99 ), randomintrange( -99, 99 ), randomintrange( -32, 80 ) ), 0 );
				wait randomfloatrange( 2,5, 4 );
				self cleartargetentity();
			}
		}
		wait randomintrange( 2, 5 );
	}
}

projectile_fired_at_tank( e_cache )
{
	self endon( "death" );
	self endon( "stop_projectile_check" );
	while ( 1 )
	{
		level.player waittill( "missile_fire", missile );
		self notify( "stop_attack" );
		wait 2;
		self settargetentity( level.player );
		self waittill( "turret_on_target" );
		wait 1;
		self shoot_turret_at_target_once( level.player, ( randomintrange( -99, 99 ), randomintrange( -99, 99 ), randomintrange( -32, 80 ) ), 0 );
		wait 2;
		self cleartargetentity();
		if ( isDefined( e_cache ) )
		{
			self thread attack_cache_tank( e_cache );
			continue;
		}
		else
		{
			self thread tank_targetting();
		}
	}
}

attack_cache_tank( e_cache )
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		e_target = e_cache;
		if ( randomint( 3 ) == 0 )
		{
			e_target = level.player;
		}
		if ( distance2d( self.origin, e_target.origin ) <= 5000 )
		{
			self settargetentity( e_target );
			self waittill( "turret_on_target" );
			wait 1;
			self fireweapon();
			wait 2;
			self cleartargetentity();
		}
		wait randomfloatrange( 2, 3 );
	}
}

tank_attack_player_then_go_back_to_base()
{
	self endon( "death" );
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
	self notify( "end_base_attack_thread" );
	self settargetentity( level.player );
	self waittill_any_timeout( 10, "turret_on_target" );
	self fireweapon();
	wait 0,5;
	self thread tank_baseattack();
}

tank_baseattack()
{
	self endon( "death" );
	self endon( "end_base_attack_thread" );
	self notify( "end_watch_for_attacks" );
	self thread tank_attack_player_then_go_back_to_base();
	if ( isDefined( self.e_base_target ) )
	{
		e_base_target = self.e_base_target;
	}
	else
	{
		e_base_target = spawn_model( "tag_origin", level.ground_attack_tank_points[ self.ground_attack_index ][ "vec_target" ], ( 0, 0, 1 ) );
		self.e_base_target = e_base_target;
	}
	self settargetentity( e_base_target );
	self waittill( "turret_on_target" );
	wait 3;
	while ( 1 )
	{
		self fireweapon();
		level notify( "base_attacked" );
		wait randomintrange( 3, 6 );
	}
}

btr_attack()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		a_guys = getaiarray( "allies" );
		i = 0;
		while ( i < a_guys.size )
		{
			e_target = a_guys[ randomint( a_guys.size ) ];
			if ( distance2dsquared( self.origin, e_target.origin ) < 25000000 )
			{
				break;
			}
			else
			{
				i++;
			}
		}
		if ( randomint( 4 ) == 0 || distance2dsquared( self.origin, level.player.origin ) < 490000 )
		{
			e_target = level.player;
		}
		n_offset_x = randomintrange( -40, 40 );
		n_offset_y = randomintrange( -40, 40 );
		n_offset_z = randomintrange( 0, 40 );
		str_difficulty = getdifficulty();
		if ( isplayer( e_target ) )
		{
			if ( str_difficulty == "easy" )
			{
				n_offset_x = randomintrange( -64, 64 );
				n_offset_y = randomintrange( -64, 64 );
				n_offset_z = randomintrange( 0, 64 );
				break;
			}
			else if ( str_difficulty == "medium" )
			{
				n_offset_x = randomintrange( -40, 40 );
				n_offset_y = randomintrange( -40, 40 );
				n_offset_z = randomintrange( 0, 40 );
				break;
			}
			else if ( str_difficulty == "hard" )
			{
				n_offset_x = randomintrange( -20, 20 );
				n_offset_y = randomintrange( -20, 20 );
				n_offset_z = randomintrange( 0, 20 );
				break;
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
		}
		if ( isDefined( e_target ) )
		{
			self thread shoot_turret_at_target( e_target, -1, ( n_offset_x, n_offset_y, n_offset_z ), 1 );
			wait randomfloatrange( 3, 5 );
			self stop_turret( 1 );
			wait randomfloatrange( 2, 4 );
			continue;
		}
		else
		{
			wait 0,15;
		}
	}
}

btr_set_target( e_target, n_time )
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		self set_turret_target( e_target, ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), randomintrange( -100, 100 ) ), 1 );
		wait 5;
	}
}

projectile_fired_at_btr( e_cache )
{
	self endon( "death" );
	self endon( "stop_projectile_check" );
	while ( 1 )
	{
		level.player waittill( "missile_fire", missile );
		self notify( "stop_attack" );
		wait 2;
		self set_turret_target( level.player, ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), randomintrange( -100, 100 ) ), 1 );
		self fire_turret_for_time( randomintrange( 3, 6 ), 1 );
		if ( isDefined( e_cache ) )
		{
			self thread attack_cache_btr( e_cache );
			continue;
		}
		else
		{
			self thread btr_attack();
		}
	}
}

attack_cache_btr( e_cache )
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		if ( isDefined( e_cache ) )
		{
			self set_turret_target( e_cache, ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), randomintrange( -100, 100 ) ), 1 );
			self fire_turret_for_time( randomintrange( 3, 6 ), 1 );
		}
		wait randomfloatrange( 5, 7 );
	}
}

hip_attack_cache( e_cache )
{
	self endon( "death" );
	self endon( "stop_attack" );
	self set_turret_target( e_cache, ( randomint( 64 ), randomint( 64 ), randomint( 64 ) ), 2 );
	while ( 1 )
	{
		if ( isDefined( e_cache ) )
		{
			self thread fire_turret_for_time( randomintrange( 3, 6 ), 2 );
		}
		wait randomfloatrange( 5, 7 );
	}
}

hip_circle( s_start )
{
	self endon( "death" );
	self endon( "stop_circle" );
	self setspeed( 50, 25, 20 );
	s_goal = s_start;
	while ( 1 )
	{
		self setvehgoalpos( s_goal.origin );
		self waittill_any( "goal", "near_goal" );
		s_goal = getstruct( s_goal.target, "targetname" );
	}
}

hip_attack()
{
	self endon( "death" );
	self endon( "stop_attack" );
	while ( 1 )
	{
		a_guys = getaiarray( "allies" );
		i = 0;
		while ( i < a_guys.size )
		{
			if ( distance2dsquared( self.origin, a_guys[ i ].origin ) < 25000000 )
			{
				e_target = a_guys[ i ];
				break;
			}
			else
			{
				i++;
			}
		}
		if ( randomint( 5 ) == 0 )
		{
			e_target = level.player;
		}
		if ( isDefined( e_target ) )
		{
			self set_turret_target( e_target, ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), randomintrange( -100, 100 ) ), 2 );
		}
		if ( isalive( e_target ) )
		{
			if ( isDefined( e_target.crew ) )
			{
				self fire_turret_for_time( randomintrange( 3, 6 ), 2 );
				break;
			}
			else
			{
				self fire_turret_for_time( randomintrange( 3, 6 ), 2 );
			}
		}
		wait randomfloatrange( 3, 5 );
	}
}

delete_corpse_bp1()
{
	flag_wait( "wave2_started" );
	if ( isDefined( self ) )
	{
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
	}
}

delete_veh_corpse_player_not_around()
{
	self endon( "delete" );
	self waittill( "death" );
	wait 1;
	while ( isDefined( self ) )
	{
		if ( distance2dsquared( self.origin, level.player.origin ) > 9000000 )
		{
			self.delete_on_death = 1;
			self notify( "death" );
			if ( !isalive( self ) )
			{
				self delete();
			}
		}
		wait 1;
	}
}

delete_corpse_wave2()
{
	flag_wait( "wave3_started" );
	if ( isDefined( self ) )
	{
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
	}
}

delete_corpse_wave3()
{
	flag_wait( "wave4_started" );
	if ( isDefined( self ) )
	{
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
	}
}

delete_corpse_arena()
{
	flag_wait( "blocking_done" );
	if ( isDefined( self ) )
	{
		self.delete_on_death = 1;
		self notify( "death" );
		if ( !isalive( self ) )
		{
			self delete();
		}
	}
}

set_dropoff_flag_ondeath( str_flag )
{
	self waittill( "death" );
	flag_set( str_flag );
}

set_flag_ondeath( str_flag )
{
	self waittill( "death" );
	flag_set( str_flag );
}

runover_by_horse_callback( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( attacker == level.player && smeansofdeath == "MOD_CRUSH" )
	{
		level.player playrumbleonentity( "damage_heavy" );
	}
	return attacker;
}

nag_destroy_vehicle()
{
}

crew_sniper_logic()
{
	self endon( "death" );
	self endon( "crew_sleep" );
	a_tags = [];
	a_tags[ 0 ] = "J_SpineLower";
	a_tags[ 1 ] = "J_Knee_LE";
	a_tags[ 2 ] = "J_SpineUpper";
	a_tags[ 3 ] = "J_Neck";
	a_tags[ 4 ] = "J_Head";
	while ( 1 )
	{
		a_ai_targets = getaiarray( "axis" );
		if ( a_ai_targets.size )
		{
			a_targets = sort_by_distance( a_ai_targets, level.player.origin );
			i = a_targets.size - 1;
			while ( i >= 0 )
			{
				if ( isalive( a_targets[ i ] ) && self cansee( a_targets[ i ] ) )
				{
					ai_target = a_targets[ i ];
					break;
				}
				else
				{
					i--;

				}
			}
			if ( isalive( ai_target ) )
			{
				if ( distance2dsquared( self.origin, ai_target.origin ) <= ( 2800 * 2800 ) )
				{
					self thread aim_at_target( ai_target );
					wait 1;
					self thread stop_aim_at_target();
					if ( isalive( ai_target ) )
					{
						v_target = ai_target gettagorigin( a_tags[ randomint( 5 ) ] );
						b_canshoot = bullettracepassed( self gettagorigin( "tag_flash" ), v_target, 1, ai_target );
						if ( b_canshoot )
						{
							magicbullet( "dragunov_sp", self gettagorigin( "tag_flash" ), v_target );
							e_trail = spawn( "script_model", self gettagorigin( "tag_flash" ) );
							e_trail setmodel( "tag_origin" );
							playfxontag( level._effect[ "sniper_trail" ], e_trail, "tag_origin" );
							e_trail moveto( v_target, 0,1 );
							playfx( level._effect[ "sniper_impact" ], v_target );
							if ( isalive( ai_target ) )
							{
								ai_target die();
							}
							wait 0,1;
							e_trail delete();
						}
					}
				}
			}
		}
		wait randomfloatrange( 2, 3 );
	}
}

crew_stinger_logic()
{
	self endon( "death" );
	self endon( "crew_sleep" );
	while ( 1 )
	{
		e_target = self stinger_crew_get_target();
		if ( isDefined( e_target ) )
		{
			self stinger_crew_shoot( e_target );
		}
		wait randomfloatrange( 4, 6 );
	}
}

stinger_crew_get_target()
{
	self endon( "death" );
	a_vh_targets = getentarray( "script_vehicle", "classname" );
	if ( a_vh_targets.size )
	{
		a_targets = sort_by_distance( a_vh_targets, self.origin );
		i = a_targets.size - 1;
		while ( i > 0 )
		{
			if ( distance2dsquared( self.origin, a_targets[ i ].origin ) <= ( 7500 * 7500 ) )
			{
				if ( a_targets[ i ].vehicletype == "heli_hind_afghan" && isDefined( a_targets[ i ] ) )
				{
					e_target = a_targets[ i ];
					break;
				}
				else if ( a_targets[ i ].vehicletype == "heli_hip" && isDefined( a_targets[ i ] ) )
				{
					e_target = a_targets[ i ];
					break;
				}
			}
			else
			{
				i--;

			}
		}
		return e_target;
	}
}

stinger_crew_shoot( e_target )
{
	if ( isDefined( e_target ) )
	{
		self thread aim_at_target( e_target );
		wait 3;
		self thread stop_aim_at_target();
		if ( isDefined( e_target ) )
		{
			if ( isDefined( e_target ) && sighttracepassed( self gettagorigin( "tag_eye" ), e_target.origin, 0, e_target ) )
			{
				magicbullet( "afghanstinger_ff_sp", self gettagorigin( "tag_flash" ), e_target.origin, self, e_target, ( randomint( 100 ), randomint( 100 ), -32 ) );
			}
		}
	}
}

crew_rpg_logic()
{
	self endon( "death" );
	while ( 1 )
	{
		e_target = self rpg_crew_get_target();
		if ( isDefined( e_target ) )
		{
			self rpg_crew_shoot( e_target );
		}
		else
		{
			self rpg_crew_attack_ai();
		}
		wait randomfloatrange( 4, 6 );
	}
}

rpg_crew_get_target()
{
	self endon( "death" );
	a_vh_targets = getentarray( "script_vehicle", "classname" );
	if ( a_vh_targets.size )
	{
		a_targets = sort_by_distance( a_vh_targets, self.origin );
		i = a_targets.size - 1;
		while ( i > 0 )
		{
			if ( distance2dsquared( self.origin, a_targets[ i ].origin ) <= ( 4000 * 4000 ) )
			{
				if ( a_targets[ i ].vehicletype == "tank_t62" && isalive( a_targets[ i ] ) )
				{
					e_target = a_targets[ i ];
					break;
				}
				else if ( a_targets[ i ].vehicletype == "apc_btr60" && isalive( a_targets[ i ] ) )
				{
					e_target = a_targets[ i ];
					break;
				}
				else if ( a_targets[ i ].vehicletype == "heli_hind_afghan" && isalive( a_targets[ i ] ) )
				{
					if ( cointoss() )
					{
						e_target = a_targets[ i ];
						break;
					}
					else }
				else if ( a_targets[ i ].vehicletype == "heli_hip" && isalive( a_targets[ i ] ) )
				{
					if ( cointoss() )
					{
						e_target = a_targets[ i ];
						break;
					}
				}
			}
			else
			{
				i--;

			}
		}
		return e_target;
	}
}

rpg_crew_attack_ai( n_range )
{
	self endon( "death" );
	a_ai_targets = getaiarray( "axis" );
	while ( a_ai_targets.size )
	{
		while ( 1 )
		{
			a_ai_targets = getaiarray( "axis" );
			if ( a_ai_targets.size )
			{
				ai_target = a_ai_targets[ randomint( a_ai_targets.size ) ];
				if ( isDefined( ai_target ) )
				{
					if ( distance2dsquared( self.origin, ai_target.origin ) <= ( 4000 * 4000 ) )
					{
						e_target = ai_target;
						self rpg_crew_shoot( e_target );
						return;
					}
				}
			}
			else
			{
				wait 2;
			}
		}
	}
}

rpg_crew_shoot( e_target )
{
	if ( isDefined( e_target ) )
	{
		self thread aim_at_target( e_target );
		wait 3;
		if ( isDefined( e_target ) )
		{
			magicbullet( "rpg_magic_bullet_sp", self gettagorigin( "tag_flash" ), e_target.origin + ( randomintrange( -300, 300 ), randomintrange( -300, 300 ), randomintrange( 0, 150 ) ) );
		}
		self thread stop_aim_at_target();
	}
}

crew_counter( str_type )
{
	self waittill( "crew_dead" );
	if ( str_type == "sniper" )
	{
		level.crew_remaining[ 0 ]--;

		level.zhao say_dialog( "wood_we_ve_lost_the_snipe_0" );
		if ( level.crew_remaining[ 0 ] )
		{
			level.zhao say_dialog( "wood_deploy_another_crew_0", 1 );
			level.zhao say_dialog( "omar_we_have_one_more_sni_0", 1 );
		}
		else
		{
			level.zhao say_dialog( "omar_that_s_the_last_of_t_0", 1 );
		}
	}
	else if ( str_type == "rpg" )
	{
		level.crew_remaining[ 1 ]--;

		level.zhao say_dialog( "wood_we_ve_lost_the_rpg_c_0" );
		if ( level.crew_remaining[ 0 ] )
		{
			level.zhao say_dialog( "omar_we_have_one_more_rpg_0", 1 );
			level.zhao say_dialog( "wood_deploy_another_crew_0", 1 );
		}
		else
		{
			level.zhao say_dialog( "omar_that_s_the_last_of_t_1", 1 );
		}
	}
	else level.crew_remaining[ 2 ]--;

	level.zhao say_dialog( "wood_we_ve_lost_the_sting_0" );
	if ( level.crew_remaining[ 0 ] )
	{
		level.zhao say_dialog( "omar_we_have_one_more_sti_0", 1 );
		level.zhao say_dialog( "wood_deploy_another_crew_0", 1 );
	}
	else
	{
		level.zhao say_dialog( "omar_that_s_the_last_of_t_2", 1 );
	}
}

muj_tank_behavior()
{
	self endon( "death" );
	self thread track_muj_tank_death();
	self setvehicleavoidance( 1 );
	while ( 1 )
	{
		tank_target = get_vehicle_target();
		if ( isDefined( tank_target ) )
		{
			self settargetentity( tank_target );
			self waittill( "turret_on_target" );
			wait 1;
			if ( isDefined( tank_target ) )
			{
				self shoot_turret_at_target_once( tank_target, ( randomintrange( -99, 99 ), randomintrange( -99, 99 ), randomintrange( -32, 80 ) ), 0 );
			}
		}
		else
		{
			ai_target = get_ai_target();
			if ( isDefined( ai_target ) )
			{
				self settargetentity( ai_target );
				self waittill( "turret_on_target" );
				wait 1;
				if ( isalive( ai_target ) )
				{
					self shoot_turret_at_target_once( ai_target, ( randomintrange( -99, 99 ), randomintrange( -99, 99 ), randomintrange( -32, 80 ) ), 0 );
				}
			}
		}
		wait randomfloatrange( 5, 8 );
	}
}

track_muj_tank_death()
{
	self waittill( "death" );
	level.player.tank_button_off = 1;
	level.tank_piece.origin = level.hold_map_items.origin;
}

get_vehicle_target()
{
	self endon( "death" );
	a_targets = getentarray( "script_vehicle", "classname" );
	vh_target = array_exclude( a_targets, self );
	while ( vh_target.size )
	{
		i = 0;
		while ( i < vh_target.size )
		{
			if ( distance2d( self.origin, vh_target[ i ].origin ) < 5000 )
			{
				b_sightpassed = sighttracepassed( self gettagorigin( "tag_flash" ), vh_target[ i ].origin, 1, vh_target[ i ] );
				b_bulletpassed = bullettracepassed( self gettagorigin( "tag_flash" ), vh_target[ i ].origin, 1, vh_target[ i ] );
				if ( vh_target[ i ].vehicletype == "tank_t62" )
				{
					if ( b_sightpassed || b_bulletpassed )
					{
						return vh_target[ i ];
					}
					else
					{
					}
					else if ( vh_target[ i ].vehicletype == "apc_btr60" )
					{
						if ( b_sightpassed || b_bulletpassed )
						{
							return vh_target[ i ];
						}
						else
						{
						}
						else if ( vh_target[ i ].vehicletype == "jeep_uaz" )
						{
							if ( b_sightpassed || b_bulletpassed )
							{
								return vh_target[ i ];
							}
						}
					}
					else
					{
						i++;
					}
				}
			}
		}
	}
}

get_ai_target()
{
	self endon( "death" );
	a_ai_enemies = getaiarray( "axis" );
	while ( a_ai_enemies.size )
	{
		i = 0;
		while ( i < a_ai_enemies.size )
		{
			if ( distance2d( self.origin, a_ai_enemies[ i ].origin ) < 5000 )
			{
				b_sightpassed = sighttracepassed( self.origin, a_ai_enemies[ i ].origin, 1, a_ai_enemies[ i ] );
				b_bulletpassed = bullettracepassed( self.origin, a_ai_enemies[ i ].origin, 1, a_ai_enemies[ i ] );
				if ( b_sightpassed || b_bulletpassed )
				{
					if ( isalive( a_ai_enemies[ i ] ) )
					{
						return a_ai_enemies[ i ];
					}
				}
			}
			else
			{
				i++;
			}
		}
	}
}

monitor_base_health()
{
	level endon( "blocking_done" );
	t_dmg = getent( "trigger_base_health", "targetname" );
	t_dmg waittill( "damage" );
	t_dmg waittill( "trigger" );
	wait 0,5;
	t_dmg waittill( "trigger" );
	t_dmg waittill( "trigger" );
	wait 2;
	missionfailedwrapper( &"AFGHANISTAN_PROTECT_FAILED" );
}

too_far_fail_managment( str_end_flag )
{
	if ( isDefined( str_end_flag ) )
	{
		level endon( str_end_flag );
	}
	trigger_array = getentarray( "player_too_far_trigger", "targetname" );
	i = 0;
	while ( i < trigger_array.size )
	{
		trigger_array[ i ] thread touching_fail_trigger( str_end_flag );
		i++;
	}
}

touching_fail_trigger( str_end_flag )
{
	if ( isDefined( str_end_flag ) )
	{
		level endon( str_end_flag );
	}
	self endon( "death" );
	n_duration = 3;
	while ( n_duration > 0 )
	{
		if ( level.player istouching( self ) )
		{
			n_duration -= 1;
		}
		else
		{
			n_duration = 3;
		}
		if ( ( n_duration + 1 ) == 3 )
		{
			if ( cointoss() )
			{
				level.woods say_dialog( "wood_stay_with_me_mason_0" );
				break;
			}
			else
			{
				level.woods say_dialog( "wood_where_the_hell_you_g_0" );
			}
		}
		wait 1;
	}
	missionfailedwrapper( &"AFGHANISTAN_DISTANCE_FAILED" );
}

insta_fail_trigger( str_end_flag )
{
	if ( isDefined( str_end_flag ) )
	{
		level endon( str_end_flag );
	}
	self endon( "death" );
	self waittill( "trigger" );
	missionfailedwrapper( &"AFGHANISTAN_DISTANCE_FAILED" );
}

vehicle_route( s_start )
{
	self endon( "vehicle_stop" );
	self endon( "death" );
	self setvehgoalpos( s_start.origin, 0 );
	if ( isDefined( s_start.target ) )
	{
		s_next_pos = getstruct( s_start.target, "targetname" );
	}
	while ( isDefined( s_next_pos ) )
	{
		v_next_pos = s_next_pos.origin;
		while ( 1 )
		{
			self setvehgoalpos( v_next_pos, 0 );
			self waittill_any( "goal", "near_goal" );
			if ( isDefined( s_next_pos.target ) )
			{
				s_next_pos = getstruct( s_next_pos.target, "targetname" );
				v_next_pos = s_next_pos.origin;
				continue;
			}
			else
			{
				self.delete_on_death = 1;
				self notify( "death" );
				if ( !isalive( self ) )
				{
					self delete();
				}
			}
		}
	}
}

fire_magic_bullet_rpg( str_struct_name, v_fire_at_origin, v_fire_at_offset )
{
	if ( !isDefined( v_fire_at_offset ) )
	{
		v_fire_at_offset = ( 0, 0, 1 );
	}
	s_fire_from = getstruct( str_struct_name, "targetname" );
	e_rpg = magicbullet( "rpg_magic_bullet_sp", s_fire_from.origin, v_fire_at_origin + v_fire_at_offset );
	e_rpg = undefined;
}

fire_magic_bullet_huey_rocket( str_struct_name, v_fire_at_origin, v_fire_at_offset )
{
	if ( !isDefined( v_fire_at_offset ) )
	{
		v_fire_at_offset = ( 0, 0, 1 );
	}
	s_fire_from = getstruct( str_struct_name, "targetname" );
	e_rocket = magicbullet( "stinger_sp", s_fire_from.origin, v_fire_at_origin + v_fire_at_offset );
	e_rocket = undefined;
}

play_mortar_fx( str_struct_name, sound_name )
{
	s_morter = getstruct( str_struct_name, "targetname" );
	playfx( level._effect[ "explode_mortar_sand" ], s_morter.origin );
	if ( isDefined( sound_name ) )
	{
		playsoundatposition( sound_name, s_morter.origin );
	}
	return s_morter;
}

vehicle_go_path_on_node( str_vehicle_node, str_vehicle_spawner )
{
	if ( isDefined( str_vehicle_spawner ) && !flag( "horse_charge_finished" ) )
	{
		vh_spawned = spawn_vehicle_from_targetname( str_vehicle_spawner );
		vh_spawned thread go_path( getvehiclenode( str_vehicle_node, "targetname" ) );
		return vh_spawned;
	}
	self thread go_path( getvehiclenode( str_vehicle_node, "targetname" ) );
}

make_horse_unuseable()
{
	self makevehicleunusable();
}

mig_shoot_down_challenge_spawn_func()
{
	self waittill( "death" );
	level notify( "mig_shot_down" );
}

old_man_woods( str_movie_name, b_trans )
{
	if ( !isDefined( b_trans ) )
	{
		b_trans = 1;
	}
	flag_set( "old_man_woods_talking" );
	level.player enableinvulnerability();
	level.player freezecontrols( 1 );
	play_movie( str_movie_name, 0, 0, undefined, b_trans, "movie_done" );
	level.player disableinvulnerability();
	level.player freezecontrols( 0 );
	flag_clear( "old_man_woods_talking" );
}

trigger_wait_for_player_touch( str_name, str_key )
{
/#
	assert( isDefined( level.player ), "level.player not defined" );
#/
	if ( isDefined( str_name ) )
	{
		if ( !isDefined( str_key ) )
		{
			str_key = "targetname";
		}
		trigger = getent( str_name, str_key );
/#
		assert( isDefined( trigger ), "trigger not found: " + str_name + " key: " + str_key );
#/
		while ( !level.player istouching( trigger ) )
		{
			wait 0,05;
		}
		level notify( str_name );
	}
}

shake_base_lights()
{
	force_x = randomfloatrange( 0,001, 0,005 );
	force_y = randomfloatrange( 0,001, 0,005 );
	force_z = randomfloatrange( 0,001, 0,005 );
	physicsjolt( ( 15850,7, -9946,1, -84,8 ), 8, 8, ( force_x, force_y, force_z ) );
	play_shake_lights_audio( 15850,7, -9946,1, -84,8 );
	force_x = randomfloatrange( 0,001, 0,005 );
	force_y = randomfloatrange( 0,001, 0,005 );
	force_z = randomfloatrange( 0,001, 0,005 );
	physicsjolt( ( 15412,7, -10106,1, -84,8 ), 8, 8, ( force_x, force_y, force_z ) );
	play_shake_lights_audio( 15412,7, -10106,1, -84,8 );
	force_x = randomfloatrange( 0,001, 0,005 );
	force_y = randomfloatrange( 0,001, 0,005 );
	force_z = randomfloatrange( 0,001, 0,005 );
	physicsjolt( ( 15832,7, -9554,1, -68,8 ), 8, 8, ( force_x, force_y, force_z ) );
	play_shake_lights_audio( 15832,7, -9554,1, -68,8 );
	force_x = randomfloatrange( 0,001, 0,005 );
	force_y = randomfloatrange( 0,001, 0,005 );
	force_z = randomfloatrange( 0,001, 0,005 );
	physicsjolt( ( 16028,7, -10108,1, -84,8 ), 8, 8, ( force_x, force_y, force_z ) );
	play_shake_lights_audio( 16028,7, -10108,1, -84,8 );
}

play_shake_lights_audio( x, y, z )
{
	wait randomfloatrange( 0,05, 0,11 );
	playsoundatposition( "evt_mortar_explosion_indoor_shake", ( x, y, z ) );
}

trigger_delete( str_trigger_targetname )
{
	t_trigger = getent( str_trigger_targetname, "targetname" );
	if ( isDefined( t_trigger ) )
	{
		t_trigger delete();
	}
}

test_sight()
{
/#
	e_entity = getent( "muj_arena_cache7", "targetname" );
	while ( 1 )
	{
		if ( level.player is_player_looking_at( e_entity.origin, undefined, 0 ) )
		{
			iprintlnbold( "can see" );
		}
		else
		{
			iprintlnbold( "no can see" );
		}
		wait 1;
#/
	}
}

manage_arena_enemy_squads()
{
	a_e_caches = [];
	a_e_caches[ 0 ] = getent( "vol_cache1", "targetname" );
	a_e_caches[ 1 ] = getent( "vol_cache2", "targetname" );
	a_e_caches[ 2 ] = getent( "vol_cache3", "targetname" );
	a_e_caches[ 3 ] = getent( "vol_cache5", "targetname" );
	a_e_caches[ 4 ] = getent( "vol_cache6", "targetname" );
	sp_cache1 = getent( "soviet_cache1", "targetname" );
	sp_cache2 = getent( "soviet_cache2", "targetname" );
	sp_cache3 = getent( "soviet_cache3", "targetname" );
	sp_cache5 = getent( "soviet_cache5", "targetname" );
	sp_cache6 = getent( "soviet_cache6", "targetname" );
	a_caches = [];
	a_caches = sort_by_distance( a_e_caches, level.player.origin );
	if ( level.player is_on_horseback() )
	{
		n_index = a_caches.size - 1;
		i = 0;
		while ( i < a_caches.size )
		{
			n_dist = distance2dsquared( level.player.origin, a_caches[ n_index ].origin );
			if ( level.player is_player_looking_at( a_caches[ n_index ].origin, undefined, 0 ) && n_dist > 2000 )
			{
				n_index = i;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	else n_index = 0;
	i = a_caches.size - 1;
	while ( i >= 0 )
	{
		n_dist = distance2dsquared( level.player.origin, a_caches[ n_index ].origin );
		if ( level.player is_player_looking_at( a_caches[ n_index ].origin, undefined, 0 ) && n_dist > 2000 )
		{
			n_index = i;
			break;
		}
		else
		{
			i--;

		}
	}
	if ( a_caches[ n_index ].targetname == "vol_cache1" )
	{
		sp_soviet = sp_cache1;
	}
	else if ( a_caches[ n_index ].targetname == "vol_cache2" )
	{
		sp_soviet = sp_cache2;
	}
	else if ( a_caches[ n_index ].targetname == "vol_cache3" )
	{
		sp_soviet = sp_cache3;
	}
	else if ( a_caches[ n_index ].targetname == "vol_cache5" )
	{
		sp_soviet = sp_cache5;
	}
	else
	{
		sp_soviet = sp_cache6;
	}
	i = 0;
	while ( i < randomintrange( 3, 6 ) )
	{
		ai_soviet_arena = sp_soviet spawn_ai( 1 );
		if ( isDefined( ai_soviet_arena ) )
		{
			ai_soviet_arena.targetname = "arena_soviet";
			ai_soviet_arena.goalradius = 256;
			if ( isDefined( level.player.my_horse ) )
			{
				ai_soviet_arena setgoalentity( level.player.my_horse );
			}
			else
			{
				ai_soviet_arena setgoalentity( level.player );
			}
			wait 0,1;
		}
		i++;
	}
	wait 1;
	level thread monitor_arena_soviet();
	level thread monitor_arena_kill();
	a_e_caches = undefined;
	a_caches = undefined;
}

monitor_arena_soviet()
{
	level endon( "blocking_done" );
	while ( 1 )
	{
		a_soviets = getentarray( "arena_soviet", "targetname" );
		if ( !a_soviets.size )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	wait randomintrange( 5, 8 );
	if ( !flag( "bp_underway" ) )
	{
		level thread manage_arena_enemy_squads();
	}
}

monitor_arena_kill()
{
	flag_wait( "bp_underway" );
	a_soviets = getentarray( "arena_soviet", "targetname" );
	while ( a_soviets.size )
	{
		wait randomfloatrange( 0,5, 2 );
		while ( isDefined( a_soviets[ 0 ] ) )
		{
			playsoundatposition( "prj_mortar_incoming", a_soviets[ 0 ].origin );
			wait 0,45;
			ai_soviet = a_soviets[ randomint( a_soviets.size ) ];
			if ( isDefined( ai_soviet ) )
			{
				playfx( level._effect[ "explode_mortar_sand" ], ai_soviet.origin );
				earthquake( 0,2, 1, level.player.origin, 100 );
				playsoundatposition( "exp_mortar", ai_soviet.origin );
			}
			_a3193 = a_soviets;
			_k3193 = getFirstArrayKey( _a3193 );
			while ( isDefined( _k3193 ) )
			{
				ai_soviet = _a3193[ _k3193 ];
				if ( isDefined( ai_soviet ) )
				{
					playsoundatposition( "exp_small_scripted", ai_soviet.origin );
					playfx( level._effect[ "explode_grenade_sand" ], ai_soviet.origin );
					radiusdamage( ai_soviet.origin, 60, 200, 150, undefined, "MOD_PROJECTILE" );
				}
				_k3193 = getNextArrayKey( _a3193, _k3193 );
			}
		}
	}
}

manage_arena_muj_squads( vol_cache )
{
	a_sp_spawners = [];
	a_sp_spawners[ 0 ] = getent( "muj_arena_cache1", "targetname" );
	a_sp_spawners[ 1 ] = getent( "muj_arena_cache2", "targetname" );
	a_sp_spawners[ 2 ] = getent( "muj_arena_cache3", "targetname" );
	a_sp_spawners[ 3 ] = getent( "muj_arena_cache4", "targetname" );
	a_sp_spawners[ 4 ] = getent( "muj_arena_cache5", "targetname" );
	a_sp_spawners[ 5 ] = getent( "muj_arena_cache6", "targetname" );
	a_sp_spawners[ 6 ] = getent( "muj_arena_cache7", "targetname" );
	while ( get_ai_count( "all" ) > 12 )
	{
		wait 1;
	}
	a_sp_muj = [];
	a_sp_muj = sort_by_distance( a_sp_spawners, level.player.origin );
	if ( cointoss() )
	{
		sp_muj = a_sp_muj[ a_sp_muj.size - 1 ];
	}
	else
	{
		sp_muj = a_sp_muj[ a_sp_muj.size - 2 ];
	}
	i = 0;
	while ( i < 3 )
	{
		level.player waittill_player_not_looking_at( sp_muj.origin, undefined, 0 );
		ai_arena_squad = sp_muj spawn_ai( 1 );
		if ( isDefined( ai_arena_squad ) )
		{
			ai_arena_squad thread arena_squad_behavior( vol_cache );
		}
		wait 0,1;
		i++;
	}
	a_sp_spawners = undefined;
	a_sp_muj = undefined;
}

arena_squad_behavior( vol_cache )
{
	self endon( "death" );
	self.goalradius = 64;
	self.arena_guy = 1;
	self setgoalvolumeauto( vol_cache );
	self waittill( "goal" );
	self set_fixednode( 0 );
	wait randomintrange( 3, 6 );
	while ( isDefined( self.enemy ) )
	{
		wait 1;
	}
	while ( 1 )
	{
		a_ai_soviets = getaiarray( "axis" );
		if ( isDefined( a_ai_soviets ) )
		{
			a_ai_guys = sort_by_distance( a_ai_soviets, level.player.origin );
			if ( isDefined( a_ai_guys[ a_ai_guys.size - 1 ] ) )
			{
				self setgoalentity( a_ai_guys[ a_ai_guys.size - 1 ] );
				self.goalradius = 64;
				self waittill( "goal" );
			}
		}
		wait randomintrange( 2, 5 );
	}
}

remove_woods_facemask_util()
{
	level.woods detach( "c_usa_afghan_woods_facewrap" );
}

get_muj()
{
	a_ai_muj = getaiarray( "allies" );
	a_ai_muj = array_exclude( a_ai_muj, level.woods );
	a_ai_muj = array_exclude( a_ai_muj, level.zhao );
	a_ai_talkers = sort_by_distance( a_ai_muj, level.player.origin );
	i = a_ai_talkers.size - 1;
	while ( i >= 0 )
	{
		if ( isalive( a_ai_talkers[ i ] ) )
		{
			return a_ai_talkers[ i ];
		}
		else
		{
			i--;

		}
	}
}

ride_horse( ai_rider, vh_horse )
{
	ai_rider enter_vehicle( vh_horse );
	wait 0,1;
	vh_horse notify( "groupedanimevent" );
	ai_rider maps/_horse_rider::ride_and_shoot( vh_horse );
}

hip_land_unload( drop_struct_name )
{
	self endon( "death" );
	self sethoverparams( 0, 0, 10 );
	drop_struct = getstruct( drop_struct_name, "targetname" );
	drop_origin = drop_struct.origin;
	original_drop_origin = drop_origin;
	original_drop_origin = ( original_drop_origin[ 0 ], original_drop_origin[ 1 ], original_drop_origin[ 2 ] + self.dropoffset );
	drop_origin = ( drop_origin[ 0 ], drop_origin[ 1 ], drop_origin[ 2 ] + 350 );
	self setneargoalnotifydist( 100 );
	self setvehgoalpos( drop_origin, 1 );
	self waittill( "goal" );
	self setvehgoalpos( original_drop_origin, 1 );
	self waittill( "goal" );
	self notify( "unload" );
	self waittill( "unloaded" );
}

hip_rappel_unload( s_drop_pt )
{
	self endon( "death" );
	self sethoverparams( 0, 0, 10 );
	drop_struct = getstruct( s_drop_pt, "targetname" );
	drop_origin = drop_struct.origin;
	drop_offset_tag = "tag_fastrope_ri";
	drop_offset = self gettagorigin( "tag_origin" ) - self gettagorigin( drop_offset_tag );
	drop_offset = ( drop_offset[ 0 ], drop_offset[ 1 ], self.fastropeoffset );
	drop_origin += drop_offset;
	self setvehgoalpos( drop_origin, 1 );
	self waittill( "goal" );
	self notify( "unload" );
	self waittill( "unloaded" );
}

load_landing_troops( n_guys_to_load, str_ai_targetname )
{
	self endon( "death" );
	n_pos = 2;
	i = 0;
	while ( i < n_guys_to_load )
	{
		n_aitype = randomint( 10 );
		if ( n_aitype < 5 )
		{
			sp_rappel = getent( "soviet_assault", "targetname" );
		}
		else if ( n_aitype < 8 )
		{
			sp_rappel = getent( "soviet_smg", "targetname" );
		}
		else
		{
			sp_rappel = getent( "soviet_lmg", "targetname" );
		}
		ai_rappeller = sp_rappel spawn_ai( 1 );
		if ( isDefined( ai_rappeller ) )
		{
			ai_rappeller.script_startingposition = n_pos;
			ai_rappeller.bp_ai = 1;
			ai_rappeller enter_vehicle( self );
			if ( isDefined( str_ai_targetname ) )
			{
				ai_rappeller.targetname = str_ai_targetname;
			}
			n_pos++;
			wait 0,1;
		}
		i++;
	}
}

get_muj_ai()
{
	n_aitype = randomint( 10 );
	if ( n_aitype < 5 )
	{
		sp_rider = getent( "muj_assault", "targetname" );
	}
	else if ( n_aitype < 8 )
	{
		sp_rider = getent( "muj_assault", "targetname" );
	}
	else
	{
		sp_rider = getent( "muj_lmg", "targetname" );
	}
	ai_muj = sp_rider spawn_ai( 1 );
	return ai_muj;
}

get_soviet_ai()
{
	n_aitype = randomint( 10 );
	if ( n_aitype < 5 )
	{
		sp_rider = getent( "soviet_assault", "targetname" );
	}
	else if ( n_aitype < 8 )
	{
		sp_rider = getent( "soviet_smg", "targetname" );
	}
	else
	{
		sp_rider = getent( "soviet_lmg", "targetname" );
	}
	ai_soviet = sp_rider spawn_ai( 1 );
	return ai_soviet;
}

ai_dismount_horse( vh_horse )
{
	self endon( "death" );
	self notify( "stop_riding" );
	self notify( "off_horse" );
	vh_horse vehicle_unload( 0,1 );
	vh_horse waittill( "unloaded" );
}

ai_mount_horse( vh_horse, teleport )
{
	if ( !isDefined( teleport ) )
	{
		teleport = 0;
	}
	self endon( "death" );
	if ( teleport || self == level.zhao && self == level.woods )
	{
		self thread ai_warp_to_horse( vh_horse );
	}
	self run_to_vehicle( vh_horse );
	while ( !isDefined( vh_horse get_driver() ) )
	{
		wait 0,05;
	}
	self notify( "on_horse" );
	vh_horse notify( "groupedanimevent" );
	wait 0,1;
	self maps/_horse_rider::ride_and_shoot( vh_horse );
}

ai_warp_to_horse( vh_horse )
{
	self endon( "enteredvehicle" );
	while ( 1 )
	{
		if ( !level.player is_player_looking_at( self.origin, 0,5, 1 ) )
		{
			if ( !level.player is_player_looking_at( vh_horse.origin, 0,5, 1 ) )
			{
				self thread teleport_ai( vh_horse.origin + ( 0, -150, 30 ), vh_horse.angles );
				return;
			}
		}
		wait 0,05;
	}
}

nag_follow( str_end_flag )
{
	level endon( str_end_flag );
	a_zhao_nag = [];
	a_zhao_nag[ 0 ] = "zhao_stay_with_me_mason_0";
	a_zhao_nag[ 1 ] = "zhao_this_way_0";
	a_zhao_nag[ 2 ] = "zhao_follow_me_0";
	a_zhao_nag[ 3 ] = "zhao_stay_with_me_mason_2";
	a_zhao_nag[ 4 ] = "zhao_follow_me_2";
	a_zhao_nag[ 5 ] = "zhao_stay_close_0";
	a_zhao_nag[ 6 ] = "zhao_keep_up_mason_0";
	a_zhao_nag[ 7 ] = "zhao_we_need_to_get_movin_0";
	a_zhao_nag[ 8 ] = "zhao_that_s_all_we_can_do_0";
	a_zhao_nag[ 9 ] = "zhao_let_s_get_moving_0";
	a_zhao_nag[ 10 ] = "zhao_let_s_go_0";
	a_zhao_nag[ 11 ] = "zhao_push_forward_mason_0";
	a_woods_nag = [];
	a_woods_nag[ 0 ] = "wood_we_need_to_stay_with_0";
	a_woods_nag[ 1 ] = "wood_keep_up_mason_0";
	a_woods_nag[ 2 ] = "wood_stay_close_to_me_0";
	a_woods_nag[ 3 ] = "wood_this_way_follow_me_0";
	a_woods_nag[ 4 ] = "wood_stay_with_me_mason_0";
	a_woods_nag[ 5 ] = "wood_let_s_go_mason_0";
	a_woods_nag[ 6 ] = "wood_time_to_go_come_on_0";
	a_woods_nag[ 7 ] = "wood_forward_mason_0";
	a_woods_nag[ 8 ] = "wood_we_need_to_go_0";
	a_woods_nag[ 9 ] = "wood_come_on_let_s_go_0";
	wait 7;
	while ( !flag( str_end_flag ) )
	{
		if ( cointoss() )
		{
			level.woods say_dialog( a_woods_nag[ randomint( a_woods_nag.size ) ] );
		}
		else
		{
			level.zhao say_dialog( a_zhao_nag[ randomint( a_zhao_nag.size ) ] );
		}
		wait randomfloatrange( 7, 9 );
	}
}

vo_nag_get_back( str_flag_clear )
{
	level endon( "wave2_done" );
	level endon( "wave3_done" );
	while ( flag( str_flag_clear ) )
	{
		switch( randomint( 5 ) )
		{
			case 0:
				level.woods say_dialog( "wood_stay_with_me_mason_0", 1 );
				break;
			continue;
			case 1:
				level.woods say_dialog( "wood_quit_screwin_around_0", 1 );
				break;
			continue;
			case 2:
				level.woods say_dialog( "wood_get_back_here_we_st_0", 1 );
				break;
			continue;
			case 3:
				level.woods say_dialog( "wood_hey_get_your_head_i_0", 1 );
				break;
			continue;
			case 4:
				level.woods say_dialog( "wood_where_the_hell_you_g_0", 1 );
				break;
			continue;
		}
	}
}

vo_get_horse()
{
	if ( !level.player is_on_horseback() )
	{
		switch( randomint( 4 ) )
		{
			case 0:
				level.woods say_dialog( "wood_you_need_a_horse_ma_0", 1 );
				break;
			return;
			case 1:
				level.zhao say_dialog( "zhao_find_another_horse_0", 1 );
				break;
			return;
			case 3:
				level.zhao say_dialog( "wood_get_a_horse_dammit_0", 1 );
				break;
			return;
		}
	}
}

vo_player_horse_sprint()
{
	switch( randomint( 5 ) )
	{
		case 0:
			level.player say_dialog( "maso_faster_come_on_0", 0 );
			break;
		case 2:
			level.player say_dialog( "maso_come_on_go_0", 0 );
			break;
		case 3:
			level.player say_dialog( "maso_gimme_all_you_got_b_0", 0 );
			break;
		case 4:
			level.player say_dialog( "maso_fast_as_you_can_com_0", 0 );
			break;
	}
}

player_has_stinger()
{
	a_current_weapons = level.player getweaponslist();
	_a3732 = a_current_weapons;
	_k3732 = getFirstArrayKey( _a3732 );
	while ( isDefined( _k3732 ) )
	{
		weapon = _a3732[ _k3732 ];
		if ( issubstr( weapon, "afghanstinger" ) )
		{
			return 1;
		}
		_k3732 = getNextArrayKey( _a3732, _k3732 );
	}
	return 0;
}

horse_set_avoidance()
{
	self setvehicleavoidance( 1 );
}

spawn_backup_cache_horse( s_spawnpt, str_delete_flag )
{
	vh_horse = spawn_vehicle_from_targetname( "horse_afghan" );
	vh_horse.origin = s_spawnpt.origin;
	vh_horse.angles = s_spawnpt.angles;
	vh_horse makevehicleusable();
	vh_horse horse_panic();
	flag_wait( str_delete_flag );
	if ( isDefined( vh_horse ) )
	{
		if ( distance2dsquared( vh_horse.origin, s_spawnpt.origin ) <= 640000 )
		{
			vh_horse.delete_on_death = 1;
			vh_horse notify( "death" );
			if ( !isalive( vh_horse ) )
			{
				vh_horse delete();
			}
		}
	}
}

remove_vehicle_corpse()
{
	self endon( "delete" );
	level.player waittill_player_not_looking_at( self.origin, undefined, 0 );
	self delete();
}

attach_weapon( m_weapon_name )
{
	self setactorweapon( m_weapon_name );
}

teleport_ai( v_pos, v_ang )
{
	self endon( "death" );
	self endon( "on_horse" );
	level.player waittill_player_not_looking_at( self.origin, undefined, 0 );
	if ( distance2dsquared( self.origin, v_pos ) > 90000 )
	{
		if ( isDefined( v_ang ) )
		{
			self forceteleport( v_pos, v_ang );
			return;
		}
		else
		{
			self forceteleport( v_pos, self.angles );
		}
	}
}

struct_cleanup_wave1()
{
	a_s_structs = [];
	a_s_structs[ 0 ] = getstruct( "uaz3_goal", "targetname" );
	a_s_structs[ 1 ] = getstruct( "zhao_bp1_goal", "targetname" );
	a_s_structs[ 2 ] = getstruct( "woods_bp1_goal", "targetname" );
	a_s_structs[ 3 ] = getstruct( "detonate_safe_point", "targetname" );
	a_s_structs[ 4 ] = getstruct( "chase_truck_spawnpt", "targetname" );
	a_s_structs[ 5 ] = getstruct( "chopper_victim_spawnpt", "targetname" );
	a_s_structs[ 6 ] = getstruct( "chopper_victim_goal0", "targetname" );
	a_s_structs[ 7 ] = getstruct( "chopper_victim_goal1", "targetname" );
	a_s_structs[ 8 ] = getstruct( "chopper_victim_goal2", "targetname" );
	a_s_structs[ 9 ] = getstruct( "chopper_victim_goal3", "targetname" );
	a_s_structs[ 10 ] = getstruct( "chopper_victim_goal4", "targetname" );
	a_s_structs[ 11 ] = getstruct( "chopper_victim_goal5", "targetname" );
	a_s_structs[ 12 ] = getstruct( "uaz_chase_horse_spawnpt", "targetname" );
	a_s_structs[ 13 ] = getstruct( "uaz_chase_horse_goal0", "targetname" );
	a_s_structs[ 14 ] = getstruct( "uaz_chase_horse_goal1", "targetname" );
	a_s_structs[ 15 ] = getstruct( "bp1_horse_spawnpt", "targetname" );
	a_s_structs[ 16 ] = getstruct( "bp1_horse_goal1", "targetname" );
	a_s_structs[ 17 ] = getstruct( "teleport_woods_pos", "targetname" );
	a_s_structs[ 18 ] = getstruct( "teleport_zhao_pos", "targetname" );
	a_s_structs[ 19 ] = getstruct( "explosion_struct", "targetname" );
	a_s_structs[ 20 ] = getstruct( "hip1_bp1_circle05", "targetname" );
	a_s_structs[ 21 ] = getstruct( "bp1_mig_spawnpt", "targetname" );
	a_s_structs[ 22 ] = getstruct( "bp1_mig_goal1", "targetname" );
	a_s_structs[ 23 ] = getstruct( "bp1_mig_goal2", "targetname" );
	a_s_structs[ 24 ] = getstruct( "bp1_mig_exp1", "targetname" );
	a_s_structs[ 25 ] = getstruct( "bp1_mig_exp2", "targetname" );
	a_s_structs[ 26 ] = getstruct( "bp1_mig_exp3", "targetname" );
	a_s_structs[ 27 ] = getstruct( "bp1_mig_exp4", "targetname" );
	a_s_structs[ 28 ] = getstruct( "bp1_mig_exp5", "targetname" );
	a_s_structs[ 29 ] = getstruct( "bp1_mig_exp6", "targetname" );
	a_s_structs[ 30 ] = getstruct( "bp1_mig2_spawnpt", "targetname" );
	a_s_structs[ 31 ] = getstruct( "bp1_mig2_goal1", "targetname" );
	a_s_structs[ 32 ] = getstruct( "bp1_mig2_goal2", "targetname" );
	a_s_structs[ 33 ] = getstruct( "bp1_mig2_exp1", "targetname" );
	a_s_structs[ 34 ] = getstruct( "bp1_mig2_exp2", "targetname" );
	a_s_structs[ 35 ] = getstruct( "mig_tower_spawnpt", "targetname" );
	a_s_structs[ 36 ] = getstruct( "mig_tower_goal1", "targetname" );
	a_s_structs[ 37 ] = getstruct( "mig_tower_goal2", "targetname" );
	a_s_structs[ 38 ] = getstruct( "mig_tower_goal3", "targetname" );
	a_s_structs[ 39 ] = getstruct( "mig_tower_goal4", "targetname" );
	a_s_structs[ 40 ] = getstruct( "mig_tower_bomb1", "targetname" );
	a_s_structs[ 41 ] = getstruct( "bp1_hitch", "targetname" );
	a_s_structs[ 42 ] = getstruct( "zhao_bp1_horse", "targetname" );
	a_s_structs[ 43 ] = getstruct( "woods_bp1_horse", "targetname" );
	a_s_structs[ 48 ] = getstruct( "cache4_horse_spawnpt", "targetname" );
	a_s_structs[ 49 ] = getstruct( "uaz_bp1exit_spawnpt1", "targetname" );
	a_s_structs[ 50 ] = getstruct( "uaz_bp1exit_spawnpt2", "targetname" );
	a_s_structs[ 51 ] = getstruct( "uaz_bp1exit_spawnpt3", "targetname" );
	a_s_structs[ 52 ] = getstruct( "uaz_bp1exit_spawnpt4", "targetname" );
	a_s_structs[ 59 ] = getstruct( "exit_battle_goal", "targetname" );
	a_s_structs[ 60 ] = getstruct( "hip2_bp1_goal04", "targetname" );
	a_s_structs[ 61 ] = getstruct( "btr_chase_approach_goal", "targetname" );
	a_s_structs[ 62 ] = getstruct( "btr_chase_over_goal", "targetname" );
	a_s_structs[ 63 ] = getstruct( "hip1_bp1_spawnpt", "targetname" );
	a_s_structs[ 64 ] = getstruct( "hip2_bp1_spawnpt", "targetname" );
	a_s_structs[ 65 ] = getstruct( "btr1_bp1_spawnpt", "targetname" );
	a_s_structs[ 66 ] = getstruct( "btr2_bp1_spawnpt", "targetname" );
	a_s_structs[ 67 ] = getstruct( "hip1_bp1_goal01", "targetname" );
	a_s_structs[ 68 ] = getstruct( "hip1_bp1_goal02", "targetname" );
	a_s_structs[ 69 ] = getstruct( "hip1_bp1_goal03", "targetname" );
	a_s_structs[ 70 ] = getstruct( "hip1_bp1_goal04", "targetname" );
	a_s_structs[ 71 ] = getstruct( "hip1_bp1_goal05", "targetname" );
	a_s_structs[ 72 ] = getstruct( "hip1_bp1_goal06", "targetname" );
	a_s_structs[ 73 ] = getstruct( "hip1_bp1_circle02", "targetname" );
	a_s_structs[ 74 ] = getstruct( "bp1_sentry_goal01", "targetname" );
	a_s_structs[ 75 ] = getstruct( "hip2_bp1_goal01", "targetname" );
	a_s_structs[ 76 ] = getstruct( "hip2_bp1_goal02", "targetname" );
	a_s_structs[ 77 ] = getstruct( "hip2_bp1_goal03", "targetname" );
	_a3891 = a_s_structs;
	_k3891 = getFirstArrayKey( _a3891 );
	while ( isDefined( _k3891 ) )
	{
		struct = _a3891[ _k3891 ];
		if ( isDefined( struct ) )
		{
			struct structdelete();
		}
		_k3891 = getNextArrayKey( _a3891, _k3891 );
	}
}

struct_cleanup_wave2()
{
	a_s_structs = [];
	a_s_structs[ 0 ] = getstruct( "wave2bp2_player_horse_spawnpt", "targetname" );
	a_s_structs[ 1 ] = getstruct( "wave2bp2_zhao_horse_spawnpt", "targetname" );
	a_s_structs[ 2 ] = getstruct( "wave2bp2_woods_horse_spawnpt", "targetname" );
	a_s_structs[ 3 ] = getstruct( "wave2bp3_player_horse_spawnpt", "targetname" );
	a_s_structs[ 4 ] = getstruct( "wave2bp3_zhao_horse_spawnpt", "targetname" );
	a_s_structs[ 5 ] = getstruct( "wave2bp3_woods_horse_spawnpt", "targetname" );
	a_s_structs[ 6 ] = getstruct( "bp2_mortar1_obj", "targetname" );
	a_s_structs[ 7 ] = getstruct( "bp2_mortar2_obj", "targetname" );
	a_s_structs[ 8 ] = getstruct( "cache1_horse_spawnpt", "targetname" );
	a_s_structs[ 9 ] = getstruct( "bp2_cache_obj", "targetname" );
	a_s_structs[ 10 ] = getstruct( "arch_target", "targetname" );
	a_s_structs[ 11 ] = getstruct( "zhao_teleport_pos", "targetname" );
	a_s_structs[ 12 ] = getstruct( "woods_teleport_pos", "targetname" );
	a_s_structs[ 13 ] = getstruct( "bp2_mortar1_pos", "targetname" );
	a_s_structs[ 14 ] = getstruct( "bp2_mortar2_pos", "targetname" );
	a_s_structs[ 15 ] = getstruct( "mortar_victim_right_spawnpt", "targetname" );
	a_s_structs[ 16 ] = getstruct( "mortar_victim_left_spawnpt", "targetname" );
	a_s_structs[ 17 ] = getstruct( "bp3_bp2_mortar_truck_spawnpt", "targetname" );
	a_s_structs[ 18 ] = getstruct( "bp3_bp2_mortar_truck_goal", "targetname" );
	a_s_structs[ 19 ] = getstruct( "mortar_victim_truck_goal", "targetname" );
	a_s_structs[ 20 ] = getstruct( "bp2_mig1_spawnpt", "targetname" );
	a_s_structs[ 21 ] = getstruct( "bp2_mig2_spawnpt", "targetname" );
	a_s_structs[ 22 ] = getstruct( "bp2_mig3_spawnpt", "targetname" );
	a_s_structs[ 23 ] = getstruct( "bp2_exit_horse_spawnpt", "targetname" );
	a_s_structs[ 24 ] = getstruct( "exit_battle_horse_goal4", "targetname" );
	a_s_structs[ 25 ] = getstruct( "bp2_exit_uaz1_spawnpt1", "targetname" );
	a_s_structs[ 26 ] = getstruct( "bp2_exit_uaz1_spawnpt2", "targetname" );
	a_s_structs[ 27 ] = getstruct( "bp2_exit_uaz2_spawnpt1", "targetname" );
	a_s_structs[ 28 ] = getstruct( "bp2_exit_uaz2_spawnpt2", "targetname" );
	a_s_structs[ 29 ] = getstruct( "bp2_exit_truck1_spawnpt", "targetname" );
	a_s_structs[ 30 ] = getstruct( "bp2_exit_truck2_spawnpt", "targetname" );
	a_s_structs[ 31 ] = getstruct( "bp2_exit_btr_spawnpt", "targetname" );
	a_s_structs[ 32 ] = getstruct( "bp2_horse_return", "targetname" );
	a_s_structs[ 33 ] = getstruct( "bp2_hitch", "targetname" );
	a_s_structs[ 34 ] = getstruct( "zhao_cache", "targetname" );
	a_s_structs[ 35 ] = getstruct( "bp2_zhaohorse_return", "targetname" );
	a_s_structs[ 36 ] = getstruct( "zhao_bp2_goal3", "targetname" );
	a_s_structs[ 37 ] = getstruct( "zhao_bp2_goal5", "targetname" );
	a_s_structs[ 38 ] = getstruct( "zhao_bp2_goal7", "targetname" );
	a_s_structs[ 39 ] = getstruct( "zhao_bp2_goal9", "targetname" );
	a_s_structs[ 40 ] = getstruct( "rpg_bridge_fire", "targetname" );
	a_s_structs[ 41 ] = getstruct( "bp2_woodshorse_return", "targetname" );
	a_s_structs[ 42 ] = getstruct( "woods_btr_chase_goal1", "targetname" );
	a_s_structs[ 43 ] = getstruct( "zhao_btr_chase_goal1", "targetname" );
	a_s_structs[ 44 ] = getstruct( "bp2_horse_runspot", "targetname" );
	a_s_structs[ 45 ] = getstruct( "ramp_horse_clear", "targetname" );
	a_s_structs[ 46 ] = getstruct( "cache_horse_clear", "targetname" );
	a_s_structs[ 47 ] = getstruct( "bp2_horse_delete", "targetname" );
	a_s_structs[ 48 ] = getstruct( "wave2bp2_hip2_spawnpt", "targetname" );
	a_s_structs[ 49 ] = getstruct( "wave2bp2_hip1_spawnpt", "targetname" );
	a_s_structs[ 50 ] = getstruct( "wave2bp2_btr1_spawnpt", "targetname" );
	a_s_structs[ 51 ] = getstruct( "wave2bp2_btr2_spawnpt", "targetname" );
	a_s_structs[ 52 ] = getstruct( "wave2bp2_hip1_spawnpt", "targetname" );
	a_s_structs[ 53 ] = getstruct( "wave2bp2_btr1_spawnpt", "targetname" );
	a_s_structs[ 54 ] = getstruct( "wave2bp2_tank_spawnpt", "targetname" );
	a_s_structs[ 55 ] = getstruct( "cave_transport_pad", "targetname" );
	a_s_structs[ 56 ] = getstruct( "wave2bp2_tank_spawnpt", "targetname" );
	a_s_structs[ 57 ] = getstruct( "bp2_reinforce_horse_spawnpt", "targetname" );
	a_s_structs[ 58 ] = getstruct( "muj_reinforce_right", "targetname" );
	a_s_structs[ 59 ] = getstruct( "muj_right_goal1", "targetname" );
	a_s_structs[ 60 ] = getstruct( "muj_right_goal2", "targetname" );
	a_s_structs[ 61 ] = getstruct( "muj_right_goal3", "targetname" );
	a_s_structs[ 62 ] = getstruct( "muj_right_goal4", "targetname" );
	a_s_structs[ 63 ] = getstruct( "muj_reinforce_left", "targetname" );
	a_s_structs[ 64 ] = getstruct( "muj_left_goal1", "targetname" );
	a_s_structs[ 65 ] = getstruct( "muj_left_goal2", "targetname" );
	a_s_structs[ 66 ] = getstruct( "muj_left_goal3", "targetname" );
	a_s_structs[ 67 ] = getstruct( "muj_left_goal4", "targetname" );
	a_s_structs[ 68 ] = getstruct( "hipdropoff1_spawnpt", "targetname" );
	a_s_structs[ 69 ] = getstruct( "hipdropoff2_spawnpt", "targetname" );
	a_s_structs[ 70 ] = getstruct( "hipdropoff3_spawnpt", "targetname" );
	a_s_structs[ 71 ] = getstruct( "hipdropoff4_spawnpt", "targetname" );
	a_s_structs[ 72 ] = getstruct( "hip_dropoff_goal1", "targetname" );
	a_s_structs[ 73 ] = getstruct( "hip_dropoff_goal2", "targetname" );
	a_s_structs[ 74 ] = getstruct( "hip_dropoff_goal3", "targetname" );
	a_s_structs[ 75 ] = getstruct( "hip_dropoff_goal4", "targetname" );
	a_s_structs[ 76 ] = getstruct( "hip1_dropoff", "targetname" );
	a_s_structs[ 77 ] = getstruct( "hip_dropoff_goal1", "targetname" );
	a_s_structs[ 78 ] = getstruct( "hip_dropoff_goal2", "targetname" );
	a_s_structs[ 79 ] = getstruct( "hip_dropoff_goal3", "targetname" );
	a_s_structs[ 80 ] = getstruct( "hip_dropoff_goal4", "targetname" );
	a_s_structs[ 81 ] = getstruct( "hip2_dropoff_goal0", "targetname" );
	a_s_structs[ 82 ] = getstruct( "hip1_wave2bp2_goal1", "targetname" );
	a_s_structs[ 83 ] = getstruct( "hip1_wave2bp2_goal2", "targetname" );
	a_s_structs[ 84 ] = getstruct( "hip1_wave2bp2_goal3", "targetname" );
	a_s_structs[ 85 ] = getstruct( "hip1_wave2bp2_goal4", "targetname" );
	a_s_structs[ 86 ] = getstruct( "hip1_wave2bp2_goal5", "targetname" );
	a_s_structs[ 87 ] = getstruct( "hip1_wave2bp2_goal6", "targetname" );
	a_s_structs[ 88 ] = getstruct( "bp2_circle_goal01", "targetname" );
	a_s_structs[ 89 ] = getstruct( "bp2_sentry_goal08", "targetname" );
	a_s_structs[ 90 ] = getstruct( "hip2_wave2bp2_goal1", "targetname" );
	a_s_structs[ 91 ] = getstruct( "hip2_wave2bp2_goal2", "targetname" );
	a_s_structs[ 92 ] = getstruct( "hip2_wave2bp2_goal3", "targetname" );
	a_s_structs[ 93 ] = getstruct( "hip2_wave2bp2_goal4", "targetname" );
	a_s_structs[ 94 ] = getstruct( "bp2_hind_goal01", "targetname" );
	a_s_structs[ 95 ] = getstruct( "bp2_hind_goal02", "targetname" );
	a_s_structs[ 96 ] = getstruct( "bp2_hind_goal03", "targetname" );
	a_s_structs[ 97 ] = getstruct( "bp2_hind_goal04", "targetname" );
	a_s_structs[ 98 ] = getstruct( "bp2_hind_goal05", "targetname" );
	a_s_structs[ 99 ] = getstruct( "bp2_hind_goal06", "targetname" );
	a_s_structs[ 100 ] = getstruct( "bp2_hind_goal07", "targetname" );
	a_s_structs[ 101 ] = getstruct( "bp2_hind_goal08", "targetname" );
	a_s_structs[ 102 ] = getstruct( "bp2_hind_goal09", "targetname" );
	a_s_structs[ 103 ] = getstruct( "bp2_hind_goal10", "targetname" );
	a_s_structs[ 104 ] = getstruct( "bp2_hind_goal10", "targetname" );
	a_s_structs[ 105 ] = getstruct( "bp2_hind_right01", "targetname" );
	a_s_structs[ 106 ] = getstruct( "bp2_hind_right02", "targetname" );
	a_s_structs[ 107 ] = getstruct( "bp2_hind_right03", "targetname" );
	a_s_structs[ 108 ] = getstruct( "bp2_hind_right04", "targetname" );
	a_s_structs[ 109 ] = getstruct( "bp2_hind_left01", "targetname" );
	a_s_structs[ 110 ] = getstruct( "bp2_hind_left02", "targetname" );
	a_s_structs[ 111 ] = getstruct( "bp2_hind_left03", "targetname" );
	a_s_structs[ 112 ] = getstruct( "bp2_hind_left04", "targetname" );
	a_s_structs[ 113 ] = getstruct( "bp2_hind_cache1", "targetname" );
	a_s_structs[ 114 ] = getstruct( "bp2_hind_cache2", "targetname" );
	a_s_structs[ 115 ] = getstruct( "bp2_hind_cache3", "targetname" );
	a_s_structs[ 116 ] = getstruct( "bp2_hind_cache4", "targetname" );
	a_s_structs[ 117 ] = getstruct( "bp3_uaz1_spawnpt", "targetname" );
	a_s_structs[ 118 ] = getstruct( "bp3_uaz2_spawnpt", "targetname" );
	a_s_structs[ 119 ] = getstruct( "btr_chase_spawnpt", "targetname" );
	a_s_structs[ 120 ] = getstruct( "btr_chase_goal1", "targetname" );
	a_s_structs[ 121 ] = getstruct( "btr_chase_goal2", "targetname" );
	a_s_structs[ 122 ] = getstruct( "bp3_exit_chopper_spawnpt", "targetname" );
	a_s_structs[ 123 ] = getstruct( "bp3_exit_horse_spawnpt", "targetname" );
	a_s_structs[ 124 ] = getstruct( "exit_battle_horse_goal4", "targetname" );
	a_s_structs[ 125 ] = getstruct( "bp3_exit_chopper_spawnpt", "targetname" );
	a_s_structs[ 126 ] = getstruct( "bp3_exit_chopper_goal0", "targetname" );
	a_s_structs[ 127 ] = getstruct( "bp3_exit_chopper_goal1", "targetname" );
	a_s_structs[ 128 ] = getstruct( "bp3_exit_chopper_goal2", "targetname" );
	a_s_structs[ 129 ] = getstruct( "bp3_exit_chopper_goal3", "targetname" );
	a_s_structs[ 130 ] = getstruct( "btr1_bp3_spawnpt", "targetname" );
	a_s_structs[ 131 ] = getstruct( "btr2_bp3_spawnpt", "targetname" );
	a_s_structs[ 132 ] = getstruct( "btr1_bp3_spawnpt", "targetname" );
	a_s_structs[ 133 ] = getstruct( "rpg_bridge_target", "targetname" );
	a_s_structs[ 134 ] = getstruct( "wave3bp3_tank_spawnpt", "targetname" );
	a_s_structs[ 135 ] = getstruct( "rpg_sniper_target", "targetname" );
	a_s_structs[ 136 ] = getstruct( "bp2_exit_divert", "targetname" );
	a_s_structs[ 137 ] = getstruct( "bp2_exit_battle_zhao", "targetname" );
	a_s_structs[ 138 ] = getstruct( "bp2_exit_divert", "targetname" );
	a_s_structs[ 139 ] = getstruct( "bp2_exit_battle_woods", "targetname" );
	a_s_structs[ 140 ] = getstruct( "tank_bp3_spawnpt", "targetname" );
	a_s_structs[ 141 ] = getstruct( "bp3_hind1_spawnpt", "targetname" );
	a_s_structs[ 142 ] = getstruct( "bp3_horse_rideoff", "targetname" );
	a_s_structs[ 143 ] = getstruct( "bp3_hip1_spawnpt", "targetname" );
	a_s_structs[ 144 ] = getstruct( "bp3_hip2_spawnpt", "targetname" );
	a_s_structs[ 145 ] = getstruct( "hip1_bp3_liftoff", "targetname" );
	a_s_structs[ 146 ] = getstruct( "hip1_bp3_dropoff", "targetname" );
	a_s_structs[ 147 ] = getstruct( "hip1_bp3_ascent", "targetname" );
	a_s_structs[ 148 ] = getstruct( "hip_bp3_circle01", "targetname" );
	a_s_structs[ 149 ] = getstruct( "bp3_sentry_goal07", "targetname" );
	a_s_structs[ 150 ] = getstruct( "hip2_bp3_liftoff", "targetname" );
	a_s_structs[ 151 ] = getstruct( "hip2_bp3_over", "targetname" );
	a_s_structs[ 152 ] = getstruct( "hip2_bp3_approach", "targetname" );
	a_s_structs[ 153 ] = getstruct( "hip2_bp3_dropoff", "targetname" );
	a_s_structs[ 154 ] = getstruct( "hip2_bp3_away", "targetname" );
	a_s_structs[ 155 ] = getstruct( "crew_stinger_fire", "targetname" );
	a_s_structs[ 156 ] = getstruct( "hind_bridge_target", "targetname" );
	a_s_structs[ 157 ] = getstruct( "hind_bp3_goal1", "targetname" );
	a_s_structs[ 158 ] = getstruct( "hind_bp3_goal2", "targetname" );
	a_s_structs[ 159 ] = getstruct( "hind_bp3_goal3", "targetname" );
	a_s_structs[ 160 ] = getstruct( "hind_bp3_goal4", "targetname" );
	a_s_structs[ 161 ] = getstruct( "hind_bp3_goal5", "targetname" );
	a_s_structs[ 162 ] = getstruct( "hind_bp3_goal6", "targetname" );
	a_s_structs[ 163 ] = getstruct( "hind_bp3_goal7", "targetname" );
	a_s_structs[ 164 ] = getstruct( "hind_bp3_goal8", "targetname" );
	a_s_structs[ 165 ] = getstruct( "hind_bp3_goal9", "targetname" );
	a_s_structs[ 166 ] = getstruct( "hind_bp3_goal10", "targetname" );
	a_s_structs[ 167 ] = getstruct( "hind_bp3_goal11", "targetname" );
	a_s_structs[ 168 ] = getstruct( "hind_bp3_goal11", "targetname" );
	a_s_structs[ 169 ] = getstruct( "hind_bp3_goal13", "targetname" );
	a_s_structs[ 170 ] = getstruct( "hind_bp3_goal14", "targetname" );
	a_s_structs[ 171 ] = getstruct( "hind_bp3_goal15", "targetname" );
	a_s_structs[ 172 ] = getstruct( "hind_bp3_goal3", "targetname" );
	a_s_structs[ 173 ] = getstruct( "hind_bp3_goal4", "targetname" );
	a_s_structs[ 174 ] = getstruct( "hind_bp3_goal5", "targetname" );
	a_s_structs[ 175 ] = getstruct( "hind_bp3_goal6", "targetname" );
	a_s_structs[ 176 ] = getstruct( "hind_bp3_goal7", "targetname" );
	a_s_structs[ 177 ] = getstruct( "hind_bp3_goal8", "targetname" );
	a_s_structs[ 178 ] = getstruct( "hind_bp3_base01", "targetname" );
	a_s_structs[ 179 ] = getstruct( "hind_bp3_base02", "targetname" );
	a_s_structs[ 180 ] = getstruct( "hind_bp3_base03", "targetname" );
	a_s_structs[ 181 ] = getstruct( "hind_bp3_base04", "targetname" );
	a_s_structs[ 182 ] = getstruct( "hind_bp3_base05", "targetname" );
	a_s_structs[ 183 ] = getstruct( "bp3_heli_hip_spawnpt", "targetname" );
	a_s_structs[ 184 ] = getstruct( "statue_entrance_rpg", "targetname" );
	a_s_structs[ 185 ] = getstruct( "statue_entrance_target", "targetname" );
	i = 0;
	while ( i <= 185 )
	{
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_structs = getstructarray( "bp3_approach_explosion", "targetname" );
	i = 0;
	while ( i < a_structs.size )
	{
		if ( isDefined( a_structs[ i ] ) )
		{
			a_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_hitpts = getstructarray( "mortar_hit_point", "targetname" );
	i = 0;
	while ( i < a_s_hitpts.size )
	{
		if ( isDefined( a_s_hitpts[ i ] ) )
		{
			a_s_hitpts[ i ] structdelete();
		}
		i++;
	}
	a_s_spawnpts = [];
	i = 0;
	while ( i < 8 )
	{
		a_s_spawnpts[ i ] = getstruct( "horse_lineup_spawnpt" + i, "targetname" );
		if ( isDefined( a_s_spawnpts[ i ] ) )
		{
			a_s_spawnpts[ i ] structdelete();
		}
		i++;
	}
	a_s_goal = [];
	i = 1;
	while ( i < 19 )
	{
		a_s_goal[ i ] = getstruct( "hind_bp3_goal" + i, "targetname" );
		if ( isDefined( a_s_goal[ i ] ) )
		{
			a_s_goal[ i ] structdelete();
		}
		i++;
	}
	a_s_spawnpts = [];
	i = 0;
	while ( i < 9 )
	{
		a_s_spawnpts[ i ] = getstruct( "bp3_horse_spawnpt" + i, "targetname" );
		if ( isDefined( a_s_spawnpts[ i ] ) )
		{
			a_s_spawnpts[ i ] structdelete();
		}
		i++;
	}
}

struct_cleanup_firehorse()
{
	a_s_structs = [];
	a_s_structs[ 0 ] = getstruct( "muj_horse_exit", "targetname" );
	a_s_structs[ 1 ] = getstruct( "firehorse_zhao_spawnpt", "targetname" );
	a_s_structs[ 2 ] = getstruct( "firehorse_woods_spawnpt", "targetname" );
	a_s_structs[ 3 ] = getstruct( "firehorse_mason_spawnpt", "targetname" );
	a_s_structs[ 4 ] = getstruct( "rpg_fireat_hip1", "targetname" );
	a_s_structs[ 5 ] = getstruct( "flaming_horse_goal", "targetname" );
	a_s_structs[ 6 ] = getstruct( "mig_cave_strafe_spawnpt", "targetname" );
	a_s_structs[ 7 ] = getstruct( "mig_cave_strafe_goal2", "targetname" );
	a_s_structs[ 8 ] = getstruct( "hip4_approach", "targetname" );
	a_s_structs[ 9 ] = getstruct( "arena_mig1_start", "targetname" );
	a_s_structs[ 10 ] = getstruct( "arena_mig1_mid", "targetname" );
	a_s_structs[ 11 ] = getstruct( "arena_mig1_end", "targetname" );
	a_s_structs[ 12 ] = getstruct( "hip4_hover", "targetname" );
	a_s_structs[ 13 ] = getstruct( "explosion_base01", "targetname" );
	a_s_structs[ 14 ] = getstruct( "base_horse_goal1", "targetname" );
	a_s_structs[ 15 ] = getstruct( "mig23_bomb_exp1", "targetname" );
	a_s_structs[ 16 ] = getstruct( "mig23_bomb_exp2", "targetname" );
	a_s_structs[ 17 ] = getstruct( "hip4_liftoff", "targetname" );
	a_s_structs[ 18 ] = getstruct( "hip3_land", "targetname" );
	a_s_structs[ 19 ] = getstruct( "hip4_descent", "targetname" );
	a_s_structs[ 20 ] = getstruct( "hip4_factory", "targetname" );
	a_s_structs[ 21 ] = getstruct( "mig_shootat", "targetname" );
	a_s_structs[ 22 ] = getstruct( "tunnel_runner_killer", "targetname" );
	a_s_structs[ 23 ] = getstruct( "mig_in_face_spawnpt", "targetname" );
	a_s_structs[ 24 ] = getstruct( "mig23_firehorse_spawnpt", "targetname" );
	a_s_structs[ 25 ] = getstruct( "first_mig_delete", "targetname" );
	a_s_structs[ 26 ] = getstruct( "hip4_air", "targetname" );
	a_s_structs[ 27 ] = getstruct( "hip4_mid", "targetname" );
	a_s_structs[ 28 ] = getstruct( "arena_uaz1_spawnpt", "targetname" );
	a_s_structs[ 29 ] = getstruct( "uaz1_entry", "targetname" );
	a_s_structs[ 30 ] = getstruct( "arena_goal_01", "targetname" );
	a_s_structs[ 31 ] = getstruct( "uaz_stinger", "targetname" );
	a_s_structs[ 32 ] = getstruct( "afghan_tank_spawnpt", "targetname" );
	a_s_structs[ 33 ] = getstruct( "muj_tank_wait", "targetname" );
	a_s_structs[ 34 ] = getstruct( "muj_tank_pos", "targetname" );
	a_s_structs[ 35 ] = getstruct( "muj_tank_move", "targetname" );
	a_s_structs[ 36 ] = getstruct( "mig_tank_destroy_spawnpt", "targetname" );
	a_s_structs[ 37 ] = getstruct( "mig_tank_destroy_goal1", "targetname" );
	a_s_structs[ 38 ] = getstruct( "mig_tank_destroy_goal2", "targetname" );
	a_s_structs[ 39 ] = getstruct( "arena_uaz2_spawnpt", "targetname" );
	a_s_structs[ 40 ] = getstruct( "uaz2_goal_03", "targetname" );
	a_s_structs[ 41 ] = getstruct( "arena_uaz3_spawnpt", "targetname" );
	a_s_structs[ 42 ] = getstruct( "uaz3_goal", "targetname" );
	a_s_structs[ 43 ] = getstruct( "arena_hip2_spawn", "targetname" );
	a_s_structs[ 44 ] = getstruct( "arena_hip2_start", "targetname" );
	a_s_structs[ 45 ] = getstruct( "arena_hip2_mid", "targetname" );
	a_s_structs[ 46 ] = getstruct( "arena_hip2_destroy", "targetname" );
	a_s_structs[ 47 ] = getstruct( "arena_hip3", "targetname" );
	a_s_structs[ 48 ] = getstruct( "arena_hip3_start", "targetname" );
	a_s_structs[ 49 ] = getstruct( "arena_hip3_mid", "targetname" );
	a_s_structs[ 50 ] = getstruct( "arena_hip3_land", "targetname" );
	a_s_structs[ 51 ] = getstruct( "arena_hip3_takeoff", "targetname" );
	a_s_structs[ 52 ] = getstruct( "arena_hip3_air", "targetname" );
	a_s_structs[ 53 ] = getstruct( "arena_hip3_far", "targetname" );
	a_s_structs[ 54 ] = getstruct( "arena_hip3_end", "targetname" );
	a_s_structs[ 55 ] = getstruct( "hip3_factory", "targetname" );
	a_s_structs[ 56 ] = getstruct( "hip3_takeoff", "targetname" );
	a_s_structs[ 57 ] = getstruct( "hip3_air", "targetname" );
	a_s_structs[ 58 ] = getstruct( "hip3_approach", "targetname" );
	i = 0;
	while ( i < a_s_structs.size )
	{
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_spawnpts = getstructarray( "base_horse_spawnpt", "targetname" );
	i = 0;
	while ( i < a_s_spawnpts.size )
	{
		if ( isDefined( a_s_spawnpts[ i ] ) )
		{
			a_s_spawnpts[ i ] structdelete();
		}
		i++;
	}
	a_s_explosion = getstructarray( "explosion_close_base", "targetname" );
	i = 0;
	while ( i < a_s_explosion.size )
	{
		if ( isDefined( a_s_explosion[ i ] ) )
		{
			a_s_explosion[ i ] structdelete();
		}
		i++;
	}
	a_s_explos = getstructarray( "explosion_far_base", "targetname" );
	i = 0;
	while ( i < a_s_explos.size )
	{
		if ( isDefined( a_s_explos[ i ] ) )
		{
			a_s_explos[ i ] structdelete();
		}
		i++;
	}
	a_s_scts = getstructarray( "explosion_player", "targetname" );
	i = 0;
	while ( i < a_s_scts.size )
	{
		if ( isDefined( a_s_scts[ i ] ) )
		{
			a_s_scts[ i ] structdelete();
		}
		i++;
	}
	a_s_stcts = getstructarray( "arena_explosion_far", "targetname" );
	i = 0;
	while ( i < a_s_stcts.size )
	{
		if ( isDefined( a_s_stcts[ i ] ) )
		{
			a_s_stcts[ i ] structdelete();
		}
		i++;
	}
	a_s_flyovers = getstructarray( "mig_base_flyover1", "targetname" );
	i = 0;
	while ( i < a_s_flyovers.size )
	{
		if ( isDefined( a_s_flyovers[ i ] ) )
		{
			a_s_flyovers[ i ] structdelete();
		}
		i++;
	}
	a_s_migs = getstructarray( "mig_flyover_delete1", "targetname" );
	i = 0;
	while ( i < a_s_migs.size )
	{
		if ( isDefined( a_s_migs[ i ] ) )
		{
			a_s_migs[ i ] structdelete();
		}
		i++;
	}
	a_s_mig_base = getstructarray( "mig_base_flyover2", "targetname" );
	i = 0;
	while ( i < a_s_mig_base.size )
	{
		if ( isDefined( a_s_mig_base[ i ] ) )
		{
			a_s_mig_base[ i ] structdelete();
		}
		i++;
	}
	a_s_delete2 = getstructarray( "mig_flyover_delete2", "targetname" );
	i = 0;
	while ( i < a_s_delete2.size )
	{
		if ( isDefined( a_s_delete2[ i ] ) )
		{
			a_s_delete2[ i ] structdelete();
		}
		i++;
	}
}

struct_cleanup_wave3()
{
	a_s_structs = [];
	a_s_structs[ 0 ] = getstruct( "wave1_player_horse_spawnpt", "targetname" );
	a_s_structs[ 1 ] = getstruct( "wave1_zhao_horse_spawnpt", "targetname" );
	a_s_structs[ 2 ] = getstruct( "wave1_woods_horse_spawnpt", "targetname" );
	a_s_structs[ 3 ] = getstruct( "zhao_bp3", "targetname" );
	a_s_structs[ 4 ] = getstruct( "bp3_entrance", "targetname" );
	a_s_structs[ 5 ] = getstruct( "truckride_spawnpt", "targetname" );
	a_s_structs[ 6 ] = getstruct( "bp1wave3_hip1_spawnpt", "targetname" );
	a_s_structs[ 7 ] = getstruct( "bp1wave3_hip2_spawnpt", "targetname" );
	a_s_structs[ 8 ] = getstruct( "bp1_hind1_spawnpt", "targetname" );
	a_s_structs[ 9 ] = getstruct( "bp1_hind2_spawnpt", "targetname" );
	a_s_structs[ 10 ] = getstruct( "bp1wave3_hip1_goal1", "targetname" );
	a_s_structs[ 11 ] = getstruct( "bp1wave3_hip1_goal2", "targetname" );
	a_s_structs[ 12 ] = getstruct( "bp1wave3_hip_circle2", "targetname" );
	a_s_structs[ 13 ] = getstruct( "hip_arena_circle1", "targetname" );
	a_s_structs[ 14 ] = getstruct( "bp1wave3_hip2_goal1", "targetname" );
	a_s_structs[ 15 ] = getstruct( "bp1wave3_hip_circle1", "targetname" );
	a_s_structs[ 16 ] = getstruct( "bp1_hind1_cache1", "targetname" );
	a_s_structs[ 17 ] = getstruct( "bp1_hind1_cache2", "targetname" );
	a_s_structs[ 18 ] = getstruct( "bp1_hind1_cache3", "targetname" );
	a_s_structs[ 19 ] = getstruct( "bp1_hind2_cache1", "targetname" );
	a_s_structs[ 20 ] = getstruct( "bp1_hind2_cache2", "targetname" );
	a_s_structs[ 21 ] = getstruct( "bp1_obj_marker2", "targetname" );
	a_s_structs[ 22 ] = getstruct( "bp2_obj_marker", "targetname" );
	a_s_structs[ 23 ] = getstruct( "bp3_obj_marker", "targetname" );
	a_s_structs[ 24 ] = getstruct( "zhao_bp1wave3_goal", "targetname" );
	a_s_structs[ 25 ] = getstruct( "woods_bp1wave3_goal", "targetname" );
	a_s_structs[ 26 ] = getstruct( "zhao_bp2", "targetname" );
	a_s_structs[ 27 ] = getstruct( "woods_bp2", "targetname" );
	a_s_structs[ 28 ] = getstruct( "woods_bp3", "targetname" );
	a_s_structs[ 29 ] = getstruct( "bp3wave3_hind_spawnpt", "targetname" );
	a_s_structs[ 30 ] = getstruct( "bp2wave3_hind_spawnpt", "targetname" );
	i = 0;
	while ( i < a_s_structs.size )
	{
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 8 )
	{
		a_s_structs[ i ] = getstruct( "bp1_hind2_basegoal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 14 )
	{
		a_s_structs[ i ] = getstruct( "bp2wave3_hind_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 13 )
	{
		a_s_structs[ i ] = getstruct( "bp3wave3_hind_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 10 )
	{
		a_s_structs[ i ] = getstruct( "bp1_hind2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 10 )
	{
		a_s_structs[ i ] = getstruct( "bp1_hind1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 8 )
	{
		a_s_structs[ i ] = getstruct( "bp1_hind1_basegoal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
}

struct_cleanup_blocking_done()
{
	a_s_structs = [];
	a_s_structs[ 0 ] = getstruct( "last_zhao_horse", "targetname" );
	a_s_structs[ 1 ] = getstruct( "last_woods_horse", "targetname" );
	a_s_structs[ 2 ] = getstruct( "last_player_horse", "targetname" );
	a_s_structs[ 3 ] = getstruct( "zhao_return", "targetname" );
	a_s_structs[ 4 ] = getstruct( "return_base_pos", "targetname" );
	a_s_structs[ 5 ] = getstruct( "base_defend_pos", "targetname" );
	a_s_structs[ 6 ] = getstruct( "truck_base_defense_spawnpt", "targetname" );
	a_s_structs[ 7 ] = getstruct( "reinforcement_goal0", "targetname" );
	a_s_structs[ 8 ] = getstruct( "reinforcement_goal1", "targetname" );
	a_s_structs[ 9 ] = getstruct( "reinforcement_goal2", "targetname" );
	a_s_structs[ 10 ] = getstruct( "reinforcement_goal3", "targetname" );
	a_s_structs[ 11 ] = getstruct( "truck_goal1", "targetname" );
	a_s_structs[ 12 ] = getstruct( "truck_goal2", "targetname" );
	a_s_structs[ 13 ] = getstruct( "truck_goal3", "targetname" );
	a_s_structs[ 14 ] = getstruct( "bp1wave4_hip1_spawnpt", "targetname" );
	a_s_structs[ 15 ] = getstruct( "bp1wave4_hip2_spawnpt", "targetname" );
	a_s_structs[ 16 ] = getstruct( "bp1wave4_hind1_spawnpt", "targetname" );
	a_s_structs[ 17 ] = getstruct( "bp1wave4_hind2_spawnpt", "targetname" );
	a_s_structs[ 18 ] = getstruct( "bp2wave4_hip1_spawnpt", "targetname" );
	a_s_structs[ 19 ] = getstruct( "bp2wave4_hip2_spawnpt", "targetname" );
	a_s_structs[ 20 ] = getstruct( "wave4bp2_btr1_spawnpt", "targetname" );
	a_s_structs[ 21 ] = getstruct( "wave4bp2_btr2_spawnpt", "targetname" );
	a_s_structs[ 22 ] = getstruct( "wave4bp2_tank1_spawnpt", "targetname" );
	a_s_structs[ 23 ] = getstruct( "bp2wave4_hind1_spawnpt", "targetname" );
	a_s_structs[ 24 ] = getstruct( "bp2wave4_hind2_spawnpt", "targetname" );
	a_s_structs[ 25 ] = getstruct( "wave4bp2_tank2_spawnpt", "targetname" );
	a_s_structs[ 26 ] = getstruct( "bp2wave4_hind_attackpos", "targetname" );
	a_s_structs[ 27 ] = getstruct( "bp3wave4_hip1_spawnpt", "targetname" );
	a_s_structs[ 28 ] = getstruct( "bp3wave4_hip2_spawnpt", "targetname" );
	a_s_structs[ 29 ] = getstruct( "wave4bp3_btr1_spawnpt", "targetname" );
	a_s_structs[ 30 ] = getstruct( "wave4bp3_btr2_spawnpt", "targetname" );
	a_s_structs[ 31 ] = getstruct( "bp3wave4_hind1_spawnpt", "targetname" );
	a_s_structs[ 32 ] = getstruct( "bp3wave4_hind2_spawnpt", "targetname" );
	a_s_structs[ 33 ] = getstruct( "wave4bp3_tank1_spawnpt", "targetname" );
	a_s_structs[ 34 ] = getstruct( "wave4bp3_tank2_spawnpt", "targetname" );
	i = 0;
	while ( i <= 34 )
	{
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 19 )
	{
		a_s_structs[ i ] = getstruct( "bp1wave4_hind2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 23 )
	{
		a_s_structs[ i ] = getstruct( "bp1wave4_hind1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 17 )
	{
		a_s_structs[ i ] = getstruct( "bp2wave4_hip1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 17 )
	{
		a_s_structs[ i ] = getstruct( "bp2wave4_hip2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 15 )
	{
		a_s_structs[ i ] = getstruct( "bp1wave4_hip2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 12 )
	{
		a_s_structs[ i ] = getstruct( "bp2wave4_hind1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 12 )
	{
		a_s_structs[ i ] = getstruct( "bp2wave4_hind2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 14 )
	{
		a_s_structs[ i ] = getstruct( "bp3wave4_hip1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 14 )
	{
		a_s_structs[ i ] = getstruct( "bp3wave4_hip2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 13 )
	{
		a_s_structs[ i ] = getstruct( "bp3wave4_hind1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 13 )
	{
		a_s_structs[ i ] = getstruct( "bp3wave4_hind2_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
	a_s_structs = [];
	i = 1;
	while ( i < 12 )
	{
		a_s_structs[ i ] = getstruct( "bp1wave4_hip1_goal" + i, "targetname" );
		if ( isDefined( a_s_structs[ i ] ) )
		{
			a_s_structs[ i ] structdelete();
		}
		i++;
	}
}

close_base_gate()
{
	e_right_door = getent( "base_gate_right", "targetname" );
	e_left_door = getent( "base_gate_left", "targetname" );
	e_right_door rotateyaw( -90, 0,5 );
	e_left_door rotateyaw( 90, 0,5 );
	clip = getent( "clip_gates_base", "targetname" );
	clip.origin += vectorScale( ( 0, 0, 1 ), 10000 );
}

open_base_gate( rotate_doors )
{
	if ( !isDefined( rotate_doors ) )
	{
		rotate_doors = 0;
	}
	clip = getent( "clip_gates_base", "targetname" );
	clip.origin -= vectorScale( ( 0, 0, 1 ), 10000 );
	clip connectpaths();
	if ( rotate_doors )
	{
		e_right_door = getent( "base_gate_right", "targetname" );
		e_left_door = getent( "base_gate_left", "targetname" );
		e_right_door rotateyaw( 90, 0,5 );
		e_left_door rotateyaw( -90, 0,5 );
	}
}

base_wall_hide_destroyed_state()
{
	i = 1;
	while ( i <= 4 )
	{
		a_wall_peices = getentarray( "base_wall_" + i + "_d", "targetname" );
		p = 0;
		while ( p < a_wall_peices.size )
		{
			a_wall_peices[ p ] hide();
			p++;
		}
		i++;
	}
	a_base_tower_clip = getentarray( "clip_base_tower", "targetname" );
	_a4667 = a_base_tower_clip;
	_k4667 = getFirstArrayKey( _a4667 );
	while ( isDefined( _k4667 ) )
	{
		e_obj = _a4667[ _k4667 ];
		e_obj.origin -= vectorScale( ( 0, 0, 1 ), 1000 );
		_k4667 = getNextArrayKey( _a4667, _k4667 );
	}
}

base_wall_destroy( num )
{
	exploder( 800 + num );
	wait 0,05;
	a_wall_peices = getentarray( "base_wall_" + num + "_d", "targetname" );
	i = 0;
	while ( i < a_wall_peices.size )
	{
		a_wall_peices[ i ] show();
		i++;
	}
	a_wall_pieces = getentarray( "base_wall_" + num, "targetname" );
	i = 0;
	while ( i < a_wall_pieces.size )
	{
		a_wall_pieces[ i ] delete();
		i++;
	}
	a_ais = get_ai_from_spawn_manager( "sm_muj_wall_" + num );
	array_delete( a_ais );
	spawn_manager_kill( "sm_muj_wall_" + num, 1 );
}

enable_base_spawn_managers()
{
	spawn_manager_enable( "sm_muj_wall_1" );
	spawn_manager_enable( "sm_muj_wall_2" );
	spawn_manager_enable( "sm_muj_wall_3" );
	spawn_manager_enable( "sm_muj_wall_4" );
}

mountain_tops_no_cull()
{
	a_mountain_ents = getentarray( "mountaintop", "targetname" );
	_a4711 = a_mountain_ents;
	_k4711 = getFirstArrayKey( _a4711 );
	while ( isDefined( _k4711 ) )
	{
		e_mountain = _a4711[ _k4711 ];
		e_mountain setforcenocull();
		_k4711 = getNextArrayKey( _a4711, _k4711 );
	}
}

cheat_reload_stinger_when_not_primary_and_on_horse()
{
	while ( 1 )
	{
		while ( isDefined( level.player.is_on_horse ) && level.player.is_on_horse )
		{
			str_curr_weapon = level.player getcurrentweapon();
			a_str_weapons = level.player getweaponslist();
			_a4728 = a_str_weapons;
			_k4728 = getFirstArrayKey( _a4728 );
			while ( isDefined( _k4728 ) )
			{
				str_weapon = _a4728[ _k4728 ];
				while ( issubstr( str_weapon, "stinger" ) && !issubstr( str_curr_weapon, "stinger" ) && level.player getweaponammoclip( str_weapon ) == 0 && level.player getweaponammostock( str_weapon ) > 0 )
				{
					level.player setweaponammoclip( str_weapon, weaponclipsize( str_weapon ) );
					level.player setweaponammostock( str_weapon, level.player getweaponammostock( str_weapon ) - 1 );
					while ( level.player getcurrentweapon() == str_curr_weapon )
					{
						wait 0,5;
					}
				}
				_k4728 = getNextArrayKey( _a4728, _k4728 );
			}
		}
		wait 0,1;
	}
}

_ammo_refill_horse_think()
{
	self endon( "disable_ammo_cache" );
	t_ammo_cache = self maps/_ammo_refill::_get_closest_ammo_trigger();
	t_ammo_cache_horse = spawn( "trigger_radius", t_ammo_cache.origin, 0, 288, 512 );
	while ( 1 )
	{
		t_ammo_cache_horse waittill( "trigger", e_guy );
		while ( isplayer( e_guy ) && isDefined( e_guy.is_on_horse ) && e_guy.is_on_horse )
		{
			b_refilled_ammo = 0;
			a_str_weapons = e_guy getweaponslist();
			_a4765 = a_str_weapons;
			_k4765 = getFirstArrayKey( _a4765 );
			while ( isDefined( _k4765 ) )
			{
				str_weapon = _a4765[ _k4765 ];
				if ( !maps/_ammo_refill::_is_banned_refill_weapon( str_weapon ) )
				{
					if ( e_guy getfractionmaxammo( str_weapon ) != 1 || str_weapon == level.player getcurrentweapon() && e_guy getcurrentweaponclipammo() != weaponclipsize( str_weapon ) )
					{
						e_guy givemaxammo( str_weapon );
						e_guy setweaponammoclip( str_weapon, weaponclipsize( str_weapon ) );
						b_refilled_ammo = 1;
						break;
					}
					else
					{
/#
						iprintln( "Horse: Ammo FULL" );
#/
					}
				}
				_k4765 = getNextArrayKey( _a4765, _k4765 );
			}
			if ( b_refilled_ammo )
			{
				e_guy playsound( "fly_ammo_crate_refill_fast" );
/#
				iprintln( "Horse: Ammo Refilled" );
#/
			}
			while ( e_guy istouching( t_ammo_cache_horse ) )
			{
				wait 0,05;
			}
		}
	}
}

player_shrug_off_horse( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime )
{
	if ( isDefined( einflictor.vehicletype ) && einflictor.vehicletype != "horse_player" && einflictor.vehicletype != "horse" || einflictor.vehicletype == "horse_player_low" && einflictor.vehicletype == "horse_low" )
	{
		return 1;
	}
	return 0;
}

player_wakes_up_afghan()
{
/#
	assert( isplayer( self ), "player_wakes_up can only be used on players!" );
#/
	self shellshock( "death", 12 );
	self screen_fade_out( 0 );
	wait 0,2;
	self playrumbleonentity( "damage_light" );
	wait 0,4;
	self playrumbleonentity( "damage_light" );
	self screen_fade_to_alpha_with_blur( 0,35, 2, 0 );
	wait 1,9;
	self screen_fade_to_alpha_with_blur( 0,6, 0,85, 0 );
	self playrumbleonentity( "damage_light" );
	wait 0,15;
	self screen_fade_to_alpha_with_blur( 0, 0,85, 0 );
	level waittill( "kicked_in_the_face" );
	self screen_fade_to_alpha_with_blur( 0,2, 2, 0,5 );
	self screen_fade_to_alpha_with_blur( 0, 2, 0 );
}

add_lui_vehicle_icon()
{
	if ( !isDefined( self.vehicletype ) )
	{
		return;
	}
	switch( self.vehicletype )
	{
		case "heli_hind_afghan":
			vehicle_type = 1;
			break;
		case "apc_btr60":
		case "tank_t62":
			vehicle_type = 2;
			break;
	}
	if ( isDefined( vehicle_type ) )
	{
		luinotifyevent( &"hud_afghan_add_vehicle_icon", 2, self getentitynumber(), vehicle_type );
	}
}

remove_lui_vehicle_icon()
{
	luinotifyevent( &"hud_afghan_remove_vehicle_icon", 1, self getentitynumber() );
}

update_lui_ammo_icon( should_not_remove, origin )
{
	if ( !isDefined( should_not_remove ) )
	{
		should_not_remove = 0;
	}
	if ( should_not_remove )
	{
		luinotifyevent( &"hud_afghan_update_ammo", 3, int( origin[ 0 ] ), int( origin[ 1 ] ), int( origin[ 2 ] ) );
	}
	else
	{
		luinotifyevent( &"hud_afghan_update_ammo" );
	}
}

update_lui_rpg_icon( should_not_remove, origin )
{
	if ( !isDefined( should_not_remove ) )
	{
		should_not_remove = 0;
	}
	if ( should_not_remove )
	{
		luinotifyevent( &"hud_afghan_update_rpg", 3, int( origin[ 0 ] ), int( origin[ 1 ] ), int( origin[ 2 ] ) + 8 );
	}
	else
	{
		luinotifyevent( &"hud_afghan_update_rpg" );
	}
}

play_battle_convo( str_team, a_str_aliases, a_delays, str_exit_early )
{
	if ( !isDefined( a_delays ) )
	{
		a_delays = [];
	}
	if ( isDefined( str_exit_early ) )
	{
		level endon( str_exit_early );
	}
	a_speakers = [];
	i = 0;
	while ( i < a_str_aliases.size )
	{
		a_guys = getaiarray( str_team );
		arrayremovevalue( a_guys, level.zhao );
		arrayremovevalue( a_guys, level.woods );
		_a4927 = a_speakers;
		_k4927 = getFirstArrayKey( _a4927 );
		while ( isDefined( _k4927 ) )
		{
			speaker = _a4927[ _k4927 ];
			arrayremovevalue( a_guys, speaker, 0 );
			_k4927 = getNextArrayKey( _a4927, _k4927 );
		}
		if ( a_guys.size == 0 )
		{
			return;
		}
		speaker = a_guys[ 0 ];
		a_speakers[ a_speakers.size ] = speaker;
		speaker say_dialog( a_str_aliases[ i ] );
		if ( isDefined( a_delays[ i ] ) )
		{
			wait a_delays[ i ];
		}
		i++;
	}
}

play_battle_convo_until_flag( str_team, a_str_aliases, min_delay, max_delay, str_flag )
{
	level endon( str_flag );
	while ( !flag( str_flag ) )
	{
		a_speakers = [];
		a_str_aliases = array_randomize( a_str_aliases );
		i = 0;
		while ( i < a_str_aliases.size )
		{
			a_guys = getaiarray( str_team );
			arrayremovevalue( a_guys, level.zhao );
			arrayremovevalue( a_guys, level.woods );
			_a4977 = a_speakers;
			_k4977 = getFirstArrayKey( _a4977 );
			while ( isDefined( _k4977 ) )
			{
				speaker = _a4977[ _k4977 ];
				arrayremovevalue( a_guys, speaker, 0 );
				_k4977 = getNextArrayKey( _a4977, _k4977 );
			}
			if ( a_guys.size == 0 )
			{
				wait 1;
				i++;
				continue;
			}
			else
			{
				speaker = a_guys[ 0 ];
				a_speakers[ a_speakers.size ] = speaker;
				speaker say_dialog( a_str_aliases[ i ] );
				wait randomfloatrange( min_delay, max_delay );
			}
			i++;
		}
	}
}

vo_muj_in_arena()
{
	a_vo = array( "muj2_hiyeeah_0", "muj2_yaaa_0", "muj2_battle_cry_0", "muj3_die_infidel_0", "muj3_send_a_runner_for_mo_0", "muj3_i_need_more_kalashni_0", "muj3_they_have_underestim_1", "muj3_make_them_pay_for_th_0", "muj3_oh_russian_dragon_0", "muj3_hiyeeah_0", "muj3_yaaa_0", "muj3_uraah_0", "muj3_screaming_0", "muj3_battle_cry_0", "muj2_infidels_coming_thro_0", "muj2_coward_dog_shot_dow_0", "muj2_enemy_killed_0", "muj2_let_rahmaan_know_we_0", "muj0_enemy_killed_0", "muj0_use_the_machinegun_o_0", "muj0_hiyeeah_0", "muj0_yaaa_0", "muj0_uraah_0", "muj0_screaming_0", "muj0_battle_cry_0", "muj1_do_not_fear_death_e_0", "muj1_we_cannot_stand_agai_0", "muj1_our_defenses_are_hol_0", "muj1_no_one_can_conquer_a_0", "muj1_hiyeeah_0", "muj1_hiyeeah_0", "muj1_yaaa_0", "muj1_screaming_0", "muj1_battle_cry_0" );
	n_delay_min = 3;
	n_delay_max = 15;
	level thread play_battle_convo_until_flag( "allies", a_vo, n_delay_min, n_delay_max, "bp3_infantry_event" );
}

vo_russians_in_arena()
{
	a_vo = array( "ru0_mujahideen_inbound_0", "ru3_hold_the_line_0", "ru0_they_re_pushing_thro_0", "ru2_spread_out_0", "ru2_take_out_the_guy_wit_0", "ru1_move_up_0", "ru1_push_into_the_valley_0", "ru2_stay_with_the_tanks_0", "ru3_here_they_come_0", "ru0_mujahideen_are_dug_i_0", "ru2_take_their_ammo_cach_0", "ru2_we_need_reinforcemen_0", "ru0_push_forward_to_the_0", "ru2_they_re_not_retreati_0", "ru3_keep_fighting_0" );
	n_delay_min = 3;
	n_delay_max = 15;
	level thread play_battle_convo_until_flag( "axis", a_vo, n_delay_min, n_delay_max, "bp3_infantry_event" );
}

vo_bp1_player_enters_blocking_point()
{
	a_vo = array( "ru0_mujahideen_inbound_0", "ru1_get_in_cover_0", "ru2_take_defensive_posit_0", "ru3_hold_the_line_0" );
	a_delay = array( 1, 1,5, 4 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_player_pushed_into_blocking_point()
{
	a_vo = array( "ru0_they_re_pushing_thro_0", "ru1_get_men_on_top_of_th_0", "ru2_spread_out_0", "ru3_hold_them_at_the_eas_0", "ru0_don_t_let_them_gain_0", "ru2_we_need_armor_suppor_0" );
	a_delay = array( 2, 1,5, 3, 2, 5 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_rpg_shot()
{
	a_vo = array( "ru3_rpg_0", "ru0_take_out_those_rpgs_0" );
	a_delay = array( 0,5 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_player_at_ammo_cache()
{
	a_vo = array( "ru1_stinger_missile_0", "ru2_take_out_the_guy_wit_0", "ru3_up_high_0", "ru0_hiding_inside_the_ru_0" );
	a_delay = array( 1,5, 0,5, 4 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_btr1_spawn()
{
	a_vo = array( "ru1_don_t_let_them_reach_0", "ru2_bring_in_the_btrs_0" );
	a_delay = array( 0,05 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_btr1_dead()
{
	wait 1;
	a_vo = array( "ru3_they_took_out_one_of_0" );
	a_delay = array( 0,05 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}

vo_bp1_btr2_dead()
{
	wait 1;
	a_vo = array( "ru0_we_lost_the_other_bt_0" );
	a_delay = array( 0,05 );
	level thread play_battle_convo( "axis", a_vo, a_delay );
}
