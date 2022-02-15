#include animscripts/anims;
#include animscripts/shared;
#include animscripts/debug;
#include animscripts/combat_utility;
#include animscripts/utility;
#include common_scripts/utility;
#include maps/_utility;

#using_animtree( "generic_human" );

init_civilians()
{
	ai = getspawnerarray();
	civilians = [];
	i = 0;
	while ( i < ai.size )
	{
		if ( issubstr( tolower( ai[ i ].classname ), "civilian" ) )
		{
			civilians[ civilians.size ] = ai[ i ];
		}
		i++;
	}
	array_thread( civilians, ::add_spawn_function, ::civilian_spawn_init );
}

civilian_spawn_init()
{
	self.is_civilian = 1;
	self.ignoreall = 1;
	self.ignoreme = 1;
	self.allowdeath = 1;
	self.gibbed = 0;
	self.head_gibbed = 0;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.dontshootwhilemoving = 1;
	self.pathenemylookahead = 0;
	self.badplaceawareness = 0;
	self.chatinitialized = 0;
	self.dropweapon = 0;
	self.goalradius = 16;
	self.combatmode = "no_cover";
	self.disableexits = 1;
	self.disablearrivals = 1;
	self.specialreact = 1;
	self.a.runonlyreact = 1;
	self disable_pain();
	self pushplayer( 1 );
	self.alwaysrunforward = 1;
	self disable_tactical_walk();
	animscripts/shared::placeweaponon( self.primaryweapon, "none" );
	self allowedstances( "stand" );
	self setup_civilian_attributes();
	self thread handle_civilian_sounds();
	idleanims = array( %ai_civ_cower_idle_01, %ai_civ_cower_idle_02, %ai_civ_cower_idle_03, %ai_civ_cower_idle_04, %ai_civ_cower_idle_05 );
	self animscripts/anims::setidleanimoverride( random( idleanims ) );
}

handle_civilian_sounds()
{
	self endon( "death" );
	while ( 1 )
	{
		while ( self.a.script != "move" || self.a.movement != "run" )
		{
			wait 0,5;
		}
		if ( self.civiliansex == "male" )
		{
			self playsound( "chr_civ_scream_male" );
		}
		else
		{
			self playsound( "chr_civ_scream_female" );
		}
		wait randomintrange( 2, 5 );
	}
}

setup_civilian_attributes()
{
	classname = tolower( self.classname );
	tokens = strtok( classname, "_" );
	self.civiliansex = "male";
	if ( issubstr( classname, "female" ) )
	{
		self.civiliansex = "female";
	}
	self.nationality = "default";
}
