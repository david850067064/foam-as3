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
 * Helps port an element for rendering out of the context of physical simulation
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IFoamRenderer
 * @see Foam
 * */
package org.generalrelativity.foam.view
{
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Renderable implements IRenderable
	{
		protected var _element:*;
		protected var _isDynamic:Boolean;
		protected var _renderMethodKey:Class;
		protected var _data:*;
		
		/** element that should be rendered **/
		public function get element():* { return _element; }
		public function set element(element:*):void { _element = element; }
		
		/** whether this is a dynamic or static element **/
		public function get isDynamic():Boolean {return _isDynamic};
		public function set isDynamic(isDynamic:Boolean):void { _isDynamic = isDynamic; }
		
		/** IFoamRenderers can use this key as a means to map element type to a drawing method **/
		public function get renderMethodKey():Class { return _renderMethodKey; }
		public function set renderMethodKey(renderMethodKey:Class):void { _renderMethodKey = renderMethodKey; }
		
		/** holds any datatype generic or specific to your IFoamRenderer **/
		public function get data():* { return _data; }
		public function set data(data:*):void { _data = data; }
		
		public function Renderable( element:*, 
									isDynamic:Boolean = true, 
									data:* = null )
		{
			
			_element = element;
			_isDynamic = isDynamic;
			if( data ) _data = data;
			else _data = new Object();
			_renderMethodKey = getDefinitionByName( getQualifiedClassName( element ) ) as Class;
			
		}
		
	}
}