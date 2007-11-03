package org.generalrelativity.foam.dynamics.force.constraint
{
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.Graphics;
	
	public class RigidBodySpring extends Spring
	{
		
		protected var point1:Vector;
		protected var point2:Vector;
		
		public function RigidBodySpring( body1:IBody, point1:Vector, body2:IBody, point2:Vector, k:Number = 0.01, damp:Number = 0.01 )
		{
			super( body1, body2, k, damp );
			this.point1 = point1;
			this.point2 = point2;
			var t1:Vector = body1.rotation.getVectorProduct( point1 );
			var t2:Vector = body2.rotation.getVectorProduct( point2 );
			restLength = MathUtil.distance( body1.x + t1.x, body2.x + t2.x, body1.y + t1.y, body2.y + t2.y );
		}
		
		override public function generate( element:ISimulatable ) : void 
		{
			const t1:RotationMatrix = IBody( element1 ).rotation;
			var trans1:Vector = t1.getVectorProduct( point1 );
			var pointInWorldSpace1:Vector = trans1.plus( new Vector( element1.x, element1.y ) );
			const t2:RotationMatrix = IBody( element2 ).rotation;
			var trans2:Vector = t2.getVectorProduct( point2 );
			var pointInWorldSpace2:Vector = trans2.plus( new Vector( element2.x, element2.y ) );
			var diff:Vector = new Vector( pointInWorldSpace1.x - pointInWorldSpace2.x, pointInWorldSpace1.y - pointInWorldSpace2.y );
			_force = diff.times( -k * ( diff.magnitude - _restLength ) );
			_force.minusEquals( IBody( element1 ).getVelocityAtPoint( trans1 ).times( damp ) );
			IBody( element1 ).addForceAtPoint( trans1, _force );
		}
		
	}
}