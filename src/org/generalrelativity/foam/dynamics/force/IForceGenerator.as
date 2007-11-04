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
 * Depicts how forces should modularly affect simulatable elements.
 * 
 * <p>
 * The idea behind a force generator is that it becomes part of the element. By
 * adding a force generator to an element, it can be present to apply its force
 * from within the element's integration.
 * </p>
 * 
 * <p>
 * This generic structure allows IForceGenerators to affect multiple particles.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ISimulatable.addForceGenerator
 * @see SimpleForceGenerator
 * */
package org.generalrelativity.foam.dynamics.force
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	
	public interface IForceGenerator
	{
		
		/**
		 * Generates a force (presumably) for the given element
		 * 
		 * @param element element to apply a force to
		 * */
		function generate( element:ISimulatable ) : void;
		
	}
}