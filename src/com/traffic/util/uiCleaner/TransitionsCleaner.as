package com.sohnar.traffic.util {
	
	import com.adobe.cairngorm.contract.Contract;
	
	import mx.core.UIComponent;
	import mx.effects.IEffect;
	import mx.states.Transition;

	public class TransitionsCleaner implements IDisplayObjectCleaner {
		
		//Not ideal but quicker than reflection
		private static const EFFECT_NAMES:Array = [
			"creationCompleteEffect",
			"moveEffect",
			"resizeEffect",
			"showEffect",
			"hideEffect",
			"mouseDownEffect",
			"mouseUpEffect",
			"rollOverEffect",
			"rollOutEffect",
			"focusInEffect",
			"focusOutEffect",
			"addedEffect",
			"removedEffect"];
		
		public function canCleanDisplayObject(object:Object):Boolean {
			return object is UIComponent && UIComponent(object).transitions;
		}
		
		public function cleanDisplayObject(object:Object):void {
			Contract.precondition(object is UIComponent);
			var component:UIComponent = object as UIComponent;
			cleanEffects(component);
			cleanTransitions(component);
		}
		
		private function cleanEffects(component:UIComponent):void {
			for each (var effectName:String in EFFECT_NAMES) {
				var effect:IEffect = component.getStyle(effectName) as IEffect;
				if (effect)
					cleanEffect(effect);
			}
		}
		
		private function cleanTransitions(component:UIComponent):void {
			for each (var transition:Object in component.transitions) {
				if (transition is Transition)
					cleanTransition(transition as Transition);
			}
			component.transitions = null;
		}
		
		private function cleanTransition(transition:Transition):void {
			Contract.precondition(transition != null);
			if (transition.effect) {
				cleanEffect(transition.effect);
				transition.effect = null;
			}
		}
		
		private function cleanEffect(effect:IEffect):void {
			Contract.precondition(effect != null);
			
			if (effect.isPlaying)
				effect.end();
			
			effect.target = null;
			effect.targets = [];
			effect.triggerEvent = null;
			effect.effectTargetHost = null;
			effect.customFilter = null;
		}
	}
}