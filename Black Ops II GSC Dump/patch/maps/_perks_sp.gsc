#include maps/_perks_sp;
#include maps/_utility;
#include common_scripts/utility;

perk_init( ref )
{
	_a11 = getplayers();
	_k11 = getFirstArrayKey( _a11 );
	while ( isDefined( _k11 ) )
	{
		player = _a11[ _k11 ];
		perk = spawnstruct();
		perk.ref = ref;
		player.perk_refs[ player.perk_refs.size ] = perk;
		_k11 = getNextArrayKey( _a11, _k11 );
	}
}

cac_get_dvar_int( dvar, def )
{
	return int( cac_get_dvar( dvar, def ) );
}

cac_get_dvar( dvar, def )
{
	if ( getDvar( dvar ) != "" )
	{
		return getDvarFloat( dvar );
	}
	else
	{
		setdvar( dvar, def );
		return def;
	}
}

initperkdvars()
{
	level.cac_armorpiercing_data = cac_get_dvar_int( "perk_armorpiercing", "40" ) / 100;
	level.cac_bulletdamage_data = cac_get_dvar_int( "perk_bulletDamage", "35" );
	level.cac_fireproof_data = cac_get_dvar_int( "perk_fireproof", "95" );
	level.cac_armorvest_data = cac_get_dvar_int( "perk_armorVest", "80" );
	level.cac_explosivedamage_data = cac_get_dvar_int( "perk_explosiveDamage", "25" );
	level.cac_flakjacket_data = cac_get_dvar_int( "perk_flakJacket", "35" );
	level.cac_flakjacket_hardcore_data = cac_get_dvar_int( "perk_flakJacket_hardcore", "9" );
}

perks_init( usehud )
{
	if ( isDefined( level.sp_perks_initialized ) )
	{
		return;
	}
	level.sp_perks_initialized = 1;
	level.armorpiercing_data = 0,4;
	level.bulletdamage_data = 1,35;
	level.armorvest_data = 0,8;
	level.explosivedamage_data = 25;
	level.flakjacket_data = 35;
	level.blink_warning = 5000;
	level.icon_fullbright_alpha = 0,85;
	level.icon_halfbright_alpha = 0,2;
	if ( !isDefined( level.player_perk_slots ) )
	{
		level.player_perk_slots = 3;
	}
	_a71 = getplayers();
	_k71 = getFirstArrayKey( _a71 );
	while ( isDefined( _k71 ) )
	{
		player = _a71[ _k71 ];
		player.perk_slots = [];
		player.perk_refs = [];
		i = 0;
		while ( i < level.player_perk_slots )
		{
			player.perk_slots[ i ] = spawnstruct();
			player.perk_slots[ i ].ref = "";
			player.perk_slots[ i ].expire = -1;
			i++;
		}
		player thread maps/_perks_sp::perk_hud();
		pos_x = 200 - ( level.player_perk_slots * 28 );
		i = 0;
		while ( i < level.player_perk_slots )
		{
			player.perk_slots[ i ].pos_x = pos_x;
			player.perk_slots[ i ].pos_y = 186;
			player.perk_slots[ i ].icon_size = 28;
			player.perk_slots[ i ].icon = undefined;
			pos_x += 30;
			i++;
		}
		_k71 = getNextArrayKey( _a71, _k71 );
	}
	perk_init( "specialty_brutestrength" );
	perk_init( "specialty_intruder" );
	perk_init( "specialty_trespasser" );
	perk_init( "specialty_longersprint" );
	perk_init( "specialty_unlimitedsprint" );
	perk_init( "specialty_endurance" );
	perk_init( "specialty_flakjacket" );
	perk_init( "specialty_deadshot" );
	perk_init( "specialty_fastads" );
	perk_init( "specialty_rof" );
	perk_init( "specialty_fastreload" );
	perk_init( "specialty_fastweaponswitch" );
	perk_init( "specialty_fastmeleerecovery" );
	perk_init( "specialty_bulletdamage" );
	perk_init( "specialty_armorvest" );
	perk_init( "specialty_detectexplosive" );
	perk_init( "specialty_holdbreath" );
}

find_perk( ref )
{
	_a125 = self.perk_refs;
	_k125 = getFirstArrayKey( _a125 );
	while ( isDefined( _k125 ) )
	{
		perk = _a125[ _k125 ];
		if ( perk.ref == ref )
		{
			return perk;
		}
		_k125 = getNextArrayKey( _a125, _k125 );
	}
	return undefined;
}

find_free_slot()
{
	i = 0;
	while ( i < level.player_perk_slots )
	{
		if ( self.perk_slots[ i ].ref == "" )
		{
			return i;
		}
		i++;
	}
	return undefined;
}

find_slot_by_ref( ref )
{
/#
	assert( isDefined( ref ), "Invalid perk ref passed into find_slot_by_ref" + ref );
#/
	i = 0;
	while ( i < level.player_perk_slots )
	{
		if ( self.perk_slots[ i ].ref == ref )
		{
			return i;
		}
		i++;
	}
	return undefined;
}

has_perk( ref )
{
	return isDefined( find_slot_by_ref( ref ) );
}

give_perk( give_ref )
{
	perk = self find_perk( give_ref );
/#
	assert( isDefined( perk ), "Undefined/unsupported perk. " + give_ref );
#/
	if ( has_perk( give_ref ) )
	{
		return 1;
	}
	if ( !isDefined( self find_free_slot() ) )
	{
		return 0;
	}
	slot = self find_free_slot();
/#
	assert( isDefined( slot ) );
#/
	self.perk_slots[ slot ].ref = give_ref;
	self.perk_slots[ slot ].expire = -1;
	self setperk( give_ref );
	self notify( "give_perk" );
	self notify( "perk_update" );
	return 1;
}

give_perk_for_a_time( give_ref, timeinsec )
{
	if ( self give_perk( give_ref ) )
	{
		slot = find_slot_by_ref( give_ref );
		self.perk_slots[ slot ].expire = getTime() + ( timeinsec * 1000 );
		self thread perk_expire_watcher();
	}
}

perk_expire_watcher()
{
	self endon( "death" );
	self notify( "perk_watcher" );
	self endon( "perk_watcher" );
	done = 0;
	while ( !done )
	{
		done = 1;
		i = 0;
		while ( i < level.player_perk_slots )
		{
			if ( self.perk_slots[ i ].expire != -1 )
			{
				current_time = getTime();
				done = 0;
				if ( current_time > self.perk_slots[ i ].expire )
				{
					take_perk_by_slot( i );
				}
			}
			i++;
		}
		wait 1;
	}
}

take_perk( take_ref )
{
/#
	assert( isDefined( self find_perk( take_ref ) ), "Undefined/unsupported perk." + take_ref );
#/
	if ( !has_perk( take_ref ) )
	{
		return;
	}
	slot = self find_slot_by_ref( take_ref );
	self.perk_slots[ slot ].ref = "";
	self.perk_slots[ slot ].expire = -1;
	self unsetperk( take_ref );
	self notify( "take_perk" );
	self notify( "perk_update" );
	wait 0,05;
}

take_perk_by_slot( slot )
{
	if ( self.perk_slots[ slot ].ref != "" )
	{
		take_perk( self.perk_slots[ slot ].ref );
	}
}

take_all_perks()
{
	_a259 = self.perk_refs;
	_k259 = getFirstArrayKey( _a259 );
	while ( isDefined( _k259 ) )
	{
		perk = _a259[ _k259 ];
		self unsetperk( perk.ref );
		_k259 = getNextArrayKey( _a259, _k259 );
	}
	i = 0;
	while ( i < level.player_perk_slots )
	{
		take_perk_by_slot( i );
		i++;
	}
}

show_perks()
{
}

hide_perks()
{
}

update_on_give_perk()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "give_perk", ref );
		self flag_set( "HUD_giving_perk" );
		while ( self flag( "HUD_taking_perk" ) )
		{
			wait 0,05;
		}
		wait 1;
		self flag_clear( "HUD_giving_perk" );
	}
}

update_on_take_perk()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "take_perk", ref );
		self flag_set( "HUD_taking_perk" );
		while ( self flag( "HUD_giving_perk" ) )
		{
			wait 0,05;
		}
		wait 1;
		self flag_clear( "HUD_taking_perk" );
	}
}

perk_hud()
{
	self endon( "death" );
	self flag_init( "HUD_giving_perk" );
	self flag_init( "HUD_taking_perk" );
	self thread update_on_give_perk();
	self thread update_on_take_perk();
	while ( 1 )
	{
		self waittill( "perk_update", ref );
		slot = self find_slot_by_ref( ref );
		if ( isDefined( slot ) )
		{
			break;
		}
	}
}
