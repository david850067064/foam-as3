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
 * Applies a gravitational force to an element
 * 
 * <p>
 * Gravity in simulation applies a mass-ignorant force.
 * </p>
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

	public class Gravity extends SimpleForceGenerator implements IForceGenerator
	{
		
		/**
		 * Constructs a new Gravity force generator
		 * 
		 * @param force vector representing gravitational force to apply to element(s)
		 * */
		public function Gravity( force:Vector ) 
		{
			super( force );
		}
		
		/**
		 * Generates a gravitational force on the given element
		 * 
		 * <p>
		 * Note that the force is scaled by the element's mass. At the simplest level,
		 * this makes elements "fall at the same rate" regardless of mass.
		 * </p>
		 * 
		 * @param element element to apply gravity to
		 * */
		override public function generate( element:ISimulatable ) : void
		{
			element.addForce( _force.times( element.mass ) );
		}
		
	}
}