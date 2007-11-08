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
	
	public class Renderable
	{
		
		/** element that should be rendered **/
		public var element:*;
		/** whether this is a dynamic or static element **/
		public var isDynamic:Boolean;
		/** IFoamRenderers can use this key as a means to map element type to a drawing method **/
		public var renderMethodKey:Class;
		/** holds any datatype generic or specific to your IFoamRenderer **/
		public var data:*;
		
		public function Renderable( element:*, 
									isDynamic:Boolean = true, 
									data:* = null )
		{
			
			this.element = element;
			this.isDynamic = isDynamic;
			if( data ) this.data = data;
			else this.data = new Object();
			this.renderMethodKey = getDefinitionByName( getQualifiedClassName( element ) ) as Class;
			
		}
		
	}
}