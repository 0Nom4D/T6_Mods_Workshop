#include animscripts/utility;

#using_animtree( "generic_human" );

main()
{
	self trackscriptstate( "Concealment Prone Main", "code" );
	self endon( "killanimscript" );
	animscripts/utility::initialize( "concealment_prone" );
	self animscripts/cover_prone::main();
}

end_script()
{
}
