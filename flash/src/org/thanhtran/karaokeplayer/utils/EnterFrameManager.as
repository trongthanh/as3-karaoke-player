/**
 * Copyright 2010 Thanh Tran - trongthanh@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.thanhtran.karaokeplayer.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	/**
	 * A single manager which centralizes all enter-frame handler
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