#include maps/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_scripted_fx();
	precache_fxanim_props();
	precache_createfx_fx();
	maps/createfx/so_rts_mp_overflow_fx::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_rts_exp_vtol_crash01" ] = loadfx( "explosions/fx_rts_exp_vtol_crash01" );
	level._effect[ "fx_rts_vtol_overflow_dust_kickup" ] = loadfx( "vehicle/treadfx/fx_rts_vtol_overflow_dust_kickup" );
	level._effect[ "fx_rts_bloodpool_zhao" ] = loadfx( "blood/fx_rts_bloodpool_zhao" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_light_flour_glow_cool_sngl_shrt" ] = loadfx( "light/fx_light_flour_glow_cool_sngl_shrt" );
	level._effect[ "fx_light_lantern_dec_red" ] = loadfx( "light/fx_light_lantern_dec_red" );
	level._effect[ "fx_light_com_utility_cool" ] = loadfx( "light/fx_light_com_utility_cool" );
	level._effect[ "fx_light_floodlight_sqr_cool" ] = loadfx( "light/fx_light_floodlight_sqr_cool_sm" );
	level._effect[ "fx_mp_sun_flare_overflow" ] = loadfx( "lens_flares/fx_lf_mp_overflow_sun1" );
	level._effect[ "fx_mp_water_drip_light_long" ] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
	level._effect[ "fx_mp_water_drip_light_shrt" ] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_shrt" );
	level._effect[ "fx_water_river_muddy_slw_lg" ] = loadfx( "water/fx_water_river_muddy_slw_lg" );
	level._effect[ "fx_insects_roaches_short" ] = loadfx( "bio/insects/fx_insects_roaches_short" );
	level._effect[ "fx_insects_swarm_md_light" ] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_debris_papers_narrow" ] = loadfx( "env/debris/fx_debris_papers_narrow" );
	level._effect[ "fx_smk_smolder_black_slow" ] = loadfx( "smoke/fx_smk_smolder_black_slow" );
	level._effect[ "fx_smk_tin_hat_sm" ] = loadfx( "smoke/fx_smk_tin_hat_sm" );
	level._effect[ "fx_mp_smk_plume_lg_blk_distant" ] = loadfx( "maps/mp_maps/fx_mp_smk_plume_md_blk_distant_wispy" );
	level._effect[ "fx_mp_smk_plume_md_blk_distant" ] = loadfx( "maps/mp_maps/fx_mp_smk_plume_sm_blk_distant_wispy" );
	level._effect[ "fx_fire_fuel_sm" ] = loadfx( "fire/fx_fire_fuel_sm" );
	level._effect[ "fx_fire_sm" ] = loadfx( "env/fire/fx_fire_sm" );
	level._effect[ "fx_fire_detail" ] = loadfx( "env/fire/fx_fire_detail_sm_nodlight" );
	level._effect[ "fx_fog_street_md_area" ] = loadfx( "fog/fx_fog_street_md_area" );
	level._effect[ "fx_fog_street_sm_area" ] = loadfx( "fog/fx_fog_street_sm_area" );
	level._effect[ "fx_mp_elec_spark_burst_sm" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_sm" );
	level._effect[ "fx_mp_elec_spark_burst_sm_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_sm_runner" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
	level._effect[ "fx_mp_elec_spark_burst_md" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_md" );
	level._effect[ "fx_mp_elec_spark_burst_md_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_md_runner" );
	level._effect[ "fx_mp_elec_spark_burst_lg" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_lg" );
	level._effect[ "fx_mp_elec_spark_burst_lg_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_lg_runner" );
	level._effect[ "fx_mp_elec_spark_pop_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_pop_runner" );
	level._effect[ "fx_mp_debris_car_floating_river" ] = loadfx( "maps/mp_maps/fx_mp_debris_car_floating_river" );
	level._effect[ "fx_mp_steam_gas_pipe_md" ] = loadfx( "maps/mp_maps/fx_mp_steam_gas_pipe_md" );
	level._effect[ "fx_mp_steam_pipe_md" ] = loadfx( "maps/mp_maps/fx_mp_steam_pipe_md" );
}

precache_fxanim_props()
{
}
