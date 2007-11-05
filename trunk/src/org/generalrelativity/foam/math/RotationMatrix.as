package org.generalrelativity.foam.math
{
	public dynamic class RotationMatrix
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