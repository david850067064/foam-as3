package org.generalrelativity.foam.view
{
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.math.RotationMatrix;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.util.RenderingUtil;

	public class DefaultFoamRenderer extends Sprite implements IFoamRenderer
	{
		
		protected var _staticRenderables:Array;
		protected var _dynamicRenderables:Array;
		protected var staticCanvas:Sprite;
		protected var dynamicCanvas:Sprite;
		protected var currentCanvas:Sprite;
		
		public function DefaultFoamRenderer()
		{
			staticCanvas = addChild( new Sprite() ) as Sprite;
			dynamicCanvas = addChild( new Sprite() ) as Sprite;
			_staticRenderables = new Array();
			_dynamicRenderables = new Array();
		}
		
		public function addRenderable( renderable:Renderable ) : void
		{
			if( renderable.isDynamic ) _dynamicRenderables.push( renderable );
			else _staticRenderables.push( renderable );
		}
		
		public function removeRenderable( renderable:Renderable ) : void
		{
			_staticRenderables.splice( _staticRenderables.indexOf( renderable ), 1 );
			_dynamicRenderables.splice( _staticRenderables.indexOf( renderable ), 1 );
		}
		
		public function getDisplayObject( renderable:Renderable ) : DisplayObject
		{
			if( _staticRenderables.indexOf( renderable ) != -1 ) return staticCanvas;
			if( _dynamicRenderables.indexOf( renderable ) != -1 ) return dynamicCanvas;
			return null;
		}
		
		public function redraw() : void
		{
			currentCanvas = dynamicCanvas;
			currentCanvas.graphics.clear();
			_dynamicRenderables.forEach( proxy );
		}
		
		public function draw() : void
		{
			currentCanvas = staticCanvas;
			currentCanvas.graphics.clear();
			_staticRenderables.forEach( proxy );
			redraw();
		}
		
		protected function proxy( renderable:Renderable, index:int, array:Array ) : void
		{
			switch( renderable.renderMethodKey )
			{
				
				case Circle :
				drawCircle( Circle( renderable.element ) );
				break;
				
				case RigidBody :
				drawPolygon( RigidBody( renderable.element ) );
				break;
				
			}
		}
		
		protected function drawCircle( circle:Circle, color:uint = 0xaaaaaa ) : void
		{
			currentCanvas.graphics.lineStyle( 1, 0x333333 );
			currentCanvas.graphics.beginFill( color );
			currentCanvas.graphics.drawCircle( circle.x, circle.y, circle.radius );
			currentCanvas.graphics.endFill();
			currentCanvas.graphics.beginFill( 0xffffff );
			RenderingUtil.drawHash( currentCanvas.graphics, circle.x, circle.y, circle.rotation, 20 );
			currentCanvas.graphics.endFill();
		}
		
		
		protected function drawPolygon( polygon:RigidBody, color:uint = 0xaaaaaa ) : void
		{
			
			currentCanvas.graphics.lineStyle( 1, 0x333333 );
			currentCanvas.graphics.beginFill( color );
			
			var transform:RotationMatrix = polygon.rotation;
			var transformed:Vector = transform.getVectorProduct( polygon.vertices[ 0 ] as Vector );
			
			var startingPoint:Vector = transformed;
			currentCanvas.graphics.moveTo( polygon.x + startingPoint.x, polygon.y + startingPoint.y );
			
			var i:int = 0;
			while( ++i < polygon.vertices.length )
			{
				transformed = transform.getVectorProduct( polygon.vertices[ i ] as Vector );
				currentCanvas.graphics.lineTo( polygon.x + transformed.x, polygon.y + transformed.y );
			}
			
			currentCanvas.graphics.lineTo( polygon.x + startingPoint.x, polygon.y + startingPoint.y );
			currentCanvas.graphics.beginFill( 0xffffff );
			if( polygon.vertices.length > 2 ) RenderingUtil.drawHash( currentCanvas.graphics, polygon.x, polygon.y, polygon.rotation );
			currentCanvas.graphics.endFill();
			
		}
		
		
		
		public function get renderables() : Array
		{
			return _staticRenderables.concat( _dynamicRenderables );
		}
		
		public function copy( renderer:IFoamRenderer ) : void
		{
			var copies:Array = renderables;
			for each( var renderable:Renderable in copies )
			{
				renderer.addRenderable( renderable );
			}
			
		}
		
		
		
	}
}