#include animscripts/run;
#include animscripts/shared;
#include animscripts/utility;
#include animscripts/anims;
#include animscripts/traverse/shared;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	if ( self.type == "human" )
	{
		step_up_human();
	}
	else
	{
		if ( self.isdog )
		{
			dog_jump_up( 40, 3 );
		}
	}
}

step_up_human()
{
	preparefortraverse();
	self.desired_anim_pose = "crouch";
	animscripts/utility::updateanimpose();
	self endon( "killanimscript" );
	self.a.movement = "walk";
	self traversemode( "nogravity" );
	startnode = self getnegotiationstartnode();
/#
	assert( isDefined( startnode ) );
#/
	self orientmode( "face angle", startnode.angles[ 1 ] );
	self setflaggedanimknoballrestart( "stepanim", animarray( "step_up", "move" ), %body, 1, 0,1, 1 );
	self waittillmatch( "stepanim" );
	return "gravity on";
	self traversemode( "gravity" );
	self animscripts/shared::donotetracks( "stepanim" );
	self setanimknoballrestart( animscripts/run::getcrouchrunanim(), %body, 1, 0,1, 1 );
}
