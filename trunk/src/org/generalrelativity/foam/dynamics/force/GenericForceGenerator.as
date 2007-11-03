package org.generalrelativity.foam.dynamics.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;

	public class GenericForceGenerator implements IForceGenerator
	{
		
		protected var _force:Vector;
		
		public function GenericForceGenerator( force:Vector = null ) : void
		{
			_force = force;
		}
		
		public function generate( element:ISimulatable ):void
		{
			element.addForce( _force );
		}
		
	}
}