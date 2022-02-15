#include maps/_utility;
#include common_scripts/utility;

main()
{
	if ( issplitscreen() )
	{
		set_splitscreen_fog( 350, 2986,33, 10000, -480, 0,805, 0,715, 0,61, 0, 10000 );
	}
	maps/_load::main();
	setdvar( "ui_specops", 1 );
	level.is_specops_level = 1;
}

for_each( array, functor, unary_predicate, predicate_argument )
{
	while ( isDefined( functor ) )
	{
		i = 0;
		while ( i < array.size )
		{
			if ( isDefined( array[ i ] ) )
			{
				if ( !isDefined( unary_predicate ) || isDefined( unary_predicate ) && isDefined( predicate_argument ) || array[ i ] [[ unary_predicate ]]( predicate_argument ) && !isDefined( predicate_argument ) && array[ i ] [[ unary_predicate ]]() )
				{
					array[ i ] [[ functor ]]();
				}
			}
			i++;
		}
	}
}

type_so()
{
	if ( isDefined( self ) && isDefined( self.classname ) && isDefined( self.script_specialops ) && self.script_specialops == 1 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

type_reg()
{
	return !self type_so();
}

type_spawners()
{
	if ( isDefined( self.classname ) )
	{
		return issubstr( self.classname, "actor_" );
	}
}

type_so_spawners()
{
	if ( self type_so() )
	{
		return self type_spawners();
	}
}

type_reg_spawners()
{
	if ( self type_reg() )
	{
		return self type_spawners();
	}
}

type_vehicle()
{
	if ( isDefined( self.classname ) )
	{
		return issubstr( self.classname, "script_vehicle" );
	}
}

type_so_vehicle()
{
	if ( self type_so() )
	{
		return self type_vehicle();
	}
}

type_reg_vehicle()
{
	if ( self type_reg() )
	{
		return self type_vehicle();
	}
}

type_spawn_trigger()
{
	if ( !isDefined( self.classname ) )
	{
		return 0;
	}
	if ( self.classname == "trigger_multiple_spawn" )
	{
		return 1;
	}
	if ( self.classname == "trigger_multiple_spawn_reinforcement" )
	{
		return 1;
	}
	if ( self.classname == "trigger_multiple_friendly_respawn" )
	{
		return 1;
	}
	if ( isDefined( self.targetname ) && self.targetname == "flood_spawner" )
	{
		return 1;
	}
	if ( isDefined( self.targetname ) && self.targetname == "friendly_respawn_trigger" )
	{
		return 1;
	}
	if ( isDefined( self.spawnflags ) && self.spawnflags & 32 )
	{
		return 1;
	}
	return 0;
}

type_so_spawn_trigger()
{
	if ( self type_so() )
	{
		return self type_so_spawn_trigger();
	}
}

type_reg_spawn_trigger()
{
	if ( self type_reg() )
	{
		return self type_so_spawn_trigger();
	}
}

type_trigger()
{
	array = [];
	array[ "trigger_multiple" ] = 1;
	array[ "trigger_once" ] = 1;
	array[ "trigger_use" ] = 1;
	array[ "trigger_radius" ] = 1;
	array[ "trigger_lookat" ] = 1;
	array[ "trigger_disk" ] = 1;
	array[ "trigger_damage" ] = 1;
	if ( isDefined( self.classname ) )
	{
		return isDefined( array[ self.classname ] );
	}
}

type_so_trigger()
{
	if ( self type_so() )
	{
		return self type_so_trigger();
	}
}

type_reg_trigger()
{
	if ( self type_reg() )
	{
		return self type_so_trigger();
	}
}

type_flag_trigger()
{
	array = [];
	array[ "trigger_multiple_flag_set" ] = 1;
	array[ "trigger_multiple_flag_set_touching" ] = 1;
	array[ "trigger_multiple_flag_clear" ] = 1;
	array[ "trigger_multiple_flag_looking" ] = 1;
	array[ "trigger_multiple_flag_lookat" ] = 1;
	if ( isDefined( self.classname ) )
	{
		return isDefined( array[ self.classname ] );
	}
}

type_so_flag_trigger()
{
	if ( self type_so() )
	{
		return self type_flag_trigger();
	}
}

type_reg_flag_trigger()
{
	if ( self type_reg() )
	{
		return self type_flag_trigger();
	}
}

type_killspawner_trigger()
{
	if ( self type_trigger() )
	{
		return isDefined( self.script_killspawner );
	}
}

type_so_killspawner_trigger()
{
	if ( self type_so() )
	{
		return self type_killspawner_trigger();
	}
}

type_reg_killspawner_trigger()
{
	if ( self type_reg() )
	{
		return self type_killspawner_trigger();
	}
}

type_goalvolume()
{
	if ( isDefined( self.classname ) && self.classname == "info_volume" )
	{
		return isDefined( self.script_goalvolume );
	}
}

type_so_goalvolume()
{
	if ( self type_so() )
	{
		return self type_goalvolume();
	}
}

type_reg_goalvolume()
{
	if ( self type_reg() )
	{
		return self type_goalvolume();
	}
}

delete_ent()
{
	self delete();
}

delete_by_type( type_predicate )
{
	for_each( getentarray(), ::delete_ent, type_predicate );
}

noteworthy_check( value )
{
	if ( isDefined( self ) && isDefined( self.classname ) && self.classname == "script_origin" )
	{
		return 0;
	}
	else
	{
		if ( isDefined( self ) && isDefined( self.script_noteworthy ) && self.script_noteworthy != value )
		{
			return 1;
		}
		else
		{
			if ( isDefined( self ) && isDefined( self.script_gameobjectname ) )
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
}

delete_by_noteworthy( level_name )
{
	for_each( getentarray(), ::delete_ent, ::noteworthy_check, level_name );
}
