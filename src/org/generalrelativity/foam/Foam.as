package org.generalrelativity.foam
{
	import flash.display.Sprite;
	import org.generalrelativity.foam.dynamics.ode.solver.RK4;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.PhysicsEngine;
	import flash.events.Event;
	import org.generalrelativity.foam.view.IFoamRenderer;
	import org.generalrelativity.foam.view.Renderable;
	import org.generalrelativity.foam.view.SimpleFoamRenderer;
	import flash.display.DisplayObject;
	import org.generalrelativity.foam.dynamics.ode.solver.Euler;
	import flash.events.MouseEvent;
	import org.generalrelativity.foam.dynamics.force.spring.MouseSpring;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;
	import org.generalrelativity.foam.dynamics.collision.ICoarseCollisionDetector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;

	public class Foam extends Sprite
	{
		
		public static const DEFAULT_ODE_SOLVER:Class = RK4;
		
		private var _solverMap:Dictionary;
		private var _renderMap:Dictionary;
		private var _engine:PhysicsEngine;
		private var _renderer:IFoamRenderer;
		private var _isSimulating:Boolean;
		private var _userSetDefaultSolver:Class;
		private var _useMouseDragger:Boolean;
		private var _mouseSpring:MouseSpring;
		private var _callOnAddedToStage:Array;
		private var _simulatables:Array;
		private var _globalForceGenerators:Array;
		
		public function Foam()
		{
			_solverMap = new Dictionary();
			_renderMap = new Dictionary();
			_simulatables = new Array();
			_engine = new PhysicsEngine();
			_globalForceGenerators = new Array();
			_callOnAddedToStage = new Array();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
		}
		
		public function addElement( element:ISimulatable, 
									collide:Boolean = true,
									render:Boolean = true,
									renderData:* = null,
									solver:IODESolver = null ) : void
		{
			
			//no need to solve the state of an immovable element
			if( element.mass != Simplification.INFINITE_MASS && element is IODE )
			{
				
				if( !solver ) 
				{
					if( _userSetDefaultSolver ) solver = new _userSetDefaultSolver( element );
					else solver = new Foam.DEFAULT_ODE_SOLVER( element );
				}
				
				_solverMap[ element ] = solver;
				_engine.addODESolver( solver );
				_simulatables.push( element );
				
				for each( var forceGenerator:IForceGenerator in _globalForceGenerators )
				{
					element.addForceGenerator( forceGenerator );
				}
				
			}
			
			if( collide ) _engine.addCollidable( element );
			
			if( render ) 
			{
				
				if( !_renderer )
				{
					_renderer = new SimpleFoamRenderer();
					addChild( DisplayObject( _renderer ) );
				}
				
				addRenderable( new Renderable( element, element.mass != Simplification.INFINITE_MASS, renderData ) );
				
			}
			
		}
		
		public function addGlobalForceGenerator( forceGenerator:IForceGenerator, applyToExisting:Boolean = true ) : void
		{
			
			if( applyToExisting )
			{
				for each( var simulatable:ISimulatable in _simulatables )
				{
					simulatable.addForceGenerator( forceGenerator );
				}
			}
			
			_globalForceGenerators.push( forceGenerator );
			
		}
		
		public function removeGlobalForceGenerator( forceGenerator:IForceGenerator, remainInEffect:Boolean = false ) : void
		{
			
			if( !remainInEffect )
			{
				for each( var simulatable:ISimulatable in _simulatables )
				{
					simulatable.removeForceGenerator( forceGenerator );
				}
			}
				
			_globalForceGenerators.splice( _globalForceGenerators.indexOf( forceGenerator ), 1 );
			
		}
		
		public function removeElement( element:ISimulatable ) : void
		{
			stopDrawing( element );
			stopSimulating( element );
			stopColliding( element );
		}
		
		public function stopDrawing( element:* ) : void
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
				_simulatables.splice( _simulatables.indexOf( element ), 1 );
				_engine.removeODESolver( IODESolver( _solverMap[ element ] ) );
				_solverMap[ element ] = null;
			}
			
			if( !_simulatables.length ) stop();
			
		}
		
		public function stopColliding( element:ISimulatable ) : void
		{
			_engine.removeCollidable( element );
		}
		
		
		public function simulate() : void
		{
			
			if( !_isSimulating && _simulatables.length )
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
		
		public function stepForward( event:Event = null ) : void
		{
			_engine.step();
			_renderer.redraw();
		}
		
		public function stepBackward( event:Event = null ) : void
		{
			_engine.step( -1.0 );
			_renderer.redraw();
		}
		
		public function setCoarseCollisionDetector( detector:ICoarseCollisionDetector ) : void
		{
			_engine.setCoarseCollisionDetector( detector );
		}
		
		public function setCollisionFactory( factory:ICollisionFactory ) : void
		{
			_engine.setCollisionFactory( factory );
		}
		
		public function get engine() : PhysicsEngine
		{
			return _engine;
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
		
		public function set userSetDefaultSolver( solverClass:Class ) : void
		{
			_userSetDefaultSolver = solverClass;
		}
		
		public function addRenderable( renderable:Renderable ) : void
		{
			_renderMap[ renderable.element ] = renderable;
			_renderer.addRenderable( renderable );
		}
		
		private function onAddedToStage( event:Event ) : void
		{
			while( _callOnAddedToStage.length )
			{
				var methodArgs:Array = _callOnAddedToStage.pop();
				var method:Function = _callOnAddedToStage.pop();
				method.apply( this, methodArgs );
			}
		}
		
		private function onMouseDown( event:MouseEvent ) : void
		{
			var mouseVector:Vector = new Vector( mouseX, mouseY );
			var body:IBody = _engine.getBodyUnderPoint( mouseVector );
			if( body )
			{
				_mouseSpring = new MouseSpring( body, mouseVector.minus( body.position ), this );
				addRenderable( new Renderable( _mouseSpring ) );
				stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp, false, 0, true );
			}
		}
		
		private function onMouseUp( event:MouseEvent ) : void
		{
			_mouseSpring.destroy();
			stopDrawing( _mouseSpring );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		public function useMouseDragger( value:Boolean ) : void
		{
		
			if( !stage )
			{
				if( _callOnAddedToStage.indexOf( useMouseDragger ) == -1 ) _callOnAddedToStage.push( useMouseDragger, [ value ] );
				return;
			}
			if( _useMouseDragger != value )
			{
				_useMouseDragger = value;
				if( _useMouseDragger ) stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true );
				else stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			}
			
		}
		
	}
}