package com.traffic.util.uiCleaner {
	internal interface IDisplayObjectCleaner {
		
		function canCleanDisplayObject(object:Object):Boolean;
		function cleanDisplayObject(object:Object):void;
			
	}
}