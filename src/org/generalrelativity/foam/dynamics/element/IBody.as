package org.generalrelativity.foam.dynamics.element
{
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.math.RotationMatrix;
	
	public interface IBody extends ISimulatable
	{
		function get q() : Number;
		function set q( value:Number ) : void;
		function get av() : Number;
		function set av( value:Number ) : void;
		function get I() : Number;
		function get inverseI() : Number;
		function get vertices() : Array;
		function get edges() : Array;
		function addTorque( torque:Number ) : void;
		function clearTorque() : void;
		function addForceAtPoint( point:Vector, force:Vector ) : void;
		function getVelocityAtPoint( point:Vector ) : Vector;
		function get rotation() : RotationMatrix;
	}
}