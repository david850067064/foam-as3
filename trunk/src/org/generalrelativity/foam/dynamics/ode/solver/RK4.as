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
 * Runga Kutta 4th-Order Differential equation solver
 * 
 * <p>
 * This is a meticulous and accurate IODESolver. It evaluates the derivative
 * 4 times and then advances the state of the ODE based on a weighted
 * average of these derivatives.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IODESolver
 * @see IODE
 * @see Euler
 * */
 
package org.generalrelativity.foam.dynamics.ode.solver
{
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.ode.IODE;

	public class RK4 extends AbstractSolver implements IODESolver
	{
		
		/** Holds first found derivative **/
		private var k1:Array;
		/** Holds second found derivative **/
		private var k2:Array;
		/** Holds third found derivative **/
		private var k3:Array;
		/** Holds fourth found derivative **/
		private var k4:Array;
		
		/**
		 * Creates a new RK4 solver
		 * 
		 * @param ode IODE to solve
		 * */
		public function RK4( ode:IODE )
		{
			super( ode );
			try{
				//try to create an Array only as long as we need
				k1 = new Array( ode.state.length );
				k2 = new Array( ode.state.length );
				k3 = new Array( ode.state.length );
				k4 = new Array( ode.state.length );
			} catch( error:Error ) {
				//otherwise just build a generic Array for each derivative
				k1 = new Array();
				k2 = new Array();
				k3 = new Array();
				k4 = new Array();
			}
		}
		
		/**
		 * Advances the state of the system by dt
		 * 
		 * @param dt timestep with which to advance equation
		 * */
		override public function step( dt:Number ) : void
		{
			
			//create an Array to hold interim states
			var tempState:Array = new Array( _ode.state.length );
			//grab the current state of the equation
			var state:Array = _ode.state;
			
			var i:int = -1;
			//evaluate the derivative at this state
			_ode.getDerivative( state, k1 );
			while( ++i < state.length )
			{
				//iterate over each state/derivative to find a state halfway through
				//the timestep
				tempState[ i ] = state[ i ] + k1[ i ] * dt * 0.5;
			}
			
			i = -1;
			//use that temporary half-way state to evaluate another derivative
			_ode.getDerivative( tempState, k2 );
			while( ++i < state.length )
			{
				//iterate over each state/derivative pair to find a second state
				//halfway through the timestep
				tempState[ i ] = state[ i ] + k2[ i ] * dt * 0.5;
			}
			
			i = -1;
			//use the second found half-step state to find a derivative at the end
			//of the interval
			_ode.getDerivative( tempState, k3 );
			while( ++i < state.length )
			{
				tempState[ i ] = state[ i ] + k3[ i ] * dt;
			}
			
			i = -1;
			//use the end derivative interval to evaluate one last derivative
			_ode.getDerivative( tempState, k4 );
			while( ++i < state.length )
			{
				//finally, advance the actual state of the equation by an average of the
				//4 different derivatives, givng preference to the midpoints
				state[ i ] += dt * ( k1[ i ] + 2 * k2[ i ] + 2 * k3[ i ] + k4[ i ] ) / 6; 
			}
			
		}
		
	}
}