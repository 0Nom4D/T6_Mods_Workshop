#include maps/_vehicle;
#include maps/haiti_util;
#include maps/_objectives;
#include maps/_utility;
#include common_scripts/utility;

jetwing_init( drop_speed )
{
	self.rolling = 0;
	self.current_roll = 0;
	self.current_offset = 0;
	self.roll_time = 0;
	self.roll_dir = 0;
	self.smoke_damage = 0;
	self setspeed( drop_speed, 100, 100 );
	if ( !isDefined( level.player_burned ) )
	{
		level.player_burned = 0;
	}
	self.overridevehicledamage = ::jetwing_damage_override;
	self thread jetwing_damage_watcher();
}

jetwing_strafe_controls()
{
	self endon( "death" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	self.jetwing_offset = ( 1, 1, 1 );
	strafe_vel = ( 1, 1, 1 );
	max_strafe_vel = ( 0, 352, 352 );
	while ( 1 )
	{
		if ( !self.rolling )
		{
			stick = level.player getnormalizedmovement();
			if ( getlocalprofileint( "input_invertPitch" ) == 1 )
			{
				stick = ( stick[ 0 ] * -1, stick[ 1 ], stick[ 2 ] );
			}
			if ( abs( self.jetwing_offset[ 1 ] ) >= 2500 && ( self.jetwing_offset[ 1 ] * stick[ 1 ] ) >= 0 )
			{
			}
			else
			{
			}
			desired_vel_y = stick[ 1 ] * max_strafe_vel[ 1 ];
			if ( abs( self.jetwing_offset[ 2 ] ) >= 1500 && ( self.jetwing_offset[ 2 ] * stick[ 0 ] ) >= 0 )
			{
			}
			else
			{
			}
			desired_vel_z = stick[ 0 ] * max_strafe_vel[ 2 ];
			strafe_vel_y = difftrack( desired_vel_y, strafe_vel[ 1 ], 2, 0,05 );
			strafe_vel_z = difftrack( desired_vel_z, strafe_vel[ 2 ], 2, 0,05 );
			strafe_vel = ( 0, strafe_vel_y, strafe_vel_z );
			self.jetwing_offset += strafe_vel * 0,05;
			self pathfixedoffset( self.jetwing_offset );
		}
		else
		{
			self.jetwing_offset = self getpathfixedoffset();
		}
		wait 0,05;
	}
}

jetwing_fx( start_origin )
{
	self endon( "death" );
	self endon( "reached_end_node" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	while ( 1 )
	{
		fwd = anglesToForward( level.jetwing.angles );
		playfx( level._effect[ "jetwing_whoosh" ], level.player.origin + ( fwd * 100 ), fwd );
		wait 0,15;
	}
}

jetwing_barrel_roll()
{
	self endon( "death" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	while ( 1 )
	{
		if ( !self.rolling )
		{
			roll_right = level.player fragbuttonpressed();
			roll_left = level.player secondaryoffhandbuttonpressed();
			if ( roll_left || roll_right )
			{
				offset = self getpathfixedoffset();
				self.rolling = 1;
				self.current_roll = self.angles[ 2 ];
				self.roll_time = 0;
				self.current_offset = offset[ 1 ];
				if ( roll_left )
				{
				}
				else
				{
				}
				self.roll_dir = 1;
			}
		}
		else
		{
			self.current_roll += ( self.roll_dir * 720 ) * 0,05;
			self.current_roll = angleClamp180( self.current_roll );
			self.roll_time += 0,05;
			if ( self.roll_time > 0,5 )
			{
				self.rolling = 0;
			}
			offset = self getpathfixedoffset();
			self.current_offset += 4000 * self.roll_dir * 0,05;
			offset = ( offset[ 0 ], self.current_offset, offset[ 2 ] );
			self pathfixedoffset( offset );
		}
		wait 0,05;
	}
}

jetwing_rumble()
{
	self endon( "death" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	while ( 1 )
	{
		vr = abs( self getspeed() / self getmaxspeed() );
		if ( vr < 0,1 )
		{
			wait 0,3;
			continue;
		}
		else if ( vr > 0,01 || vr < 0,8 && abs( self getsteering() ) > 0,5 )
		{
			earthquake( 0,15, 0,1, self.origin, 200 );
			level.player playrumbleonentity( "pullout_small" );
			wait 0,2;
			continue;
		}
		else
		{
			if ( vr >= 0,8 )
			{
				time = randomfloatrange( 0,2, 0,25 );
				earthquake( 0,2, time, self.origin, 200 );
				level.player playrumbleonentity( "pullout_small" );
				wait time;
				break;
			}
			else
			{
				wait 0,1;
			}
		}
	}
}

jetwing_landing_rumble()
{
	self endon( "death" );
	self endon( "end_jetwing_rumble" );
	rumble_time = 16;
	while ( rumble_time > 0 )
	{
		time = randomfloatrange( 0,1, 0,15 );
		earthquake( 0,2, time, self.origin, 200 );
		self playrumbleonentity( "pullout_small" );
		wait time;
		rumble_time -= time;
	}
}

jetwing_collision()
{
	self endon( "death" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	level waittill( "jetpack_go" );
	while ( 1 )
	{
		forward = anglesToForward( level.jetwing.angles );
		start = level.jetwing.origin + ( forward * 100 );
		end = start + ( forward * 1000 );
		trace = bullettrace( start, end, 0, level.jetwing );
		if ( isDefined( trace[ "entity" ] ) && trace[ "entity" ].classname != "script_vehicle" )
		{
			if ( trace[ "fraction" ] < 0,08 )
			{
				level.player playrumbleonentity( "damage_heavy" );
				screen_fade_out( 0 );
				missionfailed();
				level.player dodamage( self.health + 1, self.origin );
				self dodamage( self.health + 1, self.origin );
			}
		}
		wait 0,05;
	}
}

jetwing_instructions()
{
	screen_message_create( &"HAITI_JETWING_MOVE", &"HAITI_JETWING_LOOK" );
	wait 4;
	screen_message_delete();
}

jetwing_damage_watcher()
{
	self endon( "death" );
	self endon( "approach_facility" );
	self endon( "exit_vehicle" );
	while ( 1 )
	{
		if ( self.smoke_damage )
		{
			time = getTime() - level.last_damage_time;
			if ( time > 1000 )
			{
				self.smoke_damage = 0;
				rpc( "clientscripts/haiti", "oxygen_mask_smoke_clear" );
			}
		}
		wait 0,05;
	}
}

jetwing_deathwatcher()
{
	self endon( "approach_facility" );
	level.player waittill( "death" );
	luinotifyevent( &"hud_hide_shadesHud" );
}

jetwing_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( smeansofdeath == "MOD_BURNED" )
	{
		level.player_burned = 1;
		if ( !isDefined( level.last_damage_time ) )
		{
			level.last_damage_time = getTime();
			self.smoke_damage = 1;
			rpc( "clientscripts/haiti", "oxygen_mask_smoke" );
		}
		else
		{
			time = getTime() - level.last_damage_time;
			level.last_damage_time = getTime();
			if ( time > 1000 )
			{
				self.smoke_damage = 1;
				rpc( "clientscripts/haiti", "oxygen_mask_smoke" );
			}
		}
	}
	return idamage;
}

ai_jetwing_think( speed, delay )
{
	self endon( "death" );
	self.overridevehicledamage = ::ai_jetwing_damage_override;
	path = getvehiclenode( self.target, "targetname" );
	offset = level.jetwing_ai_offsets[ self.script_int ];
	if ( flag( "jetwing_speedup" ) )
	{
	}
	else
	{
	}
	speed = speed;
	self setspeed( speed, 100, 100 );
	self pathfixedoffset( offset );
	self pathvariableoffset( ( 75, 75, 50 ), randomfloatrange( 1, 2 ) );
	self setdefaultpitch( randomfloatrange( -15, -3 ) );
	self thread go_path( path );
	self thread ai_jetwing_follow();
	self thread ai_jetwing_avoid_fire();
	if ( isDefined( delay ) )
	{
		wait delay;
		if ( flag( "jetwing_speedup" ) )
		{
		}
		else
		{
		}
		speed = 80;
		self setspeed( speed, 100, 100 );
	}
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

ai_jetwing_follow()
{
	self endon( "death" );
	self.follow_strength = randomfloatrange( 0,4, 0,75 );
	while ( 1 )
	{
		if ( isDefined( level.jetwing ) && isDefined( level.jetwing.rolling ) && !level.jetwing.rolling )
		{
			current_offset = self getpathfixedoffset();
			new_offset_x = difftrack( level.jetwing_ai_offsets[ self.script_int ][ 0 ] + level.jetwing.jetwing_offset[ 0 ], current_offset[ 0 ], self.follow_strength, 0,05 );
			new_offset_y = difftrack( level.jetwing_ai_offsets[ self.script_int ][ 1 ] + level.jetwing.jetwing_offset[ 1 ], current_offset[ 1 ], self.follow_strength, 0,05 );
			new_offset_z = difftrack( level.jetwing_ai_offsets[ self.script_int ][ 2 ] + level.jetwing.jetwing_offset[ 2 ], current_offset[ 2 ], self.follow_strength, 0,05 );
			self pathfixedoffset( ( new_offset_x, new_offset_y, new_offset_z ) );
		}
		wait 0,05;
	}
}

ai_jetwing_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname )
{
	if ( smeansofdeath == "MOD_BURNED" )
	{
		idamage = 0;
	}
	return idamage;
}

ai_jetwing_death()
{
	self notify( "nodeath_thread" );
	self waittill( "death" );
	self maps/_vehicle::getoffpath();
	angles = self.angles;
	angles = ( angles[ 0 ], angles[ 1 ], 0 );
	fwd = anglesToForward( angles );
	right = anglesToRight( angles );
	up = anglesToUp( angles );
	r = randomintrange( 100, 300 ) * -1;
	launch_spot = level.jetwing.origin + ( fwd * 1500 );
	launch_velocity = launch_spot - self.origin;
	launch_velocity = vectornormalize( launch_velocity ) * 500;
	self setvehvelocity( launch_velocity );
	self setangularvelocity( ( 0, 0, randomintrange( -360, 360 ) ) );
}

ai_jetwing_avoid_fire()
{
	self endon( "death" );
	self.jetwing_ai_fire_offset = ( 1, 1, 1 );
	while ( 1 )
	{
		_a448 = level.missile_list;
		_k448 = getFirstArrayKey( _a448 );
		while ( isDefined( _k448 ) )
		{
			missile = _a448[ _k448 ];
			if ( isDefined( missile ) )
			{
				delta = missile.origin - self.origin;
				dist = length( delta );
				dir = vectornormalize( delta );
				angles = self.angles;
				angles = ( angles[ 0 ], angles[ 1 ], 0 );
				fwd = anglesToForward( angles );
				right = anglesToRight( angles );
				up = anglesToUp( angles );
				t = vectordot( delta, fwd );
				if ( t > 0 )
				{
					closest_point = self.origin + ( fwd * t );
					clipped_delta = closest_point - missile.origin;
					r = length( clipped_delta );
					if ( r < missile.radius )
					{
						dr = vectordot( clipped_delta, right );
						du = vectordot( clipped_delta, up );
						avoid_dir = ( 1, 1, 1 );
						scale = 1 - ( abs( dr ) / missile.radius );
						avoid_dir = ( avoid_dir[ 0 ], dr * scale * 0,05, avoid_dir[ 2 ] );
						self.jetwing_ai_fire_offset += avoid_dir;
					}
					else
					{
						x = lag( 0, self.jetwing_ai_fire_offset[ 0 ], 5, 0,05 );
						y = lag( 0, self.jetwing_ai_fire_offset[ 1 ], 5, 0,05 );
						z = lag( 0, self.jetwing_ai_fire_offset[ 2 ], 5, 0,05 );
						self.jetwing_ai_fire_offset = ( x, self.jetwing_ai_fire_offset[ 1 ], self.jetwing_ai_fire_offset[ 2 ] );
						self.jetwing_ai_fire_offset = ( self.jetwing_ai_fire_offset[ 0 ], y, self.jetwing_ai_fire_offset[ 2 ] );
						self.jetwing_ai_fire_offset = ( self.jetwing_ai_fire_offset[ 0 ], self.jetwing_ai_fire_offset[ 1 ], z );
					}
					current_offset = self getpathfixedoffset();
					self pathfixedoffset( current_offset + self.jetwing_ai_fire_offset );
				}
			}
			_k448 = getNextArrayKey( _a448, _k448 );
		}
		wait 0,05;
	}
}

ai_landing_jetwing_think( speed, delay )
{
	self endon( "death" );
	flag_wait( "jetwing_land_player_started" );
	self.overridevehicledamage = ::ai_jetwing_damage_override;
	path = getvehiclenode( self.target, "targetname" );
	offset = level.jetwing_ai_offsets[ self.script_int ];
	self pathfixedoffset( offset );
	self pathvariableoffset( ( 75, 75, 50 ), randomfloatrange( 1, 2 ) );
	self thread go_path( path );
	self waittill( "reached_end_node" );
	self.delete_on_death = 1;
	self notify( "death" );
	if ( !isalive( self ) )
	{
		self delete();
	}
}

ai_landing_jetwing_speed()
{
	self endon( "reached_end_node" );
	while ( 1 )
	{
		speed = length( level.player getvelocity() );
		self setspeed( speed, 100, 100 );
		wait 0,05;
	}
}

ai_landing_jetwing_think2()
{
	self endon( "death" );
	flag_wait( "jetwing_land_player_started" );
	current_roll = 0;
	roll_track = randomfloatrange( 1, 2 );
	v_offset = level.jetwing_ai_offsets[ self.script_int ];
	v_variable_offset = ( 75, 75, 50 );
	n_variable_offset_time = randomfloatrange( 1, 2 );
	variable_offset_time = 0;
	last_variable_offset = ( 1, 1, 1 );
	current_variable_offset = ( 1, 1, 1 );
	target_variable_offset = ( 1, 1, 1 );
	v_angles = level.player getplayerangles();
	v_fwd = anglesToForward( v_angles );
	v_right = anglesToRight( v_angles );
	v_up = anglesToUp( v_angles );
	v_desired_pos = level.player.origin + ( ( v_fwd * v_offset[ 0 ] ) + ( v_right * v_offset[ 1 ] ) ) + ( v_up * v_offset[ 2 ] );
	self.origin = v_desired_pos;
	wait 0,05;
	b_first = 1;
	player_body = getent( "player_body", "targetname" );
	while ( 1 )
	{
		v_angles = level.player getplayerangles();
		v_fwd = anglesToForward( v_angles );
		v_right = anglesToRight( v_angles );
		v_up = anglesToUp( v_angles );
		v_desired_pos = level.player.origin + ( ( v_fwd * v_offset[ 0 ] ) + ( v_right * v_offset[ 1 ] ) ) + ( v_up * v_offset[ 2 ] );
		t = variable_offset_time / n_variable_offset_time;
		smooth_frac = 0,5 * ( cos( ( 3,14159 * t ) - 3,14159 ) + 1 );
		current_variable_offset = lerpvector( last_variable_offset, target_variable_offset, t );
		variable_offset_time += 0,05;
		if ( variable_offset_time > n_variable_offset_time )
		{
			variable_offset_time = 0;
			last_variable_offset = target_variable_offset;
			target_variable_offset = ( randomfloatrange( v_variable_offset[ 0 ] * -1, v_variable_offset[ 0 ] ), randomfloatrange( v_variable_offset[ 1 ] * -1, v_variable_offset[ 1 ] ), randomfloatrange( v_variable_offset[ 2 ] * -1, v_variable_offset[ 2 ] ) );
		}
		v_desired_pos += ( ( v_fwd * current_variable_offset[ 0 ] ) + ( v_right * current_variable_offset[ 1 ] ) ) + ( v_up * current_variable_offset[ 2 ] );
		v_delta = v_desired_pos - self.origin;
		v_desired_vel = v_delta / 0,05;
		v_vel = self.velocity;
		v = vectornormalize( v_desired_vel );
		d = vectordot( v, ( 1, 1, 1 ) );
		if ( d != 0 && abs( d ) < 0,9 )
		{
			n_yaw = vectoangles( v_desired_vel );
		}
		else
		{
			n_yaw = v_angles[ 1 ];
		}
		n_yaw_vel = ( n_yaw - self.angles[ 1 ] ) / 0,05;
		n_roll = ( n_yaw_vel / 25 ) * 75;
		n_roll = clamp( n_roll, -75, 75 );
		current_roll = difftrackangle( n_roll * -1, current_roll, roll_track, 0,05 );
		self.origin = v_desired_pos;
		self setphysangles( ( 0, n_yaw, current_roll ) );
/#
		line( self.origin, v_desired_pos, ( 1, 1, 1 ), 1, 0, 1 );
		circle( v_desired_pos, 25, ( 1, 1, 1 ), 0, 1 );
#/
		wait 0,05;
	}
	speed = length( self.velocity );
	while ( speed > 0 )
	{
		v_vel = self.velocity * 0,95;
		self setvehvelocity( v_vel );
		wait 0,05;
	}
}

jetwings_spread( delay )
{
	wait delay;
	jetwing_ai = getentarray( "ai_jetwing", "targetname" );
	jetwing_ai_chinese = getentarray( "ai_jetwing_chinese", "targetname" );
	jetwing_ai_usa = getentarray( "ai_jetwing_usa", "targetname" );
	jetwings = arraycombine( jetwing_ai, jetwing_ai_chinese, 0, 0 );
	jetwings = arraycombine( jetwings, jetwing_ai_usa, 0, 0 );
	_a679 = jetwings;
	_k679 = getFirstArrayKey( _a679 );
	while ( isDefined( _k679 ) )
	{
		jetwing = _a679[ _k679 ];
		jetwing pathvariableoffset( vectorScale( ( 1, 1, 1 ), 500 ), randomfloatrange( 1,5, 2,5 ) );
		_k679 = getNextArrayKey( _a679, _k679 );
	}
}

jetwings_regroup( delay )
{
	wait delay;
	jetwing_ai = getentarray( "ai_jetwing", "targetname" );
	jetwing_ai_chinese = getentarray( "ai_jetwing_chinese", "targetname" );
	jetwing_ai_usa = getentarray( "ai_jetwing_usa", "targetname" );
	jetwings = arraycombine( jetwing_ai, jetwing_ai_chinese, 0, 0 );
	jetwings = arraycombine( jetwings, jetwing_ai_usa, 0, 0 );
	_a698 = jetwings;
	_k698 = getFirstArrayKey( _a698 );
	while ( isDefined( _k698 ) )
	{
		jetwing = _a698[ _k698 ];
		jetwing pathvariableoffset( ( 75, 75, 50 ), randomfloatrange( 1, 2 ) );
		_k698 = getNextArrayKey( _a698, _k698 );
	}
}
