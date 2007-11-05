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
 * Detects collision between a CubicBezierCurve and RigidBody
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * 
 * NOTE: this is pretty hacky and not very fast- the bezier stuff was all a test 
 * of sorts and needs to be properly thought out
 * 
 * @see IFineCollisionDetector
 * @see CubicBezierCurve
 * @see PolygonPolygonDetector
 * */
package org.generalrelativity.foam.dynamics.collision.fine.sat
{
	import org.generalrelativity.foam.dynamics.collision.IFineCollisionDetector;
	import org.generalrelativity.foam.dynamics.element.body.CubicBezierCurve;
	import org.generalrelativity.foam.dynamics.element.body.Circle;
	import org.generalrelativity.foam.dynamics.element.IBody;

	public class BezierDetector implements IFineCollisionDetector
	{
		
		protected var curve:CubicBezierCurve;
		protected var body2:IBody;
		protected var detectors:Array;
		
		public function BezierDetector( curve:CubicBezierCurve, body2:IBody )
		{
			this.curve = curve;
			this.body2 = body2;
		}
		
		public function getContacts() : Array
		{
			var contacts:Array = new Array;
			while( detectors.length )
			{
				contacts = contacts.concat( IFineCollisionDetector( detectors.pop() ).getContacts() );
			}
			return contacts;
		}
		
		public function hasCollision():Boolean
		{
			detectors = new Array();
			var detector:IFineCollisionDetector;
			for each( var line:IBody in curve.lines )
			{
				if( body2 is Circle ) detector = new CirclePolygonDetector( Circle( body2 ), line );
				else detector = new PolygonPolygonDetector( line, body2 );
				if( detector.hasCollision() )
				{
					detectors.push( detector );
				}
			}
			return detectors.length > 0;
		}
		
	}
}