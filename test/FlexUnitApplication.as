package
{
	import Array;
	
	import flash.display.Sprite;
	
	import flexunit.flexui.FlexUnitTestRunnerUIAS;
	
	import org.robotlegs.base.SignalCommandMapTests;
	import org.robotlegs.mvcs.SignalCommandTests;
	import org.robotlegs.mvcs.SignalContextTests;
	
	public class FlexUnitApplication extends Sprite
	{
		public function FlexUnitApplication()
		{
			onCreationComplete();
		}
		
		private function onCreationComplete():void
		{
			var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
			this.addChild(testRunner); 
			testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "robotlegs-modular-signals");
		}
		
		public function currentRunTestSuite():Array
		{
			var testsToRun:Array = new Array();
			testsToRun.push(org.robotlegs.mvcs.SignalContextTests);
			testsToRun.push(org.robotlegs.mvcs.SignalCommandTests);
			testsToRun.push(org.robotlegs.base.SignalCommandMapTests);
			return testsToRun;
		}
	}
}