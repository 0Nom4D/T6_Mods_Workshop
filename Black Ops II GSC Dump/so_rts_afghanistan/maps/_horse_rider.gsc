#include animscripts/weaponlist;
#include animscripts/shared;
#include animscripts/shoot_behavior;
#include animscripts/utility;
#include maps/_anim;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

ride_and_shoot( horse )
{
	if ( !isDefined( horse ) )
	{
/#
		iprintlnbold( "Warning: ride_and_shoot called with an undefined horse" );
#/
		return;
	}
	self.ridingvehicle = horse;
	self horse_rider_setup_anim_funcs();
	self animcustom( ::ai_ride_and_shoot );
}

ai_ride_and_shoot()
{
	self endon( "death" );
	self endon( "start_ragdoll" );
	self endon( "stop_riding" );
	self.riderisarmed = 0;
	self.riderisaiming = 0;
	self.ridershouldjump = 0;
	self.ridershouldland = 0;
	self.prevrideryawaimweight = 0;
	self.prevriderpitchaimweight = 0;
	self.prevsideanimweight = 99999;
	self.anim_rate = 1;
	self.pauseanimation = 0;
	self.max_horse_aim_yaw_angle = 0;
	self.max_horse_aim_pitch_angle = 60;
	self.max_horse_aim_angle_delta = 12;
	self.max_horse_side_yaw_angle = 90;
	if ( !isDefined( self.max_horse_total_yaw_angle ) )
	{
		self.max_horse_total_yaw_angle = self.max_horse_side_yaw_angle + self.max_horse_aim_yaw_angle;
	}
	if ( !isDefined( level.ai_horse_death_launch_vector ) )
	{
		level.ai_horse_death_launch_vector = ( 10, 10, 40 );
	}
	self maps/_utility::disable_pain();
	self maps/_utility::disable_react();
	self thread ai_ride_and_shoot_stop();
	self thread ai_ride_and_shoot_exit_vehicle();
	self.overrideactordamage = ::ai_ride_and_shoot_damage_override;
	self animmode( "point relative" );
	self.fixedlinkyawonly = 0;
	self.a.usetagaim = 1;
	self ai_ride_and_shoot_noncombat();
	self thread animscripts/shoot_behavior::decidewhatandhowtoshoot( "normal" );
	while ( 1 )
	{
		while ( isDefined( self.pauseanimation ) && self.pauseanimation )
		{
			wait 0,05;
		}
		if ( isDefined( self.shootent ) )
		{
			shootpos = self.shootent getshootatpos( self );
			shootfrompos = self animscripts/shared::trackloopgetshootfrompos();
			shootfromangles = self animscripts/shared::trackloopgetshootfromangles();
			vectortoshootpos = shootpos - shootfrompos;
			anglestoshootpos = vectorToAngle( vectortoshootpos );
			facingvector = anglesToForward( shootfromangles );
			yawtoenemy = angleClamp180( shootfromangles[ 1 ] - anglestoshootpos[ 1 ] );
			pitchtoenemy = angleClamp180( shootfromangles[ 0 ] - anglestoshootpos[ 0 ] );
			realyawtoenemy = self getyawtoorigin( shootpos );
			if ( abs( realyawtoenemy ) < self.max_horse_total_yaw_angle )
			{
				while ( !self.riderisarmed )
				{
					self ai_ride_and_shoot_gun_pullout();
				}
				if ( abs( realyawtoenemy ) > self.max_horse_side_yaw_angle )
				{
					yawaimweight = abs( yawtoenemy / self.max_horse_aim_yaw_angle );
					aimdelta = yawaimweight - self.prevrideryawaimweight;
					maxweightchange = self.max_horse_aim_angle_delta / self.max_horse_aim_yaw_angle;
					if ( abs( aimdelta ) > maxweightchange )
					{
						yawaimweight = self.prevrideryawaimweight + ( maxweightchange * sign( aimdelta ) );
					}
					if ( yawaimweight > 1 )
					{
						yawaimweight = 1;
					}
					if ( yawtoenemy < 0 )
					{
						self setanimlimited( %horse_aim_4, yawaimweight, 0,05 );
						self clearanim( %horse_aim_6, 0,1 );
						break;
					}
					else
					{
						self setanimlimited( %horse_aim_6, yawaimweight, 0,05 );
						self clearanim( %horse_aim_4, 0,1 );
					}
				}
				pitchaimweight = abs( pitchtoenemy / self.max_horse_aim_pitch_angle );
				if ( abs( pitchaimweight ) > 1 )
				{
					pitchaimweight = sign( pitchaimweight );
				}
				aimdelta = pitchaimweight - self.prevriderpitchaimweight;
				maxweightchange = self.max_horse_aim_angle_delta / self.max_horse_aim_pitch_angle;
				if ( abs( aimdelta ) > maxweightchange )
				{
					pitchaimweight = self.prevriderpitchaimweight + ( maxweightchange * sign( aimdelta ) );
				}
				if ( pitchtoenemy < 0 )
				{
					self setanimlimited( %horse_aim_2, pitchaimweight, 0,05 );
					self clearanim( %horse_aim_8, 0,1 );
				}
				else
				{
					self setanimlimited( %horse_aim_8, pitchaimweight, 0,05 );
					self clearanim( %horse_aim_2, 0,1 );
				}
				self.prevrideryawaimweight = yawaimweight;
				self.prevriderpitchaimweight = pitchaimweight;
			}
			else
			{
				if ( self.riderisarmed )
				{
					self ai_ride_and_shoot_gun_putaway();
				}
			}
		}
		else
		{
			if ( self.riderisarmed )
			{
				self ai_ride_and_shoot_gun_putaway();
			}
		}
		if ( self.riderisarmed )
		{
			self ai_ride_and_shoot_aim_idle( 0,2 );
		}
		wait 0,05;
	}
}

ai_ride_and_shoot_stop()
{
	self waittill( "stop_riding" );
	self.overrideactordamage = undefined;
}

ai_ride_and_shoot_exit_vehicle()
{
	self waittill( "exit_vehicle" );
	self maps/_utility::enable_pain();
	self maps/_utility::enable_react();
}

ai_ride_play_anim( animname )
{
	self endon( "death" );
	self endon( "stop_riding" );
	self setanimknoballrestart( animname, %body, 1, 0,2, 1 );
	wait getanimlength( animname );
}

ai_ride_stop_horse()
{
	self endon( "death" );
	self endon( "stop_riding" );
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	self.pauseanimation = 1;
	self ai_ride_play_anim( %ai_horse_rider_short_stop_init );
	self ai_ride_play_anim( %ai_horse_rider_short_stop_finish );
	self.pauseanimation = 0;
	if ( !self.riderisarmed )
	{
		self ai_ride_and_shoot_noncombat();
	}
}

ai_ride_stop_riding()
{
	self endon( "death" );
	self endon( "start_ragdoll" );
	self notify( "stop_riding" );
	self clearanim( %root, 0 );
	self unlink();
}

ai_ride_and_shoot_linkto_horse()
{
	horse = self.ridingvehicle;
	tag_driver_origin = horse gettagorigin( "tag_driver" );
	tag_driver_angles = horse gettagangles( "tag_driver" );
	self forceteleport( tag_driver_origin, tag_driver_angles );
	self linkto( horse, "tag_driver" );
	self clearanim( %root, 0 );
}

ai_ride_and_shoot_aiming_on( sideanimweight )
{
	animspeed = self _horse_rider_get_anim_speed();
	if ( animspeed == level.walk )
	{
		horse_fire_anim = %horse_fire_walk;
	}
	else if ( animspeed == level.trot )
	{
		horse_fire_anim = %horse_fire_trot;
	}
	else if ( animspeed == level.run )
	{
		horse_fire_anim = %horse_fire_canter;
	}
	else if ( animspeed == level.sprint )
	{
		horse_fire_anim = %horse_fire_sprint;
	}
	else
	{
		horse_fire_anim = %horse_fire_idle;
	}
	if ( !isDefined( sideanimweight ) )
	{
		sideanimweight = 0;
	}
	if ( sideanimweight < 0 )
	{
		sideanimweight = abs( sideanimweight );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 2 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 4 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 6 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 8 ], sideanimweight, 0,2 );
		self setanimknoblimited( horse_fire_anim, sideanimweight, 0,2 );
		if ( sideanimweight > 0,5 )
		{
			self setflaggedanimlimited( "fireAnim", level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ level.fire ], sideanimweight, 0,2 );
		}
		else
		{
			self setanimlimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ level.fire ], sideanimweight, 0,2 );
		}
		self clearanimlimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ level.fire ], 0,2 );
	}
	else
	{
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 2 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 4 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 6 ], sideanimweight, 0,2 );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 8 ], sideanimweight, 0,2 );
		self setanimknoblimited( horse_fire_anim, sideanimweight, 0,2 );
		if ( sideanimweight > 0,5 )
		{
			self setflaggedanimlimited( "fireAnim", level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ level.fire ], sideanimweight, 0,2 );
		}
		else
		{
			self setanimlimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ level.fire ], sideanimweight, 0,2 );
		}
		self clearanimlimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ level.fire ], 0,2 );
	}
	if ( sideanimweight < 1 )
	{
		if ( sideanimweight < 0,5 )
		{
			self setflaggedanimlimited( "fireAnim", level.horse_ai_aim_anims[ animspeed ][ level.aim_f ][ level.fire ], 1 - sideanimweight, 0,2 );
		}
		else
		{
			self setanimlimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_f ][ level.fire ], 1 - sideanimweight, 0,2 );
		}
	}
	self animscripts/weaponlist::refillclip();
}

ai_ride_and_shoot_noncombat()
{
	horse = self.ridingvehicle;
	if ( !isDefined( horse ) )
	{
		return;
	}
	if ( isDefined( self.riderisdead ) && self.riderisdead )
	{
		return;
	}
	self.riderisaiming = 0;
	self.riderisarmed = 0;
/#
	if ( isDefined( horse ) && isDefined( horse.horse_animating_override ) )
	{
		return;
#/
	}
	if ( !isDefined( horse.rider_nextanimation ) )
	{
		self thread wait_for_horse_anim( horse );
		return;
	}
	self setanim( horse.rider_nextanimation, 1, 0, self.anim_rate );
	self setanimtime( horse.rider_nextanimation, horse.current_time );
}

wait_for_horse_anim( horse )
{
	self endon( "death" );
	self endon( "wait_for_horse_anim" );
	self notify( "wait_for_horse_anim" );
	while ( 1 )
	{
		if ( isDefined( horse.rider_nextanimation ) )
		{
			self setanim( horse.rider_nextanimation, 1, 0, 1 );
			self setanimtime( horse.rider_nextanimation, horse.current_time );
			return;
		}
		wait 0,05;
	}
}

ai_ride_and_shoot_aim_time()
{
	horse = self.ridingvehicle;
	if ( !isDefined( horse ) )
	{
		return;
	}
	animspeed = horse.current_anim_speed;
	if ( isDefined( level.horse_ai_aim_anims[ animspeed ] ) && isDefined( horse.current_time ) )
	{
		self.horse_ride_sync_count = randomintrange( 2, 6 );
		self setanimtime( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 5 ], horse.current_time );
		self setanimtime( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 5 ], horse.current_time );
		self setanimtime( level.horse_ai_aim_anims[ animspeed ][ level.aim_f ][ 5 ], horse.current_time );
	}
}

ai_ride_and_shoot_aim_idle( blendtime )
{
	self.riderisaiming = 1;
	if ( !isDefined( self.shootent ) )
	{
		return;
	}
/#
	assert( isDefined( self.shootent ) );
#/
	realyawtoenemy = self getyawtoorigin( self.shootent.origin );
	sideanimweight = realyawtoenemy / self.max_horse_side_yaw_angle;
	aimdelta = sideanimweight - self.prevsideanimweight;
	maxweightchange = self.max_horse_aim_angle_delta / self.max_horse_side_yaw_angle;
	if ( abs( aimdelta ) > maxweightchange )
	{
		sideanimweight = self.prevsideanimweight + ( maxweightchange * sign( aimdelta ) );
	}
	if ( abs( sideanimweight ) > 1 )
	{
		sideanimweight = sign( sideanimweight );
	}
	if ( self.prevsideanimweight != sideanimweight )
	{
		ai_ride_and_shoot_aiming_on( sideanimweight );
	}
	self.prevsideanimweight = sideanimweight;
	if ( !isDefined( blendtime ) )
	{
		blendtime = 0,05;
	}
	animspeed = self _horse_rider_get_anim_speed();
	if ( sideanimweight < 0 )
	{
		sideanimweight = abs( sideanimweight );
		self setanimlimited( %horse_aim_l_5, sideanimweight, blendtime, 1 );
		self clearanim( %horse_aim_r_5, blendtime );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 5 ], sideanimweight, blendtime, self.anim_rate );
		self clearanim( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 5 ], blendtime );
	}
	else
	{
		self setanimlimited( %horse_aim_r_5, sideanimweight, blendtime, 1 );
		self clearanim( %horse_aim_l_5, blendtime );
		self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_r ][ 5 ], sideanimweight, blendtime, self.anim_rate );
		self clearanim( level.horse_ai_aim_anims[ animspeed ][ level.aim_l ][ 5 ], blendtime );
	}
	self setanimlimited( %horse_aim_f_5, 1 - sideanimweight, blendtime, self.anim_rate );
	self setanimknoblimited( level.horse_ai_aim_anims[ animspeed ][ level.aim_f ][ 5 ], 1 - sideanimweight, blendtime, self.anim_rate );
}

ai_ride_and_shoot_gun_pullout()
{
	self.prevsideanimweight = 0;
	if ( isDefined( self.shootent ) )
	{
		self.riderisarmed = 1;
		self.prevrideryawaimweight = 0;
		self.prevriderpitchaimweight = 0;
		self ai_ride_and_shoot_aim_idle( 0,2 );
		self ai_ride_and_shoot_aim_time();
		self thread ai_ride_and_shoot_gun_shoot();
	}
	else
	{
		self ai_ride_and_shoot_gun_putaway( 0 );
	}
}

ai_ride_and_shoot_gun_putaway( aimforwardtime )
{
	self notify( "stopShooting" );
	if ( !isDefined( aimforwardtime ) )
	{
		aimforwardtime = 0,3;
	}
	self clearanim( %horse_aim_6, 0,1 );
	self clearanim( %horse_aim_4, 0,1 );
	self clearanim( %horse_aim_8, 0,1 );
	self clearanim( %horse_aim_2, 0,1 );
	self clearanim( %horse_fire, aimforwardtime );
	self clearanim( %horse_aim_f_5, 0,1 );
	self clearanim( %horse_aim_l_5, 0,1 );
	self clearanim( %horse_aim_r_5, 0,1 );
	if ( isDefined( self.ridingvehicle ) )
	{
		self.ridingvehicle.idle_end_time = 0;
	}
	self.riderisarmed = 0;
}

ai_ride_and_shoot_gun_shoot()
{
	self notify( "stopShooting" );
	self endon( "death" );
	self endon( "stopShooting" );
	self endon( "start_ragdoll" );
	self setanim( %horse_fire, 1, 0 );
	while ( 1 )
	{
		self waittillmatch( "fireAnim" );
		return "fire";
		self shootenemywrapper();
		if ( !isDefined( self.horse_shoot_wait_time ) )
		{
			wait 0,05;
			continue;
		}
		else
		{
			wait self.horse_shoot_wait_time;
		}
	}
}

ai_ride_and_shoot_pain()
{
	if ( isDefined( self.riderispain ) )
	{
		return;
	}
	self endon( "death" );
	self.riderispain = 1;
	self setanimrestart( self.pain_anim, 1, 0,1, 1 );
	wait getanimlength( self.pain_anim );
	self clearanim( self.pain_anim, 0 );
	if ( self.riderisarmed )
	{
		self ai_ride_and_shoot_aim_idle( 0,2 );
		self thread ai_ride_and_shoot_gun_shoot();
	}
	self.riderispain = undefined;
}

ai_ride_and_shoot_set_death_anim( dir )
{
	if ( self.riderisarmed || isDefined( self.gun_pullout ) && self.gun_pullout )
	{
		if ( dir == "front" )
		{
			self.deathanim = %ai_horse_rider_aiming_death_f;
		}
		else if ( dir == "left" )
		{
			self.deathanim = %ai_horse_rider_aiming_death_l;
		}
		else if ( dir == "right" )
		{
			self.deathanim = %ai_horse_rider_aiming_death_r;
		}
		else
		{
			self.deathanim = %ai_horse_rider_aiming_death_b;
		}
	}
	else
	{
		if ( dir == "front" )
		{
			self.deathanim = %ai_horse_rider_death_f;
			return;
		}
		else if ( dir == "left" )
		{
			self.deathanim = %ai_horse_rider_death_l;
			return;
		}
		else if ( dir == "right" )
		{
			self.deathanim = %ai_horse_rider_death_r;
			return;
		}
		else
		{
			self.deathanim = %ai_horse_rider_death_b;
		}
	}
}

ai_ride_and_shoot_weapon_drop()
{
	self waittillmatch( "rider_death" );
	return "dropgun";
	self animscripts/shared::dropallaiweapons();
}

ai_ride_and_shoot_death()
{
	self thread ai_ride_and_shoot_weapon_drop();
	self unlink();
	self animscripted( "rider_death", self.origin, self.angles, self.deathanim, "normal", undefined, 1, 0,2 );
	self waittillmatch( "rider_death" );
	return "start_ragdoll";
	self.overrideactordamage = undefined;
	self startragdoll();
	self dodamage( self.health, self.origin );
}

ai_ride_and_shoot_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, modelindex, psoffsettime, bonename )
{
	if ( isDefined( self.riderisdead ) && self.riderisdead )
	{
		return 0;
	}
	angles = vectorToAngle( vdir );
	yaw = angleClamp180( angles[ 1 ] - self.angles[ 1 ] );
	dir = getanimdirection( yaw );
	if ( idamage >= self.health && !is_true( self.magic_bullet_shield ) )
	{
		self.riderisdead = 1;
		self ai_ride_and_shoot_set_death_anim( dir );
		self thread ai_ride_and_shoot_death();
		return 0;
	}
	if ( self.riderisarmed || isDefined( self.gun_pullout ) && self.gun_pullout )
	{
		if ( dir == "front" )
		{
			self.pain_anim = %ai_horse_rider_aiming_pain_f;
		}
		else if ( dir == "left" )
		{
			self.pain_anim = %ai_horse_rider_aiming_pain_l;
		}
		else if ( dir == "right" )
		{
			self.pain_anim = %ai_horse_rider_aiming_pain_r;
		}
		else
		{
			self.pain_anim = %ai_horse_rider_aiming_pain_b;
		}
	}
	else
	{
		if ( dir == "front" )
		{
			self.pain_anim = %ai_horse_rider_pain_f;
		}
		else if ( dir == "left" )
		{
			self.pain_anim = %ai_horse_rider_pain_l;
		}
		else if ( dir == "right" )
		{
			self.pain_anim = %ai_horse_rider_pain_r;
		}
		else
		{
			self.pain_anim = %ai_horse_rider_pain_b;
		}
	}
	self thread ai_ride_and_shoot_pain();
	return idamage;
}

ai_ride_and_shoot_ragdoll_death()
{
	self.a.doingragdolldeath = 1;
	self animscripts/shared::dropallaiweapons();
	velocity = anglesToForward( self.angles );
/#
	assert( isDefined( level.ai_horse_death_launch_vector ) );
#/
	velocity = ( velocity[ 0 ] * level.ai_horse_death_launch_vector[ 0 ], velocity[ 1 ] * level.ai_horse_death_launch_vector[ 1 ], level.ai_horse_death_launch_vector[ 2 ] );
	self unlink();
	self startragdoll();
	self launchragdoll( velocity );
/#
	recordline( self.origin, self.origin + velocity, ( 1, 0, 0 ), "Script", self );
#/
	return 1;
}

_horse_rider_get_anim_speed()
{
	if ( !isDefined( self.ridingvehicle ) )
	{
		return level.idle;
	}
	animspeed = self.ridingvehicle.current_anim_speed;
	if ( animspeed < level.idle || animspeed > level.sprint )
	{
		return level.idle;
	}
	return animspeed;
}

horse_rider_setup_anim_funcs()
{
	self.update_rearback_anim = ::horse_rider_update_rearback_anim;
	self.update_idle_anim = ::horse_rider_update_idle_anim;
	self.update_reverse_anim = ::horse_rider_update_reverse_anim;
	self.update_turn_anim = ::horse_rider_update_turn_anim;
	self.update_run_anim = ::horse_rider_update_run_anim;
	self.update_stop_anim = ::ai_ride_stop_horse;
}

horse_rider_can_update_anim()
{
	if ( is_true( self.pause_animation ) )
	{
		return 0;
	}
	if ( is_true( self.riderisdead ) )
	{
		return 0;
	}
	return 1;
}

horse_rider_update_rearback_anim()
{
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	rearback_anim = level.horse_ai_anims[ level.rearback ];
	self.pause_animation = 1;
	self setanimknoballrestart( rearback_anim, %root, 1, 0,2, 1 );
	len = getanimlength( rearback_anim );
	wait len;
	self.pause_animation = 0;
}

horse_rider_update_idle_anim( idle_struct, anim_index )
{
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	if ( self.riderisarmed )
	{
		self clearanim( %horse_idle, 0,2 );
		self clearanim( %horse_runs, 0,2 );
		return;
	}
	idle_anim = idle_struct.ai_animations[ anim_index ];
	self setanimknoballrestart( idle_anim, %root, 1, 0,2, 1 );
}

horse_rider_update_reverse_anim( anim_rate )
{
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	self setanimknoball( level.horse_ai_anims[ level.reverse ], %root, 1, 0,2, anim_rate );
}

horse_rider_update_turn_anim( anim_rate, anim_index )
{
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	self setanimknoball( level.horse_ai_anims[ level.idle ][ anim_index ], %root, 1, 0,2, anim_rate );
}

horse_rider_update_run_anim( anim_rate, horse )
{
	if ( !self horse_rider_can_update_anim() )
	{
		return;
	}
	self clearanim( %horse_idle, 0,2 );
	sync_time = 0;
	if ( !isDefined( self.horse_ride_sync_count ) )
	{
		sync_time = 1;
		self.horse_ride_sync_count = randomintrange( 2, 6 );
	}
	self.horse_ride_sync_count--;

	if ( self.horse_ride_sync_count == 0 )
	{
		sync_time = 1;
	}
	if ( self.anim_rate != anim_rate )
	{
		sync_time = 1;
		self.anim_rate = anim_rate;
	}
	if ( self.riderisarmed )
	{
		self clearanim( %horse_runs, 0,2 );
		if ( sync_time )
		{
			ai_ride_and_shoot_aim_time();
		}
		return;
	}
	if ( isarray( level.horse_ai_anims[ horse.current_anim_speed ][ 0 ] ) )
	{
		if ( !isDefined( self.num_assigned_sprint_anim ) )
		{
			self.num_assigned_sprint_anim = randomint( level.horse_ai_anims[ horse.current_anim_speed ][ 0 ].size );
		}
		cur_anim = level.horse_ai_anims[ horse.current_anim_speed ][ 0 ][ self.num_assigned_sprint_anim ];
		self setanimknoball( cur_anim, %root, 1, 0,2, anim_rate );
		if ( isDefined( horse.current_time ) && sync_time )
		{
			self.horse_ride_sync_count = randomintrange( 2, 6 );
			self setanimtime( cur_anim, horse.current_time );
		}
	}
	else
	{
		cur_anim = level.horse_ai_anims[ horse.current_anim_speed ][ 0 ];
		if ( isDefined( self.riderispain ) )
		{
			self setanim( cur_anim, 1, 0,2, anim_rate );
		}
		else
		{
			self setanimknoball( cur_anim, %root, 1, 0,2, anim_rate );
		}
		if ( isDefined( horse.current_time ) && sync_time )
		{
			self setanimtime( cur_anim, horse.current_time );
		}
	}
}
