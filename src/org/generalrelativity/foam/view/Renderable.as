package org.generalrelativity.foam.view
{
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Renderable
	{
		
		public var element:*;
		public var isDynamic:Boolean;
		public var depth:int;
		public var renderMethodKey:Class;
		
		public function Renderable( element:*, 
									isDynamic:Boolean = true, 
									depth:int = 0 )
		{
			
			this.element = element;
			this.isDynamic = isDynamic;
			this.depth = depth;
			this.renderMethodKey = getDefinitionByName( getQualifiedClassName( element ) ) as Class;
			
		}
		
	}
}