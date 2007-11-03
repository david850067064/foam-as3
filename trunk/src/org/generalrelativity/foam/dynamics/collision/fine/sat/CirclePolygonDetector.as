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
 * Detects a collision between a circle and a convex polygon. Convexity is assumed.
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
 * @see AxisProjection
 * @see CircleAxisProjection
 * @see IFineCollisionDetector
 * @see Contact
 * @see PhysicsEngine
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.collision.Contact;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	
	public class CirclePolygonDetector implements IFineCollisionDetector
	{
		
		/** Circle to detect **/
		public var circle:Circle;
		/** IBody to detect **/
		public var body:IBody;
		/** minimum distance along the pentration axis required to resolve penetration */
		public var minDistance:Number;
		/** most direct vector out of penetration */
		public var penetrationAxis:Vector;
		
		/**
		 * Creates a new CirclePolygonDetector
		 * 
		 * @param circle Circle to check for collision
		 * @param body body to check for collision against
		 * */
		public function CirclePolygonDetector( circle:Circle, body:IBody ) 
		{
			this.circle = circle;
			this.body = body;
		}
		
		/**
		 * Determines whether the <code>#circle</code> and <code>#body</code> are intersecting.
		 * 
		 * <p>
		 * We check each axis as a contender for separation between the bodies. It's usually
		 * quite more likely in an application that objects AREN'T intersecting. For that 
		 * reason, this algorithm is constructed such that it terminates as soon as possible
		 * given non-intersection. It's good to think of collision as absolute worst case
		 * scenario- its detection and resolution are the most processor intensive aspects
		 * of FOAM.
		 * </p>
		 * 
		 * <p>
		 * With the case of a circle, we check each of the polygon's offered axes and then the
		 * axis that's created between the closest vertex on the polygon and the Circle.
		 * </p>
		 * 
		 * @return true given penetration, false otherwise
		 * 
		 * @see AxisProjection
		 * @see CircleAxisProjection
		 * @see PolygonPolygonDetector (in depth commenting in-algorithm)
		 * */
		public function hasCollision() : Boolean
		{
			
			if( circle.inverseMass == 0 && body.inverseMass == 0 ) return false;
			
			var edge:Vector;
			var proj1:CircleAxisProjection
			var proj2:AxisProjection;
			
			var rotation:RotationMatrix = body.rotation;
			
			minDistance = Number.MAX_VALUE;
			var edges:Array = body.edges;
			var totalEdges:int = edges.length;
			
			//polygon edges
			var i:Number = -1;
			while( ++i < totalEdges )
			{
			
				edge = rotation.getVectorProduct( edges[ i ] as Vector );
				
				var axis:Vector = new Vector( -edge.y, edge.x );
				axis.normalize();
				
				proj1 = new CircleAxisProjection( circle, axis );
				proj2 = new AxisProjection( body, axis );
				
				var projectionDistance:Number = proj1.getDistance( proj2 );
				if( projectionDistance > 0 ) return false;
				
				projectionDistance = Math.abs( projectionDistance );
				if( projectionDistance < minDistance )
				{
					minDistance = projectionDistance;
					penetrationAxis = axis;
				}
				
			}
			
			//find polygon vertex closest to circle
			var temp:Vector;
			var closestDistance:Number = Number.MAX_VALUE;
			for each( var vertex:Vector in body.vertices )
			{
				temp = body.rotation.getVectorProduct( vertex ).plus( body.position );
				var diff:Vector = circle.position.minus( temp );
				var distanceSquared:Number = ( diff.x * diff.x + diff.y * diff.y );
				
				if( distanceSquared < closestDistance )
				{
					closestDistance = distanceSquared;
					axis = diff;
				}
			}
			
			axis.normalize();
				
			proj1 = new CircleAxisProjection( circle, axis );
			proj2 = new AxisProjection( body, axis );
			
			//just like PolygonPolygonDetector, if the distance between the 2 projected ranges is
			//greater than zero- exit the algorithm
			projectionDistance = proj2.getDistance( proj1 );
			if( projectionDistance > 0 ) return false;
			
			projectionDistance = Math.abs( projectionDistance );
			if( projectionDistance < minDistance )
			{
				minDistance = projectionDistance;
				penetrationAxis = axis;
			}
			
			return true;
		}
		
		/**
		 * Gets point of contact in world-coordinates
		 * 
		 * <p>
		 * In the case of Circle vs. anything, there will be at most 1 point of contact. That point
		 * of contact will always be on the circle's edge and can be found by moving out from the
		 * circle's position in the direction of the penetration axis by the length of the radius.
		 * </p>
		 * 
		 * @return Array with single Contact
		 * 
		 * @see PolygonPolygonDetector.getContacts
		 * */
		public function getContacts() : Array
		{
			
			//find the relative position between the bodies
			var diff:Vector = circle.position.minus( body.position );
			if( diff.dot( penetrationAxis ) < 0 ) penetrationAxis.negate();
			
			//scale the penetrationAxis by minDistance to find the displacement amount necessary
			//to resolve penetration
			var penetration:Vector = penetrationAxis.times( minDistance );
			//divide this by the sum of the inverse masses so that our sloppy positional adjustments
			//are at least tied to the mass of the 2 bodies
			penetration.dividedByEquals( circle.inverseMass + body.inverseMass );
			
			//translate (only- no rotation) the circle and body out of penetration
			circle.x += penetration.x * circle.inverseMass;
			circle.y += penetration.y * circle.inverseMass;
			body.x -= penetration.x * body.inverseMass;
			body.y -= penetration.y * body.inverseMass;
			
			//return the single point of contact
			var contact:Vector = circle.position.minus( penetrationAxis.times( circle.radius ) );
			return [ new Contact( contact, circle, body, penetrationAxis ) ];
			
			
		}
		
	}
}