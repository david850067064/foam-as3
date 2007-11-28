package example.rocket
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.Foam;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.util.ShapeUtil;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import example.rocket.view.BitmapFoamRenderer;
	import org.generalrelativity.foam.dynamics.force.Gravity;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.Friction;
	import example.rocket.force.ThrustForceGenerator;
	import flash.events.Event;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.view.SimpleFoamRenderer;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import org.generalrelativity.foam.dynamics.force.spring.Spring;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodyBungee;
	import org.generalrelativity.foam.view.Renderable;
	import example.orbit.force.GravitationalForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import example.rocket.view.DisplayObjectFoamRenderer;
	import example.rocket.view.DisplayObjectData;
	import flash.display.Shape;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Rocket extends Sprite
	{
		
		[Embed(source="../../../bin/images/rocket/lunarPod.png")]
		private var rocketSpriteClass:Class;
		
		[Embed(source="../../../bin/images/rocket/asteroid.png")]
		private var asteroidSpriteClass:Class;
	
		private var rocket:RigidBody;
		private var foam:Foam;
		
		public function Rocket()
		{
			
			foam = addChild( new Foam() ) as Foam;
			
			foam.setRenderer( new DisplayObjectFoamRenderer() );
			foam.useMouseDragger( true );
			
			rocket = buildRocket();
			rocket.addForceGenerator( new Friction( 0.01 ) );
			foam.addElement( rocket, true, true, new DisplayObjectData( rocketSpriteClass, 0, -5 ) );
			
			buildLabels();
			
			addEventListener( Event.ENTER_FRAME, onEnterFrame, false, 0, true );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
			
			var timer:Timer = new Timer( 500 );
			timer.addEventListener( TimerEvent.TIMER, asteroidBomb, false, 0, true );
			timer.start();
			
		}	
		
		private function asteroidBomb( event:TimerEvent = null ) : void
		{
			if( foam.simulatables.length < 20 ) 
			{
				var sx:Number = Math.random() > 0.7 ? 890 : -90;
				var sy:Number = Math.random() * 600;
				var svx:Number = sx > 0 ? Math.random() * -20 - 5 : Math.random() * 20 + 5;
				var svy:Number = -2 + Math.random() * 4;
				var size:Number = 20 + Math.random() * 50;
				size = Math.min( size, 64 );
				var asteroidSprite:DisplayObject = new asteroidSpriteClass();
				asteroidSprite.scaleX = asteroidSprite.scaleY = size / 64;
				var asteroid:Circle = new Circle( sx, sy, size, size * 4, svx, svy, 0.5, 0.25, 0, -0.1 + Math.random() * 0.2 );
				foam.addElement( asteroid, true, true, new DisplayObjectData( asteroidSprite ) );
			}
		}
		
		private function onMouseUp( event:Event = null ) : void
		{
			foam.setRenderer( new DisplayObjectFoamRenderer() );
		}
		
		private function onMouseDown( event:Event = null ) : void
		{
			foam.setRenderer( new BitmapFoamRenderer() );
		}
		
		private function onEnterFrame( event:Event = null ) : void
		{
			if( rocket.x < -40 ) rocket.x = 830;
			if( rocket.x > 840 ) rocket.x = -30;
			if( rocket.y > 640 ) rocket.y = -30;
			if( rocket.y < -40 ) rocket.y = 630;
			for each( var asteroid:ISimulatable in foam.simulatables )
			{
				if( asteroid == rocket ) continue;
				if( asteroid.x < -110 || asteroid.x > 910 || asteroid.y > 710 ||asteroid.y < -110 )
				{
					foam.removeElement( asteroid );
				}
			}
			
		}
		
		private function onAddedToStage( event:Event ) : void
		{
			rocket.addForceGenerator( new ThrustForceGenerator( stage ) );
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			
			foam.simulate();
			
		}
		
		private function buildRocket() : RigidBody
		{
			var shape:Array = new Array( 5 );
			shape[ 0 ] = new Vector( -30, -40 );
			shape[ 1 ] = new Vector( 0, -50 );
			shape[ 2 ] = new Vector( 30, -40 );
			shape[ 3 ] = new Vector( 30, 40 );
			shape[ 4 ] = new Vector( -30, 40 );
			var body:RigidBody = new RigidBody( 500, 450, 100, shape, 0, 0, 0.2, 0.25, -Math.PI / 2 );
			return body;
		}
		
		private function buildLabels() : void
		{
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.textColor = 0xffffff;
			tf.text = "mouse down/up to swap renderers, arrow keys to move rocket";
			addChild( tf );
		}
		
	}
	
}