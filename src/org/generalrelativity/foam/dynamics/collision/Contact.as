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
 * Depicts pairwise contact information
 * 
 * <p>
 * To resolve collisions, the <code>CollisionResolver</code> needs to know both bodies
 * involved, the point of contact in world coordinates, and the collision
 * normal (points outward from incident edge). 
 * </p>
 * 
 * TODO: This needs to eventually be generalized to allow for particles
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see PolygonPolygonDetector.getContacts
 * @see CollisionResolver
 * */
package org.generalrelativity.foam.dynamics.collision
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	public class Contact
	{
		
		/** Point of contact in world coordinates **/
		public var position:Vector;
		/** First body involved in collision (arbitrary) **/
		public var body1:IBody;
		/** Second body involved in collision (arbitrary) **/
		public var body2:IBody;
		/** Collision normal **/
		public var normal:Vector;
		
		/**
		 * Creates a new contact
		 * 
		 * @param position point of contact in world coordinates
		 * @param body1 first body involved in collision
		 * @param body2 second body involved in collision
		 * @param normal contact normal
		 * */
		public function Contact( position:Vector, body1:IBody, body2:IBody, normal:Vector )
		{
			this.position = position;
			this.body1 = body1;
			this.body2 = body2;
			this.normal = normal;	
		}
		
	}
}