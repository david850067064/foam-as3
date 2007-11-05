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
 * Detects a collision between 2 convex polygons. Convexity is assumed.
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
 * @see IFineCollisionDetector
 * @see Contact
 * @see PhysicsEngine
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	
	import org.generalrelativity.foam.math.Vector;
	import flash.display.Graphics;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.collision.CollisionResolver;
	import org.generalrelativity.foam.dynamics.collision.Contact;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class PolygonPolygonDetector implements IFineCollisionDetector
	{
		
		/** first body in detection */
		public var body1:IBody;
		/** second body in detection */
		public var body2:IBody;
		/** minimum distance along the pentration axis required to resolve penetration */
		public var minDistance:Number;
		/** most direct vector out of penetration */
		public var penetrationAxis:Vector;
		/** a negligible optimization **/
		private var swapBodies:Boolean;
		
		/** margin for parallel determination in multi-point contact */
		public static const EPSILON:Number = 0.1;
		
		/**
		 * Creates a new PolygonPolygonDetector
		 * 
		 * @param body1 first body in detection
		 * @param body2 second body in detection
		 * */
		public function PolygonPolygonDetector( body1:IBody, body2:IBody ) 
		{
			this.body1 = body1;
			this.body2 = body2;
			swapBodies = true;
		}
		
		/**
		 * Determines whether the 2 bodies are intersecting.
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
		 * @return true given penetration, false otherwise
		 * 
		 * @see AxisProjection
		 * */
		public function hasCollision() : Boolean
		{
			
			//if both bodies have infinite mass, there's no need to perform this check
			if( body1.inverseMass == 0 && body2.inverseMass == 0 ) return false;
			
			//declare a Vector to hold the current edge from which to derive an axis to check
			var edge:Vector;
			
			//declare AxisProjections with which to test overlap
			var proj1:AxisProjection
			var proj2:AxisProjection;
			
			//we have to project the rotated polygon- start with body 1
			var rotation:RotationMatrix = body1.rotation;
			
			//start minDistance insurmountably high
			minDistance = Number.MAX_VALUE;
			//concatenate all edges
			var edges:Array = body1.edges.concat( body2.edges );
			var totalEdges:int = edges.length;
			
			//iterate over all edges
			var i:Number = -1;
			while( ++i < totalEdges )
			{
			
				//once we've gone through all of body 1's edges, redefine rotation as body 2's rotation matrix
				if( i == body1.edges.length ) rotation = body2.rotation;
				edge = rotation.getVectorProduct( edges[ i ] as Vector );
				
				//define the axis to project onto (normal to edge)
				var axis:Vector = new Vector( -edge.y, edge.x );
				//normalize
				axis.normalize();
				
				//project each polygon onto this axis
				proj1 = new AxisProjection( body1, axis );
				proj2 = new AxisProjection( body2, axis );
				
				//find the distance between the 2 projections (ranges)
				var projectionDistance:Number = proj1.getDistance( proj2 );
				//if the distance between them is grater than zero, they are separated along this axis
				//we immediately terminate the algorithm, returning false
				if( projectionDistance > 0 ) return false;
				
				//faster than Math.abs-> wtf!?
				projectionDistance = projectionDistance < 0 ? -projectionDistance : projectionDistance; //Math.abs( projectionDistance );
				if( projectionDistance < minDistance )
				{
					//reset minDistance to this distance
					minDistance = projectionDistance;
					//update the penetration axis to this axis
					penetrationAxis = axis;
					//if we're on to body2's edges, we shouldn't swap when generating contacts
					if( swapBodies && i > body1.edges.length ) swapBodies = false;
					
				}
				
			}
			
			//if we haven't terminated the algorithm, the object's intersect along all axes- return true
			return true;
			
		}
		
		/**
		 * Generates contacts based on found collision.
		 * 
		 * <p>
		 * Given 2 convex polygons there are 3 different contact scenarios:
		 * <pre>
		 * 1. Vertex - Edge
		 * 2. Edge - Edge
		 * 3. Vertex - Vertex
		 * </pre>
		 * The third (vertex-vertex) is so unlikely that we can disregard it all together. 
		 * Edge - edge is reduced from what can be seen as an infinite number of contact
		 * points (line on line), to 2 (innermost vertices). Vertex - edge works as is.
		 * </p>
		 * 
		 * <p>
		 * First step in defining the contact point in world coordinates is resolving any
		 * penetration. Once resolved, the bodies' shared point(s) is the contact point(s).
		 * Each found point is built into a <code>Contact</code> instance and returned in an 
		 * Array.
		 * </p>
		 * 
		 * <p>
		 * In determining contact points, we once again consider the 3 scenarios above. 
		 * Remembering that we're ignoring vertex - vertex, we're left needing a means to
		 * determine whether we're dealing with vertex - edge or edge - edge. What we do is
		 * iterate over each vertex, finding the point furthest along the <code>penetrationAxis</code>.
		 * In the more likely case of vertex - edge, we'll find 1 vertex on 1 body and 2 on the 
		 * other. The 2 constitute the body's edge involved in contact- This means we can take
		 * the single point on the other body as our point of contact. If, however, we find 2 
		 * points as the extreme on each body, we're dealing with edge - edge. In this scenario
		 * we use the middle 2 vertices involved as the 2 points of contact.
		 * </p>
		 * 
		 * @return Array of contacts 
		 * 
		 * @see Contact
		 * @see PhysicsEngine
		 * */
		public function getContacts() : Array
		{
			
			//currently defined body2 more likely to offer single vertex (gives easy out)
			//swap bodies to check body2 first
			if( swapBodies )
			{
				var temp:IBody = body1;
				body1 = body2;
				body2 = temp;
			}
			
			//find the relative position between the bodies
			var diff:Vector = body1.position.minus( body2.position );
			if( diff.dot( penetrationAxis ) < 0 ) penetrationAxis.negate();
			
			//scale the penetrationAxis by minDistance to find the displacement amount necessary
			//to resolve penetration
			var penetration:Vector = penetrationAxis.times( minDistance );
			//divide this by the sum of the inverse masses so that our sloppy positional adjustments
			//are at least tied to the mass of the 2 bodies
			penetration.dividedByEquals( body1.inverseMass + body2.inverseMass );
			
			//translate (only- no rotation) each body out of penetration
			body1.x += penetration.x * body1.inverseMass;
			body1.y += penetration.y * body1.inverseMass;
			body2.x -= penetration.x * body2.inverseMass;
			body2.y -= penetration.y * body2.inverseMass;
			
			//define min as an insurmountable value
			var min:Number = Number.MAX_VALUE;
			
			//declare Array to store contact candidates
			var contacts1:Array;
			
			//possibly need to negate penetrationAxis for body2- clone it
			var axis:Vector = penetrationAxis.clone();
			var rotation:RotationMatrix = body1.rotation;
			
			//iterate over each vertex and find the one furthest down penetrationAxis
			for each( var vertex:Vector in body1.vertices )
			{
				//transform and translate to get the candidate in world coordinates
				var candidate:Vector = rotation.getVectorProduct( vertex ).plus( body1.position );
				//project this along the axis
				var proj:Number = axis.dot( candidate );
				//if it's less than our current minimum, proceed
				if( proj < min + PolygonPolygonDetector.EPSILON )
				{
					//if it's within a certain range of our current minimum, the points are close to being
					//parallel along this axis- body1 possibly has an edge involved in contact.
					//we cannot terminate the algorithm yet though as multiple points may be parallel along
					//this axis
					if( Math.abs( min - proj ) < PolygonPolygonDetector.EPSILON )
					{
						//construct the contacts1 as these 2 parallel points
						contacts1 = [ contacts1[ 0 ], candidate ];
					} 
					else 
					{
						//construct as an array of this one point in world space
						contacts1 = [ candidate ];
						//reset the min
						min = proj;
					}
					
				}
			}
			
			//based on the assumptions listed above- if only one candidate has passed, we know we can use it alone
			//as the point of contact- we can exit the algorithm with this lone contact
			if( contacts1.length == 1 ) return [ new Contact( contacts1[ 0 ], body1, body2, penetrationAxis ) ];
			
			//otherwise repeat for body 2 ->
			
			min = Number.MAX_VALUE;
			axis.negate();
			rotation = body2.rotation;
			
			var contacts2:Array;
			
			for each( vertex in body2.vertices )
			{
				candidate = rotation.getVectorProduct( vertex ).plus( body2.position );
				proj = axis.dot( candidate );
				if( proj < min + PolygonPolygonDetector.EPSILON )
				{
					if( Math.abs( min - proj ) < PolygonPolygonDetector.EPSILON )
					{
						contacts2 = [ contacts2[ 0 ], candidate ];
					} else {
						contacts2 = [ candidate ];
						min = proj;
					}
					
				}
			}
			
			var contacts:Array = new Array();
			//if we've come this far in the algorithm, there are 2 vertices involved in contact that belong to body1
			//if there are also 2 involved from body2, we have edge - edge contact; define these points
			if( contacts2.length == 2 )
			{
				
				//TODO: this is REALLY sloppy and cumbersome- probably really slow as well... come up with at least
				//a HALF decent solution here
				
				//switch to work along the incident edge (perpindicular to the contact normal) and normalize
				var contactAxis:Vector = penetrationAxis.getPerp().getUnit();
				//define a dictionary to map a projection along this axis to its respective contact candidate
				var cp:Dictionary = new Dictionary( true );
				var proj1:Number = contactAxis.dot( contacts1[ 0 ] as Vector );
				var proj2:Number = contactAxis.dot( contacts1[ 1 ] as Vector );
				var proj3:Number = contactAxis.dot( contacts2[ 0 ] as Vector );
				var proj4:Number = contactAxis.dot( contacts2[ 1 ] as Vector );
				cp[ proj1 ] = contacts1[ 0 ];
				cp[ proj2 ] = contacts1[ 1 ];
				cp[ proj3 ] = contacts2[ 0 ];
				cp[ proj4 ] = contacts2[ 1 ];
				
				//create an array to sort by this projection- we want the middle 2, so we take indices 1 & 2
				var projections:Array = [ proj1, proj2, proj3, proj4 ];
				projections.sort( Array.DESCENDING );
				//push both these contacts into the Array
				contacts.push( new Contact( cp[ projections[ 1 ] ], body1, body2, penetrationAxis ), new Contact( cp[ projections[ 2 ] ], body1, body2, penetrationAxis ) );
			}//otherwise, we're dealing with a single vertex from body2
			else contacts.push( new Contact( contacts2[ 0 ], body1, body2, penetrationAxis ) );
			
			return contacts;
		
		}
		
		
	}
}