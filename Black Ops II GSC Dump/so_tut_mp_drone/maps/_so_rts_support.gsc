#include maps/_cic_turret;
#include maps/_so_rts_poi;
#include maps/_so_rts_catalog;
#include maps/_utility_code;
#include maps/_endmission;
#include maps/_hud_util;
#include maps/_so_rts_squad;
#include animscripts/shared;
#include animscripts/init;
#include animscripts/utility;
#include maps/_so_rts_main;
#include maps/_so_rts_ai;
#include maps/sp_killstreaks/_killstreaks;
#include maps/_so_rts_event;
#include maps/_so_rts_support;
#include maps/_music;
#include maps/_scene;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

find_ground_pos( v_current, v_trace_end, checkent )
{
	v_ground = undefined;
	if ( !isDefined( v_trace_end ) )
	{
		v_down = vectorScale( ( 0, 0, 1 ), 20000 );
		v_trace_end = v_current + v_down;
	}
	if ( isDefined( checkent ) )
	{
		a_trace = entitytrace( v_current, v_trace_end, checkent );
		if ( a_trace[ "fraction" ] == 1 )
		{
			return ( 0, 0, 1 );
		}
		else
		{
			return a_trace[ "position" ];
		}
	}
	else
	{
		a_trace = bullettrace( v_current, v_trace_end, 0, level.player );
	}
	if ( a_trace[ "fraction" ] < 1 )
	{
		v_hit = a_trace[ "position" ];
		n_distance = distance( v_current, v_hit );
		n_threshold = 5000;
		if ( n_distance < n_threshold )
		{
			v_ground = v_hit;
		}
	}
	return v_ground;
}

do_switch_transition( targetent )
{
/#
	assert( isDefined( level.rts.static_trans_time ) );
#/
	level.rts.switch_trans = 1;
	self setclientflag( 1 );
	wait 0,1;
	if ( isDefined( targetent ) && isDefined( level.rts.playerlinkobj ) )
	{
		level.rts.playerlinkobj moveto( targetent.origin + ( 0, 0, 1 ), 0,4, 0 );
	}
	start = getTime();
	cur = start;
	last = cur;
	end = start + level.rts.static_trans_time;
	half = start + level.rts.static_trans_time_half;
	near = start + level.rts.static_trans_time_nearhalf;
/#
	println( "^^^^^^^^^^^^^^ do_switch_transition start ->" + start );
#/
	while ( cur < end )
	{
		if ( last < near && cur >= near )
		{
/#
			println( "^^^^^^^^^^^^^^ notify switch_nearfullstatic at " + getTime() );
#/
			level notify( "switch_nearfullstatic" );
			self notify( "switch_nearfullstatic" );
			level.disable_damage_overlay = 1;
		}
		if ( last < half && cur >= half )
		{
/#
			println( "^^^^^^^^^^^^^^ notify switch_fullstatic at " + getTime() );
#/
			level notify( "switch_fullstatic" );
			self notify( "switch_fullstatic" );
			self stopshellshock();
			self notify( "empGrenadeShutOff" );
			if ( isDefined( self.hud_damagefeedback ) )
			{
				self.hud_damagefeedback.alpha = 0;
			}
		}
		last = cur;
		if ( ( cur + 0,15 ) > end && ( last + 0,15 ) < end )
		{
			level notify( "switch_nearend" );
			self notify( "switch_nearend" );
		}
		wait 0,05;
		cur = getTime();
	}
	level notify( "switch_complete" );
	self notify( "switch_complete" );
	if ( flag( "fps_mode" ) )
	{
		level.disable_damage_overlay = 0;
	}
	self clearclientflag( 1 );
/#
	println( "^^^^^^^^^^^^^^ do_switch_transition end ->" + getTime() + " Total Time: " + int( getTime() - start ) );
#/
	level.rts.switch_trans = undefined;
}

hide_player_hud()
{
	level notify( "hide_hint" );
	setsaveddvar( "hud_showStance", "0" );
	setsaveddvar( "hud_showObjectives", "0" );
	setsaveddvar( "ammoCounterHide", "1" );
	setsaveddvar( "cg_drawCrosshair", 0 );
	_a130 = getplayers();
	_k130 = getFirstArrayKey( _a130 );
	while ( isDefined( _k130 ) )
	{
		player = _a130[ _k130 ];
		player cleardamageindicator();
		player setclientdvars( "cg_drawfriendlynames", 0 );
		player setclientuivisibilityflag( "hud_visible", 0 );
		_k130 = getNextArrayKey( _a130, _k130 );
	}
	luinotifyevent( &"hud_hide_shadesHud" );
}

show_player_hud()
{
	if ( !flag( "rts_hud_on" ) )
	{
		return;
	}
	setsaveddvar( "hud_showStance", "1" );
	setsaveddvar( "hud_showObjectives", "1" );
	setsaveddvar( "ammoCounterHide", "0" );
	setsaveddvar( "cg_drawCrosshair", 1 );
	_a149 = getplayers();
	_k149 = getFirstArrayKey( _a149 );
	while ( isDefined( _k149 ) )
	{
		player = _a149[ _k149 ];
		player setclientuivisibilityflag( "hud_visible", 1 );
		player setclientdvars( "cg_drawfriendlynames", 1 );
		_k149 = getNextArrayKey( _a149, _k149 );
	}
	luinotifyevent( &"hud_show_shadesHud" );
}

mp_ents_cleanup()
{
	entitytypes = getentarray();
	i = 0;
	while ( i < entitytypes.size )
	{
		if ( isDefined( entitytypes[ i ].script_gameobjectname ) )
		{
			if ( !isDefined( entitytypes[ i ].targetname ) || entitytypes[ i ].targetname != "so_dont_delete" )
			{
				entitytypes[ i ] delete();
			}
		}
		if ( isDefined( entitytypes[ i ].targetname ) && entitytypes[ i ].targetname == "so_delete" )
		{
			entitytypes[ i ] delete();
		}
		i++;
	}
}

playerlinkobj_zoom( amount, time )
{
	if ( isDefined( level.rts.fov_lerp ) )
	{
		return;
	}
	if ( !isDefined( time ) || time <= 0 )
	{
		time = 0,05;
	}
	if ( amount < 0 )
	{
		if ( level.rts.fov == 15 )
		{
			return;
		}
		if ( level.rts.fov == 65 )
		{
			level.rts.fov = 15;
		}
		if ( level.rts.fov == 110 )
		{
			level.rts.fov = 65;
		}
	}
	if ( amount > 0 )
	{
		if ( level.rts.fov == 110 )
		{
			return;
		}
		if ( level.rts.fov == 65 )
		{
			level.rts.fov = 110;
		}
		if ( level.rts.fov == 15 )
		{
			level.rts.fov = 65;
		}
	}
	if ( amount == 0 )
	{
		level.rts.fov = 65;
	}
	level.rts.fov_lerp = 1;
	level.rts.player setclientflag( 2 );
	rpc( "clientscripts/_so_rts", "lerp_fov_overtime", time, level.rts.fov );
	wait time;
	level.rts.player clearclientflag( 2 );
	level.rts.fov_lerp = undefined;
}

playerlinkobj_orient( x, y )
{
	x = angleClamp180( level.rts.playerlinkobj.angles[ 0 ] + x );
	y = angleClamp180( level.rts.playerlinkobj.angles[ 1 ] + y );
	z = angleClamp180( level.rts.playerlinkobj.angles[ 2 ] );
	if ( x > 89 )
	{
		x = 89;
	}
	if ( x < -20 )
	{
		x = -20;
	}
	level.rts.playerlinkobj.angles = ( x, y, z );
}

playerlinkobj_rotate( amount )
{
	angles = ( 0, amount, 0 );
	ground = playerlinkobj_gettargetgroundpos();
	diff = level.rts.playerlinkobj.origin - ground;
	diff = rotatepoint( diff, angles );
	newpoint = ground + diff;
	level.rts.playerlinkobj.origin = ( newpoint[ 0 ], newpoint[ 1 ], level.rts.playerlinkobj.origin[ 2 ] );
	level.rts.playerlinkobj.angles += ( 0, amount, 0 );
}

playerlinkobj_gettargetgroundpos( force )
{
	if ( isDefined( force ) || !isDefined( level.rts.ground ) )
	{
		forward = anglesToForward( get_player_angles() );
		projected = ( forward * 10000 ) + level.rts.playerlinkobj.origin;
		if ( level.rts.trace_ents.size > 0 )
		{
			closest = 8192;
			bestground = find_ground_pos( level.rts.playerlinkobj.origin, projected );
			_a256 = level.rts.trace_ents;
			_k256 = getFirstArrayKey( _a256 );
			while ( isDefined( _k256 ) )
			{
				ent = _a256[ _k256 ];
				ground = find_ground_pos( level.rts.playerlinkobj.origin, projected, ent );
				if ( ground == ( 0, 0, 1 ) )
				{
				}
				else
				{
					dist = distance( ground, level.rts.playerlinkobj.origin );
					if ( dist < closest )
					{
						bestground = ground;
						closest = dist;
					}
				}
				_k256 = getNextArrayKey( _a256, _k256 );
			}
			level.rts.ground = bestground;
		}
		else
		{
			level.rts.ground = find_ground_pos( level.rts.playerlinkobj.origin, projected );
		}
	}
/#
#/
	return level.rts.ground;
}

playerlinkobj_getforwardvector( scale )
{
	if ( !isDefined( scale ) )
	{
		scale = 5000;
	}
	return anglesToForward( level.rts.playerlinkobj.angles ) * scale;
}

playerlinkobj_defaultpos()
{
	maps/_so_rts_support::playerlinkobj_zoom( 0, 0 );
	if ( !isDefined( level.rts.lastfpspoint ) )
	{
		level.rts.lastfpspoint = level.rts.player_startpos;
	}
	height = level.rts.minplayerz + ( ( level.rts.maxplayerz - level.rts.minplayerz ) * 0,5 );
	if ( isDefined( level.rts.game_rules.tact_clamp ) && !level.rts.game_rules.tact_clamp )
	{
		level.rts.playerlinkobj.origin = ( level.rts.lastfpspoint[ 0 ], level.rts.lastfpspoint[ 1 ], height );
		a = level.rts.game_rules.default_camera_pitch;
		c = 90 - level.rts.game_rules.default_camera_pitch;
		sidec = ( height * sin( c ) ) / sin( a );
		dirvec = anglesToForward( level.rts.player.angles );
		addvec = dirvec * sidec * -1;
		level.rts.playerlinkobj.origin += addvec;
	}
	else
	{
		skypos = level.rts.lastfpspoint + ( 0, 0, height );
		testpos = movepoint( level.rts.lastfpspoint, ( 0, 0, height ) );
		if ( skypos != testpos )
		{
			if ( isDefined( level.rts.level_default_fps_pos ) )
			{
				level.rts.lastfpspoint = level.rts.level_default_fps_pos;
			}
			else
			{
				level.rts.lastfpspoint = level.rts.player_startpos;
			}
			skypos = level.rts.lastfpspoint + ( 0, 0, height );
			a = level.rts.game_rules.default_camera_pitch;
			c = 90 - level.rts.game_rules.default_camera_pitch;
			sidec = ( height * sin( c ) ) / sin( a );
			dirvec = anglesToForward( level.rts.player.angles );
			addvec = dirvec * sidec * -1;
			desiredpos = skypos + addvec;
			testpos = movepoint( skypos, addvec );
			if ( desiredpos == testpos )
			{
				level.rts.playerlinkobj.origin = desiredpos;
			}
			else
			{
				level.rts.playerlinkobj.origin = skypos;
			}
		}
		else a = level.rts.game_rules.default_camera_pitch;
		c = 90 - level.rts.game_rules.default_camera_pitch;
		sidec = ( height * sin( c ) ) / sin( a );
		dirvec = anglesToForward( level.rts.player.angles );
		addvec = dirvec * sidec * -1;
		desiredpos = skypos + addvec;
		testpos = movepoint( skypos, addvec );
		if ( desiredpos == testpos )
		{
			level.rts.playerlinkobj.origin = desiredpos;
		}
		else
		{
			level.rts.playerlinkobj.origin = skypos;
		}
	}
	level.rts.playerlinkobj.angles = ( level.rts.game_rules.default_camera_pitch, level.rts.player.angles[ 1 ], 0 );
	playerlinkobj_viewclamp();
}

playerlinkobj_viewclamp( onlyz )
{
	obj = level.rts.playerlinkobj;
	if ( obj.origin[ 2 ] < level.rts.minplayerz )
	{
		obj.origin = ( obj.origin[ 0 ], obj.origin[ 1 ], level.rts.minplayerz );
	}
	if ( obj.origin[ 2 ] > level.rts.maxplayerz )
	{
		obj.origin = ( obj.origin[ 0 ], obj.origin[ 1 ], level.rts.maxplayerz );
	}
	if ( !isDefined( onlyz ) && level.rts.game_rules.camera_mode == 1 )
	{
		frac = ( obj.origin[ 2 ] - level.rts.minplayerz ) / ( level.rts.maxplayerz - level.rts.minplayerz );
		level.rts.viewangle = -20 + ( ( 89 - -20 ) * frac );
		obj.angles = ( level.rts.viewangle, obj.angles[ 1 ], 0 );
	}
}

playerlinkobj_moveobj( x, y )
{
	if ( !isDefined( level.rts.playerlinkobj_moveincforward ) )
	{
		angle = ( 0, level.rts.playerlinkobj.angles[ 1 ], level.rts.playerlinkobj.angles[ 2 ] );
		level.rts.playerlinkobj_moveincforward = anglesToForward( angle ) * 64;
		level.rts.playerlinkobj_moveincright = anglesToRight( angle ) * 64;
	}
	forward = vectorScale( level.rts.playerlinkobj_moveincforward, x );
	right = vectorScale( level.rts.playerlinkobj_moveincright, y );
	if ( isDefined( level.rts.game_rules.tact_clamp ) && level.rts.game_rules.tact_clamp )
	{
		level.rts.playerlinkobj.origin = movepoint( level.rts.playerlinkobj.origin, forward + right );
	}
	else
	{
		level.rts.playerlinkobj.origin += forward + right;
		clampenttomapboundary( level.rts.playerlinkobj );
	}
}

rotate_point_around_point( v_point_to_rotate, v_point_to_rotate_around, delta_angles )
{
}

ally_missile_watcher( ally )
{
	if ( !isDefined( ally ) )
	{
		return;
	}
	self waittill( "remote_missile_start" );
	if ( !isDefined( ally ) )
	{
		return;
	}
	if ( isDefined( ally.classname ) && ally.classname == "script_vehicle" )
	{
		ally veh_magic_bullet_shield( 1 );
		ally useby( self );
		ally makevehicleunusable();
		ally maps/_vehicle::stop();
	}
	else
	{
		ally.takedamage = 0;
	}
	self waittill( "remotemissile_done" );
	if ( !isDefined( ally ) )
	{
		return;
	}
	if ( !flag( "rts_game_over" ) )
	{
		if ( isDefined( ally.classname ) && ally.classname == "script_vehicle" )
		{
			ally maps/_vehicle::stop();
			ally veh_magic_bullet_shield( 0 );
			ally makevehicleusable();
			ally usevehicle( self, 0 );
			ally makevehicleunusable();
			return;
		}
		else
		{
			ally.takedamage = 1;
		}
	}
}

missile_out_of_bounds_watcher()
{
	level endon( "fire_missile_done" );
	while ( 1 )
	{
		inbounds = 1;
		rocket = level.rts.player.missile_sp;
		if ( isDefined( rocket ) && isDefined( level.rts.bounds ) )
		{
			if ( isDefined( level.rts.missile_oob_check ) )
			{
				inbounds = [[ level.rts.missile_oob_check ]]( rocket.origin );
				break;
			}
			else
			{
				x = rocket.origin[ 0 ];
				y = rocket.origin[ 1 ];
				z = rocket.origin[ 2 ];
				if ( x <= level.rts.bounds.ulx )
				{
					inbounds = 0;
				}
				else
				{
					if ( x >= level.rts.bounds.lrx )
					{
						inbounds = 0;
					}
				}
				if ( y <= level.rts.bounds.uly )
				{
					inbounds = 0;
				}
				else
				{
					if ( y >= level.rts.bounds.lry )
					{
						inbounds = 0;
					}
				}
				if ( z <= level.rts.bounds.minz )
				{
					inbounds = 0;
				}
			}
		}
		if ( !inbounds )
		{
			maps/_so_rts_event::trigger_event( "air_strike_aborted" );
			if ( isDefined( rocket.owner ) )
			{
			}
			rocket delete();
			return;
		}
		wait 0,5;
	}
}

fire_missile()
{
	hide_player_hud();
	level.rts.player notify( "empGrenadeShutOff" );
	flag_set( "block_input" );
	player_vehicle = undefined;
	if ( !flag( "rts_mode" ) )
	{
		if ( isDefined( level.rts.player.ally ) && isDefined( level.rts.player.ally.vehicle ) )
		{
			player_vehicle = level.rts.player.ally.vehicle;
			player_vehicle veh_magic_bullet_shield( 1 );
			player_vehicle.allow_oob = 1;
			rpc( "clientscripts/_vehicle", "damage_filter_off" );
		}
		level.rts.player enableinvulnerability();
		level.rts.player.ignoreme = 1;
	}
	level notify( "fire_missile" );
	level.rts.player clearclientflag( 3 );
	level.rts.player setclientflag( 2 );
	if ( !isDefined( level.remotemissile_override_origin ) )
	{
		level.remotemissile_override_origin = ( 3025, 3756, 25750 );
	}
	if ( !isDefined( level.remotemissile_override_angles ) )
	{
		level.remotemissile_override_angles = vectorScale( ( 0, 0, 1 ), 112 );
	}
	level.rts.remotemissile = 1;
	if ( isDefined( level.rts.remotemissile_target ) )
	{
		level.remotemissile_override_target = level.rts.remotemissile_target.origin;
	}
	else if ( isDefined( level.rts.enemy_center ) )
	{
		level.remotemissile_override_target = level.rts.enemy_center.origin;
	}
	else
	{
		level.remotemissile_override_target = level.rts.player.origin;
	}
	oldfov = getDvarFloat( "cg_missile_FOV" );
	setdvar( "cg_missile_FOV", 45 );
	setdvar( "throwback_enabled", 0 );
	setdvar( "grenade_indicators_enabled", 0 );
	level.rts.player maps/sp_killstreaks/_killstreaks::usekillstreak( "remote_missile_sp" );
	level.rts.player waittill( "remote_missile_start" );
	luinotifyevent( &"rts_predator_hud", 1, 1 );
	level.rts.player stopshellshock();
	level.rts.player notify( "empGrenadeShutOff" );
	if ( !flag( "rts_mode" ) )
	{
		if ( isDefined( player_vehicle ) )
		{
			nodes = getnodesinradiussorted( player_vehicle.origin, 1024, 0 );
			if ( nodes.size )
			{
				player_vehicle.origin = nodes[ 0 ].origin;
			}
			player_vehicle maps/_vehicle::stop();
			if ( isDefined( level.rts.player.ally.swapai ) )
			{
				player_swapvehicle = level.rts.player.ally.swapai;
			}
			level.rts.player thread maps/_so_rts_ai::restorereplacement();
			level.rts.player waittill_notify_or_timeout( "exit_vehicle", 0,1 );
			if ( isDefined( player_vehicle ) )
			{
				player_vehicle veh_magic_bullet_shield( 1 );
				player_vehicle.ignoreme = 1;
			}
			else
			{
				player_vehicle = player_swapvehicle;
				player_swapvehicle.takedamage = 0;
				player_swapvehicle.ignoreme = 1;
			}
		}
		level.rts.player enableinvulnerability();
		level.rts.player.ignoreme = 1;
	}
	maps/_so_rts_event::trigger_event( "weapon_away" );
	level.rts.player thread take_and_giveback_weapons( "remotemissile_done" );
	level.rts.player thread missile_out_of_bounds_watcher();
	maps/_so_rts_event::trigger_event( "mus_missile_fire" );
	targeticon = undefined;
	if ( isDefined( level.rts.enemy_base ) && isDefined( isDefined( level.rts.enemy_base.entity ) ) )
	{
		level.rts.enemy_base.entity.takedamage = 1;
		targeticon = spawn( "script_model", level.rts.enemy_base.entity.origin );
		targeticon.angles = level.rts.enemy_base.entity.angles;
		targeticon setmodel( "tag_origin" );
		targeticon linkto( level.rts.enemy_base.entity );
		playfxontag( level._effect[ "missile_reticle" ], targeticon, "tag_origin" );
	}
	level.rts.player waittill( "remotemissile_done" );
	level.rts.remotemissile = undefined;
	screen_fade_out( 0 );
	setdvar( "cg_missile_FOV", oldfov );
	setdvar( "throwback_enabled", 1 );
	setdvar( "grenade_indicators_enabled", 1 );
	luinotifyevent( &"rts_predator_hud", 1, 0 );
	if ( isDefined( targeticon ) )
	{
		targeticon delete();
	}
	level.rts.player clearclientflag( 2 );
	wait 0,2;
	thread screen_fade_in( 0,4 );
	if ( !flag( "rts_game_over" ) )
	{
		toggle_damage_indicators( 1 );
		maps/_so_rts_event::trigger_event( "air_strike_failed" );
		show_player_hud();
		flag_clear( "block_input" );
		if ( flag( "rts_mode" ) )
		{
			level.rts.player setclientflag( 3 );
			maps/_so_rts_main::rts_menu();
		}
		else
		{
			maps/_so_rts_main::fps_menu();
		}
		if ( !flag( "rts_mode" ) )
		{
			if ( isDefined( player_vehicle ) )
			{
				level.rts.player maps/_so_rts_ai::takeoverselectedvehicle( player_vehicle );
				if ( !isDefined( player_swapvehicle ) )
				{
					player_vehicle veh_magic_bullet_shield( 0 );
					player_vehicle.ignoreme = 0;
				}
				else
				{
					player_swapvehicle.takedamage = 1;
					player_swapvehicle.ignoreme = 0;
				}
				player_vehicle.allow_oob = undefined;
			}
			else
			{
				level.rts.player.ignoreme = 0;
				level.rts.player disableinvulnerability();
			}
		}
		if ( isDefined( level.rts.enemy_base ) && isDefined( isDefined( level.rts.enemy_base.entity ) ) )
		{
			level.rts.enemy_base.entity.takedamage = 0;
		}
	}
	level notify( "fire_missile_done" );
}

debugline( frompoint, topoint, color, durationframes )
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

drawcylinder( pos, rad, height, duration, stop_notify )
{
/#
	if ( !isDefined( duration ) )
	{
		duration = 0;
	}
	level thread drawcylinder_think( pos, rad, height, duration, stop_notify );
#/
}

drawcylinder_think( pos, rad, height, seconds, stop_notify )
{
/#
	if ( !isDefined( seconds ) )
	{
		seconds = 9999;
	}
	if ( isDefined( stop_notify ) )
	{
		level endon( stop_notify );
	}
	stop_time = getTime() + ( seconds * 1000 );
	currad = rad;
	curheight = height;
	for ( ;; )
	{
		if ( seconds > 0 && stop_time <= getTime() )
		{
			return;
		}
		r = 0;
		while ( r < 20 )
		{
			theta = ( r / 20 ) * 360;
			theta2 = ( ( r + 1 ) / 20 ) * 360;
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
			r++;
		}
		wait 0,05;
#/
	}
}

debug_circle( origin, radius, color, time )
{
/#
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( time ) )
	{
		time = 1;
	}
	circle( origin, radius, color, 1, 1, time );
#/
}

debug_sphere( origin, radius, color, alpha, time )
{
/#
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( alpha ) )
	{
		alpha = 0,7;
	}
	if ( !isDefined( time ) )
	{
		time = 1;
	}
	sides = int( 10 * ( 1 + ( int( radius ) % 100 ) ) );
	sphere( origin, radius, color, alpha, 1, sides, time );
#/
}

debug_sphere_until_notify( origin, radius, color, alpha, note, note2 )
{
/#
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( alpha ) )
	{
		alpha = 0,7;
	}
	if ( !isDefined( note ) )
	{
		note = "sphere_debug_off";
	}
	if ( !isDefined( note2 ) )
	{
		note2 = "sphere_debug_off";
	}
	self endon( note );
	self endon( note2 );
	self endon( "death" );
	while ( 1 )
	{
		debug_sphere( origin, radius, color, alpha, 1 );
		wait 0,05;
#/
	}
}

debug_entline_until_notify( froment, topoint, color, note, note2 )
{
/#
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( note ) )
	{
		note = "line_debug_off";
	}
	if ( !isDefined( note2 ) )
	{
		note2 = "line_debug_off";
	}
	self endon( note );
	self endon( note2 );
	self endon( "death" );
	while ( 1 )
	{
		line( froment.origin, topoint, color );
		wait 0,05;
#/
	}
}

debug_draw_goalpos( center, color )
{
/#
	self endon( "death" );
	self notify( "draw_goalpos" );
	self endon( "draw_goalpos" );
	while ( 1 )
	{
		if ( isDefined( self.special_node ) )
		{
			debug_sphere( self.special_node.origin, 32, ( 0,7, 0, 1 ), 0,5, 1 );
			line( self.origin, self.special_node.origin, ( 0, 0, 1 ) );
			drawnode( self.special_node );
			if ( !isDefined( center ) )
			{
				center = self.goalpos;
			}
			line( self.origin, center, color );
			debug_sphere( center, 32, color, 0,5, 1 );
		}
		else
		{
			if ( !isDefined( center ) )
			{
				center = self.goalpos;
			}
			line( self.origin, center, color );
			if ( isDefined( self.node ) )
			{
				line( self.origin, self.node.origin, ( 0, 0, 1 ) );
				drawnode( self.node );
			}
			debug_sphere( center, 32, color, 0,5, 1 );
		}
		wait 0,05;
#/
	}
}

place_weapon_on( weapon, location )
{
/#
	assert( isai( self ) );
#/
	if ( !animscripts/utility::aihasweapon( weapon ) )
	{
		animscripts/init::initweapon( weapon );
	}
	animscripts/shared::placeweaponon( weapon, location );
}

get_weapon_name_from_alt( weapon )
{
	if ( weaponinventorytype( weapon ) != "altmode" )
	{
/#
		assertmsg( "Get weapon name from alt called on non alt weapon." );
#/
		return weapon;
	}
	weapon_name_parts = strtok( weapon, "_" );
	weapon_primary = "";
	i = 1;
	while ( i < weapon_name_parts.size )
	{
		weapon_primary += weapon_name_parts[ i ];
		if ( i != ( weapon_name_parts.size - 1 ) )
		{
			weapon_primary += "_";
		}
		i++;
	}
	return weapon_primary;
}

remapkeybindingparam( binding, param )
{
	level.rts.keyactions[ binding ].param = param;
}

registerkeybinding( binding, callback, param, flag )
{
	keyaction = spawnstruct();
	keyaction.binding = binding;
	keyaction.callback = callback;
	keyaction.param = param;
	keyaction.gateflag = flag;
	if ( !isDefined( level.rts.keyactions ) )
	{
		level.rts.keyactions = [];
	}
	level.rts.keyactions[ binding ] = keyaction;
}

debounceallbuttons()
{
	if ( !isDefined( level.rts.buttons ) )
	{
		return;
	}
	i = 0;
	while ( i < level.rts.buttons.tags.size )
	{
		level.rts.buttons.bits[ i ] = 0;
		i++;
	}
}

getbuttonpress()
{
	retval = "NO_INPUT";
	if ( flag( "block_button_press" ) )
	{
		debounceallbuttons();
		return retval;
	}
	if ( !isDefined( level.rts.buttons ) )
	{
		level.rts.buttons = spawnstruct();
		tags = [];
		bits = [];
		times = [];
		tags[ tags.size ] = "BUTTON_BACK";
		tags[ tags.size ] = "DPAD_UP";
		tags[ tags.size ] = "DPAD_DOWN";
		tags[ tags.size ] = "DPAD_LEFT";
		tags[ tags.size ] = "DPAD_RIGHT";
		tags[ tags.size ] = "BUTTON_X";
		tags[ tags.size ] = "BUTTON_Y";
		tags[ tags.size ] = "BUTTON_B";
		tags[ tags.size ] = "BUTTON_A";
		tags[ tags.size ] = "BUTTON_RSHLDR";
		tags[ tags.size ] = "BUTTON_LSHLDR";
		tags[ tags.size ] = "BUTTON_LSTICK";
		tags[ tags.size ] = "BUTTON_RSTICK";
		tags[ tags.size ] = "BUTTON_LTRIG";
		tags[ tags.size ] = "BUTTON_RTRIG";
		i = 0;
		while ( i < tags.size )
		{
			bits[ bits.size ] = 0;
			times[ times.size ] = getTime();
			i++;
		}
		level.rts.buttons.tags = tags;
		level.rts.buttons.bits = bits;
		level.rts.buttons.times = times;
	}
	tag = undefined;
	aux = undefined;
	i = 0;
	while ( i < level.rts.buttons.tags.size )
	{
		if ( level.rts.buttons.bits[ i ] == 3 )
		{
			tag = level.rts.buttons.tags[ i ];
			level.rts.buttons.bits[ i ] = 0;
			break;
		}
		else
		{
			if ( level.rts.player platformbuttonpressed( level.rts.buttons.tags[ i ] ) && level.rts.buttons.bits[ i ] == 0 )
			{
				level.rts.buttons.bits[ i ] = 1;
				level.rts.buttons.times[ i ] = getTime();
			}
			i++;
		}
	}
	leveltime = getTime();
	i = 0;
	while ( i < level.rts.buttons.tags.size )
	{
		if ( level.rts.buttons.bits[ i ] == 1 )
		{
			if ( !level.rts.player platformbuttonpressed( level.rts.buttons.tags[ i ] ) )
			{
				level.rts.buttons.bits[ i ] = 3;
				i++;
				continue;
			}
			else
			{
				if ( ( leveltime - level.rts.buttons.times[ i ] ) > 500 )
				{
					level.rts.buttons.bits[ i ] = 4;
					tag = level.rts.buttons.tags[ i ] + "_LONG";
					break;
				}
			}
			else
			{
				if ( level.rts.buttons.bits[ i ] == 4 && !level.rts.player platformbuttonpressed( level.rts.buttons.tags[ i ] ) )
				{
					level.rts.buttons.bits[ i ] = 0;
				}
			}
			i++;
		}
	}
	if ( isDefined( tag ) && isDefined( level.rts.keyactions ) && isDefined( level.rts.keyactions[ tag ] ) )
	{
		action = level.rts.keyactions[ tag ];
		if ( isDefined( action ) )
		{
			if ( isDefined( action.gateflag ) )
			{
				if ( flag( action.gateflag ) )
				{
					[[ action.callback ]]( action.param );
				}
			}
			else
			{
				[[ action.callback ]]( action.param );
			}
		}
	}
	if ( isDefined( tag ) )
	{
		retval = tag;
	}
	level notify( "button_event" );
	return retval;
}

platformbuttonpressed( button )
{
	if ( !level.console && !level.rts.player gamepadusedlast() )
	{
		switch( button )
		{
			case "BUTTON_BACK":
				binding = getkeybinding( "+scores" );
				break;
			case "DPAD_LEFT":
				binding = getkeybinding( "+actionslot 3" );
				break;
			case "DPAD_UP":
				binding = getkeybinding( "+actionslot 1" );
				break;
			case "DPAD_RIGHT":
				binding = getkeybinding( "+actionslot 4" );
				break;
			case "DPAD_DOWN":
				binding = getkeybinding( "+actionslot 2" );
				break;
			case "BUTTON_LSHLDR":
				binding = getkeybinding( "+smoke" );
				break;
		}
		pressed = 0;
		if ( isDefined( binding ) )
		{
			if ( binding[ "count" ] )
			{
				pressed = self buttonpressed( tolower( binding[ "key1" ] ) );
			}
			if ( !pressed && binding[ "count" ] == 2 )
			{
				pressed = self buttonpressed( tolower( binding[ "key2" ] ) );
			}
			return pressed;
		}
	}
	switch( button )
	{
		case "BUTTON_LSHLDR":
			return self secondaryoffhandbuttonpressed();
		case "BUTTON_RSHLDR":
			return self fragbuttonpressed();
		case "BUTTON_LSTICK":
			return self sprintbuttonpressed();
		case "BUTTON_RSTICK":
			return self meleebuttonpressed();
		case "BUTTON_LTRIG":
			return self adsbuttonpressed();
		case "BUTTON_RTRIG":
			return self attackbuttonpressed();
		case "BUTTON_X":
			return self usebuttonpressed();
		case "BUTTON_Y":
			return self inventorybuttonpressed();
		case "BUTTON_A":
			return self jumpbuttonpressed();
	}
	if ( level.wiiu )
	{
		controllertype = level.rts.player getcontrollertype();
		if ( controllertype == "remote" || controllertype == "classic" )
		{
			switch( button )
			{
				case "DPAD_UP":
					button = "BUTTON_WIIU_REWARD_UP";
					break;
				case "DPAD_DOWN":
					button = "BUTTON_WIIU_REWARD_DOWN";
					break;
				case "DPAD_LEFT":
					button = "BUTTON_WIIU_REWARD_LEFT";
					break;
				case "DPAD_RIGHT":
					button = "BUTTON_WIIU_REWARD_RIGHT";
					break;
			}
		}
		if ( controllertype == "remote" && button == "BUTTON_BACK" )
		{
			button = "WIIU_2";
		}
	}
	return self buttonpressed( button );
}

get_ents_touching_trigger( total_ents )
{
	touching = [];
	if ( !isDefined( total_ents ) )
	{
		total_ents = arraycombine( getplayers(), getaiarray(), 1, 0 );
	}
	_a1124 = total_ents;
	_k1124 = getFirstArrayKey( _a1124 );
	while ( isDefined( _k1124 ) )
	{
		ent = _a1124[ _k1124 ];
		if ( ent istouching( self ) )
		{
			touching[ touching.size ] = ent;
		}
		_k1124 = getNextArrayKey( _a1124, _k1124 );
	}
	return touching;
}

placevehicle( ref, origin, team )
{
/#
	assert( isDefined( ref ) );
#/
/#
	assert( isDefined( origin ) );
#/
	if ( !isDefined( team ) )
	{
		team = "allies";
	}
	spawner = get_vehicle_spawner( ref );
/#
	assert( isDefined( spawner ), "Invalid vehicle spawner targetname: " + ref );
#/
	spawner.origin = origin;
	vehicle = maps/_vehicle::spawn_vehicle_from_targetname( ref );
/#
	assert( isDefined( vehicle ), "vehicle failed to spawn." );
#/
	vehicle.team = team;
	vehicle.vteam = team;
	vehicle.hasbeenplanted = 1;
/#
	recordent( vehicle );
#/
	vehicle addvehicletocompass( "tank" );
	vehicle maps/_vehicle::stop();
	return vehicle;
}

callbackonnotify( note, cb, param1, param2 )
{
/#
	assert( isDefined( cb ) );
#/
	if ( note != "death" )
	{
		self endon( "death" );
		self waittill( note );
	}
	else
	{
		self waittill( "death" );
	}
	if ( isDefined( param1 ) && isDefined( param2 ) )
	{
		self [[ cb ]]( param1, param2 );
	}
	else
	{
		if ( isDefined( param1 ) )
		{
			self [[ cb ]]( param1 );
			return;
		}
		else
		{
			self [[ cb ]]();
		}
	}
}

notifylevelondelete( note )
{
	self waittill_any( "death", "delete" );
	level notify( note );
}

deletemeonnotify( note )
{
	self endon( "death" );
	self waittill( note );
	self delete();
}

setflaginnsec( flag, seconds )
{
	wait seconds;
/#
	println( "Setting flag(" + flag + ") at time: " + getTime() );
#/
	flag_set( flag );
}

notifymeinnsec( note, seconds, p1, p2, p3, p4, p5 )
{
	self endon( "death" );
	wait seconds;
	if ( isDefined( p1 ) && isDefined( p2 ) && isDefined( p3 ) && isDefined( p4 ) && isDefined( p5 ) )
	{
		self notify( note );
	}
	else
	{
		if ( isDefined( p1 ) && isDefined( p2 ) && isDefined( p3 ) && isDefined( p4 ) )
		{
			self notify( note );
			return;
		}
		else
		{
			if ( isDefined( p1 ) && isDefined( p2 ) && isDefined( p3 ) )
			{
				self notify( note );
				return;
			}
			else
			{
				if ( isDefined( p1 ) && isDefined( p2 ) )
				{
					self notify( note );
					return;
				}
				else
				{
					if ( isDefined( p1 ) )
					{
						self notify( note );
						return;
					}
					else
					{
						self notify( note );
					}
				}
			}
		}
	}
}

getnearai( fromorigin, distsq, team )
{
	if ( !isDefined( team ) )
	{
		ai = getaiarray();
	}
	else
	{
		ai = getaiarray( team );
	}
	ainear = [];
	_a1244 = ai;
	_k1244 = getFirstArrayKey( _a1244 );
	while ( isDefined( _k1244 ) )
	{
		dude = _a1244[ _k1244 ];
		if ( distancesquared( dude.origin, fromorigin ) < distsq )
		{
			ainear[ ainear.size ] = dude;
		}
		_k1244 = getNextArrayKey( _a1244, _k1244 );
	}
	return ainear;
}

getfarai( fromorigin, distsq, team )
{
	if ( !isDefined( team ) )
	{
		ai = getaiarray();
	}
	else
	{
		ai = getaiarray( team );
	}
	aifar = [];
	_a1265 = ai;
	_k1265 = getFirstArrayKey( _a1265 );
	while ( isDefined( _k1265 ) )
	{
		dude = _a1265[ _k1265 ];
		if ( distancesquared( dude.origin, fromorigin ) > distsq )
		{
			aifar[ aifar.size ] = dude;
		}
		_k1265 = getNextArrayKey( _a1265, _k1265 );
	}
	return aifar;
}

chopper_wait_for_closest_open_path_start( target_origin, start_name, struct_string_field, team, type )
{
	path_start = undefined;
	while ( 1 )
	{
		path_start = chopper_closest_open_path_start( target_origin, start_name, struct_string_field, team, type );
		if ( isDefined( path_start ) )
		{
			break;
		}
		else
		{
			wait 0,25;
		}
	}
	return path_start;
}

chopper_closest_open_path_start( target_origin, start_name, struct_string_field, team, type )
{
	path_starts = getvehiclenodearray( start_name, "targetname" );
/#
	assert( path_starts.size, "No heli path nodes with targetname: " + start_name );
#/
	if ( isDefined( level.rts.use_random_drop_path ) && level.rts.use_random_drop_path )
	{
		avail_paths = [];
		_a1304 = path_starts;
		_k1304 = getFirstArrayKey( _a1304 );
		while ( isDefined( _k1304 ) )
		{
			path_start = _a1304[ _k1304 ];
			if ( isDefined( path_start.in_use ) )
			{
			}
			else if ( isDefined( path_start.script_team ) && path_start.script_team != team )
			{
			}
			else
			{
				if ( isDefined( type ) && isDefined( path_start.script_linkname ) && !issubstr( path_start.script_linkname, type ) )
				{
					break;
				}
				else
				{
					avail_paths[ avail_paths.size ] = path_start;
				}
			}
			_k1304 = getNextArrayKey( _a1304, _k1304 );
		}
		if ( avail_paths.size )
		{
			return avail_paths[ randomint( avail_paths.size ) ];
		}
		else
		{
			return undefined;
		}
	}
	else
	{
		closest_path_start = undefined;
		closest_path_start_dist = undefined;
		closest_path_drop = undefined;
		_a1329 = path_starts;
		_k1329 = getFirstArrayKey( _a1329 );
		while ( isDefined( _k1329 ) )
		{
			path_start = _a1329[ _k1329 ];
			if ( isDefined( path_start.in_use ) )
			{
			}
			else if ( isDefined( path_start.script_team ) || !isDefined( team ) && path_start.script_team != team )
			{
			}
			else
			{
				if ( isDefined( type ) && isDefined( path_start.script_linkname ) && !issubstr( path_start.script_linkname, type ) )
				{
					break;
				}
				else
				{
					path_drop = path_start;
					found_path = 0;
					switch( struct_string_field )
					{
						case "script_unload":
							while ( !isDefined( path_drop.script_unload ) )
							{
								path_drop = getvehiclenode( path_drop.target, "targetname" );
							}
/#
							assert( isDefined( path_drop.script_unload ), "Level has a helicopter path without a struct with script_unload defined." );
#/
							if ( !isDefined( path_drop.script_unload ) )
							{
								break;
							}
							else found_path = 1;
							break;
						case "script_stopnode":
							while ( !isDefined( path_drop.script_stopnode ) )
							{
								path_drop = getvehiclenode( path_drop.target, "targetname" );
							}
/#
							assert( isDefined( path_drop.script_stopnode ), "Level has a helicopter path without a struct with script_stopnode defined." );
#/
							if ( !isDefined( path_drop.script_stopnode ) )
							{
								break;
							}
							else found_path = 1;
							break;
						default:
							while ( isDefined( path_drop.target ) || !isDefined( path_drop.script_noteworthy ) && path_drop.script_noteworthy != struct_string_field )
							{
								path_drop = getvehiclenode( path_drop.target, "targetname" );
							}
							if ( !isDefined( path_drop.target ) )
							{
								break;
							}
							else found_path = 1;
							break;
					}
/#
					assert( found_path, "No heli path found with a kvp matching: " + struct_string_field );
#/
					if ( !isDefined( closest_path_drop ) )
					{
						closest_path_drop = path_drop;
						closest_path_start_dist = distance2d( target_origin, path_drop.origin );
						closest_path_start = path_start;
						break;
					}
					else
					{
						path_drop_dist = distance2d( target_origin, path_drop.origin );
						if ( path_drop_dist < closest_path_start_dist )
						{
							closest_path_drop = path_drop;
							closest_path_start_dist = distance2d( target_origin, closest_path_drop.origin );
							closest_path_start = path_start;
						}
					}
				}
			}
			_k1329 = getNextArrayKey( _a1329, _k1329 );
		}
		if ( isDefined( closest_path_start ) )
		{
			closest_path_start.path_drop = closest_path_drop;
		}
		return closest_path_start;
	}
}

chopper_spawn_from_targetname_and_drive( name, spawn_origin, path_start, team )
{
	msg = "passed start struct without targetname: " + name;
/#
	assert( !isDefined( path_start.in_use ), "helicopter told to use path that is in use." );
#/
	path_start.in_use = 1;
	chopper = chopper_spawn_from_targetname( name, spawn_origin, team );
	chopper.path_start = path_start;
	chopper thread go_path( path_start );
	return chopper;
}

chopper_spawn_from_targetname( name, spawn_origin, team )
{
	chopper_spawner = get_vehicle_spawner( name );
/#
	assert( isDefined( chopper_spawner ), "Invalid chopper spawner targetname: " + name );
#/
	while ( isDefined( chopper_spawner.vehicle_spawned_thisframe ) )
	{
		wait 0,05;
	}
	chopper_spawner.vehicle_spawned_thisframe = 1;
	if ( isDefined( spawn_origin ) )
	{
		chopper_spawner.origin = spawn_origin;
	}
	chopper = maps/_vehicle::spawn_vehicle_from_targetname( name );
/#
	assert( isDefined( chopper ), "chopper failed to spawn." );
#/
	chopper setteam( team );
	chopper godon();
	if ( team == "axis" )
	{
		target_set( chopper );
	}
	wait 0,05;
	chopper_spawner.vehicle_spawned_thisframe = undefined;
	return chopper;
}

chopper_drop_smoke_at_unloading()
{
	self endon( "death" );
	self waittill_either( "unloading", "unload" );
	rappel_left_origin = self gettagorigin( "tag_fastrope_le" );
	if ( !isDefined( rappel_left_origin ) )
	{
		rappel_left_origin = self gettagorigin( "tag_enter_gunner" );
/#
		assert( isDefined( rappel_left_origin ), "Heli has no rappel tags" );
#/
	}
	groundposition = bullettrace( rappel_left_origin, rappel_left_origin + vectorScale( ( 0, 0, 1 ), 100000 ), 0, self )[ "position" ];
	self magicgrenadetype( "willy_pete_sp", groundposition, ( 0, 0, 1 ), 0 );
}

get_transport_startloc( droptarget, team, type )
{
	path_start = chopper_wait_for_closest_open_path_start( droptarget, "drop_path_start", "script_unload", team );
	return path_start;
}

chopper_send( droptarget, team, type, customunload )
{
/#
	assert( isDefined( team ) );
#/
/#
	assert( isDefined( type ) );
#/
/#
	if ( type != "helo" )
	{
		assert( type == "vtol", "Chopper type " + type + " not supported" );
	}
#/
	path_start = chopper_wait_for_closest_open_path_start( droptarget, "drop_path_start", "script_unload", team, type );
	chopper = chopper_spawn_from_targetname_and_drive( ( team + "_drop_" ) + type, path_start.origin, path_start, team );
	chopper.script_vehicle_selfremove = 1;
	if ( type == "helo" )
	{
		chopper.speed = 85;
	}
	if ( type == "vtol" )
	{
		chopper.speed = 60;
	}
	chopper vehicle_setspeed( chopper.speed, 30, "start helo path" );
	chopper.vehicle_passengersonly = 1;
	chopper.script_noteworthy = "transport";
	level notify( "chopper_inbound" );
	return chopper;
}

chopper_unload_rope_cargo( cargo, pkg_ref, team, squadid )
{
	self endon( "death" );
	if ( isai( cargo ) || cargo isvehicle() )
	{
		ai_ref = level.rts.ai[ pkg_ref.units[ 0 ] ];
		cargo.ai_ref = ai_ref;
		cargo maps/_so_rts_squad::addaitosquad( squadid );
	}
	self waittill( "unload" );
	self.cargo = undefined;
	cargo unlink();
	moverent = spawn( "script_origin", cargo.origin );
	cargo linkto( moverent );
	traceresults = bullettrace( cargo.origin, cargo.origin - vectorScale( ( 0, 0, 1 ), 2000 ), 0, cargo );
/#
	assert( traceresults[ "fraction" ] != 0, "Ground trace didn't hit anything" );
#/
	groundpos = traceresults[ "position" ];
	movetime = 3;
	moverent moveto( groundpos, movetime, 0,25, 0,25 );
	wait movetime;
	cargo unlink();
	if ( isai( cargo ) || cargo isvehicle() )
	{
		if ( cargo isvehicle() )
		{
			cargo maps/_vehicle::defend( cargo.origin, 600 );
		}
	}
	else
	{
		i = 0;
		while ( i < 10 )
		{
			playfx( level._effect[ "cargo_box_open" ], groundpos + ( randomint( 20 ), randomint( 20 ), randomint( 30 ) ) );
			i++;
		}
		wait 0,1;
		cargo delete();
		wait 0,25;
		x = 0;
		y = 0;
		_a1574 = pkg_ref.units;
		_k1574 = getFirstArrayKey( _a1574 );
		while ( isDefined( _k1574 ) )
		{
			unit = _a1574[ _k1574 ];
			ai_ref = level.rts.ai[ unit ];
			if ( ai_ref.species == "vehicle" )
			{
				guy = placevehicle( ai_ref.ref, groundpos + ( x * 36, y * 36, randomint( 36 ) ), team );
				goalpos = groundpos + ( randomint( 128 ), randomint( 128 ), 0 );
				x++;
				x %= 2;
				if ( x == 0 )
				{
					y++;
					y %= 2;
				}
			}
			else
			{
				guy = simple_spawn_single( ai_ref.ref, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
				guy forceteleport( groundpos + ( randomint( 30 ), randomint( 30 ), 0 ), ( 0, randomint( 180 ), 0 ) );
				goalpos = guy.origin;
			}
			if ( isDefined( guy ) )
			{
				guy.ai_ref = ai_ref;
				guy maps/_so_rts_squad::addaitosquad( squadid );
			}
			_k1574 = getNextArrayKey( _a1574, _k1574 );
		}
	}
	wait 1;
	self notify( "unloaded" );
}

chopper_release_path()
{
	self.path_start.in_use = undefined;
}

hud_message_scroll_down( text, endnote )
{
	level endon( endnote );
	while ( 1 )
	{
		text.y += 1;
		text.alpha -= 0,025;
		wait 0,05;
	}
}

kill_hud_message( text, note )
{
	level waittill_any( note, "kill_all_hud_messages" );
	text maps/_hud_util::destroyelem();
}

kill_hud_message_in_time( text, time, endnote )
{
	level endon( endnote );
	level thread kill_hud_message( text, endnote );
	wait ( time + 0,5 );
	level notify( endnote );
}

hud_message_queue()
{
	level endon( "rts_terminated" );
	if ( !isDefined( level.rts.hud_message_queue ) )
	{
		level.rts.hud_message_queue = [];
	}
	if ( !isDefined( level.challenge_awarded ) )
	{
		level.challenge_awarded = 0;
	}
	while ( 1 )
	{
		if ( level.rts.hud_message_queue.size > 0 && getTime() > ( level.challenge_awarded + 5000 ) )
		{
			msg = level.rts.hud_message_queue[ 0 ];
			arrayremoveindex( level.rts.hud_message_queue, 0, 0 );
			maps/_so_rts_event::trigger_event( "objective_update" );
			objective_printtext( "active", msg );
			waittill_any_timeout( 4, "hud_msg_queue_clearall" );
			continue;
		}
		else
		{
			wait 0,25;
		}
	}
}

create_hud_message( text, clearall )
{
	if ( !isDefined( clearall ) )
	{
		clearall = 0;
	}
	if ( !flag( "rts_hud_on" ) )
	{
		return;
	}
	if ( clearall )
	{
		level.rts.hud_message_queue = [];
		level notify( "hud_msg_queue_clearall" );
	}
	_a1680 = level.rts.hud_message_queue;
	_k1680 = getFirstArrayKey( _a1680 );
	while ( isDefined( _k1680 ) )
	{
		msg = _a1680[ _k1680 ];
		if ( msg == text )
		{
			return;
		}
		_k1680 = getNextArrayKey( _a1680, _k1680 );
	}
	level.rts.hud_message_queue[ level.rts.hud_message_queue.size ] = text;
}

time_countdown( timemin, owner, killnotify, luinote, expirednote, headertext, alertatoneandtwominutes )
{
	if ( !isDefined( killnotify ) )
	{
		killnotify = "kill_countdown";
	}
	if ( !isDefined( luinote ) )
	{
		luinote = "rts_time_left";
	}
	if ( !isDefined( expirednote ) )
	{
		expirednote = "expired";
	}
	if ( !isDefined( headertext ) )
	{
		headertext = "SO_RTS_MISSION_TIME_REMAINING_CAPS";
	}
	if ( !isDefined( alertatoneandtwominutes ) )
	{
		alertatoneandtwominutes = 1;
	}
	level endon( "rts_terminated" );
	level endon( "kill_timer" );
	owner endon( killnotify );
	msec = int( 1000 * timemin * 60 );
	if ( alertatoneandtwominutes )
	{
		luinotifyevent( istring( luinote ), 3, msec, istring( headertext ), 1 );
	}
	else
	{
		luinotifyevent( istring( luinote ), 2, msec, istring( headertext ) );
	}
	wait ( timemin * 60 );
	owner notify( expirednote );
}

time_countdown_delete( luinote )
{
	if ( !isDefined( luinote ) )
	{
		luinote = "rts_time_left";
	}
	level notify( "kill_timer" );
	luinotifyevent( istring( luinote ), 1, 0 );
}

missioncompletemsg( success )
{
}

missionfailuremenu()
{
	luinotifyevent( &"rts_hide_result" );
	luinotifyevent( &"rts_menu_mission_failed" );
	screen_fade_out( 0,5 );
	level clientnotify( "sndEndMenu" );
	flag_clear( "rts_mode_locked_out" );
	rpc( "clientscripts/_so_rts", "force_all_hudOutlinesOn", 0, 0 );
	wait 0,4;
	setmusicstate( "RTS_ACTION_END" );
	level.rts.lastfpspoint = undefined;
	maps/_so_rts_main::player_eyeinthesky( 0, 0, 1 );
	maps/_so_rts_support::playerlinkobj_defaultpos();
	level.rts.lastfpspoint = level.rts.player.origin;
	level.rts.player hideviewmodel();
	maps/_so_rts_support::hide_player_hud();
	thread screen_fade_in( 1 );
	flag_set( "block_input" );
	level.rts.player setclientuivisibilityflag( "hud_visible", 1 );
	level.rts.player freezecontrols( 0 );
	while ( 1 )
	{
		level.player waittill( "menuresponse", menu_action, action_arg );
		if ( menu_action == "rts_action" )
		{
			if ( action_arg == "mission_failed_retry" )
			{
/#
				println( "RTS mission_failed_retry: Retry mission" );
#/
				level clientnotify( "rts_fd" );
				wait 1;
				screen_fade_out( 1 );
				maps/_endmission::strikeforce_decrement_unit_tokens();
				luinotifyevent( &"rts_restart_mission" );
				break;
			}
			else if ( action_arg == "mission_failed_quit" )
			{
/#
				println( "RTS mission_failed_quit: Quit mission" );
#/
				break;
			}
		}
		else
		{
		}
	}
	level.rts.game_success = 0;
	flag_set( "rts_game_over" );
	flag_clear( "block_input" );
}

missionsuccessmenu()
{
	luinotifyevent( &"rts_hide_result" );
	luinotifyevent( &"rts_menu_mission_failed", 1, 1 );
	screen_fade_out( 0,5 );
	flag_clear( "rts_mode_locked_out" );
	level clientnotify( "sndEndMenu" );
	wait 0,4;
	setmusicstate( "RTS_ACTION_END" );
	level.rts.lastfpspoint = undefined;
	maps/_so_rts_main::player_eyeinthesky( 0, 0, 1 );
	maps/_so_rts_support::playerlinkobj_defaultpos();
	level.rts.lastfpspoint = level.rts.player.origin;
	level.rts.player hideviewmodel();
	maps/_so_rts_support::hide_player_hud();
	thread screen_fade_in( 1 );
	flag_set( "block_input" );
	level.rts.player setclientuivisibilityflag( "hud_visible", 1 );
	while ( 1 )
	{
		level.player waittill( "menuresponse", menu_action );
		if ( menu_action == "rts_action" )
		{
/#
			println( "RTS mission_successul: Calling next mission" );
#/
			level clientnotify( "rts_fd" );
			screen_fade_out( 1 );
			break;
		}
		else
		{
		}
	}
	level.rts.game_success = 0;
	flag_set( "rts_game_over" );
	flag_clear( "block_input" );
}

any_pending_gpr()
{
	if ( isDefined( self ) && isDefined( self.gpr_queue ) )
	{
		return self.gpr_queue.size > 0;
	}
	return 0;
}

process_pending_gpr_sets()
{
	self endon( "death" );
	if ( !isDefined( self.gpr_state ) )
	{
		self.gpr_state = 0;
	}
	waittillframeend;
	while ( 1 )
	{
		if ( self any_pending_gpr() )
		{
			nextgpr = self.gpr_queue[ 0 ];
			arrayremoveindex( self.gpr_queue, 0 );
			self setgpr( nextgpr );
			self.gpr_state = !self.gpr_state;
			if ( self.gpr_state == 1 )
			{
				self setclientflag( 5 );
				break;
			}
			else
			{
				self clearclientflag( 5 );
			}
		}
		wait 0,1;
	}
}

set_gpr( val, clearallfirst )
{
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( !isDefined( self.gpr_queue ) )
	{
		self.gpr_queue = [];
		self thread process_pending_gpr_sets();
	}
	if ( isDefined( clearallfirst ) && clearallfirst )
	{
		self.gpr_queue = [];
	}
	self.gpr_queue[ self.gpr_queue.size ] = val;
}

make_gpr_opcode( id )
{
	return id << 28;
}

flush_gpr()
{
	while ( self any_pending_gpr() )
	{
		wait 0,05;
	}
}

sortarraybyclosest( origin, array, maxdistsq, no3d, noai )
{
	if ( array.size == 0 )
	{
		return array;
	}
	if ( !isDefined( origin ) )
	{
		origin = level.rts.player.origin;
	}
	if ( isDefined( maxdistsq ) )
	{
		valid = [];
		_a1907 = array;
		_k1907 = getFirstArrayKey( _a1907 );
		while ( isDefined( _k1907 ) )
		{
			item = _a1907[ _k1907 ];
			if ( !isDefined( item ) )
			{
			}
			else if ( isDefined( no3d ) && no3d )
			{
				item calcent2dscreen();
				itemorigin = ( item.fx2d, item.fy2d, 0 );
			}
			else
			{
				itemorigin = item.origin;
			}
			distsq = distancesquared( origin, itemorigin );
			if ( distsq > maxdistsq )
			{
			}
			else
			{
				valid[ valid.size ] = item;
			}
			_k1907 = getNextArrayKey( _a1907, _k1907 );
		}
		array = valid;
	}
	if ( isDefined( noai ) && noai )
	{
		return maps/_utility_code::mergesort( array, ::closestcomparefunc, origin );
	}
	else
	{
		if ( isDefined( no3d ) && no3d )
		{
			return maps/_utility_code::mergesort( array, ::closestcomparefunc2d, origin );
		}
		else
		{
			return arraysort( array, origin, 1 );
		}
	}
}

sortarraybyfurthest( origin, array, mindistsq, no3d, noai )
{
	if ( isDefined( mindistsq ) )
	{
		valid = [];
		_a1951 = array;
		_k1951 = getFirstArrayKey( _a1951 );
		while ( isDefined( _k1951 ) )
		{
			item = _a1951[ _k1951 ];
			if ( !isDefined( item ) )
			{
			}
			else if ( isDefined( no3d ) && no3d )
			{
				item calcent2dscreen();
				itemorigin = ( item.fx2d, item.fy2d, 0 );
			}
			else
			{
				itemorigin = item.origin;
			}
			distsq = distancesquared( origin, itemorigin );
			item.lastdistcalc = distsq;
			if ( distsq < mindistsq )
			{
			}
			else
			{
				valid[ valid.size ] = item;
			}
			_k1951 = getNextArrayKey( _a1951, _k1951 );
		}
		array = valid;
	}
	if ( isDefined( noai ) && noai )
	{
		return maps/_utility_code::mergesort( array, ::furthestcomparefunc, origin );
	}
	else
	{
		if ( isDefined( no3d ) && no3d )
		{
			return maps/_utility_code::mergesort( array, ::furthestcomparefunc2d, origin );
		}
		else
		{
			return arraysort( array, origin, 0 );
		}
	}
}

getclosestinarray( origin, array )
{
	sortedarray = arraysort( array, origin, 1 );
	return sortedarray[ 0 ];
}

getfurthestinarray( origin, array )
{
	sortedarray = arraysort( array, origin, 0 );
	return sortedarray[ 0 ];
}

closestcomparefunc2d( e1, e2, origin )
{
	e1 calcent2dscreen();
	e2 calcent2dscreen();
	e1origin = ( e1.fx2d, e1.fy2d, 0 );
	e2origin = ( e2.fx2d, e2.fy2d, 0 );
	distsq1 = distancesquared( origin, e1origin );
	distsq2 = distancesquared( origin, e2origin );
	return distsq1 < distsq2;
}

furthestcomparefunc2d( e1, e2, origin )
{
	e1 calcent2dscreen();
	e2 calcent2dscreen();
	e1origin = ( e1.fx2d, e1.fy2d, 0 );
	e2origin = ( e2.fx2d, e2.fy2d, 0 );
	distsq1 = distancesquared( origin, e1origin );
	distsq2 = distancesquared( origin, e2origin );
	return distsq1 > distsq2;
}

closestcomparefunc( e1, e2, origin )
{
	distsq1 = distancesquared( origin, e1.origin );
	distsq2 = distancesquared( origin, e2.origin );
	return distsq1 < distsq2;
}

furthestcomparefunc( e1, e2, origin )
{
	distsq1 = distancesquared( origin, e1.origin );
	distsq2 = distancesquared( origin, e2.origin );
	return distsq1 > distsq2;
}

getclosestai( origin, team, distsqmax )
{
	aiteam = arraycombine( getvehiclearray( team ), getaiarray( team ), 0, 0 );
	sortedarray = arraysort( aiteam, origin, 1 );
	_a2046 = sortedarray;
	_k2046 = getFirstArrayKey( _a2046 );
	while ( isDefined( _k2046 ) )
	{
		ai = _a2046[ _k2046 ];
		distsq = distancesquared( origin, ai.origin );
		if ( distsq < distsqmax )
		{
			return ai;
		}
		_k2046 = getNextArrayKey( _a2046, _k2046 );
	}
	return undefined;
}

fademodelout( model, squadid, timesec )
{
	self notify( "fadeModelOut" + squadid );
	self endon( "fadeModelOut" + squadid );
	wait timesec;
	if ( isDefined( model ) )
	{
		model hide();
	}
}

player_plant_network_intruder( poi )
{
	flag_set( "block_input" );
	self enableinvulnerability();
	self.plantingnetworkintruder = 1;
	poi.intruder_being_planted = 1;
	player_tag_origin = spawn( "script_model", self.origin );
	player_tag_origin.angles = self.angles;
	player_tag_origin setmodel( "tag_origin" );
	player_tag_origin.targetname = "player_tag_origin";
	level thread run_scene( "plant_network_intruder" );
	wait 0,05;
	network_intruder = spawn( "script_model", self.origin );
	network_intruder setmodel( level.rts.intrudermodel );
	network_intruder.origin = self.m_scene_model gettagorigin( "tag_weapon" );
	network_intruder.angles = self.m_scene_model gettagangles( "tag_weapon" );
	network_intruder linkto( self.m_scene_model, "tag_weapon" );
/#
	recordent( network_intruder );
#/
	flag_wait( "plant_network_intruder_done" );
	self playrumbleonentity( "damage_heavy" );
	self disableinvulnerability();
	flag_clear( "block_input" );
	network_intruder unlink();
	normal = vectornormalize( poi.entity.origin - self.origin );
	origin = self.origin + vectorScale( normal, 12 );
	network_intruder.origin = origin;
	network_intruder.angles = self.angles;
	network_intruder.team = self.team;
	player_tag_origin delete();
	network_intruder thread setupnetworkintruder( poi );
	self.plantingnetworkintruder = 0;
	poi.intruder_being_planted = undefined;
}

ai_intruder_plant()
{
	self endon( "death" );
	self.a.deathforceragdoll = 1;
	self clearanim( %root, 0,2 );
	network_intruder = spawn( "script_model", self.origin );
	network_intruder.team = self.team;
	network_intruder setmodel( level.rts.intrudermodel );
	self thread ai_intruder_plant_cleanup( network_intruder );
	self.a.movement = "stop";
	self setflaggedanimknobrestart( "plantAnim", %ai_plant_claymore, 1, 0,2, 1 );
	self animscripts/shared::donotetracks( "plantAnim", ::ai_intruder_handle_notetracks, undefined, network_intruder );
	self.a.deathforceragdoll = 0;
	self findbestcovernode();
}

ai_intruder_plant_cleanup( network_intruder )
{
	self endon( "planted_intruder" );
	self waittill_any( "death" );
	network_intruder delete();
}

ai_intruder_handle_notetracks( notetrack, network_intruder )
{
	if ( notetrack == "plant" )
	{
		if ( isDefined( self.poi ) && isDefined( self.poi.has_intruder ) && !self.poi.has_intruder )
		{
			self notify( "planted_intruder" );
			network_intruder thread setupnetworkintruder( self.poi );
		}
	}
}

ai_plant_network_intruder( poi )
{
	self endon( "death" );
	self.poi = poi;
	self.poi.plant_attempt = getTime();
	self animcustom( ::ai_intruder_plant );
}

setupnetworkintruder( poi )
{
	level.rts.networkintruders[ self.team ][ level.rts.networkintruders[ self.team ].size ] = self;
	level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_INTRUDER_SET" );
	maps/_so_rts_event::trigger_event( ( poi.intruder_prefix + "_placed_" ) + self.team );
	maps/_so_rts_event::trigger_event( "sfx_intruder_planted" );
	level notify( "intruder_planted_" + poi.ref );
	poi.intruder = self;
	self.takedamage = 1;
	if ( self.team == "axis" )
	{
	}
	else
	{
	}
	self.health = 800;
	myorigin = self.origin;
	self thread blinky_light( level._effect[ "network_intruder_blink" ], "tag_fx" );
	self.sndloopingent = spawn( "script_origin", self.origin );
	self.sndloopingent playloopsound( "evt_rts_intruder_loop", 1 );
	fakevehicle = maps/_vehicle::spawn_vehicle_from_targetname( "fake_vehicle" );
	fakevehicle.team = self.team;
	fakevehicle.vteam = self.team;
	fakevehicle.origin = self.origin + vectorScale( ( 0, 0, 1 ), 8 );
	if ( self.team == "allies" )
	{
	}
	else
	{
		fakevehicle.threatbias = 6000;
	}
	fakevehicle linkto( self );
	entnum = self getentitynumber();
	luinotifyevent( &"rts_add_poi", 1, entnum );
	if ( self.team == "allies" )
	{
		luinotifyevent( &"rts_protect_poi", 2, entnum, poi.poinum );
	}
	if ( self.team == "axis" )
	{
		luinotifyevent( &"rts_destroy_poi", 2, entnum, poi.poinum );
	}
	level notify( "intruder_planted" );
	lastnotify = 0;
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage, attacker );
		while ( isDefined( attacker ) && attacker != self && isDefined( attacker.team ) && attacker.team == self.team )
		{
			self.health += damage;
		}
		if ( flag( "rts_mode" ) && self.team == "allies" )
		{
			self.health += int( damage * 0,6 );
		}
		if ( !isalive( self ) )
		{
			luinotifyevent( &"rts_del_poi", 1, entnum );
			if ( isDefined( attacker ) && attacker != self )
			{
				level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_INTRUDER_DESTROYED" );
				level notify( "intruder_disrupted" );
			}
			maps/_so_rts_event::trigger_event( "sfx_intruder_explode", self );
			maps/_so_rts_event::trigger_event( "fx_intruder_explode", myorigin );
			if ( isDefined( fakevehicle ) )
			{
				fakevehicle delete();
			}
			self.sndloopingent delete();
			self delete();
			arrayremovevalue( level.rts.networkintruders[ self.team ], self );
			if ( isDefined( poi.captured ) && !poi.captured )
			{
				maps/_so_rts_event::trigger_event( ( poi.intruder_prefix + "_died_" ) + self.team );
				maps/_so_rts_event::trigger_event( "sfx_intruder_fail" );
			}
			return;
			continue;
		}
		else
		{
			if ( getTime() > ( lastnotify - 4000 ) )
			{
				if ( isDefined( attacker ) && attacker != self )
				{
					maps/_so_rts_event::trigger_event( ( poi.intruder_prefix + "_hit_" ) + self.team );
					level thread maps/_so_rts_support::create_hud_message( &"SO_RTS_INTRUDER_ATTACK" );
					lastnotify = getTime();
				}
			}
		}
	}
}

sfxandfx( origin, sfx_alias, fx_alias )
{
	playfx( level._effect[ fx_alias ], origin );
	playsoundatposition( sfx_alias, origin );
	return 1;
}

blinky_light( fx, tagname )
{
	self endon( "death" );
	while ( 1 )
	{
		self playsound( "evt_rts_acoustic_sensor_beep" );
		if ( isDefined( self gettagorigin( tagname ) ) )
		{
			playfxontag( fx, self, tagname );
		}
		else
		{
			playfxontag( fx, self, "tag_origin" );
		}
		wait 0,5;
	}
}

setup_devgui()
{
/#
	setdvar( "cmd_send_chopper", "none" );
	setdvar( "cmd_take_poi", "none" );
	if ( getDvarInt( "scr_rts_enemyDisabled" ) == 0 )
	{
		setdvar( "scr_rts_enemyDisabled", "0" );
	}
	if ( getDvarInt( "scr_rts_enemyDebug" ) == 0 )
	{
		setdvar( "scr_rts_enemyDebug", "0" );
	}
	if ( getDvarInt( "scr_rts_allpkgs" ) == 0 )
	{
		setdvar( "scr_rts_allpkgs", "0" );
	}
	if ( getDvarInt( "scr_rts_cameraMode" ) == 0 )
	{
		setdvar( "scr_rts_cameraMode", "0" );
	}
	if ( getDvarInt( "scr_rts_squadDebug" ) == 0 )
	{
		setdvar( "scr_rts_squadDebug", "0" );
	}
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Ally Infantry:1" "cmd_send_chopper allies_helo"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Ally Quads:2" "cmd_send_chopper allies_quads"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Ally ASD:3" "cmd_send_chopper allies_asd"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Ally CLAW:4" "cmd_send_chopper allies_claw"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Enemy Infantry:5" "cmd_send_chopper axis_helo"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Enemy Quads:6" "cmd_send_chopper axis_quads"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Enemy ASD:7" "cmd_send_chopper axis_asd"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Helicopters:1/Send Enemy CLAW:8" "cmd_send_chopper axis_claw"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Enemy Mgr:2/Enabled:1/True:1" "scr_rts_enemyDisabled 0"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Enemy Mgr:2/Enabled:1/False:2" "scr_rts_enemyDisabled 1"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Enemy Mgr:2/Debug:2/On:1" "scr_rts_enemyDebug 1"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Enemy Mgr:2/Debug:2/Off:2" "scr_rts_enemyDebug 0"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Packages:3/Allow All:1/On:1" "scr_rts_allpkgs 1"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Packages:3/Allow All:1/Off:2" "scr_rts_allpkgs 0"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/All:1/Allies:1" "cmd_take_poi all_allies"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/All:1/Axis:2" "cmd_take_poi all_axis"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/1:2/Allies:1" "cmd_take_poi 1_allies"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/1:2/Axis:2" "cmd_take_poi 1_axis"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/2:3/Allies:1" "cmd_take_poi 2_allies"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/2:3/Axis:2" "cmd_take_poi 2_axis"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/3:4/Allies:1" "cmd_take_poi 3_allies"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/POIs:4/3:4/Axis:2" "cmd_take_poi 3_axis"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Camera:5/Mode:1/Look:1" "scr_rts_cameraMode 0"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Camera:5/Mode:1/Orbit:2" "scr_rts_cameraMode 1"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Squads:2/Debug:2/On:1" "scr_rts_squadDebug 1"\n" );
	adddebugcommand( "devgui_cmd "|RTS|/Squads:2/Debug:2/Off:2" "scr_rts_squadDebug 0"\n" );
	thread watch_devgui();
#/
}

watch_devgui()
{
/#
	pkg_refs = [];
	pkg_refs[ "helo" ] = "infantry_ally_reg_pkg";
	pkg_refs[ "quads" ] = "quadrotor_pkg";
	pkg_refs[ "asd" ] = "metalstorm_pkg";
	pkg_refs[ "claw" ] = "bigdog_pkg";
	lastcameramode = level.rts.game_rules.camera_mode;
	while ( 1 )
	{
		lastcameramode = int( getDvar( "scr_rts_cameraMode" ) );
		if ( lastcameramode != level.rts.game_rules.camera_mode )
		{
			level.rts.game_rules.camera_mode = lastcameramode;
			lastcameramode = level.rts.game_rules.camera_mode;
			if ( level.rts.game_rules.camera_mode == 1 )
			{
				level.rts.game_rules.minplayerz = 320;
				level.rts.game_rules.maxplayerz = 1200;
				level.rts.game_rules.zoom_avail = 1;
			}
			else
			{
				if ( level.rts.game_rules.camera_mode == 0 )
				{
					level.rts.game_rules.minplayerz = 400;
					level.rts.game_rules.maxplayerz = 400;
					level.rts.game_rules.zoom_avail = 0;
				}
			}
			level.rts.minplayerz = level.rts.player.origin[ 2 ] + level.rts.game_rules.minplayerz;
			level.rts.maxplayerz = level.rts.minplayerz + level.rts.game_rules.maxplayerz;
			if ( flag( "rts_mode" ) )
			{
				player_takeover_random_dude();
			}
		}
		cmd_send_chopper = getDvar( "cmd_send_chopper" );
		cmd_take_poi = getDvar( "cmd_take_poi" );
		if ( cmd_send_chopper != "none" )
		{
			cmd_tokens = strtok( cmd_send_chopper, "_" );
			team = cmd_tokens[ 0 ];
			type = cmd_tokens[ 1 ];
			iprintln( "Send chopper: " + cmd_send_chopper );
			package = maps/_so_rts_catalog::package_getpackagebytype( pkg_refs[ type ] );
			test_heli_dropoff( type, team, package );
			setdvar( "cmd_send_chopper", "none" );
		}
		if ( cmd_take_poi != "none" )
		{
			cmd_tokens = strtok( cmd_take_poi, "_" );
			which = cmd_tokens[ 0 ];
			team = cmd_tokens[ 1 ];
			iprintln( "Claim POI: " + cmd_take_poi );
			count = 1;
			i = 0;
			while ( i < level.rts.poi.size )
			{
				poi = level.rts.poi[ i ];
				if ( which == "all" )
				{
					maps/_so_rts_poi::claimpoi( poi, team );
					poi.dominate_weight = 99999;
					count++;
					continue;
				}
				else
				{
					if ( count == int( which ) )
					{
						maps/_so_rts_poi::claimpoi( poi, team );
						poi.dominate_weight = 99999;
						break;
					}
				}
				else
				{
					count++;
					i++;
				}
			}
			setdvar( "cmd_take_poi", "none" );
		}
		wait 0,05;
#/
	}
}

player_takeover_random_dude()
{
/#
	if ( flag( "rts_mode" ) )
	{
		allies = getaiarray( "allies" );
		valid = [];
		_a2473 = allies;
		_k2473 = getFirstArrayKey( _a2473 );
		while ( isDefined( _k2473 ) )
		{
			guy = _a2473[ _k2473 ];
			if ( !maps/_so_rts_ai::ai_isselectable( guy ) || isDefined( level.rts.squads[ guy.squadid ].selectable ) && !level.rts.squads[ guy.squadid ].selectable )
			{
			}
			else
			{
				valid[ valid.size ] = guy;
			}
			_k2473 = getNextArrayKey( _a2473, _k2473 );
		}
		allies = valid;
		if ( allies.size == 0 )
		{
			return;
		}
		level.rts.targetteammate = allies[ randomint( allies.size ) ];
		thread maps/_so_rts_main::player_in_control();
#/
	}
}

test_heli_dropoff( type, team, pkg_ref )
{
/#
	availtransport = spawnstruct();
	if ( type != "quads" || type == "asd" && type == "claw" )
	{
		availtransport.cb = ::maps/_so_rts_ai::spawn_ai_package_cargo;
	}
	else
	{
		availtransport.cb = ::maps/_so_rts_ai::spawn_ai_package_helo;
	}
	availtransport.param = undefined;
	availtransport.pkg_ref = pkg_ref;
	availtransport.type = type;
	availtransport.team = team;
	availtransport.state = 3;
	availtransport.loadtime = getTime();
	availtransport.droptarget = level.player.origin;
	availtransport.squadid = maps/_so_rts_squad::createsquad( availtransport.droptarget, team, pkg_ref );
	[[ availtransport.cb ]]( availtransport );
#/
}

toggle_damage_indicators( on )
{
	if ( on == 1 )
	{
		setdvar( "scr_damagefeedback", "1" );
		level.disable_damage_overlay = undefined;
	}
	else
	{
		setdvar( "scr_damagefeedback", "0" );
		if ( isDefined( level.rts.player.hud_damagefeedback ) )
		{
			level.rts.player.hud_damagefeedback.alpha = 0;
		}
		level.disable_damage_overlay = 1;
	}
}

formatfloat( number, decimals )
{
	power = pow( 10, decimals );
	temp = int( number * power );
	temp = float( temp / power );
	return temp;
}

get_player_angles()
{
	if ( isDefined( level.wiiu ) && level.wiiu )
	{
		return level.rts.player getgunangles();
	}
	else
	{
		return level.rts.player getplayerangles();
	}
}

calcent2dscreen()
{
	if ( !flag( "rts_mode" ) )
	{
		return;
	}
	time = getTime();
	if ( !isDefined( self.next2dcalc ) || self.next2dcalc < time )
	{
		angles = get_player_angles();
		normal = vectornormalize( self.origin - level.rts.player.origin );
		forward = anglesToForward( angles );
		dot = vectordot( forward, normal );
		if ( dot < 0 )
		{
			self.fx2d = -1000;
			self.fy2d = -1000;
		}
		else
		{
			up_vec1 = anglesToUp( angles );
			right_vec2 = anglesToRight( angles );
			forward_vec3 = anglesToForward( angles );
			p1 = level.rts.player.origin;
			p2 = p1 + vectorScale( up_vec1, 100 );
			p3 = p1 + vectorScale( right_vec2, 100 );
			r1 = self.origin;
			r2 = level.rts.player.origin + vectorScale( forward_vec3, -100 );
			vrotray1 = ( vectordot( up_vec1, r1 - p1 ), vectordot( right_vec2, r1 - p1 ), vectordot( forward_vec3, r1 - p1 ) );
			vrotray2 = ( vectordot( up_vec1, r2 - p1 ), vectordot( right_vec2, r2 - p1 ), vectordot( forward_vec3, r2 - p1 ) );
			if ( vrotray1[ 2 ] == vrotray2[ 2 ] )
			{
				self.fx2d = -1001;
				self.fy2d = -1001;
				return;
			}
			fpercent = vrotray1[ 2 ] / ( vrotray2[ 2 ] - vrotray1[ 2 ] );
			vintersect2d = vrotray1 + ( ( vrotray1 - vrotray2 ) * fpercent );
			self.fx2d = vintersect2d[ 0 ];
			self.fy2d = vintersect2d[ 1 ];
		}
		if ( !isDefined( self.next2dcalc ) )
		{
			self.next2dcalc = time + randomint( 10 ) + 150;
			return;
		}
		else
		{
			self.next2dcalc = time + 150;
		}
	}
}

deladditionaltarget( target, team )
{
	if ( isDefined( target ) )
	{
		luinotifyevent( &"rts_deselect", 1, target getentitynumber() );
		luinotifyevent( &"rts_deselect_enemy", 1, target getentitynumber() );
		luinotifyevent( &"rts_deselect_poi", 1, target getentitynumber() );
		arrayremovevalue( level.rts.additiontargets[ team ], target, 0 );
	}
}

addadditionaltarget( target, team )
{
	level.rts.additiontargets[ team ][ level.rts.additiontargets[ team ].size ] = target;
}

set_closestunitparams()
{
	if ( !isDefined( level.rts.closestunitparams ) )
	{
		level.rts.closestunitparams = spawnstruct();
		level.rts.closestunitparams.checkaivalid = 1;
		level.rts.closestunitparams.checkignoreme = 1;
		level.rts.closestunitparams.checknotplayerteam = 1;
		level.rts.closestunitparams.allowplayerteampip = 0;
	}
}

getclosestunittype( type, threshchecksq )
{
	if ( !isDefined( threshchecksq ) )
	{
		threshchecksq = 100;
	}
	origin = ( 0, 0, 1 );
	switch( type )
	{
		case 0:
			units = arraycombine( getvehiclearray( "allies" ), getaiarray( "allies" ), 0, 0 );
			units = arraycombine( units, level.rts.additiontargets[ "allies" ], 0, 0 );
			checkaivalid = level.rts.closestunitparams.checkaivalid;
			break;
		case 1:
			units = arraycombine( getvehiclearray( "axis" ), getaiarray( "axis" ), 0, 0 );
			units = arraycombine( units, level.rts.additiontargets[ "axis" ], 0, 0 );
			checkaivalid = level.rts.closestunitparams.checkaivalid;
			break;
		case 2:
			units = maps/_so_rts_poi::getpoients();
			checknotplayerteam = level.rts.closestunitparams.checknotplayerteam;
			checkignoreme = level.rts.closestunitparams.checkignoreme;
			break;
		default:
/#
			assert( 0, "unhandled type" );
#/
			break;
	}
	closest = undefined;
	sortedunits = sortarraybyclosest( origin, units, threshchecksq, 1 );
	i = 0;
	while ( i < sortedunits.size )
	{
		unit = sortedunits[ i ];
		if ( isDefined( checkaivalid ) && checkaivalid )
		{
			if ( !maps/_so_rts_ai::ai_isselectable( unit ) )
			{
				i++;
				continue;
			}
		}
		else if ( isDefined( checknotplayerteam ) && checknotplayerteam )
		{
			if ( unit.team == level.rts.player.team )
			{
				i++;
				continue;
			}
		}
		else if ( isDefined( checkignoreme ) && checkignoreme )
		{
			if ( isDefined( unit.ignoreme ) && unit.ignoreme )
			{
				i++;
				continue;
			}
		}
		else
		{
			closest = unit;
			break;
		}
		i++;
	}
	return closest;
}

unitreticletracker()
{
	level endon( "rts_terminated" );
	while ( flag( "rts_mode" ) )
	{
		if ( !flag( "unit_select_locked_out" ) )
		{
			closest = undefined;
			closestteamenemy = undefined;
			closest = getclosestunittype( 2 );
			if ( isDefined( closest ) )
			{
				if ( isDefined( level.rts.targetpoi ) && closest != level.rts.targetpoi )
				{
					luinotifyevent( &"rts_deselect_poi", 1, level.rts.targetpoi getentitynumber() );
					level.rts.targetpoi = undefined;
				}
				if ( !isDefined( level.rts.targetpoi ) )
				{
					luinotifyevent( &"rts_target_poi", 1, closest getentitynumber() );
					level.rts.targetpoi = closest;
					level.rts.targetteamenemy = undefined;
					thread pick_delayed_selection_sound( "poi", closest );
				}
			}
			else
			{
				if ( isDefined( level.rts.targetpoi ) )
				{
					luinotifyevent( &"rts_deselect_poi", 1, level.rts.targetpoi getentitynumber() );
					level.rts.targetpoi = undefined;
				}
			}
			if ( !isDefined( level.rts.targetpoi ) )
			{
				closestteamenemy = getclosestunittype( 1 );
				if ( isDefined( closestteamenemy ) )
				{
					if ( isDefined( level.rts.targetteamenemy ) && closestteamenemy != level.rts.targetteamenemy )
					{
						luinotifyevent( &"rts_deselect_enemy", 1, level.rts.targetteamenemy getentitynumber() );
						level.rts.targetteamenemy = undefined;
					}
					if ( !isDefined( level.rts.targetteamenemy ) )
					{
						luinotifyevent( &"rts_target_enemy", 1, closestteamenemy getentitynumber() );
						level.rts.targetteamenemy = closestteamenemy;
						thread pick_delayed_selection_sound( "axis", closestteamenemy );
					}
					break;
				}
				else
				{
					if ( isDefined( level.rts.targetteamenemy ) )
					{
						luinotifyevent( &"rts_deselect_enemy", 1, level.rts.targetteamenemy getentitynumber() );
						level.rts.targetteamenemy = undefined;
					}
				}
			}
			closest = getclosestunittype( 0 );
			if ( isDefined( closest ) )
			{
/#
				assert( maps/_so_rts_ai::ai_isselectable( closest ), "illegal target" );
#/
				if ( isDefined( level.rts.targetteammate ) && closest != level.rts.targetteammate )
				{
					luinotifyevent( &"rts_deselect", 1, level.rts.targetteammate getentitynumber() );
					level.rts.targetteammate = undefined;
				}
				if ( !isDefined( level.rts.targetteammate ) )
				{
					luinotifyevent( &"rts_target", 1, closest getentitynumber() );
					level.rts.targetteammate = closest;
					thread pick_delayed_selection_sound( "ally", closest );
				}
			}
			else
			{
				if ( isDefined( level.rts.targetteammate ) )
				{
					luinotifyevent( &"rts_deselect", 1, level.rts.targetteammate getentitynumber() );
					level.rts.targetteammate = undefined;
				}
			}
		}
		else
		{
			if ( isDefined( level.rts.targetpoi ) )
			{
				luinotifyevent( &"rts_deselect_poi", 1, level.rts.targetpoi getentitynumber() );
				level.rts.targetpoi = undefined;
			}
			if ( isDefined( level.rts.targetteamenemy ) )
			{
				luinotifyevent( &"rts_deselect_enemy", 1, level.rts.targetteamenemy getentitynumber() );
				level.rts.targetteamenemy = undefined;
			}
			if ( isDefined( level.rts.targetteammate ) )
			{
				luinotifyevent( &"rts_deselect", 1, level.rts.targetteammate getentitynumber() );
				level.rts.targetteammate = undefined;
			}
		}
		wait 0,1;
	}
	if ( isDefined( level.rts.targetpoi ) )
	{
		luinotifyevent( &"rts_deselect_poi", 1, level.rts.targetpoi getentitynumber() );
	}
	if ( isDefined( level.rts.targetteamenemy ) )
	{
		luinotifyevent( &"rts_deselect_enemy", 1, level.rts.targetteamenemy getentitynumber() );
	}
	if ( isDefined( level.rts.targetteammate ) )
	{
		luinotifyevent( &"rts_deselect", 1, level.rts.targetteammate getentitynumber() );
	}
}

pick_delayed_selection_sound( type, guy )
{
	wait 0,1;
	switch( type )
	{
		case "poi":
			if ( !isDefined( level.rts.targetpoi ) || level.rts.targetpoi != guy )
			{
				return;
			}
			maps/_so_rts_event::trigger_event( "poi_select" );
			return;
			case "axis":
				if ( !isDefined( level.rts.targetteamenemy ) || level.rts.targetteamenemy != guy )
				{
					return;
				}
				maps/_so_rts_event::trigger_event( "enemy_select" );
				return;
				case "ally":
					maps/_so_rts_event::trigger_event( "friendly_select", guy );
					return;
			}
		}
	}
}

get_selection_alias_from_targetname( guy, p2, p3 )
{
	if ( !isDefined( guy ) || !isDefined( guy.ai_ref.select_alias ) )
	{
		alias = "evt_rts_selection_friendly_generic";
	}
	else
	{
		alias = guy.ai_ref.select_alias;
	}
	playsoundatposition( alias, ( 0, 0, 1 ) );
	return 1;
}

block_player_damage_fortime( time )
{
/#
	println( "@$@ Player set to invulnerable at: " + getTime() + " for the next " + time + " seconds." );
#/
	self.blockalldamage = getTime() + ( time * 1000 );
}

set_as_target( team, offset )
{
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 1 );
	}
	faketarget = maps/_vehicle::spawn_vehicle_from_targetname( "fake_vehicle" );
	faketarget.team = team;
	faketarget.vteam = team;
	faketarget.origin = self getcentroid();
	faketarget.threatbias = -1000;
	faketarget linkto( self, "tag_origin", offset );
	self thread delete_ent_on_death( faketarget );
}

delete_ent_on_death( entity )
{
	self waittill( "death" );
	entity delete();
}

player_oobwatch()
{
	level endon( "mission_complete" );
	while ( 1 )
	{
		if ( isDefined( level.rts.player ) && level.rts.player maps/_so_rts_support::isentbelowmap() )
		{
			level.rts.player dodamage( level.rts.player.health + 9999, level.rts.player.origin, level.rts.player, 1, "suicide" );
		}
		wait 0,05;
	}
}

isentbelowmap()
{
	if ( isDefined( self.allow_oob ) && self.allow_oob )
	{
		return 0;
	}
	if ( isDefined( level.rts.bounds ) )
	{
		if ( self.origin[ 2 ] <= level.rts.bounds.minz )
		{
			return 1;
		}
	}
	return 0;
}

setupmapboundary()
{
	ulxy = getstruct( "rts_ulxy", "targetname" );
	lrxy = getstruct( "rts_lrxy", "targetname" );
	if ( isDefined( ulxy ) && isDefined( lrxy ) )
	{
		if ( ulxy.origin[ 0 ] < lrxy.origin[ 0 ] )
		{
		}
		else
		{
		}
		ux = lrxy.origin[ 0 ];
		if ( ulxy.origin[ 0 ] < lrxy.origin[ 0 ] )
		{
		}
		else
		{
		}
		lx = ulxy.origin[ 0 ];
		if ( ulxy.origin[ 1 ] < lrxy.origin[ 1 ] )
		{
		}
		else
		{
		}
		uy = lrxy.origin[ 1 ];
		if ( ulxy.origin[ 1 ] < lrxy.origin[ 1 ] )
		{
		}
		else
		{
		}
		ly = ulxy.origin[ 1 ];
		level.rts.bounds = spawnstruct();
		level.rts.bounds.ulx = ux;
		level.rts.bounds.uly = uy;
		level.rts.bounds.lrx = lx;
		level.rts.bounds.lry = ly;
		if ( ulxy.origin[ 2 ] < lrxy.origin[ 2 ] )
		{
		}
		else
		{
		}
		level.rts.bounds.minz = lrxy.origin[ 2 ];
		if ( ulxy.origin[ 2 ] < lrxy.origin[ 2 ] )
		{
		}
		else
		{
		}
		level.rts.bounds.maxz = ulxy.origin[ 2 ];
	}
}

clampenttomapboundary( ent, damage, warnmsg )
{
	if ( !isDefined( damage ) )
	{
		damage = 0;
	}
	if ( !isDefined( warnmsg ) )
	{
		warnmsg = 0;
	}
	if ( isDefined( ent.rts_unloaded ) && !ent.rts_unloaded && isDefined( damage ) && damage )
	{
		return 1;
	}
	if ( isDefined( ent.allow_oob ) && ent.allow_oob )
	{
		return 1;
	}
	val = clamporigintomapboundary( ent.origin );
	if ( val.inbounds )
	{
		return 1;
	}
	if ( isDefined( warnmsg ) && warnmsg )
	{
		if ( !isDefined( ent.oob_warning_time ) )
		{
			ent.oob_warning_time = getTime() + 5000;
			return 0;
		}
		if ( getTime() < ent.oob_warning_time )
		{
			return 0;
		}
	}
	if ( isDefined( damage ) && damage )
	{
		ent.armor = 0;
		if ( isDefined( ent.classname ) && ent.classname == "script_vehicle" )
		{
			ent veh_magic_bullet_shield( 0 );
		}
/#
		println( "@@@@ RIP: AI " + ent getentitynumber() + "[" + ent.ai_ref.ref + "] destroyed for being out of bounds (" + ent.origin + ")" );
#/
		ent dodamage( int( ent.maxhealth + 100 ), ent.origin, undefined, undefined, "explosive" );
	}
	else
	{
		if ( !isDefined( ent.classname ) || ent.classname == "script_model" )
		{
			ent.origin = val.origin;
		}
		else
		{
			ent forceteleport( val.origin, ent.angles );
		}
	}
	return 0;
}

clamporigintomapboundary( origin )
{
	ret = spawnstruct();
	ret.inbounds = 1;
	ret.origin = origin;
	if ( isDefined( level.rts.bounds ) )
	{
		x = origin[ 0 ];
		y = origin[ 1 ];
		z = origin[ 2 ];
		if ( x <= level.rts.bounds.ulx )
		{
			ret.inbounds = 0;
			x = level.rts.bounds.ulx;
		}
		else
		{
			if ( x >= level.rts.bounds.lrx )
			{
				ret.inbounds = 0;
				x = level.rts.bounds.lrx;
			}
		}
		if ( y <= level.rts.bounds.uly )
		{
			ret.inbounds = 0;
			y = level.rts.bounds.uly;
		}
		else
		{
			if ( y >= level.rts.bounds.lry )
			{
				ret.inbounds = 0;
				y = level.rts.bounds.lry;
			}
		}
		if ( z <= level.rts.bounds.minz )
		{
			ret.inbounds = 0;
			z = level.rts.bounds.minz;
		}
		if ( z >= level.rts.bounds.maxz )
		{
			ret.inbounds = 0;
			z = level.rts.bounds.maxz;
		}
		ret.origin = ( x, y, z );
	}
	return ret;
}

boundary_watcher( damage, interval, warnmsg, endnote )
{
	if ( !isDefined( interval ) )
	{
		interval = 0,05;
	}
	self notify( "boundary_watcher" );
	self endon( "death" );
	self endon( "boundary_watcher" );
	if ( isDefined( endnote ) )
	{
		self endon( endnote );
		level endon( endnote );
	}
	wait 1;
	while ( 1 )
	{
		clampenttomapboundary( self, damage, warnmsg );
		wait interval;
	}
}

flag_set_innseconds( flag, time )
{
	wait time;
	flag_set( flag );
}

flag_clear_innseconds( flag, time )
{
	wait time;
	flag_clear( flag );
}

custom_introscreen( level_prefix, number_of_lines, totaltime, text_color )
{
	flag_wait( "all_players_connected" );
	wait 1;
	luinotifyevent( &"hud_add_title_line", 4, level_prefix, number_of_lines, totaltime, text_color );
	waittill_textures_loaded();
	wait 7;
	flag_set( "introscreen_complete" );
}

trigger_hint( trigger, banner )
{
	trigger setcursorhint( "HINT_NOICON" );
	while ( isDefined( trigger ) )
	{
		trigger sethintstring( "" );
		trigger waittill( "trigger", who );
		while ( !isplayer( who ) )
		{
			wait 0,05;
		}
		trigger sethintstring( banner );
		while ( isDefined( trigger ) && who istouching( trigger ) )
		{
			wait 0,05;
		}
	}
}

trigger_use( trigger, banner, usednote, altbutton, team )
{
	trigger setcursorhint( "HINT_NOICON" );
	while ( isDefined( trigger ) )
	{
		wait 0,05;
		if ( !isDefined( trigger ) )
		{
			return;
		}
		trigger sethintstring( "" );
		trigger waittill( "trigger", who );
		while ( !isplayer( who ) )
		{
			continue;
		}
		while ( flag( "block_input" ) )
		{
			continue;
		}
		while ( isDefined( level.rts.switch_trans ) )
		{
			continue;
		}
		if ( isDefined( team ) && who.team != team )
		{
			continue;
		}
		btndown = undefined;
		for ( ;; )
		{
			while ( isDefined( trigger ) && who istouching( trigger ) )
			{
				while ( flag( "block_input" ) )
				{
					wait 0,05;
				}
				while ( isDefined( trigger.disabled ) && trigger.disabled )
				{
					wait 0,05;
				}
				if ( isDefined( trigger.disable_use ) && trigger.disable_use )
				{
					trigger sethintstring( "" );
					wait 0,05;
				}
			}
			else trigger sethintstring( banner );
			time = getTime();
			if ( isDefined( altbutton ) && altbutton )
			{
				if ( who jumpbuttonpressed() && !who.throwinggrenade && !who meleebuttonpressed() && !isDefined( btndown ) )
				{
					btndown = time;
				}
				if ( !who jumpbuttonpressed() )
				{
					btndown = undefined;
				}
				if ( isDefined( btndown ) && ( time - btndown ) >= 300 )
				{
					self notify( usednote );
					break;
				}
				else
				{
				}
				else if ( who usebuttonpressed() && !who.throwinggrenade && !who meleebuttonpressed() && !isDefined( btndown ) )
				{
					btndown = time;
				}
				if ( !who usebuttonpressed() )
				{
					btndown = undefined;
				}
				if ( isDefined( btndown ) && ( time - btndown ) >= 300 )
				{
					self notify( usednote );
					break;
				}
				else
				{
					wait 0,05;
				}
			}
		}
	}
}

delay_kill( delay )
{
	self endon( "death" );
	wait delay;
	self kill();
}

killzonewatch()
{
	self endon( "death" );
	teams = [];
	if ( isarray( self.teams ) )
	{
		teams = self.teams;
	}
	else
	{
		teams[ 0 ] = self.teams;
	}
	while ( 1 )
	{
		self waittill( "trigger", who );
		valid = 0;
		_a3216 = teams;
		_k3216 = getFirstArrayKey( _a3216 );
		while ( isDefined( _k3216 ) )
		{
			team = _a3216[ _k3216 ];
			if ( who.team == team )
			{
				valid = 1;
				break;
			}
			else
			{
				_k3216 = getNextArrayKey( _a3216, _k3216 );
			}
		}
		if ( valid )
		{
			who kill();
		}
	}
}

createkillzone( origin, width, height, teams )
{
	killzone = spawn( "trigger_radius", origin, 7, width, height );
	killzone.teams = teams;
	killzone thread killzonewatch();
	return killzone;
}

turret_linktrigger( trigger )
{
	while ( isDefined( trigger ) )
	{
		trigger.origin = self.origin;
		wait 0,05;
	}
}

turret_deathwatcher()
{
	self notify( "turret_deathWatcher" );
	self endon( "turret_deathWatcher" );
	trigger = self.pickup_trigger;
	fakeveh = self.fakevehicle;
	self waittill( "death" );
	if ( isDefined( level.rts.player.viewlockedentity ) && self == level.rts.player.viewlockedentity )
	{
		self useby( level.rts.player );
	}
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
	if ( isDefined( fakeveh ) )
	{
		fakeveh delete();
	}
}

turret_usewatcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self makevehicleusable();
		if ( isDefined( self.pickup_trigger ) )
		{
			self.pickup_trigger triggeron();
		}
		self waittill( "enter_vehicle" );
		if ( isDefined( self.pickup_trigger ) )
		{
			self.pickup_trigger triggeroff();
		}
		self waittill( "exit_vehicle" );
	}
}

turret_pickupwatcher( trigger, usednote )
{
	activated = 0;
	while ( isDefined( trigger ) && !activated )
	{
		level.rts.player allowjump( 1 );
		while ( flag( "block_input" ) )
		{
			wait 0,05;
		}
		trigger waittill( "trigger", who );
		while ( !isplayer( who ) )
		{
			continue;
		}
		level.rts.player allowjump( 0 );
		btndown = undefined;
		while ( isDefined( trigger ) && who istouching( trigger ) )
		{
			time = getTime();
			if ( who jumpbuttonpressed() && !who.throwinggrenade && !who meleebuttonpressed() && !isDefined( btndown ) )
			{
				btndown = time;
			}
			if ( !who jumpbuttonpressed() )
			{
				btndown = undefined;
			}
			if ( isDefined( btndown ) && ( time - btndown ) >= 300 )
			{
				level notify( usednote );
				activated = 1;
			}
			else
			{
				wait 0,05;
			}
		}
	}
	level.rts.player allowjump( 1 );
}

turret_createmovewatcher()
{
	self endon( "death" );
	self notify( "turret_placed" );
	wait 0,05;
	if ( isDefined( self.pickup_trigger ) )
	{
		self.pickup_trigger delete();
	}
	if ( isDefined( self.bad_turret_spot ) )
	{
		self.bad_turret_spot delete();
	}
	target_vec = self.origin + ( anglesToForward( ( 0, self.angles[ 1 ], 0 ) ) * 1000 );
	self settargetorigin( target_vec );
	self thread maps/_cic_turret::cic_turret_on();
	self.no_pickup = getTime() + 2000;
	while ( getTime() < self.no_pickup )
	{
		wait 0,25;
	}
	self.takedamage = 1;
	self makeusable( self.team );
	self.pickup_trigger = spawn( "trigger_radius", self.origin, 0, 80, 64 );
	self.bad_turret_spot = spawn( "trigger_radius", self.origin, 0, 128, 64 );
	self.bad_turret_spot.targetname = "bad_turret_spot";
	self thread turret_deathwatcher();
	level thread turret_pickupwatcher( self.pickup_trigger, "turret_pickup_" + self getentitynumber() );
	while ( 1 )
	{
		level waittill( "turret_pickup_" + self getentitynumber() );
		if ( isDefined( level.rts.player.usingvehicle ) && !level.rts.player.usingvehicle && !isDefined( level.rts.player.carrying_turret ) )
		{
			break;
		}
		else
		{
		}
	}
	self notify( "scripted" );
	self lights_off();
	self laseroff();
	target_vec = self.origin + ( anglesToForward( ( 0, self.angles[ 1 ], 0 ) ) * 1000 );
	self settargetorigin( target_vec );
	self.off = 1;
	self makeunusable();
	self.takedamage = 0;
	self.pickup_trigger delete();
	self.pickup_trigger = spawn( "trigger_radius", self.origin, 0, 60, 64 );
	self thread turret_linktrigger( self.pickup_trigger );
	self setmodel( self.modelgoodplacement );
	level.rts.player thread updateturretplacement( self );
	wait 0,5;
	if ( isDefined( self.pickup_trigger ) )
	{
		level thread trigger_use( self.pickup_trigger, &"SO_RTS_PLACE", "turret_place_" + self getentitynumber(), self.use_alt_btn_to_move );
		self connectpaths();
	}
}

dropturretonnotify( note, turret )
{
	turret endon( "death" );
	turret endon( "turret_placed" );
	self notify( "dropTurretOnNotify" + note );
	self endon( "dropTurretOnNotify" + note );
	self waittill( note );
	level notify( "dropTurret" );
	wait 0,05;
	turret.origin = turret.lastgoodspot;
	turret.angles = turret.lastgoodang;
	turret setmodel( turret.model_base );
	turret makeusable( turret.team );
	if ( isDefined( turret.pickup_trigger ) )
	{
		turret.pickup_trigger delete();
	}
	turret.takedamage = 1;
	if ( isDefined( self.viewlockedentity ) && self.viewlockedentity != turret )
	{
		turret maps/_cic_turret::cic_turret_on();
	}
	self.carrying_turret = undefined;
	self allowjump( 1 );
	turret disconnectpaths();
	turret thread turret_createmovewatcher();
}

turret_placementwatcher( turret )
{
	turret endon( "death" );
	turret endon( "turret_placed" );
	while ( 1 )
	{
		level waittill( "turret_place_" + turret getentitynumber() );
		if ( isDefined( turret.pickup_trigger ) )
		{
			turret.pickup_trigger delete();
		}
		turret.origin = turret.lastgoodspot;
		turret.angles = turret.lastgoodang;
		turret setmodel( turret.model_base );
		self playrumbleonentity( "damage_heavy" );
		self.carrying_turret = undefined;
		self allowjump( 1 );
		level.rts.player showviewmodel();
		turret disconnectpaths();
		turret thread turret_createmovewatcher();
		return;
	}
}

turret_weapongivebackwatch( turret )
{
	self endon( "death" );
	level.rts.player thread take_weapons();
	turret waittill( "turret_placed" );
	level.rts.player thread give_weapons();
}

updateturretplacement( turret )
{
	self endon( "deathshield" );
	self endon( "death" );
	self notify( "updateTurretPlacement" );
	self endon( "updateTurretPlacement" );
	level endon( "dropTurret" );
	turret endon( "turret_placed" );
	lastplacedturret = -1;
	turret.canbeplaced = 0;
	self.carrying_turret = turret;
	level.rts.player allowjump( 0 );
	self thread dropturretonnotify( "deathshield", turret );
	self thread dropturretonnotify( "switch_fullstatic", turret );
	self thread dropturretonnotify( "rts_go", turret );
	self thread turret_placementwatcher( turret );
	self thread turret_weapongivebackwatch( turret );
	badspots = getentarray( "bad_turret_spot", "targetname" );
	while ( 1 )
	{
		turret.canbeplaced = 1;
		while ( badspots.size )
		{
			_a3469 = badspots;
			_k3469 = getFirstArrayKey( _a3469 );
			while ( isDefined( _k3469 ) )
			{
				spot = _a3469[ _k3469 ];
				if ( turret istouching( spot ) )
				{
					turret.canbeplaced = 0;
					break;
				}
				else
				{
					_k3469 = getNextArrayKey( _a3469, _k3469 );
				}
			}
		}
		placement = self canplayerplaceturret();
		turret.origin = placement[ "origin" ];
		turret.angles = placement[ "angles" ];
		if ( turret.canbeplaced == 1 )
		{
			turret.canbeplaced = placement[ "result" ];
		}
		if ( turret.canbeplaced != lastplacedturret )
		{
			if ( turret.canbeplaced )
			{
				turret setmodel( turret.modelgoodplacement );
				turret.pickup_trigger.disable_use = undefined;
			}
			else
			{
				turret setmodel( turret.modelbadplacement );
				turret.pickup_trigger.disable_use = 1;
			}
			lastplacedturret = turret.canbeplaced;
		}
		if ( turret.canbeplaced )
		{
			turret.lastgoodspot = placement[ "origin" ];
			turret.lastgoodang = placement[ "angles" ];
		}
		wait 0,05;
	}
}

turret_deathwatch( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
	if ( isDefined( level.rts.turretdamagecb ) )
	{
		idamage = [[ level.rts.turretdamagecb ]]( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name );
	}
	if ( self.health < idamage )
	{
		self setclientflag( 7 );
		if ( self.team == "allies" )
		{
			self disconnectpaths();
		}
	}
	if ( isDefined( self.classvehicledamage ) )
	{
		return [[ self.classvehicledamage ]]( einflictor, eattacker, idamage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name );
	}
	else
	{
		return idamage;
	}
}

level_create_turrets( usable, hitpoints )
{
	if ( !isDefined( usable ) )
	{
		usable = 0;
	}
	if ( !isDefined( hitpoints ) )
	{
		hitpoints = 2000;
	}
	wait 0,05;
	turretorigins = getentarray( "turret_loc_enemy", "targetname" );
	_a3544 = turretorigins;
	_k3544 = getFirstArrayKey( _a3544 );
	while ( isDefined( _k3544 ) )
	{
		tur = _a3544[ _k3544 ];
		turret = maps/_vehicle::spawn_vehicle_from_targetname( "sentry_turret_axis" );
		turret addvehicletocompass( "artillery" );
		turret.team = "axis";
		turret.origin = tur.origin;
		turret.angles = tur.angles;
		turret.lastgoodspot = turret.origin;
		turret.lastgoodang = turret.angles;
		turret.health = hitpoints;
		turret maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 0 );
		turret.fakevehicle = maps/_vehicle::spawn_vehicle_from_targetname( "fake_vehicle" );
		origin = turret gettagorigin( "tag_player" );
		if ( !isDefined( origin ) )
		{
			turret.fakevehicle linkto( turret, "tag_origin", vectorScale( ( 0, 0, 1 ), 40 ), ( 0, 0, 1 ) );
		}
		else
		{
			turret.fakevehicle linkto( turret, "tag_player" );
		}
		turret.fakevehicle.team = "axis";
		turret.fakevehicle.vteam = "axis";
		turret.fakevehicle.origin = origin;
		turret disconnectpaths();
		if ( isDefined( turret.overridevehicledamage ) )
		{
			turret.classvehicledamage = turret.overridevehicledamage;
		}
		turret.overridevehicledamage = ::turret_deathwatch;
		turret.trigger = spawn( "trigger_radius", turret.origin, 0, 80, 64 );
		turret thread trigger_hint( turret.trigger, &"SO_RTS_CANNOT_HACK" );
		level notify( "turret_created" );
		turret.bad_turret_spot = spawn( "trigger_radius", turret.origin, 0, 128, 64 );
		turret.bad_turret_spot.targetname = "bad_turret_spot";
		tur delete();
		_k3544 = getNextArrayKey( _a3544, _k3544 );
	}
	turretorigins = getentarray( "turret_loc_friendly", "targetname" );
	_a3592 = turretorigins;
	_k3592 = getFirstArrayKey( _a3592 );
	while ( isDefined( _k3592 ) )
	{
		tur = _a3592[ _k3592 ];
		turret = maps/_vehicle::spawn_vehicle_from_targetname( "sentry_turret_friendly" );
		turret addvehicletocompass( "artillery" );
		turret.team = "allies";
		turret.origin = tur.origin;
		turret.angles = tur.angles;
		turret.lastgoodspot = turret.origin;
		turret.lastgoodang = turret.angles;
		turret.health = hitpoints;
		turret.modelgoodplacement = "t6_wpn_turret_sentry_gun_monsoon_yellow";
		turret.modelbadplacement = "t6_wpn_turret_sentry_gun_monsoon_red";
		turret.model_base = "t6_wpn_turret_sentry_gun_monsoon";
		turret.fakevehicle = maps/_vehicle::spawn_vehicle_from_targetname( "fake_vehicle" );
		origin = turret gettagorigin( "tag_player" );
		if ( !isDefined( origin ) )
		{
			turret.fakevehicle linkto( turret, "tag_origin", vectorScale( ( 0, 0, 1 ), 40 ), ( 0, 0, 1 ) );
		}
		else
		{
			turret.fakevehicle linkto( turret, "tag_player" );
		}
		turret.fakevehicle.team = "allies";
		turret.fakevehicle.vteam = "allies";
		turret.fakevehicle.origin = origin;
		turret maps/_so_rts_support::set_gpr( maps/_so_rts_support::make_gpr_opcode( 1 ) + 1 );
		if ( isDefined( usable ) && usable )
		{
			turret makeusable( "allies" );
			turret.use_alt_btn_to_move = 1;
			turret thread turret_createmovewatcher();
			turret thread turret_usewatcher();
		}
		else
		{
			turret makeunusable();
		}
		turret disconnectpaths();
		if ( isDefined( turret.overridevehicledamage ) )
		{
			turret.classvehicledamage = turret.overridevehicledamage;
		}
		turret.overridevehicledamage = ::turret_deathwatch;
		level notify( "turret_created" );
		tur delete();
		_k3592 = getNextArrayKey( _a3592, _k3592 );
	}
}

badplace_untilnotify( spot, note, radius, team, height )
{
	if ( !isDefined( team ) )
	{
		team = "all";
	}
	if ( !isDefined( height ) )
	{
		height = 100;
	}
	badplace_name = "bpn_" + note;
	badplace_cylinder( badplace_name, -1, spot, radius, height, team );
/#
	thread maps/_so_rts_support::drawcylinder( spot, radius, height, 10 );
#/
	level waittill( note );
	badplace_delete( badplace_name );
}

claymore_create( origin, angles, team )
{
	claymore = spawn_model( "weapon_claymore", origin, angles );
	if ( isDefined( claymore ) )
	{
/#
		println( "$$$ claymore created at " + origin + " for team: " + team );
		thread maps/_so_rts_support::debug_sphere( origin, 8, ( 0, 0, 1 ), 0,6, 300 );
#/
		claymore.angles = angles;
		claymore setmodel( "weapon_claymore" );
		playfxontag( getfx( "claymore_laser" ), claymore, "tag_fx" );
		claymore.team = team;
		claymore thread claymore_damagewatch();
		claymore thread claymore_detonationwatch();
		fakevehicle = maps/_vehicle::spawn_vehicle_from_targetname( "fake_vehicle" );
		fakevehicle.team = team;
		fakevehicle.vteam = team;
		fakevehicle.origin = origin;
		claymore.fakevehicle = fakevehicle;
		level thread badplace_untilnotify( claymore.origin, "badplace_entNum" + claymore getentitynumber(), 96, team );
		return claymore;
	}
	return undefined;
}

claymore_damagewatch()
{
	self endon( "death" );
	self setcandamage( 1 );
	self.health = 10000;
	self.maxhealth = self.health;
	self waittill( "damage" );
	wait 0,05;
	self thread claymore_detonate();
}

claymore_detonationwatch()
{
	self endon( "death" );
	damagearea = spawn( "trigger_radius", self.origin, 3, 192, 72 );
	while ( 1 )
	{
		damagearea waittill( "trigger", ent );
/#
		thread debug_circle( self.origin + vectorScale( ( 0, 0, 1 ), 36 ), 192, ( 0, 0, 1 ), 10 );
#/
		if ( ent.team != self.team )
		{
/#
			thread maps/_so_rts_support::debug_sphere( self.origin, 8, ( 0, 0, 1 ), 0,6, 10 );
#/
			if ( ent damageconetrace( self.origin + vectorScale( ( 0, 0, 1 ), 18 ), self ) > 0 )
			{
				wait 0,4;
				self thread claymore_detonate();
				return;
			}
		}
	}
}

claymore_detonate()
{
	if ( isDefined( self.fakevehicle ) )
	{
		self.fakevehicle delete();
	}
	level notify( "badplace_entNum" + self getentitynumber() );
	playfx( getfx( "claymore_explode" ), self gettagorigin( "tag_fx" ) );
	radiusdamage( self gettagorigin( "tag_fx" ), 192, 500, 250 );
	self delete();
}

perfect_aim_off( ent )
{
	self endon( "death" );
	self endon( "perfect_aim_on" );
	self waittill( "perfect_aim_off" );
	self.perfectaim = 0;
}

perfect_aim_fortimeoruntilnotify( note, time, timeout )
{
	if ( !isDefined( timeout ) )
	{
		timeout = 5;
	}
	self endon( "death" );
	self notify( "perfect_aim_on" );
	self endon( "perfect_aim_on" );
	self thread perfect_aim_off();
	self.perfectaim = 1;
	if ( isDefined( time ) )
	{
		wait time;
	}
	if ( isDefined( note ) )
	{
		waittill_any_timeout( timeout, note, "perfect_aim_off" );
	}
	self notify( "perfect_aim_off" );
}

get_closest_doublewidenode( origin, radius, height )
{
	nodes = getnodesinradiussorted( origin, radius, 0, height, "Path" );
	while ( nodes.size > 0 )
	{
		i = 0;
		while ( i < nodes.size )
		{
			if ( nodes[ i ].type == "BAD NODE" || !nodes[ i ] has_spawnflag( 1048576 ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( !findpath( self.origin, nodes[ i ].origin, self, 0 ) )
				{
					i++;
					continue;
				}
				else
				{
					return nodes[ i ];
				}
			}
			i++;
		}
	}
	return undefined;
}

get_closest_pathnode( origin, radius, height )
{
	nodes = getnodesinradiussorted( origin, radius, 0, height, "Path" );
	while ( nodes.size > 0 )
	{
		i = 0;
		while ( i < nodes.size )
		{
			if ( nodes[ i ].type == "BAD NODE" )
			{
				i++;
				continue;
			}
			else
			{
				return nodes[ i ];
			}
			i++;
		}
	}
	return undefined;
}

get_closest_covernode( origin, radius, height )
{
	nodes = getnodesinradiussorted( origin, radius, 0, height, "Cover" );
	while ( nodes.size > 0 )
	{
		i = 0;
		while ( i < nodes.size )
		{
			if ( nodes[ i ].type == "BAD NODE" )
			{
				i++;
				continue;
			}
			else
			{
				return nodes[ i ];
			}
			i++;
		}
	}
	return undefined;
}

get_player_rts_mode()
{
	if ( isDefined( self.ally ) )
	{
		if ( self.ally.ai_ref.species == "vehicle" || self.ally.ai_ref.species == "robot_actor" )
		{
			return self.ally.ai_ref.ref;
		}
		else
		{
			return self.ally.ai_ref.species;
		}
	}
	else
	{
		return "overwatch";
	}
}

track_unitfirewatch()
{
	level endon( "tact_expire" );
	level.rts.player waittill( "weapon_fired" );
	level.m_unit_usage[ "human" ] = 999;
}

track_unit_type_usage()
{
	level endon( "mission_complete" );
	level.m_unit_usage = [];
	level.m_unit_usage[ "overwatch" ] = 0;
	flag_wait( "rts_start_clock" );
	level thread track_unitfirewatch();
	wait 5;
	level notify( "tact_expire" );
	while ( 1 )
	{
		if ( flag( "fps_mode" ) )
		{
			level.m_unit_usage[ "human" ] = 999;
			return;
		}
		wait 0,5;
		play_type = self get_player_rts_mode();
		if ( !isDefined( level.m_unit_usage[ play_type ] ) )
		{
			level.m_unit_usage[ play_type ] = 0;
		}
		level.m_unit_usage[ play_type ] += 0,5;
	}
}

challenge_tactical( str_notify )
{
	level waittill( "mission_complete", success );
	if ( !success )
	{
		return;
	}
	keys = getarraykeys( level.m_unit_usage );
	_a3897 = keys;
	_k3897 = getFirstArrayKey( _a3897 );
	while ( isDefined( _k3897 ) )
	{
		key = _a3897[ _k3897 ];
		if ( key != "overwatch" && level.m_unit_usage[ key ] > 0 )
		{
			return;
		}
		_k3897 = getNextArrayKey( _a3897, _k3897 );
	}
	self notify( str_notify );
}
