#include animscripts/utility;
#include maps/_anim;
#include maps/_vehicle;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "player" );

init()
{
	flag_wait( "all_players_connected" );
	player = get_players()[ 0 ];
	player spawn_player_body();
	setsaveddvar( "player_disableWeaponsOnVehicle", "0" );
	setsaveddvar( "player_lookAtEntityAllowChildren", "1" );
}

precache_models()
{
	level.player_reigns_model = "c_usa_mason_afgan_reigns_viewbody";
	precachemodel( level.player_reigns_model );
}

spawn_player_body()
{
	if ( isDefined( self.body ) )
	{
		return;
	}
	self.body = spawn( "script_model", self.origin );
	self.body.angles = self.angles;
	self.body setmodel( level.player_reigns_model );
	self.body useanimtree( -1 );
	self.body notsolid();
	self.body hide();
/#
	recordent( self.body );
#/
	wait 0,05;
	self.body.origin = self.origin;
	self.body.angles = self.angles;
	self.body linkto( self );
	self.body setup_body_funcs();
}

setup_body_funcs()
{
	self.update_idle_anim = ::player_idle_anim;
	self.update_reverse_anim = ::player_reverse_anim;
	self.update_turn_anim = ::player_turn_anim;
	self.update_run_anim = ::player_run_anim;
	self.update_transition_anim = ::player_transition;
	self.update_stop_anim = ::player_stop;
	self.update_rearback_anim = ::player_rearback;
	self.update_turn180_anim = ::player_turn180;
}

player_idle_anim( idle_struct, anim_index )
{
	idle_anim = idle_struct.player_animations[ anim_index ];
	self setanimknoballrestart( idle_anim, %root, 1, 0,2, 1 );
}

player_reverse_anim( anim_rate )
{
	self setanimknoball( level.horse_player_anims[ level.reverse ], %root, 1, 0,2, anim_rate );
}

player_turn_anim( anim_rate, anim_index )
{
	self setanimknoball( level.horse_player_anims[ level.idle ][ anim_index ], %root, 1, 0,2, anim_rate );
}

player_run_anim( anim_rate, horse )
{
	sprint_index = 0;
	if ( horse.current_anim_speed == level.sprint && is_true( horse.is_boosting ) )
	{
		sprint_index = 3;
	}
	self setanimknoball( level.horse_player_anims[ horse.current_anim_speed ][ sprint_index ], %root, 1, 0,2, anim_rate );
}

player_rearback( horse )
{
	self endon( "death" );
	self endon( "stop_player_ride" );
	player = get_players()[ 0 ];
	player freezecontrols( 1 );
	self.pause_animation = 1;
	horse.dismount_enabled = 0;
	self thread follow_horse_angles( horse );
	rearback_anim = level.horse_player_anims[ level.rearback ];
	self setanimknoballrestart( rearback_anim, %root, 1, 0,2, 1 );
	len = getanimlength( rearback_anim );
	wait len;
	self notify( "stop_follow" );
	self.curranimation = undefined;
	self.pause_animation = 0;
	player freezecontrols( 0 );
}

player_turn180( horse )
{
	player = get_players()[ 0 ];
	player freezecontrols( 1 );
	self.pause_animation = 1;
	horse.dismount_enabled = 0;
	self thread follow_horse_angles( horse );
	turn180_anim = level.horse_player_anims[ level.turn_180 ];
	self setanimknoballrestart( turn180_anim, %root, 1, 0,2, 1 );
	len = getanimlength( turn180_anim );
	wait len;
	self notify( "stop_follow" );
	self.curranimation = undefined;
	self.pause_animation = 0;
	player freezecontrols( 0 );
}

follow_horse_angles( horse )
{
	horse useby( horse.driver );
	horse makevehicleunusable();
	horse.driver playerlinktoabsolute( horse.driver.body, "tag_player" );
	self waittill( "stop_follow" );
	horse.driver unlink();
	horse makevehicleusable();
	horse useby( horse.driver );
	if ( is_true( horse.disable_make_useable ) )
	{
		horse makevehicleunusable();
	}
	wait_network_frame();
	horse.dismount_enabled = 1;
}

player_play_anim( animname )
{
	self endon( "death" );
	self endon( "stop_player_ride" );
	self setanimknoball( animname, %root, 1, 0,2, 1 );
	wait getanimlength( animname );
}

player_stop()
{
	self endon( "death" );
	self endon( "stop_player_ride" );
	self.pause_animation = 1;
	player_play_anim( %int_horse_player_short_stop_init );
	player_play_anim( %int_horse_player_short_stop_finish );
	self.curranimation = undefined;
	self.pause_animation = 0;
}

player_transition( start, speed )
{
	self endon( "death" );
	self endon( "stop_player_ride" );
	self.pause_animation = 1;
	if ( is_true( start ) )
	{
		self player_play_anim( %int_horse_player_idle_to_walk );
	}
	else if ( speed == level.trot )
	{
		self player_play_anim( %int_horse_player_trot_to_idle );
	}
	else if ( speed == level.run )
	{
		self player_play_anim( %int_horse_player_canter_to_idle );
	}
	else if ( speed == level.sprint )
	{
		self player_play_anim( %int_horse_player_sprint_to_idle );
	}
	else
	{
		self player_play_anim( %int_horse_player_walk_to_idle );
	}
	self.curranimation = undefined;
	self.pause_animation = 0;
}
