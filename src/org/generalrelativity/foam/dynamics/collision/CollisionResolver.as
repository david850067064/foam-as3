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
 * Monolithic rigid body impulse-based collision resolver
 * 
 * <p>
 * This class with its lone static method is used by the <code>PhysicsEngine</code>
 * to resolve all found collisions for each iteration in its step. Because all
 * resolution is (currently) handled identically, the <code>PhysicsEngine</code>
 * can blindly pass all the contacts generated by its collision detector(s).
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
 
package org.generalrelativity.foam.dynamics.collision
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	public class CollisionResolver
	{
		
		
		/**
		 * Resolves an Array of pairwise Contacts
		 * 
		 * <p>
		 * All rigid body contact resolution is handled identically. The
		 * collision detector ultimately narrows down an Array of type
		 * <code>Contact</code>. Each pairwise contact is explicitly
		 * resolved.
		 * </p>
		 * 
		 * <p>
		 * The collision detector currently resolves penetration, so the
		 * contact points are legal- that is along the bodies, not within
		 * (doing pairwise detection/resolution which handles penetration
		 * by directly altering positon results in often-faulty contact 
		 * generation when an object is in contact with more than 1 object). 
		 * Solving this issue and all sorts of surrounding problems is a work 
		 * in progress.
		 * </p>
		 * 
		 * <p>
		 * The equation being solved/applied here is:
		 * <pre>
		 * j = -(1 + e)rV . n / (n . n(iM1 + iM2) + (pv1 . n)^2 / I1 + (pv2 . n)^2 / I2)
		 * </pre>
		 * where:
		 * <pre>
		 * j = impulse to apply at contact point on both bodies (positive for body 1, negative for body2).
		 * e = coefficient of restitution (elasticity of colliding objects)
		 * rV = relative velocity of objects at collision point
		 * n = collision normal (Vector pointing perpindicularly outward from incident edge)
		 * iM1 = inverse mass of body 1
		 * iM2 = inverse mass of body 2
		 * pv1 = velocity of body 1 at point of contact
		 * pv2 = velocity of body 2 at point of contact
		 * I1 = intertia tensor of body 1 (scalar in 2D)
		 * I2 = intertia tensor of body 2 (scalar in 2D)
		 * </pre></p>
		 * 
		 * @param contacts Array of contacts to resolve
		 * 
		 * @see Contact
		 * @see PhysicsEngine
		 * @see IFineCollisionDetector.generateContacts
		 * @see IBody.friction
		 * @see IBody.elasticity
		 * */
		public static function resolve( contacts:Array ) : void
		{
			
			//declare properties for holding the bodies in contact
			
			//because we could conceivably resolve all collisions at 
			//once, they need to be defined for each contact
			var body1:IBody;
			var body2:IBody;
			
			//iterate over each given contact
			for each( var contact:Contact in contacts )
			{
				
				//define bodies in contact
				body1 = contact.body1;
				body2 = contact.body2;
				
				/***** contact resolution impulse *****/
				
				//define contact point relative to each body (point given in world coordinates)
				var contact1:Vector = contact.position.minus( contact.body1.position );
				var contact2:Vector = contact.position.minus( contact.body2.position );
				
				//define perpindicular vector to each relative contact
				var contactPerp1:Vector = contact1.getPerp();
				var contactPerp2:Vector = contact2.getPerp();
				
				//dot this along the contact normal
				var contactPerpNorm1:Number = contactPerp1.dot( contact.normal );
				var contactPerpNorm2:Number = contactPerp2.dot( contact.normal );
				
				//define the denominator of the impulse
				var impulseDenominator:Number = contact.normal.dot( contact.normal.times( body1.inverseMass + body2.inverseMass ) ); 
				impulseDenominator += contactPerpNorm1 * contactPerpNorm1 * body1.inverseI;
				impulseDenominator += contactPerpNorm2 * contactPerpNorm2 * body2.inverseI;
				
				//find the velocity of each body at the point of contact
				var velocityAtContact1:Vector = contactPerp1.times( body1.av ).plus( body1.velocity );
				var velocityAtContact2:Vector = contactPerp2.times( body2.av ).plus( body2.velocity );
				
				//define the relative velocity at the point of contact
				var relativeVelocity:Vector = velocityAtContact1.minus( velocityAtContact2 );
				
				//dot this onto the contact normal
				var rvNorm:Number = relativeVelocity.dot( contact.normal );
				
				var restitution:Number;
				
				if( rvNorm > -3 )
				{
					restitution = 0;
					if( rvNorm > -0.01 ) return;
				} 
				else
				{
				
					//find the coefficient of restitution for this collision based upon each
					//body's elasticity property
					restitution = ( body1.elasticity + body2.elasticity ) * 0.5;
				}
				
				//solve for the impulse to apply to each body
				var impulse:Number = -( 1 + restitution ) * rvNorm / impulseDenominator;
				
				//apply this along the contact normal for the change in linear velocity for body1
				//this vector will collect the frictional impulse as well
				var dlv1:Vector = contact.normal.times( impulse * body1.inverseMass );
				//apply this along the normal's perpindicular vector for angular velocity change
				var dav1:Number = contactPerp1.dot( contact.normal.times( impulse ) ) * body1.inverseI;
				
				//apply this along the contact normal for the change in linear velocity for body2
				//this vector will collect the frictional impulse as well
				var dlv2:Vector = contact.normal.times( -impulse * body2.inverseMass );
				//apply this along the normal's perpindicular vector for angular velocity change
				var dav2:Number = contactPerp2.dot( contact.normal.times( -impulse ) ) * body2.inverseI;
				
				
				/***** frictional impulse *****/
				
				//define a tangent vector for friction calculation
				var tangent:Vector = contact.normal.getPerp();
				
				//dot this along our relative tangent
				var contactPerpTangent1:Number = contactPerp1.dot( tangent );
				var contactPerpTangent2:Number = contactPerp2.dot( tangent );
				
				//define our equation's denominator for friction impulse just as we did with contact resolution impulse
				impulseDenominator = tangent.dot( tangent.times( body1.inverseMass + body2.inverseMass ) ); 
				impulseDenominator += contactPerpTangent1 * contactPerpTangent1 * body1.inverseI;
				impulseDenominator += contactPerpTangent2 * contactPerpTangent2 * body2.inverseI;
				
				//define the relative velocity along the tangent
				var rvTangent:Number = relativeVelocity.dot( tangent );
				
				//solve for the frictional impulse to add to each body at contact
				impulse = -rvTangent / impulseDenominator * ( body1.friction + body2.friction ) * 0.5;
				
				//apply this along the contact normal for the change in linear velocity for body1
				dlv1.plusEquals( tangent.times( impulse * body1.inverseMass ) );
				//apply this along the normal's perpindicular vector for angular velocity change
				dav1 += contactPerp1.dot( tangent.times( impulse ) ) * body1.inverseI;
				
				//apply this along the contact normal for the change in linear velocity for body2
				dlv2.plusEquals( tangent.times( -impulse * body2.inverseMass ) );
				//apply this along the normal's perpindicular vector for angular velocity change
				dav2 += contactPerp2.dot( tangent.times( -impulse ) ) * body2.inverseI;
				
				//finally, apply our found change in linear and angular velocity to each body
				body1.vx += dlv1.x;
				body1.vy += dlv1.y;
				body1.av += dav1;
				
				body2.vx += dlv2.x;
				body2.vy += dlv2.y;
				body2.av += dav2;
				
			}
			
		}
		
	
		
	}
}