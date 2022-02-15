#include maps/_scene;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

_init_wounded_anims()
{
	level.scr_anim[ "dead_male" ][ "floor" ] = array( %ch_gen_m_floor_armdown_legspread_onback_deathpose, %ch_gen_m_floor_armdown_onback_deathpose, %ch_gen_m_floor_armdown_onfront_deathpose, %ch_gen_m_floor_armover_onrightside_deathpose, %ch_gen_m_floor_armrelaxed_onleftside_deathpose, %ch_gen_m_floor_armsopen_onback_deathpose, %ch_gen_m_floor_armspread_legaskew_onback_deathpose, %ch_gen_m_floor_armspread_legspread_onback_deathpose, %ch_gen_m_floor_armspreadwide_legspread_onback_deathpose, %ch_gen_m_floor_armstomach_onback_deathpose, %ch_gen_m_floor_armstomach_onrightside_deathpose, %ch_gen_m_floor_armstretched_onleftside_deathpose, %ch_gen_m_floor_armstretched_onrightside_deathpose, %ch_gen_m_floor_armup_legaskew_onfront_faceleft_deathpose, %ch_gen_m_floor_armup_legaskew_onfront_faceright_deathpose, %ch_gen_m_floor_armup_onfront_deathpose );
	level.scr_anim[ "dead_male" ][ "misc" ] = array( %ch_gen_m_ledge_armhanging_facedown_onfront_deathpose, %ch_gen_m_ledge_armhanging_faceright_onfront_deathpose, %ch_gen_m_ledge_armspread_faceleft_onfront_deathpose, %ch_gen_m_ledge_armspread_faceright_onfront_deathpose, %ch_gen_m_ramp_armup_onfront_deathpose, %ch_gen_m_vehicle_armdown_leanforward_deathpose, %ch_gen_m_vehicle_armdown_leanright_deathpose, %ch_gen_m_vehicle_armtogether_leanright_deathpose, %ch_gen_m_vehicle_armup_leanleft_deathpose, %ch_gen_m_vehicle_armup_leanright_deathpose, %ch_gen_m_wall_armcraddle_leanleft_deathpose, %ch_gen_m_wall_armopen_leanright_deathpose, %ch_gen_m_wall_headonly_leanleft_deathpose, %ch_gen_m_wall_legin_armcraddle_hunchright_deathpose, %ch_gen_m_wall_legspread_armdown_leanleft_deathpose, %ch_gen_m_wall_legspread_armdown_leanright_deathpose, %ch_gen_m_wall_legspread_armonleg_leanright_deathpose, %ch_gen_m_wall_low_armstomach_leanleft_deathpose, %ch_gen_m_wall_rightleg_wounded );
	level.scr_anim[ "wounded_male" ][ "floor" ] = array( %ch_gen_m_floor_back_wounded, %ch_gen_m_floor_chest_wounded, %ch_gen_m_floor_dullpain_wounded, %ch_gen_m_floor_head_wounded, %ch_gen_m_floor_leftleg_wounded, %ch_gen_m_floor_shellshock_wounded );
	level.scr_anim[ "wounded_male" ][ "misc" ] = array( %ch_gen_m_wall_rightleg_wounded );
	level.scr_anim[ "dead_female" ][ "floor" ] = array( %ch_gen_f_floor_onback_armstomach_legcurled_deathpose, %ch_gen_f_floor_onback_armup_legcurled_deathpose, %ch_gen_f_floor_onfront_armdown_legstraight_deathpose, %ch_gen_f_floor_onfront_armup_legcurled_deathpose, %ch_gen_f_floor_onfront_armup_legstraight_deathpose, %ch_gen_f_floor_onleftside_armcurled_legcurled_deathpose, %ch_gen_f_floor_onleftside_armstretched_legcurled_deathpose, %ch_gen_f_floor_onrightside_armstomach_legcurled_deathpose, %ch_gen_f_floor_onrightside_armstretched_legcurled_deathpose );
	level.scr_anim[ "dead_female" ][ "misc" ] = array( %ch_gen_f_wall_leanleft_armdown_legcurled_deathpose, %ch_gen_f_wall_leanleft_armstomach_legstraight_deathpose, %ch_gen_f_wall_leanright_armstomach_legcurled_deathpose, %ch_gen_f_wall_leanright_armstomach_legstraight_deathpose );
	level._wounded_animnames = array( "dead_male", "wounded_male", "dead_female" );
	level._wounded_anims = [];
	_a102 = level.scr_anim[ "dead_male" ][ "floor" ];
	_k102 = getFirstArrayKey( _a102 );
	while ( isDefined( _k102 ) )
	{
		animation = _a102[ _k102 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k102 = getNextArrayKey( _a102, _k102 );
	}
	_a107 = level.scr_anim[ "dead_male" ][ "misc" ];
	_k107 = getFirstArrayKey( _a107 );
	while ( isDefined( _k107 ) )
	{
		animation = _a107[ _k107 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k107 = getNextArrayKey( _a107, _k107 );
	}
	_a112 = level.scr_anim[ "wounded_male" ][ "floor" ];
	_k112 = getFirstArrayKey( _a112 );
	while ( isDefined( _k112 ) )
	{
		animation = _a112[ _k112 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k112 = getNextArrayKey( _a112, _k112 );
	}
	_a117 = level.scr_anim[ "wounded_male" ][ "misc" ];
	_k117 = getFirstArrayKey( _a117 );
	while ( isDefined( _k117 ) )
	{
		animation = _a117[ _k117 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k117 = getNextArrayKey( _a117, _k117 );
	}
	_a122 = level.scr_anim[ "dead_female" ][ "floor" ];
	_k122 = getFirstArrayKey( _a122 );
	while ( isDefined( _k122 ) )
	{
		animation = _a122[ _k122 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k122 = getNextArrayKey( _a122, _k122 );
	}
	_a127 = level.scr_anim[ "dead_female" ][ "misc" ];
	_k127 = getFirstArrayKey( _a127 );
	while ( isDefined( _k127 ) )
	{
		animation = _a127[ _k127 ];
		level._wounded_anims[ string( animation ) ] = animation;
		_k127 = getNextArrayKey( _a127, _k127 );
	}
}

_init_wounded()
{
	level.a_wounded = [];
	_a137 = get_triggers();
	_k137 = getFirstArrayKey( _a137 );
	while ( isDefined( _k137 ) )
	{
		trig = _a137[ _k137 ];
		if ( isDefined( trig.target ) )
		{
			a_structs = getstructarray( trig.target );
			a_structs = _process_structs( a_structs );
			if ( a_structs.size > 0 )
			{
				a_structs = array_reverse( sort_by_distance( a_structs, trig.origin ) );
				trig thread _spawn_wounded_trigger( a_structs );
			}
		}
		_k137 = getNextArrayKey( _a137, _k137 );
	}
}

_process_structs( a_structs )
{
	a_wounded_structs = [];
	_a159 = a_structs;
	_k159 = getFirstArrayKey( _a159 );
	while ( isDefined( _k159 ) )
	{
		struct = _a159[ _k159 ];
		if ( isDefined( struct.script_animation ) )
		{
			if ( isDefined( level._wounded_anims[ struct.script_animation ] ) )
			{
				struct.animation = level._wounded_anims[ struct.script_animation ];
			}
			else a_toks = strtok( struct.script_animation, ", " );
			if ( isinarray( level._wounded_animnames, a_toks[ 0 ] ) )
			{
				struct.animation = getanim_from_animname( a_toks[ 1 ], a_toks[ 0 ] );
				if ( isarray( struct.animation ) )
				{
					struct.animation = random( struct.animation );
				}
			}
			else
			{
			}
			if ( issubstr( string( struct.animation ), "floor" ) )
			{
				struct.origin = physicstrace( struct.origin + vectorScale( ( 0, 0, 1 ), 64 ), struct.origin - vectorScale( ( 0, 0, 1 ), 500 ) );
				struct.b_trace_done = 1;
			}
			a_spawners = strtok( struct.spawner_id, ", " );
			struct.e_spawner = getent( random( a_spawners ), "targetname" );
			struct.spawner_id = undefined;
			a_wounded_structs[ a_wounded_structs.size ] = struct;
		}
		_k159 = getNextArrayKey( _a159, _k159 );
	}
	return a_wounded_structs;
}

_spawn_wounded_trigger( a_structs )
{
	self endon( "death" );
	self trigger_wait();
	level thread _spawn_wounded_trigger_spawn( a_structs, self.script_trace );
}

_spawn_wounded_trigger_spawn( a_structs, b_sight_trace )
{
	_a211 = a_structs;
	_k211 = getFirstArrayKey( _a211 );
	while ( isDefined( _k211 ) )
	{
		struct = _a211[ _k211 ];
		struct spawn_wounded_at_struct( b_sight_trace );
		wait 0,05;
		_k211 = getNextArrayKey( _a211, _k211 );
	}
}

spawn_wounded( v_org, v_ang, str_animname, str_scene, str_anim_override, str_targetname, do_phys_trace )
{
	if ( !isDefined( v_ang ) )
	{
		v_ang = ( 0, 0, 1 );
	}
	if ( !isDefined( do_phys_trace ) )
	{
		do_phys_trace = 1;
	}
	if ( isDefined( str_anim_override ) )
	{
		animation = level._wounded_anims[ str_anim_override ];
	}
	else
	{
		animation = getanim_from_animname( str_scene, str_animname );
		if ( isarray( animation ) )
		{
			animation = random( animation );
		}
	}
	b_alive = 0;
	if ( issubstr( string( animation ), "wounded" ) )
	{
		b_alive = 1;
	}
	e_wounded = self spawn_drone( 1, str_targetname, 0, b_alive );
	if ( b_alive )
	{
		e_wounded.takedamage = 1;
	}
	else
	{
		e_wounded.takedamage = 0;
		e_wounded setlookattext( "", &"" );
		e_wounded notify( "no_friendly_fire" );
	}
	if ( do_phys_trace && issubstr( string( animation ), "floor" ) )
	{
		floor_pos = physicstrace( v_org + vectorScale( ( 0, 0, 1 ), 64 ), v_org - vectorScale( ( 0, 0, 1 ), 500 ) );
		e_wounded.origin = ( v_org[ 0 ], v_org[ 1 ], floor_pos[ 2 ] );
	}
	else
	{
		e_wounded.origin = v_org;
	}
	e_wounded.angles = v_ang;
	e_wounded setanim( animation, 1, 0, 1 );
	level.a_wounded[ level.a_wounded.size ] = e_wounded;
	return e_wounded;
}

spawn_wounded_at_struct( b_sight_trace )
{
	if ( !isDefined( b_sight_trace ) )
	{
		b_sight_trace = 0;
	}
	if ( isDefined( self.b_trace_done )e_wounded = self.e_spawner spawn_wounded( self.origin, self.angles, self.str_animname, self.str_scene, self.animation, self.str_targetname, !self.b_trace_done );
	 && isDefined( self.script_noteworthy ) )
	{
		e_wounded.script_noteworthy = self.script_noteworthy;
	}
	if ( b_sight_trace )
	{
		e_wounded hide();
		if ( e_wounded sightconetrace( level.player geteye(), level.player ) < 0,05 )
		{
			e_wounded show();
			return;
		}
		else
		{
			e_wounded delete();
		}
	}
}

set_wounded_auto_delete( n_count )
{
	level.n_max_wounded = n_count;
	level thread _wounded_auto_delete_thread();
}

_wounded_auto_delete_thread()
{
	level notify( "_wounded_auto_delete_thread" );
	level endon( "_wounded_auto_delete_thread" );
	if ( !isDefined( level.n_max_wounded ) )
	{
		level.n_max_wounded = 10;
	}
	while ( 1 )
	{
		wait 0,05;
		n_kill = level.a_wounded.size - level.n_max_wounded;
		while ( n_kill > 0 )
		{
			n_now = getTime();
			v_eye = level.player geteye();
			v_player_forward = anglesToForward( level.player getplayerangles() );
			i = 0;
			while ( n_kill > 0 && i < level.a_wounded.size )
			{
				e_wounded = level.a_wounded[ i ];
				if ( isDefined( e_wounded ) )
				{
					v_to_wounded = vectornormalize( e_wounded.origin - v_eye );
					n_dot = vectordot( v_to_wounded, v_player_forward );
					n_seconds_alive = ( n_now - e_wounded.birthtime ) / 1000;
					if ( n_seconds_alive > 10 && n_dot < 0 && e_wounded sightconetrace( v_eye, level.player ) < 0,1 )
					{
						e_wounded delete();
						n_kill--;

						arrayremoveindex( level.a_wounded, i );
					}
					else
					{
						i++;
					}
				}
				else
				{
					arrayremoveindex( level.a_wounded, i );
				}
				wait 0,05;
			}
		}
	}
}
