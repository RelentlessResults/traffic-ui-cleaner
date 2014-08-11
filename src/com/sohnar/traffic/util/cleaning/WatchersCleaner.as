package com.sohnar.traffic.util.cleaning
{
	import mx.binding.Binding;
	import mx.binding.FunctionReturnWatcher;
	import mx.binding.PropertyWatcher;
	import mx.binding.RepeaterComponentWatcher;
	import mx.binding.Watcher;
	import mx.core.mx_internal;
	import mx.logging.Log;
	

	use namespace mx_internal;
	
	public class WatchersCleaner implements IDisplayObjectCleaner {
		
		public function canCleanDisplayObject(object:Object):Boolean
		{
			return object != null;
		}
		
		/*************************************************************************
		 * Removes any watchers that are assigned to 
		 * the passed UIComponent-derived instance by the MXML compiler.  Note 
		 * that it does NOT remove ChangeWatcher instances that were manually
		 * added using the BindingUtils class.
		 *************************************************************************/
		public function cleanDisplayObject(component:Object):void
		{
			try
			{
				// Verify required Flex framework modifications have been made
				// before attempting to clean up watchers.  Note that this isn't
				// a thorough check as it only checks one modified property on
				// the base Watcher class.  Any error resulting from an incomplete
				// modification of the framework source will be caught by our
				// try/catch block.
				var watcher : Watcher = component._watchers[0];
				if ( !watcher || !watcher.hasOwnProperty( "listeners" ) )
					return;
				
				while (component._watchers.length)
				{
					cleanWatcher(component._watchers.splice( 0, 1 )[0]);
				}
			}
			catch( e : Error )
			{
				Log.getLogger("com.sohnar.traffic.util.cleaning.WatchersCleaner").debug( "Error in cleanWatchers: " + e.message );
			}
		}
		
		
		
		private function cleanWatcher( watcher : Watcher ):void
		{
			// The Watcher instance is cast to an Object in this function to avoid any compiler 
			// complaints if the needed Flex framework modifications haven't been made.
			
			if ( watcher != null )
			{
				// Call ourself recursively to eliminate child watchers
				if ( Object(watcher).children != null )
				{
					while ( Object(watcher).children.length > 0 )
					{
						var childWatcher : Watcher = Object(watcher).children.splice(0, 1 )[0];
						if ( childWatcher != null )
						{
							cleanWatcher( childWatcher );
						}
					}
				}
				
				// Clear all associated bindings
				if ( Object(watcher).listeners != null )
				{
					while ( Object(watcher).listeners.length > 0 )
					{
						var binding : Binding = Object(watcher).listeners.splice(0, 1 )[0];
						if ( binding != null )
						{
							BindingOperations.cleanBinding( binding );
						}
					}
				}
				
				watcher.value = null;
				
				if ( watcher is PropertyWatcher )
				{
					Object( watcher ).parentObj = null;
					Object( watcher ).propertyGetter = null;
				}
				
				if ( watcher is FunctionReturnWatcher )
				{
					Object( watcher ).parentObj = null;
					Object( watcher ).functionGetter = null;
					Object( watcher ).document = null;
					Object( watcher ).parameterFunction = null;
				}
				
				if ( watcher is RepeaterComponentWatcher && Object( watcher ).clones.length > 0 )
				{
					while ( Object(watcher).clones.length > 0 )
					{
						var childRepeaterWatcher : RepeaterComponentWatcher = Object(watcher).clones.splice( 0, 1 )[0];
						if ( childRepeaterWatcher != null )
						{
							cleanWatcher( childRepeaterWatcher );
						}
					} 
				}
			}
		}
	}
}