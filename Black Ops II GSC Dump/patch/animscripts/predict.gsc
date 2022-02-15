
start()
{
	self.codepredictcmd = [];
}

end()
{
	self.codepredictcmd = undefined;
}

addentry( entry )
{
	self.codepredictcmd[ self.codepredictcmd.size ] = entry;
	handler = entry[ "handler" ];
	[[ handler ]]( entry );
}

addentryplaybackonly( entry )
{
	self.codepredictcmd[ self.codepredictcmd.size ] = entry;
}

_setanim( animation, goalweight, goaltime, rate )
{
	entry[ "handler" ] = ::setanimh;
	entry[ "animation" ] = animation;
	entry[ "goalWeight" ] = goalweight;
	entry[ "goalTime" ] = goaltime;
	entry[ "rate" ] = rate;
	addentry( entry );
}

_setanimknoball( animation, root, goalweight, goaltime, rate )
{
	entry[ "handler" ] = ::setanimknoballh;
	entry[ "animation" ] = animation;
	entry[ "root" ] = root;
	entry[ "goalWeight" ] = goalweight;
	entry[ "goalTime" ] = goaltime;
	entry[ "rate" ] = rate;
	addentry( entry );
}

_setflaggedanimknoball( notifyname, animation, root, goalweight, goaltime, rate )
{
	entry[ "handler" ] = ::setflaggedanimknoballh;
	entry[ "notifyName" ] = notifyname;
	entry[ "animation" ] = animation;
	entry[ "root" ] = root;
	entry[ "goalWeight" ] = goalweight;
	entry[ "goalTime" ] = goaltime;
	entry[ "rate" ] = rate;
	addentry( entry );
}

setanimh( entry )
{
	self setanim( entry[ "animation" ], entry[ "goalWeight" ], entry[ "goalTime" ], entry[ "rate" ] );
}

setanimknoballh( entry )
{
	self setanimknoball( entry[ "animation" ], entry[ "root" ], entry[ "goalWeight" ], entry[ "goalTime" ], entry[ "rate" ] );
}

setflaggedanimknoballh( entry )
{
	self setflaggedanimknoball( entry[ "notifyName" ], entry[ "animation" ], entry[ "root" ], entry[ "goalWeight" ], entry[ "goalTime" ], entry[ "rate" ] );
}

stumblewall( maxtime )
{
	maxframes = maxtime / 0,05;
	i = 0;
	while ( i < maxframes )
	{
		self predictanim( 0 );
		self predictoriginandangles();
		entry[ "handler" ] = ::moveh;
		entry[ "origin" ] = self.origin;
		entry[ "angles" ] = self.angles;
		addentryplaybackonly( entry );
		switch( self gethitenttype() )
		{
			case "world":
				self orientmode( "face angle", self gethityaw() );
				return 1;
			case "obstacle":
				return 0;
		}
		i++;
	}
	return 0;
}

tumblewall( notifyname )
{
	for ( ;; )
	{
		thread getnotetrack( notifyname );
		bpredictmore = self predictanim( 1 );
		self notify( notifyname );
		self waittill( "predictGetNotetrack", notetrack );
		if ( isDefined( notetrack ) )
		{
			if ( notetrack == "end" )
			{
				return 1;
			}
		}
		if ( !bpredictmore )
		{
			break;
		}
		else
		{
		}
	}
	self predictoriginandangles();
	if ( self isdeflected() )
	{
		return 0;
	}
	entry[ "handler" ] = ::moveh;
	entry[ "origin" ] = self.origin;
	entry[ "angles" ] = self.angles;
	addentryplaybackonly( entry );
}
return 0;
}

getnotetrack( notifyname )
{
	self waittill( notifyname, notetrack );
	self notify( "predictGetNotetrack" );
}

moveh( entry )
{
	self predictanim( 0 );
	self lerpposition( entry[ "origin" ], entry[ "angles" ] );
	wait 0,05;
}

playback()
{
	self animmode( "nophysics" );
	count = self.codepredictcmd.size;
	i = 0;
	while ( i < count )
	{
		entry = self.codepredictcmd[ i ];
		handler = entry[ "handler" ];
		[[ handler ]]( entry );
		i++;
	}
	self animmode( "none" );
}
