package  {
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
	public class TestEnterFrame extends MovieClip {
		public var a: uint;
		public var eventsArr: Array = [];
		public var frame: Signal;
		public var enterFrameManager: EnterFrameManager;
		
		public function TestEnterFrame() {
			//addEventListener(Event.ENTER_FRAME, enterframeHandler);
			//frame = new Signal();
			enterFrameManager = new EnterFrameManager();
			enterFrameManager.enterFrame.add(enterframeHandler);
			//enterFrameManager.play();
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