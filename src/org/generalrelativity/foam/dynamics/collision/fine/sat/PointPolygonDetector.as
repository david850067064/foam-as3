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
 * Detects collision between a Point and IBody
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * NOTE: this needs some thought- comments to come; you should be able to
 * figure out what's going on based on PolygonPolygonDetector
 * 
 * @see IFineCollisionDetector
 * @see PolygonPolygonDetector
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class PointPolygonDetector
	{
		
		protected var body:IBody;
		protected var point:Vector;
		protected static const EPSILON:Number = 15;
		
		public function PointPolygonDetector( body:IBody, point:Vector )
		{
			this.body = body;
			this.point = point;
		}
		
		public function hasCollision() : Boolean
		{
			
			
			if( body is Circle )
			{
				var diff:Number = point.minus( body.position ).magnitude;
				if( diff <= Circle( body ).radius ) return true;
				return false;
			} 
			
			var edge:Vector; 
			
			var rotation:RotationMatrix = body.rotation;
			var totalEdges:int = body.edges.length;
			var axis:Vector;
			var proj:AxisProjection;
			var dot:Number;
			
			var i:Number = -1;
			while( ++i < totalEdges )
			{
			
				edge = rotation.getVectorProduct( body.edges[ i ] as Vector );
				
				axis = new Vector( -edge.y, edge.x );
				axis.normalize();
				
				proj = new AxisProjection( body, axis );
				dot = axis.dot( point );
				
				if( dot + PointPolygonDetector.EPSILON < proj.min || dot - PointPolygonDetector.EPSILON > proj.max ) return false;
				
			}
			
			axis = point.minus( body.position );
			axis.normalize();
			
			proj = new AxisProjection( body, axis );
			dot = axis.dot( point );
				
			if( dot + PointPolygonDetector.EPSILON < proj.min || dot - PointPolygonDetector.EPSILON > proj.max ) return false;
			
			return true;
		}
		
	}
}