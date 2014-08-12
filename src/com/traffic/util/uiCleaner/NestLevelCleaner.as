package com.traffic.util.uiCleaner {
	
	import mx.core.Container;
	import mx.core.IUITextField;
	import mx.core.UIFTETextField;
	import mx.managers.ILayoutManagerClient;

	/**
	 * TEMPFIX:
	 * This only exists because of https://issues.apache.org/jira/browse/FLEX-13036.
	 * Please remove this class once that's fixed.
	 * 
	 * ASSUMPTION: this class assumes that the objects we're dealing with here
	 * are not on stage anymore. Currently that's a valid assumption, but 
	 * keep in mind in case we change the way we clean display components.
	 */
	public class NestLevelCleaner implements IDisplayObjectCleaner
	{
		public function canCleanDisplayObject(object:Object):Boolean
		{
			const objectHasNestLevelProperty:Boolean = object is ILayoutManagerClient || object is IUITextField || object is UIFTETextField;
			if(objectHasNestLevelProperty)
				return object.hasOwnProperty("parent") && object.parent is Container;
			
			return false;
		}
		
		public function cleanDisplayObject(object:Object):void
		{
			if(object is ILayoutManagerClient)
				ILayoutManagerClient(object).nestLevel = 0;
			else if(object is IUITextField)
				IUITextField(object).nestLevel = 0;
			else if(object is UIFTETextField)
				UIFTETextField(object).nestLevel = 0;
		}
	}
}