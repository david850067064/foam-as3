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
 * Coarsely detects possible collisions depending on AABRs
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * @see PhysicsEngine
 * @see ICoarseCollisionDetector
 * @see AABR
 * @see CollisionFactory
 * */
package org.generalrelativity.foam.dynamics.collision.coarse
{
	
	import org.generalrelativity.foam.dynamics.collision.ICoarseCollisionDetector;
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import org.generalrelativity.foam.dynamics.collision.geom.AABR;
	import org.generalrelativity.foam.dynamics.element.IBody;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.enum.Simplification;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.SATCollisionFactory;
	import flash.utils.getDefinitionByName;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;

	public class AABRDetector implements ICoarseCollisionDetector
	{
		
		/** holds a cache of AABRs for non moving objects **/
		private var _staticAABRCache:Dictionary;
		/** holds a cache of AABRs for moving objects (emptied each update) **/
		private var _dynamicAABRCache:Dictionary;
		/** holds all non moving collidables (not tested against eachother) **/
		private var _staticCollidables:Array;
		/** holds all moving collidables **/
		private var _dynamicCollidables:Array;
		/** optimization- holds an unchanging length for dynamic collidables **/
		private var _dynamicLength:int;
		/** optimization- holds an unchanging length of all collidables **/
		private var _collidablesLength:int;
		/** collision factory to use */
		private var _factory:ICollisionFactory;
		
		/**
		 * Creates a new AABRDetector for use in collision culling by <code>PhysicsEngine</code>
		 * 
		 * @see PhysicsEngine
		 * */
		public function AABRDetector()
		{
			_staticAABRCache = new Dictionary( true );
			_dynamicAABRCache = new Dictionary( true );
			_staticCollidables = new Array();
			_dynamicCollidables = new Array();
			_factory = new SATCollisionFactory();
		}
		
		/**
		 * Gets an Array of IFineCollisionDetectors from all pairwise detections not ruled out
		 * 
		 * @return all necessary pairwise collision tests remaining
		 * 
		 * @see PhysicsEngine
		 * @see ICoarseCollisionDetector
		 * @see ICollisionFactory.getCollisionDetector
		 * @see #getBoundedAABR
		 * */
		public function getCandidates() : Array
		{
			
			//reset the movable AABR cache
			_dynamicAABRCache = new Dictionary( true );
			
			//define an Array to hold all fine collision-requirements
			var candidates:Array = new Array();
			
			//declare AABRs to compare against eachother
			var aabrI:AABR, aabrJ:AABR;
			
			var i:int = -1;
			var j:int;
			
			//define a list of all collidables with the statics on the end
			var collidables:Array = _dynamicCollidables.concat( _staticCollidables );
			
			while( ++i < _dynamicLength )
			{
				//define a first AABR
				aabrI = getBoundedAABR( _dynamicCollidables[ i ] );
				j = i;
				while( ++j < _collidablesLength )
				{
					//define a second AABR
					aabrJ = getBoundedAABR( collidables[ j ] );
					//if the 2 AABRs collide, push them into the list of elements that need to have fine collision detection performed
					if( aabrI.hasCollision( aabrJ ) ) candidates.push( _factory.getCollisionDetector( collidables[ i ], collidables[ j ] ) );
				}
			}
			
			//return all remaining candidates
			return candidates;
			
		}
		
		/**
		 * Gets the <code>AABR</code> for the supplied <code>IBody</code>
		 * 
		 * <p>
		 * If an update isn't needed on the AABR, we can map to it in the cache.
		 * </p>
		 * 
		 * @param body IBody to bound
		 * 
		 * @return AABR of <code>body</code>
		 * 
		 * @see #getCandidates
		 * @see AABR.bound
		 * */
		private function getBoundedAABR( body:IBody ) : AABR
		{
			
			if( _dynamicAABRCache[ body ] ) return AABR( _dynamicAABRCache[ body ] );
			if( _staticAABRCache[ body ] ) return AABR( _staticAABRCache[ body ] );
			
			//if we haven't exited the function, we need to create a new AABR to bound the body with
			var aabr:AABR = new AABR();
			aabr.bound( body );
			return aabr;
			
		}
		
		/**
		 * Sets the ICollisionFactory used to return a certain type of IFineCollisionDetectors.
		 * 
		 * <p>
		 * This opens up the easy swappability of entire detection sets
		 * </p>
		 * 
		 * @param factory ICollisionFactory to set
		 * 
		 * @see #getCandidates
		 * */
		public function set factory( factory:ICollisionFactory ) : void
		{
			_factory = factory;	
		}
		
		/**
		 * Adds a collidable element to detect for collision
		 * 
		 * @param collidable element to add for detection
		 * 
		 * @see ISimulatable
		 * @see PhysicsEngine
		 * @see #removeCollidable
		 * */
		public function addCollidable( collidable:ISimulatable ) : void
		{
			if( collidable.mass == Simplification.INFINITE_MASS ) _staticCollidables.push( collidable );
			else
			{
				_dynamicCollidables.push( collidable );
				_dynamicLength++;
			} 
			_collidablesLength++;
		}
		
		public function getDynamicCollidables() : Array
		{
			return _dynamicCollidables;
		}
		
		/**
		 * Removes a collidable element from coarse detection
		 * 
		 * @param collidable element to remove from detection
		 * 
		 * @see ISimulatable
		 * @see PhysicsEngine
		 * @see #removeCollidable
		 * */
		public function removeCollidable( collidable:ISimulatable ) : void
		{
			var index:int = _dynamicCollidables.indexOf( collidable );
			if( index > -1 ) _dynamicCollidables.splice( _dynamicCollidables.indexOf( collidable ), 1 );
			else
			{
				index = _staticCollidables.indexOf( collidable );
				if( index > -1 ) _staticCollidables.splice( _staticCollidables.indexOf( collidable ), 1 );
			}
			_dynamicLength = _dynamicCollidables.length;
			_collidablesLength = _dynamicLength + _staticCollidables.length;
		}
		
		
	}
}