#include animscripts/ai_subclass/anims_table_elite;
#include animscripts/utility;
#include animscripts/combat_utility;
#include common_scripts/utility;
#include maps/_utility;

subclass_elite()
{
	if ( self.type != "human" )
	{
		return;
	}
	if ( self animscripts/utility::aihasonlypistol() )
	{
		return;
	}
	enable_elite();
}

enable_elite()
{
	if ( self.subclass != "elite" )
	{
		self.subclass = "elite";
	}
	self.a.disablewoundedset = 1;
	self.a.userifleanimsforsmg = 1;
	self.elite = 1;
	self animscripts/ai_subclass/anims_table_elite::setup_elite_anim_array();
}

disable_elite()
{
/#
	assert( is_true( self.elite ) );
#/
	self.subclass = "regular";
	self animscripts/ai_subclass/anims_table_elite::reset_self_elite_anim_array();
}
