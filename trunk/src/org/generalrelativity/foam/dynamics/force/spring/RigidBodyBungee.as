package org.generalrelativity.foam.dynamics.force.constraint
{
	
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.Graphics;
	
	public class RigidBodyBungee extends RigidBodySpring
	{
		
		public function RigidBodyBungee( body1:IBody, point1:Vector, body2:IBody, point2:Vector, k:Number = 0.01, damp:Number = 0.01 )
		{
			super( body1, point1, body2, point2, k, damp );
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
			var magnitude:Number = diff.magnitude;
			if( magnitude <= _restLength ) return;
			_force = diff.times( -k * ( diff.magnitude - _restLength ) );
			_force.minusEquals( IBody( element1 ).getVelocityAtPoint( trans1 ).times( damp ) );
			IBody( element1 ).addForceAtPoint( trans1, _force );
		}
		
	}
}