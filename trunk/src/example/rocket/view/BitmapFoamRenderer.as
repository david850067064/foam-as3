package example.rocket.view
{
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.view.IFoamRenderer;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import org.generalrelativity.foam.dynamics.force.spring.Spring;
	import org.generalrelativity.foam.dynamics.force.spring.MouseSpring;
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.math.Vector;
	import com.foxaweb.utils.Raster;
	import org.generalrelativity.foam.math.RotationMatrix;
	import flash.display.Sprite;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodyBungee;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodySpring;
	import org.generalrelativity.foam.dynamics.force.spring.Bungee;
	import flash.geom.Point;
	import flash.filters.BlurFilter;

	public class BitmapFoamRenderer extends Sprite implements IFoamRenderer
	{
	
		public static const DEFAULT_COLOR:uint = 0xffffff;
		
		protected var _staticRenderables:Array;
		protected var _dynamicRenderables:Array;
		
		protected var _staticCanvas:BitmapData;
		protected var _canvas:BitmapData;
		protected var _bitmap:Bitmap;
		
		protected var currentCanvas:BitmapData;
		
		public function BitmapFoamRenderer( width:Number = 800, height:Number = 600 )
		{
			_staticRenderables = new Array();
			_dynamicRenderables = new Array();
			_canvas = new BitmapData( width, height, false, 0x333333 );
			_bitmap = addChild( new Bitmap( _canvas ) ) as Bitmap;
		}
		
		
		public function addRenderable( renderable:Renderable ) : void
		{
			setupRenderDataDefaults( renderable );
			if( renderable.isDynamic ) _dynamicRenderables.push( renderable );
			else _staticRenderables.push( renderable );
		}
		
		public function get renderables():Array
		{
			return _staticRenderables.concat( _dynamicRenderables );
		}
		
		public function getDisplayObject( renderable:Renderable ) : DisplayObject
		{
			return null;
		}
		
		public function copy(renderer:IFoamRenderer):void
		{
			var copies:Array = renderables;
			for each( var renderable:Renderable in copies )
			{
				renderer.addRenderable( renderable );
			}
		}
		
		
		public function redraw() : void
		{
			_canvas.copyPixels( _staticCanvas, _staticCanvas.rect, new Point() );
			currentCanvas = _canvas;
			_dynamicRenderables.forEach( proxy );
		}
		
		public function draw() : void
		{
			currentCanvas = _staticCanvas = new BitmapData( width, height, false, 0x333333 );
			_staticRenderables.forEach( proxy );
			redraw();
		}
		
		protected function proxy( renderable:Renderable, index:int, array:Array ) : void
		{
			switch( renderable.renderMethodKey )
			{
				
				case Circle :
				drawCircle( Circle( renderable.element ), renderable.data.color );
				break;
				
				case RigidBody :
				drawPolygon( RigidBody( renderable.element ), renderable.data.color );
				break;
				
				case Spring :
				drawSpring( Spring( renderable.element ) );
				break;
				
				case Bungee :
				drawSpring( Spring( renderable.element ) );
				break;
				
				case RigidBodySpring :
				drawSpring( Spring( renderable.element ) );
				break;
				
				case RigidBodyBungee : 
				drawSpring( Spring( renderable.element ) );
				break;
				
				case MouseSpring :
				drawMouseSpring( MouseSpring( renderable.element ) );
				break;
				
			}
		}
		
		protected function drawCircle( circle:Circle, color:uint ) : void
		{
			Raster.circle( currentCanvas, circle.x, circle.y, circle.radius, color );
			var pointOnCircle:Vector = circle.rotation.getVectorProduct( new Vector( circle.radius, 0 ) );
			Raster.line( currentCanvas, circle.position.x, circle.position.y, circle.position.x + pointOnCircle.x, circle.position.y + pointOnCircle.y, color );
		}
		
		
		protected function drawPolygon( polygon:RigidBody, color:uint ) : void
		{
			
			var transform:RotationMatrix = polygon.rotation;
			var transformed:Vector;
			var point:Vector = transform.getVectorProduct( polygon.vertices[ polygon.vertices.length - 1 ] as Vector );
			
			var i:int = -1;
			while( ++i < polygon.vertices.length )
			{
				transformed = transform.getVectorProduct( polygon.vertices[ i ] as Vector );
				Raster.line( currentCanvas, polygon.x + point.x, polygon.y + point.y, polygon.x + transformed.x, polygon.y + transformed.y, color );
				point = transformed;
			}
			
			
			
		}
		
		protected function drawMouseSpring( mouseSpring:MouseSpring ) : void
		{
			var pointInWorldSpace:Vector = mouseSpring.getPointInWorldSpace();
			Raster.line( currentCanvas, pointInWorldSpace.x, pointInWorldSpace.y, mouseX, mouseY, 0xff0000 );
		}
		
		protected function drawSpring( spring:Spring ) : void
		{
			var p1:Vector = spring.getPoint1InWorldSpace();
			var p2:Vector = spring.getPoint2InWorldSpace();
			Raster.line( currentCanvas, p1.x, p1.y, p2.x, p2.y, 0xff0000 );
		}
		
		public function removeRenderable( renderable:Renderable ) : void
		{
			var array:Array;
			if( renderable.isDynamic ) array = _dynamicRenderables;
			else array = _staticRenderables;
			var index:int = array.indexOf( renderable );
			if( index > -1 ) array.splice( index, 1 );
		}
		
		protected function setupRenderDataDefaults( renderable:Renderable ) : void
		{
			if( renderable.data.color == null ) renderable.data.color = BitmapFoamRenderer.DEFAULT_COLOR;
		}
		
	}
}