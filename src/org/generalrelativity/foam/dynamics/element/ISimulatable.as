package org.generalrelativity.foam.dynamics.element
{
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	
	public interface ISimulatable
	{
		
		function get x() : Number;
		function set x( value:Number ) : void;
		function get y() : Number;
		function set y( value:Number ) : void;
		function get vx() : Number;
		function set vx( value:Number ) : void;
		function get vy() : Number;
		function set vy( value:Number ) : void;
		function get mass() : Number;
		function set mass( value:Number ) : void;
		function get inverseMass() : Number;
		function get force() : Vector;
		function get elasticity() : Number;
		function set elasticity( value:Number ) : void;
		function get friction() : Number;
		function set friction( value:Number ) : void;
		function get position() : Vector;
		function get velocity() : Vector;
		function get collisionTypeID() : String;
		function addForce( force:Vector ) : void;
		function clearForces() : void;
		function addForceGenerator( generator:IForceGenerator ) : void;
		function removeForceGenerator( generator:IForceGenerator ) : void;
		function accumulateForces() : void;
		
	}
}