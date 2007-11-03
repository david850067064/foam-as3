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
 * Detects collision between 2 circles.
 * 
 * <p>
 * This detection scheme is based on the Separating Axis Theorem (SAT). The idea
 * is that given 2 convex objects (two-dimensionally in this case), if an axis
 * can be found that does not intersect either, they are not touching. This makes
 * intuitive sense because convex objects can't "wrap around" each other. Also,
 * the geometries that make this assumption hold, offer the axes we need to check.
 * Specifically, we test along the axis given by each polygonal edge normal.
 * </p>
 * 
 * <p>
 * Aside from its generality, what makes SAT so robust is that it offers an "easy
 * out." As soon as one separating axis is found, no further consideration is 
 * necessary- the objects do not intersect.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IFineCollisionDetector
 * @see Contact
 * @see PhysicsEngine
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.collision.Contact;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	
	public class CircleCircleDetector implements IFineCollisionDetector
	{
		
		/** circle 1 to check for collision **/
		public var circle1:Circle;
		/** circle 2 to check for collision **/
		public var circle2:Circle;
		/** distance between circles **/
		public var dist:Number;
		
		/**
		 * Creates a new CircleCircleDetector
		 * 
		 * @param circle1 circle 1 to check for collisions
		 * @param circle2 circle 2 to check for collisions
		 * */
		public function CircleCircleDetector( circle1:Circle, circle2:Circle )
		{
			this.circle1 = circle1;
			this.circle2 = circle2;
		}
		
		/**
		 * Determines whether 2 circles are overlapping
		 * 
		 * <p>
		 * This method simply decides whether the circles are closer than the sum of their
		 * radii. It does so using the square of the distance to avoid an expensive square
		 * root call given the quite likely scenario that the circle's do not collide.
		 * </p>
		 * 
		 * @return true if they intersect, false otherwise
		 * */
		public function hasCollision() : Boolean
		{
			//find their relative position
			var diff:Vector = circle1.position.minus( circle2.position );
			//dot against itself to find squared distance
			dist = diff.dot( diff );
			//return whether this distance is smaller than the squared sum of their radii
			return dist <= ( circle1.radius + circle2.radius ) * ( circle1.radius + circle2.radius );
		}
		
		public function getContacts() : Array
		{
			
			//getContacts only called if collision is found- safe to evaluate actual distance
			dist = Math.sqrt( dist );
			
			//define the penetration axis as that which connects the 2 circles
			var	penetrationAxis:Vector = circle1.position.minus( circle2.position );
			//find the minimum distance necessary to resolve penetration
			var minDistance:Number = circle1.radius + circle2.radius - dist;
			//normalize
			penetrationAxis.normalize();
			
			//scale penetration axis by the minimum distance
			var penetration:Vector = penetrationAxis.times( minDistance );
			//divide this by the sum of the inverse masses so that our sloppy positional adjustments
			//are at least tied to the mass of the 2 circles
			penetration.dividedByEquals( circle1.inverseMass + circle2.inverseMass );
			
			//translate (only- no rotation) each circle out of penetration
			circle1.x += penetration.x * circle1.inverseMass;
			circle1.y += penetration.y * circle1.inverseMass;
			circle2.x -= penetration.x * circle2.inverseMass;
			circle2.y -= penetration.y * circle2.inverseMass;
			
			//define their shared point as the point of contact
			var contact:Vector = circle1.position.minus( penetrationAxis.times( circle1.radius ) );
			return [ new Contact( contact, circle1, circle2, penetrationAxis ) ];
			
		}
		
	}
}