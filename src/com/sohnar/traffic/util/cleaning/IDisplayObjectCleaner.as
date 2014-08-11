package com.sohnar.traffic.util.cleaning {
	internal interface IDisplayObjectCleaner {
		
		function canCleanDisplayObject(object:Object):Boolean;
		function cleanDisplayObject(object:Object):void;
			
	}
}