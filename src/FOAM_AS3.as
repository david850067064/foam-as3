package 
{
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import example.orbit.SimpleOrbit;

	[SWF( backgroundColor="#ececed", width="800", height="600" )] 
	public class FOAM_AS3 extends Sprite
	{
		
		public function FOAM_AS3()
		{
			
			stage.frameRate = 31;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addChild( new SimpleOrbit() );
			
		}
		
	}
}
