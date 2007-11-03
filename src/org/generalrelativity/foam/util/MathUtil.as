package org.generalrelativity.foam.util
{
	public class MathUtil
	{
		
		public static function distance( x1:Number, x2:Number, y1:Number, y2:Number ) : Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
		public static function clamp( low:Number, high:Number, value:Number ) : Number
		{
			if( value < low ) return low;
			if( value > high ) return high;
			return value;
		}
		
	}
}