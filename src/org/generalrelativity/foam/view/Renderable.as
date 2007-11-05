package org.generalrelativity.foam.view
{
	import org.generalrelativity.foam.dynamics.element.body.RigidBody;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Renderable
	{
		
		public var element:*;
		public var isDynamic:Boolean;
		public var renderMethodKey:Class;
		public var data:*;
		
		public function Renderable( element:*, 
									isDynamic:Boolean = true, 
									data:* = null )
		{
			
			this.element = element;
			this.isDynamic = isDynamic;
			this.data = data;
			this.renderMethodKey = getDefinitionByName( getQualifiedClassName( element ) ) as Class;
			
		}
		
	}
}