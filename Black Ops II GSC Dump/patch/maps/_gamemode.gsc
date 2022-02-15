
shouldsaveonstartup()
{
	gt = getDvar( "g_gametype" );
	switch( gt )
	{
		case "vs":
			return 0;
		default:
		}
		return 1;
	}
}
