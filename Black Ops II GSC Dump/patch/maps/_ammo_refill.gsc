#include maps/_utility;
#include common_scripts/utility;

main()
{
	a_ammo_crates = getentarray( "trigger_ammo_refill", "targetname" );
	array_thread( a_ammo_crates, ::_ammo_refill_think_old );
	thread place_player_loadout_old();
	a_ammo_crates = getentarray( "sys_ammo_cache", "targetname" );
	array_thread( a_ammo_crates, ::_setup_ammo_cache );
	a_weapon_crates = getentarray( "sys_weapon_cache", "targetname" );
	array_thread( a_weapon_crates, ::_setup_weapon_cache );
}

_ammo_refill_think_old()
{
	self sethintstring( &"SCRIPT_AMMO_REFILL" );
	self setcursorhint( "HINT_NOICON" );
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		e_player disableweapons();
		e_player playsound( "fly_ammo_crate_refill" );
		wait 2;
		a_str_weapons = e_player getweaponslist();
		_a66 = a_str_weapons;
		_k66 = getFirstArrayKey( _a66 );
		while ( isDefined( _k66 ) )
		{
			str_weapon = _a66[ _k66 ];
			if ( !_is_banned_refill_weapon( str_weapon ) )
			{
				e_player givemaxammo( str_weapon );
				e_player setweaponammoclip( str_weapon, weaponclipsize( str_weapon ) );
			}
			_k66 = getNextArrayKey( _a66, _k66 );
		}
		e_player enableweapons();
	}
}

place_player_loadout_old()
{
	str_primary_weapon = getloadoutweapon( "primary" );
	str_secondary_weapon = getloadoutweapon( "secondary" );
	primary_weapon_pos_array = getentarray( "ammo_refill_primary_weapon", "targetname" );
	_a85 = primary_weapon_pos_array;
	_k85 = getFirstArrayKey( _a85 );
	while ( isDefined( _k85 ) )
	{
		primary_pos = _a85[ _k85 ];
		if ( !issubstr( str_primary_weapon, "null" ) )
		{
			m_weapon_script_model = spawn( "weapon_" + str_primary_weapon, primary_pos.origin );
			m_weapon_script_model.angles = primary_pos.angles;
			level thread place_player_loadout_old_camo( m_weapon_script_model, "primarycamo" );
		}
		_k85 = getNextArrayKey( _a85, _k85 );
	}
	secondary_weapon_pos_array = getentarray( "ammo_refill_secondary_weapon", "targetname" );
	_a97 = secondary_weapon_pos_array;
	_k97 = getFirstArrayKey( _a97 );
	while ( isDefined( _k97 ) )
	{
		secondary_pos = _a97[ _k97 ];
		if ( !issubstr( str_primary_weapon, "null" ) )
		{
			m_weapon_script_model = spawn( "weapon_" + str_secondary_weapon, secondary_pos.origin );
			m_weapon_script_model.angles = secondary_pos.angles;
			level thread place_player_loadout_old_camo( m_weapon_script_model, "secondarycamo" );
		}
		_k97 = getNextArrayKey( _a97, _k97 );
	}
}

place_player_loadout_old_camo( m_weapon_script_model, camo_type )
{
	wait_for_first_player();
	if ( camo_type == "primarycamo" )
	{
		primarycamoindex = getloadoutitemindex( "primarycamo" );
		primaryweaponoptions = get_players()[ 0 ] calcweaponoptions( primarycamoindex );
		m_weapon_script_model itemweaponsetoptions( primaryweaponoptions );
	}
	else
	{
		if ( camo_type == "secondarycamo" )
		{
			secondarycamoindex = getloadoutitemindex( "secondarycamo" );
			secondaryweaponoptions = get_players()[ 0 ] calcweaponoptions( secondarycamoindex );
			m_weapon_script_model itemweaponsetoptions( secondaryweaponoptions );
		}
	}
}

_setup_ammo_cache()
{
	waittill_asset_loaded( "xmodel", self.model );
	self ignorecheapentityflag( 1 );
	self thread _ammo_refill_think();
	if ( self.model != "p6_ammo_resupply_future_01" && self.model != "p6_ammo_resupply_80s_final_01" )
	{
		self thread _place_player_loadout();
		self thread _check_extra_slots();
	}
	if ( isDefined( level._ammo_refill_think_alt ) )
	{
		self thread [[ level._ammo_refill_think_alt ]]();
	}
}

_setup_weapon_cache()
{
	waittill_asset_loaded( "xmodel", self.model );
	self ignorecheapentityflag( 1 );
	self thread _place_player_loadout();
	self thread _check_extra_slots();
}

_ammo_refill_think()
{
	self endon( "disable_ammo_cache" );
	t_ammo_cache = self _get_closest_ammo_trigger();
	t_ammo_cache sethintstring( &"SCRIPT_AMMO_REFILL" );
	t_ammo_cache setcursorhint( "HINT_NOICON" );
	while ( 1 )
	{
		t_ammo_cache waittill( "trigger", e_player );
		e_player disableweapons();
		e_player playsound( "fly_ammo_crate_refill" );
		wait 2;
		a_str_weapons = e_player getweaponslist();
		_a181 = a_str_weapons;
		_k181 = getFirstArrayKey( _a181 );
		while ( isDefined( _k181 ) )
		{
			str_weapon = _a181[ _k181 ];
			if ( !_is_banned_refill_weapon( str_weapon ) )
			{
				e_player givemaxammo( str_weapon );
				e_player setweaponammoclip( str_weapon, weaponclipsize( str_weapon ) );
			}
			_k181 = getNextArrayKey( _a181, _k181 );
		}
		e_player enableweapons();
		e_player notify( "ammo_refilled" );
	}
}

_get_closest_ammo_trigger()
{
	a_ammo_cache = getentarray( "trigger_ammo_cache", "targetname" );
	t_ammo_cache = getclosest( self.origin, a_ammo_cache );
	return t_ammo_cache;
}

_place_player_loadout()
{
	str_primary_weapon = getloadoutweapon( "primary" );
	str_secondary_weapon = getloadoutweapon( "secondary" );
	v_basic_offset = ( -5, 0, 15 );
	v_full_offset = ( -10, 0, 15 );
	v_model_offset = vectorScale( ( 0, 0, 1 ), 15 );
	n_offset_multiplier = 0;
	switch( self.model )
	{
		case "p6_weapon_resupply_80s_01":
		case "p6_weapon_resupply_80s_02":
			n_offset_multiplier = -4;
			break;
	}
	if ( !issubstr( str_primary_weapon, "+" ) )
	{
		str_primary_weapon_base = str_primary_weapon;
	}
	else
	{
		str_primary_weapon_base = strtok( str_primary_weapon, "+" )[ 0 ];
	}
	if ( !issubstr( str_primary_weapon_base, "null" ) && isassetloaded( "weapon", str_primary_weapon_base ) )
	{
		primary_weapon_pos = self gettagorigin( "loadOut_B" );
		tmp_offset = anglesToRight( self gettagangles( "loadOut_B" ) ) * n_offset_multiplier;
		m_weapon_script_model = spawn( "weapon_" + str_primary_weapon, primary_weapon_pos + tmp_offset + v_model_offset, 8 );
		m_weapon_script_model.angles = self gettagangles( "loadOut_B" ) + vectorScale( ( 0, 0, 1 ), 90 );
		level thread place_player_loadout_camo( m_weapon_script_model, "primarycamo" );
	}
	switch( self.model )
	{
		case "p6_weapon_resupply_80s_01":
		case "p6_weapon_resupply_80s_02":
			n_offset_multiplier = -7;
			break;
		case "p6_weapon_resupply_future_01":
		case "p6_weapon_resupply_future_02":
			n_offset_multiplier = -3;
			break;
		default:
			n_offset_multiplier = -4;
			break;
	}
	if ( !issubstr( str_secondary_weapon, "+" ) )
	{
		str_secondary_weapon_base = str_secondary_weapon;
	}
	else
	{
		str_secondary_weapon_base = strtok( str_secondary_weapon, "+" )[ 0 ];
	}
	if ( !issubstr( str_secondary_weapon_base, "null" ) && isassetloaded( "weapon", str_secondary_weapon_base ) )
	{
		secondary_weapon_pos = self gettagorigin( "loadOut_A" );
		tmp_offset = anglesToRight( self gettagangles( "loadOut_A" ) ) * n_offset_multiplier;
		m_weapon_script_model = spawn( "weapon_" + str_secondary_weapon, secondary_weapon_pos + tmp_offset + v_model_offset, 8 );
		m_weapon_script_model.angles = self gettagangles( "loadOut_A" ) + vectorScale( ( 0, 0, 1 ), 90 );
		level thread place_player_loadout_camo( m_weapon_script_model, "secondarycamo" );
	}
}

place_player_loadout_camo( m_weapon_script_model, camo_type )
{
	wait_for_first_player();
	if ( camo_type == "primarycamo" )
	{
		primarycamoindex = getloadoutitemindex( "primarycamo" );
		primaryweaponoptions = get_players()[ 0 ] calcweaponoptions( primarycamoindex );
		m_weapon_script_model itemweaponsetoptions( primaryweaponoptions );
	}
	else
	{
		if ( camo_type == "secondarycamo" )
		{
			secondarycamoindex = getloadoutitemindex( "secondarycamo" );
			secondaryweaponoptions = get_players()[ 0 ] calcweaponoptions( secondarycamoindex );
			m_weapon_script_model itemweaponsetoptions( secondaryweaponoptions );
		}
	}
}

_check_extra_slots()
{
	if ( isDefined( self.ac_slot1 ) )
	{
		auxilary_weapon_pos = self gettagorigin( "auxilary_A" );
/#
		assert( isDefined( auxilary_weapon_pos ), "Please use the ammo_refill_crate_future_full prefab to use this slot" );
#/
		switch( self.model )
		{
			default:
				tmp_offset = anglesToRight( self gettagangles( "auxilary_A" ) ) * 5;
				break;
		}
		m_weapon_script_model = spawn( "weapon_" + self.ac_slot1, auxilary_weapon_pos + tmp_offset + vectorScale( ( 0, 0, 1 ), 10 ), 8 );
		m_weapon_script_model.angles = self gettagangles( "auxilary_A" ) + vectorScale( ( 0, 0, 1 ), 90 );
		m_weapon_script_model itemweaponsetammo( 9999, 9999 );
	}
	if ( isDefined( self.ac_slot2 ) )
	{
		auxilary_weapon_pos = self gettagorigin( "secondary_A" );
/#
		assert( isDefined( auxilary_weapon_pos ), "Please use the ammo_refill_crate_future_full prefab to use this slot" );
#/
		tmp_offset = anglesToForward( self gettagangles( "secondary_A" ) ) * 10;
		m_weapon_script_model = spawn( "weapon_" + self.ac_slot2, auxilary_weapon_pos + tmp_offset + vectorScale( ( 0, 0, 1 ), 10 ), 8 );
		m_weapon_script_model.angles = self gettagangles( "secondary_A" );
		m_weapon_script_model itemweaponsetammo( 9999, 9999 );
	}
}

_is_banned_refill_weapon( str_weapon )
{
	return 0;
}

_debug_tags()
{
/#
	tag_array = [];
	tag_array[ tag_array.size ] = "ammo_A";
	tag_array[ tag_array.size ] = "ammo_B";
	tag_array[ tag_array.size ] = "auxilary_A";
	tag_array[ tag_array.size ] = "auxilary_B";
	tag_array[ tag_array.size ] = "grenade";
	tag_array[ tag_array.size ] = "loadOut_A";
	tag_array[ tag_array.size ] = "loadOut_B";
	tag_array[ tag_array.size ] = "secondary_A";
	_a396 = tag_array;
	_k396 = getFirstArrayKey( _a396 );
	while ( isDefined( _k396 ) )
	{
		tag = _a396[ _k396 ];
		self thread _loop_text( tag );
		_k396 = getNextArrayKey( _a396, _k396 );
#/
	}
}

_loop_text( tag )
{
/#
	while ( 1 )
	{
		if ( isDefined( self gettagorigin( tag ) ) )
		{
			print3d( self gettagorigin( tag ), tag, ( 0, 0, 1 ), 1, 0,15 );
		}
		wait 0,05;
#/
	}
}

disable_ammo_cache( str_ammo_cache_id )
{
	a_ammo_cache = getentarray( str_ammo_cache_id, "script_noteworthy" );
/#
	assert( isDefined( a_ammo_cache ), "There is no ammo cache with the script_noteworthy '" + str_ammo_cache_id + "'. Please double check the names used" );
#/
	if ( a_ammo_cache.size > 1 )
	{
/#
		assertmsg( "There is more than one ammo cache with the script_noteworthy '" + str_ammo_cache_id + "'. Please give each a unique name" );
#/
	}
	a_ammo_cache[ 0 ] notify( "disable_ammo_cache" );
	t_ammo_cache = a_ammo_cache[ 0 ] _get_closest_ammo_trigger();
	t_ammo_cache trigger_off();
}

activate_extra_slot( n_slot_number, str_weapon )
{
	if ( n_slot_number < 1 || n_slot_number > 2 )
	{
/#
		assertmsg( "Only values of 1 or 2 are valid slot positions" );
#/
	}
/#
	assert( isDefined( str_weapon ), "Weapon is not defined" );
#/
	if ( n_slot_number == 1 )
	{
		auxilary_weapon_pos = self gettagorigin( "auxilary_A" );
/#
		assert( isDefined( auxilary_weapon_pos ), "Please use the ammo_refill_crate_future_full prefab to use this slot" );
#/
		tmp_offset = anglesToRight( self gettagangles( "auxilary_A" ) ) * 5;
		m_weapon_script_model = spawn( "weapon_" + str_weapon, auxilary_weapon_pos + tmp_offset + vectorScale( ( 0, 0, 1 ), 10 ), 8 );
		m_weapon_script_model.angles = self gettagangles( "auxilary_A" ) + vectorScale( ( 0, 0, 1 ), 90 );
		m_weapon_script_model itemweaponsetammo( 9999, 9999 );
	}
	if ( n_slot_number == 2 )
	{
		auxilary_weapon_pos = self gettagorigin( "secondary_A" );
/#
		assert( isDefined( auxilary_weapon_pos ), "Please use the ammo_refill_crate_*_full prefab to use this slot" );
#/
		tmp_offset = anglesToForward( self gettagangles( "secondary_A" ) ) * 7;
		m_weapon_script_model = spawn( "weapon_" + str_weapon, auxilary_weapon_pos + tmp_offset + vectorScale( ( 0, 0, 1 ), 10 ), 8 );
		m_weapon_script_model.angles = self gettagangles( "secondary_A" );
		m_weapon_script_model itemweaponsetammo( 9999, 9999 );
	}
}

cleanup_cache()
{
	if ( issubstr( self.model, "p6_weapon_" ) )
	{
		a_weapons_list = [];
		a_item_list = getitemarray();
		_a497 = a_item_list;
		_k497 = getFirstArrayKey( _a497 );
		while ( isDefined( _k497 ) )
		{
			item = _a497[ _k497 ];
			if ( issubstr( item.classname, "weapon_" ) )
			{
				a_weapons_list[ a_weapons_list.size ] = item;
			}
			_k497 = getNextArrayKey( _a497, _k497 );
		}
		n_weapon_counter = 2;
		if ( isDefined( self.ac_slot1 ) )
		{
			n_weapon_counter++;
		}
		if ( isDefined( self.ac_slot2 ) )
		{
			n_weapon_counter++;
		}
		x = 0;
		while ( x < n_weapon_counter )
		{
			e_closest_weapon = getclosest( self.origin, a_weapons_list, 50 );
			if ( isDefined( e_closest_weapon ) )
			{
				e_closest_weapon delete();
			}
			a_weapons_list = remove_undefined_from_array( a_weapons_list );
			x++;
		}
		self delete();
	}
	else
	{
		self notify( "disable_ammo_cache" );
		t_ammo_trigger = _get_closest_ammo_trigger();
		if ( isDefined( t_ammo_trigger ) )
		{
			t_ammo_trigger delete();
		}
		self delete();
	}
}
