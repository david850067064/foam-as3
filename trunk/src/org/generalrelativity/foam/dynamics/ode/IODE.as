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
 * Imposes a structure that allows an <code>IODESolver</code> to advance its
 * state. ODE stands for "Ordinary Differential Equation."
 * 
 * <p>
 * Although we sacrifice a decent amount of efficiency by stuffing our states
 * and derivatives into Arrays, we gain a tremendous amount of modularity and
 * extensibility. Provided an object implements IODE, and adheres to its
 * structure, a completely swappable IODESolver can advance its state. In other
 * words, it effectively decouples integration.
 * </p>
 * 
 * <p>
 * This implementation is a simplified interpretation of the one presented in
 * Open-Source Physics: http://www.opensourcephysics.org/
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IODESolver
 * @see SimpleParticle
 * */
package org.generalrelativity.foam.dynamics.ode
{
	
	public interface IODE
	{
		
		/**
		 * Gets the state of the differential equation
		 * 
		 * <p>
		 * Consider a particle with position x and velocity v. We want to
		 * integrate this state with respect to time. The position and 
		 * velocity are pushed into the particle's state Array and solved
		 * by an IODESolver. By abstracting the process this far, we make
		 * it easy to swap solvers for different tasks.
		 * </p>
		 * 
		 * @return Array of Numbers to integrate with respect to time
		 * 
		 * @see #getDerivative
		 * @see IODESolver
		 * */
		function get state() : Array;
		
		/**
		 * Populates the derivative according to the given state.
		 * 
		 * <p>
		 * The IODESolver asks the IODE for its derivative- depending on the
		 * order and structure of the solver, this could happen numerous times
		 * per time step. It is the IODE's job to use that state to determine
		 * its derivative.</p>
		 * 
		 * <p>
		 * The derivative's indices map to the state's. 
		 * </p>
		 * 
		 * @param state state with which to evaluate derivative
		 * @param derivative, Array to populate given state's derivatives with
		 * 
		 * @see #state
		 * @see IODESolver
		 * @see SimpleParticle
		 * */
		function getDerivative( state:Array, derivative:Array ) : void;
		
	}
	
}