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