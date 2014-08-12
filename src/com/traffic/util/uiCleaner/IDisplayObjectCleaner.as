package com.sohnar.traffic.util {
	internal interface IDisplayObjectCleaner {
		
		function canCleanDisplayObject(object:Object):Boolean;
		function cleanDisplayObject(object:Object):void;
			
	}
}