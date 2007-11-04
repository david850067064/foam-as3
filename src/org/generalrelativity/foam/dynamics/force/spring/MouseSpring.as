package org.generalrelativity.foam.dynamics.force.spring
{
	import org.generalrelativity.foam.dynamics.force.SimpleForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.math.Vector;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.display.Graphics;

	public class MouseSpring extends SimpleForceGenerator implements IForceGenerator
	{
		
		protected var body:RigidBody;
		protected var point:Vector;
		protected var displayObject:DisplayObject;
		protected var restLength:Number;
		protected var k:Number;
		protected var damp:Number;
		
		public function MouseSpring( body:RigidBody, point:Vector, displayObject:DisplayObject )
		{
			this.body = body;
			var transpose:RotationMatrix = body.rotation.getTranspose();
			this.point = transpose.getVectorProduct( point );
			this.displayObject = displayObject;
			restLength = 40;
			k = 0.001;
			damp = 0.3;
			body.addForceGenerator( this );
		}
		
		override public function generate( element:ISimulatable ) : void
		{
				
			var t1:RotationMatrix = body.rotation;
			var trans1:Vector = t1.getVectorProduct( point );
			var pointInWorldSpace1:Vector = trans1.plus( body.position );
			var diff:Vector = new Vector( pointInWorldSpace1.x - displayObject.mouseX, pointInWorldSpace1.y - displayObject.mouseY );
			if( diff.magnitude < restLength ) return;
			
			_force = diff.times( -k * ( diff.magnitude - restLength ) );
			_force.minusEquals( body.velocity.times( damp ) );
			
			body.addForceAtPoint( trans1, _force ); needs updating
			
		}
		
		public function destroy() : void
		{
			body.removeForceGenerator( this );
		}
		
	}
}