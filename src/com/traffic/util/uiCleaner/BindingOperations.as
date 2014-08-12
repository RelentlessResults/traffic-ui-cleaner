package com.sohnar.traffic.util
{
	import mx.binding.Binding;
	import mx.core.mx_internal;

	public class BindingOperations
	{
		/*************************************************************************
		 * The cleanBinding() function is a private helper for cleanBindings().
		 *************************************************************************/
		static public function cleanBinding( binding : Binding ):void
		{
			binding.mx_internal::document = null;
			binding.mx_internal::srcFunc = null;
			binding.mx_internal::destFunc = null;
			binding.mx_internal::destString = null;
			binding.twoWayCounterpart = null;
		}
	}
}