package com.traffic.util.uiCleaner
{
	/*************************************************************************
	 *
	 * http://code.google.com/p/flex-uicomponent-cleaner-and-gc-initiator/
	 *
	 * UIComponentCleaner class v1.0
	 * 
	 * The UIComponentCleaner class is a static utility class used to break 
	 * down a display component and its children so they will be prepared for
	 * garbage collection eligibility based on the Flash Player's simple
	 * reference count technique.  This class has been tested up to version
	 * 3.6 of the Adobe Flex SDK.  It has not been tested with versions 4.x
	 * of the SDK.
	 * 
	 * Use of this class to remove watchers from the passed 
	 * UIComponent-derived class instance requires modifying the Flex 
	 * framework-provided mx.binding::Watcher, mx.binding::PropertyWatcher,
	 * mx.binding::FunctionReturnWatcher and 
	 * mx.binding::RepeaterComponentWatcher classes to allow access to
	 * the following private properties declared in those classes:
	 * 
	 * mx.binding::FunctionReturnWatcher - Change the private "document", 
	 * "parameterFunction", "parentObj" and "functionGetter" properties to
	 * properties to public scope.
	 * 
	 * mx.binding::PropertyWatcher - Change the private "parentObj" Object and 
	 * protected "propertyGetter" Function properties to public scope.
	 * 
	 * mx.binding::RepeaterComponentWatcher - Change the private "clones"
	 * Array property to public scope.
	 * 
	 * mx.binding::Watcher - Change the protected "listeners" and "children" 
	 * Array properties to public scope.
	 * 
	 * If you are statically linking the Flex framework into your application,
	 * copy the above listed files from the Flex SDK source directory into
	 * your projects main source folder, maintaining the "mx.binding" package
	 * composition.  For example, if your main source folder is located in
	 * "src/main/flex", you would copy the files to the 
	 * "src/main/flex/mx/binding" folder before modifying them as instructed
	 * above.
	 * 
	 * If you are loading the Flex framework into your application using an
	 * RSL, you can follow the directions available at the below link to
	 * create your own RSL that can be loaded into your application domain
	 * before the Flex framework RSL in order for the modifications to be
	 * applied.
	 * 
	 * http://blogs.adobe.com/dloverin/2010/01/how_to_monkey_patch_when_using_flex_rsls.html
	 * 
	 * The UIComponentCleaner class will still function without failing if 
	 * you choose to not modify the Flex framework classes.  However, its
	 * level of success in preparing the passed UIComponent-derived instance
	 * for garbage collection will be reduced.
	 * 
	 * The order in which some of the cleaners run is very specific:
	 * * (TFC-10172, TFC-10256) ComponentReferenceCleaner needs to run before FlexSpriteCleaner,
	 * because otherwise clearing the references on the skin doesn't clean them on the skin owner.
	 * * (TFC-10364) ComponentReferenceCleaner needs to run after BindingsCleaner, because otherwise
	 * double-bound components will change the model values to null when we clear the references
	 * on the skin due to the way double bindings are created under the hood. See
	 * https://issues.apache.org/jira/browse/FLEX-33940 for details. (And please remove this
	 * comment once that ticket is solved in the SDK.)
	 * * (TFC-10364) BindingsCleaner needs to run before DisposableCleaner, because otherwise, if a
	 * view component which is double-bound to clears its selectedItem or dataProvider in its
	 * dispose() method, it will again set the model value to null.
	 * * (TFC-10591) CallLaterCleaner is best run at the very end, just in case the previous cleaners
	 * trigger a callLater action on a component.
	 * 
	 *************************************************************************
	 * 
	 * Copyright (C) 2011 except where noted by Tommy Baggett 
	 * (http://www.linkedin.com/in/tommybaggett), Ansuria Solutions LLC
	 * 
	 * Permission is hereby granted, free of charge, to any person obtaining a
	 * copy of this software and associated documentation files (the 
	 * "Software"), to deal in the Software without restriction, including 
	 * without limitation the rights to use, copy, modify, merge, publish, 
	 * distribute, sublicense, and/or sell copies of the Software, and to 
	 * permit persons to whom the Software is furnished to do so, subject to 
	 * the following conditions:
	 * 
	 * The above copyright notice and this permission notice shall be included 
	 * in all copies or substantial portions of the Software.
	 * 
	 * The original copyright restrictions, as defined in the license 
	 * agreement that accompanied it, are respected on Adobe Systems 
	 * Incorporated code.
	 * 
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
	 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
	 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
	 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
	 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
	 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	 * 
	 *************************************************************************/
	
	import mx.core.IUIComponent;
	import mx.managers.ISystemManager;
	
	import spark.components.Grid;
	
	[Mixin]
	public class DisplayObjectCleanerTools
	{
		
		private static var step1:Vector.<IDisplayObjectCleaner>;
		private static var step2:Vector.<IDisplayObjectCleaner>;
		
		public static function init(sm:ISystemManager):void {
			step1 = new Vector.<IDisplayObjectCleaner>();
			step1.push(new NestLevelCleaner());
			step1.push(new BindingsCleaner());
			step1.push(new DataProviderCleaner());
			
			step2 = new Vector.<IDisplayObjectCleaner>();
			step2.push(new ComponentReferenceCleaner());
			step2.push(new EventHandlerCleaner());
			step2.push(new WatchersCleaner());
			step2.push(new TransitionsCleaner());
			step2.push(new StatesCleaner());
			step2.push(new CallLaterCleaner());
		}
		
		
		/*************************************************************************
		 * The primary function of the UIComponentCleaner class is the 
		 * cleanDisplayComponents() function.  Once a display component is no 
		 * longer needed and should be released from memory, it should be passed 
		 * to this function.  Optionally, if you have a Flex mx::Container-derived
		 * class instance and you want to only remove its contents, you can use 
		 * this function and pass a value of true for the cleanChildrenOnly 
		 * parameter to remove all children and prepare them for the garbage 
		 * collection process without modifying the passed instance.
		 *************************************************************************/
		public static function cleanDisplayComponents( mainComponent : IUIComponent ):void {
			new DisplayListTraverser(applyCleanersStep1).applyToAll(mainComponent);
			new DisplayListTraverser(applyCleanersStep2).applyToAll(mainComponent);
			new DisplayListTraverser(removeElements).applyToAll(mainComponent);
		}
		
		private static function applyCleanersStep1(component : Object):void
		{
			for each (var cleaner:IDisplayObjectCleaner in step1)
			{
				if (cleaner.canCleanDisplayObject(component))
					cleaner.cleanDisplayObject(component);
			}
		}
		
		private static function applyCleanersStep2(component : Object):void
		{
			for each (var cleaner:IDisplayObjectCleaner in step2)
			{
				if (cleaner.canCleanDisplayObject(component))
					cleaner.cleanDisplayObject(component);
			}
		}
		
		private static function removeElements(component:Object):void
		{
			if(!(component is Grid))
				DisplayListUtil.removeAllElements(component);
		}
	}
}