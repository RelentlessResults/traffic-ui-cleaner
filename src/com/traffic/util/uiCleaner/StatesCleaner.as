package com.traffic.util.uiCleaner
{
	import com.adobe.cairngorm.contract.Contract;
	
	import mx.core.UIComponent;
	import mx.logging.Log;
	import mx.states.State;

	public class StatesCleaner implements IDisplayObjectCleaner {
		
		public function canCleanDisplayObject(object:Object):Boolean
		{
			return object is UIComponent;
		}
		
		public function cleanDisplayObject(object:Object):void
		{
			Contract.precondition(object is UIComponent);
			
			const component:UIComponent = UIComponent(object);
			
			try
			{
				// Iterate through the component's states and clean them up 
				// in preparation for garbage collection.
				while ( component.states && component.states.length > 0 )
				{
					var state : State = component.states.pop() as State;
					
					while ( state.overrides && state.overrides.length > 0 )
					{
						var stateOverride: Object = state.overrides.pop();
						
						if ( stateOverride.hasOwnProperty( "target" ) )
						{
                            stateOverride.target = null;
						}
					}
				}
			}
			catch( e : Error )
			{
				Log.getLogger("com.sohnar.traffic.util.StatesCleaner").warn( "Error in cleanStates: " + e.message );
			}
		}
	}
}