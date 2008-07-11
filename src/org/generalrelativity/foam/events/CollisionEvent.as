package org.generalrelativity.foam.events
{
	import flash.events.Event;
	
	import org.generalrelativity.foam.dynamics.element.IBody;

	/**
	 * An event that is dispatched when a collision occurs.
	 * 
	 * @author Mims Wright
	 */
	public class CollisionEvent extends Event
	{
		[Event(name="collision", type="org.generalrelativity.foam.events.CollisionEvent")]
		public static const COLLISION:String = "collision";
		
		public var body1:IBody;
		public var body2:IBody;
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of event being dispatched.
		 * @param body1 The first of 2 bodies involved in the collision.
		 * @param body2 The second of 2 bodies involved in the collision.
		 */
		public function CollisionEvent(type:String, body1:IBody, body2:IBody )
		{
			super(type, false, false);
			this.body1 = body1;
			this.body2 = body2;
		}
		
	}
}