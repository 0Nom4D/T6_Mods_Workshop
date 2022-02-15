#include animscripts/shared;
#include animscripts/combat_utility;

#using_animtree( "dog" );

main()
{
	self endon( "killanimscript" );
	self endon( "stop_flashbang_effect" );
	wait randomfloatrange( 0, 0,4 );
	self clearanim( %root, 0,1 );
	duration = self startflashbanged() * 0,001;
	if ( duration > 2 && randomint( 100 ) > 60 )
	{
		self setflaggedanimrestart( "flashed_anim", %german_shepherd_run_pain, 1, 0,2, self.animplaybackrate * 0,75 );
	}
	else
	{
		self setflaggedanimrestart( "flashed_anim", %german_shepherd_run_flashbang, 1, 0,2, self.animplaybackrate );
	}
	animlength = getanimlength( %german_shepherd_run_flashbang ) * self.animplaybackrate;
	if ( duration < animlength )
	{
		self animscripts/shared::donotetracksfortime( duration, "flashed_anim" );
	}
	else
	{
		self animscripts/shared::donotetracks( "flashed_anim" );
	}
	self setflashbanged( 0 );
	self.flashed = 0;
	self notify( "stop_flashbang_effect" );
}

end_script()
{
}
