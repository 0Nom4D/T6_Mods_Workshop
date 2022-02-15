#include maps/_utility;
#include common_scripts/utility;

init()
{
/#
	thread equipment_dev_gui();
	thread perk_dev_gui();
	thread testdvars();
#/
}

testdvars()
{
/#
	wait 5;
	for ( ;; )
	{
		if ( getDvar( "scr_testdvar" ) != "" )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	tokens = strtok( getDvar( "scr_testdvar" ), " " );
	dvarname = tokens[ 0 ];
	dvarvalue = tokens[ 1 ];
	setdvar( dvarname, dvarvalue );
	setdvar( "scr_testdvar", "" );
	thread testdvars();
#/
}

equipment_dev_gui()
{
/#
	equipment = [];
	equipment[ 1 ] = "satchel_charge_sp";
	setdvar( "scr_give_equipment", "" );
	while ( 1 )
	{
		wait 0,5;
		devgui_int = getDvarInt( "scr_give_equipment" );
		if ( devgui_int != 0 )
		{
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				players[ i ] takeweapon( equipment[ devgui_int ] );
				players[ i ] giveweapon( equipment[ devgui_int ] );
				players[ i ] setactionslot( 1, "weapon", equipment[ devgui_int ] );
				i++;
			}
			setdvar( "scr_give_equipment", "0" );
		}
#/
	}
}

perk_dev_gui()
{
/#
	setdvar( "scr_give_perk", "" );
	while ( 1 )
	{
		wait 0,5;
		if ( getDvar( "scr_giveperk" ) != "" )
		{
			players = get_players();
			i = 0;
			while ( i < players.size )
			{
				players[ i ] setperk( getDvar( "scr_giveperk" ) );
				i++;
			}
			setdvar( "scr_giveperk", "" );
		}
#/
	}
}
