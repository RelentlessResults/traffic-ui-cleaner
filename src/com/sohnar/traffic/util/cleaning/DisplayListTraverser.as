package com.sohnar.traffic.util.cleaning
{
	import com.sohnar.traffic.util.DisplayListUtil;
	
	import mx.logging.Log;
	
	internal class DisplayListTraverser
	{
		private var _functionToApply:Function;
		
		public function DisplayListTraverser(applicationFunction:Function)
		{
			_functionToApply = applicationFunction;
		}
		
		public function applyToAll(component:Object):void
		{
			traverseElement(component);
		}
		
		private function traverseElement(component:Object):void
		{
			if(!component)
				return;
			
			var childIndex:int = 0;
			while (DisplayListUtil.numElements(component) > childIndex)
			{
				try {var childComponent:Object = DisplayListUtil.getElementAt(component, childIndex);}
				catch (e:Error) {}
				
				childIndex++;
				traverseElement(childComponent);
			}
			
			try {_functionToApply(component);}
			catch (e:Error)
			{
				Log.getLogger("com.sohnar.traffic.util.cleaning.DisplayListTraverser").warn("Error cleaning: "+e.message);
			}
		}
	}
}