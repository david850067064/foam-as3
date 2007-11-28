package example
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import flash.events.Event;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.dynamics.force.Gravity;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.Friction;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodyBungee;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import example.rocket.view.BitmapRenderer;

	public class PerpetualFall extends Sprite
	{
		
		public static const FALL_LIMIT:int = 1000;
		private var foam:Foam;
		
		public function PerpetualFall()
		{
			
			//create a FOAM instance
			foam = addChild( new Foam() ) as Foam;
			//allow the user to drag
			foam.useMouseDragger( true );
			
			foam.solverIterations = 4;
			
			//add friction and gravity as global forces
			foam.addGlobalForceGenerator( new Gravity( new Vector( 0, 1.3 ) ) );
			foam.addGlobalForceGenerator( new Friction( 0.01 ) );
			
			//add a bunch of random polygons
			for( var i:int = 0; i < 11; i++ )
			{
				
				//set up random position/size/number of vertices
				var rx:Number = 50 + Math.random() * 700;
				var ry:Number = -150 + Math.random() * 200;
				var rSize:Number = 20 + Math.random() * 40;
				var rNumVertices:Number = 2 + Math.floor( Math.random() * 5 );
				
				//create a new RigidBody
				var body:RigidBody = new RigidBody( rx, ry, rSize, ShapeUtil.createSymmetricPolygon( rNumVertices, rSize ) );
				//add the body to foam
				foam.addElement( body );
				
			}
			
			//add a circle
			foam.addElement( new Circle( 100, -100, 40 ) );
			foam.addElement( new Circle( 100, -90, 30 ) );
			
			//build the walls
			foam.addElement( new RigidBody( 0, 300, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, 600 ) ) ); //left
			foam.addElement( new RigidBody( 800, 300, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, 600 ) ) ); //right
			
			//build the ramp
			foam.addElement( new RigidBody( 250, 400, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 500, 30 ), 0, 0, 0.2, 0.25, 0.4 ) );
			
			//create 2 immovable anchors to hold up the swing
			var anchor1:RigidBody = new RigidBody( 400, 50, Simplification.INFINITE_MASS, ShapeUtil.createSymmetricPolygon( 3, 30 ) );
			var anchor2:RigidBody = new RigidBody( 600, 50, Simplification.INFINITE_MASS, ShapeUtil.createSymmetricPolygon( 3, 30 ) );
			
			//add them to FOAM- dont draw or check for collision
			foam.addElement( anchor1, false, false );
			foam.addElement( anchor2, false, false );
			
			//create the swing
			var swing:RigidBody = new RigidBody( 500, 100, 900, ShapeUtil.createRectangle( 200, 30 ) );
			//add it to FOAM
			foam.addElement( swing );
			
			//create a bungee between it and the anchor1 and add it to be rendered
			var spring:RigidBodyBungee = new RigidBodyBungee( swing, new Vector( -95, 0 ), anchor1, new Vector( 0, 1 ), 0.05 );
			foam.addRenderable( new Renderable( spring ) );
			
			//create a bungee between swing and anchor2 and add it to be rendered
			spring = new RigidBodyBungee( swing, new Vector( 95, 0 ), anchor2, new Vector( 0, 1 ), 0.05 );
			foam.addRenderable( new Renderable( spring ) );
			
			//listen for FOAM's step
			foam.addEventListener( Foam.STEP, onFoamStep, false, 0, true );
			
			foam.setRenderer( new BitmapRenderer() );
			
			//start the simulation
			foam.simulate();
			
		}
		
		private function onFoamStep( event:Event ) : void
		{
			//iterate over every element
			for each( var simulatable:ISimulatable in foam.simulatables )
			{
				//place it back up top if it's fallen too far
				if( simulatable.y > PerpetualFall.FALL_LIMIT )
				{
					simulatable.vy = 0;
					simulatable.x = 50 + Math.random() * 700;
					simulatable.y = -200;
				}
			}
		}
		
	}
}