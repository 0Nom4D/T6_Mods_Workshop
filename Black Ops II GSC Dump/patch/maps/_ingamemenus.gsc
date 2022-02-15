#include maps/_cooplogic;
#include maps/_utility;

init()
{
	level.xenon = getDvar( #"E0DDE627" ) == "true";
	level.consolegame = getDvar( #"D1AF4972" ) == "true";
	precachemenu( "loadout_splitscreen" );
	precachemenu( "ObjectiveInfoMenu" );
	precachemenu( "InGamePopupMenu" );
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onmenuresponse();
	}
}

onmenuresponse()
{
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( menu == "loadout_splitscreen" )
		{
			self closemenu();
			self closeingamemenu();
			self [[ level.loadout ]]( response );
			continue;
		}
		else if ( response == "endround" )
		{
			if ( !level.gameended )
			{
				level thread maps/_cooplogic::forceend();
			}
			else
			{
				self closemenu();
				self closeingamemenu();
			}
			continue;
		}
		else
		{
			if ( response == "close_all_ingame_menus" )
			{
				self closeingamemenu();
			}
		}
	}
}
