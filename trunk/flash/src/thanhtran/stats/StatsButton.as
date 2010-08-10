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

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	//import com.gskinner.motion.GTweener;


	/**
	 * This will wrap the Stats panel into a retractable button. It can be show/hide  
	 * @author Thanh Tran
	 */
	public class StatsButton extends Sprite {
		public static const STATS_WIDTH: int= 70;
		public static const STATS_HEIGHT: int= 100;
		
		public var stats: Stats;
		private var showButton: Sprite;
		private var showButtonLabel: TextField;
		
		
		public function StatsButton(defaultShow: Boolean = false) {
			stats = new Stats();
			addChild(stats);
			
			createStatButton(defaultShow);
			addChild(showButton);
			
			this.y = (defaultShow)? 0 : -STATS_HEIGHT;
		}
		
		private function createStatButton(defaultShow: Boolean): void {
			showButton = new Sprite();
			showButtonLabel = new TextField();
			showButtonLabel.width = STATS_WIDTH;
			showButtonLabel.autoSize = "center";
			showButtonLabel.defaultTextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
			showButtonLabel.text = (defaultShow)? "Hide Stats":"Show Stats"
			showButtonLabel.mouseEnabled = false;
			
			var g: Graphics = showButton.graphics;
			g.beginFill(0x333333);
			g.drawRect(0, 0, STATS_WIDTH, showButtonLabel.height);
			g.endFill();
			showButton.addChild(showButtonLabel);
			showButton.y = STATS_HEIGHT;
			showButton.buttonMode = true;
			
			showButton.addEventListener(MouseEvent.ROLL_OVER, buttonRollOverHandler);
			showButton.addEventListener(MouseEvent.ROLL_OUT, buttonRollOutHandler);
			showButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			
		}

		private function buttonRollOutHandler(event: MouseEvent): void {
			showButtonLabel.textColor = 0xFFFFFF;
		}

		private function buttonRollOverHandler(event: MouseEvent): void {
			showButtonLabel.textColor = 0xFFFF00;
		}

		private function buttonClickHandler(event: MouseEvent): void {
			if(showButtonLabel.text == "Show Stats") {
//				GTweener.to(this, 0.3, {y:0});
				this.y = 0;
				showButtonLabel.text = "Hide Stats";
			} else {
				this.y = -STATS_HEIGHT;
				//GTweener.to(this, 0.3, {y:-STATS_HEIGHT});
				showButtonLabel.text = "Show Stats";
			}
			
		}
	}
}
