#include common_scripts/utility;
#include maps/_utility;
#include maps/_vehicle;

main( model, type )
{
	init_audio_turret();
	self thread turret_sound_init();
}

init_audio_turret()
{
}

turret_sound_init()
{
	self.sound_org = spawn( "script_origin", self.origin );
	self.sound_org linkto( self );
	self.sound_org.soundalias = "wpn_gaz_quad50_turret_loop_npc";
	self.sound_org.flux = "wpn_gaz_quad50_flux_npc_l";
	self waittill( "death" );
	self.sound_org delete();
}
