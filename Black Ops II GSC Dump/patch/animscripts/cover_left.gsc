#include animscripts/cover_corner;
#include animscripts/anims;
#include animscripts/utility;
#include animscripts/combat_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	self.hideyawoffset = 90;
	self trackscriptstate( "Cover Left Main", "code" );
	self endon( "killanimscript" );
	animscripts/utility::initialize( "cover_left" );
	animscripts/cover_corner::corner_think( "left", 90 );
}

end_script()
{
	animscripts/cover_corner::end_script_corner();
	animscripts/cover_behavior::end_script();
}
