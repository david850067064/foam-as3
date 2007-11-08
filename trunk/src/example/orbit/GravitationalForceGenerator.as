package example.orbit
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;

	public class GravitationalForceGenerator implements IForceGenerator
	{
		
		/** gravitational constant **/
		protected var g:Number;
		protected var source:ISimulatable;
		
		public function GravitationalForceGenerator( source:ISimulatable, g:Number = 1.2 )
		{
			this.source = source;
			this.g = g;
		}
		
		public function generate( element:ISimulatable ) : void
		{
			var diff:Vector = source.position.minus( element.position );
			element.addForce( diff.getUnit().times( g * source.mass * element.mass / diff.dot( diff ) ) );
		}
		
	}
}