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
 * Takes on the job of advancing the simulation
 * 
 * <p>
 * This should typically be accessed through the more user friendly FOAM interface
 * </p>
 * 
 * <p>
 * The simulation takes the form:
 * <pre>
 * 1. Let each IODESolver advance the state of their equations
 * 2. Narrow down possible collisions with the coarse collision detector
 * 3. Find actual collisions and generate points of contact
 * 4. Resolve collisions on a pairwise basis
 * 5. repeat 1 - 4 for as many iterations as is depicted in solverIterations
 * </pre></p>
 * 
 * <p>
 * A notable separation is that of elements responsible for advancing
 * the system and those involved in collision detection/response. 
 * This distinction is made in the vain of modularity- but it doesn't
 * provide the nicest interface for the casual developer; this sort of
 * situation is what FOAM is for.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see Foam
 * */
package org.generalrelativity.foam.dynamics
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.ode.IODESolver;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	import org.generalrelativity.foam.dynamics.collision.CollisionResolver;
	import org.generalrelativity.foam.dynamics.collision.ICoarseCollisionDetector;
	import org.generalrelativity.foam.dynamics.collision.coarse.AABRDetector;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.PointPolygonDetector;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.element.IBody;
	
	public class PhysicsEngine
	{
		
		/** offers a default number of iterations per frame **/
		public static const SOLVER_ITERATIONS:int = 3;
		/** offers a default ICoarseCollisionDetector class **/
		public static const DEFAULT_COARSE_COLLISION_DETECTOR:Class = AABRDetector;
		
		/** holds all solvers **/
		private var _odeSolvers:Array;
		/** optimization- number of solvers **/
		private var _numODESolvers:int;
		/** actual number of iterations per frame **/
		private var _solverIterations:int;
		/** coarse collision detector **/
		private var _coarseDetector:ICoarseCollisionDetector;
		
		/**
		 * Creates a new Physics Engine
		 * 
		 * <p>
		 * This should be viewed as a work in progress. It currently uses
		 * a less-than-desirable approach to contact resolution. All 
		 * functionality is pretty well broken out and shouldn't affect
		 * the user even given radical changes in future releases
		 * </p>
		 * 
		 * <p>
		 * Instantiation is typically handled through the Foam interface.
		 * </p>
		 * 
		 * @see Foam
		 * */
		public function PhysicsEngine()
		{
			_odeSolvers = new Array();
			_solverIterations = PhysicsEngine.SOLVER_ITERATIONS;
		}
		
		/**
		 * Adds an IODESolver to the engine. Because the engine draws
		 * a distinction between solvers and collidable elements, 
		 * IODESolvers can be added without being tested/solved for
		 * collision and vice versa.
		 * 
		 * @param solver IODESolver to add
		 * 
		 * @see IODESolver
		 * @see addCollidable
		 * @see Foam.addElement
		 * */
		public function addODESolver( solver:IODESolver ) : void
		{
			_odeSolvers.push( solver );
			_numODESolvers = _odeSolvers.length;
		}
		
		/**
		 * Adds a collidable element to the engine. Because the engine 
		 * draws a distinction between solvers and collidable elements, 
		 * collidable elements can be added without needing its state
		 * solved and vice versa.
		 * 
		 * @param collidable ISimulatable to add to collision list
		 * 
		 * @see IODESolver
		 * @see addCollidable
		 * @see ICoarseCollisionDetector
		 * */
		public function addCollidable( collidable:ISimulatable ) : void
		{
			//if we haven't defined our coarse collision detector, do so with the default
			if( !_coarseDetector ) _coarseDetector = new PhysicsEngine.DEFAULT_COARSE_COLLISION_DETECTOR();
			_coarseDetector.addCollidable( collidable );
		}
		
		/**
		 * This seemingly harmless little method is the heart of the physics simulation. 
		 * 
		 * <p>
		 * It takes a stepsize over which to advance the state of the system. 
		 * The more discrete the time step (and resultant subdivided timesteps 
		 * based on <code>_solverIterations</code>) the more realistic the 
		 * simulation. Realism comes at the cost of performance.
		 * </p>
		 * 
		 * @param dt timestep with which to advance the system
		 * 
		 * @see Foam.stepForward
		 * @see Foam.stepBackward
		 * @see IODESolver.step
		 * @see #resolveCollisions
		 * */
		public function step( dt:Number = 1.0 ) : void
		{
			
			var i:int;
			var iteration:int = 0;
			
			//subdivide our timestep by the unber of iterations
			const ddt:Number = dt / _solverIterations;
			
			//run a mini simulation loop to take us from t to t + dt by ddt each iteration
			while( ++iteration <= _solverIterations )
			{
				
				i = _numODESolvers;
				while( --i > -1 )
				{
					//advance the state of each solver in the engine
					IODESolver( _odeSolvers[ i ] ).step( ddt );
				}
				
				//resolve any collisions at the end of this mini-step
				if( _coarseDetector ) resolveCollisions();
				
			}
			
		}
		
		/**
		 * Resolves collisions
		 * 
		 * <p>
		 * First a list of candidates are narrowed down by the coarse detector.
		 * Then each candidate is run through a pairwise test with each other and,
		 * given collision, is resolved. This offers an absolute bare-minimum 
		 * solution to contact/collision. Evolving this and implementing a global
		 * solution to contact and constraints in general are the focus of FOAM's
		 * next release.
		 * </p>
		 * 
		 * @see #step
		 * @see ICoarseCollisionDetector.getCandidates
		 * @see IFineCollisionDetector.hasCollision
		 * @see CollisionResolver.resolve
		 * */
		private function resolveCollisions() : void
		{
			//narrow the list of collisions
			var candidates:Array = _coarseDetector.getCandidates();
			for each( var candidate:IFineCollisionDetector in candidates )
			{
				//if the candidate does in fact have a collision- resolve it
				if( candidate.hasCollision() ) CollisionResolver.resolve( candidate.getContacts() );
			}
		}
		
		/**
		 * Removes an IODESolver from the simulation
		 * 
		 * @param solver IODESolver to remove
		 * */
		public function removeODESolver( solver:IODESolver ) : void
		{
			var index:int = _odeSolvers.indexOf( solver );
			if( index > -1 ) _odeSolvers.splice( _odeSolvers.indexOf( solver ), 1 );
			_numODESolvers = _odeSolvers.length;
		}
		
		/**
		 * Removes a collidable element from simulation
		 * 
		 * @param collidable element to remove
		 * */
		public function removeCollidable( collidable:ISimulatable ) : void
		{
			_coarseDetector.removeCollidable( collidable );
		}
		
		/**
		 * Sets the engine's coarse collision detector
		 * 
		 * @param detector ICoarseCollisionDetector to handle broad phase culling
		 * */
		public function setCoarseCollisionDetector( detector:ICoarseCollisionDetector ) : void
		{
			_coarseDetector = detector;
		}
		
		/**
		 * Defines the collision factory used by the coarse detector to return IFineCollisionDetectors
		 * 
		 * @param factory CollisionFactory
		 * */
		public function setCollisionFactory( factory:ICollisionFactory ) : void
		{
			_coarseDetector.factory = factory;
		}
		
		/**
		 * Sets the number of times the timestep is subdivided and collision is checked
		 * 
		 * @param value number of iterations to set
		 * 
		 * @see #step
		 * */
		public function set solverIterations( value:int ) : void
		{
			_solverIterations = Math.max( Math.abs( value ), 1 );
		}
		
		/**
		 * Gets an IBody that collides with the given point, if any
		 * 
		 * @param point Vector to check against all bodies
		 * 
		 * @see PointPolygonDetector
		 * */
		public function getBodyUnderPoint( point:Vector ) : IBody
		{
			
			var pointPolygonDetector:PointPolygonDetector;
			for each( var solver:IODESolver in _odeSolvers )
			{
				if( solver.ode is IBody )
				{
					pointPolygonDetector = new PointPolygonDetector( IBody( solver.ode ), point );
					if( pointPolygonDetector.hasCollision() ) return IBody( solver.ode );
				}
			}
			
			return null;
			
		}
		
	}
	
}