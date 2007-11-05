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
 * Abstracts an implementation of IODESolver
 * 
 * <p>
 * NOTE: you should not instantiate this class
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IODESolver
 * */
package org.generalrelativity.foam.dynamics.ode.solver
{
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.ode.IODE;

	public class AbstractSolver implements IODESolver
	{
		
		/** equation to solve **/
		protected var _ode:IODE;
		
		/**
		 * Constructs a new AbstractSolver
		 * 
		 * @param ode equation to solve 
		 * */
		public function AbstractSolver( ode:IODE ) : void
		{
			_ode = ode;
		}
		
		public function get ode() : IODE
		{
			return _ode;
		}
		
		public function step( dt:Number ) : void
		{
			throw new Error( "AbstractSolver.step must be overridden" );
		}
		
	}
}