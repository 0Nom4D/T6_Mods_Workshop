#include animscripts/cover_prone;
#include animscripts/melee;
#include maps/_gameskill;
#include animscripts/cover_behavior;
#include animscripts/weaponlist;
#include animscripts/shoot_behavior;
#include maps/_dds;
#include maps/_utility;
#include common_scripts/utility;
#include animscripts/anims;
#include animscripts/shared;
#include animscripts/combat_utility;
#include animscripts/setposemovement;
#include animscripts/debug;

#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	[[ self.exception[ "exposed" ] ]]();
	animscripts/utility::initialize( "combat" );
	combatinit();
	self maps/_dds::dds_notify( "thrt_movement", self.team != "allies" );
	self transitiontocombat();
	self setup();
	self exposedcombatmainloop();
	self notify( "stop_deciding_how_to_shoot" );
}

combatinit()
{
	self.a.arrivaltype = undefined;
	if ( isDefined( self.node ) && isDefined( anim.isambushnode[ self.node.type ] ) && self nearnode( self.node ) )
	{
		self.ambushnode = self.node;
	}
}

combatglobalsinit()
{
	if ( !isDefined( anim.combatglobals ) )
	{
		anim.combatglobals = spawnstruct();
		anim.combatglobals.min_exposed_grenade_dist = 750;
		anim.combatglobals.min_exposed_grenade_dist_player = 500;
		anim.combatglobals.min_exposed_grenade_distsq = 250000;
		anim.combatglobals.max_grenade_throw_distsq = 1562500;
		anim.combatglobals.max_flash_grenade_throw_distsq = 589824;
		anim.combatglobals.pistol_pullout_distsq = 160000;
		anim.combatglobals.pistol_putback_distsq = 262144;
	}
}

transitiontocombat()
{
	if ( self.a.prevscript == "stop" && self.a.pose == "stand" && isDefined( self.cqb ) && self.cqb && self animscripts/utility::weaponanims() == "pistol" && isDefined( self.heat ) && !self.heat && self.animtype == "default" )
	{
		if ( animarrayexist( "idle_trans_out" ) )
		{
			self animmode( "zonly_physics" );
			self setflaggedanimknoballrestart( "transition", animarray( "idle_trans_out" ), %root, 1, 0,2, 1,2 * self.animplaybackrate );
			self animscripts/shared::donotetracks( "transition" );
		}
	}
}

setup()
{
	if ( self.weapon == self.sidearm && self isstanceallowed( "stand" ) )
	{
		transitionto( "stand" );
	}
	self set_aimturn_limits();
	self thread stopshortly();
	self clearanim( %root, 0,2 );
	self setanim( animarray( "straight_level" ) );
	self clearanim( %aim_4, 0,2 );
	self clearanim( %aim_6, 0,2 );
	self clearanim( %aim_2, 0,2 );
	self clearanim( %aim_8, 0,2 );
	setupaim( 0,2 );
	self thread idlethread();
}

set_aimturn_limits()
{
	switch( self.a.pose )
	{
		case "crouch":
		case "stand":
			self.turnthreshold = 35;
			break;
		case "prone":
/#
			assert( self.sidearm != self.weapon );
#/
			self.turnthreshold = 45;
			break;
		default:
		}
		self.rightaimlimit = 45;
		self.leftaimlimit = -45;
		self.upaimlimit = 45;
		self.downaimlimit = -45;
	}
}

stopshortly()
{
	self endon( "killanimscript" );
	self endon( "melee" );
	wait 0,2;
	self.a.movement = "stop";
}

setupaim( transtime )
{
/#
	assert( isDefined( transtime ) );
#/
	self setanimknoblimited( animarray( "add_aim_up" ), 1, transtime );
	self setanimknoblimited( animarray( "add_aim_down" ), 1, transtime );
	self setanimknoblimited( animarray( "add_aim_left" ), 1, transtime );
	self setanimknoblimited( animarray( "add_aim_right" ), 1, transtime );
}

idlethread()
{
	self endon( "killanimscript" );
	self endon( "kill_idle_thread" );
	self setanim( %add_idle );
	for ( ;; )
	{
		idleanim = animarraypickrandom( "exposed_idle" );
		if ( isarray( idleanim ) )
		{
			idleanim = random( idleanim );
		}
		self setflaggedanimknoblimitedrestart( "idle", idleanim );
		self waittillmatch( "idle" );
		return "end";
		self clearanim( idleanim, 0,2 );
	}
}

exposedcombatmainloop()
{
	self endon( "killanimscript" );
	self endon( "combat_restart" );
	self exposedcombatmainloopsetup();
	self animmode( "zonly_physics", 0 );
	self orientmode( "face angle", self.angles[ 1 ] );
	for ( ;; )
	{
		self isincombat();
		if ( exposedcombatwaitforstancechange() )
		{
			continue;
		}
		else if ( animscripts/shared::shouldswitchweapons() )
		{
			animscripts/shared::switchweapons();
			resetweaponanims();
			continue;
		}
		else trymelee();
		if ( !isDefined( self.shootpos ) )
		{
/#
			assert( !isDefined( self.shootent ) );
#/
/#
			self animscripts/debug::debugpushstate( "cantSeeEnemyBehavior" );
#/
			exposedcombatcantseeenemybehavior();
/#
			self animscripts/debug::debugpopstate( "cantSeeEnemyBehavior" );
#/
			continue;
		}
		else /#
		assert( isDefined( self.shootpos ) );
#/
		self resetgiveuponenemytime();
		distsqtoshootpos = lengthsquared( self.origin - self.shootpos );
		if ( exposedcombatstopusingrpgcheck() )
		{
			continue;
		}
		else if ( exposedcombatneedtoturn() )
		{
			continue;
		}
		else if ( exposedcombatconsiderthrowgrenade() )
		{
			continue;
		}
		else if ( exposedcombatcheckreloadorusepistol( distsqtoshootpos ) )
		{
			continue;
		}
		else exposedcombatcheckputawaypistol( distsqtoshootpos );
		if ( exposedcombatcheckstance( distsqtoshootpos ) )
		{
			continue;
		}
		else if ( aimedatshootentorpos() )
		{
			if ( exposedcombatrambo() )
			{
			}
			else
			{
/#
				self animscripts/debug::debugpushstate( "exposedCombatShootUntilNeedToTurn" );
#/
				self exposedcombatshootuntilneedtoturn();
/#
				self animscripts/debug::debugpopstate( "exposedCombatShootUntilNeedToTurn" );
#/
				self clearanim( %add_fire, 0,2 );
			}
			continue;
		}
		else
		{
			self maps/_dds::dds_notify( "thrt_acquired", self.team == "allies" );
/#
			self animscripts/debug::debugpushstate( "exposedCombatWait" );
#/
			exposedcombatwait();
/#
			self animscripts/debug::debugpopstate();
#/
		}
	}
}

exposedcombatmainloopsetup()
{
	self thread trackshootentorpos();
	self thread exposedcombatreacquirewhennecessary();
	self thread animscripts/shoot_behavior::decidewhatandhowtoshoot( "normal" );
	self thread watchshootentvelocity();
	self resetgiveuponenemytime();
	if ( self.a.magicreloadwhenreachenemy )
	{
		self animscripts/weaponlist::refillclip();
		self.a.magicreloadwhenreachenemy = 0;
	}
	self.a.dontcrouchtime = getTime() + randomintrange( 500, 1500 );
}

exposedcombatrambo()
{
	if ( isDefined( self.a.doexposedblindfire ) && !self.a.doexposedblindfire )
	{
		return 0;
	}
	if ( !animscripts/weaponlist::usingautomaticweapon() )
	{
		return 0;
	}
	if ( isDefined( self.a.nextallowedexposedblindfiretime ) )
	{
		if ( isDefined( self.a.nextallowedexposedblindfiretime ) )
		{
			shouldexposedrambo = self.a.nextallowedexposedblindfiretime < getTime();
		}
	}
	if ( shouldexposedrambo && animarrayanyexist( "exposed_rambo" ) )
	{
		self notify( "kill_idle_thread" );
		self animmode( "gravity" );
		ramboanim = animarraypickrandom( "exposed_rambo" );
		time = getanimlength( ramboanim );
		self setflaggedanimknoballrestart( "ramboAnim", ramboanim, %body, 1, 0,2, 1 );
		self animscripts/shared::donotetracksfortime( time - 0,2, "ramboAnim" );
		self animmode( "zonly_physics" );
		self thread idlethread();
		self.a.nextallowedexposedblindfiretime = getTime() + randomintrange( 3000, 5000 );
		return 1;
	}
	return 0;
}

exposedcombatwaitforstancechange()
{
	curstance = self.a.pose;
	stances = array( "stand", "crouch", "prone" );
	while ( !self isstanceallowed( curstance ) )
	{
/#
		if ( curstance != "stand" && curstance != "crouch" )
		{
			assert( curstance == "prone" );
		}
#/
		i = 0;
		while ( i < stances.size )
		{
			otherstance = stances[ i ];
			if ( otherstance == curstance )
			{
				i++;
				continue;
			}
			else
			{
				if ( self isstanceallowed( otherstance ) )
				{
					if ( curstance == "stand" && self.weapon == self.sidearm )
					{
						if ( switchtolastweapon() )
						{
							return 1;
						}
					}
					transitionto( otherstance );
					return 1;
				}
			}
			i++;
		}
	}
	return 0;
}

exposedcombatcantseeenemybehavior()
{
	if ( self.a.pose != "stand" && self isstanceallowed( "stand" ) && standifmakesenemyvisible() )
	{
		return 1;
	}
	time = getTime();
	self.a.dontcrouchtime = time + 1500;
	if ( isDefined( self.node ) && isDefined( anim.iscombatscriptnode[ self.node.type ] ) )
	{
		relyaw = angleClamp180( self.angles[ 1 ] - self.node.angles[ 1 ] );
		if ( self turntofacerelativeyaw( relyaw ) )
		{
			return 1;
		}
	}
	else
	{
		if ( isDefined( self.enemy ) || self seerecently( self.enemy, 2 ) && time > ( self.a.scriptstarttime + 1200 ) )
		{
			relyaw = undefined;
			likelyenemydir = self getanglestolikelyenemypath();
			if ( isDefined( likelyenemydir ) )
			{
				relyaw = angleClamp180( self.angles[ 1 ] - likelyenemydir[ 1 ] );
			}
			else if ( isDefined( self.node ) )
			{
				relyaw = angleClamp180( self.angles[ 1 ] - self.node.angles[ 1 ] );
			}
			else
			{
				if ( isDefined( self.enemy ) )
				{
					likelyenemydir = vectorToAngle( self lastknownpos( self.enemy ) - self.origin );
					relyaw = angleClamp180( self.angles[ 1 ] - likelyenemydir[ 1 ] );
				}
			}
			if ( isDefined( relyaw ) && self turntofacerelativeyaw( relyaw ) )
			{
				return 1;
			}
		}
	}
	if ( exposedcombatconsiderthrowgrenade() )
	{
		return 1;
	}
	givenuponenemy = self.a.nextgiveuponenemytime < time;
	threshold = 0;
	if ( givenuponenemy )
	{
		threshold = 0,99999;
	}
	if ( self exposedreload( threshold ) )
	{
		return 1;
	}
	if ( givenuponenemy && self.weapon == self.sidearm )
	{
		if ( switchtolastweapon() )
		{
			return 1;
		}
	}
	exposedcantseeenemywait();
	self maps/_dds::dds_notify( "rspns_neg", self.team == "allies" );
	return 1;
}

exposedcantseeenemywait()
{
	self endon( "shoot_behavior_change" );
	if ( isDefined( self.a.shortcantseeenemywait ) && self.a.shortcantseeenemywait )
	{
		wait 0,05;
	}
	else
	{
		wait ( 0,4 + randomfloat( 0,4 ) );
	}
	self waittill( "do_slow_things" );
}

exposedcombatstopusingrpgcheck()
{
	if ( usingrocketlauncher() && animscripts/shared::shouldthrowdownweapon() )
	{
		lastweapontype = weaponanims();
		if ( self.a.pose != "stand" && self.a.pose != "crouch" )
		{
			transitionto( "crouch" );
		}
		self notify( "kill_idle_thread" );
		animscripts/shared::throwdownweapon();
		if ( lastweapontype == "rocketlauncher" )
		{
			self.a.pose = "stand";
		}
		resetweaponanims();
		self thread idlethread();
		return 1;
	}
	return 0;
}

exposedcombatneedtoturn()
{
	if ( needtoturn() )
	{
		predicttime = 0,25;
		if ( isDefined( self.shootent ) && !issentient( self.shootent ) )
		{
			predicttime = 1,5;
		}
		yawtoshootentorpos = getpredictedaimyawtoshootentorpos( predicttime );
		if ( turntofacerelativeyaw( yawtoshootentorpos ) )
		{
			return 1;
		}
	}
	return 0;
}

exposedcombatconsiderthrowgrenade()
{
	self.a.throwinggrenade = 1;
	players = getplayers();
	if ( isDefined( players[ 0 ] ) && isDefined( anim.throwgrenadeatplayerasap ) && isalive( players[ 0 ] ) )
	{
		self.grenadeammo++;
		if ( tryexposedthrowgrenade( players[ 0 ], anim.combatglobals.min_exposed_grenade_dist_player, 1 ) )
		{
			return 1;
		}
	}
	else
	{
		if ( isDefined( self.enemy ) && isDefined( anim.throwgrenadeatenemyasap ) && isalive( self.enemy ) )
		{
			self.grenadeammo++;
			if ( tryexposedthrowgrenade( self.enemy, anim.combatglobals.min_exposed_grenade_dist, 1 ) )
			{
				return 1;
			}
		}
	}
	if ( !mygrenadecooldownelapsed() )
	{
		return 0;
	}
	if ( isDefined( self.enemy ) && tryexposedthrowgrenade( self.enemy, anim.combatglobals.min_exposed_grenade_dist ) )
	{
		return 1;
	}
	self.a.nextgrenadetrytime = getTime() + 2000;
	self.a.throwinggrenade = 0;
	return 0;
}

tryexposedthrowgrenade( throwat, mindist, forcethrow )
{
/#
	self animscripts/debug::debugpushstate( "tryThrowGrenade" );
#/
	if ( isDefined( forcethrow ) )
	{
		forcethrow = forcethrow;
	}
	threw = 0;
	if ( !forcethrow && self recentlysawenemy() )
	{
		return 0;
	}
	if ( !forcethrow && !animscripts/cover_behavior::enemyishiding() && isDefined( level.allowexposedaigrenadethrow ) && !level.allowexposedaigrenadethrow )
	{
		return 0;
	}
	throwspot = throwat.origin;
	if ( !self cansee( throwat ) )
	{
		if ( isDefined( self.enemy ) && throwat == self.enemy && isDefined( self.shootpos ) )
		{
			throwspot = self.shootpos;
		}
	}
	if ( !self cansee( throwat ) )
	{
		mindist = 250;
	}
	if ( distancesquared( self.origin, throwspot ) > ( mindist * mindist ) && self.a.pose == "stand" )
	{
		self setactivegrenadetimer( throwat );
		if ( !forcethrow && !grenadecooldownelapsed() )
		{
			return 0;
		}
		yaw = getyawtospot( throwspot );
		if ( abs( yaw ) < 60 )
		{
			throwanims = [];
			if ( isdeltaallowed( animarray( "grenade_throw" ) ) )
			{
				throwanims[ throwanims.size ] = animarray( "grenade_throw" );
			}
			if ( isdeltaallowed( animarray( "grenade_throw_1" ) ) )
			{
				throwanims[ throwanims.size ] = animarray( "grenade_throw_1" );
			}
			if ( isdeltaallowed( animarray( "grenade_throw_2" ) ) )
			{
				throwanims[ throwanims.size ] = animarray( "grenade_throw_2" );
			}
			if ( throwanims.size > 0 )
			{
				self setanim( %exposed_aiming, 0, 0,1 );
				self animmode( "zonly_physics" );
				setanimaimweight( 0, 0 );
				threw = trygrenade( throwat, throwanims[ randomint( throwanims.size ) ], forcethrow );
				self setanim( %exposed_aiming, 1, 0,1 );
				if ( threw )
				{
					setanimaimweight( 1, 0,5 );
				}
				else
				{
					setanimaimweight( 1, 0 );
				}
			}
			else
			{
/#
				self animscripts/debug::debugpopstate( "tryThrowGrenade", "no throw anim that wouldn't collide with env" );
#/
			}
		}
		else
		{
/#
			self animscripts/debug::debugpopstate( "tryThrowGrenade", "angle to enemy > 60" );
#/
		}
	}
	else
	{
/#
		if ( distancesquared( self.origin, throwspot ) < ( mindist * mindist ) )
		{
			self animscripts/debug::debugpopstate( "tryThrowGrenade", "too close (<" + mindist + ")" );
		}
		else
		{
			self animscripts/debug::debugpopstate( "tryThrowGrenade", "not standing" );
#/
		}
	}
	if ( threw )
	{
		self maps/_gameskill::didsomethingotherthanshooting();
	}
/#
	self animscripts/debug::debugpopstate( "tryThrowGrenade" );
#/
	return threw;
}

exposedcombatcheckreloadorusepistol( distsqtoshootpos )
{
/#
	if ( getDvarInt( #"28C1D720" ) == 1 )
	{
		self.forcesidearm = 1;
#/
	}
	if ( self.sidearm != self.weapon )
	{
		if ( isDefined( self.forcesidearm ) )
		{
			shouldforcesidearm = self.forcesidearm;
		}
		if ( shouldforcesidearm && self.a.pose == "stand" )
		{
			if ( self tryusingsidearm() )
			{
				return 1;
			}
			if ( issniper() && distsqtoshootpos < anim.combatglobals.pistol_pullout_distsq )
			{
				if ( self tryusingsidearm() )
				{
					return 1;
				}
			}
		}
	}
	if ( needtoreload( 0 ) )
	{
		if ( self.sidearm != self.weapon && cointoss() && !usingrocketlauncher() && self.weapon == self.primaryweapon && distsqtoshootpos < anim.combatglobals.pistol_pullout_distsq && self isstanceallowed( "stand" ) )
		{
			if ( self.a.pose != "stand" )
			{
				transitionto( "stand" );
				return 1;
			}
			if ( self tryusingsidearm() )
			{
				return 1;
			}
		}
		if ( self exposedreload( 0 ) )
		{
			return 1;
		}
	}
	return 0;
}

exposedcombatcheckputawaypistol( distsqtoshootpos )
{
	if ( self.weapon == self.sidearm && !isDefined( self.forcesidearm ) && !aihasonlypistol() )
	{
/#
		assert( self.a.pose == "stand" );
#/
		if ( distsqtoshootpos > anim.combatglobals.pistol_putback_distsq || self.combatmode == "ambush_nodes_only" || !isDefined( self.enemy ) && !self cansee( self.enemy ) )
		{
			switchtolastweapon();
		}
	}
}

exposedcombatcheckstance( distsqtoshootpos )
{
/#
	desiredstance = undefined;
	if ( shouldforcebehavior( "force_stand" ) )
	{
		desiredstance = "stand";
	}
	else
	{
		if ( shouldforcebehavior( "force_crouch" ) )
		{
			desiredstance = "crouch";
		}
	}
	if ( isDefined( desiredstance ) )
	{
		if ( self.a.pose != desiredstance )
		{
			transitionto( desiredstance );
			return 1;
		}
		return 0;
#/
	}
	if ( self.a.pose != "stand" && self isstanceallowed( "stand" ) )
	{
		if ( distsqtoshootpos < 81225 )
		{
			transitionto( "stand" );
			return 1;
		}
		if ( standifmakesenemyvisible() )
		{
			return 1;
		}
	}
	iscrouchingatnodeallowed = 1;
	if ( isDefined( self.node ) )
	{
		iscrouchingatnodeallowed = !self.node has_spawnflag( 8 );
	}
	if ( distsqtoshootpos > 262144 && self.a.pose != "crouch" && self isstanceallowed( "crouch" ) && iscrouchingatnodeallowed && self.sidearm != self.weapon && isDefined( self.heat ) && !self.heat && getTime() >= self.a.dontcrouchtime && randomint( 100 ) <= 25 && lengthsquared( self.shootentvelocity ) < 10000 )
	{
		if ( !isDefined( self.shootpos ) || sighttracepassed( self.origin + vectorScale( ( 0, 0, 0 ), 36 ), self.shootpos, 0, undefined ) )
		{
			transitionto( "crouch" );
			return 1;
		}
	}
	return 0;
}

exposedcombatshootuntilneedtoturn()
{
	self thread watchforneedtoturnortimeout();
	self endon( "need_to_turn" );
	self thread keeptryingtomelee();
	shootuntilshootbehaviorchange();
	self flamethrower_stop_shoot();
	self notify( "stop_watching_for_need_to_turn" );
	self notify( "stop_trying_to_melee" );
}

watchforneedtoturnortimeout()
{
	self endon( "killanimscript" );
	self endon( "stop_watching_for_need_to_turn" );
	endtime = getTime() + 4000 + randomint( 2000 );
	while ( 1 )
	{
		if ( getTime() > endtime || needtoturn() )
		{
			self notify( "need_to_turn" );
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}

exposedcombatwait()
{
	if ( !isDefined( self.enemy ) || !self cansee( self.enemy ) )
	{
		self endon( "enemy" );
		self endon( "shoot_behavior_change" );
		wait ( 0,2 + randomfloat( 0,1 ) );
		self waittill( "do_slow_things" );
	}
	else
	{
		wait 0,05;
	}
}

exposedcombatreacquirewhennecessary()
{
	self endon( "killanimscript" );
	self.a.exposedreloading = 0;
	while ( 1 )
	{
		wait 0,2;
		while ( isDefined( self.enemy ) && !self seerecently( self.enemy, 2 ) )
		{
			if ( self.combatmode == "ambush" || self.combatmode == "ambush_nodes_only" )
			{
				continue;
			}
		}
		tryexposedreacquire();
	}
}

tryexposedreacquire()
{
	if ( isDefined( self.a.disablereacquire ) && self.a.disablereacquire )
	{
		return;
	}
	if ( self.fixednode )
	{
		return;
	}
	if ( issniper() )
	{
		return;
	}
	if ( !isDefined( self.enemy ) )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( self.enemy isvehicle() || isai( self.enemy ) && self.enemy.isbigdog )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( getTime() < self.teammovewaittime )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( isDefined( self.prevenemy ) && self.prevenemy != self.enemy )
	{
		self.reacquire_state = 0;
		self.prevenemy = undefined;
		return;
	}
	self.prevenemy = self.enemy;
	if ( self cansee( self.enemy ) && self canshootenemy() )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( isDefined( self.a.finishedreload ) && !self.a.finishedreload )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( isDefined( self.a.throwinggrenade ) && self.a.throwinggrenade )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( isDefined( self.a.switchtosidearmdone ) && !self.a.switchtosidearmdone )
	{
		self.reacquire_state = 0;
		return;
	}
	dirtoenemy = vectornormalize( self.enemy.origin - self.origin );
	forward = anglesToForward( self.angles );
	if ( vectordot( dirtoenemy, forward ) < 0,5 )
	{
		self.reacquire_state = 0;
		return;
	}
	if ( self.a.exposedreloading && needtoreload( 0,25 ) && self.enemy.health > ( self.enemy.maxhealth * 0,5 ) )
	{
		self.reacquire_state = 0;
		return;
	}
	switch( self.reacquire_state )
	{
		case 0:
			if ( self reacquirestep( 32 ) )
			{
				return;
			}
			break;
		case 1:
			if ( self reacquirestep( 64 ) )
			{
				self.reacquire_state = 0;
				return;
			}
			break;
		case 2:
			if ( self reacquirestep( 96 ) )
			{
				self.reacquire_state = 0;
				return;
			}
			break;
		case 3:
			if ( tryrunningtoenemy( 0 ) )
			{
				self.reacquire_state = 0;
				return;
			}
			break;
		case 4:
			if ( !self cansee( self.enemy ) || !self canshootenemy() )
			{
				self flagenemyunattackable();
			}
			break;
		default:
			if ( self.reacquire_state > 15 )
			{
				self.reacquire_state = 0;
				return;
			}
			break;
	}
	self.reacquire_state++;
}

trymelee()
{
	animscripts/melee::melee_tryexecuting();
}

keeptryingtomelee()
{
	self endon( "killanimscript" );
	self endon( "stop_trying_to_melee" );
	self endon( "done turning" );
	self endon( "need_to_turn" );
	self endon( "shoot_behavior_change" );
	while ( 1 )
	{
		wait ( 0,2 + randomfloat( 0,3 ) );
		if ( isDefined( self.enemy ) )
		{
			if ( isplayer( self.enemy ) )
			{
				checkdistsq = 40000;
			}
			else
			{
				checkdistsq = 10000;
			}
			if ( distancesquared( self.enemy.origin, self.origin ) < checkdistsq )
			{
				trymelee();
			}
		}
	}
}

delaystandardmelee()
{
	if ( isDefined( self.nomeleechargedelay ) )
	{
		return;
	}
	if ( isplayer( self.enemy ) )
	{
		return;
	}
	animscripts/melee::melee_standard_delaystandardcharge( self.enemy );
}

end_script()
{
	self.ambushnode = undefined;
	self.a.throwinggrenade = 0;
	self.a.finishedreload = 1;
}

resetweaponanims()
{
	self clearanim( %aim_4, 0 );
	self clearanim( %aim_6, 0 );
	self clearanim( %aim_2, 0 );
	self clearanim( %aim_8, 0 );
	self clearanim( %exposed_aiming, 0 );
	self setanimknoballrestart( animarray( "straight_level" ), %body, 1, 0,2 );
	setupaim( 0,2 );
}

resetgiveuponenemytime()
{
	self.a.nextgiveuponenemytime = getTime() + randomintrange( 2000, 4000 );
}

switchtolastweapon( cleanup )
{
	self endon( "killanimscript" );
	if ( self.a.pose != "stand" )
	{
		return 0;
	}
	if ( isDefined( self.forcesidearm ) && self.forcesidearm && usingpistol() )
	{
		return 0;
	}
	if ( aihasonlypistol() )
	{
		return 0;
	}
	if ( self.primaryweapon != "" && self.primaryweapon != "none" )
	{
		return 0;
	}
/#
	self animscripts/debug::debugpushstate( "switchToLastWeapon" );
#/
	swapanim = animarray( "pistol_putaway", "combat" );
/#
	assert( self.lastweapon != self.sidearm );
#/
/#
	if ( self.primaryweapon != self.lastweapon )
	{
		assert( self.lastweapon == self.secondaryweapon );
	}
#/
	self notify( "kill_idle_thread" );
	self clearanim( %add_idle, 0,2 );
	self clearanim( animarray( "straight_level", "combat" ), 0,2 );
	self orientmode( "face current" );
	self.swapanim = swapanim;
	self setflaggedanimknoballrestart( "weapon swap", swapanim, %body, 1, 0,1, 1 );
	if ( isDefined( cleanup ) )
	{
		self donotetrackspostcallbackwithendon( "weapon swap", ::handleputawaycleanup, "end_weapon_swap" );
	}
	else
	{
		self donotetrackspostcallbackwithendon( "weapon swap", ::handleputaway, "end_weapon_swap" );
	}
	self clearanim( self.swapanim, 0,2 );
	self orientmode( "face angle", self.angles[ 1 ] );
	self maps/_gameskill::didsomethingotherthanshooting();
	self animscripts/anims::clearanimcache();
/#
	self animscripts/debug::debugpopstate();
#/
	return 1;
}

handleputawaycleanup( notetrack )
{
	if ( notetrack == "pistol_putaway" )
	{
		self clearanim( animarray( "straight_level", "combat" ), 0 );
	}
}

handleputaway( notetrack )
{
	if ( notetrack == "pistol_putaway" )
	{
		self clearanim( animarray( "straight_level", "combat" ), 0 );
	}
	else if ( notetrack == "start_aim" )
	{
		if ( self needtoturn() )
		{
			self notify( "end_weapon_swap" );
			return;
		}
		else
		{
			self thread idlethread();
			self setanimlimited( animarray( "straight_level", "combat" ), 1, 0 );
			setupaim( 0 );
			self setanim( %exposed_aiming, 1, 0,2 );
		}
	}
}

standifmakesenemyvisible()
{
/#
	assert( self.a.pose != "stand" );
#/
/#
	assert( self isstanceallowed( "stand" ) );
#/
	if ( isDefined( self.enemy ) && self cansee( self.enemy ) && !self canshootenemy() && sighttracepassed( self.origin + vectorScale( ( 0, 0, 0 ), 64 ), self.enemy getshootatpos(), 0, undefined ) )
	{
		self.a.dontcrouchtime = getTime() + 3000;
		transitionto( "stand" );
		return 1;
	}
	return 0;
}

transitionto( newpose )
{
	if ( newpose == self.a.pose )
	{
		return;
	}
/#
	self animscripts/debug::debugpushstate( "transitionTo: " + newpose );
#/
	self clearanim( %root, 0,3 );
	self notify( "kill_idle_thread" );
	transanim = animarray( ( self.a.pose + "_2_" ) + newpose, "combat" );
	if ( newpose == "stand" )
	{
		rate = 2;
	}
	else
	{
		rate = 1;
	}
/#
	if ( !animhasnotetrack( transanim, "anim_pose = "" + newpose + """ ) )
	{
		println( "error: ^2Pain missing notetrack to set pose!", transanim );
#/
	}
	self setflaggedanimknoballrestart( "trans", transanim, %body, 1, 0,2, rate );
	setupaim( 0 );
	self setanim( %exposed_aiming, 1, 0 );
	transtime = getanimlength( transanim ) / rate;
	playtime = transtime - 0,3;
	if ( playtime < 0,2 )
	{
		playtime = 0,2;
	}
	self animscripts/shared::donotetracksfortime( playtime, "trans" );
	self clearanim( transanim, 0,2 );
	self.a.pose = newpose;
	self set_aimturn_limits();
	self setanimknoballrestart( animarray( "straight_level" ), %body, 1, 0,25 );
	setupaim( 0,25 );
	self setanim( %add_idle );
	self thread idlethread();
	self maps/_gameskill::didsomethingotherthanshooting();
/#
	self animscripts/debug::debugpopstate();
#/
}

watchshootentvelocity()
{
	self endon( "killanimscript" );
	self.shootentvelocity = ( 0, 0, 0 );
	prevshootent = undefined;
	prevpos = self.origin;
	while ( 1 )
	{
		if ( isDefined( self.shootent ) && isDefined( prevshootent ) && self.shootent == prevshootent )
		{
			curpos = self.shootent.origin;
			self.shootentvelocity = vectorScale( curpos - prevpos, 1 / 0,15 );
			prevpos = curpos;
		}
		else
		{
			if ( isDefined( self.shootent ) )
			{
				prevpos = self.shootent.origin;
			}
			else
			{
				prevpos = self.origin;
			}
			prevshootent = self.shootent;
			self.shootentvelocity = ( 0, 0, 0 );
		}
		wait 0,15;
	}
}

isdeltaallowed( theanim )
{
	delta = getmovedelta( theanim, 0, 1 );
	endpoint = self localtoworldcoords( delta );
	if ( self isingoal( endpoint ) )
	{
		return self maymovetopoint( endpoint );
	}
}

needtoturn()
{
	point = self.shootpos;
	if ( !isDefined( point ) )
	{
		return 0;
	}
	yaw = self.angles[ 1 ] - vectorToAngle( point - self.origin )[ 1 ];
	distsq = distancesquared( self.origin, point );
	if ( distsq < 65536 )
	{
		dist = sqrt( distsq );
		if ( dist > 3 )
		{
			yaw += asin( -3 / dist );
		}
	}
	return absangleclamp180( yaw ) > self.turnthreshold;
}

exposedreload( threshold )
{
	if ( needtoreload( threshold ) )
	{
		if ( weaponisgasweapon( self.weapon ) )
		{
			self animscripts/weaponlist::refillclip();
			return 1;
		}
/#
		self animscripts/debug::debugpushstate( "exposedReload" );
#/
		self.keepclaimednode = 1;
		self.a.exposedreloading = 1;
		crouchreload = 0;
		if ( self.a.pose == "crouch" )
		{
			crouchreload = 1;
		}
		else
		{
			if ( self.a.pose == "stand" && self isstanceallowed( "crouch" ) && self.sidearm != self.weapon && cointoss() )
			{
				crouchreload = 1;
			}
			if ( self.a.pose == "stand" && isDefined( self.heat ) && !self.heat && self weaponanims() == "rocketlauncher" && self.sidearm != self.weapon )
			{
				crouchreload = 1;
			}
		}
		if ( crouchreload && animarrayanyexist( "reload_crouchhide" ) )
		{
			reloadanim = animarraypickrandom( "reload_crouchhide" );
		}
		else
		{
			reloadanim = animarraypickrandom( "reload" );
		}
		self thread keeptryingtomelee();
		self setanim( %reload, 1, 0,2 );
		self clearanim( %add_fire, 0 );
		self.a.finishedreload = 0;
		self animscripts/shared::updatelaserstatus( 0 );
		self doreloadanim( reloadanim, threshold > 0,05, 0 );
		self notify( "abort_reload" );
		self animscripts/shared::updatelaserstatus( 1 );
		if ( self.a.finishedreload )
		{
			self animscripts/weaponlist::refillclip();
		}
		self set_aimturn_limits();
		self clearanim( %reload, 0,3 );
		self setanim( %exposed_aiming, 1, 0,2 );
		self setanim( %add_idle );
		self.keepclaimednode = 0;
		self notify( "stop_trying_to_melee" );
		self.a.exposedreloading = 0;
		self maps/_gameskill::didsomethingotherthanshooting();
/#
		self animscripts/debug::debugpopstate();
#/
		return 1;
	}
	return 0;
}

doreloadanim( reloadanim, stopwhencanshoot, shouldkeepaiming )
{
	self endon( "abort_reload" );
	if ( stopwhencanshoot )
	{
		self thread abortreloadwhencanshoot();
	}
	animrate = 1;
	if ( self.sidearm != self.weapon && !self usingshotgun() && isDefined( self.enemy ) && self cansee( self.enemy ) && distancesquared( self.enemy.origin, self.origin ) < 1048576 )
	{
		animrate = 1,2;
	}
	flagname = "reload_" + getuniqueflagnameindex();
	self setflaggedanimrestart( flagname, reloadanim, 1, 0,3, animrate );
	if ( !shouldkeepaiming )
	{
		if ( animhasnotetrack( reloadanim, "stop_aim" ) )
		{
			self waittillmatch( flagname );
			return "stop_aim";
		}
		self setanim( %add_idle, 0, 0,1 );
		self setanim( %exposed_aiming, 0, 0,1 );
	}
	self thread notifyonstartaim( "abort_reload", flagname );
	self endon( "start_aim" );
	self animscripts/shared::donotetracks( flagname );
	self.a.finishedreload = 1;
}

abortreloadwhencanshoot()
{
	self endon( "abort_reload" );
	self endon( "killanimscript" );
	while ( 1 )
	{
		if ( isDefined( self.shootent ) && self cansee( self.shootent ) )
		{
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	self notify( "abort_reload" );
}

notifyonstartaim( endonstr, flagname )
{
	self endon( endonstr );
	self endon( "killanimscript" );
	self waittillmatch( flagname );
	return "start_aim";
	self.a.finishedreload = 1;
	self notify( "start_aim" );
}

finishnotetracks( animname )
{
	self endon( "killanimscript" );
	animscripts/shared::donotetracks( animname );
}

tryusingsidearm()
{
	if ( self.sidearm != "" && self.sidearm != "none" )
	{
		return 0;
	}
	if ( weaponisgasweapon( self.weapon ) )
	{
		return 0;
	}
	if ( hassecondaryweapon() )
	{
		return 0;
	}
	if ( !self.a.allow_sidearm )
	{
		return 0;
	}
	if ( usingpistol() )
	{
		return 0;
	}
	switchtosidearm( animarray( "pistol_pullout" ) );
	return 1;
}

switchtosidearm( swapanim )
{
	self endon( "killanimscript" );
/#
	self animscripts/debug::debugpushstate( "switchToSidearm" );
#/
/#
	assert( self.sidearm != "" );
#/
	if ( !isDefined( self.forcesidearm ) || !self.forcesidearm )
	{
		self thread putgunbackinhandonkillanimscript();
	}
	self notify( "kill_idle_thread" );
	self clearanim( %add_idle, 0,2 );
	self clearanim( animarray( "straight_level" ), 0,2 );
	self orientmode( "face current" );
	self.a.switchtosidearmdone = 0;
	self.pistolswitchtime = getTime() + 9000 + randomint( 3000 );
	self.swapanim = swapanim;
	self setflaggedanimknoballrestart( "weapon swap", swapanim, %body, 1, 0,2, 1 );
	self donotetrackspostcallbackwithendon( "weapon swap", ::handlepickup, "end_weapon_swap" );
	self clearanim( self.swapanim, 0 );
	self animscripts/anims::clearanimcache();
	self.a.switchtosidearmdone = 1;
	self maps/_gameskill::didsomethingotherthanshooting();
/#
	self animscripts/debug::debugpopstate();
#/
}

donotetrackspostcallbackwithendon( flagname, interceptfunction, endonmsg )
{
	self endon( endonmsg );
	self animscripts/shared::donotetrackspostcallback( flagname, interceptfunction );
}

faceenemydelay( delay )
{
	self endon( "killanimscript" );
	wait delay;
	self faceenemyimmediately();
}

handlepickup( notetrack )
{
	if ( notetrack == "pistol_pickup" )
	{
		self clearanim( animarray( "straight_level" ), 0 );
		self thread faceenemydelay( 0,25 );
	}
	else if ( notetrack == "start_aim" )
	{
		if ( self needtoturn() )
		{
			self notify( "end_weapon_swap" );
			return;
		}
		else
		{
			self thread idlethread();
			self setanimlimited( animarray( "straight_level" ), 1, 0 );
			setupaim( 0 );
			self setanim( %exposed_aiming, 1, 0,2 );
		}
	}
}

turntofacerelativeyaw( faceyaw )
{
/#
	self animscripts/debug::debugpushstate( "turnToFaceRelativeYaw", faceyaw );
#/
	if ( faceyaw < ( 0 - self.turnthreshold ) )
	{
		if ( self.a.pose == "prone" )
		{
			self animscripts/cover_prone::proneto( "crouch" );
			self set_aimturn_limits();
		}
		self doturn( "left", 0 - faceyaw );
		self maps/_gameskill::didsomethingotherthanshooting();
/#
		self animscripts/debug::debugpopstate( "turnToFaceRelativeYaw", "faceYaw < 0-self.turnThreshold" );
#/
		return 1;
	}
	if ( faceyaw > self.turnthreshold )
	{
		if ( self.a.pose == "prone" )
		{
			self animscripts/cover_prone::proneto( "crouch" );
			self set_aimturn_limits();
		}
		self doturn( "right", faceyaw );
		self maps/_gameskill::didsomethingotherthanshooting();
/#
		self animscripts/debug::debugpopstate( "turnToFaceRelativeYaw", "faceYaw > self.turnThreshold" );
#/
		return 1;
	}
/#
	self animscripts/debug::debugpopstate();
#/
	return 0;
}

faceenemyimmediately()
{
	self endon( "killanimscript" );
	self notify( "facing_enemy_immediately" );
	self endon( "facing_enemy_immediately" );
	while ( 1 )
	{
		yawchange = 0 - getyawtoenemy();
		if ( abs( yawchange ) < 2 )
		{
			break;
		}
		else
		{
			if ( abs( yawchange ) > 5 )
			{
				yawchange = 5 * sign( yawchange );
			}
			self orientmode( "face angle", self.angles[ 1 ] + yawchange );
			wait 0,05;
		}
	}
	self orientmode( "face current" );
	self notify( "can_stop_turning" );
}

doturn( direction, amount )
{
/#
	self animscripts/debug::debugpushstate( "turn", ( direction + " by " ) + amount );
#/
	rate = 1;
	transtime = 0,2;
	keepaimingon45degturn = 0;
	if ( isDefined( self.enemy ) && !self.turntomatchnode && self cansee( self.enemy ) )
	{
		mustfaceenemy = distancesquared( self.enemy.origin, self.origin ) < 262144;
	}
	if ( ( self.a.scriptstarttime + 500 ) > getTime() )
	{
		transtime = 0,25;
		if ( mustfaceenemy )
		{
			self thread faceenemyimmediately();
		}
	}
	else if ( mustfaceenemy )
	{
		urgency = 1 - ( distance( self.enemy.origin, self.origin ) / 512 );
		rate = 1 + ( urgency * 1 );
		if ( rate > 2 )
		{
			transtime = 0,05;
		}
		else if ( rate > 1,3 )
		{
			transtime = 0,1;
		}
		else
		{
			transtime = 0,15;
		}
	}
	angle = 0;
	if ( amount > 157,5 )
	{
		angle = 180;
	}
	else if ( amount > 112,5 )
	{
		angle = 135;
	}
	else if ( amount > 67,5 )
	{
		angle = 90;
	}
	else
	{
		angle = 45;
		keepaimingon45degturn = self.animtype == "default";
	}
/#
	exposedcombatturndebugmsg( "TurningAngle:" + amount );
#/
	animname = "turn_" + direction + "_" + angle;
	turnanim = animarray( animname, "combat" );
	if ( self.turntomatchnode )
	{
		self animmode( "angle deltas", 0 );
	}
	else if ( isDefined( self.node ) && isDefined( anim.iscombatscriptnode[ self.node.type ] ) && distancesquared( self.origin, self.node.origin ) < 256 || self.goalradius < 16 && !isDefined( self.enemy ) )
	{
		self animmode( "angle deltas" );
	}
	else
	{
		if ( isdeltaallowed( turnanim ) )
		{
			self animmode( "zonly_physics" );
		}
		else
		{
			self animmode( "angle deltas" );
		}
	}
	self setanimknoball( %exposed_aiming, %body, 1, transtime );
	if ( animhasnotetrack( turnanim, "start_aim" ) )
	{
		shouldusestartstopaimnotetrack = animhasnotetrack( turnanim, "stop_aim" );
	}
	if ( !self.turntomatchnode && !keepaimingon45degturn )
	{
		self thread turningaimingoff( turnanim, transtime, rate, shouldusestartstopaimnotetrack );
	}
	if ( self.turntomatchnode )
	{
		rate = 1,6;
	}
	self setanimlimited( %turn, 1, transtime );
	self setflaggedanimknoblimitedrestart( "turn", turnanim, 1, 0, rate );
	self notify( "turning" );
	if ( !keepaimingon45degturn )
	{
		self thread turnstartaiming( turnanim, rate, shouldusestartstopaimnotetrack );
	}
	doturnnotetracks();
	self setanimlimited( %turn, 0, 0,2 );
	self turnsetupidle( transtime );
	self clearanim( %turn, 0,2 );
	self setanimknob( %exposed_aiming, 1, 0,2, 1 );
	if ( isDefined( self.turnlastresort ) )
	{
		self.turnlastresort = undefined;
		self thread faceenemyimmediately();
	}
	if ( !self usingshotgun() )
	{
		self clearanim( %add_fire, 0,2 );
	}
	self notify( "done turning" );
/#
	self animscripts/debug::debugpopstate( "turn" );
#/
}

doturnnotetracks()
{
	self endon( "turning_isnt_working" );
	self endon( "can_stop_turning" );
	self animscripts/shared::donotetracks( "turn" );
}

turnstartaiming( turnanim, rate, shouldusestartstopaimnotetrack )
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "turning_isnt_working" );
	self endon( "can_stop_turning" );
	if ( shouldusestartstopaimnotetrack )
	{
		self waittillmatch( "turn" );
		return "start_aim";
	}
	else
	{
		animlength = getanimlength( turnanim ) / rate;
		wait ( animlength * 0,8 );
	}
/#
	exposedcombatturndebugmsg( "starting_aim:" + shouldusestartstopaimnotetrack );
#/
	trackloopstart();
}

turningaimingoff( turnanim, transtime, rate, shouldusestartstopaimnotetrack )
{
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "turning_isnt_working" );
	self endon( "can_stop_turning" );
	if ( shouldusestartstopaimnotetrack )
	{
		self waittillmatch( "turn" );
		return "stop_aim";
	}
	else
	{
		animlength = getanimlength( turnanim ) / rate;
		wait ( animlength * 0,2 );
	}
/#
	exposedcombatturndebugmsg( "stopping_aim:" + shouldusestartstopaimnotetrack );
#/
	self stoptracking();
	self setanimlimited( animarray( "straight_level", "combat" ), 0, transtime );
	self setanim( %aim_2, 0, transtime );
	self setanim( %aim_4, 0, transtime );
	self setanim( %aim_6, 0, transtime );
	self setanim( %aim_8, 0, transtime );
	self setanim( %add_idle, 0, transtime );
}

turnsetupidle( transtime )
{
	self setanimlimited( animarray( "straight_level" ), 1, transtime );
	self setanim( %add_idle, 1, transtime );
	trackloopstart();
}

makesureturnworks()
{
	self endon( "killanimscript" );
	self endon( "done turning" );
	startangle = self.angles[ 1 ];
	wait 0,3;
	if ( self.angles[ 1 ] == startangle )
	{
		self notify( "turning_isnt_working" );
		self.turnlastresort = 1;
	}
}

exposedcombatturndebugmsg( msg )
{
/#
	if ( getDvarInt( #"04DECC24" ) == 1 )
	{
		recordenttext( msg, self, level.color_debug[ "green" ], "Script" );
#/
	}
}
