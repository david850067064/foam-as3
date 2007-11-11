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
 * FOAM offers a simple interface for creating, running and controlling 
 * physical simulations.
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see PhysicsEngine
 * @see RigidBody
 * */
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
	import flash.events.MouseEvent;
	import org.generalrelativity.foam.dynamics.force.spring.MouseSpring;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;
	import org.generalrelativity.foam.dynamics.collision.ICoarseCollisionDetector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.util.SimpleMap;

	[Event(name="step", type="flash.events.Event")]
	public class Foam extends Sprite
	{
		
		/** offers a default solver class for differential equations **/
		public static const DEFAULT_ODE_SOLVER:Class = RK4;
		/** step event **/
		public static const STEP:String = "step";
		
		/** maps ISimulatables to IODESolvers for intefacing with <code>PhysicsEngine</code> **/
		private var _solverMap:SimpleMap;
		/** maps elements to Renderables for interfacing with IFoamRenderable **/
		private var _renderMap:SimpleMap;
		/** runs the simulation **/
		private var _engine:PhysicsEngine;
		/** renders the simulation **/
		private var _renderer:IFoamRenderer;
		/** defines whether FOAM is currently running the Physics Engine **/
		private var _isSimulating:Boolean;
		/** defines the default IODESolver Class **/
		private var _defaultSolver:Class;
		/** defines whether to use the Mouse dragger **/
		private var _useMouseDragger:Boolean;
		/** MouseSpring for dragging bodies **/
		private var _mouseSpring:MouseSpring;
		/** stage event handling work-around **/
		private var _callOnAddedToStage:Array;
		/** holds all force generators being applied to all elements **/
		private var _globalForceGenerators:Array;
		/** defines the amount of time simulated each frame **/
		private var _timestep:Number;
		
		/**
		 * Creates a new FOAM interface
		 * 
		 * This is most likely the first step in creating a physics simulation.
		 * */
		public function Foam()
		{
			_solverMap = new SimpleMap();
			_renderMap = new SimpleMap();
			_engine = new PhysicsEngine();
			_globalForceGenerators = new Array();
			_callOnAddedToStage = new Array();
			_defaultSolver = Foam.DEFAULT_ODE_SOLVER;
			_timestep = 1.0;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
		}
		
		/**
		 * Adds an element to the simulation
		 * 
		 * <p>
		 * This will probably be the most used method- it handles a lot of the logic
		 * necessary to give the user a lot of control without worrying about dividing
		 * up the element to its respective places in the application.
		 * </p>
		 * 
		 * <pre>
		 * //creates a new instance of Foam
		 * var foam:Foam = new Foam();
		 * //creates a triangle at x:100, y:100 with a mass of 100 (ShapeUtil.createSymmetricPolygon defaults to 3 vertices)
		 * var body:RigidBody = new RigidBody( 100, 100, 100, ShapeUtil.createSymmetricPolygon() );
		 * //adds the body to FOAM for simulation
		 * foam.addElement( body );
		 * </pre>
		 * 
		 * @param element ISimulatable to add
		 * @param collide defines whether this element should be tested for collision during simulation
		 * @param render defines whether this element should be drawn
		 * @param renderData a unique object to be interpreted by your IFoamRenderer and associated with this element
		 * @param solver IODESolver to use to advance the state of this element
		 * 
		 * @see ISimulatable
		 * @see RigidBody
		 * @see IFoamRenderer
		 * @see Renderable.data
		 * @see IODESolver
		 * @see #addRenderable
		 * */
		public function addElement( element:ISimulatable, 
									collide:Boolean = true,
									render:Boolean = true,
									renderData:* = null,
									solver:IODESolver = null ) : void
		{
			
			//no need to solve the state of an immovable element
			if( element.mass != Simplification.INFINITE_MASS && element is IODE )
			{
				
				//if a solver hasn't been provided, use the default
				if( !solver ) solver = new _defaultSolver( element );
				
				//map this element to the solver
				_solverMap.put( element, solver );
				//add the IODESolver to the engine for advancement
				_engine.addODESolver( solver );
				
				//add any global force generators to the element
				for each( var forceGenerator:IForceGenerator in _globalForceGenerators )
				{
					element.addForceGenerator( forceGenerator );
				}
				
			}
			
			//let the engine handle collisions if collide is set to true
			if( collide ) _engine.addCollidable( element );
			
			//if the element should be rendered, add it to the renderer
			if( render ) 
			{
				//if we haven't defined a renderer yet, create the default IFoamRenderer
				if( !_renderer )
				{
					_renderer = new SimpleFoamRenderer();
					//add this to display as a child of FOAM
					addChild( DisplayObject( _renderer ) );
				}
				
				addRenderable( new Renderable( element, element.mass != Simplification.INFINITE_MASS, renderData ) );
				
			}
			
		}
		
		/**
		 * Adds a global force to the simulation
		 * 
		 * <p>
		 * This force will be added to all future and current (as defined 
		 * by applyToExisting) elements
		 * </p>
		 * 
		 * @param forceGenerator IForceGenerator to add
		 * @param applyToExisting whether to add this force generator to all 
		 * elements already added to FOAM
		 * 
		 * @see ISimulatable.addForceGenerator
		 * */
		public function addGlobalForceGenerator( forceGenerator:IForceGenerator, applyToExisting:Boolean = true ) : void
		{
			
			if( applyToExisting )
			{
				for each( var simulatable:ISimulatable in _solverMap.keys )
				{
					simulatable.addForceGenerator( forceGenerator );
				}
			}
			
			_globalForceGenerators.push( forceGenerator );
			
		}
		
		/**
		 * Removes a global force from the simulation
		 * 
		 * <p>
		 * This force will be removed from all elements its currently generating
		 * for depending on remainInEffect
		 * </p>
		 * 
		 * @param forceGenerator IForceGenerator to remove
		 * @param remainInEffect whether to allow it to keep generating, but remove
		 * it from new additions to FOAM, or remove it from all affected ISimulatables
		 * 
		 * @see ISimulatable.addForceGenerator
		 * */
		public function removeGlobalForceGenerator( forceGenerator:IForceGenerator, remainInEffect:Boolean = false ) : void
		{
			
			var index:int = _globalForceGenerators.indexOf( forceGenerator );
			if( index > -1 )
			{
				if( !remainInEffect )
				{
					for each( var simulatable:ISimulatable in _solverMap.keys )
					{
						simulatable.removeForceGenerator( forceGenerator );
					}
				}
				_globalForceGenerators.splice( _globalForceGenerators.indexOf( forceGenerator ), 1 );
			}
			
			
		}
		
		/**
		 * Removes an element from the simulation
		 * 
		 * <p>
		 * This removes the element from the renderer and the engine.
		 * </p>
		 * 
		 * @param element ISimulatable to remove
		 * 
		 * @see #stopDrawing
		 * @see stopSimulating
		 * */
		public function removeElement( element:ISimulatable ) : void
		{
			stopDrawing( element );
			stopSimulating( element );
		}
		
		/**
		 * Stops an element from being rendered.
		 * 
		 * <p>
		 * Note that this does not stop the element from simulation when 
		 * called by itself.
		 * </p>
		 * 
		 * @param element element to remove
		 * */
		public function stopDrawing( element:* ) : void
		{
			if( _renderMap.has( element ) )
			{
				_renderer.removeRenderable( Renderable( _renderMap.getValue( element ) ) );
				_renderMap.remove( element );
				if( _isSimulating ) _renderer.draw();
			}
		}
		
		/**
		 * Stops an element from being simulated
		 * 
		 * <p>
		 * Note that this does not stop an element from being rendered.
		 * It does, however remove it from collision consideration. Also,
		 * the simulation is stopped if there is nothing left to simulate.
		 * </p>
		 * 
		 * @param element element to remove from simulation
		 * */
		public function stopSimulating( element:ISimulatable ) : void
		{
			if( _solverMap.has( element ) )
			{
				_engine.removeODESolver( IODESolver( _solverMap.getValue( element ) ) );
				_solverMap.remove( element );
				stopColliding( element );
			}
			
			//if there are no elements to be simulated, stop the simulation
			if( !_solverMap.keys.length ) stop();
			
		}
		
		/**
		 * Removes an element from collision consideration
		 * 
		 * @param element element to remove
		 * 
		 * @see PhysicsEngine.removeCollidable
		 * */
		public function stopColliding( element:ISimulatable ) : void
		{
			_engine.removeCollidable( element );
		}
		
		/**
		 * Starts running the simulation
		 * 
		 * @see IFoamRenderer.draw
		 * @see #stepForward
		 * @see #stop
		 * */
		public function simulate() : void
		{
			
			//if we're not already simulating and we have elements to simulate
			if( !_isSimulating && _solverMap.length )
			{
				_isSimulating = true;
				//draw all static elements (presumably)
				_renderer.draw(); 
				addEventListener( Event.ENTER_FRAME, stepForward, false, 0, true );
			}
			
		}
		
		/**
		 * Stops the simulation
		 * 
		 * @see #start
		 * */
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
			_engine.step( _timestep );
			_renderer.redraw();
			dispatchEvent( new Event( Foam.STEP ) );
		}
		
		public function stepBackward( event:Event = null ) : void
		{
			_engine.step( -_timestep );
			_renderer.redraw();
			dispatchEvent( new Event( Foam.STEP ) );
		}
		
		public function get timestep() : Number { return _timestep; }
		public function set timestep( value:Number ) : void { _timestep = value; }
		
		/**
		 * Sets the engine's coarse collision detector
		 * 
		 * @param detector ICoarseCollisionDetector to handle broad phase culling
		 * */
		public function setCoarseCollisionDetector( detector:ICoarseCollisionDetector ) : void
		{
			_engine.setCoarseCollisionDetector( detector );
		}
		
		/**
		 * Defines the collision factory used by the coarse detector to return IFineCollisionDetectors
		 * 
		 * @param factory CollisionFactory
		 * */
		public function setCollisionFactory( factory:ICollisionFactory ) : void
		{
			_engine.setCollisionFactory( factory );
		}
		
		public function get engine() : PhysicsEngine
		{
			return _engine;
		}
		
		/**
		 * Sets the renderer
		 * 
		 * @see IFoamRenderer
		 * */
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
		
		public function set defaultSolver( solverClass:Class ) : void
		{
			_defaultSolver = solverClass;
		}
		
		public function set solverIterations( value:int ) : void
		{
			_engine.solverIterations = value;
		}
		
		public function get simulatables() : Array
		{
			return _solverMap.keys;
		}
		
		/**
		 * Adds a renderable element to the renderer
		 * 
		 * @param renderable Renderable to add
		 * 
		 * @see Renderable
		 * @see IFoamRenderer
		 * */
		public function addRenderable( renderable:Renderable ) : void
		{
			_renderMap.put( renderable.element, renderable );
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
		
		/**
		 * Depicts whether to use the MouseSpring on bodies or not
		 * 
		 * @param value true to use the dragger, false otherwise
		 * 
		 * */
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