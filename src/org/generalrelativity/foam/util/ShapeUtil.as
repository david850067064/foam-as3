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