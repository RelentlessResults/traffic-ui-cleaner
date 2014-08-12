package com.traffic.util.uiCleaner
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;

	public class DisplayListUtil {
		
		public static function TraverseToFindInstancesOf(root:Object, type:Class):Array {
			var dict:Dictionary = new Dictionary();
			GetAllItemsOfTypeOnDisplayList(root, type, dict);
			var result:Array = [];
			for each (var item:* in dict)
				result.push(item);
			return result;
		}
		
		private static function GetAllItemsOfTypeOnDisplayList(parent:Object, type:Class, items:Dictionary):Dictionary {
			var count:int;
			var k:int;
			
			if (parent is DisplayObjectContainer) {
				//mx
				var mxParent:DisplayObjectContainer = parent as DisplayObjectContainer;
				var mxChild:DisplayObject;
				count = mxParent.numChildren;
				for (k = 0; k<count; k++) {
					mxChild = parent.getChildAt(k);
					if (mxChild is type) {
						items[mxChild] = mxChild;
					}
					if ((mxChild is DisplayObjectContainer)||(mxChild is IVisualElementContainer)) {
						GetAllItemsOfTypeOnDisplayList(mxChild, type, items);
					}
				}
			} else if (parent is IVisualElementContainer) {
				//spark
				var sparkParent:IVisualElementContainer = parent as IVisualElementContainer;
				count = sparkParent.numElements;
				var sparkChild:IVisualElement;
				for (k = 0; k<count; k++) {
					sparkChild = sparkParent.getElementAt(k);
					if (sparkChild is type) {
						items[sparkChild] = sparkChild;
					}
					if ((sparkChild is DisplayObjectContainer)||(sparkChild is IVisualElementContainer)) {
						GetAllItemsOfTypeOnDisplayList(sparkChild, type, items);
					}
				}
			}
			
			return items;
		}
		
		public static function FindAllParentsOf(leaf:Object):Array {
			var result:Array = [];
			while(leaf) {
				result.push(leaf);
				if (leaf.hasOwnProperty("parent") && leaf.parent != null) {
					leaf = leaf.parent;
				} else {
					return result;
				}
			}
			return result;
		}
		
		public static function numElements(component:Object):int
		{
			if(component is DisplayObjectContainer)
				return DisplayObjectContainer(component).numChildren;
			else if(component is IVisualElementContainer)
				return IVisualElementContainer(component).numElements;
			
			return 0;
		}
		
		public static function getElementAt(component:Object, index:int):Object
		{
			if(component is DisplayObjectContainer)
				return DisplayObjectContainer(component).getChildAt(index);
			else if(component is IVisualElementContainer)
				return IVisualElementContainer(component).getElementAt(index);
			
			return null;
		}
		
		public static function removeElementAt(component:Object, index:int):Object
		{
			if(component is DisplayObjectContainer)
				return DisplayObjectContainer(component).removeChildAt(index);
			else if(component is IVisualElementContainer)
				return IVisualElementContainer(component).removeElementAt(index) as DisplayObject;
			
			return null;
		}
		
		public static function removeAllElements(component:Object):void
		{
			if(component is DisplayObjectContainer)
				DisplayObjectContainer(component).removeChildren();
			else if(component is IVisualElementContainer)
				IVisualElementContainer(component).removeAllElements();
		}
	}
}