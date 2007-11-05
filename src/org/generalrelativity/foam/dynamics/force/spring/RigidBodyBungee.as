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
 * Bungee attached to a point on a body
 * 
 * TODO: comment
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
	
	public class RigidBodyBungee extends RigidBodySpring
	{
		
		/**
		 * Creates a new RigidBodyBungee
		 * 
		 * @param body1 first body involved in bungee
		 * @param point1 point on body1 given in relative coordinates
		 * @param body2 second body attached to bungee
		 * @param point2 point on body2 given in relative coordinates
		 * @param k spring constant
		 * @param damp damping coefficient
		 * */
		public function RigidBodyBungee( body1:IBody, point1:Vector, body2:IBody, point2:Vector, k:Number = 0.01, damp:Number = 0.01 )
		{
			super( body1, point1, body2, point2, k, damp );
		}
		
		override public function generate( element:ISimulatable ) : void 
		{
			const t1:RotationMatrix = IBody( element1 ).rotation;
			var trans1:Vector = t1.getVectorProduct( point1 );
			var pointInWorldSpace1:Vector = trans1.plus( element1.position );
			const t2:RotationMatrix = IBody( element2 ).rotation;
			var trans2:Vector = t2.getVectorProduct( point2 );
			var pointInWorldSpace2:Vector = trans2.plus( element2.position );
			var diff:Vector = new Vector( pointInWorldSpace1.x - pointInWorldSpace2.x, pointInWorldSpace1.y - pointInWorldSpace2.y );
			var magnitude:Number = diff.magnitude;
			if( magnitude <= _restLength ) return;
			_force = diff.times( -k * ( diff.magnitude - _restLength ) );
			_force.minusEquals( IBody( element1 ).getVelocityAtPoint( trans1 ).times( damp ) );
			IBody( element1 ).addForceAtPoint( trans1, _force );
		}
		
		
		
		override public function clone( invert:Boolean = true ) : Spring
		{
			if( invert ) return new RigidBodyBungee( IBody( element2 ), point2, IBody( element1 ), point1, k, damp );
			return new RigidBodyBungee( IBody( element1 ), point1, IBody( element2 ), point2, k, damp );
		}
		
	}
}