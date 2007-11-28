package example.rocket.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import flash.ui.Keyboard;

	public class ThrustForceGenerator implements IForceGenerator
	{
		
		
		protected var _thrust:Number;
		protected var _torque:Number;
		
		private var keyLeft:uint;
		private var keyRight:uint;
		private var keyThrust:uint;
		private var leftDown:Boolean;
		private var rightDown:Boolean;
		private var thrustDown:Boolean;
		
		public function ThrustForceGenerator( stage:Stage, keyThrust:uint = Keyboard.UP, keyLeft:uint = Keyboard.LEFT, keyRight:uint = Keyboard.RIGHT )
		{
			this.keyThrust = keyThrust;
			this.keyLeft = keyLeft;
			this.keyRight = keyRight;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp, false, 0, true );
			thrust = 50;
			torque = 1000;
		}
		
		public function set thrust( value:Number ) : void
		{
			_thrust = value;
		}
		
		public function set torque( value:Number ) : void
		{
			_torque = value;
		}
		
		public function generate( element:ISimulatable ) : void
		{
			
			try
			{
				if( thrustDown ) element.addForce( IBody( element ).rotation.getVectorProduct( new Vector( 0, -_thrust ) ) );
				if( leftDown ) IBody( element ).addTorque( -_torque );
				if( rightDown ) IBody( element ).addTorque( _torque );
			} 
			catch( error:TypeError ) 
			{
				//ISimulatable does not implement IBody- unable to add torque
				error.message = "element must be implementor of IBody to have torque applied";
				throw error;
			}
		}
		
		/**
		 * Handles KeyboardEvent.KEY_DOWN
		 * */
		private function onKeyDown( event:KeyboardEvent ) : void
		{
			switch( event.keyCode )
			{
				case keyLeft :
				leftDown = true;
				break;
				
				case keyRight :
				rightDown = true;
				break;
				
				case keyThrust :
				thrustDown = true;
				break;
				
			}
		}
		
		/**
		 * Handles KeyboardEvent.KEY_UP
		 * */
		private function onKeyUp( event:KeyboardEvent ) : void
		{
			switch( event.keyCode )
			{
				case keyLeft :
				leftDown = false;
				break;
				
				case keyRight :
				rightDown = false;
				break;
				
				case keyThrust :
				thrustDown = false;
				break;
				
			}
		}
		
	}
}