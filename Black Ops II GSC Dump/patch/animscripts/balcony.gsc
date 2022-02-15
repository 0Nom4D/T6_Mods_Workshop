#include animscripts/shared;
#include animscripts/pain;
#include maps/_utility;
#include animscripts/anims;
#include animscripts/utility;
#include common_scripts/utility;

#using_animtree( "generic_human" );

balconyglobalsinit()
{
	while ( !isDefined( anim.balcony_nodes ) )
	{
		anim.balcony_node_types = [];
		anim.balcony_node_types[ "Cover Stand" ] = 1;
		anim.balcony_node_types[ "Cover Crouch" ] = 1;
		anim.balcony_node_types[ "Cover Crouch Window" ] = 1;
		anim.balcony_node_types[ "Conceal Stand" ] = 1;
		anim.balcony_node_types[ "Conceal Crouch" ] = 1;
		anim.balcony_node_types[ "Guard" ] = 1;
		anim.balcony_node_types[ "Exposed" ] = 1;
		anim.balcony_nodes = [];
		all_nodes = getallnodes();
		i = 0;
		while ( i < all_nodes.size )
		{
			node = all_nodes[ i ];
			if ( isbalconynode( node ) )
			{
				anim.balcony_nodes[ anim.balcony_nodes.size ] = node;
			}
			i++;
		}
	}
}

balconydamage( idamage, smeansofdeath )
{
	if ( isDefined( self.a.doingbalconydeath ) && self.a.doingbalconydeath )
	{
		self.health = idamage + 1;
	}
	else
	{
		if ( self.health <= idamage )
		{
			if ( candobalcony( smeansofdeath ) )
			{
				self.do_balcony_death_now = 1;
				self.health = idamage + 1;
			}
			return 1;
		}
	}
	return 0;
}

candobalcony( smeansofdeath )
{
	if ( isDefined( self.a.doingbalconydeath ) && self.a.doingbalconydeath )
	{
/#
		debug_balcony( "not doing balcony death: already doing it." );
#/
		return 0;
	}
	self.balcony_node = getbalconynode();
	if ( !isDefined( self.balcony_node ) )
	{
		return 0;
	}
	else
	{
		if ( isDefined( self.balcony_node.balconydeathcounter ) && self.balcony_node.balconydeathcounter > 0 )
		{
/#
			debug_balcony( "not doing balcony death: balconyDeathCounter is at " + self.balcony_node.balconydeathcounter );
#/
			self.balcony_node.balconydeathcounter--;

			return 0;
		}
	}
	if ( is_false( self.allowpain ) )
	{
/#
		debug_balcony( "not doing balcony death: pain is disabled." );
#/
		return 0;
	}
	if ( animscripts/pain::isexplosivedamagemod( smeansofdeath ) )
	{
/#
		debug_balcony( "explosive damage" );
#/
		return 0;
	}
	if ( self.a.pose != "stand" )
	{
		if ( self.a.pose == "crouch" )
		{
/#
			debug_balcony( "crouching and at railing" );
#/
			return 0;
		}
		else
		{
			if ( self.a.pose != "crouch" )
			{
/#
				debug_balcony( "not standing or crouching" );
#/
				return 0;
			}
		}
	}
	if ( isDefined( self.balcony_node.script_balconydeathchance ) )
	{
		if ( randomfloat( 1 ) > self.balcony_node.script_balconydeathchance )
		{
			return 0;
		}
	}
	return 1;
}

getbalconynode()
{
	balcony_node = undefined;
	if ( self.a.movement == "stop" )
	{
		if ( isDefined( self.node ) && isbalconynode( self.node ) )
		{
			if ( check_ang_and_dist_to_node( self.node ) )
			{
				balcony_node = self.node;
/#
				debug_balcony( "on a balcony node (self.node)." );
#/
			}
		}
		else
		{
			if ( isDefined( self.covernode ) && isbalconynode( self.covernode ) )
			{
				if ( check_ang_and_dist_to_node( self.covernode ) )
				{
					balcony_node = self.covernode;
/#
					debug_balcony( "on a balcony node (self.covernode)." );
#/
				}
			}
		}
	}
	while ( !isDefined( balcony_node ) )
	{
		nodes = anim.balcony_nodes;
		i = 0;
		while ( i < nodes.size )
		{
			node = nodes[ i ];
			if ( check_ang_and_dist_to_node( node ) )
			{
				balcony_node = node;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	return balcony_node;
}

check_ang_and_dist_to_node( node )
{
	dist = distancesquared( self.origin, node.origin );
	if ( dist <= 900 )
	{
		node_angle = absangleclamp180( node.angles[ 1 ] );
		ai_angle = absangleclamp180( self.angles[ 1 ] );
		ang_diff = abs( node_angle - ai_angle );
		if ( ang_diff <= 75 )
		{
			vec = self.origin - node.origin;
			dot = vectordot( vectornormalize( vec ), anglesToForward( node.angles ) );
/#
			debug_balcony_line( node.origin, self.origin, ( 1, 1, 0 ) );
#/
			if ( dot >= -0,1 )
			{
/#
				debug_balcony( "In front of balcony node. dot = " + dot );
#/
				return 1;
			}
			else
			{
/#
				debug_balcony( "Behind balcony node. dot = " + dot );
#/
				if ( dist <= 900 )
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

trybalcony()
{
	if ( isDefined( self.doinglongdeath ) && self.doinglongdeath )
	{
		return 0;
	}
	if ( isDefined( self.a.doingbalconydeath ) && self.a.doingbalconydeath )
	{
		return 1;
	}
	if ( isDefined( self.do_balcony_death_now ) && self.do_balcony_death_now )
	{
		self animcustom( ::dobalcony );
		return 1;
	}
	else
	{
		return 0;
	}
}

dobalcony()
{
	self.a.doingbalconydeath = 1;
	self thread kill_animscript();
/#
	assert( isDefined( self.balcony_node ) );
#/
	if ( !isDefined( self.balcony_node ) )
	{
		return;
	}
	balconynodetype = "balcony_norailing";
	if ( !isbalconynodenorailing( self.balcony_node ) )
	{
		balconynodetype = "balcony";
	}
	disable_pain();
	disable_react();
	if ( self.a.pose == "crouch" && balconynodetype == "balcony_norailing" )
	{
		forward = anglesToForward( self.angles );
		if ( isDefined( self.balcony_node ) )
		{
			forward = anglesToForward( self.balcony_node.angles );
		}
		self startragdoll();
		self launchragdoll( vectorScale( forward, randomintrange( 25, 35 ) ), "tag_eye" );
		self do_ragdoll_death();
		return;
	}
	self.balcony_node.balconydeathcounter = randomintrange( 1, 3 );
	self thread getclosertobalconynode( self.balcony_node.origin, self.balcony_node.angles, 0,2 );
	animation = animarraypickrandom( balconynodetype, "combat" );
	if ( isDefined( animation ) )
	{
		self.a.nodeath = 1;
		self animmode( "noclip" );
		self setflaggedanimknoball( "balcony", animation, %body, 1, 0,1, 1 );
		self animscripts/shared::donotetracks( "balcony" );
	}
}

getclosertobalconynode( origin, angles, movetime )
{
	self endon( "death" );
	self endon( "killanimscript" );
/#
	debug_balcony( "Teleporting to balcony node." );
#/
	startangles = self.angles;
	movevector = vectorScale( origin - self.origin, 0,05 / movetime );
	timer = 0;
	while ( timer < movetime )
	{
		timer += 0,05;
		lerpvar = timer / movetime;
		neworigin = self.origin + movevector;
		newangles = ( anglelerp( startangles[ 0 ], angles[ 0 ], lerpvar ), anglelerp( startangles[ 1 ], angles[ 1 ], lerpvar ), anglelerp( startangles[ 2 ], angles[ 2 ], lerpvar ) );
		self forceteleport( neworigin, newangles );
		wait 0,05;
	}
}

kill_animscript()
{
	self endon( "death" );
	self waittill( "killanimscript" );
	self do_ragdoll_death();
}

debug_balcony( msg )
{
/#
	println( msg );
	recordenttext( msg, self, level.color_debug[ "white" ], "Cover" );
#/
}

debug_balcony_line( start, end, color )
{
/#
	recordline( start, end, color, "Cover", self );
#/
}
