package example.orbit
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.ode.solver.Euler;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.util.ShapeUtil;

	public class SimpleOrbit extends Sprite
	{
		
		public function SimpleOrbit()
		{
			
			var foam:Foam = addChild( new Foam() ) as Foam;
			foam.x = foam.y = 100;
			foam.scaleX = foam.scaleY = 0.5;
			
			var sun:Circle = new Circle( 400, 300, 60, 10000 );
			var earth:Circle = new Circle( 700, 300, 30, 100, 0, -7 );
			var eulerEarth:RigidBody = new RigidBody( 700, 300, 100, ShapeUtil.createRectangle( 60, 60 ), 0, -7 );
			
			var sunPull:GravitationalForceGenerator = new GravitationalForceGenerator( sun );
			
			earth.addForceGenerator( sunPull );
			eulerEarth.addForceGenerator( sunPull );
			
			foam.addElement( sun );
			foam.addElement( earth );
			foam.addElement( eulerEarth, false, true, null, new Euler( eulerEarth ) );
			foam.addRenderable( new Renderable( new Circle( 700, 300, 30 ) ) );
			
			foam.simulate();
			
		}
		
	}
}