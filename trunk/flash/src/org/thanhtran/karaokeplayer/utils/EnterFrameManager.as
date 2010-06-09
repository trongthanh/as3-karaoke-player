package org.thanhtran.karaokeplayer.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Thanh Tran
	 */
	public class EnterFrameManager extends TwoFrameMovie {
		public var enterFrame: Signal;
		
		public function EnterFrameManager() {
			enterFrame = new Signal();
			addFrameScript(0, enterFrameHandler, 1, enterFrameHandler);
			//stop();
			//addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event: Event = null): void {
			enterFrame.dispatch();
		}
		
	}

}