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
 * Euler differential equation solver
 * 
 * <p>
 * This solver simply finds the derivative and applies it directly to the state
 * to advance the equation
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IODESolver
 * @see IODE
 * @see RK4
 * */
package org.generalrelativity.foam.dynamics.ode.solver
{
	
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.ode.IODESolver;

	public class Euler extends AbstractSolver implements IODESolver
	{
		
		/** holds the derivative **/
		private var derivative:Array;
		
		/**
		 * Creates a new Euler solver
		 * 
		 * @param ode IODE to solve
		 * */
		public function Euler( ode:IODE )
		{
			super( ode );
			try{
				//try to create an Array only as long as we need
				derivative = new Array( _ode.state.length );
			} catch( error:Error ) {
				//otherwise create an open ended array
				derivative = new Array();
			}
			
		}
		
		/**
		 * Advances the state of the equation by the supplied timestep
		 * 
		 * @param dt timestep by which to advance
		 * */
		override public function step( dt:Number ) : void
		{
			
			//get the original state
			var state:Array = _ode.state;
			//get the derivative based on that state
			_ode.getDerivative( state, derivative ); 
			
			var i:int = -1;
			while( ++i < state.length )
			{
				//advance the state by the derivative
				state[ i ] += derivative[ i ] * dt;
			}
			
		}
		
	}
}