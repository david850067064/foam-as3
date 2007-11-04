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
 * Defines all necessary methods for <code>Foam</code>, <code>PhysicsEngine</code>
 * etc. to simulate a body.
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see RigidBody
 * @see Circle
 * @see ISimulatable
 * */
package org.generalrelativity.foam.dynamics.element
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	
	public interface IBody extends ISimulatable
	{
		
		/** Gets the rotation (in radians) of the body */
		function get q() : Number;
		/** Sets the rotation (in radians) of the body */
		function set q( value:Number ) : void;
		/** Gets the angular velocity of the body */
		function get av() : Number;
		/** Sets the angular velocity of the body */
		function set av( value:Number ) : void;
		/** Gets the inertia tensor of the body (rotational equivalent to mass) */
		function get I() : Number;
		/** Gets the inverse inertia tensor of the body */
		function get inverseI() : Number;
		/** Gets all vertices associated with the body */
		function get vertices() : Array;
		/** Gets all edges associated with the body */
		function get edges() : Array;
		/** Adds torque to the body */
		function addTorque( torque:Number ) : void;
		/** Clears all torque **/
		function clearTorque() : void;
		/** Adds force at a specific point on the body (affects linear and (possibly) angular momentum) */
		function addForceAtPoint( point:Vector, force:Vector ) : void;
		/** Gets the velocity at the given point **/
		function getVelocityAtPoint( point:Vector ) : Vector;
		/** Gets the rotation matrix of the body (used to transform its geometry) **/
		function get rotation() : RotationMatrix;
	}
}