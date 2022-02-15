#include maps/afghanistan_arena_manager;
#include maps/_utility;
#include common_scripts/utility;

main()
{
	maps/afghanistan::main();
}

setup_skiptos()
{
	add_skipto( "intro", ::maps/afghanistan_intro::skipto_intro, "Intro", ::maps/afghanistan_intro::main );
	add_skipto( "horse_intro", ::maps/afghanistan_horse_intro::skipto_intro, "Horse Intro", ::maps/afghanistan_horse_intro::main );
	add_skipto( "rebel_base_intro", ::maps/afghanistan_intro_rebel_base::skipto_intro, "rebel base intro", ::maps/afghanistan_intro_rebel_base::main );
	add_skipto( "firehorse", ::maps/afghanistan_firehorse::skipto_firehorse, "Fire Horse", ::maps/afghanistan_firehorse::main );
	add_skipto( "wave_1", ::maps/afghanistan_wave_1::skipto_wave1, "Wave 1", ::maps/afghanistan_wave_1::main );
	add_skipto( "arena_sandbox", ::maps/afghanistan_wave_2::skipto_wave2, "Wave 2", ::maps/afghanistan_wave_2::main );
	add_skipto( "horse_charge", ::maps/afghanistan_horse_charge::skipto_horse_charge, "Horse Charge", ::maps/afghanistan_horse_charge::main );
	add_skipto( "krav_tank", ::maps/afghanistan_horse_charge::skipto_krav_tank, "Krav Tank", ::maps/afghanistan_horse_charge::after_button_mash_scene );
	add_skipto( "krav_captured", ::maps/afghanistan_krav_captured::skipto_krav_captured, "Krav Captured", ::maps/afghanistan_krav_captured::main );
	add_skipto( "interrogation", ::maps/afghanistan_krav_captured::skipto_krav_interrogation, "Krav Captured", ::maps/afghanistan_krav_captured::interrogation );
	add_skipto( "beat_down", ::maps/afghanistan_krav_captured::skipto_beat_down, "Beatdown", ::maps/afghanistan_krav_captured::beatdown );
	add_skipto( "deserted", ::maps/afghanistan_deserted::skipto_deserted, "Deserted", ::maps/afghanistan_deserted::main );
	add_skipto( "dev_arena", ::maps/afghanistan_arena_manager::skipto_arena, "DEV ARENA" );
	default_skipto( "intro" );
}
