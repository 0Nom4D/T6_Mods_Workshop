#include animscripts/run;
#include animscripts/shared;
#include animscripts/utility;
#include animscripts/anims;
#include animscripts/traverse/shared;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	preparefortraverse();
	traverseanim = animarray( "window_climb_start", "move" );
	landanim = animarray( "window_climb_end", "move" );
	self.desired_anim_pose = "crouch";
	animscripts/utility::updateanimpose();
	self.old_anim_movement = self.a.movement;
	self endon( "killanimscript" );
	self traversemode( "noclip" );
	startnode = self getnegotiationstartnode();
/#
	assert( isDefined( startnode ) );
#/
	self orientmode( "face angle", startnode.angles[ 1 ] );
	realheight = startnode.traverse_height - startnode.origin[ 2 ];
	self setflaggedanimknoballrestart( "traverse", traverseanim, %body, 1, 0,15, 1 );
	thread animscripts/shared::donotetracksforever( "traverse", "stop_traverse_notetracks" );
	wait 1,5;
	angles = ( 0, startnode.angles[ 1 ], 0 );
	forward = anglesToForward( angles );
	forward = vectorScale( forward, 85 );
	trace = bullettrace( startnode.origin + forward, startnode.origin + forward + vectorScale( ( 1, 1, 1 ), 500 ), 0, undefined );
	endheight = trace[ "position" ][ 2 ];
	finaldif = startnode.origin[ 2 ] - endheight;
	heightchange = 0;
	i = 0;
	while ( i < level.window_down_height.size )
	{
		if ( finaldif < level.window_down_height[ i ] )
		{
			i++;
			continue;
		}
		else
		{
			heightchange = finaldif - level.window_down_height[ i ];
		}
		i++;
	}
/#
	assert( heightchange > 0, "window_jump at " + startnode.origin + " is too high off the ground" );
#/
	self thread teleportthread( heightchange * -1 );
	oldheight = self.origin[ 2 ];
	change = 0;
	level.traversefall = [];
	for ( ;; )
	{
		change = oldheight - self.origin[ 2 ];
		if ( ( self.origin[ 2 ] - change ) < endheight )
		{
			break;
		}
		else
		{
			oldheight = self.origin[ 2 ];
			wait 0,05;
		}
	}
	if ( isDefined( self.groundtype ) )
	{
		self playsound( "Land_" + self.groundtype );
	}
	self notify( "stop_traverse_notetracks" );
	self setflaggedanimknoballrestart( "traverse", landanim, %body, 1, 0,15, 1 );
	self traversemode( "gravity" );
	self animscripts/shared::donotetracks( "traverse" );
	self.a.movement = self.old_anim_movement;
	self setanimknoballrestart( animscripts/run::getrunanim(), %body, 1, 0,2, 1 );
}

printer( org )
{
	level notify( "print_this_" + org );
	level endon( "print_this_" + org );
	for ( ;; )
	{
/#
		print3d( org, ".", ( 1, 1, 1 ), 5 );
#/
		wait 0,05;
	}
}

showline( start, end )
{
	for ( ;; )
	{
/#
		line( start, end + ( 1, 1, 1 ), ( 1, 1, 1 ) );
#/
		wait 0,05;
	}
}

printerdebugger( msg, org )
{
	level notify( "prrint_this_" + org );
	level endon( "prrint_this_" + org );
	for ( ;; )
	{
/#
		print3d( org, msg, ( 1, 1, 1 ), 5 );
#/
		wait 0,05;
	}
}
