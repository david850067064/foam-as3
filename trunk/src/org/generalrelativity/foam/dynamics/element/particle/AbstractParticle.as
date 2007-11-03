package org.generalrelativity.foam.dynamics.element.particle
{
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import flash.display.Graphics;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.util.RenderingUtil;
	import org.generalrelativity.foam.dynamics.element.enum.Simplification;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;

	public class AbstractParticle implements IODE, ISimulatable
	{
		
		protected var _mass:Number;
		protected var _inverseMass:Number;
		protected var _force:Vector;
		protected var _state:Array;
		protected var _generators:Array;
		protected var _elasticity:Number;
		protected var _friction:Number;
		
		public function AbstractParticle( 	x:Number, 
											y:Number, 
											vx:Number = 0, 
											vy:Number = 0, 
											mass:Number = 5, 
											friction:Number = 0.2,
											elasticity:Number = 0.25,
											stateLength:uint = 4 )
		{
			
			_state = new Array( stateLength );
			_generators = new Array();
			this.x = x;
			this.y = y;
			this.vx = vx;
			this.vy = vy;
			this.mass = mass;
			this.friction = friction;
			this.elasticity = elasticity;
			clearForces();
			
		}
		
		public function getDerivative( state:Array, derivative:Array ):void
		{
			
			this._state = state;
			
			accumulateForces();
			derivative[ 0 ] = state[ 2 ];
			derivative[ 1 ] = state[ 3 ];
			derivative[ 2 ] = _force.x * inverseMass;
			derivative[ 3 ] = _force.y * inverseMass;
			clearForces();
		}
		
		public function get state():Array
		{
			return _state;
		}
		
		public function addForce( force:Vector ) : void
		{
			_force.plusEquals( force );
		}
		
		public function clearForces() : void
		{
			_force = new Vector();
		}
		
		public function addForceGenerator( generator:IForceGenerator ) : void
		{
			if( _generators.indexOf( generator ) == -1 ) _generators.push( generator );
		}
		
		public function removeForceGenerator( generator:IForceGenerator ) : void
		{
			_generators.splice( _generators.indexOf( generator ), 1 );
		}
		
		public function accumulateForces() : void
		{
			for each( var generator:IForceGenerator in _generators )
			{
				generator.generate( this );
			}
		}
		
		public function get force() : Vector
		{
			return _force;
		}
		
		public function get collisionTypeID() : String
		{
			return CollisionType.ABSTRACT_PARTICLE;
		}
		
		public function get x() : Number { return _state[ 0 ]; }
		public function set x( value:Number ) : void { _state[ 0 ] = value; }
		
		public function get y() : Number { return _state[ 1 ]; }
		public function set y( value:Number ) : void { _state[ 1 ] = value; }
		
		public function get vx() : Number { return _state[ 2 ]; }
		public function set vx( value:Number ) : void { _state[ 2 ] = value; }
		
		public function get vy() : Number { return _state[ 3 ]; }
		public function set vy( value:Number ) : void { _state[ 3 ] = value; }
		
		public function get inverseMass() : Number { return _inverseMass; }
		
		public function get mass() : Number { return _mass; }
		public function set mass( value:Number ) : void 
		{ 
			_mass = value; 
			if( _mass == Simplification.INFINITE_MASS ) _inverseMass = 0;
			else _inverseMass = 1 / value;
		}
		
		public function get position() : Vector { return new Vector( x, y ); }
		public function get velocity() : Vector { return new Vector( vx, vy ); }
		
		public function get friction() : Number { return _friction; }
		public function set friction( value:Number ) : void { _friction = MathUtil.clamp( 0, 1, value ); }
		
		public function get elasticity() : Number { return _elasticity; }
		public function set elasticity( value:Number ) : void { _elasticity = MathUtil.clamp( 0, 1, value ); }
		
	}
}