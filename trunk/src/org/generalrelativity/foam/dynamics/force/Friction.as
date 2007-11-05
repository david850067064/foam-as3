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
 * Applies a frictional force to an element
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ISimulatable.addForceGenerator
 * @see IForceGenerator
 * */
package org.generalrelativity.foam.dynamics.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class Friction extends SimpleForceGenerator implements IForceGenerator
	{
		
		/** coefficient of friction **/
		protected var coefficient:Number;
		
		/**
		 * Creates a new frictional force generator
		 * 
		 * @param coefficient coefficient of friction
		 * */
		public function Friction( coefficient:Number = 0.1 )
		{
			this.coefficient = coefficient;
		}
		
		/**
		 * Generates frictional force based on simulatable's velocity and coefficient of friction
		 * 
		 * @param element element to apply a force to
		 * */
		override public function generate( element:ISimulatable ) : void
		{
			element.addForce( new Vector( -element.vx * coefficient * element.mass, -element.vy * coefficient * element.mass ) );
			//if we're dealing with a body, apply a rotational damper as well
			if( element is IBody )
			{
				var body:IBody = IBody( element );
				body.addTorque( -body.av * coefficient * body.I );
			} 
		}
		
	}
}