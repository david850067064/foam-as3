package org.generalrelativity.foam.dynamics.force.spring
{
	import org.generalrelativity.foam.dynamics.force.GenericForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.display.Graphics;

	public class Spring extends GenericForceGenerator implements IForceGenerator
	{
		
		protected var element1:ISimulatable;
		protected var element2:ISimulatable; 
		protected var k:Number;
		protected var damp:Number;
		protected var _restLength:Number;
		
		public function Spring( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.4 )
		{
			this.element1 = element1;
			this.element2 = element2;
			this.k = k;
			this.damp = damp;
			element1.addForceGenerator( this );
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
		
		public function clone( invert:Boolean = true ) : Spring
		{
			if( invert ) 
			{
				if( element2 is ISimulatable ) return new Spring( ISimulatable( element2 ), element1, k, damp );
				else return null;
			}
			return new Spring( element1, element2, k, damp );
		}
		
		public function invert() : void
		{
			if( element2 is ISimulatable )
			{
				element1.removeForceGenerator( this );
				var temp:ISimulatable = ISimulatable( element2 );
				element2 = element1;
				element1 = temp;
				element1.addForceGenerator( this );
			} else throw new Error( "cannot create Spring Force Generator on unmovable Element" );
			
			
		}
		
		public static function createDoubleSidedSpring( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.1 ) : void
		{
			var spring:Spring = new Spring( element1, element2, k, damp );
			spring = new Spring( element2, element1, k, damp );
		}
		
	}
}