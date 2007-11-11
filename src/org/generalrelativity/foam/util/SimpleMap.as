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
 * Simple map data holder
 * 
 * @author Drew Cummins
 * @since 10.31.07
 * */
package org.generalrelativity.foam.util
{
	public class SimpleMap
	{
		
		protected var _keys:Array;
		protected var _values:Array;
		
		public function SimpleMap()
		{
			_keys = new Array();
			_values = new Array();
		}
		
		public function put( key:*, value:* ) : void
		{
			var index:int = getKeyIndex( key );
			if( index > -1 ) _values[ index ] = value;
			else
			{
				_keys.push( key );
				_values.push( value );
			}
		}
		
		public function getValue( key:* ) : *
		{
			var index:int = getKeyIndex( key );
			if( index > -1 ) return _values[ index ];
		}
		
		public function getKey( value:* ) : *
		{
			var index:int = getValueIndex( value );
			if( index > -1 ) return _keys[ index ];
		}
		
		public function remove( key:* ) : void
		{
			var index:int = getKeyIndex( key );
			if( index > -1 )
			{
				_keys.splice( index, 1 );
				_values.splice( index, 1 );
			}
		}
		
		public function getKeyIndex( key:* ) : int
		{
			return _keys.indexOf( key );
		}
		
		public function getValueIndex( value:* ) : int
		{
			return _values.indexOf( value );
		}
		
		public function has( key:* ) : Boolean
		{
			return getKeyIndex( key ) > -1;
		}
		
		public function get length() : int
		{
			return _keys.length;
		}
		
		public function get keys() : Array
		{
			return _keys.slice();
		}
		
		public function get values() : Array
		{
			return _values.slice();
		}
		
	}
}