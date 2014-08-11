package com.sohnar.traffic.util.cleaning
{
	import mx.binding.Binding;
	import mx.core.mx_internal;

	use namespace mx_internal;
	
	public class BindingsCleaner implements IDisplayObjectCleaner
	{
		public function canCleanDisplayObject(component:Object):Boolean
		{
			return component != null;
		}
		
		/*************************************************************************
		 * Iterates through the assigned bindings
		 * found on the passed component and removes them.  This function is based
		 * on the implementation of the Flex framework's 
		 * BindingManager::executeBindings() function.
		 *************************************************************************/
		public function cleanDisplayObject(component:Object):void
		{
			try {
				const bindings:Array = component._bindings || [];
				component._bindingsByDestination = {};
				component._bindingsBeginWithWord = {};
			}
			catch(e:Error) {}
			
			// Release all bindings maintained by the component
			while (bindings && bindings.length)
			{
				BindingOperations.cleanBinding(bindings.splice( 0, 1 )[0]);
			}
			
			// Release parent document bindings to our component
			var componentID : String = component.hasOwnProperty("id") ? component.id : "";
			if (componentID)
			{
				var document: Object = component.descriptor && component.descriptor.document ? component.descriptor.document : component.parentDocument;
				if(!document)
					return;
				
				try {
					const ownerBindings:Array = document._bindings || [];
					const ownerBindingsByDest:Object = document._bindingsByDestination;
					const ownerBindingsBeginWithWord:Object = document._bindingsBeginWithWord;
				}
				catch(e:Error) {return;}
				
				if (ownerBindingsByDest && ownerBindingsBeginWithWord[getFirstWord(componentID)])
				{
					// Track the number of deletions to know when to stop iterating the bindings array
					var deletedCount:uint = 0;
					var binding:Binding;
					
					for (var bindingID:String in ownerBindingsByDest)
					{
						if (bindingID.charAt(0) == componentID.charAt(0))
						{
							if (bindingID.indexOf(componentID + ".") == 0 ||
								bindingID.indexOf(componentID + "[") == 0 ||
								bindingID == componentID)
							{
								binding = ownerBindingsByDest[bindingID];
								if (binding)
								{
									BindingOperations.cleanBinding(binding);
									ownerBindingsByDest[bindingID] = null;
									delete ownerBindingsByDest[bindingID];
									
									deletedCount++;
								}
							}
						}
					}
					
					if ( deletedCount > 0 )
					{
						for (var index : uint = 0, length:uint = ownerBindings.length; index < length && deletedCount > 0; index++ )
						{
							binding = ownerBindings[index] as Binding;
							if (binding && !binding.mx_internal::document)
							{
								ownerBindings.splice(index--, 1);
								deletedCount--;
							}
						}
					}
				}
			}
		}
		
		/*************************************************************************
		 * The getFirstWord() function is a private helper for cleanBindings().
		 * Its functionality is duplicated from the Flex framework's 
		 * BindingManager class
		 *************************************************************************/
		////////////////////////////////////////////////////////////////////////////////
		//
		//  ADOBE SYSTEMS INCORPORATED
		//  This function copyright 2003-2007 Adobe Systems Incorporated
		//  All Rights Reserved.
		//
		//  NOTICE: Adobe permits you to use, modify, and distribute this function
		//  in accordance with the terms of the license agreement accompanying it.
		//
		////////////////////////////////////////////////////////////////////////////////
		static public function getFirstWord( destStr : String ):String
		{
			// indexPeriod and indexBracket will be equal only if they
			// both are -1.
			var indexPeriod : int = destStr.indexOf(".");
			var indexBracket : int = destStr.indexOf("[");
			if ( indexPeriod == indexBracket )
				return destStr;
			
			// Get the characters leading up to the first period or
			// bracket.
			var minIndex : int = Math.min( indexPeriod, indexBracket );
			if ( minIndex == -1 )
				minIndex = Math.max( indexPeriod, indexBracket );
			
			return destStr.substr( 0, minIndex );
		}
	}
}