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
package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	/**
	 * 
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#000000", frameRate="30", width="600", height="400")]
	public class AppDoc extends MovieClip {
		
		public var main: Sprite
		public var loadingLabel: TextField;
		
		public function AppDoc() {
			stop();
			loadingLabel = new TextField();
			loadingLabel.autoSize = "left";
			loadingLabel.defaultTextFormat = new TextFormat("_sans", 16, 0xFFFFFF);
			loadingLabel.text = "Loading...";
			addChild(loadingLabel);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event: Event): void {
			play();
			if (currentFrame == totalFrames) {
				this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				stop();
				startup();
			}
		}
		
		protected function startup():void {
			var mainClass:Class = getDefinitionByName("Main") as Class;
			main = new mainClass() as Sprite;
			addChildAt(main, 0);
			removeChild(loadingLabel);
		}
		
	}

}