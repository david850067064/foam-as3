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
 * Defines a structure to implement a collision detector factory.
 * 
 * <p>
 * The current release, 0.1, includes a SATCollisionFactory- all of 
 * the collision detection classes are SAT-based. The factory's job
 * is to evaluate and return the correct <code>IFineCollisionDetecto</code>
 * based upon 2 given <code>ISimulatable</code> instances. The entire
 * collision detection scheme can be swapped easily by simply creating
 * a new implementor of ICollisionFactory and have it return from a 
 * different pool of collision detectors.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ICoarseCollisionDetector
 * */
package org.generalrelativity.foam.dynamics.collision
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	
	public interface ICollisionFactory
	{
		
		/**
		 * Gets the collision detector this factory determines based on the supplied elements
		 * 
		 * @param element1 first element to consider
		 * @param element2 second element to consider
		 * 
		 * @return implementor of IFineCollisionDetector to be used by the <code>PhysicsEngine</code>
		 * to ultimately determine collision and to generate contacts
		 * 
		 * @see ICoarseCollisionDetector.getCandidates
		 * */
		function getCollisionDetector( element1:ISimulatable, element2:ISimulatable ) : IFineCollisionDetector;
		
	}
	
}