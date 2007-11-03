package org.generalrelativity.foam.dynamics.force
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.ui.Keyboard;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class KeyDrivenTorqueGenerator implements IForceGenerator
	{
		
		private var torque:Number;
		private var keyLeft:uint;
		private var keyRight:uint;
		private var leftDown:Boolean;
		private var rightDown:Boolean;
		
		public function KeyDrivenTorqueGenerator( stage:Stage, torque:Number = 3000, keyLeft:uint = Keyboard.LEFT, keyRight:uint = Keyboard.RIGHT )
		{
			this.torque = torque;
			this.keyLeft = keyLeft;
			this.keyRight = keyRight;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp, false, 0, true );
		}
		
		public function generate( element:ISimulatable ) : void
		{
			try
			{
				if( leftDown ) IBody( element ).addTorque( -torque );
				if( rightDown ) IBody( element ).addTorque( torque );
			} catch( error:TypeError ) {
				error.message = "element must be implementor of IBody to have torque applied";
				throw error;
			}
		}
		
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
			}
		}
		
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
			}
		}
		
	}
}