#include animscripts/cover_wall;
#include common_scripts/utility;
#include animscripts/utility;
#include animscripts/combat_utility;

#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	[[ self.exception[ "cover_crouch" ] ]]();
	self trackscriptstate( "Cover Crouch Main", "code" );
	animscripts/utility::initialize( "cover_crouch" );
	self animscripts/cover_wall::cover_wall_think( "crouch" );
}

end_script()
{
	animscripts/cover_behavior::end_script();
}
