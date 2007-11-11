package example
{
	
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.force.Friction;

	public class ZeroGravityToyChest extends Sprite
	{
		
		public function ZeroGravityToyChest()
		{
			
			//create a new FOAM interface for managing the simulation
			var foam:Foam = addChild( new Foam() ) as Foam;
			//add friction as a global force
			foam.addGlobalForceGenerator( new Friction( 0.015 ) );
			//allow user to drag elements around
			foam.useMouseDragger( true );
			
			foam.solverIterations = 2;
			
			//add a bunch of random polygons
			for( var i:int = 0; i < 22; i++ )
			{
				
				//set up random position/size/number of vertices
				var rx:Number = 50 + Math.random() * 700;
				var ry:Number = 50 + Math.random() * 500;
				var rSize:Number = 20 + Math.random() * 30;
				var rNumVertices:Number = 2 + Math.floor( Math.random() * 5 );
				
				//create a new RigidBody
				var body:RigidBody = new RigidBody( rx, ry, rSize * 10, ShapeUtil.createSymmetricPolygon( rNumVertices, rSize ) );
				//add the body to foam
				foam.addElement( body );
				
			}
			
			//build the walls
			foam.addElement( new RigidBody( 0, 300, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, 600 ) ) ); //left
			foam.addElement( new RigidBody( 800, 300, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 20, 600 ) ) ); //right
			foam.addElement( new RigidBody( 400, 0, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 800, 20 ) ) ); //top
			foam.addElement( new RigidBody( 400, 600, Simplification.INFINITE_MASS, ShapeUtil.createRectangle( 800, 20 ) ) ); //bottom
			
			//start the simulation
			foam.simulate();
			
		}
		
	}
	
}