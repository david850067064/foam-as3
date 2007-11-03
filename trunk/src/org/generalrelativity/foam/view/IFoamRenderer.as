package org.generalrelativity.foam.view
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	
	
	public interface IFoamRenderer
	{
		
		function addRenderable( renderable:Renderable ) : void;
		function removeRenderable( renderable:Renderable ) : void;
		function getDisplayObject( renderable:Renderable ) : DisplayObject;
		function redraw() : void;
		function draw() : void;
		function get renderables() : Array;
		
		/**
		 * This method is used by FOAM to swap renderers after one has
		 * already been defined- caution overriding.
		 * */
		function copy( renderer:IFoamRenderer ) : void;
		
	}
}