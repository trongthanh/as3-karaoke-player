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
package vn.karaokeplayer.utils {
	import flash.display.Shape;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	/**
	 * A single manager which centralizes all enter-frame handler
	 * @author Thanh Tran
	 */
	public class EnterFrameManager extends Shape {
		private static var _instance: EnterFrameManager;

		private var _enterFrame: Signal; 
		
		public function EnterFrameManager() {
			if(_instance) {
				throw new Error("EnterFrameManager - Singleton exception");
			}
			_enterFrame = new Signal();
			//addFrameScript(0, enterFrameHandler, 1, enterFrameHandler);
			//my experiment has revealed that using a single enterframe event make no different
			//with 2-frame movie. So I decided to replace the 2-frame movie for simplicity
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(event: Event = null): void {
			enterFrame.dispatch();
		}
		
		public function get enterFrame(): Signal {
			return _enterFrame;
		}
		
		static public function get instance(): EnterFrameManager {
			if(!_instance) {
				_instance = new EnterFrameManager();
			}
			return _instance;
		}
	}
}