#include maps/_hud_util;
#include maps/_utility;
#include common_scripts/utility;

init()
{
	precachestring( &"SCRIPT_PLATFORM_CHEAT_USETOSLOWMO" );
	precacheshellshock( "chaplincheat" );
	level.vision_cheat_enabled = 0;
	level.tire_explosion = 0;
	level.cheatstates = [];
	level.cheatfuncs = [];
	level.cheatdvars = [];
	level.cheatbobamporiginal = getDvar( #"72BFD45D" );
	level.cheatshowslowmohint = 0;
	if ( !isDefined( level._effect ) )
	{
		level._effect = [];
	}
	level._effect[ "grain_test" ] = loadfx( "misc/fx_grain_test" );
	flag_init( "has_cheated" );
	level.visionsets[ "bw" ] = 0;
	level.visionsets[ "invert" ] = 0;
	level.visionsets[ "contrast" ] = 0;
	level.visionsets[ "chaplin" ] = 0;
	level thread death_monitor();
	flag_init( "disable_slowmo_cheat" );
}

player_init()
{
	self thread specialfeaturesmenu();
	players = get_players();
	if ( self == players[ 0 ] )
	{
		self slowmo_system_init();
	}
}

death_monitor()
{
	setdvars_based_on_varibles();
	while ( 1 )
	{
		if ( issaverecentlyloaded() )
		{
			setdvars_based_on_varibles();
		}
		wait 0,1;
	}
}

setdvars_based_on_varibles()
{
	index = 0;
	while ( index < level.cheatdvars.size )
	{
		setdvar( level.cheatdvars[ index ], level.cheatstates[ level.cheatdvars[ index ] ] );
		index++;
	}
	if ( !isDefined( level.credits_active ) || !level.credits_active )
	{
		setdvar( "credits_active", "0" );
		setdvar( "credits_load", "0" );
	}
}

addcheat( toggledvar, cheatfunc )
{
	setdvar( toggledvar, 0 );
	level.cheatstates[ toggledvar ] = getDvarInt( toggledvar );
	level.cheatfuncs[ toggledvar ] = cheatfunc;
	if ( level.cheatstates[ toggledvar ] )
	{
		[[ cheatfunc ]]( level.cheatstates[ toggledvar ] );
	}
}

checkcheatchanged( toggledvar )
{
	cheatvalue = getDvarInt( toggledvar );
	if ( level.cheatstates[ toggledvar ] == cheatvalue )
	{
		return;
	}
	if ( cheatvalue )
	{
		flag_set( "has_cheated" );
	}
	level.cheatstates[ toggledvar ] = cheatvalue;
	[[ level.cheatfuncs[ toggledvar ] ]]( cheatvalue );
}

specialfeaturesmenu()
{
	addcheat( "sf_use_contrast", ::contrastmode );
	addcheat( "sf_use_bw", ::bwmode );
	addcheat( "sf_use_invert", ::invertmode );
	addcheat( "sf_use_slowmo", ::slowmomode );
	addcheat( "sf_use_ignoreammo", ::ignore_ammomode );
	addcheat( "sf_use_clustergrenade", ::clustergrenademode );
	addcheat( "sf_use_tire_explosion", ::tire_explosionmode );
	level.cheatdvars = getarraykeys( level.cheatstates );
	for ( ;; )
	{
		index = 0;
		while ( index < level.cheatdvars.size )
		{
			checkcheatchanged( level.cheatdvars[ index ] );
			index++;
		}
		wait 0,5;
	}
}

tire_explosionmode( cheatvalue )
{
	if ( cheatvalue )
	{
		level.tire_explosion = 1;
	}
	else
	{
		level.tire_explosion = 0;
	}
}

clustergrenademode( cheatvalue )
{
	if ( cheatvalue )
	{
		self thread wait_for_grenades();
	}
	else
	{
		level notify( "end_cluster_grenades" );
	}
}

wait_for_grenades()
{
	level endon( "end_cluster_grenades" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		while ( weapname != "frag_grenade" )
		{
			continue;
		}
		grenade thread create_clustergrenade();
	}
}

create_clustergrenade()
{
	prevorigin = self.origin;
	while ( 1 )
	{
		if ( !isDefined( self ) )
		{
			break;
		}
		else
		{
			prevorigin = self.origin;
			wait 0,1;
		}
	}
	prevorigin += vectorScale( ( 0, 0, 1 ), 5 );
	aiarray = getaiarray();
	if ( aiarray.size == 0 )
	{
		return;
	}
	ai = undefined;
	i = 0;
	while ( i < aiarray.size )
	{
		if ( aiarray[ i ].team == "allies" )
		{
			ai = aiarray[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	if ( !isDefined( ai ) )
	{
		ai = aiarray[ 0 ];
	}
	oldweapon = ai.grenadeweapon;
	ai.grenadeweapon = "frag_grenade";
	i = 0;
	while ( i < 8 )
	{
		velocity = getclustergrenadevelocity();
		timer = 1,5 + ( i / 6 ) + randomfloat( 0,1 );
		ai magicgrenademanual( prevorigin, velocity, timer );
		i++;
	}
	ai.grenadeweapon = oldweapon;
}

getclustergrenadevelocity()
{
	yaw = randomfloat( 360 );
	pitch = randomfloatrange( 65, 85 );
	amntz = sin( pitch );
	cospitch = cos( pitch );
	amntx = cos( yaw ) * cospitch;
	amnty = sin( yaw ) * cospitch;
	speed = randomfloatrange( 400, 600 );
	velocity = ( amntx, amnty, amntz ) * speed;
	return velocity;
}

ignore_ammomode( cheatvalue )
{
	if ( level.script == "ac130" )
	{
		return;
	}
	if ( cheatvalue )
	{
		setsaveddvar( "player_sustainAmmo", 1 );
	}
	else
	{
		setsaveddvar( "player_sustainAmmo", 0 );
	}
}

contrastmode( cheatvalue )
{
	if ( cheatvalue )
	{
		level.visionsets[ "contrast" ] = 1;
	}
	else
	{
		level.visionsets[ "contrast" ] = 0;
	}
	applyvisionsets();
}

bwmode( cheatvalue )
{
	if ( cheatvalue )
	{
		level.visionsets[ "bw" ] = 1;
	}
	else
	{
		level.visionsets[ "bw" ] = 0;
	}
	applyvisionsets();
}

invertmode( cheatvalue )
{
	if ( cheatvalue )
	{
		level.visionsets[ "invert" ] = 1;
	}
	else
	{
		level.visionsets[ "invert" ] = 0;
	}
	applyvisionsets();
}

applyvisionsets()
{
	if ( level.script == "ac130" )
	{
		return;
	}
	visionset = "";
	if ( level.visionsets[ "bw" ] )
	{
		visionset += "_bw";
	}
	if ( level.visionsets[ "invert" ] )
	{
		visionset += "_invert";
	}
	if ( level.visionsets[ "contrast" ] )
	{
		visionset += "_contrast";
	}
	if ( level.visionsets[ "chaplin" ] )
	{
		level.vision_cheat_enabled = 1;
		visionsetnaked( "sepia", 0,5 );
	}
	else if ( visionset != "" )
	{
		level.vision_cheat_enabled = 1;
		visionsetnaked( "cheat" + visionset, 1 );
	}
	else
	{
		level.vision_cheat_enabled = 0;
		visionsetnaked( level.lvl_visionset, 3 );
	}
}

slowmo_system_init()
{
	if ( !isDefined( level.slowmo ) )
	{
		level.slowmo = spawnstruct();
		slowmo_system_defaults();
		level.slowmo.speed_current = level.slowmo.speed_norm;
		level.slowmo.lerp_interval = 0,05;
		level.slowmo.lerping = 0;
	}
}

slowmo_system_defaults()
{
	level.slowmo.lerp_time_in = 0;
	level.slowmo.lerp_time_out = 0,25;
	level.slowmo.speed_slow = 0,4;
	level.slowmo.speed_norm = 1;
}

slowmo_check_system()
{
/#
	if ( !isDefined( level.slowmo ) )
	{
		assertmsg( "level.slowmo has not been initiliazed...you shoud not call a slowmo function within the first frame" );
		return 0;
#/
	}
	return 1;
}

slowmo_hintprint()
{
	if ( level.cheatshowslowmohint != 0 )
	{
		level.cheatshowslowmohint = 0;
		return;
	}
	level.cheatshowslowmohint = 1;
	myhintback = createicon( "black", 650, 30 );
	myhintback.hidewheninmenu = 1;
	myhintback setpoint( "TOP", undefined, 0, 105 );
	myhintback.alpha = 0,2;
	myhintback.sort = 0;
	myhintstring = createfontstring( "objective", 1,6 );
	myhintstring.hidewheninmenu = 1;
	myhintstring setpoint( "TOP", undefined, 0, 110 );
	myhintstring.sort = 0,5;
	myhintstring settext( &"SCRIPT_PLATFORM_CHEAT_USETOSLOWMO" );
	cycles = 0;
	while ( cycles < 100 )
	{
		if ( level.cheatshowslowmohint != 1 )
		{
			break;
		}
		else if ( isDefined( level.hintelem ) )
		{
			break;
		}
		else
		{
			wait 0,1;
			cycles++;
		}
	}
	level.cheatshowslowmohint = 0;
	myhintback destroy();
	myhintstring destroy();
}

slowmomode( cheatvalue )
{
	if ( cheatvalue )
	{
		level.slowmo thread gamespeed_proc();
		self allowmelee( 0 );
		thread slowmo_hintprint();
	}
	else
	{
		level notify( "disable_slowmo" );
		self allowmelee( 1 );
		level.slowmo thread gamespeed_reset();
		level.cheatshowslowmohint = 0;
	}
}

gamespeed_proc()
{
	level endon( "disable_slowmo" );
	self thread gamespeed_reset_on_death();
	while ( 1 )
	{
		self waittill( "action_notify_melee" );
		level.cheatshowslowmohint = 0;
		if ( !flag( "disable_slowmo_cheat" ) )
		{
			if ( self.speed_current < level.slowmo.speed_norm )
			{
				self thread gamespeed_reset();
				break;
			}
			else
			{
				self thread gamespeed_slowmo();
			}
		}
		waittillframeend;
	}
}

gamespeed_reset_on_death()
{
	level notify( "gamespeed_reset_on_death" );
	level endon( "gamespeed_reset_on_death" );
	self waittill( "death" );
	self thread gamespeed_reset();
}

gamespeed_set( speed, refspeed, lerp_time )
{
	self notify( "gamespeed_set" );
	self endon( "gamespeed_set" );
	default_range = speed - refspeed;
	actual_range = speed - self.speed_current;
	actual_rangebytime = actual_range * lerp_time;
	if ( !default_range )
	{
		return;
	}
	time = actual_rangebytime / default_range;
	interval = self.lerp_interval;
	cycles = int( time / interval );
	if ( !cycles )
	{
		cycles = 1;
	}
	increment = actual_range / cycles;
	self.lerping = time;
	while ( cycles )
	{
		self.speed_current += increment;
		settimescale( self.speed_current );
		cycles--;

		self.lerping -= interval;
		wait interval;
	}
	self.speed_current = speed;
	settimescale( self.speed_current );
	self.lerping = 0;
}

gamespeed_slowmo()
{
	gamespeed_set( self.speed_slow, self.speed_norm, self.lerp_time_in );
}

gamespeed_reset()
{
	gamespeed_set( self.speed_norm, self.speed_slow, self.lerp_time_out );
}

is_cheating()
{
	i = 0;
	while ( i < level.cheatdvars.size )
	{
		if ( level.cheatstates[ level.cheatdvars[ i ] ] )
		{
			return 1;
		}
		i++;
	}
	return 0;
}
