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
 * Axis-Aligned Bounding Rectangle
 * 
 * <p>
 * An AABR is a rectangle with 2 sides parallel to the world x-axis and the other 2
 * parallel to the world y-axis. It bounds a more complicated (or rotated) geometry.
 * Collision detection between 2 AABRs is inexpensive. This is used for coarse-level
 * collision detection to cull elements that aren't colliding.
 * </p>
 * 
 * TODO: Find a way to generalize bounding volumes (areas in 2D)
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IBody
 * @see AABRDetector
 * */
package org.generalrelativity.foam.dynamics.collision.geom
{
	
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	
	public class AABR
	{
		
		/** minimum point on body along world x-axis */
		public var minX:Number;
		/** minimum point on body along world y-axis */
		public var minY:Number;
		/** maximum point on body along world x-axis */
		public var maxX:Number;
		/** maximum point on body along world y-axis */
		public var maxY:Number;
		
		/**
		 * Indicates whether instance is intersecting with <code>rect</code>
		 * 
		 * <p>
		 * This is a simple algorithm. If the furthest reaching extent of 1 body
		 * along the x-axis is LESS than the least reaching extent of the other
		 * body in question, the AABR's do NOT overlap. This query is repeated 
		 * along each axis in each direction. 
		 * </p>
		 * 
		 * @param rect AABR to check for collision against instance
		 * 
		 * @return true if the AABRs are coincident, false otherwise
		 * */
		public function hasCollision( rect:AABR ) : Boolean
		{
			if( maxX < rect.minX ) return false;
			if( maxY < rect.minY ) return false;
			if( rect.maxX < minX ) return false;
			if( rect.maxY < minY ) return false;
			//if none of our outs work, the 2 rectangles collide- return true
			return true;
		}
		
		/**
		 * Positions this AABR to bound the given body as tightly as possible
		 * 
		 * <p>
		 * TODO: This is obviously pretty sloppy and needs to be thought out- it's
		 * important that optimizations are decoupled as much as possible from the
		 * nuts & bolts of what is needed to simulate. Otherwise it would make 
		 * sense to include these methods within the RigidBody class for instance.
		 * </p>
		 * 
		 * <p>
		 * In all likelihood it will end up being treated much like the solution of
		 * ODEs. Rigid bodies will implement IBoundable and there will be a 
		 * getBoundingVolume method. This would solve the current sloppy type check,
		 * amongst other things.
		 * </p>
		 * 
		 * @param body IBody to bound
		 * 
		 * @see AABRDetector
		 * @see #updateBounds
		 * */
		public function bound( body:IBody ) : void
		{
			
			//if it's a circle, its radius offers the AABR extents
			if( body is Circle )
			{
				var r:Number = Circle( body ).radius;
				minX = body.x - r;
				maxX = body.x + r;
				minY = body.y - r;
				maxY = body.y + r;
			} 
			else 
			{
				//set initial values so our less than/greater than bounding determination
				//yields proper results
				minX = maxX = body.x;
				minY = maxY = body.y;
				
				//we have to transform each vertex about the body's rotation
				var rotation:RotationMatrix = body.rotation;
				var i:int = -1;
				for each( var vertex:Vector in body.vertices )
				{
					//update the bounds
					updateBounds( body.position.plus( rotation.getVectorProduct( vertex ) ) );
				}
			}
		}
		
		/**
		 * Update the bounds of this AABR if the vertex exists outside of the current extents
		 * 
		 * @param vertex <code>Vector</code> to update bounds with.
		 * 
		 * @see #bound
		 * */
		private function updateBounds( vertex:Vector ) : void
		{
			if( vertex.x < minX ) minX = vertex.x;
			else if( vertex.x > maxX ) maxX = vertex.x;
			if( vertex.y < minY ) minY = vertex.y;
			else if( vertex.y > maxY ) maxY = vertex.y;
		}
		
	}
}