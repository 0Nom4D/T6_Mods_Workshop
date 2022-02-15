
main()
{
	self setmodel( "c_mul_redcross_doctor_body_blk" );
	self.headmodel = "c_mul_redcross_doctor_head2";
	self attach( self.headmodel, "", 1 );
	self.voice = "american";
	self.skeleton = "base";
}

precache()
{
	precachemodel( "c_mul_redcross_doctor_body_blk" );
	precachemodel( "c_mul_redcross_doctor_head2" );
}
