#include maps/_vehicle;
#include maps/_anim;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );
#using_animtree( "animated_props" );
#using_animtree( "player" );
#using_animtree( "vehicles" );
#using_animtree( "horse" );

_scene_init()
{
	precacherumble( "anim_light" );
	precacherumble( "anim_med" );
	precacherumble( "anim_heavy" );
	precachestring( &"hud_shrink_ammo" );
	precachestring( &"hud_expand_ammo" );
	level._default_player_height = int( getDvar( "player_standingViewHeight" ) );
	triggers = get_triggers();
	_a21 = triggers;
	_k21 = getFirstArrayKey( _a21 );
	while ( isDefined( _k21 ) )
	{
		trig = _a21[ _k21 ];
		while ( isDefined( trig.script_run_scene ) )
		{
			a_scenes = strtok( trig.script_run_scene, " ,;" );
			_a27 = a_scenes;
			_k27 = getFirstArrayKey( _a27 );
			while ( isDefined( _k27 ) )
			{
				str_scene = _a27[ _k27 ];
				add_trigger_function( trig, ::run_scene, str_scene );
				_k27 = getNextArrayKey( _a27, _k27 );
			}
		}
		_k21 = getNextArrayKey( _a21, _k21 );
	}
}

precache_assets( b_skip_precache_models )
{
	if ( !isDefined( b_skip_precache_models ) )
	{
		b_skip_precache_models = 0;
	}
/#
	assert( isDefined( level.a_scenes ), "There are no scenes to precache. Make sure to call add_scene() before calling this function." );
#/
	a_scene_names = getarraykeys( level.a_scenes );
	i = 0;
	while ( i < a_scene_names.size )
	{
		str_scene = a_scene_names[ i ];
		s_scene_info = level.a_scenes[ str_scene ];
		if ( is_scene_deleted( str_scene ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
			{
				has_different = _has_different_generic_anims( str_scene );
/#
				assert( !has_different, "Since scene, " + str_scene + ", is a generic, all asset must use the same aniamtion." );
#/
			}
			a_anim_keys = getarraykeys( s_scene_info.a_anim_info );
			j = 0;
			while ( j < a_anim_keys.size )
			{
				str_animname = a_anim_keys[ j ];
				s_asset_info = s_scene_info.a_anim_info[ str_animname ];
				if ( isDefined( s_asset_info.str_model ) )
				{
					level.scr_model[ str_animname ] = s_asset_info.str_model;
					if ( !b_skip_precache_models )
					{
						precachemodel( s_asset_info.str_model );
					}
				}
				level.scr_animtree[ str_animname ] = s_asset_info.anim_tree;
				if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
				{
					str_animname = "generic";
				}
				animation = s_asset_info.animation;
				if ( isDefined( s_scene_info.do_loop ) && s_scene_info.do_loop )
				{
					level.scr_anim[ str_animname ][ str_scene ][ 0 ] = animation;
					j++;
					continue;
				}
				else
				{
					level.scr_anim[ str_animname ][ str_scene ] = animation;
				}
				j++;
			}
		}
		i++;
	}
}

run_scene( str_scene, n_lerp_time, b_test_run, clientside_linkto )
{
	if ( !isDefined( b_test_run ) )
	{
		b_test_run = 0;
	}
	if ( !isDefined( clientside_linkto ) )
	{
		clientside_linkto = 1;
	}
	if ( level.script == "mov_av7" )
	{
		level.scene_sys notify( "_delete_scene_" + str_scene );
		level.scene_sys notify( "_stop_scene_" + str_scene );
	}
	level.scene_sys endon( "_delete_scene_" + str_scene );
	level.scene_sys endon( "_stop_scene_" + str_scene );
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for run_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	if ( flag( str_scene + "_started" ) )
	{
		level.a_scenes[ str_scene ].a_ai_anims = [];
		level.a_scenes[ str_scene ].a_model_anims = [];
		if ( !b_test_run )
		{
			flag_clear( str_scene + "_started" );
			flag_clear( str_scene + "_first_frame" );
			flag_clear( str_scene + "_done" );
		}
	}
	waittillframeend;
	level.scene_sys notify( "_start_scene_" + str_scene );
	s_scene_info = level.a_scenes[ str_scene ];
	align_object = s_scene_info _get_align_object( str_scene );
	if ( isDefined( align_object.is_node ) && align_object.is_node )
	{
		setenablenode( align_object, 0 );
	}
	if ( level.script == "mov_av7" )
	{
		align_object notify( str_scene );
	}
	a_active_anims = align_object _assemble_assets( str_scene, clientside_linkto, b_test_run );
	align_object thread _anim_stopped_notify( str_scene, a_active_anims );
	_a171 = a_active_anims;
	_k171 = getFirstArrayKey( _a171 );
	while ( isDefined( _k171 ) )
	{
		e_asset = _a171[ _k171 ];
		if ( level.script == "mov_av7" )
		{
			e_asset anim_stopanimscripted();
		}
		e_asset thread _animate_asset( str_scene, align_object, n_lerp_time, b_test_run );
		_k171 = getNextArrayKey( _a171, _k171 );
	}
	while ( isDefined( level.a_scenes[ str_scene ].a_start_funcs ) )
	{
		_a185 = level.a_scenes[ str_scene ].a_start_funcs;
		_k185 = getFirstArrayKey( _a185 );
		while ( isDefined( _k185 ) )
		{
			callback = _a185[ _k185 ];
			single_thread( level, callback.func, callback.arg1, callback.arg2, callback.arg3, callback.arg4, callback.arg5, callback.arg6 );
			_k185 = getNextArrayKey( _a185, _k185 );
		}
	}
	align_object waittill( str_scene );
	level thread _end_scene( str_scene, b_test_run );
}

_end_scene( str_scene, b_test_run )
{
	if ( !isDefined( b_test_run ) )
	{
		b_test_run = 0;
	}
	if ( !b_test_run )
	{
		flag_set( str_scene + "_done" );
	}
	level.scene_sys endon( "_delete_scene_" + str_scene );
	waittillframeend;
	delete_scene( str_scene );
}

run_scene_and_delete( str_scene, n_lerp_time )
{
	run_scene( str_scene, n_lerp_time );
	delete_scene( str_scene, 1 );
}

run_scene_first_frame( str_scene, b_skip_ai, b_clear_anim, clientside_linkto )
{
	if ( !isDefined( b_skip_ai ) )
	{
		b_skip_ai = 0;
	}
	if ( !isDefined( clientside_linkto ) )
	{
		clientside_linkto = 1;
	}
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for run_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	s_scene_info = level.a_scenes[ str_scene ];
	align_object = s_scene_info _get_align_object( str_scene );
	if ( isDefined( align_object.is_node ) && align_object.is_node )
	{
		setenablenode( align_object, 0 );
	}
	a_active_anims = align_object _assemble_assets( str_scene, clientside_linkto, 0, b_skip_ai, 1 );
	flag_set( str_scene + "_first_frame" );
	_a252 = a_active_anims;
	_k252 = getFirstArrayKey( _a252 );
	while ( isDefined( _k252 ) )
	{
		e_asset = _a252[ _k252 ];
		e_asset _run_anim_first_frame_on_asset( str_scene, align_object, b_clear_anim );
		_k252 = getNextArrayKey( _a252, _k252 );
	}
}

end_scene( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for end_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Invalid scene name '" + str_scene + "' passed to end_scene()" );
#/
	if ( !is_scene_deleted( str_scene ) )
	{
		s_scene_info = level.a_scenes[ str_scene ];
		while ( isDefined( s_scene_info.a_ai_anims ) )
		{
			__new = [];
			_a278 = s_scene_info.a_ai_anims;
			__key = getFirstArrayKey( _a278 );
			while ( isDefined( __key ) )
			{
				__value = _a278[ __key ];
				if ( isDefined( __value ) )
				{
					if ( isstring( __key ) )
					{
						__new[ __key ] = __value;
						break;
					}
					else
					{
						__new[ __new.size ] = __value;
					}
				}
				__key = getNextArrayKey( _a278, __key );
			}
			s_scene_info.a_ai_anims = __new;
			_a280 = s_scene_info.a_ai_anims;
			_k280 = getFirstArrayKey( _a280 );
			while ( isDefined( _k280 ) )
			{
				ai_anim = _a280[ _k280 ];
				ai_anim anim_stopanimscripted( 0,2 );
				_k280 = getNextArrayKey( _a280, _k280 );
			}
		}
		while ( isDefined( s_scene_info.a_model_anims ) )
		{
			__new = [];
			_a288 = s_scene_info.a_model_anims;
			__key = getFirstArrayKey( _a288 );
			while ( isDefined( __key ) )
			{
				__value = _a288[ __key ];
				if ( isDefined( __value ) )
				{
					if ( isstring( __key ) )
					{
						__new[ __key ] = __value;
						break;
					}
					else
					{
						__new[ __new.size ] = __value;
					}
				}
				__key = getNextArrayKey( _a288, __key );
			}
			s_scene_info.a_model_anims = __new;
			_a290 = s_scene_info.a_model_anims;
			_k290 = getFirstArrayKey( _a290 );
			while ( isDefined( _k290 ) )
			{
				m_anim = _a290[ _k290 ];
				m_anim anim_stopanimscripted( 0,2 );
				_k290 = getNextArrayKey( _a290, _k290 );
			}
		}
		level thread _end_scene( str_scene );
		level.scene_sys endon( "_start_scene_" + str_scene );
		waittillframeend;
		level.scene_sys notify( "_stop_scene_" + str_scene );
	}
}

add_scene_properties( str_scene, str_align_targetname )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for add_scene_properties()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	level.a_scenes[ str_scene ].align_object = undefined;
	level.a_scenes[ str_scene ].str_align_targetname = str_align_targetname;
	level.a_scenes[ str_scene ].do_not_align = undefined;
}

add_asset_properties( str_animname, str_scene, v_origin, v_angles )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_asset_properties()" );
#/
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for add_asset_properties()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ].a_anim_info[ str_animname ] ), "Asset with this animname, " + str_animname + ", does not exist in scene, " + str_scene );
#/
	level.a_scenes[ str_scene ].a_anim_info[ str_animname ].v_origin = v_origin;
	level.a_scenes[ str_scene ].a_anim_info[ str_animname ].v_angles = v_angles;
}

add_generic_ai_to_scene( ai_generic, str_scene )
{
/#
	assert( isDefined( ai_generic ), "ai_generic is a required argument for add_generic_ai_to_scene()" );
#/
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for add_generic_ai_to_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ].a_anim_info[ "generic" ] ), "Make sure the actor info is setup properly for scene, " + str_scene + ", with add_actor_anim() or add_multiple_generic_actors()" );
#/
	if ( !isDefined( level.a_scenes[ str_scene ].a_ai_anims ) )
	{
		level.a_scenes[ str_scene ].a_ai_anims = [];
	}
	if ( flag( str_scene + "_started" ) )
	{
		level.a_scenes[ str_scene ].a_ai_anims = [];
		flag_clear( str_scene + "_started" );
		flag_clear( str_scene + "_first_frame" );
	}
	s_scene_info = level.a_scenes[ str_scene ];
	s_asset_info = s_scene_info.a_anim_info[ "generic" ];
	ai_generic thread _setup_asset_for_scene( s_asset_info, s_scene_info );
	level.a_scenes[ str_scene ].a_ai_anims[ level.a_scenes[ str_scene ].a_ai_anims.size ] = ai_generic;
}

add_generic_prop_to_scene( m_generic, str_scene, anim_tree )
{
/#
	assert( isDefined( m_generic ), "m_generic is a required argument for add_generic_prop_to_scene()" );
#/
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for add_generic_prop_to_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ].a_anim_info[ "generic" ] ), "Make sure the prop info is setup properly for scene, " + str_scene + ", with add_prop_anim() or add_multiple_generic_props_from_radiant()" );
#/
	if ( !isDefined( level.a_scenes[ str_scene ].a_model_anims ) )
	{
		level.a_scenes[ str_scene ].a_model_anims = [];
	}
	if ( flag( str_scene + "_started" ) )
	{
		level.a_scenes[ str_scene ].a_model_anims = [];
		flag_clear( str_scene + "_started" );
		flag_clear( str_scene + "_first_frame" );
	}
	s_asset_info = level.a_scenes[ str_scene ].a_anim_info[ "generic" ];
	m_generic.str_name = s_asset_info.str_name;
	m_generic.do_delete = s_asset_info.do_delete;
	m_generic.str_tag = s_asset_info.str_tag;
	m_generic init_anim_model( s_asset_info.str_name, s_asset_info.is_simple_prop, anim_tree );
	while ( isDefined( s_asset_info.a_parts ) )
	{
		i = 0;
		while ( i < s_asset_info.a_parts.size )
		{
			m_generic hidepart( s_asset_info.a_parts[ i ] );
			i++;
		}
	}
	n_model_anims_size = level.a_scenes[ str_scene ].a_model_anims.size;
	level.a_scenes[ str_scene ].a_model_anims[ n_model_anims_size ] = m_generic;
}

get_model_or_models_from_scene( str_scene, str_name )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for get_model_or_models_from_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	waittill_scene_spawned( str_scene );
	s_scene_info = level.a_scenes[ str_scene ];
	model_or_models = [];
	if ( !isDefined( str_name ) )
	{
		model_or_models = s_scene_info.a_model_anims;
		if ( !isDefined( model_or_models ) )
		{
			model_or_models = [];
		}
		while ( model_or_models.size == 0 )
		{
			_a471 = s_scene_info.a_anim_info;
			str_anim_key = getFirstArrayKey( _a471 );
			while ( isDefined( str_anim_key ) )
			{
				s_asset_info = _a471[ str_anim_key ];
				if ( isDefined( s_asset_info.is_model ) && s_asset_info.is_model && !isDefined( s_asset_info.str_model ) )
				{
					model_or_models = s_asset_info _get_models_from_radiant( str_scene );
				}
				str_anim_key = getNextArrayKey( _a471, str_anim_key );
			}
		}
	}
	else _a485 = s_scene_info.a_model_anims;
	_k485 = getFirstArrayKey( _a485 );
	while ( isDefined( _k485 ) )
	{
		m_check = _a485[ _k485 ];
		if ( isDefined( m_check ) && m_check.str_name == str_name )
		{
			model_or_models[ model_or_models.size ] = m_check;
		}
		_k485 = getNextArrayKey( _a485, _k485 );
	}
	if ( model_or_models.size < 2 )
	{
		model_or_models = model_or_models[ 0 ];
	}
	return model_or_models;
}

get_ais_from_scene( str_scene, str_animname )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for get_model_or_models_from_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	while ( !is_scene_deleted( str_scene ) )
	{
		waittill_scene_spawned( str_scene );
		if ( !isDefined( level.a_scenes[ str_scene ].a_ai_anims ) )
		{
			level.a_scenes[ str_scene ].a_ai_anims = [];
		}
		__new = [];
		_a523 = level.a_scenes[ str_scene ].a_ai_anims;
		__key = getFirstArrayKey( _a523 );
		while ( isDefined( __key ) )
		{
			__value = _a523[ __key ];
			if ( isDefined( __value ) )
			{
				if ( isstring( __key ) )
				{
					__new[ __key ] = __value;
					break;
				}
				else
				{
					__new[ __new.size ] = __value;
				}
			}
			__key = getNextArrayKey( _a523, __key );
		}
		level.a_scenes[ str_scene ].a_ai_anims = __new;
		if ( !isDefined( str_animname ) )
		{
			return level.a_scenes[ str_scene ].a_ai_anims;
		}
		_a531 = level.a_scenes[ str_scene ].a_ai_anims;
		_k531 = getFirstArrayKey( _a531 );
		while ( isDefined( _k531 ) )
		{
			ai_actor = _a531[ _k531 ];
			if ( ai_actor.animname == str_animname )
			{
				return ai_actor;
			}
			_k531 = getNextArrayKey( _a531, _k531 );
		}
	}
}

get_scene_start_pos( str_scene, str_name )
{
	a_anim_info = level.a_scenes[ str_scene ].a_anim_info;
	align = level.a_scenes[ str_scene ] _get_align_object( str_scene );
	return getstartorigin( align.origin, align.angles, a_anim_info[ str_name ].animation );
}

get_scene_start_angles( str_scene, str_name )
{
	a_anim_info = level.a_scenes[ str_scene ].a_anim_info;
	align = level.a_scenes[ str_scene ] _get_align_object( str_scene );
	return getstartangles( align.origin, align.angles, a_anim_info[ str_name ].animation );
}

scene_wait( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for delete_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	flag_wait( str_scene + "_done" );
}

waittill_scene_spawned( str_scene )
{
	flag_wait_either( str_scene + "_started", str_scene + "_first_frame" );
}

skip_scene( str_scene, b_delete )
{
	if ( !isDefined( b_delete ) )
	{
		b_delete = 0;
	}
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for skip_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	flag_set( str_scene + "_started" );
	flag_set( str_scene + "_done" );
	level.a_scenes[ str_scene ].b_skip = 1;
	if ( b_delete )
	{
		delete_scene( str_scene, 1 );
	}
}

is_scene_skipped( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for skip_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	if ( isDefined( level.a_scenes[ str_scene ].b_skip ) )
	{
		return level.a_scenes[ str_scene ].b_skip;
	}
}

delete_models_from_scene( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for delete_models_from_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	_delete_models( str_scene );
}

delete_ais_from_scene( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for delete_models_from_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	_delete_ais( str_scene );
}

delete_scene( str_scene, b_cleanup_vars, b_cleanup_more )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for delete_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
	_delete_scene( str_scene, 1, b_cleanup_vars, undefined, b_cleanup_more );
}

delete_scene_all( str_scene, b_cleanup_vars, b_keep_radiant_ents, b_cleanup_more )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for delete_scene()" );
#/
/#
	assert( isDefined( level.a_scenes[ str_scene ] ), "Make sure this scene, " + str_scene + ", is added by using add_scene()" );
#/
/#
	assert( !is_scene_deleted( str_scene ), "Attempting to delete a scene that's already been deleted." );
#/
	_delete_scene( str_scene, 0, b_cleanup_vars, b_keep_radiant_ents, b_cleanup_more );
}

_delete_scene( str_scene, b_specific_ents, b_cleanup_vars, b_keep_radiant_ents, b_cleanup_more )
{
	_delete_models( str_scene, b_specific_ents, b_keep_radiant_ents );
	_delete_ais( str_scene, b_specific_ents );
	if ( isDefined( b_cleanup_vars ) && b_cleanup_vars )
	{
		while ( isDefined( b_cleanup_more ) && b_cleanup_more )
		{
			end_scene( str_scene );
			a_str_animnames = getarraykeys( level.a_scenes[ str_scene ].a_anim_info );
			_a742 = a_str_animnames;
			_k742 = getFirstArrayKey( _a742 );
			while ( isDefined( _k742 ) )
			{
				str_name = _a742[ _k742 ];
				if ( isDefined( level.scr_anim[ str_name ] ) && isDefined( level.scr_anim[ str_name ][ str_scene ] ) )
				{
					if ( level.scr_anim[ str_name ].size == 0 )
					{
					}
				}
				_k742 = getNextArrayKey( _a742, _k742 );
			}
		}
		level.a_scenes[ str_scene ] = "scene deleted";
	}
	if ( isDefined( b_cleanup_more ) && b_cleanup_more )
	{
		flag_delete( str_scene + "_started" );
		flag_delete( str_scene + "_first_frame" );
		flag_delete( str_scene + "_done" );
	}
	level notify( str_scene + "_deleted" );
	level.scene_sys endon( "_start_scene_" + str_scene );
	waittillframeend;
	level.scene_sys notify( "_delete_scene_" + str_scene );
}

_delayed_delete_scene_looped_anims( str_animname, str_scene )
{
	wait 0,25;
}

is_scene_deleted( str_scene )
{
	if ( isstring( level.a_scenes[ str_scene ] ) )
	{
		return level.a_scenes[ str_scene ] == "scene deleted";
	}
}

_has_different_generic_anims( str_scene )
{
	has_different = 0;
	a_anim_info = level.a_scenes[ str_scene ].a_anim_info;
	a_anim_keys = getarraykeys( a_anim_info );
	i = 0;
	while ( i < a_anim_keys.size )
	{
		anim_current = a_anim_info[ a_anim_keys[ i ] ].animation;
		j = i + 1;
		while ( j < a_anim_info.size )
		{
			anim_check = a_anim_info[ a_anim_keys[ j ] ].animation;
			if ( anim_current != anim_check )
			{
				has_different = 1;
			}
			j++;
		}
		i++;
	}
	return has_different;
}

_add_anim_to_current_scene()
{
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ self.str_name ] = self;
	self thread _preprocess_notetracks();
}

_get_align_object( str_scene )
{
	align_object = level;
	if ( isDefined( self.align_object ) )
	{
		align_object = self.align_object;
	}
	else
	{
		if ( isDefined( self.str_align_targetname ) )
		{
			align_object = getstruct( self.str_align_targetname, "targetname" );
			if ( !isDefined( align_object ) )
			{
				align_object = getnode( self.str_align_targetname, "targetname" );
				if ( isDefined( align_object ) )
				{
					align_object.is_node = 1;
				}
				else
				{
					align_object = getent( self.str_align_targetname, "targetname" );
				}
			}
			else
			{
				s_align = spawnstruct();
				s_align.origin = align_object.origin;
				if ( isDefined( align_object.angles ) )
				{
					s_align.angles = align_object.angles;
				}
				else
				{
					s_align.angles = ( 1, 1, 1 );
				}
				align_object = s_align;
			}
/#
			assert( isDefined( align_object ), "Could not find a struct, node, or entity with the targetname, " + self.str_align_targetname + ", in the map for scene, " + str_scene );
#/
			level.a_scenes[ str_scene ].align_object = align_object;
		}
	}
	return align_object;
}

_assemble_assets( str_scene, clientside_linkto, b_test_run, b_skip_ai, b_first_frame )
{
	if ( !isDefined( b_skip_ai ) )
	{
		b_skip_ai = 0;
	}
	s_scene_info = level.a_scenes[ str_scene ];
	_a912 = s_scene_info.a_anim_info;
	str_anim_key = getFirstArrayKey( _a912 );
	while ( isDefined( str_anim_key ) )
	{
		s_asset_info = _a912[ str_anim_key ];
		if ( str_anim_key == "generic" )
		{
		}
		else m_model = getent( s_asset_info.str_name, "targetname" );
		if ( isDefined( m_model ) )
		{
			if ( isDefined( m_model._scene_deleting )b_model_exists = !m_model._scene_deleting;
		}
		 && !isDefined( s_asset_info.str_model ) && !isDefined( s_asset_info.str_vehicletype ) && isDefined( s_asset_info.n_player_number ) && !isDefined( level.scene_sys.a_active_anim_models[ s_asset_info.str_name ] ) && !b_model_exists )
		{
			s_asset_info _assemble_non_existent_model( str_scene, b_first_frame, clientside_linkto );
		}
		else
		{
			if ( isDefined( s_asset_info.is_model ) && s_asset_info.is_model )
			{
				s_asset_info _assemble_already_exist_model( str_scene, b_first_frame, clientside_linkto );
				break;
			}
			else
			{
				if ( !b_skip_ai )
				{
					if ( isDefined( s_asset_info.has_multiple_ais ) && s_asset_info.has_multiple_ais )
					{
						s_asset_info _assemble_multiple_ais( str_scene, b_test_run, clientside_linkto );
						break;
					}
					else
					{
						s_asset_info _assemble_single_ai( str_scene, str_anim_key, b_test_run, clientside_linkto );
					}
				}
			}
		}
		str_anim_key = getNextArrayKey( _a912, str_anim_key );
	}
	a_active_anims = [];
	if ( isDefined( s_scene_info.a_ai_anims ) )
	{
		__new = [];
		_a949 = s_scene_info.a_ai_anims;
		__key = getFirstArrayKey( _a949 );
		while ( isDefined( __key ) )
		{
			__value = _a949[ __key ];
			if ( isDefined( __value ) )
			{
				if ( isstring( __key ) )
				{
					__new[ __key ] = __value;
					break;
				}
				else
				{
					__new[ __new.size ] = __value;
				}
			}
			__key = getNextArrayKey( _a949, __key );
		}
		s_scene_info.a_ai_anims = __new;
		a_active_anims = arraycombine( a_active_anims, s_scene_info.a_ai_anims, 1, 0 );
	}
	if ( isDefined( s_scene_info.a_model_anims ) )
	{
		__new = [];
		_a955 = s_scene_info.a_model_anims;
		__key = getFirstArrayKey( _a955 );
		while ( isDefined( __key ) )
		{
			__value = _a955[ __key ];
			if ( isDefined( __value ) )
			{
				if ( isstring( __key ) )
				{
					__new[ __key ] = __value;
					break;
				}
				else
				{
					__new[ __new.size ] = __value;
				}
			}
			__key = getNextArrayKey( _a955, __key );
		}
		s_scene_info.a_model_anims = __new;
		a_active_anims = arraycombine( a_active_anims, s_scene_info.a_model_anims, 1, 0 );
	}
	return a_active_anims;
}

_assemble_non_existent_model( str_scene, b_first_frame, clientside_linkto )
{
	if ( isDefined( self.str_vehicletype ) )
	{
		m_ready = _spawn_vehicle_for_anim();
	}
	else
	{
		if ( isDefined( self.n_player_number ) )
		{
			level.scr_model[ self.str_name ] = level.player_interactive_model;
		}
		if ( isDefined( self.b_connect_paths ) && self.b_connect_paths )
		{
		}
		else
		{
		}
		m_ready = spawn( "script_model", ( 1, 1, 1 ), undefined, 1 );
		m_ready assign_model( self.str_name );
		m_ready init_anim_model( self.str_name, self.is_simple_prop );
	}
	m_ready.targetname = self.str_name;
	if ( clientside_linkto )
	{
		m_ready enableclientlinkto();
	}
	else
	{
		m_ready disableclientlinkto();
	}
	s_scene_info = level.a_scenes[ str_scene ];
	m_ready thread _setup_asset_for_scene( self, s_scene_info, b_first_frame );
	level.scene_sys.a_active_anim_models[ self.str_name ] = m_ready;
	if ( !isDefined( level.a_scenes[ str_scene ].a_model_anims ) )
	{
		level.a_scenes[ str_scene ].a_model_anims = [];
	}
	level.a_scenes[ str_scene ].a_model_anims[ level.a_scenes[ str_scene ].a_model_anims.size ] = m_ready;
}

_viewmodel_delay_hide( n_time )
{
	if ( !isDefined( n_time ) )
	{
		n_time = 0,25;
	}
	wait n_time;
	self hideviewmodel();
}

_setup_asset_for_scene( s_asset_info, s_scene_info, b_first_frame )
{
	if ( !isDefined( b_first_frame ) )
	{
		b_first_frame = 0;
	}
	self.str_name = s_asset_info.str_name;
	self.animname = s_asset_info.str_name;
	self.do_delete = s_asset_info.do_delete;
	self.str_tag = s_asset_info.str_tag;
	while ( isDefined( s_asset_info.a_parts ) )
	{
		_a1024 = s_asset_info.a_parts;
		_k1024 = getFirstArrayKey( _a1024 );
		while ( isDefined( _k1024 ) )
		{
			str_part = _a1024[ _k1024 ];
			self hidepart( str_part );
			_k1024 = getNextArrayKey( _a1024, _k1024 );
		}
	}
	if ( isDefined( s_asset_info.is_weapon ) && s_asset_info.is_weapon )
	{
		self useweaponhidetags( self.str_weapon_name );
	}
	else
	{
		if ( isai( self ) )
		{
			_setup_ai_for_scene( s_asset_info, s_scene_info );
			return;
		}
		else if ( self isvehicle() )
		{
			_setup_vehicle_for_scene( s_asset_info, s_scene_info );
			return;
		}
		else if ( isDefined( s_asset_info.n_player_number ) )
		{
			player = get_players()[ s_asset_info.n_player_number ];
			player _setup_player_for_scene( s_asset_info, s_scene_info, self );
			return;
		}
		else
		{
			if ( isDefined( s_asset_info.is_model ) && s_asset_info.is_model )
			{
				_setup_model_for_scene( s_asset_info, s_scene_info, b_first_frame );
			}
		}
	}
}

_setup_ai_for_scene( s_asset_info, s_scene_info )
{
	if ( isDefined( s_asset_info.do_not_allow_death ) && s_asset_info.do_not_allow_death )
	{
		self.allowdeath = 0;
		self setcandamage( 0 );
	}
	else
	{
		self.allowdeath = 1;
		self setcandamage( 1 );
	}
	self.do_hide_weapon = s_asset_info.do_hide_weapon;
	self.do_give_back_weapon = s_asset_info.do_give_back_weapon;
}

_setup_vehicle_for_scene( s_asset_info, s_scene_info )
{
	if ( isDefined( s_asset_info.do_not_allow_death ) && s_asset_info.do_not_allow_death )
	{
		self.takedamage = 0;
	}
	else
	{
		if ( isDefined( self.script_godmode ) && !self.script_godmode )
		{
			self.takedamage = 1;
		}
	}
	if ( isDefined( s_asset_info.b_animate_origin ) && !s_asset_info.b_animate_origin )
	{
		self.supportsanimscripted = undefined;
	}
	else
	{
		self.supportsanimscripted = 1;
	}
}

_setup_model_for_scene( s_asset_info, s_scene_info, b_first_frame )
{
	if ( isDefined( self.is_drone ) && self.is_drone )
	{
		if ( isDefined( s_asset_info.b_play_dead ) && s_asset_info.b_play_dead )
		{
			self.takedamage = 0;
			self setlookattext( "", &"" );
			self notify( "no_friendly_fire" );
		}
		else
		{
			if ( !isDefined( s_asset_info.do_not_allow_death ) || s_asset_info.do_not_allow_death )
			{
				self.takedamage = 0;
			}
			else
			{
				self.takedamage = 1;
			}
		}
	}
	if ( isDefined( s_asset_info.b_connect_paths ) && s_asset_info.b_connect_paths )
	{
		if ( b_first_frame )
		{
			wait_network_frame();
			self disconnectpaths();
		}
		else
		{
			self connectpaths();
			self.b_disconnect_paths_after_scene = 1;
		}
	}
	else
	{
		self.b_disconnect_paths_after_scene = undefined;
	}
}

_setup_player_for_scene( s_asset_info, s_scene_info, m_player_model )
{
	if ( !level.createfx_enabled )
	{
		luinotifyevent( &"hud_shrink_ammo" );
		s_asset_info thread _link_to_player_model( self, m_player_model, s_scene_info, m_player_model._scene_first_link );
	}
	m_player_model.n_player_number = s_asset_info.n_player_number;
	if ( isDefined( s_asset_info.b_keep_weapons ) && s_asset_info.b_keep_weapons )
	{
/#
		println( "PLAYER ANIM: keeping viewarms" );
#/
		self showviewmodel();
		self enableweapons();
		self enableusability();
		self enableoffhandweapons();
	}
	else
	{
		if ( isDefined( s_asset_info.b_use_low_ready ) && s_asset_info.b_use_low_ready )
		{
			self setlowready( 1 );
			self showviewmodel();
			self enableweapons();
			self disableusability();
			self disableoffhandweapons();
		}
		else
		{
			self disableusability();
			self disableoffhandweapons();
			self disableweapons( 1 );
			self thread _viewmodel_delay_hide();
		}
	}
	self.m_scene_model = m_player_model;
	self.s_scene_info = s_asset_info;
}

_link_to_player_model( player, m_player_model, s_scene_info, b_first_link )
{
	if ( !isDefined( b_first_link ) )
	{
		b_first_link = 1;
	}
	if ( b_first_link )
	{
		if ( isDefined( level.era ) && level.era != "twentytwenty" && level.era != "" )
		{
			player hide_hud();
		}
		else
		{
			player._scene_old_draw_friendly_names = int( getDvar( "cg_drawFriendlyNames" ) );
			setsaveddvar( "cg_drawFriendlyNames", 0 );
		}
		player enableinvulnerability();
		m_player_model hide();
		m_player_model.origin = player.origin;
		m_player_model.angles = player.angles;
		wait_network_frame();
		if ( isDefined( self.b_use_camera_tween ) && self.b_use_camera_tween )
		{
			player startcameratween( 0,2 );
		}
		player._scene_old_player_height = getdvarfloatdefault( "player_standingViewHeight", level._default_player_height );
		setsaveddvar( "player_standingViewHeight", level._default_player_height );
		m_player_model useplayerfootsteptable();
	}
	player notify( "scene_link" );
	waittillframeend;
	if ( isDefined( self.do_delta ) && self.do_delta )
	{
		player playerlinktodelta( m_player_model, "tag_player", self.n_view_fraction, self.n_right_arc, self.n_left_arc, self.n_top_arc, self.n_bottom_arc, self.use_tag_angles, self.b_auto_center );
		player setplayerviewratescale( 100 );
	}
	else
	{
		player playerlinktoabsolute( m_player_model, "tag_player" );
	}
	if ( b_first_link )
	{
		wait 0,2;
		m_player_model show();
	}
}

switch_player_scene_to_delta()
{
/#
	assert( isDefined( self.m_scene_model ), "switch_player_scene_to_delta can only be called on an active scene." );
#/
	self playerlinktodelta( self.m_scene_model, "tag_player", self.s_scene_info.n_view_fraction, self.s_scene_info.n_right_arc, self.s_scene_info.n_left_arc, self.s_scene_info.n_top_arc, self.s_scene_info.n_bottom_arc, self.s_scene_info.use_tag_angles, self.s_scene_info.b_auto_center );
	self setplayerviewratescale( 100 );
}

_switch_to_delta( m_player_model )
{
	player = level.players[ m_player_model.n_player_number ];
	player switch_player_scene_to_delta();
}

_assemble_already_exist_model( str_scene, b_first_frame, clientside_linkto )
{
	a_models = [];
	if ( isDefined( level.scene_sys.a_active_anim_models[ self.str_name ] ) )
	{
		if ( isarray( level.scene_sys.a_active_anim_models[ self.str_name ] ) )
		{
			a_models = level.scene_sys.a_active_anim_models[ self.str_name ];
		}
		else
		{
			m_model = level.scene_sys.a_active_anim_models[ self.str_name ];
			a_models[ a_models.size ] = m_model;
			if ( isDefined( self.n_player_number ) )
			{
				m_model._scene_first_link = 0;
			}
		}
	}
	else
	{
		if ( !isDefined( self.str_spawner ) )
		{
			a_models = self _get_models_from_radiant( str_scene );
		}
		if ( a_models.size == 0 )
		{
			if ( isDefined( self.is_vehicle ) && self.is_vehicle )
			{
				a_models = maps/_vehicle::spawn_vehicles_from_targetname( self.str_name, 1 );
				_a1320 = a_models;
				_k1320 = getFirstArrayKey( _a1320 );
				while ( isDefined( _k1320 ) )
				{
					veh = _a1320[ _k1320 ];
					veh._radiant_ent = 1;
					_k1320 = getNextArrayKey( _a1320, _k1320 );
				}
			}
			else sp_model = _get_spawner( self.str_name, str_scene, self.str_spawner );
			if ( isDefined( self.is_cheap )b_fake_ai = !self.is_cheap;
			 && b_fake_ai )
			{
				if ( isDefined( self.b_spawn_collision )b_spawn_collision = self.b_spawn_collision;
			}
			m_drone = sp_model spawn_drone( b_fake_ai, undefined, b_spawn_collision, b_fake_ai, 0 );
			 && isDefined( self.str_spawner ) )
			{
				m_drone.targetname = self.str_name + "_drone";
			}
			a_models[ 0 ] = m_drone;
		}
		while ( isDefined( self.is_vehicle ) && self.is_vehicle && isDefined( self.not_usable ) && self.not_usable )
		{
			_a1345 = a_models;
			_k1345 = getFirstArrayKey( _a1345 );
			while ( isDefined( _k1345 ) )
			{
				e_model = _a1345[ _k1345 ];
				e_model makevehicleunusable();
				_k1345 = getNextArrayKey( _a1345, _k1345 );
			}
		}
	}
	n_models_array_size = a_models.size;
/#
	assert( n_models_array_size > 0, "Could not find any models with this animname or targetname, " + self.str_name + ", anywhere in the level" );
#/
	if ( n_models_array_size > 1 && !isDefined( level.scene_sys.a_active_anim_models[ self.str_name ] ) )
	{
		level.scene_sys.a_active_anim_models[ self.str_name ] = [];
	}
	s_scene_info = level.a_scenes[ str_scene ];
	i = 0;
	while ( i < n_models_array_size )
	{
		m_exist = a_models[ i ];
		s_asset_info = level.a_scenes[ str_scene ].a_anim_info[ self.str_name ];
		m_exist init_anim_model( self.str_name, self.is_simple_prop, s_asset_info.anim_tree );
		if ( clientside_linkto )
		{
			m_exist enableclientlinkto();
		}
		else
		{
			m_exist disableclientlinkto();
		}
		m_exist thread _setup_asset_for_scene( self, s_scene_info, b_first_frame );
		if ( n_models_array_size > 1 )
		{
			level.scene_sys.a_active_anim_models[ self.str_name ][ i ] = m_exist;
		}
		else
		{
			level.scene_sys.a_active_anim_models[ self.str_name ] = m_exist;
		}
		if ( !isDefined( level.a_scenes[ str_scene ].a_model_anims ) )
		{
			level.a_scenes[ str_scene ].a_model_anims = [];
		}
		if ( !isinarray( level.a_scenes[ str_scene ].a_model_anims, m_exist ) )
		{
			level.a_scenes[ str_scene ].a_model_anims[ level.a_scenes[ str_scene ].a_model_anims.size ] = m_exist;
		}
		i++;
	}
}

_assemble_multiple_ais( str_scene, b_test_run, clientside_linkto )
{
	a_ai_spawned = getentarray( self.str_name + "_ai", "targetname" );
	does_spawner_exist = 0;
	while ( a_ai_spawned.size == 0 )
	{
		a_ai_spawners = getentarray( self.str_name, "targetname" );
		while ( a_ai_spawners.size > 0 )
		{
			does_spawner_exist = 1;
			_a1422 = a_ai_spawners;
			_k1422 = getFirstArrayKey( _a1422 );
			while ( isDefined( _k1422 ) )
			{
				sp_guy = _a1422[ _k1422 ];
				n_spawner_count = sp_guy.count;
				j = 0;
				while ( j < n_spawner_count )
				{
/#
					if ( isDefined( b_test_run ) && b_test_run )
					{
						sp_guy.count++;
#/
					}
					ai = simple_spawn_single( sp_guy );
/#
					assert( isalive( ai ), "Failed to spawn AI '" + self.str_name + "' for scene '" + str_scene + "'. Make sure player cannot see the spawn point or the spawner has spawnflag SCRIPT_FORCESPAWN set." );
#/
					ai.b_scene_spawned = 1;
					a_ai_spawned[ a_ai_spawned.size ] = ai;
					j++;
				}
				_k1422 = getNextArrayKey( _a1422, _k1422 );
			}
		}
	}
	does_ai_exist = a_ai_spawned.size > 0;
/#
	if ( !does_ai_exist )
	{
		assert( does_spawner_exist, "Could not find any AIs or spawners with this targetname, " + self.str_name + ", for the scene, " + str_scene );
	}
#/
	s_scene_info = level.a_scenes[ str_scene ];
	while ( a_ai_spawned.size > 0 )
	{
		_a1455 = a_ai_spawned;
		_k1455 = getFirstArrayKey( _a1455 );
		while ( isDefined( _k1455 ) )
		{
			ai_spawned = _a1455[ _k1455 ];
			if ( clientside_linkto )
			{
				ai_spawned enableclientlinkto();
			}
			else
			{
				ai_spawned disableclientlinkto();
			}
			ai_spawned thread _setup_asset_for_scene( self, s_scene_info );
			if ( !isDefined( level.a_scenes[ str_scene ].a_ai_anims ) )
			{
				level.a_scenes[ str_scene ].a_ai_anims = [];
			}
			level.a_scenes[ str_scene ].a_ai_anims[ level.a_scenes[ str_scene ].a_ai_anims.size ] = ai_spawned;
			_k1455 = getNextArrayKey( _a1455, _k1455 );
		}
	}
}

_assemble_single_ai( str_scene, str_anim_key, b_test_run, clientside_linkto )
{
	a_all_ai_in_level = getaispeciesarray();
	ai_found = undefined;
	_a1490 = a_all_ai_in_level;
	_k1490 = getFirstArrayKey( _a1490 );
	while ( isDefined( _k1490 ) )
	{
		ai = _a1490[ _k1490 ];
		if ( !isDefined( ai.animname ) || !isDefined( str_anim_key ) && isDefined( ai.animname ) && isDefined( str_anim_key ) && ai.animname == str_anim_key )
		{
/#
			assert( !isDefined( ai_found ), "More than one AI in the level has the same animname, " + self.str_name + ", for scene, " + str_scene );
#/
			ai_found = ai;
		}
		_k1490 = getNextArrayKey( _a1490, _k1490 );
	}
	if ( !isalive( ai_found ) )
	{
		sp_guy = _get_spawner( str_anim_key, str_scene, self.str_spawner );
/#
		if ( !isDefined( sp_guy ) )
		{
			if ( isDefined( self.b_optional ) )
			{
				assert( self.b_optional, "Couldn't find spawner with name '" + str_anim_key + "' for scene '" + str_scene + "'." );
			}
		}
#/
		if ( isDefined( sp_guy ) )
		{
			if ( isDefined( sp_guy.script_hero ) && sp_guy.script_hero )
			{
				ai_found = init_hero( sp_guy.targetname );
			}
			else
			{
/#
				if ( isDefined( b_test_run ) && b_test_run )
				{
					sp_guy.count++;
				}
				if ( sp_guy.count > 0 )
				{
					if ( isDefined( self.b_optional ) )
					{
						assert( self.b_optional, "Trying to spawn AI '" + str_anim_key + "' for scene '" + str_scene + "' with zero spawner count! Might need a higher count value on the spawner." );
					}
				}
#/
				if ( sp_guy.count > 0 )
				{
					ai_found = simple_spawn_single( sp_guy, undefined, undefined, undefined, undefined, undefined, undefined, b_test_run );
					if ( isalive( ai_found ) )
					{
						ai_found.b_scene_spawned = 1;
					}
				}
				if ( isalive( ai_found ) )
				{
					ai_found dontinterpolate();
				}
			}
		}
	}
/#
	if ( !isalive( ai_found ) )
	{
		if ( isDefined( self.b_optional ) )
		{
			assert( self.b_optional, "Failed to spawn AI '" + str_anim_key + "' for scene '" + str_scene + "'. Make sure player cannot see the spawn point or the spawner has spawnflag SCRIPT_FORCESPAWN set." );
		}
	}
#/
	s_scene_info = level.a_scenes[ str_scene ];
	if ( isalive( ai_found ) )
	{
		if ( clientside_linkto )
		{
			ai_found enableclientlinkto();
		}
		else
		{
			ai_found disableclientlinkto();
		}
		ai_found thread _setup_asset_for_scene( self, s_scene_info );
		if ( isDefined( self.str_spawner ) )
		{
			ai_found.targetname = str_anim_key + "_ai";
		}
		if ( !isDefined( level.a_scenes[ str_scene ].a_ai_anims ) )
		{
			level.a_scenes[ str_scene ].a_ai_anims = [];
		}
		level.a_scenes[ str_scene ].a_ai_anims[ level.a_scenes[ str_scene ].a_ai_anims.size ] = ai_found;
	}
}

_get_spawner( str_name, str_scene, str_name_override )
{
	if ( isDefined( str_name_override ) )
	{
		str_name = str_name_override;
	}
	a_spawners = getspawnerarray( str_name, "targetname" );
	if ( a_spawners.size > 0 )
	{
		if ( a_spawners.size == 1 )
		{
			return a_spawners[ 0 ];
		}
		else
		{
/#
			assertmsg( "More than one spawner in Radiant has the same name, '" + str_name + "', for scene, '" + str_scene + "'." );
#/
		}
	}
	if ( !isDefined( level.a_scene_ai_spawners ) )
	{
		level.a_scene_ai_spawners = getspawnerarray();
	}
	sp = undefined;
/#
	b_found = 0;
#/
	_a1609 = level.a_scene_ai_spawners;
	_k1609 = getFirstArrayKey( _a1609 );
	while ( isDefined( _k1609 ) )
	{
		sp_guy = _a1609[ _k1609 ];
		if ( !isDefined( sp_guy.script_animname ) || !isDefined( str_name ) && isDefined( sp_guy.script_animname ) && isDefined( str_name ) && sp_guy.script_animname == str_name )
		{
			sp = sp_guy;
/#
			assert( !b_found, "More than one spawner in Radiant has the same name, '" + str_name + "', for scene, '" + str_scene + "'." );
			b_found = 1;
			break;
#/
		}
		else _k1609 = getNextArrayKey( _a1609, _k1609 );
	}
	level thread _delete_scene_ai_spawner_array();
	return sp;
}

_anim_stopped_notify( str_scene, a_active_anims )
{
	self endon( str_scene );
	array_wait( a_active_anims, "_anim_stopped" );
	self notify( str_scene );
}

_watch_for_stop_anim( str_scene, align_object )
{
	self endon( "death" );
	level.scene_sys endon( "_delete_scene_" + str_scene );
	self waittill( "_scene_stopped" );
	align_object notify( str_scene );
}

_animate_asset( str_scene, align_object, n_lerp_time, b_test_run )
{
	if ( !isDefined( b_test_run ) )
	{
		b_test_run = 0;
	}
	self endon( "death" );
	self thread _watch_for_stop_anim( str_scene, align_object );
	s_scene_info = level.a_scenes[ str_scene ];
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		old_free_vehicle = self.dontfreeme;
		self.dontfreeme = 1;
	}
	if ( isDefined( s_scene_info.do_reach ) && s_scene_info.do_reach && !level flag( "running_skipto" ) && !b_test_run )
	{
		self _run_anim_reach_on_asset( str_scene, align_object );
		array_wait( s_scene_info.a_ai_anims, "goal" );
	}
	if ( isai( self ) )
	{
		if ( isDefined( self.do_hide_weapon ) && self.do_hide_weapon )
		{
			self gun_remove();
		}
		else
		{
			if ( isDefined( self.species ) && self.species == "human" )
			{
				self gun_recall();
			}
		}
	}
	if ( !b_test_run )
	{
		flag_set( str_scene + "_started" );
	}
	if ( isDefined( s_scene_info.do_loop ) && s_scene_info.do_loop )
	{
		self _run_anim_loop_on_asset( str_scene, align_object, n_lerp_time );
	}
	else
	{
		self _run_anim_single_on_asset( str_scene, align_object, n_lerp_time );
	}
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		self.dontfreeme = old_free_vehicle;
	}
}

_run_anim_reach_on_asset( str_scene, align_object )
{
	s_scene_info = level.a_scenes[ str_scene ];
	if ( issentient( self ) )
	{
		if ( isDefined( s_scene_info.do_not_align ) && s_scene_info.do_not_align )
		{
			if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
			{
				align_object thread anim_generic_reach( self, str_scene );
			}
			else
			{
				align_object thread anim_reach( self, str_scene );
			}
			return;
		}
		else
		{
			if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
			{
				align_object thread anim_generic_reach_aligned( self, str_scene, self.str_tag );
				return;
			}
			else
			{
				align_object thread anim_reach_aligned( self, str_scene, self.str_tag );
			}
		}
	}
}

_run_anim_loop_on_asset( str_scene, align_object, n_lerp_time )
{
	s_scene_info = level.a_scenes[ str_scene ];
	if ( isDefined( self.is_horse ) )
	{
		self ent_flag_set( "playing_scripted_anim" );
	}
	if ( isDefined( s_scene_info.do_not_align ) && s_scene_info.do_not_align )
	{
		if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
		{
			align_object anim_generic_loop( self, str_scene );
		}
		else
		{
			align_object anim_loop( self, str_scene );
		}
	}
	else
	{
		if ( isDefined( self.str_tag ) )
		{
			self thread _scene_link( align_object, self.str_tag );
		}
		if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
		{
			align_object anim_generic_loop_aligned( self, str_scene, self.str_tag, undefined, n_lerp_time );
		}
		else
		{
			align_object anim_loop_aligned( self, str_scene, self.str_tag, undefined, undefined, n_lerp_time );
		}
		if ( isDefined( self._scene_linking ) && !self._scene_linking && isDefined( self.str_tag ) )
		{
			self unlink();
		}
	}
}

_run_anim_single_on_asset( str_scene, align_object, n_lerp_time )
{
	if ( is_scene_deleted( str_scene ) )
	{
/#
		println( "ERROR: Trying to run deleted scene " + str_scene + "!" );
#/
		return;
	}
	s_scene_info = level.a_scenes[ str_scene ];
	if ( isDefined( self.is_horse ) )
	{
		self ent_flag_set( "playing_scripted_anim" );
	}
	if ( level flag( "running_skipto" ) )
	{
		self._anim_rate = 10;
	}
	if ( isDefined( s_scene_info.do_not_align ) && s_scene_info.do_not_align )
	{
		if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
		{
			align_object anim_generic( self, str_scene );
		}
		else
		{
			align_object anim_single( self, str_scene );
		}
	}
	else
	{
		if ( isDefined( self.str_tag ) && self != align_object )
		{
			self thread _scene_link( align_object, self.str_tag );
		}
		if ( isai( self ) )
		{
			self thread _scene_set_goal( align_object, str_scene );
		}
		if ( isDefined( s_scene_info.do_generic ) && s_scene_info.do_generic )
		{
			align_object anim_generic_aligned( self, str_scene, self.str_tag, n_lerp_time );
		}
		else
		{
			align_object anim_single_aligned( self, str_scene, self.str_tag, undefined, n_lerp_time );
		}
		if ( isDefined( self._scene_linking ) && !self._scene_linking && isDefined( self.str_tag ) && self != align_object )
		{
			self unlink();
		}
		if ( isDefined( self.b_connect_paths ) && self.b_connect_paths )
		{
			self disconnectpaths();
		}
		if ( isDefined( align_object.is_node ) && align_object.is_node )
		{
			setenablenode( align_object, 1 );
		}
	}
	self._anim_rate = undefined;
	if ( isDefined( self.is_horse ) )
	{
		self ent_flag_clear( "playing_scripted_anim" );
	}
}

_scene_set_goal( align_object, str_scene )
{
	self endon( "death" );
	self endon( "goal_changed" );
	align_object waittill( str_scene );
	wait 0,05;
	if ( isDefined( align_object.is_node ) && align_object.is_node )
	{
		self setgoalnode( align_object );
	}
	else
	{
		if ( isDefined( self.b_scene_spawned ) && self.b_scene_spawned )
		{
			if ( !isDefined( self.target ) )
			{
				if ( !isDefined( self.script_spawner_targets ) )
				{
					self setgoalpos( self.origin );
				}
			}
		}
	}
}

_scene_link( align_object, str_tag )
{
	self endon( "death" );
	self._scene_linking = 1;
	self linkto( align_object, str_tag );
	waittillframeend;
	self._scene_linking = undefined;
}

_run_anim_first_frame_on_asset( str_scene, align_object, b_clear_anim )
{
	if ( !isDefined( b_clear_anim ) )
	{
		b_clear_anim = 0;
	}
	s_scene_info = level.a_scenes[ str_scene ];
	if ( isai( self ) )
	{
		self.allowdeath = 0;
		self setcandamage( 0 );
	}
	if ( isDefined( s_scene_info.do_not_align ) && s_scene_info.do_not_align )
	{
		self anim_first_frame( self, str_scene );
	}
	else
	{
		if ( isDefined( self.str_tag ) && self != align_object )
		{
			self linkto( align_object, self.str_tag );
		}
		align_object anim_first_frame( self, str_scene, self.str_tag );
		if ( b_clear_anim )
		{
			self thread _clear_anim_first_frame();
		}
	}
}

_clear_anim_first_frame()
{
	wait_network_frame();
	self stopanimscripted();
}

_get_models_from_radiant( str_scene )
{
	a_models = [];
	m_exist = undefined;
	level.from_radiant_count = 0;
	if ( isDefined( self.has_multiple_props ) && self.has_multiple_props )
	{
		a_models = getentarray( self.str_name, "targetname" );
	}
	else
	{
		if ( isDefined( level.a_script_models ) || !isDefined( level.a_script_models_time ) && level.a_script_models_time != getTime() )
		{
			level.a_script_models = [];
			level.a_script_models[ "script_model" ] = getentarray( "script_model", "classname" );
			level.a_script_models[ "script_vehicle" ] = getentarray( "script_vehicle", "classname" );
			level.a_script_models[ "script_brushmodel" ] = getentarray( "script_brushmodel", "classname" );
			level.a_script_models_time = getTime();
		}
		if ( isDefined( self.is_vehicle ) && self.is_vehicle )
		{
			m_exist = _get_models_from_radiant_internals( "script_vehicle" );
		}
		else
		{
			m_exist = _get_models_from_radiant_internals( "script_model" );
			if ( !isDefined( m_exist ) )
			{
				m_exist = _get_models_from_radiant_internals( "script_brushmodel" );
			}
		}
		if ( isDefined( m_exist ) )
		{
			m_exist._radiant_ent = 1;
			a_models[ a_models.size ] = m_exist;
		}
		level thread _delete_scene_script_model_array();
	}
/#
	println( "*****RADIANT COUNT = " + level.from_radiant_count );
#/
	return a_models;
}

_get_models_from_radiant_internals( str_key_type )
{
	my_array = level.a_script_models[ str_key_type ];
	m_in_radiant = undefined;
	_a2025 = my_array;
	_k2025 = getFirstArrayKey( _a2025 );
	while ( isDefined( _k2025 ) )
	{
		m_in_radiant = _a2025[ _k2025 ];
		if ( isDefined( m_in_radiant.targetname ) )
		{
			if ( m_in_radiant.targetname == self.str_name )
			{
				return m_in_radiant;
			}
		}
		if ( isDefined( m_in_radiant.animname ) )
		{
			if ( m_in_radiant.animname == self.str_name )
			{
				return m_in_radiant;
			}
		}
		if ( isDefined( m_in_radiant.script_animname ) )
		{
			if ( m_in_radiant.script_animname == self.str_name )
			{
				return m_in_radiant;
			}
		}
		level.from_radiant_count++;
		_k2025 = getNextArrayKey( _a2025, _k2025 );
	}
	return undefined;
}

_delete_scene_script_model_array()
{
	level notify( "kill_del_scr_array_thread" );
	level endon( "kill_del_scr_array_thread" );
	while ( level.a_script_models_time == getTime() )
	{
		wait 0,05;
	}
	level.a_script_models = undefined;
	level.a_script_models_time = undefined;
}

_delete_scene_ai_spawner_array()
{
	level notify( "kill_del_ai_array_thread" );
	level endon( "kill_del_ai_array_thread" );
	wait 0,05;
	level.a_scene_ai_spawners = undefined;
}

_delete_models( str_scene, b_specific_models, b_keep_radiant_ents )
{
	if ( !isDefined( b_specific_models ) )
	{
		b_specific_models = 0;
	}
	if ( is_scene_deleted( str_scene ) )
	{
		return;
	}
	if ( !isDefined( level.a_scenes[ str_scene ].a_model_anims ) )
	{
		return;
	}
	_a2105 = level.a_scenes[ str_scene ].a_model_anims;
	_k2105 = getFirstArrayKey( _a2105 );
	while ( isDefined( _k2105 ) )
	{
		model = _a2105[ _k2105 ];
		if ( isDefined( model ) )
		{
			model enableclientlinkto();
			if ( isDefined( model.do_delete ) && model.do_delete && isDefined( model.is_drone_corpse ) || !model.is_drone_corpse && !b_specific_models && isDefined( b_keep_radiant_ents ) || !b_keep_radiant_ents && isDefined( model._radiant_ent ) && !model._radiant_ent )
			{
				if ( isDefined( model.n_player_number ) )
				{
					player = get_players()[ model.n_player_number ];
					player _reset_player_after_anim();
				}
				model thread _delete_at_frame_end();
				break;
			}
			else
			{
				if ( isDefined( model.b_disconnect_paths_after_scene ) && model.b_disconnect_paths_after_scene )
				{
					model disconnectpaths();
				}
			}
		}
		_k2105 = getNextArrayKey( _a2105, _k2105 );
	}
	__new = [];
	_a2131 = level.scene_sys.a_active_anim_models;
	__key = getFirstArrayKey( _a2131 );
	while ( isDefined( __key ) )
	{
		__value = _a2131[ __key ];
		if ( isDefined( __value ) )
		{
			if ( isstring( __key ) )
			{
				__new[ __key ] = __value;
				break;
			}
			else
			{
				__new[ __new.size ] = __value;
			}
		}
		__key = getNextArrayKey( _a2131, __key );
	}
	level.scene_sys.a_active_anim_models = __new;
	__new = [];
	_a2132 = level.a_scenes[ str_scene ].a_model_anims;
	__key = getFirstArrayKey( _a2132 );
	while ( isDefined( __key ) )
	{
		__value = _a2132[ __key ];
		if ( isDefined( __value ) )
		{
			if ( isstring( __key ) )
			{
				__new[ __key ] = __value;
				break;
			}
			else
			{
				__new[ __new.size ] = __value;
			}
		}
		__key = getNextArrayKey( _a2132, __key );
	}
	level.a_scenes[ str_scene ].a_model_anims = __new;
}

_delete_at_frame_end()
{
	self endon( "death" );
	self endon( "drone_corpse" );
	self._scene_deleting = 1;
	waittillframeend;
	self delete();
}

_reset_player_after_anim()
{
	self.s_scene_info = undefined;
	self.m_scene_model = undefined;
	self startcameratween( 0,2 );
	setsaveddvar( "player_standingViewHeight", self._scene_old_player_height );
	if ( !isDefined( self.b_weapons_disabled ) )
	{
		self player_enable_weapons();
	}
	self showviewmodel();
	self setlowready( 0 );
	self disableinvulnerability();
	self resetplayerviewratescale();
	self enableusability();
	self enableoffhandweapons();
	if ( isDefined( level.era ) && level.era != "twentytwenty" && level.era != "" )
	{
		self show_hud();
	}
	else
	{
		setsaveddvar( "cg_drawFriendlyNames", self._scene_old_draw_friendly_names );
	}
}

_delete_ais( str_scene, b_specific_ais )
{
	if ( is_scene_deleted( str_scene ) )
	{
		return;
	}
	if ( !isDefined( level.a_scenes[ str_scene ].a_ai_anims ) )
	{
		return;
	}
	if ( !isDefined( b_specific_ais ) )
	{
		b_specific_ais = 0;
	}
	_a2210 = level.a_scenes[ str_scene ].a_ai_anims;
	_k2210 = getFirstArrayKey( _a2210 );
	while ( isDefined( _k2210 ) )
	{
		ai = _a2210[ _k2210 ];
		if ( isDefined( ai ) )
		{
			ai enableclientlinkto();
			if ( !b_specific_ais || isDefined( ai.do_delete ) && ai.do_delete )
			{
				ai thread _delete_at_frame_end();
				break;
			}
			else
			{
				if ( isDefined( ai.do_give_back_weapon ) && ai.do_give_back_weapon )
				{
					ai gun_recall();
				}
				ai setcandamage( 1 );
			}
		}
		_k2210 = getNextArrayKey( _a2210, _k2210 );
	}
	__new = [];
	_a2231 = level.a_scenes[ str_scene ].a_ai_anims;
	__key = getFirstArrayKey( _a2231 );
	while ( isDefined( __key ) )
	{
		__value = _a2231[ __key ];
		if ( isDefined( __value ) )
		{
			if ( isstring( __key ) )
			{
				__new[ __key ] = __value;
				break;
			}
			else
			{
				__new[ __new.size ] = __value;
			}
		}
		__key = getNextArrayKey( _a2231, __key );
	}
	level.a_scenes[ str_scene ].a_ai_anims = __new;
}

add_scene( str_scene, str_align_targetname, do_reach, do_generic, do_loop, do_not_align )
{
	if ( !isDefined( level.scene_sys ) )
	{
		level.scene_sys = spawnstruct();
		level.scene_sys.str_current_scene = undefined;
		level.scene_sys.a_active_anim_models = [];
	}
	if ( !isDefined( level.a_scenes ) )
	{
		level.a_scenes = [];
	}
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for add_scene()" );
#/
/#
	assert( !isDefined( level.a_scenes[ str_scene ] ), "Scene, " + str_scene + ", has already been declared." );
#/
	if ( !level flag_exists( str_scene + "_started" ) )
	{
		flag_init( str_scene + "_started" );
	}
	if ( !level flag_exists( str_scene + "_first_frame" ) )
	{
		flag_init( str_scene + "_first_frame" );
	}
	if ( !level flag_exists( str_scene + "_done" ) )
	{
		flag_init( str_scene + "_done" );
	}
	s_scene_info = spawnstruct();
	s_scene_info.str_scene = str_scene;
	s_scene_info.a_anim_info = [];
	if ( isDefined( str_align_targetname ) )
	{
		s_scene_info.str_align_targetname = str_align_targetname;
	}
	else
	{
		s_scene_info.do_not_align = 1;
	}
	if ( isDefined( do_reach ) && do_reach )
	{
		s_scene_info.do_reach = do_reach;
	}
	if ( isDefined( do_generic ) && do_generic )
	{
		s_scene_info.do_generic = do_generic;
	}
	if ( isDefined( do_loop ) && do_loop )
	{
		s_scene_info.do_loop = do_loop;
	}
	if ( isDefined( do_not_align ) && do_not_align )
	{
		s_scene_info.do_not_align = do_not_align;
	}
	level.a_scenes[ str_scene ] = s_scene_info;
	level.scene_sys.str_current_scene = str_scene;
}

add_scene_loop( str_scene, str_align_targetname, do_reach, do_generic, do_not_align )
{
	add_scene( str_scene, str_align_targetname, do_reach, do_generic, 1, do_not_align );
}

add_actor_anim( str_animname, animation, do_hide_weapon, do_give_back_weapon, do_delete, do_not_allow_death, str_tag, str_spawner )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_actor_anim() in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( isDefined( animation ), "animation is a required argument for add_actor_anim() in scene, " + level.scene_sys.str_current_scene );
#/
	_basic_actor_setup( str_animname, animation, do_delete );
	if ( isDefined( do_hide_weapon ) && do_hide_weapon )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].do_hide_weapon = do_hide_weapon;
	}
	if ( isDefined( do_give_back_weapon ) && do_give_back_weapon )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].do_give_back_weapon = do_give_back_weapon;
	}
	if ( isDefined( do_not_allow_death ) && do_not_allow_death )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].do_not_allow_death = do_not_allow_death;
	}
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	if ( isDefined( str_spawner ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_spawner = str_spawner;
	}
}

add_actor_spawner( str_animname, str_spawner )
{
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_spawner = str_spawner;
}

add_optional_actor_anim( str_animname, animation, do_hide_weapon, do_give_back_weapon, do_delete, do_not_allow_death, str_tag, str_spawner )
{
	add_actor_anim( str_animname, animation, do_hide_weapon, do_give_back_weapon, do_delete, do_not_allow_death, str_tag, str_spawner );
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_optional = 1;
}

add_multiple_generic_actors( str_name, animation, do_hide_weapon, do_give_back_weapon, do_delete, do_not_allow_death )
{
/#
	assert( isDefined( str_name ), "str_name is a required argument for add_actor_generic_anim() in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( isDefined( animation ), "animation is a required argument for add_actor_generic_anim() in scene, " + level.scene_sys.str_current_scene );
#/
	add_actor_anim( str_name, animation, do_hide_weapon, do_give_back_weapon, do_delete, do_not_allow_death );
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_name ].has_multiple_ais = 1;
}

add_actor_model_anim( str_animname, animation, str_model, do_delete, str_tag, a_parts, str_spawner, b_spawn_collision, b_play_dead, do_not_allow_death )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_actor_model_anim() in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( isDefined( animation ), "animation is a required argument for add_actor_model_anim() in scene, " + level.scene_sys.str_current_scene );
#/
	if ( !isarray( a_parts ) )
	{
		a_parts = array( a_parts );
	}
	_basic_actor_setup( str_animname, animation, do_delete );
	if ( isDefined( str_model ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_model = str_model;
	}
	if ( isDefined( a_parts ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].a_parts = a_parts;
	}
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	if ( isDefined( str_spawner ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_spawner = str_spawner;
	}
	if ( isDefined( b_spawn_collision ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_spawn_collision = b_spawn_collision;
	}
	if ( isDefined( do_not_allow_death ) && !do_not_allow_death )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].do_not_allow_death = 0;
	}
	if ( isDefined( b_play_dead ) && b_play_dead )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_play_dead = b_play_dead;
	}
	if ( isDefined( level._add_cheap_actor_model_anim ) && level._add_cheap_actor_model_anim )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_cheap = 1;
	}
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_model = 1;
}

add_cheap_actor_model_anim( str_animname, animation, str_model, do_delete, str_tag, a_parts, str_spawner )
{
	level._add_cheap_actor_model_anim = 1;
	add_actor_model_anim( str_animname, animation, str_model, do_delete, str_tag, a_parts, str_spawner );
	level._add_cheap_actor_model_anim = undefined;
}

_basic_actor_setup( str_name, animation, do_delete )
{
/#
	assert( !isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_name ] ), "Actor, " + str_name + ", has already been declared for the scene, " + level.scene_sys.str_current_scene );
#/
	s_actor = spawnstruct();
	s_actor.str_name = str_name;
	s_actor.animation = animation;
	s_actor.anim_tree = -1;
	if ( isDefined( do_delete ) && do_delete )
	{
		s_actor.do_delete = do_delete;
	}
	s_actor _add_anim_to_current_scene();
}

add_prop_anim( str_animname, animation, str_model, do_delete, is_simple_prop, a_parts, str_tag, b_connect_paths )
{
	if ( !isarray( a_parts ) )
	{
		a_parts = array( a_parts );
	}
	_basic_prop_setup( str_animname, animation, do_delete, is_simple_prop, "add_prop_anim()" );
	if ( isDefined( str_model ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_model = str_model;
	}
	if ( isDefined( a_parts ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].a_parts = a_parts;
	}
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	if ( isDefined( b_connect_paths ) && b_connect_paths )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_connect_paths = 1;
	}
}

add_multiple_generic_props_from_radiant( str_name, animation, do_delete, is_simple_prop, a_parts )
{
	if ( !isarray( a_parts ) )
	{
		a_parts = array( a_parts );
	}
	_basic_prop_setup( str_name, animation, do_delete, is_simple_prop, "add_multiple_props_from_radiant" );
	if ( isDefined( a_parts ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_name ].a_parts = a_parts;
	}
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_name ].has_multiple_props = 1;
}

add_weapon_anim( str_animname, animation, str_weapon_name, do_delete, is_simple_prop, str_tag )
{
/#
	assert( isDefined( str_weapon_name ), "str_weapon_name is a required argument for add_weapon_anim() in scene, " + level.scene_sys.str_current_scene );
#/
	str_model = getweaponmodel( str_weapon_name );
	_basic_prop_setup( str_animname, animation, do_delete, is_simple_prop, "add_weapon_anim()" );
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_model = str_model;
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_weapon_name = str_weapon_name;
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_weapon = 1;
}

_basic_prop_setup( str_animname, animation, do_delete, is_simple_prop, str_function_name, animtree )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for " + str_function_name + " in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( isDefined( animation ), "animation is a required argument for " + str_function_name + " in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( !isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ] ), "Prop, " + str_animname + ", has already been declared for the scene, " + level.scene_sys.str_current_scene );
#/
	s_prop_anim = spawnstruct();
	s_prop_anim.str_name = str_animname;
	s_prop_anim.animation = animation;
	if ( isDefined( do_delete ) && do_delete )
	{
		s_prop_anim.do_delete = do_delete;
	}
	if ( isDefined( is_simple_prop ) && is_simple_prop )
	{
		s_prop_anim.is_simple_prop = is_simple_prop;
	}
	if ( isDefined( animtree ) )
	{
		s_prop_anim.anim_tree = animtree;
	}
	else
	{
		s_prop_anim.anim_tree = -1;
	}
	s_prop_anim.is_model = 1;
	s_prop_anim _add_anim_to_current_scene();
}

add_player_anim( str_animname, animation, do_delete, n_player_number, str_tag, do_delta, n_view_fraction, n_right_arc, n_left_arc, n_top_arc, n_bottom_arc, use_tag_angles, b_auto_center, b_use_camera_tween, b_keep_weapons )
{
	if ( !isDefined( n_player_number ) )
	{
		n_player_number = 0;
	}
	if ( !isDefined( do_delta ) )
	{
		do_delta = 0;
	}
	if ( !isDefined( n_view_fraction ) )
	{
		n_view_fraction = 1;
	}
	if ( !isDefined( n_right_arc ) )
	{
		n_right_arc = 180;
	}
	if ( !isDefined( n_left_arc ) )
	{
		n_left_arc = 180;
	}
	if ( !isDefined( n_top_arc ) )
	{
		n_top_arc = 180;
	}
	if ( !isDefined( n_bottom_arc ) )
	{
		n_bottom_arc = 180;
	}
	if ( !isDefined( use_tag_angles ) )
	{
		use_tag_angles = 1;
	}
	if ( !isDefined( b_auto_center ) )
	{
		b_auto_center = 1;
	}
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_player_anim() in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( isDefined( animation ), "animation is a required argument for add_player_anim() in scene, " + level.scene_sys.str_current_scene );
#/
/#
	assert( !isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ] ), "Player model, " + str_animname + ", has already been declared for the scene, " + level.scene_sys.str_current_scene );
#/
	s_player = spawnstruct();
	s_player.str_name = str_animname;
	s_player.animation = animation;
	s_player.anim_tree = -1;
	s_player.n_player_number = n_player_number;
	if ( isDefined( str_tag ) )
	{
		s_player.str_tag = str_tag;
	}
	if ( isDefined( do_delete ) && do_delete )
	{
		s_player.do_delete = do_delete;
	}
	if ( isDefined( do_delta ) && do_delta )
	{
		s_player.do_delta = do_delta;
	}
	if ( isDefined( b_use_camera_tween ) && b_use_camera_tween )
	{
		s_player.b_use_camera_tween = b_use_camera_tween;
	}
	if ( isDefined( b_keep_weapons ) && b_keep_weapons )
	{
		s_player.b_keep_weapons = b_keep_weapons;
	}
	s_player.n_view_fraction = n_view_fraction;
	s_player.n_right_arc = n_right_arc;
	s_player.n_left_arc = n_left_arc;
	s_player.n_top_arc = n_top_arc;
	s_player.n_bottom_arc = n_bottom_arc;
	s_player.use_tag_angles = use_tag_angles;
	s_player.b_auto_center = b_auto_center;
	s_player.is_model = 1;
	s_player _add_anim_to_current_scene();
}

set_player_anim_use_lowready( str_animname )
{
/#
	assert( isDefined( str_animname ), "SCENE: required param str_animname missing for _scene::set_player_anim_use_lowready()" );
#/
/#
	assert( isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ] ), "SCENE: add_player_anim before setting anim to use low ready" );
#/
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_use_low_ready = 1;
}

add_vehicle_anim( str_animname, animation, do_delete, a_parts, str_tag, b_animate_origin, str_vehicletype, str_model, str_destructibledef, do_not_allow_death )
{
	if ( !isarray( a_parts ) )
	{
		a_parts = array( a_parts );
	}
	_basic_prop_setup( str_animname, animation, do_delete, 0, "add_vehicle_anim()", -1 );
	if ( isDefined( a_parts ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].a_parts = a_parts;
	}
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	if ( isDefined( str_vehicletype ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_vehicletype = str_vehicletype;
	}
	if ( isDefined( str_model ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_model = str_model;
	}
	if ( isDefined( str_destructibledef ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_destructibledef = str_destructibledef;
	}
	if ( isDefined( do_not_allow_death ) && do_not_allow_death )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].do_not_allow_death = do_not_allow_death;
	}
	if ( isDefined( b_animate_origin ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_animate_origin = b_animate_origin;
	}
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_vehicle = 1;
}

_spawn_vehicle_for_anim()
{
	veh = spawnvehicle( self.str_model, self.str_name, self.str_vehicletype, ( 1, 1, 1 ), ( 1, 1, 1 ), self.str_destructibledef );
	maps/_vehicle::vehicle_init( veh );
	return veh;
}

set_vehicle_unusable_in_scene( str_animname )
{
	if ( isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ] ) )
	{
		if ( isDefined( level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_vehicle ) && level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_vehicle )
		{
			level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].not_usable = 1;
		}
		else
		{
/#
			assert( 0, "Non vehicle made unusable in scene: " + level.scene_sys.str_current_scene + " with animname: " + str_animname );
#/
		}
	}
	else
	{
/#
		assert( 0, "Couldn't find vehicle in scene: " + level.scene_sys.str_current_scene + " with animname: " + str_animname );
#/
	}
}

add_horse_anim( str_animname, animation, do_delete, a_parts, str_tag, b_animate_origin )
{
	if ( !isarray( a_parts ) )
	{
		a_parts = array( a_parts );
	}
	_basic_prop_setup( str_animname, animation, do_delete, 0, "add_horse_anim()", -1 );
	if ( isDefined( a_parts ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].a_parts = a_parts;
	}
	if ( isDefined( str_tag ) )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].str_tag = str_tag;
	}
	if ( isDefined( b_animate_origin ) && b_animate_origin )
	{
		level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].b_animate_origin = b_animate_origin;
	}
	level.a_scenes[ level.scene_sys.str_current_scene ].a_anim_info[ str_animname ].is_vehicle = 1;
}

add_notetrack_attach( str_animname, str_notetrack, str_model, str_tag, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_attach()" );
#/
/#
	assert( isDefined( str_model ), "str_model is a required argument for add_notetrack_attach()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_attach( str_animname, str_notetrack, str_model, str_tag, str_scene );
}

add_notetrack_detach( str_animname, str_notetrack, str_model, str_tag, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_detach()" );
#/
/#
	assert( isDefined( str_model ), "str_model is a required argument for add_notetrack_detach()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_detach( str_animname, str_notetrack, str_model, str_tag, str_scene );
}

add_notetrack_level_notify( str_animname, str_notetrack, str_notify, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_level_notify()" );
#/
/#
	assert( isDefined( str_notify ), "str_notify is a required argument for add_notetrack_level_notify()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_level_notify( str_animname, str_notetrack, str_notify, str_scene );
}

add_notetrack_custom_function( str_animname, str_notetrack, func_pointer, b_any_scene, passnote )
{
	if ( !isDefined( passnote ) )
	{
		passnote = 0;
	}
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_custom_function()" );
#/
/#
	assert( isDefined( func_pointer ), "func_pointer is a required argument for add_notetrack_custom_function()" );
#/
	str_scene = undefined;
	if ( isstring( b_any_scene ) )
	{
		str_scene = b_any_scene;
	}
	else
	{
		str_scene = _get_scene_name_for_notetrack( b_any_scene );
	}
	str_animname = _get_animname_for_notetrack( str_animname, str_scene );
	addnotetrack_customfunction( str_animname, str_notetrack, func_pointer, str_scene, passnote );
}

add_scene_custom_function( func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
/#
	assert( isDefined( func ), "func_pointer is a required argument for add_notetrack_custom_function()" );
#/
	str_scene = level.scene_sys.str_current_scene;
	if ( !isDefined( level.a_scenes[ str_scene ].a_start_funcs ) )
	{
		level.a_scenes[ str_scene ].a_start_funcs = [];
	}
	s_callback = spawnstruct();
	s_callback.func = func;
	s_callback.arg1 = arg1;
	s_callback.arg2 = arg2;
	s_callback.arg3 = arg3;
	s_callback.arg4 = arg4;
	s_callback.arg5 = arg5;
	s_callback.arg6 = arg6;
	level.a_scenes[ str_scene ].a_start_funcs[ level.a_scenes[ str_scene ].a_start_funcs.size ] = s_callback;
}

add_notetrack_exploder( str_animname, str_notetrack, n_exploder, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_exploder()" );
#/
/#
	assert( isDefined( n_exploder ), "n_exploder is a required argument for add_notetrack_exploder()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_exploder( str_animname, str_notetrack, n_exploder, str_scene );
}

add_notetrack_stop_exploder( str_animname, str_notetrack, n_exploder, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_stop_exploder()" );
#/
/#
	assert( isDefined( n_exploder ), "n_exploder is a required argument for add_notetrack_stop_exploder()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_stop_exploder( str_animname, str_notetrack, n_exploder, str_scene );
}

add_notetrack_flag( str_animname, str_notetrack, str_flag, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_flag()" );
#/
/#
	assert( isDefined( str_flag ), "str_flag is a required argument for add_notetrack_flag()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	if ( !level flag_exists( str_flag ) )
	{
		flag_init( str_flag );
	}
	addnotetrack_flag( str_animname, str_notetrack, str_flag, str_scene );
}

add_notetrack_fov( str_animname, str_notetrack, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_fov()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_fov( str_animname, str_notetrack, str_scene );
}

add_notetrack_fov_new( str_animname, str_notetrack, n_fov, n_time, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_fov()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_fov_new( str_animname, str_notetrack, n_fov, n_time, b_any_scene );
}

add_notetrack_fx_on_tag( str_animname, str_notetrack, str_effect, str_tag, b_on_threader, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_fx_on_tag()" );
#/
/#
	assert( isDefined( str_effect ), "str_effect is a required argument for add_notetrack_fx_on_tag()" );
#/
/#
	assert( isDefined( str_tag ), "str_tag is a required argument for add_notetrack_fx_on_tag()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_fxontag( str_animname, str_scene, str_notetrack, str_effect, str_tag, b_on_threader );
}

add_notetrack_sound( str_animname, str_notetrack, str_soundalias, b_any_scene )
{
/#
	assert( isDefined( str_animname ), "str_animname is a required argument for add_notetrack_sound()" );
#/
/#
	assert( isDefined( str_soundalias ), "str_soundalias is a required argument for add_notetrack_sound()" );
#/
	str_scene = _get_scene_name_for_notetrack( b_any_scene );
	str_animname = _get_animname_for_notetrack( str_animname );
	addnotetrack_sound( str_animname, str_notetrack, str_scene, str_soundalias );
}

is_scene_defined( str_scene )
{
/#
	assert( isDefined( str_scene ), "str_scene is a required argument for is_scene_defined()" );
#/
	if ( isDefined( level.a_scenes[ str_scene ] ) )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

_get_scene_name_for_notetrack( b_any_scene )
{
	if ( !isDefined( b_any_scene ) )
	{
		b_any_scene = 0;
	}
	if ( !isstring( b_any_scene ) )
	{
		if ( !b_any_scene )
		{
			return level.scene_sys.str_current_scene;
		}
	}
	else
	{
		return b_any_scene;
	}
}

_get_animname_for_notetrack( str_animname, str_scene )
{
	if ( !isDefined( str_scene ) )
	{
		str_scene = level.scene_sys.str_current_scene;
	}
	if ( isDefined( level.a_scenes[ str_scene ].do_generic ) && level.a_scenes[ str_scene ].do_generic )
	{
		str_animname = "generic";
	}
	return str_animname;
}

_preprocess_notetracks()
{
	str_scene = level.scene_sys.str_current_scene;
	waittill_asset_loaded( "xanim", string( self.animation ) );
	if ( is_scene_deleted( str_scene ) )
	{
		return;
	}
	notetracks = getnotetracksindelta( self.animation, 0,5, 9999 );
	n_anim_length = getanimlength( self.animation );
	a_fov = [];
	_a3341 = notetracks;
	_k3341 = getFirstArrayKey( _a3341 );
	while ( isDefined( _k3341 ) )
	{
		info = _a3341[ _k3341 ];
		str_notetrack = info[ 1 ];
		str_notetrack_no_comment = strtok( str_notetrack, "#" )[ 0 ];
		a_tokens = strtok( str_notetrack_no_comment, " " );
		n_notetrack_time = linear_map( info[ 2 ], 0, 1, 0, n_anim_length );
		switch( a_tokens[ 0 ] )
		{
			case "exploder":
				n_exploder = int( a_tokens[ 1 ] );
				add_notetrack_exploder( self.str_name, str_notetrack, n_exploder, 1 );
				break;
			case "stop_exploder":
				n_exploder = int( a_tokens[ 1 ] );
				add_notetrack_stop_exploder( self.str_name, str_notetrack, n_exploder, 1 );
				break;
			case "timescale":
				if ( isDefined( a_tokens[ 1 ] ) )
				{
					switch( a_tokens[ 1 ] )
					{
						case "slow":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_time_scale_slow, str_scene );
							break;
						break;
						case "med":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_time_scale_med, str_scene );
							break;
						break;
						case "fast":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_time_scale_fast, str_scene );
							break;
						break;
						case "off":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_time_scale_off, str_scene );
							break;
						break;
					}
				}
				break;
			case "rumble":
				if ( isDefined( a_tokens[ 1 ] ) )
				{
					switch( a_tokens[ 1 ] )
					{
						case "light":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_rumble_light, str_scene );
							break;
						break;
						case "med":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_rumble_med, str_scene );
							break;
						break;
						case "heavy":
							add_notetrack_custom_function( self.str_name, str_notetrack, ::_scene_rumble_heavy, str_scene );
							break;
						break;
					}
				}
				break;
			case "fov":
				if ( isDefined( a_tokens[ 1 ] ) )
				{
					if ( a_tokens[ 1 ] == "reset" )
					{
						a_tokens[ 1 ] = -1;
					}
					a_fov[ a_fov.size ] = array( str_notetrack, float( a_tokens[ 1 ] ), float( n_notetrack_time ) );
				}
				break;
		}
		_k3341 = getNextArrayKey( _a3341, _k3341 );
	}
	if ( a_fov.size > 0 )
	{
		_preprocess_fov_notetracks( a_fov, str_scene );
	}
}

_preprocess_fov_notetracks( a_fov, str_scene )
{
	i = a_fov.size - 1;
	while ( i >= 0 )
	{
		n_time_prev = 0;
		if ( isDefined( a_fov[ i - 1 ] ) )
		{
			str_notetrack = a_fov[ i - 1 ][ 0 ];
			n_time_prev = a_fov[ i - 1 ][ 2 ];
		}
		else
		{
			str_notetrack = "start";
		}
		n_fov = a_fov[ i ][ 1 ];
		n_time = a_fov[ i ][ 2 ] - n_time_prev;
		add_notetrack_fov_new( self.str_name, str_notetrack, n_fov, n_time, str_scene );
		i--;

	}
}

_scene_time_scale_slow( e_scene_object )
{
	timescale_tween( 0,2, 0,4, 0,5 );
}

_scene_time_scale_med( e_scene_object )
{
	timescale_tween( 0,4, 0,7, 0,5 );
}

_scene_time_scale_fast( e_scene_object )
{
	timescale_tween( 0,7, 0,9, 0,5 );
}

_scene_time_scale_off( e_scene_object )
{
	timescale_tween( undefined, 1, 0,5 );
}

_scene_rumble_light( e_scene_object )
{
	e_scene_object playrumbleonentity( "anim_light" );
}

_scene_rumble_med( e_scene_object )
{
	e_scene_object playrumbleonentity( "anim_med" );
}

_scene_rumble_heavy( e_scene_object )
{
	e_scene_object playrumbleonentity( "anim_heavy" );
}

run_scene_tests()
{
/#
	while ( 1 )
	{
		str_scene = getDvar( "run_scene" );
		if ( str_scene != "" )
		{
			setdvar( "run_scene", "" );
			level thread run_scene( str_scene, 0, 1 );
		}
		wait 0,05;
#/
	}
}

toggle_scene_menu()
{
/#
	setdvar( "scene_menu", 0 );
	b_displaying_menu = 0;
	while ( 1 )
	{
		b_scene_menu = getdvarintdefault( "scene_menu", 0 );
		if ( b_scene_menu )
		{
			if ( !b_displaying_menu )
			{
				level thread display_scene_menu();
				b_displaying_menu = 1;
			}
		}
		else
		{
			level notify( "scene_menu_cleanup" );
			b_displaying_menu = 0;
		}
		wait 0,5;
#/
	}
}

create_scene_hud( skipto, index )
{
/#
	alpha = 1;
	color = vectorScale( ( 1, 1, 1 ), 0,9 );
	if ( index != -1 )
	{
		if ( index != 5 )
		{
			alpha = 1 - ( abs( 5 - index ) / 5 );
		}
	}
	if ( alpha == 0 )
	{
		alpha = 0,05;
	}
	hudelem = newdebughudelem();
	hudelem.alignx = "left";
	hudelem.aligny = "middle";
	hudelem.x = 80;
	hudelem.y = 80 + ( index * 18 );
	hudelem settext( skipto );
	hudelem.alpha = 0;
	hudelem.foreground = 1;
	hudelem.color = color;
	hudelem.fontscale = 1,75;
	hudelem fadeovertime( 0,5 );
	hudelem.alpha = alpha;
	return hudelem;
#/
}

display_scene_menu()
{
/#
	if ( !isDefined( level.a_scenes ) || level.a_scenes.size <= 0 )
	{
		return;
	}
	level endon( "scene_menu_cleanup" );
	setsaveddvar( "hud_drawhud", 1 );
	names = getarraykeys( level.a_scenes );
	names[ names.size ] = "exit";
	elems = scene_list_menu();
	title = create_scene_hud( "Selected Scenes:", -1 );
	title.color = ( 1, 1, 1 );
	a_selected_scenes = [];
	_a3662 = level.a_scenes;
	str_scene = getFirstArrayKey( _a3662 );
	while ( isDefined( str_scene ) )
	{
		_ = _a3662[ str_scene ];
		if ( flag( str_scene + "_started" ) )
		{
			a_selected_scenes[ a_selected_scenes.size ] = str_scene;
		}
		str_scene = getNextArrayKey( _a3662, str_scene );
	}
	selected = 0;
	up_pressed = 0;
	down_pressed = 0;
	scene_list_settext( elems, names, selected, a_selected_scenes );
	old_selected = selected;
	level thread scene_menu_cleanup( elems, title );
	while ( 1 )
	{
		scene_list_settext( elems, names, selected, a_selected_scenes );
		if ( !up_pressed )
		{
			if ( get_players()[ 0 ] buttonpressed( "UPARROW" ) || get_players()[ 0 ] buttonpressed( "DPAD_UP" ) )
			{
				up_pressed = 1;
				selected--;

			}
		}
		else
		{
			if ( !get_players()[ 0 ] buttonpressed( "UPARROW" ) && !get_players()[ 0 ] buttonpressed( "DPAD_UP" ) )
			{
				up_pressed = 0;
			}
		}
		if ( !down_pressed )
		{
			if ( get_players()[ 0 ] buttonpressed( "DOWNARROW" ) || get_players()[ 0 ] buttonpressed( "DPAD_DOWN" ) )
			{
				down_pressed = 1;
				selected++;
			}
		}
		else
		{
			if ( !get_players()[ 0 ] buttonpressed( "DOWNARROW" ) && !get_players()[ 0 ] buttonpressed( "DPAD_DOWN" ) )
			{
				down_pressed = 0;
			}
		}
		if ( selected < 0 )
		{
			selected = names.size - 1;
		}
		if ( selected >= names.size )
		{
			selected = 0;
		}
		if ( get_players()[ 0 ] buttonpressed( "BUTTON_B" ) )
		{
			exit_scene_menu();
		}
		while ( !get_players()[ 0 ] buttonpressed( "kp_enter" ) || get_players()[ 0 ] buttonpressed( "BUTTON_A" ) && get_players()[ 0 ] buttonpressed( "enter" ) )
		{
			if ( names[ selected ] == "exit" )
			{
				exit_scene_menu();
			}
			else if ( isinarray( a_selected_scenes, names[ selected ] ) )
			{
				arrayremovevalue( a_selected_scenes, names[ selected ] );
				if ( !is_scene_deleted( names[ selected ] ) )
				{
					delete_scene_all( names[ selected ], 0, 1 );
				}
			}
			else
			{
				if ( !is_scene_deleted( names[ selected ] ) )
				{
					a_selected_scenes[ a_selected_scenes.size ] = names[ selected ];
					setdvar( "run_scene", names[ selected ] );
				}
			}
			while ( !get_players()[ 0 ] buttonpressed( "kp_enter" ) || get_players()[ 0 ] buttonpressed( "BUTTON_A" ) && get_players()[ 0 ] buttonpressed( "enter" ) )
			{
				wait 0,05;
			}
		}
		wait 0,05;
#/
	}
}

exit_scene_menu()
{
/#
	setdvar( "scene_menu", 0 );
	level notify( "scene_menu_cleanup" );
#/
}

scene_list_menu()
{
/#
	hud_array = [];
	i = 0;
	while ( i < 11 )
	{
		hud = create_scene_hud( "", i );
		hud_array[ hud_array.size ] = hud;
		i++;
	}
	return hud_array;
#/
}

scene_list_settext( hud_array, strings, num, a_selected_scenes )
{
/#
	i = 0;
	while ( i < hud_array.size )
	{
		index = i + ( num - 5 );
		if ( isDefined( strings[ index ] ) )
		{
			text = strings[ index ];
		}
		else
		{
			text = "";
		}
		if ( is_scene_deleted( text ) )
		{
			hud_array[ i ].color = ( 0,9, 0,5, 0,5 );
			text += "(deleted)";
		}
		else if ( is_scene_selected( text, a_selected_scenes ) )
		{
			hud_array[ i ].color = ( 0,5, 0,9, 0,5 );
		}
		else
		{
			hud_array[ i ].color = vectorScale( ( 1, 1, 1 ), 0,9 );
		}
		if ( i == 5 )
		{
			text = ">" + text + "<";
		}
		hud_array[ i ] settext( text );
		i++;
#/
	}
}

is_scene_selected( str_scene, a_selected_scenes )
{
/#
	if ( str_scene != "" && str_scene != "exit" )
	{
		if ( flag( str_scene + "_started" ) )
		{
			return 1;
		}
		if ( isinarray( a_selected_scenes, str_scene ) )
		{
			return 1;
		}
	}
	return 0;
#/
}

scene_menu_cleanup( elems, title )
{
/#
	level waittill( "scene_menu_cleanup" );
	title destroy();
	i = 0;
	while ( i < elems.size )
	{
		elems[ i ] destroy();
		i++;
#/
	}
}
