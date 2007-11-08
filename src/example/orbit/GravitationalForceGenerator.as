package example.orbit
{
	import org.generalrelativity.foam.dynamics.force.SimpleForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;

	public class GravitationalForceGenerator extends SimpleForceGenerator
	{
		
		protected var gravitationalConstant:Number;
		protected var source:ISimulatable;
		
		public function GravitationalForceGenerator( source:ISimulatable, gravitationalConstant:Number = 1.2 )
		{
			this.source = source;
			this.gravitationalConstant = gravitationalConstant;
		}
		
		override public function generate( element:ISimulatable ) : void
		{
			var diff:Vector = source.position.minus( element.position );
			element.addForce( diff.getUnit().times( gravitationalConstant * source.mass * element.mass / diff.dot( diff ) ) );
		}
		
	}
}