package org.generalrelativity.foam.dynamics.force.constraint
{
	
	import org.generalrelativity.foam.dynamics.force.GenericForceGenerator;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.dynamics.element.IRenderable;
	import flash.display.Graphics;
	
	public class Bungee extends Spring
	{
		
		public function Bungee( element1:ISimulatable, element2:ISimulatable, k:Number = 0.01, damp:Number = 0.4 )
		{
			super( element1, element2, k, damp );
		}
		
		override public function generate( element:ISimulatable ):void
		{
			var diff:Vector = new Vector( element1.x - element2.x, element1.y - element2.y );
			var magnitude:Number = diff.magnitude;
			if( magnitude <= _restLength ) return;
			_force = diff.times( -k * ( magnitude - _restLength ) );
			_force.minusEquals( new Vector( element1.vx, element1.vy ).times( damp ) );
			element1.addForce( _force );
		}
		
	}
}