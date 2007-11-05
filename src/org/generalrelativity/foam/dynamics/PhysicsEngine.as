package org.generalrelativity.foam.dynamics
{
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.ode.solver.RK4;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	import org.generalrelativity.foam.dynamics.collision.CollisionResolver;
	import org.generalrelativity.foam.dynamics.collision.ICoarseCollisionDetector;
	import org.generalrelativity.foam.dynamics.collision.coarse.AABRDetector;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.PointPolygonDetector;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	
	public class PhysicsEngine
	{
		
		public static const SOLVER_ITERATIONS:int = 13;
		public static const DEFAULT_COARSE_COLLISION_DETECTOR:Class = AABRDetector;
		
		private var _odeSolvers:Array;
		private var _numODESolvers:int;
		
		private var _coarseDetector:ICoarseCollisionDetector;
		
		public function PhysicsEngine()
		{
			_odeSolvers = new Array();
		}
		
		public function addODESolver( solver:IODESolver ) : void
		{
			_odeSolvers.push( solver );
			_numODESolvers = _odeSolvers.length;
		}
		
		public function addCollidable( collidable:ISimulatable ) : void
		{
			if( !_coarseDetector ) _coarseDetector = new PhysicsEngine.DEFAULT_COARSE_COLLISION_DETECTOR();
			_coarseDetector.addCollidable( collidable );
		}
		
		public function step( dt:Number = 1.0 ) : void
		{
			
			var i:int;
			var iteration:int = 0;
			
			const ddt:Number = dt / PhysicsEngine.SOLVER_ITERATIONS;
			
			while( ++iteration <= PhysicsEngine.SOLVER_ITERATIONS )
			{
				
				i = _numODESolvers;
				while( --i > -1 )
				{
					IODESolver( _odeSolvers[ i ] ).step( ddt );
				}
				
				resolveCollisions();
				
			}
			
		}
		
		private function resolveCollisions() : void
		{
			var candidates:Array = _coarseDetector.getCandidates();
			for each( var candidate:IFineCollisionDetector in candidates )
			{
				if( candidate.hasCollision() ) CollisionResolver.resolve( candidate.getContacts() );
			}
		}
		
		public function removeODESolver( solver:IODESolver ) : void
		{
			_odeSolvers.splice( _odeSolvers.indexOf( solver ), 1 );
		}
		
		public function removeCollidable( collidable:ISimulatable ) : void
		{
			_coarseDetector.removeCollidable( collidable );
		}
		
		public function setCoarseCollisionDetector( detector:ICoarseCollisionDetector ) : void
		{
			_coarseDetector = detector;
		}
		
		public function setCollisionFactory( factory:ICollisionFactory ) : void
		{
			_coarseDetector.factory = factory;
		}
		
		public function getBodyUnderPoint( point:Vector ) : IBody
		{
			var pointPolygonDetector:PointPolygonDetector;
			for each( var collidable:ISimulatable in _coarseDetector.getDynamicCollidables() )
			{
				if( collidable is IBody )
				{
					pointPolygonDetector = new PointPolygonDetector( IBody( collidable ), point );
					if( pointPolygonDetector.hasCollision() ) return IBody( collidable );
				}
			}
			return null;
		}
		
	}
	
}