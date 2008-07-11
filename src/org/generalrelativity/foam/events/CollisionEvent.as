package org.generalrelativity.foam.events
{
	import flash.events.Event;
	
	import org.generalrelativity.foam.dynamics.collision.Contact;

	/**
	 * An event that is dispatched when a collision occurs.
	 * 
	 * @author Mims Wright
	 */
	public class CollisionEvent extends Event
	{
		[Event(name="collisionResolved", type="org.generalrelativity.foam.events.CollisionEvent")]
		public static const COLLISION_RESOLVED:String = "collisionResolved";
		
		public var contact:Contact;
		
		/**
		 * Constructor.
		 * 
		 * @param type The type of event being dispatched.
		 * @param contact The contact object for the collision.
		 */
		public function CollisionEvent(type:String, contact:Contact )
		{
			super(type, false, false);
			this.contact = contact;
		}
		
	}
}