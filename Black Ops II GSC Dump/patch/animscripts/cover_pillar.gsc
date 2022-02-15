#include animscripts/cover_corner;
#include animscripts/anims;
#include animscripts/utility;
#include animscripts/combat_utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	self.hideyawoffset = 180;
	scriptname = "cover_pillar";
	usingpistol = usingpistol();
	if ( usingpistol )
	{
		if ( self.node has_spawnflag( 1024 ) )
		{
			self.hideyawoffset = -90;
			scriptname = "cover_right";
		}
		else
		{
			self.hideyawoffset = 90;
			scriptname = "cover_left";
		}
	}
	self trackscriptstate( "Cover Pillar Main", "code" );
	self endon( "killanimscript" );
	animscripts/utility::initialize( scriptname );
	if ( self.node has_spawnflag( 1024 ) )
	{
		if ( usingpistol )
		{
			animscripts/cover_corner::corner_think( "left", -90 );
		}
		else
		{
			animscripts/cover_corner::corner_think( "left", 180 );
		}
	}
	else if ( usingpistol )
	{
		animscripts/cover_corner::corner_think( "right", 90 );
	}
	else
	{
		animscripts/cover_corner::corner_think( "right", 180 );
	}
}

end_script()
{
}
