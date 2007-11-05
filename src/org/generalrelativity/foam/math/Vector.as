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
 * Two-Dimensional Vector
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.math
{
	
	

	public class Vector
	{
		
		public var x:Number;
		public var y:Number;
		
		
		/**
		 * Constructor
		 * 
		 * @param x defines {@link #x}
		 * @param y defines {@link #y}
		 **/
		public function Vector( x:Number = 0, y:Number = 0 )
		{
			this.x = x;
			this.y = y;	
		}
		
		
		/**
		 * Adds a Vector to the instance
		 * Note that this alters the instance
		 * 
		 * @param v Vector to add
		 * */
		public function plusEquals( v:Vector ) : void
		{
			x += v.x;
			y += v.y;
		}
		
		
		/**
		 * Gets the sum of the instance and passed Vector
		 * Note that this does NOT alter the instance
		 * 
		 * @param v Vector to add to instance
		 * @return sum of v and instance
		 * */
		public function plus( v:Vector ) : Vector
		{
			return new Vector( x + v.x, y + v.y );
		}
		
		
		/**
		 * Subtracts a Vector from the instance
		 * Note that this alters the Vector
		 * 
		 * @param v Vector to minusEquals
		 * */
		public function minusEquals( v:Vector ) : void
		{
			x -= v.x;
			y -= v.y;
		}
		
		
		/**
		 * Gets the difference of the instance and passed Vector
		 * Note that this does NOT alter the instance
		 * 
		 * @param v Vector to minusEquals from instance
		 * @return difference of v from instance
		 * */
		public function minus( v:Vector ) : Vector
		{
			return new Vector( x - v.x, y - v.y );
		}
		
		
		/**
		 * Multiplies the instance by a scalar
		 * Note that this alters the Vector
		 * 
		 * @param scalar scalar by which to timesEquals
		 * */
		public function timesEquals( scalar:Number ) : void
		{
			x *= scalar;
			y *= scalar;
		}
		
		
		/**
		 * Gets the product of the instance and passed scalar
		 * Note that this does NOT alter the instance
		 * 
		 * @param scalar scalar by which to timesEquals
		 * @return product of instance and scalar
		 * */
		public function times( scalar:Number ) : Vector
		{
			return new Vector( x * scalar, y * scalar );
		}
		
		
		
		/**
		 * Divides the instance by a scalar
		 * Note that this alters the Vector
		 * 
		 * @param scalar scalar by which to divide
		 * */
		public function dividedByEquals( scalar:Number ) : void
		{
			x /= scalar;
			y /= scalar;
		}
		
		
		/**
		 * Gets the quotient of the instance and passed scalar
		 * Note that this does NOT alter the instance
		 * 
		 * @param scalar scalar by which to divide
		 * @return quotient of instance and scalar
		 * */
		public function dividedBy( scalar:Number ) : Vector
		{
			return new Vector( x / scalar, y / scalar );
		}
		
		
		/**
		 * Gets the magnitude of the instance
		 * 
		 * @return magnitude of the Vector
		 * */
		public function get magnitude() : Number
		{
			return Math.sqrt( x * x + y * y );
		}
		
		
		/**
		 * Normalizes the Vector
		 * Note that this alters the instance
		 * */
		public function normalize() : void
		{
			dividedByEquals( magnitude );
		}
		
		
		/**
		 * Gets the unit or normalized Vector
		 * Note that this does NOT alter the instance
		 * 
		 * @return unit Vector (magntiude = 1)
		 * */
		public function getUnit() : Vector
		{
			return dividedBy( magnitude );
		}
		
		
		/**
		 * Gets the dot product of the Vector and instance
		 * 
		 * @param v Vector to evaluate dot product with
		 * @return the dot product of v and the instance
		 * */
		public function dot( v:Vector ) : Number
		{
			return x * v.x + y * v.y;
		}
		
		
		/**
		 * Gets the cross product of the Vector and instance
		 * 
		 * @param v Vector to evaluate cross product with
		 * @return cross product of v and instance
		 * */
		public function cross( v:Vector ) : Number
		{
			return x * v.y - y * v.x;
		}
		
		
		public function getPerp() : Vector
		{
			return new Vector( -y, x );
		}
		
		
		/**
		 * Returns a Vector identical to the instance
		 * */
		public function clone() : Vector
		{
			return new Vector( x, y );
		}
		
		
		
		public function negate() : void
		{
			x *= -1;
			y *= -1;
		}
		
		public function crossScalar( scalar:Number ) : Vector
		{
			return new Vector( -scalar * y, scalar * x );
		}
		
		
		public function getAngle( v:Vector ) : Number
		{
			return Math.atan2( v.y - y, v.x - x );
		}
		
		
		
		public static function project( theta:Number, magnitude:Number ) : Vector
		{
			return new Vector( Math.cos( theta ) * magnitude, Math.sin( theta ) * magnitude );
		}
		
		
	}
}