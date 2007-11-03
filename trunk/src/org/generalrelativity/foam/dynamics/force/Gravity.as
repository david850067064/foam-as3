package org.generalrelativity.foam.dynamics.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;

	public class Gravity extends GenericForceGenerator implements IForceGenerator
	{
		
		public function Gravity( force:Vector ) 
		{
			super( force );
		}
		
		override public function generate( element:ISimulatable ) : void
		{
			element.addForce( _force.times( element.mass ) );
		}
		
	}
}