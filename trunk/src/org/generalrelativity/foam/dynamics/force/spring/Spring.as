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
 * Creates a spring force
 * 
 * <p>
 * Due to the need for spring forces to update within an ISimulatable's 
 * integration, there is 1 Spring element per force generation. So, despite
 * needing 2 elements to connect, only the first element has the spring force
 * generated for. The supporting methods clone, invert and the static method
 * createDoubleSidedSpring are used to ease this duality.
 * </p>
 * 
 * <p>
 * In the future a more monolithic approach may be taken to integration such
 * that more complex forces can be calculated only once per step.
 * </p>
 * 
 * TODO: comment
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IForceGenerator
 * */
package org.generalrelativity.foam.dynamics.force.spring
{
	
	import org.generalrelativity.foam.dynamics.force.SimpleForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.math.RotationMatrix;

	public class Spring extends SimpleForceGenerator implements IForceGenerator
	{
		
		/** element to generate spring force on **/
		protected var element1:ISimulatable;
		/** element to connect "other" end of spring to **/
		protected var element2:ISimulatable; 
		/** spring coefficient (0 - 1.0) **/
		protected var k:Number;
		/** damping **/
		protected var damp:Number;
		/** the spring's happy length (where no force is generated **/
		protected var _restLength:Number;
		
		/**
		 * Constructs a new Spring
		 * 
		 * @param element1 element to generate spring force on
		 * @param element2 element to connect other end of spring to
		 * @param k spring constant
		 * @param damp damping coefficient
		 * */
		public function Spring( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.4 )
		{
			this.element1 = element1;
			this.element2 = element2;
			this.k = k;
			this.damp = damp;
			element1.addForceGenerator( this ); //add the force generator to element1
			restLength = MathUtil.distance( element1.x, element2.x, element1.y, element2.y );
		}
		
		public function set restLength( value:Number ) : void
		{
			_restLength = value;
		}
		
		override public function generate( element:ISimulatable ) : void
		{
			var diff:Vector = new Vector( element1.x - element2.x, element1.y - element2.y );
			_force = diff.times( -k * ( diff.magnitude - _restLength ) );
			_force.minusEquals( new Vector( element1.vx, element1.vy ).times( damp ) );
			element1.addForce( _force );
		}
		
		/**
		 * Clone's a Spring for use with another element
		 * 
		 * @param invert specifies whether to invert the spring so that the force gets applied
		 * to element2
		 * 
		 * @return the newly cloned Spring
		 * */
		public function clone( invert:Boolean = true ) : Spring
		{
			if( invert ) return new Spring( element2, element1, k, damp );
			return new Spring( element1, element2, k, damp );
		}
		
		/**
		 * Inverts the spring so that the force is applied to element2 instead of 1
		 * */
		public function invert() : void
		{
			element1.removeForceGenerator( this );
			var temp:ISimulatable = ISimulatable( element2 );
			element2 = element1;
			element1 = temp;
			element1.addForceGenerator( this );
		}
		
		public function getPoint1InWorldSpace() : Vector
		{
			return element1.position;
		}
		
		public function getPoint2InWorldSpace() : Vector
		{
			return element2.position;
		}
		
		/**
		 * Creates forces for both elements
		 * */
		public static function createDoubleSidedSpring( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.1 ) : void
		{
			var spring:Spring = new Spring( element1, element2, k, damp );
			spring = new Spring( element2, element1, k, damp );
		}
		
	}
}