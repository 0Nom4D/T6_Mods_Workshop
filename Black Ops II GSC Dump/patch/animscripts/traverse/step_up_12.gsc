#include animscripts/traverse/shared;
#include common_scripts/utility;

#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	preparefortraverse();
	startnode = self getnegotiationstartnode();
/#
	assert( isDefined( startnode ) );
#/
	self orientmode( "face angle", startnode.angles[ 1 ] );
	realheight = startnode.traverse_height - startnode.origin[ 2 ];
	destination = realheight;
	offset = ( 0, 0, destination / 6 );
	self traversemode( "noclip" );
	i = 0;
	while ( i < 6 )
	{
		self teleport( self.origin + offset );
		wait 0,05;
		i++;
	}
	self traversemode( "gravity" );
}
