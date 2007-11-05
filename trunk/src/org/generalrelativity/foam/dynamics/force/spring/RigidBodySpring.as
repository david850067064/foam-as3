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
 * Spring attached to a point on a body
 * 
 * TODO: comment
 * TODO: override clone
 * TODO: override invert
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see Spring
 * */
package org.generalrelativity.foam.dynamics.force.spring
{
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.Graphics;
	
	public class RigidBodySpring extends Spring
	{
		
		protected var point1:Vector;
		protected var point2:Vector;
		
		/**
		 * Creates a new RigidBodySpring
		 * 
		 * @param body1 first body involved in spring
		 * @param point1 point on body1 given in relative coordinates
		 * @param body2 second body attached to spring
		 * @param point2 point on body2 given in relative coordinates
		 * @param k spring constant
		 * @param damp damping coefficient
		 * */
		public function RigidBodySpring( body1:IBody, point1:Vector, body2:IBody, point2:Vector, k:Number = 0.01, damp:Number = 0.01 )
		{
			super( body1, body2, k, damp );
			this.point1 = point1;
			this.point2 = point2;
			var t1:Vector = body1.rotation.getVectorProduct( point1 );
			var t2:Vector = body2.rotation.getVectorProduct( point2 );
			restLength = MathUtil.distance( body1.x + t1.x, body2.x + t2.x, body1.y + t1.y, body2.y + t2.y );
		}
		
		override public function generate( element:ISimulatable ) : void 
		{
			const t1:RotationMatrix = IBody( element1 ).rotation;
			var trans1:Vector = t1.getVectorProduct( point1 );
			var pointInWorldSpace1:Vector = trans1.plus( new Vector( element1.x, element1.y ) );
			const t2:RotationMatrix = IBody( element2 ).rotation;
			var trans2:Vector = t2.getVectorProduct( point2 );
			var pointInWorldSpace2:Vector = trans2.plus( new Vector( element2.x, element2.y ) );
			var diff:Vector = new Vector( pointInWorldSpace1.x - pointInWorldSpace2.x, pointInWorldSpace1.y - pointInWorldSpace2.y );
			_force = diff.times( -k * ( diff.magnitude - _restLength ) );
			_force.minusEquals( IBody( element1 ).getVelocityAtPoint( trans1 ).times( damp ) );
			IBody( element1 ).addForceAtPoint( trans1, _force );
		}
		
		override public function getPoint1InWorldSpace() : Vector
		{
			var t:RotationMatrix = IBody( element1 ).rotation;
			var trans:Vector = t.getVectorProduct( point1 );
			return trans.plus( element1.position );
		}
		
		override public function getPoint2InWorldSpace() : Vector
		{
			var t:RotationMatrix = IBody( element2 ).rotation;
			var trans:Vector = t.getVectorProduct( point2 );
			return trans.plus( element2.position );
		}
		
		override public function clone( invert:Boolean = true ) : Spring
		{
			if( invert ) return new RigidBodySpring( IBody( element2 ), point2, IBody( element1 ), point1, k, damp );
			return new RigidBodySpring( IBody( element1 ), point1, IBody( element2 ), point2, k, damp );
		}
		
	}
}