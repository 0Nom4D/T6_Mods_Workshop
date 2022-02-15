#include animscripts/cover_wall;
#include common_scripts/utility;
#include animscripts/utility;
#include animscripts/combat_utility;

#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	if ( weaponisgasweapon( self.weapon ) )
	{
		self animscripts/stop::main();
		return;
	}
	[[ self.exception[ "cover_stand" ] ]]();
	self trackscriptstate( "Cover Stand Main", "code" );
	animscripts/utility::initialize( "cover_stand" );
	self thread animscripts/utility::idlelookatbehavior( 160, 1 );
	self animscripts/cover_wall::cover_wall_think( "stand" );
}

end_script()
{
	animscripts/cover_behavior::end_script();
}
