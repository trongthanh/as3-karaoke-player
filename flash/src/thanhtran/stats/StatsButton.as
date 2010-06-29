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
package thanhtran.stats {
	import net.hires.debug.Stats;

	import com.bit101.components.PushButton;
	import com.gskinner.motion.GTweener;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Thanh Tran
	 */
	public class StatsButton extends Sprite {
		public static const STATS_WIDTH: int= 70;
		public static const STATS_HEIGHT: int= 100;
		
		public var stats: Stats;
		public var showButton: PushButton;
		
		public function StatsButton() {
			stats = new Stats();
			addChild(stats);
			
			showButton = new PushButton();
			showButton.label = "Show Stats";
			showButton.width = STATS_WIDTH;
			showButton.y = STATS_HEIGHT;
			showButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			addChild(showButton);
			
			this.y = -STATS_HEIGHT;
		}

		private function buttonClickHandler(event: MouseEvent): void {
			if(showButton.label == "Show Stats") {
				GTweener.to(this, 0.3, {y:0});
				showButton.label = "Hide Stats";
			} else {
				GTweener.to(this, 0.3, {y:-STATS_HEIGHT});
				showButton.label = "Show Stats";
			}
			
		}
	}
}
