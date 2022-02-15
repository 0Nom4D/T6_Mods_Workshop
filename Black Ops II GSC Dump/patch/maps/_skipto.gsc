#include maps/_music;
#include maps/_busing;
#include maps/_loadout;
#include maps/_load_common;
#include maps/_hud_util;
#include maps/_debug;
#include maps/_utility;
#include common_scripts/utility;

add_skipto_construct( msg, func, loc_string, optional_func )
{
	array = [];
	array[ "name" ] = msg;
	array[ "skipto_func" ] = func;
	array[ "skipto_loc_string" ] = loc_string;
	array[ "logic_func" ] = optional_func;
	return array;
}

add_skipto_assert()
{
/#
	assert( !isDefined( level._loadstarted ), "Can't create skiptos after _load" );
#/
	if ( !isDefined( level.skipto_functions ) )
	{
		level.skipto_functions = [];
	}
}

level_has_skipto_points()
{
	return level.skipto_functions.size > 1;
}

is_default_skipto()
{
	if ( isDefined( level.default_skipto ) && level.default_skipto == level.skipto_point )
	{
		return 1;
	}
	if ( level_has_skipto_points() )
	{
		return level.skipto_point == level.skipto_functions[ 0 ][ "name" ];
	}
	return 0;
}

is_first_skipto()
{
	if ( !level_has_skipto_points() )
	{
		return 1;
	}
	return level.skipto_point == level.skipto_functions[ 0 ][ "name" ];
}

is_after_skipto( skipto_name )
{
	hit_current_skipto = 0;
	if ( level.skipto_point == skipto_name )
	{
		return 0;
	}
	i = 0;
	while ( i < level.skipto_functions.size )
	{
		if ( level.skipto_functions[ i ][ "name" ] == skipto_name )
		{
			hit_current_skipto = 1;
			i++;
			continue;
		}
		else
		{
			if ( level.skipto_functions[ i ][ "name" ] == level.skipto_point )
			{
				return hit_current_skipto;
			}
		}
		i++;
	}
}

indicate_skipto( skipto )
{
	if ( isDefined( getDvar( #"95EB46BE" ) ) && getDvarInt( #"95EB46BE" ) )
	{
		return;
	}
	hudelem = newhudelem();
	hudelem.alignx = "left";
	hudelem.aligny = "top";
	hudelem.x = 0;
	hudelem.y = 80;
	hudelem settext( skipto );
	hudelem.alpha = 0;
	hudelem.fontscale = 3;
	wait 1;
	hudelem fadeovertime( 1 );
	hudelem.alpha = 1;
	wait 5;
	hudelem fadeovertime( 1 );
	hudelem.alpha = 0;
	wait 1;
	hudelem destroy();
}

handle_skiptos()
{
	if ( !isDefined( getDvar( "skipto" ) ) )
	{
		setdvar( "skipto", "" );
	}
	if ( !isDefined( level.skipto_functions ) )
	{
		level.skipto_functions = [];
	}
	skipto = tolower( getDvar( "skipto" ) );
	names = get_skipto_names();
	if ( isDefined( level.skipto_point ) )
	{
		skipto = level.skipto_point;
	}
	skipto_index = 0;
	i = 0;
	while ( i < names.size )
	{
		if ( skipto == names[ i ] )
		{
			skipto_index = i;
			level.skipto_point = names[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	while ( !isDefined( level.skipto_point ) )
	{
		if ( isDefined( level.default_skipto ) )
		{
			level.skipto_point = level.default_skipto;
		}
		else
		{
			if ( level_has_skipto_points() )
			{
				level.skipto_point = level.skipto_functions[ 0 ][ "name" ];
			}
		}
		if ( !isDefined( level.skipto_point ) )
		{
			return;
		}
		i = 0;
		while ( i < names.size )
		{
			if ( level.skipto_point == names[ i ] )
			{
				skipto_index = i;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	flag_wait( "level.player" );
	waittillframeend;
	thread skipto_menu();
	if ( !is_default_skipto() )
	{
		savegame( "levelstart", 0, &"AUTOSAVE_LEVELSTART", "", 1 );
	}
	skipto_array = level.skipto_arrays[ level.skipto_point ];
	if ( !is_default_skipto() )
	{
		if ( isDefined( skipto_array[ "skipto_loc_string" ] ) )
		{
			thread indicate_skipto( skipto_array[ "skipto_loc_string" ] );
		}
		else
		{
			thread indicate_skipto( level.skipto_point );
		}
	}
	if ( isDefined( level.func_skipto_cleanup ) )
	{
		[[ level.func_skipto_cleanup ]]();
	}
	if ( isDefined( skipto_array[ "skipto_func" ] ) )
	{
		level flag_set( "running_skipto" );
		[[ skipto_array[ "skipto_func" ] ]]();
	}
	if ( is_default_skipto() )
	{
		string = get_string_for_skiptos( names );
		setdvar( "skipto", string );
	}
	level thread dev_skipto_warning();
	waittillframeend;
	previously_run_logic_functions = [];
	level flag_clear( "running_skipto" );
	if ( !isDefined( level.skipto_functions[ skipto_index ][ "logic_func" ] ) )
	{
		return;
	}
	logic_function_progression = build_logic_function_progression();
	logic_function_starting_index = get_logic_function_starting_index( skipto_index, logic_function_progression );
	i = logic_function_starting_index;
	while ( i < logic_function_progression.size )
	{
		next_logic_func = logic_function_progression[ i ];
		if ( already_ran_function( next_logic_func, previously_run_logic_functions ) )
		{
			i++;
			continue;
		}
		else
		{
			[[ next_logic_func ]]();
			previously_run_logic_functions[ previously_run_logic_functions.size ] = next_logic_func;
		}
		i++;
	}
}

already_ran_function( func, previously_run_logic_functions )
{
	i = 0;
	while ( i < previously_run_logic_functions.size )
	{
		if ( func == previously_run_logic_functions[ i ] )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

get_string_for_skiptos( names )
{
	string = " ** No skiptos have been set up for this map with maps_utility::add_skipto().";
	while ( names.size )
	{
		string = " ** ";
		i = names.size - 1;
		while ( i >= 0 )
		{
			string = string + names[ i ] + " ";
			i--;

		}
	}
	setdvar( "skipto", string );
	return string;
}

create_skipto( skipto, index )
{
	alpha = 1;
	color = vectorScale( ( 1, 1, 1 ), 0,9 );
	if ( index != -1 )
	{
		if ( index != 4 )
		{
			alpha = 1 - ( abs( 4 - index ) / 4 );
		}
		else
		{
			color = ( 1, 1, 1 );
		}
	}
	if ( alpha == 0 )
	{
		alpha = 0,05;
	}
	hudelem = newhudelem();
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
}

skipto_menu()
{
	for ( ;; )
	{
		if ( isDefined( getDvarInt( "debug_skipto" ) ) && getDvarInt( "debug_skipto" ) )
		{
			setdvar( "debug_skipto", 0 );
			setsaveddvar( "hud_drawhud", 1 );
			get_players()[ 0 ] allowjump( 0 );
			display_skiptos();
			get_players()[ 0 ] allowjump( 1 );
		}
		if ( getDvarInt( "debug_start" ) )
		{
			setdvar( "debug_start", 0 );
			setsaveddvar( "hud_drawhud", 1 );
			get_players()[ 0 ] allowjump( 0 );
			display_skiptos();
			get_players()[ 0 ] allowjump( 1 );
		}
		wait 0,05;
	}
}

skipto_nogame()
{
	guys = getaiarray();
	guys = arraycombine( guys, getspawnerarray(), 1, 0 );
	i = 0;
	while ( i < guys.size )
	{
		guys[ i ] delete();
		i++;
	}
}

get_skipto_names()
{
	names = [];
	i = 0;
	while ( i < level.skipto_functions.size )
	{
		names[ names.size ] = level.skipto_functions[ i ][ "name" ];
		i++;
	}
	return names;
}

display_skiptos()
{
	if ( level.skipto_functions.size <= 0 )
	{
		return;
	}
	names = get_skipto_names();
	names[ names.size ] = "default";
	names[ names.size ] = "cancel";
	elems = skipto_list_menu();
	title = create_skipto( "Selected skipto:", -1 );
	title.color = ( 1, 1, 1 );
	strings = [];
	i = 0;
	while ( i < names.size )
	{
		s_name = names[ i ];
		skipto_string = "[" + names[ i ] + "]";
		if ( s_name != "cancel" && s_name != "default" && s_name != "no_game" )
		{
			skipto_string += " -> ";
			if ( isDefined( level.skipto_arrays[ s_name ][ "skipto_loc_string" ] ) )
			{
			}
		}
		strings[ strings.size ] = skipto_string;
		i++;
	}
	selected = names.size - 1;
	up_pressed = 0;
	down_pressed = 0;
	found_current_skipto = 0;
	while ( selected > 0 )
	{
		if ( names[ selected ] == level.skipto_point )
		{
			found_current_skipto = 1;
			break;
		}
		else
		{
			selected--;

		}
	}
	if ( !found_current_skipto )
	{
		selected = names.size - 1;
	}
	skipto_list_settext( elems, strings, selected );
	old_selected = selected;
	for ( ;; )
	{
		if ( old_selected != selected )
		{
			skipto_list_settext( elems, strings, selected );
			old_selected = selected;
		}
		if ( !up_pressed )
		{
			if ( !get_players()[ 0 ] buttonpressed( "UPARROW" ) || get_players()[ 0 ] buttonpressed( "DPAD_UP" ) && get_players()[ 0 ] buttonpressed( "APAD_UP" ) )
			{
				up_pressed = 1;
				selected--;

			}
		}
		else
		{
			if ( !get_players()[ 0 ] buttonpressed( "UPARROW" ) && !get_players()[ 0 ] buttonpressed( "DPAD_UP" ) && !get_players()[ 0 ] buttonpressed( "APAD_UP" ) )
			{
				up_pressed = 0;
			}
		}
		if ( !down_pressed )
		{
			if ( !get_players()[ 0 ] buttonpressed( "DOWNARROW" ) || get_players()[ 0 ] buttonpressed( "DPAD_DOWN" ) && get_players()[ 0 ] buttonpressed( "APAD_DOWN" ) )
			{
				down_pressed = 1;
				selected++;
			}
		}
		else
		{
			if ( !get_players()[ 0 ] buttonpressed( "DOWNARROW" ) && !get_players()[ 0 ] buttonpressed( "DPAD_DOWN" ) && !get_players()[ 0 ] buttonpressed( "APAD_DOWN" ) )
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
			skipto_display_cleanup( elems, title );
			return;
		}
		else if ( !get_players()[ 0 ] buttonpressed( "kp_enter" ) || get_players()[ 0 ] buttonpressed( "BUTTON_A" ) && get_players()[ 0 ] buttonpressed( "enter" ) )
		{
			if ( names[ selected ] == "cancel" )
			{
				skipto_display_cleanup( elems, title );
				return;
			}
			else
			{
				setdvar( "skipto", names[ selected ] );
				fastrestart();
			}
			wait 0,05;
		}
	}
}

skipto_list_menu()
{
	hud_array = [];
	i = 0;
	while ( i < 8 )
	{
		hud = create_skipto( "", i );
		hud_array[ hud_array.size ] = hud;
		i++;
	}
	return hud_array;
}

skipto_list_settext( hud_array, strings, num )
{
	i = 0;
	while ( i < hud_array.size )
	{
		index = i + ( num - 4 );
		if ( isDefined( strings[ index ] ) )
		{
			text = strings[ index ];
		}
		else
		{
			text = "";
		}
		hud_array[ i ] settext( text );
		i++;
	}
}

skipto_display_cleanup( elems, title )
{
	title destroy();
	i = 0;
	while ( i < elems.size )
	{
		elems[ i ] destroy();
		i++;
	}
}

dev_skipto_warning()
{
	if ( !is_current_skipto_dev() )
	{
		return;
	}
	hudelem = newhudelem();
	hudelem.alignx = "left";
	hudelem.aligny = "top";
	hudelem.x = 0;
	hudelem.y = 70;
	hudelem settext( "This skipto is for development purposes only!  The level may not progress from this point." );
	hudelem.alpha = 1;
	hudelem.fontscale = 1,8;
	hudelem.color = ( 1, 0,55, 0 );
	wait 7;
	hudelem fadeovertime( 1 );
	hudelem.alpha = 0;
	wait 1;
	hudelem destroy();
}

is_current_skipto_dev()
{
	substr = tolower( getsubstr( level.skipto_point, 0, 4 ) );
	if ( substr == "dev_" )
	{
		return 1;
	}
	return 0;
}

is_no_game_skipto()
{
	if ( !isDefined( level.skipto_point ) )
	{
		return 0;
	}
	return issubstr( level.skipto_point, "no_game" );
}

do_no_game_skipto()
{
	if ( !is_no_game_skipto() )
	{
		return;
	}
	level.stop_load = 1;
	if ( isDefined( level.custom_no_game_setupfunc ) )
	{
		level [[ level.custom_no_game_setupfunc ]]();
	}
/#
	thread maps/_radiant_live_update::main();
#/
	maps/_loadout::init_loadout();
	maps/_anim::init();
	maps/_busing::businit();
	maps/_music::music_init();
	maps/_global_fx::main();
	maps/_hud_message::init();
	thread maps/_ingamemenus::init();
/#
	thread maps/_debug::maindebug();
#/
	level thread all_players_connected();
	level thread all_players_spawned();
	level thread maps/_endmission::main();
	array_thread( getentarray( "water", "targetname" ), ::maps/_load_common::waterthink );
	thread maps/_interactive_objects::main();
	thread maps/_audio::main();
	maps/_hud::init();
/#
	thread maps/_dev::init();
#/
	level waittill( "eternity" );
}

build_logic_function_progression()
{
	logic_function_progression = [];
	i = 0;
	while ( i < level.skipto_functions.size )
	{
		skipto_array = level.skipto_functions[ i ];
		if ( !isDefined( skipto_array[ "logic_func" ] ) )
		{
			i++;
			continue;
		}
		else
		{
			logic_function_progression[ logic_function_progression.size ] = skipto_array[ "logic_func" ];
		}
		i++;
	}
	return logic_function_progression;
}

get_logic_function_starting_index( skipto_index, logic_function_progression )
{
	starting_logic_func = level.skipto_functions[ skipto_index ][ "logic_func" ];
	i = 0;
	while ( i < logic_function_progression.size )
	{
		if ( starting_logic_func == logic_function_progression[ i ] )
		{
			return i;
		}
		i++;
	}
}
