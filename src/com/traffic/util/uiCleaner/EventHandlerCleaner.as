package com.sohnar.traffic.util {
    import com.sohnar.traffic.util.cleaning.*;
	
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