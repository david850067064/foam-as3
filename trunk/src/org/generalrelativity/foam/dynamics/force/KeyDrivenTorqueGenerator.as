/*
Copyright (c) 2007 Drew Cummins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/**
 * Applies a key-driven input torque to a body
 * 
 * <p>
 * This is given as a simple example of how to create a slightly more complex force generator.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ISimulatable.addForceGenerator
 * @see IForceGenerator
 * */
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
		
		/** torque to apply to body **/
		private var torque:Number;
		/** Keyboard key used to apply counter-clockwise torque **/
		private var keyLeft:uint;
		/** Keyboard key used to apply clockwise torque to body **/
		private var keyRight:uint;
		/** represents whether the left key is down **/
		private var leftDown:Boolean;
		/** represents whether the right key is down **/
		private var rightDown:Boolean;
		
		/**
		 * Creates a new KeyDrivenTorqueGenerator
		 * 
		 * @param stage reference to stage with which to listen for KeyboardEvents
		 * @param torque amount of torque to add
		 * @param keyLeft key code of key to induce counter-clockwise torque
		 * @param keyRight key code of key to induce clockwise torque
		 * */
		public function KeyDrivenTorqueGenerator( stage:Stage, torque:Number = 3000, keyLeft:uint = Keyboard.LEFT, keyRight:uint = Keyboard.RIGHT )
		{
			this.torque = torque;
			this.keyLeft = keyLeft;
			this.keyRight = keyRight;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp, false, 0, true );
		}
		
		/**
		 * Generates torque on the given element if the assigned key(s) are down
		 * 
		 * @param element IBody to generate torque on
		 * 
		 * @see #onKeyDown
		 * @see IBody.addTorque
		 * */
		public function generate( element:ISimulatable ) : void
		{
			try
			{
				if( leftDown ) IBody( element ).addTorque( -torque );
				if( rightDown ) IBody( element ).addTorque( torque );
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
			}
		}
		
	}
}