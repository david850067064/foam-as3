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
 * Rotation Matrix
 * 
 * | r11 r12 |
 * | r21 r22 |
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.math
{
	public class RotationMatrix
	{
		
		protected var _theta:Number;
		protected var r11:Number;
		protected var r12:Number;
		protected var r21:Number;
		protected var r22:Number;
		
		public function RotationMatrix( theta:Number = 0 )
		{
			this.theta = theta;
		}
		
		public function set theta( value:Number ) : void
		{
			
			_theta = value;
			
			r11 = Math.cos( theta );
			r21 = Math.sin( theta );
			r12 = -r21;
			r22 = r11;
			
		}
		
		public function get theta() : Number
		{
			return _theta;
		}
		
		public function getVectorProduct( v:Vector ) : Vector
		{
			return new Vector( r11 * v.x + r12 * v.y, r21 * v.x + r22 * v.y );
		}
		
		public function getTransposeVectorProduct( v:Vector ) : Vector
		{
			return new Vector( r11 * v.x + r21 * v.y, r12 * v.x + r22 * v.y );
		}
		
	}
}