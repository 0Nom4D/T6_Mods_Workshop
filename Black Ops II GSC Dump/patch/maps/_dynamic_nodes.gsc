#include maps/_dynamic_nodes;
#include maps/_utility;
#include common_scripts/utility;

node_connect_to_path()
{
	if ( isDefined( self.a_node_path_connections ) )
	{
		self node_disconnect_from_path();
	}
	a_connection_nodes = [];
	a_near_nodes = getanynodearray( self.origin, 240 );
	while ( isDefined( a_near_nodes ) )
	{
		v_forward = anglesToForward( self.angles );
		nn = 0;
		while ( nn < a_near_nodes.size )
		{
			nd_test = a_near_nodes[ nn ];
			if ( nd_test != self )
			{
				v_dir = vectornormalize( nd_test.origin - self.origin );
				dot = vectordot( v_forward, v_dir );
				if ( dot >= 0,3 )
				{
					trace = bullettrace( ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + 42 ), ( nd_test.origin[ 0 ], nd_test.origin[ 1 ], nd_test.origin[ 2 ] + 42 ), 0, undefined, 1, 1 );
					if ( trace[ "fraction" ] >= 1 )
					{
						a_connection_nodes[ a_connection_nodes.size ] = nd_test;
					}
				}
			}
			nn++;
		}
	}
	while ( a_connection_nodes.size )
	{
		i = 0;
		while ( i < a_connection_nodes.size )
		{
			self node_add_connection( a_connection_nodes[ i ] );
			i++;
		}
	}
	return a_connection_nodes.size;
}

node_add_connection( nd_node )
{
	if ( !nodesarelinked( self, nd_node ) )
	{
		if ( !isDefined( self.a_node_path_connections ) )
		{
			self.a_node_path_connections = [];
		}
		linknodes( self, nd_node );
		linknodes( nd_node, self );
		self.a_node_path_connections[ self.a_node_path_connections.size ] = nd_node;
	}
}

node_disconnect_from_path()
{
	while ( isDefined( self.a_node_path_connections ) )
	{
		i = 0;
		while ( i < self.a_node_path_connections.size )
		{
			nd_node = self.a_node_path_connections[ i ];
			unlinknodes( self, nd_node );
			unlinknodes( nd_node, self );
			i++;
		}
	}
	self.a_node_path_connections = undefined;
}

entity_grab_attached_dynamic_nodes( connect_nodes_to_path )
{
	if ( !isDefined( connect_nodes_to_path ) )
	{
		connect_nodes_to_path = 1;
	}
	if ( isDefined( self.targetname ) )
	{
		a_nodes = getnodearray( self.targetname, "target" );
		_a164 = a_nodes;
		_k164 = getFirstArrayKey( _a164 );
		while ( isDefined( _k164 ) )
		{
			node = _a164[ _k164 ];
			if ( !isDefined( self.a_dynamic_nodes ) )
			{
				self.a_dynamic_nodes = [];
			}
			if ( node has_spawnflag( 256 ) )
			{
				self.a_dynamic_nodes[ self.a_dynamic_nodes.size ] = node;
			}
			_k164 = getNextArrayKey( _a164, _k164 );
		}
		if ( connect_nodes_to_path )
		{
			self thread maps/_dynamic_nodes::entity_connect_dynamic_nodes_to_navigation_mesh();
		}
	}
}

entity_connect_dynamic_nodes_to_navigation_mesh()
{
	self endon( "death" );
	while ( isDefined( self.a_dynamic_nodes ) )
	{
		self entity_connect_nodes();
		wait 0,05;
		_a204 = self.a_dynamic_nodes;
		_k204 = getFirstArrayKey( _a204 );
		while ( isDefined( _k204 ) )
		{
			node = _a204[ _k204 ];
			dropnodetofloor( node );
			_k204 = getNextArrayKey( _a204, _k204 );
		}
	}
}

entity_connect_nodes()
{
	self endon( "death" );
	if ( !isDefined( self.a_dynamic_nodes ) )
	{
		return;
	}
	_a236 = self.a_dynamic_nodes;
	_k236 = getFirstArrayKey( _a236 );
	while ( isDefined( _k236 ) )
	{
		nd_dynamic = _a236[ _k236 ];
		if ( !isDefined( nd_dynamic.a_linked_nodes ) )
		{
			nd_dynamic.a_linked_nodes = [];
		}
		a_near_nodes = getanynodearray( nd_dynamic.origin, 256 );
		_a245 = a_near_nodes;
		_k245 = getFirstArrayKey( _a245 );
		while ( isDefined( _k245 ) )
		{
			nd_test = _a245[ _k245 ];
			reject = 0;
			if ( nd_test == nd_dynamic )
			{
				reject = 1;
			}
			if ( isinarray( self.a_dynamic_nodes, nd_test ) )
			{
				reject = 1;
			}
			if ( isinarray( nd_dynamic.a_linked_nodes, nd_test ) )
			{
				reject = 1;
			}
			if ( !reject )
			{
				v_forward = anglesToForward( nd_dynamic.angles );
				v_dir = vectornormalize( nd_test.origin - nd_dynamic.origin );
				dot = vectordot( v_forward, v_dir );
				if ( dot > 0,05 )
				{
					reject = 1;
				}
			}
			if ( !reject )
			{
				trace = bullettrace( nd_dynamic.origin, nd_test.origin, 0, undefined, 1, 1 );
				if ( trace[ "fraction" ] < 1 )
				{
					reject = 1;
				}
			}
			if ( isDefined( nd_dynamic.type ) && nd_dynamic.type == "Begin" )
			{
				reject = 1;
			}
			if ( isDefined( nd_test.type ) && nd_test.type == "Begin" )
			{
				reject = 1;
			}
			if ( !reject )
			{
				linknodes( nd_dynamic, nd_test );
				linknodes( nd_test, nd_dynamic );
				nd_dynamic.a_linked_nodes[ nd_dynamic.a_linked_nodes.size ] = nd_test;
			}
			_k245 = getNextArrayKey( _a245, _k245 );
		}
		_k236 = getNextArrayKey( _a236, _k236 );
	}
}

entity_disconnect_dynamic_nodes_from_navigation_mesh()
{
	while ( isDefined( self.a_dynamic_nodes ) )
	{
		_a340 = self.a_dynamic_nodes;
		_k340 = getFirstArrayKey( _a340 );
		while ( isDefined( _k340 ) )
		{
			nd_dynamic = _a340[ _k340 ];
			while ( isDefined( nd_dynamic.a_linked_nodes ) )
			{
				_a344 = nd_dynamic.a_linked_nodes;
				_k344 = getFirstArrayKey( _a344 );
				while ( isDefined( _k344 ) )
				{
					nd_linked = _a344[ _k344 ];
					unlinknodes( nd_dynamic, nd_linked );
					unlinknodes( nd_linked, nd_dynamic );
					_k344 = getNextArrayKey( _a344, _k344 );
				}
			}
			nd_dynamic.a_linked_nodes = [];
			_k340 = getNextArrayKey( _a340, _k340 );
		}
	}
}
