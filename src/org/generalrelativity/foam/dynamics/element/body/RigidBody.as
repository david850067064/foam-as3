/*
Copyright (c) 2007 Drew Cummins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/**
 * Basal implementation of a RigidBody
 * 
 * <p>
 * Rigid bodies have some definable qualities worth mentioning. Firstly, we choose
 * a center of mass about which everything is oriented. That center of mass is
 * implicitly given by this element's position. Secondly its laws of motion are
 * more complicated than that of a particle. We have to consider both linear and
 * angular velocity.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ISimulatable
 * @see IODE
 * @see Foam
 * @see IForceGenerator
 * */
package org.generalrelativity.foam.dynamics.element.body
{

	import org.generalrelativity.foam.dynamics.element.particle.SimpleParticle;
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;

	public class RigidBody extends SimpleParticle implements IODE, ISimulatable, IBody
	{
		
		/** body vertices **/
		protected var _vertices:Array;
		/** body edges **/
		protected var _edges:Array;
		/** torque accumulator */
		protected var _torque:Number;
		/** inertia tensor **/
		protected var _I:Number;
		/** inverse inertia tensor **/
		protected var _inverseI:Number;
		/** rotation matrix of body **/
		protected var _rotation:RotationMatrix;
		
		/**
		 * Creates a new RigidBody
		 * 
		 * <p>
		 * This will most likely be the most used element in FOAM. It's important to note that
		 * most aspects of simulation assume convexity in bodies.
		 * </p>
		 * 
		 * @param x body's x position
		 * @param y body's y postiion
		 * @param mass body's mass
		 * @param vertices body vertices
		 * @param vx horizontal velocity,
		 * @param vy vertical velocity,
		 * @param friction body's surface frictional coefficient
		 * @param elasticity body's elasticity
		 * @param q body's orientation (in radians)
		 * @param av body's angular velocity
		 * 
		 * @see SimpleParticle
		 * @see #caclculateInertiaTensor
		 * */
		public function RigidBody( 	x:Number, 
									y:Number, 
									mass:Number = 100, 
									vertices:Array = null,
									vx:Number = 0, 
									vy:Number = 0, 
									friction:Number = 0.2,
									elasticity:Number = 0.25,
									q:Number = 0,
									av:Number = 0 ) 
		{								
		
			//if vertices have been supplied, build our edges and vertices
			if( vertices )
			{
				_vertices = vertices;
				_edges = ShapeUtil.getEdges( vertices );
			}
			super( x, y, vx, vy, mass, friction, elasticity, 6 );
			this.q = q;
			this.av = av;
			//define the current rotation matrix
			_rotation = new RotationMatrix( q );
			//clear torque (just sets torque to 0)
			clearTorque();
			//calculates this body's inertia tensor
			calculateInertiaTensor();
		}
		
		/**
		 * Gets the derivative of the body
		 * 
		 * <p>
		 * Note that both the state and derivative are longer than in SimpleParticle. This
		 * is because a rigid body has 2 more properties to integrate with respect to time
		 * (orientation and angular velocity).
		 * </p>
		 * 
		 * @param state body's state
		 * @param derivative Array to populate with body's derivative
		 * 
		 * @see IODE.getDerivative
		 * @see SimpleParticle
		 * */
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
			derivative[ 4 ] = state[ 5 ]; //av
			
			//derivative of angular velocity
			derivative[ 5 ] = _torque * _inverseI; //torque
			
			//clear forces
			clearForces();
			clearTorque();
			
		}
		
		/**
		 * Adds torque to the body
		 * 
		 * <p>
		 * This is the rotational equivalent to adding a force
		 * </p>
		 * 
		 * @param torque amount of torque to add
		 * */
		public function addTorque( torque:Number ) : void
		{
			_torque += torque;
		}
		
		/**
		 * Clears any accumulated torque
		 * */
		public function clearTorque() : void
		{
			_torque = 0;
		}
		
		/**
		 * Adds a force at a specific point on the body
		 * 
		 * <p>
		 * IF the point specified is not the center of mass (0,0), the force will induce a 
		 * change in angular velocity as well as linear. Note that this point is given in
		 * relative coordinates to the body- that is NOT in world-coordinates.
		 * </p>
		 * 
		 * @param point point on body relative to its center of mass on which to apply force
		 * @param force force to apply at point
		 * */
		public function addForceAtPoint( point:Vector, force:Vector ) : void
		{
			addForce( force );
			addTorque( point.getPerp().dot( force ) );
		}
		
		/**
		 * Gets the velocity of the body at a specified point
		 * 
		 * <p>
		 * Note that this point is given in world-coordinates.
		 * </p>
		 * 
		 * TODO: why is this given in world coordinates and addForceAtPoint relative? Probably
		 * confusing...
		 * 
		 * @param point point to determine velocity from
		 * 
		 * @return componentized velocity
		 * */
		public function getVelocityAtPoint( point:Vector ) : Vector
		{
			//find the direction of the point about the center of mass
			var pointRelativeTangent:Vector = point.minus( position ).getPerp();
			//normalize
			pointRelativeTangent.normalize();
			//scale by the angular velocity and add to the velocity to acquire the point's total velocity
			return velocity.plus( pointRelativeTangent.times( av ) );
		}
		
		/**
		 * Calculates the body's inertia tensor
		 * 
		 * <p>
		 * The inertia tensor is the rotational equivalent to mass- it is also linked to mass.
		 * In 3 dimensions, the inertia tensor is a 3x3 matrix- in 2 dimensions it is a rank 0
		 * tensor, or simply, a scalar.
		 * </p>
		 * 
		 * TODO: This is not very physically accurate, but provides decent resulsts for convex
		 * shapes. Improve.
		 * */
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
		
		/**
		 * Gets the rotation matrix of the body
		 * 
		 * <p>
		 * Because the creation of a rotation matrix involves 2 trigonometric function calls, it's
		 * worthwhile to do a check to see if we need to create a new rotation matrix.
		 * </p>
		 * 
		 * @return RotationMatrix of body
		 * */
		public function get rotation() : RotationMatrix 
		{ 
			if( _rotation.theta != q ) _rotation = new RotationMatrix( q );
			return _rotation; 
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
		
		
		
		
	}
}