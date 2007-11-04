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
 * This is not currently supported- This should be better thought out and included
 * in the next releast of FOAM. To have any simulational worth, a serious culling
 * mechanism must be implemented specific to bezier curves.
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.dynamics.element.body
{
	
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;
	
	public class CubicBezierCurve extends RigidBody
	{
		
		protected var resolution:int;
		protected var control1:Vector;
		protected var control2:Vector;
		protected var anchor1:Vector;
		protected var anchor2:Vector;
		protected var height:Number;
		
		public var lines:Array;
		
		public function CubicBezierCurve( 
								x:Number, 
								y:Number, 
								control1:Vector,
								anchor1:Vector,
								control2:Vector,
								anchor2:Vector,
								resolution:int = 7,
								mass:Number = Number.POSITIVE_INFINITY, 
								vx:Number = 0, 
								vy:Number = 0, 
								q:Number = 0,
								av:Number = 0,
								friction:Number = 0.2,
								elasticity:Number = 0.15,
								height:Number = 150 )
								
		{
			
			super( x, y, mass, null, vx, vy, friction, elasticity, q, av );
			this.height = height;
			this.resolution = resolution;
			this.control1 = control1;
			this.control2 = control2;
			this.anchor1 = anchor1;
			this.anchor2 = anchor2;
			createLines();
		}
		
		protected function createLines() : void
		{
			var i:int;
			
			var interval:Number;
			var intervalSq:Number;
			var intervalCu:Number;
			var diff:Number;
			var diffSq:Number;
			var diffCu:Number;
			var inverse:Number = 1 / resolution;
			var px:Number;
			var py:Number;
			var ox:Number = control1.x;
			var oy:Number = control1.y;
			lines = new Array();
			
			while( ++i <= resolution )
			{
				
				interval = inverse * i;
				intervalSq = interval * interval;
    			intervalCu = intervalSq * interval;
    			diff = 1 - interval;
    			diffSq = diff * diff;
    			diffCu = diffSq * diff;
    			
    			px = diffCu * control1.x + 3 * interval * diffSq * anchor1.x + 3 * anchor2.x * intervalSq * diff + control2.x * intervalCu;
	    		py = diffCu * control1.y + 3 * interval * diffSq * anchor1.y + 3 * anchor2.y * intervalSq * diff + control2.y * intervalCu;
	    		
	    		var dx:Number = px - ox;
	    		var dy:Number = py - oy;
	    		
	    		var line:RigidBody = new RigidBody( x + ox + dx / 2, y + oy + dy / 2, Simplification.INFINITE_MASS, [ new Vector( dx / 2, dy / 2 ), new Vector( -dx / 2, -dy / 2 ) ], 0, 0, 0, 0, friction );
	    		ox = px;
	    		oy = py;
	    		lines.push( line );
	    		
			}
			
		}
		
		override protected function calculateInertiaTensor() : void
		{
			
			if( mass == Simplification.INFINITE_MASS )
			{
				_I = Simplification.INFINITE_MASS;
				_inverseI = 0;
				return;
			}
			_I = control1.magnitude * mass / 3;
			_I += control2.magnitude * mass / 3;
			_I += anchor1.magnitude * mass / 3 * 0.5;
			_I += anchor2.magnitude * mass / 3 * 0.5;
			_inverseI = 1 / _I;
		}
		
		override public function get collisionTypeID() : String
		{
			return CollisionType.CUBIC_BEZIER_CURVE;
		}
								
	}
}