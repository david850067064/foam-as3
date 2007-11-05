package example
{
	
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.dynamics.force.Gravity;
	import org.generalrelativity.foam.math.Vector;
	import flash.events.Event;
	import org.generalrelativity.foam.view.SimpleFoamRenderer;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodySpring;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodyBungee;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.dynamics.ode.solver.Euler;

	public class SimpleExample extends Sprite
	{
		
		private var foam:Foam;
		
		public function SimpleExample()
		{
			
			foam = new Foam();
			foam.defaultSolver = Euler;
			addChild( foam );
			
			var body:RigidBody = new RigidBody( 100, 100, 40, ShapeUtil.createSymmetricPolygon( 4 ) );
			var body2:RigidBody = new RigidBody( 300, 200, 50, ShapeUtil.createSymmetricPolygon( 5, 100 ) );
			foam.addElement( body );
			foam.addElement( body2 );
			var spring:RigidBodySpring = new RigidBodySpring( body, new Vector( -30, 0 ), body2, new Vector( -20, 10 ), 0.007, 0.3 );
			foam.addRenderable( new Renderable( spring ) );
			spring = new RigidBodySpring( body, new Vector( 30, 0 ), body2, new Vector( -20, 10 ), 0.007, 0.3 );
			foam.addRenderable( new Renderable( spring ) );
			foam.addGlobalForceGenerator( new Gravity( new Vector( 0, 1.3 ) ) );
			foam.useMouseDragger( true );
			
			//foam.stopSimulating( body );
			//foam.stopColliding( body );
			
			foam.simulate();
			
		}
		
	}
	
}