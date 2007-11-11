package example.orbit.force
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.enum.Simplification;

	public class GravitationalForceGenerator implements IForceGenerator
	{
		
		/** gravitational constant **/
		protected var g:Number;
		/** source of gravitational pull (references mass) **/
		protected var source:ISimulatable;
		
		/**
		 * Creates the Force Generator
		 * 
		 * @param source source of gravitational pull
		 * @param gravitationalConstant magic constant (trial and error per simulation)
		 * 
		 * @throws ArgumentError if source has infinite mass
		 * */
		public function GravitationalForceGenerator( source:ISimulatable, gravitationalConstant:Number = 1.2 )
		{
			//if the source's mass is infinite, we'll break the simulation- throw an error
			if( source.mass == Simplification.INFINITE_MASS ) throw new ArgumentError( "Infinite mass breaks this force generator" );
			this.source = source;
			g = gravitationalConstant;
		}
		
		/**
		 * Generates the gravitational force on the supplied element
		 * 
		 * <p>
		 * We find the source through the following equation:
		 * <pre>
		 * F = G * m1 * m2 / r^2
		 * </pre>
		 * where:
		 * <pre>
		 * F is the force we're solving for (applied along the bodies' difference vector)
		 * G is a gravitational constant
		 * m1/m2 are the masses involved in the exchange (here, the force is only applied to element)
		 * r is the distance between the bodies
		 * </pre></p>
		 * 
		 * @param element ISimulatable to apply force to
		 * */
		public function generate( element:ISimulatable ) : void
		{
			//find the difference vector
			var diff:Vector = source.position.minus( element.position );
			//add our solved force along the difference vector to the supplied element
			element.addForce( diff.getUnit().times( g * source.mass * element.mass / diff.dot( diff ) ) );
		}
		
	}
}