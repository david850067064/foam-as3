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
 * Drags bodies with Mouse
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.dynamics.force.spring
{
	import org.generalrelativity.foam.dynamics.force.SimpleForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.display.Graphics;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class MouseSpring extends SimpleForceGenerator implements IForceGenerator
	{
		
		protected var body:IBody;
		protected var point:Vector;
		protected var displayObject:DisplayObject;
		protected var restLength:Number;
		protected var k:Number;
		protected var damp:Number;
		
		public function MouseSpring( body:IBody, point:Vector, displayObject:DisplayObject )
		{
			this.body = body;
			this.point = body.rotation.getTransposeVectorProduct( point );
			this.displayObject = displayObject;
			restLength = 40;
			k = 0.001;
			damp = 0.3;
			body.addForceGenerator( this );
		}
		
		override public function generate( element:ISimulatable ) : void
		{
				
			var t1:RotationMatrix = body.rotation;
			var trans1:Vector = t1.getVectorProduct( point );
			var pointInWorldSpace1:Vector = getPointInWorldSpace();
			var diff:Vector = new Vector( pointInWorldSpace1.x - displayObject.mouseX, pointInWorldSpace1.y - displayObject.mouseY );
			if( diff.magnitude < restLength ) return;
			
			_force = diff.times( -k * ( diff.magnitude - restLength ) );
			_force.minusEquals( body.velocity.times( damp ) );
			
			body.addForceAtPoint( trans1, _force );
			
		}
		
		public function destroy() : void
		{
			body.removeForceGenerator( this );
		}
		
		public function getPointInWorldSpace() : Vector
		{
			var t1:RotationMatrix = body.rotation;
			var trans1:Vector = t1.getVectorProduct( point );
			return trans1.plus( body.position );
		}
		
	}
}