#include maps/_vehicle;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
	self.script_badplace = 0;
	if ( issubstr( self.vehicletype, "_land" ) )
	{
		init_dropoffset();
		build_aianims( ::setanims_land, ::set_vehicle_anims );
		build_unload_groups( ::unload_groups_land );
	}
	else
	{
		init_fastrope();
		build_aianims( ::setanims, ::set_vehicle_anims );
		build_attach_models( ::set_attached_models );
		build_unload_groups( ::unload_groups );
	}
}

set_vehicle_anims( positions )
{
	positions[ 2 ].vehicle_getoutanim = %v_mi8_hip_hover_idle;
	positions[ 2 ].vehicle_getoutanim_clear = 0;
	positions[ 3 ].vehicle_getoutanim = %v_mi8_hip_backdoor_open;
	positions[ 3 ].vehicle_getoutanim_clear = 0;
	positions[ 1 ].delay = getanimlength( %v_mi8_hip_backdoor_open ) - 1,7;
	positions[ 2 ].delay = getanimlength( %v_mi8_hip_backdoor_open ) - 1,7;
	positions[ 3 ].delay = getanimlength( %v_mi8_hip_backdoor_open ) - 1,7;
	positions[ 4 ].delay = getanimlength( %v_mi8_hip_backdoor_open ) - 1,7;
	return positions;
}

init_fastrope()
{
	self.fastropeoffset = 866;
}

init_dropoffset()
{
	self.dropoffset = 155;
}

setanims()
{
	positions = [];
	i = 0;
	while ( i <= 5 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	positions[ 0 ].bhasgunwhileriding = 0;
	positions[ 1 ].bhasgunwhileriding = 0;
	positions[ 0 ].idle[ 0 ] = %ai_crew_mi8_hip_pilot1_idle;
	positions[ 0 ].idle[ 1 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_clickpanel;
	positions[ 0 ].idle[ 2 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_lookback;
	positions[ 0 ].idle[ 3 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_lookoutside;
	positions[ 0 ].idleoccurrence[ 0 ] = 500;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].idleoccurrence[ 3 ] = 100;
	positions[ 1 ].idle[ 0 ] = %ai_crew_mi8_hip_pilot2_idle;
	positions[ 1 ].idle[ 1 ] = %ai_crew_mi8_hip_pilot2_idle_twitch_clickpanel;
	positions[ 1 ].idle[ 2 ] = %ai_crew_mi8_hip_pilot2_idle_twitch_lookoutside;
	positions[ 1 ].idleoccurrence[ 0 ] = 450;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].sittag = "tag_passenger";
	positions[ 1 ].sittag = "tag_driver";
	positions[ 2 ].sittag = "tag_detach";
	positions[ 3 ].sittag = "tag_detach";
	positions[ 4 ].sittag = "tag_detach";
	positions[ 5 ].sittag = "tag_detach";
	positions[ 2 ].idle = %ai_crew_mi8_hip_1_idle;
	positions[ 3 ].idle = %ai_crew_mi8_hip_2_idle;
	positions[ 4 ].idle = %ai_crew_mi8_hip_3_idle;
	positions[ 5 ].idle = %ai_crew_mi8_hip_4_idle;
	positions[ 2 ].getout = %ai_crew_mi8_hip_1_drop;
	positions[ 3 ].getout = %ai_crew_mi8_hip_2_drop;
	positions[ 4 ].getout = %ai_crew_mi8_hip_3_drop;
	positions[ 5 ].getout = %ai_crew_mi8_hip_4_drop;
	positions[ 2 ].getoutstance = "crouch";
	positions[ 3 ].getoutstance = "crouch";
	positions[ 4 ].getoutstance = "crouch";
	positions[ 5 ].getoutstance = "crouch";
	positions[ 2 ].ragdoll_getout_death = 1;
	positions[ 3 ].ragdoll_getout_death = 1;
	positions[ 4 ].ragdoll_getout_death = 1;
	positions[ 5 ].ragdoll_getout_death = 1;
	positions[ 2 ].getoutrig = "rope_test_ri";
	positions[ 3 ].getoutrig = "rope_test_ri";
	positions[ 4 ].getoutrig = "rope_test_ri";
	positions[ 5 ].getoutrig = "rope_test_ri";
	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "back" ] = [];
	unload_groups[ "front" ] = [];
	unload_groups[ "both" ] = [];
	unload_groups[ "back" ][ unload_groups[ "back" ].size ] = 2;
	unload_groups[ "back" ][ unload_groups[ "back" ].size ] = 3;
	unload_groups[ "back" ][ unload_groups[ "back" ].size ] = 4;
	unload_groups[ "back" ][ unload_groups[ "back" ].size ] = 5;
	unload_groups[ "default" ] = unload_groups[ "back" ];
	return unload_groups;
}

set_attached_models()
{
	array = [];
	array[ "rope_test_ri" ] = spawnstruct();
	array[ "rope_test_ri" ].model = "rope_test_ri";
	array[ "rope_test_ri" ].tag = "TAG_FastRope_RI";
	array[ "rope_test_ri" ].idleanim = %o_mi8_hip_rope_idle_ri;
	array[ "rope_test_ri" ].dropanim = %o_mi8_hip_rope_drop_ri;
	return array;
}

precache_extra_models()
{
	precachemodel( "rope_test_ri" );
}

setanims_land()
{
	positions = [];
	positions = [];
	i = 0;
	while ( i <= 5 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	positions[ 0 ].bhasgunwhileriding = 0;
	positions[ 1 ].bhasgunwhileriding = 0;
	positions[ 0 ].idle[ 0 ] = %ai_crew_mi8_hip_pilot1_idle;
	positions[ 0 ].idle[ 1 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_clickpanel;
	positions[ 0 ].idle[ 2 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_lookback;
	positions[ 0 ].idle[ 3 ] = %ai_crew_mi8_hip_pilot1_idle_twitch_lookoutside;
	positions[ 0 ].idleoccurrence[ 0 ] = 500;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].idleoccurrence[ 3 ] = 100;
	positions[ 1 ].idle[ 0 ] = %ai_crew_mi8_hip_pilot2_idle;
	positions[ 1 ].idle[ 1 ] = %ai_crew_mi8_hip_pilot2_idle_twitch_clickpanel;
	positions[ 1 ].idle[ 2 ] = %ai_crew_mi8_hip_pilot2_idle_twitch_lookoutside;
	positions[ 1 ].idleoccurrence[ 0 ] = 450;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].idleoccurrence[ 2 ] = 100;
	positions[ 0 ].sittag = "tag_passenger";
	positions[ 1 ].sittag = "tag_driver";
	positions[ 2 ].sittag = "tag_detach";
	positions[ 3 ].sittag = "tag_detach";
	positions[ 4 ].sittag = "tag_detach";
	positions[ 5 ].sittag = "tag_detach";
	positions[ 2 ].idle = %ai_crew_mi8_hip_unload_1_idle;
	positions[ 3 ].idle = %ai_crew_mi8_hip_unload_2_idle;
	positions[ 4 ].idle = %ai_crew_mi8_hip_unload_3_idle;
	positions[ 5 ].idle = %ai_crew_mi8_hip_unload_4_idle;
	positions[ 2 ].getout = %ai_crew_mi8_hip_unload_1;
	positions[ 3 ].getout = %ai_crew_mi8_hip_unload_2;
	positions[ 4 ].getout = %ai_crew_mi8_hip_unload_3;
	positions[ 5 ].getout = %ai_crew_mi8_hip_unload_4;
	positions[ 2 ].getoutstance = "crouch";
	positions[ 3 ].getoutstance = "crouch";
	positions[ 4 ].getoutstance = "crouch";
	positions[ 5 ].getoutstance = "crouch";
	return positions;
}

unload_groups_land()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	group = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ "default" ] = unload_groups[ group ];
	return unload_groups;
}
