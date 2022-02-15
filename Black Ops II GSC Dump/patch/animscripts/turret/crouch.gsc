
#using_animtree( "generic_human" );

main()
{
	self.desired_anim_pose = "crouch";
	self.a.movement = "stop";
	self thread animscripts/turret/turret::main();
}

end_script()
{
}
