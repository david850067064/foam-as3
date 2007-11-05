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
 * Useful utilities for dealing with body geometries
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.util
{
	import org.generalrelativity.foam.math.Vector;
	
	public class ShapeUtil
	{
		
		public static function getEdges( vertices:Array ) : Array
		{
			
			var edges:Array = new Array();
			
			var v1:Vector;
			var v2:Vector;
			
			var i:int = -1;
			while( ++i < vertices.length )
			{
				
				v1 = vertices[ i ] as Vector;
				
				if( i + 1 == vertices.length ) v2 = vertices[ 0 ] as Vector;
				else v2 = vertices[ i + 1 ] as Vector;
				
				edges.push( v1.minus( v2 ) );
				
			}
			
			return edges;
			
		}
		
		public static function createRectangle( width:Number, height:Number ) : Array
		{
			return [ new Vector( -width / 2, -height / 2 ), new Vector( width / 2, -height / 2 ), new Vector( width / 2, height / 2 ), new Vector( -width / 2, height / 2 ) ];
		}
		
		public static function createSymmetricPolygon( numVertices:int = 3, size:Number = 50, theta:Number = 0 ) : Array
		{
		
			var vertices:Array = new Array();
			var omega:Number = 360 / numVertices * Math.PI / 180;
			
			var i:int = numVertices;
			while( i-- )
			{
				vertices.push( new Vector( Math.cos( theta ) * size, Math.sin( theta ) * size ) );
				theta += omega;
			}
			
			return vertices;
			
		}
		
	}
}