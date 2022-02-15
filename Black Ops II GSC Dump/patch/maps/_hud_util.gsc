#include common_scripts/utility;
#include animscripts/utility;
#include maps/_utility;

setparent( element )
{
	if ( isDefined( self.parent ) && self.parent == element )
	{
		return;
	}
	if ( isDefined( self.parent ) )
	{
		self.parent removechild( self );
	}
	self.parent = element;
	self.parent addchild( self );
	if ( isDefined( self.point ) )
	{
		self setpoint( self.point, self.relativepoint, self.xoffset, self.yoffset );
	}
	else
	{
		self setpoint( "TOPLEFT" );
	}
}

getparent()
{
	return self.parent;
}

addchild( element )
{
	element.index = self.children.size;
	self.children[ self.children.size ] = element;
}

removechild( element )
{
	element.parent = undefined;
	if ( self.children[ self.children.size - 1 ] != element )
	{
		self.children[ element.index ] = self.children[ self.children.size - 1 ];
		self.children[ element.index ].index = element.index;
	}
	element.index = undefined;
}

setpoint( point, relativepoint, xoffset, yoffset, movetime )
{
	if ( !isDefined( movetime ) )
	{
		movetime = 0;
	}
	element = self getparent();
	if ( movetime )
	{
		self moveovertime( movetime );
	}
	if ( !isDefined( xoffset ) )
	{
		xoffset = 0;
	}
	self.xoffset = xoffset;
	if ( !isDefined( yoffset ) )
	{
		yoffset = 0;
	}
	self.yoffset = yoffset;
	self.point = point;
	self.alignx = "center";
	self.aligny = "middle";
	if ( issubstr( point, "TOP" ) )
	{
		self.aligny = "top";
	}
	if ( issubstr( point, "BOTTOM" ) )
	{
		self.aligny = "bottom";
	}
	if ( issubstr( point, "LEFT" ) )
	{
		self.alignx = "left";
	}
	if ( issubstr( point, "RIGHT" ) )
	{
		self.alignx = "right";
	}
	if ( !isDefined( relativepoint ) )
	{
		relativepoint = point;
	}
	self.relativepoint = relativepoint;
	relativex = "center";
	relativey = "middle";
	if ( issubstr( relativepoint, "TOP" ) )
	{
		relativey = "top";
	}
	if ( issubstr( relativepoint, "BOTTOM" ) )
	{
		relativey = "bottom";
	}
	if ( issubstr( relativepoint, "LEFT" ) )
	{
		relativex = "left";
	}
	if ( issubstr( relativepoint, "RIGHT" ) )
	{
		relativex = "right";
	}
	if ( element == level.uiparent )
	{
		self.horzalign = relativex;
		self.vertalign = relativey;
	}
	else
	{
		self.horzalign = element.horzalign;
		self.vertalign = element.vertalign;
	}
	if ( relativex == element.alignx )
	{
		offsetx = 0;
		xfactor = 0;
	}
	else if ( relativex == "center" || element.alignx == "center" )
	{
		offsetx = int( element.width / 2 );
		if ( relativex == "left" || element.alignx == "right" )
		{
			xfactor = -1;
		}
		else
		{
			xfactor = 1;
		}
	}
	else
	{
		offsetx = element.width;
		if ( relativex == "left" )
		{
			xfactor = -1;
		}
		else
		{
			xfactor = 1;
		}
	}
	self.x = element.x + ( offsetx * xfactor );
	if ( relativey == element.aligny )
	{
		offsety = 0;
		yfactor = 0;
	}
	else if ( relativey == "middle" || element.aligny == "middle" )
	{
		offsety = int( element.height / 2 );
		if ( relativey == "top" || element.aligny == "bottom" )
		{
			yfactor = -1;
		}
		else
		{
			yfactor = 1;
		}
	}
	else
	{
		offsety = element.height;
		if ( relativey == "top" )
		{
			yfactor = -1;
		}
		else
		{
			yfactor = 1;
		}
	}
	self.y = element.y + ( offsety * yfactor );
	self.x += self.xoffset;
	self.y += self.yoffset;
	switch( self.elemtype )
	{
		case "bar":
			setpointbar( point, relativepoint );
			break;
	}
	self updatechildren();
}

setpointbar( point, relativepoint )
{
	self.bar.horzalign = self.horzalign;
	self.bar.vertalign = self.vertalign;
	self.bar.alignx = "left";
	self.bar.aligny = self.aligny;
	self.bar.y = self.y;
	if ( self.alignx == "left" )
	{
		self.bar.x = self.x;
	}
	else if ( self.alignx == "right" )
	{
		self.bar.x = self.x - self.width;
	}
	else
	{
		self.bar.x = self.x - int( self.width / 2 );
	}
	if ( self.aligny == "top" )
	{
		self.bar.y = self.y;
	}
	else
	{
		if ( self.aligny == "bottom" )
		{
			self.bar.y = self.y;
		}
	}
	self updatebar( self.bar.frac );
}

updatebar( barfrac, rateofchange )
{
	if ( self.elemtype == "bar" )
	{
		updatebarscale( barfrac, rateofchange );
	}
}

updatebarscale( barfrac, rateofchange )
{
	barwidth = int( ( self.width * barfrac ) + 0,5 );
	if ( !barwidth )
	{
		barwidth = 1;
	}
	self.bar.frac = barfrac;
	self.bar setshader( self.bar.shader, barwidth, self.height );
/#
	assert( barwidth <= self.width, "barWidth <= self.width: " + barwidth + " <= " + self.width + " - barFrac was " + barfrac );
#/
	if ( isDefined( rateofchange ) && barwidth < self.width )
	{
		if ( rateofchange > 0 )
		{
/#
			assert( ( ( 1 - barfrac ) / rateofchange ) > 0, "barFrac: " + barfrac + "rateOfChange: " + rateofchange );
#/
			self.bar scaleovertime( ( 1 - barfrac ) / rateofchange, self.width, self.height );
		}
		else
		{
			if ( rateofchange < 0 )
			{
/#
				assert( ( barfrac / ( -1 * rateofchange ) ) > 0, "barFrac: " + barfrac + "rateOfChange: " + rateofchange );
#/
				self.bar scaleovertime( barfrac / ( -1 * rateofchange ), 1, self.height );
			}
		}
	}
	self.bar.rateofchange = rateofchange;
	self.bar.lastupdatetime = getTime();
}

createfontstring( font, fontscale, player )
{
	if ( isDefined( player ) )
	{
		fontelem = newclienthudelem( player );
	}
	else
	{
		fontelem = newhudelem();
	}
	fontelem.elemtype = "font";
	fontelem.font = font;
	fontelem.fontscale = fontscale;
	fontelem.x = 0;
	fontelem.y = 0;
	fontelem.sort = 100;
	fontelem.width = 0;
	fontelem.height = int( level.fontheight * fontscale );
	fontelem.xoffset = 0;
	fontelem.yoffset = 0;
	fontelem.children = [];
	fontelem setparent( level.uiparent );
	fontelem.hidden = 0;
	return fontelem;
}

createserverfontstring( font, fontscale )
{
	fontelem = newhudelem();
	fontelem.elemtype = "font";
	fontelem.font = font;
	fontelem.fontscale = fontscale;
	fontelem.x = 0;
	fontelem.y = 0;
	fontelem.width = 0;
	fontelem.height = int( level.fontheight * fontscale );
	fontelem.xoffset = 0;
	fontelem.yoffset = 0;
	fontelem.children = [];
	fontelem setparent( level.uiparent );
	return fontelem;
}

createservertimer( font, fontscale )
{
	timerelem = newhudelem();
	timerelem.elemtype = "timer";
	timerelem.font = font;
	timerelem.fontscale = fontscale;
	timerelem.x = 0;
	timerelem.y = 0;
	timerelem.width = 0;
	timerelem.height = int( level.fontheight * fontscale );
	timerelem.xoffset = 0;
	timerelem.yoffset = 0;
	timerelem.children = [];
	timerelem setparent( level.uiparent );
	return timerelem;
}

createicon( shader, width, height, player )
{
	if ( isDefined( player ) )
	{
		iconelem = newclienthudelem( player );
	}
	else
	{
		iconelem = newhudelem();
	}
	iconelem.elemtype = "icon";
	iconelem.x = 0;
	iconelem.y = 0;
	iconelem.width = width;
	iconelem.height = height;
	iconelem.xoffset = 0;
	iconelem.yoffset = 0;
	iconelem.children = [];
	iconelem setparent( level.uiparent );
	if ( isDefined( shader ) )
	{
		iconelem setshader( shader, width, height );
	}
	return iconelem;
}

createbar( color, width, height, flashfrac )
{
	barelem = newclienthudelem( self );
	barelem.x = 0;
	barelem.y = 0;
	barelem.frac = 0;
	barelem.color = color;
	barelem.sort = -2;
	barelem.shader = "white";
	barelem setshader( "white", width, height );
	barelem.hidden = 0;
	if ( isDefined( flashfrac ) )
	{
		barelem.flashfrac = flashfrac;
	}
	barelemframe = newclienthudelem( self );
	barelemframe.elemtype = "icon";
	barelemframe.x = 0;
	barelemframe.y = 0;
	barelemframe.width = width;
	barelemframe.height = height;
	barelemframe.xoffset = 0;
	barelemframe.yoffset = 0;
	barelemframe.bar = barelem;
	barelemframe.barframe = barelemframe;
	barelemframe.children = [];
	barelemframe.sort = -1;
	barelemframe.color = ( 1, 1, 1 );
	barelemframe setparent( level.uiparent );
	barelemframe.hidden = 0;
	barelembg = newclienthudelem( self );
	barelembg.elemtype = "bar";
	if ( !level.splitscreen )
	{
		barelembg.x = -2;
		barelembg.y = -2;
	}
	barelembg.width = width;
	barelembg.height = height;
	barelembg.xoffset = 0;
	barelembg.yoffset = 0;
	barelembg.bar = barelem;
	barelembg.barframe = barelemframe;
	barelembg.children = [];
	barelembg.sort = -3;
	barelembg.color = ( 1, 1, 1 );
	barelembg.alpha = 0,5;
	barelembg setparent( level.uiparent );
	if ( !level.splitscreen )
	{
		barelembg setshader( "black", width + 4, height + 4 );
	}
	else
	{
		barelembg setshader( "black", width + 0, height + 0 );
	}
	barelembg.hidden = 0;
	return barelembg;
}

createprimaryprogressbar()
{
	bar = createbar( ( 1, 1, 1 ), level.primaryprogressbarwidth, level.primaryprogressbarheight );
	if ( level.splitscreen )
	{
		bar setpoint( "TOP", undefined, level.primaryprogressbarx, level.primaryprogressbary );
	}
	else
	{
		bar setpoint( "CENTER", undefined, level.primaryprogressbarx, level.primaryprogressbary );
	}
	return bar;
}

createprimaryprogressbartext()
{
	text = createfontstring( "objective", level.primaryprogressbarfontsize, self );
	if ( level.splitscreen )
	{
		text setpoint( "TOP", undefined, level.primaryprogressbartextx, level.primaryprogressbartexty );
	}
	else
	{
		text setpoint( "CENTER", undefined, level.primaryprogressbartextx, level.primaryprogressbartexty );
	}
	text.sort = -1;
	return text;
}

hideelem()
{
	if ( !isDefined( self.hidden ) )
	{
		self.hidden = 0;
	}
	if ( self.hidden )
	{
		return;
	}
	self.hidden = 1;
	self.oldalpha = self.alpha;
	self.alpha = 0;
	if ( isDefined( self.elemtype ) || self.elemtype == "bar" && self.elemtype == "bar_shader" )
	{
		self.bar.hidden = 1;
		self.bar.alpha = 0;
		self.barframe.hidden = 1;
		self.barframe.alpha = 0;
	}
}

showelem()
{
	if ( !isDefined( self.hidden ) )
	{
		self.hidden = 0;
	}
	if ( !self.hidden )
	{
		return;
	}
	self.hidden = 0;
	if ( isDefined( self.elemtype ) || self.elemtype == "bar" && self.elemtype == "bar_shader" )
	{
		if ( self.alpha != 0,5 )
		{
			self.alpha = 0,5;
		}
		self.bar.hidden = 0;
		if ( self.bar.alpha != 1 )
		{
			self.bar.alpha = 1;
		}
		self.barframe.hidden = 0;
		if ( self.barframe.alpha != 1 )
		{
			self.barframe.alpha = 1;
		}
	}
	else
	{
		self.alpha = self.oldalpha;
	}
}

flashthread()
{
	self endon( "death" );
	self.alpha = 1;
	while ( 1 )
	{
		if ( self.frac >= self.flashfrac )
		{
			self fadeovertime( 0,3 );
			self.alpha = 0,2;
			wait 0,35;
			self fadeovertime( 0,3 );
			self.alpha = 1;
			wait 0,7;
			continue;
		}
		else
		{
			self.alpha = 1;
			wait 0,05;
		}
	}
}

destroyelem()
{
	tempchildren = [];
	while ( isDefined( self.children ) )
	{
		index = 0;
		while ( index < self.children.size )
		{
			tempchildren[ index ] = self.children[ index ];
			index++;
		}
	}
	index = 0;
	while ( index < tempchildren.size )
	{
		tempchildren[ index ] setparent( self getparent() );
		index++;
	}
	if ( isDefined( self.elemtype ) && self.elemtype == "bar" )
	{
		self.bar destroy();
		self.barframe destroy();
	}
	self destroy();
}

seticonshader( shader )
{
	self setshader( shader, self.width, self.height );
}

updatechildren()
{
	index = 0;
	while ( index < self.children.size )
	{
		child = self.children[ index ];
		child setpoint( child.point, child.relativepoint, child.xoffset, child.yoffset );
		index++;
	}
}

get_countdown_hud( x )
{
	xpos = undefined;
	if ( !isDefined( x ) )
	{
		xpos = -225;
	}
	else
	{
		xpos = x;
	}
	hudelem = newhudelem();
	hudelem.alignx = "left";
	hudelem.aligny = "middle";
	hudelem.horzalign = "right";
	hudelem.vertalign = "top";
	hudelem.x = xpos;
	hudelem.y = 100;
	hudelem.fontscale = 1,6;
	hudelem.color = ( 0,8, 1, 0,8 );
	hudelem.font = "objective";
	hudelem.glowcolor = ( 0,3, 0,6, 0,3 );
	hudelem.glowalpha = 1;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = 1;
	return hudelem;
}

fade_over_time( target_alpha, fade_time )
{
/#
	assert( isDefined( target_alpha ), "fade_over_time must be passed a target_alpha." );
#/
	if ( isDefined( fade_time ) && fade_time > 0 )
	{
		self fadeovertime( fade_time );
	}
	self.alpha = target_alpha;
	if ( isDefined( fade_time ) && fade_time > 0 )
	{
		wait fade_time;
	}
}

destroyhudelem( hudelem )
{
	if ( isDefined( hudelem ) )
	{
		hudelem destroyelem();
	}
}

fadetoblackforxsec( startwait, blackscreenwait, fadeintime, fadeouttime )
{
	wait startwait;
	if ( !isDefined( self.blackscreen ) )
	{
		self.blackscreen = newclienthudelem( self );
	}
	self.blackscreen.x = 0;
	self.blackscreen.y = 0;
	self.blackscreen.horzalign = "fullscreen";
	self.blackscreen.vertalign = "fullscreen";
	self.blackscreen.foreground = 0;
	self.blackscreen.hidewhendead = 0;
	self.blackscreen.hidewheninmenu = 1;
	self.blackscreen.sort = 50;
	self.blackscreen setshader( "black", 640, 480 );
	self.blackscreen.alpha = 0;
	if ( fadeintime > 0 )
	{
		self.blackscreen fadeovertime( fadeintime );
	}
	self.blackscreen.alpha = 1;
	wait fadeintime;
	if ( !isDefined( self.blackscreen ) )
	{
		return;
	}
	wait blackscreenwait;
	if ( !isDefined( self.blackscreen ) )
	{
		return;
	}
	if ( fadeouttime > 0 )
	{
		self.blackscreen fadeovertime( fadeouttime );
	}
	self.blackscreen.alpha = 0;
	wait fadeouttime;
	if ( isDefined( self.blackscreen ) )
	{
		self.blackscreen destroy();
		self.blackscreen = undefined;
	}
}
