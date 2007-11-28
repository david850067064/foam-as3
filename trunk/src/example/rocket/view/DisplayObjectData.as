package example.rocket.view
{
	import flash.display.DisplayObject;
	
	dynamic public class DisplayObjectData
	{
		
		public var offsetX:Number;
		public var offsetY:Number;
		public var autoCenter:Boolean;
		public var hasBeenDisplayed:Boolean;
		protected var _displayObject:DisplayObject;
		
		public function DisplayObjectData( displayObject:*, offsetX:Number = 0, offsetY:Number = 0, autoCenter:Boolean = true )
		{
			this.displayObject = displayObject;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			this.autoCenter = autoCenter;
		}
		
		public function set displayObject( value:* ) : void
		{
			if( value is DisplayObject ) _displayObject = value;
			else if( value is Class ) _displayObject = new value();
			else throw new ArgumentError( "DisplayObjectData.displayObject must be a DisplayObject or DisplayObject Class" );
		}
		
		public function get displayObject() : DisplayObject
		{
			return _displayObject;
		}
		
	}
}