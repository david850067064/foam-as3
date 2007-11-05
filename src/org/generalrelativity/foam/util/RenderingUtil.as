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
 * Useful drawing routines
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.util
{
	import flash.display.Graphics;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	
	public class RenderingUtil
	{
		
		public static function drawVector( graphics:Graphics, vector:Vector, x:Number = 0, y:Number = 0, tipSize:Number = 3 ) : void
		{
			
			graphics.moveTo( x, y );
			
			var tip:Vector = vector.getUnit().times( tipSize );
			var projection:Vector = Vector.project( Math.atan2( vector.y, vector.x ) - Math.PI / 2, tipSize );
			
			graphics.lineTo( x + vector.x, y + vector.y );
			graphics.lineTo( x + vector.x + projection.x, y + vector.y + projection.y );
			graphics.lineTo( x + vector.x + tip.x, y + vector.y + tip.y );
			
			projection.negate();
			
			graphics.lineTo( x + vector.x + projection.x, y + vector.y + projection.y );
			graphics.lineTo( x + vector.x, y + vector.y );
			graphics.endFill();
			
		}
		
		public static function drawHash( graphics:Graphics, x:Number, y:Number, rotation:RotationMatrix, hashSize:int = 3, radius:int = 8 ) : void
		{
			graphics.lineStyle( 1 );
			var s:Vector = rotation.getVectorProduct( new Vector( -hashSize, -hashSize ) );
			graphics.moveTo( x + s.x, y + s.y );
			s = rotation.getVectorProduct( new Vector( hashSize, hashSize ) );
			graphics.lineTo( x + s.x, y + s.y );
			s = rotation.getVectorProduct( new Vector( -hashSize, hashSize ) );
			graphics.moveTo( x + s.x, y + s.y );
			s = rotation.getVectorProduct( new Vector( hashSize, -hashSize ) );
			graphics.lineTo( x + s.x, y + s.y );
			graphics.drawCircle( x, y, radius );
			
		}
		
	}
}