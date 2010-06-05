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
package org.thanhtran.karaokeplayer.lyrics {
	import org.osflash.signals.Signal;
	import org.thanhtran.karaokeplayer.data.BlockInfo;
	import org.thanhtran.karaokeplayer.data.LineInfo;
	import flash.display.Sprite;
	/**
	 * A line of text
	 * @author Thanh Tran
	 */
	public class TextLine extends Sprite {
		public var completed: Signal;
		/* timestamp millisecond */
		public var startTime: Number;
		public var blocks: Array;
		
		public var duration: uint = 0;
		private var data: LineInfo;
		/* number of bits */
		private var len: uint;
		

		public function TextLine() {
			completed = new Signal(TextLine);
		}

		public function init(data: LineInfo): void {
			this.data = data;
			len = data.lyricBlocks.length;
			blocks = new Array();
			var blockInfo: BlockInfo;
			var block: TextBlock;
			var lastX: Number = 0;
			for (var i : int = 0; i < len; i++) {
				blockInfo = data.lyricBlocks[i];
				block = new TextBlock();
				block.duration = blockInfo.duration;
				//calculate block duration
				duration += block.duration; 
				block.text = blockInfo.text;
				block.completed.add(textBitCompleteHandler);
				blocks.push(block);
				if(i > 0) {
					TextBlock(blocks[i - 1]).next = block;
				}
				//render
				block.x = lastX;
				addChild(block);
				lastX += block.width;
			} 
		}

		private function textBitCompleteHandler(tb: TextBlock): void {
//			trace('text bit ' + tb.text + ' complete, next:  ' + (tb.next));
			if(tb.next) {
				tb.next.play();
			} else {
				completed.dispatch(this);
			}
		}
		
		public function play(): void {
			for (var i : int = 0; i < len; i++) {
				blocks[i].reset();
			}
			blocks[0].play();
		}
		
		public function dispose(): void {
			for (var i : int = 0; i < len; i++) {
				blocks[i].dispose();
			}
		}
	}

}