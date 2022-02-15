#include maps/_vehicle;

#using_animtree( "vehicles" );
#using_animtree( "generic_human" );

main()
{
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::unload_groups );
}

set_vehicle_anims( positions )
{
	positions[ 0 ].sittag = "tag_guy0";
	positions[ 1 ].sittag = "tag_guy1";
	positions[ 2 ].sittag = "tag_guy2";
	positions[ 3 ].sittag = "tag_guy3";
	positions[ 4 ].sittag = "tag_guy4";
	positions[ 5 ].sittag = "tag_guy5";
	positions[ 0 ].vehicle_getoutanim_clear = 0;
	positions[ 1 ].vehicle_getoutanim_clear = 0;
	positions[ 2 ].vehicle_getoutanim_clear = 0;
	positions[ 3 ].vehicle_getoutanim_clear = 0;
	positions[ 4 ].vehicle_getoutanim_clear = 0;
	positions[ 5 ].vehicle_getoutanim_clear = 0;
	positions[ 0 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 1 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 2 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 3 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 4 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 5 ].vehicle_getoutanim = %v_crew_m113_hatch_open;
	positions[ 6 ].vehicle_idle = %v_m113_gun_aim;
	positions[ 6 ].vehicle_aimup = %v_m113_gun_aim_up;
	positions[ 6 ].vehicle_aimdown = %v_m113_gun_aim_down;
	positions[ 6 ].vehicle_fire = %v_m113_gun_fire;
	positions[ 6 ].vehicle_fireup = %v_m113_gun_fire_up;
	positions[ 6 ].vehicle_firedown = %v_m113_gun_fire_down;
	return positions;
}

setanims()
{
	positions = [];
	i = 0;
	while ( i < 8 )
	{
		positions[ i ] = spawnstruct();
		i++;
	}
	positions[ 0 ].sittag = "tag_guy0";
	positions[ 1 ].sittag = "tag_guy1";
	positions[ 2 ].sittag = "tag_guy2";
	positions[ 3 ].sittag = "tag_guy3";
	positions[ 4 ].sittag = "tag_guy4";
	positions[ 5 ].sittag = "tag_guy5";
	positions[ 0 ].idle = %ai_crew_m113_guy0_idle;
	positions[ 1 ].idle = %ai_crew_m113_guy1_idle;
	positions[ 2 ].idle = %ai_crew_m113_guy2_idle;
	positions[ 3 ].idle = %ai_crew_m113_guy3_idle;
	positions[ 4 ].idle = %ai_crew_m113_guy4_idle;
	positions[ 5 ].idle = %ai_crew_m113_guy5_idle;
	positions[ 0 ].getout = %ai_crew_m113_guy0_exit;
	positions[ 1 ].getout = %ai_crew_m113_guy1_exit;
	positions[ 2 ].getout = %ai_crew_m113_guy2_exit;
	positions[ 3 ].getout = %ai_crew_m113_guy3_exit;
	positions[ 4 ].getout = %ai_crew_m113_guy4_exit;
	positions[ 5 ].getout = %ai_crew_m113_guy5_exit;
	positions[ 6 ].sittag = "tag_gunner4";
	positions[ 6 ].vehiclegunner = 4;
	positions[ 6 ].idle = %ai_m113_gunner_aim;
	positions[ 6 ].aimup = %ai_m113_gunner_aim_up;
	positions[ 6 ].aimdown = %ai_m113_gunner_aim_down;
	positions[ 6 ].death = %ai_crew_m113_gunner_death;
	positions[ 6 ].fire = %ai_m113_gunner_fire;
	positions[ 6 ].fireup = %ai_m113_gunner_fire_up;
	positions[ 6 ].firedown = %ai_m113_gunner_fire_down;
	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "all" ] = [];
	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ "default" ] = unload_groups[ "all" ];
	return unload_groups;
}
