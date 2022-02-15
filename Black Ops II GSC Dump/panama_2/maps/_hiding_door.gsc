#include common_scripts/utility;
#include maps/_utility;
#include maps/_anim;

#using_animtree( "hiding_door" );
#using_animtree( "generic_human" );

door_main()
{
	setup_door_anims();
	main_door_guy();
	thread door_notetracks();
	level.hiding_door_spawner = ::hiding_door_spawner;
}

window_main()
{
	setup_window_anims();
	main_window_guy();
	thread window_notetracks();
	level.hiding_door_spawner = ::hiding_door_spawner;
}

setup_door_anims()
{
	level.scr_animtree[ "hiding_door" ] = #animtree;
	level.scr_model[ "hiding_door" ] = "anim_jun_com_door_wood_handleft";
	level.scr_anim[ "hiding_door" ][ "close" ] = %doorpeek_close_door;
	level.scr_anim[ "hiding_door" ][ "death_1" ] = %doorpeek_deatha_door;
	level.scr_anim[ "hiding_door" ][ "death_2" ] = %doorpeek_deathb_door;
	level.scr_anim[ "hiding_door" ][ "fire_3" ] = %doorpeek_firec_door;
	level.scr_anim[ "hiding_door" ][ "grenade" ] = %doorpeek_grenade_door;
	level.scr_anim[ "hiding_door" ][ "idle" ][ 0 ] = %doorpeek_idle_door;
	level.scr_anim[ "hiding_door" ][ "jump" ] = %doorpeek_jump_door;
	level.scr_anim[ "hiding_door" ][ "kick" ] = %doorpeek_kick_door;
	level.scr_anim[ "hiding_door" ][ "open" ] = %doorpeek_open_door;
	level.scr_anim[ "hiding_door" ][ "leave" ] = %doorpeek_jump_door;
	level.scr_anim[ "hiding_door" ][ "death_1_ends_closed" ] = %doorpeek_deatha_door_ends_closed;
	level.scr_anim[ "hiding_door" ][ "death_2_ends_closed" ] = %doorpeek_deathb_door_ends_closed;
	level.scr_anim[ "hiding_door" ][ "jump_ends_closed" ] = %doorpeek_jump_door_ends_closed;
	level.scr_anim[ "hiding_door" ][ "leave_ends_closed" ] = %doorpeek_jump_door_ends_closed;
	precachemodel( level.scr_model[ "hiding_door" ] );
	setup_model_overrides();
}

setup_window_anims()
{
	level.scr_animtree[ "hiding_window" ] = #animtree;
	level.scr_model[ "hiding_window" ] = "anim_jun_shutters";
	level.scr_anim[ "hiding_window" ][ "close" ] = %ai_shutterpeek_close_shutter;
	level.scr_anim[ "hiding_window" ][ "death_1" ] = %ai_shutterpeek_death_a_shutter;
	level.scr_anim[ "hiding_window" ][ "death_2" ] = %ai_shutterpeek_death_b_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_1" ] = %ai_shutterpeek_fire_a_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_2" ] = %ai_shutterpeek_fire_b_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_3" ] = %ai_shutterpeek_fire_c_shutter;
	level.scr_anim[ "hiding_window" ][ "grenade" ] = %ai_shutterpeek_grenade_shutter;
	level.scr_anim[ "hiding_window" ][ "idle" ][ 0 ] = %ai_shutterpeek_idle_shutter;
	level.scr_anim[ "hiding_window" ][ "open" ] = %ai_shutterpeek_open_shutter;
	level.scr_anim[ "hiding_window" ][ "melee" ] = %ai_shutterpeek_melee_shutter;
	level.scr_anim[ "hiding_window" ][ "hide_2_aim" ] = %ai_shutterpeek_hide_2_stand_shutter;
	level.scr_anim[ "hiding_window" ][ "aim_2_hide" ] = %ai_shutterpeek_stand_2_hide_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_1_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_a_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_2_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_b_shutter;
	level.scr_anim[ "hiding_window" ][ "fire_3_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_c_shutter;
	precachemodel( level.scr_model[ "hiding_window" ] );
	setup_model_overrides();
}

setup_model_overrides( model_type )
{
	spawners = getentarray( "hiding_door_spawner", "script_noteworthy" );
	i = 0;
	while ( i < spawners.size )
	{
		if ( isDefined( spawners[ i ].script_hidingdoor_model ) )
		{
			precachemodel( spawners[ i ].script_hidingdoor_model );
		}
		i++;
	}
}

main_door_guy()
{
	setup_guy_door_anims();
}

main_window_guy()
{
	setup_guy_window_anims();
}

setup_guy_door_anims()
{
	level.scr_anim[ "hiding_door_guy" ][ "close" ] = %doorpeek_close;
	level.scr_anim[ "hiding_door_guy" ][ "death_1" ] = %doorpeek_deatha;
	level.scr_anim[ "hiding_door_guy" ][ "death_2" ] = %doorpeek_deathb;
	level.scr_anim[ "hiding_door_guy" ][ "fire_3" ] = %doorpeek_firec;
	level.scr_anim[ "hiding_door_guy" ][ "grenade" ] = %doorpeek_grenade;
	level.scr_anim[ "hiding_door_guy" ][ "idle" ][ 0 ] = %doorpeek_idle;
	level.scr_anim[ "hiding_door_guy" ][ "jump" ] = %doorpeek_jump;
	level.scr_anim[ "hiding_door_guy" ][ "kick" ] = %doorpeek_kick;
	level.scr_anim[ "hiding_door_guy" ][ "open" ] = %doorpeek_open;
	level.scr_anim[ "hiding_door_guy" ][ "leave" ] = %doorpeek_jump;
	level.scr_anim[ "hiding_door_guy" ][ "death_1_ends_closed" ] = %doorpeek_deatha;
	level.scr_anim[ "hiding_door_guy" ][ "death_2_ends_closed" ] = %doorpeek_deathb;
	level.scr_anim[ "hiding_door_guy" ][ "jump_ends_closed" ] = %doorpeek_jump;
	level.scr_anim[ "hiding_door_guy" ][ "leave_ends_closed" ] = %doorpeek_jump;
	addnotetrack_sound( "hiding_door_guy", "sound door death", "any", "scn_doorpeek_door_open_death" );
	addnotetrack_sound( "hiding_door_guy", "sound door open", "any", "scn_doorpeek_door_open" );
	addnotetrack_sound( "hiding_door_guy", "sound door slam", "any", "scn_doorpeek_door_slam" );
}

setup_guy_window_anims()
{
	level.scr_anim[ "hiding_window_guy" ][ "close" ] = %ai_shutterpeek_close;
	level.scr_anim[ "hiding_window_guy" ][ "death_1" ] = %ai_shutterpeek_death_a;
	level.scr_anim[ "hiding_window_guy" ][ "death_2" ] = %ai_shutterpeek_death_b;
	level.scr_anim[ "hiding_window_guy" ][ "fire_1" ] = %ai_shutterpeek_fire_a;
	level.scr_anim[ "hiding_window_guy" ][ "fire_2" ] = %ai_shutterpeek_fire_b;
	level.scr_anim[ "hiding_window_guy" ][ "fire_3" ] = %ai_shutterpeek_fire_c;
	level.scr_anim[ "hiding_window_guy" ][ "grenade" ] = %ai_shutterpeek_grenade;
	level.scr_anim[ "hiding_window_guy" ][ "idle" ][ 0 ] = %ai_shutterpeek_idle;
	level.scr_anim[ "hiding_window_guy" ][ "open" ] = %ai_shutterpeek_open;
	level.scr_anim[ "hiding_window_guy" ][ "melee" ] = %ai_shutterpeek_melee;
	level.scr_anim[ "hiding_window_guy" ][ "hide_2_aim" ] = %ai_shutterpeek_hide_2_stand;
	level.scr_anim[ "hiding_window_guy" ][ "aim_2_hide" ] = %ai_shutterpeek_stand_2_hide;
	level.scr_anim[ "hiding_window_guy" ][ "fire_1_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_a;
	level.scr_anim[ "hiding_window_guy" ][ "fire_2_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_b;
	level.scr_anim[ "hiding_window_guy" ][ "fire_3_2ndstory" ] = %ai_shutterpeek_2ndstory_fire_c;
	addnotetrack_sound( "hiding_window_guy", "sound door death", "any", "scn_doorpeek_door_open_death" );
	addnotetrack_sound( "hiding_window_guy", "sound door open", "any", "scn_doorpeek_door_open" );
	addnotetrack_sound( "hiding_window_guy", "sound door slam", "any", "scn_doorpeek_door_slam" );
}

door_notetracks()
{
	wait 0,05;
	maps/_anim::addnotetrack_customfunction( "hiding_door_guy", "grenade_throw", ::hiding_door_guy_grenade_throw );
}

window_notetracks()
{
	wait 0,05;
	maps/_anim::addnotetrack_customfunction( "hiding_window_guy", "grenade_throw", ::hiding_door_guy_grenade_throw );
}

hiding_door_spawner()
{
	door_orgs = getentarray( "hiding_door_guy_org", "targetname" );
/#
	assert( door_orgs.size, "Hiding door guy with export " + self.export + " couldn't find a hiding_door_org!" );
#/
	door_org = getclosest( self.origin, door_orgs );
/#
	assert( distancesquared( door_org.origin, self.origin ) < 65536, "Hiding door guy with export " + self.export + " was not placed within 256 units of a hiding_door_org" );
#/
	door_org.hiding_place_type = "door";
	if ( isDefined( door_org.script_parameters ) )
	{
		door_org.hiding_place_type = door_org.script_parameters;
	}
	door_org.targetname = undefined;
	door_model = getent( door_org.target, "targetname" );
	door_clip = getent( door_model.target, "targetname" );
/#
	assert( isDefined( door_model.target ) );
#/
	pushplayerclip = undefined;
	if ( isDefined( door_clip.target ) )
	{
		pushplayerclip = getent( door_clip.target, "targetname" );
	}
	if ( isDefined( pushplayerclip ) )
	{
		door_org thread hiding_door_guy_pushplayer( pushplayerclip );
	}
	door_model delete();
	door = spawn_anim_model( "hiding_" + door_org.hiding_place_type );
	if ( isDefined( self.script_hidingdoor_model ) )
	{
		door setmodel( self.script_hidingdoor_model );
	}
/#
	recordent( door );
#/
	door_org thread anim_first_frame( door, "fire_3" );
	if ( isDefined( door_clip ) )
	{
		door_clip linkto( door, "door_hinge_jnt" );
		door_clip disconnectpaths();
	}
	start_trigger = undefined;
	leave_trigger = undefined;
	while ( isDefined( self.target ) )
	{
		trigger_array = getentarray( self.target, "targetname" );
		i = 0;
		while ( i < trigger_array.size )
		{
			trigger = trigger_array[ i ];
			if ( !issubstr( trigger.classname, "trigger" ) )
			{
				i++;
				continue;
			}
			else if ( isDefined( trigger.script_noteworthy ) && trigger.script_noteworthy == "leave" )
			{
				leave_trigger = trigger;
				i++;
				continue;
			}
			else
			{
				start_trigger = trigger;
			}
			i++;
		}
	}
	if ( !isDefined( self.script_flag_wait ) && !isDefined( start_trigger ) )
	{
		radius = 200;
		if ( isDefined( self.radius ) )
		{
			radius = self.radius;
		}
		start_trigger = spawn( "trigger_radius", door_org.origin, 0, radius, 48 );
	}
	triggers = spawnstruct();
	triggers.start_trigger = start_trigger;
	triggers.leave_trigger = leave_trigger;
	self add_spawn_function( ::hiding_door_guy, door_org, triggers, door, door_clip );
	self waittill( "spawned" );
}

hiding_door_guy( door_org, triggers, door, door_clip )
{
	self endon( "death" );
	self endon( "stop_hiding" );
/#
	assert( isDefined( door_org.hiding_place_type ) );
#/
	self.animname = "hiding_" + door_org.hiding_place_type + "_guy";
	self.grenadeammo = 2;
	self.overrideactordamage = ::hiding_door_actor_damage;
	self disable_react();
	self.a.allow_weapon_switch = 0;
	self.a.allow_sidearm = 0;
	self.goalradius = 4;
	start_trigger = triggers.start_trigger;
	leave_trigger = triggers.leave_trigger;
	self.hiding_door = spawnstruct();
	self.hiding_door.door_org = door_org;
	self.hiding_door.door = door;
	self.hiding_door.door_clip = door_clip;
	self.hiding_door.leave_trigger = leave_trigger;
	self thread hiding_door_guy_cleanup();
	guy_and_door = [];
	guy_and_door[ guy_and_door.size ] = door;
	guy_and_door[ guy_and_door.size ] = self;
	if ( isDefined( self.script_hidingdoor_starts_open ) )
	{
		starts_open = self.script_hidingdoor_starts_open;
	}
	if ( starts_open )
	{
		door_org thread anim_loop_aligned( guy_and_door, "idle" );
	}
	else
	{
		door_org thread anim_first_frame( guy_and_door, "fire_3" );
	}
	if ( isDefined( leave_trigger ) )
	{
		self thread hiding_door_leave_door();
	}
	if ( isDefined( start_trigger ) )
	{
		start_trigger waittill( "trigger" );
	}
	else
	{
		flag_wait( self.script_flag_wait );
	}
	self setgoalpos( self.origin );
	if ( starts_open )
	{
		door_org notify( "stop_loop" );
		door_org anim_single_aligned( guy_and_door, "close" );
	}
	if ( isDefined( self.script_hidingdoor_action ) )
	{
		scene = self.script_hidingdoor_action;
/#
		if ( scene != "kick" )
		{
			assert( scene == "jump" );
		}
#/
		self thread hiding_door_play_scene( scene );
	}
	else
	{
		self thread hiding_door_blindfire_loop( guy_and_door );
	}
}

hiding_door_blindfire_loop( guy_and_door )
{
	self endon( "death" );
	self endon( "stop_hiding" );
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_org ) );
#/
	grenadethrowwaittime = 5000;
	lastgrenadethrowtime = grenadethrowwaittime * -1;
	for ( ;; )
	{
		scene = get_anim_name( "fire" );
		if ( getTime() > ( lastgrenadethrowtime + grenadethrowwaittime ) && randomint( 100 ) < ( 25 * self.grenadeammo ) )
		{
			self.grenadeammo--;

			scene = get_anim_name( "grenade" );
			lastgrenadethrowtime = getTime();
		}
		self.hiding_door.door_org thread anim_single_aligned( guy_and_door, scene );
		if ( self.hiding_door.door_org.hiding_place_type == "door" )
		{
			delay_thread( 0,05, ::anim_set_time, guy_and_door, scene, 0,4 );
		}
		self.hiding_door.door_org waittill( scene );
		if ( scene == "hide_2_aim" )
		{
			self.bulletsinclip = weaponclipsize( self.weapon );
			wait 3;
			self.hiding_door.door_org thread anim_single_aligned( guy_and_door, "aim_2_hide" );
			self.hiding_door.door_org waittill( "aim_2_hide" );
		}
		self.hiding_door.door_org thread anim_single_aligned( guy_and_door, "fire_3" );
		wait_time = randomfloatrange( 1,5, 2,5 );
		timer = 0;
		while ( timer < wait_time )
		{
			self.hiding_door.door_org anim_set_time( guy_and_door, "fire_3", 0 );
			timer += 0,05;
			wait 0,05;
		}
		self.hiding_door.door_org notify( "stop_loop" );
	}
}

hiding_door_play_scene( scene )
{
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_org ) );
#/
/#
	assert( isDefined( self.hiding_door.door_clip ) );
#/
	self hiding_door_stop_threads();
	self notify( "left_door" );
	guy_and_door = [];
	guy_and_door[ guy_and_door.size ] = self.hiding_door.door;
	guy_and_door[ guy_and_door.size ] = self;
	scene = get_anim_name( scene );
	self.hiding_door.door_org thread anim_single_aligned( guy_and_door, scene );
	wait 0,5;
	self.hiding_door.door_clip connectpaths();
}

hiding_door_guy_cleanup()
{
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_org ) );
#/
/#
	assert( isDefined( self.hiding_door.door_clip ) );
#/
	self endon( "stop_hiding" );
	self waittill( "death" );
	self.hiding_door.door_org notify( "stop_loop" );
	thread hiding_door_death_door_connections( self.hiding_door.door_clip );
	self.hiding_door.door_org notify( "push_player" );
	if ( isDefined( self.script_hidingdoor_ends_closed ) )
	{
		ends_closed = self.script_hidingdoor_ends_closed;
	}
	if ( !ends_closed )
	{
		self.hiding_door.door_org thread anim_single_aligned( self.hiding_door.door, "death_2" );
	}
}

hiding_door_guy_pushplayer( pushplayerclip )
{
	self waittill( "push_player" );
	pushplayerclip moveto( self.origin, 1,5 );
	wait 3;
	pushplayerclip delete();
}

hiding_door_guy_grenade_throw( guy )
{
	startorigin = guy gettagorigin( "J_Wrist_RI" );
	player = get_closest_player( guy.origin );
	strength = distance( player.origin, guy.origin ) * 2;
	if ( strength < 300 )
	{
		strength = 300;
	}
	if ( strength > 1000 )
	{
		strength = 1000;
	}
	vector = vectornormalize( player.origin - guy.origin );
	velocity = vectorScale( vector, strength );
	guy magicgrenademanual( startorigin, velocity, randomfloatrange( 3, 5 ) );
}

hiding_door_death()
{
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_org ) );
#/
/#
	assert( isDefined( self.hiding_door.door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_clip ) );
#/
	if ( !isalive( self ) )
	{
		return;
	}
	guys = [];
	guys[ guys.size ] = self.hiding_door.door;
	guys[ guys.size ] = self;
	thread hiding_door_death_door_connections( self.hiding_door.door_clip );
	self.hiding_door.door_org notify( "push_player" );
	self hiding_door_stop_threads();
	death_anim = get_anim_name( "death" );
	self set_deathanim( death_anim );
	self.hiding_door.door_org delay_thread( 0,05, ::anim_single_aligned, guys, death_anim );
	wait 0,5;
	if ( isalive( self ) )
	{
		self dodamage( self.health + 150, ( 0, 0, 0 ) );
	}
}

hiding_door_death_door_connections( door_clip )
{
	if ( !isDefined( door_clip ) )
	{
		return;
	}
	door_clip connectpaths();
	wait 2;
	door_clip disconnectpaths();
}

hiding_door_stop_threads()
{
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door_org ) );
#/
	self notify( "stop_hiding" );
	self.overrideactordamage = undefined;
	self clear_deathanim();
	self enable_react();
	self.a.allow_weapon_switch = 1;
	self.a.allow_sidearm = 1;
	self.goalradius = 2048;
}

hiding_door_actor_damage( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename )
{
	self thread hiding_door_death();
	return 0;
}

hiding_door_leave_door()
{
	self endon( "death" );
	self endon( "left_door" );
/#
	assert( isDefined( self.hiding_door ) );
#/
/#
	assert( isDefined( self.hiding_door.door ) );
#/
/#
	assert( isDefined( self.hiding_door.leave_trigger ) );
#/
	anim_name = get_anim_name( "leave" );
	if ( !animation_exists( self.animname, anim_name ) )
	{
		return;
	}
	self.hiding_door.leave_trigger waittill( "trigger" );
	guy_and_door = [];
	guy_and_door[ guy_and_door.size ] = self.hiding_door.door;
	guy_and_door[ guy_and_door.size ] = self;
	thread hiding_door_death_door_connections( self.hiding_door.door_clip );
	self.hiding_door.door_org notify( "push_player" );
	self hiding_door_stop_threads();
	self.hiding_door.door_org thread anim_single_aligned( guy_and_door, anim_name );
}

pick_death_anim()
{
	death_choices = [];
	i = 1;
	while ( i < 3 )
	{
		anim_name = "death_" + i;
		if ( animation_exists( self.animname, anim_name ) )
		{
			death_choices[ death_choices.size ] = anim_name;
		}
		i++;
	}
	return death_choices[ randomint( death_choices.size ) ];
}

pick_fire_anim()
{
	fire_choices = [];
	i = 1;
	while ( i < 4 )
	{
		anim_name = "fire_" + i;
		if ( animation_exists( self.animname, anim_name ) )
		{
			fire_choices[ fire_choices.size ] = anim_name;
		}
		i++;
	}
	if ( animation_exists( self.animname, "hide_2_aim" ) )
	{
		fire_choices[ fire_choices.size ] = "hide_2_aim";
	}
	return fire_choices[ randomint( fire_choices.size ) ];
}

get_anim_name( action )
{
	anim_name = action;
	switch( action )
	{
		case "fire":
			anim_name = pick_fire_anim();
			break;
		case "death":
			anim_name = pick_death_anim();
			break;
	}
	if ( isDefined( self.script_hidingdoor_ends_closed ) )
	{
		ends_closed = self.script_hidingdoor_ends_closed;
	}
	if ( isDefined( self.enemy ) )
	{
		enemy_is_below = ( self.origin[ 2 ] - self.enemy.origin[ 2 ] ) > 100;
	}
	if ( ends_closed && animation_exists( self.animname, anim_name + "_ends_closed" ) )
	{
		anim_name += "_ends_closed";
	}
	if ( enemy_is_below && animation_exists( self.animname, anim_name + "_2ndstory" ) )
	{
		anim_name += "_2ndstory";
	}
	return anim_name;
}
