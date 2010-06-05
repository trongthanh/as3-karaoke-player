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
package {
	import fl.controls.Button;
	import org.thanhtran.karaokeplayer.lyrics.TextLine;
	import org.thanhtran.karaokeplayer.data.BlockInfo;
	import org.thanhtran.karaokeplayer.data.LineInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.thanhtran.karaokeplayer.lyrics.TextBlock;
	
	/**
	 * ...
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="1024", height="768")]
	public class Main extends Sprite {
		public var playButton: Button;
		private var bit:TextBlock;
		private var textBlock: TextLine;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			playButton = new Button();
			playButton.label = "Start";
			playButton.x = stage.stageWidth - playButton.width;
			playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler);
			addChild(playButton);
			
			//testTextBit();
			testTextBlock();
		}
		
		private function playButtonClickHandler(event: MouseEvent): void {
			//bit.play();
			textBlock.play();
		}

		/*
		 * test text bit:
		 */
		public function testTextBit(): void {
			
			bit = new TextBlock();
			bit.text = "Tran Trong Thanh";
			//bit.completed.add(bitCompleteHandler);
			addChild(bit);
			
		}
		
		public function testTextBlock(): void {
			var lb: LineInfo = new LineInfo();
			 
			var lbit1: BlockInfo = new BlockInfo();
			lbit1.text = "* * *";
			lbit1.duration = 2520;
			
			lb.lyricBlocks.push(lbit1);
			
			var lbit2: BlockInfo = new BlockInfo();
			lbit2.text = "Thắp nến đêm nay";
			lbit2.duration = 2000;
			
			lb.lyricBlocks.push(lbit2);
			
			var lbit3: BlockInfo = new BlockInfo();
			lbit3.text = "ấm áp trong tay";
			lbit3.duration = 1720;
			
			lb.lyricBlocks.push(lbit3);
			
			textBlock = new TextLine();
			textBlock.init(lb);
			textBlock.completed.add(textBlockCompleteHandler);
			
			addChild(textBlock);
		}

		private function textBlockCompleteHandler(tb: TextLine): void {
			trace("text block complete");
		}
	}
}