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
 * Maps and creates IFineCollisionDetectors for use by the <code>PhysicsEngine</code>
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	
	import org.generalrelativity.foam.dynamics.element.ISimulatable;
	import flash.utils.Dictionary;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.element.body.CubicBezierCurve;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.BezierDetector;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.CirclePolygonDetector;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.PolygonPolygonDetector;
	import org.generalrelativity.foam.dynamics.collision.fine.sat.CircleCircleDetector;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import org.generalrelativity.foam.dynamics.collision.ICollisionFactory;
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	import org.generalrelativity.foam.dynamics.collision.enum.CollisionType;

	public class SATCollisionFactory implements ICollisionFactory
	{
		
		/** Maps ISimulatables to the appropriate IFineCollisionDetector **/
		private var detectorMap:Dictionary;
		
		/**
		 * Creates a new SATCollisionFactor and builds its detectorMap
		 * 
		 * @see #buildDetectorMap
		 * */
		public function SATCollisionFactory()
		{
			buildDetectorMap();
		}
		
		/**
		 * Builds the detector map
		 * 
		 * @see CollisionType
		 * */
		private function buildDetectorMap() : void
		{
			
			detectorMap = new Dictionary( true );
			
			var body1IsPolygonMap:Dictionary = new Dictionary( true );
			body1IsPolygonMap[ CollisionType.CIRCLE ] = CirclePolygonDetector;
			body1IsPolygonMap[ CollisionType.CUBIC_BEZIER_CURVE ] = BezierDetector;
			body1IsPolygonMap[ CollisionType.RIGID_BODY ] = PolygonPolygonDetector;
			var body1IsCircleMap:Dictionary = new Dictionary( true );
			body1IsCircleMap[ CollisionType.RIGID_BODY ] = CirclePolygonDetector;
			body1IsCircleMap[ CollisionType.CIRCLE ] = CircleCircleDetector;
			body1IsCircleMap[ CollisionType.CUBIC_BEZIER_CURVE ] = BezierDetector;
			var body1IsBezierMap:Dictionary = new Dictionary( true );
			body1IsBezierMap[ CollisionType.RIGID_BODY ] = BezierDetector;
			body1IsBezierMap[ CollisionType.CIRCLE ] = BezierDetector;
			
			detectorMap[ CollisionType.RIGID_BODY ] = body1IsPolygonMap;
			detectorMap[ CollisionType.CIRCLE ] = body1IsCircleMap;
			detectorMap[ CollisionType.CUBIC_BEZIER_CURVE ] = body1IsBezierMap;
			
		}
		
		/**
		 * Gets an SAT IFineCollisionDetector based on the supplied elements
		 * 
		 * @param element1 first element to consider
		 * @param element2 second element to consider
		 * 
		 * @return implementor of IFineCollisionDetector to be used by the <code>PhysicsEngine</code>
		 * to ultimately determine collision and to generate contacts
		 * 
		 * @see ICoarseCollisionDetector.getCandidates
		 * */
		public function getCollisionDetector( element1:ISimulatable, element2:ISimulatable ) : IFineCollisionDetector
		{
			
			var detectorClass:Class = detectorMap[ element1.collisionTypeID ][ element2.collisionTypeID ];
			
			//circle and bezier detectors expect the circle and curve respectively first
			if( element2 is Circle || element2 is CubicBezierCurve ) return IFineCollisionDetector( new detectorClass( element2, element1 ) );
			else return IFineCollisionDetector( new detectorClass( element1, element2 ) );
			
			return null;
			
		}
		
	}
}