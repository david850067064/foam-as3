package example.rocket.view
{
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.view.IFoamRenderer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import org.generalrelativity.foam.util.SimpleMap;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.view.SimpleFoamRenderer;

	public class DisplayObjectFoamRenderer extends SimpleFoamRenderer implements IFoamRenderer
	{
		
		protected var _containerMap:SimpleMap;
		
		public function DisplayObjectFoamRenderer()
		{
			super();
			_containerMap = new SimpleMap();
		}
		
		
		override public function addRenderable( renderable:Renderable ) : void
		{
			
			if( renderable.data.displayObject )
			{
				
				var container:Sprite = addChild( new Sprite() ) as Sprite;
				var displayObject:DisplayObject = container.addChild( renderable.data.displayObject );
				
				if( !renderable.data.hasBeenDisplayed )
				{
					if( renderable.data.offsetX ) displayObject.x += renderable.data.offsetX;
					if( renderable.data.offsetY ) displayObject.y += renderable.data.offsetY;
				
					if( renderable.data.autoCenter )
					{
						//position the image to rotate about its center
						displayObject.x -= displayObject.width / 2;
						displayObject.y -= displayObject.height / 2;
					}
					
					renderable.data.hasBeenDisplayed = true;
				}
				
				_containerMap.put( renderable, container );
				
			}
			
			super.addRenderable( renderable );
			
			draw();
			redraw();
			
		}
		
		override public function removeRenderable( renderable:Renderable ) : void
		{
			if( _containerMap.has( renderable ) )
			{
				var container:Sprite = _containerMap.getValue( renderable ) as Sprite;
				removeChild( container );
			}
			super.removeRenderable( renderable );
		}
		
		override public function getDisplayObject( renderable:Renderable ) : DisplayObject
		{
			return this;
		}
		
		override public function draw():void
		{
			staticCanvas.graphics.clear();
			currentCanvas = staticCanvas;
			var displayObject:DisplayObject;
			for each( var renderable:Renderable in _staticRenderables )
			{
				if( _containerMap.has( renderable ) )
				{
					displayObject = _containerMap.getValue( renderable ) as DisplayObject;
					if( renderable.element is ISimulatable )
					{
						displayObject.x = ISimulatable( renderable.element ).x;
						displayObject.y = ISimulatable( renderable.element ).y;
						if( renderable.element is IBody ) displayObject.rotation = IBody( renderable.element ).q * 180 / Math.PI;
					}
				}
				else proxy( renderable, 0, null );
			}
		}
		
		override public function redraw():void
		{
			auxillaryCanvas.graphics.clear();
			dynamicCanvas.graphics.clear();
			currentCanvas = dynamicCanvas;
			var displayObject:DisplayObject;
			for each( var renderable:Renderable in _dynamicRenderables )
			{
				if( _containerMap.has( renderable ) )
				{
					displayObject = _containerMap.getValue( renderable ) as DisplayObject;
					if( renderable.element is ISimulatable )
					{
						displayObject.x = ISimulatable( renderable.element ).x;
						displayObject.y = ISimulatable( renderable.element ).y;
						if( renderable.element is IBody ) displayObject.rotation = IBody( renderable.element ).q * 180 / Math.PI;
					}
				}
				else proxy( renderable, 0, null );
			}
		}
		
		
		
	}
}