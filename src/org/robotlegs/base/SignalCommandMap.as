package org.robotlegs.base
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	import org.osflash.signals.*;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.ISignalCommandMap;

	public class SignalCommandMap implements ISignalCommandMap
	{
		protected var _injector:IInjector;
		protected var _signalMap:Dictionary;
		protected var _signalClassMap:Dictionary;
		protected var _verifiedCommandClasses:Dictionary;

		public function SignalCommandMap(injector:IInjector)
		{
			_injector = injector;
			_signalMap = new Dictionary(false);
			_signalClassMap = new Dictionary(false);
			_verifiedCommandClasses = new Dictionary(false);
		}

		public function mapSignal(signal:ISignal, commandClass:Class, oneShot:Boolean = false, argumentNames:Array = null):void
		{
			verifyCommandClass(commandClass);
			if (hasSignalCommand(signal, commandClass))
				return;

			var signalCommandMap:Dictionary = _signalMap[signal] = _signalMap[signal] || new Dictionary(false);
			var callback:Function = function(a:* = null, b:* = null, c:* = null, d:* = null, e:* = null, f:* = null, g:* = null):void
			{
				routeSignalToCommand(signal, arguments, commandClass, oneShot, argumentNames);
			};

			signalCommandMap[commandClass] = callback;
			signal.add(callback);
		}

		public function mapSignalClass(signalClass:Class, commandClass:Class, oneShot:Boolean = false, argumentNames:Array = null):ISignal
		{
			var signal:ISignal = getSignalClassInstance(signalClass);
			mapSignal(signal, commandClass, oneShot, argumentNames);
			return signal;
		}

		private function getSignalClassInstance(signalClass:Class):ISignal
		{
			return ISignal(_signalClassMap[signalClass]) || createSignalClassInstance(signalClass);
		}

		private function createSignalClassInstance(signalClass:Class):ISignal
		{
			var signal:ISignal = _injector.instantiate(signalClass);
			_injector.mapValue(signalClass, signal);
			_signalClassMap[signalClass] = signal;
			return signal;
		}

		public function hasSignalCommand(signal:ISignal, commandClass:Class):Boolean
		{
			var callbacksByCommandClass:Dictionary = _signalMap[signal];
			if (callbacksByCommandClass == null)
				return false;
			
			var callback:Function = callbacksByCommandClass[commandClass];
			return callback != null;
		}

		public function unmapSignal(signal:ISignal, commandClass:Class):void
		{
			var callbacksByCommandClass:Dictionary = _signalMap[signal];
			if (callbacksByCommandClass == null)
				return;

			var callback:Function = callbacksByCommandClass[commandClass];
			if (callback == null)
				return;

			signal.remove(callback);
			delete callbacksByCommandClass[commandClass];
		}

		public function unmapSignalClass(signalClass:Class, commandClass:Class):void
		{
			unmapSignal(getSignalClassInstance(signalClass), commandClass);
		}

		protected function mapValues(valueObjects:Array, valueClasses:Array, argumentNames:Array):void
		{
			var i:int;
			var value:Object;
			if (valueClasses && argumentNames)
			{
				if (valueObjects.length != valueClasses.length || valueObjects.length != argumentNames.length)
					throw new Error("Unequal numbers of arguments");

				var valueObjects_length:int = valueObjects.length;
				for (i = 0; i < valueObjects_length; i++)
					_injector.mapValue(valueClasses[int(i)], valueObjects[int(i)], argumentNames[int(i)]);
			}
			else if (valueClasses && valueClasses.length > 0)
			{
				if (valueObjects.length != valueClasses.length)
					throw new Error("Unequal numbers of arguments");

				var valueClasses_length:uint = valueClasses.length;
				for (i = 0; i < valueClasses_length; i++)
					_injector.mapValue(valueClasses[int(i)], valueObjects[int(i)]);
			}
			else
			{
				for each (value in valueObjects)
					_injector.mapValue(value.constructor, value);
			}
		}

		protected function unmapValues(valueObjects:Array, valueClasses:Array, argumentNames:Array):void
		{
			var i:int;
			var value:Object;
			var valueClasses_length:uint;
			if (valueClasses && argumentNames)
			{
				valueClasses_length = valueClasses.length;
				for (i = 0; i < valueClasses_length; i++)
					_injector.unmap(valueClasses[int(i)], argumentNames[int(i)]);
			}
			else if (valueClasses && valueClasses.length > 0)
			{
				valueClasses_length = valueClasses.length;
				for (i = 0; i < valueClasses_length; i++)
					_injector.unmap(valueClasses[int(i)]);
			}
			else
			{
				for each (value in valueObjects)
					_injector.unmap(value.constructor);
			}
		}

		protected function routeSignalToCommand(signal:ISignal, valueObjects:Array, commandClass:Class, oneshot:Boolean, argumentNames:Array):void
		{
			mapValues(valueObjects, signal.valueClasses, argumentNames);

			var command:Object = _injector.instantiate(commandClass);

			unmapValues(valueObjects, signal.valueClasses, argumentNames);

			command.execute();

			if (oneshot)
				unmapSignal(signal, commandClass);
		}

		protected function verifyCommandClass(commandClass:Class):void
		{
			if (_verifiedCommandClasses[commandClass])
				return;

			if (describeType(commandClass).factory.method.(@name == "execute").length() != 1)
				throw new ContextError(ContextError.E_COMMANDMAP_NOIMPL + ' - ' + commandClass);

			_verifiedCommandClasses[commandClass] = true;
		}
	}
}
