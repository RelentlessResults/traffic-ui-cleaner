package com.sohnar.traffic.util.cleaning {
	
	import com.adobe.cairngorm.contract.Contract;

	public class DataProviderCleaner implements IDisplayObjectCleaner {
		public function canCleanDisplayObject(object:Object):Boolean {
			return object && object.hasOwnProperty("dataProvider")
		}
		
		public function cleanDisplayObject(object:Object):void {
			Contract.precondition(object.hasOwnProperty("dataProvider"));
			try {
				object.dataProvider = null;
			} catch(e:Error) {} 
		}
	}
}