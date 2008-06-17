package org.generalrelativity.foam.view
{
	/**
	 * Indicates an element that can be rendered by a IFoamRenderer.
	 * @see org.generalrelativity.foam.view.IFoamRenderer
	 */
	public interface IRenderable
	{
	
		/** element that should be rendered **/
		function get element():*;
		function set element(element:*):void;
		/** whether this is a dynamic or static element **/
		function get isDynamic():Boolean;
		function set isDynamic(isDynamic:Boolean):void;
		/** IFoamRenderers can use this key as a means to map element type to a drawing method **/
		function get renderMethodKey():Class;
		function set renderMethodKey(renderMethodKey:Class):void;
		/** holds any datatype generic or specific to your IFoamRenderer **/
		function get data():*;
		function set data(data:*):void;
		
	}
}