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
 * Bungee
 * 
 * <p>
 * A bungee will only exert a pulling force if the spring is extended further than
 * its restlength
 * </p>
 * 
 * TODO: comment
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.dynamics.force.spring
{
	
	import org.generalrelativity.foam.dynamics.force.SimpleForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.display.Graphics;
	
	public class Bungee extends Spring
	{
		
		public function Bungee( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.4 )
		{
			super( element1, element2, k, damp );
		}
		
		override public function generate( element:ISimulatable ):void
		{
			var diff:Vector = new Vector( element1.x - element2.x, element1.y - element2.y );
			var magnitude:Number = diff.magnitude;
			if( magnitude <= _restLength ) return;
			_force = diff.times( -k * ( magnitude - _restLength ) );
			_force.minusEquals( new Vector( element1.vx, element1.vy ).times( damp ) );
			element1.addForce( _force );
		}
		
	}
}