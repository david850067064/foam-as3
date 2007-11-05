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
 * Projects a circle onto a given axis
 * 
 * <p>
 * This type is intimately tied to SAT collision detection. By projecting a 
 * circle onto an axis, we turn our collision detection, per axis, into a 
 * one-dimensional query.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see CirclePolygonDetector
 * @see IBody
 * @see AxisProjection
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	public class CircleAxisProjection extends AxisProjection
	{
		
		/**
		 * Creates a new CircleAxisProjection
		 * 
		 * @param circle Circle to project onto axis
		 * @param axis axis to project onto
		 * 
		 * @see #project
		 * */
		public function CircleAxisProjection( circle:Circle, axis:Vector )
		{
			super( circle, axis );
		}
		
		/**
		 * Projects the circle onto the axis
		 * 
		 * @param body IBody to project
		 * @param axis Vector to project onto
		 * 
		 * @see AxisProjection.project
		 * */
		override protected function project( body:IBody, axis:Vector ) : void
		{
			var circle:Circle = Circle( body );
			var projection:Number = axis.dot( circle.position );
			min = projection - circle.radius;
			max = projection + circle.radius;
		}
		
	}
}