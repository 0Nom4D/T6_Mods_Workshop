#include animscripts/debug;
#include common_scripts/utility;
#include animscripts/anims;

#using_animtree( "bigdog" );

initanimtree( animscript )
{
	self clearanim( %body, 0,3 );
	self setanim( %body, 1, 0 );
/#
	assert( isDefined( animscript ), "Animscript not specified in initAnimTree" );
#/
	self.a.prevscript = self.a.script;
	self.a.script = animscript;
	self.a.script_suffix = undefined;
	self animscripts/anims::clearanimcache();
}

initialize( animscript )
{
/#
	if ( isDefined( self.a.script ) && !self animscripts/debug::debugshouldclearstate() )
	{
		self animscripts/debug::debugpopstate( self.a.script );
	}
	else
	{
		self animscripts/debug::debugclearstate();
	}
	self animscripts/debug::debugpushstate( animscript );
#/
	self.a.scriptstarttime = getTime();
	initanimtree( animscript );
}

fire_grenade_at_target( target )
{
	scriptedenemy = self.scriptenemy;
	self setentitytarget( target );
	self.grenadeammo = 1;
	self waittill( "grenade_fire" );
	self.grenadeammo = 0;
	if ( isDefined( scriptedenemy ) )
	{
		self setentitytarget( target );
	}
	else
	{
		self clearentitytarget();
	}
}

setactivegrenadetimer( throwingat )
{
	if ( isplayer( throwingat ) )
	{
		self.activegrenadetimer = "player_frag_grenade_sp";
	}
	else
	{
		self.activegrenadetimer = "AI_frag_grenade_sp";
	}
	if ( !isDefined( anim.grenadetimers[ self.activegrenadetimer ] ) )
	{
		anim.grenadetimers[ self.activegrenadetimer ] = randomintrange( 1000, 20000 );
	}
}

animsuffix()
{
	animsuffix = "";
	if ( isDefined( self.missinglegs[ "FR" ] ) && isDefined( self.missinglegs[ "FL" ] ) && isDefined( self.missinglegs[ "RL" ] ) && isDefined( self.missinglegs[ "RR" ] ) )
	{
		animsuffix = "_all_legs";
	}
	else
	{
		if ( isDefined( self.missinglegs[ "FR" ] ) && isDefined( self.missinglegs[ "FL" ] ) )
		{
			animsuffix = "_frontlegs";
		}
		else
		{
			if ( isDefined( self.missinglegs[ "FR" ] ) && isDefined( self.missinglegs[ "RL" ] ) )
			{
				animsuffix = "_fr_rl";
			}
			else
			{
				if ( isDefined( self.missinglegs[ "FL" ] ) && isDefined( self.missinglegs[ "RR" ] ) )
				{
					animsuffix = "_fl_rr";
				}
				else
				{
					if ( isDefined( self.missinglegs[ "RR" ] ) && isDefined( self.missinglegs[ "RL" ] ) )
					{
						animsuffix = "_rearlegs";
					}
					else
					{
						if ( isDefined( self.missinglegs[ "FL" ] ) && isDefined( self.missinglegs[ "RL" ] ) )
						{
							animsuffix = "_leftlegs";
						}
						else
						{
							if ( isDefined( self.missinglegs[ "FR" ] ) && isDefined( self.missinglegs[ "RR" ] ) )
							{
								animsuffix = "_rightlegs";
							}
							else
							{
								if ( isDefined( self.missinglegs[ "FR" ] ) )
								{
									animsuffix = "_frontright";
								}
								else if ( isDefined( self.missinglegs[ "FL" ] ) )
								{
									animsuffix = "_frontleft";
								}
								else if ( isDefined( self.missinglegs[ "RR" ] ) )
								{
									animsuffix = "_rearright";
								}
								else
								{
									if ( isDefined( self.missinglegs[ "RL" ] ) )
									{
										animsuffix = "_rearleft";
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return animsuffix;
}

wasdamagedbyempgrenade( weapon, meansofdeath )
{
	if ( issubstr( weapon, "emp_grenade" ) )
	{
		return meansofdeath != "MOD_IMPACT";
	}
}

bigdog_isemped()
{
	if ( isDefined( self.a.empedendtime ) )
	{
		return getTime() <= self.a.empedendtime;
	}
}

wasdamagedbychargedsnipershot()
{
	if ( isDefined( self.damageweapon ) )
	{
		weaponchargeable = ischargedshotsniperrifle( self.damageweapon );
	}
	if ( weaponchargeable && isDefined( self.attacker ) && isDefined( self.attacker.chargeshotlevel ) )
	{
		weaponischarged = self.attacker.chargeshotlevel >= 2;
	}
	if ( weaponchargeable && weaponischarged )
	{
		return 1;
	}
	return 0;
}

wasdamagedbyfullychargedsnipershot()
{
	if ( isDefined( self.damageweapon ) )
	{
		weaponchargeable = ischargedshotsniperrifle( self.damageweapon );
	}
	if ( weaponchargeable && isDefined( self.attacker ) && isDefined( self.attacker.chargeshotlevel ) )
	{
		weaponischarged = self.attacker.chargeshotlevel >= 3;
	}
	if ( weaponchargeable && weaponischarged )
	{
		return 1;
	}
	return 0;
}

ischargedshotsniperrifle( weapon )
{
	if ( weaponischargeshot( weapon ) )
	{
		return weaponissniperweapon( weapon );
	}
}

wasdamagedbysnipershot()
{
	if ( isDefined( self.damageweapon ) )
	{
		return weaponissniperweapon( self.damageweapon );
	}
}
