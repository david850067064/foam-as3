package org.generalrelativity.foam.dynamics.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class Friction extends GenericForceGenerator implements IForceGenerator
	{
		
		protected var coefficient:Number;
		
		public function Friction( coefficient:Number = 0.1 )
		{
			this.coefficient = coefficient;
		}
		
		override public function generate( element:ISimulatable ) : void
		{
			element.addForce( new Vector( -element.vx * coefficient * element.mass, -element.vy * coefficient * element.mass) );
			if( element is IBody )
			{
				var body:IBody = IBody( element );
				body.addTorque( -body.av * coefficient * body.I );
			} 
		}
		
	}
}