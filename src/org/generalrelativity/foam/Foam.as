package org.generalrelativity.foam
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.dynamics.ode.solver.RK4;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.element.enum.Simplification;
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.PhysicsEngine;
	import flash.events.Event;
	import org.generalrelativity.foam.view.IFoamRenderer;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.view.DefaultFoamRenderer;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.dynamics.ode.solver.Euler;

	public class Foam extends Sprite
	{
		
		public static const DEFAULT_ODE_SOLVER:Class = RK4;
		
		private var _solverMap:Dictionary;
		private var _renderMap:Dictionary;
		private var _engine:PhysicsEngine;
		private var _renderer:IFoamRenderer;
		private var _isSimulating:Boolean;
		
		public function Foam()
		{
			_solverMap = new Dictionary( true );
			_renderMap = new Dictionary( true );
			_engine = new PhysicsEngine();
		}
		
		public function addElement( element:ISimulatable, 
									collide:Boolean = true,
									render:Boolean = true,
									solver:IODESolver = null,
									collisionDepth:int = 0 ) : void
		{
			
			//no need to solve the state of an immovable element
			if( element.mass != Simplification.INFINITE_MASS && element is IODE )
			{
				if( !solver ) solver = new Foam.DEFAULT_ODE_SOLVER( element );
				_solverMap[ element ] = solver;
				_engine.addODESolver( solver );
			}
			
			if( collide ) _engine.addCollidable( element );
			if( render ) 
			{
				
				if( !_renderer )
				{
					_renderer = new DefaultFoamRenderer();
					addChild( DisplayObject( _renderer ) );
				}
				
				var renderable:Renderable = new Renderable( element, element.mass != Simplification.INFINITE_MASS );
				_renderMap[ element ] = renderable;
				_renderer.addRenderable( renderable );
				
			}
			
			//TODO: implement a collision depth scheme
			
		}
		
		public function setRenderer( renderer:IFoamRenderer ) : void
		{
			if( _renderer )
			{
				_renderer.copy( renderer );
				removeChild( DisplayObject( _renderer ) );
			}
			_renderer = renderer;
			addChild( DisplayObject( _renderer ) );
		}
		
		public function removeElement( element:ISimulatable ) : void
		{
			stopDrawing( element );
			stopSimulating( element );
			stopColliding( element );
		}
		
		public function stopDrawing( element:ISimulatable ) : void
		{
			if( _renderMap[ element ] )
			{
				_renderer.removeRenderable( Renderable( _renderMap[ element ] ) );
				_renderMap[ element ] = null;
			}
		}
		
		public function stopSimulating( element:ISimulatable ) : void
		{
			if( _solverMap[ element ] )
			{
				_engine.removeODESolver( IODESolver( _solverMap[ element ] ) );
				_solverMap[ element ] = null;
			}
		}
		
		public function stopColliding( element:ISimulatable ) : void
		{
			_engine.removeCollidable( element );
		}
		
		
		public function simulate() : void
		{
			
			if( !_isSimulating )
			{
				_isSimulating = true;
				_renderer.draw();
				addEventListener( Event.ENTER_FRAME, stepForward, false, 0, true );
			}
			
		}
		
		public function stop() : void
		{
			if( _isSimulating )
			{
				_isSimulating = false;
				removeEventListener( Event.ENTER_FRAME, stepForward );
			}
		}
		
		public function stepForward( event:Event ) : void
		{
			_engine.step();
			_renderer.redraw();
		}
		
		public function stepBackward( event:Event ) : void
		{
			_engine.step( -1 );
			_renderer.redraw();
		}
		
		public function get engine() : PhysicsEngine
		{
			return _engine;
		}
		
		
	}
}