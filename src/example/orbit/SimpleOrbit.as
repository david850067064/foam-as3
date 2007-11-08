package example.orbit
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.ode.solver.Euler;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.util.ShapeUtil;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class SimpleOrbit extends Sprite
	{
		
		public static const START_COLOR:uint = 0x00aa00;
		public static const RK4_COLOR:uint = 0xaa0000;
		public static const EULER_COLOR:uint = 0x0000aa;
		public static const SUN_COLOR:uint = 0x111111;
		
		public function SimpleOrbit()
		{
			
			var foam:Foam = addChild( new Foam() ) as Foam;
			//scale to fit lulz
			foam.x = 200, foam.y = 100, foam.scaleX = foam.scaleY = 0.5;
			
			var sun:Circle = new Circle( 400, 300, 60, 10000 );
			var rungaKuttaEarth:Circle = new Circle( 700, 300, 30, 100, 0, -7 );
			var eulerEarth:Circle = new Circle( 700, 300, 30, 100, 0, -7 );
			
			var gravity:GravitationalForceGenerator = new GravitationalForceGenerator( sun );
			
			rungaKuttaEarth.addForceGenerator( gravity );
			eulerEarth.addForceGenerator( gravity );
			
			foam.addElement( sun, false, true, { color:SimpleOrbit.SUN_COLOR } );
			foam.addElement( rungaKuttaEarth, false, true, { color:SimpleOrbit.RK4_COLOR } );
			foam.addElement( eulerEarth, false, true, { color:SimpleOrbit.EULER_COLOR }, new Euler( eulerEarth ) );
			foam.addRenderable( new Renderable( new Circle( 700, 300, 30 ), true, { color:SimpleOrbit.START_COLOR } ) );
			
			setupLabels();
			foam.simulate();
			
		}
		
		private function setupLabels() : void
		{
			
			var yPos:int = 20;
			
			var text:TextField = new TextField();
			text.autoSize = TextFieldAutoSize.LEFT;
			text.x = 200;
			text.y = yPos;
			text.textColor = SimpleOrbit.SUN_COLOR;
			text.text = "SUN";
			addChild( text );
			
			yPos += text.height;
			
			text = new TextField();
			text.autoSize = TextFieldAutoSize.LEFT;
			text.x = 200;
			text.y = yPos;
			text.textColor = SimpleOrbit.START_COLOR;
			text.text = "STARTING POINT";
			addChild( text );
			
			yPos += text.height;
			
			text = new TextField();
			text.autoSize = TextFieldAutoSize.LEFT;
			text.x = 200;
			text.y = yPos;
			text.textColor = SimpleOrbit.EULER_COLOR
			text.text = "EULER INTEGRATION";
			addChild( text );
			
			yPos += text.height;
			
			text = new TextField();
			text.autoSize = TextFieldAutoSize.LEFT;
			text.x = 200;
			text.y = yPos;
			text.textColor = SimpleOrbit.RK4_COLOR;
			text.text = "RK4 INTEGRATION";
			addChild( text );
			
		}
		
	}
}