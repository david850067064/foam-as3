package org.generalrelativity.foam.math
{
	public dynamic class RotationMatrix
	{
		
		protected var _theta:Number;
		protected var r11:Number;
		protected var r12:Number;
		protected var r21:Number;
		protected var r22:Number;
		
		public function RotationMatrix( theta:Number = 0, buildMatrix:Boolean = true )
		{
			if( buildMatrix ) this.theta = theta;
			else _theta = theta;
		}
		
		public function set theta( value:Number ) : void
		{
			
			_theta = value;
			
			r11 = Math.cos( theta );
			//r12 = -Math.sin( theta );
			r21 = Math.sin( theta );
			//r22 = Math.cos( theta );
			r12 = -r21;
			r22 = r11;
			
		}
		
		public function get theta() : Number
		{
			return _theta;
		}
		
		public function clone() : RotationMatrix
		{
			var clone:RotationMatrix = new RotationMatrix( theta, false );
			clone.r11 = r11;
			clone.r12 = r12;
			clone.r21 = r21;
			clone.r22 = r22;
			return clone;
		}
		
		public function getVectorProduct( v:Vector ) : Vector
		{
			return new Vector( r11 * v.x + r12 * v.y, r21 * v.x + r22 * v.y );
		}
		
		public function getTranspose() : RotationMatrix
		{
			
			var transpose:RotationMatrix = clone();
	
			transpose.r21 = r12;
			transpose.r12 = r21;
			transpose._theta *= -1;
			
			return transpose;
			
		}
		
	}
}