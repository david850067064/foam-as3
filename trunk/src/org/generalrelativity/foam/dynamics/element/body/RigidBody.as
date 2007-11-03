package org.generalrelativity.foam.dynamics.element.body
{
	import org.generalrelativity.foam.dynamics.element.particle.AbstractParticle;
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import flash.display.Graphics;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.util.RenderingUtil;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.dynamics.element.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;

	public class RigidBody extends AbstractParticle implements IODE, ISimulatable, IBody
	{
		
		protected var _vertices:Array;
		protected var _edges:Array;
		protected var _torque:Number;
		protected var _I:Number;
		protected var _inverseI:Number;
		protected var _rotation:RotationMatrix;
		
		
		public function RigidBody( 	x:Number, 
									y:Number, 
									mass:Number = 1, 
									vertices:Array = null,
									vx:Number = 0, 
									vy:Number = 0, 
									friction:Number = 0.2,
									elasticity:Number = 0.25,
									q:Number = 0,
									av:Number = 0 ) 
		{								
		
			if( vertices )
			{
				_vertices = vertices;
				_edges = ShapeUtil.getEdges( vertices );
			}
			super( x, y, vx, vy, mass, friction, elasticity, 6 );
			this.q = q;
			this.av = av;
			_rotation = new RotationMatrix( q );
			clearTorque();
			calculateInertiaTensor();
		}
		
		override public function getDerivative( state:Array, derivative:Array ) : void
		{
			
			this._state = state;
			
			// accumulate forces
			accumulateForces(); 
			
			// derivative of position
			derivative[ 0 ] = state[ 2 ]; // vx
			derivative[ 1 ] = state[ 3 ]; // vy
			
			// derivative of velocity
			derivative[ 2 ] = _force.x * _inverseMass; // ax
			derivative[ 3 ] = _force.y * _inverseMass; // ay
			
			// derivative of orientation
			derivative[ 4 ] = state[ 5 ]; 
			
			//derivative of angular velocity
			derivative[ 5 ] = _torque * _inverseI; 
			
			//clear forces
			clearForces();
			clearTorque();
			
		}
		
		public function addTorque( torque:Number ) : void
		{
			_torque += torque;
		}
		
		public function clearTorque() : void
		{
			_torque = 0;
		}
		
		public function addForceAtPoint( point:Vector, force:Vector ) : void
		{
			addForce( force );
			addTorque( point.getPerp().dot( force ) );
		}
		
		public function getVelocityAtPoint( point:Vector ) : Vector
		{
			var pointRelativeTangent:Vector = point.minus( position ).getPerp();
			pointRelativeTangent.normalize();
			return velocity.plus( pointRelativeTangent.times( av ) );
		}
		
		protected function calculateInertiaTensor() : void
		{
			if( mass == Simplification.INFINITE_MASS )
			{
				_I = Simplification.INFINITE_MASS;
				_inverseI = 0;
				return;
			}
			_I = 0;
			var pointMass:Number = mass / _vertices.length;
			for each( var vertex:Vector in _vertices )
			{
				_I += vertex.dot( vertex ) * pointMass;
			}
			_inverseI = 1 / _I;
		}
		
		override public function get collisionTypeID() : String
		{
			return CollisionType.RIGID_BODY;
		}
		
		public function get torque() : Number { return _torque; }
		public function get inverseI() : Number { return _inverseI; }
		public function get I() : Number { return _I; }
		public function get q() : Number { return _state[ 4 ]; }
		public function set q( value:Number ) : void { _state[ 4 ] = value; }
		public function get av() : Number { return _state[ 5 ]; }
		public function set av( value:Number ) : void { _state[ 5 ] = value; }
		public function get edges() : Array { return _edges };
		public function get vertices() : Array { return _vertices };
		public function get rotation() : RotationMatrix 
		{ 
			if( _rotation.theta != q ) _rotation = new RotationMatrix( q );
			return _rotation; 
		}
		
		
	}
}