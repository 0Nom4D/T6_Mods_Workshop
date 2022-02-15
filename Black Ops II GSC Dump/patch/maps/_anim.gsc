#include maps/_turret;
#include animscripts/animmode;
#include animscripts/face;
#include animscripts/utility;
#include animscripts/shared;
#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "generic_human" );

anim_reach( ents, scene, animname_override )
{
	ents = build_ent_array( ents );
	do_anim_reach( ents, scene, undefined, animname_override, 0 );
}

anim_reach_aligned( ents, scene, tag, animname_override )
{
	ents = build_ent_array( ents );
	do_anim_reach( ents, scene, tag, animname_override, 1 );
}

anim_generic_reach( ents, scene )
{
	anim_reach( ents, scene, "generic" );
}

anim_generic_reach_aligned( ents, scene, tag )
{
	anim_reach_aligned( ents, scene, tag, "generic" );
}

anim_reach_idle( guys, scene, idle )
{
	guys = build_ent_array( guys );
	ent = spawnstruct();
	ent.count = guys.size;
	i = 0;
	while ( i < guys.size )
	{
		thread reach_idle( guys[ i ], scene, idle, ent );
		i++;
	}
	while ( ent.count )
	{
		ent waittill( "reach_idle_goal" );
	}
}

anim_teleport( ents, scene, tag, animname_override )
{
	ents = build_ent_array( ents );
	pos = get_anim_position( tag );
	org = pos[ "origin" ];
	angles = pos[ "angles" ];
	i = 0;
	while ( i < ents.size )
	{
		ent = ents[ i ];
		startorg = getstartorigin( org, angles, ent get_anim( scene, animname_override ) );
		if ( issentient( ent ) )
		{
			ent teleport( startorg );
			i++;
			continue;
		}
		else
		{
			ent.origin = startorg;
		}
		i++;
	}
}

anim_single( ents, scene, animname_override )
{
	ents = build_ent_array( ents );
	do_anim_single( ents, scene, undefined, animname_override, 0 );
}

anim_single_aligned( ents, scene, tag, animname_override, n_lerp_time )
{
	ents = build_ent_array( ents );
	do_anim_single( ents, scene, tag, animname_override, 1, n_lerp_time );
}

anim_first_frame( ents, scene, tag, animname_override )
{
	pos_array = get_anim_position( tag );
	org = pos_array[ "origin" ];
	angles = pos_array[ "angles" ];
	ents = build_ent_array( ents );
	self array_ent_thread( ents, ::anim_first_frame_on_guy, scene, org, angles, animname_override );
}

anim_generic( ents, scene )
{
	anim_single( ents, scene, "generic" );
}

anim_generic_aligned( ents, scene, tag, n_lerp_time )
{
	anim_single_aligned( ents, scene, tag, "generic", n_lerp_time );
}

anim_loop( ents, scene, ender, animname_override )
{
	ents = build_ent_array( ents );
/#
	if ( !debug_check( ents, scene, animname_override ) )
	{
		return;
#/
	}
	guypackets = [];
	i = 0;
	while ( i < ents.size )
	{
		packet = [];
		packet[ "guy" ] = ents[ i ];
		packet[ "entity" ] = packet[ "guy" ];
		guypackets[ guypackets.size ] = packet;
		i++;
	}
	anim_loop_packet( guypackets, scene, ender, animname_override );
}

anim_generic_loop( ents, scene, ender )
{
	anim_loop( ents, scene, ender, "generic" );
}

anim_loop_aligned( ents, scene, tag, ender, animname_override, n_lerp_time )
{
	ents = build_ent_array( ents );
/#
	if ( !debug_check( ents, scene, animname_override ) )
	{
		return;
#/
	}
	guypackets = [];
	i = 0;
	while ( i < ents.size )
	{
		packet = [];
		packet[ "guy" ] = ents[ i ];
		packet[ "entity" ] = self;
		packet[ "tag" ] = tag;
		guypackets[ guypackets.size ] = packet;
		i++;
	}
/#
	assert( isDefined( self.angles ), "Alignment node does not have angles specified." );
#/
	anim_loop_packet( guypackets, scene, ender, animname_override, n_lerp_time );
}

anim_generic_loop_aligned( ents, scene, tag, ender, n_lerp_time )
{
	anim_loop_aligned( ents, scene, tag, ender, "generic", n_lerp_time );
}

anim_custom_animmode( ents, custom_animmode, scene, tag, animname_override )
{
	ents = build_ent_array( ents );
	array = get_anim_position( tag );
	org = array[ "origin" ];
	angles = array[ "angles" ];
	i = 0;
	while ( i < ents.size )
	{
		thread anim_custom_animmode_on_guy( ents[ i ], custom_animmode, scene, org, angles, animname_override );
		i++;
	}
/#
	assert( isDefined( ents[ 0 ] ), "anim_custom_animmode called without a guy in the array" );
#/
	ents[ 0 ] wait_until_anim_finishes( scene );
	self notify( scene );
}

anim_generic_custom_animmode( ents, custom_animmode, scene, tag )
{
	anim_custom_animmode( ents, custom_animmode, scene, tag, "generic" );
}

anim_set_time( guys, scene, time )
{
	array_thread( guys, ::anim_self_set_time, scene, time );
}

addnotetrack_dialogue( animname, notetrack, scene, soundalias, pg_soundalias )
{
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "dialog" ] = soundalias;
	level.scr_notetrack[ animname ][ num ][ "pg_dialog" ] = pg_soundalias;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

removenotetrack_dialogue( animname, notetrack, scene, soundalias )
{
/#
	assert( isDefined( level.scr_notetrack[ animname ] ), "Animname not found in scr_notetrack." );
#/
	tmp_array = [];
	i = 0;
	while ( i < level.scr_notetrack[ animname ].size )
	{
		if ( level.scr_notetrack[ animname ][ i ][ "notetrack" ] == notetrack )
		{
			dialog = level.scr_notetrack[ animname ][ i ][ "dialog" ];
			if ( !isDefined( dialog ) )
			{
				dialog = level.scr_notetrack[ animname ][ i ][ "dialogue" ];
			}
			if ( isDefined( dialog ) && dialog == soundalias )
			{
				if ( isDefined( scene ) && isDefined( level.scr_notetrack[ animname ][ i ][ "scene" ] ) )
				{
					if ( level.scr_notetrack[ animname ][ i ][ "scene" ] == scene )
					{
						i++;
						continue;
					}
					else }
				else }
		}
		else num = tmp_array.size;
		tmp_array[ num ] = level.scr_notetrack[ animname ][ i ];
		i++;
	}
/#
	assert( tmp_array.size < level.scr_notetrack[ animname ].size, "Notetrack not found." );
#/
	level.scr_notetrack[ animname ] = tmp_array;
}

addnotetrack_sound( animname, notetrack, scene, soundalias )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	array = [];
	array[ "notetrack" ] = notetrack;
	array[ "sound" ] = soundalias;
	array[ "scene" ] = scene;
	if ( !isDefined( level.scr_notetrack ) )
	{
		level.scr_notetrack = [];
		level.scr_notetrack[ animname ] = [];
	}
	else
	{
		if ( !isDefined( level.scr_notetrack[ animname ] ) )
		{
			level.scr_notetrack[ animname ] = [];
		}
	}
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = array;
}

addonstart_animsound( animname, scene, soundalias )
{
	if ( !isDefined( level.scr_animsound[ animname ] ) )
	{
		level.scr_animsound[ animname ] = [];
	}
	level.scr_animsound[ animname ][ scene ] = soundalias;
}

addnotetrack_animsound( animname, scene, notetrack, soundalias )
{
	if ( !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	array = [];
	array[ "notetrack" ] = notetrack;
	array[ "sound" ] = soundalias;
	array[ "created_by_animSound" ] = 1;
	array[ "scene" ] = scene;
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = array;
}

addnotetrack_attach( animname, notetrack, model, tag, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "attach model" ] = model;
	level.scr_notetrack[ animname ][ num ][ "selftag" ] = tag;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

addnotetrack_detach( animname, notetrack, model, tag, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "detach model" ] = model;
	level.scr_notetrack[ animname ][ num ][ "selftag" ] = tag;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

addnotetrack_fov( animname, notetrack, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "change fov" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

addnotetrack_fov_new( animname, notetrack, n_fov, n_time, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	if ( n_fov == -1 )
	{
		n_fov = getDvarFloat( "cg_fov_default" );
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "fov" ] = n_fov;
	level.scr_notetrack[ animname ][ num ][ "time" ] = n_time;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

addnotetrack_level_notify( animname, notetrack, str_notify, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = notetrack;
	level.scr_notetrack[ animname ][ num ][ "level notify" ] = str_notify;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
}

addnotetrack_customfunction( animname, str_notetrack, function, scene, passnoteback )
{
	if ( !isDefined( str_notetrack ) )
	{
		str_notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	if ( !isDefined( passnoteback ) )
	{
		passnoteback = 0;
	}
	if ( !isDefined( level.scr_notetrack ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	num = 0;
	if ( isDefined( level.scr_notetrack[ animname ] ) )
	{
		_a635 = level.scr_notetrack[ animname ];
		_k635 = getFirstArrayKey( _a635 );
		while ( isDefined( _k635 ) )
		{
			notetrack = _a635[ _k635 ];
			if ( notetrack[ "scene" ] == scene && notetrack[ "notetrack" ] == str_notetrack && isDefined( notetrack[ "function" ] ) && notetrack[ "function" ] == function )
			{
				return;
			}
			_k635 = getNextArrayKey( _a635, _k635 );
		}
		num = level.scr_notetrack[ animname ].size;
	}
	level.scr_notetrack[ animname ][ num ][ "notetrack" ] = str_notetrack;
	level.scr_notetrack[ animname ][ num ][ "function" ] = function;
	level.scr_notetrack[ animname ][ num ][ "scene" ] = scene;
	level.scr_notetrack[ animname ][ num ][ "noteback" ] = passnoteback;
}

notetrack_customfunction_exists( animname, notetrack, function, scene )
{
	while ( isDefined( level.scr_notetrack ) && isDefined( level.scr_notetrack[ animname ] ) )
	{
		keys = getarraykeys( level.scr_notetrack[ animname ] );
		i = 0;
		while ( i < keys.size )
		{
			if ( isDefined( level.scr_notetrack[ animname ][ keys[ i ] ] ) && isDefined( level.scr_notetrack[ animname ][ keys[ i ] ][ "notetrack" ] ) && isDefined( level.scr_notetrack[ animname ][ keys[ i ] ][ "scene" ] ) && isDefined( level.scr_notetrack[ animname ][ keys[ i ] ][ "function" ] ) && level.scr_notetrack[ animname ][ keys[ i ] ][ "notetrack" ] == notetrack && level.scr_notetrack[ animname ][ keys[ i ] ][ "scene" ] == scene && level.scr_notetrack[ animname ][ keys[ i ] ][ "function" ] == function )
			{
				return 1;
			}
			i++;
		}
	}
	return 0;
}

addnotetrack_flag( animname, notetrack, flag, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	if ( !isDefined( level.scr_notetrack ) || !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	add_note = [];
	add_note[ "notetrack" ] = notetrack;
	add_note[ "flag" ] = flag;
	add_note[ "scene" ] = scene;
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = add_note;
	if ( !isDefined( level.flag[ flag ] ) )
	{
		flag_init( flag );
	}
}

addnotetrack_fxontag( animname, scene, notetrack, effect, tag, on_threader )
{
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( level.scr_notetrack ) || !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	add_note = [];
	add_note[ "notetrack" ] = notetrack;
	add_note[ "scene" ] = scene;
	add_note[ "effect" ] = effect;
	if ( isDefined( on_threader ) && on_threader )
	{
		add_note[ "tag" ] = tag;
	}
	else
	{
		add_note[ "selftag" ] = tag;
	}
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = add_note;
}

addnotetrack_exploder( animname, notetrack, exploder, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( level.scr_notetrack ) || !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	add_note = [];
	add_note[ "notetrack" ] = notetrack;
	add_note[ "exploder" ] = exploder;
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	add_note[ "scene" ] = scene;
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = add_note;
}

addnotetrack_stop_exploder( animname, notetrack, exploder, scene )
{
	if ( !isDefined( notetrack ) )
	{
		notetrack = "start";
	}
	if ( !isDefined( level.scr_notetrack ) || !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	add_note = [];
	add_note[ "notetrack" ] = notetrack;
	add_note[ "stop_exploder" ] = exploder;
	if ( !isDefined( scene ) )
	{
		scene = "any";
	}
	add_note[ "scene" ] = scene;
	level.scr_notetrack[ animname ][ level.scr_notetrack[ animname ].size ] = add_note;
}

set_animname( ents, animname )
{
	i = 0;
	while ( i < ents.size )
	{
		ents[ i ].animname = animname;
		i++;
	}
}

anim_set_blend_in_time( time )
{
	self._anim_blend_in_time = time;
}

anim_set_blend_out_time( time )
{
	self._anim_blend_out_time = time;
}

get_anim( scene, animname )
{
	if ( !isDefined( animname ) )
	{
		animname = self.animname;
	}
	if ( isDefined( level.scr_anim[ animname ] ) )
	{
		if ( isarray( level.scr_anim[ animname ][ scene ] ) )
		{
			return random( level.scr_anim[ animname ][ scene ] );
		}
		return level.scr_anim[ animname ][ scene ];
	}
}

init()
{
	if ( !isDefined( level.scr_special_notetrack ) )
	{
		level.scr_special_notetrack = [];
	}
	if ( !isDefined( level.scr_notetrack ) )
	{
		level.scr_notetrack = [];
	}
	if ( !isDefined( level.scr_face ) )
	{
		level.scr_face = [];
	}
	if ( !isDefined( level.scr_look ) )
	{
		level.scr_look = [];
	}
	if ( !isDefined( level.scr_animsound ) )
	{
		level.scr_animsound = [];
	}
	if ( !isDefined( level.scr_sound ) )
	{
		level.scr_sound = [];
	}
	if ( !isDefined( level.scr_radio ) )
	{
		level.scr_radio = [];
	}
	if ( !isDefined( level.scr_text ) )
	{
		level.scr_text = [];
	}
	if ( !isDefined( level.scr_anim ) )
	{
		level.scr_anim[ 0 ][ 0 ] = 0;
	}
	if ( !isDefined( level.scr_radio ) )
	{
		level.scr_radio = [];
	}
}

build_ent_array( ents )
{
	ent_array = [];
	if ( isarray( ents ) )
	{
		ent_array = ents;
	}
	else
	{
		ent_array[ 0 ] = ents;
	}
	return ent_array;
}

wait_until_anim_finishes( scene )
{
	self endon( "finished_custom_animmode" + scene );
	self waittill( "death" );
}

debug_check( ents, scene, animname_override )
{
/#
	if ( !isDefined( scene ) )
	{
		assertmsg( "maps/_anim: undefined scene for animation." );
		return 0;
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( !ents[ i ] assert_existance_of_anim( scene, animname_override ) )
		{
			return 0;
		}
		i++;
	}
	return 1;
#/
}

is_a_sound_only_scene( scene, animname )
{
	if ( !isDefined( animname ) )
	{
		animname = self.animname;
	}
	if ( !isDefined( animname ) )
	{
/#
		assertmsg( "Animating character of type " + self.classname + " has no animname." );
#/
		return 0;
	}
	has_anim = 0;
	has_sound = 1;
	if ( isDefined( level.scr_anim[ animname ] ) )
	{
		if ( isDefined( level.scr_anim[ animname ][ scene ] ) )
		{
			has_anim = 1;
		}
	}
	if ( isDefined( level.scr_sound[ animname ] ) )
	{
		if ( isDefined( level.scr_sound[ animname ][ scene ] ) )
		{
			has_sound = 1;
		}
	}
	if ( has_anim )
	{
		return 0;
	}
	return has_sound;
}

assert_existance_of_anim( scene, animname )
{
/#
	if ( !isDefined( animname ) )
	{
		animname = self.animname;
	}
	if ( !isDefined( animname ) )
	{
		assertmsg( "Animating character of type " + self.classname + " has no animname." );
		return 0;
	}
	has_anim = 0;
	if ( isDefined( level.scr_anim[ animname ] ) )
	{
		has_anim = 1;
		if ( isDefined( level.scr_anim[ animname ][ scene ] ) )
		{
			return 1;
		}
	}
	has_sound = 0;
	if ( isDefined( level.scr_sound[ animname ] ) )
	{
		has_sound = 1;
		if ( is_mature() || !pg_sound_exists( animname, scene ) )
		{
			if ( isDefined( level.scr_sound[ animname ][ scene ] ) )
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	if ( has_anim || has_sound )
	{
		while ( has_anim )
		{
			array = getarraykeys( level.scr_anim[ animname ] );
			println( "Legal scene scenes for " + animname + ":" );
			i = 0;
			while ( i < array.size )
			{
				println( array[ i ] );
				i++;
			}
		}
		while ( has_sound )
		{
			array = getarraykeys( level.scr_sound[ animname ] );
			println( "Legal scr_sound scenes for " + animname + ":" );
			i = 0;
			while ( i < array.size )
			{
				println( array[ i ] );
				i++;
			}
		}
		assertmsg( "Guy with animname "" + animname + "" is trying to do scene "" + scene + "" there is no level.scr_anim or level.scr_sound for that animname" );
		return 0;
	}
	keys = getarraykeys( level.scr_anim );
	keys = arraycombine( keys, getarraykeys( level.scr_sound ), 1, 0 );
	i = 0;
	while ( i < keys.size )
	{
		println( keys[ i ] );
		i++;
	}
	assertmsg( "Animname " + animname + " is not setup to do animations. See above for list of legal animnames." );
	return 0;
#/
}

anim_first_frame_on_guy( guy, scene, org, angles, animname_override )
{
	anim_ent = guy get_anim_ent();
	if ( isDefined( animname_override ) )
	{
		animname = animname_override;
	}
	else
	{
		animname = anim_ent.animname;
	}
/#
	anim_ent assert_existance_of_anim( scene, animname );
	self thread anim_info_render_thread( guy, scene, org, angles, animname, scene, 0, 1 );
#/
	animation = anim_ent get_anim( scene, animname );
	anim_ent animscripted( "anim_first_frame", org, angles, animation, "normal", anim_ent.root_anim, 0, 0 );
}

anim_custom_animmode_on_guy( guy, custom_animmode, scene, org, angles, animname_override )
{
	animname = undefined;
	if ( isDefined( animname_override ) )
	{
		animname = animname_override;
	}
	else
	{
		animname = guy.animname;
	}
/#
	guy assert_existance_of_anim( scene, animname );
#/
/#
	assert( isai( guy ), "Tried to do custom_animmode on a non ai" );
#/
	guy set_start_pos( scene, org, angles, animname_override );
	guy._animmode = custom_animmode;
	guy._custom_anim = scene;
	guy._tag_entity = self;
	guy._scene = scene;
	guy._animname = animname;
	guy animcustom( ::animscripts/animmode::main );
}

anim_loop_packet( guypackets, scene, ender, animname_override, n_lerp_time )
{
	if ( !isDefined( ender ) )
	{
		ender = "stop_loop";
	}
	baseguy = undefined;
	i = 0;
	while ( i < guypackets.size )
	{
		guy = guypackets[ i ][ "guy" ];
		if ( !isDefined( guy ) )
		{
			i++;
			continue;
		}
		else
		{
			guy = guy get_anim_ent();
			if ( i == 0 )
			{
				baseguy = guy;
/#
				self thread looping_anim_ender( baseguy, ender );
#/
			}
			if ( !isDefined( guy._animactive ) )
			{
				guy._animactive = 0;
			}
			guy _stop_anim_threads();
			guy.anim_loop_ender = ender;
			guy endon( ender );
			guy endon( "death" );
			guy._animactive++;
		}
		i++;
	}
	self endon( ender );
/#
	if ( !isDefined( baseguy.loops ) )
	{
		baseguy.loops = 0;
	}
	thread printloops( baseguy, scene );
#/
	anim_string = "looping anim";
	base_animname = undefined;
	if ( isDefined( animname_override ) )
	{
		base_animname = animname_override;
	}
	else
	{
		base_animname = baseguy.animname;
	}
/#
	assert( isarray( level.scr_anim[ base_animname ][ scene ] ), "Looping anims must have an array entry in level.scr_anim! i.e. [animname][scene][0]" );
#/
	idleanim = 0;
	lastidleanim = 0;
	while ( 1 )
	{
		idleanim = anim_weight( base_animname, scene );
		while ( idleanim == lastidleanim && idleanim != 0 )
		{
			idleanim = anim_weight( base_animname, scene );
		}
		lastidleanim = idleanim;
		scriptedanimationindex = -1;
		scriptedanimationtime = 999999;
		scriptedsoundindex = -1;
		i = 0;
		while ( i < guypackets.size )
		{
			guy = guypackets[ i ][ "guy" ];
			blend_in = guy._anim_blend_in_time;
			blend_out = guy._anim_blend_out_time;
			if ( !isDefined( guy ) )
			{
/#
				iprintlnbold( "I am dead YEAH!!!!!" );
#/
				return;
			}
			guy = guy get_anim_ent();
			pos = get_anim_position( guypackets[ i ][ "tag" ] );
			org = pos[ "origin" ];
			angles = pos[ "angles" ];
			entity = guypackets[ i ][ "entity" ];
			if ( !isDefined( org ) )
			{
				org = guy.origin;
			}
			if ( !isDefined( angles ) )
			{
				angles = guy.angles;
			}
			dofacialanim = 0;
			dodialogue = 0;
			doanimation = 0;
			dotext = 0;
			facialanim = undefined;
			dialogue = undefined;
			animname = undefined;
			if ( isDefined( animname_override ) )
			{
				animname = animname_override;
			}
			else
			{
				animname = guy.animname;
			}
			if ( isDefined( level.scr_face[ animname ] ) && isDefined( level.scr_face[ animname ][ scene ] ) && isDefined( level.scr_face[ animname ][ scene ][ idleanim ] ) )
			{
				dofacialanim = 1;
				facialanim = level.scr_face[ animname ][ scene ][ idleanim ];
			}
			if ( is_mature() || !pg_loopanim_sound_exists( animname, scene, idleanim ) )
			{
				if ( loopanim_sound_exists( animname, scene, idleanim ) )
				{
					dodialogue = 1;
					dialogue = level.scr_sound[ animname ][ scene ][ idleanim ];
				}
			}
			else
			{
				if ( pg_loopanim_sound_exists( animname, scene, idleanim ) )
				{
					dodialogue = 1;
					dialogue = level.scr_sound[ animname ][ scene + "_pg" ][ idleanim ];
				}
			}
			if ( isDefined( level.scr_animsound[ animname ] ) && isDefined( level.scr_animsound[ animname ][ idleanim + scene ] ) )
			{
				guy playsound( level.scr_animsound[ animname ][ idleanim + scene ] );
			}
/#
			if ( getdebugdvar( "animsound" ) == "on" )
			{
				guy thread animsound_start_tracker_loop( scene, idleanim, animname );
#/
			}
			if ( isDefined( level.scr_anim[ animname ] ) && isDefined( level.scr_anim[ animname ][ scene ] ) )
			{
				doanimation = 1;
			}
/#
			if ( isDefined( level.scr_text[ animname ] ) && isDefined( level.scr_text[ animname ][ scene ] ) )
			{
				dotext = 1;
#/
			}
			if ( doanimation )
			{
/#
				if ( getDvarInt( #"0099037B" ) )
				{
					self thread rec_anim_origin_render( org, angles );
				}
				self thread anim_info_render_thread( guy, scene, org, angles, animname, ender, 0 );
#/
				if ( guy.classname == "script_vehicle" && isDefined( guy.supportsanimscripted ) && !guy.supportsanimscripted )
				{
					guy.origin = org;
					guy.angles = angles;
					guy setflaggedanimknobrestart( anim_string, level.scr_anim[ animname ][ scene ][ idleanim ], 1, blend_in, 1 );
				}
				else
				{
					guy last_anim_time_check();
					guy animscripted( anim_string, org, angles, level.scr_anim[ animname ][ scene ][ idleanim ], "normal", undefined, undefined, blend_in, n_lerp_time );
				}
				guy notify( "_anim_playing" );
				animtime = getanimlength( level.scr_anim[ animname ][ scene ][ idleanim ] );
				if ( animtime < scriptedanimationtime )
				{
					scriptedanimationtime = animtime;
					scriptedanimationindex = i;
				}
				thread notetrack_wait( guy, anim_string, scene, animname );
				thread animscriptdonotetracksthread( guy, anim_string );
			}
			if ( dofacialanim || dodialogue )
			{
				if ( doanimation )
				{
					guy sayspecificdialogue( facialanim, dialogue, 1 );
				}
				else
				{
					guy sayspecificdialogue( facialanim, dialogue, 1, anim_string );
				}
				scriptedsoundindex = i;
			}
/#
			if ( dotext && !dodialogue )
			{
				iprintlnbold( level.scr_text[ animname ][ scene ] );
#/
			}
			i++;
		}
		if ( scriptedanimationindex != -1 )
		{
			guypackets[ scriptedanimationindex ][ "guy" ] get_anim_ent() waittillmatch( anim_string );
			return "end";
			continue;
		}
		else
		{
			if ( scriptedsoundindex != -1 )
			{
				guypackets[ scriptedsoundindex ][ "guy" ] get_anim_ent() waittill( anim_string );
			}
		}
	}
}

anim_single_failsafeonguy( owner, scene )
{
/#
	if ( getdebugdvar( "debug_animfailsafe" ) != "on" )
	{
		return;
	}
	owner endon( scene );
	owner endon( "death" );
	self endon( "death" );
	name = self.classname;
	num = self getentnum();
	wait 60;
	println( "Guy had classname " + name + " and entnum " + num );
	waittillframeend;
	assert( 0, "Animation "" + scene + "" did not finish after 60 seconds. See note above" );
#/
}

anim_single_failsafe( guy, scene )
{
	i = 0;
	while ( i < guy.size )
	{
		guy[ i ] thread anim_single_failsafeonguy( self, scene );
		i++;
	}
}

do_anim_single( guys, scene, tag, animname_override, aligned, n_lerp_time )
{
/#
	thread anim_single_failsafe( guys, scene );
#/
	pos = get_anim_position( tag );
	org = pos[ "origin" ];
	angles = pos[ "angles" ];
	tracker = spawnstruct();
	tracker.scriptedanimationtime = 999999;
	tracker.scriptedanimationindex = -1;
	tracker.scriptedsoundindex = -1;
	tracker.scriptedfaceindex = -1;
/#
	if ( aligned )
	{
		if ( getDvarInt( #"0099037B" ) )
		{
			self thread rec_anim_origin_render( org, angles );
#/
		}
	}
	i = 0;
	while ( i < guys.size )
	{
		if ( !isDefined( guys[ i ] ) )
		{
/#
			assertmsg( "_anim::do_anim_single - trying to play animation on undefined ent." );
#/
			return;
		}
		thread anim_single_thread( guys, i, scene, org, angles, animname_override, aligned, n_lerp_time, tracker );
		i++;
	}
	if ( tracker.scriptedanimationindex != -1 )
	{
		ent = spawnstruct();
		ent thread anim_deathnotify( guys[ tracker.scriptedanimationindex ], scene );
		ent thread anim_animationendnotify( guys[ tracker.scriptedanimationindex ], scene );
		ent waittill( scene );
	}
	else if ( tracker.scriptedfaceindex != -1 )
	{
		ent = spawnstruct();
		ent thread anim_deathnotify( guys[ tracker.scriptedfaceindex ], scene );
		ent thread anim_facialendnotify( guys[ tracker.scriptedfaceindex ], scene );
		ent waittill( scene );
	}
	else
	{
		if ( tracker.scriptedsoundindex != -1 )
		{
			ent = spawnstruct();
			ent thread anim_deathnotify( guys[ tracker.scriptedsoundindex ], scene );
			ent thread anim_dialogueendnotify( guys[ tracker.scriptedsoundindex ], scene );
			ent waittill( scene );
		}
	}
	i = 0;
	while ( i < guys.size )
	{
		if ( !isDefined( guys[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			guys[ i ]._animactive--;

			guys[ i ]._lastanimtime = getTime();
/#
			assert( guys[ i ]._animactive >= 0 );
#/
		}
		i++;
	}
	self notify( scene );
}

_stop_anim_threads()
{
	if ( isDefined( self.anim_loop_ender ) )
	{
		self notify( self.anim_loop_ender );
	}
	self notify( "stop_single" );
	self notify( "stop_sequencing_notetracks" );
}

anim_single_thread( guys, index, scene, org, angles, animname_override, aligned, n_lerp_time, tracker )
{
	guy = guys[ index ];
	guy endon( "death" );
	if ( guy is_a_sound_only_scene( scene, animname_override ) )
	{
	}
	else
	{
		guy _stop_anim_threads();
	}
	blend_in = guy._anim_blend_in_time;
	blend_out = guy._anim_blend_out_time;
	n_rate = 1;
	if ( isDefined( guy._anim_rate ) )
	{
		n_rate = guy._anim_rate;
	}
	if ( !isDefined( guy._animactive ) )
	{
		guy._animactive = 0;
	}
	guy._animactive++;
	dofacialanim = 0;
	dodialogue = 0;
	dotext = 0;
	dolook = 0;
	dialogue = undefined;
	facialanim = undefined;
	anim_string = "single anim";
	guy = guy get_anim_ent();
	animname = undefined;
	if ( isDefined( animname_override ) )
	{
		animname = animname_override;
	}
	else
	{
		animname = guy.animname;
	}
/#
	guy assert_existance_of_anim( scene, animname );
#/
	if ( isDefined( level.scr_face[ animname ] ) && isDefined( level.scr_face[ animname ][ scene ] ) )
	{
		dofacialanim = 1;
		facialanim = level.scr_face[ animname ][ scene ];
	}
	if ( is_mature() || !pg_sound_exists( animname, scene ) )
	{
		if ( sound_exists( animname, scene ) )
		{
			dodialogue = 1;
			dialogue = level.scr_sound[ animname ][ scene ];
		}
	}
	else
	{
		if ( pg_sound_exists( animname, scene ) )
		{
			dodialogue = 1;
			dialogue = level.scr_sound[ animname ][ scene + "_pg" ];
		}
	}
	if ( isDefined( level.scr_look[ animname ] ) && isDefined( level.scr_look[ animname ][ scene ] ) )
	{
		dolook = 1;
	}
	if ( isDefined( level.scr_animsound[ animname ] ) && isDefined( level.scr_animsound[ animname ][ scene ] ) )
	{
		if ( isDefined( guy.type ) && guy.type == "human" )
		{
			guy playsoundontag( level.scr_animsound[ animname ][ scene ], "J_Head" );
		}
		else
		{
			guy playsound( level.scr_animsound[ animname ][ scene ] );
		}
	}
/#
	if ( getdebugdvar( "animsound" ) == "on" )
	{
		guy thread animsound_start_tracker( scene, animname );
	}
	if ( isDefined( level.scr_text[ animname ] ) && isDefined( level.scr_text[ animname ][ scene ] ) )
	{
		dotext = 1;
#/
	}
	animation = guy get_anim( scene, animname_override );
	if ( isDefined( animation ) )
	{
/#
		self thread anim_info_render_thread( guy, scene, org, angles, animname, scene, 1 );
#/
		if ( isDefined( guy.a ) )
		{
			guy.a.coveridleonly = 0;
		}
		animtime = getanimlength( animation );
		if ( animtime < tracker.scriptedanimationtime )
		{
			tracker.scriptedanimationtime = animtime;
			tracker.scriptedanimationindex = index;
		}
		if ( guy.classname == "script_vehicle" && isDefined( guy.supportsanimscripted ) && !guy.supportsanimscripted )
		{
			veh_org = getstartorigin( org, angles, animation );
			veh_ang = getstartangles( org, angles, animation );
			guy.origin = veh_org;
			guy.angles = veh_ang;
			guy setflaggedanimknobrestart( anim_string, animation, 1, 0,2, 1 );
		}
		else
		{
			if ( isDefined( aligned ) && aligned )
			{
/#
				assert( isDefined( angles ), "Alignment node does not have angles specified." );
#/
				guy animscripted( anim_string, org, angles, animation, "normal", undefined, n_rate, blend_in, n_lerp_time );
			}
			else
			{
				if ( isDefined( guy.a ) && !isDefined( guy.a.script ) || !isDefined( "move" ) && isDefined( guy.a.script ) && isDefined( "move" ) && guy.a.script == "move" )
				{
					guy wait_for_foot_sync();
				}
				guy animscripted( anim_string, guy.origin, guy.angles, animation, "normal", undefined, n_rate, blend_in );
			}
			guy last_anim_time_check();
			cut_time = 0;
			if ( isDefined( blend_out ) )
			{
				cut_time = blend_out;
			}
			guy thread earlyout_animscripted( animation, cut_time );
		}
		guy notify( "_anim_playing" );
		thread notetrack_wait( guy, anim_string, scene, animname );
		thread animscriptdonotetracksthread( guy, anim_string );
	}
	if ( dolook )
	{
/#
		assert( isDefined( animation ), "Look animation "" + scene + "" for animname "" + animname + "" does not have a base animation" );
#/
		thread anim_look( guy, scene, level.scr_look[ animname ][ scene ] );
	}
	if ( dofacialanim || dodialogue )
	{
		if ( dofacialanim )
		{
			if ( dodialogue )
			{
				guy thread delayeddialogue( scene, dofacialanim, dialogue, level.scr_face[ animname ][ scene ] );
			}
/#
			assert( !0, "Can't play a facial anim and fullbody anim at the same time. The facial anim should be in the full body anim. Occurred on animation "" + scene + """ );
#/
			thread anim_facialanim( guy, scene, level.scr_face[ animname ][ scene ] );
			tracker.scriptedfaceindex = index;
		}
		else if ( isDefined( animation ) )
		{
			guy sayspecificdialogue( facialanim, dialogue, 1 );
		}
		else
		{
			if ( isai( guy ) )
			{
				guy thread anim_facialfiller( "single dialogue" );
			}
			guy sayspecificdialogue( facialanim, dialogue, 1, "single dialogue" );
		}
		tracker.scriptedsoundindex = index;
	}
/#
	if ( !isDefined( animation ) && !dolook && !dofacialanim && !dodialogue )
	{
		assert( dotext, "Tried to do anim scene " + scene + " on guy with animname " + animname + ", but he didn't have that anim scene." );
	}
#/
/#
	if ( dotext && !dodialogue )
	{
		iprintlnbold( level.scr_text[ animname ][ scene ] );
		wait 1,5;
#/
	}
}

wait_for_foot_sync()
{
	self endon( "death" );
	self endon( "foot_sync_timeout" );
	self thread wait_for_foot_sync_timeout();
	self waittillmatch( "runanim" );
	return "footstep_left_large";
	self notify( "foot_sync" );
/#
	println( "foot sync" );
	record3dtext( "foot sync", self.origin, ( 1, 1, 0 ), "ScriptedAnim", self );
#/
}

wait_for_foot_sync_timeout()
{
	self endon( "foot_sync" );
	self endon( "death" );
	while ( self.a.script == "move" )
	{
		wait 0,05;
	}
	self notify( "foot_sync_timeout" );
/#
	println( "foot sync failed" );
	record3dtext( "foot sync failed", self.origin, ( 1, 1, 0 ), "ScriptedAnim", self );
#/
}

anim_deathnotify( guy, scene )
{
	self endon( scene );
	guy waittill( "death" );
	self notify( scene );
}

anim_facialendnotify( guy, scene )
{
	self endon( scene );
	guy waittillmatch( "face_done_" + scene );
	return "end";
	self notify( scene );
}

anim_dialogueendnotify( guy, scene )
{
	self endon( scene );
	guy waittill( "single dialogue" );
	self notify( scene );
}

anim_animationendnotify( guy, scene )
{
	self endon( scene );
	guy waittillmatch( "single anim" );
	return "end";
	self notify( scene );
}

animscriptdonotetracksthread( guy, animstring )
{
	guy endon( "stop_sequencing_notetracks" );
	guy endon( "death" );
	guy donotetracks( animstring );
}

add_animsound( newsound )
{
	i = 0;
	while ( i < level.animsound_hudlimit )
	{
		if ( isDefined( self.animsounds[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			self.animsounds[ i ] = newsound;
			return;
		}
		i++;
	}
	keys = getarraykeys( self.animsounds );
	index = keys[ 0 ];
	timer = self.animsounds[ index ].end_time;
	i = 1;
	while ( i < keys.size )
	{
		key = keys[ i ];
		if ( self.animsounds[ key ].end_time < timer )
		{
			timer = self.animsounds[ key ].end_time;
			index = key;
		}
		i++;
	}
	self.animsounds[ index ] = newsound;
}

animsound_exists( scene, notetrack )
{
	keys = getarraykeys( self.animsounds );
	i = 0;
	while ( i < keys.size )
	{
		key = keys[ i ];
		if ( self.animsounds[ key ].scene != scene )
		{
			i++;
			continue;
		}
		else if ( self.animsounds[ key ].notetrack != notetrack )
		{
			i++;
			continue;
		}
		else
		{
			self.animsounds[ key ].end_time = getTime() + 60000;
			return 1;
		}
		i++;
	}
	return 0;
}

animsound_tracker( scene, notetrack, animname )
{
	add_to_animsound();
	if ( notetrack == "end" )
	{
		return;
	}
	if ( animsound_exists( scene, notetrack ) )
	{
		return;
	}
	newtrack = spawnstruct();
	newtrack.scene = scene;
	newtrack.notetrack = notetrack;
	newtrack.animname = animname;
	newtrack.end_time = getTime() + 60000;
	add_animsound( newtrack );
}

animsound_start_tracker( scene, animname )
{
	add_to_animsound();
	newsound = spawnstruct();
	newsound.scene = scene;
	newsound.notetrack = "#" + scene;
	newsound.animname = animname;
	newsound.end_time = getTime() + 60000;
	if ( animsound_exists( scene, newsound.notetrack ) )
	{
		return;
	}
	add_animsound( newsound );
}

animsound_start_tracker_loop( scene, loop, animname )
{
	add_to_animsound();
	scene = loop + scene;
	newsound = spawnstruct();
	newsound.scene = scene;
	newsound.notetrack = "#" + scene;
	newsound.animname = animname;
	newsound.end_time = getTime() + 60000;
	if ( animsound_exists( scene, newsound.notetrack ) )
	{
		return;
	}
	add_animsound( newsound );
}

notetrack_wait( guy, msg, scene, animname_override )
{
	guy endon( "death" );
	guy notify( "stop_sequencing_notetracks" );
	guy endon( "stop_sequencing_notetracks" );
	tag_owner = self;
	animname = undefined;
	if ( isDefined( animname_override ) )
	{
		animname = animname_override;
	}
	else
	{
		animname = guy.animname;
	}
	dialogue_array = [];
	has_scripted_notetracks = isDefined( level.scr_notetrack[ animname ] );
	while ( has_scripted_notetracks )
	{
		i = 0;
		while ( i < level.scr_notetrack[ animname ].size )
		{
			scr_notetrack = level.scr_notetrack[ animname ][ i ];
			if ( isDefined( scr_notetrack[ "dialog" ] ) )
			{
				dialogue_array[ scr_notetrack[ "dialog" ] ] = 1;
			}
			i++;
		}
	}
	notetrack = "start";
	while ( 1 )
	{
		dialoguenotetrack = 0;
/#
		if ( getdebugdvar( "animsound" ) == "on" )
		{
			guy thread animsound_tracker( scene, notetrack, animname );
#/
		}
		guy do_vehicle_notetracks( notetrack );
		while ( has_scripted_notetracks )
		{
			i = 0;
			while ( i < level.scr_notetrack[ animname ].size )
			{
				scr_notetrack = level.scr_notetrack[ animname ][ i ];
				if ( notetrack == tolower( scr_notetrack[ "notetrack" ] ) || tolower( scr_notetrack[ "notetrack" ] ) == "any" )
				{
					if ( scr_notetrack[ "scene" ] != "any" && scr_notetrack[ "scene" ] != scene )
					{
						i++;
						continue;
					}
					else
					{
						if ( isDefined( scr_notetrack[ "function" ] ) )
						{
							if ( isDefined( scr_notetrack[ "noteback" ] ) && isDefined( scr_notetrack[ "noteback" ] ) && scr_notetrack[ "noteback" ] )
							{
								self thread [[ scr_notetrack[ "function" ] ]]( guy, notetrack );
								break;
							}
							else
							{
								self thread [[ scr_notetrack[ "function" ] ]]( guy );
							}
						}
						if ( isDefined( level.scr_notetrack[ animname ][ i ][ "flag" ] ) )
						{
							flag_set( level.scr_notetrack[ animname ][ i ][ "flag" ] );
						}
						if ( isDefined( level.scr_notetrack[ animname ][ i ][ "exploder" ] ) )
						{
							exploder( level.scr_notetrack[ animname ][ i ][ "exploder" ] );
						}
						if ( isDefined( level.scr_notetrack[ animname ][ i ][ "stop_exploder" ] ) )
						{
							stop_exploder( level.scr_notetrack[ animname ][ i ][ "stop_exploder" ] );
						}
						if ( isDefined( scr_notetrack[ "attach gun left" ] ) )
						{
							guy gun_pickup_left();
							i++;
							continue;
						}
						else if ( isDefined( scr_notetrack[ "attach gun right" ] ) )
						{
							guy gun_pickup_right();
							i++;
							continue;
						}
						else if ( isDefined( scr_notetrack[ "detach gun" ] ) )
						{
							guy gun_leave_behind( scr_notetrack );
							i++;
							continue;
						}
						else if ( isDefined( scr_notetrack[ "swap from" ] ) )
						{
							guy detach( guy.swapweapon, scr_notetrack[ "swap from" ] );
							guy attach( guy.swapweapon, scr_notetrack[ "self tag" ] );
							i++;
							continue;
						}
						else if ( isDefined( scr_notetrack[ "attach model" ] ) )
						{
							if ( isDefined( scr_notetrack[ "selftag" ] ) )
							{
								guy attach( scr_notetrack[ "attach model" ], scr_notetrack[ "selftag" ] );
							}
							else if ( isDefined( scr_notetrack[ "tag" ] ) )
							{
								tag_owner attach( scr_notetrack[ "attach model" ], scr_notetrack[ "tag" ] );
							}
							else
							{
								guy attach( scr_notetrack[ "attach model" ] );
							}
							i++;
							continue;
						}
						else if ( isDefined( scr_notetrack[ "detach model" ] ) )
						{
							waittillframeend;
							if ( isDefined( scr_notetrack[ "selftag" ] ) )
							{
								guy detach( scr_notetrack[ "detach model" ], scr_notetrack[ "selftag" ] );
								break;
							}
							else if ( isDefined( scr_notetrack[ "tag" ] ) )
							{
								tag_owner detach( scr_notetrack[ "detach model" ], scr_notetrack[ "tag" ] );
								break;
							}
							else
							{
								guy detach( scr_notetrack[ "attach model" ] );
							}
						}
						if ( isDefined( scr_notetrack[ "level notify" ] ) )
						{
							level notify( scr_notetrack[ "level notify" ] );
						}
						if ( isDefined( scr_notetrack[ "change fov" ] ) )
						{
							tokens = strtok( scr_notetrack[ "change fov" ], "_" );
/#
							assert( tolower( tokens[ 0 ] ) == "fov" );
#/
							if ( tokens[ 1 ] != "reset" )
							{
								new_fov = int( int( tokens[ 1 ] ) * 1,27 );
								if ( tokens.size > 2 )
								{
									lerp_time = int( tokens[ 2 ] );
									get_players()[ 0 ] thread lerp_fov_overtime( lerp_time, new_fov, 1 );
								}
								else
								{
									get_players()[ 0 ] setclientdvar( "cg_fov", new_fov );
								}
								break;
							}
							else /#
							assert( tolower( tokens[ 1 ] ) == "reset" );
#/
							if ( tokens.size > 2 )
							{
								lerp_time = int( tokens[ 2 ] );
								get_players()[ 0 ] thread lerp_fov_overtime( lerp_time, getDvarFloat( "cg_fov_default" ), 1 );
								break;
							}
							else
							{
								get_players()[ 0 ] resetfov();
							}
						}
						if ( isDefined( scr_notetrack[ "fov" ] ) )
						{
							get_players()[ 0 ] thread lerp_fov_overtime( scr_notetrack[ "time" ], scr_notetrack[ "fov" ], 1 );
						}
						if ( isDefined( scr_notetrack[ "sound" ] ) )
						{
							guy thread play_sound_on_tag( scr_notetrack[ "sound" ], undefined, 1 );
						}
						if ( !dialoguenotetrack )
						{
							if ( isDefined( scr_notetrack[ "dialog" ] ) && isDefined( dialogue_array[ scr_notetrack[ "dialog" ] ] ) )
							{
								anim_facial( guy, i, "dialog", animname );
								dialoguenotetrack = 1;
							}
						}
						if ( isDefined( scr_notetrack[ "create model" ] ) )
						{
							anim_addmodel( guy, scr_notetrack );
						}
						else
						{
							if ( isDefined( scr_notetrack[ "delete model" ] ) )
							{
								anim_removemodel( guy, scr_notetrack );
							}
						}
						if ( isDefined( scr_notetrack[ "selftag" ] ) && isDefined( scr_notetrack[ "effect" ] ) )
						{
							playfxontag( level._effect[ scr_notetrack[ "effect" ] ], guy, scr_notetrack[ "selftag" ] );
						}
						if ( isDefined( scr_notetrack[ "tag" ] ) && isDefined( scr_notetrack[ "effect" ] ) )
						{
							playfxontag( level._effect[ scr_notetrack[ "effect" ] ], tag_owner, scr_notetrack[ "tag" ] );
						}
						if ( isDefined( level.scr_special_notetrack[ animname ] ) )
						{
							tag = random( level.scr_special_notetrack[ animname ] );
							if ( isDefined( tag[ "tag" ] ) )
							{
								playfxontag( level._effect[ tag[ "effect" ] ], tag_owner, tag[ "tag" ] );
								i++;
								continue;
							}
							else
							{
								if ( isDefined( tag[ "selftag" ] ) )
								{
									playfxontag( level._effect[ tag[ "effect" ] ], self, tag[ "tag" ] );
								}
							}
						}
					}
				}
				i++;
			}
		}
		prefix = getsubstr( notetrack, 0, 3 );
		if ( prefix == "ps_" )
		{
			alias = getsubstr( notetrack, 3 );
			guy thread play_sound_on_tag( alias, undefined, 1 );
		}
		if ( notetrack == "end" )
		{
			return;
		}
		guy waittill( msg, notetrack );
	}
}

do_vehicle_notetracks( notetrack )
{
	n_weapon_index = 0;
	if ( isDefined( self.classname ) && self.classname == "script_vehicle" )
	{
		if ( getsubstr( notetrack, 0, 4 ) == "fire" )
		{
			if ( getsubstr( notetrack, 4, 9 ) == "start" )
			{
				if ( notetrack.size > 9 && isDefined( notetrack[ 9 ] ) )
				{
					n_weapon_index = int( notetrack[ 9 ] );
				}
				self thread maps/_turret::fire_turret_for_time( -1, n_weapon_index );
				return;
			}
			else if ( getsubstr( notetrack, 4, 8 ) == "stop" )
			{
				if ( notetrack.size > 8 && isDefined( notetrack[ 8 ] ) )
				{
					n_weapon_index = int( notetrack[ 8 ] );
				}
				maps/_turret::stop_turret( n_weapon_index, 0 );
				return;
			}
			else
			{
				if ( notetrack.size > 4 && isDefined( notetrack[ 4 ] ) )
				{
					n_weapon_index = int( notetrack[ 4 ] );
				}
				maps/_turret::fire_turret( n_weapon_index );
			}
		}
	}
}

anim_addmodel( guy, array )
{
	if ( !isDefined( guy.scriptmodel ) )
	{
		guy.scriptmodel = [];
	}
	index = guy.scriptmodel.size;
	guy.scriptmodel[ index ] = spawn( "script_model", ( 1, 1, 0 ) );
	guy.scriptmodel[ index ] setmodel( array[ "create model" ] );
	guy.scriptmodel[ index ].origin = guy gettagorigin( array[ "selftag" ] );
	guy.scriptmodel[ index ].angles = guy gettagangles( array[ "selftag" ] );
}

anim_removemodel( guy, array )
{
/#
	if ( !isDefined( guy.scriptmodel ) )
	{
		assertmsg( "Tried to remove a model with delete model before it was create model'd on guy: " + guy.animname );
#/
	}
	i = 0;
	while ( i < guy.scriptmodel.size )
	{
		if ( isDefined( array[ "explosion" ] ) )
		{
			forward = anglesToForward( guy.scriptmodel[ i ].angles );
			forward = vectorScale( forward, 120 );
			forward += guy.scriptmodel[ i ].origin;
			playfx( level._effect[ array[ "explosion" ] ], guy.scriptmodel[ i ].origin );
			radiusdamage( guy.scriptmodel[ i ].origin, 350, 700, 50 );
		}
		guy.scriptmodel[ i ] delete();
		i++;
	}
}

anim_facial( guy, i, dialoguestring, animname )
{
	facialanim = undefined;
	if ( isDefined( level.scr_notetrack[ animname ][ i ][ "facial" ] ) )
	{
		facialanim = level.scr_notetrack[ animname ][ i ][ "facial" ];
	}
	dialogue = undefined;
	if ( is_mature() || !isDefined( level.scr_notetrack[ animname ][ i ][ "pg_" + dialoguestring ] ) )
	{
		dialogue = level.scr_notetrack[ animname ][ i ][ dialoguestring ];
	}
	else
	{
		if ( isDefined( level.scr_notetrack[ animname ][ i ][ "pg_" + dialoguestring ] ) )
		{
			dialogue = level.scr_notetrack[ animname ][ i ][ "pg_" + dialoguestring ];
		}
	}
	guy sayspecificdialogue( facialanim, dialogue, 1 );
}

gun_pickup_left()
{
	if ( !isDefined( self.gun_on_ground ) )
	{
		return;
	}
	self.gun_on_ground delete();
	self.dropweapon = 1;
	self animscripts/shared::placeweaponon( self.weapon, "left" );
}

gun_pickup_right()
{
	if ( !isDefined( self.gun_on_ground ) )
	{
		return;
	}
	self.gun_on_ground delete();
	self.dropweapon = 1;
	self animscripts/shared::placeweaponon( self.weapon, "right" );
}

gun_leave_behind( scr_notetrack )
{
	if ( isDefined( self.gun_on_ground ) )
	{
		return;
	}
	gun = spawn( "script_model", ( 1, 1, 0 ) );
	gun setmodel( self.weaponmodel );
	self.gun_on_ground = gun;
	gun.origin = self gettagorigin( scr_notetrack[ "tag" ] );
	gun.angles = self gettagangles( scr_notetrack[ "tag" ] );
	self animscripts/shared::placeweaponon( self.weapon, "none" );
	self.dropweapon = 0;
}

anim_weight( animname, scene )
{
	total_anims = level.scr_anim[ animname ][ scene ].size;
	idleanim = randomint( total_anims );
	while ( total_anims > 1 )
	{
		weights = 0;
		anim_weight = 0;
		i = 0;
		while ( i < total_anims )
		{
			if ( isDefined( level.scr_anim[ animname ][ scene + "weight" ] ) )
			{
				if ( isDefined( level.scr_anim[ animname ][ scene + "weight" ][ i ] ) )
				{
					weights++;
					anim_weight += level.scr_anim[ animname ][ scene + "weight" ][ i ];
				}
			}
			i++;
		}
		while ( weights == total_anims )
		{
			anim_play = randomfloat( anim_weight );
			anim_weight = 0;
			i = 0;
			while ( i < total_anims )
			{
				anim_weight += level.scr_anim[ animname ][ scene + "weight" ][ i ];
				if ( anim_play < anim_weight )
				{
					idleanim = i;
					break;
				}
				else
				{
					i++;
				}
			}
		}
	}
	return idleanim;
}

get_anim_position( tag )
{
	org = undefined;
	angles = undefined;
	if ( isDefined( tag ) )
	{
		org = self gettagorigin( tag );
		angles = self gettagangles( tag );
	}
	else
	{
		org = self.origin;
		angles = self.angles;
	}
	array = [];
	array[ "angles" ] = angles;
	array[ "origin" ] = org;
	return array;
}

do_anim_reach( guys, scene, tag, animname_override, aligned )
{
	array = get_anim_position( tag );
	org = array[ "origin" ];
	angles = array[ "angles" ];
	debugstartpos = 0;
/#
	debugstartpos = getdebugdvar( "debug_animreach" ) == "on";
#/
	threads = 0;
	tracker = spawnstruct();
	if ( !isarray( guys ) )
	{
		newguys[ newguys.size ] = guys;
		guys = newguys;
	}
	i = 0;
	while ( i < guys.size )
	{
		guy = guys[ i ];
		animation = guy get_anim( scene, animname_override );
		if ( isDefined( animation ) )
		{
			startorg = getstartorigin( org, angles, animation );
		}
		else
		{
			startorg = org;
		}
/#
		if ( debugstartpos )
		{
			thread debug_message_clear( "x", startorg, 1000, "clearAnimDebug" );
#/
		}
		threads++;
		disablearrivals = 1;
		if ( isDefined( guy.disablearrivals ) && !guy.disablearrivals )
		{
			notetracks = getnotetracksindelta( animation, 0, 1 );
			if ( notetracks.size )
			{
				if ( notetracks[ 0 ][ 1 ] == "anim_movement = "stop"" && notetracks[ 0 ][ 2 ] == 0 )
				{
					disablearrivals = 0;
				}
			}
		}
		self thread begin_anim_reach( guy, tracker, startorg, disablearrivals, aligned );
		i++;
	}
	while ( threads )
	{
		tracker waittill( "reach_notify" );
		threads--;

	}
/#
	if ( debugstartpos )
	{
		level notify( "x" + "clearAnimDebug" );
#/
	}
}

anim_spawner_teleport( guy, scene, tag )
{
	pos = get_anim_position( tag );
	org = pos[ "origin" ];
	angles = pos[ "angles" ];
	i = 0;
	while ( i < guy.size )
	{
		animation = guy[ i ] get_anim( scene );
		startorg = getstartorigin( org, angles, animation );
		guy[ i ].origin = startorg;
		i++;
	}
}

reach_death_notify( guy )
{
	self endon( "reach_notify" );
	self waittill_any( "death", "_anim_reach", "_anim_playing", "_anim_stopped" );
	self notify( "reach_notify" );
}

begin_anim_reach( guy, tracker, startorg, disablearrivals, aligned )
{
	guy endon( "death" );
	guy notify( "stop_going_to_node" );
	guy notify( "_anim_reach" );
	guy endon( "_anim_reach" );
	waittillframeend;
	tracker thread reach_death_notify( guy );
	guy._anim_old_disablearrivals = guy.disablearrivals;
	guy._anim_old_fixednode = guy.fixednode;
	goal = startorg;
	if ( vector_compare( self.origin, startorg ) && isDefined( self.type ) && getsubstr( self.type, 0, 5 ) == "Cover" )
	{
		guy.a.coveridleonly = 1;
		disablearrivals = 0;
		goal = self;
		aligned = 1;
		guy.fixednode = 1;
	}
	else
	{
		guy.fixednode = 0;
	}
	if ( disablearrivals )
	{
		guy.stopanimdistsq = 0,0001;
	}
	else
	{
		guy.stopanimdistsq = 0;
	}
	guy.disablearrivals = disablearrivals;
	goal_radius = 50;
	if ( aligned )
	{
		goal_radius = 0;
	}
	guy thread force_goal( goal, goal_radius, 1, "anim_reach_done" );
	guy thread end_anim_reach();
	guy waittill( "goal" );
	tracker notify( "reach_notify" );
}

end_anim_reach()
{
	self endon( "death" );
	self waittill_any( "_anim_reach", "_anim_playing", "_anim_stopped" );
	self notify( "anim_reach_done" );
	self.disablearrivals = self._anim_old_disablearrivals;
	self.fixednode = self._anim_old_fixednode;
	self.stopanimdistsq = 0;
	self._anim_old_fixednode = undefined;
	self._anim_old_disablearrivals = undefined;
}

printloops( guy, scene )
{
/#
	if ( !isDefined( guy ) )
	{
		return;
	}
	guy endon( "death" );
	waittillframeend;
	guy.loops++;
	if ( guy.loops > 1 )
	{
		assertmsg( "guy with name " + guy.animname + " has " + guy.loops + " looping animations played, scene: " + scene );
#/
	}
}

looping_anim_ender( guy, ender )
{
/#
	guy endon( "death" );
	waittill_any_ents_two( self, ender, guy, ender );
	guy.loops--;

#/
}

get_animtree( guy )
{
	i = 0;
	while ( i < guy.size )
	{
		guy[ i ] useanimtree( level.scr_animtree[ guy[ i ].animname ] );
		i++;
	}
}

setanimtree()
{
	self useanimtree( level.scr_animtree[ self.animname ] );
}

anim_single_queue( guy, scene, tag )
{
/#
	assert( isDefined( scene ), "Tried to do anim_single_queue without passing a scene name (scene)" );
#/
	if ( isDefined( guy.last_queue_time ) )
	{
		wait_for_buffer_time_to_pass( guy.last_queue_time, 0,5 );
	}
	function_stack( ::anim_single_aligned, guy, scene, tag );
	guy.last_queue_time = getTime();
}

anim_pushplayer( guy )
{
	i = 0;
	while ( i < guy.size )
	{
		guy[ i ] pushplayer( 1 );
		i++;
	}
}

addnotetrack_custom( animname, scene, notetrack, index1_str, index1_val, index2_str, index2_val )
{
	if ( !isDefined( level.scr_notetrack[ animname ] ) )
	{
		level.scr_notetrack[ animname ] = [];
	}
	num = level.scr_notetrack[ animname ].size;
	add_note = [];
	add_note[ "notetrack" ] = notetrack;
	add_note[ "scene" ] = scene;
	add_note[ index1_str ] = index1_val;
	if ( isDefined( index2_str ) && isDefined( index2_val ) )
	{
		add_note[ index2_str ] = index2_val;
	}
	level.scr_notetrack[ animname ][ num ] = add_note;
}

anim_ents( ents, scene, tag, animname )
{
	ents = build_ent_array( ents );
	pos = get_anim_position( tag );
	origin = pos[ "origin" ];
	angles = pos[ "angles" ];
	parent_model = undefined;
	if ( !isDefined( animname ) && isDefined( ents[ 0 ].animname ) )
	{
		animname = ents[ 0 ].animname;
	}
/#
	assert( isDefined( animname ), "_anim::anim_ents() - Animname is not defined" );
#/
	if ( isDefined( level.scr_model[ animname ] ) )
	{
		parent_model = spawn( "script_model", origin );
		parent_model.angles = angles;
		parent_model.animname = animname;
		parent_model setanimtree();
		parent_model setmodel( level.scr_model[ animname ] );
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( parent_model ) )
		{
/#
			assert( isDefined( ents[ i ].script_linkto ), "_anim::anim_ents() - Entity at " + ents[ i ].origin + " does not have a script_linkto Key/Value" );
#/
			ents[ i ] linkto( parent_model, ents[ i ].script_linkto );
		}
		else
		{
			ents[ i ] setanimtree();
			ents[ i ] setflaggedanimknob( "ent_anim", get_anim( scene, animname ), 1, 0,2, 1 );
			thread notetrack_wait( ents[ i ], "ent_anim", scene, animname );
		}
		ents[ i ] notify( "_anim_playing" );
		i++;
	}
	if ( isDefined( parent_model ) )
	{
		parent_model setflaggedanimknob( "ent_anim", get_anim( scene, animname ), 1, 0,2, 1 );
		thread notetrack_wait( parent_model, "ent_anim", scene, animname );
		parent_model waittillmatch( "ent_anim" );
		return "end";
		self notify( scene );
	}
}

anim_look( guy, scene, array )
{
	guy endon( "death" );
	self endon( scene );
	wait 0,05;
	guy setflaggedanimknobrestart( "face_done_" + scene, array[ "left" ], 1, 0,2, 1 );
	thread clearfaceanimonanimdone( guy, "face_done_" + scene, scene );
	guy setanimknobrestart( array[ "right" ], 1, 0,2, 1 );
	guy setanim( %scripted, 0,01, 0,3, 1 );
	for ( ;; )
	{
		destyaw = guy getyawtoorigin( level.player.origin );
		if ( destyaw <= array[ "left_angle" ] )
		{
			animweights[ "left" ] = 1;
			animweights[ "right" ] = 0,01;
		}
		else if ( destyaw < array[ "right_angle" ] )
		{
			middlefraction = ( array[ "right_angle" ] - destyaw ) / ( array[ "right_angle" ] - array[ "left_angle" ] );
			if ( middlefraction < 0,01 )
			{
				middlefraction = 0,01;
			}
			if ( middlefraction > ( 1 - 0,01 ) )
			{
				middlefraction = 1 - 0,01;
			}
			animweights[ "left" ] = middlefraction;
			animweights[ "right" ] = 1 - middlefraction;
		}
		else
		{
			animweights[ "left" ] = 0,01;
			animweights[ "right" ] = 1;
		}
		wait 0,05;
	}
}

anim_facialanim( guy, scene, faceanim )
{
	guy endon( "death" );
	self endon( scene );
	guy notify( "newLookTarget" );
	waittillframeend;
	guy setanim( %scripted_look_straight, 0, 0 );
	guy setanim( %scripted_look_straight, 1, 0,5 );
	guy setflaggedanimknobrestart( "face_done_" + scene, faceanim, 1, 0, 1 );
	thread clearfaceanimonanimdone( guy, "face_done_" + scene, scene );
}

anim_facialfiller( msg, looktarget )
{
	self endon( "death" );
	changetime = 0,05;
	self notify( "newLookTarget" );
	self endon( "newLookTarget" );
	waittillframeend;
	if ( !isDefined( looktarget ) && isDefined( self.looktarget ) )
	{
		looktarget = self.looktarget;
	}
	if ( isDefined( looktarget ) )
	{
		thread chatattarget( msg, looktarget );
		return;
	}
	self set_talker_until_msg( msg );
	changetime = 0,3;
	self clearanim( %scripted_look_straight, changetime );
}

set_talker_until_msg( msg, talkanim )
{
	self endon( msg );
	for ( ;; )
	{
		self sendfaceevent( "face_talk" );
		wait 0,05;
	}
}

talk_for_time( timer )
{
	self endon( "death" );
	talkanim = %generic_talker_allies;
	if ( self.team == "axis" )
	{
		talkanim = %generic_talker_axis;
	}
	self setanimknobrestart( talkanim, 1, 0, 1 );
	self setanim( %scripted_talking, 1, 0,1 );
	wait timer;
	self clearanim( %scripted_talking, 0,1 );
	self clearanim( %scripted_look_straight, 0,3 );
}

getyawangles( angles1, angles2 )
{
	yaw = angles1[ 1 ] - angles2[ 1 ];
	yaw = angleClamp180( yaw );
	return yaw;
}

chatattarget( msg, looktarget )
{
	self endon( msg );
	self endon( "death" );
	self thread lookrecenter( msg );
	array[ "right" ] = %generic_lookupright;
	array[ "left" ] = %generic_lookupleft;
	array[ "left_angle" ] = -65;
	array[ "right_angle" ] = 65;
	org = looktarget.origin;
	moverange = 2;
	for ( ;; )
	{
		if ( isalive( looktarget ) )
		{
			org = looktarget.origin;
		}
/#
		if ( getdebugdvar( "debug_chatlook" ) == "on" )
		{
			thread lookline( org, msg );
#/
		}
		angles = anglesToRight( self gettagangles( "J_Spine4" ) );
		angles = vectorScale( angles, 10 );
		angles = vectorToAngle( ( 1, 1, 0 ) - angles );
		yaw = angles[ 1 ] - vectorToAngle( org - self.origin )[ 1 ];
		destyaw = angleClamp180( yaw );
		moverange = abs( destyaw - self.a.lookangle ) * 1;
		if ( destyaw > ( self.a.lookangle + moverange ) )
		{
			self.a.lookangle += moverange;
		}
		else if ( destyaw < ( self.a.lookangle - moverange ) )
		{
			self.a.lookangle -= moverange;
		}
		else
		{
			self.a.lookangle = destyaw;
		}
		destyaw = self.a.lookangle;
		if ( destyaw <= array[ "left_angle" ] )
		{
			animweights[ "left" ] = 1;
			animweights[ "right" ] = 0,01;
		}
		else if ( destyaw < array[ "right_angle" ] )
		{
			middlefraction = ( array[ "right_angle" ] - destyaw ) / ( array[ "right_angle" ] - array[ "left_angle" ] );
			if ( middlefraction < 0,01 )
			{
				middlefraction = 0,01;
			}
			if ( middlefraction > ( 1 - 0,01 ) )
			{
				middlefraction = 1 - 0,01;
			}
			animweights[ "left" ] = middlefraction;
			animweights[ "right" ] = 1 - middlefraction;
		}
		else
		{
			animweights[ "left" ] = 0,01;
			animweights[ "right" ] = 1;
		}
		self setanim( array[ "left" ], animweights[ "left" ], 0,3 );
		self setanim( array[ "right" ], animweights[ "right" ], 0,3 );
		wait 0,3;
	}
}

lookrecenter( msg )
{
	self endon( "newLookTarget" );
	self endon( "death" );
	self waittill( msg );
	self clearanim( %scripted_talking, 0,1 );
	self setanim( %generic_lookupright, 1, 0,3 );
	self setanim( %generic_lookupleft, 1, 0,3 );
	self setanim( %scripted_look_straight, 0,2, 0,1 );
	wait 0,2;
	self clearanim( %scripted_look_straight, 0,2 );
}

lookline( org, msg )
{
/#
	self notify( "lookline" );
	self endon( "lookline" );
	self endon( msg );
	self endon( "death" );
	for ( ;; )
	{
		line( self geteye(), org + vectorScale( ( 1, 1, 0 ), 60 ), ( 1, 1, 0 ), 1 );
		wait 0,05;
#/
	}
}

reach_idle( guy, scene, idle, ent )
{
	anim_reach_aligned( guy, scene );
	ent.count--;

	ent notify( "reach_idle_goal" );
	anim_loop( guy, idle );
}

delayeddialogue( scene, doanimation, dialogue, animationname )
{
/#
	assert( animhasnotetrack( animationname, "dialog" ), "Animation " + scene + " does not have a dialog notetrack." );
#/
	self waittillmatch( "face_done_" + scene );
	return "dialog";
	if ( doanimation )
	{
		self sayspecificdialogue( undefined, dialogue, 1 );
	}
	else
	{
		self sayspecificdialogue( undefined, dialogue, 1, "single dialogue" );
	}
}

clearfaceanimonanimdone( guy, msg, scene )
{
	guy endon( "death" );
	guy waittillmatch( msg );
	return "end";
	guy clearanim( %scripted_look_straight, 0,3 );
}

anim_start_pos( ents, scene, tag )
{
	ents = build_ent_array( ents );
	pos = get_anim_position( tag );
	org = pos[ "origin" ];
	angles = pos[ "angles" ];
	array_thread( ents, ::set_start_pos, scene, org, angles );
}

set_start_pos( scene, origin, angles, animname_override )
{
	animation = get_anim( scene, animname_override );
	origin = getstartorigin( origin, angles, animation );
	angles = getstartangles( origin, angles, animation );
	if ( issentient( self ) )
	{
		self forceteleport( origin, angles );
	}
	else
	{
		self.origin = origin;
		self.angles = angles;
	}
}

add_to_animsound()
{
	if ( !isDefined( self.animsounds ) )
	{
		self.animsounds = [];
	}
	isinarray = 0;
	i = 0;
	while ( i < level.animsounds.size )
	{
		if ( self == level.animsounds[ i ] )
		{
			isinarray = 1;
			break;
		}
		else
		{
			i++;
		}
	}
	if ( !isinarray )
	{
		level.animsounds[ level.animsounds.size ] = self;
	}
}

anim_self_set_time( scene, time )
{
	self setanimtime( self getanim( scene ), time );
}

last_anim_time_check()
{
	if ( !isDefined( self.last_anim_time ) )
	{
		self.last_anim_time = getTime();
		return;
	}
	time = getTime();
	if ( self.last_anim_time == time )
	{
		wait 0,05;
	}
	self.last_anim_time = time;
}

loopanim_sound_exists( animname, scene, idleanim )
{
	if ( isDefined( level.scr_sound[ animname ] ) && isDefined( level.scr_sound[ animname ][ scene ] ) && isDefined( level.scr_sound[ animname ][ scene ][ idleanim ] ) )
	{
		return 1;
	}
	return 0;
}

pg_loopanim_sound_exists( animname, scene, idleanim )
{
	if ( isDefined( level.scr_sound[ animname ] ) && isDefined( level.scr_sound[ animname ][ scene + "_pg" ] ) && isDefined( level.scr_sound[ animname ][ scene + "_pg" ][ idleanim ] ) )
	{
		return 1;
	}
	return 0;
}

sound_exists( animname, scene )
{
	if ( isDefined( level.scr_sound[ animname ] ) && isDefined( level.scr_sound[ animname ][ scene ] ) )
	{
		return 1;
	}
	return 0;
}

animation_exists( animname, scene )
{
	if ( isDefined( level.scr_anim[ animname ] ) && isDefined( level.scr_anim[ animname ][ scene ] ) )
	{
		return 1;
	}
	return 0;
}

pg_sound_exists( animname, scene )
{
	if ( isDefined( level.scr_sound[ animname ] ) && isDefined( level.scr_sound[ animname ][ scene + "_pg" ] ) )
	{
		return 1;
	}
	return 0;
}

earlyout_animscripted( animation, cut_time, blend_time )
{
	if ( !isDefined( cut_time ) )
	{
		cut_time = 0,3;
	}
	self endon( "death" );
	self endon( "stop_single" );
	if ( !isDefined( blend_time ) )
	{
		blend_time = cut_time;
	}
	if ( cut_time <= 0 )
	{
		return;
	}
	anim_time = getanimlength( animation );
	wait ( anim_time - cut_time );
	self anim_stopanimscripted( blend_time );
}

anim_origin_render( org, angles, line_length, str_label )
{
/#
	if ( !isDefined( line_length ) )
	{
		line_length = 6;
	}
	if ( isDefined( org ) && isDefined( angles ) )
	{
		originendpoint = org + vectorScale( anglesToForward( angles ), line_length );
		originrightpoint = org + vectorScale( anglesToRight( angles ), -1 * line_length );
		originuppoint = org + vectorScale( anglesToUp( angles ), line_length );
		line( org, originendpoint, ( 1, 1, 0 ) );
		line( org, originrightpoint, ( 1, 1, 0 ) );
		line( org, originuppoint, ( 1, 1, 0 ) );
		if ( isDefined( str_label ) )
		{
			print3d( org, str_label, ( 0, 0,3, 0,3 ), 1, 0,05 );
#/
		}
	}
}

rec_anim_origin_render( org, angles )
{
/#
	if ( !getDvarInt( #"0099037B" ) )
	{
		return;
	}
	if ( isDefined( org ) && isDefined( angles ) )
	{
		originendpoint = org + vectorScale( anglesToForward( angles ), 10 );
		originrightpoint = org + vectorScale( anglesToRight( angles ), -10 );
		originuppoint = org + vectorScale( anglesToUp( angles ), 10 );
		recordline( org, originendpoint, ( 1, 1, 0 ), "ScriptedAnim" );
		recordline( org, originrightpoint, ( 1, 1, 0 ), "ScriptedAnim" );
		recordline( org, originuppoint, ( 1, 1, 0 ), "ScriptedAnim" );
#/
	}
}

toggle_scene_debug()
{
/#
	setdvar( "scene_debug", 0 );
	while ( 1 )
	{
		level.scene_debug_enabled = getdvarintdefault( "scene_debug", 0 );
		wait 0,05;
#/
	}
}

anim_info_render_thread( guy, scene, org, angles, animname, ender, showblends, b_first_frame )
{
/#
	self thread rec_anim_info_render_thread( guy, scene, org, angles, animname, ender, showblends, b_first_frame );
	guy endon( "death" );
	guy notify( "anim_info_render_thread" );
	guy endon( "anim_info_render_thread" );
	self endon( ender );
	guy endon( ender );
	while ( 1 )
	{
		if ( isDefined( level.scene_debug_enabled ) && level.scene_debug_enabled )
		{
			str_extra_info = "";
			color = ( 1, 1, 0 );
			if ( isDefined( b_first_frame ) && b_first_frame )
			{
				str_extra_info += "(first frame)";
			}
			if ( !isassetloaded( "xanim", string( get_anim( scene, animname ) ) ) )
			{
				str_extra_info += "(missing)";
				color = ( 1, 1, 0 );
			}
			if ( isDefined( org ) )
			{
				line( guy.origin, org, vectorScale( ( 1, 1, 0 ), 0,3 ), 0,5, 1 );
				sphere( org, 2, vectorScale( ( 1, 1, 0 ), 0,3 ), 0,5, 1 );
			}
			if ( self != guy && self != level )
			{
				if ( isDefined( level.a_scenes ) )
				{
					if ( isDefined( level.a_scenes[ scene ] ) )
					{
						str_align_targetname = level.a_scenes[ scene ].str_align_targetname;
						if ( isDefined( str_align_targetname ) )
						{
						}
						else
						{
						}
						print3d( self.origin + vectorScale( ( 1, 1, 0 ), 5 ), "no targetname", str_align_targetname, vectorScale( ( 1, 1, 0 ), 0,3 ), 1, 0,15 );
					}
				}
			}
			guy anim_origin_render( guy.origin, guy.angles );
			print3d( guy.origin, guy getentnum() + ":name:" + animname, color, 0,8, 0,3 );
			print3d( guy.origin - vectorScale( ( 1, 1, 0 ), 5 ), "scene:" + scene, color, 0,8, 0,3 );
			print3d( guy.origin - vectorScale( ( 1, 1, 0 ), 7 ), str_extra_info, color, 0,8, 0,15 );
			if ( isai( guy ) )
			{
				v_tag_org = guy gettagorigin( "tag_weapon_right" );
				if ( isDefined( v_tag_org ) )
				{
					v_tag_ang = guy gettagangles( "tag_weapon_right" );
					anim_origin_render( v_tag_org, v_tag_ang, 2, "right" );
				}
				v_tag_org = guy gettagorigin( "tag_weapon_left" );
				if ( isDefined( v_tag_org ) )
				{
					v_tag_ang = guy gettagangles( "tag_weapon_left" );
					anim_origin_render( v_tag_org, v_tag_ang, 2, "left" );
				}
				break;
			}
			else
			{
				v_tag_org = guy gettagorigin( "tag_player" );
				if ( isDefined( v_tag_org ) )
				{
					v_tag_ang = guy gettagangles( "tag_player" );
					anim_origin_render( v_tag_org, v_tag_ang, 2, "plr" );
				}
				v_tag_org = guy gettagorigin( "tag_camera" );
				if ( isDefined( v_tag_org ) )
				{
					v_tag_ang = guy gettagangles( "tag_camera" );
					anim_origin_render( v_tag_org, v_tag_ang, 2, "cam" );
				}
			}
		}
		wait 0,05;
#/
	}
}

rec_anim_info_render_thread( guy, scene, org, angles, animname, ender, showblends, b_first_frame )
{
/#
	if ( !getDvarInt( #"0099037B" ) )
	{
		return;
	}
	if ( isDefined( guy.script_recordent ) && !guy.script_recordent )
	{
		return;
	}
	guy notify( "anim_info_render_thread" );
	guy endon( "anim_info_render_thread" );
	self endon( ender );
	guy endon( ender );
	guy endon( "death" );
	recordent( guy );
	if ( isDefined( org ) )
	{
		recordline( guy.origin, org, ( 1, 1, 0 ), "ScriptedAnim", guy );
	}
	if ( isDefined( showblends ) && showblends )
	{
		blendintime = 0;
		if ( isDefined( guy._anim_blend_in_time ) )
		{
			blendintime = guy._anim_blend_in_time;
		}
		recordenttext( "blend-in time: " + blendintime, guy, ( 1, 1, 0 ), "ScriptedAnim" );
		blendouttime = 0;
		if ( isDefined( guy._anim_blend_out_time ) )
		{
			blendouttime = guy._anim_blend_out_time;
		}
		recordenttext( "blend-out time: " + blendouttime, guy, ( 1, 1, 0 ), "ScriptedAnim" );
	}
	str_extra_info = "";
	color = ( 1, 1, 0 );
	if ( isDefined( b_first_frame ) && b_first_frame )
	{
		str_extra_info += "(first frame)";
	}
	if ( !isassetloaded( "xanim", string( get_anim( scene, animname ) ) ) )
	{
		str_extra_info += "(missing)";
		color = ( 1, 1, 0 );
	}
	while ( 1 )
	{
		originendpoint = guy.origin + vectorScale( anglesToForward( guy.angles ), 10 );
		anim_origin_render( guy.origin, guy.angles );
		recordenttext( "name: " + animname, guy, color, "ScriptedAnim" );
		recordenttext( "scene: " + scene + str_extra_info, guy, color, "ScriptedAnim" );
		if ( !isai( guy ) )
		{
			tagplayerorigin = guy gettagorigin( "tag_player" );
			if ( isDefined( tagplayerorigin ) )
			{
				tagplayerangles = guy gettagangles( "tag_player" );
				anim_origin_render( tagplayerorigin, tagplayerangles );
				record3dtext( "plr", tagplayerorigin, ( 1, 1, 0 ), "ScriptedAnim" );
			}
			tagcameraorigin = guy gettagorigin( "tag_camera" );
			if ( isDefined( tagcameraorigin ) )
			{
				tagcameraangles = guy gettagangles( "tag_camera" );
				anim_origin_render( tagcameraorigin, tagcameraangles );
				record3dtext( "cam", tagcameraorigin, ( 1, 1, 0 ), "ScriptedAnim" );
			}
		}
		wait 0,05;
#/
	}
}
