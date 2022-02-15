
#using_animtree( "generic_human" );

main()
{
	self.desired_anim_pose = "prone";
	self.a.movement = "stop";
	self thread animscripts/turret/turret::main();
}

end_script()
{
}
