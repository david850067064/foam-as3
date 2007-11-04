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
 * etc. to simulate an element.
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see SimpleParticle
 * @see IBody
 * */
package org.generalrelativity.foam.dynamics.element
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	
	public interface ISimulatable
	{
		
		/** Gets x positon **/
		function get x() : Number;
		/** Sets x position **/
		function set x( value:Number ) : void;
		/** Gets the y position **/
		function get y() : Number;
		/** Sets the y position **/
		function set y( value:Number ) : void;
		/** Gets the horizontal velocity **/
		function get vx() : Number;
		/** Sets the horizontal velocity **/
		function set vx( value:Number ) : void;
		/** Gets the vertical velocity **/
		function get vy() : Number;
		/** Sets the vertical velocity **/
		function set vy( value:Number ) : void;
		/** Gets the element's mass **/
		function get mass() : Number;
		/** Sets the element's mass **/
		function set mass( value:Number ) : void;
		/** Gets the element's inverse mass **/
		function get inverseMass() : Number;
		/** Gets the sum of all forces currently accumulated on the element **/
		function get force() : Vector;
		/** Gets the elasticity of the element (bounciness- used in collision reaction) **/
		function get elasticity() : Number;
		/** Sets the elasticity of the element (legal between 0 and 1.0) **/
		function set elasticity( value:Number ) : void;
		/** Gets the frictional coefficient of the element (used in collision response) **/
		function get friction() : Number;
		/** Sets the frictional coefficient of the element (legal between 0 and 1.0) **/
		function set friction( value:Number ) : void;
		/** Gets the position as a Vector- note that this is read-only **/
		function get position() : Vector;
		/** Gets the velocity as a Vector- note that this is read-only **/
		function get velocity() : Vector;
		/** Gets the collision type id used to map element to an appropriate collision detector **/
		function get collisionTypeID() : String;
		/** Adds a force to the element (Acceleration = Force / Mass) **/
		function addForce( force:Vector ) : void;
		/** Clears the force accumulation **/
		function clearForces() : void;
		/** Adds an IForceGenerator to the element **/
		function addForceGenerator( generator:IForceGenerator ) : void;
		/** Removes an IForceGenerator from the element **/
		function removeForceGenerator( generator:IForceGenerator ) : void;
		/** Accumulates forces from all IForceGenerators **/
		function accumulateForces() : void;
		
	}
}