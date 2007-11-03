package org.generalrelativity.foam.dynamics.element.body
{
	import flash.display.Graphics;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.util.RenderingUtil;
	import org.generalrelativity.foam.dynamics.element.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;
	
	public class Circle extends RigidBody
	{
		
		public var radius:Number;
		
		public function Circle( x:Number, 
								y:Number, 
								radius:Number,
								mass:Number = 1, 
								vx:Number = 0, 
								vy:Number = 0, 
								q:Number = 0,
								av:Number = 0,
								friction:Number = 0.5,
								elasticity:Number = 0.15 )
		{
			this.radius = radius;
			super( x, y, mass, null, vx, vy, q, av, friction, elasticity );
			
		}
		
		override protected function calculateInertiaTensor() : void
		{
			if( mass == Simplification.INFINITE_MASS )
			{
				_I = Simplification.INFINITE_MASS;
				_inverseI = 0;
				return;
			}
			_I = radius * radius * mass;
			_inverseI = 1 / _I;
		}
		
		override public function get collisionTypeID() : String
		{
			return CollisionType.CIRCLE;
		}
		
		
	}
}