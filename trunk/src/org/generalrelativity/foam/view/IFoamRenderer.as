/*
Copyright (c) 2007 Drew Cummins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/**
 * Depicts a necessary structure to build a renderer for FOAM
 * 
 * <p>
 * I tried to keep this as general and uninhibitive as possible. Few
 * assumptions were made regarding how elements should be drawn, redrawn
 * etc.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see SimpleFoamRenderer
 * */
package org.generalrelativity.foam.view
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	
	public interface IFoamRenderer
	{
		
		/**
		 * Adds a renderable element to the renderer
		 * 
		 * @param renderable element to add
		 * */
		function addRenderable( renderable:Renderable ) : void;
		
		/**
		 * Removes a renderable element from the renderer
		 * 
		 * @param renderable element to remove
		 * */
		function removeRenderable( renderable:Renderable ) : void;
		
		/**
		 * Gets the DisplayObject that this element is "drawn" in
		 * 
		 * @param renderable Renderable to find associated DisplayObject
		 * 
		 * @return DisplayObject that renderable is "drawn" in
		 * */
		function getDisplayObject( renderable:Renderable ) : DisplayObject;
		
		/**
		 * Draws everything the renderer should draw (generally called offline)
		 * 
		 * @see #redraw
		 * */
		function draw() : void;
		
		/**
		 * Redraws dynamic elements (generally called from within the simulation loop)
		 * 
		 * @see draw
		 * */
		function redraw() : void;
		
		/**
		 * Gets all renderables
		 * 
		 * @return Array of renderables
		 * */
		function get renderables() : Array;
		
		/**
		 * This method is used by FOAM to swap renderers after one has
		 * already been defined- caution overriding.
		 * */
		function copy( renderer:IFoamRenderer ) : void;
		
	}
}