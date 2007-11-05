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
 * Extends a RigidBody to a circular shape
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see RigidBody
 * */
package org.generalrelativity.foam.dynamics.element.body
{
	
	import flash.display.Graphics;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;
	
	public class Circle extends RigidBody
	{
		
		/** circle's radius **/
		public var radius:Number;
		
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
		 * @param radius circle's radius
		 * @param mass body's mass
		 * @param vx horizontal velocity,
		 * @param vy vertical velocity,
		 * @param q body's orientation (in radians)
		 * @param av body's angular velocity
		 * @param friction body's surface frictional coefficient
		 * @param elasticity body's elasticity
		 * 
		 * @see RigidBody
		 * @see #caclculateInertiaTensor
		 * */
		public function Circle( x:Number, 
								y:Number, 
								radius:Number,
								mass:Number = 100, 
								vx:Number = 0, 
								vy:Number = 0, 
								friction:Number = 0.5,
								elasticity:Number = 0.15,
								q:Number = 0,
								av:Number = 0 )
		{
			this.radius = radius;
			//no vertices- set to null
			super( x, y, mass, null, vx, vy, friction, elasticity, q, av );
			
		}
		
		/**
		 * Calculates the inertia tensor
		 * 
		 * @see RigidBody.calculateInertiaTensor
		 * */
		override protected function calculateInertiaTensor() : void
		{
			if( mass == Simplification.INFINITE_MASS )
			{
				_I = Simplification.INFINITE_MASS;
				_inverseI = 0;
				return;
			}
			_I = radius * radius * mass;
			_inverseI = 1 / _I;
		}
		
		override public function get collisionTypeID() : String
		{
			return CollisionType.CIRCLE;
		}
		
		
	}
}