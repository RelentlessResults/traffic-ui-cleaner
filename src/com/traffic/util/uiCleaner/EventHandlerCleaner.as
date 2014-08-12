package com.traffic.util.uiCleaner {
	import mx.core.FlexSprite;

	public class EventHandlerCleaner implements IDisplayObjectCleaner {
		
		public function canCleanDisplayObject(object:Object):Boolean {
			return object is FlexSprite;
		}
		
		public function cleanDisplayObject(object:Object):void {
			object.removeAllListeners();
		}
	}
}