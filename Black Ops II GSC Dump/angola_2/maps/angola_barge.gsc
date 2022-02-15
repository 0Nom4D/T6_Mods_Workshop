#include maps/_audio;
#include maps/_turret;
#include maps/createart/angola_art;
#include maps/angola_river;
#include maps/_anim;
#include maps/_music;
#include animscripts/utility;
#include maps/angola_2_util;
#include maps/_vehicle;
#include maps/_objectives;
#include maps/_scene;
#include maps/_dialog;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

init_flags()
{
	flag_init( "first_barge_ai_dead" );
	flag_init( "first_gunboat_dead" );
	flag_init( "waves_done" );
	flag_init( "barge_defend_done" );
	flag_init( "hind_crash" );
	flag_init( "river_done" );
	flag_init( "ammo_cache_obj_kill" );
	flag_init( "tow_missile_not_fired" );
	flag_set( "tow_missile_not_fired" );
	flag_init( "hind_special_action_running" );
	flag_set( "hind_special_action_running" );
	level.dontdropaiclips = 1;
	setsaveddvar( "ragdoll_max_life", "3000" );
}

teleport_player_to_location( targetname )
{
	wait_for_first_player();
	players = get_players();
	node = getnode( targetname, "targetname" );
	players[ 0 ] setorigin( node.origin );
	players[ 0 ] setplayerangles( node.angles );
}

teleport_hudson_to_location( targetname )
{
	level.hudson = init_hero( "hudson" );
	node = getnode( targetname, "targetname" );
	level.hudson forceteleport( node.origin, node.angles );
}

skipto_container()
{
	init_flags();
	flag_init( "barge_knockoff_started" );
	load_gump( "angola_2_gump_river" );
	maps/angola_river::init_heroes();
	level.woods = init_hero( "woods" );
	maps/angola_river::setup_level();
	maps/angola_river::setup_main_barge();
	wait 0,05;
	teleport_player_to_location( "player_barge_teleport" );
	teleport_hudson_to_location( "hudson_barge_teleport" );
	cleanup_river_intro_boats();
	visionsetnaked( "sp_angola_2_river", 0,5 );
	level.barge_spawners = [];
	level.barge_spawners[ 0 ] = getent( "river_barge_convoy_2_guards_assault", "targetname" );
	level.barge_spawners[ 1 ] = getent( "river_barge_convoy_2_guards_assault", "targetname" );
	level thread maps/angola_river::clean_up_barge_ents();
	level thread barge_defend_setup();
	flag_set( "hudson_container_approach_done" );
}

skipto_barge_defend()
{
	load_gump( "angola_2_gump_river" );
	flag_init( "barge_knockoff_started" );
	maps/angola_river::setup_level();
	maps/angola_river::setup_main_barge();
	level.main_barge setspeed( 30 );
	maps/angola_river::init_heroes();
	level.woods = init_hero( "woods" );
	wait 0,05;
	teleport_player_to_location( "player_barge_teleport" );
	teleport_hudson_to_location( "hudson_barge_teleport" );
}

barge_defend_main()
{
	level notify( "barge_defend_start" );
	barge_defend_setup();
	init_flags();
	barge_defend_attack_boats_think();
	level notify( "boat_convoy_section_finished" );
	flag_set( "barge_defend_done" );
}

container_main()
{
	level thread voice_over_barge();
	level.player thread maps/createart/angola_art::river_barge();
	find_woods();
	hind_fight();
	river_finale();
	container_cleanup();
	flag_wait( "river_done" );
}

barge_defend_setup()
{
	level thread barge_barrel_topple_watch();
	level thread barge_knockoff_watch();
}

barge_defend_attack_boats_think()
{
	level.challenge_escort_boat_destroy = 1;
	_a155 = level.boat_convoy;
	_k155 = getFirstArrayKey( _a155 );
	while ( isDefined( _k155 ) )
	{
		vh_boat = _a155[ _k155 ];
		vh_boat thread convoy_boat_speed_think();
		_k155 = getNextArrayKey( _a155, _k155 );
	}
	_a159 = level.boat_convoy_small;
	_k159 = getFirstArrayKey( _a159 );
	while ( isDefined( _k159 ) )
	{
		vh_boat = _a159[ _k159 ];
		vh_boat thread convoy_boat_speed_think();
		_k159 = getNextArrayKey( _a159, _k159 );
	}
	boat_wave_1();
	flag_set( "waves_done" );
	a_ai = getaiarray( "axis" );
	while ( a_ai.size > 0 )
	{
		_a173 = a_ai;
		_k173 = getFirstArrayKey( _a173 );
		while ( isDefined( _k173 ) )
		{
			ai_guy = _a173[ _k173 ];
			if ( distance2dsquared( ai_guy.origin, level.main_barge.origin ) > 1000000 )
			{
				ai_guy delete();
			}
			_k173 = getNextArrayKey( _a173, _k173 );
		}
		wait 1;
		a_ai = getaiarray( "axis" );
	}
}

determine_convoy_spawn_points()
{
	level endon( "boat_convoy_section_finished" );
	index = 1;
	level.spawn_boat_trigger = getent( "trigger_spawner_boats_1", "targetname" );
	while ( 1 )
	{
		level.spawn_boat_trigger = trigger_wait( "trigger_spawner_boats_" + index );
		index++;
		if ( index == 10 )
		{
			index = 0;
		}
	}
}

convoy_boat_speed_think()
{
	self endon( "goto_barge" );
	self endon( "death" );
	self endon( "delete" );
	self veh_magic_bullet_shield( 1 );
	self.leave_convoy = 0;
	n_current_speed = 30;
	n_change_speed_timer = 0;
	time_between_switching_speed = randomfloatrange( 3, 6 );
	while ( !self.leave_convoy )
	{
		n_dist_sq = distancesquared( level.main_barge.origin, self.origin );
		if ( n_dist_sq < 42250000 )
		{
			self setspeed( 20 );
			n_current_speed = 20;
		}
		else if ( n_dist_sq > 100000000 )
		{
			self setspeed( 90 );
			n_current_speed = 40;
		}
		else if ( n_dist_sq > 72250000 )
		{
			self setspeed( 40 );
			n_current_speed = 40;
		}
		else
		{
			self setspeed( n_current_speed );
		}
		if ( n_change_speed_timer > time_between_switching_speed )
		{
			n_current_speed = randomfloatrange( 25, 35 );
			n_change_speed_timer = 0;
			time_between_switching_speed = randomfloatrange( 3, 6 );
		}
		wait 0,5;
		n_change_speed_timer += 0,5;
	}
}

barge_defend_wait_for_ai_dead()
{
	level thread barge_fight_hudson();
	wait 1;
	while ( 1 )
	{
		enemies = getaiarray( "axis" );
		i = 0;
		while ( i < enemies.size )
		{
			if ( distance2dsquared( enemies[ i ].origin, level.main_barge.origin ) > 64000000 )
			{
				enemies[ i ] die();
			}
			i++;
		}
		if ( enemies.size == 0 )
		{
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}

barge_fight_hudson()
{
	hudson_cover = getnode( "hudson_cover", "targetname" );
	level.hudson.goalradius = 64;
	level.hudson.fixednode = 0;
	level.hudson setgoalnode( hudson_cover );
	level.main_barge setspeed( 30 );
}

barge_clear_the_deck()
{
	a_ai = getentarray( "barge_intro_ai", "script_noteworthy" );
	a_ai = array_removedead( a_ai );
	wait 0,1;
	flag_set( "first_barge_ai_dead" );
}

first_gunboat_attack()
{
	small_boat_attack_barge( "right", 1, 0 );
	flag_set( "first_gunboat_dead" );
}

boat_wave_1_hudson_vo()
{
	level endon( "start_hudson_mg_vo" );
	level.hudson say_dialog( "huds_the_deck_s_clear_0" );
	wait 2;
	level.hudson say_dialog( "huds_we_got_a_lot_of_gunb_0" );
	level.hudson say_dialog( "huds_it_ain_t_over_yet_1" );
}

boat_wave_1_hudson_mg_vo()
{
	level notify( "start_hudson_mg_vo" );
	level.hudson say_dialog( "huds_they_re_coming_along_0" );
	level.hudson say_dialog( "huds_stay_on_em_0" );
	level.hudson say_dialog( "huds_get_on_the_rear_gun_0" );
}

boat_wave_1()
{
	level.a_barge_attacker = [];
	wait 2;
	level thread first_gunboat_attack();
	level thread barge_clear_the_deck();
	level waittill_either( "first_barge_ai_dead", "first_gunboat_dead" );
	if ( !flag( "first_gunboat_dead" ) )
	{
		level thread boat_wave_1_hudson_vo();
		e_turret = getent( "barge_turret_right", "script_noteworthy" );
		e_turret.use_obj_offset = vectorScale( ( 0, 0, 0 ), 72 );
		set_objective( level.obj_secure_the_barge, e_turret, "use" );
		flag_wait( "first_gunboat_dead" );
		set_objective( level.obj_secure_the_barge, undefined, "reactivate" );
	}
	level thread boat_wave_1_hudson_mg_vo();
	level thread boat_board_barge( "frontright", level.boat_convoy[ 0 ], 1, 0 );
	wait 5;
	level thread boat_board_barge( "left", level.boat_convoy[ 0 ], 1, 0 );
	autosave_by_name( "boat_group_1" );
	wait_time_or_boats_defeated( 20 );
	level thread small_boat_attack_barge( "right", 0 );
	wait 5;
	level thread boat_board_barge( "frontleft", level.boat_convoy[ 0 ] );
	autosave_by_name( "boat_group_3" );
	wait_time_or_boats_defeated( 20 );
	level thread boat_board_barge( "right", level.boat_convoy[ 0 ], 0 );
	wait 5;
	boat_board_barge( "left", level.boat_convoy[ 0 ], 0 );
}

wait_time_or_boats_defeated( n_time )
{
	n_timer = getTime() + ( n_time * 1000 );
	while ( !level.a_barge_attacker.size )
	{
		wait 0,05;
	}
	while ( getTime() < n_timer )
	{
		if ( !level.a_barge_attacker.size )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	wait 1;
	level.a_barge_attacker = [];
}

add_boat_to_attack_array()
{
	level.a_barge_attacker[ level.a_barge_attacker.size ] = self;
	self waittill_either( "death", "delete" );
	arrayremovevalue( level.a_barge_attacker, self );
}

boat_board_barge( str_board_location, vh_enemy_boat, is_replaced, is_called_out )
{
	if ( !isDefined( is_replaced ) )
	{
		is_replaced = 1;
	}
	if ( !isDefined( is_called_out ) )
	{
		is_called_out = 1;
	}
	vh_enemy_boat endon( "death" );
	vh_enemy_boat endon( "delete" );
	arrayremovevalue( level.boat_convoy, vh_enemy_boat );
	if ( is_replaced )
	{
		vh_enemy_boat boat_replace_when_boarding( "mediumboat_01" );
	}
	vh_enemy_boat thread add_boat_to_attack_array();
	level thread boat_board_barge_and_unload( str_board_location, vh_enemy_boat, is_replaced, is_called_out );
	vh_enemy_boat waittill_any( "finished_boarding", "driver_dead" );
	vh_enemy_boat unlink();
	vh_enemy_boat boat_board_fallback( str_board_location );
	vh_enemy_boat = undefined;
}

boat_board_barge_and_unload( str_board_location, vh_enemy_boat, is_replaced, is_called_out )
{
	if ( !isDefined( vh_enemy_boat ) )
	{
		vh_enemy_boat = undefined;
	}
	if ( !isDefined( is_replaced ) )
	{
		is_replaced = 1;
	}
	if ( !isDefined( is_called_out ) )
	{
		is_called_out = 1;
	}
	vh_enemy_boat endon( "death" );
	vh_enemy_boat endon( "delete" );
	vh_enemy_boat endon( "driver_dead" );
	str_boat_boarding_anim = "enemy_boat_ram_barge_" + str_board_location;
	str_boat_boarding_anim_idle = "enemy_ramming_boat_idle_" + str_board_location;
	vh_enemy_boat boarding_boat_setup( str_board_location );
	vh_enemy_boat thread boarding_boat_ai_think( str_board_location );
	if ( is_called_out )
	{
		level thread boat_approach_hudson_vo( str_board_location );
	}
	vh_enemy_boat boarding_boat_wait_until_at_barge( str_board_location );
	vh_enemy_boat linkto( level.main_barge, "tag_origin" );
	vh_enemy_boat thread unlink_from_barge_if_animating_on_death( str_board_location );
	vh_enemy_boat boarding_boat_spawn_ai( str_board_location, 2 );
	level.main_barge anim_single_aligned( vh_enemy_boat, str_boat_boarding_anim, "tag_origin", undefined, 1 );
	if ( vh_enemy_boat.health > 250 )
	{
		level thread boarding_vo();
		vh_enemy_boat notify( "boarding_done" );
		vh_enemy_boat.targetname = undefined;
		vh_enemy_boat.animname = undefined;
		vh_enemy_boat notify( "done_animating" );
		if ( issubstr( str_board_location, "front" ) )
		{
			array_delete( vh_enemy_boat.gunner );
			wait 10;
			boat_board_barge_spawn_additional_ai( str_board_location, 1 );
		}
		vh_enemy_boat setspeed( 30, 20, 20 );
		wait 2;
		vh_enemy_boat notify( "finished_boarding" );
	}
}

boarding_boat_ai_think( str_board_location )
{
	self endon( "delete" );
	self endon( "death" );
	if ( issubstr( str_board_location, "left" ) )
	{
	}
	else
	{
	}
	str_side = "right";
	str_animname = "enemy_ai_" + str_side + "_";
	a_ai = [];
	i = 0;
	while ( i < 2 )
	{
		ai_guy = spawn_barge_ai();
		ai_guy.animname = str_animname + string( i );
		v_origin = getstartorigin( self.origin, self.angles, level.scr_anim[ ai_guy.animname ][ "board_idle" ][ 0 ] );
		v_angles = getstartangles( self.origin, self.angles, level.scr_anim[ ai_guy.animname ][ "board_idle" ][ 0 ] );
		ai_guy forceteleport( v_origin, v_angles );
		ai_guy linkto( self );
		ai_guy.allowdeath = 1;
		ai_guy thread kill_if_my_boat_dies( self );
		a_ai[ a_ai.size ] = ai_guy;
		i++;
	}
	self thread anim_loop_aligned( a_ai, "board_idle", "tag_origin", "done_animating" );
	self waittill_either( "done_animating", "at_barge_front" );
	a_ai = array_removedead( a_ai );
	level thread boarding_boat_ai_animate( a_ai, str_board_location );
}

boarding_boat_ai_animate( a_ai, str_board_location )
{
	nd_goto = getnodearray( "top_goto_pos", "targetname" )[ 0 ];
	_a545 = a_ai;
	_k545 = getFirstArrayKey( _a545 );
	while ( isDefined( _k545 ) )
	{
		ai_guy = _a545[ _k545 ];
		ai_guy unlink();
		ai_guy linkto( level.main_barge );
		_k545 = getNextArrayKey( _a545, _k545 );
	}
	level thread boat_board_hudson_vo( str_board_location );
	str_anim = "board_barge_" + str_board_location;
	if ( !issubstr( str_board_location, "front" ) )
	{
		str_anim += "_" + randomint( 2 );
		nd_goto = getnode( "strella_guard_start", "targetname" );
	}
	_a560 = a_ai;
	_k560 = getFirstArrayKey( _a560 );
	while ( isDefined( _k560 ) )
	{
		ai_guy = _a560[ _k560 ];
		level.main_barge thread anim_single_aligned( ai_guy, str_anim, "tag_origin" );
		ai_guy.allowdeath = 1;
		ai_guy setgoalnode( nd_goto );
		_k560 = getNextArrayKey( _a560, _k560 );
	}
	if ( isDefined( a_ai[ 0 ] ) )
	{
		n_waittime = getanimlength( level.scr_anim[ a_ai[ a_ai.size - 1 ].animname ][ str_anim ] );
		wait n_waittime;
	}
	a_ai = array_removedead( a_ai );
	_a575 = a_ai;
	_k575 = getFirstArrayKey( _a575 );
	while ( isDefined( _k575 ) )
	{
		ai_guy = _a575[ _k575 ];
		ai_guy unlink();
		ai_guy setgoalnode( nd_goto );
		_k575 = getNextArrayKey( _a575, _k575 );
	}
}

boat_replace_when_boarding( str_spawner_name )
{
	v_offset = self.v_path_offset;
	if ( !flag( "barge_defend_done" ) )
	{
		vh_boat = maps/angola_river::convoy_boat_spawn( str_spawner_name, v_offset, 1 );
		vh_boat veh_magic_bullet_shield( 1 );
		if ( isDefined( self.death_animation ) )
		{
			vh_boat.death_animation = self.death_animation;
		}
		vh_boat pathfixedoffset( vh_boat.v_path_offset );
		vh_boat thread go_path( getvehiclenode( level.spawn_boat_trigger.target, "targetname" ) );
		vh_boat thread convoy_boat_speed_think();
		if ( str_spawner_name == "smallboat_02" )
		{
			level.boat_convoy_small[ level.boat_convoy_small.size ] = vh_boat;
			return;
		}
		else
		{
			level.boat_convoy[ level.boat_convoy.size ] = vh_boat;
		}
	}
}

boat_board_fallback( str_board_location )
{
	self endon( "death" );
	self endon( "delete" );
	level endon( "boat_convoy_section_finished" );
	goal_set = level.boat_goal_sets[ "med_boat_2" ];
	self setvehicleavoidance( 1, 256, 1 );
	if ( issubstr( self.model, "medium" ) )
	{
		self boat_drive_away_forward();
	}
	else if ( isalive( self.driver ) )
	{
		self boat_drive_away_forward();
	}
	else
	{
		while ( distancesquared( level.main_barge.origin, self.origin ) < 6250000 )
		{
			self setspeed( 1, 20, 20 );
			self cancelaimove();
			self setvehgoalpos( goal_set[ str_board_location ].origin, 0, 0 );
			wait 0,2;
		}
	}
	wait 0,1;
	array_delete( self.gunner );
	self.overridevehicledamage = undefined;
	self dodamage( self.health + 100, self.origin );
}

boat_drive_away_forward()
{
	self setvehicleavoidance( 1, 470, 1 );
	nd_goto = level.main_barge.currentnode;
	i = 0;
	while ( i < 10 )
	{
		nd_current = nd_goto;
		nd_goto = getvehiclenode( nd_current.target, "targetname" );
		i++;
	}
	self cancelaimove();
	self setspeed( 70, 509 );
	self setvehgoalpos( nd_goto.origin, 0, 1 );
	while ( distancesquared( level.main_barge.origin, self.origin ) < 42250000 )
	{
		wait 0,2;
	}
	while ( level.player is_looking_at( self, 0,6, 1 ) )
	{
		wait 0,1;
	}
}

small_boat_attack_barge( str_attack_side, is_replaced, is_called_out )
{
	if ( !isDefined( is_replaced ) )
	{
		is_replaced = 1;
	}
	if ( !isDefined( is_called_out ) )
	{
		is_called_out = 1;
	}
	vh_boat = level.boat_convoy_small[ 0 ];
	vh_boat endon( "delete" );
	vh_boat endon( "death" );
	arrayremovevalue( level.boat_convoy_small, vh_boat );
	vh_boat boarding_boat_setup( "small_boat" );
	m_goal = level.boat_goal_sets[ "med_boat_2" ][ "small_boat" ];
	if ( is_replaced )
	{
		vh_boat boat_replace_when_boarding( "smallboat_02" );
	}
	if ( is_called_out )
	{
		level thread boat_approach_hudson_vo( str_attack_side );
	}
	vh_boat setspeed( 80, 20, 20 );
	vh_boat thread small_boat_unlink_rpg_guy();
	vh_boat setvehicleavoidance( 1, 512, 25 );
	vh_boat cancelaimove();
	while ( !isalive( vh_boat.gunner[ 0 ] ) && isalive( vh_boat.gunner[ 1 ] ) && isalive( vh_boat.driver ) )
	{
		n_dist = distancesquared( m_goal.origin, vh_boat.origin );
		if ( n_dist < 1056784 )
		{
			vh_boat setspeed( 20, 20, 20 );
		}
		else
		{
			if ( n_dist < 20250000 )
			{
				vh_boat setspeed( 50, 20, 20 );
			}
		}
		vh_boat setvehgoalpos( m_goal.origin, 0, 1 );
		wait 0,2;
	}
	if ( isalive( vh_boat ) )
	{
		vh_boat thread boat_board_fallback( str_attack_side );
	}
	level notify( "small_boat_done" );
}

small_boat_unlink_rpg_guy()
{
	self endon( "death" );
	self endon( "delete" );
	self.gunner[ 1 ] endon( "death" );
	while ( distancesquared( level.main_barge.origin, self.origin ) > 4000000 )
	{
		wait 0,1;
	}
	if ( isDefined( self.gunner[ 1 ] ) && isalive( self.gunner[ 1 ] ) )
	{
		self.gunner[ 1 ] unlink();
		self.gunner[ 1 ] shoot_at_target_untill_dead( level.player );
	}
}

boat_approach_hudson_vo( str_board_location )
{
	a_vo = array( "huds_they_re_coming_along_0", "huds_stay_on_em_0", "huds_gun_boats_are_right_0", "huds_you_d_better_throw_e_0", "huds_stay_on_those_damn_g_0", "huds_take_em_out_mason_0" );
	level.hudson say_dialog( random( a_vo ) );
}

boat_board_hudson_vo( str_board_location )
{
	a_vo = array( "huds_dammit_they_re_boa_0", "huds_we_ve_got_mpla_on_bo_0", "huds_stay_on_em_1" );
	if ( issubstr( str_board_location, "front" ) )
	{
		a_vo[ a_vo.size ] = "huds_enemies_on_board_u_0";
	}
	else
	{
		a_vo[ a_vo.size ] = "huds_enemies_on_the_lower_0";
	}
	level.hudson say_dialog( random( a_vo ) );
}

boat_board_barge_spawn_additional_ai( str_board_location, n_spawn_count )
{
	if ( issubstr( str_board_location, "left" ) )
	{
	}
	else
	{
	}
	str_side = "right";
	str_animname = "enemy_ai_" + str_side + "_";
	nd_goto = getnodearray( "top_goto_pos", "targetname" )[ 0 ];
	str_anim = "board_barge_" + str_board_location;
	if ( !issubstr( str_board_location, "front" ) )
	{
		str_anim += "_" + randomint( 2 );
		nd_goto = getnode( "strella_guard_start", "targetname" );
	}
	a_ai = [];
	i = 0;
	while ( i < n_spawn_count )
	{
		ai_guy = spawn_barge_ai();
		ai_guy.animname = str_animname + string( i );
		v_origin = getstartorigin( level.main_barge.origin, level.main_barge.angles, level.scr_anim[ ai_guy.animname ][ str_anim ] );
		v_angles = getstartangles( level.main_barge.origin, level.main_barge.angles, level.scr_anim[ ai_guy.animname ][ str_anim ] );
		ai_guy forceteleport( v_origin, v_angles );
		ai_guy linkto( level.main_barge );
		a_ai[ a_ai.size ] = ai_guy;
		i++;
	}
	level.main_barge anim_single_aligned( a_ai, str_anim, "tag_origin" );
	a_ai = array_removedead( a_ai );
	_a824 = a_ai;
	_k824 = getFirstArrayKey( _a824 );
	while ( isDefined( _k824 ) )
	{
		ai_guy = _a824[ _k824 ];
		ai_guy unlink();
		ai_guy setgoalnode( nd_goto );
		_k824 = getNextArrayKey( _a824, _k824 );
	}
	return a_ai;
}

boarding_boat_setup( str_board_location )
{
	self notify( "goto_barge" );
	self.animname = "boarding_boat";
	self.targetname = "boarding_boat";
	self.supportsanimscripted = 1;
	self.overridevehicledamage = ::boat_damage_override;
	self thread boarding_boat_watch_challenge_death();
	self thread delete_on_death();
	self setvehicleavoidance( 1, 256, 50 );
	self setspeed( 60, 20, 20 );
	self pathfixedoffset( ( 0, 0, 0 ) );
	self veh_magic_bullet_shield( 0 );
	self.leave_convoy = 1;
}

boarding_boat_watch_challenge_death()
{
	self endon( "delete" );
	self waittill( "death", attacker, type, weapon );
	if ( isDefined( weapon ) || weapon == "auto_gun_turret_sp_barge" && isDefined( attacker ) && attacker == level.player )
	{
		level notify( "boarding_boat_death" );
	}
}

boarding_boat_wait_until_at_barge( str_board_location )
{
	str_boarding_anim = "enemy_boat_ram_barge_" + str_board_location;
	str_animname = "boarding_boat";
	while ( distancesquared( getstartorigin( level.main_barge.origin, level.main_barge.angles, level.scr_anim[ str_animname ][ str_boarding_anim ] ), self.origin ) > 160000 )
	{
		v_offset = anglesToForward( level.main_barge.angles ) * 500;
		self setvehgoalpos( getstartorigin( level.main_barge.origin, level.main_barge.angles, level.scr_anim[ str_animname ][ str_boarding_anim ] ) + v_offset, 0, 1 );
		wait 0,2;
	}
}

boarding_boat_wait_until_at_front( str_board_location )
{
	if ( str_board_location == "frontleft" )
	{
	}
	else
	{
	}
	nd_goto1 = level.boat_goal_sets[ "med_boat_2" ][ "right" ];
	nd_goto2 = level.boat_goal_sets[ "med_boat_2" ][ str_board_location ];
	while ( distancesquared( nd_goto1.origin, self.origin ) > 250000 )
	{
		v_offset = anglesToForward( level.main_barge.angles ) * 500;
		self setvehgoalpos( nd_goto1.origin + v_offset, 0, 1 );
		wait 0,2;
	}
	while ( distancesquared( nd_goto2.origin, self.origin ) > 250000 )
	{
		v_offset = anglesToForward( level.main_barge.angles ) * 500;
		self setvehgoalpos( nd_goto2.origin + v_offset, 0, 1 );
		wait 0,2;
	}
	self notify( "at_barge_front" );
}

boarding_boat_spawn_ai( str_side, n_ai_count )
{
	a_guys = [];
	i = 0;
	while ( i < n_ai_count )
	{
		a_guys[ i ] = spawn_barge_ai();
		a_guys[ i ].animname = "enemy_ai_" + str_side + "_" + i;
		a_guys[ i ].targetname = "enemy_ai_" + str_side + "_" + i;
		a_guys[ i ] thread kill_if_my_boat_dies( self );
		a_guys[ i ] setgoalnode( getnode( "strella_guard_start", "targetname" ) );
		a_guys[ i ] thread change_ai_animname_and_targetname_after_anim();
		i++;
	}
	self thread watch_boat_boarding_done( a_guys );
}

watch_boat_boarding_done( a_guys )
{
	self endon( "death" );
	self waittill( "boarding_done" );
	_a920 = a_guys;
	_k920 = getFirstArrayKey( _a920 );
	while ( isDefined( _k920 ) )
	{
		ai_guy = _a920[ _k920 ];
		ai_guy notify( "boat_rider_anim_done" );
		_k920 = getNextArrayKey( _a920, _k920 );
	}
}

spawn_barge_ai_at_node( str_node_spawn, n_count )
{
	nd_spawn = getnode( str_node_spawn, "targetname" );
	a_ai = [];
	i = 0;
	while ( i < n_count )
	{
		ai_guy = spawn_barge_ai();
		ai_guy forceteleport( nd_spawn.origin, ( 0, 0, 0 ) );
		ai_guy setgoalnode( nd_spawn );
		a_ai[ a_ai.size ] = ai_guy;
		wait_network_frame();
		i++;
	}
	return a_ai;
}

spawn_barge_ai()
{
	n_spawner = randomint( 4 );
	ai_guy = simple_spawn_single( "enemy_boat_gunner_" + n_spawner, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	ai_guy.overrideactordamage = ::boat_gunner_damage_override;
	ai_guy.script_accuracy = 0,5;
	ai_guy.dontmelee = 1;
	ai_guy set_goalradius( 1024 );
	return ai_guy;
}

unlink_from_barge_if_animating_on_death( str_board_location )
{
	level endon( "boat_convoy_section_finished" );
	self waittill( "death" );
	self unlink();
	self anim_stopanimscripted( 0,2 );
	if ( self.health > 0 )
	{
		radiusdamage( self.origin, 512, self.health * 2, self.health * 2, level.player );
	}
}

kill_if_my_boat_dies( vh_boat )
{
	self endon( "death" );
	self endon( "delete" );
	vh_boat endon( "boarding_done" );
	self thread watch_boat_death( vh_boat );
	vh_boat waittill_either( "death", "delete" );
	self ragdoll_death();
}

kill_on_boat_death( vh_boat )
{
	self endon( "death" );
	self endon( "delete" );
	vh_boat waittill_either( "death", "delete" );
	self ragdoll_death();
}

watch_boat_death( vh_boat )
{
	self endon( "death" );
	vh_boat endon( "delete" );
	vh_boat waittill( "death" );
	self notify( "my_boat_destroyed" );
}

change_ai_animname_and_targetname_after_anim()
{
	self endon( "death" );
	self endon( "delete" );
	self waittill_either( "boat_rider_anim_done", "my_boat_destroyed" );
	self.targetname = "ram_ai";
	self.animname = "ram_ai";
}

boarding_vo()
{
	if ( !level.boarding_vo_playing )
	{
		level.boarding_vo_playing = 1;
		level.hudson say_dialog( "huds_dammit_they_re_boa_0" );
		level.boarding_vo_playing = 0;
	}
}

barge_barrel_topple_watch()
{
	level endon( "river_done" );
	trigger_wait( "barge_barrel_top_trig" );
	m_parent = getent( "barrel_fxanim_parent", "targetname" );
	m_parent useanimtree( level.scr_animtree[ "barrel_fxanim_parent" ] );
	level.main_barge anim_single_aligned( m_parent, "barge_barrel_topple" );
	m_parent delete();
}

barge_knockoff_watch()
{
	level endon( "barge_defend_done" );
	nd_knockoff = getnode( "barge_knockoff_node", "targetname" );
	m_box = getent( "barge_knockoff_box", "targetname" );
	m_origin = spawn_model( "tag_origin", m_box.origin, m_box.angles );
	m_origin linkto( level.main_barge );
	guy_knocked_off = 0;
	while ( !guy_knocked_off )
	{
		ai_owner = getnodeowner( nd_knockoff );
		if ( isDefined( ai_owner ) && ai_owner != level.hudson )
		{
			ai_owner set_goalradius( 32 );
			ai_owner set_fixednode( 1 );
			ai_owner setgoalnode( nd_knockoff );
			ai_owner waittill_either( "death", "goal" );
			if ( isalive( ai_owner ) )
			{
				flag_set( "barge_knockoff_started" );
				ai_owner thread barge_knockoff_watch_boat_ram();
				ai_owner waittill_either( "death", "boat_rammed" );
				if ( isalive( ai_owner ) )
				{
					ai_owner.animname = "crate_knockoff_guy";
					m_box.animname = "crate_knockoff_crate";
					ai_owner linkto( level.main_barge );
					level thread run_scene( "crate_knockoff" );
					a_models = get_model_or_models_from_scene( "crate_knockoff" );
					_a1084 = a_models;
					_k1084 = getFirstArrayKey( _a1084 );
					while ( isDefined( _k1084 ) )
					{
						m_anim_model = _a1084[ _k1084 ];
						m_anim_model unlink();
						m_anim_model linkto( level.main_barge );
						_k1084 = getNextArrayKey( _a1084, _k1084 );
					}
					scene_wait( "crate_knockoff" );
					m_box solid();
					guy_knocked_off = 1;
				}
			}
		}
		wait 1;
	}
}

barge_knockoff_watch_boat_ram()
{
	self endon( "death" );
	level waittill_either( "gunboat_ram_right", "gunboat_ram_left" );
	self notify( "boat_rammed" );
}

container_cleanup()
{
	a_vehicles = getvehiclearray();
	_a1116 = a_vehicles;
	_k1116 = getFirstArrayKey( _a1116 );
	while ( isDefined( _k1116 ) )
	{
		vh_vehicle = _a1116[ _k1116 ];
		if ( vh_vehicle.model != "veh_t6_sea_gunboat_medium_damaged" || vh_vehicle.model == "veh_t6_sea_gunboat_medium_damaged2" && vh_vehicle.model == "veh_t6_sea_gunboat_small_dead" )
		{
			vh_vehicle.delete_on_death = 1;
			vh_vehicle notify( "death" );
			if ( !isalive( vh_vehicle ) )
			{
				vh_vehicle delete();
			}
		}
		_k1116 = getNextArrayKey( _a1116, _k1116 );
	}
	level.main_barge setmovingplatformenabled( 0 );
	a_barge_model_names = array( "hind_fly_path", "heli_destination_start", "chase_boat_goal", "woods_container", "barge_jumpto_obj_spot", "barge_ammo_obj_spot", "heli_jump_trigger", "woods_container_clip", "side_damage_clip", "rear_damage_clip", "barge_ladder_blocker_origin", "barge_gl_turret", "barge_barrel_top_trig", "crate_clips", "barrel_fxanim_parent", "barge_avoidance_linker", "barge_collectible", "barge_collectible_trig", "barge_ammo_cache", "bargeback_ammo_cache", "intruder_box", "intruder_box_trig", "barge_cover_back" );
	_a1130 = a_barge_model_names;
	_k1130 = getFirstArrayKey( _a1130 );
	while ( isDefined( _k1130 ) )
	{
		str_name = _a1130[ _k1130 ];
		a_ents = getentarray( str_name, "targetname" );
		if ( !a_ents.size )
		{
			a_ents = getentarray( str_name, "script_noteworthy" );
		}
		_a1137 = a_ents;
		_k1137 = getFirstArrayKey( _a1137 );
		while ( isDefined( _k1137 ) )
		{
			ent = _a1137[ _k1137 ];
			ent setmovingplatformenabled( 0 );
			_k1137 = getNextArrayKey( _a1137, _k1137 );
		}
		_k1130 = getNextArrayKey( _a1130, _k1130 );
	}
}

find_woods()
{
	flag_wait( "hudson_container_approach_done" );
	truck = getent( "woods_container", "targetname" );
	woods_trigger = getent( "woods_truck_trigger", "targetname" );
	woods_trigger sethintstring( &"angola_2_open_truck_door" );
	trigger_origin = spawn( "script_model", woods_trigger.origin );
	trigger_origin setmodel( "tag_origin" );
	trigger_origin linkto( level.main_barge );
	autosave_by_name( "angola_find_woods" );
	setmusicstate( "ANGOLA_BARGE_PRE_CONT" );
	level notify( "search_for_woods" );
	set_objective( level.obj_secure_the_barge, undefined, "done" );
	set_objective( level.obj_find_woods, trigger_origin, "use" );
	trigger_wait( "woods_truck_trigger" );
	_a1172 = level.boat_convoy;
	_k1172 = getFirstArrayKey( _a1172 );
	while ( isDefined( _k1172 ) )
	{
		vh_boat = _a1172[ _k1172 ];
		vh_boat.delete_on_death = 1;
		vh_boat notify( "death" );
		if ( !isalive( vh_boat ) )
		{
			vh_boat delete();
		}
		_k1172 = getNextArrayKey( _a1172, _k1172 );
	}
	_a1176 = level.boat_convoy_small;
	_k1176 = getFirstArrayKey( _a1176 );
	while ( isDefined( _k1176 ) )
	{
		vh_boat = _a1176[ _k1176 ];
		vh_boat.delete_on_death = 1;
		vh_boat notify( "death" );
		if ( !isalive( vh_boat ) )
		{
			vh_boat delete();
		}
		_k1176 = getNextArrayKey( _a1176, _k1176 );
	}
	setmusicstate( "ANGOLA_DEAD_BODIES" );
	container = getent( "woods_container", "targetname" );
	tag_origin = container gettagorigin( "tag_animate" );
	tag_angles = container gettagangles( "tag_animate" );
	level.bodies = [];
	if ( is_mature() )
	{
		level.bodies[ 0 ] = spawn_model( "p6_container_dead_bodies_clump01", tag_origin, tag_angles );
		level.bodies[ 0 ] linkto( container, "tag_animate" );
		level.bodies[ 1 ] = spawn_model( "p6_container_dead_bodies_clump02", tag_origin, tag_angles );
		level.bodies[ 1 ] linkto( container, "tag_animate" );
		level.bodies[ 2 ] = spawn_model( "p6_container_dead_bodies_clump03", tag_origin, tag_angles );
		level.bodies[ 2 ] linkto( container, "tag_animate" );
		level.bodies[ 3 ] = spawn_model( "p6_container_dead_bodies_clump04", tag_origin, tag_angles );
		level.bodies[ 3 ] linkto( container, "tag_animate" );
		level.bodies[ 4 ] = spawn_model( "p6_container_dead_bodies_clump05", tag_origin, tag_angles );
		level.bodies[ 4 ] linkto( container, "tag_animate" );
	}
	level.woods = init_hero( "woods" );
	woods_trigger delete();
	set_objective( level.obj_find_woods, undefined, "delete" );
	s_align = getstruct( "container_lighting_align", "targetname" );
	m_align = spawn_model( "tag_origin", s_align.origin, s_align.angles );
	m_align.targetname = "container_lighting_align";
	s_align structdelete();
	level thread set_up_lighting_for_cod();
	end_scene( "hudson_container_loop_novo" );
	end_scene( "hudson_container_loop" );
	level thread run_scene( "container_open" );
	trigger_origin delete();
	level.player enableinvulnerability();
	level clientnotify( "heli_context_switch" );
	level thread container_body_animations();
	level thread run_scene( "container_open" );
	level thread run_scene( "open_woods_container" );
	level thread run_scene( "open_woods_container_p1_lighting" );
	truck play_fx( "fx_ango_container_light", undefined, undefined, "spotlight_off", 1, "tag_flashlight" );
	truck play_fx( "fx_ango_container_dust", undefined, undefined, "spotlight_off", 1, "tag_origin" );
	a_light_targets = array( "hudson_ai", "woods_ai", "player_body_river", "body_1", "body_2" );
	a_light_entities = array( "hudson_lighting_drone", "woods_lighting_drone", "player_lighting_drone", "body_1_lighting_drone", "body_2_lighting_drone" );
	wait 1;
	i = 0;
	while ( i < a_light_targets.size )
	{
		if ( isDefined( getent( a_light_targets[ i ], "targetname" ) ) )
		{
			set_lighting_pair( a_light_targets[ i ], a_light_entities[ i ] );
		}
		i++;
	}
	wait 4;
	container play_fx( "container_bugs", container.origin, container.angles, undefined, 1, "tag_origin" );
	m_back_cover = getent( "barge_cover_farback", "script_noteworthy" );
	m_back_cover delete();
	m_blocker_linker = getentarray( "barge_ladder_blocker_origin", "targetname" );
	m_blocker = getentarray( "barge_ladder_blocker", "targetname" );
	i = 0;
	while ( i < m_blocker_linker.size )
	{
		m_blocker[ i ].origin = m_blocker_linker[ i ].origin;
		m_blocker[ i ].angles = m_blocker_linker[ i ].angles;
		m_blocker[ i ] linkto( m_blocker_linker[ i ] );
		i++;
	}
	scene_wait( "open_woods_container" );
	level thread run_scene( "open_woods_container_p2" );
	level thread run_scene( "open_woods_container_p2_lighting" );
	level clientnotify( "default_fog_bank" );
	level thread container_animations();
	level thread hudson_carry_woods();
	level waittill( "spawn_hind" );
	wait 2;
	level.player thread maps/createart/angola_art::vision_leave_container();
}

container_animations()
{
	run_scene( "container_p2" );
	level thread run_scene( "container_loop" );
}

container_body_animations()
{
	if ( is_mature() )
	{
		level thread run_scene( "container_bodies_body1_p1" );
	}
	level thread run_scene( "container_bodies_body2_p1" );
	wait 1;
	level.container_body1 = getent( "body_1", "targetname" );
	level.container_body2 = getent( "body_2", "targetname" );
	scene_wait( "container_bodies_body2_p1" );
	if ( is_mature() )
	{
		level thread run_scene( "container_bodies_body1_p2" );
	}
	level thread run_scene( "container_bodies_body2_p2" );
}

clear_lighting_for_cod()
{
	level clientnotify( "default_fog_bank" );
	anim_time = getanimlength( %ch_ang_06_02_find_woods_part2_hudson );
	wait ( anim_time - 2 );
	clientnotify( "clear_lighting_entities" );
}

hudson_carry_woods()
{
	scene_wait( "open_woods_container_p2" );
	level thread container_clear_lighting_ents();
	level thread hudson_carry_woods_vo();
	run_scene( "hudson_carry_woods" );
	level thread run_scene( "woods_outside_animations" );
	nd_goto = getnodearray( "hudson_cover", "targetname" );
	level.hudson.fixednode = 0;
	level.hudson setgoalnode( nd_goto[ 0 ] );
}

container_clear_lighting_ents()
{
	a_ents = array( "hudson_ai", "woods_ai" );
	_a1357 = a_ents;
	_k1357 = getFirstArrayKey( _a1357 );
	while ( isDefined( _k1357 ) )
	{
		str_guy = _a1357[ _k1357 ];
		clear_lighting_pair( str_guy );
		_k1357 = getNextArrayKey( _a1357, _k1357 );
	}
	delete_scene_all( "open_woods_container_p1_lighting", 1 );
}

hudson_carry_woods_vo()
{
	level.player say_dialog( "maso_get_woods_to_cover_0" );
	level.hudson say_dialog( "huds_come_on_woods_0" );
	wait 3;
	level.hudson say_dialog( "huds_that_arms_crate_is_a_0" );
}

set_up_lighting_for_cod()
{
	wait 0,05;
	level waittill( "turn_on_lighting" );
	level.player_model = get_model_or_models_from_scene( "open_woods_container", "player_body_river" );
	level clientnotify( "cod_fog_bank" );
}

hind_fight()
{
	start_origin = getent( "heli_destination_start", "targetname" );
	level.river_hind = spawn_vehicle_from_targetname( "river_hind_attack_chopper" );
	level.river_hind.animname = "river_hind";
	level.river_hind.damaged_effect = 0;
	level.river_hind thread veh_magic_bullet_shield( 1 );
	target_set( level.river_hind, vectorScale( ( 0, 0, 0 ), 40 ) );
	level.river_hind.destination_nodes = [];
	level.river_hind.destination_nodes[ 0 ] = getent( "heli_destination_front_left", "targetname" );
	level.river_hind.destination_nodes[ 1 ] = getent( "heli_destination_mid_left", "targetname" );
	level.river_hind.destination_nodes[ 2 ] = getent( "heli_destination_back_left", "targetname" );
	level.river_hind.destination_nodes[ 3 ] = getent( "heli_destination_back_right", "targetname" );
	level.river_hind.destination_nodes[ 4 ] = getent( "heli_destination_mid_right", "targetname" );
	level.river_hind.destination_nodes[ 5 ] = getent( "heli_destination_front_right", "targetname" );
	level.river_hind.side_already_destroyed = 0;
	level.river_hind.b_initial_move_back = 0;
	level.river_hind.get_to_the_back = 0;
	level.river_hind.damage_immunity = 0;
	level.river_hind.at_barge_back = 0;
	level.player_shot_at_hind = 0;
	level.river_hind.player_on_foot_dmg = 0;
	level.river_hind.overridevehicledamage = ::river_hind_damage_override;
	level.river_hind.origin = start_origin.origin;
	level.river_hind.angles = start_origin.angles;
	level.river_hind setspeed( 80 );
	level.river_hind setdefaultpitch( 10 );
	level.river_hind setlookatent( level.player );
	level.river_hind notify( "nodeath_thread" );
	level.river_hind maps/_turret::set_turret_target( level.main_barge, ( 0, 0, 0 ), 1 );
	level.river_hind maps/_turret::set_turret_target( level.main_barge, ( 0, 0, 0 ), 2 );
	level.river_hind thread attack_barge_back_front( 2, 7 );
	level thread spawn_aft_explosion();
	level thread hind_attack_find_tow();
	autosave_by_name( "woods_located" );
	level.main_barge thread rotate_barge();
	level.main_barge setspeed( 15 );
	wait 2;
	level thread play_rumble_on_spinning_barge();
	setmusicstate( "ANGOLA_CHOPPER_ARRIVE" );
	level notify( "engine_dmg_snd" );
	level.river_hind thread run_heli_path_logic();
	level thread destroy_barge_turrets();
	wait 8;
	level.river_hind thread kill_player_on_timeout();
	level.player disableinvulnerability();
	level waittill( "hind_crash" );
	level thread maps/_audio::switch_music_wait( "ANGOLA_CHOPPER_DEAD", 3 );
	level thread maps/_audio::switch_music_wait( "ANGOLA_POST_CHOPPER", 20 );
}

kill_player_on_timeout()
{
	self endon( "death" );
	level endon( "hind_crash" );
	wait 150;
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 40 ), 0 );
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 40 ), 1 );
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 40 ), 2 );
	self thread maps/_turret::fire_turret_for_time( 5, 0 );
	wait 2;
	self thread maps/_turret::fire_turret( 1 );
	self thread maps/_turret::fire_turret( 2 );
	wait 1;
	level.player godoff();
	level.player suicide();
}

river_hind_damage_override( einflictor, eattacker, idamage, idflags, type, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( eattacker != level.player )
	{
		return 0;
	}
	if ( level.river_hind.damage_immunity )
	{
		return 1;
	}
	if ( type != "MOD_EXPLOSIVE" && type != "MOD_PROJECTILE_SPLASH" && type != "MOD_PROJECTILE" && type != "MOD_EXPLOSIVE_SPLASH" && type != "MOD_IMPACT" )
	{
		return 0;
	}
	if ( ( self.health - idamage ) < 3000 )
	{
		level notify( "hind_crash" );
		return 0;
	}
	if ( ( self.health - idamage ) < 4000 && !level.river_hind.damaged_effect )
	{
		level.river_hind.damaged_effect = 1;
		if ( !level.river_hind.at_barge_back )
		{
			level.river_hind.damage_immunity = 1;
		}
		playfxontag( level._effect[ "hind_damage" ], level.river_hind, "tag_wing_r" );
	}
	return idamage;
}

river_finale()
{
	hut_heli = getent( "real_hut_heli", "targetname" );
	hut_heli hide();
	playfxontag( level._effect[ "hind_rotor_damage" ], level.river_hind, "tag_body" );
	playfxontag( level._effect[ "hind_explosion" ], level.river_hind, "tag_origin" );
	set_objective( level.obj_destroy_hind, undefined, "delete" );
	wait 2;
	stop_exploder( 100 );
	wait 0,8;
	earthquake( 0,75, 2, level.player.origin, 128, level.player );
	level.player shellshock( "death", 2 );
	level.player playsound( "exp_river_hind" );
	wait 0,2;
	exploder( 200 );
	level notify( "stop_boat_audio" );
	wait 0,5;
	exploder( 222 );
	flag_set( "hind_crash" );
	flag_set( "ammo_cache_obj_kill" );
	level notify( "hind_crashing" );
	level.woods unlink();
	level.hudson unlink();
	level thread hind_falling_animation();
	level thread run_scene( "player_hind_shell_shock" );
	if ( isDefined( level.player.viewlockedentity ) )
	{
		level.player.viewlockedentity useby( level.player );
	}
	level thread run_scene( "player_knocked_off_turret" );
	level.player playsound( "evt_barge_sandbar" );
	wait 1,5;
	level.hudson thread say_dialog( "huds_dammit_we_ve_run_ag_0" );
	level clientnotify( "aS_on" );
	playfxontag( level._effect[ "barge_sinking" ], level.main_barge, "tag_origin" );
	level thread play_barge_explosion_fx();
	playfxontag( level._effect[ "barge_truck_quarter_explosion" ], level.main_barge, "tag_origin" );
	if ( level.player hasweapon( "m220_tow_sp" ) )
	{
		level.player takeweapon( "m220_tow_sp" );
		weapons = level.player getweaponslist();
		level.player switchtoweapon( weapons[ 1 ] );
	}
	level notify( "fxanim_river_debris_start" );
	level thread barge_sink_sfx();
	level thread run_scene( "barge_sinking_idle" );
	level thread maps/_audio::playsoundatposition_wait( "evt_building_collapse", ( 0, 0, 0 ), 6,3 );
	scene_wait( "player_hind_shell_shock" );
	hut_heli show();
	hut_fxanim = getent( "fxanim_hind_crash", "targetname" );
	hut_fxanim delete();
	level.river_hind delete();
	scene_wait( "player_knocked_off_turret" );
	level thread player_save_woods();
}

hind_falling_animation()
{
	level.river_hind.origin = ( -28400, -5670, 907 );
	level.river_hind.angles = ( 0, 0, 0 );
	level thread run_scene( "hind_crash_on_shore" );
	level.river_hind vehicle_toggle_sounds( 0 );
	time = getanimlength( %fxanim_angola_hind_crash_veh_anim );
	wait ( time - 5 );
	level notify( "fxanim_hind_crash_start" );
	clientnotify( "stop_tow_futz" );
}

run_heli_path_logic()
{
	scene_wait( "open_woods_container_p2" );
	destroy_container();
	wait 3;
	level.river_hind.goal_radius = 300;
	level.river_hind.is_player_control = 0;
	first_location = getent( "heli_destination_housing", "targetname" );
	level.river_hind hind_reach_goal( first_location, 400 );
	level.river_hind thread hind_go_to_position_and_hold( first_location );
	level.river_hind.current_destination = "heli_destination_housing_node";
	level.hudson thread say_dialog( "huds_take_it_down_0" );
	level notify( "player_control_hind" );
	destroy_barge_housing();
	level.hudson say_dialog( "huds_gotta_knock_out_that_0" );
	level notify( "player_control_hind" );
	level.river_hind.damage_immunity = 0;
	level.river_hind.at_barge_back = 1;
	level.river_hind thread veh_magic_bullet_shield( 0 );
	level.river_hind hind_strafe_states_logic();
}

destroy_barge_turrets()
{
	a_turrets = getentarray( "barge_gl_turret", "targetname" );
	_a1694 = a_turrets;
	_k1694 = getFirstArrayKey( _a1694 );
	while ( isDefined( _k1694 ) )
	{
		vh_turret = _a1694[ _k1694 ];
		m_dead_turret = spawn_model( "veh_t6_turret_dshk_dead_no_base", vh_turret.origin, vh_turret.angles );
		m_dead_turret linkto( level.main_barge );
		vh_turret.delete_on_death = 1;
		vh_turret notify( "death" );
		if ( !isalive( vh_turret ) )
		{
			vh_turret delete();
		}
		_k1694 = getNextArrayKey( _a1694, _k1694 );
	}
}

hind_go_to_position_and_hold( destination )
{
	self endon( "death" );
	level endon( "hind_crash" );
	level endon( "player_control_hind" );
	while ( 1 )
	{
		level.river_hind setvehgoalpos( destination.origin, 0 );
		wait 1,8;
	}
}

destroy_barge_housing()
{
	level thread fire_at_player_while_waiting();
	level thread wait_till_player_looking_at_hind();
	level thread wait_for_player_to_hit_housing_trigger();
	level waittill( "destroy_barge_housing" );
	level notify( "hind_starting_special_action" );
	hind_target = getent( "hind_fire_at_housing", "targetname" );
	level.river_hind setlookatent( hind_target );
	level.river_hind maps/_turret::set_turret_target( hind_target, vectorScale( ( 0, 0, 0 ), 30 ), 0 );
	level.river_hind maps/_turret::set_turret_target( hind_target, vectorScale( ( 0, 0, 0 ), 30 ), 1 );
	level.river_hind maps/_turret::set_turret_target( hind_target, vectorScale( ( 0, 0, 0 ), 30 ), 2 );
	wait 1;
	level.river_hind thread maps/_turret::fire_turret_for_time( 5, 0 );
	level.river_hind thread hind_fire_missiles_at_housing();
	wait 1,8;
	level thread spawn_barge_housing_damage_fx();
}

wait_till_player_looking_at_hind()
{
	level endon( "destroy_barge_housing" );
	while ( !level.player is_player_looking_at( level.river_hind.origin, 0,9, 1 ) )
	{
		wait 0,05;
	}
	level notify( "destroy_barge_housing" );
}

hind_fire_missiles_at_housing()
{
	i = 0;
	while ( i < 4 )
	{
		missile = self firegunnerweapon( i % 2 );
		missile thread hind_missiles_impact_on_housing();
		wait 0,5;
		i++;
	}
}

hind_missiles_impact_on_housing()
{
	self waittill( "death" );
	play_fx( "housing_missile_explosion", self.origin );
}

fire_at_player_while_waiting()
{
	level.river_hind endon( "death" );
	level endon( "hind_crashing" );
	level endon( "hind_starting_special_action" );
	level.river_hind setlookatent( level.player );
	level.river_hind maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 0 );
	level.river_hind maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 1 );
	level.river_hind maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 2 );
	pause = 0;
	player_shot_at_timer = 0;
	kill_player_for_delaying = 0;
	while ( 1 )
	{
		if ( pause >= 1,5 )
		{
			pause = 0;
			wait 2,5;
		}
		if ( !level.player_shot_at_hind )
		{
			player_shot_at_timer += 0,05;
			if ( player_shot_at_timer >= 25 || !kill_player_for_delaying && kill_player_for_delaying && player_shot_at_timer >= 1 )
			{
				tag_origin = level.river_hind gettagorigin( "tag_gunner_turret1" );
				magicbullet( "huey_rockets_angola_lockon", tag_origin, level.player.origin, level.river_hind, level.player );
				tag_origin = level.river_hind gettagorigin( "tag_gunner_turret2" );
				magicbullet( "huey_rockets_angola_lockon", tag_origin, level.player.origin, level.river_hind, level.player );
				kill_player_for_delaying = 1;
				player_shot_at_timer = 0;
			}
		}
		level.river_hind thread maps/_turret::fire_turret( 0 );
		wait 0,05;
		pause += 0,05;
	}
}

wait_for_player_to_hit_housing_trigger()
{
	level endon( "destroy_barge_housing" );
	trigger_wait( "tigger_hind_fire_at_housing" );
	level notify( "destroy_barge_housing" );
}

destroy_container()
{
	container = getent( "woods_container", "targetname" );
	container notify( "spotlight_off" );
	level.river_hind setlookatent( container );
	level.river_hind maps/_turret::set_turret_target( container, vectorScale( ( 0, 0, 0 ), 30 ), 0 );
	level.river_hind maps/_turret::set_turret_target( container, vectorScale( ( 0, 0, 0 ), 30 ), 1 );
	level.river_hind maps/_turret::set_turret_target( container, vectorScale( ( 0, 0, 0 ), 30 ), 2 );
	level.river_hind waittill_looking_at_entity( container );
	level.river_hind thread maps/_turret::fire_turret_for_time( 5, 0 );
	level.river_hind thread hind_fire_missiles_at_housing();
	wait 1,8;
	container playsound( "evt_barge_explo_container" );
	level thread spawn_barge_side_damage_fx();
	wait 1;
	level.river_hind setlookatent( level.player );
}

waittill_looking_at_entity( ent )
{
	self endon( "death" );
	self endon( "delete" );
	ent endon( "death" );
	ent endon( "delete" );
	while ( 1 )
	{
		if ( self is_looking_at( ent, 0,8 ) )
		{
			return;
		}
		else
		{
			wait 0,05;
		}
	}
}

hind_strafe_states_logic()
{
	self endon( "death" );
	self endon( "delete" );
	level endon( "hind_crashing" );
	self.current_state = "over_strafe";
	self.node_index = 2;
	self.holding_position = 1;
	self thread hind_strafe_fire();
	while ( 1 )
	{
		switch( level.river_hind.current_state )
		{
			case "side_strafe":
				if ( randomint( 2 ) )
				{
					next_node = self.node_index - 1;
				}
				else
				{
					next_node = self.node_index + 1;
				}
				if ( next_node > 5 )
				{
					next_node = 0;
				}
				else
				{
					if ( next_node < 0 )
					{
						next_node = 5;
					}
				}
				level.river_hind maps/_turret::set_turret_target( level.hudson, vectorScale( ( 0, 0, 0 ), 30 ), 0 );
				level.river_hind thread maps/_turret::fire_turret_for_time( -1, 0 );
				self setlookatent( level.player );
				self hind_reach_goal( self.destination_nodes[ next_node ] );
				level.river_hind thread maps/_turret::stop_turret( 0 );
				self.node_index = next_node;
				level.river_hind.current_state = "over_strafe";
				break;
			case "over_strafe":
				next_node = self.node_index + 3;
				if ( next_node > 5 )
				{
					next_node -= 6;
				}
				level notify( "hind_start_firing" );
				self.holding_position = 0;
				self setlookatent( self.destination_nodes[ next_node ] );
				self hind_reach_goal( self.destination_nodes[ next_node ], 500, vectorScale( ( 0, 0, 0 ), 500 ) );
				self.node_index = next_node;
				level.river_hind.current_state = "side_strafe";
				self setlookatent( level.player );
				break;
		}
		self thread hind_hold_postion( self.destination_nodes[ self.node_index ] );
		self.holding_position = 1;
		wait 4;
		flag_wait( "tow_missile_not_fired" );
		level notify( "player_control_hind" );
	}
}

hind_strafe_fire()
{
	self endon( "death" );
	self endon( "delete" );
	level endon( "hind_crashing" );
	hind_fire_at = spawn_model( "tag_origin" );
	hind_fire_at.origin = ( self.origin + ( anglesToForward( ( self.angles[ 0 ], self.angles[ 1 ], 0 ) ) * 500 ) ) - vectorScale( ( 0, 0, 0 ), 1000 );
	hind_fire_at linkto( self );
	while ( 1 )
	{
		if ( isDefined( self.holding_position ) && self.holding_position )
		{
			level waittill( "hind_start_firing" );
		}
		level.river_hind maps/_turret::set_turret_target( level.player, ( randomintrange( -100, 100 ), randomintrange( -100, 100 ), 0 ), 0 );
		level.river_hind maps/_turret::fire_turret( 0 );
		wait randomfloatrange( 0,05, 0,1 );
	}
}

hind_hold_postion( destination )
{
	self endon( "death" );
	level endon( "hind_crash" );
	level endon( "player_control_hind" );
	while ( 1 )
	{
		level.river_hind setvehgoalpos( destination.origin, 0 );
		wait 0,5;
	}
}

hind_reach_goal( destination, distance, offset )
{
	if ( !isDefined( distance ) )
	{
		distance = 500;
	}
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	self endon( "death" );
	level endon( "hind_crash" );
	level endon( "player_control_hind" );
	while ( 1 )
	{
		if ( distancesquared( self.origin, destination.origin + offset ) < ( distance * distance ) )
		{
			return;
		}
		else
		{
			level.river_hind setvehgoalpos( destination.origin + offset, 0 );
			wait 0,05;
		}
	}
}

fire_on_player_in_sight()
{
	self endon( "death" );
	level endon( "hind_crash" );
	level endon( "player_control_hind" );
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 0 );
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 1 );
	self maps/_turret::set_turret_target( level.player, vectorScale( ( 0, 0, 0 ), 30 ), 2 );
	self thread maps/_turret::fire_turret_for_time( 2, 0 );
	if ( ( ( self.health - 500 ) / 4500 ) < 0,5 )
	{
		self thread maps/_turret::fire_turret( 1 );
		self thread maps/_turret::fire_turret( 2 );
	}
}

woods_hudson_idle()
{
	truck = getent( "woods_container", "targetname" );
	barge = getent( "main_barge", "targetname" );
	level thread run_scene( "woods_truck_flip" );
	playfxontag( level._effect[ "barge_truck_exp" ], truck, "tag_origin" );
	playfxontag( level._effect[ "barge_truck_exp_2" ], barge, "tag_origin" );
	level thread run_scene( "barge_bodies_explosion" );
	playfxontag( level._effect[ "barge_truck_exp_2" ], barge, "tag_origin" );
	wait 8;
}

spawn_barge_housing_damage_fx()
{
	level.main_barge hidepart( "TAG_WHEELHOUSE" );
	level notify( "barge_wheelhouse_destroyed" );
	fake_housing_barge_damage = spawn( "script_model", level.main_barge.origin );
	fake_housing_barge_damage setmodel( "fxanim_angola_barge_wheelhouse_mod" );
	fake_housing_barge_damage.angles = level.main_barge.angles;
	fake_housing_barge_damage.animname = "barge_wheel_house";
	fake_housing_barge_damage linkto( level.main_barge );
	fake_housing_barge_damage playsound( "evt_barge_explo_bridge" );
	cables = getent( "barge_wheel_house_cables", "targetname" );
	cables delete();
	playfxontag( getfx( "barge_wheelhouse_exp" ), fake_housing_barge_damage, "wheelhouse_explode_loc_jnt" );
	level thread run_scene( "wheel_house_explosion" );
	wait 0,1;
	earthquake( 0,6, 1,5, level.player.origin, 2048, level.player );
	scene_wait( "wheel_house_explosion" );
	fake_housing_barge_damage linkto( level.main_barge );
}

spawn_barge_side_damage_fx()
{
	fake_side_barge_damage = spawn( "script_model", level.main_barge.origin );
	fake_side_barge_damage setmodel( "fxanim_angola_barge_side_debris_mod" );
	fake_side_barge_damage.angles = level.main_barge.angles;
	fake_side_barge_damage.animname = "barge_side_damage";
	fake_side_barge_damage linkto( level.main_barge );
	level thread woods_hudson_idle();
	container_clip = getent( "woods_container_clip", "targetname" );
	container_clip delete();
	side_damage_clip = getent( "side_damage_clip", "targetname" );
	side_damage_clip solid();
	level.main_barge hidepart( "TAG_SIDE_DAMAGE" );
	fake_model = spawn( "script_model", level.main_barge gettagorigin( "TAG_SIDE_DAMAGE" ) );
	fake_model setmodel( "veh_t6_sea_barge_side_dmg_destroyed" );
	fake_model.angles = level.main_barge gettagangles( "TAG_SIDE_DAMAGE" );
	fake_model linkto( level.main_barge, "TAG_SIDE_DAMAGE" );
	level thread run_scene( "barge_side_explosion" );
	wait 0,1;
	radiusdamage( fake_model.origin, 1024, level.player.health / 4, level.player.health / 8 );
	if ( distance( fake_model.origin, level.player.origin ) >= 1024 )
	{
		level.player shellshock( "death", 0,5 );
	}
	earthquake( 0,5, 1, fake_model.origin, 1024 );
	scene_wait( "barge_side_explosion" );
	woods_container = getent( "woods_container", "targetname" );
	woods_container delete();
	array_delete( level.bodies );
}

hind_attack_find_tow()
{
	weapon_origin = getent( "launcher_origin", "targetname" );
	a_weapons_list = [];
	a_item_list = getitemarray();
	_a2209 = a_item_list;
	_k2209 = getFirstArrayKey( _a2209 );
	while ( isDefined( _k2209 ) )
	{
		item = _a2209[ _k2209 ];
		if ( issubstr( item.classname, "weapon_" ) )
		{
			if ( distance2dsquared( item.origin, level.main_barge.origin ) < 4194304 )
			{
				item delete();
			}
		}
		_k2209 = getNextArrayKey( _a2209, _k2209 );
	}
	tag_origin_linkto = spawn_model( "t5_weapon_strela_world_obj", weapon_origin.origin, weapon_origin.angles );
	tag_origin_linkto linkto( level.main_barge );
	m_weapon_script_model = spawn( "weapon_m220_tow_sp", weapon_origin.origin, 8 );
	m_weapon_script_model.angles = weapon_origin.angles;
	m_weapon_script_model.targetname = "tow_missile";
	m_weapon_script_model linkto( weapon_origin );
	m_weapon_script_model itemweaponsetammo( 9999, 9999 );
	m_weapon_script_model hide();
	tag_origin_linkto thread delete_obj_when_picked_up();
	set_objective( level.obj_destroy_hind, tag_origin_linkto, "use" );
	level.player thread watch_player_firing_tow_missile();
	level.player thread player_teach_ammo_cache();
	m_tarp = undefined;
	a_tarps = getentarray( "crate_tarps", "targetname" );
	i = 0;
	while ( i < a_tarps.size )
	{
		if ( isDefined( a_tarps[ i ].script_animname ) && a_tarps[ i ].script_animname == "tarp_blowoff" )
		{
			m_tarp = a_tarps[ i ];
		}
		i++;
	}
	anim_origin = spawn_model( "tag_origin", m_tarp.origin, m_tarp.angles );
	anim_origin linkto( level.main_barge );
	anim_origin.targetname = "tarp_flyoff_origin";
	add_scene_properties( "tarp_flyoff", "tarp_flyoff_origin" );
	level thread run_scene( "tarp_flyoff" );
}

monitor_player_has_tow_missile()
{
	level endon( "hind_crash" );
	while ( 1 )
	{
		if ( !level.player hasweapon( "m220_tow_sp" ) )
		{
			level.player giveweapon( "m220_tow_sp" );
			level.player switchtoweapon( "m220_tow_sp" );
		}
		wait 0,1;
	}
}

player_teach_ammo_cache()
{
	out_of_ammo = 0;
	while ( !out_of_ammo )
	{
		a_weapons = level.player getweaponslistprimaries();
		_a2279 = a_weapons;
		_k2279 = getFirstArrayKey( _a2279 );
		while ( isDefined( _k2279 ) )
		{
			weapon = _a2279[ _k2279 ];
			if ( weapon == "m220_tow_sp" && !level.player anyammoforweaponmodes( "m220_tow_sp" ) )
			{
				out_of_ammo = 1;
			}
			_k2279 = getNextArrayKey( _a2279, _k2279 );
		}
		wait 0,05;
	}
	m_jumpto_spot = getent( "barge_ammo_obj_spot", "targetname" );
	m_jumpto_spot.use_obj_offset = ( 0, 0, 0 );
	set_objective( level.obj_refill_ammo, m_jumpto_spot, "AMMO" );
	level thread remove_ammo_marker_on_reload();
	flag_wait( "ammo_cache_obj_kill" );
	wait_network_frame();
	wait_network_frame();
	set_objective( level.obj_refill_ammo, undefined, "delete" );
}

remove_ammo_marker_on_reload()
{
	ammo_refilled = 0;
	while ( !ammo_refilled )
	{
		a_weapons = level.player getweaponslistprimaries();
		_a2309 = a_weapons;
		_k2309 = getFirstArrayKey( _a2309 );
		while ( isDefined( _k2309 ) )
		{
			weapon = _a2309[ _k2309 ];
			if ( weapon == "m220_tow_sp" && level.player anyammoforweaponmodes( "m220_tow_sp" ) )
			{
				ammo_refilled = 1;
			}
			_k2309 = getNextArrayKey( _a2309, _k2309 );
		}
		wait 0,05;
	}
	level notify( "ammo_cache_used" );
	flag_set( "ammo_cache_obj_kill" );
}

delete_obj_when_picked_up()
{
	tow_missile = getent( "tow_missile", "targetname" );
	tow_missile waittill( "trigger" );
	level thread monitor_player_has_tow_missile();
	set_objective( level.obj_destroy_hind, level.river_hind, "destroy" );
	self delete();
}

watch_player_firing_tow_missile()
{
	level.river_hind endon( "death" );
	level.river_hind endon( "delete" );
	self thread tow_missile_instructions();
	self thread watch_player_tow_missile_ads();
	while ( 1 )
	{
		self waittill( "missile_fire", missile, weapon_name );
		flag_clear( "tow_missile_not_fired" );
		if ( weapon_name == "m220_tow_sp" )
		{
			clientnotify( "tow_futz_on" );
			missile thread missile_highlight_on_heli_lookat( level.river_hind );
		}
		level.player godon();
		level.player.health = 100;
		missile thread check_to_release_chaff();
		missile waittill( "death" );
		flag_set( "tow_missile_not_fired" );
		clientnotify( "tow_futz_off" );
		level.player godoff();
		level.player.health = 100;
	}
}

watch_player_tow_missile_ads()
{
	level.river_hind endon( "death" );
	level.river_hind endon( "delete" );
	while ( 1 )
	{
		while ( self playerads() < 0,9 || self getcurrentweapon() != "m220_tow_sp" )
		{
			wait 0,05;
		}
		level.player setclientflag( 10 );
		level.player thread tow_highlight_on_heli_lookat( level.river_hind );
		while ( self playerads() > 0,9 && self getcurrentweapon() == "m220_tow_sp" )
		{
			wait 0,05;
		}
		level.player clearclientflag( 10 );
		level.player notify( "m220_tow_lowered" );
		wait 0,05;
	}
}

tow_highlight_on_heli_lookat( vh_heli )
{
	self endon( "m220_tow_lowered" );
	vh_heli endon( "death" );
	vh_heli endon( "delete" );
	while ( 1 )
	{
		while ( !self is_player_looking_at( vh_heli.origin, 0,95, 1, vh_heli ) )
		{
			wait 0,05;
		}
		self setclientflag( 8 );
		while ( self is_player_looking_at( vh_heli.origin, 0,95, 1, vh_heli ) )
		{
			wait 0,05;
		}
		self clearclientflag( 8 );
		wait 0,05;
	}
}

missile_highlight_on_heli_lookat( vh_heli )
{
	self endon( "delete" );
	self endon( "death" );
	while ( 1 )
	{
		while ( !self is_missile_looking_at( vh_heli.origin, 0,95, 1, vh_heli ) )
		{
			wait 0,05;
		}
		level.player setclientflag( 8 );
		while ( self is_missile_looking_at( vh_heli.origin, 0,95, 1, vh_heli ) )
		{
			wait 0,05;
		}
		level.player clearclientflag( 8 );
		wait 0,05;
	}
}

is_missile_looking_at( origin, dot, do_trace, ignore_ent )
{
	if ( !isDefined( dot ) )
	{
		dot = 0,7;
	}
	if ( !isDefined( do_trace ) )
	{
		do_trace = 1;
	}
	eye = self.origin;
	delta_vec = anglesToForward( vectorToAngle( origin - eye ) );
	view_vec = anglesToForward( self.angles );
	new_dot = vectordot( delta_vec, view_vec );
	if ( new_dot >= dot )
	{
		if ( do_trace )
		{
			return bullettracepassed( origin, eye, 0, ignore_ent );
		}
		else
		{
			return 1;
		}
	}
	return 0;
}

tow_missile_instructions()
{
	b_instructions_given = 0;
	while ( !b_instructions_given )
	{
		self waittill( "missile_fire", missile, weapon_name );
		if ( weapon_name == "m220_tow_sp" )
		{
			b_instructions_given = 1;
			instruction_string = &"ANGOLA_2_TOW_INSTRUCTION";
			if ( level.wiiu )
			{
				controller_type = level.player getcontrollertype();
				if ( controller_type == "remote" )
				{
					instruction_string = &"ANGOLA_2_TOW_INSTRUCTION_WIIU_REMOTE";
				}
			}
			screen_message_create( instruction_string );
			missile waittill( "death" );
			screen_message_delete();
		}
	}
}

check_to_release_chaff()
{
	self endon( "death" );
	self endon( "deleted" );
	while ( distancesquared( level.river_hind.origin, self.origin ) > 4000000 )
	{
		wait 0,05;
	}
	level.river_hind play_fx( "aircraft_flares", level.river_hind.origin, level.river_hind.angles, undefined, 1, "tag_origin" );
}

attack_barge_back_front( missile_fire_time, gun_firing_time )
{
	level notify( "start_attack_run" );
	level endon( "start_attack_run" );
	wait 0,5;
	self thread maps/_turret::fire_turret_for_time( gun_firing_time, 0 );
	i = 0;
	while ( i < 4 )
	{
		missile = self firegunnerweapon( i % 2 );
		missile thread missile_death_earthquake();
		wait 0,5;
		i++;
	}
}

missile_death_earthquake()
{
	self waittill( "death" );
	earthquake( 0,5, 1,5, level.player.origin, 128, level.player );
}

cleanup_river_intro_boats()
{
	e_trash = getentarray( "river_boat_intro_cleanup", "script_noteworthy" );
	i = 0;
	while ( i < e_trash.size )
	{
		e_trash[ i ] die();
		if ( isDefined( e_trash[ i ] ) )
		{
			e_trash[ i ] delete();
		}
		i++;
	}
	e_trash = getentarray( "river_boat_cleanup", "script_noteworthy" );
	i = 0;
	while ( i < e_trash.size )
	{
		e_trash[ i ] notify( "death" );
		e_trash[ i ] delete();
		i++;
	}
	e_trash = getentarray( "river_boats_lance_cleanup", "script_noteworthy" );
	i = 0;
	while ( i < e_trash.size )
	{
		e_trash[ i ] notify( "death" );
		e_trash[ i ] delete();
		i++;
	}
}

align_swim_to_anim()
{
	self endon( "death" );
	self endon( "stop_align" );
	swim_pos = getent( "swim_start", "targetname" );
	while ( 1 )
	{
		swim_pos.origin = self.origin;
		swim_pos.angles = self.angles;
		wait 0,05;
	}
}

player_save_woods()
{
	player_clip = getentarray( "barge_player_clip", "targetname" );
	array_delete( player_clip );
	level thread set_water_dvars_swim();
	level thread play_water_fx_on_everyone();
	level thread run_scene( "player_swim_to_shore" );
	run_scene_first_frame( "j_stealth_player_picks_up_woods_hudson_watches" );
	level.m_player_rig = get_model_or_models_from_scene( "player_swim_to_shore", "player_body_river" );
	level.ai_woods = get_ais_from_scene( "player_swim_to_shore", "woods" );
	level.m_player_rig thread align_swim_to_anim();
	scene_wait( "player_swim_to_shore" );
	level thread run_scene( "hudson_idle_on_shore" );
	level thread clean_up_enemy_ai();
	clearallcorpses();
	swim_mechanic();
	flag_set( "river_done" );
	stop_exploder( 222 );
	stop_exploder( 200 );
	clientnotify( "imp_context_reset" );
}

clean_up_enemy_ai()
{
	axis_array = getaiarray( "axis" );
	array_delete( axis_array );
}

swim_mechanic()
{
	playing_backstroke = 0;
	playing_idle = 1;
	level.m_player_rig notify( "stop_align" );
	swim_pos = getent( "swim_start", "targetname" );
	swim_end = getstruct( "swim_end", "targetname" );
	swim_end.origin = get_scene_start_pos( "j_stealth_player_picks_up_woods", "player_body_river" );
	swim_end.angles = get_scene_start_angles( "j_stealth_player_picks_up_woods", "player_body_river" );
	diff_org = level.m_player_rig.origin - get_scene_start_pos( "player_idle_swim", "player_body_river" );
	diff_ang = level.m_player_rig.angles - get_scene_start_angles( "player_idle_swim", "player_body_river" );
	time = 15;
	level.player setwaterdrops( 25 );
	level thread run_scene( "player_idle_swim" );
	wait 0,05;
	screen_message_create( &"ANGOLA_2_SWIMMING" );
	b_message_up = 1;
	player_model = get_model_or_models_from_scene( "player_idle_swim", "player_body_river" );
	player_model play_fx( "player_wake", player_model.origin + vectorScale( ( 0, 0, 0 ), 44 ), player_model.angles, "delete_wake", 1 );
	level notify( "save_woods_swim_started" );
	while ( time > 0 )
	{
		input = level.player getnormalizedmovement();
		if ( input[ 0 ] < 0 && !playing_backstroke )
		{
			swim_pos moveto( swim_end.origin, time );
			level thread run_scene( "player_backstroke_swim" );
			playing_backstroke = 1;
			playing_idle = 0;
			if ( b_message_up )
			{
				screen_message_delete();
			}
		}
		else
		{
			if ( input == 0 && !playing_idle )
			{
				swim_pos moveto( swim_pos.origin, 0,05 );
				level thread run_scene( "player_idle_swim" );
				playing_backstroke = 0;
				playing_idle = 1;
			}
		}
		wait 0,05;
		if ( playing_backstroke )
		{
			time -= 0,05;
		}
	}
	player_model notify( "delete_wake" );
	level.player setwaterdrops( 0 );
}

play_water_fx_on_everyone()
{
	exploder( 210 );
	wait 0,05;
	player_body = get_model_or_models_from_scene( "player_swim_to_shore", "player_body_river" );
	playfxontag( getfx( "fx_ango_water_splash_player" ), player_body, "tag_camera" );
	hudson_water_origin = spawn( "script_model", level.hudson.origin );
	hudson_water_origin setmodel( "tag_origin" );
	playfxontag( level._effect[ "water_splash_effect" ], hudson_water_origin, "tag_origin" );
	hudson_water_origin.origin = ( level.hudson.origin[ 0 ], level.hudson.origin[ 1 ], -40 );
	hudson_water_origin linkto( level.hudson );
	level waittill( "hudson_idle_on_shore_started" );
	hudson_water_origin delete();
}

play_barge_explosion_fx()
{
	wait 6,5;
	level.main_barge playsound( "exp_barge" );
	level clientnotify( "barge_sink" );
	playfxontag( level._effect[ "barge_woods_exp" ], level.main_barge, "TAG_WHEEL_BACK_RIGHT" );
	wait 2;
	exploder( 250 );
}

heli_evade()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "missile_fire", missile );
		weapon = self getcurrentweapon();
		while ( self getcurrentweapon() == "rpg_sp" )
		{
			continue;
		}
		while ( self getcurrentweapon() != "strela_sp" )
		{
			wait 0,05;
		}
	}
}

rotate_barge()
{
	self endon( "end_rotate_barge" );
	start_angles = self.angles;
	yaw = start_angles[ 1 ];
	ang_vel = 0;
	while ( 1 )
	{
		dir = anglesToForward( ( 0, yaw, 0 ) );
		path_dir = vectornormalize( self.pathlookpos - self.pathpos );
		ang_vel += 0,025;
		ang_vel = clamp( ang_vel, -10, 10 );
		yaw -= ang_vel * 0,05;
		yaw = angleClamp180( yaw );
		self settargetyaw( yaw );
		self setphysangles( ( self.angles[ 0 ], self.angles[ 1 ], 4 * sin( getTime() * 0,075 ) ) );
		wait 0,05;
	}
}

fire_dying_missile_at_boat()
{
	self maps/_turret::set_turret_target( level.main_barge, ( 0, 0, 0 ), 1 );
	self maps/_turret::set_turret_target( level.main_barge, ( 0, 0, 0 ), 2 );
	self thread maps/_turret::fire_turret_for_time( 2, 1 );
	self thread maps/_turret::fire_turret_for_time( 2, 2 );
}

spawn_aft_explosion()
{
	wait 1;
	fake_aft_board = spawn( "script_model", level.main_barge.origin );
	fake_aft_board setmodel( "fxanim_angola_barge_aft_debris_mod" );
	fake_aft_board.angles = level.main_barge.angles;
	fake_aft_board.animname = "barge_aft";
	fake_aft_board linkto( level.main_barge );
	fake_aft_board playsound( "evt_barge_explo_back" );
	a_barrels = getentarray( "barge_barrel", "targetname" );
	array_delete( a_barrels );
	playfxontag( level._effect[ "barge_aft_exp" ], level.main_barge, "tag_origin" );
	level.main_barge hidepart( "TAG_REAR_DAMAGE" );
	rear_damage_clip = getent( "rear_damage_clip", "targetname" );
	rear_damage_clip solid();
	fake_model = spawn( "script_model", level.main_barge gettagorigin( "TAG_REAR_DAMAGE" ) );
	fake_model setmodel( "veh_t6_sea_barge_rear_dmg_destroyed" );
	fake_model.angles = level.main_barge gettagangles( "TAG_REAR_DAMAGE" );
	fake_model linkto( level.main_barge, "TAG_REAR_DAMAGE" );
	level notify( "aft_explosion" );
	trigger_use( "barge_barrel_top_trig" );
	level thread run_scene( "crane_sink" );
	run_scene( "barge_aft_explosion" );
	level thread update_player_barge_rolling();
	fake_aft_board delete();
}

play_rumble_on_spinning_barge()
{
	level endon( "hind_crash" );
	while ( 1 )
	{
		level.player playrumbleonentity( "tank_damage_light_mp" );
		level.player playsound( "evt_barge_water_hit" );
		wait randomfloatrange( 1, 3 );
	}
}

update_player_barge_rolling()
{
	level endon( "hind_crash" );
	if ( !isDefined( level.player.fake_ground_ent ) )
	{
		level.player.fake_ground_ent = spawn( "script_model", level.player.origin );
		level.player.fake_ground_ent setmodel( "tag_origin" );
		level.player.fake_ground_ent.angles = level.player.angles;
		level.player playersetgroundreferenceent( level.player.fake_ground_ent );
	}
	while ( 1 )
	{
		new_angles = ( level.main_barge.angles[ 0 ], 0, level.main_barge.angles[ 2 ] );
		level.player.fake_ground_ent.angles = new_angles;
		wait 0,05;
	}
}

voice_over_barge()
{
	level.player say_dialog( "maso_i_ll_deal_with_them_0" );
}

set_water_dvars_swim()
{
	setdvar( "r_waterwavespeed", "0.5 1.1 1 1.012" );
	setdvar( "r_waterwaveamplitude", "3 1.5 2.5 2" );
	setdvar( "r_waterwavewavelength", "85 200 295 460" );
	setdvar( "r_waterwaveangle", "85 33 69 162" );
}

barge_sink_sfx()
{
	sink_sfx = spawn( "script_origin", ( -27701, -2858, 49 ) );
	sink_sfx playloopsound( "evt_barge_sink" );
	wait 22;
	playsoundatposition( "evt_barge_barrels", ( -27739, -3008, 8 ) );
	wait 2;
	playsoundatposition( "evt_barge_crane", ( -27739, -3008, 8 ) );
	wait 20;
	sink_sfx stoploopsound( 5 );
	wait 7;
	sink_sfx delete();
}
