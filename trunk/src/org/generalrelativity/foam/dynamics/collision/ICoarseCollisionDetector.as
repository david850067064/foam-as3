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
 * Imposes minimum structure necessary for the <code>PhysicsEngine</code> to 
 * coarsely cull collision instances which aren't worth the more expensive fine
 * phase of detection.
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.dynamics.collision
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	
	public interface ICoarseCollisionDetector
	{
		
		/**
		 * Adds a collidable element to detect for collision
		 * 
		 * @param collidable element to add for detection
		 * 
		 * @see ISimulatable
		 * @see PhysicsEngine
		 * @see #removeCollidable
		 * */
		function addCollidable( collidable:ISimulatable ) : void;
		
		/**
		 * Removes a collidable element from coarse detection
		 * 
		 * @param collidable element to remove from detection
		 * 
		 * @see ISimulatable
		 * @see PhysicsEngine
		 * @see #removeCollidable
		 * */
		function removeCollidable( collidable:ISimulatable ) : void;
		
		/**
		 * Gets all pairwise elements that require fine collision detection
		 * 
		 * <p>
		 * As an optimization, this Array is populated with <code>IFineCollisionDetector</code>
		 * instances. In practice- when a pairwise coarse collision check yields intersection,
		 * an <code>IFineCollisionDetector</code> instance is created, rather than requiring
		 * the <code>PhysicsEngine</code> to reiterate over a two-dimensional Array.
		 * </p>
		 * 
		 * TODO: AS3 does not offer typed Arrays- it may be worthwhile in the future to change
		 * this to a typed LinkedList
		 * 
		 * @return Array of IFineCollisionDetectors representing all collisions which were not
		 * ruled out by coarse detection.
		 * 
		 * @see IFineCollisionDetector
		 * @see PhysicsEngine
		 * */
		function getCandidates() : Array;
		
		/**
		 * Gets dynamic collidable elements
		 * 
		 * @return Array of all dynamic elements
		 * */
		function getDynamicCollidables() : Array;
		
		/**
		 * Sets the ICollisionFactory used to return a certain type of IFineCollisionDetectors.
		 * 
		 * <p>
		 * This opens up the easy swappability of entire detection sets
		 * </p>
		 * 
		 * @param factory ICollisionFactory to set
		 * 
		 * @see PhysicsEngine
		 * */
		function set factory( factory:ICollisionFactory ) : void;
		
	}
}