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
	import org.thanhtran.karaokeplayer.data.LyricStyle;
	import org.osflash.signals.Signal;
	import org.thanhtran.karaokeplayer.data.BlockInfo;
	import org.thanhtran.karaokeplayer.data.LineInfo;
	import flash.display.Sprite;
	/**
	 * A line of text
	 * @author Thanh Tran
	 */
	public class TextLine extends Sprite {
		
		include "../version.as";		
		
		/* complete event, param: TextLine */
		public var completed: Signal;
		public var blocks: Array;
		public var index: int;
		// these style are set from SongLyrics
		public var normalStyle: LyricStyle;
		public var syncStyle: LyricStyle;
		
		private var _data: LineInfo;
		/* number of blocks */
		private var _len: uint;
		private var _playing: Boolean;

		public function TextLine() {
			completed = new Signal(TextLine);
		}

		public function init(data: LineInfo): void {
			this._data = data;
			checkStyle();
			_len = data.lyricBlocks.length;
			
			blocks = new Array();
			var blockInfo: BlockInfo;
			var block: TextBlock;
			var lastX: Number = 0;
			for (var i : int = 0; i < _len; i++) {
				blockInfo = data.lyricBlocks[i];
				block = new TextBlock();
				block.setStyle(normalStyle, syncStyle);
				block.duration = blockInfo.duration;
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

		private function checkStyle(): void {
			syncStyle = _data.songLyrics.syncLyricStyle;
			switch(_data.styleName) {
				case LyricStyle.MALE:
					normalStyle = _data.songLyrics.maleLyricStyle;
					break;
				case LyricStyle.FEMALE:
					normalStyle = _data.songLyrics.femaleLyricStyle;
					break;
				case LyricStyle.BASIC:
				default:
					normalStyle = _data.songLyrics.basicLyricStyle;
			}
		}

		private function textBitCompleteHandler(tb: TextBlock): void {
//			trace('text bit ' + tb.text + ' complete, next:  ' + (tb.next));
			if(tb.next) {
				tb.next.play();
			} else {
				_playing = false;
				completed.dispatch(this);
			}
		}
		
		public function play(): void {
			for (var i : int = 0; i < _len; i++) {
				blocks[i].reset();
			}
			blocks[0].play();
			_playing = true;
		}

		public function dispose(): void {
			for (var i : int = 0; i < _len; i++) {
				blocks[i].dispose();
			}
		}
		
		public function get duration(): uint {
			return _data.duration;
		}
		
		/* timestamp millisecond */
		public function get startTime(): Number {
			return _data.startTime;
		}
		
		public function get playing(): Boolean {
			return _playing;
		}
		
		override public function toString(): String {
			var str: String = "Line {";
			for (var i : int = 0; i < _len; i++) {
				str += blocks[i].text;
			}
			return str + "}";
		}
	}
}