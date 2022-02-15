#include animscripts/anims;
#include animscripts/anims_table;
#include maps/_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

setup_self_elite_anim_array()
{
/#
	assert( self.subclass == "elite" );
#/
	self animscripts/anims::clearanimcache();
	if ( !isDefined( self.anim_array ) )
	{
		self.anim_array = [];
	}
	self.anim_array[ self.animtype ][ "stop" ][ "stand" ][ "rifle" ][ "idle_trans_in" ] = %ai_elite_casual_stand_idle_trans_in;
	self.anim_array[ self.animtype ][ "stop" ][ "stand" ][ "rifle" ][ "idle" ] = array( array( %ai_elite_casual_stand_idle, %ai_elite_casual_stand_idle_twitch, %ai_elite_casual_stand_idle_twitchb ) );
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "exposed_idle" ] = array( %ai_elite_exposed_idle_alert_v1 );
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "idle_trans_out" ] = %ai_elite_casual_stand_idle_trans_out;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "fire" ] = %ai_elite_exposed_shoot_auto_v3;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "single" ] = array( %ai_elite_exposed_shoot_semi2 );
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "burst2" ] = %ai_elite_exposed_shoot_burst3;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "burst3" ] = %ai_elite_exposed_shoot_burst3;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "burst4" ] = %ai_elite_exposed_shoot_burst4;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "burst5" ] = %ai_elite_exposed_shoot_burst5;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "burst6" ] = %ai_elite_exposed_shoot_burst6;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "semi2" ] = %ai_elite_exposed_shoot_semi2;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "semi3" ] = %ai_elite_exposed_shoot_semi3;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "semi4" ] = %ai_elite_exposed_shoot_semi4;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "semi5" ] = %ai_elite_exposed_shoot_semi5;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "reload" ] = array( %ai_elite_exposed_reload );
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "reload_crouchhide" ] = array( %ai_elite_exposed_reload );
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_left_45" ] = %ai_elite_exposed_tracking_turn45l;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_left_90" ] = %ai_elite_exposed_tracking_turn90l;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_left_135" ] = %ai_elite_exposed_tracking_turn135l;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_left_180" ] = %ai_elite_exposed_tracking_turn180l;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_right_45" ] = %ai_elite_exposed_tracking_turn45r;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_right_90" ] = %ai_elite_exposed_tracking_turn90r;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_right_135" ] = %ai_elite_exposed_tracking_turn135r;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "turn_right_180" ] = %ai_elite_exposed_tracking_turn180r;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "straight_level" ] = %ai_elite_exposed_aim_5;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_aim_up" ] = %ai_elite_exposed_aim_8;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_aim_down" ] = %ai_elite_exposed_aim_2;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_aim_left" ] = %ai_elite_exposed_aim_4;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_aim_right" ] = %ai_elite_exposed_aim_6;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_turn_aim_up" ] = %ai_elite_exposed_aim_8;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_turn_aim_down" ] = %ai_elite_exposed_aim_2;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_turn_aim_left" ] = %ai_elite_exposed_aim_4;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "add_turn_aim_right" ] = %ai_elite_exposed_aim_6;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "crouch_2_stand" ] = %ai_elite_exposed_crouch_2_stand;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "stand_2_crouch" ] = %ai_elite_exposed_stand_2_crouch;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "grenade_throw" ] = %ai_elite_exposed_grenadethrow_a;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "grenade_throw_1" ] = %ai_elite_exposed_grenadethrow_a;
	self.anim_array[ self.animtype ][ "combat" ][ "stand" ][ "rifle" ][ "grenade_throw_2" ] = %ai_elite_exposed_grenadethrow_a;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "exposed_idle" ] = array( %ai_elite_exposed_crouch_idle_alert_v1 );
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "fire" ] = %ai_elite_exposed_crouch_shoot_auto_v2;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "single" ] = array( %ai_elite_exposed_crouch_shoot_semi2 );
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "burst2" ] = %ai_elite_exposed_crouch_shoot_burst3;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "burst3" ] = %ai_elite_exposed_crouch_shoot_burst3;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "burst4" ] = %ai_elite_exposed_crouch_shoot_burst4;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "burst5" ] = %ai_elite_exposed_crouch_shoot_burst5;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "burst6" ] = %ai_elite_exposed_crouch_shoot_burst6;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "semi2" ] = %ai_elite_exposed_crouch_shoot_semi2;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "semi3" ] = %ai_elite_exposed_crouch_shoot_semi3;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "semi4" ] = %ai_elite_exposed_crouch_shoot_semi4;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "semi5" ] = %ai_elite_exposed_crouch_shoot_semi5;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "reload" ] = array( %ai_elite_exposed_crouch_reload );
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_left_45" ] = %ai_elite_exposed_crouch_turn_l;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_left_90" ] = %ai_elite_exposed_crouch_turn_l;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_left_135" ] = %ai_elite_exposed_crouch_turn_l;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_left_180" ] = %ai_elite_exposed_crouch_turn_l;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_right_45" ] = %ai_elite_exposed_crouch_turn_r;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_right_90" ] = %ai_elite_exposed_crouch_turn_r;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_right_135" ] = %ai_elite_exposed_crouch_turn_r;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "turn_right_180" ] = %ai_elite_exposed_crouch_turn_r;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "straight_level" ] = %ai_elite_exposed_crouch_aim_5;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_aim_up" ] = %ai_elite_exposed_crouch_aim_8;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_aim_down" ] = %ai_elite_exposed_crouch_aim_2;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_aim_left" ] = %ai_elite_exposed_crouch_aim_4;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_aim_right" ] = %ai_elite_exposed_crouch_aim_6;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_turn_aim_up" ] = %ai_elite_exposed_crouch_aim_8;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_turn_aim_down" ] = %ai_elite_exposed_crouch_aim_2;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_turn_aim_left" ] = %ai_elite_exposed_crouch_aim_4;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "add_turn_aim_right" ] = %ai_elite_exposed_crouch_aim_6;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "crouch_2_stand" ] = %ai_elite_exposed_crouch_2_stand;
	self.anim_array[ self.animtype ][ "combat" ][ "crouch" ][ "rifle" ][ "stand_2_crouch" ] = %ai_elite_exposed_stand_2_crouch;
}

setup_elite_anim_array( subclasstype, array )
{
	if ( isai( self ) )
	{
/#
		assert( self.subclass == "elite" );
#/
		subclasstype = self.subclass;
		array = anim.anim_array;
		self animscripts/anims::clearanimcache();
		setup_self_elite_anim_array();
	}
	if ( !isDefined( subclasstype ) )
	{
		subclasstype = "elite";
	}
	if ( isDefined( array[ subclasstype ] ) )
	{
		return;
	}
	array[ subclasstype ] = [];
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "combat_run_f" ] = %ai_elite_run_lowready_f;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "sprint" ] = array( %ai_elite_sprint_f );
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 1 ] = %ai_elite_exposed_arrival_1;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 2 ] = %ai_elite_exposed_arrival_2;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 3 ] = %ai_elite_exposed_arrival_3;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 4 ] = %ai_elite_exposed_arrival_4;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 6 ] = %ai_elite_exposed_arrival_6;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 7 ] = %ai_elite_exposed_arrival_7;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 8 ] = %ai_elite_exposed_arrival_8;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed" ][ 9 ] = %ai_elite_exposed_arrival_9;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 1 ] = %ai_elite_exposed_crouch_arrival_1;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 2 ] = %ai_elite_exposed_crouch_arrival_2;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 3 ] = %ai_elite_exposed_crouch_arrival_3;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 4 ] = %ai_elite_exposed_crouch_arrival_4;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 6 ] = %ai_elite_exposed_crouch_arrival_6;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 7 ] = %ai_elite_exposed_crouch_arrival_7;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 8 ] = %ai_elite_exposed_crouch_arrival_8;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "arrive_exposed_crouch" ][ 9 ] = %ai_elite_exposed_crouch_arrival_9;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 1 ] = %ai_elite_exposed_exit_1;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 2 ] = %ai_elite_exposed_exit_2;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 3 ] = %ai_elite_exposed_exit_3;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 4 ] = %ai_elite_exposed_exit_4;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 6 ] = %ai_elite_exposed_exit_6;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 7 ] = %ai_elite_exposed_exit_7;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 8 ] = %ai_elite_exposed_exit_8;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed" ][ 9 ] = %ai_elite_exposed_exit_9;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 1 ] = %ai_elite_exposed_crouch_exit_1;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 2 ] = %ai_elite_exposed_crouch_exit_2;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 3 ] = %ai_elite_exposed_crouch_exit_3;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 4 ] = %ai_elite_exposed_crouch_exit_4;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 6 ] = %ai_elite_exposed_crouch_exit_6;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 7 ] = %ai_elite_exposed_crouch_exit_7;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 8 ] = %ai_elite_exposed_crouch_exit_8;
	array[ subclasstype ][ "move" ][ "stand" ][ "rifle" ][ "exit_exposed_crouch" ][ 9 ] = %ai_elite_exposed_crouch_exit_9;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "chest" ] = %ai_elite_exposed_pain_chest;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "groin" ] = %ai_elite_exposed_pain_groin;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "head" ] = %ai_elite_exposed_pain_groin;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "left_arm" ] = %ai_elite_exposed_pain_left_arm;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "right_arm" ] = %ai_elite_exposed_pain_right_arm;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "leg" ] = array( %ai_elite_exposed_pain_right_leg, %ai_elite_exposed_pain_left_leg );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "big" ] = %ai_elite_exposed_pain_groin;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "drop_gun" ] = %ai_elite_exposed_pain_groin;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "chest" ] = %ai_elite_exposed_crouch_pain_chest;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "head" ] = %ai_elite_exposed_crouch_pain_head;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "left_arm" ] = %ai_elite_exposed_crouch_pain_left_arm;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "right_arm" ] = %ai_elite_exposed_crouch_pain_right_arm;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "flinch" ] = %ai_elite_exposed_crouch_pain_groin;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_fire" ] = %ai_elite_cornerstndl_shoot_auto_v3;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_semi2" ] = %ai_elite_cornerstndl_shoot_semi2;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_semi3" ] = %ai_elite_cornerstndl_shoot_semi3;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_semi4" ] = %ai_elite_cornerstndl_shoot_semi4;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_semi5" ] = %ai_elite_cornerstndl_shoot_semi5;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_burst2" ] = %ai_elite_cornerstndl_shoot_burst3;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_burst3" ] = %ai_elite_cornerstndl_shoot_burst3;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_burst4" ] = %ai_elite_cornerstndl_shoot_burst4;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_burst5" ] = %ai_elite_cornerstndl_shoot_burst5;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_burst6" ] = %ai_elite_cornerstndl_shoot_burst6;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_single" ] = array( %ai_elite_cornerstndl_shoot_semi2 );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_aim_down" ] = %ai_elite_cornerstndl_lean_aim_2;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_aim_left" ] = %ai_elite_cornerstndl_lean_aim_4;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_aim_straight" ] = %ai_elite_cornerstndl_lean_aim_5;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_aim_right" ] = %ai_elite_cornerstndl_lean_aim_6;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_aim_up" ] = %ai_elite_cornerstndl_lean_aim_8;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_idle" ] = array( %ai_elite_cornerstndl_lean_idle );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "lean_to_alert" ] = array( %ai_elite_cornerstndl_lean_2_alert );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "alert_to_lean" ] = array( %ai_elite_cornerstndl_alert_2_lean );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_left_lean" ] = %ai_elite_cornerstndl_lean_pain;
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_cornerstndl_alert_2_a );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_cornerstndl_alert_2_b );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_cornerstndl_a_2_alert );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_cornerstndl_a_2_b );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_cornerstndl_b_2_alert );
	array[ subclasstype ][ "cover_left" ][ "stand" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_cornerstndl_b_2_a );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_left_A" ] = %ai_elite_cornerstndl_pain_a_2_alert;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_left_B" ] = %ai_elite_cornerstndl_pain_b_2_alert;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_fire" ] = %ai_elite_cornercl_shoot_auto_v2;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_semi2" ] = %ai_elite_cornercl_shoot_semi2;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_semi3" ] = %ai_elite_cornercl_shoot_semi3;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_semi4" ] = %ai_elite_cornercl_shoot_semi4;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_semi5" ] = %ai_elite_cornercl_shoot_semi5;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_burst2" ] = %ai_elite_cornercl_shoot_burst3;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_burst3" ] = %ai_elite_cornercl_shoot_burst3;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_burst4" ] = %ai_elite_cornercl_shoot_burst4;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_burst5" ] = %ai_elite_cornercl_shoot_burst5;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_burst6" ] = %ai_elite_cornercl_shoot_burst6;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_single" ] = array( %ai_elite_cornercl_shoot_semi1 );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_aim_down" ] = %ai_elite_cornercl_lean_aim_2;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_aim_left" ] = %ai_elite_cornercl_lean_aim_4;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_aim_straight" ] = %ai_elite_cornercl_lean_aim_5;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_aim_right" ] = %ai_elite_cornercl_lean_aim_6;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_aim_up" ] = %ai_elite_cornercl_lean_aim_8;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_idle" ] = array( %ai_elite_cornercl_lean_idle );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "lean_to_alert" ] = array( %ai_elite_cornercl_lean_2_alert );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "alert_to_lean" ] = array( %ai_elite_cornercl_alert_2_lean );
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_left_lean" ] = %ai_elite_cornercl_lean_pain;
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_cornercl_alert_2_a );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_cornercl_alert_2_b );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_cornercl_a_2_alert );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_cornercl_a_2_b );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_cornercl_b_2_alert );
	array[ subclasstype ][ "cover_left" ][ "crouch" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_cornercl_b_2_a );
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_left_A" ] = %ai_elite_cornercl_pain_a_2_alert;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_left_B" ] = %ai_elite_cornercl_pain_b_2_alert;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_fire" ] = %ai_elite_cornerstndr_shoot_auto_v3;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_semi2" ] = %ai_elite_cornerstndr_shoot_semi2;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_semi3" ] = %ai_elite_cornerstndr_shoot_semi3;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_semi4" ] = %ai_elite_cornerstndr_shoot_semi4;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_semi5" ] = %ai_elite_cornerstndr_shoot_semi5;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_burst2" ] = %ai_elite_cornerstndr_shoot_burst3;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_burst3" ] = %ai_elite_cornerstndr_shoot_burst3;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_burst4" ] = %ai_elite_cornerstndr_shoot_burst4;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_burst5" ] = %ai_elite_cornerstndr_shoot_burst5;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_burst6" ] = %ai_elite_cornerstndr_shoot_burst6;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_single" ] = array( %ai_elite_cornerstndr_shoot_semi2 );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_aim_down" ] = %ai_elite_cornerstndr_lean_aim_2;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_aim_left" ] = %ai_elite_cornerstndr_lean_aim_4;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_aim_straight" ] = %ai_elite_cornerstndr_lean_aim_5;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_aim_right" ] = %ai_elite_cornerstndr_lean_aim_6;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_aim_up" ] = %ai_elite_cornerstndr_lean_aim_8;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_idle" ] = array( %ai_elite_cornerstndr_lean_idle );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "lean_to_alert" ] = array( %ai_elite_cornerstndr_lean_2_alert );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "alert_to_lean" ] = array( %ai_elite_cornerstndr_alert_2_lean );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_right_lean" ] = %ai_elite_cornerstndr_lean_pain;
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_cornerstndr_alert_2_a );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_cornerstndr_alert_2_b );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_cornerstndr_a_2_alert );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_cornerstndr_a_2_b );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_cornerstndr_b_2_alert );
	array[ subclasstype ][ "cover_right" ][ "stand" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_cornerstndr_b_2_a );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_right_A" ] = %ai_elite_cornerstndr_pain_a_2_alert;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_right_B" ] = %ai_elite_cornerstndr_pain_b_2_alert;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_fire" ] = %ai_elite_cornercr_shoot_auto_v2;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_semi2" ] = %ai_elite_cornercr_shoot_semi2;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_semi3" ] = %ai_elite_cornercr_shoot_semi3;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_semi4" ] = %ai_elite_cornercr_shoot_semi4;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_semi5" ] = %ai_elite_cornercr_shoot_semi5;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_burst2" ] = %ai_elite_cornercr_shoot_burst3;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_burst3" ] = %ai_elite_cornercr_shoot_burst3;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_burst4" ] = %ai_elite_cornercr_shoot_burst4;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_burst5" ] = %ai_elite_cornercr_shoot_burst5;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_burst6" ] = %ai_elite_cornercr_shoot_burst6;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_single" ] = array( %ai_elite_cornercr_shoot_semi1 );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_aim_down" ] = %ai_elite_cornercr_lean_aim_2;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_aim_left" ] = %ai_elite_cornercr_lean_aim_4;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_aim_straight" ] = %ai_elite_cornercr_lean_aim_5;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_aim_right" ] = %ai_elite_cornercr_lean_aim_6;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_aim_up" ] = %ai_elite_cornercr_lean_aim_8;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_idle" ] = array( %ai_elite_cornercr_lean_idle );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "alert_to_lean" ] = array( %ai_elite_cornercr_alert_2_lean );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "lean_to_alert" ] = array( %ai_elite_cornercr_lean_2_alert );
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_right_lean" ] = %ai_elite_cornercr_lean_pain;
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_cornercr_alert_2_a );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_cornercr_alert_2_b );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_cornercr_a_2_alert );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_cornercr_a_2_b );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_cornercr_b_2_alert );
	array[ subclasstype ][ "cover_right" ][ "crouch" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_cornercr_b_2_a );
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_right_A" ] = %ai_elite_cornercr_pain_a_2_alert;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_right_B" ] = %ai_elite_cornercr_pain_b_2_alert;
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_pillar_stand_idle_2_a_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_pillar_stand_idle_2_b_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_pillar_stand_a_left_2_idle );
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_pillar_stand_a_left_2_b_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_pillar_stand_b_left_2_idle );
	array[ subclasstype ][ "cover_pillar_left" ][ "stand" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_pillar_stand_b_left_2_a_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_pillar_crouch_idle_2_a_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_pillar_crouch_idle_2_b_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_pillar_crouch_a_left_2_idle );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_pillar_crouch_a_left_2_b_left );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_pillar_crouch_b_left_2_idle );
	array[ subclasstype ][ "cover_pillar_left" ][ "crouch" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_pillar_crouch_b_left_2_a_left );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_pillar_stand_idle_2_a_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_pillar_stand_idle_2_b_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_pillar_stand_a_right_2_idle );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_pillar_stand_a_right_2_b_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_pillar_stand_b_right_2_idle );
	array[ subclasstype ][ "cover_pillar_right" ][ "stand" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_pillar_stand_b_right_2_a_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "alert_to_A" ] = array( %ai_elite_pillar_crouch_idle_2_a_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "alert_to_B" ] = array( %ai_elite_pillar_crouch_idle_2_b_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "A_to_alert" ] = array( %ai_elite_pillar_crouch_a_right_2_idle );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "A_to_B" ] = array( %ai_elite_pillar_crouch_a_right_2_b_right );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "B_to_alert" ] = array( %ai_elite_pillar_crouch_b_right_2_idle );
	array[ subclasstype ][ "cover_pillar_right" ][ "crouch" ][ "rifle" ][ "B_to_A" ] = array( %ai_elite_pillar_crouch_b_right_2_a_right );
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_pillar_left_A" ] = %ai_elite_pillar_stand_left_a_pain;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_pillar_left_B" ] = %ai_elite_pillar_stand_left_b_pain;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_pillar_right_A" ] = %ai_elite_pillar_stand_right_a_pain;
	array[ subclasstype ][ "pain" ][ "stand" ][ "rifle" ][ "cover_pillar_right_B" ] = %ai_elite_pillar_stand_right_b_pain;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_pillar_left_A" ] = %ai_elite_pillar_crouch_left_a_pain;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_pillar_left_B" ] = %ai_elite_pillar_crouch_left_b_pain;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_pillar_right_A" ] = %ai_elite_pillar_crouch_right_a_pain;
	array[ subclasstype ][ "pain" ][ "crouch" ][ "rifle" ][ "cover_pillar_right_B" ] = %ai_elite_pillar_crouch_right_b_pain;
	animscripts/anims_table::setup_delta_arrays( array, anim );
	if ( isai( self ) )
	{
		anim.anim_array = array;
	}
	return array;
}

reset_self_elite_anim_array()
{
/#
	if ( isDefined( self.elite ) )
	{
		assert( self.elite );
	}
#/
	self animscripts/anims::clearanimcache();
	if ( isDefined( self.anim_array ) && isDefined( self.anim_array[ self.animtype ] ) )
	{
	}
}
