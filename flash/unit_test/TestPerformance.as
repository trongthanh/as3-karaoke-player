package  {
	import flash.utils.getTimer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	import vn.karaokeplayer.utils.EnterFrameManager;
	//import vn.karaokeplayer.utils.EnterFrameDispatcher;
	
	/**
	 * ...
	 * @author Thanh Tran
	 */
	//[Frame(factoryClass="vn.karaokeplayer.utils.EnterFrameDispatcher")]
	public class TestPerformance extends MovieClip {
		public var a: uint;
		public var eventsArr: Array = [];
		public var frame: Signal;
		public var enterFrameManager: EnterFrameManager;
		
		public function TestPerformance() {
			//addEventListener(Event.ENTER_FRAME, enterframeHandler);
			//frame = new Signal();
			//enterFrameManager = new EnterFrameManager();
			//enterFrameManager.enterFrame.add(enterframeHandler);
			//enterFrameManager.play();
			
			//test expression if(Boolean);
			testIfBoolean();
			//test expression if(Object)
			testIfObject();
			//test expression if(complex)
			testIfComplexExpression1();
			testIfComplexExpression2();
		
		}
		
		private function testIfComplexExpression1(): void {
			var start: int = getTimer();
			var obj: Object = {}
			var begin: Number = 1000;
			var end: Number = 2000;
			var pos: Number = 1500;
			for (var i : int = 0; i < 1000000; i++) {
				if(obj && begin < pos && end > pos) continue;
			}
			
			trace("testIfComplexExpression1 elapsed time: " + (getTimer() - start));
		}
		
		private function testIfComplexExpression2(): void {
			var start: int = getTimer();
			var obj: Object = {};
			var begin: Number = 1000;
			var end: Number = 2000;
			var pos: Number = 1500;
			for (var i : int = 0; i < 1000000; i++) {
				if(begin < pos && end > pos) continue;
			}
			
			trace("testIfComplexExpression2 w/o obj elapsed time: " + (getTimer() - start));
		}

		private function testIfBoolean(): void {
			var start: int = getTimer();
			var bool: Boolean = true;
			for (var i : int = 0; i < 1000000; i++) {
				if(bool) continue;
			}
			
			trace("testIfBoolean elapsed time: " + (getTimer() - start));
		}

		private function testIfObject(): void {
			var start: int = getTimer();
			var obj: Object = {};
			for (var i : int = 0; i < 1000000; i++) {
				if(obj) continue;
			}
			
			trace("testIfObject elapsed time: " + (getTimer() - start));
		}

		public function init(): void {
			//frame.add(enterframeHandler);
		}
		
		private function enterframeHandler(event: Event = null): void {
			a++;
			//eventsArr.push(event);
			trace(a);
		}
		
	}

}