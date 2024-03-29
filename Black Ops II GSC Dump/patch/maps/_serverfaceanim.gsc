#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "generic_human" );

null_ai_face_anims_func()
{
	anims = %faces;
	anims = %f_idle_casual_v1;
	anims = %f_idle_casual_v2;
	anims = %f_idle_casual_v3;
	anims = %f_idle_alert_v1;
	anims = %f_idle_alert_v2;
	anims = %f_idle_alert_v3;
	anims = %f_idle_alert_v4;
	anims = %f_idle_alert_v6;
	anims = %f_idle_alert_v8;
	anims = %f_idle_alert_v9;
	anims = %f_idle_alert_v10;
	anims = %f_firing_v2;
	anims = %f_firing_v3;
	anims = %f_firing_v7;
	anims = %f_firing_v8;
	anims = %f_firing_v9;
	anims = %f_firing_v10;
	anims = %f_firing_v11;
	anims = %f_firing_v12;
	anims = %f_firing_v13;
	anims = %f_firing_v14;
	anims = %f_im_reloading;
	anims = %f_melee_v1;
	anims = %f_melee_v2;
	anims = %f_melee_v3;
	anims = %f_melee_v4;
	anims = %f_melee_v5;
	anims = %f_melee_v6;
	anims = %f_melee_v7;
	anims = %f_melee_v8;
	anims = %f_pain_v1;
	anims = %f_pain_v2;
	anims = %f_pain_v4;
	anims = %f_pain_v5;
	anims = %f_pain_v6;
	anims = %f_pain_v7;
	anims = %f_death_v1;
	anims = %f_death_v2;
	anims = %f_death_v3;
	anims = %f_death_v4;
	anims = %f_death_v5;
	anims = %f_death_v6;
	anims = %f_death_v7;
	anims = %f_death_v8;
	anims = %f_react_v3;
	anims = %f_react_v4;
	anims = %f_react_v6;
	anims = %f_running_v1;
	anims = %f_running_v2;
}

init_serverfaceanim()
{
	self addaieventlistener( "grenade danger" );
	self addaieventlistener( "bulletwhizby" );
	self addaieventlistener( "projectile_impact" );
	self.do_face_anims = 1;
	if ( !isDefined( level.face_event_handler ) )
	{
		level.face_event_handler = spawnstruct();
		level.face_event_handler.events = [];
		level.face_event_handler.events[ "death" ] = "face_death";
		level.face_event_handler.events[ "grenade danger" ] = "face_alert";
		level.face_event_handler.events[ "bulletwhizby" ] = "face_alert";
		level.face_event_handler.events[ "projectile_impact" ] = "face_alert";
		level.face_event_handler.events[ "explode" ] = "face_alert";
		level.face_event_handler.events[ "alert" ] = "face_alert";
		level.face_event_handler.events[ "shoot" ] = "face_shoot_single";
		level.face_event_handler.events[ "melee" ] = "face_melee";
		level.face_event_handler.events[ "damage" ] = "face_pain";
		level.face_event_handler.forced = [];
		level.face_event_handler.forced[ "death" ] = 1;
		level thread wait_for_face_event();
	}
}

wait_for_face_event()
{
	while ( 1 )
	{
		level waittill( "face", face_notify, ent );
		if ( isDefined( ent ) && isDefined( ent.do_face_anims ) && ent.do_face_anims )
		{
			if ( isDefined( level.face_event_handler.events[ face_notify ] ) )
			{
				forced = 0;
				if ( isDefined( level.face_event_handler.forced[ face_notify ] ) )
				{
					forced = level.face_event_handler.forced[ face_notify ];
				}
				ent sendfaceevent( level.face_event_handler.events[ face_notify ], forced );
			}
		}
	}
}
