package org.generalrelativity.foam.dynamics.force
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	
	public interface IForceGenerator
	{
		
		function generate( element:ISimulatable ) : void;
		
	}
}