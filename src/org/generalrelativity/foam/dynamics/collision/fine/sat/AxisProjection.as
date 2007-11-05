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
 * Projects a polygon onto a given axis
 * 
 * <p>
 * This type is intimately tied to SAT collision detection. By projecting a 
 * polygon onto an axis, we turn our collision detection, per axis, into a 
 * one-dimensional query.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see PolygonPolygonDetector
 * @see IBody
 * @see CircleAxisProjection
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	public class AxisProjection
	{
		
		/** minimum point of projection along axis **/
		public var min:Number;
		/** maximum point of projection along axis **/
		public var max:Number;
		
		/**
		 * Creates a new AxisProjection
		 * 
		 * @param body IBody to project onto axis
		 * @param axis axis to project onto
		 * 
		 * @see #project
		 * */
		public function AxisProjection( body:IBody, axis:Vector )
		{
			project( body, axis );
		}
		
		/**
		 * Projects the body onto the axis
		 * 
		 * @param body IBody to project
		 * @param axis Vector to project onto
		 * */
		protected function project( body:IBody, axis:Vector ) : void
		{
			
			// We need to project the rotated body onto the axis, so grab its rotation matrix
			var rotation:RotationMatrix = body.rotation;
			// dot our starting point
			var dot:Number = axis.dot( rotation.getVectorProduct( Vector( body.vertices[ 0 ] ) ).plus( body.position ) );
			
			//define both the min and max as this Number
			min = dot;
			max = dot;
			
			var i:Number = 0;
			//iterate over each vertex, updating the min/max where applicable
			while( ++i < body.vertices.length )
			{
				
				dot = axis.dot( rotation.getVectorProduct( Vector( body.vertices[ i ] ) ).plus( body.position ) );
				
				if( dot < min ) min = dot;
				else if ( dot > max ) max = dot;
				
			}
			
		}
		
		/**
		 * Gets a signed distance- negative indicates range overlap, zero indicates coincidence
		 * and positive indicates a separation
		 * 
		 * @param projection AxisProjection to compute distance with
		 * 
		 * @return signed distance
		 * 
		 * @see PolygonPolygonDetector
		 * @see AABR.isColliding() (same overlap concept in two dimensions)
		 * */
		public function getDistance( projection:AxisProjection ) : Number
		{
			if( min < projection.min ) return projection.min - max;
			return min - projection.max;
		}
		
	}
}