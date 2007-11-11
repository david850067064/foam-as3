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
 * Simple implementation of a FOAM renderer
 * 
 * TODO: comment
 * TODO: flesh out documentation so that it's easy to see how to build a new IFoamRenderer
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see IFoamRenderer
 * @see Foam
 * */
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
	import org.generalrelativity.foam.dynamics.force.spring.MouseSpring;
	import org.generalrelativity.foam.dynamics.force.spring.Spring;
	import org.generalrelativity.foam.dynamics.force.spring.Bungee;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodySpring;
	import org.generalrelativity.foam.dynamics.force.spring.RigidBodyBungee;

	public class SimpleFoamRenderer extends Sprite implements IFoamRenderer
	{
		
		public static const DEFAULT_COLOR:uint = 0xffffff;
		
		protected var _staticRenderables:Array;
		protected var _dynamicRenderables:Array;
		protected var staticCanvas:Sprite;
		protected var dynamicCanvas:Sprite;
		protected var currentCanvas:Sprite;
		protected var auxillaryCanvas:Sprite;
		
		public function SimpleFoamRenderer()
		{
			staticCanvas = addChild( new Sprite() ) as Sprite;
			dynamicCanvas = addChild( new Sprite() ) as Sprite;
			auxillaryCanvas = addChild( new Sprite() ) as Sprite;
			_staticRenderables = new Array();
			_dynamicRenderables = new Array();
		}
		
		public function addRenderable( renderable:Renderable ) : void
		{
			setupRenderDataDefaults( renderable );
			if( renderable.isDynamic ) _dynamicRenderables.push( renderable );
			else _staticRenderables.push( renderable );
		}
		
		public function removeRenderable( renderable:Renderable ) : void
		{
			var array:Array;
			if( renderable.isDynamic ) array = _dynamicRenderables;
			else array = _staticRenderables;
			var index:int = array.indexOf( renderable );
			if( index > -1 ) array.splice( index, 1 );
		}
		
		public function getDisplayObject( renderable:Renderable ) : DisplayObject
		{
			if( _staticRenderables.indexOf( renderable ) != -1 ) return staticCanvas;
			if( _dynamicRenderables.indexOf( renderable ) != -1 ) return dynamicCanvas;
			return null;
		}
		
		public function redraw() : void
		{
			auxillaryCanvas.graphics.clear();
			dynamicCanvas.graphics.clear();
			currentCanvas = dynamicCanvas;
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
				drawCircle( Circle( renderable.element ), renderable.data.color, renderable.data.alpha, renderable.data.hashSize );
				break;
				
				case RigidBody :
				drawPolygon( RigidBody( renderable.element ), renderable.data.color, renderable.data.alpha );
				break;
				
				case Spring :
				currentCanvas = auxillaryCanvas;
				drawSpring( Spring( renderable.element ) );
				currentCanvas = dynamicCanvas;
				break;
				
				case Bungee :
				currentCanvas = auxillaryCanvas;
				drawSpring( Spring( renderable.element ) );
				currentCanvas = dynamicCanvas;
				break;
				
				case RigidBodySpring :
				currentCanvas = auxillaryCanvas;
				drawSpring( Spring( renderable.element ) );
				currentCanvas = dynamicCanvas;
				break;
				
				case RigidBodyBungee : 
				currentCanvas = auxillaryCanvas;
				drawSpring( Spring( renderable.element ) );
				currentCanvas = dynamicCanvas;
				break;
				
				case MouseSpring :
				currentCanvas = auxillaryCanvas;
				drawMouseSpring( MouseSpring( renderable.element ) );
				currentCanvas = dynamicCanvas;
				break;
				
			}
		}
		
		protected function drawCircle( circle:Circle, color:uint, alpha:Number, hashSize:int ) : void
		{
			currentCanvas.graphics.lineStyle( 1, 0x333333 );
			currentCanvas.graphics.beginFill( color, alpha );
			currentCanvas.graphics.drawCircle( circle.x, circle.y, circle.radius );
			currentCanvas.graphics.endFill();
			currentCanvas.graphics.beginFill( 0xffffff );
			RenderingUtil.drawHash( currentCanvas.graphics, circle.x, circle.y, circle.rotation, hashSize );
			currentCanvas.graphics.endFill();
		}
		
		
		protected function drawPolygon( polygon:RigidBody, color:uint, alpha:Number ) : void
		{
			
			currentCanvas.graphics.lineStyle( 3, 0x333333, 0.4 );
			currentCanvas.graphics.beginFill( color, alpha );
			
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
		
		protected function drawMouseSpring( mouseSpring:MouseSpring ) : void
		{
			currentCanvas.graphics.lineStyle( 1, 0xff0000 );
			var pointInWorldSpace:Vector = mouseSpring.getPointInWorldSpace();
			currentCanvas.graphics.moveTo( pointInWorldSpace.x, pointInWorldSpace.y );
			currentCanvas.graphics.lineTo( mouseX, mouseY );
		}
		
		protected function drawSpring( spring:Spring ) : void
		{
			currentCanvas.graphics.lineStyle( 1, 0xff0000 );
			var p1:Vector = spring.getPoint1InWorldSpace();
			var p2:Vector = spring.getPoint2InWorldSpace();
			currentCanvas.graphics.moveTo( p1.x, p1.y );
			currentCanvas.graphics.lineTo( p2.x, p2.y );
		}
		
		protected function setupRenderDataDefaults( renderable:Renderable ) : void
		{
			if( renderable.data.color == null ) renderable.data.color = SimpleFoamRenderer.DEFAULT_COLOR;
			if( !renderable.data.alpha ) renderable.data.alpha = 0.5;
			if( !renderable.data.hashSize ) renderable.data.hashSize = 10;
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