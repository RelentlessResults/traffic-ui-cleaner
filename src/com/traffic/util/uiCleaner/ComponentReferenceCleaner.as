package com.traffic.util.uiCleaner
{
	import mx.core.IFlexDisplayObject;
	import mx.logging.Log;
	
	import spark.components.Grid;

	public class ComponentReferenceCleaner implements IDisplayObjectCleaner
	{
		public function canCleanDisplayObject(component:Object):Boolean
		{
			return component.hasOwnProperty("owner") && component.hasOwnProperty("document") &&
				   component.hasOwnProperty("id") && component.hasOwnProperty("parentDocument");
		}
		
		public function cleanDisplayObject(component:Object):void
		{
			if ( !(component is Grid) && component.id && component.parentDocument is IFlexDisplayObject
				&& component.parentDocument.hasOwnProperty(component.id))
			{
				try {component.deleteReferenceOnParentDocument(IFlexDisplayObject(component.parentDocument));}
				catch(e:Error)
				{
					Log.getLogger("com.sohnar.traffic.util.ComponentReferenceCleaner").warn("Error in cleanComponentReferences, UIComponent::deleteReferenceOnParentDocument() failed: " + e.message);
				}
			}
			
			component.document = null;
			component.owner = null;
		}
	}
}