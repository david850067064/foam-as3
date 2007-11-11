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
 * Basal implementation of ISimulatable
 * 
 * <p>
 * SimpleParticle could be used to simulate particle movement- though no collision
 * system is currently in place for such elements.
 * </p>
 * 
 * <p>
 * SimpleParticle implements IODE as well. This means that the PhysicsEngine can
 * advance its state. The IODESolver associated with this "equation" will call for
 * this particle's derivative- it's important that from within that call all forces
 * are accumulated according to the given state. For this reason and tidy modularity,
 * all forces are typically added by IForceGenerators.
 * </p>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see ISimulatable
 * @see IODE
 * @see Foam
 * @see IForceGenerator
 * */
package org.generalrelativity.foam.dynamics.element.particle
{
	
	import org.generalrelativity.foam.dynamics.ode.IODE;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.math.Vector;
	import org.generalrelativity.foam.dynamics.force.IForceGenerator;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.util.MathUtil;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;

	public class SimpleParticle implements IODE, ISimulatable
	{
		
		/** holds the mass of the particle **/
		protected var _mass:Number;
		/** holds the inverse mass- this is an optimization as multiplication is faster than division and we can calculate this offline */
		protected var _inverseMass:Number;
		/** holds all accummulate forces **/
		protected var _force:Vector;
		/** holds the state of the system **/
		protected var _state:Array;
		/** holds all IForceGenerators affecting this particle **/
		protected var _generators:Array;
		/** elastic coefficient of particle (used in collision response) **/
		protected var _elasticity:Number;
		/** frictional coefficient (used in collision response) **/
		protected var _friction:Number;
		
		/**
		 * Creates a new SimpleParticle
		 * 
		 * @param x horizontal position of particle
		 * @param y vertical position of particle
		 * @param vx horizontal starting velocity of particle
		 * @param vy vertical starting velocity of particle
		 * @param mass mass of element
		 * @param friction frictional coefficient (0 - 1.0)
		 * @param elasticity elastic coefficient (0 - 1.0)
		 * @param stateLength- defines the length of this IODE's state
		 * */
		public function SimpleParticle( 	x:Number, 
											y:Number, 
											vx:Number = 0, 
											vy:Number = 0, 
											mass:Number = 100, 
											friction:Number = 0.2,
											elasticity:Number = 0.25,
											stateLength:uint = 4 )
		{
			
			_state = new Array( stateLength );
			//define a new Array to hold force generators
			_generators = new Array();
			this.x = x;
			this.y = y;
			this.vx = vx;
			this.vy = vy;
			this.mass = mass;
			this.friction = friction;
			this.elasticity = elasticity;
			//creates an empty force vector
			clearForces();
			
		}
		
		/**
		 * Gets the element's derivative
		 * 
		 * <p>
		 * This is called by this equation's IODESolver. First, the state is updated. Then,
		 * all forces are accumulated based on this state (this is important- without this,
		 * higher-order differential equation solvers have no worth). Next, the derivative
		 * is populated. Finally all forces are cleared.
		 * </p>
		 * 
		 * @param state state needed to define derivative
		 * @param derivative derivative at given state
		 * 
		 * @see #state
		 * @see IODESolver.step
		 * */
		public function getDerivative( state:Array, derivative:Array ):void
		{
			
			//update the state
			this._state = state;
			
			//accumulate forces
			accumulateForces();
			
			//derivative of position
			derivative[ 0 ] = state[ 2 ]; //vx
			derivative[ 1 ] = state[ 3 ]; //vy
			
			//derivative of velocity
			derivative[ 2 ] = _force.x * inverseMass; //ax
			derivative[ 3 ] = _force.y * inverseMass; //ay
			
			//clear all forces
			clearForces();
			
		}
		
		/**
		 * Gets the state of the differential equation
		 * 
		 * <p>
		 * Consider a particle with position x and velocity v. We want to
		 * integrate this state with respect to time. The position and 
		 * velocity are pushed into the particle's state Array and solved
		 * by an IODESolver. By abstracting the process this far, we make
		 * it easy to swap solvers for different tasks.
		 * </p>
		 * 
		 * @return Array of Numbers to integrate with respect to time
		 * 
		 * @see #getDerivative
		 * @see IODESolver
		 * */
		public function get state():Array
		{
			return _state;
		}
		
		/**
		 * Adds a force to the particle
		 * 
		 * @param force force to add
		 * */
		public function addForce( force:Vector ) : void
		{
			_force.plusEquals( force );
		}
		
		/**
		 * Clears all forces
		 * */
		public function clearForces() : void
		{
			_force = new Vector();
		}
		
		/**
		 * Adds a force generator to influence this particle
		 * 
		 * @param generator IForceGenerator to add
		 * 
		 * @see IForceGenerator
		 * @see #removeForceGenerator
		 * */
		public function addForceGenerator( generator:IForceGenerator ) : void
		{
			//only add if force generator not already existent in generators
			if( _generators.indexOf( generator ) == -1 ) _generators.push( generator );
		}
		
		/**
		 * Removes a force generator
		 * 
		 * @param generator IForceGenerator to remove
		 * 
		 * @see IForceGenerator
		 * @see #addForceGenerator
		 * */
		public function removeForceGenerator( generator:IForceGenerator ) : void
		{
			var index:int = _generators.indexOf( generator );
			if( index > -1 ) _generators.splice( _generators.indexOf( generator ), 1 );
		}
		
		/**
		 * Accumulates forces
		 * 
		 * @see IForceGenerator.generate
		 * */
		public function accumulateForces() : void
		{
			//iterate over each generator, calling it to influence this particle
			for each( var generator:IForceGenerator in _generators )
			{
				generator.generate( this );
			}
		}
		
		
		public function get force() : Vector
		{
			return _force;
		}
		
		public function get collisionTypeID() : String
		{
			return CollisionType.ABSTRACT_PARTICLE;
		}
		
		/**
		 * Note that these values that constitute this IODE's state use getters/setters
		 * that access specific indices within _state. Everything is modified through this
		 * state Array
		 * 
		 * @see IODE
		 * @see ISimulatable
		 * */
		 
		public function get x() : Number { return _state[ 0 ]; }
		public function set x( value:Number ) : void { _state[ 0 ] = value; }
		
		public function get y() : Number { return _state[ 1 ]; }
		public function set y( value:Number ) : void { _state[ 1 ] = value; }
		
		public function get vx() : Number { return _state[ 2 ]; }
		public function set vx( value:Number ) : void { _state[ 2 ] = value; }
		
		public function get vy() : Number { return _state[ 3 ]; }
		public function set vy( value:Number ) : void { _state[ 3 ] = value; }
		
		public function get inverseMass() : Number { return _inverseMass; }
		
		public function get mass() : Number { return _mass; }
		
		/**
		 * Sets the particle's mass
		 * 
		 * @param value Number to set as mass- the inverse mass is then calculated
		 * 
		 * @see Simplification.INFINITE_MASS
		 * */
		public function set mass( value:Number ) : void 
		{ 
			_mass = value; 
			if( _mass == Simplification.INFINITE_MASS ) _inverseMass = 0;
			else _inverseMass = 1 / value;
		}
		
		public function get position() : Vector { return new Vector( x, y ); }
		public function get velocity() : Vector { return new Vector( vx, vy ); }
		
		public function get friction() : Number { return _friction; }
		//clamp the friction value to a legal range
		public function set friction( value:Number ) : void { _friction = MathUtil.clamp( 0, 1, value ); }
		
		public function get elasticity() : Number { return _elasticity; }
		//clamp the elasticity to a legal range
		public function set elasticity( value:Number ) : void { _elasticity = MathUtil.clamp( 0, 1, value ); }
		
	}
}