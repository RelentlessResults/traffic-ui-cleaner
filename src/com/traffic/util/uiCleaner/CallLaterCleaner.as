package com.traffic.util.uiCleaner
{
	import mx.core.UIComponent;
	import mx.core.mx_internal;

	public class CallLaterCleaner implements IDisplayObjectCleaner {
		
		public function canCleanDisplayObject(object:Object):Boolean {
			return object is UIComponent;
		}
		
		public function cleanDisplayObject(object:Object):void {
			UIComponent(object).mx_internal::cancelAllCallLaters();
		}
		
	}
}